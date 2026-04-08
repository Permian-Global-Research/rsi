# Landsat band mapping

This object is structured slightly differently from other band mapping
objects; it is a list of named lists, whose names correspond to DEM
collections available within a given STAC catalog. Those named lists are
then more standard band mapping objects, containing character vectors
with names corresponding to asset names and values equal to `elevation`.

## Usage

``` r
dem_band_mapping
```

## Format

An object of class `list` of length 1.

## Details

Band mapping objects:

These objects are semi-standardized sets of metadata which provide all
the necessary information for downloading data from a given STAC server.
The object itself is list of character vectors, whose names represent
asset names on a given STAC server and whose values represent the
corresponding standardized band name from the Awesome Spectral Indices
project. In addition to this data, these vectors usually have some of
(but not necessarily all of) the following attributes:

- `stac_source`: The URL for the STAC server this metadata corresponds
  to.

- `collection_name`: The default STAC collection for this data source.

- `download_function`: The function to be used to download assets from
  the STAC server.

- `mask_band`: The name of the asset on this server to be used for
  masking images.

- `mask_function`: The function to be used to mask images downloaded
  from this server.
