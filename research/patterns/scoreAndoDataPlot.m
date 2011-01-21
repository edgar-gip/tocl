%% -*- mode: octave; -*-

%% Minority clustering of data

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus

%% Ando elements
source(binrel("andoElements.m"));


%%%%%%%%%%%
%% Plots %%
%%%%%%%%%%%

%% Histogram plot
function histogram_plot(sort_scores, sort_full, th_cuts, do_log)
  %% Histogram bins
  histo_bins = 100;

  %% Number of groups
  n_groups = max(sort_full);

  %% Min/max
  min_score = min(sort_scores);
  max_score = max(sort_scores);

  %% Histogram
  h = Histogram();

  %% Plots
  plots   = {};
  max_bin = 0;

  %% For each cl
  for cl = 1 : n_groups

    %% Cluster
    cluster = find(sort_full == cl);

    %% Histogram
    [ histo, bin_limits ] = ...
	make(h, sort_scores(cluster), histo_bins, min_score, max_score);

    %% Is it the noise cluster?
    if cl == 1
      plots = cell_push(plots, bin_limits, histo, "-r", "linewidth", 2);
    else
      plots = cell_push(plots, bin_limits, histo, "-");
    endif
  endfor

  %% All histogram
  [ histo, bin_limits ] = ...
      make(h, sort_scores, histo_bins, min_score, max_score);
  plots = cell_push(plots, bin_limits, histo, "-k", "linewidth", 2);

  %% Add thresholds
  for th = th_cuts
    %% Add the plot
    plots = cell_push(plots, ...
		      [ th.value ], [ 1 ], ...
		      sprintf("*;%s;", th.name), "linewidth", 4);
  endfor

  %% Plot
  figure("name", "Histogram");
  if do_log
    semilogy(plots{:});
  else
    plot(plots{:});
  endif
endfunction

%% F1 plot
function f1_plot(sort_truth, sort_full, th_cuts)
  %% Find accumulated positive and negative
  cum_pos = cumsum( sort_truth);
  cum_neg = cumsum(~sort_truth);

  %% Length
  n_data = length(cum_pos);

  %% Precision
  prc = cum_pos ./ (cum_pos .+ cum_neg);
  rec = cum_pos ./ cum_pos(n_data);
  f1  = (2 .* prc .* rec) ./ (prc + rec);

  %% Remove NaN's
  f1(isnan(f1)) = 0.0;

  %% Plots
  plots = { 1 : n_data, prc, "-;Precision;", ...
	    1 : n_data, rec, "-;Recall;", ...
	    1 : n_data, f1,  "-;F1;" };

  %% Number of groups
  n_groups = max(sort_full);

  %% Cluster recall
  for cl = 1 : n_groups
    %% Find accumulated
    cum_cl = cumsum(sort_full == cl);
    cl_rec = cum_cl ./ cum_cl(n_data);

    %% Plot
    plots = cell_push(plots, ...
		      1 : n_data, cl_rec, ...
		      sprintf("-;Recall (%d);", cl));
  endfor

  %% Add thresholds
  for th = th_cuts
    %% Add the plot
    plots = cell_push(plots, ...
		      [ th.index ], [ f1(th.index) ], ...
		      sprintf("*;%s;", th.name), "linewidth", 4);
  endfor

  %% For
  figure("name", "Precision/Recall");
  plot(plots{:});
endfunction


%%%%%%%%%%
%% Main %%
%%%%%%%%%%

%% Get the parameters
args = argv();

%% Option?
pairwise = true();
if length(args) > 0 && strcmp(args{1}, "--no-pairwise")
  pairwise = false();
  args     = { args{2 : length(args)} };
endif

%% Do log
do_log = true();
if length(args) > 0 && strcmp(args{1}, "--no-log")
  do_log = false();
  args   = { args{2 : length(args)} };
endif

%% Arguments
if length(args) ~= 7
  error(cstrcat("Wrong number of arguments: Expected", ...
		" [--no-pairwise] [--no-log] <input> <distance> <d-extra> ", ...
		"<method> <m-extra> <k> <seed>"));
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
  error("Wrong distance name '%s'. Must be: %s", met, fields(distances));
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
[ k, status ] = str2double(args{6});
if status ~= 0
  error("Wrong number of clusters '%s'", args{6})
endif

%% Seed
[ seed, status ] = str2double(args{7});
if status ~= 0
  error("Wrong seed '%s'", args{7});
endif


%% Plot data
if pairwise
  pairwise_cluster_plot(data, truth, "Truth");
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
n_data  = length(truth);
s_truth = truth > 1;

%% Create clusterer
clustfun  = getfield(methods, met, "make");
clusterer = clustfun(distance, data, s_truth, mextra);

%% Cluster
[ total0, user0, system0 ] = cputime();
[ expec, model ] = cluster(clusterer, data, k);
[ total1, user1, system1 ] = cputime();

%% Time difference
cluster_time = total1 - total0;


%% Sort by score
scores = score(model, data);
[ sort_scores, sort_idx ] = sort(scores, "descend");
sort_truth = s_truth(sort_idx);
sort_full  = truth(sort_idx);

%% Map scores
[ msort_scores, msort_model ] = apply(LinearInterpolator(), sort_scores);

%% Truth classes
pos_tr  = find( sort_truth); n_pos_tr = length(pos_tr);
neg_tr  = find(~sort_truth); n_neg_tr = length(neg_tr);

%% ROC

%% Find accumulated positive and negative
acc_pos = cumsum( sort_truth);
acc_neg = cumsum(~sort_truth);

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
printf("*** %8g %5.3f ***\n", cluster_time, auc);


%% Threshold cut points
th_cuts = struct();

%% For each threshold
i   = 1;
ths = getfield(methods, met, "ths");
for th = ths

  %% Find the threshold
  thfun    = getfield(th, "find");
  th_value = thfun(sort_scores, sort_truth, msort_scores, msort_model, ...
		   f1_c, model);

  %% Negative/positive cluster
  pos_cl = find(sort_scores >= th_value); n_pos_cl = length(pos_cl);
  neg_cl = find(sort_scores <  th_value);

  %% Set
  th_cuts(i).name  = th.name;
  th_cuts(i).value = th_value;
  th_cuts(i).index = max(pos_cl);

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
  printf("%5s %5d  %5.3f %5.3f %5.3f %5.3f\n", ...
	 getfield(th, "name"), n_pos_cl, prc, rec, nrec, f1);

  %% Plot data
  if pairwise
    th_truth = 1 + (scores >= th_value);
    pairwise_cluster_plot(data, th_truth, th.name);
  endif

  %% Next
  i += 1;
endfor

%% Histogram plot
histogram_plot(sort_scores, sort_full, th_cuts, do_log);

%% F1 plot
f1_plot(sort_truth, sort_full, th_cuts);

%% Pause
pause();
