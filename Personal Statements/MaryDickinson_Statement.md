# Mary Dickinson Personal Statement 

**Module:** Design of Visual Systems  
**Project:** Ring Size Estimator (`RingSizeGUI.m`)   
**Author:** Mary Dickinson  
**Date:** 12th March 2026  

---

## Personal Contribution

My primary responsibilities on this project were the early-stage image processing pipeline and the user interface. Specifically, I developed:

- **Skin segmentation:** implementing the HSV-based thresholding approach used to isolate skin pixels from the background. This involved tuning the hue, saturation and value ranges to produce a reliable binary mask of the hand across a range of test images.

- **Morphological cleaning:** developing the post-segmentation cleanup steps, including erosion to disconnect touching regions and between-finger shadows.

- **GUI setup:** building the full graphical user interface in MATLAB, including the three-panel layout (Settings, Instructions and Annotated Result), the colour scheme, interactive controls (browse button, radio buttons, dropdown, editable measurement position field), the status bar, and the result display with the UK ring size badge.

- **Shadow rejection development:**  I investigated and attempted to extend the skin segmentation to exclude shadow regions from the mask. Shadows on light backgrounds frequently contain hue and saturation values that fall within the skin tone range, causing them to be incorrectly included. I explored additional constraints and post-processing steps to mitigate this, but the results were inconsistent across different images and lighting conditions. After evaluation, the decision was made to retain the current segmentation approach with stricter instructions for use rather than introduce a less reliable shadow-rejection step.

---

## Reflection

### What I Learned

**Skin segmentation is harder than it looks:** The core challenge I encountered was that shadows cast on a white or light background often produce colours that sit within the HSV skin tone range, particularly in hue and saturation. This means that simply tightening thresholds is not enough; shadows and skin genuinely overlap in colour space in many real photographs. Working on a black background made things considerably worse, as the contrast caused the skin mask to fragment and miss large regions of the hand entirely.

**Overfitting to a single development image is a real risk:** Because the prototype was largely built and tuned around two reference images, the pipeline performed very well on those images and less reliably on others. I started to understand that threshold values and morphological parameters that work for one photograph (and its lighting, camera distance and background) may not generalise. A broader and more varied image bank from the start would have produced a more robust system.

**Circumference from a flat width measurement is an approximation:** The pipeline measures the apparent width of the finger in the image plane and assumes a circular cross-section to compute circumference as π × diameter. Fingers are not perfectly circular, they are roughly oval in cross-section, so this calculation introduces a systematic error. Additionally, rings are worn snugly and compress the soft tissue slightly, meaning the relaxed finger width captured in a photograph represents a larger circumference than the ring actually needs to be. In practice this means the estimated ring size tends to come out larger than the real size a person would wear.

### Design Decisions

**HSV over RGB for skin segmentation:** HSV separates colour information (hue) from lighting intensity (value), making it more robust to changes in brightness than raw RGB thresholds. The hue range used wraps around to capture both ends of the red spectrum, which is important for a range of skin tones.

**Erosion before connected component analysis:** Eroding the skin mask before selecting the largest connected component ensures that any skin-coloured background regions attached to the hand are disconnected first, making it more likely that the largest remaining blob is the hand.

**Shadow rejection not included in final version:** Despite spending time on this, I chose not to include my shadow removal development in the final script. The results were inconsistent, on some images it improved the mask and on others it removed genuine skin pixels or did not recognise the hand. Keeping an unreliable step would have made the overall pipeline less predictable.


### What I Would Do Differently

**I would collect a larger and more diverse image bank before writing any code:** Having a proper dataset covering different skin tones, backgrounds, lighting conditions and camera distances would have let me tune parameters more robustly and exposed problems, like the shadow issue, much earlier in development.

**I would account for finger geometry more carefully:** Rather than treating the finger as a perfect cylinder, I would look into measuring width at multiple orientations or using the known oval cross-section of fingers to apply a correction factor, bringing the estimated circumference closer to the size that would actually fit.

**I would build in a finger compression correction:** Since rings compress the skin when worn, a small downward adjustment to the estimated circumference (or the ring size) would produce more accurate results for the user's actual size.

**I would spend more time on shadow handling earlier:** Rather than attempting it as an extension toward the end, I would treat shadow robustness as a core step from the start, testing potential approaches against a varied image set before committing to any particular method.

