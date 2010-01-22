%% -*- mode: octave; -*-

%% Weak classifiers test

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

%% Set rbf gamma
function [ opts ] = set_rbf_gamma(opts, value)
  opts.rbf_gamma = cellfun(@str2double, regex_split(value, '(,|\s+,)\s*'));
endfunction

%% Set all do's function
function [ opts ] = set_all_do(opts, value)
  opts.do_berni = opts.do_kmean = opts.do_svm = opts.do_ssvm = ...
      opts.do_qsvm = opts.do_sqsvm = opts.do_rbf = opts.do_srbf = ...
      opts.do_cpmmc = opts.do_smmc = opts.do_rfnce = value;
endfunction

%% Set all hard's function
function [ opts ] = set_all_hard(opts, value)
  opts.do_svm = opts.do_qsvm = opts.do_rbf = opts.do_cpmmc = value;
endfunction

%% Set all soft's function
function [ opts ] = set_all_soft(opts, value)
  opts.do_ssvm = opts.do_sqsvm = opts.do_srbf = opts.do_smmc = value;
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
def_opts.rbf_gamma  = [ 0.1, 0.2, 0.5, 1.0, 2.0, 5.0, 10.0 ];
def_opts.runs       = 1;
def_opts.repeats    = 100;
def_opts.seed       = [];
def_opts.max_tries  = 10;
def_opts.threshold  = 10;
def_opts.train      = "apw2000";
def_opts.test       = "ace0Xall_c";
def_opts.rfnce_head = "Base-Soft-NSiz";
def_opts.do_berni   = false();
def_opts.do_kmean   = false();
def_opts.do_svm     = false();
def_opts.do_ssvm    = false();
def_opts.do_qsvm    = false();
def_opts.do_sqsvm   = false();
def_opts.do_rbf     = false();
def_opts.do_srbf    = false();
def_opts.do_cpmmc   = false();
def_opts.do_smmc    = false();
def_opts.do_rfnce   = false();

%% Parse options
[ cmd_args, cmd_opts ] = ...
    get_options(def_opts, ...
		"soft-alpha=s",      @set_soft_alpha, ...
		"rbf-gamma=s",       @set_rbf_gamma,  ...
		"runs=i",            "runs",          ...
		"repeats=i",         "repeats",       ...
		"seed=f",            "seed",          ...
		"max-tries=i",       "max_tries",     ...
		"threshold=i",       "threshold",     ...
		"train=s",           "train",         ...
		"test=s",            "test",          ...
		"reference-header=s","rfnce_head",    ...
		"do-bernoulli!",     "do_berni",      ...
		"do-kmeans!",        "do_kmean",      ...
		"do-svm!",           "do_svm",        ...
		"do-soft-svm!",      "do_ssvm",       ...
		"do-quad-svm!",      "do_qsvm",       ...
		"do-soft-quad-svm!", "do_sqsvm",      ...
		"do-rbf-svm!",       "do_rbf",        ...
		"do-soft-rbf-svm!",  "do_srbf",       ...
		"do-cpmmc!",         "do_cpmmc",      ...
		"do-soft-cpmmc!",    "do_smmc",       ...
		"do-reference!",     "do_rfnce",      ...
		"do-all",            @set_all_do,     ...
		"do-none~",          @set_all_do,     ...
		"do-all-hard",       @set_all_hard,   ...
		"do-none-hard~",     @set_all_hard,   ...
		"do-all-soft",       @set_all_soft,   ...
		"do-none-soft~",     @set_all_soft);

%% Chek number of arguments
if length(cmd_args) != 1 && length(cmd_args) != 3
  error("Wrong number of arguments (should be 1 or 3)");
endif

%% Set a seed
if isempty(cmd_opts.seed)
  cmd_opts.seed = floor(1000.0 * rand());
endif

%% Number of alpha's and gamma's
n_alpha = length(cmd_opts.soft_alpha);
n_gamma = length(cmd_opts.rbf_gamma);


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

%% CPMMC works so far?
cpmmc_works = true();

