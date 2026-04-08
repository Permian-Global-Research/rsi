# Changelog

## rsi (development version)

- Test fixes for CRAN

## rsi 0.3.2

CRAN release: 2025-01-22

- Failed downloads and merges should now be handled a bit better. Thanks
  to [@h-a-graham](https://github.com/h-a-graham) for
  [\#89](https://github.com/Permian-Global-Research/rsi/issues/89) and
  to [@lucas-johnson](https://github.com/lucas-johnson) for
  [\#81](https://github.com/Permian-Global-Research/rsi/issues/81).

- If `composite = NULL` and the resource has duplicated asset
  timestamps,
  [`get_stac_data()`](https://permian-global-research.github.io/rsi/dev/reference/get_stac_data.md)
  will now generate unique filenames (rather than saving multiple files
  to the same path). Thanks to
  [@h-a-graham](https://github.com/h-a-graham) for
  [\#89](https://github.com/Permian-Global-Research/rsi/issues/89) and
  [\#90](https://github.com/Permian-Global-Research/rsi/issues/90).

## rsi 0.3.1

CRAN release: 2024-10-22

- A test that requires online resources is now skipped on CRAN. There
  are no user-facing changes in this version.

## rsi 0.3.0

CRAN release: 2024-10-02

- rsi has been peer-reviewed by the rOpenSci project! Huge thank you to
  [@OldLipe](https://github.com/OldLipe) and
  [@mdsumner](https://github.com/mdsumner) for their extremely helpful
  reviews.

- [`sentinel2_mask_function()`](https://permian-global-research.github.io/rsi/dev/reference/sentinel2_mask_function.md)
  now masks out SCL values of 2, “DARK_AREA”, by default.

- [`landsat_mask_function()`](https://permian-global-research.github.io/rsi/dev/reference/landsat_mask_function.md)
  gains an argument, `masked_bits`, that allows you to specify the
  values you wish to mask out by bit values rather than just integers.
  Refer to the Landsat science product guide for further information on
  what bit values represent for your platform of interest.

- [`get_stac_data()`](https://permian-global-research.github.io/rsi/dev/reference/get_stac_data.md)
  no longer fails if downloading an asset fails, but instead returns a
  raster with all available data. This may still fail when a single
  asset fails to download while downloading multiple assets combined
  within a single raster; please open an issue if this happens to you!
  Thanks to [@laurenkwick](https://github.com/laurenkwick) in
  [\#74](https://github.com/Permian-Global-Research/rsi/issues/74)
  ([\#75](https://github.com/Permian-Global-Research/rsi/issues/75)).

## rsi 0.2.1

CRAN release: 2024-06-27

- [`calculate_indices()`](https://permian-global-research.github.io/rsi/dev/reference/calculate_indices.md)
  gains several new arguments:

  - `overwrite`, which is passed directly to
    [`terra::predict()`](https://rspatial.github.io/terra/reference/predict.html).
    Thanks to [@Cidree](https://github.com/Cidree) in
    [\#69](https://github.com/Permian-Global-Research/rsi/issues/69)
    ([\#70](https://github.com/Permian-Global-Research/rsi/issues/70)).
  - `wopt` and `cores`, which are passed directly to
    [`terra::predict()`](https://rspatial.github.io/terra/reference/predict.html).
  - `extra_objects`, which lets you provide additional objects for
    calculating indices inside of the minimal environment used to
    isolate potentially untrustworthy code.

- Band mapping objects now have a [`c()`](https://rdrr.io/r/base/c.html)
  method, making it easier to add assets you wish to download to an
  existing object. Thanks to
  [@laurenkwick](https://github.com/laurenkwick) in
  [\#71](https://github.com/Permian-Global-Research/rsi/issues/71)
  ([\#72](https://github.com/Permian-Global-Research/rsi/issues/72)).

- [`stack_rasters()`](https://permian-global-research.github.io/rsi/dev/reference/stack_rasters.md)
  gains a new argument, `check_crs`, which can be set to `FALSE` to skip
  checking if all rasters share the same CRS.

- Added a new section to the “How can I?” article on the pkgdown site,
  with pointers on how to “Calculate all possible indices using a
  certain data set”. Thanks to [@alkimj](https://github.com/alkimj) in
  [\#60](https://github.com/Permian-Global-Research/rsi/issues/60)
  ([\#61](https://github.com/Permian-Global-Research/rsi/issues/61)).

## rsi 0.2.0

CRAN release: 2024-03-29

### Deprecations

- [`default_query_function()`](https://permian-global-research.github.io/rsi/dev/reference/deprecated.md)
  has been renamed to
  [`rsi_query_api()`](https://permian-global-research.github.io/rsi/dev/reference/rsi_query_api.md).
  Please update any code using the old name; it will be removed in a
  future release.

### New features

- [`get_stac_data()`](https://permian-global-research.github.io/rsi/dev/reference/get_stac_data.md)
  gains an argument, `download_function`, which takes a
  `STACItemCollection` object and returns a data frame, where columns
  correspond to distinct assets, rows correspond to distinct items, and
  cells contain file paths to the downloaded data.

- [`rsi_download_rasters()`](https://permian-global-research.github.io/rsi/dev/reference/rsi_download_rasters.md)
  is a new function that exposes how
  [`get_stac_data()`](https://permian-global-research.github.io/rsi/dev/reference/get_stac_data.md)
  downloads assets.

- [`get_alos_palsar_imagery()`](https://permian-global-research.github.io/rsi/dev/reference/get_stac_data.md)
  and
  [`alos_palsar_mask_function()`](https://permian-global-research.github.io/rsi/dev/reference/alos_palsar_mask_function.md)
  are new functions to help you get and mask ALOS PALSAR imagery,
  respectively. Thanks to [@h-a-graham](https://github.com/h-a-graham)
  via [\#48](https://github.com/Permian-Global-Research/rsi/issues/48)
  and [\#50](https://github.com/Permian-Global-Research/rsi/issues/50).

- `get_naip_data()` is a function for getting National Agricultural
  Imagery Program data from (by default) Planetary Computer. Data covers
  the continental United States.

- [`landsat_mask_function()`](https://permian-global-research.github.io/rsi/dev/reference/landsat_mask_function.md)
  gains an argument, `include`, which lets you specify whether you’d
  like to include pixels that represent land (`"land"`), water
  (`"water"`), or both (`"both"`). Thanks to
  [@mateuszrydzik](https://github.com/mateuszrydzik) for the report via
  [\#37](https://github.com/Permian-Global-Research/rsi/issues/37)
  ([\#46](https://github.com/Permian-Global-Research/rsi/issues/46)).

### Bug fixes and other changes

- Progress bars have been split into separate bars for downloading,
  masking, compositing and so on.

- [`get_stac_data()`](https://permian-global-research.github.io/rsi/dev/reference/get_stac_data.md)
  no longer errors in (rare) circumstances where calculating the
  intersection of bounding boxes between your AOI and an individual
  item, performed when setting `composite_function = NULL`, produces a
  bounding box with `ymin` or `xmin` higher than `ymax` or `xmax`.

- Functions will no longer error if you construct their arguments with
  [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html) (or
  otherwise if they have more than one class).

- [`stack_rasters()`](https://permian-global-research.github.io/rsi/dev/reference/stack_rasters.md)
  will only rename bands if `band_names` is the same length as the
  number of bands in the output raster (or missing, or defined by a
  function). It will now warn you if these lengths are different.
  Previously, if you provided more than the required number of band
  names,
  [`stack_rasters()`](https://permian-global-research.github.io/rsi/dev/reference/stack_rasters.md)
  would silently ignore the extra names, and would error if you provided
  fewer names than bands.

- [`get_stac_data()`](https://permian-global-research.github.io/rsi/dev/reference/get_stac_data.md)
  now warns if `asset_names` is `NULL` and there is more than one asset
  per item.

- Functions sending HTTP requests now set a user agent of
  `rsi (https://permian-global-research.github.io/rsi/)`

## rsi 0.1.2

CRAN release: 2024-02-13

- [`get_stac_data()`](https://permian-global-research.github.io/rsi/dev/reference/get_stac_data.md)
  no longer includes `mask_band` in its outputs when
  `composite_function = NULL`. Add this band to `asset_names` to include
  it in the download.

## rsi 0.1.1

CRAN release: 2024-01-18

- [`get_stac_data()`](https://permian-global-research.github.io/rsi/dev/reference/get_stac_data.md)
  now removes colons (`:`) from the file names generated when
  `composite_function = NULL`. This means that datetimes are now
  generally formatted as YYYY-MM-DDTHHMMSSZ, which is slightly
  dissatisfying but is a valid path on Windows systems (thanks to
  [@jguelat](https://github.com/jguelat),
  [\#29](https://github.com/Permian-Global-Research/rsi/issues/29),
  [\#32](https://github.com/Permian-Global-Research/rsi/issues/32)).

- `stacK_rasters()` no longer includes `"-r", "bilinear"` in its default
  value for `gdalwarp_options`
  ([\#27](https://github.com/Permian-Global-Research/rsi/issues/27),
  [\#30](https://github.com/Permian-Global-Research/rsi/issues/30)).

- [`get_stac_data()`](https://permian-global-research.github.io/rsi/dev/reference/get_stac_data.md)
  now provides a more informative error when 0 items are found for a
  given query
  ([\#26](https://github.com/Permian-Global-Research/rsi/issues/26),
  [\#31](https://github.com/Permian-Global-Research/rsi/issues/31)).

## rsi 0.1.0

CRAN release: 2024-01-10

- Initial CRAN submission.
