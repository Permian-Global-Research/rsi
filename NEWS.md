# rsi 0.2.1

* `calculate_indices()` gains several new arguments:
  * `overwrite`, which is passed directly to `terra::predict()`. 
    Thanks to @Cidree in #69 (#70).
  * `wopt` and `cores`, which are passed directly to `terra::predict()`.
  * `extra_objects`, which lets you provide additional objects for calculating
    indices inside of the minimal environment used to isolate potentially untrustworthy code.

* Band mapping objects now have a `c()` method, making it easier to add assets
  you wish to download to an existing object. Thanks to @laurenkwick in #71 (#72).

* `stack_rasters()` gains a new argument, `check_crs`, which can be set to `FALSE` 
  to skip checking if all rasters share the same CRS.

* Added a new section to the "How can I?" article on the pkgdown site, with
  pointers on how to "Calculate all possible indices using a certain data set".
  Thanks to @alkimj in #60 (#61).

# rsi 0.2.0

## Deprecations

* `default_query_function()` has been renamed to `rsi_query_api()`. Please 
  update any code using the old name; it will be removed in a future release.

## New features

* `get_stac_data()` gains an argument, `download_function`, which takes a 
  `STACItemCollection` object and returns a data frame, where columns correspond
  to distinct assets, rows correspond to distinct items, and cells contain file
  paths to the downloaded data.

* `rsi_download_rasters()` is a new function that exposes how `get_stac_data()`
  downloads assets. 

* `get_alos_palsar_imagery()` and `alos_palsar_mask_function()` are new 
  functions to help you get and mask ALOS PALSAR imagery, respectively. Thanks 
  to @h-a-graham via #48 and #50.

* `get_naip_data()` is a function for getting National Agricultural Imagery
  Program data from (by default) Planetary Computer. Data covers the continental
  United States.
  
* `landsat_mask_function()` gains an argument, `include`, which lets you specify
  whether you'd like to include pixels that represent land (`"land"`), water
  (`"water"`), or both (`"both"`). Thanks to @mateuszrydzik for the report via
  #37 (#46).

## Bug fixes and other changes

* Progress bars have been split into separate bars for downloading, masking, 
  compositing and so on. 
  
* `get_stac_data()` no longer errors in (rare) circumstances where calculating 
  the intersection of bounding boxes between your AOI and an individual item, 
  performed when setting `composite_function = NULL`, produces a bounding box
  with `ymin` or `xmin` higher than `ymax` or `xmax`.

* Functions will no longer error if you construct their arguments with 
  `glue::glue()` (or otherwise if they have more than one class).

* `stack_rasters()` will only rename bands if `band_names` is the same length as 
  the number of bands in the output raster (or missing, or defined by a 
  function). It will now warn you if these lengths are different. Previously, if 
  you provided more than the required number of band names, `stack_rasters()` 
  would silently ignore the extra names, and would error if you provided fewer 
  names than bands. 
  
* `get_stac_data()` now warns if `asset_names` is `NULL` and there is more 
  than one asset per item.
  
* Functions sending HTTP requests now set a user agent of 
  `rsi (https://permian-global-research.github.io/rsi/)`

# rsi 0.1.2

* `get_stac_data()` no longer includes `mask_band` in its outputs when 
  `composite_function = NULL`. Add this band to `asset_names` to include it in 
  the download.

# rsi 0.1.1

* `get_stac_data()` now removes colons (`:`) from the file names generated when
  `composite_function = NULL`. This means that datetimes are now generally 
  formatted as YYYY-MM-DDTHHMMSSZ, which is slightly dissatisfying but is a 
  valid path on Windows systems (thanks to @jguelat, #29, #32).

* `stacK_rasters()` no longer includes `"-r", "bilinear"` in its default value
  for `gdalwarp_options` (#27, #30). 

* `get_stac_data()` now provides a more informative error when 0 items are found 
  for a given query (#26, #31).

# rsi 0.1.0

* Initial CRAN submission.
