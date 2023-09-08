#!/bin/sh
#BSUB -J fcst_htar
#BSUB -o fcst_htar.%J.out
#BSUB -e fcst_htar.%J.out
#BSUB -n 1
#BSUB -W 02:30
#BSUB -P RAP-T2O
#BSUB -q dev_transfer
#BSUB -R "rusage[mem=1000]"
#BSUB -R "affinity[core]"


#==============================================  BEGIN CHANGES  ================================================

ymd=20230131
yyyy=`echo $ymd | cut -c1-4`
ym=`echo $ymd | cut -c1-6`
cyc=`echo $ymdh | cut -c9-10`
RETRO_DIR=/lfs/h2/emc/stmp/$USER/getgrib2_ops
mkdir -p $RETRO_DIR
mkdir /lfs/h2/emc/ptmp/geoffrey.manikin/obs

cd $RETRO_DIR
OBSTAR=dcom

#===================================
OBS_ARCHIVE1=/NCEPPROD/hpssprod/runhistory/rh${yyyy}/${ym}/${ymd}/${OBSTAR}_ldmdata_obs.tar 
echo $OBS_ARCHIVE1
htar -xvf $GFS_ARCHIVE1 ./gempak/uair/${ymd}.snd
exit
