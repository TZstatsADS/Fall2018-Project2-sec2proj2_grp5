library(shiny)
library(shinydashboard)
library(data.table)
library(dplyr)
library(ggmap)
library(leaflet)
library(plotly)
library(RJSONIO)
library(geosphere)
library(purrr)
library(googleway)
# if (require(devtools)) install.packages("devtools")
# devtools::install_github("AnalytixWare/ShinySky")
library(shinysky)
# library(maps)
# library(rgdal)

# Load data
injury_fatality_1718 <- read.csv('../data/injury_fatality_1718.csv')
citi_stations <- read.csv('../data/citi_stations.csv')
load('../data/citi_aug18.csv') # data named as "citibikes"

shinyServer(function(input, output) {
  
  api_key <- 'AIzaSyAJZcM_Y6wM6z1MEGebLPnQCVHE8RpM3Qg'
  
  ################################################################
  ## Travel Planner
  ################################################################
  # helper method to get route, credit: https://stackoverflow.com/questions/49473094/plotting-waypoint-routes-with-googleway-in-shiny-app
  df_route <- eventReactive(input$getRoute,{
    o <- input$origin
    d <- input$destination
    return(data.frame(origin = o, destination = d, stringsAsFactors = F))
  })
  
  output$travelPlanner <- renderGoogle_map({
    df <- df_route()
    if(df$origin == "" | df$destination == "")
      return()
    
    res <- google_directions(key = api_key,
                             origin = df$origin,
                             destination = df$destination,
                             mode = "bicycling")
    
    df_route <- data.frame(route = res$routes$overview_polyline$points)
    
    google_map(key = api_key, search_box = FALSE, scale_control = TRUE, height = 1000) %>%
      add_traffic()%>%
      add_polylines(data = df_route,
                    polyline = "route",
                    stroke_colour = "#FF33D6",
                    stroke_weight = 5,
                    stroke_opacity = 0.7,
                    info_window = "New route",
                    load_interval = 100)
  })
  
  ################################################################
  ## Safety
  ################################################################
  df_injury <- reactive({
    months <- month(input$date_safe)
    years <- year(input$date_safe)
    hours <- input$hour_safe
    if (years[1] == years[2]) {
      injury <- injury_fatality_1718 %>%
        filter(Time >= hours[1] & Time <= hours[2]) %>%
        filter(Year == years[1] & Month >= months[1] & Month <= months[2])
    }
    else {
      injury <- injury_fatality_1718 %>%
        filter(Time >= hours[1] & Time <= hours[2]) %>%
        filter((Year == years[1] & Month >= months[1]) | (Year == years[2] & Month <= months[2]))
    }
    return(injury)
  })
  
  output$barSafe <- renderPlot({
    df <- df_injury()
    df$Time.Range <- factor(df$Time.Range, 
                            levels = c('0-3','3-6','6-9','9-12','12-15','15-18','18-21','21-24'),
                            labels = c('12am-3am','3am-6am','6am-9am','9am-12pm','12pm-3pm',
                                       '3pm-6pm','6pm-9pm','9pm-12am'))
    ggplot(data = as.data.frame(table(df$Time.Range))) +
      geom_bar(aes(x = Var1, y = Freq), stat = "identity", fill = 'steelblue3', width = 0.6) +
      coord_flip() +
      labs(x = NULL, y = NULL)
  })
  
  output$bikeSafe <- renderLeaflet({
    df <- df_injury()
    
    injuryColor <- colorFactor(c('red','orange'), c('Injury','Fatality'))
    injuryOpacity <- function(injuries) {
      sapply(injuries$Type, function(x) { ifelse(x == 'Fatality', 2, 0.3) } )
    }
    injuryRadius <- function(injuries) {
      w <- sapply(injuries$Type, function(x) { ifelse(x == 'Fatality', 4, 1) } )
      w * injuries$Class
    }
    
    m <- leaflet(data = df) %>%
      setView(lat = 40.725, lng = -73.92, zoom = 12) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addCircleMarkers(lng = ~Longitude, lat = ~Latitude,
                       radius = injuryRadius(df), color = ~injuryColor(Type), 
                       opacity = injuryOpacity(df), 
                       popup = paste("Type:", df$Type, "<br>","Class:", df$Class)) %>%
      addLegend(position = "bottomleft", pal = injuryColor, values = ~df$Type, opacity = 0.8, title = NULL)
    m
  })
  
  ################################################################
  ## Network Graph
  ################################################################
  
  output$Netgraph <- renderLeaflet({
    # remove trips whose station ID's are null
    null.start <- citibikes$start.station.name == "NULL"
    null.stop <- citibikes$end.station.name == "NULL"
    citibikes <- citibikes[-which(null.start), ]
    
    # extract list of all stations and their locations
    last <- as.character(unique(citibikes$start.station.name)[770]) # ...this one.
    station.index <- unique(citibikes[, 8:11])
    colnames(station.index) <- c("ID", "Name", "Latitude", "Longitude")
    # add "last" to the station index
    last.info <- unname(citibikes[citibikes$start.station.name == last, ][4:7])
    colnames(last.info) <- colnames(station.index)
    station.index <- rbind(station.index, last.info)
    
    station.index <- station.index[order(station.index$Name), ]
    
    ID <- as.character(station.index[, 1])
    names <- as.character(station.index[, 2])
    lat <- station.index[, 3]
    long <- station.index[, 4]
    
    # display all bike stations on an interactive map
    map <- leaflet() %>%
      addTiles() %>%
      addCircleMarkers(lng = long, lat = lat, 
                       popup = paste(names, ", ID: ", ID, sep = ""),
                       radius = 7)
    map
  })
  
})
