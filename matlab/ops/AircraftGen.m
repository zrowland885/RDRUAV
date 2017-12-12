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
%   v0.4:   ZR, LEH         09/12/17    Added new spar sizing code, considerable assem updates, readme update, set up Git
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
OtherComponentsFf_kg = 0;
MotorFf_kg = 0;
AvionicsFf_kg = 0;
FuselageStructFf_kg = 0;

% Read the mass of the assembly
SwMass = ReadSwMass(SwPart);
% Payload mass
PlMass_kg = iVar('"controlPayloadDensity_kgm-3"=')*(iVar('"fuselage_PayloadBay_Length_mm"=')*78.90*152.40)/1000000000;


McIter = iVar('"controlMonteCarloIterations"=');	% Number of iterations to run for passenger Monte Carlo
PassengerMc = {McIter,1};   % Cell for MC data to reside in

% Doubles for MLE
PaxCoMD_x_mm = zeros(1,McIter);
PaxCoMD_y_mm = zeros(1,McIter);
PaxCoMD_z_mm = zeros(1,McIter);
PaxMassD_kg  = zeros(1,McIter);

% Run Monte Carlo
fprintf('\nMonte Carlo iteration: ');
for i=1:McIter
    PassengerMc{i} = PassCogMc_v3(iVar('"controlNumPassengerRows"='));  % Run the MC
    fprintf('%d',i);
    fprintf(repmat('\b',1,length(num2str(i)))); % Progress counter

    % Fill up the doubles
    PaxCoMD_x_mm(i) = PassengerMc{i}(1);
    PaxCoMD_y_mm(i) = 53.5;
    PaxCoMD_z_mm(i) = -PassengerMc{i}(2);
    PaxMassD_kg(i)  = PassengerMc{i}(3);
end

% Generate mean and sigma values via MLE with normal distribution
PaxCoM_x_mm = mle(PaxCoMD_x_mm);
PaxCoM_y_mm = mle(PaxCoMD_y_mm);
PaxCoM_z_mm = mle(PaxCoMD_z_mm);
PaxMass_kg =  mle(PaxMassD_kg);

% Payload CoM and mass value
PlCoM_x_mm = 0;
PlCoM_y_mm = -(15+78.90/2);
PlCoM_z_mm = -iVar('"fuselage_PayloadBay_Length_mm"=')/2;

% Aircraft CoM and mass value
AcCoM_x_mm = SwMass('CoM_x')*1000;
AcCoM_y_mm = SwMass('CoM_y')*1000;
AcCoM_z_mm = SwMass('CoM_z')*1000;

AcMass_kg = SwMass('mass')+OtherComponentsFf_kg+MotorFf_kg+AvionicsFf_kg+FuselageStructFf_kg; % With FF

% Combine mean MC values for passengers with aircraft mass
TotalMass_kg = AcMass_kg + PaxMass_kg(1) + PaxMass_kg(2) + PlMass_kg;
TotalCoM_x_mm = (PaxMass_kg(1)*PaxCoM_x_mm(1) + AcMass_kg*AcCoM_x_mm + PlMass_kg*PlCoM_x_mm)/TotalMass_kg;
TotalCoM_y_mm = (PaxMass_kg(1)*PaxCoM_y_mm(1) + AcMass_kg*AcCoM_y_mm + PlMass_kg*PlCoM_y_mm)/TotalMass_kg;
TotalCoM_z_mm = (PaxMass_kg(1)*PaxCoM_z_mm(1) + AcMass_kg*AcCoM_z_mm + PlMass_kg*PlCoM_z_mm)/TotalMass_kg;

% Declare mass properties
fprintf('\nTotal aircraft mass: %f kg\n', AcMass_kg)
fprintf('\nTotal passenger mass: %f kg\n', PaxMass_kg(1))
fprintf('\nTotal payload mass: %f kg\n', PlMass_kg)
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
LgfGeom = LgfAero(iVar,0);

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

iVar = SecondaryDimensionSizing(iVar);

%% ----------------------------------------------------------------------%%
%                          STRUCTURAL ANALYSIS                            %
%------------------------------------------------------------------------%%

