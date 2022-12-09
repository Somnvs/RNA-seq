#!/usr/bin/env Rscript
# -*- encoding: utf-8 -*-

# @Time	:	2019/04/25 14:40:56
# @Author	:	Yaheng	Wang 
# @Version	:	1.0
# @Contact	:	wangyh@rainbow-genome.com
# @License 	:	(C)Copyright 2018-2019, rainbow-genome
# @Desc	:	None

options(stringsAsFactors = F)
Args <- commandArgs(trailingOnly=T)

infile <- Args[1]
samples <- Args[2]
groups <- Args[3]
height <- as.numeric(Args[4])
width <- as.numeric(Args[5])
outpath <- Args[6]
mar_bottom <- as.numeric(Args[7])
mar_left <- as.numeric(Args[8])
mar_top <- as.numeric(Args[9])
mar_right <- as.numeric(Args[10])
legend_cex <- as.numeric(Args[11])
cex=as.numeric(Args[12])
cexAxis=as.numeric(Args[13])
cexLab=as.numeric(Args[14])


plot_withDESeq2 <- function(infile, sample, group, height, width, outpath){
    # 有重复样本的
    suppressPackageStartupMessages(library(DESeq2))

    matrix <- read.table(infile, header=T, row.names=1, sep="\t", na.strings="")
    modify_matrix <- subset(matrix, select=sample)

    condition <- as.factor(group)
    coldata <- data.frame(row.names = colnames(modify_matrix), condition)
    dds <- DESeqDataSetFromMatrix(countData = modify_matrix, colData = coldata, design = ~condition)

    dds <- DESeq(dds)
    rld <- rlogTransformation(dds, blind=TRUE)
    pcaData <- plotPCA(rld, intgroup=c("condition"), returnData=TRUE)
    percentVar <- round(100 * attr(pcaData, "percentVar"))
    #pch <- unlist(lapply(unlist(as.data.frame(table(group))$Freq), seq)) + 15
    #pch <- unlist(lapply(group, function(x){y <-data.frame(name = unique(group), num = seq(from=16, to=15+length(unique(group)))); return(y[y$name==x, ]$num)}))
    #pch <- unlist(lapply(unlist(as.data.frame(table(group))$Freq), seq))	
    freq <- lapply(table(group), seq)
    rawd <- data.frame(group = group, num=0)
    for(g in group){
          rawd[rawd$group == g, ]$num <- unlist(freq[g])
    }
    pch <-  rawd$num
    print(pch)
    print(pch[sample])


    lenx <- max(pcaData$PC1) - min(pcaData$PC1)
    leny <- max(pcaData$PC2) - min(pcaData$PC2)
    min_x <- min(pcaData$PC1) - lenx * 0.1
    max_x <- max(pcaData$PC1) + lenx * 0.1
    min_y <- min(pcaData$PC2) - leny * 0.1
    max_y <- max(pcaData$PC2) + leny * 0.1

    pdf(paste(outpath, "_PCA.pdf", sep=""), height=height, width=width)
   #par(mar=c(6,6,2,9))
    par(mar=c(mar_bottom,mar_left,mar_top,mar_right))
    # plot(pcaData[,1:2], col=colour, pch=pch[sample], cex=1.5, xlab=percentage[1], ylab=percentage[2], xlim=c(min_x, max_x), ylim=c(min_y, max_y), tck=0.03)
    plot(pcaData[,1:2], col=colour, pch=pch[sample], cex=cex,cex.axis=cexAxis,cex.lab=cexLab, xlab=paste0("PC1 (",percentVar[1],"%)"), ylab=paste0("PC2 (",percentVar[2],"%)"), xlim=c(min_x, max_x), ylim=c(min_y, max_y))
    legend(max_x + 0.1*lenx, max(pcaData$PC2), legend=levels(sample), col=colour, pch=pch[sample], cex=legend_cex, xpd = T)
    dev.off()

    png(paste(outpath, "_PCA.png", sep=""), width = width*240, height = height*240, res=72*3)
   # par(mar=c(6,6,2,9))
    par(mar=c(mar_bottom,mar_left,mar_top,mar_right))
    # plot(pcaData[,1:2], col=colour, pch=pch[sample], cex=1.5, xlab=percentage[1], ylab=percentage[2], xlim=c(min_x, max_x), ylim=c(min_y, max_y), tck=0.03)
    plot(pcaData[,1:2], col=colour, pch=pch[sample], cex=cex,cex.axis=cexAxis,cex.lab=cexLab, xlab=paste0("PC1 (",percentVar[1],"%)"), ylab=paste0("PC2 (",percentVar[2],"%)"), xlim=c(min_x, max_x), ylim=c(min_y, max_y))
    legend(max_x + 0.1*lenx, max(pcaData$PC2), legend=levels(sample), col=colour, pch=pch[sample], cex=legend_cex, xpd = T)
    dev.off()
}


s <- unlist(strsplit(samples, "[,]"))
sample <- factor(s, levels=s)
print(sample)
print(levels(sample))
group <-  factor(unlist(strsplit(groups, "[,]")))
print(group)
colours <- c("red", "gold3", "blue", "chartreuse1", "cadetblue1", "chocolate1", "yellow1", "mediumvioletred", "mediumpurple1", "grey0", "darkgreen")
colours <- c(colours,"#89C5DA", "#DA5724", "#74D944", "#CE50CA", "#3F4921", "#C0717C", "#CBD588", "#5F7FC7", 
"#673770", "#D3D93E", "#38333E", "#508578", "#D7C1B1", "#689030", "#AD6F3B", "#CD9BCD", 
"#D14285", "#6DDE88", "#652926", "#7FDCC0", "#C84248", "#8569D5", "#5E738F", "#D1A33D", 
"#8A7C64", "#599861")
#colour <- rep(colours[1: length(levels(group))], as.data.frame(table(group))$Freq)
colour <- unlist(lapply(group, function(x){y <-data.frame(name = unique(group), col = colours[1: length(levels(group))]); return(y[y$name==x, ]$col)}))
print(colour)

plot_withDESeq2(infile, sample, group, height, width, outpath)
