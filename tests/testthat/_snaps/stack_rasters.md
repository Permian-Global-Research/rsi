# stack_rasters fails when rasters are not character vectors

    Code
      stack_rasters(r1, "a")
    Condition
      Error in `stack_rasters()`:
      ! Some input arguments weren't the right class or length:
      * rasters should be a character, but is a SpatRaster.

# type_and_length checks

    Code
      stack_rasters("a", c("a", "b"))
    Condition
      Error in `stack_rasters()`:
      ! Some input arguments weren't the right class or length:
      * output_filename should be of length 1, but is length 2.

---

    Code
      stack_rasters("a", "b", resampling_method = c("a", "b"))
    Condition
      Error in `stack_rasters()`:
      ! Some input arguments weren't the right class or length:
      * resampling_method should be of length 1, but is length 2.

