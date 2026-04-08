# Filter indices based on (relatively) complicated fields

Filter indices based on (relatively) complicated fields

## Usage

``` r
filter_platforms(
  indices = spectral_indices(),
  platforms = unique(unlist(spectral_indices(download_indices = FALSE, update_cache =
    FALSE)$platforms)),
  operand = c("all", "any")
)

filter_bands(
  indices = spectral_indices(),
  bands = unique(unlist(spectral_indices(download_indices = FALSE, update_cache =
    FALSE)$bands)),
  operand = c("all", "any"),
  type = c("filter", "search")
)
```

## Arguments

- indices:

  The data frame to filter. Must contain the relevant column.

- platforms, bands:

  Names of the instruments (for `platforms`) or spectra (for `bands`)
  indices must contain.

- operand:

  A function defining how to apply this filter. For instance,
  `operand = all` means that the index must contain all the `platforms`
  or `bands` provided, while `operand = any` means that the index must
  contain at least one of the `platforms` or `bands` provided.

- type:

  What type of query is this? If `filter`, then indices are returned if
  all/any the bands they use (depending on `operand`) are in `bands`. If
  `search`, then indices are returned if all/any of `bands` are in the
  bands they use.

## Value

A filtered version of `indices`.

## Examples

``` r
filter_platforms(platforms = "Sentinel-2")
#> # A tibble: 238 × 9
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
#> # ℹ 228 more rows
#> # ℹ 3 more variables: platforms <list>, reference <chr>, short_name <chr>
filter_platforms(platforms = c("Landsat-OLI", "Sentinel-2"))
#> # A tibble: 189 × 9
#>    application_domain bands     contributor   date_of_addition formula long_name
#>    <chr>              <list>    <chr>         <chr>            <chr>   <chr>    
#>  1 vegetation         <chr [2]> https://gith… 2021-11-17       (N - 0… Aerosol …
#>  2 vegetation         <chr [2]> https://gith… 2021-11-17       (N - 0… Aerosol …
#>  3 water              <chr [6]> https://gith… 2022-09-22       (B + G… Augmente…
#>  4 vegetation         <chr [4]> https://gith… 2021-05-11       (N - (… Atmosphe…
#>  5 vegetation         <chr [4]> https://gith… 2021-05-14       sla * … Adjusted…
#>  6 vegetation         <chr [2]> https://gith… 2022-04-08       (N * (… Advanced…
#>  7 water              <chr [4]> https://gith… 2021-09-18       4.0 * … Automate…
#>  8 water              <chr [5]> https://gith… 2021-09-18       B + 2.… Automate…
#>  9 burn               <chr [2]> https://gith… 2021-04-07       1.0 / … Burned A…
#> 10 burn               <chr [2]> https://gith… 2022-04-20       1.0/((… Burned A…
#> # ℹ 179 more rows
#> # ℹ 3 more variables: platforms <list>, reference <chr>, short_name <chr>
filter_bands(bands = c("R", "N"), operand = any)
#> # A tibble: 209 × 9
#>    application_domain bands     contributor   date_of_addition formula long_name
#>    <chr>              <list>    <chr>         <chr>            <chr>   <chr>    
#>  1 vegetation         <chr [2]> https://gith… 2021-11-17       (N - 0… Aerosol …
#>  2 vegetation         <chr [2]> https://gith… 2021-11-17       (N - 0… Aerosol …
#>  3 water              <chr [6]> https://gith… 2022-09-22       (B + G… Augmente…
#>  4 vegetation         <chr [3]> https://gith… 2022-04-08       N * ((… Anthocya…
#>  5 vegetation         <chr [4]> https://gith… 2021-05-11       (N - (… Atmosphe…
#>  6 vegetation         <chr [4]> https://gith… 2021-05-14       sla * … Adjusted…
#>  7 vegetation         <chr [2]> https://gith… 2022-04-08       (N * (… Advanced…
#>  8 water              <chr [4]> https://gith… 2021-09-18       4.0 * … Automate…
#>  9 water              <chr [5]> https://gith… 2021-09-18       B + 2.… Automate…
#> 10 burn               <chr [2]> https://gith… 2021-04-07       1.0 / … Burned A…
#> # ℹ 199 more rows
#> # ℹ 3 more variables: platforms <list>, reference <chr>, short_name <chr>
```
