# pram_paper

Linux only
assume 2.1 GHz, 40 cores machine

## install PRAM and download genomic files
`0_setup/`

`1_benchmark/`
  input/ bam is from `repe/known/12_poolTgtBam/`
  upload to [Sunduz's ftp server](ftp://ftp.cs.wisc.edu/pub/users/kelesgroup/pliu/pram_paper/known/12_poolTgtBam/)

  `reported/`: 
  - gtf:  `known/13_buildMdl/`
  - eval: meta methods from `known/14_evalMdl/mode.tsv`
  - tgtids: tgtids from `known/09_selTgt.tsv`

`2_human/`
  `reported/`: `known/23_selIgMdl/`

`3_mouse/`:
- my run aligned FASTQ with GENCODE vM9
- ENCODE BAM based on GENCODE vM4 and some entries do not have BAM available, 
  e.g.  ENCSR000CLU (416B) or ENCSR000CLY (BCell).
- Therefore, we cannot simply download BAM from ENCODE and run PRAM to reproduce
  the results reported in the paper.  Instead, I will provided the results.
- If needed, I can upload the ~750G Bam to an FTP server 
