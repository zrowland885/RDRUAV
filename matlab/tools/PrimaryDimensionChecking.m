function [ iVar ] = PrimaryDimensionChecking(iVar)
%PRIMARYDIMENSIONCHECKING Checks the input dimensions are legal, alters as appropriete

% Check the main wing spar isn't too large.
wingMaxSpar_Diameter_mm = iVar('"wingTipChord_Length_mm"=')*0.12 - 10;
if iVar('"wingMainSpar_OuterDiameter_mm"=') > wingMaxSpar_Diameter_mm
    iVar('"wingMainSpar_OuterDiameter_mm"=') = wingMaxSpar_Diameter_mm;
    iVar('"wingMainSpar_InnerDiameter_mm"=') = 0;
    fprintf('\nWing main spar too large for airfoil - reduced to: %d mm.\n', wingMaxSpar_Diameter_mm);
end

end

