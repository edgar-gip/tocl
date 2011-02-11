%% -*- mode: octave; -*-

%% k-Minority Detection
%% Clustering function

%% Author: Edgar Gonzalez

function [ expec, model, info ] = cluster(this, data, k, expec_0)

  %% Check arguments
  if ~any(nargin() == [ 2, 3, 4 ])
    usage(cstrcat("[ expec, model, info ] = ",
		  "@KMD/cluster(this, data [, k [, expec_0]])"));
  endif

  %% The number of clusters must be 1
  if nargin() >= 3 && k ~= 1
    usage("k must be 1 if given");
  endif

  %% Warn that expec_0 is ignored
  if nargin() == 4 && ~isempty(expec_0)
    warning("expec_0 is ignored");
  endif

  %% Size
  [ n_dims, n_data ] = size(data);

  %% Effective min size
  if this.min_size >= 1.0
    eff_min_size = this.min_size;
  else
    eff_min_size = max([ 1, floor(this.min_size * n_data) ]);
  endif

  %% Effective start size
  if this.start_size >= 1.0
    eff_start_size = this.start_size;
  else
    eff_start_size = max([ 1, floor(this.start_size * n_data) ]);
  endif

  %% Effective change threshold
  if this.change_threshold >= 1.0
    eff_change_threshold = this.change_threshold;
  else
    eff_change_threshold = max([ 1, floor(this.change_threshold * n_data) ]);
  endif

  %% Hard expectation
  hard_expec = zeros(1, n_data);

  %% Unassigned data and indices
  un_idxs = 1 : n_data;
  n_un    = n_data;

  %% Create the background component
  bg_c = feval(this.bg_component, data);

  %% Background log-likelihood
  bg_ll = log_likelihood(bg_c, data);

  %% Foreground components
  fg_cs = [];
  fg_k  = 0;

  %% For each iteration
  for i = 1 : this.max_iterations
    %% Select an unassigned element as seed
    seed_idx = un_idxs(1 + floor(n_un * rand()));

    %% Create the component
    fg_c = feval(this.fg_component, data(:, seed_idx));

    %% Extend it
    fg_idxs = un_idxs(add(fg_c, data(:, un_idxs), eff_start_size));

    %% Inner loop
    final = false();
    while ~final
      %% Find log-likelihood
      fg_ll = log_likelihood(fg_c, data(:, fg_idxs));

      %% Which are below it?
      out_idxs = fg_idxs(find(fg_ll < bg_ll(fg_idxs)));

      %% Remove
      fg_idxs = setdiff(fg_idxs, out_idxs);

      %% Update component
      remove(fg_c, data(:, out_idxs));

      %% Changes below the threshold?
      final = length(out_idxs) < eff_change_threshold || length(fg_idxs) == 0;
    endwhile

    %% Is the size more than the threshold?
    size = length(fg_idxs);
    if size >= eff_min_size
      %% One more cluster
      fg_k += 1;

      %% Set expectation
      hard_expec(fg_idxs) = fg_k;

      %% Remove
      un_idxs = setdiff(un_idxs, fg_idxs);
      n_un    = length(un_idxs);

      %% Not enough for a single cluster?
      if n_un < eff_min_size
	break
      endif
    endif
  endfor

  %% Expectation
  expec_on = find(hard_expec);
  expec    = ...
      sparse(hard_expec(expec_on), expec_on, ones(1, length(expec_on)), ...
	     fg_k, n_data);

  %% Model
  model = [];

  %% Info
  info = struct();
endfunction
