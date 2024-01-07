#' Retrieve raster data from STAC endpoints
#'
#' These functions retrieve raster data from STAC endpoints and optionally
#' create composite data sets from multiple files.
#' `get_stac_data()` is a generic function which should be able to download
#' raster data from a variety of data sources, while the other helper functions
#' have useful defaults for downloading common data sets from standard
#' STAC sources.
#'
#' @section Usage Tips:
#' It's often useful to buffer your `aoi` object slightly, on the order of 1-2
#' cell widths, in order to ensure that data is downloaded for your entire AOI
#' even after accounting for any reprojection needed to compare your AOI to
#' the data on the STAC server.
#'
#' These functions allow for parallelizing downloads via [future::plan()], and
#' for user-controlled progress updates via [progressr::handlers()]. If
#' there are fewer images to download than `asset_names`, then this function
#' uses [lapply()] to iterate through images and [future.apply::future_mapply()]
#' to iterate through downloading each asset. If there are more images than
#' assets, this function uses [future.apply::future_lapply()] to iterate through
#' images.
#'
#' There are currently some challenges with certain Landsat images in Planetary
#' Computer; please see
#' https://github.com/microsoft/PlanetaryComputer/discussions/101
#' for more information on these images and their current status. These files
#' may cause data downloads to fail.
#'
#' @section Compositing:
#'
#' This function can either download all data that intersects with your
#' spatiotemporal AOI as multiple files (if `composite_function = NULL`),
#' or can be used to rescale band values, apply a mask function, and create a
#' composite from the resulting files in a single function call. Each of these
#' steps can be skipped by passing `NULL` to the corresponding argument.
#'
#' Masks are applied to each downloaded asset separately. Rescaling is applied
#' to the final composite after images are combined.
#'
#' A number of the steps involved in creating composites -- rescaling band
#' values, running the mask function, masking images, and compositing images --
#' currently rely on the `terra` package for raster calculations. This means
#' creating larger composites, either in geographic or temporal dimension, may
#' cause errors. It can be a good idea to tile your `aoi` using
#' `sf::st_make_grid()` and iterate through the tiles to avoid these errors
#' (and to make it easier to interrupt and restart a download job).
#'
#' @section Rescaling:
#' If `rescale_bands` is `TRUE`, then this function is able to use the `scale`
#' and `offset` values in the `bands` field of the `raster` STAC extension.
#' This was implemented originally to work with the Landsat collections in the
#' Planetary Computer STAC catalogue, but hopefully will work automatically with
#' other data sources as well. Note that Sentinel-2 data typically doesn't use
#' this STAC extension, and so the returned data is typically not re-scaled;
#' divide the downloaded band values by 10000 to get reflectance values in the
#' expected values.
#'
#' @section Sentinel-1 Data:
#' The `get_sentinel1_data()` function is designed to download Sentinel-1 data
#' from the Microsoft Planetary Computer STAC API. Both the GRD and RTC
#' Sentinel-1 collections are supported. To download RTC data,
#' set `collection` to `sentinel-1-rtc`, and supply your subscription key
#' as an environment variable named `rsi_pc_key` (through, e.g., `Sys.setenv()`
#' or your `.Renviron` file).
#'
#' @param aoi An sf(c) object outlining the area of interest to get imagery for.
#' Will be used to get the bounding box used for calculating metrics and the
#' output data's CRS.
#' @param start_date,end_date Character of length 1: The first and last date,
#' respectively, of imagery to include in metrics calculations. Should be in
#' YYYY-MM-DD format.
#' @param pixel_x_size,pixel_y_size Numeric of length 1: size of pixels in
#' x-direction (longitude / easting) and y-direction (latitude / northing).
#' @param asset_names The names of the assets to download. If this vector has
#' names, then the names of the vector are assumed to be the names of assets on
#' the STAC server, which will be renamed to the elements of the vector in the
#' final output.
#' @param stac_source Character of length 1: the STAC URL to download
#' imagery from.
#' @param collection Character of length 1: the STAC collection to download
#' images from.
#' @param query_function A function that takes the output from
#' [rstac::stac_search()] and executes the request. See
#' [default_query_function()] and the `query_function` slots of
#' [sentinel1_band_mapping], [sentinel2_band_mapping], and
#' [landsat_band_mapping].
#' @param sign_function A function that takes the output from `query_function`
#' and signs the item URLs, if necessary.
#' @param ... Passed to `item_filter_function`.
#' @param rescale_bands Logical of length 1: If the STAC collection implements
#' the `raster` STAC extension, and that extension includes `scale` and `offset`
#' values, should this function attempt to automatically rescale the downloaded
#' data?
#' @param item_filter_function A function that takes the outputs of
#' `query_function` (usually a `STACItemCollection`) and `...` and returns a
#' filtered `STACItemCollection`. This is used, for example, to only download
#' images from specific Landsat platforms.
#' @param mask_band Character of length 1: The name of the asset in your
#' STAC source to use to mask the data. Set to `NULL` to not mask. See the
#' `mask_band` slots of [sentinel1_band_mapping], [sentinel2_band_mapping], and
#' [landsat_band_mapping].
#' @param mask_function A function that takes a raster and returns a boolean
#' raster, where `TRUE` pixels will be preserved and `FALSE` or `NA` pixels will
#' be masked out. See [sentinel2_mask_function()].
#' @param output_filename The filename to write the output raster to. If
#' `composite_function` is `NULL`, item datetimes will be appended to this
#' in order to create unique filenames. If items do not have datetimes, a
#' sequential ID will be appended instead.
#' @param composite_function Character of length 1: The name of a
#' function used to combine downloaded images into a single composite
#' (i.e., to aggregate pixel values from multiple images into a single value).
#' Must be one of of "sum", "mean", "median", "min", "max".
#' Set to `NULL` to not composite
#' (i.e., to rescale and save each individual file independently).
#' @inheritParams rstac::stac_search
#' @param gdalwarp_options Options passed to `gdalwarp` through the `options`
#' argument of [sf::gdal_utils()]. The same set of options are used for all
#' downloaded data and the final output images; this means that some common
#' options (for instance, `PREDICTOR=3`) may cause errors if bands are of
#' varying data types.
#' @param gdal_config_options Options passed to `gdalwarp` through the
#' `config_options` argument of [sf::gdal_utils()].
#' @param platforms The names of Landsat satellites to download imagery from.
#' These do not correspond to the `platforms` column in [spectral_indices()];
#' the default argument of `c("landsat-9", "landsat-8")` corresponds to
#' the `Landsat-OLI` value in that column.
#'
#' @returns `output_filename`, unchanged.
#'
#' @examplesIf interactive()
#' aoi <- sf::st_point(c(-74.912131, 44.080410))
#' aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
#' aoi <- sf::st_buffer(sf::st_transform(aoi, 5070), 100)
#'
#' get_stac_data(aoi,
#'   start_date = "2022-06-01",
#'   end_date = "2022-06-30",
#'   pixel_x_size = 30,
#'   pixel_y_size = 30,
#'   asset_names = c(
#'     "red", "blue", "green"
#'   ),
#'   stac_source = "https://planetarycomputer.microsoft.com/api/stac/v1/",
#'   collection = "landsat-c2-l2",
#'   query_function = default_query_function,
#'   sign_function = sign_planetary_computer,
#'   mask_band = "qa_pixel",
#'   mask_function = landsat_mask_function,
#'   item_filter_function = landsat_platform_filter,
#'   platforms = c("landsat-9", "landsat-8")
#' )
#'
#' # or, mostly equivalently (will download more bands):
#' landsat_image <- get_landsat_imagery(
#'   aoi,
#'   start_date = "2022-06-01",
#'   end_date = "2022-08-30"
#' )
#'
#' @export
get_stac_data <- function(aoi,
                          start_date,
                          end_date,
                          pixel_x_size = NULL,
                          pixel_y_size = NULL,
                          asset_names,
                          stac_source,
                          collection,
                          ...,
                          query_function = default_query_function,
                          sign_function = NULL,
                          rescale_bands = TRUE,
                          item_filter_function = NULL,
                          mask_band = NULL,
                          mask_function = NULL,
                          output_filename = paste0(proceduralnames::make_english_names(1), ".tif"),
                          composite_function = c("merge", "median", "mean", "sum", "min", "max"),
                          limit = 999,
                          gdalwarp_options = c(
                            "-r", "bilinear",
                            "-multi",
                            "-overwrite",
                            "-co", "COMPRESS=DEFLATE",
                            "-co", "PREDICTOR=2",
                            "-co", "NUM_THREADS=ALL_CPUS"
                          ),
                          gdal_config_options = c(
                            VSI_CACHE = "TRUE",
                            GDAL_CACHEMAX = "30%",
                            VSI_CACHE_SIZE = "10000000",
                            GDAL_HTTP_MULTIPLEX = "YES",
                            GDAL_INGESTED_BYTES_AT_OPEN = "32000",
                            GDAL_DISABLE_READDIR_ON_OPEN = "EMPTY_DIR",
                            GDAL_HTTP_VERSION = "2",
                            GDAL_HTTP_MERGE_CONSECUTIVE_RANGES = "YES",
                            GDAL_NUM_THREADS = "ALL_CPUS"
                          )) {
  if (!(inherits(aoi, "sf") || inherits(aoi, "sfc"))) {
    rlang::abort(
      "`aoi` must be an sf or sfc object.",
      class = "rsi_aoi_not_sf"
    )
  }

  if (sf::st_is_longlat(aoi) && !(is.null(pixel_x_size) || is.null(pixel_y_size)) && all(c(pixel_x_size, pixel_y_size) %in% c(10, 30))) {
    rlang::warn(c(
      "The default pixel size arguments are intended for use with projected AOIs, but `aoi` appears to be in geographic coordinates.",
      i = glue::glue("Pixel X size: {pixel_x_size}. Pixel Y size: {pixel_y_size}."),
      i = glue::glue("These dimensions will be interpreted in the same units as `aoi` (likely degrees), which may cause errors.")
    ))
  }

  if (!is.null(composite_function)) {
    composite_function <- rlang::arg_match(composite_function)
  }

  if (is.null(mask_function)) {
    if (!is.null(mask_band)) {
      rlang::warn(
        c(
          "`mask_function` was NULL, but `mask_band` was not `NULL`.",
          i = "`mask_band` will be ignored (not downloaded or used)."
        )
      )
    }
    mask_band <- NULL
  }

  check_type_and_length(
    start_date = character(1),
    end_date = character(1),
    pixel_x_size = numeric(1),
    pixel_y_size = numeric(1),
    stac_source = character(1),
    collection = character(1),
    rescale_bands = logical(1),
    mask_band = character(1),
    output_filename = character(1),
    composite_function = character(1),
    limit = numeric(1),
    gdalwarp_options = character()
  )

  if (is.null(sign_function) && is_pc(stac_source)) {
    sign_function <- sign_planetary_computer
  }

  gdalwarp_options <- process_gdalwarp_options(
    gdalwarp_options = gdalwarp_options,
    aoi = aoi,
    pixel_x_size = pixel_x_size,
    pixel_y_size = pixel_y_size
  )

  aoi_bbox <- sf::st_bbox(aoi)

  if (!is.null(start_date)) {
    start_date <- process_dates(start_date)
    end_date <- process_dates(end_date)
  }

  items <- query_function(
    bbox = sf::st_bbox(sf::st_transform(aoi, 4326)),
    stac_source = stac_source,
    collection = collection,
    start_date = start_date,
    end_date = end_date,
    limit = limit,
    ...
  )

  if (!is.null(item_filter_function)) {
    items <- item_filter_function(items, ...)
  }

  if (missing(asset_names)) asset_names <- NULL
  if (is.null(asset_names)) asset_names <- rstac::items_assets(items)
  if (is.null(names(asset_names))) names(asset_names) <- asset_names

  items_urls <- extract_urls(asset_names, items)
  if (!is.null(mask_band)) items_urls[[mask_band]] <- rstac::assets_url(items, mask_band)

  download_locations <- data.frame(
    matrix(
      data = replicate(
        length(items_urls) * length(items$features),
        tempfile(fileext = ".tif")
      ),
      ncol = length(items_urls),
      nrow = length(items$features)
    )
  )
  names(download_locations) <- names(items_urls)

  scale_strings <- character()
  if (rescale_bands) {
    scale_strings <- calc_scale_strings(download_locations, items)
  }
  if (length(scale_strings)) {
    scale_strings <- stats::setNames(
      paste("function(x) x", scale_strings),
      names(scale_strings)
    )
  } else {
    rescale_bands <- FALSE
  }

  if (rlang::is_installed("progressr")) {
    length_progress <- figure_out_progress_length(
      items_urls,
      mask_band,
      composite_function,
      mask_function,
      download_locations,
      rescale_bands,
      scale_strings
    )
    p <- progressr::progressor(length_progress)
  } else {
    p <- function(...) NULL
  }

  use_simple_download <- is.null(mask_function) &&
    !rescale_bands &&
    !is.null(composite_function) &&
    composite_function == "merge"

  if (use_simple_download) {
    download_results <- simple_download(
      items,
      sign_function,
      asset_names,
      gdalwarp_options,
      aoi_bbox,
      gdal_config_options,
      p
    )
  } else {
    download_results <- complex_download(
      items,
      items_urls,
      download_locations,
      sign_function,
      asset_names,
      mask_band,
      gdalwarp_options,
      aoi_bbox,
      gdal_config_options,
      p,
      mask_function,
      composite_function,
      output_filename,
      rescale_bands,
      scale_strings
    )
    on.exit(file.remove(unlist(download_results[["final_bands"]])), add = TRUE)
  }

  mapply(
    function(in_bands, vrt) {
      stack_rasters(
        in_bands,
        vrt,
        band_names = remap_band_names(names(items_urls), asset_names)
      )
    },
    in_bands = download_results[["final_bands"]],
    vrt = download_results[["out_vrt"]]
  )

  on.exit(file.remove(download_results[["out_vrt"]]), add = TRUE)

  if (is.null(composite_function)) {
    app <- tryCatch(rstac::items_datetime(items), error = function(e) NA)
    if (any(is.na(app))) app <- NULL
    app <- app %||% seq_along(download_results[["final_bands"]])

    output_filename <- paste0(
      tools::file_path_sans_ext(output_filename),
      "_",
      app,
      ".",
      tools::file_ext(output_filename)
    )
  }

  out <- mapply(
    function(vrt, out) {
      sf::gdal_utils(
        "warp",
        vrt,
        out,
        options = gdalwarp_options
      )
      out
    },
    vrt = download_results[["out_vrt"]],
    out = output_filename
  )

  # drop VRT filenames from vector
  as.vector(out)
}

