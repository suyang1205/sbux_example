# Load Required packages
source("check_packages.R")
check_packages(c("httr","XML","stringr","jsonlite","rgeos","maptools"))


# Get county locations
nc_shp = readShapeSpatial(system.file("shapes/sids.shp", package="maptools")[1])
county_locs = coordinates(gCentroid(nc_shp, byid=TRUE))
rownames(county_locs) = as.character(nc_shp$NAME)


# Get Data

dir.create("json/", showWarnings = FALSE)

token = "z8f4vwmg4jm5ex6wdtzcsqnp"
other = "1411507618546"


for(i in 1:nrow(county_locs))
{
    name = rownames(county_locs)[i]
    lat  = county_locs[i,2]
    long = county_locs[i,1]

    offset = 0
    j = 1

    repeat 
    {
        cat("Fetching",name,"- Page",j,"...\n")

        url = paste0("https://openapi.starbucks.com/v1/stores/nearby",
                 "?callback=jQuery17205138783170841634_1411418054835",
                 "&radius=50",
                 "&limit=50",
                 "&latLng=", lat, "%2C", long,
                 "&ignore=storeNumber%2CownershipTypeCode%2CtimeZoneInfo%2CextendedHours%2ChoursNext7Days",
                 "&brandCodes=SBUX",
                 "&access_token=", token,
                 "&_=", other,
                 "&offset=",offset)

        d=GET(url)

        stopifnot(d$status_code == 200)

        # Clean up jQuery wrapper to get valid json
        s = content(d, as="text")
        s = str_replace(s, "[a-zA-Z0-9_]+\\(", "")
        s = str_replace(s, "}\\)","}")

        # Save the file locally
        file = paste0("json/",name,"_",j,".json")
        write(s, file=file)
        
        json = fromJSON(s)

        if (json$paging$total <= offset+50)
            break

        offset = offset+50
        j = j+1
    }

    # Wait a bit before moving on to the next county
    Sys.sleep(rexp(1,1/5))
}

