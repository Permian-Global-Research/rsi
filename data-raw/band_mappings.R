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
    scl_name = "SCL",
    stac_source = "https://earth-search.aws.element84.com/v0/",
    collection_name = "sentinel-s2-l2a-cogs",
    download_function = \(q) {
      rstac::items_fetch(rstac::get_request(q))
    }
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
    scl_name = "scl",
    stac_source = "https://earth-search.aws.element84.com/v1/",
    collection_name = "sentinel-2-l2a",
    download_function = \(q) {
      rstac::items_fetch(rstac::get_request(q))
    }
  )
)

sentinel2_band_mapping$planetary_computer_v1 <- sentinel2_band_mapping$aws_v0
attr(sentinel2_band_mapping$planetary_computer_v1, "scl_name") <- "SCL"
attr(sentinel2_band_mapping$planetary_computer_v1, "stac_source") <- "https://planetarycomputer.microsoft.com/api/stac/v1/"
attr(sentinel2_band_mapping$planetary_computer_v1, "collection_name") <- "sentinel-2-l2a"
attr(sentinel2_band_mapping$planetary_computer_v1, "download_function") <- rsi::download_planetary_computer

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
    qa_name = "qa_pixel",
    stac_source = "https://planetarycomputer.microsoft.com/api/stac/v1/",
    collection_name = "landsat-c2-l2",
    download_function = rsi::download_planetary_computer
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
    download_function = rsi::download_planetary_computer
  )
)

usethis::use_data(sentinel1_band_mapping, overwrite = TRUE)
