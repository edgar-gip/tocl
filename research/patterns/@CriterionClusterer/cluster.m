%% -*- mode: octave; -*-

%% Criterion-function based clustering
%% Main procedure

%% Author: Edgar Gonzalez

function [ best_expec, best_model, best_info ] = cluster(this, data, k, expec_0)

  %% Check arguments
  if ~any(nargin() == [ 2, 3, 4 ])
    usage(cstrcat("[ best_expec, best_model, best_info ] = ", ...
                  "@CriterionCluster/cluster(this, data [, k [, expec_0]])"));
  endif

  %% Are k and expec_0 given?
  if nargin() == 4
    %% Pass it, right now!
    [ expec, model, info ] = cluster(this.inner, data, k, expec_0);

  else
    %% Size
    n_data = data_size(data);

    %% Effective min and max k
    if nargin() == 3 && ~isempty(k)
      eff_min_k = eff_max_k = k;

    else
      if this.min_k < 1
        eff_min_k = floor(this.max_k * n_data);
      else
        eff_min_k = min([ this.min_k, n_data ]);
      endif

      if this.max_k <= 1
        eff_max_k = floor(this.max_k * n_data);
      else
        eff_max_k = max([ eff_min_k, min([ this.max_k, n_data ]) ]);
      endif
    endif

    %% Best so far
    if eff_min_k == 1
      %% One cluster model
      [ best_expec, best_model, best_info ] = ...
          cluster(this.clusterer, data, 1, ones(1, n_data));

      %% Criterion
      best_crit = ...
          apply(this.criterion, data, best_expec, best_model, best_info);

      %% Add
      best_info.k         = 1;
      best_info.criterion = best_crit;

      %% Update
      eff_min_k = 2;

    else
      %% Empty model
      best_expec = [];
      best_model = [];
      best_info  = struct();
      best_crit  = -inf;
    endif

    %% For each one
    for k = eff_min_k : eff_max_k

      %% Iterate
      for r = 1 : this.repeats

        %% Do it
        [ expec, model, info ] = cluster(this.clusterer, data, k);

        %% Criterion
        crit = apply(this.criterion, data, expec, model, info);

        %% Log
        %% fprintf(2, "%d %d -> %g\n", k, r, crit);

        %% Better?
        if crit > best_crit
          best_expec = expec;
          best_model = model;
          best_info  = info;
          best_crit  = crit;

          %% Add
          best_info.k         = k;
          best_info.criterion = crit;
        endif
      endfor
    endfor
  endif
endfunction
