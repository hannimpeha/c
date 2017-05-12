nruns<-100
for(i in 1:nruns){
  NLCommand("go")
  vars<-c("who", "energy", "trust")
  agents <- "turtles"
  reporters <- sprintf("map [x -> [%s] of x ] sort %s", vars, agents)
  nlogo_ret <- RNetLogo::NLReport(reporters)
  df1[[i]] <- data.frame(nlogo_ret, stringsAsFactors = FALSE)
}

DF = data.frame(x=rep(c("b","a","c"),each=3), y=c(1,3,6), v=1:9)
DT = data.table(x=rep(c("b","a","c"),each=3), y=c(1,3,6), v=1:9)
DT[, c("A","B","C") := DF]
DT
for(i in 1:9) DT[i, V1 := i]

merge(x = df1, y = df2, by = "CustomerId", all = TRUE)



set1 <- set2 <- data.frame(sol1 = c("s1", "s1", "s1", "s1"), 
                           sol2 = c("s2", "s3", "s4", "s5"), 
                           Istat = c(0.435, 0.456, 0.845, 0.234))
set2$Istat <- set2$Istat + 1 ## Just to see some different data

all.data <- mget(ls(pattern = "set\\d+")) ## use your actual object

## The reshaping
library(reshape2)
dcast(melt(all.data, id.vars = c("sol1", "sol2")), L1 + sol1 ~ sol2, value.var = "value")
      
# lib folder name :C:/Desktop/
item<-c()
for(i in 1:100){
  
df<-c(paste("trust", i))

item <- merge(item, df)
}


df<-array(dim=c(1,100))
for (i in 1:100){
  df[,i] <-paste0("trust",i)
}
df<-cbind("who",df)


do.call(rbind, lapply(as.data.frame(t(aa)), "/", 5))
do.call(rbind, lapply(as.data.frame(t(temp1)), "/", tsum))



library(dplyr)
library(tidyr)


df<-data.frame(Product=c("A","A","A","B","B","C"), 
               Ingredients=c("Chocolate","Vanilla","Berry","Chocolate","Berry2","Vanilla"))
df %>% 
  group_by(Product) %>%
  mutate(Ingredient = paste0("Ingredient_", row_number())) %>%
  spread(Ingredient, Ingredients)



library(reshape2)

df1 <- data.frame(Vegetables="Cheap", Onion=20,Potato=30,Tomato=40)
df2 <- data.frame(Vegetables="Mid", Cabbage=20, Carrot=30,Cauliflower=40, Eggplant=30)

do.call("rbind", lapply(list(df1,df2),
                        function(d){
                          melt(d,id.vars="Vegetables", variable.name="Type", 
                               value.name="Quantity")}))

tmp <- expand.grid(letters[1:2], 1:3, c("+", "-"))
do.call("paste", c(tmp, sep = ""))

do.call(paste, list(as.name("A"), as.name("B")), quote = TRUE)



library(dplyr)
library(tidyr)

data_long<-as.data.frame(matrix(nrow = 10, ncol = 2))
colnames(data_long)<-c("treatment","rolls")
data_long[,1]<-c(1,2,3,4,1,2,3,1,2,1)
data_long[,2]<-c(6,6,6,6,6,6,6,6,6,6)

aa<-data_long %>% 
  group_by(treatment) %>% 
  mutate(unique_id = 1:n()) %>% 
  spread(treatment, rolls)


u <- list("A", list("B", list("C", "D")), "E")
v <- c("x", "y")
w1 <- do.call(c,lapply(u, function(x) {
  x1 <- if(!is.list(x)) outer(x,v, FUN=paste) 
  else t(outer(do.call(paste, x), v, FUN= paste))
  strsplit(x1, " ")}))


u <- c("who")
v <- as.vector(paste("trust in expr", 1:nrun, sep = ""))
df<-reshape(u,v,direction="long")
stack(u,v)
  

df <- data.frame(id = rep(1:4, rep(2,4)),
                 visit = I(rep(c("Before","After"), 4)),
                 x = rnorm(4), y = runif(4))
df3 <- data.frame(school = rep(1:3, each = 4), class = rep(9:10, 6),
                  time = rep(c(1,1,2,2), 3), score = rnorm(12))

stack(df3)



A = matrix[ 1 2; 2 4 ]
v = matrix[ 2 4 ]
B = bsxfun(@rdivide, A, v)