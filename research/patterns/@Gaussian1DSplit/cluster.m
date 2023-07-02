%% -*- mode: octave; -*-

%% 1D Gaussian distribution splitter
%% Main procedure

%% Author: Edgar Gonzalez

function [ expec, model, info ] = cluster(this, data, k, expec_0)

  %% Check arguments
  if ~any(nargin() == [ 2, 3, 4 ])
    usage(cstrcat("[ expec, model, info ] = ", ...
                  "@Gaussian1DSplit/cluster(this, data [, k [, expec_0 ]])"));
  endif

  %% The number of clusters must be 2
  if nargin() >= 3 && k ~= 2
    usage("k must be 2 if given");
  endif

  %% Warn that expec_0 is ignored
  if nargin() == 4 && ~isempty(expec_0)
    warning("expec_0 is ignored");
  endif

  %% Size
  n_data = length(data);

  %% Sort
  [ sort_data, sort_idx ] = sort(data);

  %% Cummulated sums
  left_sum     = cumsum(sort_data);
  left_sum_sq  = cumsum(sort_data .* sort_data);
  right_sum    = left_sum   (n_data) - [ 0,    left_sum(1 : n_data - 1) ];
  right_sum_sq = left_sum_sq(n_data) - [ 0, left_sum_sq(1 : n_data - 1) ];

  %% Means and variances
  left_mean  = left_sum     ./ (1 : n_data);
  left_var   = left_sum_sq  ./ (1 : n_data) - left_mean  .* left_mean;
  right_mean = right_sum    ./ (n_data : -1 : 1);
  right_var  = right_sum_sq ./ (n_data : -1 : 1) - right_mean .* right_mean;

  %% Cut points
  log_like = zeros(1, n_data - 1);
  for k = 1 : n_data - 1
    log_like(k) = + k * ...
                    log(1 / sqrt(2 * pi * left_var(k)) * k / n_data) ...
                  - sum(((sort_data(1 : k) - left_mean(k)) .^ 2) ./ ...
                        (2 * left_var(k))) ...
                  + (n_data - k) * ...
                    log(1 / sqrt(2 * pi * right_var(k + 1)) * ...
                        (n_data - k) / n_data)...
                  - sum(((sort_data(k + 1 : n_data) -
                          right_mean(k + 1)) .^ 2) ./ ...
                        (2 * right_var(k + 1)));
  endfor

  %% Fix numerical errors
  log_like = real(log_like);

  %% Cut
  [ max_log_like, max_log_like_idx ] = max(log_like);

  %% Expectation
  expec = sparse([ 1 * ones(1, max_log_like_idx), ...
                   2 * ones(1, n_data - max_log_like_idx) ], ...
                 sort_idx, ones(1, n_data), 2, n_data);

  %% Model
  alphas = [ max_log_like_idx / n_data, (n_data - max_log_like_idx) / n_data ];
  means  = [ left_mean(max_log_like_idx), right_mean(max_log_like_idx + 1) ];
  vars   = [ left_var(max_log_like_idx), right_var(max_log_like_idx + 1) ];
  model  = Gaussian1DModel(2, alphas, means, vars);

  %% Return the information
  info          = struct();
  info.cut_size = [ max_log_like_idx, n_data - max_log_like_idx ];
  info.cut      = data(sort_idx(max_log_like_idx));
  info.log_like = max_log_like;
endfunction
