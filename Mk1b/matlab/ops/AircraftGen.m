function [] = AircraftGen(iVar,id)
%AIRCRAFTGEN Master script for generating the SW assembly
%
%   Version history:
%   v0:     ZR              10/11/17
%   v0.1:   ZR, DB          12/11/17
%   v0.2:   ZR, DB          15/11/17    I/O completed; dimension sizing completed; SW activeX working
%   v0.21:  ZR              17/11/17    I/O, varible name cleanup; more user friendly
%   v0.3:   ZR, HGo         18/11/17    added MC function; iteration_shell functional; re-arranged code
%   v0.31:  ZR              21/11/17    Debugging iterations; generating output datafiles
%   v0.32:  ZR, LEH, HGo	22/11/17    Cleaned up code somewhat; added spar sizing
%   v0.33:  ZR              25/11/17    Significant code cleanup; file organisation; Readme created with best practices; LgfAero added
%   v0.34:  ZR              28/11/17    Cleanup of result output
% 
%   Debugging FAQ:
%       Issues with importing dimensions:
%       - Check SW equation files are tab-deliminated.
%       Equations broken in Solidworks:
%       - Check the linked equation file is correct. It should be in the
%       same directory as your sub-assembly.
%       Strange mass properties:
%       - Close all other SW windows aside from the master assembly.
%

%%
SwPart = LoadSw(); % Load in currently open SW files

%% ----------------------------------------------------------------------%%
%                            DIMENSION SIZING                             %
%-------------------------------------------------------------------------%
% Based on input variables.
% Alters the input_variables map accordingly.
% Updates the assembly to give the new mass.

iVar = PrimaryDimensionSizing(iVar);   % Size the dimensions
UpdateSubassemblies(iVar);   % Find and replace previous dimensions
RefreshSw(SwPart);    % Refresh the Solidworks assembly

% PUT THE SIZING GUI GRAPHIC FUNCTION HERE!

%% ----------------------------------------------------------------------%%
%                       PRIMARY DIMENSION CHECKING                        %
%------------------------------------------------------------------------%% 
% Check for impossible dimensions.
% Fix and alert the user to the change.

iVar = PrimaryDimensionChecking(iVar);

%% ----------------------------------------------------------------------%%
%                             MONTE CARLO                                 %
%------------------------------------------------------------------------%%
% Execute the passenger Monte Carlo and find the overall CoM with
% passengers and the aircraft structure, in mm. Also finds the total mass
% in kg.

% Mass fudge and safety factors
OtherComponentsFf_kg = 0.2;
MotorFf_kg = 0.5;
AvionicsFf_kg = 0.5;
% FuselageStructFf_kg = iVar('"fuselage_Length_mm"=')*0.002*0.2;
FuselageStructFf_kg = 0;

% Read the mass of the assembly
SwMass = ReadSwMass(SwPart);
% Payload mass
PayloadMass_kg = iVar('"controlPayloadDensity_kgm-3"=')*(iVar('"fuselage_PayloadBay_Length_mm"=')*78.90*152.40)/1000000000;

McIter = iVar('"controlMonteCarloIterations"=');	% Number of iterations to run for passenger Monte Carlo
PassengerMc = {McIter,1};   % Cell for MC data to reside in

% Doubles for MLE
PaxCoMD_x_mm = [];
PaxCoMD_y_mm = [];
PaxCoMD_z_mm = [];
PaxMassD_kg  = [];

% Run Monte Carlo
fprintf('\nMonte Carlo iteration: ');
for i=1:McIter
    PassengerMc{i} = PassCogMc_v3(iVar('"controlNumPassengerRows"='));  % Run the MC
    fprintf('%d',i);
    fprintf(repmat('\b',1,length(num2str(i)))); % Progress counter

    % Fill up the doubles
    PaxCoMD_x_mm(end+1) = PassengerMc{i}(1);
    PaxCoMD_y_mm(end+1) = 0;
    PaxCoMD_z_mm(end+1) = PassengerMc{i}(2);
    PaxMassD_kg(end+1)  = PassengerMc{i}(3);
end

% Generate mean and sigma values via MLE with normal distribution
PaxCoM_x_mm = mle(PaxCoMD_x_mm);
PaxCoM_y_mm = mle(PaxCoMD_y_mm);
PaxCoM_z_mm = mle(PaxCoMD_z_mm);
PaxMass_kg =  mle(PaxMassD_kg);

% Aircraft CoM and mass value
AcCoM_x_mm = SwMass('CoM_x')*1000;
AcCoM_y_mm = SwMass('CoM_y')*1000;
AcCoM_z_mm = SwMass('CoM_z')*1000;

AcMass_kg = SwMass('mass')+OtherComponentsFf_kg+MotorFf_kg+AvionicsFf_kg+FuselageStructFf_kg; % With FF

