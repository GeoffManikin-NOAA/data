#!/bin/sh

#==========  BEGIN CHANGES  ================================================

currentymdh=`cut -c 7-16 /lfs/h1/ops/prod/com/date/t00z`
#currentymdh=2023052900
echo $currentymdh

TMP=/lfs/h2/emc/stmp/geoffrey.manikin
mkdir $TMP

ymdh="`/lfs/h2/emc/vpppg/save/geoffrey.manikin/meteograms.nam/advtime ${currentymdh} -72 -1`"
ymd=`echo $ymdh | cut -c1-8`
echo $ymd
day=`echo $ymdh | cut -c7-8`

EMC_DATA=/lfs/h2/emc/vpppg/noscrub/geoffrey.manikin/validation_data
DCOM_DATA=/lfs/h1/ops/dev/dcom/${ymd}/validation_data

# AQ
cp ${DCOM_DATA}/aq/aeronet/* ${EMC_DATA}/aq/aeronet/.
cp ${DCOM_DATA}/aq/omi/* ${EMC_DATA}/aq/omi/.

mkdir ${TMP}/geos5
rm ${TMP}/geos5/*
cp ${DCOM_DATA}/aq/geos5/* ${TMP}/geos5
cd ${TMP}/geos5
tar -cvf geos5_${ymd}.tar *
cp *tar ${EMC_DATA}/aq/geos5/.

mkdir ${TMP}/icap
rm ${TMP}/icap/*
cp ${DCOM_DATA}/aq/icap/* ${TMP}/icap
cd ${TMP}/icap
tar -cvf icap_${ymd}.tar *
cp *tar ${EMC_DATA}/aq/icap/.

mkdir ${TMP}/viirs
rm ${TMP}/viirs/*
cp ${DCOM_DATA}/aq/viirs/*GEFS* ${TMP}/viirs
cd ${TMP}/viirs
tar -cvf viirs_${ymd}.tar *
cp *tar ${EMC_DATA}/aq/viirs/.

# CoCoRaHS
cp ${DCOM_DATA}/CoCoRaHS/* ${EMC_DATA}/CoCoRaHS/.

# LandSfc
cp ${DCOM_DATA}/landsfc/alexi/* ${EMC_DATA}/landsfc/alexi/.
cp ${DCOM_DATA}/landsfc/olr/*daily*latest* ${EMC_DATA}/landsfc/olr/.

# Marine 
cp ${DCOM_DATA}/marine/argo/atlantic_ocean/* ${EMC_DATA}/marine/argo/${ymd}_atlantic_prof.nc
cp ${DCOM_DATA}/marine/argo/pacific_ocean/* ${EMC_DATA}/marine/argo/${ymd}_pacific_prof.nc
cp ${DCOM_DATA}/marine/argo/indian_ocean/* ${EMC_DATA}/marine/argo/${ymd}_indian_prof.nc
cp ${DCOM_DATA}/marine/cmems/ssh/* ${EMC_DATA}/marine/cmems/.
cp ${DCOM_DATA}/marine/cmems/sst/* ${EMC_DATA}/marine/cmems/.
cp ${DCOM_DATA}/marine/ghrsst/* ${EMC_DATA}/marine/ghrsst/.
cp ${DCOM_DATA}/marine/smap/* ${EMC_DATA}/marine/smap/.
cp ${DCOM_DATA}/marine/smos/* ${EMC_DATA}/marine/smos/.

mkdir ${TMP}/buoy
rm ${TMP}/buoy/*
cp ${DCOM_DATA}/marine/buoy/* ${TMP}/buoy
cd ${TMP}/buoy
tar -cvf buoy_${ymd}.tar *
cp *tar ${EMC_DATA}/marine/buoy/.

# Sea Ice
mkdir ${TMP}/osisaf
rm ${TMP}/osisaf/*
cp ${DCOM_DATA}/seaice/osisaf/* ${TMP}/osisaf
cd ${TMP}/osisaf
tar -cvf osisaf_${ymd}.tar *
cp *tar ${EMC_DATA}/seaice/osisaf/.

exit
