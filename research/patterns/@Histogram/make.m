%% -*- mode: octave; -*-

%% Histogram
%% Find it

%% Author: Edgar Gonzalez

function [ histo, bin_limits ] = make(this, data, n_bins, min_data, max_data)

  %% Check arguments
  if ~any(nargin() == [ 3, 5 ])
    usage(cstrcat("[ histo, bin_limits ] =", ...
                  " @Histogram/make(this, data, bins [, min_data, max_data])"));
  endif

  %% Size
  n_data = length(data);

  %% Min/max
  if nargin == 3
    min_data = min(data);
    max_data = max(data);
  endif

  %% Empty range?
  if min_data ~= max_data
    %% Bin size
    bin_size = (max_data - min_data) / n_bins;

    %% Bin limits
    bin_limits = min_data + bin_size * (0 : (n_bins - 1));

    %% Bins
    bins = 1 + floor((data - min_data) / bin_size);
    bins(bins == (n_bins + 1)) = n_bins;

    %% Histogram
    histo = full(sum(sparse(bins, 1 : n_data, ones(1, n_data), ...
                            n_bins, n_data), 2));

  else
    %% A single one
    histo      = length(data);
    bin_limits = min_data;
  endif
endfunction
