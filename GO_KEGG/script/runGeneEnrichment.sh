#!/bin/bash
set -e
cd $1
echo ""
scriptFile=$2
infile=$3
anno=$4
prefix=$5
#analysisType=$6
log2fcColNum=$6
skipHead=$7
geneId=$8


if [ ! -d "GO" ]; then
mkdir GO
fi
#cd GO
Rscript $scriptFile -i $infile -a $anno -p $prefix -t GO --log2fcColNum $log2fcColNum --skipHead $skipHead --geneId $geneId

if [ ! -d "Pathway" ]; then
mkdir Pathway
fi
#cd Pathway
Rscript $scriptFile -i $infile -a $anno -p $prefix -t Pathway --log2fcColNum $log2fcColNum --skipHead $skipHead --geneId $geneId

echo ""
echo "jobs done"