# Nicole Stott Personal Statement  
**Module:** Design of Visual Systems  
**Project:** Ring Size Estimator (RingSizeGUI.m)  
**Author:** Nicole Stott  
**Date:** 17th March 2026  

## Personal Contribution  
My primary responsibilities on this project were hand isolation and fingertip detection. Specifically, I developed:

- **Connected component analysis:**  Implementing the selection of the dominant hand region after morphological cleaning by identifying and extracting the largest connected component.

- **Skeletonisation and fingertip detection:**  
Developed the skeletonisation process using morphological thinning to reduce the hand mask to one pixel wide. From that I extracted endpoints to identify fingertip locations. I then clustered nearby endpoints followed by spatial filtering that divides the hand into five regions and selects the highest endpoint in each for more stable and consistent fingertip detection across images.

- **Finger localisation and ordering:**  
I contributed to the logic that sorts detected fingertips from left to right and maps them to specific fingers depending on hand orientation.

- **Measurement refinement development:**  
I investigated and attempted to improve the robustness of the finger width measurement stage. This included exploring different ways of measuring and grouping pixel regions more accurately. While some approaches improved results for specific images, they were inconsistent across different lighting conditions and hand positions which is why we made the decision to not include these refinements in the final version to maintain reliability and consistency.

## Reflection  

### What I Learned  

**Skeletonisation is highly sensitive to input quality:** The accuracy of the skeleton depends directly on the quality of the binary mask. Small segmentation errors can introduce extra branches or false endpoints which can affect fingertip detection, showing how small errors early on can have a bigger impact later on.

**Endpoint detection is noisy without post-processing:** Raw endpoints often produce multiple detections around a single fingertip. Clustering and filtering were needed to produce accurate fingertip positions.

**Assumptions about hand structure simplify but constrain the system:** Dividing the hand into five vertical regions works well when the hand is positioned consistently, but doesn't work so well with variations in orientation.

**Measurement methods are difficult to generalise:** Attempts to improve measurement accuracy showed that approaches that work well on one image can fail on others. Variability in lighting, segmentation quality, and finger positioning makes it difficult to design a universally reliable measurement method.

### Design Decisions  

**Largest connected component selection:** The hand is meant to be the largest object in the image, so selecting the largest connected component after morphological cleaning is an effective way to isolate it.

**Skeleton-based fingertip detection:** Skeleton endpoints allow an efficient alternative to contour-based methods for locating fingertip locations.

**Endpoint clustering for stability:** Raw endpoints are noisy, so clustering nearby detections reduces duplicates and improves consistency.

**Measurement refinements not included in final version:** Other measurement strategies were explored but produced inconsistent results across images, so they were not included to mantain the overall reliability.

## What I Would Do Differently  

I would explore more **robust fingertip detection methods:** Approaches based on contour curvature or shape analysis could provide more reliable fingertip detection than skeleton-based methods.

I would **normalise hand orientation before processing:** Reducing variation in hand pose would make fingertip detection and measurement more consistent.

I would **develop measurement methods less dependent on segmentation quality:** Using multiple cross-sections or averaging techniques could improve robustness compared to a single measurement line.

I would **test improvements on a larger and more varied dataset:** Evaluating methods across diverse images would ensure that refinements generalise rather than overfitting to a small set of examples.
