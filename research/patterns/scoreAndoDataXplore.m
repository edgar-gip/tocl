%% -*- mode: octave; -*-

%% Minority clustering of data

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus

%% Ando elements
source(binrel("andoElements.m"));

%% Debugging
debug_on_warning(true());
debug_on_error(true());


%%%%%%%%%%%%%%%%%
%% Performance %%
%%%%%%%%%%%%%%%%%

function [ prc_c, rec_c, f1_c ] = performance_curves(sort_struth)
  %% Data size
  n_data = length(sort_struth);

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

  %% Remove NaN's
  f1_c(isnan(f1_c)) = 0.0;

  %% Display
  %% printf("*** %8g %5.3f ***\n", cluster_time, auc);
endfunction



%%%%%%%%%%%%%%%
%% Histogram %%
%%%%%%%%%%%%%%%

%% Histogram plot
function [ plots, max_histo, min_score, max_score ] = ...
      histogram_plot(sort_scores, sort_truth, sort_struth, cmd_opts)

  %% Histogram bins
  histo_bins = 100;

  %% Min/max
  min_score = min(sort_scores);
  max_score = max(sort_scores);

  %% Histogram
  h = Histogram();

  %% Plots
  plots   = {};
  max_bin = 0;

  %% Simple?
  if cmd_opts.simple
    %% Simple
    truth    = 1 + sort_struth;
    n_groups = 2;
  else
    %% Complex
    truth    = sort_truth;
    n_groups = max(truth);
  endif

  %% For each cl
  for cl = 1 : n_groups

    %% Cluster
    xcluster = find(truth == cl);

    %% Histogram
    [ histo, bin_limits ] = ...
        make(h, sort_scores(xcluster), histo_bins, min_score, max_score);

    %% Is it the noise cluster?
      if cl == 1
        plots = cell_push(plots, bin_limits, histo, "-r", "linewidth", 2);
      elseif cmd_opts.simple
        plots = cell_push(plots, bin_limits, histo, "-g", "linewidth", 2);
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
endfunction


%%%%%%%%%%%
%% Model %%
%%%%%%%%%%%

%% Fit the model
function [ nm_expec, nm_model, gs_expec ] = ...
      fit_gaussian_model(msort_scores, sort_data, cmd_opts)

  %% Two-step?
  if cmd_opts.two_step
    %% Inner clusterer
    inner = SeqEM({ Gaussian1D(), GaussianEM() }, struct("final_model", 1));

    %% Fit the model
    [ raw_expec, raw_model, raw_info ] = ...
        cluster(CriterionClusterer(inner, BIC(),  ...
                                   struct("max_k",  10, ...
                                          "repeats", 1)), ...
                { msort_scores, [ msort_scores ; sort_data ] });

    %% Gaussian expectation
    gs_expec = raw_info.expec_f;

  else
    %% Fit the model
    [ raw_expec, raw_model ] = ...
        cluster(CriterionClusterer(Gaussian1D(), BIC(),  ...
                                   struct("max_k",  10, ...
                                          "repeats", 1)), ...
                msort_scores);

    %% No Gaussian expectation
    gs_expec = [];
  endif

  %% Sort the model
  [ nm_model, sorted_cl ] = sort_means(raw_model, "descend");

  %% Sort the expectation
  nm_expec = raw_expec(sorted_cl, :);
endfunction

%% Gaussian model plots
%% From sameSide.m
function [ model_plots ] = gaussian_model_plots(model, max_histo, msort_model)

  %% Model info
  als = alphas(model);
  mns = means(model);
  std = sqrt(variances(model));

  %% Number of clusters
  k = length(als);

  %% Xs and Ps
  xs = zeros(k, 21);
  ps = zeros(k, 21);

  %% For each cluster
  for c = 1 : k
    %% Get 21 points Within 2 stdevs
    xs(c, :) = mns(c) + (-10 : 10) * std(c) / 10;

    %% Find a scaled density
    ps(c, :) = als(c) * normpdf(xs(c, :), mns(c), std(c));
  endfor

  %% Scale
  max_p = max(max(ps));
  ps   *= max_histo / max_p;

  %% Map the x's
  xs = inverse(msort_model, xs);

  %% For each cluster
  model_plots = {};
  for c = 1 : k
    %% Add it
    model_plots = cell_push(model_plots, xs(c, :), ps(c, :), ...
                            sprintf("-%d", mod(c - 1, 6)), ...
                            "linewidth", 2);
  endfor
endfunction

%% Find the cut points
function [ nm_th_idxs ] = model_th_cutpoints(nm_expec, sort_scores)
  %% Size
  [ n_cl, n_data ] = size(nm_expec);

  %% Cut points
  nm_th_idxs = [];

  %% Find it
  for c = 1 : n_cl - 1
    %% Expec
    expec_tru = sum(nm_expec(1 : c, :), 1);
    cut_idx   = last_downfall(expec_tru, 0.5);

    %% Not empty?
    if ~isempty(cut_idx)
      %% Add it
      nm_th_idxs = [ nm_th_idxs, ...
                    struct("name",  sprintf("1:%d", c), ...
                           "index", cut_idx,
                           "score", sort_scores(cut_idx)) ];
    endif
  endfor
