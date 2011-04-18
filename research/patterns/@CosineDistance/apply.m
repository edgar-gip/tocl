%% -*- mode: octave; -*-

%% Cosine Distance
%% Distance

%% Author: Edgar Gonzalez

function [ dists ] = apply(this, source, target)

  %% Check arguments
  if ~any(nargin() == [ 2, 3 ])
    usage("[ dists ] = @CosineDistance/apply(this, source [, target])");
  endif

  %% Call helper functions
  if nargin() == 2
    %% Dot product
    dot         = source' * source;
    self_source = sqrt(diag(dot, 0))';

    %% Convert to cosine, and substract
    dists = 1 - dot ./ (self_source' * self_source);

  else %% nargin() == 3
    %% Dot product
    self_source = sqrt(sum(source .* source, 1));
    self_target = sqrt(sum(target .* target, 1));
    dot         = source' * target;

    %% Convert to cosine, and substract
    dists = 1 - dot ./ (self_source' * self_target);
  endif
endfunction
