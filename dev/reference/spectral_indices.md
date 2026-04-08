# Get a data frame of spectral indices

This function returns a data frame of spectral indices, from the
`awesome-spectral-indices` repository.

## Usage

``` r
spectral_indices(
  ...,
  url = spectral_indices_url(),
  download_indices = NULL,
  update_cache = NULL
)
```

## Source

<https://github.com/awesome-spectral-indices/awesome-spectral-indices>

## Arguments

- ...:

  These dots are for future extensions and must be empty.

- url:

  The URL to download spectral indices from. If the option `rsi_url` is
  set, that value will be used; otherwise, if the environment variable
  `rsi_url` is set, that value will be used; otherwise, the list at
  https://github.com/awesome-spectral-indices/awesome-spectral-indices
  will be used.

- download_indices:

  Logical: should this function download indices? If `NULL`, this
  function will only download indices if the cache will be updated. If
  `TRUE`, this function will attempt to download indices no matter what.
  If `FALSE`, either cached or package indices will be used.

- update_cache:

  Logical: should cached indices be updated? If `NULL`, cached values
  will be updated if the cache is older than a day. If `TRUE`, the cache
  will be updated, if `FALSE` it will not.

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
with nine columns, containing information about spectral indices.

## Examples

``` r
spectral_indices()
#> # A tibble: 271 × 9
#>    application_domain bands     contributor   date_of_addition formula long_name
#>    <chr>              <list>    <chr>         <chr>            <chr>   <chr>    
#>  1 vegetation         <chr [2]> https://gith… 2021-11-17       (N - 0… Aerosol …
#>  2 vegetation         <chr [2]> https://gith… 2021-11-17       (N - 0… Aerosol …
#>  3 water              <chr [6]> https://gith… 2022-09-22       (B + G… Augmente…
#>  4 vegetation         <chr [2]> https://gith… 2021-09-20       (1 / G… Anthocya…
#>  5 vegetation         <chr [3]> https://gith… 2022-04-08       N * ((… Anthocya…
#>  6 vegetation         <chr [4]> https://gith… 2021-05-11       (N - (… Atmosphe…
#>  7 vegetation         <chr [4]> https://gith… 2021-05-14       sla * … Adjusted…
#>  8 vegetation         <chr [2]> https://gith… 2022-04-08       (N * (… Advanced…
#>  9 water              <chr [4]> https://gith… 2021-09-18       4.0 * … Automate…
#> 10 water              <chr [5]> https://gith… 2021-09-18       B + 2.… Automate…
#> # ℹ 261 more rows
#> # ℹ 3 more variables: platforms <list>, reference <chr>, short_name <chr>
```
