% Get the best matching unit in a sparse way
function BMUs = som_bmus_sparse(sM, Data)
    % Size
    [ ndocs  nterms  ] = size(Data);
    [ ncells nterms2 ] = size(sM.codebook);
    
    % Different sizes?
    if nterms ~= nterms2
        error "Codebook and Data dimension differ";
    end
    
    % Output
    BMUs = zeros(ndocs, 1);

    % For each data    
    for i = 1 : ndocs
        % Dist
        dist = sum((sM.codebook - ones(ncells,1) * Data(i,:)) .^ 2, 2);
        
        % Minumum
        [ valMin idxMin ] = min(dist);
        BMUs(i) = idxMin;
    end

% end function    