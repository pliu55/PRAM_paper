PRAM manuscript key results and scripts for reproducibility
===========================================================

Table of Contents
-----------------

* [Introduction](#Introduction)
* [Setup dependent files](#Setup-dependent-files)
* ['Noise-free' benchmark](#Noise-free-benchmark)
    * [Key results](#Noise-free-benchmark-key-results)
    * [Reproducibility](#Noise-free-benchmark-reproducibility)
* [Human master set](#Human-master-set)
    * [Key results](#Human-master-set-key-results)
    * [Reproducibility](#Human-master-set-reproducibility)
* [Mouse hematopoietic system](#Mouse-hematopoietic-system)
    * [Key results](#Mouse-hematopoietic-system-key-results)
    * [Reproducibility](#Mouse-hematopoietic-system-reproducibility)
* [Reference](#Reference)
* [Contact](#Contact)

* * *

## <a name='Introduction'></a> Introduction

This repository contains key results reported in PRAM's manuscript and __R__ 
scripts to reproduce them on user's local machine.  We provided results for 
['noise-free' benchmark](#Noise-free-benchmark), 
[human master set transcript models](#Human-master-set), and 
[mouse hematopoietic transcript models](#Mouse-hematopoietic-system). 
In the sections below, We will describe each of them in details.  To reproduce 
these results, we recommend to run all the __R__ scripts in __Linux__, where 
we have tested their reproducibility.  Also, please make sure 
to [setup dependent files](#Setup-dependent-files) first before running any 
other R scripts.

To obtain this repository, please use the follow command

```bash
git clone https://github.com/pliu55/pram_paper
```

It will create a directory `pram_paper/` that contains the following folders 
and files:
- `0_setup/` 
  - `run.R`: script to setup dependent software and files
- `1_benchmark/` 
  - `reported/`: results for 'noise-free' benchmark
  - `run.R`: script for reproducing the results
- `2_human/`: 
  - `reported/`: results for human master set transcript models
  - `prepareEncodeBam.R` and `run.R`: scripts for reproducing the results
- `3_mouse/`: 
  - `reported/`: results for mouse hematopoitic system

## <a name='Setup-dependent-files'></a> Setup dependent files

To reproduce PRAM's results, we need to prepare required software and genomic
files first with the following commands: 

```bash
cd 0_setup/
./run.R
```

The script [run.R](0_setup/run.R) will download and install:
- the latest PRAM package
- transcript-building software:
  - Cufflinks
  - StringTie
  - TACO
- human gene annotation from GENCODE version v24
- human genome version hg38

This script requires ~ 9 GB hard drive space and takes ~ 10 minutes using a 
single 2.1 GHz CPU.  All the dependent software and files will be 
saved in `0_setup/output/`.



## <a name='Noise-free-benchmark'></a> 'Noise-free' benchmark

### <a name='Noise-free-benchmark-key-results'></a> Key results

Results for the 'noise-free' benchmark test are in the folder 
`1_benchmark/reported/` with their descriptions listed in the table below

| file name | description |
|:---------:|-------------|
| [target_transcript_ids.txt](1_benchmark/reported/target_transcript_ids.txt) | GENCODE v24 transcript IDs for the 1,256 target transcripts|
| [plcf.gtf](1_benchmark/reported/plcf.gtf) | predicted transcript models by PRAM's __pooling + Cufflinks__ method|
| [plst.gtf](1_benchmark/reported/plst.gtf) | predicted transcript models by PRAM's __pooling + StringTie__ method|
| [cfmg.gtf](1_benchmark/reported/cfmg.gtf) | predicted transcript models by PRAM's __Cufflinks + Cuffmerge__ method|
| [stmg.gtf](1_benchmark/reported/stmg.gtf) | predicted transcript models by PRAM's __StringTie + merging__ method|
| [cftc.gtf](1_benchmark/reported/cftc.gtf) | predicted transcript models by PRAM's __Cufflinks + TACO__ method|
| [model_eval.tsv](1_benchmark/reported/model_eval.tsv) | precision and recall for transcript models predicted by the above five methods in terms of __exon nucleotide__ (row name: `exon_nuc`), __individual junction__ (row name: `indi_jnc`), and __transcript structure__ (row name: `tr_jnc`) |

<!--
`1_benchmark/`
  input/ bam is from `repe/known/12_poolTgtBam/`
  upload to [Sunduz's ftp server](ftp://ftp.cs.wisc.edu/pub/users/kelesgroup/pliu/pram_paper/known/12_poolTgtBam/)

  `reported/`: 
  - gtf:  `known/13_buildMdl/`
  - eval: meta methods from `known/14_evalMdl/mode.tsv`
  - tgtids: tgtids from `known/09_selTgt.tsv`
-->

### <a name='Noise-free-benchmark-reproducibility'></a> Reproducibility

To reproduce the model prediction results, run the follow command:

```bash
cd 1_benchmark/
./run.R
```

The script [run.R](1_benchmark/run.R) will:
- download 'noise-free' input RNA-seq BAM files to `1_benchmark/input/`
- predict transcript models by PRAM's five meta-assembly methods and save 
  prediction results as GTF files in `1_benchmark/output/`. Files will be 
  named in
  the same way as in the [table](#Noise-free-benchmark-key-results) above
- compare transcript models with GENCODE annotation and save the evaluation
  results in `1_benchmark/output/model_eval.tsv`

The script [run.R](1_benchmark/run.R) requires ~23 GB hard drive space and 
takes ~3 hours using forty 2.1 GHz CPUs. To adjust to the running CPUs on your 
own machine, please edit the `njob_in_para` and `nthr_per_job` variables in 
[run.R](1_benchmark/run.R) to make sure `njob_in_para * nthr_per_job` do not
exceed the number of available cores.


## <a name='Human-master-set'></a> Human master set

### <a name='Human-master-set-key-results'></a> Key results

Five meta-assembly methods of PRAM were applied to predict intergenic 
transcript models based on thirty human ENCODE RNA-seq datasets.  All five 
prediction results are saved in `2_human/reported/`:

| file name | PRAM method |
|:---------:|-------------|
| [plcf.gtf.gz](2_human/reported/plcf.gtf.gz) | pooling + Cufflinks   |
| [plst.gtf.gz](2_human/reported/plst.gtf.gz) | pooling + StringTie   |
| [cfmg.gtf.gz](2_human/reported/cfmg.gtf.gz) | Cufflinks + Cuffmerge |
| [stmg.gtf.gz](2_human/reported/stmg.gtf.gz) | StringTie + merging   |
| [cftc.gtf.gz](2_human/reported/cftc.gtf.gz) | Cufflinks + TACO      |


We quantified the expression levels of transcript models predicted by 
'pooling + Cufflinks' together with GENCODE (v24)-annotated transcripts in each
of the 30 ENCODE RNA-seq datasets.  Their expression levels (in TPM) can be 
found in [isoforms.tpm.gz](2_human/reported/isoforms.tpm.gz) 

<!--
assume 2.1 GHz, 40 cores machine

`2_human/`
  `reported/`: `known/23_selIgMdl/`
               `known/29_colExpr/enc_plcf/isoforms.tpm`
-->

### <a name='Human-master-set-reproducibility'></a> Reproducibility

To reproduce the model prediction results, run the follow command:

```bash
cd 2_human/
./prepareEncodeBam.R
./run.R
```

The script [prepareEncodeBam.R](2_human/prepareEncodeBam.R) will download
thirty human RNA-seq BAM files from ENCODE, index and save them in 
`2_human/input/`.  It will take ~500 GB hard drive space and cost ~3 hours 
using thirty 2.1 GHz CPUs.  You can adjust the number of running CPUs by the 
`njob_in_para` variable in [prepareEncodeBam.R](2_human/prepareEncodeBam.R).


The script [run.R](2_human/run.R) will predict transcript models in human 
intergenic regions based on the downloaded BAM files.  It will take ~20 GB 
space and ~4.5 hours using forty 2.1 GHz CPUs.  To customize the number of 
running CPUs for your own machine is the same as in 
[reproducing benchmark results](#Noise-free-benchmark-reproducibility). 
Predicted models will be saved as GTF files in `2_human/output/`.  Files will
be named in the same way as the [table](#Human-master-set-key-results) above.


## <a name='Mouse-hematopoietic-system'></a> Mouse hematopoietic system

### <a name='Mouse-hematopoietic-system-key-results'></a> Key results

Three meta-assembly methods of PRAM were applied to predict intergenic 
transcript models based on thirty-two RNA-seq datasets from mouse 
hematopoietic system, followed by selection of 
transcript models that do not overlap with RefSeq genes and have mappability 
≥ 0.8. All three prediction results are saved in `3_mouse/reported/`:

| file name | PRAM method |
|:---------:|-------------|
| [plcf.gtf.gz](3_mouse/reported/plcf.gtf.gz) | pooling + Cufflinks   |
| [cfmg.gtf.gz](3_mouse/reported/cfmg.gtf.gz) | Cufflinks + Cuffmerge |
| [cftc.gtf.gz](3_mouse/reported/cftc.gtf.gz) | Cufflinks + TACO      |

<!--
`3_mouse/`:
reported/ is from gata/86_4paper/
-->

### <a name='Mouse-hematopoietic-system-reproducibility'></a> Reproducibility

The way to use PRAM to predict intergenic transcript models for mouse 
hematopoietic system is the same as for [human master set](#Human-master-set).
You can refer to the script [run.R](2_human/run.R) in 
[human master set](#Human-master-set) for the usage of PRAM. 

We do not provide scripts for automatically reproducing the results because:
- Some mouse ENCODE RNA-seq datasets do not have alignment BAM files 
  available, such as 
  [ENCSR000CLU](https://www.encodeproject.org/experiments/ENCSR000CLU/) and 
  [ENCSR000CLY](https://www.encodeproject.org/experiments/ENCSR000CLY/)
- Some mouse ENCODE RNA-seq datasets have alignment BAM files available, such as
  [ENCSR000CHV](https://www.encodeproject.org/experiments/ENCSR000CHV/) and 
  [ENCSR000CHY](https://www.encodeproject.org/experiments/ENCSR000CHY/). 
  But they were based on GENCODE vM4, not vM9, which we used to define known 
  genes and intergenic regions.
- The mouse RNA-seq alignment BAM file we generated takes ~750 GB hard drive 
  space, which would cost a long time for users to download.

Therefore, we simply provided the results instead.  You are always welcome to 
[contact us](#Contact) regarding the details on reproducing these results.


## <a name="Reference"></a> Reference

PRAM identifies novel hematopoietic transcripts. Peng Liu, Alexandra A. Soukup, Emery H. Bresnick, Colin N. Dewey, and Sündüz Keleş. Manuscript in preparation.


## <a name="Contact"></a> Contact

Got a question? Please report it at the [issues tab](https://github.com/pliu55/pram_paper/issues) in this repository.
