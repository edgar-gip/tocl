%% -*- mode: octave; -*-

%% Minority clustering of data

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus


%%%%%%%%%%%%%%%
%% Distances %%
%%%%%%%%%%%%%%%

%% Distances
distances = ...
    struct("none",   [], ...
	   "sqe",    SqEuclideanDistance(),          ...
	   "rbf_05", KernelDistance(RBFKernel(0.5)), ...
	   "rbf_10", KernelDistance(RBFKernel(1.0)), ...
	   "rbf_20", KernelDistance(RBFKernel(2.0)), ...
	   "mah",    @(data)  MahalanobisDistance(data));


%%%%%%%%%%%%%
%% Methods %%
%%%%%%%%%%%%%

%% Size ratio
function [ ratio ] = size_ratio(truth)
  %% Find it
  ratio = sum(truth > 1) / length(truth);
endfunction

%% Methods
methods = ...
    struct("bbocc", @(dist, data, truth, extra) ...
	       BBOCC(dist, struct("size_ratio", size_ratio(truth))), ...
	   "bbcpress", @(dist, data, truth, extra) ...
	       BBCPress(dist, struct("size_ratio", size_ratio(truth))), ...
	   "ewocs_voro", @(dist, data, truth, extra) ...
	       EWOCS(Voronoi(dist, struct("soft_alpha", 0.1)), ...
		     struct("ensemble_size", str2double(extra{1}), ...
			    "max_clusters", str2double(extra{2}), ...
			    "interpolator", extra{3})), ...
	   "ewocs_bern", @(dist, data, truth, extra) ...
	       EWOCS(Bernoulli(), ...
		     struct("ensemble_size", str2double(extra{1}), ...
			    "max_clusters", str2double(extra{2}), ...
			    "interpolator", extra{3})));


%%%%%%%%%%
%% Main %%
%%%%%%%%%%

%% Get the parameters
args = argv();
if ~any(length(args) == [ 6, 7, 8 ])
  error(cstrcat("Wrong number of arguments: Expected", ...
		" <input> <distance> <method> <extra>", ...
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
  error("Wrong distance name '%s'", met);
endif

%% Method
met = args{3};
if ~isfield(methods, met)
  error("Wrong method name '%s'", met);
endif

%% Extra arguments
extra = regex_split(args{4}, '(,|\s+,)\s*');

%% k
[ k, status ] = str2double(args{5});
if status ~= 0
  error("Wrong number of clusters '%s'", args{5})
endif

%% Seed
[ seed, status ] = str2double(args{6});
if status ~= 0
  error("Wrong seed '%s'", args{6});
endif

%% Output
if length(args) >= 7
  output = args{7};
  [ fout, status ] = fopen(output, "wt");
  if fout == -1
    error("Cannot open output '%s': %s", output, status);
  endif
else
  fout = 1;
endif

%% Initialize seed
rand("seed", seed);

%% Create distance
distfun = getfield(distances, dist);
if isfunctionhandle(distfun)
  distance = distfun(data);
else
  distance = distfun;
endif

%% Create clusterer
clustfun  = getfield(methods, met);
clusterer = clustfun(distance, data, truth, extra);


%% Cluster
[ total0, user0, system0 ] = cputime();
[ expec, model ] = cluster(clusterer, data, k);
[ total1, user1, system1 ] = cputime();

%% Time difference
cluster_time = total1 - total0;


%% Score
scores    = score    (model, data);
threshold = threshold(model);


%% Truth information
n_data  = length(truth);
s_truth = truth > 1;
pos_tr  = find( s_truth); n_pos_tr = length(pos_tr);
neg_tr  = find(~s_truth); n_neg_tr = length(neg_tr);


%% Precision/Recall

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
prc  = n_pos_pos / (n_pos_pos + n_neg_pos);
rec  = n_pos_pos / (n_pos_pos + n_pos_neg);
nrec = n_neg_pos / (n_neg_pos + n_neg_neg);
f1   = 2 * prc * rec / (prc + rec);


%% ROC

%% Sort'em
[ sort_scores, sort_idx ] = sort(scores, "descend");

%% Find accumulated positive and negative
roc_pos = cumsum( s_truth(sort_idx)); roc_pos ./= n_pos_tr;
roc_neg = cumsum(~s_truth(sort_idx)); roc_neg ./= n_neg_tr;

%% AUC
auc = sum(diff(roc_neg) .* ...
	  (roc_pos(1 : n_data - 1) + roc_pos(2 : n_data))) / 2;


%% Output

%% Display
fprintf(fout, "%8g  %5.3f %5.3f %5.3f %5.3f  %5.3f\n", ...
	cluster_time, prc, rec, nrec, f1, auc);
if fout ~= 1
  fclose(fout);
endif


%% Save?
if length(args) >= 8
  try
    save("-binary", "-zip", args{8}, "scores", "threshold");
  catch
    error("Cannot save data to '%s': %s", args{8}, lasterr());
  end_try_catch
endif
