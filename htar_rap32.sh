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

ymdh=2023031600
ymd=`echo $ymdh | cut -c1-8`
yyyy=`echo $ymd | cut -c1-4`
ym=`echo $ymd | cut -c1-6`
cyc=`echo $ymdh | cut -c9-10`
RETRO_DIR=/lfs/h2/emc/stmp/geoffrey.manikin/getgrib2_rapops
mkdir -p $RETRO_DIR
mkdir /lfs/h2/emc/ptmp/geoffrey.manikin/rap

cd $RETRO_DIR

if [ $ymd -lt 20200227 ] 
then
 RAPTAR=gpfs_dell1_nco_ops_com_rap_prod
elif [ $ymd -gt 20220626 ]
then 
 RAPTAR=com_rap_v5.1	 
else
 RAPTAR=com_rap_prod
fi

 if [[ ${cyc} < 06 ]] ; then 
     ff1=00
     ff2=05
 elif [[ ${cyc} < 12 ]] ; then
     ff1=06
     ff2=11
 elif [[ ${cyc} < 18 ]] ; then
     ff1=12
     ff2=17
 else
     ff1=18
     ff2=23
 fi

#====  GET RAP  FORECASTS  ==============================================

hours="09 12 15 24"
hours="00 06 12 15 18 21 24 27 30"
hours="24 27 30"
for fhr in $hours; do

RAP_ARCHIVE1=/NCEPPROD/hpssprod/runhistory/2year/rh${yyyy}/${ym}/${ymd}/${RAPTAR}_rap.${ymd}${ff1}-${ff2}.awip32.tar 
echo $RAP_ARCHIVE1
htar -xvf $RAP_ARCHIVE1 ./rap.t${cyc}z.awip32f${fhr}.grib2

    nagrib2 << EOF
 GBFILE   = rap.t${cyc}z.awip32f${fhr}.grib2 
 GDOUTF   = rap32_${ymdh}f0${fhr}
 PROJ     = MER
 GRDAREA  =  
 KXKY     = 10;10
 MAXGRD   = 1000 
 CPYFIL   = gds 
 GAREA    = grid 
 OUTPUT   = T
 G2TBLS   =  
 G2DIAG   =  
 OVERWR   = NO
 PDSEXT   = NO

 r
 ex
EOF
 
mv rap32_${ymdh}f0${fhr} /lfs/h2/emc/vpppg/noscrub/geoffrey.manikin/dews/.
done
exit
