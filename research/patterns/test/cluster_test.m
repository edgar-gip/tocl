%% -*- mode: octave; -*-

pkg load octopus;

%% Constants
global n_samples = 100;
global k         = 3;

%% Cluster and plot
function cluster_and_plot(index, clusterer, data, seeds_expec)
  %% Cluster
  [ cl, model, info ] = cluster(clusterer, data, 3, seeds_expec);

  %% Seed indices
  seeds = info.seeds;
  s1 = seeds(1);
  s2 = seeds(2);
  s3 = seeds(3);

  %% Harden clustering
  [ dummy, hard_cl ] = max(cl);
  cl1 = hard_cl == 1;
  cl2 = hard_cl == 2;
  cl3 = hard_cl == 3;

  %% First plot
  figure(index);
  plot3(data(1, :),  data(2, :),  cl(1, :),  'rx', ...
	data(1, s1), data(2, s1), cl(1, s1), 'ro', ...
	data(1, :),  data(2, :),  cl(2, :),  'kx', ...
	data(1, s2), data(2, s2), cl(2, s2), 'ko', ...
	data(1, :),  data(2, :),  cl(3, :),  'bx', ...
	data(1, s3), data(2, s3), cl(3, s3), 'bo');

  %% Second plot
  figure(index + 1);
  plot(data(1, cl1),  data(2, cl1),  'rx', ...
       data(1, s1),   data(2, s1),   'ro', ...
       data(1, cl2),  data(2, cl2),  'kx', ...
       data(1, s2),   data(2, s2),   'ko', ...
       data(1, cl3),  data(2, cl3),  'bx', ...
       data(1, s3),   data(2, s3),   'bo');
endfunction

%% Generate data
data = rand(2, n_samples);

%% Select seeds
seeds       = sort(randperm(n_samples)(1 : k));
seeds_expec = sparse(1 : k, seeds, ones(1, k), k, n_samples);

%% Voronoi options
vor_opts            = struct();
vor_opts.soft_alpha = 1.0;

%% Plots
cluster_and_plot(1, Voronoi(SqEuclideanDistance(), ...
			    vor_opts), data, seeds_expec);
cluster_and_plot(3, Voronoi(KernelDistance(LinearKernel()), ...
			    vor_opts), data, seeds_expec);
cluster_and_plot(5, Voronoi(KernelDistance(PolynomialKernel(2, true)), ...
			    vor_opts), data, seeds_expec);
cluster_and_plot(7, Voronoi(KernelDistance(RBFKernel(0.1)), ...
			    vor_opts), data, seeds_expec);

pause;
