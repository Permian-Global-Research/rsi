#' Retrieve and composite images from STAC endpoints
#'
#' These function retrieves composites of satellite images from STAC endpoints.
#' `get_stac_data()` is a generic function which should be able to download and
#' composite images from a variety of data sources, while the other helper
#' functions have useful defaults for downloading common data sets from standard
#' STAC sources.
#'
#' @section Usage Tips:
#' It's often useful to buffer your `aoi` object slightly, on the order of 1-2
#' cell widths, in order to ensure that data is downloaded for your entire AOI
#' even after accounting for any reprojection needed to compare your AOI to
#' the data on the STAC server.
#'
#' Setting the following GDAL configuration variables via `Sys.setenv()` or in
#' `.Renviron` might be useful to speed up downloads from cloud services:
#' + VSI_CACHE = "TRUE"
#' + GDAL_CACHEMAX = "30%"
#' + VSI_CACHE_SIZE = "10000000"
#' + GDAL_HTTP_MULTIPLEX = "YES"
#' + GDAL_INGESTED_BYTES_AT_OPEN = "32000"
#' + GDAL_DISABLE_READDIR_ON_OPEN = "EMPTY_DIR"
#' + GDAL_HTTP_VERSION = "2"
#' + GDAL_HTTP_MERGE_CONSECUTIVE_RANGES = "YES"
#' + GDAL_NUM_THREADS = "ALL_CPUS"
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
#' [query_planetary_computer()] and the `query_function` slots of
#' [sentinel1_band_mapping], [sentinel2_band_mapping], and
#' [landsat_band_mapping].
#' @param ... Passed to `item_filter_functiion`.
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
#' @param output_filename The filename to write the output raster to.
#' @param composite_function Character of length 1: The (quoted) name of a
#' function from `terra` (for instance, [terra::median]) used to combine
#' downloaded images into a single composite (i.e., to aggregate pixel values
#' from multiple images into a single value).
#' @inheritParams rstac::stac_search
#' @param gdalwarp_options Options passed to `gdalwarp` through the `options`
#' argument of [sf::gdal_utils()]. The same set of options are used for all
#' downloaded data and the final output images; this means that some common
#' options (for instance, `PREDICTOR=3`) may cause errors if bands are of
#' varying data types.
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
#'   end_date = "2022-08-30",
#'   pixel_x_size = 30,
#'   pixel_y_size = 30,
#'   asset_names = sentinel2_band_mapping$planetary_computer_v1,
#'   stac_source = attr(sentinel2_band_mapping$planetary_computer_v1, "stac_source"),
#'   collection = attr(sentinel2_band_mapping$planetary_computer_v1, "collection"),
#'   query_function = download_planetary_computer,
#'   mask_band = attr(sentinel2_band_mapping$planetary_computer_v1, "mask_band"),
#'   mask_function = sentinel2_mask_function
#' )
#'
#' @export
get_stac_data <- function(aoi,
                          start_date,
                          end_date,
                          pixel_x_size = 30,
                          pixel_y_size = 30,
                          asset_names,
                          stac_source,
                          collection,
                          query_function,
                          ...,
                          rescale_bands = TRUE,
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
                          )) {

  if (!(inherits(aoi, "sf") || inherits(aoi, "sfc"))) {
    rlang::abort(
      "`aoi` must be an sf or sfc object.",
      class = "rsi_aoi_not_sf"
    )
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

  gdalwarp_options <- process_gdalwarp_options(
    gdalwarp_options = gdalwarp_options,
    aoi = aoi,
    pixel_x_size = pixel_x_size,
    pixel_y_size = pixel_y_size
  )

  items <- get_items(
    sf::st_bbox(sf::st_transform(aoi, 4326)),
    stac_source,
    collection,
    start_date,
    end_date,
    limit,
    query_function
  )

  if (!is.null(item_filter_function)) {
    items <- item_filter_function(items, ...)
  }

  items_urls <- lapply(
    names(asset_names),
    function(asset_name) suppressWarnings(rstac::assets_url(items, asset_name))
  )
  names(items_urls) <- names(asset_names)

  items_urls <- items_urls[!vapply(items_urls, is.null, logical(1))]

  downloaded_bands <- lapply(
    names(items_urls),
    function(band_name) {
      urls <- items_urls[[band_name]]
      downloads <- replicate(length(urls), tempfile(fileext = ".tif"))

      scales <- vapply(
        items$features,
        function(x) x$assets[[band_name]]$`raster:bands`[[1]]$scale %||% NA_real_,
        numeric(1)
      )
      offsets <- vapply(
        items$features,
        function(x) x$assets[[band_name]]$`raster:bands`[[1]]$offset %||% NA_real_,
        numeric(1)
      )

      if (length(unique(scales)) != 1) {
        rlang::warn(c(
          glue::glue("Images in band {band_name} have different scaling factors."),
          i = "Returning images without rescaling."
        ))
        scales <- NA_real_
      }
      scales <- unique(scales)

      if (length(unique(offsets)) != 1) {
        rlang::warn(c(
          glue::glue("Images in band {band_name} have different offsets."),
          i = "Returning images without adding the offset."
        ))
        offsets <- NA_real_
      }
      offsets <- unique(offsets)

      if (!is.na(scales)) attr(downloads, "scaling_factor") <- scales
      if (!is.na(offsets)) attr(downloads, "offset") <- offsets

      download_assets(urls, downloads, gdalwarp_options)
    }
  )
  on.exit(file.remove(unlist(downloaded_bands)), add = TRUE)
  names(downloaded_bands) <- names(items_urls)

  if (!is.null(mask_band)) {
    mask_urls <- rstac::assets_url(items, mask_band)
    mask_files <- replicate(length(mask_urls), tempfile(fileext = ".tif"))
    download_assets(mask_urls, mask_files, gdalwarp_options)
    on.exit(file.remove(mask_files), add = TRUE)

    masks <- lapply(
      mask_files,
      function(mask) {
        mask_function(terra::rast(mask))
      }
    )

    lapply(
      downloaded_bands,
      function(images) {
        temp_file_masks <- replicate(length(images), tempfile(fileext = ".tif"))
        mapply(
          function(raster, mask, masked_file) {
            terra::mask(
              terra::rast(raster),
              mask,
              maskvalues = c(NA, FALSE),
              filename = masked_file
            )
            file.rename(masked_file, raster)
            raster
          },
          raster = images,
          mask = masks,
          masked_file = temp_file_masks
        )
      }
    )
  }

  download_dir <- file.path(tempdir(), "composite_dir")
  if (!dir.exists(download_dir)) dir.create(download_dir)

  composited_bands <- vapply(
    names(downloaded_bands),
    function(band_name) {
      out_file <- file.path(download_dir, paste0(toupper(band_name), ".tif"))

      do.call(
        getFromNamespace(composite_function, "terra"),
        list(
          x = terra::rast(downloaded_bands[[band_name]]),
          na.rm = TRUE,
          filename = out_file,
          overwrite = TRUE
        )
      )

      if (rescale_bands) {
        out_file <- rescale_band(downloaded_bands, band_name, out_file)
      }

      out_file
    },
    character(1)
  )
  on.exit(file.remove(composited_bands), add = TRUE)

  out_vrt <- tempfile(fileext = ".vrt")
  invisible(
    stack_rasters(
      composited_bands,
      out_vrt,
      band_names = remap_band_names(names(items_urls), asset_names)
    )
  )
  on.exit(file.remove(out_vrt), add = TRUE)

  sf::gdal_utils(
    "warp",
    out_vrt,
    output_filename,
    options = gdalwarp_options
  )

  output_filename
}

#' @rdname get_stac_data
#' @export
get_sentinel1_imagery <- function(aoi,
                                  start_date,
                                  end_date,
                                  ...,
                                  pixel_x_size = 10,
                                  pixel_y_size = 10,
                                  asset_names = sentinel1_band_mapping$planetary_computer_v1,
                                  stac_source = attr(asset_names, "stac_source"),
                                  collection = attr(asset_names, "collection_name"),
                                  query_function = attr(asset_names, "query_function"),
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
                                  )) {
  args <- as.list(rlang::call_match(defaults = TRUE))[-1]
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
                                  asset_names = sentinel2_band_mapping$planetary_computer_v1,
                                  stac_source = attr(asset_names, "stac_source"),
                                  collection = attr(asset_names, "collection_name"),
                                  query_function = attr(asset_names, "query_function"),
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
                                  )) {
  args <- as.list(rlang::call_match(defaults = TRUE))[-1]
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
                                asset_names = landsat_band_mapping$planetary_computer_v1,
                                stac_source = attr(asset_names, "stac_source"),
                                collection = attr(asset_names, "collection_name"),
                                query_function = attr(asset_names, "query_function"),
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
                                )) {
  args <- as.list(rlang::call_match(defaults = TRUE))[-1]
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
                    asset_names = dem_band_mapping$planetary_computer_v1$`cop-dem-glo-30`,
                    stac_source = attr(asset_names, "stac_source"),
                    collection = attr(asset_names, "collection_name"),
                    query_function = attr(asset_names, "query_function"),
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
                    )) {
  args <- as.list(rlang::call_match(defaults = TRUE))[-1]
  do.call(get_stac_data, args)
}

