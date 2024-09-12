function writeMatrixWithHeader(matrix, headers, outputDir, fileName)
    % Writes a matrix to a CSV file with column headers
    %
    % Parameters:
    %  matrix    - The matrix to be written to the CSV file.
    %  headers   - A cell array of column headers as strings.
    %  outputDir - The directory where the CSV file will be saved.
    %  fileName  - The name of the CSV file to be saved (with extension).
    
    % Check if headers length matches the number of columns in the matrix
    if length(headers) ~= size(matrix, 2)
        error('Number of headers must match the number of columns in the matrix.');
    end
    
    % Full path to the output file
    outputFile = fullfile(outputDir, fileName);
    
    % Open the file for writing
    fileID = fopen(outputFile, 'w');
    
    % Write the header line
    fprintf(fileID, '%s,', headers{1:end-1});
    fprintf(fileID, '%s\n', headers{end});  % Avoid extra comma at the end
    
    % Close the file after writing headers
    fclose(fileID);
    
    % Append the matrix to the file
    writematrix(matrix, outputFile, 'WriteMode', 'append');
    
    % Display confirmation
    fprintf('Matrix with headers written to %s\n', outputFile);
end
