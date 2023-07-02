% Create a regular grid of n x n
function [ Grid, sigma ] = regular_grid(n)
    % Empty grid
    Grid = zeros(n * n, 2);

    % Increase
    incr = 2.0 / (n - 1);

    % Fill the grid
    i = 1;
    for x = -1:incr:1
        for y = -1:incr:1
            Grid(i, 1) = x;
            Grid(i, 2) = y;
            i = i + 1;
        end
    end

    % Sigma
    sigma = 2.0 * incr;

%end function
