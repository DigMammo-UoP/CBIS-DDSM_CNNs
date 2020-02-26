function [center_row, center_col, too_big, mask_size] = create_mask(mask_arr)

% input: path to mask image PNG
% opens the mask, reduces its size by half, finds the borders of the mask and returns the center of the mass
% if the mass is bigger than the slice it returns the upper left and lower right corners of the mask as tuples
% which will be used to create multiple slices
% returns: center_row - int with center row of mask, or tuple with edges of the mask if the mask is bigger than the slice
%          center_col - idem
%          too_big - boolean indicating if the mask is bigger than the slice

% some images have white on the borders which may be something a convnet can use to predict. To prevent this,
% if the full image has more than 50,000 white pixels we will trim the edges by 20 pixels on either side
%if sum(sum(full_image_arr >= 225)) > 20000
%    full_image_arr = remove_margins(full_image_arr)
%    mask_arr = remove_margins(mask_arr)
%    if output:
%        print("Trimming borders", mask_path)

% make sure the mask is the same size as the full image, if not there is a problem, don't use this one

% if (mask_arr.shape ~= full_image_arr.shape)
%     # see if the ratios are the same
%     mask_ratio = mask_arr.shape[0] / mask_arr.shape[1]
%     image_ratio = full_image_arr.shape[0] / full_image_arr.shape[1]
% 
%     if abs(mask_ratio - image_ratio) <=  1e-03:
%         if output:
%             print("Mishaped mask, resizing mask", mask_path)
% 
%         # reshape the mask to match the image
%         mask_arr = imresize(mask_arr, full_image_arr.shape)
% 
%     else:
%         if output:
%             print("Mask shape:", mask_arr.shape)
%             print("Image shape:", full_image_arr.shape)
%         print("Mask shape doesn't match image!", mask_path)
%         return 0, 0, False, full_image_arr, 0
% 
slice_size=598 ; %this is used as the final rois we want to be 299X299

% find the borders of the mask (pixels that are equal to 255)
[r,c,v] = find(mask_arr==255);

% figure out where the corners are
first_col = min(c) ; 
last_col = max(c) ; 
center_col = fix((first_col + last_col) / 2) ; 
first_row = min(r) ; 
last_row = max(r) ; 
center_row = fix((first_row + last_row) / 2) ; 

col_size = last_col - first_col ; 
row_size = last_row - first_row ; 

mask_size = [row_size, col_size] ; 

% signal if the mask is bigger than the slice
too_big = false ; 
if (((last_col - first_col) > (slice_size + 30)) || ((last_row - first_row) > (slice_size + 30)))
    too_big = true ; 
end
