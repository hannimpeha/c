#C:/Program Files/NetLogo 6.0.1/app/models
library(RNetLogo)
nl.path <- "C:/Program Files/NetLogo 6.0.1/app"
nl.jarname <- "netlogo-6.0.1.jar"
NLStart(nl.path, nl.jarname=nl.jarname)
model.path <- "/models/dissertation.nlogo" 
NLLoadModel(paste(nl.path,model.path,sep=""))
NLCommand("setup")

df1<-list()
current_mean_trust_store<-list()
current_mean_energy_store<-list()
nruns<-100
for(i in 1:nruns){
  NLCommand("go")
  vars<-c("who", "energy", "trust")
  agents <- "turtles"
  reporters <- sprintf("map [x -> [%s] of x ] sort %s", vars, agents)
  nlogo_ret <- RNetLogo::NLReport(reporters)
  df1[[i]] <- list(nlogo_ret, stringsAsFactors = FALSE)
  
  current_mean_trust<-apply(as.data.frame(df1[[i]][[1]][[2]]),1,mean)
  current_mean_trust_store[[i]]<-current_mean_trust
  
  current_mean_energy<-apply(as.data.frame(df1[[i]][[1]][[3]]),1,mean)
  current_mean_energy_store[[i]]<-current_mean_energy
}
NLQuit()

test1 <- NLDoReport(10, "go", c("energy-by-agent","trust-by-agent"),
                    as.data.frame=TRUE, df.col.names=c("energy-by-agent","trust-by-agent")) 
str(test1)
NLQuit()
