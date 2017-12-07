function [iVar] = SecondaryDimensionSizing(iVar)
%SECONDARYDIMENSIONSIZING Sizes dimensions for aerodynamic requirements

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


end