WorstCase_PaxMass_kg = iVar('"controlNumPassengerRows"=')*4*0.06775536;
WorstCase_TotalMass_kg = AcMass_kg+WorstCase_PaxMass_kg+PlMass_kg;
E = 600*(10^6); % Youngs Modulus of carbon fibre spars
% wingSpanFromBoom_m = (iVar('"wingSpan_Length_mm"=') + (iVar('"fuselageSemiMajorAxis_Dist_mm"=')-0.5*iVar('"boomSeparation_Dist_mm"=')))/1000;
Ws = 1.1; % Total wing mass in kg
wingMainSpar_Thickness_mm = 2;
SparFf = 1.2;

iVar('"wingMainSpar_OuterDiameter_mm"=') = SparSizing(iVar('"wingSpan_Length_mm"=')/1000,WorstCase_TotalMass_kg,Ws,6,iVar('"wingRootChord_Length_mm"=')/1000,iVar('"wingTipChord_Length_mm"=')/1000,E,wingMainSpar_Thickness_mm/1000)*2*SparFf;
iVar('"wingMainSpar_InnerDiameter_mm"=') = iVar('"wingMainSpar_OuterDiameter_mm"=')-wingMainSpar_Thickness_mm*2;

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
TotalMass_kg = AcMass_kg + PaxMass_kg(1) + PaxMass_kg(2) + PlMass_kg;


%% ----------------------------------------------------------------------%%
%                             OUTPUT RESULTS                              %
%------------------------------------------------------------------------%%

%% Calculate score

[SCORE,RAC] = ScoreCalc(iVar,AcMass_kg,PlMass_kg);

%% Create export file

exportid = strcat('C:/Users/Zach/Desktop/GDP/RDUAVGit/RDUAV/matlab/results/results_',num2str(id(1))); % Create results file with ID

%% Prepare data for export

ExportCell =...
    {'AcMass_kg',               AcMass_kg-0.9072        ;...
    'PaxMass_kg',               PaxMass_kg(1)           ;...
    'PaxMassSigma_kg',          PaxMass_kg(2)           ;...
    'PlMass_kg'                 0.9072                  ;...
    'TotalMass_kg',             TotalMass_kg            ;...
    'WorstCase_TotalMass_kg'    WorstCase_TotalMass_kg  ;...

    'AcCoM_x_mm',               AcCoM_x_mm              ;...
    'AcCoM_y_mm',           	AcCoM_y_mm              ;...
    'AcCoM_z_mm',               AcCoM_z_mm              ;...

    'PaxCoM_x_mm',              PaxCoM_x_mm(1)          ;...
    'PaxCoM_xSigma_mm',         PaxCoM_x_mm(2)          ;...
    'PaxCoM_y_mm',              PaxCoM_y_mm(1)          ;...
    'PaxCoM_ySigma_mm',         PaxCoM_y_mm(2)          ;...
    'PaxCoM_z_mm',              PaxCoM_z_mm(1)          ;...
    'PaxCoM_zSigma_mm',         PaxCoM_z_mm(2)          ;...

    'PlCoM_x_mm'                PlCoM_x_mm              ;...
    'PlCoM_y_mm'                PlCoM_y_mm              ;...
    'PlCoM_z_mm'                PlCoM_z_mm              ;...
    
    'TotalCoM_x_mm',            TotalCoM_x_mm           ;...
    'TotalCoM_y_mm',            TotalCoM_y_mm           ;...
    'TotalCoM_z_mm',            TotalCoM_z_mm           ;...

    'FuselageMaxCamber_Pc',     LgfGeom(1)              ;...
    'FuselageMaxCamberPos_Pc',  LgfGeom(2)              ;...
    'FuselageMaxThickness_Pc',  LgfGeom(3)              ;...
    'FuselageMaxChordPos_Pc',   LgfGeom(4)              ;...

    'TotalWeight_N',            TotalMass_kg*9.81       ;...
    'TotalLift_N',              TotalLift_N             ;...

    'SCORE',                    SCORE                   ;...
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

