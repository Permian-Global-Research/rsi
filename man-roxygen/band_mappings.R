#' @details Band mapping objects:
#'
#' These objects are semi-standardized sets of metadata which provide all the
#' necessary information for downloading data from a given STAC server.
#' The object itself is list of character vectors, whose names represent asset
#' names on a given STAC server and whose values represent the corresponding
#' standardized band name from the Awesome Spectral Indices project. In addition
#' to this data, these vectors usually have some of (but not necessarily all of)
#' the following attributes:
#'
#' + `stac_source`: The URL for the STAC server this metadata corresponds to.
#' + `collection_name`: The default STAC collection for this data source.
#' + `download_function`: The function to be used to download assets from the
#' STAC server.
#' + `mask_band`: The name of the asset on this server to be used for masking
#' images.
#' + `mask_function`: The function to be used to mask images downloaded from
#' this server.
