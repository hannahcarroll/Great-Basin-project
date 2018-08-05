##### Start here only the first time you run this code. Skip after! #####
# Set your working directory to source file location

# This code will intall and load all required packages
packages <- c("plyr", "ggplot2", "raster", "rgdal", "rasterVis", "RColorBrewer", "tictoc")
new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(packages, library, character.only = TRUE)

# Highlight lines 11 to 47 and run all at once. This will take half an hour or so.
tic() # Just for fun
temp <- tempfile()
download.file("https://prd-tnm.s3.amazonaws.com/StagedProducts/Elevation/13/IMG/n40w115.zip", temp)
unzip(temp, exdir=getwd())
n40w115 <- raster("./imgn40w115_13.img")
unlink(temp)

temp <- tempfile()
download.file("https://prd-tnm.s3.amazonaws.com/StagedProducts/Elevation/13/IMG/n40w116.zip", temp)
unzip(temp, exdir=getwd())
n40w116 <- raster("./imgn40w116_13.img")
unlink(temp)

temp <- tempfile()
download.file("https://prd-tnm.s3.amazonaws.com/StagedProducts/Elevation/13/IMG/n41w115.zip", temp)
unzip(temp, exdir=getwd())
n41w115 <- raster("./imgn41w115_13.img")
unlink(temp)

temp <- tempfile()
download.file("https://prd-tnm.s3.amazonaws.com/StagedProducts/Elevation/13/IMG/USGS_NED_13_n41w116_IMG.zip",temp)
unzip(temp, exdir=getwd())
n41w116 <- raster("./USGS_NED_13_n41w116_IMG.img")
unlink(temp)

temp <- tempfile()
download.file("https://prd-tnm.s3.amazonaws.com/StagedProducts/Elevation/13/IMG/USGS_NED_13_n42w115_IMG.zip",temp)
unzip(temp, exdir=getwd())
n42w115 <- raster("./USGS_NED_13_n42w115_IMG.img")
unlink(temp)

temp <- tempfile()
download.file("https://prd-tnm.s3.amazonaws.com/StagedProducts/Elevation/13/IMG/USGS_NED_13_n42w116_IMG.zip",temp)
unzip(temp, exdir=getwd())
n42w116 <- raster("./USGS_NED_13_n42w116_IMG.img")
unlink(temp)
toc() # End the timer and how long that nonsense took

# Once all the files have downloaded and unzipped, run the next 3 lines
# This might take several minutes

# Make a list of all the rasters we need to combine
allmaps <- c(n40w115, n40w116, n41w115, n41w116, n42w115, n42w116)

# Merge the rasters into one bigger one
rubyvalley <- do.call(merge, allmaps)

# Write the new, bigger raster to file. You will work from this from now on.
writeRaster(rubyvalley, filename="rubyvalley.img", overwrite=TRUE)

# After you have successfully written the new raster, run this to clean up your environment:
remove(allmaps, n40w115, n40w116, n41w115, n41w116, n42w115, n42w116)

##### Skip this code #####
#bstate.outlines <- shapefile("./mapfiles/cb_2017_us_state_500k.shp")
# so.reproj <- spTransform(state.outlines, crs(rubyvalley))

# twostates <- subset(so.reproj, NAME %in% c("Utah", "Nevada"))
# writeOGR(twostates, dsn = "./mapfiles", layer = "state outlines2", driver="ESRI Shapefile")

##################################################################
##################################################################
#      Start here every time after downloading the rasters       #
#     Set your working directory to the source file location     #
##################################################################
##################################################################

packages <- c("plyr", "ggplot2", "raster", "rgdal", "rasterVis", "RColorBrewer")
lapply(packages, library, character.only = TRUE)

rubyvalley <- raster("rubyvalley.img")
twostates <- shapefile("state outlines.shp")
twostates.f <- fortify(twostates)

###### Elevation is in meters ######

# Use this guide to change labels and plot options:
# http://www.sthda.com/english/wiki/ggplot2-title-main-axis-and-legend-titles

gplot(rubyvalley, maxpixels = 5e5) + geom_tile(aes(fill = value)) +
  facet_wrap(~ variable) + scale_fill_continuous(low = "black", high = "white") +
  coord_quickmap(ylim=c(39,41.5), xlim=c(-116, -114)) + theme_minimal() +
  geom_polygon(data=twostates.f, aes(x=long, y=lat, group=group),
                               color="white", fill=NA)

# This saves a low resolution map for viewing only
# Change the dpi to 1200 when you need publication quality
ggsave("testmap.png", dpi=300, scale=2)
