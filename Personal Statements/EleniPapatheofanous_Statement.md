# Eleni Papatheofanous Personal Statement

**Module:** Design of Visual Systems  
**Project:** Ring Size Estimator (`RingSizeGUI.m`)   
**Author:** Eleni Papatheofanous
**Date:** 17th March 2026  

---

## Personal Contribution

The tasks that I was allocated for this project involved calibrating for the reference object and mapping the measurements to a UK ring size. 

* **Reference Object Calibration:** implementing the credit card detection used to compute the pixels-to-mm factor. This involved using Canny edge detection to find rectangular outlines in the image, scoring each candidate by its aspect ratio against the known credit card dimensions (85.6mm x 54mm) and using the best match to derive the scale factor.
* **Finger Width Measurement:** developed the skeleton walk algorithm that travels down each finger from its detected tip, stopping at a configurable position to measure the finger's width via a horizontal scan across the binary mask. This included constratining the walk to each finger's column band to prevent the path wondering into adjacent fingers or the palm.
* **UK Ring Size Mapping:** converting the measured pixel width to millimetres using the calibrated scale factor, computing finger circumference, and matching it against the A-Z UK ring size lookup table to product the final result.

In addition, I was responsible for creating and writing the manual for our final product.

* **Manual and Documentation:** writing the project README, including the system overview, step-by-step usage instructions, reference photo guidance, and example case. This involved translating the technical pipeline into clear, accessible language.
* **Evaluation:** documenting the strengths and limitations of the system, including an analysis of failure cases such as shadow misclassification and card detection unreliability. 


---

## Reflection

### What I Learned

### Design Decisions

### What I Would Do Differently
