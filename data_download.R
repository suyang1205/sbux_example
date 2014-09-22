# Load Required packages
source("check_packages.R")
check_packages(c("httr","XML","stringr","jsonlite","rgeos","maptools"))


# Get county locations
nc_shp = readShapeSpatial(system.file("shapes/sids.shp", package="maptools")[1])
county_locs = coordinates(gCentroid(nc.shp, byid=TRUE))
rownames(county_locs) = as.character(nc_shp$NAME)


# Download Data

zip = 27701
url = paste0("http://www.starbucks.com/store-locator/search/location/",zip)

# dir.create("html/", showWarnings = FALSE)
# 
# file = paste0("html/",zip,".html")
# 
# 
# write(content(GET(url), as="text"), file=file)
# 
# 
# d = xmlRoot(htmlParse(file))
# 
# ul = getNodeSet(d, "//ul[@id='searchResults']")


### FAIL


# Attempt 2

url = "https://openapi.starbucks.com/v1/stores/nearby?callback=jQuery17205138783170841634_1411418054835&radius=50&limit=50&latLng=35.9981205%2C-78.89204440000003&ignore=storeNumber%2CownershipTypeCode%2CtimeZoneInfo%2CextendedHours%2ChoursNext7Days&brandCodes=SBUX&access_token=ga3tyvj9bgmkyuezazw2cwzk&_=1411418073026"

d=GET(url)

stopifnot(d$status_code == 200)

file = paste0("json/",zip,".json")
write(content(d, as="text"), file=file)

s = readLines(file)

s = str_replace(s, "[a-zA-Z0-9_]+\\(", "")
s = str_replace(s, "}\\)","}")

d = fromJSON(s)


l = lapply(d$stores, function(x){
    data.frame(
        id = x$store$id,
        name = x$store$name,
        lat = x$store$coordinates$latitude,
        long= x$store$coordinates$longitude,
        stringsAsFactors = FALSE
    )
})


l = do.call(rbind, l)

#rbind(l[[1]], l[[2]], l[[3]] ... l[[50]])
