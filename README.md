# Twin-Airy-PSF
Repository containing MATLAB scripts for the **Twin-Airy point-spread function for extended-volume particle localization** paper. It is assumed that the folder structure is preserved as described below. Briefly, each experiment is contained in a seperate directory, which contains subdirectories of MATLAB scripts, and raw data for that experiment. Due to the relatively large size of the data , it is hosted by the University and Glasgow. The raw data can be found here: http://dx.doi.org/10.5525/gla.researchdata.854.

## Supplementary Data and Codes: Twin-Airy point-spread function for extended-volume particle localization ##

Authors: Yongzhuang Zhou, Paul Zammit, Vytautas Zickus, Jonathan M. Taylor and Andrew R. Harvey

Contact Information: andy.harvey@glasgow.ac.uk


## General Introduction ##

This supplementary contains experimental data for the zebrafish blood flow tracking and necessary codes to localize and track the tracer particles. The processed results as a list of tracer trajectories and a video visualization are also included.

The datasets including the point-spread function (PSF) z stack and the blood flow tracking were collected in the Imaging Concepts Group lab at the University of Glasgow between November 2017 and January 2019.

The datasize for precision tests are about 300MB and about 12.4GB for the blood flow tracking.


## Experiment Equipment ##

Experiments were performed on a Nikon Eclipse Ti microscope equipped with a 20x 0.5NA and a 60x, 1.4NA objectives. It was modified to have a home-built laser illumination and a 4f relay imaging system which employs a twin-Airy phase mask that was custom-made by PowerPhotonic Ltd., Scotland. The 20x, 0.5NA objective was used to measure the zebrafish blood flow with a 2048x2048 pixel Andor Zyla sCMOS camera (6.5 micron pixel size) to record the raw data. The 60x, 1.4NA system was used to perform the precision test using quantum dots with a 1024x1024 pixel Andor EMCCD camera (13 micron pixel size) to record the raw data.


## Description of Contents ##

This supplementary includes the following files:

_"Raw_data_and_codes_for_blood_flow_tracking.zip"_

_"Raw_data_and_codes_for_precision_test.zip"_

_"Codes_for_Cramer_Rao_lower_bound_analysis.zip"_

_"Some_presaved_results.zip"_

### **Raw_data_and_codes_for_blood_flow_tracking.zip** ###

"Raw_data_and_codes_for_blood_flow_tracking.zip" has three folders:

#### **Raw_data_PSF_stack** #### 

Folder _"Raw_data_PSF_stack"_ contains the calibration PSF stack, recorded with a single fluorescent bead scanned through the depth range of 180 microns with 1 micron step size. The PSF images are named as "psf (_i_).tif" with _i_ indicating its numbering in the axial direction. In this dataset, psf (91).tif corresponds to the in-focus position.


#### **Raw_data_blood_flow** ####

Folder _"Raw_data_blood_flow"_ contains the raw images of tracers flowing in the blood vessels of a 3-day-post-fertilization zebrafish, recorded at a frame rate of 50Hz. A total of 5000 frames are included, and the recorded images are named as "t*k*.tif" with _k_ indicating the frame number.

#### **Codes_blood_flow_tracking** ####

Folder _"Codes_blood_flow_tracking"_ contains the MATLAB scripts and functions that were used to process the zebrafish blood flow measurement data, i.e. to localize and track the tracer beads in 3D.

_"calib.m"_ performs the xyz calibration using the recorded PSF calibration stack, outputting file named _"CALIB.mat"_ with its three columns being the two-lobe disparity, the axial coordinate, and the lateral shift of the PSF;

_"gaussFit.m"_ is a function that takes an input image (i.e. a deconvolved image) and an initial guess of the centroid coordinates, and returns the estimated coordinates by fitting a 2D Gaussian function;

_"twoD_Gauss_func.m"_ determines the 2D Gaussian function used for centroiding;

_"IMREC.m"_ is a function that recovers the images with a Wiener filter, it performs the deconvolution of the input image with the input PSF;

_"Centro.m"_ is a function that emoloys _"gaussFit.m"_ to find the intensity centroids within a deconvolved image, returning a list of centroids with the Gaussian fitting parameters;

_"MatchCentroids.m"_ performs the task of matching the centroids of the deconvolved upper lobe and the deconvolved lower lobe;

_"Multi_frame_localization.m"_ performs the 3D localization of each tracer bead frame by frame, using the calibration data. It generates and saves the localization results in _"LocsList.mat"_.

