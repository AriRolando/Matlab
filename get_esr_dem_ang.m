function PL_cell = get_esr_dem_ang(folder, rep, Nb_f, sli,th)
% Returns a cell array containing the microwave response spectrum in 
% slices of the images angled according to the index map 'sli'. 
%     INPUTS:
%     - 'folder' is the path to the folder containing the repeat subfolders 
%       (\1, \2, \3...),themselves containing the images in presence 
%     and absence of microwave radiation in two subfolders (\DATA and \BG)
%     - 'rep' indicates the number of repeats
%     - 'Nb_f' is the number of images acquired per repeat of the
%     measurement
%     - 'sli' is a index map mapping the slice index to the pixel position.
%     - 'th' is a relative intensity threshold, typically 0.2

PL_cell = cell(1,max(max(sli)));
for l=1:max(max(sli))
    PL_cell{l} = zeros(rep,Nb_f);
end


h = waitbar(0,'Please wait...ESRDEMANG');
c = 0;
for i = 1:rep
    fold_rep = cat(2,folder,num2str(i),'\');
    f_backg = cat(2,fold_rep,'BG\');
    f_data = cat(2,fold_rep,'DATA\');
    
    list = ls(f_backg); list=list(3:end,:);
    
    for j = 1:Nb_f
            A = imread(cat(2,f_backg,list(j,:))); 
%             A = gaussian_hist_filter(A);
            B = imread(cat(2,f_data,list(j,:))); 
%             B = gaussian_hist_filter(B);
            C = medfilt2(uint16(double(A)-double(B)),[2 2]);

            for l = min(min(sli(sli>0))):max(max(sli))
                C_tmp = C(sli==l);
                BW = logical(C_tmp(C_tmp>th));
                PL_val_tmp = PL_cell{l};
                PL_val_tmp(i,j) = mean(mean(C_tmp(BW)));
                PL_cell{l}=PL_val_tmp;
                clear PL_val_tmp
            end
        waitbar(c / (rep*Nb_f))
        c = c+1;

    end
end

close(h)