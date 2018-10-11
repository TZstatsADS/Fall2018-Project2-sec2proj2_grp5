citibikes <- read.csv("201808-citibike-tripdata.csv", as.is = FALSE)

library(leaflet)
library(magrittr) # for pipe
library(dplyr) # for dataframe manipulation
library(geosphere) # for distance calculations

# remove trips whose station ID's are null
null.start <- citibikes$start.station.name == "NULL"
null.stop <- citibikes$end.station.name == "NULL"
which(which(null.start) != which(null.stop)) # verifies that these are actually the same
citibikes <- citibikes[-which(null.start), ]

# extract list of all stations and their locations
unique(citibikes$start.station.name) %in% unique(citibikes$end.station.name)
# here, all of the CitiBike start stations are also end stations except for...
last <- as.character(unique(citibikes$start.station.name)[770]) # ...this one.
# so we can work directly with the end stations and ignore the start stations except for "last"

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

# to create the netgraph, we need an index of path data
path.index <- unique(citibikes[, c(5:7, 9:11)])
# finding paths with same starting and ending point
null.path <- which(as.character(path.index$start.station.name) == 
                     as.character(path.index$end.station.name))
path.index <- path.index[-null.path, ] # removing those paths
# reordering the paths alphabetically by start station and then end station
path.index <- path.index[order(path.index$start.station.name, path.index$end.station.name), ]
# creating frequency table
path.table <- table(citibikes$start.station.name, citibikes$end.station.name)
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

# let's try adding flowlines to the map that represent frequencies
startlat <- path.index$StartLat
startlong <- path.index$StartLong
startname <- path.index$StartName
endlat <- path.index$EndLat
endlong <- path.index$EndLong
endname <- path.index$EndName
freq <- path.index$Freq
redblue <- colorRamp(c("red", "green", "blue"), interpolate = "spline")
map %>%
  addFlows(startlong[1:100], startlat[1:100],
           endlong[1:100], endlat[1:100], 
           color = rgb(redblue(freq[1:100] / 20), maxColorValue = 255), 
           flow = freq[1:100], 
           opacity = 0.75, 
           popup = popupArgs(labels = "Freq"),
           maxThickness = 50)
# of note: it takes an EXTREMELY long time to render all the points for the data set
# this means we'll probably have to select the data by day, more on that later

# we will alter their colors to reflect the average velocities
# but first, we need to add distance and time data
path.index$Dist <- distHaversine(path.index[, 2:3], path.index[, 5:6]) # in meters
avg.time <- aggregate(citibikes$tripduration, citibikes[, c(5, 9)], mean)
colnames(avg.time) <- c("Start", "End", "AvgTime")
null.path.time <- which(as.character(avg.time$Start) == as.character(avg.time$End))
avg.time <- avg.time[-null.path.time, ]
avg.time <- avg.time[order(avg.time$Start, avg.time$End), ]
path.index$AvgTime <- avg.time$AvgTime
path.index$AvgVelo <- path.index$Dist / path.index$AvgTime # in meters per second
velo <- path.index$AvgVelo

# the colors of the flowlines will depend on the average velocity
rainbow <- colorNumeric(c("red", "green"), domain = NULL)
rainbowbin <- colorBin(c("#FF0000", "#00FF00", "#0000FF"), velo, 10)
map %>%
  addFlows(startlong[1:1000], startlat[1:1000],
           endlong[1:1000], endlat[1:1000], 
           color = rainbow(1 + 20 * (velo[1:1000] - min(velo[1:1000])) / max(velo[1:1000])), 
           flow = freq[1:1000], 
           opacity = 0.75, 
           popup = popupArgs(labels = "Freq"),
           maxThickness = 50) %>%
  addLegend("bottomright", pal = rainbow, values = velo[1:1000],
            title = "Average Bike Velocity", 
            labFormat = labelFormat(suffix = " m/s"),
            opacity = 1)
