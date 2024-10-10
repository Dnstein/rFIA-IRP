
#set up version control with GIT
library(usethis)
usethis::use_git

#install package
library(devtools)
# Recieved warning message saing that package 'rFIA' is not available for this version of R.
install.packages("rFIA")

#this install worked using after adding force = TRUE
devtools::install_github('hunter-stanke/rFIA', force = TRUE)
library(rFIA)

#Allow download to run for 1 hour. R stops downloads automatically after 60 s. 
options(timeout=3600)
#Download a subset of the dataset from DataMart for the state of Arizona
#Can load specific tables by specifying tables = c('TREE', 'PLOT') when loading data originally
#az <- getFIA(states = 'AZ', tables = c('TREE', 'PLOT'))
#getFIA(states, dir = NULL, common = true, tables = NULL, load = TRUE, nCores =1)
# status is a required argument when getting data with getFIA function. The rest of the arguments are defulted to the values above.
# By default, getFIA and readFIA only loads/downloads the portions of the database required to produce summaries with other rFIA functions (common = TRUE). When set to false there are 43 elements and the download size is 1.1 GB
az <- getFIA(states = 'AZ')

#accessing specific TREE and PLOT tables
az$TREE
az['PLOT']

#check the spatial coverage of the plots held in the database
plotFIA(az)

#Spatial and Temporal queries 
#Subsetting for the most recent AZ data. Is it set to true by default (?)
azMR <- clipFIA(az, mostRecent = TRUE)
#get tree abundance estimates for most recent year of data
tpa_azMR <- tpa(azMR)
head(tpa_azMR)

#get tree abundance estimates for all az all inventory years
tpa_az <- tpa(az)
head(tpa_az)

#get tree abundance estimates by species for the most recent inventory year
tpaaz_species <- tpa(azMR, bySpecies = TRUE)
head(tpaaz_species, n = 5)

#get tree abundance estimates by size class for the most recent inventory year
tpaaz_sizeClass <- tpa(azMR, bySizeClass = TRUE)
head(tpaaz_sizeClass, n = 5)

# Group by species and size class, and plot the distribution for the most recent inventory year
tpaaz_spsc <- tpa(azMR, bySpecies = TRUE, bySizeClass = TRUE)
plotFIA(tpaaz_spsc, TPA, grp = COMMON_NAME, x = sizeClass,
        plot.title = 'Size-class distributions of TPA by species', 
        x.lab = 'Size Class (inches)', text.size = .75,
        n.max = 5) # Only want the top 5 species, try n.max = -5 for bottom 5

## grpBy specifies what to group estimates by (just like species and size class above)
## treeDomain describes the trees of interest, in terms of FIA variables 
## areaDomain, just like above,describes the land area of interest
tpaaz_own <- tpa(azMR, 
                 grpBy = OWNGRPCD, 
                 treeDomain = DIA > 5 & CCLCD %in% c(1,2),
                 areaDomain = PHYSCLCD %in% c(20:29))
head(tpaaz_own)

#Load shape files of AZ counties 
library(sf)
az_counties <- st_read("~/Desktop/rFIA-IRP/data/arizona_counties")

## polys specifies the polygons (zones) where you are interested in producing estimates
## returnSpatial = TRUE indicates that the resulting estimates will be joined with the 
##    polygons we specified, thus allowing us to visualize the estimates across space
tpaaz_counties <- tpa(azMR, polys = az_counties, returnSpatial = TRUE)
#plot basal area per acre
plotFIA(tpaaz_counties, TPA)

## Using the full FIA dataset, all available inventories

tpaaz_st <- tpa(az, polys = az_counties, returnSpatial = TRUE)
library(gganimate)
plotFIA(tpaaz_st, TPA, animate = TRUE, legend.title = 'Abundance (TPA)',
        legend.height = .8)
