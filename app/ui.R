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
# library(shinysky)

dashboardPage(
  dashboardHeader( title = "Bike Smart in NYC" ),
  
  # dashboard sidebar
  dashboardSidebar(
    sidebarMenu(
      # menuItem("Bike Smart, Bike Safe", tabName = "all",
      #          menuItem('Choosing the Safest Route',
      #                   tabName = 'tSafety'),
      #          menuItem('Bike Lanes',
      #                   tabName = 'tLane')
      # ),
      menuItem("Bike Smart, Bike Safe",  tabName = 'tSafety'),
      ################################################################
      ## Maps tab side
      ################################################################
      menuItem("Bike Routes for Visitors", tabName = "map",
               menuItem('Landmarks',
                        tabName = 'tLandmark'),
               menuItem('Travel Planner',
                        tabName = 'tTravelPlanner')
               ),
      ################################################################
      ## Statistics tab side
      ################################################################
      menuItem("Data Explorer",  tabName = "eda_citibike2"),
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
              h2("NYC landmarks and bike rides you don't want to miss"),
              leafletOutput("landmark", height = 600)
      ),
      # tabItem(tabName = "tLane",
      #         h2("Ride in NYC bike lanes"),
      #         leafletOutput("bikeLane")
      # ),
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
                                     textInput(inputId = "origin2", label = "Departure point", value = "W 116 St & Broadway"),
                                     textInput(inputId = "destination2", label = "Destination point", value = "E 17 St & Broadway"),
                                     actionButton(inputId = "getRoute2", label = "Go"),
                                     
                                     sliderInput("date_safe", label = "Choose Date Range", 
                                                 min = as.Date("2017-10-01"), max = as.Date("2018-8-30"),
                                                 value = c(as.Date("2017-10-01"),as.Date("2018-8-30")),
                                                 timeFormat = "%b %Y"),
                                     sliderInput("hour_safe", label = "Choose Hour Range", 
                                                 min = 0, max = 24, value = c(0,24), step = 3),
                                     plotOutput("barSafe", height = '180px')
                              ))
              )
      ),
      
      ################################################################
      ## Statistics tab body
      ################################################################
      tabItem(tabName = "eda_citibike2",
              fluidRow(
                column(4, selectInput("var", label = h5("Choose Variable"),
                                      choices = list("Gender"='gender',
                                                     "Weekend"='Week',
                                                     "Group"='Group'),
                                      selected = 'Week')),
                column(4, selectInput("month", label = h5("Choose Month"),
                                      choices = list("All Month"=0,
                                                     "Jan"='2018-01',
                                                     "Feb"='2018-02',
                                                     "May"='2018-03',
                                                     "Apr"='2018-04',
                                                     "Mar"='2018-05',
                                                     "Jun"='2018-06',
                                                     "Jul"='2018-07',
                                                     "Aug"='2018-08',
                                                     "Sep"='2018-09',
                                                     "Oct"='2017-10',
                                                     "Nov"='2017-11',
                                                     "Dec"='2017-12'),
                                      selected = 0))
              ),
              plotOutput("plot")
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

