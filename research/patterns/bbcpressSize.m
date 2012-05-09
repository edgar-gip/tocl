%% -*- mode: octave; -*-

%% BBCPress size parameter influence

%% Author: Edgar Gonzàlez i Pellicer


%% Division by zero
%% warning error Octave:divide-by-zero;

%% Octopus
pkg load octopus;

%% Ando elements
source(binrel("andoElements.m"));


%%%%%%%%%%%%%%
%% Evaluate %%
%%%%%%%%%%%%%%

%% Evaluate
function [ n_pos_cl, prc, rec, nrec, f1 ] = ...
      evaluate(sort_scores, th_value, pos_tr, neg_tr)

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

endfunction


%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%

%% Default options
def_opts             = struct();
def_opts.min_ratio   = 0.05;
def_opts.max_ratio   = 0.95;
def_opts.ratio_steps = 18;

%% Parse options
[ cmd_args, cmd_opts ] = ...
    get_options(def_opts, ...
		"min-ratio=f",   "min_ratio", ...
		"max-ratio=f",   "max_ratio", ...
		"ratio-steps=i", "ratio_steps");

%% Check parameter length
if length(cmd_args) ~= 5
  error(cstrcat("Wrong number of arguments: Expected", ...
		" <input> <distance> <d-extra> <k> <seed>"));
endif

%% Input file
input = cmd_args{1};
try
  load(input, "data", "truth");
catch
  error("Cannot load data from '%s': %s", input, lasterr());
end_try_catch

%% Distance
dist = cmd_args{2};
if ~isfield(distances, dist)
  error("Wrong distance name '%s'. Must be: %s", dist, fields(distances));
endif

%% Extra arguments
dextra = regex_split(cmd_args{3}, '(,|\s+,)\s*');

%% k
k = parse_double(cmd_args{4}, "number of clusters");

%% Seed
seed = parse_double(cmd_args{5}, "seed");

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

%% Ratios
ratios = cmd_opts.min_ratio + ...
        (cmd_opts.max_ratio - cmd_opts.min_ratio) * ...
        [ 0 : cmd_opts.ratio_steps ] / cmd_opts.ratio_steps;

%% True ratio
true_ratio = sum(struth) / length(struth);
ratios = union(ratios, [ true_ratio ]);

%% Try all ratios
for ratio = ratios

  %% Initialize seed
  set_all_seeds(seed);

  %% Clusterer
  clusterer = BBCPress(distance, struct("size_ratio", ratio));

  %% Cluster
  [ total0, user0, system0 ] = cputime();
  [ expec, model ] = cluster(clusterer, data, k);
  [ total1, user1, system1 ] = cputime();

  %% Time difference
  cluster_time = total1 - total0;


  %% Scores

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


  %% Best threshold

  %% Threshold
  [ best_f1, best_idx ] = max(f1_c);
  best_th = sort_scores(best_idx);

  %% Evaluate
  [ best_n_pos_cl, best_prc, best_rec, best_nrec, best_f1 ] = ...
      evaluate(sort_scores, best_th, pos_tr, neg_tr);


  %% Model threshold

  %% Threshold
  size_th = threshold(model);

  %% Evaluate
  [ size_n_pos_cl, size_prc, size_rec, size_nrec, size_f1 ] = ...
      evaluate(sort_scores, size_th, pos_tr, neg_tr);


  %% Output

  %% Prefix
  if ratio == true_ratio
    prefix = "*";
  else
    prefix = "-";
  endif

  %% Display
  printf("%1s %.3f Roc  %8g %5.3f nan nan nan\n", ...
	 prefix, ratio, cluster_time, auc);
  printf("%1s %.3f Best  %5d  %5.3f %5.3f %5.3f %5.3f\n", ...
	 prefix, ratio, best_n_pos_cl, best_prc, best_rec, best_nrec, best_f1);
  printf("%1s %.3f Size  %5d  %5.3f %5.3f %5.3f %5.3f\n", ...
	 prefix, ratio, size_n_pos_cl, size_prc, size_rec, size_nrec, size_f1);
endfor
