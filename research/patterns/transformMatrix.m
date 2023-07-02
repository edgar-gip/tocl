%% -*- mode: octave; -*-

%% Transform a Matrix

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus


%%%%%%%%%%%%%
%% Helpers %%
%%%%%%%%%%%%%

%% Read lines
function [ lines ] = read_lines(file)
  %% Open the file
  f = fopen(file, "r");

  %% Starting size and position
  size = 16;
  pos  =  0;

  %% Result
  lines = resize({}, size, 1);

  %% Can we read a line
  line = fgetl(f);
  while line ~= -1
    %% One more
    pos += 1;
    if pos > size
      %% Double
      lines = resize(lines, size *= 2, 1);
    endif

    %% Add it
    lines{pos} = line;

    %% Next
    line = fgetl(f);
  endwhile

  %% Remove unused
  lines = resize(lines, pos, 1);
endfunction


%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%

%% Default options
def_opts           = struct();
def_opts.freq_th   = [];
def_opts.mi_cheat  = false();
def_opts.mi_feats  = [];
def_opts.norm_norm = false();
def_opts.norm_sum  = false();
def_opts.sparse    = false();
def_opts.tf_idf    = false();
def_opts.verbose   = false();

%% Parse options
[ cmd_args, cmd_opts ] = ...
    get_options(def_opts, ...
                "freq-th=i",  "freq_th",   ...
                "mi-cheat!",  "mi_cheat",  ...
                "mi-feats=i", "mi_feats",  ...
                "norm-norm!", "norm_norm", ...
                "norm-sum!",  "norm_sum",  ...
                "sparse!",    "sparse",    ...
                "tf-idf!",    "tf_idf",    ...
                "verbose!",   "verbose");

%% Usage
usage = cstrcat("Usage: transformMatrix.m [options] <input> <output>\n", ...
                "       transformMatrix.m [options] --sparse <matrix>",  ...
                " <features> <output>");

%% Input and output
try
  if cmd_opts.sparse
    if length(cmd_args) ~= 3
      error(usage);
    endif

    input_f  = cmd_args{1};
    feats_f  = cmd_args{2};
    output_f = cmd_args{3};

    [ data, truth ] = read_sparse(input_f, true());
    feats           = read_lines(feats_f);

  else
    if length(cmd_args) ~= 2
      error(usage);
    endif

    input_f  = cmd_args{1};
    output_f = cmd_args{2};

    load(input_f, "data", "feats", "truth");
  endif

catch
  error("Cannot load data: %s", lasterr());
end_try_catch

%% Size
[ n_feats, n_data ] = size(data);

%% Apply frequency threshold
if ~isempty(cmd_opts.freq_th)

  %% Feature frequency
  feat_freq = full(sum(data > 0, 2));

  %% Kept feats
  kept_feats = find(feat_freq >= cmd_opts.freq_th);
  n_feats    = length(kept_feats);

  %% Keep only those above it
  data = data(kept_feats, :);

  %% Feats
  feats = { feats{kept_feats} };
endif

%% Apply mutual information
if ~isempty(cmd_opts.mi_feats) && n_feats > cmd_opts.mi_feats

  %% Cheat?
  if cmd_opts.mi_cheat
    %% Expectation -> C * D
    expec = sparse(truth, 1 : n_data, ones(1, n_data));

    %% Source data is the sum by classes
    src_data   = data * expec';
    n_src_data = size(src_data, 1);

    %% Probability of a class
    %% p(x) -> 1 * C
    p_x = sum(expec, 2)' / n_data;

  else
    %% Source data is raw data
    src_data   = data;
    n_src_data = n_data;

    %% Probability of a document
    %% p(x) -> 1 * D
    p_x = 1.0 / n_src_data * ones(1, n_data);
  endif

  %% Document length
  %% l(x) -> 1 * X
  l_x = sum(src_data, 1);

  %% Probability of a word given a document
  %% p(w | x) -> W * X
  p_w_by_x = src_data * diag(1 ./ l_x);

  %% Probability of a word
  %% p(w) = \sum_x p(w | x) * p(x) -> W * 1
  p_w = sum(p_w_by_x * diag(p_x), 2);

  %% Probability of a document given a word
  %% p(x | w) = \frac{p(w | x) * p(x)}{p(w)} -> W * X
  p_x_by_w = diag(1 ./ p_w) * p_w_by_x * diag(p_x);

  %% Probability quotient
  %% p(x | w) / p(x) -> W * X
  p_x_by_w__p_x = p_x_by_w * diag(1 ./ p_x);

  %% Product matrix
  %% p(x | w) * log(p(x | w) / p(x)) -> W * X
  prod_matrix                  = p_x_by_w;
  prod_matrix(p_x_by_w ~= 0) .*= log(p_x_by_w__p_x(p_x_by_w ~= 0));

  %% Kullback Leibler
  %% kl(w) = \sum_x p(x | w) * log(p(x | w) / p(x))
  kl_w = sum(prod_matrix, 2);

  %% Mutual information
  %% mi(w) = p(w) * \sum_x  p(x | w) * log(p(x | w) / p(x))
  %%       = p(w) * kl(w)
  mi_w = p_w .* kl_w;

  %% Sort them
  [ max_mi, max_feats ] = sort(mi_w, "descend");

  %% Kept feats
  kept_feats = max_feats(1 : cmd_opts.mi_feats);
  n_feats    = cmd_opts.mi_feats;

  %% New data
  data = data(kept_feats, :);

  %% Feats
  feats = { feats{kept_feats} };

  %% Display
  if cmd_opts.verbose
    for f = 1 : n_feats
      kf = kept_feats(f);
      fprintf(2, "%5d  %-20s  p: %.6f  kl: %.6f  mi: %.6f\n",
              f, words{f}, p_w(kf), kl_w(kf), mi_w(kf));
    endfor
  endif
endif

%% Find tf-idf
if cmd_opts.tf_idf
  %% Document frequency
  df  = sum(data > 0, 2);
  idf = log(n_data ./ df);

  %% Scale
  data = sparse(diag(idf)) * data;
endif

%% Normalize
if cmd_opts.norm_sum
  %% Find the norm
  norm = sum(data, 1);

  %% Invert non-zeros
  nz       = (norm ~= 0);
  norm(nz) = 1 ./ norm(nz);

  %% Scale
  data *= sparse(diag(norm));

elseif cmd_opts.norm_norm
  %% Find the norm
  norm = sqrt(sum(data .* data, 1));

  %% Invert non-zeros
  nz       = (norm ~= 0);
  norm(nz) = 1 ./ norm(nz);

  %% Scale
  data *= sparse(diag(norm));
endif

%% Save
try
  save("-binary", "-zip", output_f, "data", "truth", "feats");
catch
  error("Cannot save data to '%s': %s", output_f, lasterr());
end_try_catch
