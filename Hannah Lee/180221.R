set.seed(724985)
rm(list=ls())
setwd("C:/Users/Hannah Lee/Desktop/data")
data <- read.csv("data.csv", header = FALSE)
colnames(dat)<-c(1:60)
data1 <- data[,1]
data2 <- data[,2]
data3 <- data[,3]
data4 <- data[,4]
data5 <- data[,5]
data6 <- data[,6]
data7 <- data[,7]
data8 <- data[,8]
data9 <- data[,9]
data10 <- data[,10]
data11 <- data[,11]
data12 <- data[,12]
data13 <- data[,13]
data14 <- data[,14]
data15 <- data[,15]
data16 <- data[,16]
data17 <- data[,17]
data18 <- data[,18]
data19 <- data[,19]
data20 <- data[,20]
data21 <- data[,21]
data22 <- data[,22]
data23 <- data[,23]
data24 <- data[,24]
data25 <- data[,25]
data26 <- data[,26]
data27 <- data[,27]
data28 <- data[,28]
data29 <- data[,29]
data30 <- data[,30]
data31 <- data[,31]
data32 <- data[,32]
data33 <- data[,33]
data34 <- data[,34]
data35 <- data[,35]
data36 <- data[,36]
data37 <- data[,37]
data38 <- data[,38]
data39 <- data[,39]
data40 <- data[,40]
data41 <- data[,41]
data42 <- data[,42]
data43 <- data[,43]
data44 <- data[,44]
data45 <- data[,45]
data46 <- data[,46]
data47 <- data[,47]
data48 <- data[,48]
data49 <- data[,49]
data50 <- data[,50]
data51 <- data[,51]
data52 <- data[,52]
data53 <- data[,53]
data54 <- data[,54]
data55 <- data[,55]
data56 <- data[,56]
data57 <- data[,57]
data58 <- data[,58]
data59 <- data[,59]
data60 <- data[,60]
png("1.png", width = 200, height = 400)
a1<- boxplot(data1, data2, names=c("base","2.5%"), title = "house price")
dev.off()
png("2.png", width = 200, height = 400)
a2<- boxplot(data1, data3, names=c("base","20%"), title = "house price")
dev.off()
png("3.png", width = 200, height = 400)
a3<- boxplot(data1, data4, names=c("base","supply"), title = "house price")
dev.off()
png("4.png", width = 200, height = 400)
a4<- boxplot(data1, data5, names=c("base","reserve"), title = "house price")
dev.off()
png("5.png", width = 200, height = 400)
a5<- boxplot(data1, data6, names=c("base","demo"), title = "house price")
dev.off()
png("6.png", width = 200, height = 400)
a6<- boxplot(data7, data8, names=c("base","2.5%"), title = "jeonse price")
dev.off()
png("7.png", width = 200, height = 400)
a7<- boxplot(data7, data9, names=c("base","20%"), title = "jeonse price")
dev.off()
png("8.png", width = 200, height = 400)
a8<- boxplot(data7, data10, names=c("base","supply"), title = "jeonse price")
dev.off()
png("9.png", width = 200, height = 400)
a9<- boxplot(data7, data11, names=c("base","reserve"), title = "jeonse price")
dev.off()
png("10.png", width = 200, height = 400)
a10<- boxplot(data7, data12, names=c("base","demo"), title = "jeonse price")
dev.off()
png("11.png", width = 200, height = 400)
a11<- boxplot(data13, data14, names=c("base","2.5%"), title = "price per size")
dev.off()
png("12.png", width = 200, height = 400)
a12<- boxplot(data13, data15, names=c("base","20%"), title = "price per size")
dev.off()
png("13.png", width = 200, height = 400)
a13<-boxplot(data13, data16, names=c("base","supply"), title = "price per size")
dev.off()
png("14.png", width = 200, height = 400)
a14<-boxplot(data13, data17, names=c("base","reserve"), title = "price per size")
dev.off()
png("15.png", width = 200, height = 400)
a15<-boxplot(data13, data18, names=c("base","demo"), title = "price per size")
dev.off()
png("16.png", width = 200, height = 400)
a16<-boxplot(data19, data20, names=c("base","2.5%"), title = "mortgage")
dev.off()
png("17.png", width = 200, height = 400)
a17<-boxplot(data19, data21, names=c("base","20%"), title = "mortgage")
dev.off()
png("18.png", width = 200, height = 400)
a18<-boxplot(data19, data22, names=c("base","supply"), title = "mortgage")
dev.off()
png("19.png", width = 200, height = 400)
a19<-boxplot(data19, data23, names=c("base","reserve"), title = "mortgage")
dev.off()
png("20.png", width = 200, height = 400)
a20<-boxplot(data19, data24, names=c("base","demo"), title = "mortgage")
dev.off()
png("21.png", width = 200, height = 400)
a21<-boxplot(data25, data26, names=c("base","2.5%"), title = "jeonse")
dev.off()
png("22.png", width = 200, height = 400)
a22<-boxplot(data25, data27, names=c("base","20%"), title = "jeonse")
dev.off()
png("23.png", width = 200, height = 400)
a23<-boxplot(data25, data28, names=c("base","supply"), title = "jeonse")
dev.off()
png("24.png", width = 200, height = 400)
a24<-boxplot(data25, data29, names=c("base","reserve"), title = "jeonse")
dev.off()
png("25.png", width = 200, height = 400)
a25<-boxplot(data25, data30, names=c("base","demo"), title = "jeonse")
dev.off()
png("26.png", width = 200, height = 400)
a26<-boxplot(data25, data26, names=c("base","2.5%"), title = "credits")
dev.off()
png("27.png", width = 200, height = 400)
a27<-boxplot(data25, data27, names=c("base","20%"), title = "credits")
dev.off()
png("28.png", width = 200, height = 400)
a28<-boxplot(data25, data28, names=c("base","supply"), title = "credits")
dev.off()
png("29.png", width = 200, height = 400)
a29<-boxplot(data25, data29, names=c("base","reserve"), title = "credits")
dev.off()
png("30.png", width = 200, height = 400)
a30<-boxplot(data25, data30, names=c("base","demo"), title = "credits")
dev.off()
png("31.png", width = 200, height = 400)
a31<-boxplot(data31, data32, names=c("base","2.5%"), title = "gangnam")
dev.off()
png("32.png", width = 200, height = 400)
a32<-boxplot(data31, data33, names=c("base","20%"), title = "gangnam")
dev.off()
png("33.png", width = 200, height = 400)
a33<-boxplot(data31, data34, names=c("base","supply"), title = "gangnam")
dev.off()
png("34.png", width = 200, height = 400)
a34<-boxplot(data31, data35, names=c("base","reserve"), title = "gangnam")
dev.off()
png("35.png", width = 200, height = 400)
a35<-boxplot(data31, data36, names=c("base","demo"), title = "gangnam")
dev.off()
png("36.png", width = 200, height = 400)
a36<-boxplot(data37, data38, names=c("base","2.5%"), title = "non-gangnam")
dev.off()
png("37.png", width = 200, height = 400)
a37<-boxplot(data37, data39, names=c("base","20%"), title = "non-gangnam")
dev.off()
png("38.png", width = 200, height = 400)
a38<-boxplot(data37, data40, names=c("base","supply"), title = "non-gangnam")
dev.off()
png("39.png", width = 200, height = 400)
a39<-boxplot(data37, data41, names=c("base","reserve"), title = "non-gangnam")
dev.off()
png("40.png", width = 200, height = 400)
a40<-boxplot(data37, data42, names=c("base","demo"), title = "non-gangnam")
dev.off()
png("41.png", width = 200, height = 400)
a41<-boxplot(data43, data44, names=c("base","2.5%"), title = "gangnam-pps")
dev.off()
png("42.png", width = 200, height = 400)
a42<-boxplot(data43, data45, names=c("base","20%"), title = "gangnam-pps")
dev.off()
png("43.png", width = 200, height = 400)
a43<-boxplot(data43, data46, names=c("base","supply"), title = "gangnam-pps")
dev.off()
png("44.png", width = 200, height = 400)
a44<-boxplot(data43, data47, names=c("base","reserve"), title = "gangnam-pps")
dev.off()
png("45.png", width = 200, height = 400)
a45<-boxplot(data43, data48, names=c("base","demo"), title = "gangnam-pps")
dev.off()
png("46.png", width = 200, height = 400)
a46<-boxplot(data49, data50, names=c("base","2.5%"), title = "non-gangnam-pps")
dev.off()
png("47.png", width = 200, height = 400)
a47<-boxplot(data49, data51, names=c("base","20%"), title = "non-gangnam-pps")
dev.off()
png("48.png", width = 200, height = 400)
a48<-boxplot(data49, data52, names=c("base","supply"), title = "non-gangnam-pps")
dev.off()
png("49.png", width = 200, height = 400)
a49<-boxplot(data49, data53, names=c("base","reserve"), title = "non-gangnam-pps")
dev.off()
png("50.png", width = 200, height = 400)
a50<-boxplot(data49, data54, names=c("base","demo"), title = "non-gangnam-pps")
dev.off()


