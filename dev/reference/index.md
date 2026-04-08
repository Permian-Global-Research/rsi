# Package index

## Spectral indices

- [`spectral_indices()`](https://permian-global-research.github.io/rsi/dev/reference/spectral_indices.md)
  : Get a data frame of spectral indices
- [`calculate_indices()`](https://permian-global-research.github.io/rsi/dev/reference/calculate_indices.md)
  : Calculate indices from the bands of a raster
- [`filter_platforms()`](https://permian-global-research.github.io/rsi/dev/reference/filters.md)
  [`filter_bands()`](https://permian-global-research.github.io/rsi/dev/reference/filters.md)
  : Filter indices based on (relatively) complicated fields
- [`spectral_indices_url()`](https://permian-global-research.github.io/rsi/dev/reference/spectral_indices_url.md)
  : Get the URL to download spectral indices from

## STAC data

- [`get_stac_data()`](https://permian-global-research.github.io/rsi/dev/reference/get_stac_data.md)
  [`get_sentinel1_imagery()`](https://permian-global-research.github.io/rsi/dev/reference/get_stac_data.md)
  [`get_sentinel2_imagery()`](https://permian-global-research.github.io/rsi/dev/reference/get_stac_data.md)
  [`get_landsat_imagery()`](https://permian-global-research.github.io/rsi/dev/reference/get_stac_data.md)
  [`get_naip_imagery()`](https://permian-global-research.github.io/rsi/dev/reference/get_stac_data.md)
  [`get_alos_palsar_imagery()`](https://permian-global-research.github.io/rsi/dev/reference/get_stac_data.md)
  [`get_dem()`](https://permian-global-research.github.io/rsi/dev/reference/get_stac_data.md)
  : Retrieve raster data from STAC endpoints

## Band mappings

- [`alos_palsar_band_mapping`](https://permian-global-research.github.io/rsi/dev/reference/alos_palsar_band_mapping.md)
  : ALOS PALSAR band mapping
- [`dem_band_mapping`](https://permian-global-research.github.io/rsi/dev/reference/dem_band_mapping.md)
  : Landsat band mapping
- [`landsat_band_mapping`](https://permian-global-research.github.io/rsi/dev/reference/landsat_band_mapping.md)
  : Landsat band mapping
- [`sentinel1_band_mapping`](https://permian-global-research.github.io/rsi/dev/reference/sentinel1_band_mapping.md)
  : Sentinel-1 band mapping
- [`sentinel2_band_mapping`](https://permian-global-research.github.io/rsi/dev/reference/sentinel2_band_mapping.md)
  : Sentinel-2 band mapping

## Utilities

- [`alos_palsar_mask_function()`](https://permian-global-research.github.io/rsi/dev/reference/alos_palsar_mask_function.md)
  : Create an ALOS PALSAR mask raster from the mask band
- [`landsat_mask_function()`](https://permian-global-research.github.io/rsi/dev/reference/landsat_mask_function.md)
  : Create a Landsat mask raster from the QA band
- [`sentinel2_mask_function()`](https://permian-global-research.github.io/rsi/dev/reference/sentinel2_mask_function.md)
  : Create a Sentinel-2 mask raster from the SCL band
- [`landsat_platform_filter()`](https://permian-global-research.github.io/rsi/dev/reference/landsat_platform_filter.md)
  : Filter Landsat features to only specific platforms
- [`rsi_download_rasters()`](https://permian-global-research.github.io/rsi/dev/reference/rsi_download_rasters.md)
  : Download specific assets from a set of STAC items
- [`rsi_gdal_config_options()`](https://permian-global-research.github.io/rsi/dev/reference/rsi_gdal_options.md)
  [`rsi_gdalwarp_options()`](https://permian-global-research.github.io/rsi/dev/reference/rsi_gdal_options.md)
  : Default options for GDAL
- [`rsi_query_api()`](https://permian-global-research.github.io/rsi/dev/reference/rsi_query_api.md)
  : Query a STAC API using a specific spatiotemporal area of interest
- [`sign_planetary_computer()`](https://permian-global-research.github.io/rsi/dev/reference/sign_planetary_computer.md)
  : Sign STAC items retrieved from the Planetary Computer
- [`stack_rasters()`](https://permian-global-research.github.io/rsi/dev/reference/stack_rasters.md)
  : Create and save a multi-band output raster by combining input
  rasters
