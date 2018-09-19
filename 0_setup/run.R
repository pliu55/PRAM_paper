#!/usr/bin/env Rscript

#
#  pliu 20180916
#
#  download required software and genomic data for reproducing results reported
#  in the PRAM manuscript
#  - install PRAM from GitHub
#  - download extenal software
#    - Cufflinks, Cuffmerge
#    - StringTie, StringTie-merge
#    - TACO
#  - GENCODE v24
#  - genome sequence files
#    - hg38
#    - mm10
#
#  - all actions will take place in output/
#
#  1 x 2.1 GHz, 13 mins
#  9.4 G total (saved + removed)
#

library(devtools)
suppressMessages(library(rtracklayer))

main <- function() {
    prm = list(
        pram_repo = 'pliu55/pram',

        cufflinks_url = 'http://cole-trapnell-lab.github.io/cufflinks/assets/downloads/cufflinks-2.2.1.Linux_x86_64.tar.gz',

        stringtie_url = 'http://ccb.jhu.edu/software/stringtie/dl/stringtie-1.3.3b.Linux_x86_64.tar.gz',

        taco_url = 'https://github.com/tacorna/taco/releases/download/v0.7.0/taco-v0.7.0.Linux_x86_64.tar.gz',

        hg_gnc_url = 'ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_24/gencode.v24.annotation.gtf.gz',

        mm_gnc_url = 'ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_mouse/release_M9/gencode.vM9.annotation.gtf.gz',

        hg_genome = 'hg38',
        mm_genome = 'mm10',

        hg_genome_url = 'ftp://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.chromFa.tar.gz',
        mm_genome_url = 'ftp://hgdownload.soe.ucsc.edu/goldenPath/mm10/bigZips/chromFa.tar.gz',

        hg_chroms = paste0('chr', c(1:22, 'X')),
        mm_chroms = paste0('chr', c(1:19, 'X', 'Y')),

        outdir      = 'output/',
        fout_hg_gtf = 'hg38_exon.gtf',
        fout_mm_gtf = 'mm10_exon.gtf',
        fout_hg_fa  = 'hg38_cufflinks.fa',
        fout_mm_fa  = 'mm10_cufflinks.fa'
    )

    if ( ! file.exists(prm$outdir) ) dir.create(prm$outdir, recursive=T)

    setwd(prm$outdir)

    ## install PRAM from GitHub
  # devtools:install_github(prm$repo)

    ## setup external software
    setupSoftware(prm)

    ## setup GENCODE
    setupGENCODE(prm)

    ## setup genomes for Cufflinks
    setupGenome(prm)
}


setupGenome <- function(prm) {
    ## hg38: hg38_chromFa/chroms/chr*.fa
    ## mm10: mm10_chromFa/chr*.fa

    cat("setup", prm$hg_genome, "genome\n")
    downloadAndPrepGenome(prm$hg_genome, prm$hg_genome_url, prm$fout_hg_fa)

    cat("setup", prm$mm_genome, "genome\n")
    downloadAndPrepGenome(prm$mm_genome, prm$mm_genome_url, prm$fout_mm_fa)
}


downloadAndPrepGenome <- function(genome, genome_url, fout) {
    if ( file.exists(fout) ) {
        cat('will use existing file:', fout, "\n")
    } else {
        fdest = paste0(genome, '_chromFa.tar.gz')
        exdir = paste0(genome, '_chromFa/')
        if ( file.exists(exdir) ) {
            cat('will use existing files in:', exdir, "\n")
        } else {
            downloadAndUntar(genome_url, fdest, exdir)
        }

        ffas  = list.files(exdir, recursive=T, full.names=T)
        if ( genome == 'hg38' ) {
            ffas = ffas[ ! grepl('chrY', ffas) ]
        }

        cmd = paste0('cat ', paste0(ffas, collapse=' '), ' > ', fout)
      # cat(cmd, "\n")
        system(cmd)
        cat('file written:', fout, "\n")

        unlink(exdir, recursive=T, force=T)
    }
}


setupGENCODE <- function(prm) {
    cat("setup human GENCODE GTF\n")
    downloadAndExtractExon(prm$hg_gnc_url, prm$hg_chroms, prm$fout_hg_gtf)

    cat("setup mouse GENCODE GTF\n")
    downloadAndExtractExon(prm$mm_gnc_url, prm$mm_chroms, prm$fout_mm_gtf)
}


setupSoftware <- function(prm) {
    ## download Cufflinks suite
    cat("setup Cufflinks\n")
    downloadAndUntar(prm$cufflinks_url)

    ## download StringTie suite
    cat("setup StringTie\n")
    downloadAndUntar(prm$stringtie_url)

    ## donwload TACO
    cat("setup TACO\n")
    downloadAndUntar(prm$taco_url)
}


downloadAndUntar <- function(url, fdest=NULL, exdir='.') {
    if ( is.null(fdest) ) {
        fdest = basename(url)
    }

    if ( file.exists(fdest) ) {
        cat('will use existing file:', fdest, "\n")
    } else {
        download.file(url, destfile = fdest, quiet=F)
    }

    untar(fdest, exdir=exdir)
}


downloadAndExtractExon <- function(url, chroms, fout) {
    fgz = basename(url)
    if ( ! file.exists(fgz) ) {
        download.file(url, destfile=fgz, quiet=F)
    } else {
        cat('will use existing file:', fgz, "\n")
    }

    if ( ! file.exists(fout) ) {
        export( readGFF( fgz,
                         tags   = c('gene_id'),
                         filter = list( type  = c('exon'),
                                        seqid = chroms ) ),
                fout,
                format = 'GTF' )
        cat('file written:', fout, "\n")
    } else {
        cat('will use existing file:', fout, "\n")
    }
}

system.time( main() )
