%% -*- mode: octave; -*-

%% Weak classifiers test

%% Author: Edgar Gonzàlez i Pellicer


%% Path
addpath("~/devel/libs/liboctave-0.1/base")

%%%%%%%%%%%
% Helpers %
%%%%%%%%%%%

%% Set all do's function
function [ opts ] = set_all_do(opts, value)
  opts.do_berni = opts.do_kmean = opts.do_svm = opts.do_ssvm = ...
      opts.do_ksvm = opts.do_sksvm = opts.do_rbf = opts.do_srbf = ...
      opts.do_cpmmc = opts.do_smmc = opts.do_rfnce = value;
endfunction

%% Set all hard's function
function [ opts ] = set_all_hard(opts, value)
  opts.do_svm = opts.do_ksvm = opts.do_rbf = opts.do_cpmmc = value;
endfunction

%% Set all soft's function
function [ opts ] = set_all_soft(opts, value)
  opts.do_ssvm = opts.do_sksvm = opts.do_srbf = opts.do_smmc = value;
endfunction

%% Set all plot's function
function [ opts ] = set_all_plot(opts, value)
  opts.do_f1 = opts.do_prc_rec = opts.do_roc = value;
endfunction

%% Plot curves
function plot_curves(title, xidx, x_label, yidx, y_label, curves, ...
		     legend_labels, legend_pos)
  %% List of items to plot
  items  = {};

  %% List of colours
  colours   = { "k-", "r-", "m-", "g-", "b-", "c-", "y-" };
  n_colours = length(colours);
  
  %% Add each
  for c = 1:length(curves)
    items = cell_push(items, curves{c}(xidx,:), curves{c}(yidx,:), ...
		      colours{1 + mod(length(items), n_colours)});
  endfor

  %% Plot
  figure();
  plot(items{:});
  %% title(title);
  legend(legend_labels, "location", legend_pos);
  xlabel(x_label);
  ylabel(y_label);
endfunction

%% Empty curve (constant)
EMPTY_CURVE = zeros(6, 1);

%% Dump output format(constant)
DUMP_FORMAT = "%d %f %f %f %f %f\n";

%% Field information
enum SAMPLES NEGATIVES RECALL PRECISION F1;


%%%%%%%%%%%%%
%% Startup %%
%%%%%%%%%%%%%

%% Default options
def_opts            = struct();
def_opts.soft_alpha = 1.0;
def_opts.runs       = 1;
def_opts.repeats    = 100;
def_opts.seed       = [];
def_opts.max_tries  = 10;
def_opts.threshold  = 10;
def_opts.train      = "apw2000";
def_opts.test       = "ace0Xall_c";
def_opts.rfnce_head = "Base-Soft-Siz";
def_opts.do_berni   = false();
def_opts.do_kmean   = false();
def_opts.do_svm     = false();
def_opts.do_ssvm    = false();
def_opts.do_ksvm    = false();
def_opts.do_sksvm   = false();
def_opts.do_rbf     = false();
def_opts.do_srbf    = false();
def_opts.do_cpmmc   = false();
def_opts.do_smmc    = false();
def_opts.do_rfnce   = false();
def_opts.do_dump    = true();
def_opts.do_f1      = false();
def_opts.do_prc_rec = false();
def_opts.do_roc     = false();

%% Parse options
[ cmd_args, cmd_opts ] = ...
    get_options(def_opts, ...
		"soft-alpha=f",      "soft_alpha", ...
		"runs=i",            "runs",       ...
		"repeats=i",         "repeats",    ...
		"seed=f",            "seed",       ...
		"max-tries=i",       "max_tries",  ...
		"threshold=i",       "threshold",  ...
		"train=s",           "train",      ...
		"test=s",            "test",       ...
		"reference-header=s","rfnce_head", ...
		"do-bernoulli!",     "do_berni",   ...
		"do-kmeans!",        "do_kmean",   ...
		"do-svm!",           "do_svm",     ...
		"do-soft-svm!",      "do_ssvm",    ...
		"do-quad-svm!",      "do_ksvm",    ...
		"do-soft-quad-svm!", "do_sksvm",   ...
		"do-rbf-svm!",       "do_rbf",     ...
		"do-soft-rbf-svm!",  "do_srbf",    ...
		"do-cpmmc!",         "do_cpmmc",   ...
		"do-soft-cpmmc!",    "do_smmc",    ...
		"do-reference!",     "do_rfnce",   ...
		"do-all",            @set_all_do,  ...
		"do-none~",          @set_all_do,  ...
		"do-all-hard",       @set_all_hard,...
		"do-none-hard~",     @set_all_hard,...
		"do-all-soft",       @set_all_soft,...
		"do-none-soft~",     @set_all_soft,...
		"dump!",             "do_dump",    ...
		"plot-f1!",          "do_f1",      ...
		"plot-prc-rec!",     "do_prc_rec", ...
		"plot-roc!",         "do_roc",     ...
		"plot-all",          @set_all_plot,...
		"plot-none~",        @set_all_plot);

