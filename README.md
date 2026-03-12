# Design of Visual Systems: Group Project

**Authors:** Mary Dickinson, Nicole Stott, Eleni Papatheofanous

**Date:** Xth March 2026

## Project Overview
For our group project, we chose to create a Ring Size Estimator. The goal for this was to place your hand flat next to a reference objext (credit card), and take a photo. The system then calculates your finger width, and maps it to a UK ring size.

The pipeline begins with HSV thresholding to segment the skin from the background. Morphological cleaning is then applied to refine the mask, followed by connected component analysis to isolate the largest skin region. Skeletonisation is then performed using bwmorph thinning to extract the centreline of the hand, and fingertips are identified as skeleton endpoints. The width is measured at a specified distance along the finger between the tip to the knuckle. Then, the card is detected via canny edge detection and used as a reference object to convert pixel measurements into millimetres. Finally, the finger width (pixels) is converted to a circumference (millimetres), which is compared against a table of UK ring sizes to return the closest matching letter size.

## Instructions
* Place your hand flat on a **plain, light-coloured background** with fingers **spread apart** (*see reference photo below or on GUI*)
* Place a standard credit card in **portrait orientation** (54 mm wide 85.6 mm tall)
* Take the photo from directly above, an **overhead shot only**
* Click "Browse..." to upload your photo
* Select whether it's a right or left hand
* Select which finger you'd like to measure first
* Select your measurement position (0 indicates the tip of your finger, 1 indicates the knuckle - we'd recommend starting at 0.45)
* Click "Estimate ring size" and let our code do the rest!

### Reference Photo

<img width="659" height="496" alt="REFERENCE" src="https://github.com/user-attachments/assets/49fc3c09-831d-4378-bcf2-8ae1e913c1e7" />


## Example Case
The example case shows a right hand with the index finger selected at position 0.5. The system correctly detected the Oyster card as the reference object, identified all five fingertips, and measured the index finger width at 17.12 mm (circumference 53.80 mm), returning a UK size P.


<img width="1301" height="740" alt="Screenshot 2026-03-12 at 12 07 52" src="https://github.com/user-attachments/assets/11caf4f5-fe53-4fdc-9c7d-6fb5c0be9752" />


## Strengths and Limitations

**Strengths**

The system requires no specialist equipment, only a camera and card, making it accesible and practical for everyday use. The use of a credit card in particular as a reference is particularly given it's a standardised, widely available item. 

The graphical user interface makes the tool straightforward to use. The annotated output clearly displays the measurement line, finger labels, and detected card outline, making results easy to interpret and verify visually. The measurement position parameter also offers flexibility, allowing the user to adjust where along the finger the width is taken to suit different ring styles.

**Limitations**

The skin segmentation relies on HSV thresholding, which is sensitive to lighting conditions. Shadows cast behind the hand can be misidenfitied as skin, increase the finger width measurement. Similarly, if the background is not sufficiently light and plain, the hand may not separate clearly from it. 

The card detection can also be unreliable in certain conditions. If the card is too light in colour, the Canny edge detector may fail to detect it. In some cases, printed details or markings on the card surface are detected instead of the card itself. 

The measurement position parameter also causes errors at higher values. Settings above approximately 0.5 can cause the measured width to span across adjacent fingers rather than isolating the target finger, leading to an overestimate of the finger diameter. 
