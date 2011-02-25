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
def_opts.mi_feats  = [];
def_opts.normalize = false();
def_opts.sparse    = false();
def_opts.words     = [];

%% Parse options
[ cmd_args, cmd_opts ] = ...
    get_options(def_opts, ...
		"freq-th=i",  "freq_th", ...
		"mi-feats=i", "mi_feats", ...
		"normalize!", "normalize", ...
		"sparse!",    "sparse", ...
		"words=s",    "words");

%% Input and output
if length(cmd_args) ~= 2
  error("Usage: transformMatrix.m [options] <input> <output>");
endif
input  = cmd_args{1};
output = cmd_args{2};

%% Load
try
  if cmd_opts.sparse
    [ data, truth ] = read_sparse(input, true());
  else
    load(input, "data", "truth");
  endif
catch
  error("Cannot load data from '%s': %s", input, lasterr());
end_try_catch

%% Word list
if ~isempty(cmd_opts.words)
  %% Read it
  try
    [ words ] = read_lines(cmd_opts.words);
  catch
    error("Cannot load word list from '%s': %s", cmd_opts.words, lasterr());
  end_try_catch
else
  words = {};
endif

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

  %% Words
  if ~isempty(words)
    words = words{kept_feats};
  endif
else
  %% Keep all
  kept_feats = 1 : n_feats;
endif

%% Apply mutual information
if ~isempty(cmd_opts.mi_feats) && n_feats > cmd_opts.mi_feats

  %% Convert to probabilities
  n_words  = sum(data, 1);
  p_w_by_x = data ./ (ones(n_feats, 1) * n_words); % p(w | x)

  %% Probability of a document
  p_x = 1.0 ./ n_data;

  %% Probability of a word
  p_w = sum(p_w_by_x, 2) .* p_x; % p(w)

  %% Probability of a document given a word
  p_x_by_w = (p_w_by_x * p_x) ./ (p_w * ones(1, n_data));

  %% Product matrix
  prod_matrix                  = p_x_by_w;
  prod_matrix(p_x_by_w ~= 0) .*= log(p_x_by_w(p_x_by_w ~= 0) ./ p_x);

  %% Mutual information
  mi = p_w .* sum(prod_matrix, 2);

  %% Sort them
  [ max_mi, max_feats ] = sort(mi, "descend");

  %% Kept feats
  rekept_feats = max_feats(1 : cmd_opts.mi_feats);
  kept_feats   = kept_feats(rekept_feats);

  %% New data
  data = data(rekept_feats, :);

  %% Words
  if ~isempty(words)
    %% Display
    for f = rekept_feats
      fprintf(2, "%d(%s) -> %.3f", kept_feats(f), words(f), mi(f));
    endfor

    %% Update
    words = words{rekept_feats};
  endif
endif

%% Normalize (as a distribution)
if cmd_opts.normalize
  %% Do it
  data ./= ones(n_feats, 1) * sum(data);
endif

%% Save
try
  save("-binary", "-zip", output, "data", "truth", "kept_feats");
catch
  error("Cannot save data to '%s': %s", output, lasterr());
end_try_catch
