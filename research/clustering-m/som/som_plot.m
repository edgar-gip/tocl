% Plot a SOM
function som_plot(Mapping, Labels, Different, dim)
  %% Size
  [ nlabels dummy ] = size(Different);
  [ ndocs   dummy ] = size(Mapping);

  %% Add some blur
  if nargin < 4 || dim == 0
    blur    = 0
  else
    blur    = 1.0 / (dim - 1);
    Mapping = Mapping + blur * rand(ndocs, dummy) - blur / 2.0;
  end

  %% Output line
  line = {};
  lidx = 1;
  
  %% For each label
  for l = 1 : nlabels
    %% Find the labels that are equal
    i   = 1;
    Idx = zeros(1, ndocs);

    %% For each document
    for d = 1 : ndocs
      if strcmp(Labels{d}, Different{l})
	Idx(i) = d;
	i = i + 1;
      end
    end

    %% Now plot
    line{lidx}   = Mapping(Idx(1:(i-1)),1);
    line{lidx+1} = Mapping(Idx(1:(i-1)),2);
    line{lidx+2} = sprintf("@%d;%s;", mod(l,6)+1, Different{l});
    lidx         = lidx + 3;
  end

  %% Plot everything
  axis([-1.1 - blur, 1.1 + blur, -1.1 - blur, 1.1 + blur]);
  gset key below;
  clg();
  plot(line{:});
  pause();

  %% Plot one by one
  for i = 1 : 3 : (lidx - 3)
    clg();
    plot(line{i:i+2});
    pause();
  end

% end function

