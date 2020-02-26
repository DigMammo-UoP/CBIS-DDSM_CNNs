function [start_row, end_row, start_col, end_col] = get_roi_edges(center_col, center_row, img_height, img_width, fuzz_offset_w, fuzz_offset_h, scale_factor, slice_size)

%this function gets the center coordinates of the mask and checks in
%mammogram to see if we can fit it or gets out of image bounds. If it does,
%it alters the windows appropriately to fit inside the image.

%default variables
fuzz_offset_w=0; fuzz_offset_h=0 ; % these are not used in this implementation
scale_factor=1 ; 

% slice margin
slice_margin = fix(slice_size/2) ; 
    
% figure out the new center of the ROI
center_col_scaled = (center_col * scale_factor) ;
center_row_scaled = (center_row * scale_factor) ; 
    
start_col = center_col_scaled - slice_margin + fuzz_offset_h ; 
end_col = start_col + slice_size ; 
if (start_col < 0)
    start_col = 1 ; 
    end_col = slice_size ; 
elseif (end_col > img_width)
        end_col = img_width ; 
        start_col = img_width - slice_size+1 ;
end

start_row = center_row_scaled - slice_margin + fuzz_offset_w ; 
end_row = start_row + slice_size ; 
if start_row < 0
    start_row = 1 ; 
    end_row = slice_size ;
elseif (end_row > img_height)
    end_row = img_height;
    start_row = img_height - slice_size +1;
end
 