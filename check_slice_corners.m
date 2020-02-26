function [image_slice] = check_slice_corners(image_slice, full_image_arr, corners, slice_size)

%this function checks if the slice of the mammogram that has the mass /
%abnormality, has valuable data (intensity > 25), and the corners are inside the full_mammogram.

% corners: array with [left, right, bottom, top] corners of slice

[h, w] = size(image_slice) ; 
[image_h, image_w] = size(full_image_arr) ; 

%if the slice is the right shape return it
if ((h == slice_size) && (w == slice_size) && (mean(mean(image_slice))) > 25)
    disp('right shape') ; 
%else try to reframe it by checking each corner
else
    if (corners(1) < 0)
        corners(1) = 1;
        corners(2) = slice_size;
    elseif (corners(2) > image_h)
        corners(2) = image_h ; 
        corners(1) = image_h - slice_size +1 ;
    end
    if (corners(3) < 0)
        corners(3) = 1 ; 
        corners(4) = slice_size ; 
    elseif (corners(4) > image_w)
        corners(4) = image_w ; 
        corners(3) = image_w - slice_size +1; 
    end           
    image_slice = full_image_arr(corners(1):corners(2),corners(3):corners(4)) ; 
end
