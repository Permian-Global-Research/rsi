# Create a Sentinel-2 mask raster from the SCL band

Create a Sentinel-2 mask raster from the SCL band

## Usage

``` r
sentinel2_mask_function(raster)
```

## Arguments

- raster:

  The SCL band of a Sentinel-2 image

## Value

A boolean raster to be used to mask a Sentinel-2 image

## Examples

``` r
if (FALSE) { # interactive()
aoi <- sf::st_point(c(-74.912131, 44.080410))
aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
aoi <- sf::st_buffer(sf::st_transform(aoi, 5070), 100)

sentinel2_image <- get_sentinel2_imagery(
  aoi,
  start_date = "2022-06-01",
  end_date = "2022-08-30",
  mask_function = sentinel2_mask_function
)
}
```
