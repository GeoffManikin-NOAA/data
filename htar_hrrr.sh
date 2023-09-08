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

OUTDIR=pete
ymdh=2023061512
ymd=`echo $ymdh | cut -c1-8`
yyyy=`echo $ymd | cut -c1-4`
ym=`echo $ymd | cut -c1-6`
cyc=`echo $ymdh | cut -c9-10`
RETRO_DIR=/lfs/h2/emc/stmp/geoffrey.manikin/getgrib2_hrrrops4
mkdir -p $RETRO_DIR
mkdir /lfs/h2/emc/ptmp/geoffrey.manikin

cd $RETRO_DIR

if [ $ymd -lt 20200227 ] 
then
 HRRRTAR=gpfs_dell1_nco_ops_com_hrrr_prod
elif [ $ymd -gt 20220626 ]
then 
 HRRRTAR=com_hrrr_v4.1	 
else
 HRRRTAR=com_hrrr_prod
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

#====  GET HRRR  FORECASTS  ==============================================

hours="09 12 15 24"
hours="12 24 36 48"
hours="24 36 48"
hours="00 06 12 15 18 21 24 27 30"
hours="06 07 08 09 10 11 12 13 14 15"
for fhr in $hours; do

HRRR_ARCHIVE1=/NCEPPROD/hpssprod/runhistory/rh${yyyy}/${ym}/${ymd}/${HRRRTAR}_hrrr.${ymd}_conus${ff1}-${ff2}.wrf.tar 
echo $HRRR_ARCHIVE1
htar -xvf $HRRR_ARCHIVE1 ./hrrr.t${cyc}z.wrfprsf${fhr}.grib2

cp /lfs/h2/emc/vpppg/save/geoffrey.manikin/gempak/nagrib2/*tbl .

#    nagrib2 << EOF
# GBFILE   = hrrr.t${cyc}z.wrfprsf${fhr}.grib2 
# GDOUTF   = hrrr_${ymdh}f0${fhr}00
# PROJ     = MER
# GRDAREA  =  
# KXKY     = 10;10
# MAXGRD   = 1000 
# CPYFIL   = gds 
# GAREA    = grid 
# OUTPUT   = T
# G2TBLS   =  
# G2DIAG   =  
# OVERWR   = NO
# PDSEXT   = NO
#
# r
# ex
#EOF
 
#mv hrrr_${ymdh}f0${fhr}00 /lfs/h2/emc/vpppg/noscrub/geoffrey.manikin/${OUTDIR}/.
mv hrrr.t* /lfs/h2/emc/ptmp/geoffrey.manikin/${OUTDIR}/.
done
exit
