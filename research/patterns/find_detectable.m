%% -*- mode: octave; -*-

function [ detectable ] = find_detectable(alpha, met_aff, method = "exact")
  %% Which method?
  switch method
    case "exact"
      [ detectable ] = find_detectable_exact(alpha, met_aff);

    case "delta_lambda"
      [ detectable ] = find_detectable_dl(alpha, met_aff);

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

function [ detectable ] = find_detectable_dl(alpha, met_aff)
  %% Number of clusters
  n_clusters = length(alpha);

  %% Alphas
  alpha_1 = alpha(1);
  alpha_f = alpha(2 : n_clusters);

  %% Find delta
  fake_diag       = diag(met_aff) - met_aff(1, 1);
  fake_diag(1, 1) = inf;
  delta           = min(fake_diag)

  %% Find lambda_1
  lambda_1 = -min(met_aff(1, 2 : n_clusters) - met_aff(1, 1))

  %% Find lambda_f
  fake_aff = met_aff(2 : n_clusters, 2 : n_clusters) ...
           + diag(inf(1, n_clusters - 1));
  lambda_f = -min(min(fake_aff - ...
		      ones(n_clusters - 1, 1) * met_aff(1, 2 : n_clusters)))

  %% Find detectable
  detectable = delta > (alpha_1 * lambda_1 + ...
			(1 - alpha_1 - alpha_f) * lambda_f) ./ alpha_f
endfunction
