# rsi (development version)

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
