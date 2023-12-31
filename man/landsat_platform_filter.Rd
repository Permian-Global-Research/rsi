% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/landsat_platform_filter.R
\name{landsat_platform_filter}
\alias{landsat_platform_filter}
\title{Filter Landsat features to only specific platforms}
\usage{
landsat_platform_filter(items, platforms)
}
\arguments{
\item{items}{A \code{STACItemCatalog} containing some number of features}

\item{platforms}{A vector of acceptable platforms, for instance \code{landsat-9}.
Note that this refers to satellite names, and \emph{not} to platforms in
\code{spectral_indices()}.}
}
\value{
A \code{STACItemCollection}.
}
\description{
Filter Landsat features to only specific platforms
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
aoi <- sf::st_point(c(-74.912131, 44.080410))
aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
aoi <- sf::st_buffer(sf::st_transform(aoi, 5070), 100)

landsat_image <- get_landsat_imagery(
  aoi,
  start_date = "2022-06-01",
  end_date = "2022-08-30",
  item_filter_function = landsat_platform_filter
)
\dontshow{\}) # examplesIf}
}
