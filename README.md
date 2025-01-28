# Video Orthorectification for Large Scale Particle Image Velocimetry (LSPIV)

## Description
This project provides MATLAB codes to orthorectify each frame of a drone video using an orthophoto. It is designed for applications in Large Scale Particle Image Velocimetry (LSPIV) and similar research areas where precise spatial alignment is critical for analyzing motion or flow dynamics. 

**Author**: Clémence Dorthe - Eidg. Forschungsanstalt für Wald, Schnee und Landschaft WSL- ETH Zürich (adapted from Britta Götz's work - Versuchsanstalt für Wasserbau, Hydrologie und Glaziologie - ETH Zürich)  
**Last Edited**: 27.01.2025

## Features
- Orthorectify each frame of a drone video using an orthophoto through geometric transformations.
- Manual feature selection between video frames and the orthophoto for precision.
- Customizable frame rate and output video duration.
- Easy-to-use MATLAB script for video stabilization and frame extraction.

## Installation
1. Ensure MATLAB is installed on your system.
2. Clone or download this repository: git clone https://github.com/cdorthe/Video_Orthorectification.git


## Usage
To use the code, follow these steps:

1. Open the `MAIN_video_stabilisation.m` script and specify the paths and file names for the following inputs:
   - **Orthophoto**: The reference orthophoto image.
   - **Original video**: The drone video you want to process.
   - **Camera calibration matrix**: The `.mat` file containing the calibration matrix.

2. Define the following paths:
   - The **output folder** where the orthorectified video will be saved.
   - The **output directory** for the extracted frames.

3. Customize the following parameters in the script:
   - **Frame rate**: Line 47 (corresponds to the frame rate of the output video).
   - **Start and end times**: Lines 48-49. Specify the section of the original video to process.

4. Run the code.

5. During execution:
   - You will be prompted to manually define common features between a video frame and the orthophoto.
   - Define a mask to select the region of interest.

6. Once complete, the orthorectified video will be saved in the specified output folder.

---

**Enjoy!**
