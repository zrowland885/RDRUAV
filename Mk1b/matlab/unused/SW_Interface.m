clear;
clc;

swApp = actxserver('SldWorks.Application');
set(swApp, 'Visible', true);

Part1=invoke(swApp,'ActiveDoc'); %active part
partTitle = invoke(Part1, 'GetTitle')

% SWSMan=invoke(Part1,'SketchManager');
% S1=invoke(SWSMan,'InsertSketch','1'); %new sketch
% SEG1=invoke(SWSMan,'CreateCircle',0, 0, 0, .5, .5, 0); %circle
Rebuild = invoke(Part1,'EditRebuild');
Mass = invoke(Part1, 'GetMassProperties')

% SW=actxserver('SldWorks.Application'); %start the link
% SWEd = invoke(SW,'GetEdition');
% SWRec = invoke(SW,'GetRecentFiles'); %getENV = invoke(SW,'GetEnvironment'); %take control
% 
% Part1=invoke(SW,'ActiveDoc'); %new part
% SWSMan=invoke(Part1,'SketchManager');
% S1=invoke(SWSMan,'InsertSketch','1'); %new sketch
% SEG1=invoke(SWSMan,'CreateCircle',0, 0, 0, 50, 50, 0); %circle
% SEG2=invoke(SWSMan,'CreateLine',0, 0, 0, 50, 50, 0); %line
% Zoom=invoke(Part1, 'ViewZoomToFit');

