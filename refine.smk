rule merge:
	input: 
		bins=os.path.join(config["binning"],"{sample}/metabat2")
	output:
		fit_bin=directory(os.path.join(config["binning"],"{sample}/refine/fit_bins")),
		merger=os.path.join(config["binning"],"{sample}/refine/merger.tsv"),
		checkm_log=os.path.join(config["binning"],"{sample}/refine/checkm.log"),
		checkm=temp(directory(os.path.join(config["binning"],"{sample}/refine/checkm"))),
		merge=temp(directory(os.path.join(config["binning"],"{sample}/refine/merge")))
	params:
		comp=config["completeness"],
		cont=config["contamination"],
		ref=config["merge_ref"]
	threads: 4
	shell:
		'''
		checkm lineage_wf -x fa -t {threads} -f {output.checkm_log} {input.bins} {output.checkm}
		checkm merge --merged_comp {params.comp} --merged_cont {params.cont} -t {threads} -x fa {params.ref} {input.bins} {output.merge}
		cp {output.merge}/merger.tsv {output.merger}
		perl script/bins_process.pl --merger {output.merger} --lineage {output.checkm_log} --comp {params.comp} --cont {params.cont} --bin {input.bins} --output {output.fit_bin}
		'''

rule refine:
	input:
		fit_bin=os.path.join(config["binning"],"{sample}/refine/fit_bins"),
		contigs=os.path.join(config["assembly"],"{sample}/{sample}.contigs.fa")
	output:
		filter=directory(os.path.join(config["binning"],"{sample}/refine/filter_bins")),
		filter_log=os.path.join(config["binning"],"{sample}/refine/filter_checkm.log"),
		refinem=temp(directory(os.path.join(config["binning"],"{sample}/refine/refinem"))),
		checkm=temp(directory(os.path.join(config["binning"],"{sample}/refine/filter_checkm")))
	threads: 4	
	shell:
		'''
		refinem scaffold_stats -x fa -c {threads} {input.contigs} {input.fit_bin} {output.refinem}
		refinem outliers {output.refinem}/scaffold_stats.tsv {output.refinem}
		refinem filter_bins -x fa {input.fit_bin} {output.refinem}/outliers.tsv {output.filter}
		checkm lineage_wf -x fa -t {threads} -f {output.filter_log} {output.filter} {output.checkm}
		'''

