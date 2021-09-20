nextflow.enable.dsl=2

// params for part 1 of pipeline
params.assembly = 'contigs.fa'
params.subreads = 'subreads.bam'

// params for part 2 of pipeline
params.low = ''
params.mid = '' 
params.high = ''
params.gencov = 'histogram/aligned.bam.gencov'

process align {

    input:
    path contigs
    path subreads

    output:
    path "${subreads.baseName}.aligned.bam"

    """
    samtools fastq $subreads | \
        minimap2 -t ${task.cpus} -ax map-pb --secondary=no $contigs - \
        | samtools sort -m 10G -o ${subreads.baseName}.aligned.bam
    samtools index ${subreads.baseName}.aligned.bam
    """
}

process histogram {
    publishDir 'histogram'
    
    input:
    path contigs
    path 'aligned.bam'

    output:
    path 'aligned.bam.gencov', emit: 'gencov'
    path 'aligned.bam.histogram.png'

    """
    purge_haplotigs hist -t $task.cpus -b aligned.bam -g $contigs
    """
}

process purge {
    publishDir 'purged', mode: 'copy'

    input:
    path assembly
    path gencov

    output:
    path "curated.*"

    """
    purge_haplotigs cov -in $gencov \
        -low $params.low -mid $params.mid -high $params.high
    purge_haplotigs purge -t $task.cpus -g $assembly -c coverage_stats.csv
    """
}

workflow {
    assembly = file(params.assembly)
    subreads = file(params.subreads)

    if ( ! (params.low && params.mid && params.high )) {
        align(assembly, subreads)
        histogram(assembly, align.out)
    } else {
        purge(assembly, file(params.gencov))
    }
}
