if (!requireNamespace("glue", quietly = TRUE))
    install.packages("glue", version = "1.3.2", repos = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN')
require(glue)
Sys.setenv(TAR = "/bin/tar")
if (!requireNamespace("devtools", quietly = TRUE))
    install.packages("devtools", repos ='https://mirrors.tuna.tsinghua.edu.cn/CRAN')
require(devtools)
if (!requireNamespace("cpp11", quietly = TRUE))
    devtools::install_version("cpp11", version = "0.1", repos = "http://cran.us.r-project.org")
require(cpp11)

if (!requireNamespace("optparse", quietly = TRUE))
    install.packages("optparse", repos ='https://mirrors.tuna.tsinghua.edu.cn/CRAN')

if (!requireNamespace("tidyr", quietly = TRUE))
    install.packages("tidyr", version = "1.3.2", repos ='https://mirrors.tuna.tsinghua.edu.cn/CRAN')

library("optparse")
require("tidyr")

option_list <- list(        
	make_option(c("-i", "--infile"), help="interested gene list"),   
	make_option(c("-a", "--anno"), help="Annotation.xls"),
	make_option(c("-t", "--analysisType"), help="analysisType, GO or Pathway, default %default", default="GO"),
	make_option(c("--skipHead"), help="whether to skip infile first row, default: %default", default=FALSE),
	make_option(c("--geneId"), help="use geneId or geneName as identifier, default: %default", default="geneName"),
	make_option(c("--geneColNum"), help="the column number of gene to be enriched in input file, default: %default", default=1, type="integer"),
	make_option(c( "--log2fcColNum"), help="the column number of log2fc in input file to filter non differential expression genes, default: %default. if 0 is given, log2fc will not be used as a filter condition for genes to be enriched, --upLog2fcCutoff and --downLog2fcCutoff will not be used too.", default=2, type="integer"),
	make_option(c("--upLog2fcCutoff"), help="log2fc cutoff for gene expression up regulation, default: %default", default=0, type="double"),
	make_option(c("--downLog2fcCutoff"), help="log2fc cutoff for gene expression down regulation, default: %default", default=0, type="double"),
	make_option(c("--minGeneNumInTerm"), help="go terms/pathway with gene number > this value will be analysed, default: %default", default=0, type="integer"),
	make_option(c("-p", "--prefix"), help="output prefix")
)
opt <- parse_args(OptionParser(option_list=option_list))
##################################################

if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager", repos ='https://mirrors.tuna.tsinghua.edu.cn/CRAN')
#if (!requireNamespace("clusterProfiler", quietly = TRUE))
#    BiocManager::install("clusterProfiler")
library("clusterProfiler")

# constant 
GENE_ID_COL = 1 
GENE_NAME_COL = 6
GENE_DESCRIPTION_COL = 7
GO_COL = c(8, 9, 10)
names(GO_COL)=c("BP", "CC", "MF")
PATHWAY_COL = 11
GENE_IDENTIFIER = ifelse(opt$geneId=="geneId", GENE_ID_COL, GENE_NAME_COL) # use gene name to find association between annotation and interested gene list

readAnno <- function(anno, col) {

	term2gene = apply(anno[ anno[, col] !="-", ], 1, function(x) strsplit(x[col], split=";")[[1]]) # skip rows with "-"
	names(term2gene)<-anno[ anno[, col] !="-", GENE_IDENTIFIER]
	termNum <- sapply(term2gene, function(x) length(x) ) # record the term number of each gene 
	term2gene<-data.frame(TERMSTR=as.vector(unlist(term2gene)), GENE=rep(names(termNum), termNum)) #replicate gene name n times, n = term number of this gene
	term2gene$TERM = apply(term2gene, 1, function(x) strsplit(x[1], split="//")[[1]][1])
	term2gene$NAME = apply(term2gene, 1, function(x) strsplit(x[1], split="//")[[1]][2])

	cat("[INFO] handle annotation column ", col, " done.\n")
	term2gene[, -1]
	#term2gene
}

enrichment <- function(geneList, term2gene, anno, minGeneNumInTerm, outPrefix, outPrefix1) {
	# use clusterProfiler enricher function to do gene enrichment
	
	# colnames of term2gene are "TERM","GENE", "NAME"
	# TERM2GENE paramter of enricher function needs the order of columns of input data to be exactly as "TERM","GENE", so as TERM2NAME
	# pvalueCutoff and qvalueCutoff are used to filter out enriched terms with pvalue/qvalue > this value
	rawResult <- enricher(geneList, 
		TERM2GENE = term2gene[,c("TERM","GENE")], 
		TERM2NAME=term2gene[,c("TERM","NAME")], 
		pAdjustMethod = "BH", 
		minGSSize = minGeneNumInTerm, 
		maxGSSize = Inf, # default maxGSSize = 500
		pvalueCutoff = 1, 
		qvalueCutoff = 1
	)
	rawResult <- as.data.frame(rawResult@result)[, c(1:6, 8)]

	cat("[INFO] enrichment for ", outPrefix," done.\n")

	resultList = apply(rawResult, 1, strsplit, "/")
	geneNumSet = as.data.frame(t(sapply(resultList, function(x) as.numeric(c(x$GeneRatio[1], x$GeneRatio[2], x$BgRatio[1], x$BgRatio[2] )))))
	colnames(geneNumSet) <- c("GeneInListInTerm", "GeneInList", "GeneInTerm", "TotalGene")
	geneNumSet$Enrichment = (geneNumSet$GeneInListInTerm/geneNumSet$GeneInList)/(geneNumSet$GeneInTerm/geneNumSet$TotalGene)
	result <- cbind(data.frame(TermID=rawResult[, 1], TermName=rawResult[, 2]), geneNumSet, data.frame(Pvalue=rawResult[, 5], FDR=rawResult[, 6]))
	write.table(result, file=paste(outPrefix, ".enrichment.xls", sep=""), sep="\t", quote=F, row.names=F)
	write.table(result, file=paste(outPrefix1, ".enrichment.xls", sep=""), sep="\t", quote=F, row.names=F)

	enrichedGenes <- lapply(resultList, function(x) c(x$geneID))
	enrichedGeneNum <- sapply(enrichedGenes, function(x) length(x) ) # get gene number in enriched terms
	geneWithAnno <- t(sapply(unlist(enrichedGenes), function(x) c(x, anno[anno[, GENE_IDENTIFIER]==x, GENE_DESCRIPTION_COL][1]))) # find gene description in anno
	term2geneResult = cbind(result[rep(1:nrow(result), enrichedGeneNum), ], data.frame(GeneID=geneWithAnno[,1], Description=geneWithAnno[,2]))
	write.table(term2geneResult[, c(1,2,7:11)], file=paste(outPrefix, ".term2gene.xls", sep=""), sep="\t", quote=F, row.names=F) # "GeneInListInTerm", "GeneInList", "GeneInTerm", "TotalGene" will not be output in term2gene.xls
	write.table(term2geneResult[, c(1,2,7:11)], file=paste(outPrefix1, ".term2gene.xls", sep=""), sep="\t", quote=F, row.names=F)

	cat("[INFO] write result for ", outPrefix," done.\n")
}

# read interested gene list,
# for RNA-seq, interested gene list is up regulated genes, down regulated genes and all diff genes
# for ATAC-seq, interested gene list is peak target genes
# if --log2fcColNum is given, allGene = upGene + downGene
df = read.table(opt$infile, head = opt$skipHead, sep="\t", stringsAsFactors=F)

geneList = list()
geneList[["all"]] = unique( df[ , opt$geneColNum] )

if(opt$log2fcColNum){
	geneList[["up"]] = unique( df[ df[, opt$log2fcColNum ] >=  opt$upLog2fcCutoff, opt$geneColNum] )
	geneList[["down"]] = unique( df[ df[, opt$log2fcColNum ] <=  opt$downLog2fcCutoff, opt$geneColNum] )
	cat(length(geneList[["up"]]),length(geneList[["down"]]),"\n")
	geneList[["all"]] = c(geneList[["up"]], geneList[["down"]])
}

anno = read.table(opt$anno, head = T, sep="\t", quote="", stringsAsFactors=F)
cat("[INFO] read annotation done.\n")

if(opt$analysisType=="GO"){
	term2gene = list()
	for(namespace in names(GO_COL)){
		term2gene[[namespace]] = readAnno(anno, GO_COL[namespace])
	}

	for(listName in names(geneList)){ # iter for "up", "down", "all" geneList, or only for "all" geneList
		if(length(geneList[[listName]])){ 
			for(namespace in names(GO_COL)){ # iter for 
				outPrefix = ifelse( 
					opt$log2fcColNum, 
					paste(opt$prefix,  listName, opt$analysisType, namespace, sep="_"),  
					paste(opt$prefix,  opt$analysisType, namespace, sep="_")
				)
				outPrefix1 = ifelse( 
					opt$log2fcColNum, 
					paste(paste(opt$prefix,  listName, sep="."), opt$analysisType, namespace, sep="_"),  
					paste(paste(opt$prefix,  opt$analysisType, sep="."), namespace, sep="_")
				)
				enrichment(geneList[[listName]], term2gene[[namespace]], anno, opt$minGeneNumInTerm, outPrefix, outPrefix1)
			}
		}else{
			cat("[WARN] Length of geneList ", listName, " is 0, skip enrichment.")
		}
	}
}else if(opt$analysisType=="Pathway"){
	term2gene = readAnno(anno, PATHWAY_COL)

	for(listName in names(geneList)){
		if(length(geneList[[listName]])){ 
			outPrefix = ifelse( 
				opt$log2fcColNum, 
				paste(opt$prefix,  listName, opt$analysisType, sep="_"),  
				paste(opt$prefix,  opt$analysisType, sep="_")
			)
			outPrefix1 = ifelse( 
				opt$log2fcColNum, 
				paste(paste(opt$prefix,  listName, sep="."), opt$analysisType, sep="_"),  
				paste(opt$prefix,  opt$analysisType, sep=".")
			)
			enrichment(geneList[[listName]], term2gene, anno, opt$minGeneNumInTerm, outPrefix, outPrefix1)
		}else{
			cat("[WARN] Length of geneList ", geneList, " is 0, skip enrichment.")
		}
	}
}
