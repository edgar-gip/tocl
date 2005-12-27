% Read a sparse matrix
function matrix = read_sparse (filename)
    % Open file
    fid = fopen(filename, 'rt');
    if (fid == -1)
        error('Can''t open file');
    end
    
    % Read header
    header = fgetl(fid);
    if (header == -1)
        error('Empty file');
    end
    
    % Parse header
    info = sscanf(header, '%u %u %u');
    nRows = info(1);
    nCols = info(2);
    nNz   = info(3);

    % Data
    rows = zeros(nNz, 1);
    cols = zeros(nNz, 1);
    vals = zeros(nNz, 1);
    k    = 1;
    
    % Start reading lists
    curRow = 1;
    line = fgetl(fid);
    while (line ~= -1)
        data = split_string(line);
        while (~isempty(data))
            % Get next cell
            colString = data{1};
            valString = data{2};
            col = sscanf(colString, '%u');
            val = sscanf(valString, '%f');
            
            % Add it to the contents
            rows(k) = curRow;
            cols(k) = col;
            vals(k) = val;
            k       = k + 1;
            
            % Next
            data = data(3:end);
        end
        
        % Next row
        curRow = curRow + 1;
        line = fgetl(fid);    
    end
    
    % Close
    fclose(fid);
    
    % Return the matrix
    matrix = sparse(rows, cols, vals, nRows, nCols, nNz);
    
% end function
