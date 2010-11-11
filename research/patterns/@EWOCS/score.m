%% -*- mode: octave; -*-

%% Ensemble Weak One-Class Scoring
%% Scoring function

%% Author: Edgar Gonzalez

function [ scores, model, info, expec ] = score(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ scores, model, info, expec ] = @EWOCS/score(this, data)");
  endif

  %% Size
  [ n_dims, n_samples ] = size(data);

  %% Effective max_clusters
  if this.max_clusters > n_samples
    eff_max_clusters = n_samples;
  else
    eff_max_clusters = this.max_clusters;
  endif

  %% Effective min_clusters
  if this.min_clusters > eff_max_clusters
    eff_min_clusters = eff_max_clusters;
  else
    eff_min_clusters = this.min_clusters;
  endif

  %% Effective range
  eff_range = eff_max_clusters - eff_min_clusters + 1;

  %% Scores
  scores = zeros(1, n_samples);

  %% Ensemble components: models and cluster scores
  ensemble_models         = cell(1, this.ensemble_size);
  ensemble_cluster_scores = cell(1, this.ensemble_size);

  %% For each element in the ensemble
  for i = 1 : this.ensemble_size

    %% Select the number of classes and seeds
    k     = floor(eff_min_clusters + eff_range * rand());
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

  %% Interpolate probabilities
  [ expec, inter_model, inter_info ] = apply(this.interpolator, scores);

  %% Create the model
  model = EWOCSModel(ensemble_models, ensemble_cluster_scores, ...
		     inter_model);

  %% Create the information
  info = struct();

  %% Extend info with inter_info
  for [ value, field ] = inter_info
    info = setfield(info, field, value);
  endfor
endfunction
