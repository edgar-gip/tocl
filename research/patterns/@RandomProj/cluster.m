%% -*- mode: octave; -*-

%% Random projection clustering
%% Main procedure

%% Author: Edgar Gonzalez

function [ expec, model, info ] = cluster(this, data, k, expec_0)

  %% Check arguments
  if ~any(nargin() == [ 3, 4 ])
    usage(cstrcat("[ expec, model, info ] = ", ...
		  "@RandomProj/cluster(this, data, k [, expec_0])"));
  endif

  %% Size
  [ n_dims, n_data ] = size(data);

  %% Warn that expec_0 is ignored
  %% if nargin() == 4 && ~isempty(expec_0)
  %%   warning("expec_0 is ignored");
  %% endif

  %% Random projection matrix
  projection = rand(k, n_dims) - 0.5;

  %% Normalize
  projection ./= sqrt(sum(projection .^ 2, 2)) * ones(1, n_dims);

  %% Random bias
  if this.homogeneous
    %% No bias
    bias = zeros(k, 1);

  else
    %% Apply the projection matrix
    margin = projection * data;

    %% Min, max and range
    min_margin = min(margin')';
    max_margin = max(margin')';
    range      = max_margin - min_margin;

    %% Biases should lie within the range
    bias = min_margin + range .* rand(k, 1);
  endif

  %% Create the model
  model = RandomProjModel(this.soft_alpha, projection, bias);

  %% Find the expectation
  [ expec, log_like ] = expectation(model, data);

  %% Return the information
  info          = struct();
  info.log_like = log_like;
endfunction
