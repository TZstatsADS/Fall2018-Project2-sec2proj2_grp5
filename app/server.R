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
library(sp)
# if (require(devtools)) install.packages("devtools")
# devtools::install_github("AnalytixWare/ShinySky")
library(shinysky)
# library(maps)
# library(rgdal)

# Load data
injury_fatality_1718 <- read.csv('../data/injury_fatality_1718.csv')
citi_stations <- read.csv('../data/citi_stations.csv')

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
  }, ignoreNULL = FALSE)
  
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
  
  df_route2 <- eventReactive(input$getRoute2,{
    o <- input$origin2
    d <- input$destination2
    res <- google_directions(key = api_key,
                             origin = o,
                             destination = d,
                             mode = "bicycling",
                             alternatives = TRUE)
    df_routes <- res$routes$overview_polyline$points
    lst <- lapply(df_routes, function(x) {decode_pl(x)})
    dt <- rbindlist(lst, idcol = "id")
    lst_lines <- lapply(unique(dt$id), function(x){
      Lines(Line(dt[id == x, .(lon, lat)]), ID = x)
    })
    spl_lst <- SpatialLines(lst_lines)
    return(spl_lst)
  }, ignoreNULL = FALSE)
  
  output$bikeSafe <- renderLeaflet({
    df <- df_injury()
    spl_lst <- df_route2()
    
    injuryColor <- colorFactor(c('red','orange'), c('Injury','Fatality'))
    injuryOpacity <- function(injuries) {
      sapply(injuries$Type, function(x) { ifelse(x == 'Fatality', 2, 0.3) } )
    }
    injuryRadius <- function(injuries) {
      w <- sapply(injuries$Type, function(x) { ifelse(x == 'Fatality', 4, 1) } )
      w * injuries$Class
    }
    pal <- colorFactor("Dark2", NULL)
    
    m <- leaflet(data = spl_lst) %>%
      setView(lat = 40.75, lng = -73.92, zoom = 12) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolylines(opacity = 2, weight = 3, color = pal(1:length(spl_lst))) %>%
      addCircleMarkers(lng = df$Longitude, lat = df$Latitude,
                       radius = injuryRadius(df), color = injuryColor(df$Type),
                       opacity = injuryOpacity(df),
                       popup = paste("Type:", df$Type, "<br>","Class:", df$Class)) %>%
      addLegend(position = "bottomleft", pal = injuryColor, values = df$Type, opacity = 0.8, title = NULL)
    m
  })
})
