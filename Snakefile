import os,sys
import pandas as pd

configfile: "./config.yaml"
#samples=pd.read_table(config["sample"],index_col=False,header=None)[0].values.tolist()
sample_df=pd.read_table(config['sample'],index_col=0,header=0)
samples=sample_df.index.tolist()
#workdir="./"
#if not os.path.exists(os.path.join(workdir,"logs")): os.mkdir(os.path.join(workdir,"logs"))
include: "binning.smk"
include: "refine.smk"

rule all:
	input:
		expand([
			os.path.join(config['binning'],"{sample}","metabat2"),
			os.path.join(config['binning'],"{sample}","{sample}.depth"),
			os.path.join(config['binning'],"{sample}","{sample}.pe.flagstat"),
			os.path.join(config['binning'],"{sample}","{sample}.se.flagstat"),
			os.path.join(config["binning"],"{sample}/refine/fit_bins"),
			os.path.join(config["binning"],"{sample}/refine/merger.tsv"),
			os.path.join(config["binning"],"{sample}/refine/checkm.log"),
			os.path.join(config["binning"],"{sample}/refine/filter_bins"),
			os.path.join(config["binning"],"{sample}/refine/filter_checkm.log")],
			sample=samples)


