%% -*- mode: octave; -*-

%% Minority clustering of data

%% Author: Edgar Gonzàlez i Pellicer


%% Division by zero
%% warning error Octave:divide-by-zero;

%% Octopus
pkg load octopus;

%% Ando elements
source(binrel("andoElements.m"));


%%%%%%%%%%%%%%%%
%% Evaluation %%
%%%%%%%%%%%%%%%%

function [ n_pos_cl, prc, rec, nrec, f1 ] = eval_expec(expec, struth, n_data)
  %% Positive cluster
  pos_cl = find(sum(expec, 1)); n_pos_cl = length(pos_cl);

  %% Truth
  pos_tr = find(struth); n_pos_tr = length(pos_tr);
  n_neg_tr = n_data - n_pos_tr;

  %% The good (and the bad) ones
  n_pos_pos = length(intersect(pos_cl, pos_tr));
  n_neg_pos = n_pos_cl - n_pos_pos;

  %% Prc/Rec/F1
  prc  = n_pos_pos / n_pos_cl;
  rec  = n_pos_pos / n_pos_tr;
  nrec = n_neg_pos / n_neg_tr;
  f1   = 2 * prc * rec / (prc + rec);
endfunction


%%%%%%%%%%
%% Main %%
%%%%%%%%%%

%% Get the parameters
args = argv();

%% Full level
full_level = 1;
if length(args) > 1
  switch args{1}
    case "--basic"
      %% full_level = 1
      args       = { args{2 : length(args)} };
    case "--full"
      full_level = 2;
      args       = { args{2 : length(args)} };
    case "--extra"
      full_level = 3;
      args       = { args{2 : length(args)} };
  endswitch
endif

%% Check parameter length
if ~any(length(args) == [ 7, 8, 9 ])
  error(cstrcat("Wrong number of arguments: Expected", ...
                " <input> <distance> <d-extra> <method> <m-extra>", ...
                " <k> <seed> [<output> [<scores>]]"));
endif

%% Input file
input = args{1};
try
  load(input, "data", "truth");
catch
  error("Cannot load data from '%s': %s", input, lasterr());
end_try_catch

%% Distance
dist = args{2};
if ~isfield(distances, dist)
  error("Wrong distance name '%s'. Must be: %s", dist, fields(distances));
endif

%% Extra arguments
dextra = regex_split(args{3}, '(,|\s+,)\s*');

%% Method
met = args{4};
if ~isfield(methods, met)
  error("Wrong method name '%s'. Must be: %s", met, fields(methods));
endif

%% Extra arguments
mextra = regex_split(args{5}, '(,|\s+,)\s*');

%% Enough args?
req_args = getfield(methods, met, "args");
if length(mextra) ~= req_args
  error("Method '%s' requires %d extra arg(s): %s",
        met, req_args, getfield(methods, met, "help"));
endif

%% k
if length(args{6}) == 0
  k = [];
else
  k = parse_double(args{6}, "number of clusters");
endif

%% Seed
seed = parse_double(args{7}, "seed");

%% Output
if length(args) >= 8
  output = args{8};
  [ fout, status ] = fopen(output, "wt");
  if fout == -1
    error("Cannot open output '%s': %s", output, status);
  endif
else
  fout = 1;
endif


%% Initialize seed
set_all_seeds(seed);

%% Create distance
distfun = getfield(distances, dist);
if isfunctionhandle(distfun)
  distance = distfun(data, dextra);
else
  distance = distfun;
endif

%% Truth information
n_data = length(truth);
struth = truth > 1;

%% Create clusterer
clustfun  = getfield(methods, met, "make");
clusterer = clustfun(distance, data, struth, mextra);

%% Cluster
[ total0, user0, system0 ] = cputime();
[ expec, model ] = cluster(clusterer, data, k);
[ total1, user1, system1 ] = cputime();

%% Time difference
cluster_time = total1 - total0;

