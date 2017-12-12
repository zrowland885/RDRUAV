function [Part1] = LoadSw()
%LOADSW Loads in currently open SW files
swApp = actxserver('SldWorks.Application');
set(swApp, 'Visible', true);
Part1=invoke(swApp,'ActiveDoc'); % Active part
invoke(Part1, 'GetTitle');
end

