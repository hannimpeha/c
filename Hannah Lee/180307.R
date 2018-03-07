set.seed(724985)
rm(list=ls())
setwd("C:/Users/bok/Desktop")
.libPaths()
data <- read.csv("hannimpeha.csv", header = FALSE)

house_price <- data.frame(data[,5])
row_sub = apply(house_price, 1, function(row) row !=0)
house_price <- house_price[row_sub,]

jeonse_price <- data.frame(data[,6])
row_sub = apply(jeonse_price, 1, function(row) row !=0)
jeonse_price <- jeonse_price[row_sub,]

walse_price <- data.frame(data[,7])
row_sub = apply(walse_price, 1, function(row) row !=0)
walse_price <- walse_price[row_sub,]

library(MASS)
library(fitdistrplus)
library(logspline)
png('house_price.png')
descdist(house_price, discrete = FALSE)
dev.off()
fit.weibull <- fitdist(house_price, "weibull")
png('house_price_fit.png')
plot(fit.weibull)
dev.off()

png('jeonse_price.png')
descdist(jeonse_price, discrete = FALSE)
dev.off()
fit.weibull <- fitdist(jeonse_price, "weibull")
png('jeonse_price_fit.png')
plot(fit.weibull)
dev.off()

png('walse_price.png')
descdist(walse_price, discrete = FALSE)
dev.off()
fit.weibull <- fitdist(walse_price, "weibull")
png('walse_price_fit.png')
plot(fit.weibull)
dev.off()

#---------------------------------------------------
set.seed(724985)
rm(list=ls())
setwd("C:/Users/bok/Desktop")
.libPaths()
data <- read.csv("data.csv", header = FALSE)
info <- data.frame(start=seq(1,2400,by=24), len=rep(3,100));
data<-data[-(sequence(info$len) + rep(info$start-1, info$len)),]


set.seed(1)
aaaa<-sapply(seq(1,60,6),function(j) 
  sapply(seq(5), function(b) 
    1 - mean(t.test(sample(data[,j+b] - data[,j]))$stat > 
               replicate(100, t.test(sample(data[,j+b] - mean(data[,j+b], na.rm=T), 200, replace=T),
                                     sample(data[,j] - mean(data[,j], na.rm=T), 200, replace=T), 
                                     var.equal=FALSE)$stat))
  ))
aaaa<-aaaa[,c(1,7,8,2,6,3,8,10,4,5)]
sprintf("%.3f",aaaa)
write.csv (aaaa, file = "aaaa.csv")

set.seed(1)
bbbb<-sapply(seq(1,60,6),function(j) 
  1 - mean(t.test(sample(data[,j]))$p.value > 
             replicate(100, t.test(sample(data[,j] - mean(data[,j], na.rm=T), 200, replace=T))$p.value))
)
sprintf("%.3f",bbbb)
write.csv (bbbb, file = "bbbb.csv")




#---------------------------------------------------------------  
gggg<-sapply(seq(1,60,6),function(j) 
  sapply(seq(5),function(b) t.test(data[,j+b]-data[,j],
                                   alternative = "greater")$p.value))
gggg<-gggg[,c(1,7,8,2,6,3,8,10,4,5)]
sprintf("%.3f",gggg)
write.csv (gggg, file = "gggg.csv")

hhhh<-sapply(seq(1,60,6),function(j) 
  sapply(seq(5),function(b) t.test(data[,j+b]-data[,j],
                                   alternative = "greater")$estimate))
hhhh<-hhhh[,c(1,7,8,2,6,3,8,10,4,5)]
sprintf("%.3f",hhhh)
write.csv (hhhh, file = "hhhh.csv")

#-----------------------------------------------------------------
#---------------------------------------------------------------
data <- read.csv("data1.csv", header = FALSE)
info <- data.frame(start=seq(1,2400,by=24), len=rep(3,100));
data<-data[-(sequence(info$len) + rep(info$start-1, info$len)),]
iiii<-sapply(seq(1,60,6),function(j) 
  sapply(seq(5),function(b)
    jackknife(theta = function(x, mydata) {
      t.test(c(data[,j+b],data[,j]) ~ c(rep('A',21),rep('B',21)), 
             data = mydata[1:21 %in% x, ], 
             paired = T)$p.value},
      x = 1:21,
      mydata = data.frame(c(data[,j+b],data[,j]),
                          c(rep('A',21),rep('B',21))))$jack.se
  ))
iiii<-iiii[,c(1,7,8,2,6,3,8,10,4,5)]
sprintf("%.3f",iiii)
write.csv (iiii, file = "iiii.csv")

#-----------------------------------------------------------------
#---------------------------------------------------------------
jjjj<-sapply(seq(1,60,6),function(j) 
  sapply(seq(5),function(b) wilcox.test(data[,j+b]-data[,j],
                                        alternative = "greater")$p.value))
jjjj<-jjjj[,c(1,7,8,2,6,3,8,10,4,5)]
sprintf("%.3f",jjjj)
write.csv (jjjj, file = "jjjj.csv")


#---------------------------------------------------------------
#---------------------------------------------------------------
kkkk<-sapply(seq(1,60,6),function(j) 
  sapply(seq(5),function(b) ks.test(log(data[,j+b]),log(data[,j]))$p.value))
kkkk<-kkkk[,c(1,7,8,2,6,3,8,10,4,5)]
sprintf("%.3f",kkkk)
write.csv (kkkk, file = "kkkk.csv")

#----------------------------------------------------
set.seed(724985)
rm(list=ls())
setwd("C:/Users/bok/Desktop/")
data <- read.csv("final.csv", header = FALSE)
# info <- data.frame(start=seq(1,2400,by=24), len=rep(3,100));
# data<-data[-(sequence(info$len) + rep(info$start-1, info$len)),-c(1)]
library(ggplot2)
png('rplot.png')
matplot(x = seq(24), y = data, type = "l", xlab = "trial", ylab = "data")
dev.off()

#--------------------------------------------------------
set.seed(724985)
require(ggplot2)
rm(list=ls())
setwd("C:/Users/bok/Desktop/pic")
.libPaths()
data <- read.csv("data1.csv", header = FALSE)
sapply(seq(1,60,6),function(j) 
  sapply(seq(5),function(b) 
    ggsave(ggplot(with(data,
                       if (b ==1){
                           dataframe(value = c(data[,j+b], data[,j]),
                           variable = factor(rep(c("policy","base"), each = nrow(data))),
                           dates = seq(24))
                         }else{
                           if (b ==2){
                           dataframe(value = c(data[,j+b], data[,j]),
                                     variable = factor(rep(c("LTV","base"), each = nrow(data))),
                                     dates = seq(24))
                         }else{
                           if (b ==3){
                             dataframe(value = c(data[,j+b], data[,j]),
                                       variable = factor(rep(c("supply","base"), each = nrow(data))),
                                       dates = seq(24))
                         }else{
                           if (b ==4){
                             dataframe(value = c(data[,j+b], data[,j]),
                                       variable = factor(rep(c("reserve","base"), each = nrow(data))),
                                       dates = seq(24))
                         }else{
                           dataframe(value = c(data[,j+b], data[,j]),
                                     variable = factor(rep(c("demo","base"), each = nrow(data))),
                                     dates = seq(24))
                         }}}}),
                  aes(date, value, colour = variable))
           + geom_line()
           + them(plot.background = element_blank(),
                  legend.background=element_blank(),
                  axis.line.x = element_line(color = "black"),
                  axis.line.y = element_line(color = "black")
                  ), 
           filename = paste0(j,b,".png",sep=""),
           width = 200, height = 100, dpi = "mm")))




