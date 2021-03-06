
; Description: 2 subplots, each is a depth-year contour plot
;
;      Author: OU Yuyuan <ouyuyuan@lasg.iap.ac.cn>
;     Created: 2014-10-24 19:56:55 BJT
; Last Change: 2015-03-16 13:28:27 BJT

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

datDir = getenv("NCL_ARG_1")
img = getenv("NCL_ARG_2")

;ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
; get data
;ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
;{{{
function get_deviation(fname, varName, cn0)
; get the value devated to the initial value of each layer
local var, f
begin
  f = addfile(fname, "r")
  cn = f->$varName$(0,0,:,:)
  delete(f)
  cn = cn - cn0

  if (varName.eq."pt")
    cn@units = "~S~o~N~C"
  end if
  if (varName.eq."sa")
    cn@units = "psu"
  end if

  return cn
end

f = addfile("/home/ou/archive/data/pcom/input/pcom_ini.nc", "r")
cn10 = f->ct(0,:,:)
cn20 = f->sa(0,:,:)
delete(f)

fname = datDir + "climate_791-800.nc"
cn1 = get_deviation(fname, "pt", cn10)
cn2 = get_deviation(fname, "sa", cn20)

;}}}


;ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
; plot model 
;ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

;  cmap = "NCL_default"
;  cmap = "GMT_jet"
;  cmap = "WhiteBlueGreenYellowRed"
cmap = "NCV_blu_red"

fontSize = 0.03
yLabelSize = fontSize*0.6
xLabelSize = fontSize*0.6
plotWid = 0.7
plotHei = 0.4
cbTitle1 = cn1@units
cbTitle2 = cn2@units
cn1MinMaxInc = (/-4.5, 4.5, 0.25/)
cn2MinMaxInc = (/-3, 3, 0.25/)
autoTicks = False
;autoTicks = True

wks = gsn_open_wks ("eps", img)
gsn_define_colormap(wks,cmap)

res = True
; {{{
res@vpWidthF = plotWid
res@vpHeightF = plotHei
;  res@vpXF = 0.2
;  res@vpYF = 0.9

res@tiXAxisFontHeightF = fontSize*0.8
res@tiYAxisFontHeightF = res@tiXAxisFontHeightF

res@gsnDraw = False
res@gsnFrame = False
res@gsnLeftString = ""
res@gsnRightString = ""
res@gsnCenterString = ""
res@gsnStringFontHeightF = res@tiXAxisFontHeightF
res@gsnCenterStringOrthogonalPosF = 0.03

;res@tmXTOn = False
;res@tmYROn = False
res@tmYRMinorOn = False
res@tmYRLabelFontHeightF = yLabelSize 
res@tmXBLabelFontHeightF = xLabelSize
res@tmXBLabelStride = 2

res@cnFillOn             = True               ; turn on color for contours
res@cnLinesOn            = False              ; turn off contour lines
res@cnLineThicknessF     = 1.5
res@cnLineLabelFontHeightF = yLabelSize*0.7
;res@cnLineLabelBackgroundColor = "transparent"
res@cnLineLabelsOn       = False              ; turn off contour line labels
res@cnInfoLabelOn        = False      ; turns off contour info label
;res@cnMissingValFillColor = "gray60"
;   res@cnFillMode = "RasterFill"

res@mpCenterLonF = 200
res@mpMaxLatF = 80
res@mpMinLatF = -80

res@lbLabelBarOn   = True
res@lbOrientation = "Vertical"     ; vertical label bar
res@lbBoxLinesOn = False
;res@lbTitlePosition = "Right"
res@lbTitleFontHeightF = fontSize*0.8
res@lbLabelFontHeightF = fontSize*0.7

res@pmLabelBarOrthogonalPosF = 0.01
res@pmLabelBarWidthF = 0.1
res@pmLabelBarHeightF = 0.3

;}}}

res1 = res
res1@gsnCenterString = "temperature"
res1@tiXAxisString = ""
res1@lbTitleString = cbTitle1
if .not.autoTicks
  res1@cnLevelSelectionMode = "ManualLevels"
  res1@cnMinLevelValF       = cn1MinMaxInc(0)
  res1@cnMaxLevelValF       = cn1MinMaxInc(1)
  res1@cnLevelSpacingF      = cn1MinMaxInc(2)
end if

res2 = res
res2@gsnCenterString = "salinity"
res2@lbTitleString = cbTitle2
if .not.autoTicks
  res2@cnLevelSelectionMode = "ManualLevels"
  res2@cnMinLevelValF       = cn2MinMaxInc(0)
  res2@cnMaxLevelValF       = cn2MinMaxInc(1)
  res2@cnLevelSpacingF      = cn2MinMaxInc(2)
end if

res10 = res1
res1@gsnCenterString = ""
res10@cnFillOn             = False
res10@cnLinesOn            = True
res10@cnLineLabelsOn       = True
res10@cnMinLevelValF       = -2
res10@cnMaxLevelValF       = 30
res10@cnLevelSpacingF      = 2

res20 = res2
res2@gsnCenterString = ""
res20@cnFillOn             = False
res20@cnLinesOn            = True
res20@cnLineLabelsOn       = True
res20@cnMinLevelValF       = 28
res20@cnMaxLevelValF       = 40
res20@cnLevelSpacingF      = 0.5

plot = new(2, graphic)

plot(0) = gsn_csm_contour_map(wks, cn1, res1)
plot10 = gsn_csm_contour(wks, cn10, res10)
overlay(plot(0), plot10)

plot(1) = gsn_csm_contour_map(wks, cn2, res2)
plot20 = gsn_csm_contour(wks, cn20, res20)
overlay(plot(1), plot20)

resP = True
;resP@gsnDraw = False
resP@gsnFrame = False
;      resP@gsnPanelBottom = 0.05
;resP@gsnPanelLabelBar = True
resP@gsnPanelYWhiteSpacePercent = 5
resP@gsnPanelRowSpec = True
resP@gsnPanelFigureStrings = (/"a)","b)"/)
resP@gsnPanelFigureStringsFontHeightF = fontSize*0.8
resP@gsnPanelFigureStringsPerimOn = False
resP@amJust = "TopLeft"
resP@amOrthogonalPosF = -0.65

gsn_panel(wks, plot, (/1,1/), resP)

frame(wks)
delete(wks)
system("eps2png_trim "+img)
