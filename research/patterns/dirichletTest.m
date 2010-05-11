%% -*- mode: octave; -*-

%% Dirichlet-based clustering test

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus


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


%%%%%%%%%%%%%%%%
%% Clustering %%
%%%%%%%%%%%%%%%%

%% Perform the clustering
function do_clustering(label, scores, data, k, blocks, ...
		       truth_expec, truth_sizes, ...
		       bin_truth_expec, bin_truth_sizes)
  %% Find the evaluation curves
  curves = binary_evaluation_curves(scores, bin_truth_expec, bin_truth_sizes);

  %% Find the optimal F1 point
  [ max_f1, max_idx  ]           = max(curves(5, :));
  max_prc  = curves(3, max_idx);
  max_rec  = curves(4, max_idx);
  th_score = curves(6, max_idx);

  %% Take only those samples above the score
  pos_idx = find(scores > th_score);
  n_pos   = length(pos_idx);

  %% Cluster
  blocks
  [ dirich_exp, dirich_model, dirich_info ] = ...
      dirichlet_clustering(data(:, pos_idx), k, blocks);

  %% Log
  fprintf(2, "        Dirichlet model fitted in %d iterations (Log-like=%g)\n", ...
	  dirich_info.iterations, dirich_info.log_like);

  %% Harden the decision
  [ max_expec, max_expec_idx ] = max(dirich_exp);
  hard_dirich_exp = sparse(max_expec_idx, 1 : n_pos, ones(1, n_pos), k, n_pos);

  %% Evaluate this clustering
  [ pur_v1, ipur_v1, f1_v1 ] = ...
      classification_evaluation(hard_dirich_exp, truth_expec(:, pos_idx));

  %% Take those samples really positive
  pos_idx = find(bin_truth_expec(2, :));
  n_pos   = length(pos_idx);

  %% Cluster
  pos_idx
  full(data(:, pos_idx))
  k
  blocks
  [ dirich_exp, dirich_model, dirich_info ] = ...
      dirichlet_clustering(data(:, pos_idx), k, blocks);

  %% Log
  fprintf(2, "        Dirichlet model fitted in %d iterations (Log-like=%g)\n", ...
	  dirich_info.iterations, dirich_info.log_like);

  %% Harden the decision
  [ max_expec, max_expec_idx ] = max(dirich_exp);
  hard_dirich_exp = sparse(max_expec_idx, 1 : n_pos, ones(1, n_pos), k, n_pos);

  %% Evaluate this other clustering
  [ pur_v2, ipur_v2, f1_v2 ] = ...
      classification_evaluation(hard_dirich_exp, truth_expec(:, pos_idx));

  %% Display it
  printf("%s  %d %g %g %g %g  %g %g %g  %g %g %g\n", ...
	 label, max_idx, th_score, max_rec, max_prc, max_f1, ...
	 pur_v1, ipur_v1, f1_v1, pur_v2, ipur_v2, f1_v2); 
endfunction


%%%%%%%%%%%%%
%% Startup %%
%%%%%%%%%%%%%

%% Default options
def_opts            = struct();
def_opts.noise      = 1000;
def_opts.clusters   = 10;
def_opts.cl_samples = 100;
def_opts.dimensions = 10;
def_opts.range      = 5.0;
def_opts.var_df     = 3;
def_opts.soft_alpha = [ 0.1, 0.2, 0.5, 1.0, 2.0, 5.0, 10.0 ];
def_opts.rbf_gamma  = [ 0.1, 0.2, 0.5, 1.0, 2.0, 5.0, 10.0 ];
def_opts.runs       = 1;
def_opts.repeats    = 100;
def_opts.seed       = [];
def_opts.max_tries  = 10;
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
		"noise=i",           "noise",         ...
		"clusters=i",        "clusters",      ...
		"cl-samples=i",      "cl_samples",    ...
		"dimensions=i",      "dimensions",    ...
		"range=f",           "range",         ...
		"var-df=i",          "var_df",        ...
		"runs=i",            "runs",          ...
		"repeats=i",         "repeats",       ...
		"seed=f",            "seed",          ...
		"max-tries=i",       "max_tries",     ...
		"threshold=i",       "threshold",     ...
		"train=s",           "train",         ...
		"test=s",            "test",          ...
		"reference-header=s","rfnce_head",    ...
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

