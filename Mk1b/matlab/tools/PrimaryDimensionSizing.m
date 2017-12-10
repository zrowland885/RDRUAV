function [iVar] = PrimaryDimensionSizing(iVar)
%DIMENSIONSSIZING Sizes dimensions based on user input

% Wing tip chord defined by taper ratio
iVar('"wingTipChord_Length_mm"=') =...
    iVar('"wingRootChord_Length_mm"=')*iVar('"wingTaper_Ratio"=');

% Length of fuselage needed to carry the specified passengers
iVar('"fuselage_PassengerBay_Length_mm"=') =...
    iVar('"controlNumPassengerRows"=') * ( iVar('"fuselagePassengerSpacingLong_Length_mm"=') + iVar('"fuselageSeat_Diameter_mm"=') );

% Set connector length to cover wing chord plus some room space
iVar('"fuselageConnector_Length_mm"=') =...
    iVar('"wingRootChord_Length_mm"=');

% Divide up the remaining alotted fuselage length
if iVar('"fuselage_PassengerBay_Length_mm"=') > iVar('"fuselageConnector_Length_mm"=')
    FractionalFuselageLength_mm =...
        iVar('"fuselage_PassengerBay_Length_mm"=') - iVar('"fuselageConnector_Length_mm"=') - 3*iVar('"fuselageRib_Thickness_mm"=');
    iVar('"fuselageS1_Length_mm"=') = iVar('"fuselageS1_Ratio"=')*FractionalFuselageLength_mm;
    iVar('"fuselageS2_Length_mm"=') = iVar('"fuselageS2_Ratio"=')*FractionalFuselageLength_mm;
    iVar('"fuselageS3_Length_mm"=') = iVar('"fuselageS3_Ratio"=')*FractionalFuselageLength_mm;
    
    % Resultant length of payload bay
    iVar('"fuselage_PayloadBay_Length_mm"=') = iVar('"fuselageS1_Length_mm"=') + iVar('"fuselageConnector_Length_mm"=') + iVar('"fuselageS2_Length_mm"=') + 2*iVar('"fuselageRib_Thickness_mm"=');
else
    iVar('"fuselageS1_Length_mm"=') = 1;
    iVar('"fuselageS2_Length_mm"=') = 1;
    iVar('"fuselageS3_Length_mm"=') = 1;
    iVar('"fuselage_PassengerBay_Length_mm"=') = iVar('"fuselageConnector_Length_mm"=') + 3*iVar('"fuselageRib_Thickness_mm"=') + 3;
    
    % Resultant length of payload bay
    iVar('"fuselage_PayloadBay_Length_mm"=') = iVar('"fuselageConnector_Length_mm"=') + 2*iVar('"fuselageRib_Thickness_mm"=') + 2;
end
iVar('"fuselage_Length_mm"=') =...
    iVar('"fuselage_PassengerBay_Length_mm"=') + iVar('"fuselageS4_Length_mm"=');

% Wing main spar length defined as total wingspan
iVar('"wingMainSpar_Length_mm"=') =...
    iVar('"wingSpan_Length_mm"=')*2 + 20.29 + iVar('"fuselageSemiMajorAxis_Dist_mm"=')*2 + iVar('"wingRib_Thickness_mm"=')*2;

% Wing minor spar length is the same as the main spar length
iVar('"wingMinorSpar_Length_mm"=') =...
    iVar('"wingMainSpar_Length_mm"=');

% Boom length
iVar('"boom_Length_mm"=') =...
    iVar('"motor_Length_mm"=') + iVar('"fuselage_Length_mm"=') + iVar('"tailChord_Length_mm"=') + iVar('"boomClearance_Dist_mm"=');

% Wing thickness for fuselage and clamp sizing
iVar('"wingSlotThickness_mm"=') = iVar('"wingRootChord_Length_mm"=')*0.12;
if iVar('"wingSlotThickness_mm"=') < 65
    iVar('"wingSlotThickness_mm"=') = 65;
end

end

