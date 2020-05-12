% Variant Quality Score Recalibration (VQSR) 
% Timo Lassmann
% Today

# Introduction

The GATK variant qiuality score recallibration pipeline in bpipe. 


# CODE

## File: gatk_recal.groovy

~~~~{.java} 

about title: "GATK VQSR pipeline."

load "localprograms.groovy"
load "localdatafiles.groovy"
load "../modules/gatk_base_recalibration.groovy"

def BASEROOTDIR="BASEDIRNAME"

TARGETREGIONS="$BASEROOTDIR" +"/misc/S04380110_Regions.bed"



Bpipe.run {recalibrate_SNP + Apply_SNP_Recalibration + recalibrate_INDEL + Apply_INDEL_Recalibration}



~~~~


