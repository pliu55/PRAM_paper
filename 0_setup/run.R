#!/usr/bin/env Rscript

#
#  pliu 20180915
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

library(devtools)
suppressMessages(library(rtracklayer))

main <- function() {
    prm = list(
        pram_repo = 'pliu55/pram',

        human_genome_version = 'hg38',
        mouse_genome_version = 'mm10',

        cufflinks_url = 'http://cole-trapnell-lab.github.io/cufflinks/assets/downloads/cufflinks-2.2.1.Linux_x86_64.tar.gz',

        stringtie_url = 'http://ccb.jhu.edu/software/stringtie/dl/stringtie-1.3.3b.Linux_x86_64.tar.gz',

        taco_url = 'https://github.com/tacorna/taco/releases/download/v0.7.0/taco-v0.7.0.Linux_x86_64.tar.gz',

        hg_gnc_url = 'ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_24/gencode.v24.annotation.gtf.gz',

        mm_gnc_url = 'ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_mouse/release_M9/gencode.vM9.annotation.gtf.gz',

        outdir = 'output/'
    )

    if ( ! file.exists(prm$outdir) ) dir.create(prm$outdir, recursive=T)

    ## install PRAM from GitHub
  # devtools:install_github(prm$repo)

    ## download external software
  # downloadSoftware(prm)

  # ## download GENCODE
  # downloadGENCODE(prm)

#   ## download genomes
#   downloadGemoces(prm)
}


downloadGENCODE <- function(prm) {
    setwd(prm$outdir)

    cat("setup human GENCODE GTF\n")
    downloadAndExtractExon(prm$hg_gnc_url, prm$outdir)

    cat("setup mouse GENCODE GTF\n")
    downloadAndExtractExon(prm$mm_gnc_url, prm$outdir)
}


downloadSoftware <- function(prm) {
    setwd(prm$outdir)

    ## download Cufflinks suite
    cat("setup Cufflinks\n")
    downloadAndUntar(prm$cufflinks_url, prm$outdir)

    ## download StringTie suite
    cat("setup StringTie\n")
    downloadAndUntar(prm$stringtie_url, prm$outdir)

    ## donwload TACO
    cat("setup TACO\n")
    downloadAndUntar(prm$taco_url, prm$outdir)
}


downloadAndUntar <- function(url, dldir) {
    ftgz = basename(url)
    if ( ! file.exists(ftgz) ) {
        download.file(url, destfile = ftgz, quiet=F)
    } else {
        cat('Will use existing file:', ftgz, "\n")
    }

    untar(ftgz)
}


downloadAndExtractExon <- function(url, outdir) {
    fgz = basename(url)
    if ( ! file.exists(fgz) ) {
        download.file(url, destfile=fgz, quiet=F)
    } else {
        cat('Will use existing file:', fgz, "\n")
    }

    fout = gsub('.gtf.gz', '.exon.gtf', fgz, fixed=T)
    if ( ! file.exists(fout) ) {
        export( readGFF( fgz,
                         tags   = c('gene_id'),
                         filter = list(type=c('exon')) ),
                fout,
                format = 'GTF' )
        cat('File written:', fout, "\n")
    } else {
        cat('Will use existing file:', fout, "\n")
    }
}

system.time( main() )