#' @rdname get_stac_data
#' @export
get_sentinel1_imagery <- function(aoi,
                                  start_date,
                                  end_date,
                                  ...,
                                  pixel_x_size = 10,
                                  pixel_y_size = 10,
                                  asset_names = rsi::sentinel1_band_mapping$planetary_computer_v1,
                                  stac_source = attr(asset_names, "stac_source"),
                                  collection = attr(asset_names, "collection_name"),
                                  query_function = attr(asset_names, "query_function"),
                                  sign_function = attr(asset_names, "sign_function"),
                                  rescale_bands = FALSE,
                                  item_filter_function = NULL,
                                  mask_band = NULL,
                                  mask_function = NULL,
                                  output_filename = paste0(proceduralnames::make_english_names(1), ".tif"),
                                  composite_function = "median",
                                  limit = 999,
                                  gdalwarp_options = c(
                                    "-r", "bilinear",
                                    "-multi",
                                    "-overwrite",
                                    "-co", "COMPRESS=DEFLATE",
                                    "-co", "PREDICTOR=2",
                                    "-co", "NUM_THREADS=ALL_CPUS"
                                  ),
                                  gdal_config_options = c(
                                    VSI_CACHE = "TRUE",
                                    GDAL_CACHEMAX = "30%",
                                    VSI_CACHE_SIZE = "10000000",
                                    GDAL_HTTP_MULTIPLEX = "YES",
                                    GDAL_INGESTED_BYTES_AT_OPEN = "32000",
                                    GDAL_DISABLE_READDIR_ON_OPEN = "EMPTY_DIR",
                                    GDAL_HTTP_VERSION = "2",
                                    GDAL_HTTP_MERGE_CONSECUTIVE_RANGES = "YES",
                                    GDAL_NUM_THREADS = "ALL_CPUS"
                                  )) {
  args <- mget(names(formals()))
  args$`...` <- NULL
  args <- c(args, rlang::list2(...))
  do.call(get_stac_data, args)
}

