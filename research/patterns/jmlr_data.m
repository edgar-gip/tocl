%% -*- mode: octave; -*-

%% Generate the data
function [ data, truth ] = jmlr_data(generator)
  %% Which generator?
  switch generator
    case "2gauss"
      [ data, truth ] = gen_two_gauss();
    case "3gauss-d"
      [ data, truth ] = gen_three_gauss_d();
    case "gauss-tri"
      [ data, truth ] = gen_gauss_tri();
    case "tri-hm"
      [ data, truth ] = gen_tri_hm();
    case "gauss-tri-hm"
      [ data, truth ] = gen_gauss_tri_hm();
    case "2gauss-tri-hm"
      [ data, truth ] = gen_two_gauss_tri_hm();
    case "3gauss-tri-hm"
      [ data, truth ] = gen_three_gauss_tri_hm();
    otherwise
      error(sprintf("Wrong data generator '%s'", cmd_args{2}));
  endswitch
endfunction


%%%%%%%%%%%%%%%%%%%%%%%
%% Private functions %%
%%%%%%%%%%%%%%%%%%%%%%%

%% Random points in equilateral triangle
function [ data ] = randt(dims, n_data);
  %% Vertices
  el = sqrt(3) / 6;
  vx = [ 0 ; 2 * el ];
  vy = [ -0.5 ; -el ];
  vz = [ +0.5 ; -el ];

  %% Generate within the triangle
  %% From http://www.cgafaq.info/wiki/Random_Point_In_Triangle

  %% Generate random numbers
  x = rand(1, n_data);
  y = rand(1, n_data);

  %% Correct those for which the sum is larger than 1
  corr = (x + y) > 1;
  x(corr) = 1 - x(corr);
  y(corr) = 1 - y(corr);

  %% Third coordinate
  z = 1 - x - y;

  %% Return the data
  data = (vx * ones(1, n_data)) .* (ones(2, 1) * x) + ...
         (vy * ones(1, n_data)) .* (ones(2, 1) * y) + ...
         (vz * ones(1, n_data)) .* (ones(2, 1) * z);
endfunction

%% Random points in a david star
function [ data ] = randds(dims, n_data);
  %% Generate from a triangle
  data = randt(dims, n_data);

  %% Invert some
  inv = 2 * (rand(1, n_data) > 0.5) - 1;

  %% Do it
  data .*= ones(dims, 1) * inv;
endfunction

%% Random points in a half moon
function [ data ] = randhm(dims, n_data);
  %% Generate random numbers
  x = 2 * rand(1, n_data) - 1.0;
  y = 0.05 * randn(1, n_data);

  %% Return the data
  data = (ones(2, 1) * (1 + y)) .* [ cos(x) ; sin(x) ] - ...
          [ 1 ; 0 ] * ones(1, n_data);
endfunction

%% Two gaussian data set
function [ data, truth ] = gen_two_gauss()
  %% Generate each cluster
  data1 = 10 * rand(2, 2000) - 5;
  data2 = [ -2.5, 0 ]' * ones(1, 200) + 0.5 * randn(2, 200);
  data3 = [ +2.5, 0 ]' * ones(1, 200) + 0.5 * randn(2, 200);

  %% Join them
  data  = [ data1, data2, data3 ];
  truth = [ 1 * ones(1, 2000), 2 * ones(1, 200), 3 * ones(1, 200) ];
endfunction

%% Three gaussian data set
function [ data, truth ] = gen_three_gauss_d()
  %% Generate each cluster
  data1 = 10 * rand(2, 2000) - 5;
  data2 = [ -2.5,    0 ]' * ones(1, 200) + 0.5  * randn(2, 200);
  data3 = [ +2.5, +2.5 ]' * ones(1, 100) + 0.1  * randn(2, 100);
  data4 = [ +2.5, -2.5 ]' * ones(1, 100) + 0.1  * randn(2, 100);

  %% Join them
  data  = [ data1, data2, data3, data4 ];
  truth = [ 1 * ones(1, 2000), 2 * ones(1, 200), ...
	    3 * ones(1, 100),  4 * ones(1, 100) ];
endfunction

