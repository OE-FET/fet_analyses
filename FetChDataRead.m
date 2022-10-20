function data = FetChDataRead(filePath)

    % Finds the name of the file from the path
    [~, name, ~] = fileparts(filePath);

    % Opens the file for reading, extracts the first line (the attributes line)
    file  = fopen(filePath, 'r');
    line  = fgetl(file);
    attrs = jsondecode(line(15:end));

    % Closes the file
    fclose(file);

    % Re-opens the file and reads all its CSV contents into a matrix
    raw = csvread(filePath, 2, 0);

    % We need to process the data slightly different for transfer vs output curves
    if (strcmp(attrs.Type, 'Transfer'))
        data = parseTransfer(raw);
        data.type = 'transfer';
    else
        data = parseOutput(raw);
        data.type = 'output';
    end

    % Add all the other parameters to the output structure
    data.path       = filePath;
    data.attributes = attrs;
    data.title      = name;
    data.DataMatrix = raw;
    return;

end

function data = parseOutput(raw)

    % Find all the unique source-gate voltages applied
    gates = sortAbs(unique(raw(:,2)));

    % Initialise matrices
    dI = [];
    gI = [];
    sI = [];

    % Loop over all source-gate voltage values
    for i = 1:numel(gates)

        % Find all rows which correspond to this source-gate voltage
        rows    = raw(raw(:,2) == gates(i), :);
        dI(:,i) = rows(:, 4); % Drain currents are in column 4
        gI(:,i) = rows(:, 6); % Gate currents are in column 6

        % If the source/ground current is not measured, calculate it
        if (isnan(rows(:, 10)))
            sI(:, i) = dI(:, i) + gI(:, i);
        else
            sI(:, i) = rows(:, 10); % Source currents are in column 10
        end

        % Set the x-axis data as being the source-drain voltage
        data.x = rows(:,1);

    end

    % Put all the matrices into a single structure to return
    data.Is    = sI;
    data.Id    = dI;
    data.Ig    = gI;
    data.Vstep = gates;
    return;

end

function data = parseTransfer(raw)

    % Find all unique values of source-drain voltage used (sorted by abs value)
    drains = sortAbs(unique(raw(:,1)));

    % Initialise matrices
    dI = [];
    gI = [];
    sI = [];

    % Loop over each source-drain voltage
    for i = 1:numel(drains)

        % Find all rows with this source-drain voltage
        rows    = raw(raw(:,1) == drains(i), :);
        dI(:,i) = rows(:, 4); % Drain currents are in column 4
        gI(:,i) = rows(:, 6); % Gate currents are in column 6

        % If the source/ground current wasn't measured, calculate it
        if (isnan(rows(:, 10)))
            sI(:, i) = dI(:, i) + gI(:, i);
        else
            sI(:, i) = rows(:, 10); % Source currents are in column 10
        end

        % Set the x-axis data as source-gate voltage
        data.x = rows(:,2);

    end

    % Put all the matrices into a single structure to return
    data.Is    = sI;
    data.Id    = dI;
    data.Ig    = gI;
    data.Vstep = drains;
    return;

end

function sorted = sortAbs(values)
    [~, indices] = sort(abs(values));
    sorted       = values(indices);
    return;
end
