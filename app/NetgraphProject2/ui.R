library(shiny)
library(shinydashboard)
library(leaflet)
library(leaflet.minicharts)

dashboardPage(
  
  dashboardHeader(title = "Bike Smart"),
  
  # dashboard sidebar
  dashboardSidebar(
    sidebarMenu(
      menuItem("Map", tabName = "map",
               menuItem('Network Graph',
                        tabName = 'tNetgraph'))
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "tNetgraph",
              h2("Network Graph: Bike Paths in August 2018"),
              leafletOutput("Netgraph", height = 530),
              
              fixedPanel(id = "controls", class = "panel panel-default",
                         draggable = TRUE, top = 125, left = "auto", right = 18, bottom = "auto",
                         width = '25%', height = "auto", style = "opacity: 0.75",
                         
                         fluidRow(
                           column(10, offset = 1,
                                  sliderInput("aug_day", label = "Date Range",
                                              min = as.Date("2018-8-01"), 
                                              max = as.Date("2018-8-31"),
                                              value = c(as.Date("2018-8-01"),
                                                        as.Date("2018-8-01")),
                                              timeFormat = "%b %e"),
                                  sliderInput("aug_time", label = "Time Range",
                                              min = 0, max = 23, value = c(0, 1),
                                              step = 1))
                         )))
    )
  )
)
