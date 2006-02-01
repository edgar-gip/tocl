% Learn by the method of Ata Kaban
function [ Exp Resp Xk ] = kaban(Data, sqrt_l, sqrt_k, iter)
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
    A  = starting_mapping(Data, l);

    % Iterate
    for i = 1 : iter
        % Find posterior probabilities
        R = posterior_probabilities(Data, A, Phi);

	% Plot posterior
	E = R' * Xk;
        plot(Xk(:,1), Xk(:,2), '@*1', E(:,1), E(:,2), '@+2');

        % Update A
        AN = A .* ( ( (Data * R') ./ (A * Phi) ) * Phi' );
        A  = normalize_cols(AN);
        clear AN;
    end

    % Find last probabilities
    Resp = posterior_probabilities(Data, A, Phi);

    % Plot posterior
    Exp  = find_posterior(Resp, Xk);
    plot(Xk(:,1), Xk(:,2), '@*1', Exp(:,1), Exp(:,2), '@+2');

% end function
