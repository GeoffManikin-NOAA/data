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

ymdh=2023062812
ymd=`echo $ymdh | cut -c1-8`
yyyy=`echo $ymd | cut -c1-4`
ym=`echo $ymd | cut -c1-6`
cyc=`echo $ymdh | cut -c9-10`
RETRO_DIR=/lfs/h2/emc/stmp/geoffrey.manikin/getgrib2_gfs
mkdir -p $RETRO_DIR
mkdir /lfs/h2/emc/ptmp/geoffrey.manikin/gfs

cd $RETRO_DIR
cp /lfs/h1/ops/prod/packages/rap.v5.1.4/gempak/parm/* .

if [ $ymd -lt 20220605 ]
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

#========================================  GET GFSGFS PHYSICS TEST FORECASTS  ==============================================

hours="09 12 15 24"
hours="12 18 24"
hours="24 48 72 96"
hours="00 06 12 18 24 30 36 42 48 54 60 66 72"
hours="00 03 06 09 12 15 18 21 24 27 30"
hours="15 27"
hours="00"
for fhr in $hours; do

GFS_ARCHIVE1=/NCEPPROD/hpssprod/runhistory/rh${yyyy}/${ym}/${ymd}/${GFSTAR}_gfs.${ymd}_${cyc}.gfs_pgrb2.tar 
echo $GFS_ARCHIVE1
htar -xvf $GFS_ARCHIVE1 ./gfs.${ymd}/${cyc}/atmos/gfs.t${cyc}z.pgrb2.0p25.f0${fhr}
pwd
cd gfs.${ymd}/${cyc}/atmos
pwd
ls

        nagrib2 << EOF
 GBFILE   = gfs.t${cyc}z.pgrb2.0p25.f0${fhr}
 GDOUTF   = gfs_0p25_${ymdh}f0${fhr}
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

mv gfs_0p25_${ymdh}f0${fhr} /lfs/h2/emc/vpppg/noscrub/geoffrey.manikin/dews/.
#mv gfs* /lfs/h2/emc/vpppg/noscrub/geoffrey.manikin/alaska/.

done
exit
