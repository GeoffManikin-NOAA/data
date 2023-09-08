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
RETRO_DIR=/lfs/h2/emc/stmp/geoffrey.manikin/getgrib2_hireswops
mkdir -p $RETRO_DIR
mkdir /lfs/h2/emc/ptmp/geoffrey.manikin/hiresw

cd $RETRO_DIR

if [ $ymd -lt 20200227 ] 
then
 HIRESWTAR=gpfs_dell1_nco_ops_com_nam_prod
elif [ $ymd -gt 20220626 ]
then 
 HIRESWTAR=com_hiresw_v8.1	 
else
 HIRESWTAR=com_hiresw_prod
fi

#====  GET HIRESW  FORECASTS  ==============================================

hours="09 12 15 24"
hours="12 18 24"
hours="00 03 06 09 12 15 18 21 24 27 30"
for fhr in $hours; do

HIRESW_ARCHIVE1=/NCEPPROD/hpssprod/runhistory/2year/rh${yyyy}/${ym}/${ymd}/${HIRESWTAR}_hiresw.${ymdh}.5km.tar 
echo $HIRESW_ARCHIVE1
htar -xvf $HIRESW_ARCHIVE1 ./hiresw.t${cyc}z.arw_5km.f${fhr}.conus.grib2
htar -xvf $HIRESW_ARCHIVE1 ./hiresw.t${cyc}z.arw_5km.f${fhr}.conusmem2.grib2
htar -xvf $HIRESW_ARCHIVE1 ./hiresw.t${cyc}z.fv3_5km.f${fhr}.conus.grib2

    nagrib2 << EOF
 GBFILE   = hiresw.t${cyc}z.arw_5km.f${fhr}.conus.grib2 
 GDOUTF   = arw_${ymdh}f0${fhr}
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

 GBFILE   = hiresw.t${cyc}z.arw_5km.f${fhr}.conusmem2.grib2
 GDOUTF   = arw2_${ymdh}f0${fhr}
 r

 GBFILE   = hiresw.t${cyc}z.fv3_5km.f${fhr}.conus.grib2
 GDOUTF   = fv3_${ymdh}f0${fhr}
 r

 ex
EOF
 
mv *f0${fhr} /lfs/h2/emc/vpppg/noscrub/geoffrey.manikin/dews/.
done
exit
