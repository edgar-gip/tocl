%% Add something to the load path
LOADPATH = [ LOADPATH ":/home/usuaris/egonzalez/devel/research/clusteringSys/octave/combination" ];
LOADPATH = [ LOADPATH ":/home/usuaris/egonzalez/devel/research/clusteringSys/octave/io" ];
LOADPATH = [ LOADPATH ":/home/usuaris/egonzalez/devel/research/clusteringSys/octave/measures" ];

%% Check arguments
[ length dummy ] = size(argv);
if mod(length, 2) ~= 0
  error('The number of arguments should be pair');
end

%% Output
output = {};

%% For every element
for i = 1:2:length
  %% Weight
  output{i}   = str2num(argv{i});

  %% Name
  output{i+1} = argv{i+1};
end

%% Call the combination
[ Lls Sizes Models ] = comb_combine_mem_weighted(0, output{:});

%% Data plot
fprintf(stderr, "%d %g\n", [ Sizes Lls ]');

%% Keep the max
[ val idx ] = max(Lls);
%% [ val idx ] = comb_local_max(Lls);
fprintf(stderr, "Best: %d %g\n", Sizes(idx), Lls(idx));
printf("%d\n", Models{idx});

%% Bye Bye


