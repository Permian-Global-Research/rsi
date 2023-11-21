# warning (but not error) fires if `mask_band` is not NULL with NULL `mask_function`

    Code
      x <- get_landsat_imagery(aoi = aoi, start_date = "2022-06-01", end_date = "2022-08-01",
        mask_function = NULL, rescale_bands = FALSE, output_filename = tempfile(
          fileext = ".tif"))
    Condition
      Warning:
      `mask_function` was NULL, but `mask_band` was not `NULL`.
      i `mask_band` will be ignored (not downloaded or used).

