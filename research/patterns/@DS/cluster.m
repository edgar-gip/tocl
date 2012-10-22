%% -*- mode: octave; -*-

%% Density Shaving
%% Clustering function

%% Author: Edgar Gonzalez

function [ expec, model, info ] = cluster(this, data, k, expec_0)

  %% Check arguments
  if ~any(nargin() == [ 2, 3, 4 ])
    usage(cstrcat("[ expec, model, info ] = ",
		  "@DS/cluster(this, data [, k [, expec_0]]])"));
  endif

  %% Warn that k is ignored
  if nargin() >= 3 && ~isempty(k)
    usage("k is ignored");
  endif

  %% Warn that expec_0 is ignored
  if nargin() == 4 && ~isempty(expec_0)
    warning("expec_0 is ignored");
  endif

  %% Get temporary prefix
  tmp_prefix = tmpnam();
  try
    %% Dump divergence matrix to a temporary file
    div_file = cstrcat(tmp_prefix, ".txt");
    divs = apply(this.divergence, data);
    save("-ascii", div_file, "divs");
    if this.verbose
      fprintf(2, "Generated divergence matrix file %s\n", div_file);
    endif

    %% Clustering file
    cls_file = cstrcat(tmp_prefix, ".cls");

    %% Command line for Gene Diver
    cmd = sprintf(cstrcat("'%s' --ds --matrix --n-eps=%d --f-shave=%g", ...
			  " --r-shave=%g --verbose '%s' '%s'"), ...
		  this.wrap_path, this.n_eps, this.f_shave, this.f_shave, ...
		  div_file, cls_file);
    if this.verbose
      fprintf(2, "Running %s\n", cmd);
    else
      cmd = cstrcat(cmd, " >& /dev/null");
    endif

    %% Call subprocess
    status = system(cmd);
    if status ~= 0
      error("Cannot run gene-diver");
    endif

    %% Load clustering file
    indices = load("-ascii", cls_file);

    %% Remove temporaries
    unlink(cls_file);
    unlink(div_file);

    %% Expectation
    n_samples = length(indices);
    k = max(indices);
    on = find(indices);
    n_on = length(on);
    expec = sparse(indices(on), on, ones(1, n_on), k, n_samples);

    %% Model and info
    model = [];
    info = struct();

  catch
    %% Remove temporaries and rethrow
    unlink(cls_file);
    unlink(div_file);
    rethrow(lasterror());
  end_try_catch
endfunction
