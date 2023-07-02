%% -*- mode: octave; -*-

%% One-Class clustering frontend

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus


%%%%%%%%%%%
%% Enums %%
%%%%%%%%%%%

%% Methods
enum M_BBOCC M_EWOCS M_HOCC M_HYPER_BB M_OC_IB

%% Inside weak clustering methods
enum C_BERNOULLI C_KMEANS C_SVM C_VORONOI

%% Distance
enum D_EUCLIDEAN D_KERNEL

%% Kernels
enum K_LINEAR K_POLYNOMIAL K_RBF

%% Scoring functions
enum S_DENSE S_NDENSE S_NSIZE S_RADIUS S_SIZE


%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%

%% Set cluster cost
function [ opts ] = s_cluster_cost(opts, value)
  opts.cluster_cost = value;
  opts.cluster_size = nan;
endfunction

%% Set cluster size
function [ opts ] = s_cluster_size(opts, value)
  opts.cluster_cost = nan;
  opts.cluster_size = value;
endfunction

%% Set hard alpha
function [ opts ] = s_hard_alpha(opts, value)
  opts.soft_alpha = inf;
endfunction

%% Default options
def_opts                 = struct();
def_opts.sparse          = false();
def_opts.train_truth     = false();
def_opts.test_truth      = false();
def_opts.runs            = 5;
def_opts.ensemble_size   = 100;
def_opts.seed            = [];
def_opts.max_tries       = 10;
def_opts.method          = M_EWOCS;
def_opts.cluster_radius  = 1.0;       %% For M_OCIB
def_opts.cluster_size    = 1000;      %% For M_BBOCC M_HOCC M_HYPER
def_opts.cluster_cost    = nan;       %% For M_BBOCC M_HOCC M_HYPER
def_opts.clusterer       = C_VORONOI; %% For M_EWOCS
def_opts.soft_alpha      = 0.1;       %% For M_EWOCS
def_opts.em_iterations   = 100;       %% For C_BERNOULLI
def_opts.em_threshold    = 1e-6;      %% For C_BERNOULLI
def_opts.distance        = D_KERNEL;
def_opts.kernel          = K_RBF;     %% For D_KERNEL
def_opts.poly_degree     = 2;
def_opts.poly_constant   = true();
def_opts.rbf_gamma       = 0.1;       %% For K_RBF
def_opts.csf             = S_NSIZE;   %% For M_EWOCS

%% Parse options
[ cmd_args, cmd_opts ] = ...
    get_options(def_opts, ...
                "sparse!",           "sparse",        ...
                "train-truth!",      "train_truth",   ...
                "test-truth!",       "test_truth",    ...
                "runs=i",            "runs",          ...
                "repeats=i",         "repeats",       ...
                "seed=f",            "seed",          ...
                "max-tries=i",       "max_tries",     ...
                "bbocc=r0",          "method",        ...
                "hocc=r1",           "method",        ...
                "hyper-bb=r2",       "method",        ...
                "oc-ib=r3",          "method",        ...
                "weak=r4",           "method",        ...
                "cluster-radius=f",  "cluster_radius",...
                "cluster-size=f",    @s_cluster_size, ...
                "cluster-cost=f",    @s_cluster_cost, ...
                "bernoulli=r0",      "clusterer",     ...
                "k-means=r1",        "clusterer",     ...
                "svm=r2",            "clusterer",     ...
                "voronoi=r3",        "clusterer",     ...
                "hard-alpha",        @s_hard_alpha,   ...
                "soft-alpha=f",      "soft_alpha",    ...
                "em-iterations=i",   "em_iterations", ...
                "em-threshold=f",    "em_threshold",  ...
                "euclidean-dist=r0", "distance",      ...
                "kernel-dist=r1",    "distance",      ...
                "linear-kernel=r0",  "kernel",        ...
                "poly-kernel=r1",    "kernel",        ...
                "rbf-kernel=r2",     "kernel",        ...
                "poly-degree=i",     "poly_degree",   ...
                "poly-constant!",    "poly_constant", ...
                "rbf-gamma=f",       "rbf_gamma",     ...
                "dense-csf=r0",      "csf",           ...
                "ndense-csf=r1",     "csf",           ...
                "nsize-csf=r2",      "csf",           ...
                "radius-csf=r3",     "csf",           ...
                "size-csf=r4",       "csf");