download_assets <- function(urls, destinations, gdalwarp_options) {
  if (length(urls) != length(destinations)) {
    rlang::abort("`urls` and `destinations` must be the same length.")
  }

  mapply(
    function(url, destination) {
      sf::gdal_utils(
        "warp",
        paste0("/vsicurl/", url),
        destination,
        options = gdalwarp_options,
        quiet = TRUE
      )
    },
    url = urls,
    destination = destinations
  )

  destinations
}

rescale_band <- function(downloaded_bands, band_name, out_file) {
  scale_string <- ""
  if (!is.null(attr(downloaded_bands[[band_name]], "scaling_factor"))) {
    scale_string <- paste(
      scale_string,
      glue::glue("* {attr(downloaded_bands[[band_name]], 'scaling_factor')}")
    )
  }
  if (!is.null(attr(downloaded_bands[[band_name]], "offset"))) {
    scale_string <- paste(
      scale_string,
      glue::glue("+ {attr(downloaded_bands[[band_name]], 'offset')}")
    )
  }
  if (scale_string != "") {
    scale_string <- paste("function(x) x", scale_string)
    rescaled_file <- tempfile(fileext = ".tif")
    terra::writeRaster(
      eval(str2lang(scale_string))(terra::rast(out_file)),
      filename = rescaled_file,
      overwrite = TRUE
    )
    file.rename(rescaled_file, out_file)
  }

  out_file
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

  if (!("-te" %in% gdalwarp_options)) {
    gdalwarp_options <- c(gdalwarp_options, "-te", sf::st_bbox(aoi))
  }

  if (!("-tr" %in% gdalwarp_options)) {
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

get_items <- function(bbox_wgs84,
                      stac_source,
                      collections,
                      start_date,
                      end_date,
                      limit,
                      download_function) {
  if (!is.null(start_date)) {
    start_date <- process_dates(start_date)
    end_date <- process_dates(end_date)
    datetime <- paste0(start_date, "/", end_date)
  } else {
    datetime <- NULL
  }

  rstac::stac(stac_source) |>
    rstac::stac_search(
      collections = collections,
      bbox = c(
        bbox_wgs84["xmin"],
        bbox_wgs84["ymin"],
        bbox_wgs84["xmax"],
        bbox_wgs84["ymax"]
      ),
      datetime = datetime,
      limit = limit
    ) |>
    download_function()
}
