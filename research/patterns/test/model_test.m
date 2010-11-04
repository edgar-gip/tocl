%% -*- mode:octave; -*-

pkg load octopus;

for i = 1 : 5
  x = rand(2, 1000);
  %% d = KernelDistance(RBFKernel(1.0));
  d = SqEuclideanDistance();
  %% c = HyperBB(d, struct("size_ratio", 0.2));
  c = EWOCS(Voronoi(d));

  [ expec, model ] = cluster(c, x);
  expec1 = expectation(model, x);

  if ~all(expec == expec1)
    expec - expec1
    error("Model is not working fine");
  endif

  cl = expec > 0.5;

  figure()
  plot(x(1, :),  x(2, :),  'bx',
       x(1, cl), x(2, cl), 'ro');
endfor

pause;
