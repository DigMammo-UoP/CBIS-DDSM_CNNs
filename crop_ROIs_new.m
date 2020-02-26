function crop_ROIs_new()



warning off
% This function collects the malignant / benign ROIs of the DDSM curated DB
% in TEST / TRAIN directories for Tensorflow using the mask images
% DESCRIPTION FILE HEADERS
% 1. patient_id
% 2. breast_density (1-4)
% 3. LEFT/RIGHT
% 4. image_view (CC/MLO)
% 5. abnormality_id (1-6)
% 6. mass_shape
% 7. mass_margins (circimscribed, ill-defined, ...)
% 8. assesment (0-5)
% 9. pathology (malignant/benign)
% 10. subtlety (0-5)


%need to be in the folder /Research/Mammography/CBIS-DDSM/
Folder   = '/Research/Mammography/CBIS-DDSM/' ; 
FileList = dir(fullfile(Folder, '**', '*.dcm')) ; %this is a structure with filenames and folders for each dcm image in the DDSM database

%write folder
write_folder   = '/Research/Mammography/CBIS-DDSM/MYROIS/TEST/' ; 

%open file with all information for ROIS
roifile = uigetfile('*.txt', 'Select file with ROIs information') ; 
f2 = fopen(roifile,'r') ; %txtfile is the file that has the listing of the dcom masses files
file_index = 0 ; %this is a counter to construct new ROIs filenames

while(~feof(f2))
       try
        line = fgetl(f2); %reads every dcom image one-by-one
        end_path_ptr = strfind(line, '/1-ROI') ; 
        imagepath = line(17:end_path_ptr) ; 
        ptr2 = strfind(imagepath, '/');
        imagepath = imagepath(1:ptr2-3) ; 
        for i= 1:length(FileList)
            if (strfind(FileList(i).folder, imagepath) ~=0)
                mammo_index = i ;
                full_mammo_file = sprintf('%s/%s', FileList(mammo_index).folder,FileList(mammo_index).name )  ;
                break ; 
            end
        end
        fprintf('Found match: %s\n', full_mammo_file) ; 
        
        %extract data for ROI
        ptr = strfind(line, '.dcm ') ;
        full_mask_file = line(1:ptr+3) ; 
        
              
        %show full image + region to check if all is OK
        mam_info = dicominfo(full_mammo_file) ;
        PatientID = mam_info.PatientID ; 
        I_mammo = dicomread(mam_info) ;
        mam_info = dicominfo(full_mask_file) ;
        I_mask = dicomread(mam_info) ;
        
        [img_slice, img_slice1, img_slice2, big_flag] = create_roi_slices(I_mask, I_mammo, 299) ; 
        if (big_flag==0)
            figure(2) ; imshow(img_slice) ; title(mam_info.PatientID) ; 
        else
            figure(3) ; title('VERY BIG MASS')
            subplot(1,2,1) ; imshow(img_slice1) ; title(mam_info.PatientID) ; 
            subplot(1,2,2) ; imshow(img_slice2) ; title(mam_info.PatientID) ; 
        end
        
        file_index = file_index+1 ; 
        data = line(ptr+5:end) ; 
        
        %get info if MALIGNANT / BENIGN
        if strfind(data, 'M')
            type = 'MALIGNANT' ;
            image_name = sprintf('%sMALIGNANT/%s_MALIGNANT_%05d.png', write_folder, PatientID, file_index) ; %the output type is PNG 8-bit and the filename is a five-digit fname (e.g. 00012.jpg)
            if (big_flag==0)
                imwrite((img_slice), image_name, 'PNG') ; 
            else
                disp('INSIDE!') ; 
                name1 = sprintf('1_%s', image_name) ;
                name2 = sprintf('2_%s', image_name) ;
                imwrite((img_slice1), 'PNG') ;
                imwrite((img_slice2), name2, 'PNG') ; 
            end
               
        else
                
            type = 'BENIGN' ; 
            image_name = sprintf('%sBENIGN/%s_BENIGN_%05d.png', write_folder, PatientID, file_index) ; %the output type is PNG 8-bit and the filename is a five-digit fname (e.g. 00012.jpg)
            if (big_flag==0)
                imwrite((img_slice), image_name, 'PNG') ; 
            else
                disp('INSIDE!') ; 
                name1 = sprintf('1_%s', image_name) ;
                name2 = sprintf('2_%s', image_name) ;
                imwrite((img_slice1), name1, 'PNG') ;
                imwrite((img_slice2), name2, 'PNG') ; 
            end
        end
    end   
end
fclose(f2) ; 
