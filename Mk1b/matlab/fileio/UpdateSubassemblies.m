function [] = UpdateSubassemblies(iVar)
%UPDATESUBASSEMBLIES Finds and replaces previous dimensions
ExportDimensions('C:/Users/Zach/Desktop/GDP/RDUAVGit/RDUAV/Mk1b/cad/','master_equations.txt',iVar);
ExportDimensions('C:/Users/Zach/Desktop/GDP/RDUAVGit/RDUAV/Mk1b/cad/wing','wing_equations.txt',iVar);
ExportDimensions('C:/Users/Zach/Desktop/GDP/RDUAVGit/RDUAV/Mk1b/cad/fuselage','fuselage_equations.txt',iVar);
ExportDimensions('C:/Users/Zach/Desktop/GDP/RDUAVGit/RDUAV/Mk1b/cad/tail/','tail_equations.txt',iVar);
end