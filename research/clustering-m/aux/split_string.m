% Split a string by whitespace
function list = split_string (string)
    string = deblank(string);
    list   = {};
    while (~isempty(string))
        [ token, string ] = strtok(string);
        list = horzcat(list, { token });
    end
