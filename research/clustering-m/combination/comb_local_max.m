%% Find the first local maximum
function [ max idx ] = comb_local_max (vector)
  %% Length
  l = length(vector);

  %% Keep the max
  for i = 2:l-1
    %% Edge    
    if vector(i) > vector(i - 1) && ...
	  vector(i) > vector(i + 1)
      max = vector(i);
      idx = i;
      return;

    %% Plateau
    elseif vector(i) > vector(i - 1) && ...
	  vector(i) == vector(i + 1)
      %% Find the end of the plateau
      j = i + 1;
      while j < l && vector(j + 1) == vector(i)
	j = j + 1;
      end
      
      %% End of the end?
      if j == l
	%% Give an extreme
	if vector(1) > vector(i)
	  max = vector(1);
	  idx = 1;
	else
	  max = vector(i);
	  idx = i;
	end
	return;

      elseif vector(j + 1) < vector(i)
	%% A raised plateau
	max = vector(i);
	idx = i;
      end
    end
  end

  %% Give an extreme
  if vector(1) > vector(l)
    max = vector(1);
    idx = 1;
  else
    max = vector(l);
    idx = l;
  end

% end function