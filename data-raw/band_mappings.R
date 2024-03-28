# rstudioapi::restartSession()
devtools::install()
library(rsi)
sentinel2_band_mapping <- list(
  aws_v0 = structure(
    c(
      "B01" = "A",
      "B02" = "B",
      "B03" = "G",
      "B04" = "R",
      "B05" = "RE1",
      "B06" = "RE2",
      "B07" = "RE3",
      "B08" = "N",
      "B8A" = "N2",
      "B09" = "WV",
      "B11" = "S1",
      "B12" = "S2"
    ),
    mask_band = "SCL",
    mask_function = sentinel2_mask_function,
    stac_source = "https://earth-search.aws.element84.com/v0/",
    collection_name = "sentinel-s2-l2a-cogs",
    query_function = rsi_query_api,
    class = "rsi_band_mapping"
  ),
  aws_v1 = structure(
    c(
      blue = "B",
      coastal = "A",
      green = "G",
      nir = "N",
      nir08 = "N2",
      nir09 = "WV",
      red = "R",
      rededge1 = "RE1",
      rededge2 = "RE2",
      rededge3 = "RE3",
      swir16 = "S1",
      swir22 = "S2"
    ),
    mask_band = "scl",
    mask_function = sentinel2_mask_function,
    stac_source = "https://earth-search.aws.element84.com/v1/",
    collection_name = "sentinel-2-l2a",
    query_function = rsi_query_api,
    download_function = rsi_download_rasters,
    class = "rsi_band_mapping"
  )
)

sentinel2_band_mapping$planetary_computer_v1 <- sentinel2_band_mapping$aws_v0
attr(sentinel2_band_mapping$planetary_computer_v1, "scl_name") <- "SCL"
attr(sentinel2_band_mapping$planetary_computer_v1, "stac_source") <- "https://planetarycomputer.microsoft.com/api/stac/v1/"
attr(sentinel2_band_mapping$planetary_computer_v1, "collection_name") <- "sentinel-2-l2a"
attr(sentinel2_band_mapping$planetary_computer_v1, "query_function") <- rsi_query_api
attr(sentinel2_band_mapping$planetary_computer_v1, "download_function") <- rsi_download_rasters
attr(sentinel2_band_mapping$planetary_computer_v1, "sign_function") <- sign_planetary_computer

usethis::use_data(sentinel2_band_mapping, overwrite = TRUE)

landsat_band_mapping <- list(
  planetary_computer_v1 = structure(
    c(
      "coastal" = "A",
      "blue" = "B",
      "green" = "G",
      "red" = "R",
      "nir08" = "N",
      "swir16" = "S1",
      "swir22" = "S2",
      "lwir" = "T",
      "lwir11" = "T1"
    ),
    mask_band = "qa_pixel",
    mask_function = landsat_mask_function,
    stac_source = "https://planetarycomputer.microsoft.com/api/stac/v1/",
    collection_name = "landsat-c2-l2",
    query_function = rsi_query_api,
    download_function = rsi_download_rasters,
    sign_function = sign_planetary_computer,
    class = "rsi_band_mapping"
  )
)

usethis::use_data(landsat_band_mapping, overwrite = TRUE)

sentinel1_band_mapping <- list(
  planetary_computer_v1 = structure(
    c(
      "vh" = "VH",
      "vv" = "VV",
      "hh" = "HH",
      "hv" = "HV"
    ),
    stac_source = "https://planetarycomputer.microsoft.com/api/stac/v1/",
    collection_name = "sentinel-1-grd",
    query_function = rsi_query_api,
    download_function = rsi_download_rasters,
    sign_function = sign_planetary_computer,
    class = "rsi_band_mapping"
  )
)

usethis::use_data(sentinel1_band_mapping, overwrite = TRUE)

alos_palsar_band_mapping <- list(
  planetary_computer_v1 = structure(
    c(
      "HH" = "HH",
      "HV" = "HV",
      "VV" = "VV",
      "VH" = "VH",
      "linci" = "linci"
    ),
    mask_band = "mask",
    mask_function = alos_palsar_mask_function,
    stac_source = "https://planetarycomputer.microsoft.com/api/stac/v1/",
    collection_name = "alos-palsar-mosaic",
    query_function = rsi_query_api,
    download_function = rsi_download_rasters,
    sign_function = sign_planetary_computer,
    class = "rsi_band"
  )
)

usethis::use_data(alos_palsar_band_mapping, overwrite = TRUE)


pc_dem_mapping <- function(assets, collection_name) {
  structure(
    assets,
    stac_source = "https://planetarycomputer.microsoft.com/api/stac/v1/",
    collection_name = collection_name,
    query_function = rsi_query_api,
    download_function = rsi_download_rasters,
    sign_function = sign_planetary_computer,
    class = "rsi_band_mapping"
  )
}

dem_band_mapping <- list(
  planetary_computer_v1 = list(
    nasadem = pc_dem_mapping(c("elevation" = "elevation"), "nasadem"),
    "alos-dem" = pc_dem_mapping(c("data" = "elevation"), "alos-dem"),
    "cop-dem-glo-30" = pc_dem_mapping(c("data" = "elevation"), "cop-dem-glo-30"),
    "cop-dem-glo-90" = pc_dem_mapping(c("data" = "elevation"), "cop-dem-glo-90"),
    "3dep-lidar-dtm" = pc_dem_mapping(c("data" = "elevation"), "3dep-lidar-dtm"),
    "3dep-lidar-dsm" = pc_dem_mapping(c("data" = "elevation"), "3dep-lidar-dsm"),
    "3dep-lidar-dtm-native" = pc_dem_mapping(c("data" = "elevation"), "3dep-lidar-dtm-native"),
    "3dep-seamless" = pc_dem_mapping(c("data" = "elevation"), "3dep-seamless")
  )
)

usethis::use_data(dem_band_mapping, overwrite = TRUE)
