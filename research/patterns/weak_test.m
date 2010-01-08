% Make the test

% Check arguments:
if length(argv()) < 3 || length(argv()) > 5
  usage("test1 <train> <test> <output> <repeats> <seed>");
end

% Get'em
train  = (argv()){1};
test   = (argv()){2};
output = (argv()){3};
if length(argv()) >= 4
  repeats = floor(str2double((argv()){4}));
else
  repeats = 100;
end
if length(argv()) >= 5
  seed = str2double((argv()){5});
else
  seed = floor(1000.0 * rand());
end

% Prepare seed
fprintf(2, "Using %d as random seed...\n", seed);
rand("seed", seed);

% Read data
train_data                = read_sparse(train);
[ test_data, test_truth ] = read_sparse(test, true());

% Number of samples
n_train = size(train_data, 2);
n_test  = size(test_data,  2);

% Truth expectation
test_truth_expec = ...
    sparse(test_truth / 2 + 1.5, 1 : n_test, ones(1, n_test));
test_truth_sizes = full(sum(test_truth_expec, 2));

% Accumulated scores
train_berni_scores = zeros(1, n_train);
train_svm_scores   = zeros(1, n_train);
train_cpmmc_scores = zeros(1, n_train);
test_berni_scores  = zeros(1, n_test);
test_svm_scores    = zeros(1, n_test);
test_cpmmc_scores  = zeros(1, n_test);

% For each repetition
for r = 1 : repeats

  %%%%%%%%%%%%%%%%%%%%%%%%
  % Select the two seeds %
  %%%%%%%%%%%%%%%%%%%%%%%%

  % Seeds
  seed1 = 1 + floor( n_train      * rand());
  seed2 = 1 + floor((n_train - 1) * rand());
  if seed2 >= seed1
    ++seed2;
  end


  %%%%%%%%%%%%%
  % Bernoulli %
  %%%%%%%%%%%%%

  % Find the model
  berni_opts         = struct();
  berni_opts.expec_0 = sparse([ 1, 2 ], [ seed1, seed2 ], [ 1, 1 ], 2, n_train);
  [ berni_expec, berni_model, berni_info ] = ...
      bernoulli_clustering(train_data, 2, berni_opts);

  % Log
  fprintf(2, "%d: Bernoulli clustering in %d iterations (Log-like=%g)\n", ...
	  r, berni_info.iterations, berni_info.log_like);

  % Update train scores
  berni_scores        = sum(berni_expec, 2)';
  train_berni_scores += berni_scores * berni_expec;
  
  % Update test scores
  test_berni_expec   = bernoulli_expectation(test_data, berni_model);
  test_berni_scores += berni_scores * test_berni_expec;

  % Log
  fprintf(2, "    - Updated scores\n");


  %%%%%%%
  % SVM %
  %%%%%%%
  
  % Find SVM
  svm_opts          = struct();
  svm_opts.use_dual = false();
  [ svm_model, svm_info ] = ...
      simple_svm(train_data(:, [ seed1, seed2 ]), [ +1, -1 ], svm_opts);

  % Log
  fprintf(2, "    SVM fitted in %d iterations (obj=%g)\n", ...
	  svm_info.iterations, svm_info.obj);

  % Apply to train
  train_svm_clus    = ...
      sign(svm_model.omega' * train_data + svm_model.b) / 2 + 1.5;
  train_svm_expec   = ...
      sparse(train_svm_clus, 1 : n_train, ones(1, n_train),  2, n_train);
  svm_scores        = sum(train_svm_expec, 2)';
  train_svm_scores += svm_scores * train_svm_expec;

  % Apply to test
  test_svm_clus    = ...
      sign(svm_model.omega' * test_data + svm_model.b) / 2 + 1.5;
  test_svm_expec   = ...
      sparse(test_svm_clus, 1 : n_test, ones(1, n_test), 2, n_test);
  test_svm_scores += svm_scores * test_svm_expec;
  
  % Log
  fprintf(2, "    - Updated scores\n");


  %%%%%%%%%
  % CPMMC %
  %%%%%%%%%

  % Now, find CPMMC
  cpmmc_opts = struct();
  cpmmc_opts.omega_0 = svm_model.omega;
  cpmmc_opts.b_0     = svm_model.b;
  [ cpmmc_expec, cpmmc_model, cpmmc_info ] = ...
      CPM3C_clustering(train_data, 2, cpmmc_opts);

  % Log
  fprintf(2, "    CPMMC clustering in %d iterations (obj=%g)\n", ...
	  cpmmc_info.iterations, cpmmc_info.obj);
  
  % Update train scores
  cpmmc_scores        = sum(cpmmc_expec, 2)';
  train_cpmmc_scores += cpmmc_scores * cpmmc_expec;
  
  % Update test scores
  test_cpmmc_clus    = ...
      sign(cpmmc_model.omega' * test_data + cpmmc_model.b) / 2 + 1.5;
  test_cpmmc_expec   = ...
      sparse(test_cpmmc_clus, 1 : n_test, ones(1, n_test), 2, n_test);
  test_cpmmc_scores += cpmmc_scores * test_cpmmc_expec;

  % Log
  fprintf(2, "    - Updated scores\n");
  
end
  
% Sort test samples by Berni score
[ test_sorted_berni_scores, test_sorted_berni_indices ] = ...
    sort(test_berni_scores, 'descend');
berni_roc = diag(1 ./ test_truth_sizes) * ...
            full(cumsum(test_truth_expec(:,test_sorted_berni_indices), 2));

% Sort test samples by SVM score
[ test_sorted_svm_scores, test_sorted_svm_indices ] = ...
    sort(test_svm_scores, 'descend');
svm_roc   = diag(1 ./ test_truth_sizes) * ...
            full(cumsum(test_truth_expec(:,test_sorted_svm_indices), 2));

% Sort test samples by CPMMC score
[ test_sorted_cpmmc_scores, test_sorted_cpmmc_indices ] = ...
    sort(test_cpmmc_scores, 'descend');
cpmmc_roc = diag(1 ./ test_truth_sizes) * ...
            full(cumsum(test_truth_expec(:,test_sorted_cpmmc_indices), 2));

% Plot
plot(berni_roc(1,:), berni_roc(2,:), 'r-;Bernoulli;', ...
     svm_roc  (1,:), svm_roc  (2,:), 'g-;SVM;', ...
     cpmmc_roc(1,:), cpmmc_roc(2,:), 'b-;CPMMC;', ...
     [ 0, 1 ],       [ 0, 1 ],       'm-;Random;');
pause();

% Local Variables:
% mode:octave
% End:
