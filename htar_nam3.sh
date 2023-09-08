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

ymdh=2023061512
ymd=`echo $ymdh | cut -c1-8`
yyyy=`echo $ymd | cut -c1-4`
ym=`echo $ymd | cut -c1-6`
cyc=`echo $ymdh | cut -c9-10`
RETRO_DIR=/lfs/h2/emc/stmp/geoffrey.manikin/getgrib2_nam3ops
mkdir -p $RETRO_DIR
mkdir /lfs/h2/emc/ptmp/geoffrey.manikin/nam3

cd $RETRO_DIR

if [ $ymd -lt 20200227 ] 
then
 NAMNESTTAR=gpfs_dell1_nco_ops_com_nam_prod
elif [ $ymd -gt 20220626 ]
then 
 NAMNESTTAR=com_nam_v4.2	 
else
 NAMNESTTAR=com_nam_prod
fi

#====  GET NAMNEST  FORECASTS  ==============================================

hours="09 12 15 24"
hours="12 18 24"
hours="03 06 09 12 15 18 21 24 27 30 33 36 39 42 45 48 51 54 57 60"
hours="00 03 06 09 12 15 18 21 24 27 30"
hours="06 07 08 09 10 11 12 13 14 15"
for fhr in $hours; do

NAMNEST_ARCHIVE1=/NCEPPROD/hpssprod/runhistory/2year/rh${yyyy}/${ym}/${ymd}/${NAMNESTTAR}_nam.${ymdh}.conusnest.tar 
echo $NAMNEST_ARCHIVE1
htar -xvf $NAMNEST_ARCHIVE1 ./nam.t${cyc}z.conusnest.hiresf${fhr}.tm00.grib2

    nagrib2 << EOF
 GBFILE   = nam.t${cyc}z.conusnest.hiresf${fhr}.tm00.grib2 
 GDOUTF   = nam_conusnest_${ymdh}f0${fhr}
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

#mv nam_conusnest_${ymdh}f0${fhr} /lfs/h2/emc/vpppg/noscrub/geoffrey.manikin/dews/.
#mv nam.t${cyc}z.conusnest.hiresf${fhr}.tm00.grib2 /lfs/h2/emc/vpppg/noscrub/geoffrey.manikin/ian/.
mv nam.t${cyc}z.conusnest.hiresf${fhr}.tm00.grib2 /lfs/h2/emc/geoffrey.manikin/pete/.
done
exit