%% Is it a scored method?
if getfield(methods, met, "scor")
  %% Scored method

  %% Sort by score
  scores = score(model, data);
  [ sort_scores, sort_idx ] = sort(scores, "descend");
  sort_data   = data(:, sort_idx);
  sort_struth = struth(sort_idx);

  %% Map scores
  [ msort_scores, msort_model ] = apply(LinearInterpolator(), sort_scores);

  %% Truth classes
  pos_tr  = find( sort_struth); n_pos_tr = length(pos_tr);
  neg_tr  = find(~sort_struth); n_neg_tr = length(neg_tr);

  %% ROC

  %% Find accumulated positive and negative
  acc_pos = cumsum( sort_struth);
  acc_neg = cumsum(~sort_struth);

  %% Find ROC
  roc_pos = acc_pos ./ n_pos_tr;
  roc_neg = acc_neg ./ n_neg_tr;

  %% AUC
  auc = sum(diff(roc_neg) .* ...
            (roc_pos(1 : n_data - 1) + roc_pos(2 : n_data))) / 2;

  %% Prc/Rec/F1 curves
  prc_c = acc_pos ./ (acc_pos .+ acc_neg);
  rec_c = acc_pos ./  acc_pos(n_data);
  f1_c  = (2 .* prc_c .* rec_c) ./ (prc_c .+ rec_c);

  %% Display
  fprintf(fout, "*** %8g %5.3f ***\n", cluster_time, auc);

  %% For each threshold
  ths = getfield(methods, met, "ths");
  for th = ths

    %% Must we do it?
    %% -> Full output or basic threshold
    if full_level >= getfield(th, "level")

      %% Find the threshold
      thfun    = getfield(th, "find");
      th_value = thfun(sort_scores, sort_data, sort_struth, msort_scores, ...
                       msort_model, f1_c, model);

      %% Negative/positive cluster
      pos_cl = find(sort_scores >= th_value); n_pos_cl = length(pos_cl);
      neg_cl = find(sort_scores <  th_value);

      %% Intersections
      pos_pos = intersect(pos_tr, pos_cl);
      pos_neg = intersect(pos_tr, neg_cl);
      neg_pos = intersect(neg_tr, pos_cl);
      neg_neg = intersect(neg_tr, neg_cl);

      %% Sizes
      n_pos_pos = length(pos_pos);
      n_pos_neg = length(pos_neg);
      n_neg_pos = length(neg_pos);
      n_neg_neg = length(neg_neg);

      %% Precision/Recall
      prc  = n_pos_pos / (n_pos_pos + n_neg_pos);
      rec  = n_pos_pos / (n_pos_pos + n_pos_neg);
      nrec = n_neg_pos / (n_neg_pos + n_neg_neg);
      f1   = 2 * prc * rec / (prc + rec);

      %% Output

      %% Display
      fprintf(fout, "%7s %5d  %5.3f %5.3f %5.3f %5.3f\n", ...
              getfield(th, "name"), n_pos_cl, prc, rec, nrec, f1);
    endif
  endfor

  %% Evaluate the expectation?
  if getfield(methods, met, "xpec")
    %% Eval
    [ n_pos_cl, prc, rec, nrec, f1 ] = eval_expec(expec, struth, n_data);

    %% Display
    fprintf(fout, "%7s %5d  %5.3f %5.3f %5.3f %5.3f\n", ...
            "Model", n_pos_cl, prc, rec, nrec, f1);
  endif

else
  %% Non-scored method

  %% Eval
  [ n_pos_cl, prc, rec, nrec, f1 ] = eval_expec(expec, struth, n_data);

  %% ROC is a quadrilateral
  %% AUC = rec * nrec / 2 + rec * (1 - nrec) + (1 - rec) * (1 - nrec) / 2
  auc = (1 + rec - nrec) / 2;

  %% Truth
  pos_tr = find(struth); n_pos_tr = length(pos_tr);
  n_neg_tr = n_data - n_pos_tr;

  %% All Prc/F1
  all_prc = n_pos_tr / n_data;
  all_f1  = 2 * all_prc / (1 + all_prc);

  %% Display
  fprintf(fout, "*** %8g %5.3f ***\n", cluster_time, auc);
  fprintf(fout, "%7s %5d  %5.3f %5.3f %5.3f %5.3f\n", ...
          "All", n_data, all_prc, 1.0, 1.0, all_f1);
  fprintf(fout, "%7s %5d  %5.3f %5.3f %5.3f %5.3f\n", ...
          "Model", n_pos_cl, prc, rec, nrec, f1);
endif

%% Close output
if fout ~= 1
  fclose(fout);
endif

%% Save?
if length(args) >= 9
  try
    save("-binary", "-zip", args{9}, "scores");
  catch
    error("Cannot save data to '%s': %s", args{9}, lasterr());
  end_try_catch
endif
