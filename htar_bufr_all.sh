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

#============  GATHER INFO   ================================================

ymdh=2023031512

RETRO_DIR="/lfs/h2/emc/ptmp/geoffrey.manikin/bufr"
mkdir $RETRO_DIR
cd $RETRO_DIR
cp /lfs/h2/emc/vpppg/save/geoffrey.manikin/gempak/s*nam* .
cp /lfs/h2/emc/vpppg/save/geoffrey.manikin/gempak/s*rap* .

DAPATH="/lfs/h2/emc/vpppg/noscrub/geoffrey.manikin/dews"

mdlymdh=`echo $ymdh | cut -c1-10`
mdlymd=`echo $ymdh | cut -c1-8`
mdlcyc=`echo $ymdh | cut -c9-10`
mdlyyyy=`echo $ymdh | cut -c1-4`
mdlyyyymm=`echo $ymdh | cut -c1-6`

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
  HRRRTAR=gpfs_dell1_nco_ops_com_hrrr_prod
elif [ $mdlymd -gt 20220626 ]
then
  HRRRTAR=com_hrrr_v4.1
else
  HRRRTAR=com_hrrr_prod
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

if [ $mdlymd -lt 20200227 ]
then GFSTAR=gpfs_dell1_nco_ops_com_gfs_prod
elif [ $mdlymd -lt 20220627 ]
then
   GFSTAR=com_gfs_prod
 else
   GFSTAR=com_gfs_v16.3
fi

if [ $mdlymd -lt 20200227 ]
then RAPTAR=gpfs_dell_nco_ops_com_rap_prod
elif [ $mdlymd -lt 20220627 ]
then
  RAPTAR=com_rap_prod
else
  RAPTAR=com_rap_v5.1
fi

#### NAM and NAM NEST
NAM_ARCHIVE=/NCEPPROD/hpssprod/runhistory/rh${mdlyyyy}/${mdlyyyymm}/${mdlymd}/${NAMTAR}_nam.${mdlymdh}.bufr.tar
echo $NAM_ARCHIVE
#htar -xvf $NAM_ARCHIVE ./nam.t${mdlcyc}z.class1.bufr.tm00
#htar -xvf $NAM_ARCHIVE ./nam.t${mdlcyc}z.class1.bufr_conusnest.tm00

#    namsnd << EOF
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
#r

#ex
#EOF
mv nam*snd* ${DAPATH}/.
mv nam*sfc* ${DAPATH}/.

#### HRRR
HRRR_ARCHIVE=/NCEPPROD/hpssprod/runhistory/rh${mdlyyyy}/${mdlyyyymm}/${mdlymd}/${HRRRTAR}_hrrr.${mdlymd}_conus${ff1}-${ff2}.bufr.tar
echo $HRRR_ARCHIVE
htar -xvf $HRRR_ARCHIVE ./hrrr.t${mdlcyc}z.class1.bufr.tm00

       namsnd << EOF
 SNBUFR   = hrrr.t${mdlcyc}z.class1.bufr.tm00
 SNOUTF   = hrrr_${mdlymdh}.snd
 SFOUTF   = hrrr_${mdlymdh}.sfc+
 SNPRMF   = snrap.prm
 SFPRMF   = sfrap.prm
 TIMSTN   = 49/1800
r

ex
EOF

mv hrrr*snd ${DAPATH}/.
mv hrrr*sfc* ${DAPATH}/.

###  GFS
GFS_ARCHIVE=/NCEPPROD/hpssprod/runhistory/rh${mdlyyyy}/${mdlyyyymm}/${mdlymd}/${GFSTAR}_gfs.${mdlymd}_${mdlcyc}.gfs.tar
echo $GFS_ARCHIVE
htar -xvf $GFS_ARCHIVE ./gfs.${mdlymd}/${mdlcyc}/atmos/gempak/gfs_${mdlymd}${mdlcyc}.snd
htar -xvf $GFS_ARCHIVE ./gfs.${mdlymd}/${mdlcyc}/atmos/gempak/gfs_${mdlymd}${mdlcyc}.sfc

cd gfs.${mdlymd}/${mdlcyc}/atmos/gempak
mv gfs_${mdlymd}${mdlcyc}.snd ${DAPATH}/.
mv gfs_${mdlymd}${mdlcyc}.sfc ${DAPATH}/.

#### RAP 
RAP_ARCHIVE=/NCEPPROD/hpssprod/runhistory/rh${mdlyyyy}/${mdlyyyymm}/${mdlymd}/${RAPTAR}_rap.${mdlymd}${ff1}-${ff2}.bufr.tar
htar -xvf $HRRR_ARCHIVE ./rap.t${mdlcyc}z.class1.bufr.tm00

       namsnd << EOF
  SNBUFR   = rap.t${mdlcyc}z.class1.bufr.tm00
  SNOUTF   = rap_${mdlymdh}.snd
  SFOUTF   = rap_${mdlymdh}.sfc+
  SNPRMF   = snrap.prm
  SFPRMF   = sfrap.prm
  TIMSTN   = 52/1800
r

ex
EOF

mv rap_${mdlymd}${mdlcyc}.snd ${DAPATH}/.
mv rap_${mdlymd}${mdlcyc}.sfc ${DAPATH}/.

exit
