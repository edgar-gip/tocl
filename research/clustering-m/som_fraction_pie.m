% Create the fraction pie
function Contrib = som_fraction_pie(sM, Data, Labels, Present, BMUs)
    % Sizes
    [ nlabels dummy  ] = size(Present);
    [ ncells nterms  ] = size(sM.codebook);
    [ ndocs  nterms2 ] = size(Data);

    % If not found
    if nargin < 5
        BMUs = som_bmus_sparse(sM, Data)
    end
    
    % Contribution
    Contrib = zeros(ncells, nlabels);
    
    % For each
    for i = 1 : ndocs
        idx = find(strcmp(Labels(i), Present));
        Contrib(BMUs(i), idx) = Contrib(BMUs(i), idx) + 1;
    end
    
    % You can plot with
    % som_pieplane(sM, Contrib);

% end function    