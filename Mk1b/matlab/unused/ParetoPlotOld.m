results = {};

figure
for i=1:200
    filename = strcat('results/17-11-21c/results_c',num2str(i),'.txt');
    fid = fopen(filename,'r');
    if fid < 0
        fprintf('Result %d not found\n!',i);
    else
        results{i} = fscanf(fid,'%f');
        fclose(fid);
        
            plotresult = results{i};
        scatter3(plotresult(7),plotresult(5),plotresult(6),10,plotresult(1),'o');
        colorbar
%         colorbar.Label.String = 'Mean total mass (kg)';
        xlabel('No. passengers'); zlabel('RAC'); ylabel('L/W');
        hold on
    end
end