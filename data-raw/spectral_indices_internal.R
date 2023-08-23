## code to prepare `spectral_indices_internal` dataset goes here
spectral_indices_internal <- rsi:::download_indices()

usethis::use_data(spectral_indices_internal, overwrite = TRUE, internal = TRUE)
