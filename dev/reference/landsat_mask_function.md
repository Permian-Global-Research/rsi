# Create a Landsat mask raster from the QA band

Create a Landsat mask raster from the QA band

## Usage

``` r
landsat_mask_function(
  raster,
  include = c("land", "water", "both"),
  ...,
  masked_bits
)
```

## Arguments

- raster:

  The QA band of a Landsat image

- include:

  Include pixels that represent land, water, or both? Passing
  `c("land", "water")` is identical to passing `"both"`.

- ...:

  These dots are for future extensions and must be empty.

- masked_bits:

  Optionally, a list of integer vectors representing the individual bits
  to mask out. Each vector is converted to an integer representation,
  and then pixels with matching `qa_pixel` values are preserved by the
  mask. Refer to the Landsat science product guide for further
  information on what bit values represent for your platform of
  interest.

## Value

A boolean raster to be used to mask a Landsat image

## Examples

``` r
if (FALSE) { # interactive()
aoi <- sf::st_point(c(-74.912131, 44.080410))
aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
aoi <- sf::st_buffer(sf::st_transform(aoi, 5070), 100)

landsat_image <- get_landsat_imagery(
  aoi,
  start_date = "2022-06-01",
  end_date = "2022-08-30",
  mask_function = landsat_mask_function,
  output_file = tempfile(fileext = ".tif")
)

# Or, optionally pass the qa_pixel bits to mask out directly
landsat_image <- get_landsat_imagery(
  aoi,
  start_date = "2022-06-01",
  end_date = "2022-08-30",
  mask_function = \(x) landsat_mask_function(
    x,
    masked_bits = list(c(0:5, 7, 9, 11, 13, 15))
  ),
  output_file = tempfile(fileext = ".tif")
)

# You can use this to specify multiple acceptable values
# from the qa_pixel bitmask; names are optional
landsat_image <- get_landsat_imagery(
  aoi,
  start_date = "2022-06-01",
  end_date = "2022-08-30",
  mask_function = \(x) landsat_mask_function(
    x,
    masked_bits = list(
      clear_land = c(0:5, 7, 9, 11, 13, 15),
      clear_water = c(0:5, 9, 11, 13, 15)
    )
  ),
  output_file = tempfile(fileext = ".tif")
)
}
```
