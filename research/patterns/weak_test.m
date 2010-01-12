%% Make the test

%% Default options
def_opts            = struct();
def_opts.soft_alpha = 1.0;
def_opts.repeats    = 100;
def_opts.seed       = [];
def_opts.do_berni   = true();
def_opts.do_kmean   = true();
def_opts.do_svm     = true();
def_opts.do_ssvm    = true();
def_opts.do_ksvm    = true();
def_opts.do_sksvm   = true();

try
  %% Parse options
  [ cmd_args, cmd_opts ] = ...
      get_options(def_opts,
		  "soft-alpha=f",   "soft_alpha",
		  "repeats=i",      "repeats",
		  "seed=f",         "seed",
		  "bernoulli!",     "do_berni",
		  "kmeans!",        "do_kmean",
		  "svm!",           "do_svm",
		  "soft-svm!",      "do_ssvm",
		  "quad-svm!",      "do_ksvm",
		  "soft-quad-svm!", "do_sksvm",
		  "cpmmc!",         "do_cpmmc",
		  "soft-cpmmc!",    "do_smmc")

  %% Chek number of arguments
  if length(cmd_args) != 2
    error("Missing arguments");
  end

catch
  %% Some error caught 
  usage(sprintf("%s\nweak_test.m [options] <pair> <feat>\n", lasterr()));
end

%% Get'em
pair = (cmd_args()){1};
feat = (cmd_args()){2};

%% Set a seed
if isempty(opts.seed)
  opts.seed = floor(1000.0 * rand());
end

%% Files
train = sprintf("../cldata/%s/%s/apw2000.t10.matrix.gz",           pair, feat);
test  = sprintf("../cldata/%s/%s/ace0Xall_c.t10.matrix.gz",        pair, feat);
rfnce = sprintf("../cldata/%s/%s/combi.t10/r0/apw2000.redo.nx.gz", pair, feat);
rfnce_header = ...
        sprintf("Base-Soft-Siz ../cldata/%s/%s/ace0Xall_c.t10.matrix.gz", ...
		pair, feat);

%% Prepare seed
fprintf(2, "Using %d as random seed...\n", opts.seed);
rand("seed", opts.seed);

%% Read data
train_data                = read_sparse(train);
[ test_data, test_truth ] = read_sparse(test, true());
rfnce_info = read_redo(rfnce, rfnce_header);

%% Found it?
if isempty(rfnce_info)
  error("Reference information not available");
end

%% Number of samples
[ n_train_feats, n_train ] = size(train_data);
[ n_test_feats,  n_test  ] = size(test_data);

%% Complete the test matrix
if n_test_feats < n_train_feats
  test_data = [ test_data ; sparse(n_train_feats - n_test_feats, n_test) ];
end

%% Truth expectation
test_truth_expec = ...
    sparse(test_truth / 2 + 1.5, 1 : n_test, ones(1, n_test));
test_truth_sizes = full(sum(test_truth_expec, 2));

%% %% Expectations
%% berni_expecs = cell(1, repeats);
%% kmean_expecs = cell(1, repeats);
%% svm_expecs   = cell(1, repeats);
%% cpmmc_expecs = cell(1, repeats);

%% %% Accumulated train scores
%% train_berni_scores = zeros(1, n_train);
%% train_kmean_scores = zeros(1, n_train);
%% train_svm_scores   = zeros(1, n_train);
%% train_ssvm_scores  = zeros(1, n_train);
%% train_ksvm_scores  = zeros(1, n_train);
%% train_sksvm_scores = zeros(1, n_train);
%% train_cpmmc_scores = zeros(1, n_train);
%% train_smmc_scores  = zeros(1, n_train);

%% Accumulated test scores
if opts.do_berni
  test_berni_scores  = zeros(1, n_test);
end
if opts.do_kmean
  test_kmean_scores  = zeros(1, n_test);
end
if opts.do_svm  
  test_svm_scores    = zeros(1, n_test);
end
if opts.do_ssvm
  test_ssvm_scores   = zeros(1, n_test);