#' @rdname get_stac_data
#' @export
get_sentinel2_imagery <- function(aoi,
                                  start_date,
                                  end_date,
                                  ...,
                                  pixel_x_size = 10,
                                  pixel_y_size = 10,
                                  asset_names = rsi::sentinel2_band_mapping$planetary_computer_v1,
                                  stac_source = attr(asset_names, "stac_source"),
                                  collection = attr(asset_names, "collection_name"),
                                  query_function = attr(asset_names, "query_function"),
                                  sign_function = attr(asset_names, "sign_function"),
                                  rescale_bands = FALSE,
                                  item_filter_function = NULL,
                                  mask_band = attr(asset_names, "mask_band"),
                                  mask_function = attr(asset_names, "mask_function"),
                                  output_filename = paste0(proceduralnames::make_english_names(1), ".tif"),
                                  composite_function = "median",
                                  limit = 999,
                                  gdalwarp_options = c(
                                    "-r", "bilinear",
                                    "-multi",
                                    "-overwrite",
                                    "-co", "COMPRESS=DEFLATE",
                                    "-co", "PREDICTOR=2",
                                    "-co", "NUM_THREADS=ALL_CPUS"
                                  ),
                                  gdal_config_options = c(
                                    VSI_CACHE = "TRUE",
                                    GDAL_CACHEMAX = "30%",
                                    VSI_CACHE_SIZE = "10000000",
                                    GDAL_HTTP_MULTIPLEX = "YES",
                                    GDAL_INGESTED_BYTES_AT_OPEN = "32000",
                                    GDAL_DISABLE_READDIR_ON_OPEN = "EMPTY_DIR",
                                    GDAL_HTTP_VERSION = "2",
                                    GDAL_HTTP_MERGE_CONSECUTIVE_RANGES = "YES",
                                    GDAL_NUM_THREADS = "ALL_CPUS"
                                  )) {
  args <- mget(names(formals()))
  args$`...` <- NULL
  args <- c(args, rlang::list2(...))
  do.call(get_stac_data, args)
}

