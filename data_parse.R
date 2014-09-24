# Load Required packages
source("check_packages.R")
check_packages(c("httr","XML","stringr","jsonlite","rgeos","maptools"))


# Get files
files = dir("json/",full.names=TRUE)


# Get Counts
counts = do.call(rbind, lapply(files, function(file) 
{
    j = fromJSON(file, simplifyDataFrame=FALSE)

    data.frame(file = file, 
               returned = j$paging$returned,
               stringsAsFactors = FALSE)
}))


# Parse store data
r = do.call(rbind, lapply(files, function(file)
{
    cat(file,"\n")
    j = fromJSON(file, simplifyDataFrame=FALSE)

    build_address = function(x)
    {
        x$countryCode = NULL
        x$city = paste(x$city, x$countrySubdivisionCode)
        x$countrySubdivisionCode = NULL

        paste(unlist(x),collapse=", ")
    }

    exists = function(x)
    {
        if (is.null(x)) NA
        else x
    }

    l=lapply(j$stores, 
             function(x)
             {
                  data.frame(id          = exists(x$store$id),
                             name        = exists(x$store$name),
                             brandName   = exists(x$store$brandName),
                             phoneNumber = exists(x$store$phoneNumber),
                             openDate    = exists(x$store$operatingStatus$openDate),
                             status      = exists(x$store$operatingStatus$status),
                             address     = build_address(x$store$address),
                             lat         = exists(x$store$coordinates$latitude),
                             long        = exists(x$store$coordinates$longitude),
                             currency    = exists(x$store$currency),
                             stringsAsFactors=FALSE)
             }
    )

    do.call("rbind",l)
}))


# Are IDs unique?
stopifnot( length(unique(r$id)) == nrow(unique(r)) )

# Cleanup
r = unique(r)


save(r, file = "NC_Starbucks.Rdata")