b1<-ks.test(data1, data2)
b1$statistic
b1$p.value
x<-numeric(100)
for (i in seq(1,46,by=6))
    x[i] <- ks.test(data[,i], data[,i+1])$p.value
    x[i+1] <- ks.test(data[,i], data[,i+2])$p.value
    x[i+2] <- ks.test(data[,i], data[,i+3])$p.value
    x[i+3] <- ks.test(data[,i], data[,i+4])$p.value
    x[i+4] <- ks.test(data[,i], data[,i+5])$p.value
x    

res <- function (i) {
  for (i in seq(1,46,by=6))
  ks1 <- ks.test(data[,i], data[,i+1])
  ks2 <- ks.test(data[,i], data[,i+2])
  ks3 <- ks.test(data[,i], data[,i+3])
  ks4 <- ks.test(data[,i], data[,i+4])
  ks5 <- ks.test(data[,i], data[,i+5])
  a <- array()
  a[i]<-
  c(statistic=ks1$statistic, p.value=ks1$p.value)
  c(statistic=ks2$statistic, p.value=ks2$p.value)
  c(statistic=ks3$statistic, p.value=ks3$p.value)
  c(statistic=ks4$statistic, p.value=ks4$p.value)
  c(statistic=ks5$statistic, p.value=ks5$p.value)

  setNames(c(ks1$statistic, ks1$p.value), c("statistic", "p.value"))
  setNames(c(ks2$statistic, ks2$p.value), c("statistic", "p.value"))
  setNames(c(ks3$statistic, ks3$p.value), c("statistic", "p.value"))
  setNames(c(ks4$statistic, ks4$p.value), c("statistic", "p.value"))
  setNames(c(ks5$statistic, ks5$p.value), c("statistic", "p.value"))
}
res[,1:5]