%% Gaussian and triangle set
function [ data, truth ] = gen_gauss_tri()
  %% Generate each cluster
  data1 = 10 * rand(2, 2000) - 5;
  data2 = [ -2.5, 0 ]' * ones(1, 200) + 0.5 * randn(2, 200);
  data3 = [ +2.5, 0 ]' * ones(1, 200) + 2.0 * randt(2, 200);

  %% Join them
  data  = [ data1, data2, data3 ];
  truth = [ 1 * ones(1, 2000), 2 * ones(1, 200), 3 * ones(1, 200) ];
endfunction

%% Triangle and half moon set
function [ data, truth ] = gen_tri_hm()
  %% Generate each cluster
  data1 = 10 * rand(2, 2000) - 5;
  data2 = [ -2.5, 0 ]' * ones(1, 200) + 2.0 * randt(2, 200);
  data3 = [ +2.5, 0 ]' * ones(1, 200) + 2.0 * randhm(2, 200);

  %% Join them
  data  = [ data1, data2, data3 ];
  truth = [ 1 * ones(1, 2000), 2 * ones(1, 200), 3 * ones(1, 200) ];
endfunction

%% Gaussian, triangle and half moon set
function [ data, truth ] = gen_gauss_tri_hm()
  %% Generate each cluster
  data1 = 10 * rand(2, 2000) - 5;
  data2 = [    0, +2.5 ]' * ones(1, 200) + 0.5 * randn(2, 200);
  data3 = [ -2.5, -2.5 ]' * ones(1, 200) + 2.0 * diag([-1, 1]) * randhm(2, 200);
  data4 = [ +2.5, -2.5 ]' * ones(1, 200) + 2.0 * randt(2, 200);

  %% Join them
  data  = [ data1, data2, data3, data4 ];
  truth = [ 1 * ones(1, 2000), 2 * ones(1, 200), 3 * ones(1, 200), ...
	    4 * ones(1, 200) ];
endfunction

%% Two gaussian, triangle and half moon set
function [ data, truth ] = gen_two_gauss_tri_hm()
  %% Generate each cluster
  data1 = 10 * rand(2, 2000) - 5;
  data2 = [ -2.5, +2.5 ]' * ones(1, 200) + 0.5 * randn(2, 200);
  data3 = [ -2.5, -2.5 ]' * ones(1, 200) + 2.0 * diag([-1, 1]) * randhm(2, 200);
  data4 = [ +2.5, -2.5 ]' * ones(1, 200) + 2.0 * randt(2, 200);
  data5 = [ +2.5, +2.5 ]' * ones(1, 100) + 0.1 * randn(2, 100);

  %% Join them
  data  = [ data1, data2, data3, data4, data5 ];
  truth = [ 1 * ones(1, 2000), 2 * ones(1, 200), 3 * ones(1, 200), ...
	    4 * ones(1, 200), 5 * ones(1, 100) ];
endfunction

%% Three gaussian, triangle and half moon set
function [ data, truth ] = gen_three_gauss_tri_hm()
  %% Generate each cluster
  data1 = 10 * rand(2, 2000) - 5;
  data2 = [ -2.5, +2.5 ]' * ones(1, 200) + 0.5 * randn(2, 200);
  %% data2 = [ -2.5, +2.5 ]' * ones(1, 300) + 2.5 * randds(2, 300);
  data3 = [ -2.5, -2.5 ]' * ones(1, 200) + 2.0 * diag([-1, 1]) * randhm(2, 200);
  data4 = [ +2.5, -2.5 ]' * ones(1, 200) + 2.0 * randt(2, 200);
  data5 = [ +1.0, +1.0 ]' * ones(1, 100) + 0.1 * randn(2, 100);
  data6 = [ +3.0, +3.0 ]' * ones(1, 100) + 0.3 * randn(2, 100);

  %% Join them
  data  = [ data1, data2, data3, data4, data5, data6 ];
  truth = [ 1 * ones(1, 2000), 2 * ones(1, 200), 3 * ones(1, 200), ...
	    4 * ones(1, 200), 5 * ones(1, 100), 6 * ones(1, 100) ];
endfunction

