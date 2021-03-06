
; Description: create atmospheric forcing field 
;
;      Author: OU Yuyuan <ouyuyuan@lasg.iap.ac.cn>
;     Created: 2014-07-23 08:28:47 BJT
; Last Change: 2014-09-09 10:16:40 BJT

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/ou/archive/scripts/utils/ncl.ncl"

begin

  ncgen = True

  nc_cfsr = "/media/DAT_OCN/HYCOM/force/ncep_cfsr/netcdf/cfsr-sea_2006_01hr_TaqaQrQp.nc"
  out_dir = "/home/ou/archive/models/roms/roms_734/Apps/scs/in/"
  nc_grid = out_dir + "seagrid.nc"
  nc_out = out_dir + "frc_lwrad.nc"
  cdl = "frc_lwrad.cdl"

  Llon=100.0 ; Left   corner longitude
  Rlon=125.0 ; Right  corner longitude
  Blat=-5.0  ; Bottom corner latitude
  Tlat=30.0  ; Top    corner latitude

  f = addfile(nc_grid, "r")
  lat2d = f->lat_rho
  lon2d = f->lon_rho
  delete(f)

  date_b = "2006-04-05 00:00:00"
  date_e = "2006-04-16 00:00:00"

  f = addfile( nc_cfsr, "r")
  lat = f->Latitude({Blat:Tlat})
  lon = f->Longitude({Llon:Rlon})
  t_cfsr = f->MT(:)

  tsta = ou_string2ti(date_b, t_cfsr)
  tend = ou_string2ti(date_e, t_cfsr)
  tmp = f->radflx(tsta:tend, {Blat:Tlat},{Llon:Rlon})
  tmp2 = f->shwflx(tsta:tend,{Blat:Tlat},{Llon:Rlon})
  delete(f)

  var_cfsr = new(dimsizes(tmp), double)
  var_cfsr = tmp*tmp@scale_factor + tmp@add_offset - \
             (tmp2*tmp2@scale_factor + tmp2@add_offset)
;  var_cfsr = tmp*tmp@scale_factor + tmp@add_offset
  delete(tmp)
  delete(tmp2)

  if (ncgen) then
    cmd = "ncgen -o " + nc_out + " " + cdl
    print(cmd+"")
    system(cmd)
  end if

  f = addfile( nc_out, "r")
  tunits = f->time@units
  delete(f)
  t_roms = cd_convert( t_cfsr, tunits )

  f = addfile( nc_out, "w")
  f->time@begin_date = date_b
  f->time@end_date = date_e
  f@source = "create by " + systemfunc("pwd") + "/" + getenv("NCL_ARG_0") + \
  ", " + systemfunc("date")

;  print( "Interpolate to roms grid ..." )
  lon = where( lon.gt.180.0, lon-360.0, lon )
  v_roms = rgrid2rcm( lat, lon, var_cfsr, lat2d, lon2d, 0)
  f->lwrad = (/v_roms/)
  f->time = (/t_roms(tsta:tend)/)
end
