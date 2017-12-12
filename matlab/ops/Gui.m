function [iVar] = Gui()
%GUI

% Load input variables
iVar = ReadDimensions('','input_variables.txt','map');
kV = keys(iVar);
vV = values(iVar);

% Load iteration values
iIter = ReadDimensions('','input_iteration.txt','itermap');
kI = keys(iIter);
vI = values(iIter);

InitialVal      = cell(length(vI),1);
IncrementVal	= cell(length(vI),1);
FinalVal        = cell(length(vI),1);

for i=1:length(vI)
    items = vI{i};
    InitialVal{i}	= items{1};
    IncrementVal{i} = items{2};
    FinalVal{i}     = items{3};
end

% UI and table setup
f = uifigure('Position', [100 100 750 900]);
t = uitable('Parent',f);

%% Manage the table
% Setup
t.Position = [25 100 700 700];
% Rows
t.RowStriping = 'on';
t.RowName = [];
% Columns
t.ColumnName = {'Parameter','Value'};
t.ColumnWidth = {300,'auto'};
t.ColumnEditable = [false true];
% Data
t.Data = [kV',vV'];

%%
% Retrieve the new data
iVar = get(t,'Data')

end

