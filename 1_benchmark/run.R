#!/usr/bin/nohup Rscript

#
#  pliu 20180917
#
#  run PRAM to reproduce the benchmark results reported in the paper
#  - download the 30 RNA-seq bam and bai
#  - run PRAM by five meta-methods
#
#  need to run as ./run.R to get the right dir structure, otherwise getwd()
#  will be inconsistent to dir structure
#
#  5 x 8 x 2.2 GHz, 2.6 hrs
#  ~23G
#

library(pram)
library(parallel)

main <- function() {
    currdir = getwd()
    setupdir = paste0(currdir, '/../0_setup/output/')

    prm = list(
        njob_in_para = 5,
        nthr_per_job = 8,

        methods = c(  'plcf', 'plst', 'cfmg', 'stmg', 'cftc' ),

        bamids = c(
            'ENCFF044SJL', 'ENCFF048ODN', 'ENCFF125RAL', 'ENCFF207ZSA',
            'ENCFF244ZQA', 'ENCFF263OLY', 'ENCFF306YQS', 'ENCFF315VHI',
            'ENCFF343WEZ', 'ENCFF367VEP', 'ENCFF381BQZ', 'ENCFF428VBU',
            'ENCFF444SCT', 'ENCFF521KYZ', 'ENCFF547YFO', 'ENCFF588YLF',
            'ENCFF709IUX', 'ENCFF728JKQ', 'ENCFF739OVZ', 'ENCFF782IVX',
            'ENCFF782TAX', 'ENCFF800YJR', 'ENCFF802TLC', 'ENCFF834ITU',
            'ENCFF838JGD', 'ENCFF846WOV', 'ENCFF904OHO', 'ENCFF912SZP',
            'ENCFF978ACT', 'ENCFF983FHE'
        ),

        inbam_url = 'ftp://ftp.cs.wisc.edu/pub/users/kelesgroup/pliu/pram_paper/known/12_poolTgtBam/',

        cufflinks = paste0(setupdir, 'cufflinks-2.2.1.Linux_x86_64/cufflinks'),
        stringtie = paste0(setupdir, 'stringtie-1.3.3b.Linux_x86_64/stringtie'),
        taco      = paste0(setupdir, 'taco-v0.7.0.Linux_x86_64/taco_run'),
        fgnmfa    = paste0(setupdir, 'hg38_cufflinks.fa'),

        indir  = paste0(currdir, '/input/'),
        outdir = paste0(currdir, '/output/')
    )

    for ( dir in c(prm$indir, prm$outdir) ) {
        if ( ! file.exists(dir) ) dir.create(dir, recursive=T)
    }

    ## download input Bam
    mclapply(prm$bamids, downloadInputBam, prm,
             mc.cores=prm$njob_in_para, mc.preschedule=F)

    ## run pram
    mclapply(prm$methods, buildMetaModel, prm,
             mc.cores=prm$njob_in_para)
}


buildMetaModel <- function(method, prm) {
    finbamv = paste0(prm$indir, prm$bamids, '.bam')
    foutgtf = paste0(prm$outdir, method, '.gtf')

    pram::buildModel( in_bamv   = finbamv,
                      out_gtf   = foutgtf,
                      method    = method,
                      nthreads  = prm$nthr_per_job,
                      tmpdir    = prm$outdir,
                      keep_tmpdir = T,
                      cufflinks = prm$cufflinks,
                      stringtie = prm$stringtie,
                      taco      = prm$taco,
                      cufflinks_ref_fa = prm$fgnmfa )
}


downloadInputBam <- function(bamid, prm) {
    fbam_remote = paste0(prm$inbam_url, bamid, '.bam')
    fbai_remote = paste0(prm$inbam_url, bamid, '.bam.bai')

    fbam_local = paste0(prm$indir, bamid, '.bam')
    fbai_local = paste0(prm$indir, bamid, '.bam.bai')

    if ( ! file.exists( fbam_local ) ) {
        download.file(fbam_remote, destfile=fbam_local, quiet=F)
    } else {
        cat('use existing file:', fbam_local, "\n")
    }

    if ( ! file.exists( fbai_local ) ) {
        download.file(fbai_remote, destfile=fbai_local, quiet=F)
    } else {
        cat('use existing file:', fbai_local, "\n")
    }
}


system.time( main() )
