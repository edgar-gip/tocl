%% -*- mode: octave; -*-

%% Learning curve

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus

%% Errors
warning error Octave:divide-by-zero


%%%%%%%%%%%
% Helpers %
%%%%%%%%%%%

%% Set hard alpha
function [ opts ] = set_hard_alpha(opts, value)
  opts.soft_alpha = inf;
endfunction

%% Dump output format(constant)
IN_DUMP_HEADER = "# Repeat Samples Negatives Recall Precision F1 Score";
IN_DUMP_FORMAT = "%d %f %f %f %f %f %f\n";

%% Full dump output format(constant)
IN_FULL_DUMP_HEADER = ...
    cstrcat("# Repeat Samples Negatives Recall Precision F1 Score ", ...
            " NScoMean NScoMeanA NScoMeanB NScoMeanT  NScoMW NScoMWZ ", ...
            " NScoSq NScoRho NScoRhoT NScoRhoZ ", ...
            " NRankSq NRankRho NRankRhoT NRankRhoZ");
IN_FULL_DUMP_FORMAT = ...
    cstrcat("%d %f %f %f %f %f %f ", ...
            " %f %f %f %f %f %f ", ...
            " %f %f %f %f ",
            " %f %f %f %f\n");

%% Dump output format(constant)
DUMP_HEADER = "# Samples Negatives Recall Precision F1 Score";
DUMP_FORMAT = "%d %f %f %f %f %f\n";

%% Field information
enum SAMPLES=1 NEGATIVES RECALL PRECISION F1 SCORES;


%%%%%%%%%%%%%
%% Startup %%
%%%%%%%%%%%%%

%% Default options
def_opts            = struct();
def_opts.soft_alpha = 1.0;
def_opts.rbf_gamma  = 1.0;
def_opts.runs       = 1;
def_opts.repeats    = 100;
def_opts.seed       = [];
def_opts.max_tries  = 10;
def_opts.threshold  = 10;
def_opts.train      = "apw2000";
def_opts.test       = "ace0Xall_c";
def_opts.show_final = false();
def_opts.n_best     = 1;
def_opts.stat_tests = false();

%% Parse options
[ cmd_args, cmd_opts ] = ...
    get_options(def_opts, ...
                "soft-alpha=f",      "soft_alpha",    ...
                "hard-alpha",        @set_hard_alpha, ...
                "rbf-gamma=f",       "rbf_gamma",     ...
                "runs=i",            "runs",          ...
                "repeats=i",         "repeats",       ...
                "seed=f",            "seed",          ...
                "max-tries=i",       "max_tries",     ...
                "threshold=i",       "threshold",     ...
                "train=s",           "train",         ...
                "test=s",            "test",          ...
                "show-final!",       "show_final",    ...
                "n-best=i",          "n_best",        ...
                "stat-tests!",       "stat_tests");

