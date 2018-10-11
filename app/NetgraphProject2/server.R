library(shiny)
library(shinydashboard)
library(leaflet)
library(leaflet.minicharts)
library(chron)
library(geosphere)
library(dplyr)

load("./data/citi_aug18.RData") # data named as "citibikes"

# define server logic required to plot the netgraph
shinyServer(function(input, output) {
  
  starttime <- citibikes$starttime
  date <- format(as.POSIXct(strptime(starttime, "%F %H:%M:%OS", tz="")), format = "%F")
  time <- format(as.POSIXct(strptime(starttime, "%F %H:%M:%OS", tz="")), format = "%H:%M")
  citibikes$Date <- date
  citibikes$Time <- time
  
  citi <- reactive({
    
    day.select <- input$aug_day
    time.select <- substr(times(input$aug_time / 24), 1, 5)
    
    if(day.select[1] == day.select[2]) {
      bikes <- citibikes %>% 
        filter(Date == day.select[1]) %>%
        filter(time.select[1] <= Time & Time <= time.select[2])
    }
    else {
      bikes <- citibikes %>% 
        filter((Date == day.select[1] & Time >= time.select[1]) | 
                 (Date == day.select[2] & Time <= time.select[2]))
    }
    return(bikes)
  })
   
  output$Netgraph <- renderLeaflet({
    
    ct <- citi()
    cat(file = stderr(), if(is.null(ct)) return(NULL))
    
    # remove trips whose station ID's are null
    null.start <- ct$start.station.name == "NULL"
    ct <- ct[-which(null.start), ]
    # no need to remove the null stopstations because I found ahead of time that they're the same
    
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
    
    # to create the netgraph, we need an index of path data
    path.index <- unique(ct[, c(5:7, 9:11)])
    # finding paths with same starting and ending point
    null.path <- which(as.character(path.index$start.station.name) == 
                         as.character(path.index$end.station.name))
    path.index <- path.index[-null.path, ] # removing those paths
    # reordering the paths alphabetically by start station and then end station
    path.index <- path.index[order(path.index$start.station.name, path.index$end.station.name), ]
    # creating frequency table
    path.table <- table(ct$start.station.name, ct$end.station.name)
    path.table <- as.data.frame(path.table)
    colnames(path.table) <- c("Start", "End", "Freq")
    # if we order the data by start and then end station and remove null paths, the data in
    # path.table will be ordered the same as in path.index
    null.path.tab <- which(as.character(path.table$Start) == as.character(path.table$End))
    path.table <- path.table[-null.path.tab, ]
    path.table <- path.table[order(path.table$Start, path.table$End), ]
    paths.found <- path.table[path.table$Freq > 0, ]
    # adding the frequencies to path.index
    path.index$Freq <- paths.found$Freq
    colnames(path.index) <- c("StartName", "StartLat", "StartLong", 
                              "EndName", "EndLat", "EndLong", "Freq")
    
    # adding flowlines to represent frequency and average velocity
    startlat <- as.numeric(path.index$StartLat)
    startlong <- as.numeric(path.index$StartLong)
    endlat <- as.numeric(path.index$EndLat)
    endlong <- as.numeric(path.index$EndLong)
    freq <- path.index$Freq
    startcoords <- cbind(startlong, startlat)
    colnames(startcoords) <- c("Longitude", "Latitude")
    endcoords <- cbind(endlong, endlat)
    colnames(endcoords) <- c("Longitude", "Latitude")
    # but first, we need to add distance and time data
    path.index$Dist <- distHaversine(startcoords, endcoords) # in meters
    avg.time <- aggregate(ct$tripduration, ct[, c(5, 9)], mean)
    colnames(avg.time) <- c("Start", "End", "AvgTime")
    null.path.time <- which(as.character(avg.time$Start) == as.character(avg.time$End))
    avg.time <- avg.time[-null.path.time, ]
    avg.time <- avg.time[order(avg.time$Start, avg.time$End), ]
    path.index$AvgTime <- avg.time$AvgTime
    path.index$AvgVelo <- path.index$Dist / path.index$AvgTime # in meters per second
    velo <- path.index$AvgVelo
    
    # the colors of the flowlines will depend on the average velocity
    # the thickness of the flowlines depends on the frequency
    rainbow <- colorNumeric(c("red", "green"), domain = NULL)
    map %>%
      addFlows(startlong, startlat,
               endlong, endlat, 
               color = rainbow(1 + 20 * (velo - min(velo)) / max(velo)), 
               flow = freq, 
               opacity = 0.75, 
               popup = popupArgs(labels = "Freq"),
               maxThickness = 50) %>%
      addLegend("bottomright", pal = rainbow, values = velo,
                title = "Average Bike Velocity", 
                labFormat = labelFormat(suffix = " m/s"),
                opacity = 1)
    map
  })
  
})
