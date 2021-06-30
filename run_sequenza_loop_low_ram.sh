#!/bin/bash

REFGENOMEDIR='/mnt/md0/Bam_files/Perou/wxs/refGenome'
CHR="chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX"

while read -r NORMAL;
do
NORMALID=$(echo $NORMAL | cut -d ' ' -f 1)
SAMPLENAME=$(echo $NORMAL | cut -d ' ' -f 2)

echo '[INFO] sorting ' ${NORMALID} ' file...'

samtools sort -@ 8 ${NORMALID}.bam > ${NORMALID}_S.bam
samtools index -@ 8 ${NORMALID}_S.bam ${NORMALID}_S.bai

cat tumourBam | grep $SAMPLENAME > tumourBamList

	while read -r TUMOUR;
	do
	TUMOURID=$(echo $TUMOUR | cut -d ' ' -f 1)

	echo '[INFO] sorting ' ${TUMOURID} ' file...'
	
	samtools sort -@ 8 ${TUMOURID}.bam > ${TUMOURID}_S.bam
	samtools index -@ 8 ${TUMOURID}_S.bam ${TUMOURID}_S.bai

		echo '[INFO] bam2seqz ' $TUMOURID ' file...'

		for chr in $CHR; do

		sequenza-utils bam2seqz -n ${NORMALID}_S.bam -t ${TUMOURID}_S.bam --fasta ${REFGENOMEDIR}/GRCh38_filt.fa -gc hg38.gc50Base.wig.gz -o ${TUMOURID}_${chr}.seqz.gz -C $chr &

		done
		wait

		echo '[INFO] merging ' $TUMOURID ' seqz files...'

        while read -r line; do

        C1=$(echo $line | cut -d ' ' -f 1)
        C2=$(echo $line | cut -d ' ' -f 2)
        C3=$(echo $line | cut -d ' ' -f 3)

        if [ $C1 == 'a' ];
        then
        sequenza-utils seqz_merge -o ${TUMOURID}_${C1}.seqz.gz -1 ${TUMOURID}_${C2}.seqz.gz -2 ${TUMOURID}_${C3}.seqz.gz 
        elif [ $C1 != 'v' ];
        then
        sequenza-utils seqz_merge -o ${TUMOURID}_${C1}.seqz.gz -1 ${TUMOURID}_${C2}.seqz.gz -2 ${TUMOURID}_${C3}.seqz.gz 
        rm ${TUMOURID}_${C2}.seqz.gz
        else
        sequenza-utils seqz_merge -o ${TUMOURID}.seqz.gz -1 ${TUMOURID}_${C2}.seqz.gz -2 ${TUMOURID}_${C3}.seqz.gz 
        rm ${TUMOURID}_${C2}.seqz.gz
        fi ;


        done < 'lettersSeq'


	echo '[INFO] binning ' $TUMOURID ' file...'

	sequenza-utils seqz_binning --seqz ${TUMOURID}.seqz.gz -w 50 -o ${TUMOURID}_small.seqz.gz ;

	echo '[INFO] rscript running in ' $TUMOURID ' file...'

	Rscript rsequenza.R $TUMOURID ;

	echo '[INFO] ' $TUMOURID ' file analyses DONE!'

	done < 'tumourBamList'

echo '[INFO] ' $SAMPLENAME ' files analyses DONE!'

done < 'normalBam'
