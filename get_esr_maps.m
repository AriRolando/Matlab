function C = get_esr_maps(fold,sz,PL_cell)
% Return a cell array containing a vector and a matrix. This calculates the
% microwave frequency vector and a matrix where each line is the microwave
% response spectrum of a slice of PL_cell array.
% INPUTS: 
%      -fold : directory path to the folder where the repetition of the
%      measurement are found
%      -sz : median filter size
%      -PL_cell: cell array containing the microwave response spectrum per
%      slice of the surface map.
% OUTPUTS:
%      C:  cell array containing a vector and a matrix, microwave frequency
%       vector and a matrix where each line is the microwave
%       response spectrum of a slice of PL_cell array

folder = cat(2,fold, '1\BG\');
C = cell(1,2);
    
    list = ls(folder); list=list(3:end,:);
    
[a,~]= size(list);
xf = zeros(a,1);

for j=1:a
    xf(j) = str2double(list(j,4:end-5));
end

[~,Nfreq] = size(PL_cell{1});
M = zeros(length(PL_cell),Nfreq);
for i=1:length(PL_cell)
    M(i,:) = 2-medfilt1(mean(PL_cell{i},1),sz)./mean(medfilt1(mean(PL_cell{i},1),sz));
end

C{1} = xf;
C{2} = M;