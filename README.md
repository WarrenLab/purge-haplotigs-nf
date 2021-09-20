# purge-haplotigs-nf
Nextflow workflow for purging haplotigs from a genome assembly

## Introduction
This pipeline uses the program 
[purge\_haplotigs](https://bitbucket.org/mroachawri/purge_haplotigs/src/master/)
to purge haplotigs from an assembly of a diploid organism.

## Requirements
Only nextflow and conda or mamba are required.

## Running
First, perform the alignment and create the histogram:
```bash
nextflow run WarrenLab/purge-haplotigs-nf \
    --assembly contigs.fa --subreads subreads.bam
```

Then, examine the histogram in `histogram/` to choose low, mid, and high
cutoffs, as explained in the
[README](https://bitbucket.org/mroachawri/purge_haplotigs/src/master/)
for `purge_haplotigs`. Enter those cutoffs to run the purging part of the
pipeline:
```bash
nextflow run WarrenLab/purge-haplotigs-nf \
    --assembly contigs.fa --low 5 --mid 20 --high 50
```

Your curated assembly will now be in `purged/curated.fa`.