endfunction


%%%%%%%%%%%%%%%%
%% Properties %%
%%%%%%%%%%%%%%%%

%% Model heterogenousness
function [ hetero, lhetero, rhetero ] = ...
      model_heterogeneousness(sort_data, nm_class, nm_k)
  %% Initialize
  hetero  = zeros(1, nm_k);
  lhetero = zeros(1, nm_k);
  rhetero = zeros(1, nm_k);

  %% For each one
  for cl = 1 : nm_k
    %% Find the trace of the covariance matrix
    %% i.e., the sum of variances
    idx = find(nm_class == cl);
    if ~isempty(idx)
      hetero(cl) = sum(var(sort_data(:, idx)'));
    else
      hetero(cl) = nan;
    endif
    lhetero(cl) = sum(var(sort_data(:, find(nm_class <= cl))'));
    rhetero(cl) = sum(var(sort_data(:, find(nm_class >= cl))'));
  endfor
endfunction


%%%%%%%%%%%%%%%%%%
%% Plot Helpers %%
%%%%%%%%%%%%%%%%%%

%% Push bar plots
%% From ../../../production/journals/jmlr/plots/scores.m:add_th_plots
function [ out_plots ] = push_bar_plots(in_plots, points, low, high, cmd_opts)
  %% Initially...
  out_plots = in_plots;

  %% For each one
  i = 0;
  for p = points
    %% Add'em
    if cmd_opts.bars
      out_plots = cell_push(out_plots, ...
                            [ p.score, p.score ], [ low, high ], ...
                            sprintf("-%d;%s;", mod(i, 6), p.name), ...
                            "linewidth", 2);
    else
      out_plots = cell_push(out_plots, ...
                            [ p.score ], [ low ], ...
                            sprintf("*%d;%s;", mod(i, 6), p.name));
    endif

    %% Next
    i += 1;
  endfor
endfunction


%%%%%%%%%%%
%% Plots %%
%%%%%%%%%%%

%% Plot performance
function plot_performance(prc_c, rec_c, f1_c, points)
  %% Size
  n_data = length(f1_c);

  %% Plots
  plots = { 1 : n_data, prc_c, "-;Precision;", ...
            1 : n_data, rec_c, "-;Recall;", ...
            1 : n_data, f1_c,  "-;F1;" };

  %% For each one
  i = 0;
  for p = points
    %% Add'em
    plots = cell_push(plots, ...
                      [ p.index ], [ f1_c(p.index) ], ...
                      sprintf("*%d;%s;", mod(i, 6), p.name), ...
                      "linewidth", 4);

    %% Next
    i += 1;
  endfor

  %% Figure
  figure("name", "Precision/Recall");
  plot(plots{:});
endfunction

%% Plot a histogram
%% From ../../../production/journals/jmlr/plots/scores.m:plot_histo
function plot_histogram(curves, points, max_histo, min_score, max_score, ...
                        cmd_opts)
  %% Margin
  margin = 0.01 * (max_score - min_score);

  %% Figure
  figure("name", "Histogram");

  %% Is there a histo top, and it is smaller than max_histo?
  if ~isempty(cmd_opts.histo_top) && max_histo > cmd_opts.histo_top
    %% Split the plot in two!

    %% Higher part
    subplot(2, 1, 1);

    %% Add bars
    plots = push_bar_plots(curves, points, cmd_opts.histo_top, max_histo, ...
                           cmd_opts);

    %% Log?
    if cmd_opts.log
      %% Log Plot
      semilogy(plots{:});
      axis([ min_score - margin, max_score + margin, ...
             cmd_opts.histo_top, max_histo ], "ticy");
    else
      %% Regular Plot
      plot(plots{:});
      axis([ min_score - margin, max_score + margin, ...
             cmd_opts.histo_top, max_histo ], "ticy");
    endif

    %% Lower part
    subplot(2, 1, 2);

    %% Log?
    if cmd_opts.log
      %% Add bars
      plots = push_bar_plots(curves, points, 1, cmd_opts.histo_top, cmd_opts);

      %% Log Plot
      semilogy(plots{:});
      axis([ min_score - margin, max_score + margin, ...
             1, cmd_opts.histo_top ]);
    else
      %% Add bars
      plots = push_bar_plots(curves, points, 0, cmd_opts.histo_top, cmd_opts);

      %% Regular Plot
      plot(plots{:});
      axis([ min_score - margin, max_score + margin, ...
             0, cmd_opts.histo_top ]);
    endif

    %% No legend here
    legend("off");

  else
    %% All in one
    subplot(1, 1, 1);

    %% Log?
    if cmd_opts.log
      %% Add bars
      plots = push_bar_plots(curves, points, 1, max_histo, cmd_opts);

      %% Log Plot
      semilogy(plots{:});
      axis([ min_score - margin, max_score + margin, ...
             1, max_histo ]);
    else
      %% Add bars
      plots = push_bar_plots(curves, points, 0, max_histo, cmd_opts);

      %% Regular Plot
      plot(plots{:});
      axis([ min_score - margin, max_score + margin, ...
             0, max_histo ]);
    endif
  endif

  %% X-Label
  xlabel("Score");
endfunction

%% Plot heterogenousness
function plot_heterogeneousness(nm_means, hetero, lhetero, rhetero)
  %% Figure
  figure("name", "Cluster info");

  %% Plots
  plots = {};

  %% For each one
  k = length(nm_means);
  for i = 1 : k
    %% Add it
    plots = cell_push(plots, [ nm_means(i) ], [ hetero(i) ], ...
                      sprintf("*%d", mod(i - 1, 6)), ...
                      "linewidth", 4);
  endfor

  %% Good hetero's
  good_h = ~isnan(hetero);

  %% Add the lines
  plots = cell_push(plots, ...
                    nm_means(good_h), hetero(good_h), "-;Het.;", ...
                    nm_means, lhetero, "-;L-Het.;", ...
                    nm_means, rhetero, "-;R-Het.;");

  %% Range
  min_mn = nm_means(k);
  max_mn = nm_means(1);
  margin = 0.01 * (max_mn - min_mn);

  %% Plot
  subplot(2, 1, 1);
  plot(plots{:});
  axis([ min_mn - margin, max_mn + margin ]);

  %% Differences
  nm_means_mid = (nm_means(1 : k - 1) + nm_means(2 : k)) / 2;
  hetero_diff  = (rhetero(2 : k) - lhetero(1 : k - 1));

  %% Plot
  subplot(2, 1, 2);
  plot(nm_means_mid, hetero_diff, "-;Difference;");
  axis([ min_mn - margin, max_mn + margin ]);
endfunction


%%%%%%%%%%
%% Main %%
%%%%%%%%%%

%% Default options
def_opts           = struct();
def_opts.bars      = false();
def_opts.hetero    = false();
def_opts.histo_top = [];
def_opts.log       = false();
def_opts.pairwise  = false();
def_opts.simple    = false();
def_opts.two_step  = false();

%% Parse options
[ args, opts ] = ...
    get_options(def_opts, ...
                "bars!",       "bars", ...
                "hetero!",     "hetero", ...
                "histo-top=f", "histo_top", ...
                "log!",        "log",  ...
                "pairwise!",   "pairwise", ...
                "simple!",     "simple", ...
                "two-step!",   "two_step");

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

%% Is it a scored method?
if ~getfield(methods, met, "scor")
  error("Method '%s' is not scored", met);
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


%% Sort by score
scores = score(model, data);
[ sort_scores, sort_idx ] = sort(scores, "descend");
sort_data   = data(:, sort_idx);
sort_struth = struth(sort_idx);
sort_truth  = truth(sort_idx);

%% Map scores
[ msort_scores, msort_model ] = apply(LinearInterpolator(), sort_scores);


%% Performance curves
[ prc_c, rec_c, f1_c ] = performance_curves(sort_struth);

%% Histogram plot
[ histo_plots, max_histo, min_score, max_score ] = ...
    histogram_plot(sort_scores, sort_truth, sort_struth, opts);

%% Fit and plot the model
[ nm_expec, nm_model, gs_expec ] = ...
    fit_gaussian_model(msort_scores, sort_data, opts);
[ model_plots ] = gaussian_model_plots(nm_model, max_histo, msort_model);

%% Convert model information
[ nm_hard, nm_class ] = harden_expectation(nm_expec);
nm_means = inverse(msort_model, means(nm_model));
nm_k     = length(nm_means);

%% Model cut points
th_cuts = model_th_cutpoints(nm_expec, sort_scores);

%% Plot everything
plot_performance(prc_c, rec_c, f1_c, th_cuts);
plot_histogram({ model_plots{:}, histo_plots{:} }, th_cuts, ...
               max_histo, min_score, max_score, opts);

%% Model heterogeneousness
if opts.hetero
  [ hetero, lhetero, rhetero ] = ...
      model_heterogeneousness(sort_data, nm_class, nm_k);
  plot_heterogeneousness(nm_means, hetero, lhetero, rhetero);
endif

%% Pairwise plots
if opts.pairwise
  pairwise_cluster_plot(sort_data, sort_truth, "Truth");
  pairwise_cluster_plot(sort_data, nm_class, "Cluster membership");

  %% Gaussian?
  if ~isempty(gs_expec)
    [ gs_hard, gs_class ] = harden_expectation(gs_expec);
    pairwise_cluster_plot(sort_data, gs_class, "Gaussian cluster membership");
  endif
endif

%% Pause
pause();
