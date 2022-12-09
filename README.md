# RNA-seq
plot methods

## running example
### heatmap
`Rscript heatmap.r KOVSWT.All.txt KOVSWT true pvalue 1 0.05 red blue white 0.01 10 45 7 7 2 T F 0`

![image](https://user-images.githubusercontent.com/26337757/206697924-fe12ccd1-13e4-4eac-b25c-abd83e8fdbec.png)


### Vocano plot
`Rscript volcano.R KOVSWT.All.txt 2 3 1 0.05 4 10 true Pvalue KOVSWT.Volcano.png KOVSWT.Volcano.txt KOVSWT.Volcano.pdf red blue grey 1.2 0.6 1 1.2 "#f0f0f0" 7 7`

![image](https://user-images.githubusercontent.com/26337757/206698301-ff76135f-a049-4a1a-b3f2-75e68172e3a6.png)



### PCA
`Rscript plot.r All.HTSeq.counts.txt KO1,KO2,KO3,KO4,WT1,WT2,WT3,WT4 KO,KO,KO,KO,WT,WT,WT,WT 6 8 RNA 6 6 2 9 0.8 1.5 1.0 1.2`

![image](https://user-images.githubusercontent.com/26337757/206698061-30018571-b22e-433e-8f63-380e1ea9408e.png)


### GSEA
```
less KOVSWT.All.txt | cut -f1,2 | grep -i -w -v "NA" | sed '1d' | tr "a-z" "A-Z"  > GSEA.simple.rnk
top_num=20
software="GSEA/java/gsea2-2.2.2.jar"
gmt_dir="GSEA/all.v7.4/"

for gmt in $(ls ${gmt_dir} | grep ".gmt")
do
        name=$(echo ${gmt} | cut -d"." -f1-2 | less)
        java -cp $software  -Xmx4g xtools.gsea.GseaPreranked -gmx ${gmt_dir}"/"${gmt} \
     -collapse false -mode Max_probe -norm meandiv -nperm 1000 -rnk ./GSEA.simple.rnk -scoring_scheme weighted\
      -rpt_label ${name} -include_only_symbols true -make_sets true -plot_top_x ${top_num} -rnd_seed timestamp -set_max 500\
       -set_min 15 -zip_report false -out ./ -gui false
done
```