%% Chek number of arguments
if length(cmd_args) != 1 && length(cmd_args) != 3
  error("Wrong number of arguments (should be 1 or 3)");
endif

%% Check some task is defined
if ~cmd_opts.do_dump && ...
   ~cmd_opts.do_f1 && ~cmd_opts.do_prc_rec && ~cmd_opts.do_roc
  error("No task specified");
endif

%% Set a seed
if isempty(cmd_opts.seed)
  cmd_opts.seed = floor(1000.0 * rand());
endif


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

  %% %% Expectations
  %% berni_expecs = cell(1, repeats);
  %% kmean_expecs = cell(1, repeats);
  %% svm_expecs   = cell(1, repeats);
  %% ssvm_expecs  = cell(1, repeats);
  %% ksvm_expecs  = cell(1, repeats);
  %% sksvm_expecs = cell(1, repeats);
  %% rbf_expecs   = cell(1, repeats);
  %% srbf_expecs  = cell(1, repeats);
  %% cpmmc_expecs = cell(1, repeats);
  %% smmc_expecs  = cell(1, repeats);

  %% Accumulated scores
  if cmd_opts.do_berni
    %% train_berni_scores = zeros(1, n_train);
    test_berni_scores  = zeros(1, n_test);
  endif
  if cmd_opts.do_kmean
    %% train_kmean_scores = zeros(1, n_train);
    test_kmean_scores  = zeros(1, n_test);
  endif
  if cmd_opts.do_svm  
    %% train_svm_scores   = zeros(1, n_train);
    test_svm_scores    = zeros(1, n_test);
  endif
  if cmd_opts.do_ssvm
    %% train_ssvm_scores  = zeros(1, n_train);
    test_ssvm_scores   = zeros(1, n_test);
  endif
  if cmd_opts.do_ksvm
    %% train_ksvm_scores  = zeros(1, n_train);
    test_ksvm_scores   = zeros(1, n_test);
  endif
  if cmd_opts.do_sksvm
    %% train_sksvm_scores = zeros(1, n_train);
    test_sksvm_scores  = zeros(1, n_test);
  endif
  if cmd_opts.do_rbf
    %% train_rbf_scores   = zeros(1, n_train);
    test_rbf_scores    = zeros(1, n_test);
  endif
  if cmd_opts.do_srbf
    %% train_srbf_scores  = zeros(1, n_train);
    test_srbf_scores   = zeros(1, n_test);
  endif
  if cmd_opts.do_cpmmc
    %% train_cpmmc_scores = zeros(1, n_train);
    test_cpmmc_scores  = zeros(1, n_test);
  endif
  if cmd_opts.do_smmc
    %% train_smmc_scores  = zeros(1, n_train);
    test_smmc_scores   = zeros(1, n_test);
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
      fprintf(2, "%2d:%3d: Bernoulli clustering in %d iterations (Log-like=%g)\n", ...
	      run, repeat, berni_info.iterations, berni_info.log_like);

      %% Update train scores
      berni_scores        = sum(berni_expec, 2)';
      %% train_berni_scores += berni_scores * berni_expec;

      %% Update test scores
      test_berni_expec   = bernoulli_expectation(test_data, berni_model);
      test_berni_scores += berni_scores * test_berni_expec;

      %% Log
      fprintf(2, "        - Updated scores\n");

      %% %% Save the expectation
      %% berni_expecs{r} = berni_expec;
    endif


    %%%%%%%%%%%%%
    %% k-Means %%
    %%%%%%%%%%%%%

    if cmd_opts.do_kmean

      %% Find k-Means
      kmean_opts    = struct();
      kmean_expec_0 = seed_expec();
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

      %% Log
      fprintf(2, "        - Updated scores\n");

      %% % Save the expectation
      %% kmean_expecs{r} = kmean_expec;
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
	
	%% Log
	fprintf(2, "        - Updated scores\n");

	%% %% Save the expectation
	%% svm_expecs{r} = svm_expec;
      endif
    endif


    %%%%%%%%%%%%%%
    %% Soft SVM %%
    %%%%%%%%%%%%%%

    if cmd_opts.do_ssvm

      %% Apply to train
      train_ssvm_expec   = [ exp( cmd_opts.soft_alpha * train_svm_dist) ./ ...
			    (exp( cmd_opts.soft_alpha * train_svm_dist) +  ...
			     exp(-cmd_opts.soft_alpha * train_svm_dist)) ; ...
			     exp(-cmd_opts.soft_alpha * train_svm_dist) ./ ...
			    (exp( cmd_opts.soft_alpha * train_svm_dist) +  ...
			     exp(-cmd_opts.soft_alpha * train_svm_dist)) ];
      ssvm_scores        = sum(train_ssvm_expec, 2)';
      %% train_ssvm_scores += ssvm_scores * train_ssvm_expec;

      %% Apply to test
      test_ssvm_expec   = [ exp( cmd_opts.soft_alpha * test_svm_dist) ./ ...
			   (exp( cmd_opts.soft_alpha * test_svm_dist) +  ...
			    exp(-cmd_opts.soft_alpha * test_svm_dist)) ; ...
		            exp(-cmd_opts.soft_alpha * test_svm_dist) ./ ...
			   (exp( cmd_opts.soft_alpha * test_svm_dist) +  ...
			    exp(-cmd_opts.soft_alpha * test_svm_dist)) ];
      test_ssvm_scores += ssvm_scores * test_ssvm_expec;

      %% Log
      fprintf(2, "        Softened SVM decision\n        - Updated scores\n");
    endif


    %%%%%%%%%%%%%%%%%%%
    %% Quadratic SVM %%
    %%%%%%%%%%%%%%%%%%%
    
    if cmd_opts.do_ksvm || cmd_opts.do_sksvm

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

      if cmd_opts.do_ksvm

	%% Apply to train
	train_ksvm_expec   = ...
	    sparse(sign(train_ksvm_dist) / 2 + 1.5, 1 : n_train, ...
		   ones(1, n_train), 2, n_train);
	ksvm_scores        = sum(train_ksvm_expec, 2)';
	%% train_ksvm_scores += ksvm_scores * train_ksvm_expec;

	%% Apply to test
	test_ksvm_expec   = ...
	    sparse(sign(test_ksvm_dist) / 2 + 1.5, 1 : n_test, ...
		   ones(1, n_test), 2, n_test);
	test_ksvm_scores += ksvm_scores * test_ksvm_expec;
	
	%% Log
	fprintf(2, "        - Updated scores\n");

	%% %% Save the expectation
	%% svm_expecs{r} = svm_expec;
      endif
    endif


    %%%%%%%%%%%%%%%%%%%%%%%%
    %% Soft Quadratic SVM %%
    %%%%%%%%%%%%%%%%%%%%%%%%

    if cmd_opts.do_sksvm

      %% Apply to train
      train_sksvm_expec   = [ exp( cmd_opts.soft_alpha * train_ksvm_dist) ./ ...
			     (exp( cmd_opts.soft_alpha * train_ksvm_dist) +  ...
			      exp(-cmd_opts.soft_alpha * train_ksvm_dist)) ; ...
			      exp(-cmd_opts.soft_alpha * train_ksvm_dist) ./ ...
			     (exp( cmd_opts.soft_alpha * train_ksvm_dist) +  ...
			      exp(-cmd_opts.soft_alpha * train_ksvm_dist)) ];
      sksvm_scores        = sum(train_sksvm_expec, 2)';
      %% train_sksvm_scores += sksvm_scores * train_sksvm_expec;

      %% Apply to test
      test_sksvm_expec   = [ exp( cmd_opts.soft_alpha * test_ksvm_dist) ./ ...
			    (exp( cmd_opts.soft_alpha * test_ksvm_dist) +  ...
			     exp(-cmd_opts.soft_alpha * test_ksvm_dist)) ; ...
		             exp(-cmd_opts.soft_alpha * test_ksvm_dist) ./ ...
			    (exp( cmd_opts.soft_alpha * test_ksvm_dist) +  ...
			     exp(-cmd_opts.soft_alpha * test_ksvm_dist)) ];
      test_sksvm_scores += sksvm_scores * test_sksvm_expec;

      %% Log
      fprintf(2, "        Softened Quadratic SVM decision\n");
      fprintf(2, "        - Updated scores\n");
    endif


    %%%%%%%%%%%%%
    %% RBF SVM %%
    %%%%%%%%%%%%%
    
    if cmd_opts.do_rbf || cmd_opts.do_srbf

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
	test_rbf_scores += rbf_scores * test_rbf_expec;
	
	%% Log
	fprintf(2, "        - Updated scores\n");

	%% %% Save the expectation
	%% svm_expecs{r} = svm_expec;
      endif
    endif


    %%%%%%%%%%%%%%%%%%%%%%%%
    %% Soft Quadratic SVM %%
    %%%%%%%%%%%%%%%%%%%%%%%%

    if cmd_opts.do_srbf

      %% Apply to train
      train_srbf_expec   = [ exp( cmd_opts.soft_alpha * train_rbf_dist) ./ ...
			    (exp( cmd_opts.soft_alpha * train_rbf_dist) +  ...
			     exp(-cmd_opts.soft_alpha * train_rbf_dist)) ; ...
			     exp(-cmd_opts.soft_alpha * train_rbf_dist) ./ ...
			    (exp( cmd_opts.soft_alpha * train_rbf_dist) +  ...
			     exp(-cmd_opts.soft_alpha * train_rbf_dist)) ];
      srbf_scores        = sum(train_srbf_expec, 2)';
      %% train_srbf_scores += srbf_scores * train_srbf_expec;

      %% Apply to test
      test_srbf_expec   = [ exp( cmd_opts.soft_alpha * test_rbf_dist) ./ ...
			   (exp( cmd_opts.soft_alpha * test_rbf_dist) +  ...
			    exp(-cmd_opts.soft_alpha * test_rbf_dist)) ; ...
		            exp(-cmd_opts.soft_alpha * test_rbf_dist) ./ ...
			   (exp( cmd_opts.soft_alpha * test_rbf_dist) +  ...
			    exp(-cmd_opts.soft_alpha * test_rbf_dist)) ];
      test_srbf_scores += srbf_scores * test_srbf_expec;

      %% Log
      fprintf(2, "        Softened RBF SVM decision\n");
      fprintf(2, "        - Updated scores\n");
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
	  fprintf(2, ...
		  "        CPMMC clustering in %d iterations (obj=%g, try=#%d)\n", ...
		  cpmmc_info.iterations, cpmmc_info.obj, cpmmc_tries);

          %% Apply to train
	  train_cpmmc_dist = cpmmc_model.omega' * train_data + cpmmc_model.b;
	  test_cpmmc_dist  = cpmmc_model.omega' * test_data  + cpmmc_model.b;

	  if cmd_opts.do_cpmmc

            %% Apply to train
	    train_cpmmc_dist    = ...
		cpmmc_model.omega' * train_data + cpmmc_model.b;
	    cpmmc_scores        = sum(cpmmc_expec, 2)';
	    %% train_cpmmc_scores += cpmmc_scores * cpmmc_expec;
	    
            %% Apply to test
	    test_cpmmc_expec   = ...
		sparse(sign(test_cpmmc_dist) / 2 + 1.5, 1 : n_test, ...
		       ones(1, n_test), 2, n_test);
	    test_cpmmc_scores += cpmmc_scores * test_cpmmc_expec;

            %% Log
	    fprintf(2, "        - Updated scores\n");

            %% %% Save the expectation
	    %% cpmmc_expecs{r} = cpmmc_expec;
	  endif


	  %%%%%%%%%%%%%%%%
	  %% Soft CPMMC %%
	  %%%%%%%%%%%%%%%%

	  if cmd_opts.do_smmc

	    %% Apply to train
	    train_smmc_expec   = ...
		[ exp( cmd_opts.soft_alpha * train_cpmmc_dist) ./ ...
		 (exp( cmd_opts.soft_alpha * train_cpmmc_dist) +  ...
		  exp(-cmd_opts.soft_alpha * train_cpmmc_dist)) ; ...
	          exp(-cmd_opts.soft_alpha * train_cpmmc_dist) ./ ...
		 (exp( cmd_opts.soft_alpha * train_cpmmc_dist) +  ...
		  exp(-cmd_opts.soft_alpha * train_cpmmc_dist)) ];
	    smmc_scores        = sum(train_smmc_expec, 2)';
	    %% train_smmc_scores += smmc_scores * train_smmc_expec;

	    %% Apply to test
	    test_smmc_expec   = ...
		[ exp( cmd_opts.soft_alpha * test_cpmmc_dist) ./ ...
		 (exp( cmd_opts.soft_alpha * test_cpmmc_dist) +  ...
		  exp(-cmd_opts.soft_alpha * test_cpmmc_dist)) ; ...
	          exp(-cmd_opts.soft_alpha * test_cpmmc_dist) ./ ...
		 (exp( cmd_opts.soft_alpha * test_cpmmc_dist) +  ...
		  exp(-cmd_opts.soft_alpha * test_cpmmc_dist)) ];
	    test_smmc_scores += smmc_scores * test_smmc_expec;

	    %% Log
	    fprintf(2, "        Softened CPMMC decision\n");
	    fprintf(2, "        - Updated scores\n");
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
    endif
  endfor
  

  %%%%%%%%%
  %% CUR %%
  %%%%%%%%%

  %% Find the evaluation curves
  if cmd_opts.do_berni
    berni_cur = evaluation_curves(test_berni_scores, test_truth_expec, ...
				  test_truth_sizes);
  endif
  if cmd_opts.do_kmean
    kmean_cur = evaluation_curves(test_kmean_scores, test_truth_expec, ...
				  test_truth_sizes);
  endif
  if cmd_opts.do_svm
    svm_cur = evaluation_curves(test_svm_scores,   test_truth_expec, ...
				test_truth_sizes);
  endif
  if cmd_opts.do_ssvm
    ssvm_cur = evaluation_curves(test_ssvm_scores,  test_truth_expec, ...
				 test_truth_sizes);
  endif
  if cmd_opts.do_ksvm
    ksvm_cur = evaluation_curves(test_ksvm_scores,  test_truth_expec, ...
				 test_truth_sizes);
  endif
  if cmd_opts.do_sksvm
    sksvm_cur = evaluation_curves(test_sksvm_scores, test_truth_expec, ...
				  test_truth_sizes);
  endif
  if cmd_opts.do_rbf
    rbf_cur = evaluation_curves(test_rbf_scores,  test_truth_expec, ...
				test_truth_sizes);
  endif
  if cmd_opts.do_srbf
    srbf_cur = evaluation_curves(test_srbf_scores, test_truth_expec, ...
				 test_truth_sizes);
  endif
  if cmd_opts.do_cpmmc
    if cpmmc_works
      cpmmc_cur = evaluation_curves(test_cpmmc_scores, test_truth_expec, ...
				    test_truth_sizes);
    else
      cpmmc_cur = EMPTY_CURVE;
    endif
  endif
  if cmd_opts.do_smmc
    if cpmmc_works
      smmc_cur = evaluation_curves(test_smmc_scores, test_truth_expec, ...
				   test_truth_sizes);
    else
      smmc_cur = EMPTY_CURVE;
    endif
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
	
	%% Empty curve
	rfnce_cur = EMPTY_CURVE;

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
      endif

    catch
      %% Error reading
      fprintf(2, "%2d:     Could not read reference file %s", run, rfnce_file);

      %% Empty curve
      rfnce_cur = EMPTY_CURVE;
    end_try_catch
  endif


  %%%%%%%%%%
  %% Dump %%
  %%%%%%%%%%

  if cmd_opts.do_dump

    %% Header
    if run == 1
      printf("# %s %s\n", pair, feat);
    endif

    %% Print
    if cmd_opts.do_berni
      printf("# Bernoulli #%d\n", run);
      printf(DUMP_FORMAT, berni_cur); printf("\n\n");
    endif
    if cmd_opts.do_kmean
      printf("# k-Means #%d\n", run);
      printf(DUMP_FORMAT, kmean_cur); printf("\n\n");
    endif
    if cmd_opts.do_svm
      printf("# SVM #%d\n", run);
      printf(DUMP_FORMAT, svm_cur); printf("\n\n");
    endif
    if cmd_opts.do_ssvm
      printf("# Soft SVM #%d\n", run);
      printf(DUMP_FORMAT, ssvm_cur); printf("\n\n");
    endif
    if cmd_opts.do_ksvm
      printf("# Quadratic SVM #%d\n", run);
      printf(DUMP_FORMAT, ksvm_cur); printf("\n\n");
    endif
    if cmd_opts.do_sksvm
      printf("# Soft Quadratic SVM #%d\n", run);
      printf(DUMP_FORMAT, sksvm_cur); printf("\n\n");
    endif
    if cmd_opts.do_rbf
      printf("# RBF SVM #%d\n", run);
      printf(DUMP_FORMAT, rbf_cur); printf("\n\n");
    endif
    if cmd_opts.do_srbf
      printf("# Soft RBF SVM #%d\n", run)
      printf(DUMP_FORMAT, srbf_cur); printf("\n\n");
    endif
    if cmd_opts.do_cpmmc
      printf("# CPMMC #%d\n", run);
      printf(DUMP_FORMAT, cpmmc_cur); printf("\n\n");
    endif
    if cmd_opts.do_smmc
      printf("# Soft CPMMC #%d\n", run);
      printf(DUMP_FORMAT, smmc_cur); printf("\n\n");
    endif
    if cmd_opts.do_rfnce
      printf("# Reference #%d\n", run);
      printf(DUMP_FORMAT, rfnce_cur); printf("\n\n");
    endif
  endif


  %%%%%%%%%%
  %% Plot %%
  %%%%%%%%%%

  if cmd_opts.do_prc_rec || cmd_opts.do_prc_rec || cmd_opts.do_roc

    %% List of curves and labels to plot
    curves = {};
    labels = {};

    %% Add each
    if cmd_opts.do_berni
      curves = cell_push(curves, berni_cur);
      labels = cell_push(labels, "Bernoulli");
    endif
    if cmd_opts.do_kmean
      curves = cell_push(curves, kmean_cur);
      labels = cell_push(labels, "k-Means");
    endif
    if cmd_opts.do_svm
      curves = cell_push(curves, svm_cur);
      labels = cell_push(labels, "SVM");

    endif
    if cmd_opts.do_ssvm
      curves = cell_push(curves, ssvm_cur);
      labels = cell_push(labels, "Soft SVM");
    endif
    if cmd_opts.do_ksvm
      curves = cell_push(curves, ksvm_cur);
      labels = cell_push(labels, "Quadratic SVM");
    endif
    if cmd_opts.do_sksvm
      curves = cell_push(curves, sksvm_cur);
      labels = cell_push(labels, "Soft Quadratic SVM");
    endif
    if cmd_opts.do_rbf
      curves = cell_push(curves, rbf_cur);
      labels = cell_push(labels, "RBF SVM");
    endif
    if cmd_opts.do_srbf
      curves = cell_push(curves, srbf_cur);
      labels = cell_push(labels, "Soft RBF SVM");
    endif
    if cmd_opts.do_cpmmc
      curves = cell_push(curves, cpmmc_cur);
      labels = cell_push(labels, "CPMMC");
    endif
    if cmd_opts.do_smmc
      curves = cell_push(curves, smmc_cur);
      labels = cell_push(labels, "Soft CPMMC");
    endif
    if cmd_opts.do_rfnce
      curves = cell_push(curves, rfnce_cur);
      labels = cell_push(labels, "Reference");
    endif

    %% Plot each
    title = sprintf("Run %d", run);
    if cmd_opts.do_f1
      plot_curves(title, SAMPLES(), "samples", F1(), "f1", ...
		  curves, labels, "northeast");
    endif
    if cmd_opts.do_prc_rec
      plot_curves(title, RECALL(), "recall", PRECISION(), "precision", ...
		  curves, labels, "northeast");
    endif
    if cmd_opts.do_roc
      plot_curves(title, NEGATIVES(), "negatives", RECALL(), "positives", ...
		  curves, labels, "southeast");
    endif

    %% Pause on the last run
    if run == cmd_opts.runs
      pause();
    endif
  endif
endfor
