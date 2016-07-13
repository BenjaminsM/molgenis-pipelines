#MOLGENIS walltime=23:59:00 mem=40gb nodes=1 ppn=2

### variables to help adding to database (have to use weave)
#string sampleName
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string bam

#string exonlist
#string readCountDir
#string readCountFileGene
#string readCountFileExon
#string bedtoolsVersion
#string samtoolsVersion
#string tabixVersion

echo "## "$(date)" Start $0"
getFile ${bam}


${stage} BEDTools/${bedtoolsVersion}
${stage} SAMtools/${samtoolsVersion}
${stage} tabix/${tabixVersion}

mkdir -p ${readCountDir}


#I: $1 Location of QCd BAM files $2 Location of Condensed exonList file (Generated by GetExonInfo)
#O: Y.txt Gcc.txt file generated for RASQUAL Main.txt file with gene data C.txt counts per gene
#W: Make sure the formats are the same for exonlist and BAMS chr1/1..chrX/X
###########################################################################
# Gets counts per exon per sample prints them to files and pastes them together to generate  CountTable (EXONLIST + Reads per sample)
# This is the longest step of the script
echo Intersecting with bams
export LC_ALL=C
# Reads per Gene
bedtools bamtobed -split -i ${bam} | \
	LC_ALL=C sort -t $'\t' -k1,1 -k2,2n | \
awk 'BEGIN {FS=OFS="\t"} {$5=0; print $0}' | \
	bedtools intersect -sorted -loj -b stdin -a ${exonlist} | \
sed 's#/.##' | cut -f1,2,4,20,21 | sort -t $'\t' -k3,3 |\
bedtools groupby -g 3 -c 1,2,4,5 -o first,first,count_distinct,sum | \
cut --complement -f1 | LC_ALL=C sort -t $'\t' -k1,1 -k2,2n | \
awk -F "\t" '{if ($4<0) print $3-1; else print $3}' > ${readCountFileGene}
## Per Exon
#bedtools bamtobed -split -i ${bam} | \
#        LC_ALL=C sort -t $'\t' -k1,1 -k2,2n | \
#        bedtools intersect -sorted -c -b stdin -a ${exonlist} | cut -f17 > ${readCountFileExon}
bedtools bamtobed -split -i ${bam} | \
        LC_ALL=C sort -t $'\t' -k1,1 -k2,2n | \
awk 'BEGIN {FS=OFS="\t"} {$5=0; print $0}' | \
        bedtools intersect -sorted -loj -b stdin -a ${exonlist} | \
sed 's#/.##' | cut -f1,2,4,6,20,21 | awk 'BEGIN {FS=OFS="\t"} {$3=$3"_"$4; print $0}' | \
cut --complement -f4 |sort -t $'\t' -k3,3 |\
bedtools groupby -g 3 -c 1,2,4,5 -o first,first,count_distinct,sum | \
cut --complement -f1 | LC_ALL=C sort -t $'\t' -k1,1 -k2,2n | \
awk -F "\t" '{if ($4<0) print $3-1; else print $3}' > ${readCountFileExon}
################################
echo "## "$(date)" ##  $0 Done "
################################
