# CBIS-DDSM_CNNs
This is the code to extract ROIs from malignant / benign mammograms from CBIS-DDSM database in MATLAB. It crops abnormal regions based on their dimensions. If these are too small, it extends the region. If these are too big, it takes all region and then resizes it. If the regions (masks) are too wide or tall, it takes two ROIs. All final ROIs are resized at 299X299.

## Usage:
```
crop_ROIs_new('TRAIN') (to extract MALIGNANT/BENIGN ROIs in the training directory)
crop_ROIs_new('TEST') (to extract MALIGNANT/BENIGN ROIs in the testing directory)
```
You need to provide the test_masses_roi.txt / train_masses_roi.txt file when prompted only to get the filenames.
The rest of the information in the file is DISREGARDED.

## Needs to be done:
1. Augment the database by constructing rotated, scaled, flipped versions of the ROIs.
