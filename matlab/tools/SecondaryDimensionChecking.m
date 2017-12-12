function [StructErrorFlag] = SecondaryDimensionChecking(iVar)
%SECONDARYDIMENSIONCHECKING checks legality of dimensions and returns error flag if illegal

StructErrorFlag = 0;

% Check the main wing spar isn't too large.
wingMaxSpar_Diameter_mm = iVar('"wingRootChord_Length_mm"=')*0.12 - 10;
if iVar('"wingMainSpar_OuterDiameter_mm"=') > wingMaxSpar_Diameter_mm
    StructErrorFlag = 1;
    error('Wing spar too large for airfoil.');
end

end