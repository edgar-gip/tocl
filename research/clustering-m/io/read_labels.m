% Read the document labels
function [ Labels Present ] = read_labels(rlabel_file, doc2cat_file)
  %% Check arguments
  if (nargin < 2)
    error('read_labels requires two arguments');
  end

  %% Read labels using a C function
  [ LM PM ] = cread_labels(rlabel_file, doc2cat_file);

  %% Convert to cell arrays
  Labels  = cellstr(LM);
  Present = cellstr(PM);

% end function
