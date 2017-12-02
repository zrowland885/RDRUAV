function [AirfoilDetails] = LgfAero(iVar,PlotSwitch)
%LGFAERO Generates a plot of fuselage and returns aerodynamic geometry
% In dire need of some code golf

%% ----------------------------------------------------------------------%%
%                              COORDINATES                                %
%------------------------------------------------------------------------%%

iVar = PrimaryDimensionSizing(iVar);

% Longitudinal input dimensions
noseLength_mm               = 175;
fuselageS1_Length_mm        = iVar('"fuselageS1_Length_mm"=');   % The distance between the nose and the spar/boom connector
fuselageConnectorLength_mm  = iVar('"fuselageConnector_Length_mm"=');  % Length of the spar/boom connector
fuselageS2_Length_mm        = iVar('"fuselageS2_Length_mm"=');  % Length of the rectangular 'main' section
fuselageS3_Length_mm        = iVar('"fuselageS3_Length_mm"=');  % Length of the first sloped section
fuselageS4_Length_mm        = iVar('"fuselageS4_Length_mm"=');  % Length of the second sloped section
rL                          = iVar('"fuselageRib_Thickness_mm"=');	% Thickness of the ribs

tail_Gap_mm = iVar('"boomClearance_Dist_mm"=');	% Gap between fuselage and tail

% Vertical input dimensions
fuselageSemiMinorAxis_Dist_mm = iVar('"fuselageSemiMinorAxis_Dist_mm"=');
y_nose_tip = -50;    % Distance of the nose tip from the axis (-/+ in mm) 20
y_mm = fuselageSemiMinorAxis_Dist_mm;

% Passenger and cargo bay coords
passengerBay_y1_mm = 28.1;
passengerBay_y2_mm = 78.9;
cargoBay_y1_mm = -15;
cargoBay_y2_mm = -93.9;

% Chamfer coords
Body3_y1_mm = y_mm - iVar('"fuselageS3YUpper_Chamfer_mm"=');
Body4_y1_mm = y_mm - iVar('"fuselageS4YUpper_Chamfer_mm"=');
Body3_y2_mm = -y_mm + iVar('"fuselageS3YLower_Chamfer_mm"=');
Body4_y2_mm = -y_mm + iVar('"fuselageS4YLower_Chamfer_mm"=');

% Boom diameter
Boom_Dia_mm = iVar('"boomOuter_Diameter_mm"=');
Boom_Rad_mm = Boom_Dia_mm/2;
y_Boom_centreline = -30;

% Dimension doubles
x_lengths = [0,noseLength_mm,rL,...
    fuselageS1_Length_mm,rL,...
    fuselageConnectorLength_mm,rL,...
    fuselageS2_Length_mm,rL,...
    fuselageS3_Length_mm,rL,...
    fuselageS4_Length_mm];
y_coords_pos = [y_nose_tip,y_mm,y_mm,y_mm,y_mm,y_mm,y_mm,y_mm,y_mm,Body3_y1_mm,Body3_y1_mm,Body4_y1_mm];
y_coords_neg = [y_nose_tip,-y_mm,-y_mm,-y_mm,-y_mm,-y_mm,-y_mm,-y_mm,-y_mm,Body3_y2_mm,Body3_y2_mm,Body4_y2_mm];

% X coordinate generation and Y chord coordinate generation
x_coords = zeros(1,12);
y_camber = zeros(1,12);
y_camber(1) = y_nose_tip;
for i=2:12
    x_coords(i) = x_lengths(i) + x_coords(i-1);
    y_camber(i) = mean([y_coords_pos(i),y_coords_neg(i)]);
end

% Aerodynamic centre
total_Length_mm = x_coords(12);
AC_pos = total_Length_mm/4;


%% ----------------------------------------------------------------------%%
%                                PLOTTING                                 %
%------------------------------------------------------------------------%%

