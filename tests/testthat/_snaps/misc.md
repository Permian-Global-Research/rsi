# subsetting works

    Code
      landsat_band_mapping$planetary_computer_v1
    Output
      An rsi band mapping object with attributes:
      names mask_band mask_function stac_source collection_name query_function download_function sign_function class
      
      coastal    blue   green     red   nir08  swir16  swir22    lwir  lwir11 
          "A"     "B"     "G"     "R"     "N"    "S1"    "S2"     "T"    "T1" 

---

    Code
      landsat_band_mapping$planetary_computer_v1["red"]
    Output
      An rsi band mapping object with attributes:
      mask_band mask_function stac_source collection_name query_function download_function sign_function class names
      
      red 
      "R" 

---

    Code
      landsat_band_mapping$planetary_computer_v1[["red"]]
    Output
      An rsi band mapping object with attributes:
      mask_band mask_function stac_source collection_name query_function download_function sign_function class names
      
      red 
      "R" 

---

    Code
      landsat_band_mapping$planetary_computer_v1[landsat_band_mapping$
        planetary_computer_v1 == "R"]
    Output
      An rsi band mapping object with attributes:
      mask_band mask_function stac_source collection_name query_function download_function sign_function class names
      
      red 
      "R" 

# c works

    Code
      c(rsi::sentinel2_band_mapping$planetary_computer_v1, scl = "scl")
    Output
      An rsi band mapping object with attributes:
      mask_band mask_function stac_source collection_name query_function class scl_name download_function sign_function names
      
        B01   B02   B03   B04   B05   B06   B07   B08   B8A   B09   B11   B12   scl 
        "A"   "B"   "G"   "R" "RE1" "RE2" "RE3"   "N"  "N2"  "WV"  "S1"  "S2" "scl" 

