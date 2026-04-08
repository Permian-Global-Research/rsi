# Create and save a multi-band output raster by combining input rasters

This function creates an output raster that "stacks" all the bands of
its input rasters, as though they were loaded one after another into a
GIS. It does this by first constructing a GDAL virtual raster, or "VRT",
and then optionally uses GDAL's warper to convert this VRT into a
standalone file. The VRT is fast to create and does not require much
space, but does require the input rasters not be moved or altered.
Creating a standalone raster from this file may take a long time and a
large amount of disk space.

## Usage

``` r
stack_rasters(
  rasters,
  output_filename,
  ...,
  resolution,
  extent,
  reference_raster = 1,
  resampling_method = "bilinear",
  band_names,
  check_crs = TRUE,
  gdalwarp_options = c("-multi", "-overwrite", "-co", "COMPRESS=DEFLATE", "-co",
    "PREDICTOR=2", "-co", "NUM_THREADS=ALL_CPUS"),
  gdal_config_options = c(VSI_CACHE = "TRUE", GDAL_CACHEMAX = "30%", VSI_CACHE_SIZE =
    "10000000", GDAL_HTTP_MULTIPLEX = "YES", GDAL_INGESTED_BYTES_AT_OPEN = "32000",
    GDAL_DISABLE_READDIR_ON_OPEN = "EMPTY_DIR", GDAL_HTTP_VERSION = "2",
    GDAL_HTTP_MERGE_CONSECUTIVE_RANGES = "YES", GDAL_NUM_THREADS = "ALL_CPUS")
)
```

## Arguments

- rasters:

  A list of rasters to combine into a single multi-band raster, as
  character file paths to files that can be read by
  [`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html).
  Rasters will be "stacked" upon one another, preserving values. They
  must share CRS.

- output_filename:

  The location to save the final "stacked" raster. If this filename has
  a "vrt" extension as determined by
  [`tools::file_ext()`](https://rdrr.io/r/tools/fileutils.html), then
  this function exits after creating a VRT; otherwise, this function
  will create a VRT and then use `sf::gdal_utils("warp")` to convert the
  VRT into another format.

- ...:

  These dots are for future extensions and must be empty.

- resolution:

  Numeric of length 2, representing the target X and Y resolution of the
  output raster. If only a single value is provided, it will be used for
  both X and Y resolution; if more than 2 values are provided, an error
  is thrown.

- extent:

  Numeric of length 4, representing the target xmin, ymin, xmax, and
  ymax values of the output raster (its bounding box), in that order.

- reference_raster:

  The position (index) of the raster in `rasters` to take extent,
  resolution, and CRS information from. No reprojection is done. If
  `resolution` or `extent` are provided, they override the values from
  the reference raster.

- resampling_method:

  The method to use when resampling to different resolutions in the VRT.

- band_names:

  Either a character vector of band names, or a function that when given
  a character vector of band names, returns a character vector of the
  same length containing new band names.

- check_crs:

  Logical: Should this function check that all `rasters` share the same
  CRS? Set to `FALSE` only if you are entirely confident that rasters
  have equivalent CRS definitions, but not identical WKT strings.

- gdalwarp_options:

  Options passed to `gdalwarp` through the `options` argument of
  [`sf::gdal_utils()`](https://r-spatial.github.io/sf/reference/gdal_utils.html).
  This argument is ignored (with a warning) if `output_filename` is a
  VRT.

- gdal_config_options:

  Options passed to `gdalwarp` through the `config_options` argument of
  [`sf::gdal_utils()`](https://r-spatial.github.io/sf/reference/gdal_utils.html).
  This argument is ignored (with a warning) if `output_filename` is a
  VRT.

## Value

`output_filename`, unchanged.

## Examples

``` r
stack_rasters(
  list(
    system.file("rasters/dpdd.tif", package = "rsi"),
    system.file("rasters/example_sentinel1.tif", package = "rsi")
  ),
  tempfile(fileext = ".vrt")
)
#> [1] "/tmp/RtmpNK8mwE/file20aa6531e309.vrt"
```
