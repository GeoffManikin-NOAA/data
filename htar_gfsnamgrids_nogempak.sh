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

ymdh=2023031500
ymd=`echo $ymdh | cut -c1-8`
yyyy=`echo $ymd | cut -c1-4`
ym=`echo $ymd | cut -c1-6`
cyc=`echo $ymdh | cut -c9-10`
RETRO_DIR=/lfs/h2/emc/stmp/geoffrey.manikin/getgrib2
mkdir -p $RETRO_DIR

cd $RETRO_DIR

if [ $ymd -lt 20200227 ] 
then
 GFSTAR=gpfs_dell1_nco_ops_com_gfs_prod
elif [ $ymd -gt 20221206 ]
then 
 GFSTAR=com_gfs_v16.3	
elif [ $ymd -gt 20220626 ]
then
 GFSTAR=com_gfs_v16.2
else
 GFSTAR=com_gfs_prod
fi

if [ $mdlymd -lt 20200227 ]
then
 NAMTAR=gpfs_dell1_nco_ops_com_nam_prod
elif [ $mdlymd -lt 20220627 ]
then
  NAMTAR=com_nam_prod
else
  NAMTAR=com_nam_v4.2
fi

if [ $mdlymd -lt 20200227 ]
then
  RAPTAR=lfs_dell1_nco_ops_com_rap_prod
elif [ $mdlymd -lt 20220627 ]
then
  RAPTAR=com_rap_prod
else
  RAPTAR=com_rap_v5.1
fi

hours="09 12 15 24"
hours="12 18 24"
hours="24 48 72 96"
hours="21"

#================ GET GFS FORECASTS ====================================
for fhr in $hours; do

GFS_ARCHIVE1=/NCEPPROD/hpssprod/runhistory/rh${yyyy}/${ym}/${ymd}/${GFSTAR}_gfs.${ymd}_${cyc}.gfs_pgrb2.tar 
echo $GFS_ARCHIVE1
htar -xvf $GFS_ARCHIVE1 ./gfs.${ymd}/${cyc}/atmos/gfs.t${cyc}z.pgrb2.0p25.f0${fhr}
pwd
cd gfs.${ymd}/${cyc}/atmos
pwd
ls

mv gfs.t${cyc}z.pgrb2.0p25.f0${fhr} /lfs/h2/emc/vpppg/noscrub/geoffrey.manikin/dews/.
done

#=================== GET NAM FORECASTS =============================

for fhr in $hours; do

NAM_ARCHIVE1=/NCEPPROD/hpssprod/runhistory/rh${yyyy}/${ym}/${ymd}/${NAMTAR}_nam.${ymdh}.awip32.tar
echo $NAM_ARCHIVE1
htar -xvf $NAM_ARCHIVE1 ./nam.t${cyc}z.awip32${fhr}.tm00.grib2

mv nam*awip32*  /lfs/h2/emc/vpppg/noscrub/geoffrey.manikin/dews/.
done

#=================== GET RAP FORECASTS =============================

for fhr in $hours; do

if [[ ${mdlcyc} < 06 ]] ; then
     ff1=00
     ff2=05
elif [[ ${mdlcyc} < 12 ]] ; then
    ff1=06
    ff2=11
elif [[ ${mdlcyc} < 18 ]] ; then
   ff1=12
   ff2=17
else
   ff1=18
   ff2=23
fi

RAP_ARCHIVE1=/NCEPPROD/hpssprod/runhistory/2year/rh${yyyy}/${ym}/${ymd}/${RAPTAR}_rap.${ymd}${ff1}-${ff2}.awip32.tar
echo $RAP_ARCHIVE1
htar -xvf $RAP_ARCHIVE1 ./rap.t${cyc}z.awip32f${fhr}.grib2

mv rap* /lfs/h2/emc/vpppg/noscrub/geoffrey.manikin/dews/.
done

exit