_"Flow_tracking_plot.m"_ links the 3D tracer locations using the particle tracking software developed by Crocker et al., in particular, the function _track.m_ was used here (see http://www.physics.emory.edu/faculty/weeks//idl/ for more information). It also displays the successfully tracked trajectories.

_"Plot_trajectories.m"_ shows the successfully localized and tracked tracers in a 3D plot.

Note: The correct order to run the above code as indicated in the algorithm is: 

(1) _"calib.m"_ to perform the xyz calibration. 

(2) _"Multi_frame_localization.m"_ to localize detected tracer particles frame by frame. 

(3) _"Flow_tracking_plot.m"_ to link the localized tracer coordinates and to show the particle tracking results.

However, since intermediate results have been pre-saved, one may run _"Flow_tracking_plot.m"_ directly.


------------------------------------------------

### **Raw_data_and_codes_for_precision_test.zip** ###

_"Raw_data_and_codes_for_precision_test.zip"_ contains two folders:

#### **High_NA_quantum_dots_scenario** ####
Folder _"High_NA_quantum_dots_scenario"_ is the quantum dots measurement using the 1.4NA system, it  further has three subfolders:

##### **Raw_data_PSF_stack** #####

Folder _"Raw_data_PSF_stack"_ contains the calibration PSF stack, recorded with a single fluorescent bead scanned through the depth range of 11 microns with 1 micron step size. The PSF images are named as "psf*i*_X1.tif" with _i_ indicating its numbering in the axial direction. In this dataset, "psf5_X1.tif" corresponds to the in-focus position. Note that these data were recorded on a 1.4NA, 60x imaging system, in contrast to the blood flow data where a 0.5NA, 20x imaging system was used. 

##### **Raw_data_precision_test** #####

Folder "Raw_data_precision_test" contains the raw images of an immobilized quantum dot recorded at 11 different axial positions corresponding to the 11 sub-folders. At each axial position, 1000 frames were taken in a time sequence to quantify the precision of the 3D localization. The images are named "t_X*i*.tif" with _i_ indicating the number of frames.

##### **Codes_precision_test** #####

In addition to the functions and scripts mentioned above, this folder contains the following scripts:

_"Precision_depth.m"_ performs the precision test, i.e. the localization of 1000 frames throughout the whole depth range and estimate the standard deviation in the estimated x, y and z coordinates. The list of locations and the deconvolved images will be saved in the current folder after running this script as _Xs.mat_, _Ys.mat_, _Zs.mat_, _SRP.mat_, and _SRN.mat_.

_"Show_results.m"_ displays the results of the precision test, including the precision as a function of depth, two-lobe-disparity as a function of depth, PSF lateral shift as a function of depth and the recovered PSFs for each depth superimposed. It uses the saved results of the script _"Precision_depth.m"_, namely _Xs.mat_, _Ys.mat_, _Zs.mat_, _SRP.mat_, and _SRN.mat_.

Note: The correct order to run the above code as indicated in the algorithm is: 

(1) _"calib.m"_ to perform the xyz calibration. 

(2) _"Precision_depth.m"_ to localize the imaged quantum dot frame by frame at each axial position. 

(3) _"Show_results.m"_ to displays the results of the precision test. 

However, since intermediate results have been pre-saved, one may run _"Show_results.m"_ directly.

**Low_NA_fluorescent_beads_scenario**
Folder _"Low_NA_fluorescent_beads_scenario"_ contains the fluorescent bead measurement approximating the blood flow scenario using the 0.5NA system, it has a similar substructure as **High_NA_quantum_dots_scenario**.


### **Code_for_Cramer_Rao_lower_bound_analysis.zip** ###

_"Code_for_Cramer_Rao_lower_bound_analysis.zip"_ contains two MATLAB scripts for the Cramer-Rao lower bound simulations.

_"Calculate_Cramer_Rao_lower_bounds.m"_ calculates and saves the Cramer-Rao lower bounds for the twin-Airy PSFs and single airy PSFs with various peak modulations (i.e. alpha) based on shot given the specified parameters including wavelength, numerical aperture, magnification, pixel size, number of detected photons etc.

_"Show_CRLB_results.m"_ loads and displays the saved results from _"Calculate_Cramer_Rao_lower_bound.m"_.

### **Some_presaved_results.zip** ###

_"Some_presaved_results.zip"_ holds saved results for both the precision test and the blood flow measurement. In case one does not want to run the time consuming matlab scripts but would like to know more details about the experimental results.

_"Flow_trajectory_list.xlsx"_ is a list of the locations and trajectories of the successfully localized and tracked tracer beads. There are four columns in the excel file with its first three being the xyz coordinates in microns, the fourth column being the frame number and the fifth column being the assigned trajectory number.

_"Supplementary video_In-vivo blood flow tracking with TA-PSF.mp4"_ shows on the left the raw data frames and on the right the corresponding reconstructed tracer trajectories with red dots indicating tracers in the current frame.

_"Precision_test_highNA"_ are the estimated xyz locations of a quantum dot for 1000 frames (row) at 9 axial positions (column), the standard deviation of which gives the experimental localizaiton precision. _"Precision_test_lowNA"_ are the estimated xyz locations of a fluorescent bead for 100 frames (row) at 12 axial positions (column).


## Known issues ##
On Ubuntu 18.04 and MATLAB 2019b figure titles appear only on the last figure. However, the numerical results appear to be the same when running on Windows 10 and MATLAB 2019a or Ubuntu 18.04 MATLAB 2019b.


## Licenses ##
The code in this repository is under GNU General Public License v3.0 https://www.gnu.org/licenses/gpl-3.0.en.html
The raw data and images produced are under CC BY 4.0 license https://creativecommons.org/licenses/by/4.0/