end
if opts.do_ksvm
  test_ksvm_scores   = zeros(1, n_test);
end
if opts.do_sksvm
  test_sksvm_scores  = zeros(1, n_test);
end
if opts.do_cpmmc
  test_cpmmc_scores  = zeros(1, n_test);
end
if opts.do_smmc
  test_smmc_scores   = zeros(1, n_test);
end

%% CPMMC works?
cpmmc_works = true();

%% For each repetition
for r = 1 : repeats

  %%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Select the two seeds %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%

  %% Seeds
  seed1 = 1 + floor( n_train      * rand());
  seed2 = 1 + floor((n_train - 1) * rand());
  if seed2 >= seed1
    ++seed2;
  end

  %% Seed expectation
  seed_expec = sparse([ 1, 2 ], [ seed1, seed2 ], [ 1, 1 ], 2, n_train);

  %%%%%%%%%%%%%%%
  %% Bernoulli %%
  %%%%%%%%%%%%%%%

  if opts.do_berni

    %% Find the model
    berni_opts         = struct();
    berni_opts.expec_0 = seed_expec;
    [ berni_expec, berni_model, berni_info ] = ...
	bernoulli_clustering(train_data, 2, berni_opts);

    %% Log
    fprintf(2, "%d: Bernoulli clustering in %d iterations (Log-like=%g)\n", ...
	    r, berni_info.iterations, berni_info.log_like);

    %% Update train scores
    berni_scores        = sum(berni_expec, 2)';
    %% train_berni_scores += berni_scores * berni_expec;

    %% Update test scores
    test_berni_expec   = bernoulli_expectation(test_data, berni_model);
    test_berni_scores += berni_scores * test_berni_expec;

    %% Log
    fprintf(2, "    - Updated scores\n");

    %% %% Save the expectation
    %% berni_expecs{r} = berni_expec;

  end


  %%%%%%%%%%%%%
  %% k-Means %%
  %%%%%%%%%%%%%

  if opts.do_kmean

    %% Find k-Means
    kmean_opts    = struct();
    kmean_expec_0 = seed_expec();
    [ kmean_expec, kmean_model, kmean_info ] = ...
	kmeans_clustering(train_data, 2, kmean_opts);

    %% Log
    fprintf(2, "    k-Means clustering in %d iterations (Sum-sq=%g)\n", ...
	    kmean_info.iterations, kmean_info.sum_sq);

    %% Update train scores
    kmean_scores        = sum(kmean_expec, 2)';
    %% train_kmean_scores += kmean_scores * kmean_expec;
  
    %% Update test scores
    test_kmean_expec   = kmeans_expectation(test_data, kmean_model);
    test_kmean_scores += kmean_scores * test_kmean_expec;

    %% Log
    fprintf(2, "    - Updated scores\n");

    %% % Save the expectation
    %% kmean_expecs{r} = kmean_expec;

  end

  %%%%%%%%%
  %% SVM %%
  %%%%%%%%%
  
  %% Find SVM
  svm_opts          = struct();
  svm_opts.use_dual = false();
  [ svm_model, svm_info ] = ...
      simple_svm(train_data(:, [ seed1, seed2 ]), [ +1, -1 ], svm_opts);

  % Log
  fprintf(2, "    SVM fitted in %d iterations (obj=%g)\n", ...
	  svm_info.iterations, svm_info.obj);

  % Apply to train
  train_svm_dist    = svm_model.omega' * train_data + svm_model.b;
  train_svm_expec   = ...
      sparse(sign(train_svm_dist) / 2 + 1.5, 1 : n_train, ones(1, n_train), ...
	     2, n_train);
  svm_scores        = sum(train_svm_expec, 2)';
  % train_svm_scores += svm_scores * train_svm_expec;

  % Apply to test
  test_svm_dist    = svm_model.omega' * test_data + svm_model.b;
  test_svm_expec   = ...
      sparse(sign(test_svm_dist) / 2 + 1.5, 1 : n_test, ones(1, n_test), ...
	     2, n_test);
  test_svm_scores += svm_scores * test_svm_expec;
  
  % Log
  fprintf(2, "    - Updated scores\n");

  % % Save the expectation
  % svm_expecs{r} = svm_expec;


  %%%%%%%%%%%%
  % Soft SVM %
  %%%%%%%%%%%%

  % Apply to train
  train_ssvm_expec   = [ exp( soft_alpha * train_svm_dist) ./ ...
			(exp( soft_alpha * train_svm_dist) +  ...
			 exp(-soft_alpha * train_svm_dist)) ; ...
			 exp(-soft_alpha * train_svm_dist) ./ ...
			(exp( soft_alpha * train_svm_dist) +  ...
			 exp(-soft_alpha * train_svm_dist)) ];
  ssvm_scores        = sum(train_ssvm_expec, 2)';
  % train_ssvm_scores += ssvm_scores * train_ssvm_expec;

  % Apply to test
  test_ssvm_expec   = [ exp( soft_alpha * test_svm_dist) ./ ...
		       (exp( soft_alpha * test_svm_dist) +  ...
			exp(-soft_alpha * test_svm_dist)) ; ...
		        exp(-soft_alpha * test_svm_dist) ./ ...
		       (exp( soft_alpha * test_svm_dist) +  ...
			exp(-soft_alpha * test_svm_dist)) ];
  test_ssvm_scores += ssvm_scores * test_ssvm_expec;

  % Log
  fprintf(2, "    Softened SVM decision\n    - Updated scores\n");


  %%%%%%%%%%%%%%%%%
  % Quadratic SVM %
  %%%%%%%%%%%%%%%%%
  
  % Find quadratic SVM
  ksvm_opts        = struct();
  ksvm_opts.kernel = @(x) (x .+ 1) .^ 2;
  [ ksvm_model, ksvm_info ] = ...
      simple_kernel_svm(train_data(:, [ seed1, seed2 ]), [ +1, -1 ], ksvm_opts);

  % Log
  fprintf(2, "    Quadratic SVM fitted in %d iterations (obj=%g)\n", ...
	  ksvm_info.iterations, ksvm_info.obj);

  % Apply to train
  train_ksvm_dist    = simple_kernel_svm_distances(train_data, ksvm_model);
  train_ksvm_expec   = ...
      sparse(sign(train_ksvm_dist) / 2 + 1.5, 1 : n_train, ones(1, n_train), ...
	     2, n_train);
  ksvm_scores        = sum(train_ksvm_expec, 2)';
  % train_ksvm_scores += ksvm_scores * train_ksvm_expec;

  % Apply to test
  test_ksvm_dist    = simple_kernel_svm_distances(test_data, ksvm_model);
  test_ksvm_expec   = ...
      sparse(sign(test_ksvm_dist) / 2 + 1.5, 1 : n_test, ones(1, n_test), ...
	     2, n_test);
  test_ksvm_scores += ksvm_scores * test_ksvm_expec;
  
  % Log
  fprintf(2, "    - Updated scores\n");

  % % Save the expectation
  % svm_expecs{r} = svm_expec;


  %%%%%%%%%%%%%%%%%%%%%%
  % Soft Quadratic SVM %
  %%%%%%%%%%%%%%%%%%%%%%

  % Apply to train
  train_sksvm_expec   = [ exp( soft_alpha * train_ksvm_dist) ./ ...
			 (exp( soft_alpha * train_ksvm_dist) +  ...
			  exp(-soft_alpha * train_ksvm_dist)) ; ...
			  exp(-soft_alpha * train_ksvm_dist) ./ ...
			 (exp( soft_alpha * train_ksvm_dist) +  ...
			  exp(-soft_alpha * train_ksvm_dist)) ];
  sksvm_scores        = sum(train_sksvm_expec, 2)';
  % train_sksvm_scores += sksvm_scores * train_sksvm_expec;

  % Apply to test
  test_sksvm_expec   = [ exp( soft_alpha * test_ksvm_dist) ./ ...
			(exp( soft_alpha * test_ksvm_dist) +  ...
			 exp(-soft_alpha * test_ksvm_dist)) ; ...
		         exp(-soft_alpha * test_ksvm_dist) ./ ...
			(exp( soft_alpha * test_ksvm_dist) +  ...
			 exp(-soft_alpha * test_ksvm_dist)) ];
  test_sksvm_scores += sksvm_scores * test_sksvm_expec;

  % Log
  fprintf(2, "    Softened Quadratic SVM decision\n    - Updated scores\n");


  %%%%%%%%%
  % CPMMC %
  %%%%%%%%%

  % Does CPMMC work?
  if cpmmc_works

    % Find CPMMC
    cpmmc_opts         = struct();
    cpmmc_opts.omega_0 = svm_model.omega;
    cpmmc_opts.b_0     = svm_model.b;

    % Try it
    cpmmc_ok    = false();
    cpmmc_tries = 0;
    while ~cpmmc_ok
      try 
	++cpmmc_tries;
	[ cpmmc_expec, cpmmc_model, cpmmc_info ] = ...
	    CPM3C_clustering(train_data, 2, cpmmc_opts);

        % Log
	fprintf(2, ...
		"    CPMMC clustering in %d iterations (obj=%g, try=#%d)\n", ...
		cpmmc_info.iterations, cpmmc_info.obj, cpmmc_tries);

        % Update train scores
	train_cpmmc_dist    = cpmmc_model.omega' * train_data + cpmmc_model.b;
	cpmmc_scores        = sum(cpmmc_expec, 2)';
	% train_cpmmc_scores += cpmmc_scores * cpmmc_expec;
	  
        % Update test scores
	test_cpmmc_dist    = cpmmc_model.omega' * test_data + cpmmc_model.b;
	test_cpmmc_expec   = ...
	    sparse(sign(test_cpmmc_dist) / 2 + 1.5, 1 : n_test, ...
		   ones(1, n_test), 2, n_test);
	test_cpmmc_scores += cpmmc_scores * test_cpmmc_expec;

        % Log
	fprintf(2, "    - Updated scores\n");

        % % Save the expectation
	% cpmmc_expecs{r} = cpmmc_expec;


	%%%%%%%%%%%%%%
	% Soft CPMMC %
	%%%%%%%%%%%%%%

	% Apply to train
	train_smmc_expec   = [ exp( soft_alpha * train_cpmmc_dist) ./ ...
			      (exp( soft_alpha * train_cpmmc_dist) +  ...
			       exp(-soft_alpha * train_cpmmc_dist)) ; ...
			      exp(-soft_alpha * train_cpmmc_dist) ./ ...
			      (exp( soft_alpha * train_cpmmc_dist) +  ...
			       exp(-soft_alpha * train_cpmmc_dist)) ];
	smmc_scores        = sum(train_smmc_expec, 2)';
	% train_smmc_scores += smmc_scores * train_smmc_expec;

	% Apply to test
	test_smmc_expec   = [ exp( soft_alpha * test_cpmmc_dist) ./ ...
			     (exp( soft_alpha * test_cpmmc_dist) +  ...
			      exp(-soft_alpha * test_cpmmc_dist)) ; ...
		             exp(-soft_alpha * test_cpmmc_dist) ./ ...
			     (exp( soft_alpha * test_cpmmc_dist) +  ...
			      exp(-soft_alpha * test_cpmmc_dist)) ];
	test_smmc_scores += smmc_scores * test_smmc_expec;

	% Log
	fprintf(2, "    Softened CPMMC decision\n    - Updated scores\n");

	% It worked!
	cpmmc_ok = true();

      catch
	% Fail
	fprintf(2, "    CPMMC clustering failed '%s' (try=#%d)\n", ...
		lasterr(), cpmmc_tries);

	% Too many?
	if cpmmc_tries == 10
	  fprintf(2, ...
		  "    Unable to make CPMMC work after 10 tries, skipping\n");
	  cpmmc_works = false();
	  cpmmc_ok    = true();
	end
      end
    end
  end
