# Query a STAC API using a specific spatiotemporal area of interest

This function is the default method used to retrieve lists of items to
download for all the collections and endpoints supported by rsi. It will
likely work for any other STAC APIs of interest.

## Usage

``` r
rsi_query_api(bbox, stac_source, collection, start_date, end_date, limit, ...)
```

## Arguments

- bbox:

  A `bbox` or `sfc` object, from the sf package, representing the
  spatial bounding box of your area of interest. This must be in
  EPSG:4326 coordinates (and, if this function is called from within
  [`get_stac_data()`](https://permian-global-research.github.io/rsi/dev/reference/get_stac_data.md),
  it will be) or else it will be automatically reprojected.

- stac_source:

  Character of length 1: the STAC URL to download imagery from.

- collection:

  Character of length 1: the STAC collection to download images from.

- start_date, end_date:

  Character strings of length 1 representing the boundaries of your
  temporal range of interest, in RFC-3339 format. Set either argument to
  `..` to use an open interval; set `start_date` to `NULL` to not pass a
  temporal range of interest (which may cause errors with some APIs). If
  this function is called from within
  [`get_stac_data()`](https://permian-global-research.github.io/rsi/dev/reference/get_stac_data.md),
  the inputs to `start_date` and `end_date` will have already been
  processed to try and force RFC-3339 compliance.

- limit:

  an `integer` defining the maximum number of results to return. If not
  informed, it defaults to the service implementation.

- ...:

  Ignored by this function. Arguments passed to
  [`get_stac_data()`](https://permian-global-research.github.io/rsi/dev/reference/get_stac_data.md)
  via `...` will be available (unchanged) in this function

## Value

A StacItemCollection object.

## Details

You can pass your own query functions to
[`get_stac_data()`](https://permian-global-research.github.io/rsi/dev/reference/get_stac_data.md)
and its variants. This is the best way to perform more complex queries,
for instance if you need to provide authentication to get the list of
items (not just the assets) available for your AOI, or to perform cloud
filtering prior to downloading assets.

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
  query_function = rsi_query_api
)
}
```
