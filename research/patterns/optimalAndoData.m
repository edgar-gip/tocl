%% -*- mode: octave; -*-

%% Optimal minority clustering of data
%% (Using convex hull)

%% Author: Edgar Gonzàlez i Pellicer


%% Octopus
pkg load octopus

%% Get the parameters
args = argv();

%% Check parameter length
if ~any(length(args) == [ 1, 2 ])
  error("Wrong number of arguments: Expected <input> [<output>]");
endif

%% Input file
input = args{1};
try
  load(input, "data", "truth");
catch
  error("Cannot load data from '%s': %s", input, lasterr());
end_try_catch

%% Output
if length(args) >= 2
  output = args{2};
  [ fout, status ] = fopen(output, "wt");
  if fout == -1
    error("Cannot open output '%s': %s", output, status);
  endif
else
  fout = 1;
endif


%% Start timing
[ total0, user0, system0 ] = cputime();

%% Number of samples
n_data = length(data);

%% Number of groups
n_groups = max(truth);

%% Background
background   = data(:, truth == 1);
n_background = length(background);
n_foreground = n_data - n_background;

%% Debug
%% fprintf(2, "There's %d foreground and %d background samples\n", ...
%%         n_foreground, n_background);

%% Inside
inside = zeros(1, n_background);

%% For each other group
for c = 2 : n_groups
  %% Foreground
  foreground = data(:, truth == c);

  %% Inside this
  this_inside = in_convex_hull(foreground, background);

  %% Debug
  %% fprintf(2, ...
  %%         "Group %d contains %d foreground and %d background samples\n", ...
  %%         c, length(foreground), sum(this_inside));

  %% Or the inside
  inside |= this_inside;
endfor

%% How many can be confused
n_inside = sum(inside);
n_pos_cl = n_foreground + n_inside;

%% Debug
%% fprintf(2, "Overall, %d background samples fall in foreground groups\n", ...
%%         n_inside);

%% End timing
[ total1, user1, system1 ] = cputime();

%% Time difference
cluster_time = total1 - total0;

%% Optimal ROC
auc = 1.0 - (n_inside / n_background) / 2;

%% Optimal precision
prc  = n_foreground / n_pos_cl;
rec  = 1.0;
nrec = n_inside / n_background;
f1  = 2 * prc * rec / (prc + rec);

%% Display
fprintf(fout, "*** %8g %5.3f ***\n", cluster_time, auc);

%% Display
fprintf(fout, "%5s %5d  %5.3f %5.3f %5.3f %5.3f\n", ...
	"Best", n_pos_cl, prc, rec, nrec, f1);

%% Close output
if fout ~= 1
  fclose(fout);
endif
