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
scirpt=${18}


array=(${infile//,/ })  
 
for var in ${array[@]}
do
	newvar=${var/%.enrichment.xls/}
	newnewvar=`basename $newvar`
	bash $scirpt $1 $scriptFile $var $newnewvar $bubbScriptFile $width $height $number $itemNameLength $enrichmentXaxisAngle $orderBy $legendTitleFontSize $legendKeyFontSize $axisTitleFontSize $xAxisTextFontSize $yAxisTextFontSize $threshold
done