%% Chek number of arguments
if length(cmd_args) ~= 1 && length(cmd_args) ~= 2
  error("Wrong number of arguments (should be 1 or 2)");
endif

%% Test given
test_given = (length(cmd_args) == 2)

%% Set a seed
if isempty(cmd_opts.seed)
  cmd_opts.seed = floor(1000.0 * rand());
endif



%%%%%%%%%%%%%
%% Helpers %%
%%%%%%%%%%%%%

%% Log
function log(fmt, varargin)
  %% Print it
  fprintf(2, fmt, varargin{:});
endfunction

%% Wrap read
function [ data, truth ] = wrap_read(file, is_sparse, has_truth)
  %% Has truth?
  if has_truth
    %% Sparse?
    if is_sparse
      %% Read sparse
      [ data, truth ] = read_sparse(file, true());
    else
      %% Read full
      [ data, truth ] = read_full  (file, true());
    endif

  else %% ~has_truth
    %% Sparse?
    if is_sparse
      %% Read sparse
      data = read_sparse(file, false());
    else
      %% Read full
      data = read_full  (file, false());
    endif

    %% The truth is out there
    truth = [];
  endif
endfunction


%%%%%%%%%%
%% Data %%
%%%%%%%%%%

%% Read the train
train_file = cmd_args{1};
[ train_data, train_truth ] = ...
    wrap_read(train_file, cmd_opts.sparse, cmd_opts.train_truth);
log("Read train file %s\n", train_file);

%% Number of samples
[ n_train_feats, n_train ] = size(train_data);

%% Test given?
if test_given
  %% Read the test
  test_file = cmd_args{2};
  [ test_data, test_truth ] = ...
      wrap_read(test_file, cmd_opts.sparse, cmd_opts.test_truth);
  log("Read test file %s\n", test_file);

  %% Number of samples
  [ n_test_feats, n_test ] = size(test_data);

  %% Complete the test matrix
  if n_test_feats < n_train_feats
    if cmd_opts.sparse
      test_data = [ test_data ; sparse(n_train_feats - n_test_feats, n_test) ];
    else
      test_data = [ test_data ; zeros (n_train_feats - n_test_feats, n_test) ];
    endif
  endif
endif


%%%%%%%%%%%%%%%%%%%%%
%% Object Creation %%
%%%%%%%%%%%%%%%%%%%%%

%% Learner method
switch cmd_opts.method
  case M_BBOCC
    %% BBOCC learner
    learner = BBOCC()

  case M_HOCC
    %% HOCC learner
    learner = HOCC()

  case M_HYPER_BB
    %% Hyper-BB learner
    learner = HYPER_BB()

  case M_OC_IB
    %% OC-IB learner
    learner = OC_IB()

  case M_EWOCS
    %% First, Weak Clusterer
    switch cmd_opts.clusterer
      case C_BERNOULLI
        %% Bernoulli clusterer
        clusterer = Bernoulli()

      case C_KMEANS
        %% k-Means clusterer
        clusterer = KMeans()

      case C_SVM
        %% SVM clusterer
        clusterer = SVM()

      case C_VORONOI
        %% Voronoi clusterer
        clusterer = Voronoi()
    endswitch

    %% Then, EWOCS learner
    learner = EWOCS()
endswitch

%%%%%%%%%%%%%
%% Process %%
%%%%%%%%%%%%%

%% Results
train_scores = zeros(runs, n_train);
if test_given
  test_scores = zeros(runs, n_test);
endif

%% For each run
for run = 1 : cmd_opts.runs
  %% Learn a scorer
  [ train_score, scorer ] = learn(learner, train_data);

  %% Apply it


endfor
