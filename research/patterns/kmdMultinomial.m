%% -*- mode: octave; -*-

%% Minority clustering of data
%% Edgar Gonzalez i Pellicer

%% Octopus
pkg load octopus;


%%%%%%%%%%%%
%% Output %%
%%%%%%%%%%%%

%% Number of features
global display_feats = 20;

%% Display a component
function display_component(label, alpha, log_theta, feats)
  global display_feats;

  %% Display alpha
  printf("%s: p=%.3f", label, alpha);

  %% Sort
  [ s_ths, s_feats ] = sort(log_theta, "descend");

  %% Take the first 20
  for i = 1 : min([ display_feats, length(s_feats) ])
    printf(" %s(%.3f)", feats{s_feats(i)}, log_theta(s_feats(i)));
  endfor

  %% Newline
  printf(" ...\n\n");
endfunction

%% Display a confusion matrix
function display_confusion(label, sys_expec, truth_expec, add_bg = false())
  %% Harden the expectation
  sys_hexpec = harden_expectation(sys_expec, add_bg);

  %% Confusion
  confusion = full(truth_expec * sys_hexpec');

  %% Display
  disp(label);
  disp(confusion);
  disp("");
endfunction


%%%%%%%%%%
%% Main %%
%%%%%%%%%%

%% Get the parameters
args = argv();

%% Check parameter length
if length(args) ~= 5
  error(cstrcat("Wrong number of arguments: Expected", ...
                " <input> <s_0> <s_min> <iterations> <seed>"));
endif

%% Input file
input = args{1};
try
  load(input, "data", "truth", "feats");
catch
  error("Cannot load data from '%s': %s", input, lasterr());
end_try_catch

%% Parse
s_0   = parse_double(args{2}, "s_0");
s_min = parse_double(args{3}, "s_min");
its   = parse_double(args{4}, "iterations");
seed  = parse_double(args{5}, "seed");


%% Initialize seed
set_all_seeds(seed);


%% Create kMD clusterer
kmd_clusterer = KMD(@KMDMultinomial, [], ...
                    struct("start_size",     s_0,   ...
                           "min_size",       s_min, ...
                           "max_iterations", its));

%% Perform clustering
[ kmd_expec, kmd_model ] = cluster(kmd_clusterer, data);


%% Truth information
n_data  = length(truth);
classes = max(truth);

%% Create the truth expectation
truth_expec = sparse(truth, 1 : n_data, ones(1, n_data), classes, n_data);


%% Overall distribution
overall_c = KMDMultinomial(data);
display_component("ovr", 1.0, theta(overall_c), feats);

%% True classes
for c = 1 : classes
  %% Indices
  idxs = truth == c;

  %% Find the component
  a    = sum(idxs) / n_data;
  comp = KMDMultinomial(data(:, idxs));

  %% Display
  display_component(sprintf("s_%d", c), a, theta(comp), feats);
endfor


%% Display confusion matrix
display_confusion("kMD:", kmd_expec, truth_expec, true);


%% Components
kmd_as = alpha(kmd_model);
kmd_cs = components(kmd_model);
kmd_k  = length(kmd_as);

%% For each one...
for c = 1 : kmd_k
  %% Display it
  display_component(sprintf("kmd_%d", c), kmd_as(c), theta(kmd_cs{c}), feats);
endfor


%% Remove the background
fg_idxs  = truth > 1;
n_fg     = sum(fg_idxs);
fg_data  = data(:, fg_idxs);
fg_truth = truth(:, fg_idxs) - 1;
fg_expec = sparse(fg_truth, 1 : n_fg, ones(1, n_fg), classes - 1, n_fg);

%% Create EM clusterer
em_clusterer = Multinomial();

%% Perform clustering
[ em_expec, em_model ] = cluster(em_clusterer, fg_data, classes - 1);


%% Display confusion matrix
display_confusion("EM:", em_expec, fg_expec, false);


%% Components
em_as  = alpha(em_model);
em_ths = theta(em_model);
em_k   = length(em_as);

%% For each one...
for c = 1 : em_k
  %% Display it
  display_component(sprintf("em_%d", c), em_as(c), em_ths(c, :), feats);
endfor


%% Perform full clustering
[ emf_expec, emf_model ] = cluster(em_clusterer, data, classes);


%% Display confusion matrix
display_confusion("EM (Full):", emf_expec, truth_expec, false);


%% Components
emf_as  = alpha(emf_model);
emf_ths = theta(emf_model);
emf_k   = length(emf_as);

%% For each one...
for c = 1 : emf_k
  %% Display it
  display_component(sprintf("emf_%d", c), emf_as(c), emf_ths(c, :), feats);
endfor


%% Perform informed clustering
[ emi_expec, emi_model ] = cluster(em_clusterer, data, classes, truth_expec);


%% Display confusion matrix
display_confusion("EM (Informed):", emi_expec, truth_expec, false);


%% Components
emi_as  = alpha(emi_model);
emi_ths = theta(emi_model);
emi_k   = length(emi_as);

%% For each one...
for c = 1 : emi_k
  %% Display it
  display_component(sprintf("emi_%d", c), emi_as(c), emi_ths(c, :), feats);
endfor
