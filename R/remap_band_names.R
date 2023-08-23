remap_band_names <- function(band_names, name_mapping) {
  ifelse(
    band_names %in% names(name_mapping),
    name_mapping[band_names],
    band_names
  )
}
