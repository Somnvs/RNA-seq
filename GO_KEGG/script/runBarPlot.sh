#!/bin/bash
set -e
cd $1
echo ""
scriptFile=$2
infile=$3
prefix=$4
bubbScriptFile=$5
width=$6
height=$7
number=$8
itemNameLength=$9
enrichmentXaxisAngle=${10}
orderBy=${11}
legendTitleFontSize=${12}
legendKeyFontSize=${13}
axisTitleFontSize=${14}
xAxisTextFontSize=${15}
yAxisTextFontSize=${16}
threshold=${17}

if [ ! -d "GO" ]; then
mkdir GO
fi

if [ ! -d "Pathway" ]; then
mkdir Pathway
fi

if [[ $infile =~ _GO_ ]]; then
cd GO
Rscript $scriptFile -i $infile -p $prefix -b $orderBy -n $number -l $itemNameLength -t $threshold --width $width --height $height --enrichmentXaxisAngle $enrichmentXaxisAngle
Rscript $bubbScriptFile -i $infile -p $prefix -b $orderBy -n $number -l $itemNameLength --width $width --height $height --legendKeyFontSize $legendKeyFontSize --axisTitleFontSize $axisTitleFontSize --xAxisTextFontSize $xAxisTextFontSize --yAxisTextFontSize $yAxisTextFontSize
cd -
fi

if [[ $infile =~ _Pathway ]]; then
cd Pathway
Rscript $scriptFile -i $infile -p $prefix -b $orderBy -n $number -l $itemNameLength -t $threshold --width $width --height $height --enrichmentXaxisAngle $enrichmentXaxisAngle
Rscript $bubbScriptFile -i $infile -p $prefix -b $orderBy -n $number -l $itemNameLength --width $width --height $height --legendKeyFontSize $legendKeyFontSize --axisTitleFontSize $axisTitleFontSize --xAxisTextFontSize $xAxisTextFontSize --yAxisTextFontSize $yAxisTextFontSize
cd -
fi

