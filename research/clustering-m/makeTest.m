%% -*- mode: octave; -*-

%% Add something to the LOADPATH
addpath("/home/usuaris/egonzalez/devel/research/matlabClustering/combination",...
        "/home/usuaris/egonzalez/devel/research/matlabClustering/io",       ...
        "/home/usuaris/egonzalez/devel/research/matlabClustering/measures", ...
        "/home/usuaris/egonzalez/devel/research/matlabClustering/weak");

%% Data

%% APW
dAPW.dir = '/home/usuaris/egonzalez/devel/research/hybridTI/data/Remake-Combi/APW5000/words/';
dAPW.all = { 'geo.GW.85', 'it.GWN.10', 'it.WN.85', 'it.WN.85.2' };
dAPW.it  = { 'it.GWN.10', 'it.WN.85', 'it.WN.85.2' };

dLA.dir  = '/home/usuaris/egonzalez/devel/research/hybridTI/data/Remake-Combi/LATIMES/words/';
dLA.all = { 'geo.GW.55', 'it.W.90', 'it.WN.10', 'it.WN.80' };
dLA.it  = { 'it.W.90', 'it.WN.10', 'it.WN.80' };

dReu.dir = '/home/usuaris/egonzalez/devel/research/hybridTI/data/Remake-Combi/ReutersModApte/words/';
dReu.all = { 'geo.GWB.75', 'it.GW.10', 'it.WN.35', 'it.WN.75' };
dReu.it  = { 'it.GW.10', 'it.WN.35', 'it.WN.75' };

dReu10.dir = '/home/usuaris/egonzalez/devel/research/hybridTI/data/Remake-Combi/ReutersModApteTop10/words/';
dReu10.all = { 'geo.GW.90', 'it.W.40', 'it.WB.10', 'it.WN.85' };
dReu10.it  = { 'it.W.40', 'it.WB.10', 'it.WN.85' };

dSmart.dir = '/home/usuaris/egonzalez/devel/research/hybridTI/data/Remake-Combi/SMART/words/';
dSmart.all = { 'geo.GWN.90', 'it.GW.10', 'it.WN.35', 'it.WN.90' };
dSmart.it  = { 'it.GW.10', 'it.WN.35', 'it.WN.90' };

%% All
tests = { dLA, dReu, dReu10, dSmart };

%% Do it again
for i = 1:4
  %% Cd to the directory
  chdir(tests{i}.dir);

  %% Say we are in
  disp(tests{i}.dir);

  %% Cluster all
  %%%%%%%%%%%%%%%
  disp('All');
  [ Lls Sizes Models ] = comb_combine_mem(0, tests{i}.all{:});

  %% Data plot
  file = fopen("mem.gi.plot", "w");
  fprintf(file, "%d %g\n", [ Sizes Lls ]');
  fclose(file);

  %% Max
  [ val idx ] = max(Lls);
  file = fopen("mem.gi.gmax", "w");
  fprintf(file, "%d\n", Models{idx});
  fclose(file);

  %% Local
  [ val idx ] = comb_local_max(Lls);
  file = fopen("mem.gi.lmax", "w");
  fprintf(file, "%d\n", Models{idx});
  fclose(file);


  %% Cluster it
  %%%%%%%%%%%%%%%
  disp('It');
  [ Lls Sizes Models ] = comb_combine_mem(0, tests{i}.it{:});

  %% Data plot
  file = fopen("mem.i.plot", "w");
  fprintf(file, "%d %g\n", [ Sizes Lls ]');
  fclose(file);

  %% Max
  [ val idx ] = max(Lls);
  file = fopen("mem.i.gmax", "w");
  fprintf(file, "%d\n", Models{idx});
  fclose(file);

  %% Local
  [ val idx ] = comb_local_max(Lls);
  file = fopen("mem.i.lmax", "w");
  fprintf(file, "%d\n", Models{idx});
  fclose(file);

end