% Combine mean MC values for passengers with aircraft mass
TotalMass_kg = AcMass_kg + PaxMass_kg(1) + PayloadMass_kg;
TotalCoM_x_mm = (PaxMass_kg(1)*PaxCoM_x_mm(1) + AcMass_kg*AcCoM_x_mm)/(PaxMass_kg(1) + AcMass_kg);
TotalCoM_y_mm = (PaxMass_kg(1)*PaxCoM_y_mm(1) + AcMass_kg*AcCoM_y_mm)/(PaxMass_kg(1) + AcMass_kg);
TotalCoM_z_mm = (PaxMass_kg(1)*PaxCoM_z_mm(1) + AcMass_kg*AcCoM_z_mm)/(PaxMass_kg(1) + AcMass_kg);

% Declare mass properties
fprintf('\nTotal aircraft mass: %f kg\n', AcMass_kg)
fprintf('\nTotal passenger mass: %f kg\n', PaxMass_kg(1))
fprintf('\nCoM position (x, y, z): %f mm, %f mm, %f mm\n',...
	TotalCoM_x_mm, TotalCoM_y_mm, TotalCoM_z_mm)

% SOME USEFUL PLOTS
% hist(pMassd_kg)

% figure
% scatter3(pCoMd_x_mm,pCoMd_z_mm,pCoMd_y_mm,'.','k')
% hold on
% hist3([pCoMd_x_mm', pCoMd_z_mm'],'FaceAlpha',.9)
% xlabel('x (mm)'); ylabel('y (mm)');

% [n,c] = hist3([pCoMd_x_mm', pCoMd_z_mm']);
% contour(c{1},c{2},n)


%% ----------------------------------------------------------------------%%
%                          AERODYNAMIC SIZING                             %
%------------------------------------------------------------------------%%

% Fuselage lifting geometry
LgfGeom = LgfAero(iVar,1);

% Wing reference area
%         __
%    ____|__|____
%   /____________\  <- Includes section of fuselage and connectors
%       _|__|_
%

