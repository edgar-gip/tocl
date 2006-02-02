% Read a sparse matrix (in matlab)
function matrix = read_sparse_matlab (filename, normalization)
    % Read data using a C function
    M = cread_sparse_matlab(filename);
    
    % Normalize
    if nargin == 1 || strcmp(normalization, 'no')
        matrix = M;
        
    % Sum
    elseif strcmp(normalization, 'sum')
        matrix = M * diag(sum(M) .^ -1);

    % Euclid        
    elseif strcmp(normalization, 'euclid')
        matrix = M * diag(sqrt(sum(M .^ 2) .^ -1));
        
    % Tfidf
    elseif strcmp(normalization, 'tfidf')
        % Size
        [ nterms ndocs ] = size(M);
        
        % Idf normalization
        idf = log(ndocs) - log(sum((M > 0)'));
        I = spdiags(idf', 0, nterms, nterms);
        M = I * M;
        
        % Then euclid
        matrix = M * diag(sqrt(sum(M .^ 2) .^ -1));

    % Other
    else
        error('Wrong normalization mode')
    end
    
% end function