#' @rdname get_stac_data
#' @export
get_landsat_imagery <- function(aoi,
                                start_date,
                                end_date,
                                ...,
                                platforms = c("landsat-9", "landsat-8"),
                                pixel_x_size = 30,
                                pixel_y_size = 30,
                                asset_names = rsi::landsat_band_mapping$planetary_computer_v1,
                                stac_source = attr(asset_names, "stac_source"),
                                collection = attr(asset_names, "collection_name"),
                                query_function = attr(asset_names, "query_function"),
                                sign_function = attr(asset_names, "sign_function"),
                                rescale_bands = TRUE,
                                item_filter_function = landsat_platform_filter,
                                mask_band = attr(asset_names, "mask_band"),
                                mask_function = attr(asset_names, "mask_function"),
                                output_filename = paste0(proceduralnames::make_english_names(1), ".tif"),
                                composite_function = "median",
                                limit = 999,
                                gdalwarp_options = c(
                                  "-r", "bilinear",
                                  "-multi",
                                  "-overwrite",
                                  "-co", "COMPRESS=DEFLATE",
                                  "-co", "PREDICTOR=2",
                                  "-co", "NUM_THREADS=ALL_CPUS"
                                ),
                                gdal_config_options = c(
                                  VSI_CACHE = "TRUE",
                                  GDAL_CACHEMAX = "30%",
                                  VSI_CACHE_SIZE = "10000000",
                                  GDAL_HTTP_MULTIPLEX = "YES",
                                  GDAL_INGESTED_BYTES_AT_OPEN = "32000",
                                  GDAL_DISABLE_READDIR_ON_OPEN = "EMPTY_DIR",
                                  GDAL_HTTP_VERSION = "2",
                                  GDAL_HTTP_MERGE_CONSECUTIVE_RANGES = "YES",
                                  GDAL_NUM_THREADS = "ALL_CPUS"
                                )) {
  args <- mget(names(formals()))
  args$`...` <- NULL
  args <- c(args, rlang::list2(...))
  do.call(get_stac_data, args)
}

