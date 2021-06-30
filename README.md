# sequenza

This is a shell script to run the sequenza pipeline over multiple samples

### How to run:

The normalBam e tumourBam files are tab separated one where 1<sup>st</sup> column stands for the BAM file prefix and the 2<sup>nd</sup> column is the sample name or ID.

```bash
./run_sequenza_loop.sh normalBam tumourBam 1
```

Note the 3<sup>rd</sup> argument is useful if you are running multiple jobs in parallel. In this case, you can split your normalBam file into as many as you want:

```bash
split -n l/N normalBam <prefix> # N = number of subfiles to be split
```

If you are running the pipeline in a low RAM memory machine, you can use the `run_sequenza_loop_low_ram.sh` script. In this case, the script runs every file in parallel, splitting it in 23 processes. So, if you are using a machine with limited cores, it’s recommended you to edit the script to avoid the loop running the processes in parallel.

The following code is how to run the for loop sequentially:

```bash
echo '[INFO] bam2seqz ' $TUMOURID ' file...'

		for chr in $CHR; do

		sequenza-utils bam2seqz -n ${NORMALID}_S.bam -t ${TUMOURID}_S.bam --fasta ${REFGENOMEDIR}/GRCh38_filt.fa -gc hg38.gc50Base.wig.gz -o ${TUMOURID}_${chr}.seqz.gz -C $chr # REMOVE THE &

		done
		#REMOVE THE wait
```
