### Setup stuff you don't need
library(plyr)

n40w115 <- raster("./rubyvalley/imgn40w115_13.img")
n40w116 <- raster("./rubyvalley/imgn40w116_13.img")
n41w115 <- raster("./rubyvalley/imgn41w115_13.img")
n41w116 <- raster("./rubyvalley/USGS_NED_13_n41w116_IMG.img")
n42w115 <- raster("./rubyvalley/USGS_NED_13_n42w115_IMG.img")
n42w116 <- raster("./rubyvalley/USGS_NED_13_n42w116_IMG.img")

allmaps <- c(n40w115, n40w116, n41w115, n41w116, n42w115, n42w116)
rubyvalley <- do.call(merge, allmaps)

writeRaster(rubyvalley, filename="rubyvalley.img", overwrite=TRUE)

state.outlines <- shapefile("./mapfiles/cb_2017_us_state_500k.shp")
so.reproj <- spTransform(state.outlines, crs(greatbasin))

twostates <- subset(so.reproj, NAME %in% c("Utah", "Nevada"))
writeOGR(twostates, dsn = "./mapfiles", layer = "state outlines", driver="ESRI Shapefile")

########################################################
########################################################
#      Start here and set your working directory       #
########################################################
########################################################

library(plyr)
library(raster)
library(rgdal)
library(ggplot2)
library(rasterVis)
library(RColorBrewer)

rubyvalley <- raster("rubyvalley.img")
twostates <- shapefile("state outlines.shp")
twostates.f <- fortify(twostates)

###### Elevation is in meters ######

gplot(rubyvalley, maxpixels = 5e5) + geom_tile(aes(fill = value)) +
  facet_wrap(~ variable) + scale_fill_continuous(low = "#252525", high = "#ffffff") +
  coord_quickmap(ylim=c(39,41.5), xlim=c(-116, -114)) + theme_minimal() +
  geom_polygon(data=twostates.f, aes(x=long, y=lat, group=group),
                               color="white", fill=NA)

ggsave("testmap2.png", dpi=300, scale=2)
