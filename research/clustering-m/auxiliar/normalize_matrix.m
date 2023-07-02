% Normalize a Matrix between -1.0 and 1.0
function Out = normalize_matrix(In)
  %% Find the minimum and maximum value
  small  = min(min(In));
  big    = max(max(In));

  %% Normalize
  Out = -1.0 + 2.0 * (In - small) / (big - small);

% end function
