% Get options in a Getopt::Long style

% Author: Edgar Gonzalez

function [ args, opts ] = get_options(varargin)

  % Length
  n_argin = size(varargin, 2);
  if n_argin == 0
    usage("Option list cannot be empty");
  end

  % Is first a struct?option?
  if isstruct(varargin{1})
    opts     = varargin{1};
    varargin = celltail(varargin);
    --n_argin;
  else
    opts     = struct();
  end

  % Is the number of arguments pair?
  if mod(n_argin, 2) ~= 0
    usage("Number of arguments must be pair");
  end

  % Functions hash
  sw_funcs = struct();

  % Parse each option
  for i = 1:2:n_argin
    % String and target
    arg_str = varargin{i};
    arg_tgt = varargin{i + 1};

    % Parse the string
    if (( [ match ] = regex_match(arg_str, '(\w(?:[\w\-]*\w)?)') ))
      % Convert - to _
      arg_str = strrep(arg_str, '-', '_');

      % Simple option
      sw_funcs = setfield(sw_funcs, arg_str, ...
			  @(o, args) { setfield(o, arg_tgt, true()), args });

    elseif (( [ match, sw ] = regex_match(arg_str, '(\w(?:[\w\-]*\w)?)!') ))
      % Convert - to _
      sw = strrep(sw, '-', '_');

      % Negable option
      sw_funcs = setfield(sw_funcs, sw, ...
			   @(o, as) { setfield(o, arg_tgt, true()), as });
      sw_funcs = setfield(sw_funcs, strcat('no', sw), ...
			   @(o, as) { setfield(o, arg_tgt, false()), as });
      sw_funcs = setfield(sw_funcs, strcat('no_', sw), ...
			   @(o, as) { setfield(o, arg_tgt, false()), as });

    elseif (( [ match, sw ] = regex_match(arg_str, '(\w(?:[\w\-]*\w)?)~') ))
      % Convert - to _
      sw = strrep(sw, '-', '_');

      % Nullable option
      sw_funcs = setfield(sw_funcs, sw, ...
			   @(o, as) { setfield(o, arg_tgt, false()), as });
      
    elseif (( [ match, sw ] = regex_match(arg_str, '(\w(?:[\w\-]*\w)?)-') ))
      % Convert - to _
      sw = strrep(sw, '-', '_');

      % Negated option
      sw_funcs = setfield(sw_funcs, sw, ...
			   @(o, as) { setfield(o, arg_tgt, -1), as });

    elseif (( [ match, sw ] = regex_match(arg_str, '(\w(?:[\w\-]*\w)?)=s') ))
      % Convert - to _
      sw = strrep(sw, '-', '_');

      % String-Valued option
      sw_funcs = setfield(sw_funcs, sw, ...
			   @(o, as) { setfield(o, arg_tgt, as{1}), ...
				      celltail(as) });

    elseif (( [ match, sw ] = ...
	      regex_match(arg_str, '(\w(?:[\w\-]*\w)?)=f)') ))
      % Convert - to _
      sw = strrep(sw, '-', '_');

      % Double-Valued option
      sw_funcs = setfield(sw_funcs, sw, ...
			   @(o, as) { setfield(o, arg_tgt, ...
					       str2double(as{1})), ...
				      celltail(as) });

    elseif (( [ match, sw ] = ...
	      regex_match(arg_str, '(\w(?:[\w\-]*\w)?)=i)') ))
      % Convert - to _
      sw = strrep(sw, '-', '_');

      % Integer-Valued option
      sw_funcs = setfield(sw_funcs, sw, ...
			   @(o, as) { setfield(o, arg_tgt, ...
					       fix(str2double(as{1}))), ...
				      celltail(as) });

    elseif (( [ match, sw, value ] = ...
	     regex_match(arg_str, '(\w(?:[\w\-]*\w)?)=r(\d+)') ))
      % Convert - to _
      sw = strrep(sw, '-', '_');

      % Radio-Valued option
      sw_funcs = setfield(sw_funcs, sw, ...
			  @(o, as) { setfield(o, arg_tgt, value), as });
    else
      % Error!
      usage(sprintf("Wrong option specification %s", arg_str));

    end
  end

  % Output options and arguments
  args = {};

  % Now, get the arguments
  inargs = argv();

  % While some remain
  while ~isempty(inargs)
    % Get the first
    inarg  = inargs{1};
    inargs = celltail(inargs);

    % What comes next?
    if strcmp(inarg, '--')
      % Skip the rest
      args   = cellcat(args, inargs);
      inargs = {};

    elseif (( [ match, sw ] = regex_match(inarg, '--(\w(?:[\w\-]*\w)?)') ))
      % Convert - to _
      sw = strrep(sw, '-', '_');

      % Look for it
      if isfield(sw_funcs, sw)
	% Apply it
	res    = getfield(sw_funcs, sw)(opts, inargs);
	opts   = res{1};
	inargs = res{2};
      else
	% Error
	error(sprintf("Wrong option %s", inarg));
      end

    else
      % Add it
      args = cellpush(args, inarg);
    end
  end

% Local Variables:
% mode:octave
% End:
