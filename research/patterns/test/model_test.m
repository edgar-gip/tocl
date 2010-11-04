%% -*- mode:octave; -*-

pkg load octopus;

%% Distances
d1 = KernelDistance(RBFKernel(1.0));
d2 = SqEuclideanDistance();

%% Clusterers
c11 = HyperBB(d1, struct("size_ratio", 0.1));
c12 = HyperBB(d2, struct("size_ratio", 0.1));
c21 = EWOCS(Voronoi(d1), struct("ensemble_size", 50));
c22 = EWOCS(Voronoi(d2), struct("ensemble_size", 50));

%% Clusterers set
cs       = { c11, c12, c21, c22 };
cs_names = { "HyperBB - RBF",  "HyperBB - SqE", ...
	     "EWOCS - RBF",    "EWOCS - SqE" };
n_cs = length(cs);

%% Tries
for i = 1 : 2
  %% Generate the data
  noise   = 20.0 * rand(2, 2000);
  signal1 =  1.0 * rand(2,  100) + (5.0 * rand(2, 1)) * ones(1, 100);
  signal2 =  1.0 * rand(2,  100) + (5.0 * rand(2, 1)) * ones(1, 100);
  x       = [ noise, signal1, signal2 ];

  %% New figure
  figure();

  %% Cluster
  for i = 1 : n_cs
    %% Cluster (timed)
    [ total0, user0, system0 ] = cputime();
    [ expec, model ] = cluster(cs{i}, x);
    [ total1, user1, system1 ] = cputime();

    %% Display the difference
    fprintf(2, "%s -> %g\n", cs_names{i}, total1 - total0);

    %% Model is OK
    %% expec1 = expectation(model, x);
    %% if ~all(abs(expec - expec1) < 1e-6)
    %%   abs(expec - expec1)
    %%   error("Model is not working fine");
    %% endif

    %% Take positive cluster
    cl = expec > 0.5;

    %% plot
    subplot(2, ceil(n_cs / 2), i);
    plot(x(1, :),  x(2, :),  'bx',
	 x(1, cl), x(2, cl), 'ro');
    title(cs_names{i});
  endfor
endfor

pause;
