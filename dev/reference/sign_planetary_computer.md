# Sign STAC items retrieved from the Planetary Computer

Sign STAC items retrieved from the Planetary Computer

## Usage

``` r
sign_planetary_computer(items, subscription_key = Sys.getenv("rsi_pc_key"))
```

## Arguments

- items:

  A STACItemCollection, as returned by `rsi_query_api`.

- subscription_key:

  Optionally, a subscription key associated with your Planetary Computer
  account. At the time of writing, this is required for downloading
  Sentinel 1 RTC products, as well as NAIP imagery. This key will be
  automatically used if the environment variable `rsi_pc_key` is set.

## Value

A STACItemCollection object with signed assets url.

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
  sign_function = sign_planetary_computer
)
}
```
