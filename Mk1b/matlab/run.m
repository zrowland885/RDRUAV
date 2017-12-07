%% Boot
% Write the path to the aircraft directory here
userpath = 'C:/Users/Zach/Desktop/GDP/RDUAVGit/RDUAV/Mk1b/';
addpath(genpath(userpath));

%% Check user input
fprintf('\n\n\n-------------------------------------------------------\n');
fprintf('\nEXCUTING\n')
fprintf('\nChecking user input...\n')

user_input = input('Input 1 for GUI, 2 for textfile or 3 for iterations: ');

switch user_input
    case 1 % Input via UI (currently broken)
        iVar = Gui();
        AircraftGen(iVar,[0,0]);
    case 2 % Input via textfile (no iteration)
        iVar = ReadDimensions('','input_variables.txt','map');
        AircraftGen(iVar,[0,0]);
    case 3 % Input via textfile (with iteration)
        iIter = ReadDimensions('','input_iteration.txt','itermap');
        iVar = ReadDimensions('','input_variables.txt','map');
        
        % Check runtime
        vi = values(iIter);
        variations = zeros(1,length(vi));
        for i = 1:length(iIter)
            items = vi{i};
            variations(i)=(items{3}-items{1})/items{2}+1;
        end
        numDesigns = prod(variations); % Currently not accounting for duplicate design error - will need to fix!
        
        queststr = strcat({'This will generate '},{num2str(numDesigns)},...
            {' different designs. Continue?'});
        button = questdlg(queststr,'Confirmation');
        
        if strcmp(button,'No') || strcmp(button,'Cancel')
            return
        end
        
        % Run iterations
        i=1;
        count=1;
        IterLoop(iIter,iVar,i,count);
    otherwise
        error('user_input needs to be integer 0, 1 or 2.');
end
