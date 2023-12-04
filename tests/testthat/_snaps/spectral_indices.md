# no cache, update false

    Code
      spectral_indices(update_cache = FALSE)
    Condition
      Warning:
      No cache file present and `download_indices` set to `FALSE`.
      i Returning (likely outdated) package data instead.
    Output
      # A tibble: 231 x 9
         application_domain bands     contributor   date_of_addition formula long_name
         <chr>              <list>    <chr>         <chr>            <chr>   <chr>    
       1 vegetation         <chr [2]> https://gith~ 2021-11-17       (N - 0~ Aerosol ~
       2 vegetation         <chr [2]> https://gith~ 2021-11-17       (N - 0~ Aerosol ~
       3 water              <chr [6]> https://gith~ 2022-09-22       (B + G~ Augmente~
       4 vegetation         <chr [2]> https://gith~ 2021-09-20       (1 / G~ Anthocya~
       5 vegetation         <chr [3]> https://gith~ 2022-04-08       N * ((~ Anthocya~
       6 vegetation         <chr [4]> https://gith~ 2021-05-11       (N - (~ Atmosphe~
       7 vegetation         <chr [4]> https://gith~ 2021-05-14       sla * ~ Adjusted~
       8 vegetation         <chr [2]> https://gith~ 2022-04-08       (N * (~ Advanced~
       9 water              <chr [4]> https://gith~ 2021-09-18       4.0 * ~ Automate~
      10 water              <chr [5]> https://gith~ 2021-09-18       B + 2.~ Automate~
      # i 221 more rows
      # i 3 more variables: platforms <list>, reference <chr>, short_name <chr>

# no cache, download false

    Code
      spectral_indices(download_indices = FALSE)
    Condition
      Warning:
      No cache file present and `download_indices` set to `FALSE`.
      i Returning (likely outdated) package data instead.
    Output
      # A tibble: 231 x 9
         application_domain bands     contributor   date_of_addition formula long_name
         <chr>              <list>    <chr>         <chr>            <chr>   <chr>    
       1 vegetation         <chr [2]> https://gith~ 2021-11-17       (N - 0~ Aerosol ~
       2 vegetation         <chr [2]> https://gith~ 2021-11-17       (N - 0~ Aerosol ~
       3 water              <chr [6]> https://gith~ 2022-09-22       (B + G~ Augmente~
       4 vegetation         <chr [2]> https://gith~ 2021-09-20       (1 / G~ Anthocya~
       5 vegetation         <chr [3]> https://gith~ 2022-04-08       N * ((~ Anthocya~
       6 vegetation         <chr [4]> https://gith~ 2021-05-11       (N - (~ Atmosphe~
       7 vegetation         <chr [4]> https://gith~ 2021-05-14       sla * ~ Adjusted~
       8 vegetation         <chr [2]> https://gith~ 2022-04-08       (N * (~ Advanced~
       9 water              <chr [4]> https://gith~ 2021-09-18       4.0 * ~ Automate~
      10 water              <chr [5]> https://gith~ 2021-09-18       B + 2.~ Automate~
      # i 221 more rows
      # i 3 more variables: platforms <list>, reference <chr>, short_name <chr>

# no cache, download and update false

    Code
      spectral_indices(download_indices = FALSE, update_cache = FALSE)
    Condition
      Warning:
      No cache file present and `download_indices` set to `FALSE`.
      i Returning (likely outdated) package data instead.
    Output
      # A tibble: 231 x 9
         application_domain bands     contributor   date_of_addition formula long_name
         <chr>              <list>    <chr>         <chr>            <chr>   <chr>    
       1 vegetation         <chr [2]> https://gith~ 2021-11-17       (N - 0~ Aerosol ~
       2 vegetation         <chr [2]> https://gith~ 2021-11-17       (N - 0~ Aerosol ~
       3 water              <chr [6]> https://gith~ 2022-09-22       (B + G~ Augmente~
       4 vegetation         <chr [2]> https://gith~ 2021-09-20       (1 / G~ Anthocya~
       5 vegetation         <chr [3]> https://gith~ 2022-04-08       N * ((~ Anthocya~
       6 vegetation         <chr [4]> https://gith~ 2021-05-11       (N - (~ Atmosphe~
       7 vegetation         <chr [4]> https://gith~ 2021-05-14       sla * ~ Adjusted~
       8 vegetation         <chr [2]> https://gith~ 2022-04-08       (N * (~ Advanced~
       9 water              <chr [4]> https://gith~ 2021-09-18       4.0 * ~ Automate~
      10 water              <chr [5]> https://gith~ 2021-09-18       B + 2.~ Automate~
      # i 221 more rows
      # i 3 more variables: platforms <list>, reference <chr>, short_name <chr>

# download false and update true

    Code
      spectral_indices(download_indices = FALSE, update_cache = TRUE)
    Condition
      Error in `spectral_indices()`:
      ! Cannot update the cache if not downloading indices.

