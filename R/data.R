#' Sentinel-2 band mapping
#'
#' This object is a named list of character vectors, with names corresponding to
#' Sentinel-2 band names and values corresponding to band names in
#' `spectral_indices`.
#'
#' @template band_mappings
"sentinel2_band_mapping"

#' Sentinel-1 band mapping
#'
#' This object is a named list of character vectors, with names corresponding to
#' Sentinel-1 band names and values corresponding to band names in
#' `spectral_indices`.
#'
#' @template band_mappings
"sentinel1_band_mapping"

#' Landsat band mapping
#'
#' This object is a named list of character vectors, with names corresponding to
#' Landsat band names and values corresponding to band names in
#' `spectral_indices`.
#'
#' @template band_mappings
"landsat_band_mapping"

#' ALOS PALSAR band mapping
#'
#' This object is a named list of character vectors, with names corresponding to
#' Landsat band names and values corresponding to band names in
#' `spectral_indices`.
#'
#' @template band_mappings
"alos_palsar_band_mapping"


#' Landsat band mapping
#'
#' This object is structured slightly differently from other band mapping
#' objects; it is a list of named lists, whose names correspond to DEM
#' collections available within a given STAC catalog. Those named lists are
#' then more standard band mapping objects, containing character vectors with
#' names corresponding to asset names and values equal to `elevation`.
#'
#' @template band_mappings
"dem_band_mapping"
