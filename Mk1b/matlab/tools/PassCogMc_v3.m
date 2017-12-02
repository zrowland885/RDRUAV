function [output] = PassCogMc_v3(numRows)
%PASSCOGMC_V3 Returns CoM and mass for given distribution of passengers

%-------------------------------------------------------------------------%
% Description   The function sets a random number of passengers and then
%               populates the passenger bay based on the random-
%               distribution of the passengers (i.e.given probability).
%               Once the passenger distribution is set the Centre of
%               Gravity for the passengers are calculated.
% 
% Author        Hirad Goudarzi
% Email         <hg9g13@soton.ac.uk>
% 
%% ----------------------------------------------------------------------%%
%                       CONFIGURATION PARAMETERS                          %
%-------------------------------------------------------------------------%

% Setting the passenger details
% Diameter_mm, Mass_Oz, Probability
pasngDetails=[27,0.40,0.15;
              32,0.67,0.20;
              38,1.12,0.30;
              45,1.85,0.20;
              49,2.39,0.15];
          
          
pasngLongSpacing_mm = 55.35;  % Passenger longitudinal spacing. The is the
                              % longitudinal distance between the centre of 
                              % each passenger expressed in mm
pasngLatSpacing_mm = 51;      % Passenger lateral spacing. The is the
                              % lateral distance between the centre of each
                              % passenger expressed in mm
aisleSpacing_mm = 99.8;       % Central aisle width. This is the distance 
                              % between centre of adjacent passengers
                              % across the aisle in mm
distance2FuselageLeadingEdge_mm = 24.5; % longitudinal (i.e y) distance
                             % between the passenger bay(PB) frame to the
                             %  centre of the first row passengers

nOfCol = 4;                        % Number of colomns in the passenger bay

% ----- Derived parameters ----- %

nOfPassenger = randi([numRows*nOfCol numRows*nOfCol],1,1); % Set passenger number by taking a value   
                                   % from a discrete uniform distribution
                                   % with a lower and upper limit

nOfPassenger = nOfPassenger - mod(nOfPassenger, nOfCol); % Making sure the 
                % passenger number is complient with the constraint on the
                % number of colomns
nOfRow = ceil(nOfPassenger/nOfCol); % Deriving the numner of rows based on 
                                    % Passenger number and the number of
                                    % colmns 
pasngDist = zeros(nOfRow,nOfCol);   % Initialising the passenger -
                                    % distribution array


%% ----------------------------------------------------------------------%%
%                    CONSTRUCT PASSENGER DISTRIBUTION                     %
%-------------------------------------------------------------------------%

% ---- Populating the Passenger Distribution matrix ---- %
for row = 1:nOfRow
    for col = 1:nOfCol
        if nnz(pasngDist) < nOfPassenger
            % Choose a passenger based on its probability
            pasngDist(row, col) = randsample(pasngDetails(:,1), 1, true,...
            pasngDetails(:,3));
        else
            pasngDist(row, col) = 0;
        end
    end
end

% Debug %
% nOfCol = 4;
% nOfPassenger = 80;
% nOfRow = nOfPassenger/nOfCol;
% pasngDist = ones(nOfRow,nOfCol)*38;

%% ----------------------------------------------------------------------%%
%                        PASSENGER COG ESTIMATE                           %
%-------------------------------------------------------------------------%

pasngPos_PB_mm = struct([]); % Initilising the passenger position cell -
                             % struct. The pass position is relative to the
                             % passenger bay(PB) frame and its given in mm.

pasngMass_kg = zeros(nOfRow,nOfCol); % Initialising the passenger mass -
                                     % array. The mass is given in kg
sumVal = 0;

for row = 1:nOfRow
    for col = 1:nOfCol
    
    if (col<3)
        lateralRelativeIndex = (col-2); 
        if (aisleSpacing_mm > 0); aisleSpacing_mm = -aisleSpacing_mm; end
    else
        lateralRelativeIndex = (col-3);
        if (aisleSpacing_mm < 0); aisleSpacing_mm = -aisleSpacing_mm; end
    end
    
    % Find the x and y distance of the passenger form the PB frame
    x = (aisleSpacing_mm/2) + lateralRelativeIndex * pasngLatSpacing_mm;
    y = distance2FuselageLeadingEdge_mm + (row-1) * pasngLongSpacing_mm;
    pasngPos_PB_mm{row, col}= {x y}; % Store x and y in a cell struct
    
    % Find corresponding mass for the passenger in passDist
    elementMassIndex = find(pasngDetails == pasngDist(row, col));
    if isempty(elementMassIndex); pasngMass_kg(row, col) = 0;else
    pasngMass_kg(row, col) = pasngDetails(elementMassIndex, 2) * 0.0283495;
    end
    
    a = [x,y] * pasngMass_kg(row, col);
    sumVal = sumVal + a;
    
    end
end

% Calculate Centre of Gravity of the passengers in the passenger bay
% relative to PB frame in mm
CoG_PB_mm = sumVal/sum(sum(pasngMass_kg));

pCoM_x = CoG_PB_mm(1);
pCoM_y = CoG_PB_mm(2);
pMass = sum(sum(pasngMass_kg));

output = [pCoM_x,pCoM_y,pMass];

end

