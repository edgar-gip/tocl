%% -*- mode: octave; -*-

%% Make the ROC plots with the data from
%% Shin Ando
%% "Clustering Needles in a Haystack: An Information Theoretic
%%  Analysis of Minority And Outlier Detection"
%% 7th IEEE Conference on Data Mining, 2007

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus

%% Warnings
warning off Octave:divide-by-zero;


%%%%%%%%%%%
%% Enums %%
%%%%%%%%%%%

%% Distributions
enum P_BERNOULLI P_GAUSSIAN P_SPHERICAL P_UNIFORM


%%%%%%%%%%%%%
%% Helpers %%
%%%%%%%%%%%%%

%% File name
function [ name ] = file_name(file)
  %% Get the parts
  [ dr, name, ext, ver ] = fileparts(file);
endfunction


%%%%%%%%%%%%%%%
%% Data sets %%
%%%%%%%%%%%%%%%

%% Uniform background
function [ data, truth ] = data_unibg(dims)
  %% Generate it
  [ data, truth ] = gen_data(struct("dimensions", dims,

				    "noise_dist", P_UNIFORM,
				    "noise_size", 1000 * 2 ^ dims,
				    "noise_mean", 0.0,
				    "noise_var",  1.0,

				    "signal_dist",  P_GAUSSIAN,
				    "signal_size",  [ 100, 150, 150, 200 ],
				    "signal_var",   0.125,
				    "signal_mean",  0.0,
				    "signal_shift", 0.5));
endfunction

%% Gaussian background
function [ data, truth ] = data_gaussbg(dims)
  %% Generate it
  [ data, truth ] = gen_data(struct("dimensions", dims,

				    "noise_dist", P_SPHERICAL,
				    "noise_size", 1000 * 2 ^ dims,
				    "noise_mean", 0.0,
				    "noise_var",  1.0,

				    "signal_dist",  P_GAUSSIAN,
				    "signal_size",  [ 100, 150, 150, 200 ],
				    "signal_var",   0.125,
				    "signal_mean",  0.0,
				    "signal_shift", 0.5));
endfunction

%% Generators
generators = struct("name", { "UniBG",     "GaussBG"     },
		    "fun",  { @data_unibg, @data_gaussbg });

%% Dimensions
dimensions = [ 2, 3, 5, 8 ];


%%%%%%%%%%%%%%%%
%% Clusterers %%
%%%%%%%%%%%%%%%%

%% Size ratio
function [ ratio ] = size_ratio(truth)
  %% Find it
  ratio = sum(truth > 1) / length(truth);
endfunction

%% Distances
d_sqe    = SqEuclideanDistance();
d_rbf_05 = KernelDistance(RBFKernel(0.5));
d_rbf_10 = KernelDistance(RBFKernel(1.0));
d_rbf_20 = KernelDistance(RBFKernel(2.0));
d_rbf_40 = KernelDistance(RBFKernel(4.0));
d_rbf_80 = KernelDistance(RBFKernel(8.0));
%% d_mah = @(data) MahalanobisDistance(data);

%% Clusterers
cl_voro = @(dist) Voronoi(dist, struct("soft_alpha", 0.1));
cl_bern = Bernoulli();

%% Clusterer Constructors
c_oc = @(dist, data, truth) BBOCC(dist, ...
				   struct("size_ratio", size_ratio(truth)));
c_bp = @(dist, data, truth) BBCPress(dist, ...
				     struct("size_ratio", size_ratio(truth)));
c_ew_voro_2_g  = @(dist, data, truth) EWOCS(cl_voro(dist), ...
					    struct("max_clusters",   2, ...
						   "ensemble_size", 50, ...
						   "interpolator",  ...
						       "knee-gauss-noise"));
c_ew_voro_10_g = @(dist, data, truth) EWOCS(cl_voro(dist), ...
					    struct("max_clusters",  10, ...
						   "ensemble_size", 50, ...
						   "interpolator",  ...
						       "knee-gauss-noise"));
c_ew_voro_50_g = @(dist, data, truth) EWOCS(cl_voro(dist), ...
					    struct("max_clusters",  50, ...
						   "ensemble_size", 50, ...
						   "interpolator",  ...
						       "knee-gauss-noise"));
c_ew_voro_2_d  = @(dist, data, truth) EWOCS(cl_voro(dist), ...
					  struct("max_clusters",   2, ...
						 "ensemble_size", 50, ...
						 "interpolator",  "knee-dist"));
c_ew_voro_10_d = @(dist, data, truth) EWOCS(cl_voro(dist), ...
					  struct("max_clusters",  10, ...
						 "ensemble_size", 50, ...
						 "interpolator",  "knee-dist"));
c_ew_voro_50_d = @(dist, data, truth) EWOCS(cl_voro(dist), ...
					  struct("max_clusters",  50, ...
						 "ensemble_size", 50, ...
						 "interpolator",  "knee-dist"));