%% Chek number of arguments
if length(cmd_args) ~= 1 && length(cmd_args) ~= 3
  error("Wrong number of arguments (should be 1 or 3)");
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
set_all_seeds(cmd_opts.seed);

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

  %% Scores
  %% train_scores = zeros(1, n_train);
  test_scores  = zeros(1, n_test);

  %% Previous scores
  %% prev_train_scores = [];
  prev_test_scores  = [];

  %% Header
  if run == 1
    printf("# Pair: %s Feature: %s\n", pair, feat);
  endif

  %% Run
  printf("# Run: #%d\n", run);
  if cmd_opts.stat_tests
    printf("%s\n", IN_FULL_DUMP_HEADER);
  else
    printf("%s\n", IN_DUMP_HEADER);
  endif


  %%%%%%%%%%%%%%%%%
  %% Repeat Loop %%
  %%%%%%%%%%%%%%%%%

  %% For each repetition
  for repeat = 1 : cmd_opts.repeats

    %% Try it
    rbf_end   = false();
    rbf_tries = 0;
    while ~rbf_end
      try
        %% One more try
        ++rbf_tries;

        %%%%%%%%%%%
        %% Seeds %%
        %%%%%%%%%%%

        %% Select the two seeds
        seed1 = 1 + floor( n_train      * rand());
        seed2 = 1 + floor((n_train - 1) * rand());
        if seed2 >= seed1
          ++seed2;
        endif


        %%%%%%%%%%%%%
        %% RBF SVM %%
        %%%%%%%%%%%%%

        %% Find RBF SVM
        rbf_opts        = struct();
        rbf_opts.radial = true();
        rbf_opts.kernel = @(x) exp(-cmd_opts.rbf_gamma * x);
        [ rbf_model, rbf_info ] = ...
            twopoint_kernel_svm(train_data(:, [ seed1, seed2 ]), rbf_opts);

        %% Log
        fprintf(2, cstrcat("%2d:%3d: RBF SVM fitted in %d iterations for", ...
                           " gamma=%g (obj=%g)\n"), ...
                run, repeat, rbf_info.iterations, ...
                cmd_opts.rbf_gamma, rbf_info.obj);

        %% It worked!
        rbf_end = true();

      catch
        %% Fail
        fprintf(2, "        RBF SVM failed '%s' (try=#%d)\n", ...
                lasterr(), rbf_tries);

        %% Too many?
        if rbf_tries == cmd_opts.max_tries
          fprintf(2, ...
                  "        Unable to make RBF SVM work after %d tries", ...
                  cmd_opts.max_tries);
          rethrow(lasterror());
        endif
      end_try_catch
    endwhile

    %% Apply to train
    train_rbf_dist = simple_kernel_svm_distances(train_data, rbf_model);

    %% Apply to test
    test_rbf_dist  = simple_kernel_svm_distances(test_data, rbf_model);

    %% Clear
    %% clear rbf_opts rbf_model rbf_info

    %% Alpha?
    if isfinite(cmd_opts.soft_alpha)
      %% Finite -> Soft version
      train_srbf_expec = ...
          [ exp( cmd_opts.soft_alpha * train_rbf_dist) ./ ...
           (exp( cmd_opts.soft_alpha * train_rbf_dist) +  ...
            exp(-cmd_opts.soft_alpha * train_rbf_dist)) ; ...
            exp(-cmd_opts.soft_alpha * train_rbf_dist) ./ ...
           (exp( cmd_opts.soft_alpha * train_rbf_dist) +  ...
            exp(-cmd_opts.soft_alpha * train_rbf_dist)) ];

      %% Apply to test
      test_srbf_expec = ...
          [ exp( cmd_opts.soft_alpha * test_rbf_dist) ./ ...
           (exp( cmd_opts.soft_alpha * test_rbf_dist) +  ...
            exp(-cmd_opts.soft_alpha * test_rbf_dist)) ; ...
            exp(-cmd_opts.soft_alpha * test_rbf_dist) ./ ...
           (exp( cmd_opts.soft_alpha * test_rbf_dist) +  ...
            exp(-cmd_opts.soft_alpha * test_rbf_dist)) ];

      %% Log
      fprintf(2, "        Softened RBF SVM decision for alpha=%.3f\n", ...
              cmd_opts.soft_alpha);
    else
      %% Inifinite -> Hard version

      %% Apply to train
      train_srbf_expec = ...
          sparse(sign(train_rbf_dist) / 2 + 1.5, 1 : n_train, ...
                 ones(1, n_train), 2, n_train);

      %% Apply to test
      test_srbf_expec  = ...
          sparse(sign(test_rbf_dist) / 2 + 1.5, 1 : n_test, ...
                 ones(1, n_test), 2, n_test);
    endif

    %% Score
    srbf_scores = sum(train_srbf_expec, 2)';

    %% Add
    %% train_scores += srbf_scores * train_srbf_expec;
    test_scores  += srbf_scores * test_srbf_expec;

    %% Clear
    %% clear train_rbf_expec rbf_scores test_rbf_expec
    %% clear train_rbf_dist test_rbf_dist


    %%%%%%%%%%%%%%%%
    %% Evaluation %%
    %%%%%%%%%%%%%%%%

    %% Evaluation curve
    cur = binary_evaluation_curves(test_scores, test_truth_expec, ...
                                   test_truth_sizes);

    %% Find the maximum F1 points
    [ sorted_f1, sorted_i ] = sort(cur(F1, :), 'descend');

    %% Average
    avg_cur = mean(cur(:, [ sorted_i(1:cmd_opts.n_best) ]), 2);

    %% Perform statistical tests?
    if cmd_opts.stat_tests
      %% Compare the scores of the two groups
      sco_comp = score_comparison(test_scores, test_truth_expec, ...
                                  test_truth_sizes);

      %% Compare scores to previous (and update)
      sco_evol = score_evolution(prev_test_scores, test_scores);
      prev_test_scores = test_scores;

      %% Display it
      printf(IN_FULL_DUMP_FORMAT, repeat, avg_cur, sco_comp, sco_evol);

    else
      %% Display it
      printf(IN_DUMP_FORMAT, repeat, avg_cur);
    endif
  endfor

  %% Newline
  printf("\n\n");


  %%%%%%%%%%%%%%%%%%%%%%
  %% Final evaluation %%
  %%%%%%%%%%%%%%%%%%%%%%

  if cmd_opts.show_final
    %% Header
    if isfinite(cmd_opts.soft_alpha)
      printf("# Soft RBF SVM %.3f %.3f #%d\n", ...
             cmd_opts.rbf_gamma, cmd_opts.soft_alpha, run)
    else
      printf("# RBF SVM %.3f #%d\n", cmd_opts.rbf_gamma, run);
    endif

    %% Curve
    printf("%s\n", DUMP_HEADER);
    printf(DUMP_FORMAT, ...
           binary_evaluation_curves(test_scores, test_truth_expec, ...
                                    test_truth_sizes));
    printf("\n\n");
  endif
endfor
