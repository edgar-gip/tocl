%% -*- mode: octave; -*-

%% Density Shaving
%% From:
%%   Gunjan Gupta, Alexander Liu, Joydeep Gosh
%%   "Automated Hierarchical Density Shaving: A Robust Automated Clustering
%%    and Visualization Framework for Large Biological Data Sets"
%%   IEEE Transactions on Computational Biology and Bioinformatics, 7(2)
%%   April-June 2010

%% Constructor

%% Author: Edgar Gonzalez

function [ this ] = DS(divergence, opts = struct())

  %% Check arguments
  if ~any(nargin() == [ 1, 2 ])
    usage("[ this ] = DS(divergence [, opts])");
  endif

  %% This object
  this = struct();

  %% Divergence
  this.divergence = divergence;

  %% Sphere size
  %% Default -> 5
  this.n_eps = getfielddef(opts, "n_eps", 5);

  %% Shaved fraction
  %% Default -> 0.01
  this.f_shave = getfielddef(opts, "f_shave", 0.01);

  %% Verbose
  %% Default -> false
  this.verbose = getfielddef(opts, "verbose", false());

  %% Wrap path
  this.wrap_path = getfielddef(opts, "wrap_path", []);
  if isempty(this.wrap_path)
    [ dir, name, ext, ver ] = fileparts(mfilename("fullpathext"));
    this.wrap_path = fullfile(dir, "gene-diver");
    if this.verbose
      fprintf(2, "Using wrapper script %s\n", this.wrap_path);
    endif
  endif

  %% Bless
  %% And add inheritance
  this = class(this, "DS", ...
               Simple());
endfunction
