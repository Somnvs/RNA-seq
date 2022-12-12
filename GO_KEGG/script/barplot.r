if (!requireNamespace("optparse", quietly = TRUE))
    install.packages("optparse",repos = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")
library(optparse)

option_list <- list(
    make_option(c("-i", "--inFile"), help="enrichment file"),
    make_option(c("-b", "--orderBy"), help="order item by Pvalue or FDR, default %default", default="Pvalue"),
    make_option(c("-n", "--number"), help="top item number to plot, default %default", default=20, type="integer"),
    make_option(c("-l", "--itemNameLength"), help="item name will be replaced by '...' if its length > this value, default %default", default=40, type="integer"),
    make_option(c("-t", "--threshold"), help="Pvalue or FDR threshold for significant, default %default", default=0.05, type="double"),
    make_option(c("-c", "--colors"), help="colors for significant/non-siginificant items, default %default", default="red,blue"),
    make_option(c("--width"), help="image width, default %default", default=8, type="double"),
    make_option(c("--height"), help="image height, default %default", default=7, type="double"),
    make_option(c("--enrichmentXaxisAngle"), help="angle for enrichment plot x axis text angle, default %default", default=60, type="double"),
    make_option(c("-p", "--prefix"), help="output prefix, default %default", default="out")
)
opt <- parse_args(OptionParser(option_list=option_list))

##################################################
library(ggplot2)

df <- read.table(opt$inFile, head=T, sep="\t", quote="")

#order dataframe by pvalue or FDR
df <- df[order(df[, opt$orderBy], decreasing = FALSE),]

# select item number to plot
df <- df[1:ifelse(opt$number <= dim(df)[1], opt$number, dim(df)[1]), ]

# turn pvalue or FDR to -log10(pvalue or FDR) 
df$log10P <- -log10(df[, opt$orderBy])

# 324 is the most approximate positive number to 0 that can be expressed in /rainbow/software/anaconda3/envs/rainbow/bin/R
df[df[, "log10P"]==Inf, "log10P"] <- 324 

# item name will be replaced by ¡±...¡° if its length > opt$itemNameLength
df$TermName1 <- apply(df, 1, function(x) { 
    c = unlist(strsplit(x[2], split=''));  
    if(length(c)<=opt$itemNameLength){ 
        x[2] 
    }else{  
        paste(c( c[1:opt$itemNameLength-1], "..."), collapse = '') 
    } 
} )  
df$TermID <- factor(df$TermID, levels=df$TermID, ) # there are some terms with same TermName, so use TermID as x factor

# mark significant/non-siginificant items
df[df[, opt$orderBy] < opt$threshold, "significant"] <- "N"
df[df[, opt$orderBy] >= opt$threshold, "significant"] <- "Y"

colors = strsplit(opt$colors, split=',')[[1]]

# plot Enrichment
p <- ggplot(df, aes(x=TermID, y=Enrichment, fill=significant)) +  
        geom_bar(stat="identity", width = 0.68) + 
        scale_fill_manual(values = colors) +
        scale_x_discrete(labels = df$TermName1) + 
        scale_y_continuous(expand = c(0.01, 0), position = "left") + 
        #coord_flip() +
        labs(title = "", x="", y=paste("Enrichment", sep="") ) + 
        theme_bw() + 
        theme(
            #plot.title = element_text(colour = "black", face = "bold", size = 30, hjust = 0.5),
            axis.text.x=element_text(color="black", size=rel(1.1), angle=opt$enrichmentXaxisAngle, hjust = 1),
            axis.text.y=element_text(color="black", size=rel(1.2)),
            axis.title.y = element_text(color="black", size=rel(1.1)),
            #legend.text=element_text(color="black", size=rel(1.0)),
            #legend.title = element_text(color="black", size=rel(1.1)),
            legend.position = "none",
            panel.grid=element_blank(),
            panel.border=element_blank(),
            axis.line=element_line(size=1, colour="black"),
            plot.margin = unit(c(3.5,3.5,3.5,3.5), "lines")
        )
ggsave(p, filename = paste(opt$prefix, "Enrichment.png", sep="."), width = opt$width, height = opt$height)
ggsave(p, filename = paste(opt$prefix, "Enrichment.pdf", sep="."), width = opt$width, height = opt$height)

#order dataframe by pvalue or FDR
#df <- df[order(df[, opt$orderBy], decreasing = TRUE),]
df$TermID <- factor(df$TermID, levels=rev(df$TermID), )

# plot Log10P
p <- ggplot(df, aes(x=TermID, y=log10P, fill=significant)) + 
        geom_bar(stat="identity", width = 0.68) + 
        scale_fill_manual(values = colors) +
        scale_x_discrete(labels = rev(df$TermName1)) + 
        scale_y_continuous(expand = c(0.01, 0), position = "right") + 
        coord_flip() +
        labs(title = "", x="", y=paste("-Log10(", opt$orderBy, ")", sep="") ) + 
        theme_bw() + 
        theme(
            #plot.title = element_text(colour = "black", face = "bold", size = 30, hjust = 0.5),
            axis.text.x=element_text(color="black", size=rel(0.95)),
            axis.text.y=element_text(color="black", size=rel(1.1)),
            axis.title.x = element_text(color="black", size=rel(1.1)),
            #legend.text=element_text(color="black", size=rel(1.0)),
            #legend.title = element_text(color="black", size=rel(1.1)),
            legend.position = "none",
            panel.grid=element_blank(),
            panel.border=element_blank(),
            axis.line=element_line(size=1, colour="black"),
            plot.margin = unit(c(2,2,2,2), "lines")
        )
ggsave(p, filename = paste(opt$prefix, "Log10P.png", sep="."), width = opt$width, height = opt$height)
ggsave(p, filename = paste(opt$prefix, "Log10P.pdf", sep="."), width = opt$width, height = opt$height)



