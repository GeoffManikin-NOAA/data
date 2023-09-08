#!/bin/sh
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

#===========  GATHER INFO   ================================================

RETRO_DIR="/lfs/h2/emc/ptmp/geoffrey.manikin/bufr"
cd $RETRO_DIR
cp /lfs/h2/emc/vpppg/save/geoffrey.manikin/gempak/s*rap* .

DAPATH="/lfs/h2/emc/vpppg/noscrub/geoffrey.manikin/dews"
mkdir $DAPATH

#====================================  GET RAP BUFR FILES  ============

mdlymdh=2023031509
mdlymd=`echo $mdlymdh | cut -c1-8`
mdlcyc=`echo $mdlymdh | cut -c9-10`
mdlyyyy=`echo $mdlymdh | cut -c1-4`
mdlyyyymm=`echo $mdlymdh | cut -c1-6`

if [ $mdlymd -lt 20200227 ]
then
 RAPTAR=lfs_dell1_nco_ops_com_rap_prod
elif [ $mdlymd -lt 20220627 ]
then
 RAPTAR=com_rap_prod
else
 RAPTAR=com_rap_v5.1
fi

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

RAP_ARCHIVE=/NCEPPROD/hpssprod/runhistory/rh${mdlyyyy}/${mdlyyyymm}/${mdlymd}/${RAPTAR}_rap.${mdlymd}${ff1}-${ff2}.bufr.tar
echo $RAP_ARCHIVE
htar -xvf $RAP_ARCHIVE ./rap.t${mdlcyc}z.class1.bufr.tm00

#===================== UNPACK RAP NEST FILE ===========================

    namsnd << EOF
 SNBUFR   = rap.t${mdlcyc}z.class1.bufr.tm00
 SNOUTF   = rap_${mdlymdh}.snd 
 SFOUTF   = rap_${mdlymdh}.sfc+ 
 SNPRMF   = snrap.prm 
 SFPRMF   = sfrap.prm 
 TIMSTN   = 85/1800 
r

ex
EOF
mv rap*snd* ${DAPATH}/.
mv rap*sfc* ${DAPATH}/.
exit
