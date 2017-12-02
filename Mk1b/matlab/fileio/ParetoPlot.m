for i=1:279
    filename = strcat('results_',num2str(i),'.txt');
    PlotData = ReadDimensions('matlab/results/',filename,'resultmap');
    
    var1='"wingAspectRatio"=';
    var2='"controlNumPassengerRows"=';
    var3='RAC';
    var4='TotalMass_kg';
    
    plotR(1)=PlotData.iVar(var1);
    plotR(2)=PlotData.iVar(var2)*4;
    plotR(3)=PlotData.results(var3)*2;
    plotR(4)=PlotData.results(var4);
    
    
    score = (PlotData.iVar('"controlNumPassengerRows"=')*4 + 2*PlotData.iVar('"controlNumPassengerRows"=')*4*PlotData.iVar('"controlPayloadDensity_kgm-3"='))/PlotData.results('RAC');
    
    % Add numerical labels to each point on plot
    dx=plotR(1)/50;dy=plotR(2)/50;dz=score/50;
    text(plotR(1)+dx,plotR(2)+dy,score+dz,num2str(i));
    
    scatter3(plotR(1),plotR(2),score,100,plotR(4),'o','filled');
    colorbar;
    colorbar.Label.String = 'Total mass (kg)';
    xlabel('AR');  ylabel('No. passengers'); zlabel('(no. pax + 2 * no. pax * payload density) / RAC');
    hold on
    
end