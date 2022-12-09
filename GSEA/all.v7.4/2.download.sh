#!/bin/bash

set -e

wget http://www.gsea-msigdb.org/gsea/msigdb/download_file.jsp?filePath=/msigdb/release/7.4/h.all.v7.4.symbols.gmt

wget http://www.gsea-msigdb.org/gsea/msigdb/download_file.jsp?filePath=/msigdb/release/7.4/c1.all.v7.4.symbols.gmt

wget http://www.gsea-msigdb.org/gsea/msigdb/download_file.jsp?filePath=/msigdb/release/7.4/c2.all.v7.4.symbols.gmt

wget http://www.gsea-msigdb.org/gsea/msigdb/download_file.jsp?filePath=/msigdb/release/7.4/c3.all.v7.4.symbols.gmt

wget http://www.gsea-msigdb.org/gsea/msigdb/download_file.jsp?filePath=/msigdb/release/7.4/c4.all.v7.4.symbols.gmt

wget http://www.gsea-msigdb.org/gsea/msigdb/download_file.jsp?filePath=/msigdb/release/7.4/c5.all.v7.4.symbols.gmt

wget http://www.gsea-msigdb.org/gsea/msigdb/download_file.jsp?filePath=/msigdb/release/7.4/c6.all.v7.4.symbols.gmt

wget http://www.gsea-msigdb.org/gsea/msigdb/download_file.jsp?filePath=/msigdb/release/7.4/c7.all.v7.4.symbols.gmt

wget http://www.gsea-msigdb.org/gsea/msigdb/download_file.jsp?filePath=/msigdb/release/7.4/c8.all.v7.4.symbols.gmt


echo "all file were download"

# wget could not download gmt file completely
# paste the website to the browser to download them

