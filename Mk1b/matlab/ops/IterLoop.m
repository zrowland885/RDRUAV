function [i,count] = IterLoop(iIter,iVar,i,count)
%ITERLOOP Loops through every possible aircraft configuration for given iterations

vi = values(iIter);
ki = keys(iIter);
items = vi{i};
iVarOld = 'none';

for j=items{1}:items{2}:items{3}                                            % Iterate over set range
%     fprintf('\nj = %d, i = %d',j,i) % for debugging
    iVar(ki{i}) = j;                                                        % Write the latest iteration value to iVar
    if iVar(ki{i}) ~= iVarOld
        AircraftGen(iVar,[count,j])                                             % Run AircraftGen with current iVar and id
    end
    iVarOld = iVar(ki{i});                                                  % Store to prevent repeats
    count = count + 1;                                                      % Update the count to 'move down a level'
    if i < length(vi)                                                       % Check if there are more levels to move down
        i=i+1;                                                              % Set i to move to the next level
        fprintf('\nNext variable!\n');                                      % Alert move down to the next variable level
        [i,count]=IterLoop(iIter,iVar,i,count);                             % Call the next level
    end
end

i=i-1;                                                                      % Come back up a variable level
fprintf('\nPrevious variable!\n');                                          % Alert move up to the previous variable level
end