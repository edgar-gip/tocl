%% -*- mode: octave; -*-

%% Add something to the LOADPATH
addpath("/home/egonzalez/devel/research/matlabClustering/io", ...
        "/home/egonzalez/devel/research/matlabClustering/measures");

%% Get arguments
doc2cat = argv{1};
rlabel  = argv{2};

%% Load labels
[ L n ] = read_labels_num(rlabel, doc2cat);

%% Read every cluster
[ length dummy ] = size(argv);
for i = 3:length
  %% Read
  [ C nc ] = read_clustering(argv{i});

  %% Find purity
  [ nmi Occ ] = meas_nmi(C, L);

  %% Number of clusters (real)
  nr = sum(sum(Occ') ~= 0);

  %% Output
  printf("%s %g %d/%d/%d\n", argv{i}, nmi, nr, nc, n);
end
