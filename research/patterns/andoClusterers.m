%% -*- mode: octave; -*-

%% Elements (Extra)

%% Author: Edgar Gonz�lez i Pellicer


%%%%%%%%%%%%%%%%
%% Clusterers %%
%%%%%%%%%%%%%%%%

%% Objects
clusterer_kmeans = ...
    struct("args", 2, ...
	   "help", "<max_iterations>, <change_threshold>", ...
	   "make", @(dist, extra) ...
	   KMeans(dist, struct("max_iterations",   str2double(extra{1}), ...
			       "change_threshold", str2double(extra{2}))));

clusterer_rproj = ...
    struct("args", 1, ...
	   "help", "<soft_alpha>", ...
	   "make", @(dist, extra) ...
	   RandomProj(struct("soft_alpha", str2double(extra{1}))));

clusterer_rand = ...
    struct("args", 1, ...
	   "help", "<concentration>", ...
	   "make", @(dist, extra) ...
	   Random(struct("concentration", str2double(extra{1}))));

clusterer_voro = ...
    struct("args", 1, ...
	   "help", "<soft_alpha>", ...
	   "make", @(dist, extra) ...
	   Voronoi(dist, struct("soft_alpha", str2double(extra{1}))));

%% Index
clusterers = ...
    struct("kmeans", clusterer_kmeans, ...
	   "rand",   clusterer_rand, ...
	   "rproj",  clusterer_rproj, ...
	   "voro",   clusterer_voro);