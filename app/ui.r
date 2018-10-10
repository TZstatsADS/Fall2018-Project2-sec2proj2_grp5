library(shiny)
library(shinydashboard)
library(data.table)
library(ggmap)
library(leaflet)
library(plotly)
library('RJSONIO')
library('geosphere')
library('purrr')

dashboardPage(
  
  ## dashboard header
  dashboardHeader( title = "Welcome to NYC!" ),
  
  ## dashboard sidebar
  dashboardSidebar(
    sidebarMenu(
      
      ################################################################
      ## Introduction tab side
      ################################################################
      menuItem("Introduction", tabName = "intro"),
      
      
      
      ################################################################
      ## Maps tab side
      ################################################################
      # create Maps Tab with subitems
      menuItem("Map", tabName = "map",
               
               menuItem('Landmarks',
                        tabName = 'tLandmark'),   
               menuItem('Travel Planner',
                        tabName = 'tTravelPlanner' )),
      
      
      
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
      menuItem("Contact us", tabName = "contact")
      
      
    )),
  
  ## dashboard body
  dashboardBody(
    
    tabItems(
      
      ################################################################
      ## Introduction tab body
      ################################################################
      # Introduction tab content
      tabItem(tabName = "intro",
              
              h2("Introduction"),
              
              h4(type="html", " We care about living a green life, and we have a 
                 hunch that we’re not the only ones. Global warming 
                 is real, and driving our cars creates more 
                 greenhouse gases that are contributing to the 
                 problem. Crops are yielding less food, glaciers 
                 are melting causing the ocean levels to rise, and 
                 droughts are plaguing areas that once had plenty 
                 of water. But living a 
                 green life is important for our personal health, too."),
              h3(""),
              h4("The academic 
                 literature on the effect of air pollutants on our 
                 health has grown dramatically in the last decade, 
                 all pointing in the same direction. We now know 
                 that breathing pollutants has a strong relationship
                 with small health problems like 
                 allergies and asthma, and even deadly 
                 cardiovascular diseases. In fact, the Global 
                 Burden of Disease has ranked exposure to 
                 airborne pollution as the seventh most important 
                 factor to mortality worldwide. And the National 
                 Institute of Health has identified a strong 
                 relationship between those who develop lung cancer 
                 and those who are exposed to air pollution on a 
                 daily basis."),
              h3(""),
              h4("Furthermore, these pollutants are 
                 more present in dense urban areas, and if New York 
                 City is anything, it’s a dense urban area. We want to help you live 
                 a life in New York City and enjoy the benefits of 
                 an urban life while avoiding the problems 
                 associated with breathing bad air. Our tool will 
                 help you:"),
              h3(""),
              
              h4("•	Explore the distribution of air pollution in New York so 
                 you can find a place to live with cleaner air \n"
              ),
              
              tags$h4(" •	Show you the location of bike-share stations so you can 
                      fight the problem of air pollution by avoiding the harmful fossil-
                      fuel combustion of motor vehicles \n"),
              tags$h4("•	Identify community gardens to help find safe produce 
                      and avoid having to choose between potentially dangerous 
                      genetically modified organisms (GMO’s) and expensive organic 
                      alternatives \n"),
              h3(""),
              
              h4("Living green is important, and we want to empower 
                 you to do your part. Enjoy our tool and learn how to live an 
                 environmentally friendly life. It’s more important now than ever 
                 to take action to solve our environmental problems. Because these changes in our planet are serious, 
                 and without action, they're only going to get worse."),
              HTML('<p><img src="image_nyc.jpg"/></p>')
              
              
              
              ),
      
      
      
      ################################################################
      ## Maps tab body
      ################################################################
      
      # Garden map tab content
      tabItem(tabName = "tTravelPlanner",
              
              h2("See what's the best route to travel around NYC with Citi bike"),
              
              
              
              leafletOutput("travelPlanner")
              
      ),
      
      # Air quality map tab content
      tabItem(tabName = "tLandmark",
              
              h2("See all the landmarks in NYC"),
              
              leafletOutput("landmark")
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
      tabItem(tabName = "contact",
              
              h2("Contact us"),
              
              h3( "We are Group 5."),
              
              h5("Dong, Xiaojing xd2195@columbia.edu"),
              h5("Kolins, Samuel sk3651@columbia.edu"),
              h5("Lin, Shaolong sl4095@columbia.edu"),
              h5("Qiu, Yimeng yq2231@columbia.edu"),
              h5("Yan, Jiaming jy2882@columbia.edu")
              
      )
      
              )
              ))


