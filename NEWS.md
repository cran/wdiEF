# wdiEF 1.0.4 (2025-10-20)


- Fixed an issue where the package would crash if the raster FVC had no values equal to 1.
- The function now ensures that FVC values are properly handled to avoid computational errors.
- FVC normalization is now silent: the function handles FVC values without issuing warnings.
---
This update improves the robustness of the package for cases where the full range of FVC values is not present.
