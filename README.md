# sequenza
Shell script to run the sequenza pipeline over multiple samples

### How to run:

The normalBam e tumourBam files are tab separated one where 1st column stands for the BAM file prefix and the 2nd column is the sample name or ID.

```bash
./run_sequenza_loop.sh normalBam tumourBam 1
```

Note the 3rd argument is useful if you are running multiple jobs in parallel.

If you are running the pipeline in a low RAM memory machine, you can use the `run_sequenza_loop_low_ram.sh` script. In this cases, the script runs every file in parallel, spliting it in 23 processes. So, if you are using a machine with limited cores, I recomend you to edit the script to avoid the loop running the processes in parallel. 

The following code is how to run the for loop sequentially:

```bash
echo '[INFO] bam2seqz ' $TUMOURID ' file...'

		for chr in $CHR; do

		sequenza-utils bam2seqz -n ${NORMALID}_S.bam -t ${TUMOURID}_S.bam --fasta ${REFGENOMEDIR}/GRCh38_filt.fa -gc hg38.gc50Base.wig.gz -o ${TUMOURID}_${chr}.seqz.gz -C $chr # REMOVE THE &

		done
		#REMOVE THE wait
```
