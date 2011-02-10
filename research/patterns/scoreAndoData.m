%% -*- mode: octave; -*-

%% Minority clustering of data

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus

%% Ando elements
source(binrel("andoElements.m"));


%%%%%%%%%%
%% Main %%
%%%%%%%%%%

%% Get the parameters
args = argv();

%% Full level
full_level = 1;
if length(args) > 1
  switch args{1}
    case "--full"
      full_level = 2;
      args       = { args{2 : length(args)} };
    case "--extra"
      full_level = 3;
      args       = { args{2 : length(args)} };
  endswitch
endif

%% Check parameter length
if ~any(length(args) == [ 7, 8, 9 ])
  error(cstrcat("Wrong number of arguments: Expected", ...
		" <input> <distance> <d-extra> <method> <m-extra>", ...
		" <k> <seed> [<output> [<scores>]]"));
endif

%% Input file
input = args{1};
try
  load(input, "data", "truth");
catch
  error("Cannot load data from '%s': %s", input, lasterr());
end_try_catch

%% Distance
dist = args{2};
if ~isfield(distances, dist)
  error("Wrong distance name '%s'. Must be: %s", dist, fields(distances));
endif

%% Extra arguments
dextra = regex_split(args{3}, '(,|\s+,)\s*');

%% Method
met = args{4};
if ~isfield(methods, met)
  error("Wrong method name '%s'. Must be: %s", met, fields(methods));
endif

%% Extra arguments
mextra = regex_split(args{5}, '(,|\s+,)\s*');

%% Enough args?
req_args = getfield(methods, met, "args");
if length(mextra) ~= req_args
  error("Method '%s' requires %d extra arg(s): %s",
	met, req_args, getfield(methods, met, "help"));
endif

%% k
[ k, status ] = str2double(args{6});
if status ~= 0
  error("Wrong number of clusters '%s'", args{6})
endif

%% Seed
[ seed, status ] = str2double(args{7});
if status ~= 0
  error("Wrong seed '%s'", args{7});
endif

%% Output
if length(args) >= 8
  output = args{8};
  [ fout, status ] = fopen(output, "wt");
  if fout == -1
    error("Cannot open output '%s': %s", output, status);
  endif
else
  fout = 1;
endif


%% Initialize seed
set_all_seeds(seed);

%% Create distance
distfun = getfield(distances, dist);
if isfunctionhandle(distfun)
  distance = distfun(data, dextra);
else
  distance = distfun;
endif

%% Truth information
n_data  = length(truth);
s_truth = truth > 1;

%% Create clusterer
clustfun  = getfield(methods, met, "make");
clusterer = clustfun(distance, data, s_truth, mextra);

%% Cluster
[ total0, user0, system0 ] = cputime();
[ expec, model ] = cluster(clusterer, data, k);
[ total1, user1, system1 ] = cputime();

%% Time difference
cluster_time = total1 - total0;


%% Sort by score
scores = score(model, data);
[ sort_scores, sort_idx ] = sort(scores, "descend");
sort_truth = s_truth(sort_idx);

%% Map scores
[ msort_scores, msort_model ] = apply(LinearInterpolator(), sort_scores);

%% Truth classes
pos_tr  = find( sort_truth); n_pos_tr = length(pos_tr);
neg_tr  = find(~sort_truth); n_neg_tr = length(neg_tr);

%% ROC

%% Find accumulated positive and negative
acc_pos = cumsum( sort_truth);
acc_neg = cumsum(~sort_truth);

%% Find ROC
roc_pos = acc_pos ./ n_pos_tr;
roc_neg = acc_neg ./ n_neg_tr;

%% AUC
auc = sum(diff(roc_neg) .* ...
	  (roc_pos(1 : n_data - 1) + roc_pos(2 : n_data))) / 2;

%% Prc/Rec/F1 curves
prc_c = acc_pos ./ (acc_pos .+ acc_neg);
rec_c = acc_pos ./  acc_pos(n_data);
f1_c  = (2 .* prc_c .* rec_c) ./ (prc_c .+ rec_c);

%% Display
fprintf(fout, "*** %8g %5.3f ***\n", cluster_time, auc);

%% For each threshold
ths = getfield(methods, met, "ths");
for th = ths

  %% Must we do it?
  %% -> Full output or basic threshold
  if full_level >= getfield(th, "level")

    %% Find the threshold
    thfun    = getfield(th, "find");
    th_value = thfun(sort_scores, sort_truth, msort_scores, msort_model, ...
		     f1_c, model);

    %% Negative/positive cluster
    pos_cl = find(sort_scores >= th_value); n_pos_cl = length(pos_cl);
    neg_cl = find(sort_scores <  th_value);

    %% Intersections
    pos_pos = intersect(pos_tr, pos_cl);
    pos_neg = intersect(pos_tr, neg_cl);
    neg_pos = intersect(neg_tr, pos_cl);
    neg_neg = intersect(neg_tr, neg_cl);

    %% Sizes
    n_pos_pos = length(pos_pos);
    n_pos_neg = length(pos_neg);
    n_neg_pos = length(neg_pos);
    n_neg_neg = length(neg_neg);

    %% Precision/Recall
    prc  = n_pos_pos / (n_pos_pos + n_neg_pos);
    rec  = n_pos_pos / (n_pos_pos + n_pos_neg);
    nrec = n_neg_pos / (n_neg_pos + n_neg_neg);
    f1   = 2 * prc * rec / (prc + rec);

    %% Output

    %% Display
    fprintf(fout, "%7s %5d  %5.3f %5.3f %5.3f %5.3f\n", ...
	    getfield(th, "name"), n_pos_cl, prc, rec, nrec, f1);
  endif
endfor

%% Close output
if fout ~= 1
  fclose(fout);
endif

%% Save?
if length(args) >= 9
  try
    save("-binary", "-zip", args{9}, "scores");
  catch
    error("Cannot save data to '%s': %s", args{9}, lasterr());
  end_try_catch
endif
