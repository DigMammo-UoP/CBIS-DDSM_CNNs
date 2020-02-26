function [img_slice, img_slice_1, img_slice_2, big_flag] = create_roi_slices(mask_image_arr, full_image_arr, slice_size)



big_flag=0 ; % a floag to switch on when the ROI is VERY big
img_slice = [] ; img_slice_1 = [] ; img_slice_2 = [] ; %the outputs of the roi extraction program. 
slice_size=299 ; % defaults to 299X299 window

full_slice_size = slice_size * 2;
fuzz_offset_h = 0 ; fuzz_offset_w = 0;

% get the mask, if the mask is bigger than the slice we will create multiple slices using the corners of the mask. 
[center_row, center_col, too_big, mask_size] = create_mask(mask_image_arr) ; 

% get some info we will need later
[image_h, image_w] = size(full_image_arr) ; 
mask_height = mask_size(1) ; 
mask_width = mask_size(2) ; 
roi_size = max([mask_height, mask_width]) ; %rectangular roi with biggest dimension

% if the ROI is smaller than the slice do some offsetting, otherwise leave
% it as is - NOT USING IT
if (roi_size <= (full_slice_size - 60))
    %fuzz_offset_h, fuzz_offset_w = get_fuzzy_offset(roi_size + 10, slice_size=full_slice_size);
else
    fuzz_offset_h = 0 ; fuzz_offset_w = 0;
end

% define boundaries for the abnormality
[start_row, end_row, start_col, end_col] = get_roi_edges(center_col, center_row, image_h, image_w, fuzz_offset_w, fuzz_offset_h, 1, full_slice_size) ; 

% slice the ROI out of the image
img_slice = full_image_arr(start_row:end_row, start_col:end_col) ; 

%cut the slice down to half size
img_slice = imresize(img_slice, [slice_size,slice_size]) ; 



% if the ROI is either too big or too small cut out the full ROI and zoom it to size (less than 400 pixels)
if (too_big || (roi_size <= fix(full_slice_size / 1.5)))
    % Add a 20% margin to the ROI area
    roi_margin = roi_size * 0.20 ; 
    roi_size_w_margin = roi_size + roi_margin ; 

    % set a lower bound to the zoom so we don't lose too much info by zooming in, 1.5x zoom seems a good max
    if (roi_size_w_margin <= 400)
        zoom_roi_size_w_margin = 400 ; 
    else
        zoom_roi_size_w_margin = roi_size_w_margin ; 
    end
    % define a random offset so the images are not all - NOT IMPLEMENTED
    %[fuzz_offset_h, fuzz_offset_w] = get_fuzzy_offset(roi_size, zoom_roi_size_w_margin) ; 

    % define boundaries for the ROI
    [start_row, end_row, start_col, end_col] = get_roi_edges(center_col, center_row, image_h, image_w, fuzz_offset_w, fuzz_offset_h, 1, zoom_roi_size_w_margin);

    % slice the ROI out of the image
    img_slice = full_image_arr(start_row:end_row, start_col:end_col) ; 
    %resize the slice
    img_slice = imresize(img_slice, [slice_size,slice_size]) ; 

end

  
% if the ROI is either very wide or very high we will cut it into two slices with each end in one if it is higher than wide
if ((mask_height >= mask_width * 1.5) && too_big)
    % each slice will be the shorter dimension or the width square
    cropped_full_slice_size = mask_width ; 
    % Start the top slice at from 10 to 25 pixels above the upper edge of the ROI
    top_offset = randi([20,50],1) ; 
    start_row_1 = center_row - (fix(mask_height/2)) - top_offset ; 
    end_row_1 = start_row_1 + cropped_full_slice_size ; 
    % end the bottom slice from 10 to 25 pixels below the lower edge of the ROI
    bottom_offset = randi([20,50],1) ; 
    end_row_2 = center_row + (fix(mask_height/2)) + bottom_offset ; 
    start_row_2 = end_row_2 - cropped_full_slice_size ; 
    % the left and right boundaries stay the same
    start_col = center_col - (fix(cropped_full_slice_size/2)) ; 
    end_col =  start_col + cropped_full_slice_size ; 
    % create slice 1
    img_slice_1 = full_image_arr(start_row_1:end_row_1,start_col:end_col) ; 
    % check that the corners don't go over the edges of the image
    img_slice_1 = check_slice_corners(img_slice_1, full_image_arr, [start_row_1,end_row_1,start_col,end_col], cropped_full_slice_size) ; 
    % create slice 2
    img_slice_2 = full_image_arr(start_row_2:end_row_2,start_col:end_col) ; 
    % check that the corners don't go over the edges of the image
    img_slice_2 = check_slice_corners(img_slice_2, full_image_arr, [start_row_2,end_row_2,start_col,end_col], cropped_full_slice_size) ; 
    % if the slice is properly shaped cut it down to size and add it to the list
    img_slice_1 = imresize(img_slice_1, [slice_size,slice_size]) ; 
    % if the slice is properly shaped cut it down to size and add it to the list
    img_slice_2 = imresize(img_slice_2, [slice_size,slice_size]) ; 
    big_flag=1 ; 
    
end
        
%if it is wider than high
if ((mask_width >= mask_height * 1.5) && too_big)
    % each slice will be the shorter dimension or the width square
    cropped_full_slice_size = mask_height ; 
    % Start the top slice at from 10 to 25 pixels above the upper edge of the ROI
    top_offset = randi([20,50],1) ;
    start_col_1 = center_col - (fix(mask_width/2)) - top_offset;
    end_col_1 = start_col_1 + cropped_full_slice_size;
    % end the bottom slice from 10 to 25 pixels below the lower edge of the ROI
    bottom_offset = randi([20,50],1) ;
    end_col_2 = center_col + (fix(mask_width/2)) + bottom_offset;
    start_col_2 = end_col_2 - cropped_full_slice_size;
    % the left and right boundaries stay the same
    start_row = center_row - (fix(cropped_full_slice_size/2)) ; 
    end_row =  start_row + cropped_full_slice_size ; 
    % create slice 1
    img_slice_1 = full_image_arr(start_row:end_row,start_col_1:end_col_1) ; 
    % check that the corners don't go over the edges of the image
    img_slice_1 = check_slice_corners(img_slice_1, full_image_arr, [start_row,end_row,start_col_1,end_col_1], cropped_full_slice_size) ; 
    % create slice 2
    img_slice_2 = full_image_arr(start_row:end_row,start_col_2:end_col_2) ; 
    % check that the corners don't go over the edges of the image
    img_slice_2 = check_slice_corners(img_slice_2, full_image_arr, [start_row,end_row,start_col_2,end_col_2], cropped_full_slice_size) ; 
    % if the slice is properly shaped cut it down to size and add it to the list
    img_slice_1 = imresize(img_slice_1, [slice_size,slice_size]) ; 
    % if the slice is properly shaped cut it down to size and add it to the list
    img_slice_2 = imresize(img_slice_2, [slice_size,slice_size]) ; 
    big_flag=1 ; 
end
