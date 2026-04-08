# Create an ALOS PALSAR mask raster from the mask band

Create an ALOS PALSAR mask raster from the mask band

## Usage

``` r
alos_palsar_mask_function(raster, include = c("land", "water", "both"))
```

## Arguments

- raster:

  The mask band of an ALOS PALSAR image

- include:

  Include pixels that represent land, water, or both? Passing
  `c("land", "water")` is identical to passing `"both"`.

## Value

A boolean raster to be used to mask an ALOS PALSAR image

## Examples

``` r
if (FALSE) { # interactive()
aoi <- sf::st_point(c(-74.912131, 44.080410))
aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
aoi <- sf::st_buffer(sf::st_transform(aoi, 5070), 100)

palsar_image <- get_alos_palsar_imagery(
  aoi,
  start_date = "2021-01-01",
  end_date = "2021-12-31",
  mask_function = alos_palsar_mask_function,
  output_file = tempfile(fileext = ".tif"),
  gdalwarp_options = c(
    rsi::rsi_gdalwarp_options(),
    "-srcnodata", "nan"
  )
)
}
```
