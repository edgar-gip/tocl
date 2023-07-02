%% -*- mode: octave; -*-

%% SVM test

%% Path
addpath ..

%% -> A cube split through a plane
data    = [ 0, 0, 0 ; 0, 0, 1 ; 0, 1, 0 ; 0, 1, 1 ; ...
            1, 0, 0 ; 1, 0, 1 ; 1, 1, 0 ; 1, 1, 1 ];
classes = [ -1, +1, +1, +1, -1, -1, -1, +1 ];

%% Plot
%% plot3(data(classes > 0, 1), data(classes > 0, 2), data(classes > 0, 3), 'o1',
%%      data(classes < 0, 1), data(classes < 0, 2), data(classes < 0, 3), 'o2');

%% Do it
spdata          = sparse(data');
opts.use_dual   = true();
[ model, info ] = simple_svm(spdata, classes, opts);

%% Classify
classes
model.omega, model.b
full(model.omega * spdata + model.b)

%% Do it
opts.use_dual   = false();
[ model, info ] = simple_svm(spdata, classes, opts);

%% Classify
model.omega, model.b
full(model.omega * spdata + model.b)

%% Pause
%% pause();
