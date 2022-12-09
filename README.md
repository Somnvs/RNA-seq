# RNA-seq
plot methods

## running example
### heatmap
`Rscript heatmap.r KOVSWT.All.txt KOVSWT true pvalue 1 0.05 red blue white 0.01 10 45 7 7 2 T F 0`

### Vocano plot
`Rscript volcano.R KOVSWT.All.txt 2 3 1 0.05 4 10 true Pvalue KOVSWT.Volcano.png KOVSWT.Volcano.txt KOVSWT.Volcano.pdf red blue grey 1.2 0.6 1 1.2 "#f0f0f0" 7 7`

### PCA
`Rscript plot.r All.HTSeq.counts.txt KO1,KO2,KO3,KO4,WT1,WT2,WT3,WT4 KO,KO,KO,KO,WT,WT,WT,WT 6 8 RNA 6 6 2 9 0.8 1.5 1.0 1.2`
