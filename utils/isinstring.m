function contains = isinstring(string, string_list)
% ISINSTRING checks any entry in string_list can be found in string.
%
% INPUT:
% string - string to search
% string_list - cell array of strings / chr to search for in string
%
% OUTPUT:
% true if string can be found, false otherwise

if isstring(string_list)
    string_list = {string_list};
elseif ~iscellstr(string_list)
    error('"string_list" must be of type "chr array" or "str".')
end

if iscellstr(string)
    n = length(string);
elseif isstring(string)
    n = 1;
else
    error('"string" must be of type "chr array" or "str".')
end

contains = zeros(1, n);

for search_string = string_list
    find = strfind(string, search_string, 'ForceCellOutput', true);
    for i = 1:n
        if isempty(find{i})
            contains(i) = 0;
        else
            contains(i) = find{i};
        end
    end
    if sum(contains) > 0
        break
    end
end

contains = logical(contains);

end    
