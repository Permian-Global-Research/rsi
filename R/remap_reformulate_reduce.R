remap_reformulate_reduce <- function(stac_collection,
                                     remap_band_names,
                                     reduce_time,
                                     reduce_function) {
  if (!is.null(remap_band_names)) {
    stac_collection <- do.call(
      gdalcubes::rename_bands,
      c(cube = stac_collection, remap_band_names)
    )
  }

  if (reduce_time) {
    stac_collection <- stac_collection |>
      gdalcubes::reduce_time(
        paste0(reduce_function, "(", names(stac_collection), ")"),
        names = names(stac_collection)
      )
  }
  stac_collection
}
