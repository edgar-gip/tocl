% Create the Phi matrix
function Phi = create_phi(Xl, Xk, sigma)
    % Dimensions
    [ dl dl2 ] = size(Xl);
    [ dk dk2 ] = size(Xk);
    
    % Starting with a zero distribution
    PhiT = zeros(dl, dk);
    
    % Coefficient
    coef = - 0.5 / ( sigma * sigma );
    
    % Fill it
    for il = 1 : dl
        for ik = 1 : dk
          PhiT(il, ik) = exp(coef * norm_sq(Xl(il,:) - Xk(ik,:)));
        end
    end
    
    Phi = normalize_cols(PhiT);
    
% end function
