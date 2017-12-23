for i=1:246
    filename = strcat('results_',num2str(i),'.txt');
    PlotData = ReadDimensions('matlab/results/',filename,'resultmap');
    
    if PlotData.iVar('"controlVelocity_ms-1"=')==13 && PlotData.iVar('"wingSpan_Length_mm"=')*2 + 496<=2500
    
    var1='"wingSpan_Length_mm"=';
    var2='"controlNumPassengerRows"=';
    var3='RAC';
    var4='TotalMass_kg';
    
    plotR(1)=PlotData.iVar(var1)*2 + 496;
    plotR(2)=PlotData.iVar(var2)*4;
    plotR(3)=PlotData.results(var3);
    plotR(4)=PlotData.results(var4);
    
    
    score = (PlotData.iVar('"controlNumPassengerRows"=')*4 + 2*PlotData.iVar('"controlNumPassengerRows"=')*4*PlotData.iVar('"controlPayloadDensity_kgm-3"='))/PlotData.results('RAC');

    % Add numerical labels to each point on plot
    dx=plotR(1)/50;dy=plotR(2)/50;dz=score/50;
    text(plotR(1)+dx,plotR(2)+dy,score+dz,num2str(i));
    
    
    scatter3(plotR(1),plotR(2),score,100,plotR(4),'o','filled');
    colorbar;
    colorbar.Label.String = 'Total mass (kg)';
    xlabel('Wingspan (mm)');  ylabel('No. passengers'); zlabel('(no. pax + 2 * no. pax * payload density) / RAC');
    hold on
    end
end