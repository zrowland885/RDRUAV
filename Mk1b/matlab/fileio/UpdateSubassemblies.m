function [] = UpdateSubassemblies(iVar)
%UPDATESUBASSEMBLIES Finds and replaces previous dimensions
ExportDimensions('cad/','master_equations.txt',iVar);
ExportDimensions('cad/wing/','wing_equations.txt',iVar);
ExportDimensions('cad/fuselage/','fuselage_equations.txt',iVar);
%ExportDimensions('cad/tail/','tail_equations.txt',input_variables);
end

