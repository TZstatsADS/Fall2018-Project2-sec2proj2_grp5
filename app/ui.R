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
      menuItem("Map", tabName = "map",
               menuItem('Travel Planner',
                        tabName = 'tTravelPlanner'),
               menuItem('Bike Safe',
                        tabName = 'tSafety'),
               menuItem('Landmarks',
                        tabName = 'tLandmark')),
      ################################################################
      ## Statistics tab side
      ################################################################
      menuItem("Report",  tabName = "stats",
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
                column(5, textInput(inputId = "origin", label = "Departure point")),
                column(5, textInput(inputId = "destination", label = "Destination point")),
                column(2, actionButton(inputId = "getRoute", label = "Go"))
              ),
              google_mapOutput(outputId = "travelPlanner")
      ),
      
      tabItem(tabName = "tSafety",
              h2("Bike Injuries and Fatalities"),
              fluidRow(
                column(4,
                       sliderInput("date_safe", label = "Choose Date Range", 
                                   min = as.Date("2017-10-01"), max = as.Date("2018-8-30"),
                                   value = c(as.Date("2017-10-01"),as.Date("2018-8-30")),
                                   timeFormat = "%b %Y"),
                       sliderInput("hour_safe", label = "Choose Hour Range", 
                                   min = 0, max = 24, value = c(0,24), step = 3)
                ),
                column(4,
                       textInput(inputId = "origin", label = "Departure point"),
                       textInput(inputId = "destination", label = "Destination point"),
                       actionButton(inputId = "getRoute", label = "Get Route")
                ),
                column(4,
                       plotOutput("barSafe", height = '200px')
                )
              ),
              
              hr(),
              leafletOutput("bikeSafe", height = 600)
              
              # google_mapOutput(outputId = "safeRoute"),
              # textInput(inputId = "origin", label = "Departure point"),
              # textInput(inputId = "destination", label = "Destination point"),
              # actionButton(inputId = "getRoute", label = "Get Route")
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

