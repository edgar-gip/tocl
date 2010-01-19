%% -*- mode: octave; -*-

%% Soft weak classifiers test

%% Author: Edgar Gonzàlez i Pellicer


%% Path
addpath("~/devel/libs/liboctave-0.1/base")

%%%%%%%%%%%
% Helpers %
%%%%%%%%%%%

%% Set soft alpha
function [ opts ] = set_soft_alpha(opts, value)
  opts.soft_alpha = cellfun(@str2double, regex_split(value, '(,|\s+,)\s*'));
endfunction

%% Set all do's function
function [ opts ] = set_all_do(opts, value)
  opts.do_ssvm = opts.do_sksvm = opts.do_srbf = value;
endfunction

%% Dump output format(constant)
DUMP_FORMAT = "%d %f %f %f %f %f\n";

%% Field information
enum SAMPLES NEGATIVES RECALL PRECISION F1;


%%%%%%%%%%%%%
%% Startup %%
%%%%%%%%%%%%%

%% Default options
def_opts            = struct();
def_opts.soft_alpha = [ 0.1, 0.2, 0.5, 1.0, 2.0, 5.0, 10.0 ];
def_opts.runs       = 1;
def_opts.repeats    = 100;
def_opts.seed       = [];
def_opts.threshold  = 10;
def_opts.train      = "apw2000";
def_opts.test       = "ace0Xall_c";
def_opts.do_ssvm    = false();
def_opts.do_sksvm   = false();
def_opts.do_srbf    = false();

%% Parse options
[ cmd_args, cmd_opts ] = ...
    get_options(def_opts, ...
		"soft-alpha=s",      @set_soft_alpha, ...
		"runs=i",            "runs",          ...
		"repeats=i",         "repeats",       ...
		"seed=f",            "seed",          ...
		"threshold=i",       "threshold",     ...
		"train=s",           "train",         ...
		"test=s",            "test",          ...
		"do-soft-svm!",      "do_ssvm",       ...
		"do-soft-quad-svm!", "do_sksvm",      ...
		"do-soft-rbf-svm!",  "do_srbf",       ...
		"do-all",            @set_all_do,     ...
		"do-none~",          @set_all_do);

%% Chek number of arguments
if length(cmd_args) != 1 && length(cmd_args) != 3
  error("Wrong number of arguments (should be 1 or 3)");
endif

%% Set a seed
if isempty(cmd_opts.seed)
  cmd_opts.seed = floor(1000.0 * rand());
endif

%% Number of alpha's
n_alpha = length(cmd_opts.soft_alpha);


%%%%%%%%%%
%% Data %%
%%%%%%%%%%

%% Get arguments
if length(cmd_args) == 1
  %% Get it
  data_dir = (cmd_args()){1};

  %% Split
  if ~([ match, base_dir, pair, feat ] =
       regex_match(data_dir, '(.+)/([A-Za-z\-]+)/([sdlm]+)/?'))
    %% Warn (and leave the dummy empty values)
    warning("Directory %s is not splitable", data_dir);
  endif

else % length(cmd_args) == 3
  %% Get them
  base_dir = (cmd_args()){1};
  pair     = (cmd_args()){2};
  feat     = (cmd_args()){3};

  %% Format the data dir
  data_dir = sprintf("%s/%s/%s", base_dir, pair, feat);
endif

%% Infix  
if cmd_opts.threshold == 1
  th_infix = "";
else
  th_infix = sprintf(".t%d", cmd_opts.threshold);
endif

%% Files
train_file = sprintf("%s/%s%s.matrix.gz", data_dir, cmd_opts.train, th_infix);
test_file  = sprintf("%s/%s%s.matrix.gz", data_dir, cmd_opts.test,  th_infix);

%% Prepare seed
fprintf(2, "        Using %d as random seed\n", cmd_opts.seed);
rand("seed", cmd_opts.seed);

%% Read training data
train_data = read_sparse(train_file);
fprintf(2, "        Read train file %s\n", train_file);

