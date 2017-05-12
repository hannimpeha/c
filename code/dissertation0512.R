#C:/Program Files/NetLogo 6.0.1/app/models
.libPaths("C:/Users/Hannah Lee/R")
rm(list=ls())

library(RNetLogo)

nl.path <- "C:/Program Files/NetLogo 6.0.1/app"
nl.jarname <- "netlogo-6.0.1.jar"
NLStart(nl.path, nl.jarname=nl.jarname)
model.path <- "/models/dissertation.nlogo" 
NLLoadModel(paste(nl.path,model.path,sep=""))

NLCommand("setup")
nturtle<-8
nrun<-100
temp1<-c()
temp2<-rep(0,8)
tsum<-c()

for(i in 1:nrun){
  NLCommand("go")
  vars<-c("who","trust")
  agents <- "turtles"
  reporters <- sprintf("map [x -> [%s] of x ] sort %s", vars, agents)
  nlogo_ret <- RNetLogo::NLReport(reporters)
  df_nw <- t(data.frame(nlogo_ret, stringsAsFactors = FALSE))
  temp1<-rbind(temp1,df_nw[2,])
  temp2<-temp2 + df_nw[2,]
  tsum<-rbind(tsum,temp2)
  temp3<-df_nw[2,]/temp2
  tratio<-temp3
  NLDfToList(temp3)
}
# tratio<-do.call(rbind, lapply(as.data.frame(t(temp1)), "/", tsum))
ctrust<-temp1;rm(temp1);rm(df_nw)
tratio <- ctrust / tsum
# names(ctrust)<-list(c(paste("turtle",1:nturtle)),c(paste0("expr", 1:100)))
# names(tsum)<-list(c(paste("turtle",1:nturtle)),c(paste0("expr", 1:100)))
# names(tratio)<-list(c(paste("turtle",1:nturtle)),c(paste0("expr", 1:100)))
write.csv(ctrust,"C:/Users/Hannah Lee/R/ctrust.csv",row.names=TRUE)
write.csv(tsum,"C:/Users/Hannah Lee/R/tsum.csv",row.names=TRUE)
write.csv(tratio,"C:/Users/Hannah Lee/R/tratio.csv",row.names=TRUE)

NLQuit()


test1 <- NLDoReport(10, "go", c("energy-by-agent","trust-by-agent"),
                    as.data.frame=TRUE, df.col.names=c("energy-by-agent","trust-by-agent")) 
str(test1)
NLQuit()
