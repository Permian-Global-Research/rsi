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
#' @section Downloading from Planetary Computer:
#'
#' Certain data sets in Planetary Computer require
#' [providing a subscription key](https://planetarycomputer.microsoft.com/docs/concepts/sas/).
#' Even for non-protected data sets, providing a subscription key grants you
#' higher rate limits and faster downloads. As such, it's a good idea to
#' [request a Planetary Computer account](https://planetarycomputer.microsoft.com/account/request),
#' then [generate a subscription key](https://planetarycomputer.developer.azure-api.net/).
#' If you set the `rsi_pc_key` environment variable to your key (either primary
#' or secondary; there is no difference), rsi will automatically use
#' this key to sign all requests against Planetary Computer.
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
#' The `get_sentinel1_imagery()` function is designed to download Sentinel-1 data
#' from the Microsoft Planetary Computer STAC API. Both the GRD and RTC
#' Sentinel-1 collections are supported. To download RTC data,
#' set `collection` to `sentinel-1-rtc`, and supply your subscription key
#' as an environment variable named `rsi_pc_key` (through, e.g., `Sys.setenv()`
#' or your `.Renviron` file).
#'
#' @section AlOS PALSAR Data:
#' The `get_alos_palsar_imagery()` function is designed to download ALOS PALSAR
#' annual mosaic data from the Microsoft Planetary Computer STAC API. Data are
#' returned as a digital number (which is appropriate for some applications
#' and indices). To convert to backscatter (decibels) use the following formula:
#' `10 * log10(dn) - 83.0` where dn is the radar band in digital number.
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
#' [rsi_query_api()] and the `query_function` slots of
#' [sentinel1_band_mapping], [sentinel2_band_mapping], and
#' [landsat_band_mapping].
#' @param download_function A function that takes the output from
#' `query_function` and downloads the assets attached to those items. See
#' [rsi_download_rasters()] for an example.
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
#' Options include "merge", which 'stamps' images on top of one another such that
#' the "last" value downloaded for a pixel -- which isn't guaranteed to be the most
#' recent one -- will be the only value used, or any of "sum", "mean", "median", 
#' "min", or "max", which consider all values available at each pixel.
#' Set to `NULL` to not composite
#' (i.e., to rescale and save each individual file independently).
#' @inheritParams rstac::stac_search
#' @param gdalwarp_options Options passed to `gdalwarp` through the `options`
#' argument of [sf::gdal_utils()]. The same set of options are used for all
#' downloaded data and the final output images; this means that some common
#' options (for instance, `PREDICTOR=3`) may cause errors if bands are of
#' varying data types. The default values are provided by 
#' [rsi_gdalwarp_options()].
#' @param gdal_config_options Options passed to `gdalwarp` through the
#' `config_options` argument of [sf::gdal_utils()]. The default values are
#' provided by [rsi_gdal_config_options()].
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
#'   query_function = rsi_query_api,
#'   sign_function = sign_planetary_computer,
#'   mask_band = "qa_pixel",
#'   mask_function = landsat_mask_function,
#'   item_filter_function = landsat_platform_filter,
#'   platforms = c("landsat-9", "landsat-8"),
#'   output_filename = tempfile(fileext = ".tif")
#' )
#'
#' # or, mostly equivalently (will download more bands):
#' landsat_image <- get_landsat_imagery(
#'   aoi,
#'   start_date = "2022-06-01",
#'   end_date = "2022-08-30",
#'   output_filename = tempfile(fileext = ".tif")
#' )
#' 
#' landsat_image |> 
#'   terra::rast() |>
#'   terra::stretch() |>
#'   terra::plotRGB()
#' 
#' # The `get_*_imagery()` functions will download 
#' # all available "data" assets by default
#' # (usually including measured values, and excluding derived bands)
#' sentinel1_data <- get_sentinel1_imagery(
#'   aoi,
#'   start_date = "2022-06-01",
#'   end_date = "2022-07-01",
#'   output_filename = tempfile(fileext = ".tif")
#' )
#' names(terra::rast(sentinel1_data))
#' 
#' # You can see what bands will be downloaded by a function
#' # by inspecting the corresponding `band_mapping` object:
#' sentinel2_band_mapping$planetary_computer_v1
#' 
#' # And you can add additional assets using `c()`:
#' c(
#'   sentinel2_band_mapping$planetary_computer_v1,
#'   "scl"
#' )
#' 
#' # Or subset the assets downloaded using `[` or `[[`:
#' sentinel2_imagery <- get_sentinel2_imagery(
#'   aoi,
#'   start_date = "2022-06-01",
#'   end_date = "2022-07-01",
#'   asset_names = sentinel2_band_mapping$planetary_computer_v1["B01"],
#'   output_filename = tempfile(fileext = ".tif")
#' )
#' names(terra::rast(sentinel2_imagery))
#' 
#' # If you're downloading data for a particularly large AOI,
#' # and can't composite the resulting images or want to make
#' # sure you can continue an interrupted download,
#' # consider tiling your AOI and requesting each tile separately:
#' aoi <- sf::st_make_grid(aoi, n = 2)
#' tiles <- lapply(
#'   seq_along(aoi),
#'   function(i) {
#'     get_landsat_imagery(
#'       aoi[i],
#'       start_date = "2022-06-01",
#'       end_date = "2022-08-30",
#'       output_filename = tempfile(fileext = ".tif")
#'     )
#'   }
#' )
#' # You'll get a list of tiles that you can then composite or 
#' # work with however you wish:
#' unlist(tiles)
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
                          query_function = rsi_query_api,
                          download_function = rsi_download_rasters,
                          sign_function = NULL,
                          rescale_bands = TRUE,
                          item_filter_function = NULL,
                          mask_band = NULL,
                          mask_function = NULL,
                          output_filename = paste0(proceduralnames::make_english_names(1), ".tif"),
                          composite_function = c("merge", "median", "mean", "sum", "min", "max"),
                          limit = 999,
                          gdalwarp_options = rsi_gdalwarp_options(),
                          gdal_config_options = rsi_gdal_config_options()) {
  # query |> filter |> download |> mask |> composite |> rescale
  if (!(inherits(aoi, "sf") || inherits(aoi, "sfc"))) {
    rlang::abort(
      "`aoi` must be an sf or sfc object.",
      class = "rsi_aoi_not_sf"
    )
  }

  if (sf::st_is_longlat(aoi) && !(is.null(pixel_x_size) || is.null(pixel_y_size)) && all(c(pixel_x_size, pixel_y_size) %in% c(10, 30))) {
    rlang::warn(
      c(
        "The default pixel size arguments are intended for use with projected AOIs, but `aoi` appears to be in geographic coordinates.",
        i = glue::glue("Pixel X size: {pixel_x_size}. Pixel Y size: {pixel_y_size}."),
        i = glue::glue("These dimensions will be interpreted in the same units as `aoi` (likely degrees), which may cause errors.")
      ),
      class = "rsi_default_pixel_size_geographic_coords"
    )
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
        ),
        class = "rsi_ignored_mask_band"
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

  if (is.null(item_filter_function)) item_filter_function <- \(x, ...) identity(x)

  # query
  items <- query_function(
    bbox = sf::st_bbox(sf::st_transform(aoi, 4326)),
    stac_source = stac_source,
    collection = collection,
    start_date = start_date,
    end_date = end_date,
    limit = limit,
    ...
  )
  # filter
  items <- item_filter_function(items, ...)

  if (!length(items$features)) {
    rlang::abort(
      "No items were found for this combination of collection, AOI, date range, and item filter function.",
      class = "rsi_no_items_found"
    )
  }

  if (missing(asset_names)) asset_names <- NULL
  if (is.null(asset_names)) {
    asset_names <- rstac::items_assets(items)
    if (length(asset_names) > 1) {
      rlang::warn(c(
        "`asset_names` was `NULL`, so rsi is attempting to download all assets in items in this collection.",
        i = "This includes multiple assets, so rsi is attempting to download all of them using the same download function.",
        i = "This might cause errors or not be what you want! Specify `asset_names` to fix this (and to silence this warning)."
      ),
      class = "rsi_missing_asset_names"
    )
    }
  }
  if (is.null(names(asset_names))) names(asset_names) <- asset_names

  items_urls <- extract_urls(asset_names, items)
  drop_mask_band <- FALSE
  if (!is.null(mask_band) && !(mask_band %in% names(items_urls))) {
    items_urls[[mask_band]] <- rstac::assets_url(items, mask_band)
    drop_mask_band <- TRUE
  }

  scale_strings <- character()
  if (rescale_bands) {
    scale_strings <- calc_scale_strings(names(items_urls), items)
  }
  if (length(scale_strings)) {
    scale_strings <- stats::setNames(
      paste("function(x) x", scale_strings),
      names(scale_strings)
    )
  } else {
    rescale_bands <- FALSE
  }

  merge_assets <- is.null(mask_function) &&
    !rescale_bands &&
    !is.null(composite_function) &&
    composite_function == "merge"

  # download
  # download_results is a data frame with names corresponding to "final" band
  # names and rows corresponding to individual STAC items
  download_results <- download_function(
    items = items,
    aoi = aoi_bbox,
    asset_names = stats::setNames(nm = names(items_urls)),
    sign_function = sign_function,
    merge = merge_assets,
    gdalwarp_options = gdalwarp_options,
    gdal_config_options = gdal_config_options,
    ...
  )
  if (!is.null(stats::na.action(download_results))) {
    items$features[stats::na.action(download_results)] <- NULL
  }
  # mask
  if (!is.null(mask_band)) {
    download_results <- rsi_apply_masks(
      download_locations = download_results,
      mask_band = mask_band,
      mask_function = mask_function
    )
  }

  download_results <- download_results[names(download_results) %in% names(asset_names)]

  # composite
  output_vrt <- tempfile(fileext = ".vrt")
  if (is.null(composite_function)) {
    output_vrt <- replicate(nrow(download_results), tempfile(fileext = ".vrt"))
    # turn each row of the DF into its own character vector, stored in a list
    download_results <- apply(download_results, 1, identity, simplify = FALSE)
  } else if (!merge_assets) {
    download_results <- rsi_composite_bands(download_results, composite_function)
  } else {
    # turn DF into a character vector inside a list
    download_results <- list(unlist(download_results))
  }
  # rescale
  if (rescale_bands) {
    lapply(download_results, rescale_band, scale_strings)
  }

  on.exit(file.remove(unlist(download_results)), add = TRUE)

  if (drop_mask_band) items_urls[[mask_band]] <- NULL

  mapply(
    function(in_bands, vrt) {
      stack_rasters(
        in_bands[names(items_urls)],
        vrt,
        band_names = remap_band_names(names(items_urls), asset_names)
      )
    },
    in_bands = download_results,
    vrt = output_vrt
  )

  on.exit(file.remove(output_vrt), add = TRUE)

  if (is.null(composite_function)) {
    app <- tryCatch(rstac::items_datetime(items), error = function(e) NA)
    app <- gsub(":", "", app) # #29, #32
    if (any(is.na(app))) app <- NULL
    app <- app %||% seq_along(download_results)

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
    vrt = output_vrt,
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
                                  download_function = attr(asset_names, "download_function"),
                                  sign_function = attr(asset_names, "sign_function"),
                                  rescale_bands = FALSE,
                                  item_filter_function = NULL,
                                  mask_band = NULL,
                                  mask_function = NULL,
                                  output_filename = paste0(proceduralnames::make_english_names(1), ".tif"),
                                  composite_function = "median",
                                  limit = 999,
                                  gdalwarp_options = rsi_gdalwarp_options(),
                                  gdal_config_options = rsi_gdal_config_options()) {
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
                                  download_function = attr(asset_names, "download_function"),
                                  sign_function = attr(asset_names, "sign_function"),
                                  rescale_bands = FALSE,
                                  item_filter_function = NULL,
                                  mask_band = attr(asset_names, "mask_band"),
                                  mask_function = attr(asset_names, "mask_function"),
                                  output_filename = paste0(proceduralnames::make_english_names(1), ".tif"),
                                  composite_function = "median",
                                  limit = 999,
                                  gdalwarp_options = rsi_gdalwarp_options(),
                                  gdal_config_options = rsi_gdal_config_options()) {
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
                                download_function = attr(asset_names, "download_function"),
                                sign_function = attr(asset_names, "sign_function"),
                                rescale_bands = TRUE,
                                item_filter_function = landsat_platform_filter,
                                mask_band = attr(asset_names, "mask_band"),
                                mask_function = attr(asset_names, "mask_function"),
                                output_filename = paste0(proceduralnames::make_english_names(1), ".tif"),
                                composite_function = "median",
                                limit = 999,
                                gdalwarp_options = rsi_gdalwarp_options(),
                                gdal_config_options = rsi_gdal_config_options()) {
  args <- mget(names(formals()))
  args$`...` <- NULL
  args <- c(args, rlang::list2(...))
  do.call(get_stac_data, args)
}

#' @rdname get_stac_data
#' @export
get_naip_imagery <- function(aoi,
                             start_date,
                             end_date,
                             ...,
                             pixel_x_size = 1,
                             pixel_y_size = 1,
                             asset_names = "image",
                             stac_source = "https://planetarycomputer.microsoft.com/api/stac/v1",
                             collection = "naip",
                             query_function = rsi_query_api,
                             download_function = rsi_download_rasters,
                             sign_function = sign_planetary_computer,
                             rescale_bands = FALSE,
                             output_filename = paste0(proceduralnames::make_english_names(1), ".tif"),
                             composite_function = "merge",
                             limit = 999,
                             gdalwarp_options = rsi_gdalwarp_options(),
                             gdal_config_options = rsi_gdal_config_options()) {
  args <- mget(names(formals()))
  args$`...` <- NULL
  args <- c(args, rlang::list2(...))
  suppressWarnings(
    do.call(get_stac_data, args),
    classes = "rsi_band_name_length_mismatch"
  )
}

#' @rdname get_stac_data
#' @export
get_alos_palsar_imagery <- function(aoi,
                                    start_date,
                                    end_date,
                                    ...,
                                    pixel_x_size = 25,
                                    pixel_y_size = 25,
                                    asset_names = rsi::alos_palsar_band_mapping$planetary_computer_v1,
                                    stac_source = attr(asset_names, "stac_source"),
                                    collection = attr(asset_names, "collection_name"),
                                    query_function = attr(asset_names, "query_function"),
                                    download_function = attr(asset_names, "download_function"),
                                    sign_function = attr(asset_names, "sign_function"),
                                    rescale_bands = FALSE,
                                    item_filter_function = NULL,
                                    mask_band = attr(asset_names, "mask_band"),
                                    mask_function = attr(asset_names, "mask_function"),
                                    output_filename = paste0(proceduralnames::make_english_names(1), ".tif"),
                                    composite_function = "median",
                                    limit = 999,
                                    gdalwarp_options = rsi_gdalwarp_options(),
                                    gdal_config_options = rsi_gdal_config_options()) {
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
                    download_function = attr(asset_names, "download_function"),
                    sign_function = attr(asset_names, "sign_function"),
                    rescale_bands = FALSE,
                    item_filter_function = NULL,
                    mask_band = NULL,
                    mask_function = NULL,
                    output_filename = paste0(proceduralnames::make_english_names(1), ".tif"),
                    composite_function = "max",
                    limit = 999,
                    gdalwarp_options = rsi_gdalwarp_options(),
                    gdal_config_options = rsi_gdal_config_options()) {
  args <- mget(names(formals()))
  args$`...` <- NULL
  args <- c(args, rlang::list2(...))
  do.call(get_stac_data, args)
}

rsi_apply_masks <- function(download_locations, mask_band, mask_function) {
  p <- build_progressr(nrow(download_locations) + (nrow(download_locations) * (ncol(download_locations) - 1)))

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

  download_locations
}

rsi_composite_bands <- function(download_locations,
                                composite_function = c("merge", "median", "mean", "sum", "min", "max")) {
  composite_function <- rlang::arg_match(composite_function)

  p <- build_progressr(length(names(download_locations)))

  download_dir <- file.path(tempdir(), "composite_dir")
  if (!dir.exists(download_dir)) dir.create(download_dir)

  out <- vapply(
    names(download_locations),
    function(band_name) {
      p(glue::glue("Compositing {band_name}"))
      out_file <- file.path(download_dir, paste0(toupper(band_name), ".tif"))

      if (length(download_locations[[band_name]]) == 1) {
        file.copy(download_locations[[band_name]], out_file)
      } else if (composite_function == "merge") {
        do.call(
          terra::merge,
          list(
            x = terra::sprc(lapply(download_locations[[band_name]], terra::rast)),
            filename = out_file,
            overwrite = TRUE
          )
        )
      } else {
        do.call(
          terra::mosaic,
          list(
            x = terra::sprc(lapply(download_locations[[band_name]], terra::rast)),
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

  list(out)
}
calc_scale_strings <- function(asset_names, items) {
  # Assign scale, offset attributes if they exist
  scales <- vapply(
    asset_names,
    get_rescaling_formula,
    items = items,
    element = "scale",
    numeric(1)
  )
  offsets <- vapply(
    asset_names,
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

rescale_band <- function(composited_bands, scale_strings) {
  p <- build_progressr(length(names(scale_strings)))

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

process_dates <- function(date) {
  if (date == "..") {
    return(date)
  } # open intervals
  date <- as.POSIXct(date, "UTC")
  date <- strftime(date, "%Y-%m-%dT%H:%M:%S%Z", "UTC")
  gsub("UTC", "Z", date)
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
    ),
    class = "rsi_multiple_scaling_formulas"
    )
    elements <- NA_real_
  }
  elements <- unique(elements)
  elements
}

is_pc <- function(url) {
  grepl("planetarycomputer.microsoft.com/api/stac/v1", url)
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
