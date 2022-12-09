library(pheatmap)

args<-commandArgs(T)
countFile <- args[1]
outprefix <- args[2]
isMutiSample <- as.logical(args[3])
PvalueFDR <- as.character(args[4])
log2FC <- as.numeric(args[5])
PvalueFDR_cutoff <- as.numeric(args[6])
upColor=args[7]
downColor=args[8]
baseColor=args[9]
fontsizeRow=as.numeric(args[10])
fontsizeCol=as.numeric(args[11])
angleCol=as.numeric(args[12])
width=as.numeric(args[13])
height=as.numeric(args[14])
clusterNum=as.numeric(args[15])
clusterRows=as.logical(args[16])
clusterCols=as.logical(args[17])
treeHeightRow=as.numeric(args[18])

oneSamplePheatmap <- function(matrix, PvalueFDR, log2FC, PvalueFDR_cutoff, outprefix){
	# 过滤logFC为NA的行
	data <- matrix[! is.na(matrix[, "log2FC"]),]
	data <- data[data[, PvalueFDR] < PvalueFDR_cutoff,]
	data<-data[abs(data[, "log2FC"]) >= log2FC, ]
#	names<-unlist(strsplit(colnames(data)[4:5], ".fpkm"))
	names<-unlist(strsplit(colnames(data)[6:7], ".fpkm"))
	data<-data[,c("log2FC","log2FC")]
	data[,2]<-data[,2]*(-1)
	colnames(data)<-names

	#ann_col=data.frame(sample=c(rep('treat',1),rep('control',1)))
	#rownames(ann_col)=colnames(data)[1:2]
	p<-pheatmap(data[,1:2],col=colorRampPalette(c(downColor,baseColor,upColor))(50),scale='none',cutree_rows=clusterNum)
        dev.off()
	data$cl <- cutree(p$tree_row,k=clusterNum)
        data <- data[order(data$cl),]

        ann <- data.frame(cluster=data$cl)
        rownames(ann) <- rownames(data)

	pdf(paste0(outprefix, '.pdf'), onefile=F,width=width,height=height)
	pheatmap(data[,1:2],col=colorRampPalette(c(downColor,baseColor,upColor))(50),scale='none',cluster_rows=clusterRows,cluster_cols=clusterCols,show_rownames=T,cellwidth=80,fontsize_col=fontsizeCol,angle_col=angleCol,fontsize_row=fontsizeRow,annotation_row=ann,treeheight_row=treeHeightRow)
	dev.off()

	png(paste(outprefix, ".png", sep=""), width = width*240, height = height*240, res=72*3)
    pheatmap(data[,1:2],col=colorRampPalette(c(downColor,baseColor,upColor))(50),scale='none',cluster_rows=clusterRows,cluster_cols=clusterCols,show_rownames=T,cellwidth=80,fontsize_col=fontsizeCol,angle_col=angleCol,fontsize_row=fontsizeRow,annotation_row=ann,treeheight_row=treeHeightRow)
	dev.off()

}


multiSamplePheatmap <- function(matrix, PvalueFDR, log2FC, PvalueFDR_cutoff, outprefix){
        data <- matrix[matrix[, PvalueFDR]< PvalueFDR_cutoff,]
        data<-data[abs(data[,1]) >= log2FC,]
        
	s <- colnames(data)
	sample <- unique(unlist(strsplit(s[grep(".fpkm$", s)], "\\.fpkm")))
	data <- subset(data, select=sample)
	length <- length(data)

	data$ave <- apply(data, 1, mean)
	data[1:length] <- data[1:length]/data$ave

		p <- pheatmap(data[,1:length],col=colorRampPalette(c(downColor,baseColor,upColor))(50),scale='row',cutree_rows=clusterNum)

		dev.off()

		data$cl <- cutree(p$tree_row,k=clusterNum)
		data <- data[order(data$cl),]

		ann <- data.frame(cluster=data$cl)
		rownames(ann) <- rownames(data)


		pdf(paste0(outprefix, '.pdf'),width=width,height=height,onefile=F)
		pheatmap(data[,1:length],col=colorRampPalette(c(downColor,baseColor,upColor))(50),scale='row',cluster_rows=clusterRows,cluster_cols=clusterCols,show_rownames=T,cellwidth=30,fontsize_col=fontsizeCol,angle_col=angleCol,fontsize_row=fontsizeRow,annotation_row=ann,treeheight_row=treeHeightRow)
		dev.off()

		png(paste(outprefix, ".png", sep=""), width = width*240, height = height*240, res=72*3)
		pheatmap(data[,1:length],col=colorRampPalette(c(downColor,baseColor,upColor))(50),scale='row',cluster_rows=clusterRows,cluster_cols=clusterCols,show_rownames=T,cellwidth=30,fontsize_col=fontsizeCol,angle_col=angleCol,fontsize_row=fontsizeRow,annotation_row=ann,treeheight_row=treeHeightRow)
		dev.off()

}




matrix <- read.table(countFile, header=T, row.names=1, sep="\t")


if(isMutiSample){
	multiSamplePheatmap(matrix, PvalueFDR, log2FC, PvalueFDR_cutoff, outprefix)
}else{
	if(PvalueFDR=="padj"){
        	PvalueFDR <- "FDR"
	}else{
        	PvalueFDR <- "Pvalue"
	}
	oneSamplePheatmap(matrix, PvalueFDR, log2FC, PvalueFDR_cutoff, outprefix)
}

