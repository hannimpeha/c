
.libPaths("C:/Users/Hannah Lee/R")
#install.packages("RNetLogo", repos="http://R-Forge.R-project.org")
library(RNetLogo)
library(reshape2)
library(doParallel)
library(foreach)
library(pastecs)


nl.path <- "C:/Program Files/NetLogo 6.0.1/app"
nl.jarname <- "netlogo-6.0.1.jar"
NLStart(nl.path, nl.jarname=nl.jarname)
model.path <- "/models/dissertation_psm.nlogo" 
NLLoadModel(paste(nl.path,model.path,sep=""))


rm(list=ls())
NLCommand("setup")
nrun<-700
nturtle<-60


temp3<-list()
temp4<-matrix(, nrow = nturtle, ncol = 0)
temp7<-c()
temp8<-matrix(, nrow = 1, ncol = 1)


cl<-makeCluster(3)
registerDoParallel(cl)

##########################
###calculating psmratio###
##########################

simvw<-function(nturtle, temp4){
  for(j in 1:nturtle){
    temp5<-as.numeric(temp4[j,])
    temp6<-turnpoints(temp5)
    temp7<-rbind(temp7,temp6$nturns)
  }
  
  for(k in 1:nturtle){
    pmsratio <- sqrt((temp7 - (sum(temp7) - temp7) / (length(temp7)-1))^2)
  }
}


 for(i in 1:nrun){
  NLCommand("go")
  vars<-c("who","partnerstore")
  agents <- "turtles"
  reporters <- sprintf("map [x -> [%s] of x ] sort %s", vars, agents)
  temp3 <- RNetLogo::NLReport(reporters)
  temp4<-cbind(temp4, as.data.frame(temp3[[2]]))
  
  
  psmratio<-clusterExport(cl=cl, "simvw" ,envir=environment())
  
   if(i >= 2 ){
     psmratio<-as.data.frame(psmratio)
     NLSetAgentSet("turtles", psmratio)
 }
 } 

NLQuit()
