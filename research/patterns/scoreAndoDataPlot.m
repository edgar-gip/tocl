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
function histogram_plot(sort_scores, msort_scores, msort_model, sort_truth, ...
                        th_cuts, do_log)
  %% Histogram bins
  histo_bins = 100;

  %% Number of groups
  n_groups = max(sort_truth);

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
    xcluster = find(sort_truth == cl);

    %% Histogram
    [ histo, bin_limits ] = ...
        make(h, sort_scores(xcluster), histo_bins, min_score, max_score);

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

  %% Max
  max_histo = max(histo);

  %% Add thresholds
  for th = th_cuts
    %% Add the plot
    plots = cell_push(plots, ...
                      [ th.value ], [ 1 ], ...
                      sprintf("*;%s;", th.name), "linewidth", 4);
  endfor


  %% Plot histogram
  figure("name", "Histogram");
  if do_log
    semilogy(plots{:});
  else
    plot(plots{:});
  endif
endfunction

%% F1 plot
function f1_plot(sort_struth, sort_truth, th_cuts)
  %% Find accumulated positive and negative
  cum_pos = cumsum( sort_struth);
  cum_neg = cumsum(~sort_struth);

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
  n_groups = max(sort_truth);

  %% Cluster recall
  for cl = 1 : n_groups
    %% Find accumulated
    cum_cl = cumsum(sort_truth == cl);
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

%% Default options
def_opts            = struct();
def_opts.pairwise   = false();
def_opts.do_log     = false();
def_opts.n_model    = false();
def_opts.full_level = 1;

%% Helper functions
function [ opts ] = s_full(opts, value)
  opts.full_level = 2;
endfunction
function [ opts ] = s_extra(opts, value)
  opts.full_level = 3;
endfunction

%% Parse options
[ args, opts ] = ...
    get_options(def_opts, ...
                "pairwise!", "pairwise", ...
                "log!",      "do_log", ...
                "n-model!",  "n_model", ...
                "full",      @s_full, ...
                "extra",     @s_extra);

%% Arguments
if length(args) ~= 7
  error(cstrcat("Wrong number of arguments: Expected [options]", ...
                " <input> <distance> <d-extra> <method> <m-extra> <k> <seed>"));
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

% Extra arguments
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
if opts.pairwise
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
  %% Scored

  %% Sort by score
  scores = score(model, data);
  [ sort_scores, sort_idx ] = sort(scores, "descend");
  sort_struth = struth(sort_idx);
  sort_truth  = truth(sort_idx);

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
  printf("*** %8g %5.3f ***\n", cluster_time, auc);


  %% Threshold cut points
  th_cuts = struct();

  %% For each threshold
  i   = 1;
  ths = getfield(methods, met, "ths");
  for th = ths

    %% Must we do it?
    %% -> Full output or basic threshold
    if opts.full_level >= getfield(th, "level")

      %% Find the threshold
      thfun    = getfield(th, "find");
      th_value = thfun(sort_scores, sort_struth, msort_scores, msort_model, ...
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
      printf("%7s %5d  %5.3f %5.3f %5.3f %5.3f\n", ...
             getfield(th, "name"), n_pos_cl, prc, rec, nrec, f1);

      %% Plot data
      if opts.pairwise
        th_truth = 1 + (scores >= th_value);
        pairwise_cluster_plot(data, th_truth, th.name);
      endif

      %% Next
      i += 1;
    endif
  endfor

  %% Histogram plot
  histogram_plot(sort_scores, msort_scores, msort_model, sort_truth, ...
                 th_cuts, opts.do_log);

  %% F1 plot
  f1_plot(sort_struth, sort_truth, th_cuts);

else
  %% Non-scored method

  %% Positive cluster
  pos_cl = find(sum(expec, 1)); n_pos_cl = length(pos_cl);

  %% Truth
  pos_tr = find(struth); n_pos_tr = length(pos_tr);
  n_neg_tr = n_data - n_pos_tr;

  %% The good (and the bad) ones
  n_pos_pos = length(intersect(pos_cl, pos_tr));
  n_neg_pos = n_pos_cl - n_pos_pos;

  %% Prc/Rec/F1 curves
  prc  = n_pos_pos / n_pos_cl;
  rec  = n_pos_pos / n_pos_tr;
  nrec = n_neg_pos / n_neg_tr;
  f1  = 2 * prc * rec / (prc + rec);

  %% ROC is a quadrilateral
  %% AUC = rec * nrec / 2 + rec * (1 - nrec) + (1 - rec) * (1 - nrec) / 2
  auc = (1 + rec - nrec) / 2;

  %% All Prc/F1
  all_prc = n_pos_tr / n_data;
  all_f1  = 2 * all_prc / (1 + all_prc);

  %% Display
  printf("*** %8g %5.3f ***\n", cluster_time, auc);
  printf("%7s %5d  %5.3f %5.3f %5.3f %5.3f\n", ...
         "All", n_data, all_prc, 1.0, 1.0, all_f1);
  printf("%7s %5d  %5.3f %5.3f %5.3f %5.3f\n", ...
         "Model", n_pos_cl, prc, rec, nrec, f1);

  %% Plot data
  if opts.pairwise
    [ hard_e, hard_cl ] = harden_expectation(expec, true());
    pairwise_cluster_plot(data, hard_cl, "Model");
  endif
endif

%% Pause
pause();
