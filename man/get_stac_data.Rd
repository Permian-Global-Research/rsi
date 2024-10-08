% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_stac_data.R
\name{get_stac_data}
\alias{get_stac_data}
\alias{get_sentinel1_imagery}
\alias{get_sentinel2_imagery}
\alias{get_landsat_imagery}
\alias{get_naip_imagery}
\alias{get_alos_palsar_imagery}
\alias{get_dem}
\title{Retrieve raster data from STAC endpoints}
\usage{
get_stac_data(
  aoi,
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
  gdal_config_options = rsi_gdal_config_options()
)

get_sentinel1_imagery(
  aoi,
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
  gdal_config_options = rsi_gdal_config_options()
)

get_sentinel2_imagery(
  aoi,
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
  gdal_config_options = rsi_gdal_config_options()
)

get_landsat_imagery(
  aoi,
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
  gdal_config_options = rsi_gdal_config_options()
)

get_naip_imagery(
  aoi,
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
  gdal_config_options = rsi_gdal_config_options()
)

get_alos_palsar_imagery(
  aoi,
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
  gdal_config_options = rsi_gdal_config_options()
)

get_dem(
  aoi,
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
  gdal_config_options = rsi_gdal_config_options()
)
}
\arguments{
\item{aoi}{An sf(c) object outlining the area of interest to get imagery for.
Will be used to get the bounding box used for calculating metrics and the
output data's CRS.}

\item{start_date, end_date}{Character of length 1: The first and last date,
respectively, of imagery to include in metrics calculations. Should be in
YYYY-MM-DD format.}

\item{pixel_x_size, pixel_y_size}{Numeric of length 1: size of pixels in
x-direction (longitude / easting) and y-direction (latitude / northing).}

\item{asset_names}{The names of the assets to download. If this vector has
names, then the names of the vector are assumed to be the names of assets on
the STAC server, which will be renamed to the elements of the vector in the
final output.}

\item{stac_source}{Character of length 1: the STAC URL to download
imagery from.}

\item{collection}{Character of length 1: the STAC collection to download
images from.}

\item{...}{Passed to \code{item_filter_function}.}

\item{query_function}{A function that takes the output from
\code{\link[rstac:stac_search]{rstac::stac_search()}} and executes the request. See
\code{\link[=rsi_query_api]{rsi_query_api()}} and the \code{query_function} slots of
\link{sentinel1_band_mapping}, \link{sentinel2_band_mapping}, and
\link{landsat_band_mapping}.}

\item{download_function}{A function that takes the output from
\code{query_function} and downloads the assets attached to those items. See
\code{\link[=rsi_download_rasters]{rsi_download_rasters()}} for an example.}

\item{sign_function}{A function that takes the output from \code{query_function}
and signs the item URLs, if necessary.}

\item{rescale_bands}{Logical of length 1: If the STAC collection implements
the \code{raster} STAC extension, and that extension includes \code{scale} and \code{offset}
values, should this function attempt to automatically rescale the downloaded
data?}

\item{item_filter_function}{A function that takes the outputs of
\code{query_function} (usually a \code{STACItemCollection}) and \code{...} and returns a
filtered \code{STACItemCollection}. This is used, for example, to only download
images from specific Landsat platforms.}

\item{mask_band}{Character of length 1: The name of the asset in your
STAC source to use to mask the data. Set to \code{NULL} to not mask. See the
\code{mask_band} slots of \link{sentinel1_band_mapping}, \link{sentinel2_band_mapping}, and
\link{landsat_band_mapping}.}

\item{mask_function}{A function that takes a raster and returns a boolean
raster, where \code{TRUE} pixels will be preserved and \code{FALSE} or \code{NA} pixels will
be masked out. See \code{\link[=sentinel2_mask_function]{sentinel2_mask_function()}}.}

\item{output_filename}{The filename to write the output raster to. If
\code{composite_function} is \code{NULL}, item datetimes will be appended to this
in order to create unique filenames. If items do not have datetimes, a
sequential ID will be appended instead.}

\item{composite_function}{Character of length 1: The name of a
function used to combine downloaded images into a single composite
(i.e., to aggregate pixel values from multiple images into a single value).
Options include "merge", which 'stamps' images on top of one another such that
the "last" value downloaded for a pixel -- which isn't guaranteed to be the most
recent one -- will be the only value used, or any of "sum", "mean", "median",
"min", or "max", which consider all values available at each pixel.
Set to \code{NULL} to not composite
(i.e., to rescale and save each individual file independently).}

\item{limit}{an \code{integer} defining the maximum number of results
to return. If not informed, it defaults to the service implementation.}

\item{gdalwarp_options}{Options passed to \code{gdalwarp} through the \code{options}
argument of \code{\link[sf:gdal_utils]{sf::gdal_utils()}}. The same set of options are used for all
downloaded data and the final output images; this means that some common
options (for instance, \code{PREDICTOR=3}) may cause errors if bands are of
varying data types. The default values are provided by
\code{\link[=rsi_gdalwarp_options]{rsi_gdalwarp_options()}}.}

\item{gdal_config_options}{Options passed to \code{gdalwarp} through the
\code{config_options} argument of \code{\link[sf:gdal_utils]{sf::gdal_utils()}}. The default values are
provided by \code{\link[=rsi_gdal_config_options]{rsi_gdal_config_options()}}.}

\item{platforms}{The names of Landsat satellites to download imagery from.
These do not correspond to the \code{platforms} column in \code{\link[=spectral_indices]{spectral_indices()}};
the default argument of \code{c("landsat-9", "landsat-8")} corresponds to
the \code{Landsat-OLI} value in that column.}
}
\value{
\code{output_filename}, unchanged.
}
\description{
These functions retrieve raster data from STAC endpoints and optionally
create composite data sets from multiple files.
\code{get_stac_data()} is a generic function which should be able to download
raster data from a variety of data sources, while the other helper functions
have useful defaults for downloading common data sets from standard
STAC sources.
}
\section{Usage Tips}{

It's often useful to buffer your \code{aoi} object slightly, on the order of 1-2
cell widths, in order to ensure that data is downloaded for your entire AOI
even after accounting for any reprojection needed to compare your AOI to
the data on the STAC server.

These functions allow for parallelizing downloads via \code{\link[future:plan]{future::plan()}}, and
for user-controlled progress updates via \code{\link[progressr:handlers]{progressr::handlers()}}. If
there are fewer images to download than \code{asset_names}, then this function
uses \code{\link[=lapply]{lapply()}} to iterate through images and \code{\link[future.apply:future_mapply]{future.apply::future_mapply()}}
to iterate through downloading each asset. If there are more images than
assets, this function uses \code{\link[future.apply:future_lapply]{future.apply::future_lapply()}} to iterate through
images.
}

\section{Downloading from Planetary Computer}{


Certain data sets in Planetary Computer require
\href{https://planetarycomputer.microsoft.com/docs/concepts/sas/}{providing a subscription key}.
Even for non-protected data sets, providing a subscription key grants you
higher rate limits and faster downloads. As such, it's a good idea to
\href{https://planetarycomputer.microsoft.com/account/request}{request a Planetary Computer account},
then \href{https://planetarycomputer.developer.azure-api.net/}{generate a subscription key}.
If you set the \code{rsi_pc_key} environment variable to your key (either primary
or secondary; there is no difference), rsi will automatically use
this key to sign all requests against Planetary Computer.

There are currently some challenges with certain Landsat images in Planetary
Computer; please see
https://github.com/microsoft/PlanetaryComputer/discussions/101
for more information on these images and their current status. These files
may cause data downloads to fail.
}

\section{Compositing}{


This function can either download all data that intersects with your
spatiotemporal AOI as multiple files (if \code{composite_function = NULL}),
or can be used to rescale band values, apply a mask function, and create a
composite from the resulting files in a single function call. Each of these
steps can be skipped by passing \code{NULL} to the corresponding argument.

Masks are applied to each downloaded asset separately. Rescaling is applied
to the final composite after images are combined.

A number of the steps involved in creating composites -- rescaling band
values, running the mask function, masking images, and compositing images --
currently rely on the \code{terra} package for raster calculations. This means
creating larger composites, either in geographic or temporal dimension, may
cause errors. It can be a good idea to tile your \code{aoi} using
\code{sf::st_make_grid()} and iterate through the tiles to avoid these errors
(and to make it easier to interrupt and restart a download job).
}

\section{Rescaling}{

If \code{rescale_bands} is \code{TRUE}, then this function is able to use the \code{scale}
and \code{offset} values in the \code{bands} field of the \code{raster} STAC extension.
This was implemented originally to work with the Landsat collections in the
Planetary Computer STAC catalogue, but hopefully will work automatically with
other data sources as well. Note that Sentinel-2 data typically doesn't use
this STAC extension, and so the returned data is typically not re-scaled;
divide the downloaded band values by 10000 to get reflectance values in the
expected values.
}

\section{Sentinel-1 Data}{

The \code{get_sentinel1_imagery()} function is designed to download Sentinel-1 data
from the Microsoft Planetary Computer STAC API. Both the GRD and RTC
Sentinel-1 collections are supported. To download RTC data,
set \code{collection} to \code{sentinel-1-rtc}, and supply your subscription key
as an environment variable named \code{rsi_pc_key} (through, e.g., \code{Sys.setenv()}
or your \code{.Renviron} file).
}

\section{AlOS PALSAR Data}{

The \code{get_alos_palsar_imagery()} function is designed to download ALOS PALSAR
annual mosaic data from the Microsoft Planetary Computer STAC API. Data are
returned as a digital number (which is appropriate for some applications
and indices). To convert to backscatter (decibels) use the following formula:
\code{10 * log10(dn) - 83.0} where dn is the radar band in digital number.
}

\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
aoi <- sf::st_point(c(-74.912131, 44.080410))
aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
aoi <- sf::st_buffer(sf::st_transform(aoi, 5070), 100)

get_stac_data(aoi,
  start_date = "2022-06-01",
  end_date = "2022-06-30",
  pixel_x_size = 30,
  pixel_y_size = 30,
  asset_names = c(
    "red", "blue", "green"
  ),
  stac_source = "https://planetarycomputer.microsoft.com/api/stac/v1/",
  collection = "landsat-c2-l2",
  query_function = rsi_query_api,
  sign_function = sign_planetary_computer,
  mask_band = "qa_pixel",
  mask_function = landsat_mask_function,
  item_filter_function = landsat_platform_filter,
  platforms = c("landsat-9", "landsat-8"),
  output_filename = tempfile(fileext = ".tif")
)

# or, mostly equivalently (will download more bands):
landsat_image <- get_landsat_imagery(
  aoi,
  start_date = "2022-06-01",
  end_date = "2022-08-30",
  output_filename = tempfile(fileext = ".tif")
)

landsat_image |> 
  terra::rast() |>
  terra::stretch() |>
  terra::plotRGB()

# The `get_*_imagery()` functions will download 
# all available "data" assets by default
# (usually including measured values, and excluding derived bands)
sentinel1_data <- get_sentinel1_imagery(
  aoi,
  start_date = "2022-06-01",
  end_date = "2022-07-01",
  output_filename = tempfile(fileext = ".tif")
)
names(terra::rast(sentinel1_data))

# You can see what bands will be downloaded by a function
# by inspecting the corresponding `band_mapping` object:
sentinel2_band_mapping$planetary_computer_v1

# And you can add additional assets using `c()`:
c(
  sentinel2_band_mapping$planetary_computer_v1,
  "scl"
)

# Or subset the assets downloaded using `[` or `[[`:
sentinel2_imagery <- get_sentinel2_imagery(
  aoi,
  start_date = "2022-06-01",
  end_date = "2022-07-01",
  asset_names = sentinel2_band_mapping$planetary_computer_v1["B01"],
  output_filename = tempfile(fileext = ".tif")
)
names(terra::rast(sentinel2_imagery))

# If you're downloading data for a particularly large AOI,
# and can't composite the resulting images or want to make
# sure you can continue an interrupted download,
# consider tiling your AOI and requesting each tile separately:
aoi <- sf::st_make_grid(aoi, n = 2)
tiles <- lapply(
  seq_along(aoi),
  function(i) {
    get_landsat_imagery(
      aoi[i],
      start_date = "2022-06-01",
      end_date = "2022-08-30",
      output_filename = tempfile(fileext = ".tif")
    )
  }
)
# You'll get a list of tiles that you can then composite or 
# work with however you wish:
unlist(tiles)
\dontshow{\}) # examplesIf}
}
