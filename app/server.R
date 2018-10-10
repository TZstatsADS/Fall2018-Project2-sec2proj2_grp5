library(shiny)
library(choroplethr)
library(choroplethrZip)
library(dplyr)
library(leaflet)
library(maps)
library(rgdal)
library(googleway)





# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  api_key <- 'AIzaSyAJZcM_Y6wM6z1MEGebLPnQCVHE8RpM3Qg'
  
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
                             mode = "driving")
    
    df_route <- data.frame(route = res$routes$overview_polyline$points)
    
    google_map(key = api_key, search_box = TRUE, scale_control = TRUE, height = 1000) %>%
      add_traffic()%>%
      add_polylines(data = df_route,
                    polyline = "route",
                    stroke_colour = "#FF33D6",
                    stroke_weight = 7,
                    stroke_opacity = 0.7,
                    info_window = "New route",
                    load_interval = 100)
  })
  
})