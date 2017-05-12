install.packages("RNetLogo")
library(RNetLogo)
library(igraph)

nl.path <- "C:/Program Files/NetLogo 6.0.1/app"
nl.jarname <- "netlogo-6.0.1.jar"
NLStart(nl.path, nl.jarname=nl.jarname)
model.path <- "/models/Sample Models/Earth Science/Fire.nlogo"
NLLoadModel(paste(nl.path,model.path,sep="")) 
NLCommand("setup")
NLDoCommand(10, "go") 
burned <- NLReport("burned-trees") 
print(burned) 
NLQuit()


library(RNetLogo)
nl.path <- "C:/Program Files/NetLogo 6.0.1/app"
nl.jarname <- "netlogo-6.0.1.jar"
NLStart(nl.path, nl.jarname=nl.jarname)
model.path <- "/models/fire.nlogo"
NLLoadModel(paste(nl.path,model.path,sep=""))
NLCommand("setup")
df1 <- data.frame(x=c(1,2,3,4),y=c(5,6,7,8))
#NLSourceFromString("globals [x y]", append.model=FALSE)
NLDfToList(df1)
NLQuit()


library(RNetLogo)
nl.path <- "C:/Program Files/NetLogo 6.0.1/app"
nl.jarname <- "netlogo-6.0.1.jar"
NLStart(nl.path, nl.jarname=nl.jarname)
model.path <- "/models/Sample Models/Earth Science/Fire.nlogo" 
NLLoadModel(paste(nl.path,model.path,sep=""))
NLCommand("setup")
NLDoCommandWhile("burned-trees < 500", "go")
NLQuit()


library(RNetLogo)
nl.path <- "C:/Program Files/NetLogo 6.0.1/app"
nl.jarname <- "netlogo-6.0.1.jar"
NLStart(nl.path, nl.jarname=nl.jarname)
model.path <- "/models/Sample Models/Earth Science/Fire.nlogo" 
NLLoadModel(paste(nl.path,model.path,sep=""))
NLCommand("setup")
burned10 <- NLDoReport(10, "go", "burned-trees")
initburned10 <- NLDoReport(10, "go", c("initial-trees","burned-trees"),
                           as.data.frame=TRUE, df.col.names=c("initial","burned")) 
str(initburned10)
NLQuit()


library(RNetLogo)
nl.path <- "C:/Program Files/NetLogo 6.0.1/app"
nl.jarname <- "netlogo-6.0.1.jar"
NLStart(nl.path, nl.jarname=nl.jarname)
model.path <- "/models/Sample Models/Earth Science/Fire.nlogo" 
NLLoadModel(paste(nl.path,model.path,sep=""))
NLCommand("setup")
burnedLower2200 <- NLDoReportWhile("burned-trees < 2200", "go","burned-trees")
str(burnedLower2200)
NLQuit()


library(RNetLogo)
nl.path <- "C:/Program Files/NetLogo 6.0.1/app"
nl.jarname <- "netlogo-6.0.1.jar"
NLStart(nl.path, nl.jarname=nl.jarname)
model.path <- "/models/fire.nlogo"
NLLoadModel(paste(nl.path,model.path,sep=""))
NLCommand("setup")
NLCommand("create-turtles 10")
colors <- NLGetAgentSet(c("who","xcor","ycor","color"),"turtles with [who < 5]")
str(colors)

colors.list <- NLGetAgentSet(c("who","xcor","ycor","color"),"turtles with [who < 5]", as.data.frame=FALSE)
str(colors.list)

colors.list2 <- NLGetAgentSet(c("who","xcor","ycor","color"),"turtles with [who < 5]", as.data.frame=FALSE, agents.by.row=TRUE)
str(colors.list2)

NLCommand("ask turtles [ create-links-with n-of 2 other turtles ]")
link.test <- NLGetAgentSet(c("[who] of end1","[who] of end2"),"links")
str(link.test)
NLQuit()



library(RNetLogo)
nl.path <- "C:/Program Files/NetLogo 6.0.1/app"
nl.jarname <- "netlogo-6.0.1.jar"
NLStart(nl.path, nl.jarname=nl.jarname)
model.path <-"/models/Sample Models/Networks/Preferential Attachment.nlogo" 
NLLoadModel(paste(nl.path,model.path,sep=""))
NLCommand("setup")
NLDoCommand(4, "go")
graph1 <- NLGetGraph()
plot(graph1, layout=layout.kamada.kawai, vertex.label=V(graph1)$name,
     vertex.shape="rectangle", vertex.size=20, asp=FALSE)
NLQuit()



