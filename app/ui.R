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

dashboardPage(
  dashboardHeader( title = "Bike Smart" ),
  
  # dashboard sidebar
  dashboardSidebar(
    sidebarMenu(
      ################################################################
      ## Maps tab side
      ################################################################
      menuItem("Interactive Map", tabName = "map",
               menuItem('Bike Smart, Bike Safe',
                        tabName = 'tSafety'),
               menuItem('Travel Planner',
                        tabName = 'tTravelPlanner'),
               menuItem('Landmarks',
                        tabName = 'tLandmark')),
      ################################################################
      ## Statistics tab side
      ################################################################
      menuItem("Data Explorer",  tabName = "stats",
               menuSubItem('Explore Citibike Data',
                           tabName = 'eda_citibike' )),
      ################################################################
      ## Contact tab side
      ################################################################
      # create Data Tab with subitems
      menuItem("Group Info", tabName = "info")
    )),
  
  # dashboard body
  dashboardBody(
    tabItems(
      ################################################################
      ## Maps tab body
      ################################################################
      tabItem(tabName = "tLandmark",
              h2("Find Citi bike stations near NYC landmarks"),
              leafletOutput("landmark")
      ),
      
      tabItem(tabName = "tTravelPlanner",
              h2("Best route to travel around NYC with Citi bike"),
              fluidRow(
                column(5, textInput(inputId = "origin", label = "Departure point", value = "W 116 St & Broadway")),
                column(5, textInput(inputId = "destination", label = "Destination point", value = "E 17 St & Broadway")),
                column(2, actionButton(inputId = "getRoute", label = "Go"))
              ),
              google_mapOutput(outputId = "travelPlanner")
      ),
      
      tabItem(tabName = "tSafety",
              h2("Avoid Bike Injuries and Fatalities"),
              leafletOutput("bikeSafe", height = 530),
              
              absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                            draggable = TRUE, top = 125, left = "auto", right = 18, bottom = "auto",
                            width = '25%', height = "auto", style = "opacity: 0.75",
                            
                            fluidRow(
                              column(10, offset = 1,
                                     sliderInput("date_safe", label = "Choose Date Range", 
                                                 min = as.Date("2017-10-01"), max = as.Date("2018-8-30"),
                                                 value = c(as.Date("2017-10-01"),as.Date("2018-8-30")),
                                                 timeFormat = "%b %Y"),
                                     sliderInput("hour_safe", label = "Choose Hour Range", 
                                                 min = 0, max = 24, value = c(0,24), step = 3),
                                     textInput(inputId = "origin2", label = "Departure point", value = "W 116 St & Broadway"),
                                     textInput(inputId = "destination2", label = "Destination point", value = "E 17 St & Broadway"),
                                     actionButton(inputId = "getRoute2", label = "Go"),
                                     
                                     plotOutput("barSafe", height = '180px')
                              ))
              )
      ),
      
      ################################################################
      ## Statistics tab body
      ################################################################
      tabItem(tabName = "eda_citibike",
              h2("Explore the Citi bike data"),
              
              
              leafletOutput("citibike data")
      ),
      
      ################################################################
      ## Contact  tab body
      ################################################################
      # Introduction tab content
      tabItem(tabName = "info",
              h2("Group 5"),
              h5("Dong, Xiaojing xd2195@columbia.edu"),
              h5("Kolins, Samuel sk3651@columbia.edu"),
              h5("Lin, Shaolong sl4095@columbia.edu"),
              h5("Qiu, Yimeng yq2231@columbia.edu"),
              h5("Yan, Jiaming jy2882@columbia.edu")
      )
              )
              ))

