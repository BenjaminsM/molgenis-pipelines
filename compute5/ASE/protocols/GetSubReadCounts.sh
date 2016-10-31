#MOLGENIS walltime=23:59:00 mem=6gb nodes=1 ppn=2

### variables to help adding to database (have to use weave)
#string sampleName
#string project
###
#string stage
#string checkStage
#string WORKDIR
#string projectDir
#string bam
#string exonGTF
#string readCountDir
#string readCountFileGene
#string readCountFileExon
#string pathSubread
#string sampleName
#string stranded
#string CHR

echo "## "$(date)" Start $0"

getFile ${bam}

mkdir -p ${readCountDir}

#Load Subread module
${stage} Subread/${subreadVersion}
${checkStage}


#I: $1 Location of QCd BAM files $2 Location of Condensed exonList file (Generated by GetExonInfo)
#O: Y.txt Gcc.txt file generated for RASQUAL Main.txt file with gene data C.txt counts per gene
#W: Make sure the formats are the same for exonlist and BAMS chr1/1..chrX/X

#Get featureCounts and group per gene

featureCounts \
-F GTF \
-O \
-s ${stranded} \
-p \
-B \
-a ${exonGTF} \
-o $TMPDIR/${sampleName}.chr${CHR}.txt \
${bam}

tail -n +3 $TMPDIR/${sampleName}.chr${CHR}.txt | \
LC_ALL=C \
sort -t$'\t' -k1,1 | \
cut -f7 > ${readCountFileGene}


## Per Exon
featureCounts \
-F GTF \
-O -f -s ${stranded} \
-p \
-B \
-a ${exonGTF} \
-o $TMPDIR/${sampleName}.chr${CHR}.txt \
${bam}

tail -n +3 $TMPDIR/${sampleName}.chr${CHR}.txt | \
cut -f7 > ${readCountFileExon}


echo "## "$(date)" ##  $0 Done "

