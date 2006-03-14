%% Add something to the LOADPATH
LOADPATH = [ LOADPATH ":/home/usuaris/egonzalez/devel/research/matlabClustering/io" ];
LOADPATH = [ LOADPATH ":/home/usuaris/egonzalez/devel/research/matlabClustering/measures" ];

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
  [ pur ipur f1 Occ ] = meas_purity(C, L);

  %% Number of clusters (real)
  nr = sum(sum(Occ') ~= 0);
  
  %% Output
  printf("%s %g %g %g %d/%d/%d\n", argv{i}, pur, ipur, f1, nr, nc, n);
end