CL = 1.2;   % Wing CL
LiftSf = 1.1;   % Safety factor for lift
TotalLift_N = TotalMass_kg*9.81*LiftSf; % Lift requirement
iVar('"wingRefArea_mm2"=') = (2*TotalLift_N)/(1.225*CL*iVar('"controlVelocity_ms-1"=')^2)*10^6; % Lifting area in mm2 (both wings0

% VVV TO BE TRANSFERED TO SECONDARY DIMENSION SIZING FUNCTION VVV

% Span of each wing
iVar('"wingSpan_Length_mm"=') = iVar('"wingRefArea_mm2"=')/...
    (iVar('"wingRootChord_Length_mm"=')*(1+iVar('"wingTaper_Ratio"=')));

% Taper angle for driving Solidworks subassembly
iVar('"wingTaper_Angle_deg"=') =...
    (180/pi)*atan( ( iVar('"wingRootChord_Length_mm"=')/iVar('"wingSpan_Length_mm"=')*(1-iVar('"wingTaper_Ratio"=')) ));

% iVar('"wingRefArea"=') = ( 2*(iVar('"wingTaper_Ratio"=')*iVar('"wingSpan_Length_mm"=') + 0.5*(1-iVar('"wingTaper_Ratio"='))*iVar('"wingSpan_Length_mm"=')) + 2*iVar('"fuselageSemiMajorAxis_Dist_mm"=') )*iVar('"wingRootChord_Length_mm"=');

% Wing Aspect Ratio
iVar('"wingAspectRatio"=') = (2*(iVar('"wingSpan_Length_mm"=')+iVar('"fuselageSemiMajorAxis_Dist_mm"=')))^2 / iVar('"wingRefArea_mm2"=');

% Wing main spar length defined as total wingspan
iVar('"wingMainSpar_Length_mm"=') =...
    iVar('"wingSpan_Length_mm"=')*2 + 20.29 + iVar('"fuselageSemiMajorAxis_Dist_mm"=')*2 + iVar('"wingRib_Thickness_mm"=')*2;

% Wing minor spar length is the same as the main spar length
iVar('"wingMinorSpar_Length_mm"=') =...
    iVar('"wingMainSpar_Length_mm"=');

% Wing thickness for fuselage and clamp sizing
iVar('"wingSlotThickness_mm"=') = iVar('"wingRootChord_Length_mm"=')*0.12;
if iVar('"wingSlotThickness_mm"=') < 65
    iVar('"wingSlotThickness_mm"=') = 65;
end
%% ----------------------------------------------------------------------%%
%                          STRUCTURAL ANALYSIS                            %
%------------------------------------------------------------------------%%

WorstCase_pMass_kg = iVar('"controlNumPassengerRows"=')*4*0.06775536;
k = TotalLift_N/(2*(iVar('"wingSpan_Length_mm"=')+iVar('"fuselageSemiMajorAxis_Dist_mm"='))); % Lift distribution
E = 228*1000000000; % Youngs Modulus of carbon fibre spars
wingSpanFromBoom = iVar('"wingSpan_Length_mm"=') + (iVar('"fuselageSemiMajorAxis_Dist_mm"=')-0.5*iVar('"boomSeparation_Dist_mm"='));

% iVar('"wingMainSpar_OuterDiameter_mm"=')=SparSizing(wingSpanFromBoom,iVar('"boomSeparation_Dist_mm"='),k,(aMass_kg+WorstCase_pMass_kg),E,iVar('"controlVelocity_ms-1"='));

fprintf('\nOuter diameter: %f mm',iVar('"wingMainSpar_OuterDiameter_mm"='));

%% ----------------------------------------------------------------------%%
%                      SECONDARY DIMENSION CHECKING                       %
%------------------------------------------------------------------------%%
% If any structure driven dimensions are impossible, break the function and
% return an error listing for the invalid dimenions.

StructErrorFlag = SecondaryDimensionChecking(iVar);

%%
UpdateSubassemblies(iVar);   % Find and replace previous dimensions
RefreshSw(SwPart);    % Refresh the Solidworks assembly
% Read the mass of the assembly
SwMass = ReadSwMass(SwPart);
% Update mass to consider new wing span
AcMass_kg = SwMass('mass')+OtherComponentsFf_kg+MotorFf_kg+AvionicsFf_kg+FuselageStructFf_kg; % With FF
TotalMass_kg = AcMass_kg + PaxMass_kg(1) + PayloadMass_kg;


%% ----------------------------------------------------------------------%%
%                             OUTPUT RESULTS                              %
%------------------------------------------------------------------------%%

%% Calculate score

[SCORE,RAC] = ScoreCalc(iVar,AcMass_kg,PayloadMass_kg);

%% Create export file

exportid = strcat('matlab/results/results_',num2str(id(1))); % Create results file with ID code (still working on that)

%% Prepare data for export

ExportCell =...
    {'AcMass_kg',               AcMass_kg           ;...
    'PaxMass_kg',               PaxMass_kg(1)       ;...
    'PaxMassSigma_kg',          PaxMass_kg(2)       ;...
    'PayloadMass_kg'            PayloadMass_kg      ;...
    'TotalMass_kg',             TotalMass_kg        ;...

    'AcCoM_x_mm',               AcCoM_x_mm          ;...
    'AcCoM_y_mm',           	AcCoM_y_mm          ;...
    'AcCoM_z_mm',               AcCoM_z_mm          ;...

    'PaxCoM_x_mm',              PaxCoM_x_mm(1)      ;...
    'PaxCoM_xSigma_mm',         PaxCoM_x_mm(2)      ;...
    'PaxCoM_y_mm',              PaxCoM_y_mm(1)      ;...
    'PaxCoM_ySigma_mm',         PaxCoM_y_mm(2)      ;...
    'PaxCoM_z_mm',              PaxCoM_z_mm(1)      ;...
    'PaxCoM_zSigma_mm',         PaxCoM_z_mm(2)      ;...

    'TotalCoM_x_mm',            TotalCoM_x_mm       ;...
    'TotalCoM_y_mm',            TotalCoM_y_mm       ;...
    'TotalCoM_z_mm',            TotalCoM_z_mm       ;...

    'FuselageMaxCamber_Pc',     LgfGeom(1)          ;...
    'FuselageMaxCamberPos_Pc',  LgfGeom(2)          ;...
    'FuselageMaxThickness_Pc',  LgfGeom(3)          ;...
    'FuselageMaxChordPos_Pc',   LgfGeom(4)          ;...

    'TotalWeight_N',            TotalMass_kg*9.81   ;...
    'TotalLift_N',              TotalLift_N         ;...

    'SCORE',                    SCORE               ;...
    'RAC',                      RAC
};

exportid = strcat(exportid,'.txt');
fid = fopen(exportid,'wt'); % Open file ID for writing

[nrows,~] = size(ExportCell);
for row = 1:nrows
    fprintf(fid,'%s\t%f\n',ExportCell{row,:});
end

% Input variables
fprintf(fid,'\nINPUTVARS\t');
k = keys(iVar);
v = values(iVar);
for i = 1:length(iVar)
    fprintf(fid,'\n%s\t%f',k{i},v{i});
end

% Passenger Monte Carlo data
% fprintf(fid,'\n\n% MONTECARLO');
% for i = 1:McIter
%     fprintf(fid,'\nx (mm):\t%f\tz (mm):\t%f\tmass (kg):\t%f',...
%         PassengerMc{i}(1),PassengerMc{i}(2),PassengerMc{i}(3));
% end

fclose(fid); % Close the file

end

