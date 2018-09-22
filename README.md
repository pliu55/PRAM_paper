PRAM Manuscript Key Results and Scripts for Reproducibility
===========================================================

Table of Contents
-----------------

* [Introduction](#Introduction)
* [Setup dependent files](#Setup-dependent-files)
* [Benchmark](#Benchmark)
* [Human master set](#Human-master-set)
* [Mouse hematopoietic system](#Mouse-hematopoietic-system)
* [Reference](#Reference)
* [Contact](#Contact)

* * *

## <a name='Introduction'></a> Introduction

This repository contains key results reported in PRAM's manuscript and __R__ 
scripts to reproduce them on user's local machine.  We provided results for 
['noise-free' benchmark](#Benchmark), 
[human master set transcript models](#Human-master-set), and 
[mouse hematopoietic transcript models](#Mouse-hematopoietic-system). 
In the sections below, We will describe each of them in details.  To reproduce 
these results, we recommand to run all the __R__ scripts in __Linux__, where 
we have tested their reproducibility.  Also, please make sure 
to [setup dependent files](#Setup-dependent-files) first before running any 
other R scripts.

To obtain this repository, please use the follow command

```
git clone https://github.com/pliu55/pram_paper
```

It will create a directory `pram_paper/` that contains the following folders 
and files:
- `0_setup/` 
  - `run.R`: script to setup dependent software and files
- `1_benchmark/` 
  - `reported/`: results for 'noise-free' benchmark
  - `run.R`: script for reproducing the results
- `2_human/`: results and scripts for human master set transcript models
- `3_mouse/`: results for mouse hematopoitic system

## <a name='Setup-dependent-files'></a> Setup dependent files

To reproduce PRAM's results, we need to prepare required software and genomic
files first with the following commands: 

```
cd 0_setup/
./run.R
```

The [run.R](0_setup/run.R) script will download and install:
- the latest PRAM package
- transcript-building software:
  - Cufflinks
  - StringTie
  - TACO
- human gene annotation from GENCODE version v24
- human genome version hg38

This script will take about 10 minutes on a 2.2 GHz machine.  All the 
dependent software and files will be saved in `0_setup/output/`, which will 
take about 9G space.


## <a name='Benchmark'></a> Benchmark

<!--
assume 2.1 GHz, 40 cores machine

`1_benchmark/`
  input/ bam is from `repe/known/12_poolTgtBam/`
  upload to [Sunduz's ftp server](ftp://ftp.cs.wisc.edu/pub/users/kelesgroup/pliu/pram_paper/known/12_poolTgtBam/)

  `reported/`: 
  - gtf:  `known/13_buildMdl/`
  - eval: meta methods from `known/14_evalMdl/mode.tsv`
  - tgtids: tgtids from `known/09_selTgt.tsv`
-->

## <a name='Human-master-set'></a> Human master set

<!--
assume 2.1 GHz, 40 cores machine

`2_human/`
  `reported/`: `known/23_selIgMdl/`
-->

## <a name='Mouse-hematopoietic-system'></a> Mouse hematopoietic system

<!--
`3_mouse/`:
- my run aligned FASTQ with GENCODE vM9
- ENCODE BAM based on GENCODE vM4 and some entries do not have BAM available, 
  e.g.  ENCSR000CLU (416B) or ENCSR000CLY (BCell).
- Therefore, we cannot simply download BAM from ENCODE and run PRAM to reproduce
  the results reported in the paper.  Instead, I will provided the results.
- If needed, I can upload the ~750G Bam to an FTP server 
- the way to predict models by PRAM are the same as in human
- selectiong by mpp and refseq, see manuscript
reported/ is from gata/86_4paper/
-->
 

## <a name="Reference"></a> Reference

PRAM identifies novel hematopoietic transcripts. Peng Liu, Alexandra A. Soukup, Emery H. Bresnick, Colin N. Dewey, and Sündüz Keleş. Manuscript in preparation.


## <a name="Contact"></a> Contact

Got a question? Please report it at the [issues tab](https://github.com/pliu55/pram_paper/issues) in this repository.
