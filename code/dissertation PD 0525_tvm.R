
.libPaths("C:/Users/Hannah Lee/R")
#install.packages("RNetLogo", repos="http://R-Forge.R-project.org")
library(RNetLogo)
library(reshape2)
library(doParallel)
library(foreach)

nl.path <- "C:/Program Files/NetLogo 6.0.1/app"
nl.jarname <- "netlogo-6.0.1.jar"
NLStart(nl.path, nl.jarname=nl.jarname)
model.path <- "/models/dissertation.nlogo" 
NLLoadModel(paste(nl.path,model.path,sep=""))

rm(list=ls())
NLCommand("setup")
cl<-makeCluster(3)
registerDoParallel(cl)
nrun<-20


temp1<-list()
temp2<-list(c(rep(1,60)))


##########################
###calculating tvmratio###
##########################

 for(i in 1:nrun){
  NLCommand("go")
  #temp0 <- NLGetAgentSet(c("trustt"), "turtles")
  vars<-c("who","trustt")
  agents <- "turtles"
  reporters <- sprintf("map [x -> [%s] of x ] sort %s", vars, agents)
  temp1 <- RNetLogo::NLReport(reporters)
  temp2<-temp1[[2]]+temp2[[1]]
  tvmratio<-temp1[[2]]/temp2
  
  if(i >= 2 ){
    tvmratio<-as.data.frame(tvmratio)
    NLSetAgentSet("turtles", tvmratio)
  }}
  
  

NLQuit()
