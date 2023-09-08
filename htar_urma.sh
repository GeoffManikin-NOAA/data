#!/bin/sh
#BSUB -J fcst_htar
#BSUB -o fcst_htar.%J.out
#BSUB -e fcst_htar.%J.out
#BSUB -n 1
#BSUB -W 02:30
#BSUB -P URMA-T2O
#BSUB -q dev_transfer
#BSUB -R "rusage[mem=1000]"
#BSUB -R "affinity[core]"


#==============================================  BEGIN CHANGES  ================================================

ymdh=2023031706
ymd=`echo $ymdh | cut -c1-8`
yyyy=`echo $ymd | cut -c1-4`
ym=`echo $ymd | cut -c1-6`
cyc=`echo $ymdh | cut -c9-10`
RETRO_DIR=/lfs/h2/emc/stmp/geoffrey.manikin/getgrib2_urma
mkdir -p $RETRO_DIR
cd $RETRO_DIR

if [ $ymd -lt 20200227 ] 
then
 URMATAR=gpfs_dell1_nco_ops_com_urma_prod
elif [ $ymd -lt 20230103 ]
then 
 URMATAR=com_urma_v2.9
elif [ $ymd -gt 20230103 ]
then
 URMATAR=com_urma_v2.10
else
 URMATAR=com_urma_prod
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

#====  GET URMA  ANALYSES  ==============================================

URMA_ARCHIVE1=/NCEPPROD/hpssprod/runhistory/rh${yyyy}/${ym}/${ymd}/${URMATAR}_urma2p5.${ymd}${ff1}-${ff2}.tar 
echo $URMA_ARCHIVE1
htar -xvf $URMA_ARCHIVE1 ./urma2p5.t${cyc}z.2dvaranl_ndfd.grb2_wexp

cp /lfs/h1/ops/prod/packages/urma.v2.9.2/gempak/fix/urma2p5/* .

    nagrib2 << EOF
 GBFILE   = urma2p5.t${cyc}z.2dvaranl_ndfd.grb2_wexp 
 GDOUTF   = urma2p5_${ymdh}f000
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
 
mv urma2p5_${ymdh}f000 /lfs/h2/emc/vpppg/noscrub/geoffrey.manikin/urma/.
exit
