%% -*- mode: octave; -*-

%% Cutting Plane Multiclass Maximum Margin Clustering Algorithm (CPM3C)
%% Driver procedure

%% Author: Edgar Gonzalez

function [ expec, model, info ] = CPM3C_clustering(data, k, opts)

  %% Data and k must be given
  if nargin() < 2 || nargin() > 3
    usage('[ expec, model, info ] = CPM3C_clustering(data, k [, opts ])');
  endif

  %% Sizes
  [ n_dims, n_data ] = size(data);

  %% Defaults
  if nargin() < 3
    opts = struct();
  elseif ~isstruct(opts)
    usage("opts must be a structure if present");
  endif

  %% C: same as in SVM
  if ~isfield(opts, "C")
    opts.C = 1.0;
  endif

  %% epsilon: precision control
  if ~isfield(opts, "epsilon")
    opts.epsilon = 0.10;
  endif

  %% l: balance constraint
  if ~isfield(opts, "l")
    opts.l = 10;
  endif

  %% per_quit: total step of the CCCP iteration
  if ~isfield(opts, "per_quit")
    opts.per_quit = 0.01;
  endif

  %% Verbose
  if ~isfield(opts, "verbose")
    %% Default -> false
    opts.verbose = false();
  endif

  %% xi_0
  if ~isfield(opts, "xi_0")
    opts.xi_0 = 0.5;
  endif

  %% How many classes?
  if k == 2
    %% use_dual: use or not dual
    if ~isfield(opts, "use_dual")
      opts.use_dual = true();
    endif

    %% omega_0
    if ~isfield(opts, "omega_0")
      %% Random in [-1...+1] range
      opts.omega_0 = 2 * rand(n_dims, 1) - 1;
    endif

    %% b_0
    if ~isfield(opts, "b_0")
      %% Random in [-1...+1] range
      opts.b_0 = 2 * rand() - 1;
    endif

    %% Call CPMMC
    [ expec, model, info ] = CPMMC_loop(data, opts);

  else
    %% omega_0
    if ~isfield(opts, "omega_0")
      %% Random in [-1...+1] range
      opts.omega_0 = 2 * rand(n_dims, k) - 1;
    endif
    
    %% Call generic CPM3C
    [ expec, model, info ] = CPM3C_loop(data, k, opts);
  endif
endfunction
