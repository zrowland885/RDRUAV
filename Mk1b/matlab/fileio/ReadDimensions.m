function [dimensions] = ReadDimensions(filepath,filename,format)
%READDIMENSIONS Reads tab delimininated data from files as given format
% Reads from SW equations files or input variable textfiles as a cell
% matrix, then converts this to a given data format to be returned.

% Read the equations file
fileID = fopen(fullfile(filepath,filename),'r','native','UTF-8');
if fileID < 0
    error('Cannot open file for reading: %s', filename);
end
dimensions_cell = textscan(fileID,'%s %s','Delimiter','\t','CommentStyle','%');
fclose(fileID);

if strcmpi('cell',format)
    % Leave as yx2 cell
    dimensions = [dimensions_cell{1} dimensions_cell{2}];
elseif strcmpi('table',format)
    % Convert to table
    dimensions = cell2table([dimensions_cell{1} dimensions_cell{2}],...
        'VariableNames',{'Dimension' 'Value'});
elseif strcmpi('struct',format)
    % Convert to Struct
    rowHeadings = {'Dimension','Value'};
    dimensions = cell2struct(dimensions_cell,rowHeadings,2);
elseif strcmpi('map',format)
    % Convert to Map
    dimensionSet = dimensions_cell{1};
    valueSet = str2double(dimensions_cell{2});
    dimensions = containers.Map(dimensionSet,valueSet);
elseif strcmpi('itermap',format)
    % Convert to Map (inlude increment and final value)
    dimensionSet = dimensions_cell{1};
    valueSet = dimensions_cell{2};
    for i = 1:length(valueSet)
        value = strsplit(valueSet{i},':');
        valueSet{i} = {str2double(value(1)), str2double(value(2)), str2double(value(3))};
    end
    dimensions = containers.Map(dimensionSet,valueSet);
elseif strcmpi('resultmap',format)
    % Convert to Map up to 'INPUTVARS' string, then 
    dimensionSet = dimensions_cell{1};
    valueSet = str2double(dimensions_cell{2});
    cutoff = find(strcmp(dimensionSet,'INPUTVARS'));
    dimensions.results = containers.Map(dimensionSet(1:cutoff-1),valueSet(1:cutoff-1));
    dimensions.iVar = containers.Map(dimensionSet(cutoff:length(dimensionSet)),valueSet(cutoff:length(valueSet)));
else
    error('Give a format for the returned data: cell, table, struct or map.');
end