end
  
if cpmmc_works
  cpmmc_roc = ROC(test_cpmmc_scores, test_truth_expec, test_truth_sizes);
  smmc_roc  = ROC(test_smmc_scores,  test_truth_expec, test_truth_sizes);
else
  cpmmc_roc = smmc_roc = [ 0 ; 0 ];
end

% Reference roc

% Header
printf("# %s %s\n", pair, feat);

% Find ROCs and Print
if opts.do_berni
  berni_roc = ROC(test_berni_scores, test_truth_expec, test_truth_sizes);
  printf("# Bernoulli\n"); printf("%f %f\n", berni_roc); printf("\n\n");
end

% k-Means
if opts.do_kmean
  kmean_roc = ROC(test_kmean_scores, test_truth_expec, test_truth_sizes);
  printf("# K-Means\n"); printf("%f %f\n", kmean_roc); printf("\n\n");
end

% SVM
if opts.do_svm
  svm_roc = ROC(test_svm_scores,   test_truth_expec, test_truth_sizes);
  printf("# SVM\n"); printf("%f %f\n", svm_roc); printf("\n\n");
end

% Soft SVM
if opts.do_ssvm
  ssvm_roc = ROC(test_ssvm_scores,  test_truth_expec, test_truth_sizes);
  printf("# S-SVM\n"); printf("%f %f\n", ssvm_roc); printf("\n\n");
