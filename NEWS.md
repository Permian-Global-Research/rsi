# rsi (development version)

* Progress bars have been split into separate bars for downloading, masking, 
  compositing and so on. 

* `get_stac_data()` gains an argument, `download_function`, which takes a 
  `STACItemCollection` object and returns a data frame, where columns correspond
  to distinct assets, rows correspond to distinct items, and cells contain file
  paths to the downloaded data.

* `rsi_download_rasters()` is a new function that exposes how `get_stac_data()`
  downloads assets. 

* `default_query_function()` has been renamed to `rsi_query_api()`. Please 
  update any code using the old name; it will be removed in a future release.

* `get_alos_palsar_imagery()` and `alos_palsar_mask_function()` are new 
  functions to help you get and mask ALOS PALSAR imagery, respectively.

* Functions will no longer error if you construct their arguments with 
  `glue::glue()` (or otherwise if they have more than one class).

* `landsat_mask_function()` gains an argument, `include`, which lets you specify
  whether you'd like to include pixels that represent land (`"land"`), water
  (`"water"`), or both (`"both"`). Thanks to @mateuszrydzik for the report via
  #37 (#46).

* Added `get_naip_data()`, a function for getting National Agricultural Imagery
  Program data from (by default) Planetary Computer. Data covers the continental
  United States.

* `stack_rasters()` will only rename bands if `band_names` is the same length as 
  the number of bands in the output raster (or missing, or defined by a 
  function). It will now warn you if these lengths are different. Previously, if 
  you provided more than the required number of band names, `stack_rasters()` 
  would silently ignore the extra names, and would error if you provided fewer 
  names than bands. 

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
