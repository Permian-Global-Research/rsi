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
