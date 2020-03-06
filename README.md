# CBIS-DDSM_CNNs
This is the code to extract ROIs from malignant / benign mammograms from CBIS-DDSM database in MATLAB. It crops abnormal regions based on their dimensions. If these are too small, it extends the region. If these are too big, it takes all region and then resizes it. If the regions (masks) are too wide or tall, it takes two ROIs. All final ROIs are resized at 299X299.

Needs to be done:
1. Augment the database by constructing rotated, scaled, flipped versions of the ROIs.
