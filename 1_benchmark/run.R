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
#  5 x 8 x 2.1 GHz, 2.6 hrs
#  ~23G
#

library(data.table)
library(parallel)
library(pram)
suppressMessages(library(rtracklayer))

main <- function() {
    currdir = getwd()
    setupdir = paste0(currdir, '/../0_setup/output/')

    prm = list(
        njob_in_para = 5,
        nthr_per_job = 8,

        methods = c(  'plcf', 'plst', 'cfmg', 'stmg', 'cftc' ),

        bamids = c(
            "ENCFF125RAL", "ENCFF739OVZ", "ENCFF802TLC", "ENCFF428VBU",
            "ENCFF547YFO", "ENCFF782IVX", "ENCFF709IUX", "ENCFF244ZQA",
            "ENCFF343WEZ", "ENCFF444SCT", "ENCFF315VHI", "ENCFF834ITU",
            "ENCFF306YQS", "ENCFF521KYZ", "ENCFF800YJR", "ENCFF782TAX",
            "ENCFF912SZP", "ENCFF207ZSA", "ENCFF846WOV", "ENCFF588YLF",
            "ENCFF048ODN", "ENCFF381BQZ", "ENCFF044SJL", "ENCFF728JKQ",
            "ENCFF367VEP", "ENCFF983FHE", "ENCFF904OHO", "ENCFF838JGD",
            "ENCFF263OLY", "ENCFF978ACT"
        ),

        inbam_url = 'ftp://ftp.cs.wisc.edu/pub/users/kelesgroup/pliu/pram_paper/known/12_poolTgtBam/',

        setupdir  = setupdir,
        cufflinks = paste0(setupdir, 'cufflinks-2.2.1.Linux_x86_64/cufflinks'),
        stringtie = paste0(setupdir, 'stringtie-1.3.3b.Linux_x86_64/stringtie'),
        taco      = paste0(setupdir, 'taco-v0.7.0.Linux_x86_64/taco_run'),
        fgnmfa    = paste0(setupdir, 'hg38_cufflinks.fa'),

        ftgtids = paste0(currdir, '/reported/target_transcript_ids.txt'),
        indir   = paste0(currdir, '/input/'),
        outdir  = paste0(currdir, '/output/'),
        fout    = paste0(currdir, '/output/model_eval.tsv')
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

    ## evaluate models
    evaluateModels(prm)
}


evaluateModels <- function(prm) {
    fgnc = paste0(prm$setupdir, '/hg38_exon.gtf')
    tgt_trids = readLines(prm$ftgtids)
    tgtdt = data.table(readGFF(fgnc))[transcript_id %in% tgt_trids]
    setnames(tgtdt, 'seqid', 'chrom')

    outdt = rbindlist(mclapply(prm$methods, evalMetaModel, tgtdt, prm$outdir,
                               mc.cores=prm$njob_in_para))
    write.table(outdt, prm$fout, quote=F, sep="\t", row.names=F)
    cat('file written:', prm$fout, "\n")
}


evalMetaModel <- function(method, tgtdt, outdir) {
    fmdl = paste0(outdir, method, '.gtf')
    mdldt = data.table(readGFF(fmdl))
    setnames(mdldt, 'seqid', 'chrom')
    evaldt = pram::evalModel(mdldt, tgtdt)
    evaldt[, method := method]

    return(evaldt)
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