if PlotSwitch == 1
% Plot LGF
figure
hold on
h1=plot(x_coords,y_coords_pos,'m');                      % Upper surface
h2=plot(x_coords,y_coords_neg,'m');                      % Lower surface
h3=plot(x_coords,y_camber,'r');                          % Camberline
h4=plot([0,x_coords(12)],[y_nose_tip,y_camber(12)],'b'); % Chordline
h5=scatter(AC_pos,0,'r*');                               % AC position

% Plot booms
h6=plot([0,total_Length_mm+tail_Gap_mm],[y_Boom_centreline+Boom_Rad_mm,y_Boom_centreline+Boom_Rad_mm],'k:');
plot([0,total_Length_mm+tail_Gap_mm],[y_Boom_centreline-Boom_Rad_mm,y_Boom_centreline-Boom_Rad_mm],'k:');
% Plot passenger bay
h7=plot([x_coords(2),x_coords(10)],[passengerBay_y1_mm,passengerBay_y1_mm],'g--');
plot([x_coords(2),x_coords(10)],[passengerBay_y2_mm,passengerBay_y2_mm],'g--');
% Plot cargo bay
h8=plot([x_coords(2),x_coords(8)],[cargoBay_y1_mm,cargoBay_y1_mm],'g--');
plot([x_coords(2),x_coords(8)],[cargoBay_y2_mm,cargoBay_y2_mm],'g--');

% Plot sections
for i=2:12
    plot([x_coords(i),x_coords(i)],[y_coords_pos(i),y_coords_neg(i)],'k');
end

% Legend
legend([h1 h2 h3 h4 h5 h6 h7 h8],...
    {'Upper surface','Lower surface','Camberline','Chordline',...
    'Aerodynamic Centre','Boom','Passenger bay','Cargo bay'});
end

%% ----------------------------------------------------------------------%%
%                            AIRFOIL ANALYSIS                             %
%------------------------------------------------------------------------%%

% Chord length (mm)
v1 = [0,y_nose_tip,0];              % Chordline coords
v2 = [x_coords(12),y_camber(12),0];
ChordLength_mm = pdist2(v1,v2);

% Maximum camber (mm)
DistToCamber = zeros(1,12);
for i=1:12
    DistToCamber(i) = PointToLine([x_coords(i),y_camber(i),0], v1, v2);
end
MaxCamber_mm = max(DistToCamber);
for i=1:12
    if DistToCamber(i) == MaxCamber_mm
        MaxCamberX = x_coords(i);
    end
end

% Maximum chord (mm)
DistToChord = zeros(1,24);
x_totalcoords = horzcat(x_coords,x_coords);
y_totalcoords = horzcat(y_coords_pos,y_coords_neg);
for i=1:24
    DistToChord(i)    = PointToLine([x_totalcoords(i),y_totalcoords(i),0], v1, v2);
end
MaxThickness_mm = max(DistToChord);
for i=1:24
    if DistToChord(i) == MaxThickness_mm
        MaxChordX = x_totalcoords(i);
    end
end

MaxCamber_Pc = MaxCamber_mm/ChordLength_mm*100;         % Max camber as percentage of chord
MaxCamberPos_Pc = MaxCamberX/x_coords(12)*100;          % Max camber position as percentage of chord
MaxThickness_Pc = MaxThickness_mm/ChordLength_mm*100;   % Max thickness as percentage of chord
MaxChordPos_Pc = MaxChordX/x_coords(12)*100;           % Max thickness position as percentage of chord

% AirfoilDetails = [round(MaxCamber_Pc),(round(MaxCamberPos_Pc,-1)/10),round(MaxThickness_Pc)];

AirfoilDetails = [MaxCamber_Pc,MaxCamberPos_Pc,MaxThickness_Pc,MaxChordPos_Pc];

% sprintf('\nLGF geometry: %d%d%02d\n',AirfoilDetails(1),AirfoilDetails(2),AirfoilDetails(3))

end
