function [SwMassProperties] = ReadSwMass(Part1)
%SWMASSPROPERTIES Reads mass from Solidworks file

% Read mass properties into doubles, convert to map
sw_mass_read = invoke(Part1, 'GetMassProperties');
propertySet = {'CoM_x', 'CoM_y', 'CoM_z',...
    'volume', 'surface_area', 'mass',...
    'L_xx', 'L_yy', 'L_zz', 'L_xy', 'L_xz', 'L_yz'};
valueSet = sw_mass_read;

SwMassProperties = containers.Map(propertySet,valueSet);

end

