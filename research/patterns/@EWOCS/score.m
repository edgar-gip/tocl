%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Scoring function

function [ scores, model, info ] = score(this, data)

  %% Data must be given
  if nargin() ~= 2
    usage("[ scores, model, info ] = @EWOCS/score(this, data)");
  endif

  %% Size
  [ n_feats, n_samples ] = size(data);

  %% Scores
  scores = zeros(1, n_samples);

  %% Ensemble components: models and cluster scores
  ensemble_models         = cell(1, this.ensemble_size);
  ensemble_cluster_scores = cell(1, this.ensemble_size);

  %% For each element in the ensemble
  for i = 1 : this.ensemble_size

    %% Select the number of classes and seeds
    k     = floor(2 + (this.max_clusters - 1) * rand());
    seeds = sort(randperm(n_samples)(1 : k));

    %% Seed expectation
    seed_expec = sparse(1 : k, seeds, ones(1, k), k, n_samples);

    %% Log
    if this.verbose
      fprintf(2, "Selected %d seeds for element %d\n", k, i);
    endif

    %% Find the model
    [ ind_expec, ind_model, ind_info ] = ...
	cluster(this.clusterer, data, k, seed_expec);

    %% Log
    if this.verbose
      fprintf(2, "Found clustering\n");
    endif

    %% Cluster scores
    ind_cluster_scores = cluster_scores(this.score_function, data, ind_expec);

    %% Log
    if this.verbose
      fprintf(2, "Found cluster scores\n");
    endif

    %% Add scores
    scores += ind_cluster_scores * ind_expec;

    %% Store for the model
    ensemble_models        {i} = ind_model;
    ensemble_cluster_scores{i} = ind_cluster_scores;
  endfor

  %% Create the model
  model = EWOCSModel(ensemble_models, ensemble_cluster_scores, ...
		     this.interpolator);

  %% Create the information
  info = struct();
endfunction