end

% Quadratic SVM
if opts.do_ksvm
  ksvm_roc = ROC(test_ksvm_scores,  test_truth_expec, test_truth_sizes);
  printf("# K-SVM\n"); printf("%f %f\n", ksvm_roc); printf("\n\n");
end

% Soft Quadratic SVM
if opts.do_sksvm
  sksvm_roc = ROC(test_sksvm_scores, test_truth_expec, test_truth_sizes);
  printf("# S-K-SVM \n"); printf("%f %f\n", sksvm_roc); printf("\n\n");
end

% CPMMC
if opts.do_cpmmc
  if cpmmc_works
    cpmmc_roc = ROC(test_cpmmc_scores, test_truth_expec, test_truth_sizes);
  else
    cpmmc_roc = [ 0 ; 0 ];
  end
  printf("# CPMMC\n"); printf("%f %f\n", cpmmc_roc); printf("\n\n");
end

% Soft CPMMC
if opts.do_smmc
  if cpmmc_works
    smmc_roc = ROC(test_smmc_scores, test_truth_expec, test_truth_sizes);
  else
    smmc_roc = [ 0 ; 0 ];
  end
  printf("# S-CPMMC\n"); printf("%f %f\n", smmc_roc); printf("\n\n");
end

% Reference
rfnce_roc        = rfnce_info(:, [ 5, 4 ])';
rfnce_roc_length = size(rfnce_roc, 2);
rfnce_roc      ./= rfnce_roc(:, rfnce_roc_length) * ones(1, rfnce_roc_length);
printf("# Reference\n"); printf("%f %f\n", rfnce_roc); printf("\n\n");

% % Plot
% plot(berni_roc(1,:), berni_roc(2,:), 'g-;Bernoulli;', ...
%      kmean_roc(1,:), kmean_roc(2,:), 'y-;k-Means;', ...
%      svm_roc  (1,:), svm_roc  (2,:), 'b-;SVM;', ... 
%      ssvm_roc (1,:), ssvm_roc (2,:), 'c-;Soft SVM;', ...
%      cpmmc_roc(1,:), cpmmc_roc(2,:), 'r-;CPMMC;', ...
%      smmc_roc (1,:), smmc_roc (2,:), 'm-;Soft CPMMC;', ...
%      rfnce_roc(1,:), rfnce_roc(2,:), 'k-;Reference;', ...
%      [ 0, 1 ],       [ 0, 1 ],       'k-;Random;');
% pause();

% Local Variables:
% mode:octave
% End:
