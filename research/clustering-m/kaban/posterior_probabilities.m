% Find the posterior probabilities
function R = posterior_probabilities(Data, A, Phi)
    RT = exp(log(A * Phi)' * Data);
    R  = normalize_cols(RT);
