function [] = UpdateSubassemblies(iVar)
%UPDATESUBASSEMBLIES Finds and replaces previous dimensions
ExportDimensions('C:/Users/Zach/Desktop/GDP/RDUAVGit/RDUAV/Mk1c/cad/','master_equations.txt',iVar);
ExportDimensions('C:/Users/Zach/Desktop/GDP/RDUAVGit/RDUAV/Mk1c/cad/wing','wing_equations.txt',iVar);
ExportDimensions('C:/Users/Zach/Desktop/GDP/RDUAVGit/RDUAV/Mk1c/cad/fuselage','fuselage_equations.txt',iVar);
ExportDimensions('C:/Users/Zach/Desktop/GDP/RDUAVGit/RDUAV/Mk1c/cad/tail/','tail_equations.txt',iVar);
ExportDimensions('C:/Users/Zach/Desktop/GDP/RDUAVGit/RDUAV/Mk1c/cad/clamp/','clamp_equations.txt',iVar);
end