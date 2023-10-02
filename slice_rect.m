function sli = slice_rect(im, nb_slice, angle)
    % Returns an indexed map of the size of the input microscopy image (im).
    % The indexed map assign each pixel to a slice index. Slices are calculated
    % usign a number (nb_slice) and an angle (angle). The surface is then
    % sliced in the direction perpendicular to a line inclined of an angle
    % defined by angle.
[W, H] = size(im);
s = (sqrt((W*W+H*H))/nb_slice);
sli = zeros(size(im));
for i=1:W
    for j =1:H
        x0 = j;
        y0 = W-i+1;
        for k= 1:nb_slice
            lx = (k-1)*s/cos(angle*pi/180);
            ly = (k-1)*s/sin(angle*pi/180);
            lx1 = (k)*s/cos(angle*pi/180);
            ly1 = (k)*s/sin(angle*pi/180);
            slin = ly*(1-x0/lx);
            slin1 = ly1*(1-x0/lx1);
            if y0>=slin && y0<slin1
                sli(i,j) = k;
                break
            end
        end
    end
end


