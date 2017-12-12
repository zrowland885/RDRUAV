function [] = RefreshSw(Part1)
%REFRESHSW Refreshes active SW files

fprintf('\nRefreshing Solidworks...\n')
invoke(Part1,'EditRebuild'); % Refresh SW files
fprintf('\nSolidworks refreshed.\n')

end

