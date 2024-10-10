**Independent Research Project for STAT574E introducing and exploring the R package "rFIA"**

The rFIA package was created with the goal of increasing the accessibility and use of the USFS Forest Inventory and 
analysis (FIA) Database. There are a suite of functions assosiated with the package that help users easily query and 
more easily analyize data. 

The lead author of the rFIA package is Hunter Stanke, a PhD student in the The Harvey Lab and the Ecosystem 
Biogeochemistry Group in School of Environmental and Forest Science at the University of Washington. Andrew O. 
Finley is the co-author of this package. He is a professor at Michigan State University with a joint appointment 
in the Departments of FOrestry and Geography. It was originally published to the CRAN repository in 2020 but was 
removed and archived in 2023 while issues are being addressed. 

**Installation**
Because the rFIA package has been removed from CRAN for the time being you will need to install
the development version from GitHub. But first you need to load the 'devtools' and 'usethis' packages

library(usethis)
library(devtools)
devtools::install_github('hunter-stanke/rFIA', force = TRUE)

**Downloading Data**
It is recommended to download the data you are interested in using in subsets. Forest Inventory and Analysis (FIA) 
data is downloaded from the FIA DataMart which is a huge dataset that is continously being updated with new data. Therefore,
when downloading large datasets could max out your RAM and you may want to consider saving to a disk.

rFIA allows you to download a subset of data using the getFIA function. Depending on the speed of your internet you many need
to set "options(timeout=3600)". R will automatically stop downloading after 60 seconds and by setting the timeout to 3600 you 
are allowing R to download for an hour. I was only interested in downloading the FIA data for 
the state of Arizona and therefore used.

az <- getFIA(states = 'AZ')

This gives me a portion of the database with 20 tables of data. If you are only interested in loading certain tables that is
possible using the getFIA function. They use the example of:

getFIA(states = 'AZ', tables = c('TREE', 'PLOT'))

**Compute Estimates of Forest Variable**
Now we can explore the basic functionality of rFIA with the tpa function. This function is used to compute tree abundance
estimates (trees per acre (TPA), basal area per acre (BAA), & relative abundance). 

Using the az data we downloaded we can either compute with all inventory years or from the most recent year. Let's start by 
by running only looking at the most recent data by running:

azMR <- clipFIA(az, mostRecent = TRUE)

And then we can use the tpa function to compute trees per acre for the most recent year and all inventory years:

tpa_azMR <- tpa(azMR)
tpa_az <- tpa(az)

We can also group the tpa estimates by species with:

tpaaz_species <- tpa(azMR, bySpecies = TRUE)

or by size class:

tpaaz_sizeClass <- tpa(azMR, bySizeClass = TRUE)

**Plot the distribution**
We can plot the TPA for the most recent year by species and size class using the plotFIA function:

tpaaz_spsc <- tpa(azMR, bySpecies = TRUE, bySizeClass = TRUE)
plotFIA(tpaaz_spsc, TPA, grp = COMMON_NAME, x = sizeClass,
        plot.title = 'Size-class distributions of TPA by species', 
        x.lab = 'Size Class (inches)', text.size = .75,
        n.max = 5) # Only want the top 5 species, try n.max = -5 for bottom 5

**TPA estimates within population boundaries**
We can load shape file data for our population boundaries and plot TPA. I downloaded the 'Arizona
County Boundaries' shapefiles from AZGeo Data hub
(https://azgeo-open-data-agic.hub.arcgis.com/datasets/545fc0393f0747cb9665848a75f9b23c_0/explore)

To use these shape files, I first needed to load the sf package. I then used st_read function 
to load the data into R as a simple features object.

library(sf)
az_counties <- st_read("~/Desktop/rFIA-IRP/data/arizona_counties")

I was then able to plot the TPA estimates and counties together for all inventory years:

tpaaz_st <- tpa(az, polys = az_counties, returnSpatial = TRUE)
library(gganimate)
plotFIA(tpaaz_st, TPA, animate = TRUE, legend.title = 'Abundance (TPA)',
        legend.height = .8)
        
I also plotted it just for the most recent year:

tpaaz_counties <- tpa(azMR, polys = az_counties, returnSpatial = TRUE)
plotFIA(tpaaz_counties, TPA)
