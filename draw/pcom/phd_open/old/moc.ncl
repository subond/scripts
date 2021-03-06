
; Description: Meridional overturning circulation 
;
;       Usage: run_ncl moc.ncl basinname depth
;
;      Author: OU Yuyuan <ouyuyuan@lasg.iap.ac.cn>
;     Created: 2014-04-01 15:33:48 BJT
; Last Change: 2014-04-11 08:41:44 BJT

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
   
;   ferret = True
   ferret = False

   ; input options <<<1

   maxdepth = "5000"
   basin = getenv("NCL_ARG_1")
   if (ismissing(basin)) then
      basin = "Global"
   end if
   depth = getenv("NCL_ARG_2")
   if (ismissing(depth)) then
      depth = maxdepth
   end if

   if (ferret) then
      nc_name = "calculated/moc_" + basin + "_ferret.nc"
   else
      nc_name = "calculated/moc_" + basin + ".nc"
   end if

   ; corressponding resource value
   if ( basin .eq. "Global" .and. depth .eq. "5000" ) then
      cnMaxLevelValF = 40
      cnMinLevelValF = -40
      cnLevelSpacingF = 10
   else if ( basin .eq. "Global" .and. depth .eq. "500" ) then
      cnMaxLevelValF = 40
      cnMinLevelValF = -40
      cnLevelSpacingF = 10
   else if ( basin .eq. "Global" .and. depth .eq. "300" ) then
      cnMaxLevelValF = 40
      cnMinLevelValF = -40
      cnLevelSpacingF = 10
   else if ( basin .eq. "Atlantic" .and. depth .eq. "5000" ) then
      cnMaxLevelValF = 20
      cnMinLevelValF = -8
      cnLevelSpacingF = 1
   else
      cnMaxLevelValF = 40
      cnMinLevelValF = 40
      cnLevelSpacingF = 10
   end if
   end if
   end if
   end if

   trYMaxF = stringtofloat(depth)

   ; dirs, files <<<1

   data_dir = "/home/ou/archive/data/"
   draw_dir = "/home/ou/archive/drawing/pcom/phd_open/"

   f_s = addfile(data_dir + "soda/climate/" + nc_name, "r")
   f_p_n = addfile(data_dir + "pcom/climate/fix_fkh/" + nc_name, "r")
   f_p_r = addfile(data_dir + "pcom/climate/res_s/" + nc_name, "r")
   f_l = addfile(data_dir + "licom/climate/unmodified/" + nc_name, "r")

   ; data field <<<1

   if (ferret) then
      cn_s = f_s->moc(:,:)
      cn_l_ori = f_l->moc(0,:,:)
      cn_p_n_ori = f_p_n->moc(0,:,:)
      cn_p_r_ori = f_p_r->moc(0,:,:)
   else
      cn_s = f_s->moc(:,:)
      cn_l_ori = f_l->moc(:,:)
      cn_p_n_ori = f_p_n->moc(:,:)
      cn_p_r_ori = f_p_r->moc(:,:)
   end if

   if (ferret) then
      lev_s = f_s->depth
      lev_l = f_l->lev
      lev_p = f_p_n->z
   else
      lev_s = f_s->lev
      lev_l = f_l->lev
      lev_p = f_p_n->lev
   end if

   ; interpolate to soda levels
   ; ref. https://www.ncl.ucar.edu/Document/Functions/Built-in/linint1_n.shtml
   ; for interpolation
   cn_l = linint1_n_Wrap(lev_l, cn_l_ori, False, lev_s, 0, 0)
   cn_p_n = linint1_n_Wrap(lev_p, cn_p_n_ori, False, lev_s, 0, 0)
   cn_p_r = linint1_n_Wrap(lev_p, cn_p_r_ori, False, lev_s, 0, 0)

   ; workstation <<<1

   wtype = "eps"

   if ( depth .eq. maxdepth ) then
      img = draw_dir + "moc_" + basin
   else
      img = draw_dir + "moc_" + basin + "_" + depth + "m"
   end if
   wks = gsn_open_wks(wtype, img)
;   gsn_define_colormap(wks,"BlueYellowRed")  ; choose color map
;   gsn_define_colormap(wks,"BlGrYeOrReVi200")  ; choose color map
;   gsn_define_colormap(wks,"cmp_b2r")  ; choose color map
   gsn_define_colormap(wks,"ncl_default")  ; choose color map
;   gsn_define_colormap(wks,"NCV_jet")  ; choose color map
   if ( basin .eq. "Atlantic" ) then
      gsn_define_colormap(wks,"BlGrYeOrReVi200")  ; choose color map
;      gsn_define_colormap(wks,"NCV_jet")  ; choose color map
   end if

   ; main res. <<<1

   res = True

   ; title  <<<2

;   res@tiXAxisString = "latitude"
   res@tiYAxisString = "depth (m)"
   res@tiMainFontHeightF = 0.05

   ; viewport  <<<2

   res@vpWidthF = 3

   ; gsn <<<2
   ;
   res@gsnDraw = False
   res@gsnFrame = False
;   res@gsnMaximize = True
   res@gsnSpreadColors      = True               ; use full color map