%% For each run
for run = 1 : cmd_opts.runs

  %%%%%%%%%%%%
  %% Scores %%
  %%%%%%%%%%%%

  %% Accumulated scores

  %% Bernoulli
  if cmd_opts.do_berni
    %% train_berni_scores = zeros(1, n_train);
    test_berni_scores  = zeros(1, n_test);
  endif

  %% k-Means
  if cmd_opts.do_kmean
    %% train_kmean_scores = zeros(1, n_train);
    test_kmean_scores  = zeros(1, n_test);
  endif

  %% SVM
  if cmd_opts.do_svm  
    %% train_svm_scores = zeros(1, n_train);
    test_svm_scores  = zeros(1, n_test);
  endif

  %% Soft SVM
  if cmd_opts.do_ssvm
    %% train_ssvm_scores = cell(1, n_alpha);
    test_ssvm_scores  = cell(1, n_alpha);
    for i = 1 : n_alpha
      %% train_ssvm_scores{i} = zeros(1, n_test);
      test_ssvm_scores {i} = zeros(1, n_test);
    endfor
  endif

  %% Quadratic SVM
  if cmd_opts.do_qsvm
    %% train_qsvm_scores = zeros(1, n_train);
    test_qsvm_scores  = zeros(1, n_test);
  endif

  %% Soft Quadratic SVM
  if cmd_opts.do_sqsvm
    %% train_sqsvm_scores = cell(1, n_alpha);
    test_sqsvm_scores  = cell(1, n_alpha);
    for i = 1 : n_alpha
      %% train_sqsvm_scores{i} = zeros(1, n_train);
      test_sqsvm_scores {i} = zeros(1, n_test);
    endfor
  endif

  %% RBF SVM
  if cmd_opts.do_rbf
    %% train_rbf_scores = cell(n_gamma, 1);
    test_rbf_scores  = cell(n_gamma, 1);
    for j = 1 : n_gamma
      %% train_rbf_scores{j} = zeros(1, n_train);
      test_rbf_scores {j} = zeros(1, n_test);
    endfor
  endif

  %% Soft RBF SVM
  if cmd_opts.do_srbf
    %% train_srbf_scores = cell(n_gamma, n_alpha);
    test_srbf_scores  = cell(n_gamma, n_alpha);
    for j = 1 : n_gamma
      for i = 1 : n_alpha
	%% train_srbf_scores{j,i} = zeros(1, n_train);
	test_srbf_scores {j,i} = zeros(1, n_test);
      endfor
    endfor
  endif

  %% CPMMC
  if cmd_opts.do_cpmmc
    %% train_cpmmc_scores = zeros(1, n_train);
    test_cpmmc_scores  = zeros(1, n_test);
  endif

  %% Soft CPMMC
  if cmd_opts.do_smmc
    %% train_smmc_scores = cell(1, n_alpha);
    test_smmc_scores  = cell(1, n_alpha);
    for i = 1 : n_alpha
      %% train_smmc_scores{i} = zeros(1, n_train);
      test_smmc_scores {i} = zeros(1, n_test);
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


    %%%%%%%%%%%%%%%
    %% Bernoulli %%
    %%%%%%%%%%%%%%%

    if cmd_opts.do_berni

      %% Find the model
      berni_opts         = struct();
      berni_opts.expec_0 = seed_expec;
      [ berni_expec, berni_model, berni_info ] = ...
	  bernoulli_clustering(train_data, 2, berni_opts);

      %% Log
      fprintf(2, ...
	      "%2d:%3d: Bernoulli clustering in %d iterations (Log-like=%g)\n", ...
	      run, repeat, berni_info.iterations, berni_info.log_like);

      %% Update train scores
      berni_scores        = sum(berni_expec, 2)';
      %% train_berni_scores += berni_scores * berni_expec;

      %% Update test scores
      test_berni_expec   = bernoulli_expectation(test_data, berni_model);
      test_berni_scores += berni_scores * test_berni_expec;

      %% Clear
      clear berni_opts berni_expec berni_model berni_info
      clear berni_scores test_berni_expec
    endif


    %%%%%%%%%%%%%
    %% k-Means %%
    %%%%%%%%%%%%%

    if cmd_opts.do_kmean

      %% Find k-Means
      kmean_opts         = struct();
      %% @todo: Uncomment. Commented for compatibility.
      %% kmean_opts.expec_0 = seed_expec;
      [ kmean_expec, kmean_model, kmean_info ] = ...
	  kmeans_clustering(train_data, 2, kmean_opts);

      %% Log
      fprintf(2, "        k-Means clustering in %d iterations (Sum-sq=%g)\n", ...
	      kmean_info.iterations, kmean_info.sum_sq);

      %% Update train scores
      kmean_scores        = sum(kmean_expec, 2)';
      %% train_kmean_scores += kmean_scores * kmean_expec;
      
      %% Update test scores
      test_kmean_expec   = kmeans_expectation(test_data, kmean_model);
      test_kmean_scores += kmean_scores * test_kmean_expec;

      %% Clear
      clear kmean_opts kmean_expec kmean_model kmean_info
      clear kmean_scores test_kmean_expec
    endif


    %%%%%%%%%
    %% SVM %%
    %%%%%%%%%
    
    if cmd_opts.do_svm || cmd_opts.do_ssvm || ...
	  (cpmmc_works && (cmd_opts.do_cpmmc || cmd_opts.do_smmc))

      %% Find SVM
      svm_opts          = struct();
      svm_opts.use_dual = false();
      [ svm_model, svm_info ] = ...
	  twopoint_svm(train_data(:, [ seed1, seed2 ]), svm_opts);

      %% Log
      fprintf(2, "        SVM fitted in %d iterations (obj=%g)\n", ...
	      svm_info.iterations, svm_info.obj);

      %% Apply to train
      train_svm_dist = svm_model.omega' * train_data + svm_model.b;

      %% Apply to test
      test_svm_dist  = svm_model.omega' * test_data + svm_model.b;

      %% Clear
      clear svm_opts svm_info

      if cmd_opts.do_svm

	%% Apply to train
	train_svm_expec   = ...
	    sparse(sign(train_svm_dist) / 2 + 1.5, 1 : n_train, ...
		   ones(1, n_train), 2, n_train);
	svm_scores        = sum(train_svm_expec, 2)';
	%% train_svm_scores += svm_scores * train_svm_expec;

	%% Apply to test
	test_svm_expec   = ...
	    sparse(sign(test_svm_dist) / 2 + 1.5, 1 : n_test, ...
		   ones(1, n_test), 2, n_test);
	test_svm_scores += svm_scores * test_svm_expec;

	%% Clear
	clear train_svm_expec svm_scores test_svm_expec
      endif


      %%%%%%%%%%%%%%
      %% Soft SVM %%
      %%%%%%%%%%%%%%

      if cmd_opts.do_ssvm

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
	  if i == 1
	    fprintf(2, "        Softened SVM decision for alpha=%.3f", ...
		    cmd_opts.soft_alpha(i));
	  else
	    fprintf(2, ",%.3f", ...
		    cmd_opts.soft_alpha(i));
	  endif
	endfor

	%% Newline
	fprintf(2, "\n");

	%% Clear
	clear train_ssvm_expec ssvm_scores test_ssvm_expec
      endif

      %% Clear
      clear train_svm_dist test_svm_dist
    endif


    %%%%%%%%%%%%%%%%%%%
    %% Quadratic SVM %%
    %%%%%%%%%%%%%%%%%%%
    
    if cmd_opts.do_qsvm || cmd_opts.do_sqsvm

      %% Find quadratic SVM
      qsvm_opts        = struct();
      qsvm_opts.radial = false();
      qsvm_opts.kernel = @(x) (x .+ 1) .^ 2;
      [ qsvm_model, qsvm_info ] = ...
	  twopoint_kernel_svm(train_data(:, [ seed1, seed2 ]), qsvm_opts);

      %% Log
      fprintf(2, "        Quadratic SVM fitted in %d iterations (obj=%g)\n", ...
	      qsvm_info.iterations, qsvm_info.obj);

      %% Apply to train
      train_qsvm_dist = ...
	  simple_kernel_svm_distances(train_data, qsvm_model);

      %% Apply to test
      test_qsvm_dist  = simple_kernel_svm_distances(test_data, qsvm_model);

      %% Clear
      clear qsvm_opts qsvm_model qsvm_info

      if cmd_opts.do_qsvm

	%% Apply to train
	train_qsvm_expec   = ...
	    sparse(sign(train_qsvm_dist) / 2 + 1.5, 1 : n_train, ...
		   ones(1, n_train), 2, n_train);
	qsvm_scores        = sum(train_qsvm_expec, 2)';
	%% train_qsvm_scores += qsvm_scores * train_qsvm_expec;

	%% Apply to test
	test_qsvm_expec   = ...
	    sparse(sign(test_qsvm_dist) / 2 + 1.5, 1 : n_test, ...
		   ones(1, n_test), 2, n_test);
	test_qsvm_scores += qsvm_scores * test_qsvm_expec;

	%% Clear
	clear train_qsvm_expec qsvm_scores test_qsvm_expec
      endif


      %%%%%%%%%%%%%%%%%%%%%%%%
      %% Soft Quadratic SVM %%
      %%%%%%%%%%%%%%%%%%%%%%%%

      if cmd_opts.do_sqsvm

	for i = 1 : n_alpha

	  %% Apply to train
	  train_sqsvm_expec = ...
	      [ exp( cmd_opts.soft_alpha(i) * train_qsvm_dist) ./ ...
	       (exp( cmd_opts.soft_alpha(i) * train_qsvm_dist) +  ...
		exp(-cmd_opts.soft_alpha(i) * train_qsvm_dist)) ; ...
	        exp(-cmd_opts.soft_alpha(i) * train_qsvm_dist) ./ ...
	       (exp( cmd_opts.soft_alpha(i) * train_qsvm_dist) +  ...
		exp(-cmd_opts.soft_alpha(i) * train_qsvm_dist)) ];
	  sqsvm_scores = sum(train_sqsvm_expec, 2)';
	  
	  %% Apply to test
	  test_sqsvm_expec = ...
	      [ exp( cmd_opts.soft_alpha(i) * test_qsvm_dist) ./ ...
	       (exp( cmd_opts.soft_alpha(i) * test_qsvm_dist) +  ...
		exp(-cmd_opts.soft_alpha(i) * test_qsvm_dist)) ; ...
	        exp(-cmd_opts.soft_alpha(i) * test_qsvm_dist) ./ ...
	       (exp( cmd_opts.soft_alpha(i) * test_qsvm_dist) +  ...
		exp(-cmd_opts.soft_alpha(i) * test_qsvm_dist)) ];
	  test_sqsvm_scores{i} += sqsvm_scores * test_sqsvm_expec;
	  
	  %% Log
	  if i == 1
	    fprintf(2, "        Softened Quadratic SVM decision for alpha=%.3f", ...
		    cmd_opts.soft_alpha(i));
	  else
	    fprintf(2, ",%.3f", ...
		    cmd_opts.soft_alpha(i));
	  endif
	endfor

	%% Newline
	fprintf(2, "\n");

	%% Clear
	clear train_sqsvm_expec sqsvm_scores test_sqsvm_expec
      endif

      %% Clear
      clear train_qsvm_dist test_qsvm_dist
    endif


    %%%%%%%%%%%%%
    %% RBF SVM %%
    %%%%%%%%%%%%%
    
    if cmd_opts.do_rbf || cmd_opts.do_srbf

      for j = 1 : n_gamma

	%% Find RBF SVM
	rbf_opts        = struct();
	rbf_opts.radial = true();
	rbf_opts.kernel = @(x) exp(-cmd_opts.rbf_gamma(j) * x);
	[ rbf_model, rbf_info ] = ...
	    twopoint_kernel_svm(train_data(:, [ seed1, seed2 ]), rbf_opts);

	%% Log
	fprintf(2, "        RBF SVM fitted in %d iterations for gamma=%g (obj=%g)\n", ...
		rbf_info.iterations, cmd_opts.rbf_gamma(j), rbf_info.obj);

	%% Apply to train
	train_rbf_dist = simple_kernel_svm_distances(train_data, rbf_model);

	%% Apply to test
	test_rbf_dist  = simple_kernel_svm_distances(test_data, rbf_model);

	%% Clear
	clear rbf_opts rbf_model rbf_info

	if cmd_opts.do_rbf

	  %% Apply to train
	  train_rbf_expec   = ...
	      sparse(sign(train_rbf_dist) / 2 + 1.5, 1 : n_train, ...
		     ones(1, n_train), 2, n_train);
	  rbf_scores        = sum(train_rbf_expec, 2)';
	  %% train_rbf_scores += rbf_scores * train_rbf_expec;
	  
	  %% Apply to test
	  test_rbf_expec   = ...
	      sparse(sign(test_rbf_dist) / 2 + 1.5, 1 : n_test, ...
		     ones(1, n_test), 2, n_test);
	  test_rbf_scores{j} += rbf_scores * test_rbf_expec;

	  %% Clear
	  clear train_rbf_expec rbf_scores test_rbf_expec
	endif

	
	%%%%%%%%%%%%%%%%%%
	%% Soft RBF SVM %%
	%%%%%%%%%%%%%%%%%%

	if cmd_opts.do_srbf

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
	    test_srbf_scores{j,i} += srbf_scores * test_srbf_expec;

	    %% Log
	    if i == 1
	      fprintf(2, "        Softened RBF SVM decision for alpha=%.3f", ...
		      cmd_opts.soft_alpha(i));
	    else
	      fprintf(2, ",%.3f", ...
		      cmd_opts.soft_alpha(i));
	    endif
	  endfor
	    
	  %% Newline
	  fprintf(2, "\n");

	  %% Clear
	  clear train_srbf_expec srbf_scores test_srbf_expec
	endif

	%% Clear
	clear train_rbf_dist test_rbf_dist
      endfor
    endif


    %%%%%%%%%%%
    %% CPMMC %%
    %%%%%%%%%%%

    if cpmmc_works && (cmd_opts.do_cpmmc || cmd_opts.do_smmc)

      %% Find CPMMC
      cpmmc_opts         = struct();
      cpmmc_opts.omega_0 = svm_model.omega;
      cpmmc_opts.b_0     = svm_model.b;

      %% Try it
      cpmmc_end   = false();
      cpmmc_tries = 0;
      while ~cpmmc_end
	try 
	  %% Try
	  ++cpmmc_tries;
	  [ cpmmc_expec, cpmmc_model, cpmmc_info ] = ...
	      CPM3C_clustering(train_data, 2, cpmmc_opts);

          %% Log
	  fprintf(2, "        CPMMC clustering in %d iterations (obj=%g, try=#%d)\n", ...
		  cpmmc_info.iterations, cpmmc_info.obj, cpmmc_tries);

          %% Apply to train
	  train_cpmmc_dist = cpmmc_model.omega' * train_data + cpmmc_model.b;
	  test_cpmmc_dist  = cpmmc_model.omega' * test_data  + cpmmc_model.b;

	  %% Clear
	  clear cpmmc_model cpmmc_info

	  if cmd_opts.do_cpmmc

            %% Apply to train
	    cpmmc_scores        = sum(cpmmc_expec, 2)';
	    %% train_cpmmc_scores += cpmmc_scores * cpmmc_expec;
	    
            %% Apply to test
	    test_cpmmc_expec   = ...
		sparse(sign(test_cpmmc_dist) / 2 + 1.5, 1 : n_test, ...
		       ones(1, n_test), 2, n_test);
	    test_cpmmc_scores += cpmmc_scores * test_cpmmc_expec;

	    %% Clear
	    clear cpmmc_scores test_cpmmc_expec
	  endif

	  %% Clear
	  clear cpmmc_expec


	  %%%%%%%%%%%%%%%%
	  %% Soft CPMMC %%
	  %%%%%%%%%%%%%%%%

	  if cmd_opts.do_smmc

	    for i = 1 : n_alpha

	      %% Apply to train
	      train_smmc_expec   = ...
		  [ exp( cmd_opts.soft_alpha(i) * train_cpmmc_dist) ./ ...
		   (exp( cmd_opts.soft_alpha(i) * train_cpmmc_dist) +  ...
		    exp(-cmd_opts.soft_alpha(i) * train_cpmmc_dist)) ; ...
	            exp(-cmd_opts.soft_alpha(i) * train_cpmmc_dist) ./ ...
		   (exp( cmd_opts.soft_alpha(i) * train_cpmmc_dist) +  ...
		    exp(-cmd_opts.soft_alpha(i) * train_cpmmc_dist)) ];
	      smmc_scores        = sum(train_smmc_expec, 2)';
	      %% train_smmc_scores += smmc_scores * train_smmc_expec;

	      %% Apply to test
	      test_smmc_expec   = ...
		  [ exp( cmd_opts.soft_alpha(i) * test_cpmmc_dist) ./ ...
		   (exp( cmd_opts.soft_alpha(i) * test_cpmmc_dist) +  ...
		    exp(-cmd_opts.soft_alpha(i) * test_cpmmc_dist)) ; ...
	            exp(-cmd_opts.soft_alpha(i) * test_cpmmc_dist) ./ ...
		   (exp( cmd_opts.soft_alpha(i) * test_cpmmc_dist) +  ...
		    exp(-cmd_opts.soft_alpha(i) * test_cpmmc_dist)) ];
	      test_smmc_scores{i} += smmc_scores * test_smmc_expec;

	      %% Log
	      if i == 1
		fprintf(2, "        Softened CPMMC decision for alpha=%.3f", ...
			cmd_opts.soft_alpha(i));
	      else
		fprintf(2, ",%.3f", ...
			cmd_opts.soft_alpha(i));
	      endif
	    endfor
	    
	    %% Newline
	    fprintf(2, "\n");

	    %% Clear
	    clear train_smmc_expec smmc_scores test_smmc_expec
	  endif

	  %% It worked!
	  cpmmc_end = true();

	catch
	  %% Fail
	  fprintf(2, "        CPMMC clustering failed '%s' (try=#%d)\n", ...
		  lasterr(), cpmmc_tries);

	  %% Too many?
	  if cpmmc_tries == cmd_opts.max_tries
	    fprintf(2, ...
		    "        Unable to make CPMMC work after %d tries, skipping\n", ...
		    cmd_opts.max_tries);
	    cpmmc_works = false();
	    cpmmc_end   = true();
	  endif
	end_try_catch
      endwhile

      %% Clear
      clear svm_model cpmmc_end cpmmc_tries cpmmc_opts
    endif
  endfor
  

  %%%%%%%%%%%%%%%%
  %% CUR & Dump %%
  %%%%%%%%%%%%%%%%

  %% Header
  if run == 1
    printf("# Pair: %s Feature: %s\n", pair, feat);
  endif

  %% Seeds
  printf("# Run: #%d Seeds: %d, %d\n", run, seed1, seed2);

  %% Bernoulli
  if cmd_opts.do_berni
    %% Dump
    printf("# Bernoulli #%d\n", run);
    printf(DUMP_FORMAT, ...
	   evaluation_curves(test_berni_scores, test_truth_expec, ...
			     test_truth_sizes));
    printf("\n\n");
  endif

  %% k-Means
  if cmd_opts.do_kmean
    printf("# k-Means #%d\n", run);
    printf(DUMP_FORMAT, ...
	   evaluation_curves(test_kmean_scores, test_truth_expec, ...
			     test_truth_sizes));
    printf("\n\n");
  endif

  %% SVM
  if cmd_opts.do_svm
    printf("# SVM #%d\n", run);
    printf(DUMP_FORMAT, ...
	   evaluation_curves(test_svm_scores, test_truth_expec, ...
			     test_truth_sizes));
    printf("\n\n");
  endif

  %% Soft SVM
  if cmd_opts.do_ssvm
    for i = 1 : n_alpha
      printf("# Soft SVM %.3f #%d\n", cmd_opts.soft_alpha(i), run);
      printf(DUMP_FORMAT, ...
	     evaluation_curves(test_ssvm_scores{i}, test_truth_expec, ...
			       test_truth_sizes));
      printf("\n\n");
    endfor
  endif

  %% Quadratic SVM
  if cmd_opts.do_qsvm
    printf("# Quadratic SVM #%d\n", run);
    printf(DUMP_FORMAT, ...
	   evaluation_curves(test_qsvm_scores,  test_truth_expec, ...
			     test_truth_sizes));
    printf("\n\n");
  endif

  %% Soft Quadratic SVM
  if cmd_opts.do_sqsvm
    for i = 1 : n_alpha
      printf("# Soft Quadratic SVM %.3f #%d\n", cmd_opts.soft_alpha(i), run);
      printf(DUMP_FORMAT, ...
	     evaluation_curves(test_sqsvm_scores{i}, test_truth_expec, ...
			       test_truth_sizes));
      printf("\n\n");
    endfor
  endif

  %% RBF SVM
  if cmd_opts.do_rbf
    for j = 1 : n_gamma
      printf("# RBF SVM %.3f #%d\n", cmd_opts.rbf_gamma(j), run);
      printf(DUMP_FORMAT, ...
	     evaluation_curves(test_rbf_scores{j}, test_truth_expec, ...
			       test_truth_sizes));
      printf("\n\n");
    endfor
  endif

  %% Soft RBF SVM
  if cmd_opts.do_srbf
    for j = 1 : n_gamma
      for i = 1 : n_alpha
	printf("# Soft RBF SVM %.3f %.3f #%d\n", ...
	       cmd_opts.rbf_gamma(j), cmd_opts.soft_alpha(i), run)
	printf(DUMP_FORMAT, ...
	       evaluation_curves(test_srbf_scores{j,i}, test_truth_expec, ...
				 test_truth_sizes));
	printf("\n\n");
      endfor
    endfor
  endif

  %% CPMMC
  if cmd_opts.do_cpmmc && cpmmc_works
    printf("# CPMMC #%d\n", run);
    printf(DUMP_FORMAT, ...
	   evaluation_curves(test_cpmmc_scores, test_truth_expec, ...
			     test_truth_sizes));
    printf("\n\n");
  endif
  
  %% Soft CPMMC
  if cmd_opts.do_smmc && cpmmc_works
    for i = 1 : n_alpha
      printf("# Soft CPMMC %.3f #%d\n", cmd_opts.soft_alpha(i), run);
      printf(DUMP_FORMAT, ...
	     evaluation_curves(test_smmc_scores{i}, test_truth_expec, ...
			       test_truth_sizes));
      printf("\n\n");
    endfor
  endif
    

  %%%%%%%%%%%%%%%
  %% Reference %%
  %%%%%%%%%%%%%%%

  if cmd_opts.do_rfnce
    try
      %% Reference
      rfnce_file = ...
	  sprintf("%s/combi%s/r%d/%s.redo.nx.gz", data_dir, th_infix, ...
		  run - 1, cmd_opts.train);
      rfnce_header = ...
	  sprintf("%s .+/%s%s.matrix.gz", cmd_opts.rfnce_head, ...
		  cmd_opts.test, th_infix)
      rfnce_info = read_redo(rfnce_file, rfnce_header);
      fprintf(2, "%2d:     Read reference file %s\n", run, rfnce_file);

      %% Found it?
      if isempty(rfnce_info)
	%% Not found!
	fprintf(2, "        Reference information not available for %s\n", ...
		cmd_opts.rfnce_head);
	
      else
	%% Curves
	rfnce_length = size(rfnce_info, 1);

	%% ROC and total
	rfnce_roc   = rfnce_info(:, [ 5, 4 ])';
	rfnce_total = sum(rfnce_roc, 1);
	rfnce_roc ./= rfnce_roc(:, rfnce_length) * ones(1, rfnce_length);

	%% Precision
	rfnce_prc   = rfnce_info(:, 4)' ./ rfnce_total;

	%% F1
	rfnce_f1    = 2 * (rfnce_prc .* rfnce_roc(2, :)) ./ ...
                      (rfnce_prc .+ rfnce_roc(2, :));

	%% Scores
	rfnce_sco   = rfnce_info(:, 10)';

	%% Curve
	rfnce_cur   = [ rfnce_total ; rfnce_roc ; rfnce_prc ; ...
		        rfnce_f1 ; rfnce_sco ];

	%% Dump
	printf("# Reference #%d\n", run);
	printf(DUMP_FORMAT, rfnce_cur);
	printf("\n\n");

	%% Clear
	clear rfnce_roc rfnce_total rfnce_roc rfnce_prc rfnce_f1
	clear rfnce_sco rfnce_cur
      endif

      %% Clear
      clear rnfce_info

    catch
      %% Error reading
      fprintf(2, "%2d:     Could not read reference file %s", run, rfnce_file);
    end_try_catch
  endif

  %% Clear
  clear seed_expec
endfor
