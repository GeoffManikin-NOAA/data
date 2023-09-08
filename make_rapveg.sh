
set -x
fhr=21
cycle=t09z
module load wgrib2/2.0.7

# 32 km
export grid_specs_221="lambert:253:50.000000 214.500000:349:32463.000000 1.000000:277:32463.000000"
grid=221
eval grid_specs=\${grid_specs_${grid}}

wgrib2 -inv tmp.inv rap.${cycle}.wrfprsf${fhr}.grib2 
grep < tmp.inv "`cat rapveg_parmlist_221.txt`" | wgrib2 -i rap.${cycle}.wrfprsf${fhr}.grib2 -grib tmp.grib2

${WGRIB2} tmp.grib2 -set_bitmap 1 -set_grib_type jpeg -new_grid ${grid_specs} tmp_${grid}.grib2
