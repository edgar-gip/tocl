%% -*- mode: octave; -*-

%% Kernel Density Estimation EM clustering
%% Expectation

%% Author: Edgar Gonzalez

function [ expec, log_like ] = expectation(this, data)

  %% Check arguments
  if nargin() ~= 2
    usage("[ expec, log_like ] = @KdeEMModel/expectation(this, data)");
  endif

  %% Find the kernel
  KM = apply(this.kernel, this.data, data); % n_base * n_data

  %% Add it
  expec = this.expec * KM;

  %% Normalize
  sum_expec = sum(expec);
  expec     = expec ./ (ones(this.k, 1) * sum_expec);

  %% Log-likelihood
  log_like = sum(log(sum_expec));
endfunction