#' @rdname get_stac_data
#' @export
get_dem <- function(aoi,
                    ...,
                    start_date = NULL,
                    end_date = NULL,
                    pixel_x_size = 30,
                    pixel_y_size = 30,
                    asset_names = rsi::dem_band_mapping$planetary_computer_v1$`cop-dem-glo-30`,
                    stac_source = attr(asset_names, "stac_source"),
                    collection = attr(asset_names, "collection_name"),
                    query_function = attr(asset_names, "query_function"),
                    sign_function = attr(asset_names, "sign_function"),
                    rescale_bands = FALSE,
                    item_filter_function = NULL,
                    mask_band = NULL,
                    mask_function = NULL,
                    output_filename = paste0(proceduralnames::make_english_names(1), ".tif"),
                    composite_function = "max",
                    limit = 999,
                    gdalwarp_options = c(
                      "-r", "bilinear",
                      "-multi",
                      "-overwrite",
                      "-co", "COMPRESS=DEFLATE",
                      "-co", "PREDICTOR=2",
                      "-co", "NUM_THREADS=ALL_CPUS"
                    ),
                    gdal_config_options = c(
                      VSI_CACHE = "TRUE",
                      GDAL_CACHEMAX = "30%",
                      VSI_CACHE_SIZE = "10000000",
                      GDAL_HTTP_MULTIPLEX = "YES",
                      GDAL_INGESTED_BYTES_AT_OPEN = "32000",
                      GDAL_DISABLE_READDIR_ON_OPEN = "EMPTY_DIR",
                      GDAL_HTTP_VERSION = "2",
                      GDAL_HTTP_MERGE_CONSECUTIVE_RANGES = "YES",
                      GDAL_NUM_THREADS = "ALL_CPUS"
                    )) {
  args <- mget(names(formals()))
  args$`...` <- NULL
  args <- c(args, rlang::list2(...))
  do.call(get_stac_data, args)
}

