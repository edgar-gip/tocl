%% -*- mode: octave; -*-

%% Multiclass kernel svm test

%% Octopus
pkg load octopus

%% Path
addpath ..

%% Number of samples
n_classes = 4;

%% Data along the diagonal
data        = diag(ones(1, n_classes));
classes     = 1 : n_classes;
opts.radial = true();
%% opts.kernel = @(x) x;

%% Do it
[ model, info ] = multiclass_kernel_svm(data, classes, opts)
distances = multiclass_kernel_svm_distances(data, model)
winners   = full(distance_winner(distances))
probs     = distance_probability(1.0, distances)

%% Duplicate it
data    = [ data,    2 * data ];
classes = [ classes, classes  ];

%% Redo it
[ model, info ] = multiclass_kernel_svm(data, classes, opts)
distances = multiclass_kernel_svm_distances(data, model)
winners   = full(distance_winner(distances))
probs     = distance_probability(1.0, distances)

%% Reduplicate it
data    = [ data,    2 * data ];
classes = [ classes, classes  ];

%% Redo it
[ model, info ] = multiclass_kernel_svm(data, classes, opts)
distances = multiclass_kernel_svm_distances(data, model)
winners   = full(distance_winner(distances))
probs     = distance_probability(1.0, distances)
