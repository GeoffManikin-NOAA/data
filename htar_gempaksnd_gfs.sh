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

ymdh=2022022412
ymd=`echo $ymdh | cut -c1-8`
yyyy=`echo $ymd | cut -c1-4`
ym=`echo $ymd | cut -c1-6`
cyc=`echo $ymdh | cut -c9-10`
RETRO_DIR=/gpfs/dell1/stmp/$USER/getgrib2_ops
mkdir -p $RETRO_DIR
mkdir /gpfs/dell1/ptmp/Geoffrey.Manikin/gfs

cd $RETRO_DIR

if [ $ymd -lt 20200227 ] 
then
 GFSTAR=gpfs_dell1_nco_ops_com_gfs_prod
else
 GFSTAR=com_gfs_prod
fi

#========================================  GET GFSGFS PHYSICS TEST FORECASTS  ==============================================

GFS_ARCHIVE1=/NCEPPROD/hpssprod/runhistory/rh${yyyy}/${ym}/${ymd}/${GFSTAR}_gfs.${ymd}_${cyc}.gfs.tar 
echo $GFS_ARCHIVE1
htar -xvf $GFS_ARCHIVE1 ./gfs.${ymd}/${cyc}/atmos/gempak/gfs_${ymdh}.snd
cd gfs.${ymd}/${cyc}/atmos/gempak
mv gfs_${ymdh}.snd /gpfs/dell1/ptmp/Geoffrey.Manikin/gfs/gfs.${ymd}
exit