%% Number of data
n_data = cmd_opts.noise + cmd_opts.clusters * cmd_opts.cl_samples;

%% Generate the data
data  = zeros(cmd_opts.dimensions, n_data);
truth = zeros(1,                   n_data);

%% Noise cluster
data(:, 1 : cmd_opts.noise) = ...
    cmd_opts.range * (2 * rand(cmd_opts.dimensions, cmd_opts.noise) - 1);
truth(1, 1 : cmd_opts.noise) = ... 
    ones(1, cmd_opts.noise);

%% Gaussian clusters
base = cmd_opts.noise + 1;
for cl = 1 : cmd_opts.clusters
  %% Generate the mean and the variance
  mean = cmd_opts.range * (2 * rand(cmd_opts.dimensions, 1) - 1);
  var  = chi2rnd(cmd_opts.var_df);

  %% Data and truth
  data(:, base : base + cmd_opts.cl_samples - 1) = ...
      normrnd(mean * ones(1, cmd_opts.cl_samples), var);
  truth(1, base : base + cmd_opts.cl_samples - 1) = ...
      (cl + 1) * ones(1, cmd_opts.cl_samples);

  %% Update the base
  base += cmd_opts.cl_samples;
endfor

%% Read test data
fprintf(2, "        Generated data\n");

%% Truth expectation
truth_expec = sparse(truth, 1 : n_data, ones(1, n_data));
truth_sizes = full(sum(truth_expec, 2));

%% Binary truth expectation
bin_truth_expec = ...
    [ truth_expec(1, :) ;
      sum(truth_expec(2 : 1 + cmd_opts.clusters, :), 1) ];
