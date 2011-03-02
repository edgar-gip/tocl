%% -*- mode: octave; -*-

%% Soft Bregman Bubble Clustering
%% Maximization

%% Author: Edgar Gonzalez

function [ model ] = maximization(this, data, expec)

  %% Check arguments
  if nargin() ~= 3
    usage("[ model ] = @SoftBBCEM/maximization(this, data, expec)");
  endif

  %% Number of data and features
  [ n_dims, n_data ] = size(data);
  [ k     , n_data ] = size(expec);

  %% Uniform background probability
  bg_p = -sum(log(max(data') - min(data')));

  %% Cluster sizes
  cl_sizes = sum(expec, 2)'; % 1 * k
  cl_size  = sum(cl_sizes);

  %% Mean
  cl_mu = full(data * expec') ./ (ones(n_dims, 1) * cl_sizes); % n_dims * k

  %% Smoothen cl_sizes
  cl_sizes .+= this.alpha_prior;

  %% Fixed background probability?
  if isnan(this.bg_alpha)
    %% Mutable

    %% Background size
    bg_size  = n_data - cl_size;

    %% A priori background probability
    bg_alpha = log((bg_size + this.alpha_prior) / ...
		   (n_data + (k + 1) * this.alpha_prior));

    %% Convert cl_sizes to alpha (and log)
    cl_sizes ./= n_data + (k + 1) * this.alpha_prior;
    cl_sizes   = log(cl_sizes);

  else
    %% A priori background probability
    bg_alpha = log(this.bg_alpha);

    %% Smoothen
    cl_sizes ./= cl_size + k * this.alpha_prior;
    cl_sizes   = log((1 - this.bg_alpha) * cl_sizes);
  endif

  %% Create the model
  model = SoftBBCEMModel(this.divergence, ...
			 this.beta, ...
			 k, ...
			 bg_alpha + bg_p, ...
	  		 cl_sizes, ... % 1 * k
			 cl_mu);       % n_dims * k
endfunction
