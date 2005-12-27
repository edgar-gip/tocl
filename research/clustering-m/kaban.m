% Learn by the method of Ata Kaban
function E = kaban(Data, sqrt_l, sqrt_k, iter)
    % Get the size
    [ terms docs ] = size(Data);
    
    % Real l and k
    l = sqrt_l * sqrt_l;
    k = sqrt_k * sqrt_k;
    
    % Find grids
    [ Xl sigma_l ] = regular_grid(sqrt_l);
    [ Xk sigma_k ] = regular_grid(sqrt_k);
        
    % Phi
    Phi = create_phi(Xl, Xk, sigma_l);
    
    % Starting mapping
    AT = rand(terms, l);
    A  = normalize_cols(AT);
    clear AT;
    
    % Iterate
    for i = 1 : iter
        % Find posterior probabilities
        R = posterior_probabilities(Data, A, Phi);
        
        % Update A
        AN = A .* ( ( (Data * R') ./ (A * Phi) ) * Phi' );
        A  = normalize_cols(AN);
        clear AN;
    end
    
    % Fins last probabilities
    R = posterior_probabilities(Data, A, Phi);
    
    % Find posterior
    E = find_posterior(R, Xk);
    
% end function
