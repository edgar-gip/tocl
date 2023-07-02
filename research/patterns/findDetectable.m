%% -*- mode: octave; -*-

%% Find detectable clusters from affinity matrix

%% Author: Edgar Gonzàlez i Pellicer


%% Division by zero
%% warning error Octave:divide-by-zero;

%% Octopus
pkg load octopus;


%%%%%%%%%%
%% Main %%
%%%%%%%%%%

%% Get the parameters
args = argv();

%% Stats
consistency_sum   = struct();
consistency_den   = struct();
detectability_sum = struct();
detectability_den = struct();
cluster_det       = struct();
cluster_total     = struct();

%% For each file
n = length(args);
for i = 1 : n
  %% Load
  loaded = load(args{i}, "alpha", "affinities");
  alpha      = loaded.alpha;
  affinities = loaded.affinities;

  %% Methods
  methods = fieldnames(affinities);
  for j = 1 : length(methods);
    met = methods{j};

    %% Detectable
    dets    = find_detectable(alpha, getfield(affinities, met));
    n_dets  = sum(dets);
    n_clust = length(dets);

    %% Consistency
    consistency = n_dets == n_clust;
    detectablty = n_dets  / n_clust;

    %% Log
    %% fprintf(2, "%15s %15s %d/%d = %6.2f%%\n", args{i}, met, ...
    %%         n_dets, n_clust, 100 * consistency);

    %% Update stats
    if ~isfield(consistency_sum, met)
      consistency_sum = setfield(consistency_sum, met, consistency);
      consistency_den = setfield(consistency_den, met, 1);
      detectablty_sum = setfield(consistency_sum, met, detectablty);
      detectablty_den = setfield(consistency_den, met, 1);
      cluster_det     = setfield(cluster_det,     met, n_dets);
      cluster_total   = setfield(cluster_total,   met, n_clust);
    else
      consistency_sum = setfield(consistency_sum, met, ...
                                 getfield(consistency_sum, met) + consistency);
      consistency_den = setfield(consistency_den, met, ...
                                 getfield(consistency_den, met) + 1);
      detectablty_sum = setfield(detectablty_sum, met, ...
                                 getfield(detectablty_sum, met) + detectablty);
      detectablty_den = setfield(detectablty_den, met, ...
                                 getfield(detectablty_den, met) + 1);
      cluster_det     = setfield(cluster_det,     met, ...
                                 getfield(cluster_det,     met) + n_dets);
      cluster_total   = setfield(cluster_total,   met, ...
                                 getfield(cluster_total,   met) + n_clust);
    endif
  endfor
endfor

%% Averages
methods = fieldnames(consistency_sum);
for j = 1 : length(methods)
  met = methods{j};

  %% Averages
  consistency = ...
      getfield(consistency_sum, met) / getfield(consistency_den, met);
  macro_detectablty = ...
      getfield(detectablty_sum, met) / getfield(detectablty_den, met);
  micro_detectablty = ...
      getfield(cluster_det, met) / getfield(cluster_total, met);

  %% Print them
  printf("%s %.2f %.2f %.2f\n", met, 100 * consistency, ...
         100 * macro_detectablty, 100 * micro_detectablty);
endfor