bin_truth_sizes = full(sum(bin_truth_expec, 2));

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

  %% k-Means
  if cmd_opts.do_kmean
    data_kmean_scores = zeros(1, n_data);
    data_kmean_class  = zeros(0, n_data);
  endif

  %% SVM
  if cmd_opts.do_svm  
    data_svm_scores = zeros(1, n_data);
    data_svm_class  = zeros(0, n_data);
  endif

  %% Soft SVM
  if cmd_opts.do_ssvm
    data_ssvm_scores = cell(1, n_alpha);
    data_ssvm_class  = cell(1, n_alpha);
    for i = 1 : n_alpha
      data_ssvm_scores{i} = zeros(1, n_data);
      data_ssvm_class {i} = zeros(0, n_data);
    endfor
  endif

  %% Quadratic SVM
  if cmd_opts.do_qsvm
    data_qsvm_scores = zeros(1, n_data);
    data_qsvm_class  = zeros(0, n_data);
  endif

  %% Soft Quadratic SVM
  if cmd_opts.do_sqsvm
    data_sqsvm_scores = cell(1, n_alpha);
    data_sqsvm_class  = cell(1, n_alpha);
    for i = 1 : n_alpha
      data_sqsvm_scores{i} = zeros(1, n_data);
      data_sqsvm_class {i} = zeros(0, n_data);
    endfor
  endif

  %% RBF SVM
  if cmd_opts.do_rbf
    data_rbf_scores = cell(n_gamma, 1);
    data_rbf_class  = cell(n_gamma, 1);
    for j = 1 : n_gamma
      data_rbf_scores{j} = zeros(1, n_data);
      data_rbf_class {j} = zeros(0, n_data);
    endfor
  endif

  %% Soft RBF SVM
  if cmd_opts.do_srbf
    data_srbf_scores = cell(n_gamma, n_alpha);
    data_srbf_class  = cell(n_gamma, n_alpha);
    for j = 1 : n_gamma
      for i = 1 : n_alpha
	data_srbf_scores{j, i} = zeros(1, n_data);
	data_srbf_class {j, i} = zeros(0, n_data);
      endfor
    endfor
  endif

  %% CPMMC
  if cmd_opts.do_cpmmc
    data_cpmmc_scores = zeros(1, n_data);
    data_cpmmc_class  = zeros(0, n_data);
  endif

  %% Soft CPMMC
  if cmd_opts.do_smmc
    data_smmc_scores = cell(1, n_alpha);
    for i = 1 : n_alpha
      data_smmc_scores{i} = zeros(1, n_data);
      data_smmc_class {i} = zeros(0, n_data);
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
    seed1 = 1 + floor( n_data      * rand());
    seed2 = 1 + floor((n_data - 1) * rand());
    if seed2 >= seed1
      ++seed2;
    endif

    %% Seed expectation
    seed_expec = sparse([ 1, 2 ], [ seed1, seed2 ], [ 1, 1 ], 2, n_data);


    %%%%%%%%%%%%%
    %% k-Means %%
    %%%%%%%%%%%%%

    if cmd_opts.do_kmean

      %% Find k-Means
      kmean_opts         = struct();
      kmean_opts.expec_0 = seed_expec;
      [ kmean_expec, kmean_model, kmean_info ] = ...
	  kmeans_clustering(data, 2, kmean_opts);

      %% Log
      fprintf(2, "%2d:%3d: k-Means clustering in %d iterations (Sum-sq=%g)\n", ...
	      run, repeat, kmean_info.iterations, kmean_info.sum_sq);

      %% Update scores
      kmean_scores       = sum(kmean_expec, 2)';
      data_kmean_scores += kmean_scores * kmean_expec;
      data_kmean_class   = [ data_kmean_class ; kmean_expec ];

      %% Clear
      clear kmean_opts kmean_expec kmean_model kmean_info kmean_scores
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
	  twopoint_svm(data(:, [ seed1, seed2 ]), svm_opts);

      %% Log
      fprintf(2, "        SVM fitted in %d iterations (obj=%g)\n", ...
	      svm_info.iterations, svm_info.obj);

      %% Apply to data
      svm_dist = svm_model.omega' * data + svm_model.b;

      %% Clear
      clear svm_opts svm_info

      if cmd_opts.do_svm

	%% Apply to data
	svm_expec = ...
	    sparse(sign(svm_dist) / 2 + 1.5, 1 : n_data, ...
		   ones(1, n_data), 2, n_data);
	svm_scores       = sum(svm_expec, 2)';
	data_svm_scores += svm_scores * svm_expec;
	data_svm_class   = [ data_svm_class ; svm_expec ];

	%% Clear
	clear svm_expec svm_scores
      endif


      %%%%%%%%%%%%%%
      %% Soft SVM %%
      %%%%%%%%%%%%%%

      if cmd_opts.do_ssvm

	for i = 1 : n_alpha

	  %% Apply to data
	  ssvm_expec = ...
	      distance_probability(cmd_opts.soft_alpha(i), svm_dist)
	  ssvm_scores          = sum(ssvm_expec, 2)';
	  data_ssvm_scores{i} += ssvm_scores * ssvm_expec;
	  data_ssvm_class {i}  = [ data_ssvm_class{i} ; ssvm_expec ];
	  
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
	clear ssvm_expec ssvm_scores
      endif

      %% Clear
      clear svm_dist
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
	  twopoint_kernel_svm(data(:, [ seed1, seed2 ]), qsvm_opts);

      %% Log
      fprintf(2, "        Quadratic SVM fitted in %d iterations (obj=%g)\n", ...
	      qsvm_info.iterations, qsvm_info.obj);

      %% Apply to data
      qsvm_dist = ...
	  simple_kernel_svm_distances(data, qsvm_model);

      %% Clear
      clear qsvm_opts qsvm_model qsvm_info

      if cmd_opts.do_qsvm

	%% Apply to data
	qsvm_expec   = ...
	    sparse(sign(qsvm_dist) / 2 + 1.5, 1 : n_data, ...
		   ones(1, n_data), 2, n_data);
	qsvm_scores       = sum(qsvm_expec, 2)';
	data_qsvm_scores += qsvm_scores * qsvm_expec;
	data_qsvm_class   = [ data_qsvm_class ; qsvm_expec ];

	%% Clear
	clear qsvm_expec qsvm_scores
      endif


      %%%%%%%%%%%%%%%%%%%%%%%%
      %% Soft Quadratic SVM %%
      %%%%%%%%%%%%%%%%%%%%%%%%

      if cmd_opts.do_sqsvm

	for i = 1 : n_alpha

	  %% Apply to data
	  sqsvm_expec = ...
	      distance_probability(cmd_opts.soft_alpha(i), qsvm_dist);
	  sqsvm_scores          = sum(sqsvm_expec, 2)';
	  data_sqsvm_scores{i} += sqsvm_scores * sqsvm_expec;
	  data_sqsvm_class {i}  = [ data_sqsvm_class{i} ; sqsvm_expec ];
	  
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
	clear sqsvm_expec sqsvm_scores
      endif

      %% Clear
      clear qsvm_dist
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
	    twopoint_kernel_svm(data(:, [ seed1, seed2 ]), rbf_opts);

	%% Log
	fprintf(2, "        RBF SVM fitted in %d iterations for gamma=%g (obj=%g)\n", ...
		rbf_info.iterations, cmd_opts.rbf_gamma(j), rbf_info.obj);

	%% Apply to data
	rbf_dist = simple_kernel_svm_distances(data, rbf_model);

	%% Clear
	clear rbf_opts rbf_model rbf_info

	if cmd_opts.do_rbf

	  %% Apply to data
	  rbf_expec   = ...
	      sparse(sign(rbf_dist) / 2 + 1.5, 1 : n_data, ...
		     ones(1, n_data), 2, n_data);
	  rbf_scores          = sum(rbf_expec, 2)';
	  data_rbf_scores{j} += rbf_scores * rbf_expec;
	  data_rbf_class {j}  = [ data_rbf_class{j} ; rbf_expec ];

	  %% Clear
	  clear rbf_expec rbf_scores
	endif

	
	%%%%%%%%%%%%%%%%%%
	%% Soft RBF SVM %%
	%%%%%%%%%%%%%%%%%%

	if cmd_opts.do_srbf

	  for i = 1 : n_alpha

	    %% Apply to data
	    srbf_expec = ...
		distance_probability(cmd_opts.soft_alpha(i), rbf_dist);
	    srbf_scores            = sum(srbf_expec, 2)';
	    data_srbf_scores{j,i} += srbf_scores * srbf_expec;
	    data_srbf_class {j,i}  = [ data_srbf_class{j,i} ; srbf_expec ];

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
	  clear srbf_expec srbf_scores
	endif

	%% Clear
	clear rbf_dist
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
	      CPM3C_clustering(data, 2, cpmmc_opts);

          %% Log
	  fprintf(2, "        CPMMC clustering in %d iterations (obj=%g, try=#%d)\n", ...
		  cpmmc_info.iterations, cpmmc_info.obj, cpmmc_tries);

          %% Apply to data
	  cpmmc_dist = cpmmc_model.omega' * data + cpmmc_model.b;

	  %% Clear
	  clear cpmmc_model cpmmc_info

	  if cmd_opts.do_cpmmc

            %% Apply to data
	    cpmmc_scores       = sum(cpmmc_expec, 2)';
	    data_cpmmc_scores += cpmmc_scores * cpmmc_expec;
	    data_cpmmc_class   = [ data_cpmmc_class ; cpmmc_expec ];

	    %% Clear
	    clear cpmmc_scores
	  endif

	  %% Clear
	  clear cpmmc_expec


	  %%%%%%%%%%%%%%%%
	  %% Soft CPMMC %%
	  %%%%%%%%%%%%%%%%

	  if cmd_opts.do_smmc

	    for i = 1 : n_alpha

	      %% Apply to data
	      smmc_expec = ...
		  distance_probability(cmd_opts.soft_alpha(i), cpmmc_dist);
	      smmc_scores          = sum(smmc_expec, 2)';
	      data_smmc_scores{i} += smmc_scores * smmc_expec;
	      data_smmc_class {i}  = [ data_smmc_class{i} ; smmc_expec ];

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
	    clear smmc_expec smmc_scores
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
  %% Clustering %%
  %%%%%%%%%%%%%%%%

  %% Seeds
  printf("# Run: #%d Seeds: %d, %d\n", run, seed1, seed2);

  %% k-Means
  if cmd_opts.do_kmean
    do_clustering(sprintf("k-means 0 0 %d ", run), data_kmean_scores, ...
		  data_kmean_class, cmd_opts.clusters, ...
		  2 * ones(1, cmd_opts.repeats), ...
		  truth_expec, truth_sizes, ...
		  bin_truth_expec, bin_truth_sizes);
  endif

  %% SVM
  if cmd_opts.do_svm
    # printf("# SVM #%d\n", run);
    # printf(DUMP_FORMAT, ...
    # 	   evaluation_curves(svm_scores, truth_expec, ...
    # 			     truth_sizes));
    # printf("\n\n");
  endif

  %% Soft SVM
  if cmd_opts.do_ssvm
    for i = 1 : n_alpha
      # printf("# Soft SVM %.3f #%d\n", cmd_opts.soft_alpha(i), run);
      # printf(DUMP_FORMAT, ...
      # 	     evaluation_curves(ssvm_scores{i}, truth_expec, ...
      # 			       truth_sizes));
      # printf("\n\n");
    endfor
  endif

  %% Quadratic SVM
  if cmd_opts.do_qsvm
    # printf("# Quadratic SVM #%d\n", run);
    # printf(DUMP_FORMAT, ...
    # 	   evaluation_curves(qsvm_scores,  truth_expec, ...
    # 			     truth_sizes));
    # printf("\n\n");
  endif

  %% Soft Quadratic SVM
  if cmd_opts.do_sqsvm
    for i = 1 : n_alpha
      # printf("# Soft Quadratic SVM %.3f #%d\n", cmd_opts.soft_alpha(i), run);
      # printf(DUMP_FORMAT, ...
      # 	     evaluation_curves(sqsvm_scores{i}, truth_expec, ...
      # 			       truth_sizes));
      # printf("\n\n");
    endfor
  endif

  %% RBF SVM
  if cmd_opts.do_rbf
    for j = 1 : n_gamma
      # printf("# RBF SVM %.3f #%d\n", cmd_opts.rbf_gamma(j), run);
      # printf(DUMP_FORMAT, ...
      # 	     evaluation_curves(rbf_scores{j}, truth_expec, ...
      # 			       truth_sizes));
      # printf("\n\n");
    endfor
  endif

  %% Soft RBF SVM
  if cmd_opts.do_srbf
    for j = 1 : n_gamma
      for i = 1 : n_alpha
	do_clustering(sprintf("rbf %g %g %d ", ...
			      cmd_opts.rbf_gamma(j), ...
			      cmd_opts.soft_alpha(i), run), ...
		      data_srbf_scores{i, j}, ...
		      data_srbf_class{i, j}, cmd_opts.clusters, ...
		      2 * ones(1, cmd_opts.repeats), ...
		      truth_expec, truth_sizes, ...
		      bin_truth_expec, bin_truth_sizes);
      endfor
    endfor
  endif

  %% CPMMC
  if cmd_opts.do_cpmmc && cpmmc_works
    # printf("# CPMMC #%d\n", run);
    # printf(DUMP_FORMAT, ...
    # 	   evaluation_curves(cpmmc_scores, truth_expec, ...
    # 			     truth_sizes));
    # printf("\n\n");
  endif
  
  %% Soft CPMMC
  if cmd_opts.do_smmc && cpmmc_works
    for i = 1 : n_alpha
      # printf("# Soft CPMMC %.3f #%d\n", cmd_opts.soft_alpha(i), run);
      # printf(DUMP_FORMAT, ...
      # 	     evaluation_curves(smmc_scores{i}, truth_expec, ...
      # 			       truth_sizes));
      # printf("\n\n");
    endfor
  endif
    
  %% Clear
  clear seed_expec
endfor
