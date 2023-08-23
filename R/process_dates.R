process_dates <- function(date) {
  if (date == "..") {
    return(date)
  } # open intervals
  date <- as.POSIXct(date, "UTC")
  date <- strftime(date, "%Y-%m-%dT%H:%M:%S%Z", "UTC")
  gsub("UTC", "Z", date)
}
