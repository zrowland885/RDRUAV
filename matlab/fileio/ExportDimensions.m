function [] = ExportDimensions(filepath,filename,export_map)
%EXPORTDIMENSIONS Exports dimension map into global variables within Solidworks equation file.

fprintf('\n-------------------------------------------------------\n');
fprintf('Exporting to: %s\n\n', filename);

% Read in the old file as a table
dimensions_table = ReadDimensions(filepath,filename,'table');

% Update the old values (if changed)
k = keys(export_map);
val = values(export_map);

for i = 1:height(dimensions_table)                                          % Check all lines in the equation file
    for j = 1:length(export_map)                                            % ...Against all values in the map
        if strcmpi(k{j},dimensions_table{i,'Dimension'})                    % If the map key is in the file:
            if strcmpi(num2str(val{j}),dimensions_table{i,'Value'})                     % - Check if it is already that value,
                %fprintf('Present:\t%s\n', k{j})                             % - Report back
            else                                                                % If it isn't already there:
                dimensions_table{i,'Value'} = {val{j}};                         % - Update the value,
                fprintf('Updated:\t%s\n', k{j})                               % - Report back
            end
        end
    end
end

% Overwrites the old textfile data
writetable(dimensions_table,fullfile(filepath,filename),'Delimiter',...
    '\t','WriteVariableNames',0);

end