%% Read test data
[ test_data, test_truth ] = read_sparse(test_file, true());
fprintf(2, "        Read test file %s\n", test_file);

%% Number of samples
[ n_train_feats, n_train ] = size(train_data);
[ n_test_feats,  n_test  ] = size(test_data);

%% Complete the test matrix
if n_test_feats < n_train_feats
  test_data = [ test_data ; sparse(n_train_feats - n_test_feats, n_test) ];
endif

%% Truth expectation
test_truth_expec = ...
    sparse(test_truth / 2 + 1.5, 1 : n_test, ones(1, n_test));
test_truth_sizes = full(sum(test_truth_expec, 2));


%%%%%%%%%%%%%%
%% Run Loop %%
%%%%%%%%%%%%%%

%% For each run
for run = 1 : cmd_opts.runs

  %%%%%%%%%%%%
  %% Scores %%
  %%%%%%%%%%%%

  %% Soft SVM
  if cmd_opts.do_ssvm
    test_ssvm_scores = cell(1, n_alpha);
    for i = 1 : n_alpha
      test_ssvm_scores{i} = zeros(1, n_test);
    endfor
  endif

  %% Soft Quadratic SVM
  if cmd_opts.do_sksvm
    test_sksvm_scores = cell(1, n_alpha);
    for i = 1 : n_alpha
      test_sksvm_scores{i} = zeros(1, n_test);
    endfor
  endif

  %% Soft RBF SVM
  if cmd_opts.do_srbf
    test_srbf_scores = cell(1, n_alpha);
    for i = 1 : n_alpha
      test_srbf_scores{i} = zeros(1, n_test);
    endfor
  endif


  %%%%%%%%%%%%%%%%%
  %% Repeat Loop %%
  %%%%%%%%%%%%%%%%%

  %% For each repetition
  for repeat = 1 : cmd_opts.repeats

    %%%%%%%%%%%
    %% Seeds %%
    %%%%%%%%%%%

    %% Select the two seeds
    seed1 = 1 + floor( n_train      * rand());
    seed2 = 1 + floor((n_train - 1) * rand());
    if seed2 >= seed1
      ++seed2;
    endif

    %% Seed expectation
    seed_expec = sparse([ 1, 2 ], [ seed1, seed2 ], [ 1, 1 ], 2, n_train);


    %%%%%%%%%
    %% SVM %%
    %%%%%%%%%
    
    if cmd_opts.do_ssvm

      %% Find SVM
      svm_opts          = struct();
      svm_opts.use_dual = false();
      [ svm_model, svm_info ] = ...
	  twopoint_svm(train_data(:, [ seed1, seed2 ]), svm_opts);

      %% Log
      fprintf(2, "%2d:%3d: SVM fitted in %d iterations (obj=%g)\n", ...
	      run, repeat, svm_info.iterations, svm_info.obj);

      %% Apply to train
      train_svm_dist = svm_model.omega' * train_data + svm_model.b;

      %% Apply to test
      test_svm_dist  = svm_model.omega' * test_data + svm_model.b;

      %%%%%%%%%%%%%%
      %% Soft SVM %%
      %%%%%%%%%%%%%%

      for i = 1 : n_alpha
      
	%% Apply to train
	train_ssvm_expec = ...
	    [ exp( cmd_opts.soft_alpha(i) * train_svm_dist) ./ ...
	     (exp( cmd_opts.soft_alpha(i) * train_svm_dist) +  ...
	      exp(-cmd_opts.soft_alpha(i) * train_svm_dist)) ; ...
	      exp(-cmd_opts.soft_alpha(i) * train_svm_dist) ./ ...
	     (exp( cmd_opts.soft_alpha(i) * train_svm_dist) +  ...
	      exp(-cmd_opts.soft_alpha(i) * train_svm_dist)) ];
	ssvm_scores = sum(train_ssvm_expec, 2)';

	%% Apply to test
	test_ssvm_expec = ...
	    [ exp( cmd_opts.soft_alpha(i) * test_svm_dist) ./ ...
	     (exp( cmd_opts.soft_alpha(i) * test_svm_dist) +  ...
	      exp(-cmd_opts.soft_alpha(i) * test_svm_dist)) ; ...
	      exp(-cmd_opts.soft_alpha(i) * test_svm_dist) ./ ...
	     (exp( cmd_opts.soft_alpha(i) * test_svm_dist) +  ...
	      exp(-cmd_opts.soft_alpha(i) * test_svm_dist)) ];
	test_ssvm_scores{i} += ssvm_scores * test_ssvm_expec;
	
	%% Log
	fprintf(2, "        Softened SVM decision for alpha=%.3f\n", ...
		cmd_opts.soft_alpha(i));
	fprintf(2, "        - Updated scores\n");
      endfor
    endif


    %%%%%%%%%%%%%%%%%%%
    %% Quadratic SVM %%
    %%%%%%%%%%%%%%%%%%%
    
    if cmd_opts.do_sksvm

      %% Find quadratic SVM
      ksvm_opts        = struct();
      ksvm_opts.radial = false();
      ksvm_opts.kernel = @(x) (x .+ 1) .^ 2;
      [ ksvm_model, ksvm_info ] = ...
	  twopoint_kernel_svm(train_data(:, [ seed1, seed2 ]), ksvm_opts);

      %% Log
      fprintf(2, "        Quadratic SVM fitted in %d iterations (obj=%g)\n", ...
	      ksvm_info.iterations, ksvm_info.obj);

      %% Apply to train
      train_ksvm_dist = ...
	  simple_kernel_svm_distances(train_data, ksvm_model);

      %% Apply to test
      test_ksvm_dist  = simple_kernel_svm_distances(test_data, ksvm_model);

      %%%%%%%%%%%%%%%%%%%%%%%%
      %% Soft Quadratic SVM %%
      %%%%%%%%%%%%%%%%%%%%%%%%

      for i = 1 : n_alpha

	%% Apply to train
	train_sksvm_expec = ...
	    [ exp( cmd_opts.soft_alpha(i) * train_ksvm_dist) ./ ...
	     (exp( cmd_opts.soft_alpha(i) * train_ksvm_dist) +  ...
	      exp(-cmd_opts.soft_alpha(i) * train_ksvm_dist)) ; ...
	      exp(-cmd_opts.soft_alpha(i) * train_ksvm_dist) ./ ...
	     (exp( cmd_opts.soft_alpha(i) * train_ksvm_dist) +  ...
	      exp(-cmd_opts.soft_alpha(i) * train_ksvm_dist)) ];
	sksvm_scores = sum(train_sksvm_expec, 2)';
	
	%% Apply to test
	test_sksvm_expec = ...
	    [ exp( cmd_opts.soft_alpha(i) * test_ksvm_dist) ./ ...
	     (exp( cmd_opts.soft_alpha(i) * test_ksvm_dist) +  ...
	      exp(-cmd_opts.soft_alpha(i) * test_ksvm_dist)) ; ...
	      exp(-cmd_opts.soft_alpha(i) * test_ksvm_dist) ./ ...
	     (exp( cmd_opts.soft_alpha(i) * test_ksvm_dist) +  ...
	      exp(-cmd_opts.soft_alpha(i) * test_ksvm_dist)) ];
	test_sksvm_scores{i} += sksvm_scores * test_sksvm_expec;
      
	%% Log
	fprintf(2, "        Softened Quadratic SVM decision for alpha=%.3f\n",
		cmd_opts.soft_alpha(i));
	fprintf(2, "        - Updated scores\n");
      endfor
    endif


    %%%%%%%%%%%%%
    %% RBF SVM %%
    %%%%%%%%%%%%%
    
    if cmd_opts.do_srbf

      %% Find RBF SVM
      rbf_opts        = struct();
      rbf_opts.radial = true();
      rbf_opts.kernel = @(x) exp(-x);
      [ rbf_model, rbf_info ] = ...
	  twopoint_kernel_svm(train_data(:, [ seed1, seed2 ]), rbf_opts);

      %% Log
      fprintf(2, "        RBF SVM fitted in %d iterations (obj=%g)\n", ...
	      rbf_info.iterations, rbf_info.obj);

      %% Apply to train
      train_rbf_dist = simple_kernel_svm_distances(train_data, rbf_model);

      %% Apply to test
      test_rbf_dist  = simple_kernel_svm_distances(test_data, rbf_model);

      %%%%%%%%%%%%%%%%%%%%%%%%
      %% Soft Quadratic SVM %%
      %%%%%%%%%%%%%%%%%%%%%%%%

      for i = 1 : n_alpha

	%% Apply to train
	train_srbf_expec = ...
	    [ exp( cmd_opts.soft_alpha(i) * train_rbf_dist) ./ ...
	     (exp( cmd_opts.soft_alpha(i) * train_rbf_dist) +  ...
	      exp(-cmd_opts.soft_alpha(i) * train_rbf_dist)) ; ...
	      exp(-cmd_opts.soft_alpha(i) * train_rbf_dist) ./ ...
	     (exp( cmd_opts.soft_alpha(i) * train_rbf_dist) +  ...
	      exp(-cmd_opts.soft_alpha(i) * train_rbf_dist)) ];
	srbf_scores = sum(train_srbf_expec, 2)';

	%% Apply to test
	test_srbf_expec = ...
	    [ exp( cmd_opts.soft_alpha(i) * test_rbf_dist) ./ ...
	     (exp( cmd_opts.soft_alpha(i) * test_rbf_dist) +  ...
	      exp(-cmd_opts.soft_alpha(i) * test_rbf_dist)) ; ...
	      exp(-cmd_opts.soft_alpha(i) * test_rbf_dist) ./ ...
	     (exp( cmd_opts.soft_alpha(i) * test_rbf_dist) +  ...
	      exp(-cmd_opts.soft_alpha(i) * test_rbf_dist)) ];
	test_srbf_scores{i} += srbf_scores * test_srbf_expec;

	%% Log
	fprintf(2, "        Softened RBF SVM decision for alpha=%.3f\n",
		cmd_opts.soft_alpha(i));
	fprintf(2, "        - Updated scores\n");
      endfor
    endif
  endfor
  

  %%%%%%%%%
  %% CUR %%
  %%%%%%%%%

  %% Find the evaluation curves
  for i = 1 : n_alpha
    if cmd_opts.do_ssvm
      ssvm_cur{i} = evaluation_curves(test_ssvm_scores{i}, ...
				      test_truth_expec, ...
				      test_truth_sizes);
    endif
    if cmd_opts.do_sksvm
      sksvm_cur{i} = evaluation_curves(test_sksvm_scores{i}, ...
				       test_truth_expec, ...
				       test_truth_sizes);
    endif
    if cmd_opts.do_srbf
      srbf_cur{i} = evaluation_curves(test_srbf_scores{i}, ...
				      test_truth_expec, ...
				      test_truth_sizes);
    endif
  endfor


  %%%%%%%%%%
  %% Dump %%
  %%%%%%%%%%

  %% Header
  if run == 1
    printf("# %s %s\n", pair, feat);
  endif

  %% Print
  for i = 1 : n_alpha
    if cmd_opts.do_ssvm
      printf("# Soft SVM %.3f #%d\n", cmd_opts.soft_alpha(i), run);
      printf(DUMP_FORMAT, ssvm_cur{i}); printf("\n\n");
    endif
    if cmd_opts.do_sksvm
      printf("# Soft Quadratic SVM %.3f #%d\n", cmd_opts.soft_alpha(i), run);
      printf(DUMP_FORMAT, sksvm_cur{i}); printf("\n\n");
    endif
    if cmd_opts.do_srbf
      printf("# Soft RBF SVM %.3f #%d\n", cmd_opts.soft_alpha(i), run)
      printf(DUMP_FORMAT, srbf_cur{i}); printf("\n\n");
    endif
  endfor
endfor
