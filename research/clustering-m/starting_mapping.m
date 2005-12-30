% Starting mapping
function A = starting_mapping (Data, l)
    % Size of Data
    [ terms docs ] = size(Data);

    % Random
    % A = normalize_cols(rand(terms, l));

    % At the beginning, empty
    A = zeros(terms, l);

    % Choose a document for each dimension
    for cl = 1:l
        doc = floor(1.0 + rand(1) * docs);
        A(:,cl) = A(:,cl) + Data(:,doc);
    end

    % Check there is at least a dimension for each term
    for t = 1:terms
        if (~any(A(t,:)))
            tl = floor(1.0 + rand(1) * l);
            A(t,tl) = 1.0;
        end
    end


    % Normalize
    A = normalize_cols(A);

% end function