c_ew_bern_2_g  = @(data, truth) EWOCS(cl_bern, ...
                                    struct("max_clusters",   2, ...
                                           "ensemble_size", 50, ...
					   "interpolator",  ...
					     "knee-gauss-noise"));
c_ew_bern_10_g = @(data, truth) EWOCS(cl_bern, ...
                                    struct("max_clusters",  10, ...
                                           "ensemble_size", 50, ...
					   "interpolator",  ...
					     "knee-gauss-noise"));
c_ew_bern_50_g = @(data, truth) EWOCS(cl_bern, ...
                                    struct("max_clusters",  50, ...
                                           "ensemble_size", 50, ...
					   "interpolator",  "knee-dist"));
c_ew_bern_2_d  = @(data, truth) EWOCS(cl_bern, ...
                                    struct("max_clusters",   2, ...
                                           "ensemble_size", 50, ...
					   "interpolator",  "knee-dist"));
c_ew_bern_10_d = @(data, truth) EWOCS(cl_bern, ...
                                    struct("max_clusters",  10, ...
                                           "ensemble_size", 50, ...
					   "interpolator",  "knee-dist"));
c_ew_bern_50_d = @(data, truth) EWOCS(cl_bern, ...
                                    struct("max_clusters",  50, ...
                                           "ensemble_size", 50, ...
					   "interpolator",  "knee-dist"));

%% Clusterers set
    %% struct("name", { "BBOCC",      "BBCPress/1", ...
    %% 		     "BBCPress/2", "BBCPress/3", ...
    %% 		     "BBCPress/4", "BBCPress/5", ...
    %% 		     "EWOCS-Vo/2", "EWOCS-Vo/10", "EWOCS-Vo/50" }, ...
    %% 	   "new",  { c_oc, c_bp, c_bp, c_bp, c_bp, c_bp, ...
    %% 		     c_ew_voro_2, c_ew_voro_10, c_ew_voro_50 }, ...
    %% 	   "k",    { 1, 1, 2, 3, 4, 5, 1, 1, 1 });
clusterers = ...
    struct("name", { "BBOCC",        "BBCPress/5", ...
		     "EWOCS-G-Vo/2", "EWOCS-G-Vo/10", "EWOCS-G-Vo/50", ...
		     "EWOCS-D-Vo/2", "EWOCS-D-Vo/10", "EWOCS-D-Vo/50" }, ...
	   "new",  { c_oc, c_bp, ...
		     c_ew_voro_2_g, c_ew_voro_10_g, c_ew_voro_50_g, ...
		     c_ew_voro_2_d, c_ew_voro_10_d, c_ew_voro_50_d }, ...
	   "k",    { 1, 5, 1, 1, 1, 1, 1, 1 });

%% Prob clusterers
prob_clusterers = ...
    struct("name", { "EWOCS-G-Be/2", "EWOCS-G-Be/10", "EWOCS-G-Be/50", ...
		     "EWOCS-D-Be/2", "EWOCS-D-Be/10", "EWOCS-D-Be/50" }, ...
	   "new",  { c_ew_bern_2_g, c_ew_bern_10_g, c_ew_bern_50_g, ...
		     c_ew_bern_2_d, c_ew_bern_10_d, c_ew_bern_50_d }, ...
	   "k",    { 1, 1, 1, 1, 1, 1 });

%% Distances
distances = ...
    struct("name", { "SqE", "RBF/0.5", "RBF/1.0", "RBF/2.0", ...
		     "RBF/4.0", "RBF/8.0" },
	   "dist", { d_sqe, d_rbf_05, d_rbf_10, d_rbf_20, d_rbf_40, d_rbf_80 });


%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%

%% Default options
def_opts            = struct();
def_opts.ok         = true();
def_opts.seed       = [];
def_opts.sparse     = false();
def_opts.outer_runs = 5;
def_opts.inner_runs = 5;

%% Parse options
[ cmd_args, cmd_opts ] = ...
    get_options(def_opts, ...
		"ok",           "ok",         ...
		"seed=f",       "seed",       ...
		"sparse!",      "sparse",     ...
		"outer-runs=i", "outer_runs", ...
		"inner-runs=i", "inner_runs");

%% Set a seed
if isempty(cmd_opts.seed)
  cmd_opts.seed = floor(1000.0 * rand());
endif


%%%%%%%%%
%% Run %%
%%%%%%%%%

