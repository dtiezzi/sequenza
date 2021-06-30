#!/bin/bash

REFGENOMEDIR='/mnt/md0/Bam_files/Perou/wxs/refGenome'

while read -r NORMAL;
do
NORMALID=$(echo $NORMAL | cut -d ' ' -f 1)
SAMPLENAME=$(echo $NORMAL | cut -d ' ' -f 2)

echo '[INFO] sorting ' ${NORMALID} ' file...'

samtools sort -@ 8 ${NORMALID}.bam > ${NORMALID}_S.bam
samtools index -@ 8 ${NORMALID}_S.bam ${NORMALID}_S.bai

cat $2 | grep $SAMPLENAME > tumourBamList_$3

	while read -r TUMOUR;
	do
	TUMOURID=$(echo $TUMOUR | cut -d ' ' -f 1)

	echo '[INFO] sorting ' ${TUMOURID} ' file...'
	
	samtools sort -@ 8 ${TUMOURID}.bam > ${TUMOURID}_S.bam
	samtools index -@ 8 ${TUMOURID}_S.bam ${TUMOURID}_S.bai

	echo '[INFO] bam2seqz ' $TUMOURID ' file...'

		sequenza-utils bam2seqz -n ${NORMALID}_S.bam -t ${TUMOURID}_S.bam --fasta ${REFGENOMEDIR}/GRCh38_filt.fa -gc hg38.gc50Base.wig.gz -o ${TUMOURID}.seqz.gz ;

	echo '[INFO] binning ' $TUMOURID ' file...'

	sequenza-utils seqz_binning --seqz ${TUMOURID}.seqz.gz -w 50 -o ${TUMOURID}_small.seqz.gz ;

	echo '[INFO] rscript running in ' $TUMOURID ' file...'

	Rscript rsequenza.R $TUMOURID ;

	echo '[INFO] ' $TUMOURID ' file analyses DONE!'

	done < tumourBamList_$3
    
echo '[INFO] ' $SAMPLENAME ' files analyses DONE!'

done < $1
