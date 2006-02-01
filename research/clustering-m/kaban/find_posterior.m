% Find the posterior coordinate
function E = find_posterior(R, Xk)
    E = R' * Xk;
