# Load Required packages
source("check_packages.R")
check_packages(c("httr","XML","stringr","jsonlite","rgeos","maptools"))


# Get county locations
nc_shp = readShapeSpatial(system.file("shapes/sids.shp", package="maptools")[1])
county_locs = coordinates(gCentroid(nc.shp, byid=TRUE))
rownames(county_locs) = as.character(nc_shp$NAME)


#