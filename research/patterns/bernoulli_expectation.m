% Bernoulli distribution clustering
% Expectation

% Author: Edgar Gonzalez

function [ expec, log_like ] = bernoulli_expectation(data, model)
  % Number of data
  n_data = size(data, 2);

  % Find the expectation
  expec = model.alpha_ctheta * ones(1, n_data) .+ ...
          model.theta        * data;

  % Normalize
  max_expec = max(expec);
  sum_expec = max_expec .+ log(sum(exp(expec .- ones(model.k, 1) * max_expec)));
  expec     = exp(expec .- ones(model.k, 1) * sum_expec );

  % Log-likelihood
  log_like = sum(sum_expec);

% Local Variables:
% mode:octave
% End:
