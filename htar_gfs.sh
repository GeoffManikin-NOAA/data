#!/bin/ksh
#BSUB -J ec_htar
#BSUB -o ec_htar.%J.out
#BSUB -e ec_htar.%J.out
#BSUB -n 1
#BSUB -W 01:00
#BSUB -P HRRR-T2O
#BSUB -q dev_transfer
#BSUB -R "rusage[mem=1000]"
#BSUB -R "affinity[core]"

source ~/.bashrc

#==============================================  GATHER INFO   ================================================

validymdh=2022091512
gfshours="00 12 24 36 48 60 72 84 96 108 120 132 144 156 168"
gfshours="48"

RETRO_DIR="/lfs/h2/emc/ptmp/geoffrey.manikin/bufr"
cd $RETRO_DIR
DAPATH="/lfs/h2/emc/ptmp/geoffrey.manikin/gfs"

#========================================  GET GFS GEMPAK FILES  ==============================================
for hh in $gfshours; do

dattim="`/lfs/h2/emc/vpppg/save/geoffrey.manikin/meg/advtime ${validymdh} -$hh -1`"
echo $dattim
mdlymdh=`echo $dattim | cut -c1-10`
mdlymd=`echo $dattim | cut -c1-8`
mdlcyc=`echo $dattim | cut -c9-10`
mdlyyyy=`echo $dattim | cut -c1-4`
mdlyyyymm=`echo $dattim | cut -c1-6`


if [ $mdlymd -lt 20200227 ]
then
 GFSTAR=gpfs_dell1_nco_ops_com_gfs_prod
elif [ $mdlymd -lt 20220627 ]
then
 GFSTAR=com_gfs_prod
else
 GFSTAR=com_gfs_v16.2
fi

GFS_ARCHIVE=/NCEPPROD/hpssprod/runhistory/rh${mdlyyyy}/${mdlyyyymm}/${mdlymd}/${GFSTAR}_gfs.${mdlymd}_${mdlcyc}.gfs.tar
echo $GFS_ARCHIVE
htar -xvf $GFS_ARCHIVE ./gfs.${mdlymd}/${mdlcyc}/atmos/gempak/gfs_${mdlymd}${mdlcyc}.snd
cd gfs.${mdlymd}/${mdlcyc}/atmos/gempak
mv gfs_${mdlymd}${mdlcyc}.snd ${DAPATH}/.
done
exit
