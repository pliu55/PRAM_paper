#!/usr/bin/nohup Rscript

#
#  pliu 20180919
#
#  run PRAM to reproduce the human master set results reported in the paper
#  - run PRAM by five meta-methods
#
#  need to run as ./run.R to get the right dir structure, otherwise getwd()
#  will be inconsistent to dir structure
#
#  5 x 8 x 2.2 GHz, 4.3 hrs
#  ~20 G
#

library(pram)
library(parallel)

main <- function() {
    currdir = getwd()
    setupdir = paste0(currdir, '/../0_setup/output/')

    prm = list(
        njob_in_para = 5,
        nthr_per_job = 8,

        methods = c( 'plcf', 'plst', 'cfmg', 'stmg', 'cftc' ),

        ## bamids need to be in the same order as previous run to make model ids
        ## the same
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

      # methods = c( 'plst', 'stmg' ),
      # bamids = c( 'ENCFF306YQS', 'ENCFF521KYZ' ),

        cufflinks = paste0(setupdir, 'cufflinks-2.2.1.Linux_x86_64/cufflinks'),
        stringtie = paste0(setupdir, 'stringtie-1.3.3b.Linux_x86_64/stringtie'),
        taco      = paste0(setupdir, 'taco-v0.7.0.Linux_x86_64/taco_run'),
        fgnmfa    = paste0(setupdir, 'hg38_cufflinks.fa'),
        fgtf      = paste0(setupdir, 'hg38_exon.gtf'),

        radius = 10000, ## 10kb
        genome = 'hg38',
        max_uni_n_dup_aln = 10,
        max_mul_n_dup_aln = 10,

        chroms = paste0('chr', c(1:22, 'X')),
        min_n_exon = 2,
        min_tr_len = 200,
        info_keys = c( 'transcript_id', 'gene_id' ),

        bamdir    = paste0(currdir, '/input/'),
        outdir    = paste0(currdir, '/output/'),
        outbamdir = paste0(currdir, '/output/bam/'),
        fout_ig   = paste0(currdir, '/output/iggrs.rda')
    )

    if ( ! file.exists(prm$outbamdir) ) dir.create(prm$outbamdir, recursive=T)

    iggrs = pram::defIgRanges( in_gtf = prm$fgtf,
                               genome = prm$genome,
                               radius = prm$radius,
                               chroms = prm$chroms,
                               feat   = 'exon' )

    save(iggrs, file=prm$fout_ig)

  # lapply(prm$bamids, extractBam, iggrs, prm)
  # lapply(prm$methods, buildIgModel, prm$bamids, prm)
  # lapply(prm$methods, selIgModel, prm)

    mclapply(prm$bamids, extractBam, iggrs, prm,
             mc.cores=prm$njob_in_para * prm$nthr_per_job)

    mclapply(prm$methods, buildIgModel, prm$bamids, prm,
             mc.cores=prm$njob_in_para)

    mclapply(prm$methods, selIgModel, prm,
             mc.cores=prm$njob_in_para)

    unlink(prm$outbamdir, recursive=T, force=T)
    unlink(prm$fout_ig, force=T)
}


extractBam <- function(bamid, iggrs, prm) {
    finbam  = paste0(prm$bamdir,    bamid, '.bam')
    foutbam = paste0(prm$outbamdir, bamid, '.bam')

    pram::prepIgBam( finbam   = finbam,
                     iggrs    = iggrs,
                     foutbam  = foutbam,
                     max_uni_n_dup_aln = prm$max_uni_n_dup_aln,
                     max_mul_n_dup_aln = prm$max_mul_n_dup_aln )
}


buildIgModel <- function(method, bamids, prm) {
    finbamv = paste0(prm$outbamdir, bamids, '.bam')
    pram::buildModel( in_bamv   = finbamv,
                      out_gtf   = paste0(prm$outdir, 'tmp_', method, '.gtf'),
                      method    = method,
                      nthreads  = prm$nthr_per_job,
                      tmpdir    = prm$outdir,
                      keep_tmpdir = T,
                      cufflinks = prm$cufflinks,
                      stringtie = prm$stringtie,
                      taco      = prm$taco,
                      cufflinks_ref_fa = prm$fgnmfa )
}


selIgModel <- function(method, prm) {
    fin_gtf  = paste0(prm$outdir, 'tmp_', method, '.gtf')
    fsel_gtf = paste0(prm$outdir, method, '.gtf')

    pram::selModel( fin_gtf  = fin_gtf,
                    fout_gtf = fsel_gtf,
                    min_n_exon = prm$min_n_exon,
                    min_tr_len = prm$min_tr_len,
                    info_keys  = prm$info_keys )

    unlink(fin_gtf, force=T)
}

system.time( main() )
