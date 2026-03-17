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

**Shape over colour for object detection:** Several approaches to card detection failed before Canny edge detection worked. Colour-based detection excluded the card when it matched the skin tone range, and brightness-based detection merged it with the background. This taught me that searching for shape is more robust than searching for appearance.

**Connected skeletons cause measurement drift:** Because the whole hand skeleton is one connected structure, the skeleton walk could drift into adjacent fingers. This wasn't obvious until multiple fingers returned identical path lengths of 601 pixels, meaning the walk was hitting the step limit every time rather than following each individual finger.

### Design Decisions

**Canny edge detection for card detection:** Finds the card's rectangular outline directly rather than relying on colour or brightness, making it work regardless of card colour.

**Column band constraint on skeleton walk:** Restricting each finger's walk to its own horizontal region of the image prevents the path drifting into adjacent fingers or the palm.

### What I Would Do Differently

**Use a rotated bounding box for card measurement:** The axis-aligned bounding box slightly overestimates the card size when it is at an angle. Using `regionprops` with orientation fitting would give a more accurate scale factor.

**Average multiple width scans:** Rather than a single horizontal scan, averaging across several adjacent rows would make the finger width measurement more robust against local noise in the mask.
