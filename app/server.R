library(shiny)
library(choroplethr)
library(choroplethrZip)
library(dplyr)
library(leaflet)
library(maps)
library(rgdal)

api_key <- 'AIzaSyAJZcM_Y6wM6z1MEGebLPnQCVHE8RpM3Qg'


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  
  
  output$travelPlanner <- renderLeaflet({
    
    leaflet() %>% 
      setView(lat = 40.749, lng = -73.98, zoom = 12) %>%
      addTiles()
    
  })
  
})