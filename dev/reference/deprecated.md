# Deprecated functions

**\[deprecated\]**

These functions have been deprecated in favor of better approaches.

- `default_query_function()` was renamed to
  [`rsi_query_api()`](https://permian-global-research.github.io/rsi/dev/reference/rsi_query_api.md).
  These functions are identical, and the older name will be removed in a
  future release.

## Usage

``` r
default_query_function(
  bbox,
  stac_source,
  collection,
  start_date,
  end_date,
  limit,
  ...
)
```