%% Evaluate one
function [ cl_prc, cl_rec, cl_nrec, cl_f1, cl_auc ] = ...
      evaluate(s_truth, pos_tr, neg_tr, expec, scores)

  %% Info
  n_data = length(s_truth);

  %% Find Prec/Rec

  %% Negative/positive cluster
  sexpec = sum(expec, 1);
  pos_cl = find(sexpec >= 0.5);
  neg_cl = find(sexpec < 0.5);

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
  cl_prc  = n_pos_pos / (n_pos_pos + n_neg_pos);
  cl_rec  = n_pos_pos / (n_pos_pos + n_pos_neg);
  cl_nrec = n_neg_pos / (n_neg_pos + n_neg_neg);
  cl_f1   = 2 * cl_prc * cl_rec / (cl_prc + cl_rec);

  %% Find ROC curve

  %% Sort'em
  [ sort_scores, sort_idx ] = sort(scores, "descend");

  %% Find accumulated positive and negative
  roc_pos = cumsum( s_truth(sort_idx)); roc_pos ./= length(pos_tr);
  roc_neg = cumsum(~s_truth(sort_idx)); roc_neg ./= length(neg_tr);

  %% AUC
  cl_auc = sum(diff(roc_neg) .* ...
	       (roc_pos(1 : n_data - 1) + roc_pos(2 : n_data))) / 2;
endfunction

%% Run one
function run_one(data, truth, gen_name, dims, o_r, ...
		 clusterers, prob_clusterers, distances, cmd_opts)

  %% Info
  n_data  = length(truth);
  s_truth = truth > 1;

  %% Negative and positive indices
  pos_tr = find( s_truth);
  neg_tr = find(~s_truth);

  %% Clusterer
  for clu = clusterers

    %% Distance
    for dst = distances

      %% Construct it
      cl_object = clu.new(dst.dist, data, truth);

      %% Inner run
      for ir = 1 : cmd_opts.inner_runs

	%% Cluster (timed)
	[ total0, user0, system0 ] = cputime();
	[ expec, cl_model ] = cluster(cl_object, data, clu.k);
	[ total1, user1, system1 ] = cputime();

	%% Time difference
	cl_time = total1 - total0;

	%% Scores
	scores = score(cl_model, data);

	%% Evaluate
	[ cl_prc, cl_rec, cl_nrec, cl_f1, cl_auc ] = ...
	    evaluate(s_truth, pos_tr, neg_tr, expec, scores);

	%% Display
	printf(cstrcat("%-25s %5d %2d %-15s %-7s %2d ",
		       " %8g  %5.3f %5.3f %5.3f %5.3f  %5.3f\n"),
	       gen_name, dims, o_r, clu.name, dst.name, ir, ...
	       cl_time, cl_prc, cl_rec, cl_nrec, cl_f1, cl_auc);
      endfor
    endfor
  endfor

  %% Clusterer
  for clu = prob_clusterers

    %% Construct it
    cl_object = clu.new(dst.dist, data, truth);

    %% Inner run
    for ir = 1 : cmd_opts.inner_runs

      %% Cluster (timed)
      [ total0, user0, system0 ] = cputime();
      [ expec, cl_model ] = cluster(cl_object, data, clu.k);
      [ total1, user1, system1 ] = cputime();

      %% Time difference
      cl_time = total1 - total0;

      %% Scores
      scores = score(cl_model, data);

      %% Evaluate
      [ cl_prc, cl_rec, cl_nrec, cl_f1, cl_auc ] = ...
	  evaluate(s_truth, pos_tr, neg_tr, expec, scores);

      %% Display
      printf(cstrcat("%-25s %5d %2d %-15s %-7s %2d ",
		     " %8g  %5.3f %5.3f %5.3f %5.3f  %5.3f\n"),
	     gen_name, dims, o_r, clu.name, "-", ir, ...
	     cl_time, cl_prc, cl_rec, cl_nrec, cl_f1, cl_auc);
    endfor
  endfor
endfunction

%% Print the header
printf(cstrcat("# %-23s %5s %2s %-15s %-7s %2s ", ...
	       " %8s  %5s %5s %5s %5s  %5s\n"), ...
       "Data", "Dims", "OR", "Method", "Dist", "IR", ...
       "Time", "Prc", "Rec", "NRec", "F1", "AUC");

%% What
if length(cmd_args) == 0

  %% For each data generator
  for gen = generators

    %% For each number of dimensions
    for dims = dimensions

      %% Outer run
      for o_r = 1 : cmd_opts.outer_runs

	%% Generate data
	[ data, truth ] = gen.fun(dims);

	%% Call
	run_one(data, truth, gen.name, dims, o_r, ...
		clusterers, prob_clusterers, distances, cmd_opts);
      endfor
    endfor
  endfor

else
  %% For each file
  for f = cmd_args

    %% Load
    if cmd_opts.sparse
      [ data, truth ] = read_sparse(f{1}, true());
    else
      load(f{1}, "data", "truth");
    endif

    %% Size
    [ dims, n_data ] = size(data);

    %% Call
    run_one(data, truth, file_name(f{1}), dims, 1, ...
	    clusterers, prob_clusterers, distances, cmd_opts);
  endfor
endif
