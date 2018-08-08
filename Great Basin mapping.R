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

#nevada <- subset(so.reproj, NAME %in% c("Nevada"))
#writeOGR(nevada, dsn = "./mapfiles", layer = "nevada", driver="ESRI Shapefile")

##################################################################
##################################################################
#      Start here every time after downloading the rasters       #
#     Set your working directory to the source file location     #
##################################################################
##################################################################

packages <- c("plyr", "ggplot2", "raster", "rgdal", "rasterVis", "wesanderson", "cowplot")
lapply(packages, library, character.only = TRUE)

rubyvalley <- raster("rubyvalley.img")
nevada <- shapefile("nevada.shp")
sampling.locations <- read.csv("RelictDaceSampling.csv", header=TRUE)

###### Elevation is in meters ######

# Use this guide to change labels and plot options:
# http://www.sthda.com/english/wiki/ggplot2-title-main-axis-and-legend-titles

pal <- wes_palette("Darjeeling1", 4, type="discrete")
ttl <- NULL
rubyvalley.plot <- gplot(rubyvalley, maxpixels = 5e5) + geom_tile(aes(fill = value)) +
  facet_wrap(~ variable) + scale_fill_continuous(low = "black", high = "white") +
  coord_quickmap(ylim=c(39,41.1), xlim=c(-116, -114)) + theme_minimal(base_size = 12) +
  geom_point(data=sampling.locations, aes(x=long, y=lat, shape=status, color=valley), size=2.5) +
  xlab("Latitude") + ylab("Longitude") +
  scale_color_manual(values=pal) +
  theme(plot.title = element_blank(),
        axis.title.x = element_text(face="bold",
                                    margin = margin(t = 10, r = 0, b = 0, l = 0)),
        axis.title.y = element_text(face="bold",
                                    margin = margin(t = 0, r = 10, b = 0, l = 0)),
        legend.title = element_text(face="bold")) + 
  labs(fill="Elevation (m)", shape="Sampling Status", color="Valley")

# Code for inset map
bounding <- as.data.frame(bbox(rubyvalley))
inset <- ggplot() + theme_void() + 
            geom_polygon(data=fortify(nevada), aes(x=long, y=lat, group=group),
                                 color="black", fill="white") +
         geom_rect(data=bounding, aes(xmin=min[1], xmax=max[1],
                                           ymin=min[2], ymax=max[2]),
                   color="black", fill=NA) + coord_map()
          
plot_grid(inset, rubyvalley.plot, ncol=2, rel_heights=c(1/4, 3/4))
dev_off()

# This saves a low resolution map for viewing only
# Change the dpi to 1200 when you need publication quality
ggsave("testmap.png", dpi=300, scale=2)
