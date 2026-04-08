# Filter Landsat features to only specific platforms

Filter Landsat features to only specific platforms

## Usage

``` r
landsat_platform_filter(items, platforms)
```

## Arguments

- items:

  A `STACItemCatalog` containing some number of features

- platforms:

  A vector of acceptable platforms, for instance `landsat-9`. Note that
  this refers to satellite names, and *not* to platforms in
  [`spectral_indices()`](https://permian-global-research.github.io/rsi/dev/reference/spectral_indices.md).

## Value

A `STACItemCollection`.

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
  item_filter_function = landsat_platform_filter
)
}
```