download_assets <- function(urls,
                            destinations,
                            gdalwarp_options,
                            gdal_config_options,
                            progressor) {
  if (length(urls) != length(destinations)) {
    rlang::abort("`urls` and `destinations` must be the same length.")
  }

  future.apply::future_mapply(
    function(url, destination) {
      progressor("Downloading assets")
      sf::gdal_utils(
        "warp",
        paste0("/vsicurl/", url),
        destination,
        options = gdalwarp_options,
        quiet = TRUE,
        config_options = gdal_config_options
      )
    },
    url = urls,
    destination = destinations,
    future.seed = TRUE
  )

  destinations
}

apply_masks <- function(mask_band, mask_function, download_locations, p) {
  apply(
    download_locations,
    1,
    function(files) {
      p("Running mask function")
      mask <- mask_function(terra::rast(files[[mask_band]]))

      lapply(
        files[setdiff(names(files), mask_band)],
        function(raster) {
          masked_file <- tempfile(fileext = ".tif")
          p("Applying mask to downloaded assets")
          terra::mask(
            terra::rast(raster),
            mask,
            maskvalues = c(NA, FALSE),
            filename = masked_file
          )
          file.rename(masked_file, raster)
          raster
        }
      )
    }
  )
}

simple_download <- function(items,
                            sign_function,
                            asset_names,
                            gdalwarp_options,
                            aoi_bbox,
                            gdal_config_options,
                            p) {
  gdalwarp_options <- set_gdalwarp_extent(gdalwarp_options, aoi_bbox, NULL)
  out <- future.apply::future_lapply(
    names(asset_names),
    function(asset) {
      p(glue::glue("Downloading {asset}"))
      signed_items <- maybe_sign_items(items, sign_function)
      item_urls <- paste0("/vsicurl/", rstac::assets_url(signed_items, asset))
      out_file <- tempfile(fileext = ".tif")
      sf::gdal_utils(
        "warp",
        source = item_urls,
        destination = out_file,
        options = gdalwarp_options,
        config_options = gdal_config_options
      )
      out_file
    },
    future.seed = TRUE
  )
  list(
    final_bands = list(out),
    out_vrt = tempfile(fileext = ".vrt")
  )
}

