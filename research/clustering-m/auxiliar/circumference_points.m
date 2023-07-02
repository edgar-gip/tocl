% Find the points in a circle
function [ X Y ] = circumference_points(xc, yc, r)
  %% Empty lists
  X = zeros(8 * r, 1);
  Y = zeros(8 * r, 1);

  %% Start
  dx = 0;
  dy = r;

  %% Add the 8 points
  X(1:8) = [ +dx, -dx, +dx, -dx, +dy, -dy, +dy, -dy ];
  Y(1:8) = [ +dy, +dy, -dy, -dy, +dx, +dx, -dx, -dx ];

  %% Position
  i = 9;

  %% P
  p = 1 - r;

  %% Until they cross
  while dx < dy
    %% Find new point
    if p < 0
      dx = dx + 1;
      p  = p + 2 * dx + 1;
    else
      dx = dx + 1;
      dy = dy - 1;
      p  = p + 2 * (dx - dy) + 1;
    end

    %% Add
    X(i:(i + 7)) = [ +dx, -dx, +dx, -dx, +dy, -dy, +dy, -dy ];
    Y(i:(i + 7)) = [ +dy, +dy, -dy, -dy, +dx, +dx, -dx, -dx ];
    i = i + 8;
  end

  %% Truncate
  X = X(1:(i-1));
  Y = Y(1:(i-1));

  %% Shift
  X = X + xc;
  Y = Y + yc;

% end function
