%% -*- mode: octave; -*-

%% Maximal Mutual Information

function [ new_data, mi, max_dims ] = max_mi(data, k)

  %% Size
  [ n_dims, n_data ] = size(data);

  %% Convert to probabilities
  n_words  = sum(data, 1);
  p_w_by_x = data ./ (ones(n_dims, 1) * n_words); % p(w | x)

  %% Probability of a document
  p_x = 1.0 ./ n_data;

  %% Probability of a word
  p_w = sum(p_w_by_x, 2) .* p_x; % p(w)

  %% Probability of a document given a word
  p_x_by_w = (p_w_by_x * p_x) ./ (p_w * ones(1, n_data));

  %% Product matrix
  prod_matrix                  = p_x_by_w;
  prod_matrix(p_x_by_w ~= 0) .*= log(p_x_by_w(p_x_by_w ~= 0) ./ p_x);

  %% Mutual information
  mi = p_w .* sum(prod_matrix, 2);

  %% Sort them
  [ max_mi, max_dims ] = sort(mi, "descend");

  %% Fix k
  if k > n_dims
    k = n_dims
  endif

  %% New data
  new_data = data(max_dims(1 : k), :);

  %% Mutual info
  %% p_x_w = p_w_by_x * p_x;
  %% prod_matrix = p_x_w;
  %% reg_matrix  = p_w * (p_x * ones(1, n_data));
  %% prod_matrix(p_x_by_w ~= 0) .*= log(prod_matrix(p_x_by_w ~= 0) ./ ...
  %% 				     reg_matrix(p_x_by_w ~= 0));
  %% mi = sum(sum(prod_matrix));
endfunction
