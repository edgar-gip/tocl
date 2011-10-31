%% -*- mode: octave; -*-

function [ detectable ] = find_detectable(alpha, met_aff, method = "exact")
  %% Which method?
  switch method
    case "exact"
      [ detectable ] = find_detectable_exact(alpha, met_aff);

    case "dl1"
      [ detectable ] = find_detectable_dl1(alpha, met_aff);

    case "dl2"
      [ detectable ] = find_detectable_dl2(alpha, met_aff);

    case "dl3"
      [ detectable ] = find_detectable_dl3(alpha, met_aff);

    case "dl4"
      [ detectable ] = find_detectable_dl4(alpha, met_aff);

    case "all"
      [ detectable ] = ...
	  [ find_detectable_exact(alpha, met_aff), ...
	    find_detectable_dl1(alpha, met_aff),   ...
	    find_detectable_dl2(alpha, met_aff),   ...
	    find_detectable_dl3(alpha, met_aff),   ...
	    find_detectable_dl4(alpha, met_aff) ];

    otherwise
      error(sprintf("Wrong detection method '%s'", method));
  endswitch
endfunction

function [ detectable ] = find_detectable_exact(alpha, met_aff)
  %% Expected scores
  exp_score = met_aff * alpha;

  %% Find detectable
  detectable = exp_score > exp_score(1);
  detectable = detectable(2 : length(detectable));
endfunction

function [ detectable ] = find_detectable_dl1(alpha, met_aff)
  %% Number of clusters
  n_clusters = length(alpha);

  %% Alphas
  alpha_f = alpha(2 : n_clusters);

  %% Find delta
  delta = min((diag(met_aff) - met_aff(1, :)')(2 : n_clusters));

  %% Find lambda
  diffs  = met_aff - ones(n_clusters, 1) * met_aff(1, :) + ...
           diag(inf(1, n_clusters));
  lambda = -min(min(diffs(2 : n_clusters, :)));

  %% Find detectable
  detectable = delta > ((1 - alpha_f) ./ alpha_f) * lambda;
endfunction

function [ detectable ] = find_detectable_dl2(alpha, met_aff)
  %% Number of clusters
  n_clusters = length(alpha);

  %% Alphas
  alpha_1 = alpha(1);
  alpha_f = alpha(2 : n_clusters);

  %% Find delta
  delta = min((diag(met_aff) - met_aff(1, :)')(2 : n_clusters));

  %% Find differences
  diffs = met_aff - ones(n_clusters, 1) * met_aff(1, :) + ...
          diag(inf(1, n_clusters));

  %% Find lambda's
  lambda_1 = -min(diffs(2 : n_clusters, 1));
  lambda_f = -min(min(diffs(2 : n_clusters, 2 : n_clusters)));

  %% Find detectable
  detectable = delta > (alpha_1 * lambda_1 + ...
			(1 - alpha_1 - alpha_f) * lambda_f) ./ alpha_f;
endfunction

function [ detectable ] = find_detectable_dl3(alpha, met_aff)
  %% Number of clusters
  n_clusters = length(alpha);

  %% Alphas
  alpha_f = alpha(2 : n_clusters);

  %% Find delta
  delta = min((diag(met_aff) - met_aff(1, :)')(2 : n_clusters));

  %% Find differences
  diffs   = met_aff - ones(n_clusters, 1) * met_aff(1, :) + ...
            diag(inf(1, n_clusters));
  diffs .*= ones(n_clusters, 1) * alpha';

  %% Find lambda
  lambda = -min(min(diffs(2 : n_clusters, :)));

  %% Find detectable
  detectable = delta > ((n_clusters - 1) * lambda) ./ alpha_f;
endfunction

function [ detectable ] = find_detectable_dl4(alpha, met_aff)
  %% Number of clusters
  n_clusters = length(alpha);

  %% Alphas
  alpha_f = alpha(2 : n_clusters);

  %% Find delta
  delta = min((diag(met_aff) - met_aff(1, :)')(2 : n_clusters));

  %% Find differences
  diffs   = met_aff - ones(n_clusters, 1) * met_aff(1, :) + ...
            diag(inf(1, n_clusters));
  diffs .*= ones(n_clusters, 1) * alpha';

  %% Find lambda's
  lambda_1 = -min(diffs(2 : n_clusters, 1));
  lambda_f = -min(min(diffs(2 : n_clusters, 2 : n_clusters)));

  %% Find detectable
  detectable = delta > (lambda_1 + (n_clusters - 2) * lambda_f) ./ alpha_f;
endfunction
