# rsi: Efficiently Retrieve and Process Satellite Imagery

Downloads spatial data from spatiotemporal asset catalogs ('STAC'),
computes standard spectral indices from the Awesome Spectral Indices
project (Montero et al. (2023)
[doi:10.1038/s41597-023-02096-0](https://doi.org/10.1038/s41597-023-02096-0)
) against raster data, and glues the outputs together into predictor
bricks. Methods focus on interoperability with the broader spatial
ecosystem; function arguments and outputs use classes from 'sf' and
'terra', and data downloading functions support complex 'CQL2' queries
using 'rstac'.

## See also

Useful links:

- <https://github.com/Permian-Global-Research/rsi>

- <https://permian-global-research.github.io/rsi/>

- Report bugs at <https://github.com/Permian-Global-Research/rsi/issues>

## Author

**Maintainer**: Michael Mahoney <mike.mahoney.218@gmail.com>
([ORCID](https://orcid.org/0000-0003-2402-304X))

Other contributors:

- Felipe Carvalho (Felipe reviewed the package (v. 0.3.0) for rOpenSci,
  see \<https://github.com/ropensci/software-review/issues/636\>)
  \[reviewer\]

- Michael Sumner (Michael reviewed the package (v. 0.3.0) for rOpenSci,
  see \<https://github.com/ropensci/software-review/issues/636\>)
  \[reviewer\]

- Permian Global \[copyright holder, funder\]