#-------------------------------------------------------------------

aaaa<-sapply(seq(1,60,6),function(j) 
  sapply(seq(5),function(b) ks.test(data[,j],data[,j+b],"gamma", 
                                    alternative = "l")$statistic))
sprintf("%.3f",aaaa)
bbbb<-sapply(seq(1,60,6),function(j) 
  sapply(seq(5),function(b) ks.test(data[,j],data[,j+b],"gamma",
                                    alternative = "l")$p.value))
sprintf("%.3f",bbbb)

write.csv (aaaa, file = "aaaa.csv")
write.csv (bbbb, file = "bbbb.csv")
#---------------------------------------------------------------
library(reshape2)
library(lme4)
boolean <- c(rep(0,2400), rep(1,2400))
aa<-matrix(0,nrow = 4800, ncol = 1)
for (i in 1:2400)
aa[i,]<-data1[i]
for (i in 1:2400)
aa[2400+i,]<-data2[i]
data_all<-as.data.frame(cbind(boolean,aa))
a<-glmer(boolean ~ aa,  family= gamma(link = "logit"))$coefficients

aa<-matrix(0,nrow = 4800, ncol = 1)
cccc <- sapply (seq(1,60,6), function (j)
          sapply (seq(5),function(b)
            sapply (seq(1:2400), function (i) {
             aa[i,1]<- data[,j][i]
             aa[2400+i,1]<- data[,j+b][i]})))
    data_all<-as.data.frame(cbind(boolean,aa))
    glmer(boolean ~ aa, family= gamma(link = "log"))$coefficients
            
    sprintf("%.3f",cccc[,1])
#---------------------------------------------------------------
dddd <- sapply (seq(1,60,6), function (j)
      sapply (seq(5),function(b)
      pf(mean(data[,j])/mean(data[,j+b]),4800,4800,
         lower.tail = FALSE, na.omit)))
sprintf("%.3f",dddd)
write.csv (dddd, file = "dddd.csv")      


rm(list=ls())      
n.boot <- 10000      
require(boot)
#dat <- read.csv("data.csv", header = FALSE)
eeee <- sapply (seq(1,60,6), function (j)
  sapply (seq(5),function(b)
    
    ecdf(boot(rbind(data.frame(X=dat[,j],group = "A"),data.frame(X=dat[,j+b], group = "B")),
         statistic=function(data, indices)
           diff(by(data[indices,"X"],data[indices,"group"],mean)),
         R=n.boot)$t)(0)
    ))
sprintf("%.3f",eeee)
write.csv (eeee, file = "eeee.csv")



ffff<-sapply(seq(1,60,6),function(j) 
  sapply(seq(5),function(b) t.test(data[,j]-data[,j+b],
                                    alternative = "less")$statistic))
sprintf("%.3f",ffff)
write.csv (ffff, file = "ffff.csv")

gggg<-sapply(seq(1,60,6),function(j) 
  sapply(seq(5),function(b) t.test(data[,j]-data[,j+b],
                                   alternative = "less")$p.value))
sprintf("%.3f",gggg)
write.csv (gggg, file = "gggg.csv")

hhhh<-sapply(seq(1,60,6),function(j) 
  sapply(seq(5),function(b) t.test(data[,j]-data[,j+b],
                                   alternative = "less")$estimate))
sprintf("%.3f",hhhh)
write.csv (hhhh, file = "hhhh.csv")


t.test(data1, data2)


