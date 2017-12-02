function [SCORE,RAC] = ScoreCalc(iVar,AcMass_kg,PayloadMass_kg)
%SCORECALC Provides an estimate of our DBF competition final score

% Written report score
ReportScore = 100;

% Our results
M2_NumPassengers = 4*iVar('"controlNumPassengerRows"=');
M2_Time = 300; % Max 300s (5min) to complete 3 laps

M3_NumPassengers = M2_NumPassengers;
PayloadMass_oz = PayloadMass_kg*0.0283495;
M3_Laps = 6; % In 600s (10min)

% Best results
bestM2_NumPassengers =  M2_NumPassengers;
bestM2_Time = M2_Time;

bestM3_NumPassengers = M3_NumPassengers;
bestPayloadMass_oz = PayloadMass_oz;
bestM3_Laps = M3_Laps;

% Score calculation
M1_Score = 1.0;
M2_Score = 2*( (M2_NumPassengers/M2_Time)/(bestM2_NumPassengers/bestM2_Time) );
M3_Score = 4*( (M3_NumPassengers*PayloadMass_oz*M3_Laps)/(bestM3_NumPassengers*bestPayloadMass_oz*bestM3_Laps) ) + 2;

% RAC
AcMass_lbs = AcMass_kg*0.453592;
TotalSpan_in = 2*(iVar('"wingSpan_Length_mm"=')+iVar('"fuselageSemiMajorAxis_Dist_mm"='))*0.0393701;

RAC = AcMass_lbs*TotalSpan_in;

% SCORE
SCORE = (ReportScore*(M1_Score+M2_Score+M3_Score))/RAC;

end

