%% -*- mode: octave; -*-

%% Random clustering similarity

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus

%% Ando elements
source(binrel("andoElements.m"));
source(binrel("andoClusterers.m"));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Normalized Mutual Information %
% As in (Strehl & Ghosh, 2002)  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Entropy
function [ e ] = entropy(marg)
  %% Find it
  e = full(-sum(marg .* log(marg)));
endfunction

%% Normalized mutual information
%% And matched value
function [ value ] = nmi(cl_1, marg_1, sqrt_h_1, cl_2, marg_2, sqrt_h_2)
  %% Size
  [ k_1, n_data ] = size(cl_1);
  [ k_2, n_data ] = size(cl_2);

  %% Average contingency table
  act = (cl_1 * cl_2') / n_data;

  %% Mutual information
  mi = sum(sum(act .* log(act ./ ((marg_1 * ones(1, k_2)) .* ...
				  (ones(k_1, 1) * marg_2')))));

  %% Normalize
  value = full(mi) / sqrt_h_1 / sqrt_h_2;

  %% From this on, this is a fail...

  %% %% Match
  %% [ match, map_1, map_2, groups ] = multi_assignment(act);

  %% %% Map matrices
  %% map_m_1 = sparse(map_1, 1 : k_1, ones(1, k_1), groups, k_1);
  %% map_m_2 = sparse(map_2, 1 : k_2, ones(1, k_2), groups, k_2);

  %% %% Convert average contingency table
  %% map_act = map_m_1 * act * map_m_2';

  %% %% Convert clusters
  %% map_cl_1 = map_m_1 * cl_1;
  %% map_cl_2 = map_m_2 * cl_2;

  %% %% Convert marginals
  %% map_marg_1 = map_m_1 * marg_1;
  %% map_marg_2 = map_m_2 * marg_2;

  %% %% Find entropies
  %% map_sqrt_h_1 = sqrt(entropy(map_marg_1));
  %% map_sqrt_h_2 = sqrt(entropy(map_marg_2));

  %% %% Mi
  %% map_mi = sum(sum(map_act .* ...
  %% 		   log(map_act ./ ((map_marg_1 * ones(1, groups)) .* ...
  %% 				   (ones(groups, 1) * map_marg_2')))));

  %% %% Normalize
  %% m_value = full(map_mi) / map_sqrt_h_1 / map_sqrt_h_2;
endfunction


%%%%%%%%%%
%% Main %%
%%%%%%%%%%

%% Get the parameters
args = argv();
if length(args) ~= 8
  error(cstrcat("Wrong number of arguments: Expected", ...
		" <input> <distance> <d-extra> <clusterer> <c-extra>", ...
		" <repeats> <max_k> <seed>"));
endif

%% Input file
input = args{1};
try
  load(input, "data", "truth");
catch
  error("Cannot load data from '%s': %s", input, lasterr());
end_try_catch

%% Distance
dist = args{2};
if ~isfield(distances, dist)
  error("Wrong distance name '%s'. Must be: %s", met, fields(distances));
endif

%% Extra arguments
dextra = regex_split(args{3}, '(,|\s+,)\s*');

%% Clusterer
clu = args{4};
if ~isfield(clusterers, clu)
  error("Wrong clusterer name '%s'. Must be: %s", clu, fields(clusterers));
endif

%% Extra arguments
cextra = regex_split(args{5}, '(,|\s+,)\s*');

%% Enough args?
req_args = getfield(clusterers, clu, "args");
if length(cextra) ~= req_args
  error("Clusterer '%s' requires %d extra arg(s): %s",
	clu, req_args, getfield(clusterers, clu, "help"));
endif

%% Repeats
[ repeats, status ] = str2double(args{6});
if status ~= 0
  error("Wrong number of repetitions '%s'", args{6})
endif

%% Max clusters
[ max_clusters, status ] = str2double(args{7});
if status ~= 0
  error("Wrong maximum number of clusters '%s'", args{7})
endif

%% Seed
[ seed, status ] = str2double(args{8});
if status ~= 0
  error("Wrong seed '%s'", args{8});
endif


%% Initialize seed
set_all_seeds(seed);

%% Create distance
distfun = getfield(distances, dist);
if isfunctionhandle(distfun)
  distance = distfun(data, dextra);
else
  distance = distfun;
endif

%% Create clusterer
clustfun  = getfield(clusterers, clu, "make");
clusterer = clustfun(distance, cextra);


%% Size
[ n_dims, n_data ] = size(data);

%% Effective max_clusters
if max_clusters > n_data
  eff_max_clusters = n_data;
else
  eff_max_clusters = max_clusters;
endif

%% Effective range
eff_range = eff_max_clusters - 1;


%% History
cl_i     = cell(repeats);
marg_i   = cell(repeats);
sqrt_h_i = zeros(1, repeats);

%% Accumulated NMI
acc_nmi = 0;

%% For each element in the ensemble
for i = 1 : repeats

  %% Select the number of classes and seeds
  k     = floor(2 + eff_range * rand());
  seeds = sort(randperm(n_data)(1 : k));

  %% Seed expectation
  seed_expec = sparse(1 : k, seeds, ones(1, k), k, n_data);

  %% Find the clustering (expec)
  ind_cl = cluster(clusterer, data, k, seed_expec);

  %% Marginals and entroy
  ind_marg   = sum(ind_cl, 2) ./ n_data;
  ind_sqrt_h = sqrt(entropy(ind_marg));

  %% Full!
  %% ind_marg = full(ind_marg);

  %% Compare to previous
  for j = 1 : (i - 1)
    %% Find nmi
    n = nmi(cl_i{j}, marg_i{j}, sqrt_h_i(j), ind_cl, ind_marg, ind_sqrt_h);

    %% Accumulate it
    acc_nmi   += n;
  endfor

  %% Store it
  cl_i{i}     = ind_cl;
  marg_i{i}   = ind_marg;
  sqrt_h_i(i) = ind_sqrt_h;
endfor

%% Average
n_pairs  = repeats * (repeats - 1) / 2;
acc_nmi /= n_pairs;

%% Display
printf("%5.3f\n", acc_nmi);
