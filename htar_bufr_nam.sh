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

validymdh=2023031600
namhours="00 12 24 36 48 60 72 84"
namhours="00 12 24 36 48 60"
namhours="00 06 12 15 18 21 24 27 30"

RETRO_DIR="/gpfs/dell1/ptmp/Geoffrey.Manikin/getnam"
cd $RETRO_DIR
cp /gpfs/dell2/emc/verification/save/Geoffrey.Manikin/gempak/s*nam* .

DAPATH="/gpfs/dell1/ptmp/Geoffrey.Manikin/bufr3"
mkdir $DAPATH

#========================================  GET NAM BUFR FILES  ==============================================
for hh in $namhours; do

dattim="`/gpfs/dell2/emc/verification/save/Geoffrey.Manikin/meg/advtime ${validymdh} -$hh -1`"
echo $dattim
mdlymdh=`echo $dattim | cut -c1-10`
mdlymd=`echo $dattim | cut -c1-8`
mdlcyc=`echo $dattim | cut -c9-10`
mdlyyyy=`echo $dattim | cut -c1-4`
mdlyyyymm=`echo $dattim | cut -c1-6`

if [ $mdlymd -lt 20200227 ]
then
 NAMTAR=gpfs_dell1_nco_ops_com_nam_prod
elif [ $mdlymd -lt 20220627 ]
then
 NAMTAR=com_nam_prod
else
 NAMTAR=com_nam_v4.2
fi

NAM_ARCHIVE=/NCEPPROD/hpssprod/runhistory/rh${mdlyyyy}/${mdlyyyymm}/${mdlymd}/${NAMTAR}_nam.${mdlymdh}.bufr.tar
echo $NAM_ARCHIVE
htar -xvf $NAM_ARCHIVE ./nam.t${mdlcyc}z.class1.bufr.tm00
htar -xvf $NAM_ARCHIVE ./nam.t${mdlcyc}z.class1.bufr_conusnest.tm00

#================== UNPACK NAM NEST FILE ====================================

    namsnd << EOF
 SNBUFR   = nam.t${mdlcyc}z.class1.bufr.tm00
 SNOUTF   = nam_${mdlymdh}.snd 
 SFOUTF   = nam_${mdlymdh}.sfc+ 
 SNPRMF   = snnam.prm 
 SFPRMF   = sfnam.prm 
 TIMSTN   = 85/1800 
r

 SNBUFR   = nam.t${mdlcyc}z.class1.bufr_conusnest.tm00
 SNOUTF   = nam_conusnest_${mdlymdh}.snd 
 SFOUTF   = nam_conusnest_${mdlymdh}.sfc+
 TIMSTN   = 61/1500
r

ex
EOF
done
mv nam*snd* ${DAPATH}/.
mv nam*sfc* ${DAPATH}/.
exit
