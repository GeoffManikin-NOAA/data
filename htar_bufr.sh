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

DAY=20220504
hours="00 12"
hrrrhours="00 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21"
namhours="00 06 12 18"
hireswhours="00 12"
namhours=""
hireswhours=""
gfshours="00 06 12 18"

RETRO_DIR="/gpfs/dell1/ptmp/Geoffrey.Manikin/bufr"
DAPATH=/gpfs/dell2/emc/verification/noscrub/Geoffrey.Manikin/may22svr
mkdir -p $RETRO_DIR
cd $RETRO_DIR
cp /gpfs/dell2/emc/verification/save/Geoffrey.Manikin/gempak/s*rap* .
cp /gpfs/dell2/emc/verification/save/Geoffrey.Manikin/gempak/s*nam* .

yyyy=`echo $DAY | cut -c 1-4`
yyyymm=`echo $DAY | cut -c 1-6`
yyyymmdd=`echo $DAY | cut -c 1-8`
mm=`echo $DAY | cut -c 5-6`
dd=`echo $DAY | cut -c 7-8`

for hh in $hrrrhours; do

 if [[ ${hh} < 06 ]] ; then 
     ff1=00
     ff2=05
 elif [[ ${hh} < 12 ]] ; then
     ff1=06
     ff2=11
 elif [[ ${hh} < 18 ]] ; then
     ff1=12
     ff2=17
 else
     ff1=18
     ff2=23
 fi

#===============================================  GET HRRR FILE  =================================================

 HRRR_ARCHIVE=/NCEPPROD/hpssprod/runhistory/rh${yyyy}/${yyyymm}/${yyyymmdd}/com_hrrr_prod_hrrr.${yyyymmdd}_conus${ff1}-${ff2}.bufr.tar
 echo $HRRR_ARCHIVE

      htar -xvf $HRRR_ARCHIVE ./hrrr.t${hh}z.class1.bufr.tm00
      echo "Extracting "${DAY}" HRRR bufr file"


#================================================ UNPACK HRRR FILE =====================================================

    namsnd << EOF
 SNBUFR   = hrrr.t${hh}z.class1.bufr.tm00
 SNOUTF   = hrrr_${DAY}${hh}.snd 
 SFOUTF   = hrrr_${DAY}${hh}.sfc+ 
 SNPRMF   = snrap.prm 
 SFPRMF   = sfrap.prm 
 TIMSTN   = 49/1500 
r

ex
EOF
done
mv hrrr*snd ${DAPATH}/hrrr.${DAY}/.
mv hrrr*sfc* ${DAPATH}/hrrr.${DAY}/.

for hh in $namhours; do

#===============================================  GET NAM NEST FILE  =================================================

 NAM_ARCHIVE=/NCEPPROD/hpssprod/runhistory/rh${yyyy}/${yyyymm}/${yyyymmdd}/com_nam_prod_nam.${yyyymmdd}${hh}.bufr.tar
 echo $NAM_ARCHIVE

      htar -xvf $NAM_ARCHIVE ./nam.t${hh}z.class1.bufr_conusnest.tm00
      echo "Extracting "${DAY}" NAM bufr file"


#================================================ UNPACK NAM NEST FILE =====================================================

    namsnd << EOF
 SNBUFR   = nam.t${hh}z.class1.bufr_conusnest.tm00
 SNOUTF   = nam_conusnest_${DAY}${hh}.snd 
 SFOUTF   = nam_conusnest_${DAY}${hh}.sfc+ 
 SNPRMF   = snnam.prm 
 SFPRMF   = sfnam.prm 
 TIMSTN   = 61/1500 
r

ex
EOF
done
mv nam*snd ${DAPATH}/nam.${DAY}/.
mv nam*sfc* ${DAPATH}/nam.${DAY}/.

for hh in $hireswhours; do

#===============================================  GET HIRESW FILES  =================================================

 HIRESW_ARCHIVE=/NCEPPROD/hpssprod/runhistory/2year/rh${yyyy}/${yyyymm}/${yyyymmdd}/com_hiresw_prod_hiresw.${yyyymmdd}${hh}.bufr.tar
 echo $HIRESW_ARCHIVE

      htar -xvf $HIRESW_ARCHIVE ./hiresw.t${hh}z.conusarw.class1.bufr
      echo "Extracting "${DAY}" "${hh}Z" ARW bufr file"
      
      htar -xvf $HIRESW_ARCHIVE ./hiresw.t${hh}z.conusmem2arw.class1.bufr
      echo "Extracting "${DAY}" "${hh}Z" ARW2 bufr file"  

      htar -xvf $HIRESW_ARCHIVE ./hiresw.t${hh}z.conusfv3.class1.bufr
      echo "Extracting "${DAY}" "${hh}Z" FV3 bufr file"

#================================================ UNPACK HIRESW FILES =====================================================

    namsnd << EOF
 SNBUFR   = hiresw.t${hh}z.conusarw.class1.bufr
 SNOUTF   = hiresw_conusarw_${DAY}${hh}.snd 
 SFOUTF   = hiresw_conusarw_${DAY}${hh}.sfc+ 
 SNPRMF   = snnam.prm 
 SFPRMF   = sfnam.prm 
 TIMSTN   = 49/1500 
r

 SNBUFR   = hiresw.t${hh}z.conusmem2arw.class1.bufr
 SNOUTF   = hiresw_conusmem2arw_${DAY}${hh}.snd 
 SFOUTF   = hiresw_conusmem2arw_${DAY}${hh}.sfc+ 
r

 SNBUFR   = hiresw.t${hh}z.conusfv3.class1.bufr
 SNOUTF   = hiresw_conusfv3_${DAY}${hh}.snd 
 SFOUTF   = hiresw_conusfv3_${DAY}${hh}.sfc+ 
r

ex
EOF
done
mv hiresw*snd ${DAPATH}/hiresw.${DAY}/.
mv hiresw*sfc* ${DAPATH}/hiresw.${DAY}/.

if [ $yyyymmdd -lt 20200227 ]
then
 GFSTAR=gpfs_dell1_nco_ops_com_gfs_prod
else
 GFSTAR=com_gfs_prod
fi

#========================================  GET GFS GEMPAK FILES  ==============================================
for hh in $gfshours; do
GFS_ARCHIVE=/NCEPPROD/hpssprod/runhistory/rh${yyyy}/${yyyymm}/${yyyymmdd}/${GFSTAR}_gfs.${yyyymmdd}_${hh}.gfs.tar
echo $GFS_ARCHIVE
htar -xvf $GFS_ARCHIVE ./gfs.${yyyymmdd}/${hh}/atmos/gempak/gfs_${yyyymmdd}${hh}.snd
cd gfs.${yyyymmdd}/${hh}/atmos/gempak
mv gfs_${yyyymmdd}${hh}.snd ${DAPATH}/gfs.${DAY}/.
done
exit
