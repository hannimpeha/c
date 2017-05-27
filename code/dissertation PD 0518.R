.libPaths("C:/Users/Hannah Lee/R")
rm(list=ls())
install.packages("RNetLogo", repos="http://R-Forge.R-project.org")
library(RNetLogo)
library(reshape2)
library(doParallel)
library(foreach)

nl.path <- "C:/Program Files/NetLogo 6.0.1/app"
nl.jarname <- "netlogo-6.0.1.jar"
NLStart(nl.path, nl.jarname=nl.jarname)
model.path <- "/models/dissertation.nlogo" 
NLLoadModel(paste(nl.path,model.path,sep=""))

NLCommand("setup")
cl<-makeCluster(3)
registerDoParallel(cl)
nrun<-100

##########################
###calculating tvmratio###
##########################

for(i in 1:nrun){
  NLCommand("go")
  temp1[[i]] <- NLGetAgentSet(c("trust-tvm"), "turtles")
  vars<-c("who","trust")
  agents <- "turtles"
  reporters <- sprintf("map [x -> [%s] of x ] sort %s", vars, agents)
  temp0 <- RNetLogo::NLReport(reporters)
  temp1 <- data.frame(temp0, stringsAsFactors = FALSE)
  temp1<-temp1[,-1]
  temp2<-temp2+temp1
  tvmratio<-temp1/temp2
  tvmratio<-as.data.frame(tvmratio)
  NLDfToList(tvmratio)
}


##########################
###calculating psmratio###
##########################
tvmratio<-foreach(i = 1:nrun) %dopar% {}



NLQuit()
