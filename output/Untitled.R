##########
library(googleway)

## Shaolong's key
api_key <- "AIzaSyAJZcM_Y6wM6z1MEGebLPnQCVHE8RpM3Qg"
map_key <- "AIzaSyAJZcM_Y6wM6z1MEGebLPnQCVHE8RpM3Qg"

## set up a data.frame of locations
## can also use 'lat/lon' coordinates as the origin/destination
df_locations <- data.frame(
  origin = c("Bear Mountain")
  , destination = c("The Rita Plaza")
  , stringsAsFactors = F
)

## loop over each pair of locations, and extract the polyline from the result
lst_directions <- apply(df_locations, 1, function(x){
  res <- google_directions(
    key = api_key
    , origin = x[['origin']]
    , destination = x[['destination']]
  )
  
  df_result <- data.frame(
    origin = x[['origin']]
    , destination = x[['destination']]
    , route = res$routes$overview_polyline$points
  )
  return(df_result)
})

## convert the results to a data.frame
df_directions <- do.call(rbind, lst_directions)

## plot the map
google_map(key = map_key) %>%
  add_polylines(data = df_directions, polyline = "route") %>% 
  add_markers(lat = latitude, lon = -longitude, info_window = landmark)






















