# Calculate indices from the bands of a raster

This function computes any number of indices from an input raster via
[`terra::predict()`](https://rspatial.github.io/terra/reference/predict.html).
By default, this function is designed to work with subsets of
[`spectral_indices()`](https://permian-global-research.github.io/rsi/dev/reference/spectral_indices.md),
but it will work with any data frame with a `formula`, `bands`, and
`short_name` column.

## Usage

``` r
calculate_indices(
  raster,
  indices,
  output_filename,
  ...,
  cores = 1L,
  wopt = list(),
  overwrite = FALSE,
  extra_objects = list(),
  names_suffix = NULL
)
```

## Arguments

- raster:

  The raster (either as a SpatRaster or object readable by
  [`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html))
  to compute indices from.

- indices:

  A data frame of indices to compute. The intent is for this function to
  work with subsets of
  [`spectral_indices()`](https://permian-global-research.github.io/rsi/dev/reference/spectral_indices.md),
  but you can provide any data frame with `formula`, `bands`, and
  `short_name` columns; see "Custom indices" below.

- output_filename:

  The filename to write the computed metrics to.

- ...:

  These dots are for future extensions and must be empty.

- cores:

  positive integer. If `cores > 1`, a 'parallel' package cluster with
  that many cores is created and used

- wopt:

  list with named options for writing files as in
  [`writeRaster`](https://rspatial.github.io/terra/reference/writeRaster.html)

- overwrite:

  logical. If `TRUE`, `filename` is overwritten

- extra_objects:

  A named list of additional objects to pass to the minimal environment
  that formulas are executed in. For instance, if you need to use the
  `pmax` function in order to calculate an index, you can make it
  available in the environment by setting
  `extra_objects = list("pmax" = pmax)`. Providing extra functionality
  is inherently less safe than the default minimal environment, and as
  such always emits a warning, which you can suppress with
  [`suppressWarnings()`](https://rdrr.io/r/base/warning.html).

- names_suffix:

  If not `NULL`, will be used (with
  [`paste()`](https://rdrr.io/r/base/paste.html)) to add a suffix to
  each of the band names returned.

## Value

`output_filename`, unchanged.

## Security

Note that this function is running code from the `formula` column of the
spectral indices data frame, which is derived from a JSON file
downloaded off the internet. It's not impossible that an attacker could
take advantage of this to run arbitrary code on your computer. To
mitigate this, indices are calculated in a minimal environment that
contains very few functions or symbols (preventing an attacker from
accessing, for example,
[`system()`](https://rdrr.io/r/base/system.html)).

Still, it's good practice to inspect your `formula` column to make sure
there's nothing nasty hiding in any of the formulas you're going to run.
Additionally, consider using pre-saved indices tables or
`spectral_indices(download_indices = FALSE)` if using this in an
unsupervised workload.

## Custom indices

While this function is designed to work with subsets of
[`spectral_indices()`](https://permian-global-research.github.io/rsi/dev/reference/spectral_indices.md),
you can also provide your own custom indices by providing a data frame
with at least three columns:

- `formula` should contain a string representation of the equation used
  to calculate the index. This string will be interpreted as R code, and
  should use normal R arithmetic operators. Any additional functions
  used in calculating the index will need to be passed through
  `extra_objects`.

- `bands` should be a list column containing character vectors
  identifying the bands required to calculate the index. These vectors
  will be checked against the band names of `raster` to make sure that
  all necessary bands are available before indices are calculated.

- `short_name` should contain a string which will be used as the band
  name in the final output file.

Sometimes you might want to tweak the formula used for an existing
index, for instance to set non-data parameters to constant values. In
that case, make sure you also update `bands` to reflect just the bands
required by your updated formula, so that the function won't error
unnecessarily.

## Examples

``` r
our_raster <- system.file("rasters/example_sentinel1.tif", package = "rsi")
calculate_indices(
  our_raster,
  filter_bands(bands = names(terra::rast(our_raster))),
  tempfile(fileext = ".tif"),
  names_suffix = "sentinel1"
)
#> Warning: No cache file present and `download_indices` set to `FALSE`.
#> ℹ Returning (likely outdated) package data instead.
#> [1] "/tmp/RtmpNK8mwE/file20aa2c29ae54.tif"

# Formulas aren't able to access most R functions or operators,
# in order to try and keep formulas from doing something bad:
example_indices <- filter_platforms(platforms = "Sentinel-1 (Dual Polarisation VV-VH)")[1, ]
example_indices$formula <- 'system("echo something bad")'
# So this will error:
try(
  calculate_indices(
    system.file("rasters/example_sentinel1.tif", package = "rsi"),
    example_indices,
    tempfile(fileext = ".tif")
  )
)
#> Error in system("echo something bad") : could not find function "system"

# Because of this, formulas which try to use most R functions
# will wind up erroring as well:
example_indices$formula <- "pmax(VH, VV)"
try(
  calculate_indices(
    system.file("rasters/example_sentinel1.tif", package = "rsi"),
    example_indices,
    tempfile(fileext = ".tif")
  )
)
#> Error in pmax(VH, VV) : could not find function "pmax"

# To fix this, pass the objects you want to use to `extra_objects`
calculate_indices(
  system.file("rasters/example_sentinel1.tif", package = "rsi"),
  example_indices,
  tempfile(fileext = ".tif"),
  extra_objects = list(pmax = pmax)
) |>
  suppressWarnings(classes = "rsi_extra_objects")
#> [1] "/tmp/RtmpNK8mwE/file20aa73866d94.tif"
```