complex_download <- function(items,
                             items_urls,
                             download_locations,
                             sign_function,
                             asset_names,
                             mask_band,
                             gdalwarp_options,
                             aoi_bbox,
                             gdal_config_options,
                             p,
                             mask_function,
                             composite_function,
                             output_filename,
                             rescale_bands,
                             scale_strings) {
  feature_iterator <- ifelse(
    length(items$features) > ncol(download_locations),
    function(...) future.apply::future_lapply(..., future.seed = TRUE),
    lapply
  )
  feature_iterator(
    seq_along(items$features),
    function(i) {
      item <- items$features[[i]]

      item <- maybe_sign_items(item, sign_function)

      item_urls <- extract_urls(asset_names, item)
      if (!is.null(mask_band)) item_urls[[mask_band]] <- rstac::assets_url(item, mask_band)

      item_bbox <- item$bbox
      current_options <- set_gdalwarp_extent(gdalwarp_options, aoi_bbox, item_bbox)

      tryCatch(
        download_assets(
          unlist(item_urls),
          unlist(download_locations[i, , drop = FALSE]),
          current_options,
          gdal_config_options,
          p
        ),
        error = function(e) {
          rlang::warn(glue::glue("Failed to download {item$id %||% 'UNKNOWN'} from {item$properties$datetime %||% 'UNKNOWN'}"))
          download_locations[i, ] <- NA
        }
      )
    }
  )
  download_locations <- stats::na.omit(download_locations)
  names(download_locations) <- names(items_urls)

  if (!is.null(mask_band)) apply_masks(mask_band, mask_function, download_locations, p)

  if (is.null(composite_function)) {
    out_vrt <- replicate(nrow(download_locations), tempfile(fileext = ".tif"))
    final_bands <- apply(download_locations, 1, identity, simplify = FALSE)
  } else {
    out_vrt <- tempfile(fileext = ".vrt")
    final_bands <- list(
      make_composite_bands(
        download_locations[, names(download_locations) %in% names(asset_names), drop = FALSE],
        composite_function,
        p
      )
    )
  }
  if (rescale_bands) lapply(final_bands, rescale_band, scale_strings, p)
  list(
    final_bands = final_bands,
    out_vrt = out_vrt
  )
}

calc_scale_strings <- function(download_locations, items) {
  # Assign scale, offset attributes if they exist
  scales <- vapply(
    names(download_locations),
    get_rescaling_formula,
    items = items,
    element = "scale",
    numeric(1)
  )
  offsets <- vapply(
    names(download_locations),
    get_rescaling_formula,
    items = items,
    element = "offset",
    numeric(1)
  )

  scale_strings <- vapply(
    names(scales),
    function(band) {
      out <- ""

      if (band %in% names(scales) && !is.na(scales[[band]])) {
        out <- paste(out, glue::glue("* {scales[[band]]}"))
      }

      if (band %in% names(offsets) && !is.na(offsets[[band]])) {
        out <- paste(out, glue::glue("+ {offsets[[band]]}"))
      }

      out
    },
    character(1)
  )
  names(scale_strings) <- names(scales)

  scale_strings <- scale_strings[scale_strings != ""]
  scale_strings
}

rescale_band <- function(composited_bands, scale_strings, p) {
  for (band in names(scale_strings)) {
    p(glue::glue("Rescaling band {band}"))
    rescaled_file <- tempfile(fileext = ".tif")
    terra::writeRaster(
      eval(str2lang(scale_strings[[band]]))(terra::rast(composited_bands[[band]])),
      filename = rescaled_file,
      overwrite = TRUE
    )
    file.rename(rescaled_file, composited_bands[[band]])
  }
  composited_bands
}

remap_band_names <- function(band_names, name_mapping) {
  ifelse(
    band_names %in% names(name_mapping),
    name_mapping[band_names],
    band_names
  )
}

process_gdalwarp_options <- function(gdalwarp_options,
                                     aoi,
                                     pixel_x_size = 30,
                                     pixel_y_size = 30) {
  if (is.null(gdalwarp_options)) {
    gdalwarp_options <- character(0)
  }

  if (!("-t_srs" %in% gdalwarp_options)) {
    gdalwarp_options <- c(gdalwarp_options, "-t_srs", sf::st_crs(aoi)$wkt)
  }

  if (!("-tr" %in% gdalwarp_options) && !is.null(pixel_x_size) && !is.null(pixel_y_size)) {
    gdalwarp_options <- c(gdalwarp_options, "-tr", pixel_x_size, pixel_y_size)
  }

  gdalwarp_options
}

