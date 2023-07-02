%% -*- mode: octave; -*-

%% Add something to the LOADPATH
addpath("/home/egonzalez/devel/research/matlabClustering/io", ...
        "/home/egonzalez/devel/research/matlabClustering/measures");

%% Get arguments
args = argv();
doc2cat = args{1};
rlabel  = args{2};

%% Load labels
[ L n ] = read_labels_num(rlabel, doc2cat);

%% Read every cluster
[ length dummy ] = size(args);
for i = 3 : length
  %% Read
  [ C nc ] = read_clustering(args{i});

  %% Find purity
  [ pur ipur f1 Occ ] = meas_purity(C, L);

  %% Number of clusters (real)
  nr = sum(sum(Occ') ~= 0);

  %% Output
  printf("%s %g %g %g %d/%d/%d\n", args{i}, pur, ipur, f1, nr, nc, n);
end