;   res@gsnSpreadColorStart  = 30                 ; start at color 17
;   res@gsnSpreadColorEnd    = 240                ; end at color 200
   if ( basin .eq. "Atlantic" ) then
      res@gsnSpreadColorEnd    = 180
   end if
   res@gsnYAxisIrregular2Linear = True   ; converts irreg depth to linear 
;   res@gsnYAxisIrregular2Log = True   ; converts irreg depth to linear 
   res@gsnLeftString = ""
   res@gsnRightString = ""
   res@gsnLeftStringOrthogonalPosF = 0.03
   res@gsnRightStringOrthogonalPosF = 0.03

   ; contour <<<2
   ;
   res@cnFillOn             = True               ; turn on color for contours
   res@cnLinesOn            = False              ; turn off contour lines
   res@cnLineLabelsOn       = False              ; turn off contour line labels
   res@cnInfoLabelOn        = False      ; turns off contour info label
   res@cnLevelSelectionMode = "ManualLevels"
   res@cnMaxLevelValF       = cnMaxLevelValF  ; set max contour level
   res@cnMinLevelValF       = cnMinLevelValF  ; set min contour level
   res@cnLevelSpacingF = cnLevelSpacingF 
;   res@cnMissingValFillColor = "black"

   ; label bar <<<2

   res@lbLabelBarOn = False
;   res@lbOrientation            = "Vertical"     ; vertical label bar
   res@lbPerimOn                = False             ; no box around it
   ;    res@lbLabelStride            = 4

   ; plot manager <<<2

   ;    res@pmLabelBarDisplayMode    = "Always"          ; Turn on a label bar.
   ;    res@pmLabelBarWidthF         = 0.08              ; make it thinner
   res@pmLabelBarOrthogonalPosF = 0.04          ; move label bar closer

   ; map  <<<2

;   res@mpLandFillColor          = "gray"            ; set land to be gray
;   res@mpMinLonF = 0
;   res@mpMaxLonF = 360
;   res@mpCenterLonF = 200

   ; tick mark  <<<2

   res@tmLabelAutoStride = True
   res@tmYROn = False
   res@tmXTOn = False
;   res@tmYLMode = "Manual"
;   res@tmYLTickStartF    = 100.
;   res@tmYLTickSpacingF  = 100.
;   res@tmXBMode = "Manual"
;   res@tmXBTickSpacingF = 5
;   res@tmXBTickStartF    = -75
;   res@tmXBTickEndF      = 75
;   res@tmYLTickEndF      = 300.

   ; transformation <<<2

   trXMaxF = 75
   trXMinF = -75
   if ( basin .eq. "Atlantic" ) then
      trXMaxF = 60
      trXMinF = -40
   end if
   res@trYMaxF = trYMaxF
   res@trYMinF = 0
   res@trXMaxF = trXMaxF
   res@trXMinF = trXMinF
   res@trYReverse               = True   ; reverses y-axis

   ; individual res. <<<1

   res_s = res
   res_p_n = res
   res_p_r = res
   res_l = res

   res_s@tiMainString = "Reanalysis (SODA)"
   res_p_n@tiMainString = "PCOM (natual salinity boundary)"
   res_p_r@tiMainString = "PCOM"
   res_l@tiMainString = "LICOM"
;   res_l@gsnAddCyclic = False
   res_l@gsnXAxisIrregular2Linear = True   ; converts irreg latitude to linear 

   ; gsn plot <<<1

   plot = new(3, graphic)
   plot(0) = gsn_csm_contour(wks, cn_s, res_s)
   plot(1) = gsn_csm_contour(wks, cn_p_r, res_p_r)
   plot(2) = gsn_csm_contour(wks, cn_l, res_l)

   ; gsn panel <<<1

   resP = True
   resP@gsnFrame = False
;      resP@gsnPanelDebug = True
   resP@gsnPanelLabelBar = True
;      resP@gsnPanelBottom = 0.05
;   resP@gsnPanelRowSpec = True
   resP@gsnPanelXWhiteSpacePercent = 10
   resP@gsnPanelYWhiteSpacePercent = 5

;   resP@pmLabelBarWidthF = 0.6
   resP@pmLabelBarWidthF = 0.6
;   resP@pmLabelBarHeightF = 0.05
   resP@pmLabelBarOrthogonalPosF = -0.025 ; let label bar a bit far

;   resP@lbOrientation = "Vertical"     ; vertical label bar
   resP@lbLabelFontHeightF = 0.013
;   resP@lbLabelAutoStride = True
   resP@lbTitleString = basin + " meridional overturning circulation (Sv)"
   resP@lbTitleFontHeightF = 0.013
   resP@lbTitleOffsetF = -0.03
;   resP@lbTitlePosition = "Right"

;   resP@txString = "Meridional overturning circulation, " + basin

   gsn_panel(wks, plot, (/3,1/), resP)

   ; label bar text  <<<1

   txres               = True
   txres@txFontHeightF = 0.015
   text = "zonal current (m/s)"
;   gsn_text_ndc(wks, text, 0.5, 0.11, txres)
   
   text = "climate mean"
;   gsn_text_ndc(wks, text, 0.2, 0.05, txres)
   frame(wks)

   delete(wks)

   system("eps2png_trim " + img)

end
