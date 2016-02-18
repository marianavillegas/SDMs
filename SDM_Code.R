## add packages
library(maps)
library(mapdata)
library(dismo)
library(rgdal)
library(PresenceAbsence)
library(lattice)
library(biomod2)
library(MASS)
library(gbm)             
library(nlme)
library(mgcv)                                  
library(raster)

### 1000 random points, following Parra et al 2004

## very important to use these lines to define the mask from where draw random points!
files <- list.files(path=paste(system.file(package="dismo"), '/ex' , sep= ''),  pattern= 'grd',  
                    full.names=TRUE)
mask <- raster(files[[1]])

### delimitando un extent de donde samplear 1000 random points: 
e <- extent(-92, -34, -33, 14) ## ampliando a casi todo Sudamérica.
## first the 2 longitude limits, then latitude limits
rand1k <- randomPoints(mask, 1000, ext=e) # this background set is called cbol1.
plot(!is.na(mask), legend=FALSE)
plot(e, add=TRUE, col= 'red' )
points(rand1k, cex=0.5)
head(rand1k)

### Now add environmental variables 
## First, set working directory.
setwd("/Volumes/Mariana/SDM_2016/all_envars")

## add each variable one by one. ####
anmtemp<-raster("annt.asc")          
anpp<-raster("annualpp.asc")            
maxtwarmmo<-raster("maxtwarmmo.asc") 
mtcoldqua<-raster("meantcoldqua.asc")
mtdryqua<-raster("meantdryqua.asc")
ppcoldqua<-raster("ppcoldqua.asc")  
ppdryqua<-raster("ppdryqua.asc")
ppwetmo<-raster("ppwetmo.asc")  
ppseasoncv<-raster("ppseason.asc")
tseasoncv<-raster("tseason.asc")  
mintcoldmo<-raster("mintcoldmo.asc") 
meantwarmqua<-raster("meantwarmqua.asc")
meantwetqua<-raster("meantwetqua.asc")
ppwarmqua<-raster("ppwarmqua.asc")
ppdrymo<-raster("ppdrymo.asc")
ppwetqua<-raster("ppwetqua2.asc")
## vegetation variables: 4 (se aumentaron 3ene2016)
maxndvi<-raster("me_maxndvi.asc") 
minndvi<-raster("me_minndvi.asc") 
manndvi<-raster("me_anndvi.asc") 
cvndvi<-raster("cv_ndvi.asc") 
## Now the elevation variables:
eastness<-raster("eastness.asc")
northness<-raster("northness.asc") 
slope<-raster("slope_nt.asc")

### Stack the environmental variables:
predictors<-stack(anmtemp, anpp, maxtwarmmo, mtcoldqua, mtdryqua, ppcoldqua, ppdryqua, ppwetmo, 
                  ppseasoncv, tseasoncv,mintcoldmo,meantwarmqua,meantwetqua,ppwarmqua,ppdrymo,
                  ppwetqua, maxndvi,minndvi,manndvi,cvndvi, eastness, northness, slope)

## We are doing this to do a correlation matrix, to select env variables
### to extract the values of the predictors at the locations of the points
random <- extract(predictors, rand1k)

random1k<-read.table(file="random_envars.csv", header=TRUE, sep= ",")
random1k_DF = data.frame(random1k)
summary(random1k_DF)
head(random1k_DF)

#### to investigate COLLINEARITY in the environmental data.
##correlation matrix to see correlation between predictors on presence locations:
cormatrix <- cor(random1k_DF)
cormatrix

write.csv(cormatrix, "cormatrix.csv", row.names=F, quote=F)