%% Read the calinskis files for combi
function M = read_cals_combi (file)
  %% Open the file
  [f, msg] = fopen(file, "rt");
  if f == -1
    error(msg);
  end

  %% Output
  M = [];

  %% Read one line at a time
  line = fgetl(f);
  while line ~= -1
    %% Strip path
    idx = index(line, "/");
    if idx ~= 0
      line = substr(line, idx + 1);
    end

    %% Parse
    [ a b c cal ] = sscanf(line, "combi.em.%d.%d.%d %f %f %f", "C");

    %% Add to the output
    M = [ M ; a b c cal ];

    %% Read next line
    line = fgetl(f);
  end

  %% Close
  fclose(f);

% end function
