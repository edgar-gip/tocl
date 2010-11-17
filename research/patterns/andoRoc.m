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
%% d_mah = @(data) MahalanobisDistance(data);

%% Clusterers
cl_voro_2  = @(dist) Voronoi(dist, struct("max_clusters",  2,
					  "soft_alpha",  0.1));
cl_voro_10 = @(dist) Voronoi(d_rbf_05, struct("max_clusters", 10,
					      "soft_alpha",  0.1));
cl_voro_50 = @(dist) Voronoi(d_rbf_05, struct("max_clusters", 50,
					      "soft_alpha",  0.1));

%% Clusterer Constructors
c_oc = @(dist, data, truth) BBOCC(dist, ...
				   struct("size_ratio", size_ratio(truth)));
c_bp = @(dist, data, truth) BBCPress(dist, ...
				     struct("size_ratio", size_ratio(truth)));
c_ew_voro_2  = @(dist, data, truth) EWOCS(cl_voro_2(dist), ...
					  struct("ensemble_size",  50));
c_ew_voro_10 = @(dist, data, truth) EWOCS(cl_voro_10(dist), ...
					  struct("ensemble_size",  50));
c_ew_voro_50 = @(dist, data, truth) EWOCS(cl_voro_50(dist), ...
					  struct("ensemble_size",  50));

%% Clusterers set
clusterers = ...
    struct("name", { "BBOCC",      "BBCPress/1", ...
		     "BBCPress/2", "BBCPress/3", ...
		     "BBCPress/4", "BBCPress/5", ...
		     "EWOCS/2", "EWOCS/10", "EWOCS/50" }, ...
	   "new",  { c_oc, c_bp, c_bp, c_bp, c_bp, c_bp, ...
		     c_ew_voro_2, c_ew_voro_10, c_ew_voro_50 }, ...
	   "k",    { 1, 1, 2, 3, 4, 5, 1, 1, 1 });

%% Distances
distances = ...
    struct("name", { "SqE", "RBF/0.5", "RBF/1.0", "RBF/2.0" },
	   "dist", { d_sqe, d_rbf_05, d_rbf_10, d_rbf_20 });


%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%

%% Default options
def_opts            = struct();
def_opts.ok         = true();
def_opts.seed       = [];
def_opts.outer_runs = 5;
def_opts.inner_runs = 5;

%% Parse options
[ cmd_args, cmd_opts ] = ...
    get_options(def_opts, ...
		"ok",           "ok",         ...
		"seed=f",       "seed",       ...
		"outer-runs=i", "outer_runs", ...
		"inner-runs=i", "inner_runs");

%% Chek number of arguments
if length(cmd_args) ~= 0
  error("Wrong number of arguments (should be 0)");
endif

%% Set a seed
if isempty(cmd_opts.seed)
  cmd_opts.seed = floor(1000.0 * rand());
endif


%%%%%%%%%
%% Run %%
%%%%%%%%%

%% Print the header
printf(cstrcat("# %-5s %2s %2s %-10s %-7s %2s ", ...
	       " %8s  %5s %5s %5s %5s  %5s\n"), ...
       "Data", "Ds", "OR", "Method", "Dist", "IR", ...
       "Time", "Prc", "Rec", "NRec", "F1", "AUC");

%% For each data generator
for gen = generators

  %% For each number of dimensions
  for dims = dimensions

    %% Outer run
    for or = 1 : cmd_opts.outer_runs

      %% Generate data
      [ data, truth ] = gen.fun(dims);
      n_data  = length(truth);
      s_truth = truth > 1;

      %% printf("Generated %d samples with %d dimensions\n", length(data), dims)

      %% Negative and positive indices
      pos_tr = find( s_truth); n_pos_tr = length(pos_tr);
      neg_tr = find(~s_truth); n_neg_tr = length(neg_tr);

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

	    %% Scores
	    scores = score(cl_model, data);

	    %% Sort'em
	    [ sort_scores, sort_idx ] = sort(scores, "descend");

	    %% Find accumulated positive and negative
	    roc_pos = cumsum( s_truth(sort_idx)); roc_pos ./= n_pos_tr;
	    roc_neg = cumsum(~s_truth(sort_idx)); roc_neg ./= n_neg_tr;

	    %% AUC
	    cl_auc = sum(diff(roc_neg) .* ...
			 (roc_pos(1 : n_data - 1) + roc_pos(2 : n_data))) / 2;

	    %% Display
	    printf(cstrcat("%-7s %2d %2d %-10s %-7s %2d ",
			   " %8g  %5.3f %5.3f %5.3f %5.3f  %5.3f\n"),
		   gen.name, dims, or, clu.name, dst.name, ir, ...
		   cl_time, cl_prc, cl_rec, cl_nrec, cl_f1, cl_auc);
	  endfor
	endfor
      endfor
    endfor
  endfor
endfor