set_gdalwarp_extent <- function(gdalwarp_options, aoi_bbox, item_bbox = NULL) {
  if (!("-te" %in% gdalwarp_options)) {
    if (!is.null(item_bbox)) {
      class(item_bbox) <- "bbox"
      item_bbox <- sf::st_as_sfc(item_bbox)
      item_bbox <- sf::st_set_crs(item_bbox, 4326)
      item_bbox <- sf::st_transform(item_bbox, sf::st_crs(aoi_bbox))
      item_bbox <- sf::st_bbox(item_bbox)

      aoi_bbox <- c(
        xmin = max(aoi_bbox[[1]], item_bbox[[1]]),
        ymin = max(aoi_bbox[[2]], item_bbox[[2]]),
        xmax = min(aoi_bbox[[3]], item_bbox[[3]]),
        ymax = min(aoi_bbox[[4]], item_bbox[[4]])
      )
    }

    gdalwarp_options <- c(gdalwarp_options, "-te", aoi_bbox)
  }
  gdalwarp_options
}

process_dates <- function(date) {
  if (date == "..") {
    return(date)
  } # open intervals
  date <- as.POSIXct(date, "UTC")
  date <- strftime(date, "%Y-%m-%dT%H:%M:%S%Z", "UTC")
  gsub("UTC", "Z", date)
}

extract_urls <- function(asset_names, items) {
  items_urls <- lapply(
    names(asset_names),
    function(asset_name) suppressWarnings(rstac::assets_url(items, asset_name))
  )
  names(items_urls) <- names(asset_names)

  items_urls <- items_urls[!vapply(items_urls, is.null, logical(1))]

  items_urls
}

make_composite_bands <- function(downloaded_bands, composite_function, p) {
  download_dir <- file.path(tempdir(), "composite_dir")
  if (!dir.exists(download_dir)) dir.create(download_dir)

  vapply(
    names(downloaded_bands),
    function(band_name) {
      p(glue::glue("Compositing {band_name}"))
      out_file <- file.path(download_dir, paste0(toupper(band_name), ".tif"))

      if (length(downloaded_bands[[band_name]]) == 1) {
        file.copy(downloaded_bands[[band_name]], out_file)
      } else if (composite_function == "merge") {
        do.call(
          terra::merge,
          list(
            x = terra::sprc(lapply(downloaded_bands[[band_name]], terra::rast)),
            filename = out_file,
            overwrite = TRUE
          )
        )
      } else {
        do.call(
          terra::mosaic,
          list(
            x = terra::sprc(lapply(downloaded_bands[[band_name]], terra::rast)),
            fun = composite_function,
            filename = out_file,
            overwrite = TRUE
          )
        )
      }

      out_file
    },
    character(1)
  )
}

maybe_sign_items <- function(items, sign_function) {
  if (!is.null(sign_function)) {
    items <- sign_function(items)
  }
  items
}

get_rescaling_formula <- function(items, band_name, element) {
  elements <- vapply(
    items$features,
    function(x) {
      x <- x$assets[[band_name]]$`raster:bands`[[1]]
      tryCatch(x[[element]] %||% NA_real_, error = function(e) NA_real_)
    },
    numeric(1)
  )

  if (length(unique(elements)) != 1) {
    rlang::warn(c(
      glue::glue("Images in band {band_name} have different {element}s."),
      i = "Returning images without rescaling."
    ))
    elements <- NA_real_
  }
  elements <- unique(elements)
  elements
}

figure_out_progress_length <- function(items_urls, mask_band, composite_function, mask_function, download_locations, rescale_bands, scale_strings) {
  # this is frankly ridiculous

  # How many steps do we walk through:
  # 1. Must download all items, including the masks
  length_progress <- length(unlist(items_urls))
  # 2. If masking, we are going to either run a mask function or actually mask
  # all downloads (*2)
  if (!is.null(mask_band)) length_progress <- length_progress * 2
  # 3. Compositing complicates things:
  if (!is.null(composite_function)) {
    # 3.1 We'll add 1x the number of bands:
    composite_multiplier <- 1
    length_progress <- length_progress + (length(items_urls) * composite_multiplier)
    # 4. But not the mask band if it exists:
    if (!is.null(mask_function)) length_progress <- length_progress - 1
  } else {
    # If rescaling, we'll need to scale each image separately:
    composite_multiplier <- nrow(download_locations)
  }
  # 5. If rescaling, add one step for each rescale:
  if (rescale_bands) {
    length_progress <- length_progress + (length(scale_strings) * composite_multiplier)
  }
  length_progress
}

is_pc <- function(url) {
  grepl("planetarycomputer.microsoft.com/api/stac/v1", url)
}
