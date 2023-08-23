composite_images <- function(downloads, out_file, reduce_function) {
  do.call(
    getFromNamespace(reduce_function, "terra"),
    list(x = terra::rast(downloads), na.rm = TRUE, filename = out_file, overwrite = TRUE)
  )
}
