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
            'ENCFF044SJL', 'ENCFF048ODN', 'ENCFF125RAL', 'ENCFF207ZSA',
            'ENCFF244ZQA', 'ENCFF263OLY', 'ENCFF306YQS', 'ENCFF315VHI',
            'ENCFF343WEZ', 'ENCFF367VEP', 'ENCFF381BQZ', 'ENCFF428VBU',
            'ENCFF444SCT', 'ENCFF521KYZ', 'ENCFF547YFO', 'ENCFF588YLF',
            'ENCFF709IUX', 'ENCFF728JKQ', 'ENCFF739OVZ', 'ENCFF782IVX',
            'ENCFF782TAX', 'ENCFF800YJR', 'ENCFF802TLC', 'ENCFF834ITU',
            'ENCFF838JGD', 'ENCFF846WOV', 'ENCFF904OHO', 'ENCFF912SZP',
            'ENCFF978ACT', 'ENCFF983FHE'
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
