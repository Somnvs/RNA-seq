Args <- commandArgs(T)
library(ggplot2)
library(dplyr)
data=read.table(Args[1],sep="\t",header=T,fill=TRUE,quote=NULL)
log2fc=as.numeric(Args[2])
fdr=as.numeric(Args[3])
log2fcThreshold=as.numeric(Args[4])
fdrThreshold=as.numeric(Args[5])
xlimit = as.numeric(Args[6])
ylimit = as.numeric(Args[7])

rmOutLimit = Args[8]

pvaluefdr=Args[9]
png=Args[10]
outScript=Args[11]
pdf=Args[12]

upColour=Args[13]
downColour=Args[14]
normalColour=Args[15]

pointSize=as.numeric(Args[16])
vlineSize=as.numeric(Args[17])
axisTextSize=as.numeric(Args[18])
axisTitleSize=as.numeric(Args[19])
gridColour=Args[20]
#gridColour="white"
width=as.numeric(Args[21])
height=as.numeric(Args[22])



FDR <- c(data[,fdr])
FC <- c(data[,log2fc])
df <- data.frame(FDR, FC)
df.G <- subset(df, FC < -log2fcThreshold& FDR < fdrThreshold) #define Down
df.G <- cbind(df.G, rep("Down", nrow(df.G)))
colnames(df.G)[3] <- "Style"
df.B <- subset(df, (FC >= -log2fcThreshold & FC <= log2fcThreshold) | FDR >= fdrThreshold) #define Normal
df.B <- cbind(df.B, rep("Normal", nrow(df.B)))
colnames(df.B)[3] <- "Style"
df.R <- subset(df, FC > log2fcThreshold & FDR < fdrThreshold) #define Up
df.R <- cbind(df.R, rep("Up", nrow(df.R)))
colnames(df.R)[3] <- "Style"
df.t <- rbind(df.G, df.B, df.R)
df.t$Style <- as.factor(df.t$Style)

if (rmOutLimit == "false"){
  df.t[df.t$FC > xlimit, "FC"] = xlimit
  df.t[df.t$FC < -xlimit, "FC"] = -xlimit
  df.t[df.t$FDR < 10**(-ylimit), "FDR"] = 10**(-ylimit)
}else{
  df.t <- df.t %>% 
  filter(.,abs(FC) < xlimit) %>% 
  filter(.,FDR > 10**(-ylimit))
}




result=ggplot(data=df.t,aes(FC,-1*log10(FDR), color= Style)) +theme_bw()+theme(panel.grid.major=element_blank(),panel.grid.minor=element_blank(),panel.border=element_blank(),axis.line=element_line(colour="black"))+ geom_point(size=pointSize)+ xlim(-xlimit,xlimit) + ylim(0,ylimit) + geom_vline(xintercept=c(-log2fcThreshold,log2fcThreshold), linetype="longdash", size=vlineSize) + geom_hline(yintercept=c(-log10(fdrThreshold)), linetype="longdash", size=vlineSize)

if (nrow(df.G) == 0) {
result=result + scale_color_manual(values =c(normalColour,upColour)) 
}else if(nrow(df.B) == 0){
result=result + scale_color_manual(values =c(downColour,upColour)) 
}else if(nrow(df.R) == 0){
result=result + scale_color_manual(values =c(downColour,normalColour)) 
}else {
result=result + scale_color_manual(values =c(downColour,normalColour,upColour)) 
}

downNum=nrow(df.G)
nodiffNum=nrow(df.B)
upNum=nrow(df.R)
result=result+scale_color_manual(values =c(downColour,normalColour, upColour), breaks=c('Down', 'Normal', 'Up'), labels = c(paste('Down: ', downNum, sep=""),paste('Normal: ', nodiffNum, sep=""),paste('Up: ', upNum, sep="") ) )

if (pvaluefdr == "FDR") {
result2=result + labs(title="",x=expression(Log[2](FC)),y=expression(-log[10](FDR)))
} else {
result2=result + labs(title="",x=expression(Log[2](FC)),y=expression(-log[10](Pvalue)))
}


theme_Publication <- function(base_size=14) {
  library(grid)
  library(ggthemes)
  (theme_foundation(base_size=base_size)
    + theme(plot.title = element_text(face = "bold",
                                      size = rel(1.2), hjust = 0.5),
            text = element_text(),
            panel.background = element_rect(colour = NA),
            plot.background = element_rect(colour = NA),
            panel.border = element_rect(colour = NA),
            axis.title = element_text(face = "bold",size = rel(axisTitleSize)),
            axis.title.y = element_text(angle=90,vjust =2),
            axis.title.x = element_text(vjust = -0.2),
            axis.text = element_text(size = rel(axisTextSize)), 
            axis.line = element_line(colour="black"),
            axis.ticks = element_line(),
            panel.grid.major = element_line(colour=gridColour),
            panel.grid.minor = element_blank(),
            legend.key = element_rect(colour = NA),
            legend.position = "right",
            legend.direction = "vertical",
            legend.key.size= unit(0.2, "cm"),
            legend.spacing = unit(0, "cm"),
            legend.title = element_text(face="italic",size=rel(1.0)),
            legend.text = element_text(size=rel(1.0)),
            plot.margin=margin(c(10,5,5,5),"mm"),
            strip.background=element_rect(colour="#f0f0f0",fill="#f0f0f0"),
            strip.text = element_text(face="bold")
    ))
}

result2=result2+theme_Publication()


ggsave(result2,file=png,width=width,height=height)
dataplot=cbind(data[,log2fc],-1*log10(data[,fdr]))
colnames(dataplot) <-c("Log2FC","-log10(FDR)")
write.table(dataplot,quote=FALSE, row.names=FALSE, sep="\t", eol="\n",file=outScript)
ggsave(result2,file=pdf,width=width,height=height)
dataplot=cbind(data[,log2fc],-1*log10(data[,fdr]))
colnames(dataplot) <-c("Log2FC","-log10(FDR)")


