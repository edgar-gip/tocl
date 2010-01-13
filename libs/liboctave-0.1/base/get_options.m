%% Copyright (C) 2010 Edgar Gonzàlez i Pellicer <edgar.gip@gmail.com>
%%
%% This file is part of liboctave-0.1.
%%
%% liboctave is free software; you can redistribute it and/or modify it
%% under the terms of the GNU General Public License as published by the
%% Free Software Foundation; either version 3 of the License, or (at your
%% option) any later version.
%%
%% liboctave is distributed in the hope that it will be useful, but WITHOUT
%% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
%% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
%% for more details.
%% 
%% You should have received a copy of the GNU General Public License
%% along with liboctave; see the file COPYING.  If not, see
%% <http://www.gnu.org/licenses/>.

%% Get options in a Getopt::Long style

function [ args, opts ] = get_options(varargin)

  %% Length
  n_argin = length(varargin);
  if n_argin == 0
    usage("Option list cannot be empty");
  endif

  %% Is first a struct?option?
  if isstruct(varargin{1})
    opts     = varargin{1};
    varargin = cell_tail(varargin);
    --n_argin;
  else
    opts     = struct();
  endif

  %% Is the number of arguments pair?
  if mod(n_argin, 2) ~= 0
    usage("Number of arguments must be pair");
  endif

  %% Functions hash
  sw_funcs = struct();

  %% Parse each option
  for i = 1:2:n_argin
    %% String and target
    arg_str = varargin{i};
    arg_tgt = varargin{i + 1};

    %% Check the arguments
    if ~ischar(arg_str)
      usage("Option specifiers must be strings");
    elseif ~ischar(arg_tgt) && ~isfunctionhandle(arg_tgt)
      usage("Option targets must be strings or function handles");
    endif

    %% Parse the string
    if regex_match(arg_str, '[a-zA-Z](?:[\w\-]*\w)?')
      %% Convert - to _
      arg_str = strrep(arg_str, '-', '_');

      %% Simple option
      if isfunctionhandle(arg_tgt)
	%% With a function handle
	sw_funcs = setfield(sw_funcs, arg_str, ...
			    @(o, args) { arg_tgt(o, true()), args });
      else % ischar(arg_tgt)
	%% With a string
	sw_funcs = setfield(sw_funcs, arg_str, ...
			    @(o, args) { setfield(o, arg_tgt, true()), args });
      endif

    elseif (([ match, sw ] = ...
	     regex_match(arg_str, '([a-zA-Z](?:[\w\-]*\w)?)!')))
      %% Convert - to _
      sw = strrep(sw, '-', '_');

      %% Negable option
      if isfunctionhandle(arg_tgt)
	%% With a function handle
	sw_funcs = setfield(sw_funcs, sw, ...
			    @(o, as) { arg_tgt(o, true()), as });
	sw_funcs = setfield(sw_funcs, strcat('no', sw), ...
			    @(o, as) { arg_tgt(o, false()), as });
	sw_funcs = setfield(sw_funcs, strcat('no_', sw), ...
			    @(o, as) { arg_tgt(o, false()), as });
      else % ischar(arg_tgt)
	%% With a string
	sw_funcs = setfield(sw_funcs, sw, ...
			    @(o, as) { setfield(o, arg_tgt, true()), as });
	sw_funcs = setfield(sw_funcs, strcat('no', sw), ...
			    @(o, as) { setfield(o, arg_tgt, false()), as });
	sw_funcs = setfield(sw_funcs, strcat('no_', sw), ...
			    @(o, as) { setfield(o, arg_tgt, false()), as });
      endif

    elseif (([ match, sw ] = ...
	     regex_match(arg_str, '([a-zA-Z](?:[\w\-]*\w)?)~')))
      %% Convert - to _
      sw = strrep(sw, '-', '_');

      %% Nullable option
      if isfunctionhandle(arg_tgt)
	%% With a function handle
	sw_funcs = setfield(sw_funcs, sw, ...
			    @(o, as) { arg_tgt(o, false()), as });

      else % ischar(arg_tgt)
	%% With a string
	sw_funcs = setfield(sw_funcs, sw, ...
			    @(o, as) { setfield(o, arg_tgt, false()), as });
      endif
      
    elseif (([ match, sw ] = ...
	     regex_match(arg_str, '([a-zA-Z](?:[\w\-]*\w)?)-')))
      %% Convert - to _
      sw = strrep(sw, '-', '_');

      %% Negated option
      if isfunctionhandle(arg_tgt)
	%% With a function handle
	sw_funcs = setfield(sw_funcs, sw, ...
			    @(o, as) { arg_tgt(o, -1), as });

      else % ischar(arg_tgt)
	%% With a string
	sw_funcs = setfield(sw_funcs, sw, ...
			    @(o, as) { setfield(o, arg_tgt, -1), as });
      endif

    elseif (([ match, sw ] = ...
	     regex_match(arg_str, '([a-zA-Z](?:[\w\-]*\w)?)=s')))
      %% Convert - to _
      sw = strrep(sw, '-', '_');

      %% String-Valued option
      if isfunctionhandle(arg_tgt)
	%% With a function handle
	sw_funcs = setfield(sw_funcs, sw, ...
			    @(o, as) { arg_tgt(o, as{1}), ...
				       cell_tail(as) });

      else % ischar(arg_tgt)
	%% With a string
	sw_funcs = setfield(sw_funcs, sw, ...
			    @(o, as) { setfield(o, arg_tgt, as{1}), ...
				       cell_tail(as) });
      endif

    elseif (([ match, sw ] = ...
	     regex_match(arg_str, '([a-zA-Z](?:[\w\-]*\w)?)=f')))
      %% Convert - to _
      sw = strrep(sw, '-', '_');

      %% Double-Valued option
      if isfunctionhandle(arg_tgt)
	%% With a function handle
	sw_funcs = setfield(sw_funcs, sw, ...
			    @(o, as) { arg_tgt(o, str2double(as{1})), ...
				       cell_tail(as) });
      else % ischar(arg_tgt)
	%% With a string
	sw_funcs = setfield(sw_funcs, sw, ...
			    @(o, as) { setfield(o, arg_tgt, ...
						str2double(as{1})), ...
				      cell_tail(as) });
      endif

    elseif (([ match, sw ] = ...
	     regex_match(arg_str, '([a-zA-Z](?:[\w\-]*\w)?)=i')))
      %% Convert - to _
      sw = strrep(sw, '-', '_');

      %% Integer-Valued option
      if isfunctionhandle(arg_tgt)
	%% With a function handle
	sw_funcs = setfield(sw_funcs, sw, ...
			    @(o, as) { arg_tgt(o, fix(str2double(as{1}))), ...
				       cell_tail(as) });
      else % ischar(arg_tgt)
	%% With a string
	sw_funcs = setfield(sw_funcs, sw, ...
			    @(o, as) { setfield(o, arg_tgt, ...
						fix(str2double(as{1}))), ...
				      cell_tail(as) });
      endif

    elseif (([ match, sw, value ] = ...
	     regex_match(arg_str, '([a-zA-Z](?:[\w\-]*\w)?)=r(\d+)')))
      %% Convert - to _
      sw = strrep(sw, '-', '_');

      %% Convert value to an integer
      value = fix(str2double(value));

      %% Radio-Valued option
      if isfunctionhandle(arg_tgt)
	%% With a function handle
	sw_funcs = setfield(sw_funcs, sw, ...
			    @(o, as) { arg_tgt(o, value), ...
				       cell_tail(as) });
      else % ischar(arg_tgt)
	%% With a string
	sw_funcs = setfield(sw_funcs, sw, ...
			    @(o, as) { setfield(o, arg_tgt, value), as });
      endif

    else
      %% Error!
      usage("Wrong option specification %s", arg_str);
    endif
  endfor

  %% Output options and arguments
  args = {};

  %% Now, get the arguments
  inargs = argv();

  %% While some remain
  while ~isempty(inargs)
    %% Get the first
    inarg  = inargs{1};
    inargs = cell_tail(inargs);

    %% What comes next?
    if strcmp(inarg, '--')
      %% Skip the rest
      args   = cell_cat(args, inargs);
      inargs = {};

    elseif (([ match, sw ] = ...
	     regex_match(inarg, '--([a-zA-Z](?:[\w\-]*\w)?)')))
      %% Convert - to _
      sw = strrep(sw, '-', '_');

      %% Look for it
      if isfield(sw_funcs, sw)
	%% Apply it
	res    = getfield(sw_funcs, sw)(opts, inargs);
	opts   = res{1};
	inargs = res{2};
      else
	%% Error
	error("Wrong option %s", inarg);
      endif

    else
      %% Add it
      args = cell_push(args, inarg);
    endif
  endwhile
endfunction

%% Local Variables:
%% mode:octave
%% End:
