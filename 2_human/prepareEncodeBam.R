#!/usr/bin/nohup Rscript

#
#  pliu 20180917
#
#  download human ENCODE BAM and then index
#
#  30 x 2.1 GHz, ~3 hrs
#  ~ 500G
#

suppressMessages(library(Rsamtools))
library(parallel)

main <- function() {
    prm = list(
        njob_in_para = 30,

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

        enc_url = 'https://www.encodeproject.org/files/',
        bamdir  = 'input/'
    )

    if ( ! file.exists(prm$bamdir) ) dir.create(prm$bamdir, recursive=T)
    setwd(prm$bamdir)

    ## download input Bam
    mclapply(prm$bamids, dlBamAndIndex, prm, mc.cores=prm$njob_in_para)
}


dlBamAndIndex <- function(bamid, prm) {
    fbam_remote = paste0(prm$enc_url, bamid, '/@@download/', bamid, '.bam')
    fbam_local = paste0(bamid, '.bam')
    fbai_local = paste0(bamid, '.bam.bai')

    if ( ! file.exists( fbam_local ) ) {
        download.file(fbam_remote, destfile=fbam_local, quiet=F)
    } else {
        cat('use existing file:', fbam_local, "\n")
    }

    if ( ! file.exists( fbai_local ) ) {
        indexBam(fbam_local)
    } else {
        cat('use existing file:', fbai_local, "\n")
    }
}

system.time( main() )
