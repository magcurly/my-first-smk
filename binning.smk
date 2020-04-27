def get_read(sample_df,wildcards,col):
    return sample_df.loc[[wildcards.sample],col].dropna()
    
rule bwa:
    input:
        contigs=os.path.join(config['assembly'],"{sample}/{sample}.contigs.fa"),
        read1=lambda wildcards: sample_df.loc[wildcards.sample,"fq1"],
        read2=lambda wildcards: sample_df.loc[wildcards.sample,"fq2"],
        readsingle=lambda wildcards: sample_df.loc[wildcards.sample,"single"]
    output:
        pe_flag=os.path.join(config['binning'],"{sample}","{sample}.pe.flagstat"),
        se_flag=os.path.join(config['binning'],"{sample}","{sample}.se.flagstat"),
        pe_bam=temp(os.path.join(config['binning'],"{sample}","{sample}.pe.sort.bam")),
        se_bam=temp(os.path.join(config['binning'],"{sample}","{sample}.se.sort.bam"))
    
    threads: 4

    shell:
        '''
        bwa index {input.contigs}
        bwa mem -t {threads} -5 {input.contigs} {input.read1} {input.read2} |samtools view  -hbS - | tee >(samtools flagstat  - >{output.pe_flag}) | samtools sort -o {output.pe_bam}
        bwa mem -t {threads} -5 {input.contigs} {input.readsingle} |samtools view  -hbS - | tee >(samtools flagstat  - >{output.se_flag}) | samtools sort -o {output.se_bam}
        '''

rule binning:
    input:
        contigs=os.path.join(config['assembly'],"{sample}/{sample}.contigs.fa"),
        se_bam=os.path.join(config['binning'],"{sample}","{sample}.se.sort.bam"),
        pe_bam=os.path.join(config['binning'],"{sample}","{sample}.pe.sort.bam")
    output:
        depth=os.path.join(config['binning'],"{sample}","{sample}.depth"),
        metabat=directory(os.path.join(config['binning'],"{sample}","metabat2"))
        
    threads: 4
    shell:
        '''
        jgi_summarize_bam_contig_depths --outputDepth {output.depth} {input.pe_bam} {input.se_bam}
        metaba2 -t {threads} -i {input.contigs} -a {output.depth} -o {output.metabat}/{wildcards.sample}_bin
        '''
