/*

 Copyright The Closure Library Authors.
 SPDX-License-Identifier: Apache-2.0
*/
var gvjs_ar = " - "
  , gvjs_br = " and "
  , gvjs_cr = " but expected type is "
  , gvjs_dr = ' class="'
  , gvjs_er = " does not have a domain column."
  , gvjs_fr = " is of type "
  , gvjs_gr = " of "
  , gvjs_hr = " to "
  , gvjs_ir = '" id="'
  , gvjs_jr = '" value="'
  , gvjs_X = '">'
  , gvjs_kr = "#000"
  , gvjs_lr = "#109618"
  , gvjs_mr = "#222222"
  , gvjs_nr = "#333333"
  , gvjs_or = "#444444"
  , gvjs_pr = "#666666"
  , gvjs_qr = "#757575"
  , gvjs_rr = "#994499"
  , gvjs_sr = "#999"
  , gvjs_tr = "#999999"
  , gvjs_ur = "#CCCCCC"
  , gvjs_vr = "#DC3912"
  , gvjs_wr = "#FF9900"
  , gvjs_xr = "#FFFFFF"
  , gvjs_yr = "#ccc"
  , gvjs_zr = "#cccccc"
  , gvjs_Ar = "#e0e0e0"
  , gvjs_Br = "#fff"
  , gvjs_Cr = "&up__table_query_url="
  , gvjs_Dr = "-caption"
  , gvjs_Er = "-content"
  , gvjs_Fr = "-default"
  , gvjs_Gr = "-disabled"
  , gvjs_Hr = "-dropdown"
  , gvjs_Ir = "-inner-box"
  , gvjs_Jr = "-outer-box"
  , gvjs_Kr = "..."
  , gvjs_Lr = ".enableInteractivity"
  , gvjs_Mr = "0 0"
  , gvjs_Nr = "0px"
  , gvjs_Or = "100"
  , gvjs_Pr = "1px"
  , gvjs_Qr = "1px solid infotext"
  , gvjs_Rr = "400"
  , gvjs_Sr = "500"
  , gvjs_Tr = "600"
  , gvjs_Ur = "700"
  , gvjs_Vr = "800"
  , gvjs_Wr = "900"
  , gvjs_Xr = ";stop-opacity:"
  , gvjs_Yr = "</li>"
  , gvjs_Zr = '<div id="chartArea"></div>'
  , gvjs__r = "<style> v\\:* { behavior:url(#default#VML);}</style>"
  , gvjs_0r = "All data columns targeting the same axis must be of the same data type.  Column #"
  , gvjs_1r = "All domains must be of the same data type"
  , gvjs_2r = "Arial"
  , gvjs_3r = "BACKGROUND"
  , gvjs_4r = "Cannot compute diff for this chart type."
  , gvjs_5r = "Cannot set a non-zero base-line for a stacked chart"
  , gvjs_6r = "Chart has not finished drawing."
  , gvjs_7r = "Color"
  , gvjs_8r = "Component already rendered"
  , gvjs_9r = "Copy-Paste this code to an HTML page"
  , gvjs_$r = "Data must contain at least two columns."
  , gvjs_as = "Data table is not defined"
  , gvjs_bs = "Drawing_Frame_"
  , gvjs_cs = "First column must be a domain column"
  , gvjs_ds = "Google_Visualization"
  , gvjs_es = "Incompatible chart types."
  , gvjs_fs = "Incompatible default series types."
  , gvjs_gs = "Invalid data table format: must have at least 2 columns."
  , gvjs_hs = "Invalid format in "
  , gvjs_is = "Invalid orientation."
  , gvjs_js = "Last domain does not have enough data columns (missing "
  , gvjs_ks = "Lines"
  , gvjs_ls = "MAP"
  , gvjs_ms = "No data"
  , gvjs_ns = "No datatable provided."
  , gvjs_os = "ROW"
  , gvjs_ps = "ROW_INDEX"
  , gvjs_qs = "Roboto"
  , gvjs_rs = "SUBTYPE"
  , gvjs_ss = "TABLE"
  , gvjs_ts = "TBODY"
  , gvjs_us = "TD"
  , gvjs_vs = "TR"
  , gvjs_ws = "Theme must be a theme name or an options object."
  , gvjs_xs = "Unable to set parent component"
  , gvjs_ys = "Unexpected domain column (column #"
  , gvjs_zs = "Unspecified chart type."
  , gvjs_As = "Your browser does not support charts"
  , gvjs_Bs = "_default_"
  , gvjs_Cs = "_focusedLabels"
  , gvjs_Ds = "_selectedLabels"
  , gvjs_Es = "goog-button"
  , gvjs_Fs = "goog-checkbox"
  , gvjs_Gs = "goog-control"
  , gvjs_Hs = "goog-custom-button"
  , gvjs_Y = "goog-inline-block"
  , gvjs_Is = "goog-inline-block "
  , gvjs_Z = "goog-menu"
  , gvjs_Js = "goog-menu-button"
  , gvjs_Ks = "goog-menuheader"
  , gvjs__ = "goog-menuitem"
  , gvjs_Ls = "goog-menuseparator"
  , gvjs_Ms = "goog-option"
  , gvjs_Ns = "goog-option-selected"
  , gvjs_Os = "goog-select"
  , gvjs_Ps = "goog-submenu"
  , gvjs_Qs = "goog-submenu-arrow"
  , gvjs_Rs = "goog-submenu-arrow-rtl"
  , gvjs_Ss = "action"
  , gvjs_Ts = "activedescendant"
  , gvjs_Us = "allowHtml"
  , gvjs_Vs = "alternatingRowStyle"
  , gvjs_Ws = "animation.duration"
  , gvjs_Xs = "animationEasing"
  , gvjs_Ys = "animationfinish"
  , gvjs_Zs = "annotation"
  , gvjs__s = "annotations.boxStyle"
  , gvjs_0s = "annotations.domain.stemColor"
  , gvjs_1s = "annotations.domain.style"
  , gvjs_2s = "annotations.domain.textStyle"
  , gvjs_3s = "annotations.highContrast"
  , gvjs_4s = "annotations.stem.color"
  , gvjs_5s = "annotations.stem.length"
  , gvjs_6s = "annotations.stemColor"
  , gvjs_7s = "annotations.stemLength"
  , gvjs_8s = "annotations.style"
  , gvjs_9s = "annotations.textStyle"
  , gvjs_$s = "annotationtext"
  , gvjs_at = "area"
  , gvjs_bt = "areaOpacity"
  , gvjs_ct = "aria-activedescendant"
  , gvjs_dt = "aria-hidden"
  , gvjs_et = "aria-label"
  , gvjs_ft = "arial"
  , gvjs_gt = "axisBackgroundColor"
  , gvjs_ht = "backgroundColor"
  , gvjs_it = "backgroundColor.fill"
  , gvjs_jt = "bar.groupWidth"
  , gvjs_kt = "bar.width"
  , gvjs_lt = "bars"
  , gvjs_mt = "baselineColor"
  , gvjs_nt = "beforedrag"
  , gvjs_ot = "beforehide"
  , gvjs_pt = "beforeshow"
  , gvjs_qt = "below"
  , gvjs_rt = "black"
  , gvjs_st = "bold"
  , gvjs_tt = "border-box"
  , gvjs_ut = "both"
  , gvjs_vt = "bottom"
  , gvjs_wt = "bottom-space"
  , gvjs_xt = "bottom-vert"
  , gvjs_yt = "bubble"
  , gvjs_zt = "bubble.opacity"
  , gvjs_At = "bubbles"
  , gvjs_Bt = "button"
  , gvjs_Ct = "candlestick"
  , gvjs_Dt = "candlestick.fallingColor"
  , gvjs_Et = "candlestick.risingColor"
  , gvjs_Ft = "candlesticks"
  , gvjs_Gt = "canvas"
  , gvjs_Ht = "category"
  , gvjs_It = "categorypoint"
  , gvjs_Jt = "categorysensitivityarea"
  , gvjs_0 = "center"
  , gvjs_Kt = "change"
  , gvjs_Lt = "character"
  , gvjs_Mt = "chartArea"
  , gvjs_Nt = "chartArea.backgroundColor"
  , gvjs_Ot = "chartDragStart"
  , gvjs_Pt = "chartMouseDown"
  , gvjs_Qt = "chartMouseMove"
  , gvjs_Rt = "chartRightClick"
  , gvjs_St = "chartType"
  , gvjs_Tt = "chartarea"
  , gvjs_Ut = "checkbox"
  , gvjs_Vt = "checked"
  , gvjs_Wt = "click"
  , gvjs_Xt = "clipped"
  , gvjs_Yt = "close"
  , gvjs_Zt = "closedPhase"
  , gvjs__t = "col-resize"
  , gvjs_1 = "color"
  , gvjs_0t = "colorAxis.values must not contain nulls"
  , gvjs_1t = "colorBar"
  , gvjs_2t = "colors"
  , gvjs_3t = "contextmenu"
  , gvjs_4t = "crosshair.color"
  , gvjs_5t = "crosshair.opacity"
  , gvjs_6t = "crosshair.orientation"
  , gvjs_7t = "curve"
  , gvjs_8t = "curveType"
  , gvjs_9t = "dash"
  , gvjs_$t = "data"
  , gvjs_au = "data-logicalname"
  , gvjs_bu = "data-value"
  , gvjs_cu = "dataOpacity"
  , gvjs_du = "dblclick"
  , gvjs_eu = "default"
  , gvjs_fu = "dialogselect"
  , gvjs_gu = "diff.newData.opacity"
  , gvjs_hu = "diff.oldData.opacity"
  , gvjs_iu = "direction"
  , gvjs_ju = "disable"
  , gvjs_ku = "display"
  , gvjs_lu = "dive"
  , gvjs_mu = "domain"
  , gvjs_nu = "drag"
  , gvjs_ou = "dragend"
  , gvjs_pu = "dragstart"
  , gvjs_qu = "enable"
  , gvjs_ru = "enableInteractivity"
  , gvjs_su = "explicit"
  , gvjs_tu = "explorer"
  , gvjs_uu = "explorer.actions"
  , gvjs_vu = "finish"
  , gvjs_wu = "fixed"
  , gvjs_xu = "focus"
  , gvjs_yu = "focusTarget"
  , gvjs_zu = "focusin"
  , gvjs_Au = "focusout"
  , gvjs_Bu = "font-style"
  , gvjs_Cu = "font-weight"
  , gvjs_Du = "fontColor"
  , gvjs_Eu = "forceIFrame"
  , gvjs_Fu = "format"
  , gvjs_Gu = "formatOptions.prefix"
  , gvjs_Hu = "formatOptions.scaleFactor"
  , gvjs_Iu = "formatOptions.suffix"
  , gvjs_Ju = "frozen-column"
  , gvjs_Ku = "frozenColumnsBackground"
  , gvjs_Lu = "global"
  , gvjs_Mu = "google-visualization-toolbar-html-code-explanation"
  , gvjs_Nu = "google-visualization-tooltip"
  , gvjs_Ou = "gotpointercapture"
  , gvjs_Pu = "grid"
  , gvjs_Qu = "gridlineColor"
  , gvjs_Ru = "gridlines"
  , gvjs_Su = "gridlines.color"
  , gvjs_Tu = "gridlines.count"
  , gvjs_Uu = "gridlines.interval"
  , gvjs_Vu = "gridlines.minSpacing"
  , gvjs_Wu = "gridlines.multiple"
  , gvjs_Xu = "hAxis"
  , gvjs_Yu = "haspopup"
  , gvjs_Zu = "headerColor"
  , gvjs__u = "headerHeight"
  , gvjs_0u = "hidden"
  , gvjs_1u = "hide"
  , gvjs_2u = "highContrast"
  , gvjs_3u = "highlight"
  , gvjs_4u = "histogram"
  , gvjs_5u = "histogram.bucketSize"
  , gvjs_6u = "histogram.hideBucketItems"
  , gvjs_7u = "histogram.lastBucketPercentile"
  , gvjs_8u = "histogramBuckets"
  , gvjs_9u = "hoverIn"
  , gvjs_$u = "hoverOut"
  , gvjs_av = "html"
  , gvjs_bv = "image/png"
  , gvjs_cv = "inAndOut"
  , gvjs_dv = "infobackground"
  , gvjs_ev = "inline"
  , gvjs_fv = "input"
  , gvjs_gv = "inside"
  , gvjs_hv = "interpolateNulls"
  , gvjs_iv = "interval"
  , gvjs_jv = "isStacked"
  , gvjs_kv = "key"
  , gvjs_lv = "keydown"
  , gvjs_mv = "keyup"
  , gvjs_nv = "labelInLegend"
  , gvjs_ov = "labeled"
  , gvjs_pv = "labelledby"
  , gvjs_qv = "last-frozen-column"
  , gvjs_rv = "legend"
  , gvjs_sv = "legend.alignment"
  , gvjs_tv = "legend.maxLines"
  , gvjs_uv = "legend.position"
  , gvjs_vv = "legend.textStyle"
  , gvjs_wv = "legendFontSize"
  , gvjs_xv = "legendTextColor"
  , gvjs_yv = "legendTextStyle"
  , gvjs_zv = "legendentry"
  , gvjs_Av = "legendscrollbutton"
  , gvjs_Bv = "lineWidth"
  , gvjs_Cv = "logScale"
  , gvjs_Dv = "ltr"
  , gvjs_Ev = "margin"
  , gvjs_Fv = "material"
  , gvjs_Gv = "max"
  , gvjs_Hv = "max-width"
  , gvjs_Iv = "maxAlternation"
  , gvjs_Jv = "maxColor"
  , gvjs_Kv = "maxDepth"
  , gvjs_Lv = "maximized"
  , gvjs_Mv = "midColor"
  , gvjs_Nv = "middle"
  , gvjs_Ov = "min"
  , gvjs_Pv = "minColor"
  , gvjs_Qv = "minorGridlines.color"
  , gvjs_Rv = "minorGridlines.count"
  , gvjs_Sv = "minorGridlines.interval"
  , gvjs_Tv = "minorGridlines.minSpacing"
  , gvjs_Uv = "minorGridlines.multiple"
  , gvjs_Vv = "mirrorLog"
  , gvjs_Wv = "mousewheel"
  , gvjs_Xv = "move"
  , gvjs_Yv = "move_offscreen"
  , gvjs_Zv = "name"
  , gvjs__v = "nonNegative"
  , gvjs_0v = "normal"
  , gvjs_1v = "nowrap"
  , gvjs_2v = "numberOrString"
  , gvjs_3v = "old-data"
  , gvjs_4v = "onmousedown"
  , gvjs_5v = "onmousemove"
  , gvjs_6v = "onmouseout"
  , gvjs_7v = "onmouseover"
  , gvjs_8v = "opacity 1s linear"
  , gvjs_9v = "orientation"
  , gvjs_$v = "orientationchange"
  , gvjs_aw = "out"
  , gvjs_bw = "outside"
  , gvjs_cw = "page"
  , gvjs_dw = "paging-controls"
  , gvjs_ew = "percentage"
  , gvjs_fw = "pie"
  , gvjs_gw = "pieSliceBorderColor"
  , gvjs_hw = "pieSliceText"
  , gvjs_iw = "piecewiseLinear"
  , gvjs_jw = "pointSize"
  , gvjs_kw = "pointer"
  , gvjs_lw = "pointer-events"
  , gvjs_mw = "points"
  , gvjs_nw = "pointsVisible"
  , gvjs_ow = "pointsensitivityarea"
  , gvjs_pw = "polygon"
  , gvjs_qw = "pretty"
  , gvjs_rw = "primarydiagonalstripes"
  , gvjs_sw = "range"
  , gvjs_tw = "ratio"
  , gvjs_uw = "removeseriebutton"
  , gvjs_vw = "resize"
  , gvjs_ww = "reverseAxis"
  , gvjs_xw = "reverseCategories"
  , gvjs_yw = "rgba(0,0,0,0)"
  , gvjs_zw = "right-space"
  , gvjs_Aw = "rightclick"
  , gvjs_Bw = "rowlabels"
  , gvjs_Cw = "rows"
  , gvjs_Dw = "sans-serif"
  , gvjs_Ew = "scaleType"
  , gvjs_Fw = "screen"
  , gvjs_Gw = "scroll"
  , gvjs_Hw = "secondarydiagonalstripes"
  , gvjs_Iw = "selected"
  , gvjs_Jw = "selection"
  , gvjs_Kw = "selectionMode"
  , gvjs_Lw = "separator"
  , gvjs_Mw = "series"
  , gvjs_Nw = "series-color"
  , gvjs_Ow = "series-color-dark"
  , gvjs_Pw = "series-color-light"
  , gvjs_Qw = "series."
  , gvjs_Rw = "shape"
  , gvjs_Sw = "show"
  , gvjs_Tw = "showChartButtons"
  , gvjs_Uw = "showTooltip"
  , gvjs_Vw = "showTooltips"
  , gvjs_Ww = "single"
  , gvjs_Xw = "size"
  , gvjs_Yw = "smoothingFactor"
  , gvjs_Zw = "solid"
  , gvjs__w = "sortColumn"
  , gvjs_0w = "span"
  , gvjs_1w = "square"
  , gvjs_2w = "stack"
  , gvjs_3w = "star"
  , gvjs_2 = "start"
  , gvjs_4w = "steppedArea"
  , gvjs_5w = "steppedareabar"
  , gvjs_6w = "stop-color:"
  , gvjs_7w = "stroke-dasharray"
  , gvjs_8w = "stroke-linecap"
  , gvjs_9w = "tabindex"
  , gvjs_$w = "targetAxisIndex"
  , gvjs_ax = "text-decoration"
  , gvjs_bx = "textStyle"
  , gvjs_cx = "textpathok"
  , gvjs_dx = "tick"
  , gvjs_ex = "ticks"
  , gvjs_fx = "title"
  , gvjs_gx = "titleColor"
  , gvjs_hx = "titleFontSize"
  , gvjs_ix = "titleTextStyle"
  , gvjs_jx = "titleY"
  , gvjs_kx = "toggle_display"
  , gvjs_lx = "tooltip.bounds"
  , gvjs_mx = "tooltip.ignoreBounds"
  , gvjs_nx = "tooltip.isHtml"
  , gvjs_ox = "tooltip.showColorCode"
  , gvjs_px = "tooltip.textStyle"
  , gvjs_qx = "tooltip.trigger"
  , gvjs_rx = "tooltipFontSize"
  , gvjs_sx = "tooltipTextColor"
  , gvjs_tx = "tooltipTextStyle"
  , gvjs_ux = "tooltipTrigger"
  , gvjs_vx = "top"
  , gvjs_wx = "top-space"
  , gvjs_xx = "trendlines."
  , gvjs_yx = "unhighlight"
  , gvjs_zx = "unselectable"
  , gvjs_Ax = "urn:schemas-microsoft-com:vml"
  , gvjs_Bx = "userSpaceOnUse"
  , gvjs_Cx = "v-text-align"
  , gvjs_Dx = "v:fill"
  , gvjs_Ex = "v:oval"
  , gvjs_Fx = "v:path"
  , gvjs_Gx = "v:shape"
  , gvjs_Hx = "vAxes"
  , gvjs_Ix = "value-and-percentage"
  , gvjs_Jx = "viewWindow.max"
  , gvjs_Kx = "viewWindow.min"
  , gvjs_Lx = "viewWindowMode"
  , gvjs_Mx = "visible"
  , gvjs_Nx = "visibleInLegend"
  , gvjs_Ox = "white";
function gvjs_Px(a, b) {
    var c = b || document;
    return c.querySelectorAll && c.querySelector ? c.querySelectorAll("." + a) : gvjs_7g(document, "*", a, b)
}
function gvjs_Qx(a) {
    return gvjs_y && !gvjs_Eg("9") ? (a = a.getAttributeNode(gvjs_9w),
    null != a && a.specified) : a.hasAttribute(gvjs_9w)
}
function gvjs_Rx(a) {
    a = a.tabIndex;
    return typeof a === gvjs_g && 0 <= a && 32768 > a
}
function gvjs_Sx(a) {
    return gvjs_Qx(a) && gvjs_Rx(a)
}
function gvjs_Tx(a) {
    try {
        var b = a && a.activeElement;
        return b && b.nodeName ? b : null
    } catch (c) {
        return null
    }
}
function gvjs_Ux(a) {
    gvjs_Zk(a);
    return a.$m.pop()
}
function gvjs_Vx(a, b, c, d, e) {
    b = e[b];
    d === gvjs_fw ? (c = b.Cs,
    d = null) : d = b.Cs;
    return {
        type: a,
        data: {
            row: c,
            column: d
        }
    }
}
gvjs_8q.prototype.Is = gvjs_V(33, function(a, b, c, d) {
    var e = this
      , f = []
      , g = b.focused
      , h = a.focused;
    if (g.Hb !== h.Hb || g.datum !== h.datum)
        null != h.Hb && f.push(gvjs_Vx(gvjs_6v, h.Hb, h.datum, c, d)),
        null != g.Hb && f.push(gvjs_Vx(gvjs_7v, g.Hb, g.datum, c, d));
    g.Eb !== h.Eb && (null != h.Eb && f.push({
        type: gvjs_6v,
        data: {
            row: h.Eb,
            column: null
        }
    }),
    null != g.Eb && f.push({
        type: gvjs_7v,
        data: {
            row: g.Eb,
            column: null
        }
    }));
    g = b.annotations.focused;
    h = a.annotations.focused;
    !h || g && g.row === h.row && g.column === h.column || f.push({
        type: gvjs_6v,
        data: {
            row: h.row,
            column: h.column
        }
    });
    !g || h && g.row === h.row && g.column === h.column || f.push({
        type: gvjs_7v,
        data: {
            row: g.row,
            column: g.column
        }
    });
    g = b.legend.focused;
    h = a.legend.focused;
    g.Xc !== h.Xc && (null != h.Xc && f.push(gvjs_Vx(gvjs_6v, h.Xc, null, c, d)),
    null != g.Xc && f.push(gvjs_Vx(gvjs_7v, g.Xc, null, c, d)));
    b.selected.equals(a.selected) || f.push({
        type: gvjs_k
    });
    b.legend.Xi === a.legend.Xi && b.legend.xF === a.legend.xF || f.push({
        type: "legendpagination",
        data: {
            currentPageIndex: b.legend.Xi,
            totalPages: b.legend.xF
        }
    });
    gvjs_u(f, function(k) {
        e.dispatchEvent(k.type, k.data)
    })
});
gvjs_wq.prototype.Ou = gvjs_V(27, function() {
    return !1
});
gvjs_Uq.prototype.Ou = gvjs_V(26, function() {
    return !1
});
gvjs_wq.prototype.Qj = gvjs_V(25, function() {
    if (!(null != this.eo || this.Ou() && null != this.eo || this.fireEvent("box", [this]) && null != this.eo))
        throw "cannot determine bounding box until inserted into a scene.";
    return this.eo
});
gvjs_Qn.prototype.ah = gvjs_V(24, function() {
    return ""
});
gvjs_M.prototype.Do = gvjs_V(20, function() {
    return gvjs_0e(this.bf)
});
gvjs_N.prototype.Do = gvjs_V(19, function() {
    return this.FZ()
});
gvjs_Po.prototype.Do = gvjs_V(18, function() {
    return this.bd.Do()
});
gvjs_ok.prototype.aU = gvjs_V(17, function(a) {
    this.x -= a.x;
    this.y -= a.y;
    return this
});
gvjs_hj.prototype.J_ = gvjs_V(15, function(a) {
    var b = new gvjs_hj;
    a = gvjs_ej(a);
    for (var c = 0; c < a.length; c++) {
        var d = a[c];
        this.contains(d) && b.add(d)
    }
});
gvjs_H.prototype.uA = gvjs_V(14, function(a) {
    this.g2 = a
});
gvjs_4g.prototype.Gq = gvjs_V(8, function(a) {
    var b;
    (b = "A" == a.tagName && a.hasAttribute("href") || a.tagName == gvjs_Na || a.tagName == gvjs_Vo || a.tagName == gvjs_Uo || a.tagName == gvjs_To ? !a.disabled && (!gvjs_Qx(a) || gvjs_Rx(a)) : gvjs_Sx(a)) && gvjs_y ? (a = typeof a.getBoundingClientRect !== gvjs_d || gvjs_y && null == a.parentElement ? {
        height: a.offsetHeight,
        width: a.offsetWidth
    } : a.getBoundingClientRect(),
    a = null != a && 0 < a.height && 0 < a.width) : a = b;
    return a
});
gvjs_4g.prototype.Ly = gvjs_V(6, function() {
    return gvjs_Tx(this.dd)
});
gvjs_4g.prototype.wq = gvjs_V(0, function(a, b) {
    return gvjs_Px(a, b || this.dd)
});
function gvjs_Wx(a) {
    return a
}
function gvjs_Xx(a, b, c) {
    for (var d = a.length, e = typeof a === gvjs_l ? a.split("") : a, f = 0; f < d; f++)
        if (f in e && b.call(c, e[f], f, a))
            return f;
    return -1
}
function gvjs_Yx(a, b, c) {
    b = gvjs_Xx(a, b, c);
    return 0 > b ? null : typeof a === gvjs_l ? a.charAt(b) : a[b]
}
var gvjs_kda = /^([^?#]*)(\?[^#]*)?(#[\s\S]*)?/;
function gvjs_Zx(a, b, c) {
    if (null == c)
        return b;
    if (typeof c === gvjs_l)
        return c ? a + encodeURIComponent(c) : "";
    for (var d in c)
        if (Object.prototype.hasOwnProperty.call(c, d)) {
            var e = c[d];
            e = Array.isArray(e) ? e : [e];
            for (var f = 0; f < e.length; f++) {
                var g = e[f];
                null != g && (b || (b = a),
                b += (b.length > a.length ? "&" : "") + encodeURIComponent(d) + "=" + encodeURIComponent(String(g)))
            }
        }
    return b
}
function gvjs__x(a, b) {
    gvjs_cg(a, b)
}
function gvjs_0x(a) {
    a = a.document;
    a = gvjs_eh(a) ? a.documentElement : a.body;
    return new gvjs_A(a.clientWidth,a.clientHeight)
}
function gvjs_1x(a) {
    return a.scrollingElement ? a.scrollingElement : !gvjs_tg && gvjs_eh(a) ? a.documentElement : a.body || a.documentElement
}
function gvjs_2x(a) {
    var b = gvjs_1x(a);
    a = a.parentWindow || a.defaultView;
    return gvjs_y && gvjs_Eg("10") && a.pageYOffset != b.scrollTop ? new gvjs_z(b.scrollLeft,b.scrollTop) : new gvjs_z(a.pageXOffset || b.scrollLeft,a.pageYOffset || b.scrollTop)
}
function gvjs_3x(a) {
    return a ? a.parentWindow || a.defaultView : window
}
function gvjs_4x(a, b) {
    var c = gvjs_ah(a, gvjs_b);
    gvjs_y ? (b = gvjs_$f(gvjs_bg, b),
    gvjs_cg(c, b),
    c.removeChild(c.firstChild)) : gvjs_cg(c, b);
    if (1 == c.childNodes.length)
        c = c.removeChild(c.firstChild);
    else {
        for (a = a.createDocumentFragment(); c.firstChild; )
            a.appendChild(c.firstChild);
        c = a
    }
    return c
}
function gvjs_5x(a, b) {
    a.left = Math.min(a.left, b.left);
    a.top = Math.min(a.top, b.top);
    a.right = Math.max(a.right, b.right);
    a.bottom = Math.max(a.bottom, b.bottom)
}
function gvjs_6x(a, b) {
    b = gvjs_re(gvjs_E, b);
    a.xf ? b() : (a.Wz || (a.Wz = []),
    a.Wz.push(b))
}
function gvjs_7x(a) {
    return 0 == a.$i.button && !(gvjs_ug && a.ctrlKey)
}
function gvjs_8x(a, b, c) {
    gvjs_yi(a, b, gvjs_Wd, void 0 === c ? !0 : c)
}
function gvjs_9x(a) {
    if (a === gvjs_f)
        return gvjs_f;
    a = gvjs_vj(a);
    a = Math.round((a[0] + a[1] + a[2]) / 3);
    return gvjs_wj(a, a, a)
}
function gvjs_$x(a, b, c) {
    this.style = a;
    this.color = gvjs_yj(b);
    this.Pp = gvjs_yj(null != c ? c : gvjs_ea)
}
gvjs_ = gvjs_$x.prototype;
gvjs_.getStyle = function() {
    return this.style
}
;
gvjs_.ee = function() {
    return this.color
}
;
gvjs_.getBackgroundColor = function() {
    return this.Pp
}
;
gvjs_.clone = function() {
    return new gvjs_$x(this.style,this.color,this.Pp)
}
;
gvjs_.yI = function() {
    return new gvjs_$x(this.style,gvjs_9x(this.color),gvjs_9x(this.Pp))
}
;
function gvjs_ay(a, b) {
    null != b && (a.strokeOpacity = gvjs_0g(Number(b), 0, 1))
}
function gvjs_by(a, b) {
    b && (a.pattern = b instanceof gvjs_$x ? b.clone() : new gvjs_$x(b.style,b.color,b.Pp))
}
function gvjs_cy(a, b) {
    null === a.gradient ? a.gradient = gvjs_0e(b || null) : null != b && (Object.assign(a.gradient, b),
    b.Vf = gvjs_yj(b.Vf || "", !0),
    b.sf = gvjs_yj(b.sf || "", !0),
    null === b.tn && delete b.tn,
    null === b.un && delete b.un,
    null === b.Sn && delete b.Sn,
    null === b.sp && delete b.sp)
}
function gvjs_3(a) {
    a = void 0 === a ? {} : a;
    this.Rw = this.pattern = this.gradient = this.radiusY = this.radiusX = null;
    this.fill = gvjs_f;
    this.fillOpacity = 1;
    this.stroke = gvjs_f;
    this.strokeOpacity = this.strokeWidth = 1;
    this.Mi = gvjs_Zw;
    this.sr(a)
}
gvjs_ = gvjs_3.prototype;
gvjs_.sr = function(a) {
    (a = void 0 === a ? {} : a) || (a = {});
    this.Te(a.fill);
    this.mf(a.fillOpacity);
    this.rd(a.stroke);
    this.hl(a.strokeWidth);
    gvjs_ay(this, a.strokeOpacity);
    var b = a.Mi;
    null != b && (this.Mi = b);
    b = a.rx;
    null != b && (this.radiusX = b);
    b = a.ry;
    null != b && (this.radiusY = b);
    gvjs_by(this, a.pattern);
    gvjs_cy(this, a.gradient);
    this.Rw = a.Rw || null;
    return this
}
;
gvjs_.getProperties = function() {
    var a = this.pattern
      , b = null;
    a && (b = {
        style: a.getStyle(),
        color: a.ee(),
        Pp: a.getBackgroundColor()
    });
    return {
        fill: this.fill,
        fillOpacity: this.fillOpacity,
        stroke: this.Uj(),
        strokeWidth: this.strokeWidth,
        strokeOpacity: this.strokeOpacity,
        Mi: this.Mi,
        rx: this.radiusX,
        ry: this.radiusY,
        pattern: b,
        gradient: gvjs_0e(this.gradient),
        Rw: gvjs_0e(this.Rw)
    }
}
;
gvjs_.toJSON = function() {
    var a = this.gradient;
    a && (a = {
        color1: a.Vf,
        color2: a.sf,
        opacity1: a.tn,
        opacity2: a.un,
        x1: a.x1,
        y1: a.y1,
        x2: a.x2,
        y2: a.y2,
        useObjectBoundingBoxUnits: a.Sn,
        sharpTransition: a.sp
    });
    var b = this.pattern ? {
        style: this.pattern.getStyle(),
        color: this.pattern.ee(),
        Pp: this.pattern.getBackgroundColor()
    } : {}
      , c = this.Rw;
    c && (c = {
        radius: c.radius,
        opacity: c.opacity,
        xOffset: c.xOffset,
        yOffset: c.yOffset
    });
    return gvjs_Hi({
        fill: this.fill,
        fillOpacity: this.fillOpacity,
        stroke: this.Uj(),
        strokeWidth: this.strokeWidth,
        strokeOpacity: this.strokeOpacity,
        strokeDashStyle: this.Mi,
        rx: this.radiusX,
        ry: this.radiusY,
        gradient: a,
        pattern: b,
        shadow: c
    })
}
;
gvjs_.clone = function() {
    return new gvjs_3(this.getProperties())
}
;
gvjs_.yI = function() {
    var a = this.clone();
    a.Te(gvjs_9x(this.fill));
    a.rd(gvjs_9x(this.stroke));
    var b = this.gradient;
    if (b) {
        var c = gvjs_x(b);
        c.Vf = gvjs_9x(b.Vf);
        c.sf = gvjs_9x(b.sf);
        gvjs_cy(a, c)
    }
    this.pattern && gvjs_by(a, this.pattern.yI());
    return a
}
;
gvjs_.Te = function(a) {
    null != a && (this.fill = gvjs_yj(a, !0));
    return this
}
;
gvjs_.qZ = gvjs_n(34);
gvjs_.mf = function(a) {
    null != a && (this.fillOpacity = gvjs_0g(a, 0, 1));
    return this
}
;
gvjs_.rd = function(a, b) {
    null != a && (this.stroke = gvjs_yj(a, !0));
    this.hl(b)
}
;
gvjs_.Uj = function() {
    return this.stroke
}
;
gvjs_.hl = function(a) {
    if (null != a && (typeof a === gvjs_l && (a = Number(a)),
    typeof a === gvjs_g && !isNaN(a))) {
        if (0 > a)
            throw Error("Negative strokeWidth not allowed.");
        0 <= a && (this.strokeWidth = a)
    }
}
;
gvjs_.equals = function(a) {
    var b;
    if (b = this.fill === a.fill && this.fillOpacity === a.fillOpacity && this.stroke === a.stroke && this.strokeWidth === a.strokeWidth && this.strokeOpacity === a.strokeOpacity && this.Mi === a.Mi && this.radiusX === a.radiusX && this.radiusY === a.radiusY) {
        b = this.gradient;
        var c = a.gradient;
        b = b === c ? !0 : null === b || null === c ? !1 : b.Vf === c.Vf && b.sf === c.sf && b.x1 === c.x1 && b.y1 === c.y1 && b.x2 === c.x2 && b.y2 === c.y2 && b.Sn === c.Sn && b.sp === c.sp
    }
    b && (b = this.pattern || null,
    a = a.pattern || null,
    b = b === a ? !0 : null == b || null == a ? !1 : b.Pp === a.Pp && b.color === a.color && b.style === a.style);
    return b
}
;
function gvjs_dy(a) {
    return null === a || "" === a || a === gvjs_f || gvjs_r(a) && gvjs_dy(a.color)
}
function gvjs_ey(a) {
    return 0 < a.strokeWidth && 0 < a.strokeOpacity && !gvjs_dy(a.stroke)
}
function gvjs_fy(a) {
    return gvjs_ey(a) ? a.strokeWidth : 0
}
function gvjs_gy(a) {
    return 0 < a.fillOpacity && (!gvjs_dy(a.fill) || null != a.gradient || null != a.pattern)
}
function gvjs_hy(a) {
    return gvjs_gy(a) && 1 <= a.fillOpacity
}
var gvjs_iy = {
    stroke: gvjs_Ox,
    strokeOpacity: 0,
    fill: gvjs_Ox,
    fillOpacity: 0
};
function gvjs_jy(a, b) {
    null != b && (a.bold = b);
    return a
}
function gvjs_ky(a, b) {
    null != b && (a.Nc = b);
    return a
}
function gvjs_ly(a) {
    this.bb = gvjs_Dw;
    this.fontSize = Number(10);
    this.color = gvjs_rt;
    this.opacity = 1;
    this.Lb = "";
    this.tG = 3;
    this.Ue = this.Nc = this.bold = !1;
    this.sr(a || {})
}
gvjs_ = gvjs_ly.prototype;
gvjs_.sr = function(a) {
    a = a || {};
    this.Mw(a.bb);
    this.om(a.fontSize);
    this.setColor(a.color);
    this.setOpacity(a.opacity);
    var b = a.Lb;
    null != b && (this.Lb = b);
    b = a.tG;
    null != b && (this.tG = b);
    gvjs_jy(this, a.bold);
    gvjs_ky(this, a.Nc);
    a = a.Ue;
    null != a && (this.Ue = a);
    return this
}
;
gvjs_.getProperties = function() {
    return {
        fontName: this.bb,
        fontSize: this.fontSize,
        color: this.color,
        auraColor: this.Lb,
        auraWidth: this.tG,
        bold: this.bold,
        italic: this.Nc,
        underline: this.Ue,
        opacity: this.opacity
    }
}
;
gvjs_.toJSON = function() {
    return gvjs_Hi(this.getProperties())
}
;
gvjs_.Mw = function(a) {
    null != a && "" !== a && (this.bb = a);
    return this
}
;
gvjs_.om = function(a) {
    if (null != a && (typeof a === gvjs_l && (a = Number(a)),
    typeof a === gvjs_g)) {
        if (0 > a)
            throw Error("Negative fontSize not allowed.");
        0 < a && (this.fontSize = a)
    }
    return this
}
;
gvjs_.setColor = function(a) {
    null != a && (this.color = a);
    return this
}
;
gvjs_.setOpacity = function(a) {
    null != a && (this.opacity = a);
    return this
}
;
var gvjs_lda = {
    fill: {
        name: gvjs_np,
        type: gvjs_1
    },
    fillOpacity: {
        name: gvjs_sp,
        type: gvjs_tw
    },
    stroke: {
        name: gvjs_0p,
        type: gvjs_1
    },
    strokeOpacity: {
        name: gvjs_7p,
        type: gvjs_tw
    },
    strokeWidth: {
        name: gvjs_8p,
        type: gvjs__v
    },
    Mi: {
        name: "strokeDashStyle",
        type: ["arrayOfNumber", {
            type: gvjs_l,
            eu: {
                Cja: gvjs_Zw,
                Zza: gvjs_9t
            }
        }]
    },
    rx: {
        name: "rx",
        type: gvjs_g
    },
    ry: {
        name: "ry",
        type: gvjs_g
    },
    gradient: {
        name: gvjs_Bp,
        type: gvjs_h,
        properties: {
            Vf: {
                name: "color1",
                type: gvjs_1
            },
            sf: {
                name: "color2",
                type: gvjs_1
            },
            tn: {
                name: "opacity1",
                type: gvjs_tw
            },
            un: {
                name: "opacity2",
                type: gvjs_tw
            },
            x1: {
                name: "x1",
                type: gvjs_2v
            },
            y1: {
                name: "y1",
                type: gvjs_2v
            },
            x2: {
                name: "x2",
                type: gvjs_2v
            },
            y2: {
                name: "y2",
                type: gvjs_2v
            },
            sp: {
                name: "sharpTransition",
                type: gvjs_zb
            },
            Sn: {
                name: "useObjectBoundingBoxUnits",
                type: gvjs_zb
            }
        }
    },
    Rw: {
        name: "shadow",
        type: gvjs_h,
        properties: {
            radius: {
                name: "radius",
                type: gvjs_g
            },
            opacity: {
                name: gvjs_Kp,
                type: gvjs_tw
            },
            xOffset: {
                name: "xOffset",
                type: gvjs_g
            },
            yOffset: {
                name: "yOffset",
                type: gvjs_g
            }
        }
    },
    pattern: {
        name: gvjs_td,
        type: gvjs_h,
        properties: {
            color: {
                name: gvjs_1,
                type: gvjs_1
            },
            backgroundColor: {
                name: gvjs_ht,
                type: gvjs_1
            },
            style: {
                name: gvjs_Jd,
                type: {
                    type: gvjs_l,
                    eu: {
                        dBa: gvjs_rw,
                        lBa: gvjs_Hw
                    }
                }
            }
        }
    }
}
  , gvjs_mda = {
    color: {
        name: gvjs_1,
        type: gvjs_1
    },
    opacity: {
        name: gvjs_Kp,
        type: gvjs_tw
    },
    Lb: {
        name: "auraColor",
        type: gvjs_1
    },
    tG: {
        name: "auraWidth",
        type: gvjs__v
    },
    bb: {
        name: gvjs_yp,
        type: gvjs_l
    },
    fontSize: {
        name: gvjs_zp,
        type: gvjs__v
    },
    bold: {
        name: gvjs_st,
        type: gvjs_zb
    },
    Nc: {
        name: gvjs_Gp,
        type: gvjs_zb
    },
    Ue: {
        name: gvjs_bq,
        type: gvjs_zb
    }
};
function gvjs_nda(a, b) {
    b && (a = b(a));
    return gvjs_lj(a)
}
function gvjs_my(a, b, c, d) {
    return gvjs_Fj(a, gvjs_nda, {}, b, c || {}, d)
}
function gvjs_ny(a, b, c) {
    return gvjs_Fj(a, gvjs_Pj, 0, b, c)
}
function gvjs_oy(a, b, c, d) {
    return gvjs_Fj(a, gvjs_Qj, gvjs_f, b, c, d)
}
function gvjs_py(a, b, c) {
    function d(f, g, h) {
        function k() {
            var m = f.type;
            m === gvjs_h ? (m = f.properties,
            l = gvjs_py(a.view(g), m, h)) : l = d(m, g || f.name, h || f.eu)
        }
        var l = null;
        Array.isArray(f) ? gvjs_Yx(f, function(m) {
            l = d(m, g, h);
            return null != l
        }) : gvjs_lj(f) ? k() : typeof f === gvjs_l ? l = d(gvjs_zj[f], g, h) : typeof f === gvjs_d && (l = f.call(a, g, h));
        return l
    }
    var e = null;
    gvjs_w(b, function(f, g) {
        f = d(f, f.name, c && c[g]);
        null != f && (null == e && (e = {}),
        e[g] = f)
    });
    return e
}
function gvjs_qy(a, b, c) {
    var d = null
      , e = null;
    c instanceof gvjs_3 ? d = new gvjs_3(c.getProperties()) : typeof c === gvjs_h ? d = new gvjs_3(c) : e = c;
    a = a.ob(b, e);
    a = gvjs_v(a, function(f) {
        typeof f === gvjs_l && (f = {
            fill: gvjs_Qj(f)
        });
        return f
    });
    a = gvjs_py(new gvjs_Aj(a), gvjs_lda);
    d = d || new gvjs_3;
    d.sr(a);
    gvjs_gy(d) || (d.Te(gvjs_iy.fill),
    d.mf(gvjs_iy.fillOpacity));
    gvjs_ey(d) || (d.rd(gvjs_iy.stroke),
    gvjs_ay(d, gvjs_iy.strokeOpacity));
    return d
}
function gvjs_ry(a, b, c, d) {
    a = a.ob(b);
    d = gvjs_py(new gvjs_Aj(a), gvjs_mda, {
        color: d,
        Lb: d
    });
    c = new gvjs_ly(c || {});
    c.sr(d);
    return c
}
function gvjs_sy(a, b) {
    a.Lh && (a.Lh.reject = b)
}
function gvjs_ty(a, b, c) {
    var d = gvjs_do(a, b);
    c && a.clear();
    d ? a.qE(b) : a.Kp(b)
}
function gvjs_uy(a, b, c) {
    var d = gvjs_eo(a, b);
    c && a.clear();
    d ? a.BS(b) : a.xd(b)
}
function gvjs_vy(a, b, c, d) {
    var e = gvjs_fo(a, b, c);
    d && a.clear();
    e ? a.MK(b, c) : gvjs_go(a, b, c)
}
function gvjs_wy(a) {
    if (a.eq !== gvjs_pq)
        throw Error("Sanitized content was not of kind HTML.");
    return gvjs_3f(a.toString(), a.TN || null)
}
function gvjs_xy() {
    this.T_ = !1;
    this.qx = null;
    this.l6 = void 0;
    this.Fi = 1;
    this.Ws = this.Lx = 0;
    this.HY = this.Am = null
}
function gvjs_yy(a) {
    if (a.T_)
        throw new TypeError("Generator is already running");
    a.T_ = !0
}
gvjs_ = gvjs_xy.prototype;
gvjs_.KA = function() {
    this.T_ = !1
}
;
gvjs_.bK = function(a) {
    this.l6 = a
}
;
gvjs_.LL = function(a) {
    this.Am = {
        a$: a,
        Dba: !0
    };
    this.Fi = this.Lx || this.Ws
}
;
gvjs_.return = function(a) {
    this.Am = {
        return: a
    };
    this.Fi = this.Ws
}
;
function gvjs_zy(a, b, c) {
    a.Fi = c;
    return {
        value: b
    }
}
gvjs_.hh = function(a) {
    this.Fi = a
}
;
function gvjs_Ay(a) {
    this.Sb = new gvjs_xy;
    this.jva = a
}
gvjs_Ay.prototype.bK = function(a) {
    gvjs_yy(this.Sb);
    if (this.Sb.qx)
        return gvjs_By(this, this.Sb.qx.next, a, this.Sb.bK);
    this.Sb.bK(a);
    return gvjs_Cy(this)
}
;
function gvjs_oda(a, b) {
    gvjs_yy(a.Sb);
    var c = a.Sb.qx;
    if (c)
        return gvjs_By(a, "return"in c ? c["return"] : function(d) {
            return {
                value: d,
                done: !0
            }
        }
        , b, a.Sb.return);
    a.Sb.return(b);
    return gvjs_Cy(a)
}
gvjs_Ay.prototype.LL = function(a) {
    gvjs_yy(this.Sb);
    if (this.Sb.qx)
        return gvjs_By(this, this.Sb.qx["throw"], a, this.Sb.bK);
    this.Sb.LL(a);
    return gvjs_Cy(this)
}
;
function gvjs_By(a, b, c, d) {
    try {
        var e = b.call(a.Sb.qx, c);
        if (!(e instanceof Object))
            throw new TypeError("Iterator result " + e + " is not an object");
        if (!e.done)
            return a.Sb.KA(),
            e;
        var f = e.value
    } catch (g) {
        return a.Sb.qx = null,
        a.Sb.LL(g),
        gvjs_Cy(a)
    }
    a.Sb.qx = null;
    d.call(a.Sb, f);
    return gvjs_Cy(a)
}
function gvjs_Cy(a) {
    for (; a.Sb.Fi; )
        try {
            var b = a.jva(a.Sb);
            if (b)
                return a.Sb.KA(),
                {
                    value: b.value,
                    done: !1
                }
        } catch (c) {
            a.Sb.l6 = void 0,
            a.Sb.LL(c)
        }
    a.Sb.KA();
    if (a.Sb.Am) {
        b = a.Sb.Am;
        a.Sb.Am = null;
        if (b.Dba)
            throw b.a$;
        return {
            value: b.return,
            done: !0
        }
    }
    return {
        value: void 0,
        done: !0
    }
}
function gvjs_pda(a) {
    this.next = function(b) {
        return a.bK(b)
    }
    ;
    this.throw = function(b) {
        return a.LL(b)
    }
    ;
    this.return = function(b) {
        return gvjs_oda(a, b)
    }
    ;
    this[Symbol.iterator] = function() {
        return this
    }
}
function gvjs_Dy(a, b) {
    b = new gvjs_pda(new gvjs_Ay(b));
    gvjs_ce && a.prototype && gvjs_ce(b, a.prototype);
    return b
}
function gvjs_Ey(a, b) {
    a: {
        for (var c = typeof a === gvjs_l ? a.split("") : a, d = a.length - 1; 0 <= d; d--)
            if (d in c && b.call(void 0, c[d], d, a)) {
                b = d;
                break a
            }
        b = -1
    }
    return 0 > b ? null : typeof a === gvjs_l ? a.charAt(b) : a[b]
}
function gvjs_Fy(a) {
    if (!Array.isArray(a))
        for (var b = a.length - 1; 0 <= b; b--)
            delete a[b];
    a.length = 0
}
function gvjs_Gy(a, b) {
    gvjs_He(a, b) || a.push(b)
}
function gvjs_Hy(a, b, c, d, e) {
    for (var f = 0, g = a.length, h; f < g; ) {
        var k = f + (g - f >>> 1);
        var l = c ? b.call(e, a[k], k, a) : b(d, a[k]);
        0 < l ? f = k + 1 : (g = k,
        h = !l)
    }
    return h ? f : -f - 1
}
function gvjs_Iy(a, b, c) {
    return gvjs_Hy(a, c || gvjs_Re, !1, b)
}
function gvjs_Jy(a, b) {
    if (!gvjs_ne(a) || !gvjs_ne(b) || a.length != b.length)
        return !1;
    for (var c = a.length, d = 0; d < c; d++)
        if (a[d] !== b[d])
            return !1;
    return !0
}
function gvjs_Ky(a) {
    var b = [];
    if (0 > a - 0)
        return [];
    for (var c = 0; c < a; c += 1)
        b.push(c);
    return b
}
function gvjs_Ly(a) {
    for (var b = [], c = 0; c < arguments.length; c++) {
        var d = arguments[c];
        if (Array.isArray(d))
            for (var e = 0; e < d.length; e += 8192) {
                var f = gvjs_Oe(d, e, e + 8192);
                f = gvjs_Ly.apply(null, f);
                for (var g = 0; g < f.length; g++)
                    b.push(f[g])
            }
        else
            b.push(d)
    }
    return b
}
function gvjs_My(a) {
    if (!arguments.length)
        return [];
    for (var b = [], c = arguments[0].length, d = 1; d < arguments.length; d++)
        arguments[d].length < c && (c = arguments[d].length);
    for (d = 0; d < c; d++) {
        for (var e = [], f = 0; f < arguments.length; f++)
            e.push(arguments[f][d]);
        b.push(e)
    }
    return b
}
function gvjs_Ny(a, b, c) {
    var d = {}, e;
    for (e in a)
        d[e] = b.call(c, a[e], e, a);
    return d
}
function gvjs_Oy(a) {
    for (var b in a)
        return a[b]
}
function gvjs_Py(a) {
    for (var b in a)
        return !1;
    return !0
}
function gvjs_Qy(a, b) {
    b in a && delete a[b]
}
function gvjs_Ry(a, b, c) {
    if (null !== a && b in a)
        throw Error('The object already contains the key "' + b + '"');
    a[b] = c
}
function gvjs_Sy(a, b, c) {
    return null !== a && b in a ? a[b] : c
}
function gvjs_Ty(a, b, c) {
    return b in a ? a[b] : a[b] = c
}
function gvjs_Uy(a) {
    var b = {}, c;
    for (c in a)
        b[a[c]] = c;
    return b
}
var gvjs_qda = /^((https:)?\/\/[0-9a-z.:[\]-]+\/|\/[^/\\]|[^:/\\%]+\/|[^:/\\%]*[?#]|about:blank#)/i
  , gvjs_rda = /%{(\w+)}/g;
function gvjs_sda(a, b) {
    var c = gvjs_8e(a);
    if (!gvjs_qda.test(c))
        throw Error("Invalid TrustedResourceUrl format: " + c);
    a = c.replace(gvjs_rda, function(d, e) {
        if (!Object.prototype.hasOwnProperty.call(b, e))
            throw Error('Found marker, "' + e + '", in format string, "' + c + '", but no valid label mapping found in args: ' + JSON.stringify(b));
        d = b[e];
        return d instanceof gvjs_5e ? gvjs_8e(d) : encodeURIComponent(String(d))
    });
    return gvjs_gf(a)
}
function gvjs_Vy(a, b, c) {
    a = gvjs_sda(a, b);
    a = gvjs_ef(a);
    a = gvjs_kda.exec(a);
    b = a[3] || "";
    return gvjs_gf(a[1] + gvjs_Zx("?", a[2] || "", c) + gvjs_Zx("#", b, void 0))
}
function gvjs_Wy(a, b) {
    if (a instanceof gvjs_vf)
        return a;
    a = typeof a == gvjs_h && a.Po ? a.Tk() : String(a);
    if (b && /^data:/i.test(a) && (b = gvjs_yf(a) || gvjs_Cf,
    b.Tk() == a))
        return b;
    gvjs_Af.test(a) || (a = gvjs_ob);
    return gvjs_zf(a)
}
function gvjs_Xy(a, b, c) {
    a = a instanceof gvjs_vf ? a : gvjs_Wy(a);
    c = c instanceof gvjs_5e ? gvjs_8e(c) : c || "";
    (b || gvjs_p).open(gvjs_xf(a), c)
}
function gvjs_Yy(a) {
    return !/[^0-9]/.test(a)
}
function gvjs_Zy(a) {
    return a.replace(/[\t\r\n ]+/g, " ").replace(/^[\t\r\n ]+|[\t\r\n ]+$/g, "")
}
function gvjs_tda(a) {
    return a.replace(/&([^;]+);/g, function(b, c) {
        switch (c) {
        case "amp":
            return "&";
        case "lt":
            return "<";
        case "gt":
            return ">";
        case "quot":
            return '"';
        default:
            return "#" != c.charAt(0) || (c = Number("0" + c.substr(1)),
            isNaN(c)) ? b : String.fromCharCode(c)
        }
    })
}
var gvjs_uda = /&([^;\s<&]+);?/g;
function gvjs_vda(a) {
    var b = {
        "&amp;": "&",
        "&lt;": "<",
        "&gt;": ">",
        "&quot;": '"'
    };
    var c = gvjs_p.document.createElement(gvjs_Ob);
    return a.replace(gvjs_uda, function(d, e) {
        var f = b[d];
        if (f)
            return f;
        "#" == e.charAt(0) && (e = Number("0" + e.substr(1)),
        isNaN(e) || (f = String.fromCharCode(e)));
        f || (f = gvjs_3f(d + " ", null),
        gvjs_cg(c, f),
        f = c.firstChild.nodeValue.slice(0, -1));
        return b[d] = f
    })
}
function gvjs__y(a) {
    return gvjs_sf(a, "&") ? "document"in gvjs_p ? gvjs_vda(a) : gvjs_tda(a) : a
}
function gvjs_0y(a, b) {
    a.length > b && (a = a.substring(0, b - 3) + gvjs_Kr);
    return a
}
function gvjs_1y(a) {
    for (var b = 0, c = 0; c < a.length; ++c)
        b = 31 * b + a.charCodeAt(c) >>> 0;
    return b
}
function gvjs_2y(a) {
    return String(a).replace(/([A-Z])/g, "-$1").toLowerCase()
}
function gvjs_3y(a, b) {
    a %= b;
    return 0 > a * b ? a + b : a
}
function gvjs_4y(a, b, c) {
    return a + c * (b - a)
}
function gvjs_5y(a) {
    return gvjs_3y(a, 360)
}
function gvjs_6y(a) {
    return a * Math.PI / 180
}
function gvjs_7y(a) {
    return 180 * a / Math.PI
}
function gvjs_8y(a, b) {
    return b * Math.cos(gvjs_6y(a))
}
function gvjs_9y(a, b) {
    return b * Math.sin(gvjs_6y(a))
}
function gvjs_$y(a) {
    return 0 < a ? 1 : 0 > a ? -1 : a
}
function gvjs_az(a) {
    return Array.prototype.reduce.call(arguments, function(b, c) {
        return b + c
    }, 0)
}
function gvjs_bz(a) {
    return gvjs_az.apply(null, arguments) / arguments.length
}
function gvjs_cz(a, b) {
    var c = a.x - b.x;
    a = a.y - b.y;
    return Math.sqrt(c * c + a * a)
}
function gvjs_dz(a, b) {
    return new gvjs_z(a.x - b.x,a.y - b.y)
}
function gvjs_ez(a, b) {
    return new gvjs_z(a.x + b.x,a.y + b.y)
}
function gvjs_fz(a, b) {
    return a == b ? !0 : a && b ? a.width == b.width && a.height == b.height : !1
}
function gvjs_gz(a, b, c) {
    return gvjs_7g(document, a, b, c)
}
function gvjs_4(a, b, c) {
    return gvjs_$g(document, arguments)
}
function gvjs_hz(a, b) {
    for (; b = b.previousSibling; )
        if (b == a)
            return -1;
    return 1
}
function gvjs_iz(a, b) {
    var c = a.parentNode;
    if (c == b)
        return -1;
    for (; b.parentNode != c; )
        b = b.parentNode;
    return gvjs_hz(b, a)
}
function gvjs_wda(a, b) {
    if (a == b)
        return 0;
    if (a.compareDocumentPosition)
        return a.compareDocumentPosition(b) & 2 ? 1 : -1;
    if (gvjs_y && !gvjs_Fg(9)) {
        if (9 == a.nodeType)
            return -1;
        if (9 == b.nodeType)
            return 1
    }
    if ("sourceIndex"in a || a.parentNode && "sourceIndex"in a.parentNode) {
        var c = 1 == a.nodeType
          , d = 1 == b.nodeType;
        if (c && d)
            return a.sourceIndex - b.sourceIndex;
        var e = a.parentNode
          , f = b.parentNode;
        return e == f ? gvjs_hz(a, b) : !c && gvjs_rh(e, b) ? -1 * gvjs_iz(a, b) : !d && gvjs_rh(f, a) ? gvjs_iz(b, a) : (c ? a.sourceIndex : e.sourceIndex) - (d ? b.sourceIndex : f.sourceIndex)
    }
    d = gvjs_5g(a);
    c = d.createRange();
    c.selectNode(a);
    c.collapse(!0);
    a = d.createRange();
    a.selectNode(b);
    a.collapse(!0);
    return c.compareBoundaryPoints(gvjs_p.Range.START_TO_END, a)
}
function gvjs_jz(a, b) {
    b ? a.tabIndex = 0 : (a.tabIndex = -1,
    a.removeAttribute("tabIndex"))
}
function gvjs_kz(a) {
    var b = [];
    gvjs_xh(a, b, !1);
    return b.join("")
}
function gvjs_lz(a, b) {
    return a.left <= b.right && b.left <= a.right && a.top <= b.bottom && b.top <= a.bottom
}
function gvjs_mz(a, b, c) {
    return a.left <= b.right + c && b.left <= a.right + c && a.top <= b.bottom + c && b.top <= a.bottom + c
}
function gvjs_nz(a, b) {
    return a == b ? !0 : a && b ? a.left == b.left && a.width == b.width && a.top == b.top && a.height == b.height : !1
}
function gvjs_5(a, b, c, d) {
    this.left = a;
    this.top = b;
    this.width = c;
    this.height = d
}
gvjs_ = gvjs_5.prototype;
gvjs_.clone = function() {
    return new gvjs_5(this.left,this.top,this.width,this.height)
}
;
function gvjs_oz(a) {
    return new gvjs_B(a.top,a.left + a.width,a.top + a.height,a.left)
}
gvjs_.J_ = function(a) {
    var b = Math.max(this.left, a.left)
      , c = Math.min(this.left + this.width, a.left + a.width);
    if (b <= c) {
        var d = Math.max(this.top, a.top);
        a = Math.min(this.top + this.height, a.top + a.height);
        d <= a && (this.left = b,
        this.top = d,
        this.width = c - b,
        this.height = a - d)
    }
}
;
gvjs_.intersects = function(a) {
    return this.left <= a.left + a.width && a.left <= this.left + this.width && this.top <= a.top + a.height && a.top <= this.top + this.height
}
;
gvjs_.contains = function(a) {
    return a instanceof gvjs_z ? a.x >= this.left && a.x <= this.left + this.width && a.y >= this.top && a.y <= this.top + this.height : this.left <= a.left && this.left + this.width >= a.left + a.width && this.top <= a.top && this.top + this.height >= a.top + a.height
}
;
gvjs_.distance = function(a) {
    var b = a.x < this.left ? this.left - a.x : Math.max(a.x - (this.left + this.width), 0);
    a = a.y < this.top ? this.top - a.y : Math.max(a.y - (this.top + this.height), 0);
    return Math.sqrt(b * b + a * a)
}
;
gvjs_.Tb = function() {
    return new gvjs_A(this.width,this.height)
}
;
gvjs_.getCenter = function() {
    return new gvjs_z(this.left + this.width / 2,this.top + this.height / 2)
}
;
gvjs_.ceil = function() {
    this.left = Math.ceil(this.left);
    this.top = Math.ceil(this.top);
    this.width = Math.ceil(this.width);
    this.height = Math.ceil(this.height);
    return this
}
;
gvjs_.floor = function() {
    this.left = Math.floor(this.left);
    this.top = Math.floor(this.top);
    this.width = Math.floor(this.width);
    this.height = Math.floor(this.height);
    return this
}
;
gvjs_.round = function() {
    this.left = Math.round(this.left);
    this.top = Math.round(this.top);
    this.width = Math.round(this.width);
    this.height = Math.round(this.height);
    return this
}
;
gvjs_.translate = function(a, b) {
    a instanceof gvjs_z ? (this.left += a.x,
    this.top += a.y) : (this.left += a,
    typeof b === gvjs_g && (this.top += b));
    return this
}
;
gvjs_.scale = function(a, b) {
    b = typeof b === gvjs_g ? b : a;
    this.left *= a;
    this.width *= a;
    this.top *= b;
    this.height *= b;
    return this
}
;
function gvjs_pz(a) {
    return new gvjs_5(a.left,a.top,a.right - a.left,a.bottom - a.top)
}
function gvjs_qz(a, b) {
    var c = a.style[gvjs_kg(b)];
    return "undefined" !== typeof c ? c : a.style[gvjs_Ah(a, b)] || ""
}
function gvjs_rz(a, b) {
    typeof a == gvjs_g && (a = (b ? Math.round(a) : a) + gvjs_T);
    return a
}
function gvjs_sz(a, b, c) {
    if (b instanceof gvjs_z) {
        var d = b.x;
        b = b.y
    } else
        d = b,
        b = c;
    a.style.left = gvjs_rz(d, !1);
    a.style.top = gvjs_rz(b, !1)
}
function gvjs_tz(a) {
    a = a ? gvjs_5g(a) : document;
    return !gvjs_y || gvjs_Fg(9) || gvjs_eh(gvjs_3g(a).dd) ? a.documentElement : a.body
}
function gvjs_uz(a) {
    try {
        return a.getBoundingClientRect()
    } catch (b) {
        return {
            left: 0,
            top: 0,
            right: 0,
            bottom: 0
        }
    }
}
function gvjs_xda(a) {
    if (gvjs_y && !gvjs_Fg(8))
        return a.offsetParent;
    var b = gvjs_5g(a)
      , c = gvjs_Dh(a, gvjs_vd)
      , d = c == gvjs_wu || c == gvjs_c;
    for (a = a.parentNode; a && a != b; a = a.parentNode)
        if (11 == a.nodeType && a.host && (a = a.host),
        c = gvjs_Dh(a, gvjs_vd),
        d = d && "static" == c && a != b.documentElement && a != b.body,
        !d && (a.scrollWidth > a.clientWidth || a.scrollHeight > a.clientHeight || c == gvjs_wu || c == gvjs_c || c == gvjs_zd))
            return a;
    return null
}
function gvjs_vz(a) {
    var b = gvjs_5g(a)
      , c = new gvjs_z(0,0)
      , d = gvjs_tz(b);
    if (a == d)
        return c;
    a = gvjs_uz(a);
    b = gvjs_2x(gvjs_3g(b).dd);
    c.x = a.left + b.x;
    c.y = a.top + b.y;
    return c
}
function gvjs_wz(a) {
    for (var b = new gvjs_B(0,Infinity,Infinity,0), c = gvjs_3g(a), d = c.kc().body, e = c.kc().documentElement, f = gvjs_1x(c.dd); a = gvjs_xda(a); )
        if (!(gvjs_y && 0 == a.clientWidth || gvjs_tg && 0 == a.clientHeight && a == d) && a != d && a != e && gvjs_Dh(a, "overflow") != gvjs_Mx) {
            var g = gvjs_vz(a)
              , h = new gvjs_z(a.clientLeft,a.clientTop);
            g.x += h.x;
            g.y += h.y;
            b.top = Math.max(b.top, g.y);
            b.right = Math.min(b.right, g.x + a.clientWidth);
            b.bottom = Math.min(b.bottom, g.y + a.clientHeight);
            b.left = Math.max(b.left, g.x)
        }
    d = f.scrollLeft;
    f = f.scrollTop;
    b.left = Math.max(b.left, d);
    b.top = Math.max(b.top, f);
    c = c.Vj();
    c = gvjs_0x(c || window);
    b.right = Math.min(b.right, d + c.width);
    b.bottom = Math.min(b.bottom, f + c.height);
    return 0 <= b.top && 0 <= b.left && b.bottom > b.top && b.right > b.left ? b : null
}
function gvjs_xz(a) {
    var b = a.offsetWidth
      , c = a.offsetHeight
      , d = gvjs_tg && !b && !c;
    return (void 0 === b || d) && a.getBoundingClientRect ? (a = gvjs_uz(a),
    new gvjs_A(a.right - a.left,a.bottom - a.top)) : new gvjs_A(b,c)
}
function gvjs_yz(a) {
    a = gvjs_uz(a);
    return new gvjs_z(a.left,a.top)
}
function gvjs_zz(a) {
    if (1 == a.nodeType)
        return gvjs_yz(a);
    a = a.changedTouches ? a.changedTouches[0] : a;
    return new gvjs_z(a.clientX,a.clientY)
}
function gvjs_Az(a, b) {
    a = gvjs_zz(a);
    b = gvjs_zz(b);
    return new gvjs_z(a.x - b.x,a.y - b.y)
}
function gvjs_Bz(a, b) {
    a.style.width = gvjs_rz(b, !0)
}
function gvjs_Cz(a, b, c) {
    if (b instanceof gvjs_A)
        c = b.height,
        b = b.width;
    else if (void 0 == c)
        throw Error("missing height argument");
    gvjs_Bz(a, b);
    a.style.height = gvjs_rz(c, !0)
}
function gvjs_Dz(a) {
    if (gvjs_Dh(a, gvjs_ku) != gvjs_f)
        return gvjs_xz(a);
    var b = a.style
      , c = b.display
      , d = b.visibility
      , e = b.position;
    b.visibility = gvjs_0u;
    b.position = gvjs_c;
    b.display = gvjs_ev;
    a = gvjs_xz(a);
    b.display = c;
    b.position = e;
    b.visibility = d;
    return a
}
function gvjs_Ez(a) {
    var b = gvjs_vz(a);
    a = gvjs_Dz(a);
    return new gvjs_5(b.x,b.y,a.width,a.height)
}
function gvjs_Fz(a, b) {
    a = a.style;
    gvjs_Kp in a ? a.opacity = b : "MozOpacity"in a ? a.MozOpacity = b : gvjs_tp in a && (a.filter = "" === b ? "" : "alpha(opacity=" + 100 * Number(b) + ")")
}
function gvjs_6(a, b) {
    a.style.display = b ? "" : gvjs_f
}
function gvjs_Gz(a) {
    return gvjs_Up == gvjs_Dh(a, gvjs_iu)
}
function gvjs_Hz(a, b, c) {
    c = c ? null : a.getElementsByTagName("*");
    if (gvjs_Fh) {
        if (b = b ? gvjs_f : "",
        a.style && (a.style[gvjs_Fh] = b),
        c) {
            a = 0;
            for (var d; d = c[a]; a++)
                d.style && (d.style[gvjs_Fh] = b)
        }
    } else if (gvjs_y || gvjs_qg)
        if (b = b ? "on" : "",
        a.setAttribute(gvjs_zx, b),
        c)
            for (a = 0; d = c[a]; a++)
                d.setAttribute(gvjs_zx, b)
}
function gvjs_Iz(a, b) {
    b = b || gvjs_1x(document);
    var c = b || gvjs_1x(document);
    var d = gvjs_vz(a)
      , e = gvjs_vz(c)
      , f = gvjs_Jh(c);
    if (c == gvjs_1x(document)) {
        var g = d.x - c.scrollLeft;
        d = d.y - c.scrollTop;
        gvjs_y && !gvjs_Fg(10) && (g += f.left,
        d += f.top)
    } else
        g = d.x - e.x - f.left,
        d = d.y - e.y - f.top;
    a = gvjs_xz(a);
    f = c.clientHeight - a.height;
    e = c.scrollLeft;
    var h = c.scrollTop;
    e += Math.min(g, Math.max(g - (c.clientWidth - a.width), 0));
    h += Math.min(d, Math.max(d - f, 0));
    c = new gvjs_z(e,h);
    b.scrollLeft = c.x;
    b.scrollTop = c.y
}
function gvjs_Jz(a) {
    var b = {};
    a.split(/\s*;\s*/).forEach(function(c) {
        var d = c.match(/\s*([\w-]+)\s*:(.+)/);
        d && (c = d[1],
        d = gvjs_kf(d[2]),
        b[gvjs_kg(c.toLowerCase())] = d)
    });
    return b
}
function gvjs_Kz(a) {
    var b = [];
    gvjs_w(a, function(c, d) {
        b.push(gvjs_2y(d), ":", c, ";")
    });
    return b.join("")
}
function gvjs_Lz(a) {
    a.preventDefault()
}
var gvjs_Mz = {
    ux: gvjs_gd,
    wx: gvjs_md,
    mB: "mousecancel",
    Yia: gvjs_jd,
    $ia: gvjs_ld,
    Zia: gvjs_kd,
    Wia: gvjs_hd,
    Xia: gvjs_id
};
function gvjs_Nz(a, b) {
    return a.getTime() - b.getTime()
}
function gvjs_Oz(a) {
    if (a instanceof gvjs_5i)
        return a;
    if (typeof a.xk == gvjs_d)
        return a.xk(!1);
    if (gvjs_ne(a)) {
        var b = 0
          , c = new gvjs_5i;
        c.rg = function() {
            for (; ; ) {
                if (b >= a.length)
                    throw gvjs_4i;
                if (b in a)
                    return a[b++];
                b++
            }
        }
        ;
        c.next = c.rg.bind(c);
        return c
    }
    throw Error("Not implemented");
}
function gvjs_Pz(a, b, c) {
    if (gvjs_ne(a))
        try {
            gvjs_u(a, b, c)
        } catch (d) {
            if (d !== gvjs_4i)
                throw d;
        }
    else {
        a = gvjs_Oz(a);
        try {
            for (; ; )
                b.call(c, a.next(), void 0, a)
        } catch (d) {
            if (d !== gvjs_4i)
                throw d;
        }
    }
}
function gvjs_Qz(a, b, c) {
    var d = 0
      , e = a
      , f = c || 1;
    1 < arguments.length && (d = a,
    e = +b);
    if (0 == f)
        throw Error("Range step argument must not be zero");
    var g = new gvjs_5i;
    g.rg = function() {
        if (0 < f && d >= e || 0 > f && d <= e)
            throw gvjs_4i;
        var h = d;
        d += f;
        return h
    }
    ;
    g.next = g.rg.bind(g);
    return g
}
function gvjs_yda(a) {
    var b = gvjs_Oz(a);
    a = new gvjs_5i;
    var c = null;
    a.rg = function() {
        for (; ; ) {
            if (null == c) {
                var d = b.next();
                c = gvjs_Oz(d)
            }
            try {
                return c.next()
            } catch (e) {
                if (e !== gvjs_4i)
                    throw e;
                c = null
            }
        }
    }
    ;
    a.next = a.rg.bind(a);
    return a
}
function gvjs_Rz(a) {
    return gvjs_yda(arguments)
}
function gvjs_zda(a, b) {
    a = [a];
    for (var c = b.length - 1; 0 <= c; --c)
        a.push(typeof b[c], b[c]);
    return a.join("\x0B")
}
function gvjs_Sz(a) {
    this.JJ = Math.max(1, a || Infinity);
    this.cache = new Map
}
gvjs_ = gvjs_Sz.prototype;
gvjs_.rwa = function(a) {
    this.JJ = Math.max(a, 1);
    null != this.JJ && this.truncate(this.JJ)
}
;
gvjs_.clear = function() {
    this.cache.clear()
}
;
gvjs_.contains = function(a) {
    return this.cache.has(a)
}
;
gvjs_.get = function(a) {
    var b = this.cache.get(a);
    if ("undefined" === typeof b)
        throw Error('Cache does not contain key "' + a + '"');
    this.cache.delete(a);
    this.cache.set(a, b);
    return b
}
;
gvjs_.put = function(a, b) {
    this.cache.delete(a);
    if ("undefined" !== typeof b)
        return this.cache.set(a, b),
        null != this.JJ && this.truncate(this.JJ),
        b
}
;
gvjs_.size = function() {
    return this.cache.size
}
;
gvjs_.truncate = function(a) {
    for (var b = gvjs_8d(this.cache), c = b.next(); !c.done; c = b.next()) {
        c = gvjs_8d(c.value).next().value;
        if (this.cache.size <= a)
            break;
        this.cache.delete(c)
    }
}
;
function gvjs_Tz(a, b) {
    b = void 0 === b ? {} : b;
    var c = b.gT || gvjs_zda
      , d = b.size || 1E3
      , e = b.cache || new gvjs_Sz(d);
    return Object.assign(function(f) {
        for (var g = [], h = 0; h < arguments.length; ++h)
            g[h - 0] = arguments[h];
        h = c(gvjs_pe(a), [].concat(gvjs_9d(g)));
        return e.contains(h) ? e.get(h) : e.put(h, a.apply(null, gvjs_9d(g)))
    }, {
        clear: function() {
            e.clear()
        },
        rwa: function(f) {
            e.clear();
            e = b.cache || new gvjs_Sz(f)
        }
    })
}
function gvjs_Uz(a, b) {
    if (null == a && null == b)
        return a === b;
    if (a === b)
        return !0;
    var c = gvjs_me(a)
      , d = gvjs_me(b);
    if (c !== d)
        return !1;
    d = gvjs_oe(a);
    var e = gvjs_oe(b);
    if (d !== e)
        return !1;
    switch (c) {
    case gvjs_h:
        if (d && e)
            return 0 === gvjs_Nz(a, b);
        for (var f in a)
            if (a.hasOwnProperty(f) && (!b.hasOwnProperty(f) || !gvjs_Uz(a[f], b[f])))
                return !1;
        for (var g in b)
            if (b.hasOwnProperty(g) && !a.hasOwnProperty(g))
                return !1;
        return !0;
    case gvjs_sb:
        if (a.length !== b.length)
            return !1;
        for (c = 0; c < a.length; ++c)
            if (!gvjs_Uz(a[c], b[c]))
                return !1;
        return !0;
    case gvjs_d:
        return !0;
    case gvjs_l:
    case gvjs_g:
    case gvjs_zb:
        return !1;
    default:
        throw Error("Error while comparing " + a + gvjs_br + b + ": unexpected type of obj1 " + c);
    }
}
function gvjs_Vz(a, b) {
    function c(d, e, f) {
        for (var g in d)
            d.hasOwnProperty(g) && (typeof d[g] === gvjs_h ? c(d[g], e, f) : b.call(void 0, d[g], g, d) && f.push(d[g]));
        return f
    }
    return c(a, gvjs_Tz(b), [])
}
function gvjs_Wz(a, b) {
    var c = gvjs_me(a);
    b = (31 * b + gvjs_1y(c)) % 67108864;
    switch (c) {
    case gvjs_h:
        if (a.constructor === Date)
            b = (31 * b + gvjs_1y(gvjs_Lb)) % 67108864,
            b = gvjs_Wz(a.getTime(), b);
        else {
            c = gvjs_Ye(a);
            gvjs_Qe(c);
            c = gvjs_lq(c);
            for (var d in c)
                c.hasOwnProperty(d) && (b = gvjs_Wz(a[d], gvjs_Wz(d, b)))
        }
        break;
    case gvjs_sb:
        for (d = 0; d < a.length; d++)
            b = gvjs_Wz(a[d], gvjs_Wz(String(d), b));
        break;
    default:
        b = (31 * b + gvjs_1y(String(a))) % 67108864
    }
    return b
}
function gvjs_Xz(a, b) {
    return a.size === b.size && [].concat(gvjs_9d(gvjs_nj(a))).every(function(c) {
        return b.has(c)
    })
}
function gvjs_Yz(a, b) {
    var c = new Set(a);
    b = gvjs_nj(b);
    for (var d = 0; d < b.length; d++) {
        var e = b[d];
        a.has(e) && c.delete(e)
    }
    return c
}
function gvjs_Zz(a, b, c) {
    0 > c ? c += 1 : 1 < c && --c;
    return 1 > 6 * c ? a + 6 * (b - a) * c : 1 > 2 * c ? b : 2 > 3 * c ? a + (b - a) * (2 / 3 - c) * 6 : a
}
function gvjs__z(a, b, c) {
    a /= 360;
    if (0 == b)
        c = b = a = 255 * c;
    else {
        var d = .5 > c ? c * (1 + b) : c + b - b * c;
        var e = 2 * c - d;
        c = 255 * gvjs_Zz(e, d, a + 1 / 3);
        b = 255 * gvjs_Zz(e, d, a);
        a = 255 * gvjs_Zz(e, d, a - 1 / 3)
    }
    return [Math.round(c), Math.round(b), Math.round(a)]
}
function gvjs_0z(a) {
    return !!(gvjs_rj.test("#" == a.charAt(0) ? a : "#" + a) || gvjs_tj(a).length || gvjs_pj && gvjs_pj[a.toLowerCase()])
}
function gvjs_1z(a, b) {
    return gvjs_xj([0, 0, 0], a, b)
}
function gvjs_2z(a, b) {
    return gvjs_xj([255, 255, 255], a, b)
}
function gvjs_Ada(a, b) {
    return Math.abs(a[0] - b[0]) + Math.abs(a[1] - b[1]) + Math.abs(a[2] - b[2])
}
function gvjs_3z(a) {
    return Math.round((299 * a[0] + 587 * a[1] + 114 * a[2]) / 1E3)
}
function gvjs_4z(a, b) {
    for (var c = [], d = 0; d < b.length; d++)
        c.push({
            color: b[d],
            Ih: Math.abs(gvjs_3z(b[d]) - gvjs_3z(a)) + gvjs_Ada(b[d], a)
        });
    c.sort(function(e, f) {
        return f.Ih - e.Ih
    });
    return c[0].color
}
function gvjs_5z(a, b) {
    a && (a.logicalname = b)
}
function gvjs_6z(a) {
    return (a = gvjs_yh(a, function(b) {
        return null != b.logicalname
    }, !0)) ? a.logicalname : gvjs_Bs
}
function gvjs_7z(a, b, c) {
    return a && a !== gvjs_f ? b && b !== gvjs_f ? gvjs_uj(gvjs_xj(gvjs_vj(a), gvjs_vj(b), c)) : a : b
}
function gvjs_Bda(a, b) {
    a = gvjs_4x(a.dd, b);
    var c = [];
    a.hasAttribute(gvjs_au) && c.push(a);
    Array.from(a.querySelectorAll("[data-logicalname]")).forEach(function(d) {
        c.push(d)
    });
    c.forEach(function(d) {
        var e = d.getAttribute(gvjs_au);
        gvjs_5z(d, e)
    });
    return a
}
function gvjs_8z(a, b) {
    return new gvjs_3({
        stroke: gvjs_f,
        fill: a,
        fillOpacity: void 0 === b ? 1 : b
    })
}
function gvjs_9z(a, b, c, d) {
    return new gvjs_3({
        stroke: a,
        strokeWidth: b,
        strokeOpacity: null != d ? d : 1,
        fill: null != c && c ? gvjs_Br : gvjs_f
    })
}
function gvjs_$z(a, b) {
    return a === b ? !0 : null === a || null === b ? !1 : a.equals(b)
}
function gvjs_aA(a, b) {
    var c = gvjs_mk.lastIndexOf(".");
    if (0 > a || 0 >= b)
        return gvjs_mk.substr(0, c);
    a > b && (b = gvjs_8d([b, a]),
    a = b.next().value,
    b = b.next().value);
    c = gvjs_mk.substr(0, c + 1);
    a = "0".repeat(a) + "#".repeat(b - a);
    return c + a
}
function gvjs_bA(a, b, c, d) {
    this.x0 = a;
    this.y0 = b;
    this.x1 = c;
    this.y1 = d
}
gvjs_bA.prototype.clone = function() {
    return new gvjs_bA(this.x0,this.y0,this.x1,this.y1)
}
;
gvjs_bA.prototype.equals = function(a) {
    return this.x0 == a.x0 && this.y0 == a.y0 && this.x1 == a.x1 && this.y1 == a.y1
}
;
function gvjs_cA(a) {
    var b = a.x1 - a.x0;
    a = a.y1 - a.y0;
    return b * b + a * a
}
function gvjs_dA(a, b) {
    return new gvjs_z(gvjs_4y(a.x0, a.x1, b),gvjs_4y(a.y0, a.y1, b))
}
function gvjs_eA(a, b) {
    return new gvjs_ok(a.x + b.x,a.y + b.y)
}
function gvjs_fA(a, b) {
    return new gvjs_ok(a.x - b.x,a.y - b.y)
}
function gvjs_gA(a) {
    return null == a || "" === a ? null : Number(a)
}
function gvjs_Cda(a, b) {
    return Math.abs(a - b)
}
function gvjs_hA(a, b, c) {
    if (!a || !b)
        return !0;
    c = c || gvjs_Cda;
    return gvjs_Ve(a, function(d, e) {
        var f = b[e];
        return void 0 === b[e] || .05 >= c(d, f)
    })
}
function gvjs_Dda(a, b, c) {
    if (0 === a.x || 0 === b.x)
        return {
            x: 0,
            y: (0 === a.x && 0 === b.x ? 0 : 0 === a.x ? a.y : b.y) * c / 6
        };
    c = c / 3 * Math.min(Math.abs(a.x), Math.abs(b.x));
    b = (a.y / a.x + b.y / b.x) / 2;
    return 0 < a.x ? {
        x: c,
        y: c * b
    } : {
        x: -c,
        y: -c * b
    }
}
function gvjs_Eda(a, b, c) {
    var d = Math.hypot(a.x, a.y)
      , e = Math.hypot(b.x, b.y);
    if (0 === d || 0 === e)
        return new gvjs_ok(0,0);
    d = Math.sqrt(d / e);
    a = gvjs_eA(a.clone().scale(1 / d), b.clone().scale(d));
    a.scale(c / 6);
    return a
}
function gvjs_iA(a, b, c, d) {
    var e = b + c;
    for (d && (e = (e + a.length) % a.length); e !== b && 0 <= e && e < a.length; ) {
        if (null != a[e])
            return e;
        e += c;
        d && (e = (e + a.length) % a.length)
    }
    return null
}
function gvjs_jA(a, b, c, d, e) {
    c = c ? gvjs_Dda : gvjs_Eda;
    for (var f = [], g = 0; g < a.length; ++g) {
        if (e) {
            var h = gvjs_iA(a, g, 1, d);
            var k = gvjs_iA(a, g, -1, d)
        } else
            h = d ? (g + 1) % a.length : g + 1,
            k = d ? (a.length + g - 1) % a.length : g - 1;
        null != h && null != k && null != a[g] && null != a[k] && null != a[h] ? (h = c(gvjs_fA(a[g], a[k]), gvjs_fA(a[h], a[g]), b),
        f.push([gvjs_fA(a[g], h), gvjs_eA(a[g], h)])) : null != a[g] ? f.push([a[g].clone(), a[g].clone()]) : f.push(null)
    }
    return f
}
function gvjs_kA(a, b, c) {
    c = void 0 === c ? 0 : c;
    var d = gvjs_Xx(b, function(e) {
        return e[c] > a
    });
    return -1 === d ? b.length - 1 : 0 === d ? 0 : b[d][c] - a < a - b[d - 1][c] ? d : d - 1
}
function gvjs_Fda(a, b, c) {
    c = void 0 === c ? 0 : c;
    var d = void 0 === d ? 0 : d;
    if (0 < b.length && a <= gvjs_Ae(b)[d])
        return c = gvjs_kA(a, b, d),
        [c, b[c][d]];
    var e = b.length - 1 - c
      , f = gvjs_Ae(b)[d]
      , g = b[e][d]
      , h = f - g
      , k = Math.floor((a - f) / h);
    a = a - f - k * h;
    e = gvjs_v(gvjs_Oe(b, e), function(l) {
        return [l[d] - g]
    });
    a = gvjs_kA(a, e, 0);
    return [b.length - 1 + k * c + a, f + k * h + e[a][0]]
}
function gvjs_lA(a, b) {
    for (var c = [], d = 0; d < a; d++)
        c[d] = b.call(void 0, d);
    return c
}
function gvjs_mA(a) {
    return null != a.max ? a.max : a.min
}
function gvjs_Gda(a, b, c, d) {
    void 0 === c && (c = 0);
    void 0 === d && (d = a.length);
    c = b - c;
    for (var e = 0, f = 0 <= c ? 0 : null, g = 0, h = 0, k = null, l = null; e < a.length; ) {
        var m = a[e].min
          , n = gvjs_mA(a[e]) - m;
        g += m;
        g <= c && (f = e + 1,
        l = Math.min(c - g, n),
        h = g + l,
        l = m + l);
        if (g > b)
            return e >= d ? {
                B1: e,
                e0: k,
                LK: b - (g - m)
            } : null == f ? null : {
                B1: f,
                e0: l,
                LK: c - h
            };
        k = Math.min(b - g, n);
        g += k;
        k = m + k;
        e++
    }
    return {
        B1: e,
        e0: k,
        LK: b - g
    }
}
function gvjs_Hda(a, b, c) {
    c = c || gvjs_Wx;
    a = gvjs_v(a, c);
    gvjs_Qe(a);
    for (var d = c = 0; d < a.length; d++) {
        var e = a.length - d
          , f = (a[d] - c) * e;
        if (f <= b)
            c = a[d],
            b -= f;
        else {
            c += b / e;
            b = 0;
            break
        }
    }
    return {
        bza: c,
        LK: b
    }
}
function gvjs_nA(a, b, c, d) {
    var e = gvjs_Gda(a, b, c, d);
    if (!e)
        return null;
    b = e.LK;
    c = gvjs_Oe(a, 0, e.B1);
    d = gvjs_Ee(c, function(k, l) {
        return Math.max(k, l.extra.length)
    }, 0);
    var f = gvjs_v(c, gvjs_mA);
    0 < f.length && (f[f.length - 1] = e.e0);
    for (e = {
        kB: 0
    }; e.kB < d; e = {
        kB: e.kB
    },
    e.kB++) {
        var g = gvjs_Hda(c, b, function(k) {
            return function(l) {
                return l.extra[k.kB] || 0
            }
        }(e));
        b = g.LK;
        for (var h = 0; h < f.length; h++)
            f[h] += Math.min(g.bza, a[h].extra[e.kB] || 0);
        if (0 === b)
            break
    }
    return f
}
function gvjs_oA(a, b) {
    var c = gvjs_nA(a, b, void 0, void 0)
      , d = {};
    null != c && gvjs_u(a, function(e, f) {
        e = e.key;
        null == d[e] && (d[e] = []);
        f < c.length && d[e].push(c[f])
    });
    return d
}
function gvjs_Ida(a, b) {
    for (var c = 1; c < arguments.length; ++c)
        ;
    c = Array.prototype.slice.call(arguments, 1);
    for (var d = [], e = 0; e < c.length; e += 2) {
        var f = gvjs_Oe(a, Math.min(c[e], a.length), Math.min(c[e + 1], a.length));
        gvjs_Me(d, f)
    }
    return d
}
function gvjs_pA(a) {
    if (0 === a)
        return 0;
    a = Math.abs(a);
    for (var b = 0; 16 > b; ++b) {
        if (Math.abs(a - Math.round(a)) < 1E-15 * a)
            return b;
        a *= 10
    }
    return 16
}
function gvjs_qA(a, b) {
    if (0 === b || 1E-290 > Math.abs(b))
        return b;
    var c = Math.floor(Math.log10(Math.abs(b))) + 1;
    if (c > a)
        return a = Math.pow(10, c - a),
        Math.round(b / a) * a;
    a = Math.pow(10, a - c);
    return Math.round(b * a) / a
}
function gvjs_rA(a, b, c) {
    return 0 > b || 0 > c ? null : a[b][c]
}
function gvjs_Jda(a, b, c, d, e, f) {
    var g = []
      , h = gvjs_rA(c, d - 1, e);
    h && g.push({
        gS: h,
        kr: h.kr + 1,
        rJ: d - 1,
        SU: null,
        sJ: null,
        TU: null
    });
    (h = gvjs_rA(c, d, e - 1)) && g.push({
        gS: h,
        kr: h.kr + 1,
        rJ: null,
        SU: null,
        sJ: e - 1,
        TU: null
    });
    (c = gvjs_rA(c, d - 1, e - 1)) && f(a[d - 1], b[e - 1]) && g.push({
        gS: c,
        kr: c.kr,
        rJ: d - 1,
        SU: e - 1,
        sJ: e - 1,
        TU: d - 1
    });
    gvjs_Qe(g, function(k, l) {
        return k.kr - l.kr
    });
    return 0 < g.length ? g[0] : {
        gS: null,
        kr: 0,
        rJ: null,
        SU: null,
        sJ: null,
        TU: null
    }
}
function gvjs_sA(a, b, c) {
    c = c || function(k, l) {
        return k === l
    }
    ;
    for (var d = [], e = a.length, f = b.length, g = 0; g <= e; g++) {
        d[g] = d[g] || [];
        for (var h = 0; h <= f; h++)
            d[g][h] = gvjs_Jda(a, b, d, g, h, c)
    }
    a = {};
    b = {};
    d = d[e][f];
    for (e = d.kr; d; )
        null != d.rJ && (a[d.rJ] = d.SU),
        null != d.sJ && (b[d.sJ] = d.TU),
        d = d.gS;
    return {
        kr: e,
        vca: a,
        wca: b
    }
}
function gvjs_Kda(a, b, c) {
    function d(n, p, q) {
        if (null == q)
            return 0;
        if (q === p.length - 1 || null == n)
            return q;
        var r = c(p[q]);
        if (null == r)
            return q + 1;
        p = c(p[q + 1]);
        return null == p ? q : Math.abs(n - r) <= Math.abs(n - p) ? q : q + 1
    }
    if (!a || !b || 0 === a.length || 0 === b.length)
        return null;
    var e = [];
    c || (c = gvjs_Wx);
    for (var f = 0, g = 0, h, k; f < a.length || g < b.length; )
        f < a.length && (h = c(a[f])),
        g < b.length && (k = c(b[g])),
        f < a.length && g < b.length && h === k ? (e.push({
            value: h,
            yB: f,
            zB: g
        }),
        f++,
        g++) : f < a.length && (null == h || g === b.length || h < k) ? (e.push({
            value: h,
            yB: f,
            zB: void 0
        }),
        f++) : g < b.length && (null == k || f === a.length || k < h) && (e.push({
            value: k,
            yB: void 0,
            zB: g
        }),
        g++);
    var l = null
      , m = null;
    gvjs_u(e, function(n) {
        null == n.yB ? n.yB = d(n.value, a, l) : l = n.yB;
        null == n.zB ? n.zB = d(n.value, b, m) : m = n.zB
    });
    return e
}
function gvjs_tA(a, b) {
    for (var c in a)
        if (!gvjs_He(b, c))
            return !1;
    return !0
}
function gvjs_uA(a, b, c, d) {
    var e = {};
    gvjs_w(a, function(f, g) {
        for (var h = 0; h < b.length; h++) {
            var k = (0,
            b[h])(a, g, d);
            f = c(f, k)
        }
        e[g] = f
    });
    return e
}
function gvjs_Lda(a, b, c, d) {
    for (var e = 1, f = 0; 1E3 > f; f++) {
        var g = gvjs_uA(a, b, c, e)
          , h = gvjs_uA(a, b, c, 0)
          , k = gvjs_hA(a, g, d);
        h = gvjs_hA(a, h, d);
        if (k && h)
            break;
        a = g;
        e *= .99
    }
    return a
}
function gvjs_vA(a, b) {
    var c = gvjs_Iy(a, b, function(e, f) {
        return gvjs_Re(e, f.x)
    });
    if (0 <= c)
        return a[c].y;
    var d = -(c + 1);
    if (0 === d || d === a.length)
        return null;
    c = a[d - 1];
    a = a[d];
    return gvjs_dA(new gvjs_bA(c.x,c.y,a.x,a.y), (b - c.x) / (a.x - c.x)).y
}
function gvjs_wA(a, b, c) {
    if (c)
        return gvjs_vA(gvjs_De(a, function(e) {
            return null != e
        }), b);
    var d = -1;
    for (c = 0; c < a.length; c++)
        if (null == a[c]) {
            d = gvjs_Oe(a, d + 1, c);
            d = gvjs_vA(d, b);
            if (null !== d)
                return d;
            d = c
        }
    a = gvjs_Oe(a, d + 1);
    return gvjs_vA(a, b)
}
var gvjs_xA = "Milliseconds Seconds Minutes Hours Date Month FullYear".split(" ")
  , gvjs_Mda = [0, 0, 0, 0, 1, 0, 0];
function gvjs_yA(a, b) {
    for (var c = new Date(a.getTime()), d = !1, e = b.length, f = Math.floor, g = 0; g < e; ++g) {
        var h = a["set" + gvjs_xA[g]]
          , k = a["get" + gvjs_xA[g]].apply(a)
          , l = b[g]
          , m = gvjs_Mda[g];
        if (0 === l)
            d = d || 0 !== k && !1,
            h.apply(c, [m]);
        else {
            d ? h.apply(c, [m + l * (1 + Math.floor((k - m) / l))]) : h.apply(c, [m + l * f((k - m) / l)]);
            break
        }
    }
    return c
}
var gvjs_Nda = [500, 30, 30, 12, 15, 6, 0];
function gvjs_Oda(a, b) {
    var c = Math.round, d = gvjs_Le(a), e;
    for (e = 0; e < d.length && 0 === b[e]; ++e)
        d[e] = 0;
    if (0 === e)
        return d[0] = c(a[0] / b[0]) * b[0],
        d;
    var f = 0;
    a[e - 1] >= gvjs_Nda[e - 1] ? f = .7 : 0 < a[e - 1] && (f = .1);
    d[e] = c((a[e] + f) / b[e]) * b[e];
    return d
}
function gvjs_zA(a, b) {
    a = new Date(a.getTime());
    var c;
    a: {
        for (c = 0; c < b.length; ++c)
            if (0 !== b[c]) {
                c = !1;
                break a
            }
        c = !0
    }
    if (c)
        return a;
    for (c = 0; c < b.length; ++c)
        if (0 !== b[c]) {
            var d = gvjs_xA[c]
              , e = a["set" + d];
            d = a["get" + d].apply(a, []);
            e.apply(a, [d + -1 * b[c]])
        }
    return a
}
function gvjs_AA(a, b, c, d) {
    this.tY = b;
    this.ova = d;
    this.fga = a.getTime();
    this.A5 = a["get" + gvjs_xA[c]].apply(a, []);
    this.Lwa = a["set" + gvjs_xA[c]];
    this.Qz = new Date(this.fga)
}
gvjs_AA.prototype.next = function() {
    var a = this.Qz;
    this.Qz = new Date(this.fga);
    this.A5 += this.ova;
    this.Lwa.apply(this.Qz, [this.A5]);
    return a
}
;
gvjs_AA.prototype.peek = function() {
    return this.Qz <= this.tY ? this.Qz : null
}
;
function gvjs_BA(a) {
    a = gvjs_Xx(a, function(b) {
        return 0 !== b
    });
    return Math.max(0, a)
}
var gvjs_CA = [1, 1E3, 6E4, 36E5, 864E5, 2629743830, 31556926E3];
function gvjs_DA(a) {
    for (var b = [], c = gvjs_CA.length - 1; 0 <= c; c--)
        b[c] = Math.floor(a / gvjs_CA[c]),
        a -= b[c] * gvjs_CA[c];
    return b
}
function gvjs_EA(a) {
    if (null == a)
        return -1;
    for (var b = 0, c = a.length, d = 0; d < c; ++d)
        b += a[d] * gvjs_CA[d];
    return b
}
function gvjs_FA(a, b, c) {
    var d = gvjs_v(b, function(e) {
        return [Math.log(gvjs_EA(e))]
    });
    if (!c)
        return d = gvjs_kA(Math.log(a), d),
        b[d];
    a = gvjs_Fda(Math.log(a), d, c);
    c = a[0];
    return c <= d.length - 1 ? b[c] : gvjs_Oda(gvjs_DA(Math.exp(a[1])), gvjs_Ae(b))
}
function gvjs_GA(a) {
    a = gvjs_pk(a);
    return gvjs_EA(a)
}
function gvjs_Pda(a, b) {
    return gvjs_v(a, function(c) {
        return c * b
    })
}
var gvjs_HA = [[1], [0, 1], [0, 0, 1], [0, 0, 0, 1], [0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1]];
function gvjs_IA(a, b) {
    gvjs_H.call(this);
    this.Zv = a || 1;
    this.ML = b || gvjs_p;
    this.R7 = gvjs_s(this.Y4, this);
    this.zJ = gvjs_se()
}
gvjs_t(gvjs_IA, gvjs_H);
gvjs_ = gvjs_IA.prototype;
gvjs_.enabled = !1;
gvjs_.Hc = null;
gvjs_.setInterval = function(a) {
    this.Zv = a;
    this.Hc && this.enabled ? (this.stop(),
    this.start()) : this.Hc && this.stop()
}
;
gvjs_.Y4 = function() {
    if (this.enabled) {
        var a = gvjs_se() - this.zJ;
        0 < a && a < .8 * this.Zv ? this.Hc = this.ML.setTimeout(this.R7, this.Zv - a) : (this.Hc && (this.ML.clearTimeout(this.Hc),
        this.Hc = null),
        this.dispatchEvent(gvjs_dx),
        this.enabled && (this.stop(),
        this.start()))
    }
}
;
gvjs_.start = function() {
    this.enabled = !0;
    this.Hc || (this.Hc = this.ML.setTimeout(this.R7, this.Zv),
    this.zJ = gvjs_se())
}
;
gvjs_.stop = function() {
    this.enabled = !1;
    this.Hc && (this.ML.clearTimeout(this.Hc),
    this.Hc = null)
}
;
gvjs_.M = function() {
    gvjs_IA.G.M.call(this);
    this.stop();
    delete this.ML
}
;
var gvjs_JA = [];
function gvjs_KA(a) {
    gvjs_F.call(this);
    this.pd = a;
    this.ad = {}
}
gvjs_t(gvjs_KA, gvjs_F);
gvjs_ = gvjs_KA.prototype;
gvjs_.o = function(a, b, c, d) {
    return gvjs_LA(this, a, b, c, d)
}
;
function gvjs_MA(a, b, c, d, e) {
    gvjs_LA(a, b, c, d, !1, e)
}
function gvjs_LA(a, b, c, d, e, f) {
    Array.isArray(c) || (c && (gvjs_JA[0] = c.toString()),
    c = gvjs_JA);
    for (var g = 0; g < c.length; g++) {
        var h = gvjs_G(b, c[g], d || a.handleEvent, e || !1, f || a.pd || a);
        if (!h)
            break;
        a.ad[h.key] = h
    }
    return a
}
gvjs_.vD = function(a, b, c, d) {
    return gvjs_NA(this, a, b, c, d)
}
;
function gvjs_NA(a, b, c, d, e, f) {
    if (Array.isArray(c))
        for (var g = 0; g < c.length; g++)
            gvjs_NA(a, b, c[g], d, e, f);
    else {
        b = gvjs_ei(b, c, d || a.handleEvent, e, f || a.pd || a);
        if (!b)
            return a;
        a.ad[b.key] = b
    }
    return a
}
gvjs_.Ab = function(a, b, c, d, e) {
    if (Array.isArray(b))
        for (var f = 0; f < b.length; f++)
            this.Ab(a, b[f], c, d, e);
    else
        c = c || this.handleEvent,
        d = gvjs_r(d) ? !!d.capture : !!d,
        e = e || this.pd || this,
        c = gvjs_fi(c),
        d = !!d,
        b = gvjs_7h(a) ? a.uI(b, c, d, e) : a ? (a = gvjs_hi(a)) ? a.uI(b, c, d, e) : null : null,
        b && (gvjs_ki(b),
        delete this.ad[b.key]);
    return this
}
;
gvjs_.removeAll = function() {
    gvjs_w(this.ad, function(a, b) {
        this.ad.hasOwnProperty(b) && gvjs_ki(a)
    }, this);
    this.ad = {}
}
;
gvjs_.M = function() {
    gvjs_KA.G.M.call(this);
    this.removeAll()
}
;
gvjs_.handleEvent = function() {
    throw Error("EventHandler.handleEvent not implemented");
}
;
function gvjs_OA(a) {
    return gvjs_Em ? gvjs_eca.sanitize(a) : gvjs_3f(a, null)
}
function gvjs_PA(a) {
    if (gvjs_Em)
        if (gvjs_y && 10 > document.documentMode)
            a = gvjs_Gf;
        else {
            var b = document;
            typeof HTMLTemplateElement === gvjs_d && (b = gvjs_dh("TEMPLATE").content.ownerDocument);
            b = b.implementation.createHTMLDocument("").createElement(gvjs_b);
            b.style.cssText = a;
            a = gvjs_om(b.style, void 0)
        }
    else
        a = new gvjs_Df(a,gvjs_Ef);
    return a
}
function gvjs_QA(a) {
    var b = null
      , c = null;
    typeof a === gvjs_d ? b = a : c = a;
    this.ama = b;
    this.H = c;
    this.ZQ = null
}
gvjs_QA.prototype.kp = function(a) {
    this.ZQ = a;
    this.H && gvjs_5z(this.H, a)
}
;
gvjs_QA.prototype.xv = function() {
    return this.H ? gvjs_6z(this.H) : this.ZQ
}
;
gvjs_QA.prototype.j = function() {
    this.H || (this.H = this.ama(),
    null !== this.ZQ && gvjs_5z(this.H, this.ZQ));
    return this.H
}
;
function gvjs_RA(a, b) {
    return {
        type: gvjs_Xv,
        data: {
            x: a,
            y: b
        }
    }
}
function gvjs_SA() {
    this.vc = []
}
gvjs_ = gvjs_SA.prototype;
gvjs_.Cj = function(a) {
    this.vc.push(a)
}
;
gvjs_.move = function(a, b) {
    this.Cj(gvjs_RA(a, b))
}
;
gvjs_.va = function(a, b) {
    this.Cj({
        type: gvjs_e,
        data: {
            x: a,
            y: b
        }
    })
}
;
gvjs_.Jp = function(a, b, c, d, e, f) {
    this.Cj({
        type: gvjs_7t,
        data: {
            x1: a,
            y1: b,
            x2: c,
            y2: d,
            x: e,
            y: f
        }
    })
}
;
gvjs_.Sf = function(a, b, c, d, e, f, g) {
    this.Cj({
        type: "arc",
        data: {
            cx: a,
            cy: b,
            rx: c,
            ry: d,
            Gy: e,
            ou: f,
            zba: g
        }
    })
}
;
function gvjs_TA(a, b, c) {
    if (0 != b.length)
        if (0 == a.vc.length ? a.move(b[0].x, b[0].y) : a.va(b[0].x, b[0].y),
        c)
            for (var d = 1; d < b.length; ++d)
                a.Jp(c[d - 1][1].x, c[d - 1][1].y, c[d][0].x, c[d][0].y, b[d].x, b[d].y);
        else
            for (d = 1; d < b.length; ++d)
                a.va(b[d].x, b[d].y)
}
gvjs_.close = function() {
    this.Cj({
        type: gvjs_Yt,
        data: null
    })
}
;
function gvjs_UA(a, b) {
    var c = new gvjs_SA;
    0 < a.length && (gvjs_TA(c, a),
    b || c.close());
    return c
}
function gvjs_VA(a, b, c) {
    switch (c) {
    case gvjs_2:
        c = a;
        a += b;
        break;
    case gvjs_R:
        c = a - b;
        break;
    case gvjs_0:
        c = a - b / 2;
        a += b / 2;
        break;
    default:
        c = a = NaN
    }
    return {
        start: c,
        end: a
    }
}
function gvjs_WA(a, b, c, d) {
    d && (c = c === gvjs_2 ? gvjs_R : c === gvjs_R ? gvjs_2 : c);
    switch (c) {
    case gvjs_R:
        return b;
    case gvjs_0:
        return gvjs_bz(a, b);
    default:
        return a
    }
}
function gvjs_XA(a, b) {
    gvjs_F.call(this);
    this.container = a;
    this.jF = b;
    this.kw = null;
    this.me = gvjs_Tz(function(c, d, e) {
        return this.KC(c, d, e)
    }
    .bind(this), {
        gT: function(c, d) {
            var e = [c, d[0]];
            gvjs_w(d[1], function(f, g) {
                e.push(f);
                e.push(g)
            });
            e.push(+d[2]);
            return "getTextSize_" + e.join("_")
        }
    });
    this.Kw = null
}
gvjs_t(gvjs_XA, gvjs_F);
gvjs_ = gvjs_XA.prototype;
gvjs_.width = 0;
gvjs_.height = 0;
gvjs_.Lm = function(a, b) {
    a = this.bO(a, b);
    a.kp(gvjs_Bs);
    return this.kw = a
}
;
gvjs_.deleteContents = function() {
    this.WX()
}
;
gvjs_.flush = function() {}
;
gvjs_.clear = function() {
    this.He()
}
;
gvjs_.He = function() {
    this.kw = null
}
;
gvjs_.M = function() {
    this.He();
    gvjs_XA.G.M.call(this)
}
;
gvjs_.getContainer = function() {
    return this.container
}
;
gvjs_.kp = function(a, b) {
    a && (a.constructor == gvjs_QA ? a.kp(b) : gvjs_5z(a, b))
}
;
gvjs_.xv = function(a) {
    return gvjs_6z(a)
}
;
gvjs_.appendChild = function(a, b) {
    if (b) {
        if (b.constructor == gvjs_QA) {
            if (!b.H)
                return;
            b = b.j()
        }
        a.j().appendChild(b)
    }
}
;
function gvjs_YA(a, b) {
    b instanceof gvjs_QA && (b = b.j());
    for (var c; c = b.firstChild; )
        gvjs_YA(a, c);
    b.parentElement.removeChild(b)
}
gvjs_.replaceChild = function(a, b, c) {
    a = a.j();
    gvjs_qh(c) != a ? (gvjs_YA(this, c),
    a.appendChild(b)) : a.replaceChild(b, c)
}
;
gvjs_.qc = function(a) {
    if (a.H) {
        var b = a.j();
        this.gv.qc(b);
        a.j()
    }
}
;
gvjs_.Sa = function(a) {
    a = null != a ? a : !1;
    var b = new gvjs_QA(this.nX.bind(this));
    a || b.j();
    return b
}
;
gvjs_.dC = function() {}
;
gvjs_.HH = function() {
    return null
}
;
function gvjs_ZA(a, b, c, d, e, f) {
    var g = new gvjs_SA;
    g.move(b, c);
    g.va(d, e);
    return a.Dc(g, f)
}
gvjs_.Dc = function(a, b) {
    for (var c = [], d = 0; d < a.vc.length; d++) {
        var e = c
          , f = a.vc[d];
        switch (f.type) {
        case gvjs_Xv:
            f = f.data;
            this.nd(e, f.x, f.y);
            break;
        case gvjs_e:
            f = f.data;
            this.Ma(e, f.x, f.y);
            break;
        case gvjs_7t:
            f = f.data;
            this.Yr(e, f.x1, f.y1, f.x2, f.y2, f.x, f.y);
            break;
        case "arc":
            f = f.data;
            this.Bm(e, f.cx, f.cy, f.rx, f.ry, f.Gy, f.ou, f.zba);
            break;
        case gvjs_Yt:
            this.Qi(e)
        }
    }
    return this.tX(c, b)
}
;
gvjs_.Ke = function(a, b, c, d, e) {
    a = this.$x(a, b, c, d);
    this.appendChild(e, a);
    return a
}
;
gvjs_.Gl = function(a, b, c, d, e, f) {
    a = this.mX(a, b, c, d, e);
    this.appendChild(f, a);
    return a
}
;
gvjs_.yb = function(a, b, c, d, e, f) {
    a = this.Bl(a, b, c, d, e);
    this.appendChild(f, a);
    return a
}
;
gvjs_.jY = function(a, b, c, d, e, f) {
    a = gvjs_ZA(this, a, b, c, d, e);
    this.appendChild(f, a)
}
;
gvjs_.Ia = function(a, b, c) {
    a = this.Dc(a, b);
    this.appendChild(c, a);
    return a
}
;
gvjs_.ce = function(a, b, c, d, e, f, g, h, k) {
    a = this.by(a, b, c, d, e, f, g, k);
    this.appendChild(h, a);
    return a
}
;
gvjs_.Zi = function(a, b, c, d, e, f, g, h, k, l) {
    a = this.pH(a, b, c, d, e, f, g, h, l);
    this.appendChild(k, a);
    return a
}
;
function gvjs_Qda(a, b, c, d, e, f, g, h, k, l) {
    b = a.ys(b, c, d, e, f, g, h, k, void 0);
    a.appendChild(l, b)
}
gvjs_.Wl = function(a, b) {
    return this.me(a, b).width
}
;
gvjs_.cw = gvjs_n(36);
gvjs_.ic = function() {}
;
gvjs_.ws = gvjs_ye;
function gvjs__A() {
    var a = gvjs_Oh().Vj();
    a.__googleVisualizationAbstractRendererElementsCount__ = a.__googleVisualizationAbstractRendererElementsCount__ || 0;
    var b = "_ABSTRACT_RENDERER_ID_" + a.__googleVisualizationAbstractRendererElementsCount__.toString();
    a.__googleVisualizationAbstractRendererElementsCount__ = Number(a.__googleVisualizationAbstractRendererElementsCount__) + 1;
    return b
}
function gvjs_0A(a) {
    return gvjs_yh(a, function(b) {
        return b.referencepoint
    }, !0)
}
function gvjs_1A(a) {
    gvjs_H.call(this);
    this.H = a;
    a = gvjs_y ? gvjs_Au : gvjs_Yo;
    this.Ssa = gvjs_G(this.H, gvjs_y ? gvjs_zu : gvjs_xu, this, !gvjs_y);
    this.Tsa = gvjs_G(this.H, a, this, !gvjs_y)
}
gvjs_t(gvjs_1A, gvjs_H);
gvjs_1A.prototype.handleEvent = function(a) {
    var b = new gvjs_5h(a.$i);
    b.type = a.type == gvjs_zu || a.type == gvjs_xu ? gvjs_zu : gvjs_Au;
    this.dispatchEvent(b)
}
;
gvjs_1A.prototype.M = function() {
    gvjs_1A.G.M.call(this);
    gvjs_ki(this.Ssa);
    gvjs_ki(this.Tsa);
    delete this.H
}
;
function gvjs_2A() {}
gvjs_2A.prototype.Mf = function() {}
;
function gvjs_3A(a) {
    var b = a.offsetLeft
      , c = a.offsetParent;
    c || gvjs_Eh(a) != gvjs_wu || (c = gvjs_5g(a).documentElement);
    if (!c)
        return b;
    if (gvjs_sg && !gvjs_Eg(58)) {
        var d = gvjs_Jh(c);
        b += d.left
    } else
        gvjs_Fg(8) && !gvjs_Fg(9) && (d = gvjs_Jh(c),
        b -= d.left);
    return gvjs_Gz(c) ? c.clientWidth - (b + a.offsetWidth) : b
}
function gvjs_4A(a) {
    if (a = a.offsetParent) {
        var b = "HTML" == a.tagName || "BODY" == a.tagName;
        if (!b || "static" != gvjs_Eh(a)) {
            var c = gvjs_vz(a);
            if (!b) {
                b = gvjs_Gz(a);
                var d;
                if (d = b) {
                    d = gvjs_Lg && 0 <= gvjs_tf(gvjs_oq, 10);
                    var e = gvjs_Iaa && 0 <= gvjs_tf(gvjs_gda, 10)
                      , f = gvjs_Kg && 0 <= gvjs_tf(gvjs_oq, 85);
                    d = gvjs_sg || d || e || f
                }
                b = d ? -a.scrollLeft : !b || gvjs_Caa && gvjs_Eg("8") || gvjs_Dh(a, "overflowX") == gvjs_Mx ? a.scrollLeft : a.scrollWidth - a.clientWidth - a.scrollLeft;
                c = gvjs_dz(c, new gvjs_z(b,a.scrollTop))
            }
        }
    }
    return c || new gvjs_z
}
function gvjs_5A(a, b) {
    return (b & 8 && gvjs_Gz(a) ? b ^ 4 : b) & -9
}
function gvjs_6A(a, b, c, d, e, f, g) {
    a = a.clone();
    var h = gvjs_5A(b, c);
    c = gvjs_Dz(b);
    g = g ? g.clone() : c.clone();
    a = a.clone();
    g = g.clone();
    var k = 0;
    if (d || 0 != h)
        h & 4 ? a.x -= g.width + (d ? d.right : 0) : h & 2 ? a.x -= g.width / 2 : d && (a.x += d.left),
        h & 1 ? a.y -= g.height + (d ? d.bottom : 0) : d && (a.y += d.top);
    if (f) {
        if (e) {
            d = a;
            h = g;
            k = 0;
            65 == (f & 65) && (d.x < e.left || d.x >= e.right) && (f &= -2);
            132 == (f & 132) && (d.y < e.top || d.y >= e.bottom) && (f &= -5);
            d.x < e.left && f & 1 && (d.x = e.left,
            k |= 1);
            if (f & 16) {
                var l = d.x;
                d.x < e.left && (d.x = e.left,
                k |= 4);
                d.x + h.width > e.right && (h.width = Math.min(e.right - d.x, l + h.width - e.left),
                h.width = Math.max(h.width, 0),
                k |= 4)
            }
            d.x + h.width > e.right && f & 1 && (d.x = Math.max(e.right - h.width, e.left),
            k |= 1);
            f & 2 && (k |= (d.x < e.left ? 16 : 0) | (d.x + h.width > e.right ? 32 : 0));
            d.y < e.top && f & 4 && (d.y = e.top,
            k |= 2);
            f & 32 && (l = d.y,
            d.y < e.top && (d.y = e.top,
            k |= 8),
            d.y + h.height > e.bottom && (h.height = Math.min(e.bottom - d.y, l + h.height - e.top),
            h.height = Math.max(h.height, 0),
            k |= 8));
            d.y + h.height > e.bottom && f & 4 && (d.y = Math.max(e.bottom - h.height, e.top),
            k |= 2);
            f & 8 && (k |= (d.y < e.top ? 64 : 0) | (d.y + h.height > e.bottom ? 128 : 0));
            e = k
        } else
            e = 256;
        k = e
    }
    f = new gvjs_5(0,0,0,0);
    f.left = a.x;
    f.top = a.y;
    f.width = g.width;
    f.height = g.height;
    e = k;
    if (e & 496)
        return e;
    gvjs_sz(b, new gvjs_z(f.left,f.top));
    g = f.Tb();
    gvjs_fz(c, g) || (c = g,
    a = gvjs_eh(gvjs_3g(gvjs_5g(b)).dd),
    !gvjs_y || gvjs_Eg("10") || a && gvjs_Eg("8") ? (b = b.style,
    gvjs_sg ? b.MozBoxSizing = gvjs_tt : gvjs_tg ? b.WebkitBoxSizing = gvjs_tt : b.boxSizing = gvjs_tt,
    b.width = Math.max(c.width, 0) + gvjs_T,
    b.height = Math.max(c.height, 0) + gvjs_T) : (g = b.style,
    a ? (a = gvjs_Ih(b),
    b = gvjs_Jh(b),
    g.pixelWidth = c.width - b.left - a.left - a.right - b.right,
    g.pixelHeight = c.height - b.top - a.top - a.bottom - b.bottom) : (g.pixelWidth = c.width,
    g.pixelHeight = c.height)));
    return e
}
function gvjs_7A(a, b, c, d, e, f, g, h, k) {
    var l = gvjs_4A(c)
      , m = gvjs_Ez(a)
      , n = gvjs_wz(a);
    n && m.J_(gvjs_pz(n));
    n = gvjs_3g(a);
    var p = gvjs_3g(c);
    if (n.kc() != p.kc()) {
        var q = n.kc().body;
        p = p.Vj();
        var r = new gvjs_z(0,0)
          , t = gvjs_3x(gvjs_5g(q));
        if (gvjs_og(t, "parent")) {
            var u = q;
            do {
                var v = t == p ? gvjs_vz(u) : gvjs_yz(u);
                r.x += v.x;
                r.y += v.y
            } while (t && t != p && t != t.parent && (u = t.frameElement) && (t = t.parent))
        }
        q = gvjs_dz(r, gvjs_vz(q));
        !gvjs_y || gvjs_Fg(9) || gvjs_eh(n.dd) || (q = gvjs_dz(q, gvjs_2x(n.dd)));
        m.left += q.x;
        m.top += q.y
    }
    a = gvjs_5A(a, b);
    b = m.left;
    a & 4 ? b += m.width : a & 2 && (b += m.width / 2);
    m = new gvjs_z(b,m.top + (a & 1 ? m.height : 0));
    m = gvjs_dz(m, l);
    e && (m.x += (a & 4 ? -1 : 1) * e.x,
    m.y += (a & 1 ? -1 : 1) * e.y);
    if (g)
        if (k)
            var w = k;
        else if (w = gvjs_wz(c))
            w.top -= l.y,
            w.right -= l.x,
            w.bottom -= l.y,
            w.left -= l.x;
    return gvjs_6A(m, c, d, f, w, g, h)
}
function gvjs_8A(a, b, c) {
    this.element = a;
    this.lH = b;
    this.Lua = c
}
gvjs_t(gvjs_8A, gvjs_2A);
gvjs_8A.prototype.Mf = function(a, b, c) {
    gvjs_7A(this.element, this.lH, a, b, void 0, c, this.Lua)
}
;
function gvjs_9A(a, b) {
    this.Na = a instanceof gvjs_z ? a : new gvjs_z(a,b)
}
gvjs_t(gvjs_9A, gvjs_2A);
gvjs_9A.prototype.Mf = function(a, b, c, d) {
    gvjs_7A(gvjs_tz(a), 0, a, b, this.Na, c, null, d)
}
;
function gvjs_$A(a) {
    if (48 <= a && 57 >= a || 96 <= a && 106 >= a || 65 <= a && 90 >= a || (gvjs_tg || gvjs_rg) && 0 == a)
        return !0;
    switch (a) {
    case 32:
    case 43:
    case 63:
    case 64:
    case 107:
    case 109:
    case 110:
    case 111:
    case 186:
    case 59:
    case 189:
    case 187:
    case 61:
    case 188:
    case 190:
    case 191:
    case 192:
    case 222:
    case 219:
    case 220:
    case 221:
    case 163:
    case 58:
        return !0;
    case 173:
        return gvjs_sg;
    default:
        return !1
    }
}
function gvjs_Rda(a) {
    switch (a) {
    case 61:
        return 187;
    case 59:
        return 186;
    case 173:
        return 189;
    case 224:
        return 91;
    case 0:
        return 224;
    default:
        return a
    }
}
function gvjs_aB(a) {
    if (gvjs_sg)
        a = gvjs_Rda(a);
    else if (gvjs_ug && gvjs_tg)
        switch (a) {
        case 93:
            a = 91
        }
    return a
}
function gvjs_bB(a, b, c, d, e, f) {
    if (gvjs_tg && !gvjs_Eg("525"))
        return !0;
    if (gvjs_ug && e)
        return gvjs_$A(a);
    if (e && !d)
        return !1;
    if (!gvjs_sg) {
        typeof b === gvjs_g && (b = gvjs_aB(b));
        var g = 17 == b || 18 == b || gvjs_ug && 91 == b;
        if ((!c || gvjs_ug) && g || gvjs_ug && 16 == b && (d || f))
            return !1
    }
    if ((gvjs_tg || gvjs_rg) && d && c)
        switch (a) {
        case 220:
        case 219:
        case 221:
        case 192:
        case 186:
        case 189:
        case 187:
        case 188:
        case 190:
        case 191:
        case 192:
        case 222:
            return !1
        }
    if (gvjs_y && d && b == a)
        return !1;
    switch (a) {
    case 13:
        return gvjs_sg ? f || e ? !1 : !(c && d) : !0;
    case 27:
        return !(gvjs_tg || gvjs_rg || gvjs_sg)
    }
    return gvjs_sg && (d || e || f) ? !1 : gvjs_$A(a)
}
function gvjs_cB(a, b) {
    gvjs_H.call(this);
    this.pd = new gvjs_KA(this);
    this.sA(a || null);
    b && this.rp(b)
}
gvjs_t(gvjs_cB, gvjs_H);
gvjs_ = gvjs_cB.prototype;
gvjs_.H = null;
gvjs_.y7 = !0;
gvjs_.w7 = null;
gvjs_.x7 = null;
gvjs_.lD = !1;
gvjs_.Uwa = !1;
gvjs_.j0 = -1;
gvjs_.pra = !1;
gvjs_.zna = !0;
gvjs_.pf = gvjs_kx;
gvjs_.getType = function() {
    return this.pf
}
;
gvjs_.rp = function(a) {
    this.pf = a
}
;
gvjs_.j = function() {
    return this.H
}
;
gvjs_.sA = function(a) {
    gvjs_dB(this);
    this.H = a
}
;
gvjs_.iT = gvjs_n(37);
gvjs_.QE = gvjs_n(39);
gvjs_.hc = function() {
    return this.pd
}
;
function gvjs_dB(a) {
    if (a.lD)
        throw Error("Can not change this state of the popup while showing.");
}
gvjs_.isVisible = function() {
    return this.lD
}
;
gvjs_.setVisible = function(a) {
    this.UE && this.UE.stop();
    this.ZC && this.ZC.stop();
    a ? this.i4() : this.$C()
}
;
gvjs_.Mf = gvjs_ke;
gvjs_.i4 = function() {
    if (!this.lD && this.N1()) {
        if (!this.H)
            throw Error("Caller must call setElement before trying to show the popup");
        this.Mf();
        var a = gvjs_5g(this.H);
        this.pra && this.pd.o(a, gvjs_lv, this.nua, !0);
        if (this.y7)
            if (this.pd.o(a, gvjs_gd, this.Cda, !0),
            gvjs_y) {
                try {
                    var b = a.activeElement
                } catch (d) {}
                for (; b && b.nodeName == gvjs_Ma; ) {
                    try {
                        var c = gvjs_sh(b)
                    } catch (d) {
                        break
                    }
                    a = c;
                    b = a.activeElement
                }
                this.pd.o(a, gvjs_gd, this.Cda, !0);
                this.pd.o(a, "deactivate", this.Bda)
            } else
                this.pd.o(a, gvjs_Yo, this.Bda);
        this.pf == gvjs_kx ? (this.H.style.visibility = gvjs_Mx,
        gvjs_6(this.H, !0)) : this.pf == gvjs_Yv && this.Mf();
        this.lD = !0;
        this.j0 = Date.now();
        this.UE ? (gvjs_ei(this.UE, gvjs_R, this.Zz, !1, this),
        this.UE.play()) : this.Zz()
    }
}
;
gvjs_.$C = function(a) {
    if (!this.lD || !this.dispatchEvent({
        type: gvjs_ot,
        target: a
    }))
        return !1;
    this.pd && this.pd.removeAll();
    this.lD = !1;
    Date.now();
    this.ZC ? (gvjs_ei(this.ZC, gvjs_R, gvjs_re(this.G8, a), !1, this),
    this.ZC.play()) : this.G8(a);
    return !0
}
;
gvjs_.G8 = function(a) {
    this.pf == gvjs_kx ? this.Uwa ? gvjs_pl(this.Zaa, 0, this) : this.Zaa() : this.pf == gvjs_Yv && (this.H.style.top = "-10000px");
    this.yw(a)
}
;
gvjs_.Zaa = function() {
    this.H.style.visibility = gvjs_0u;
    gvjs_6(this.H, !1)
}
;
gvjs_.N1 = function() {
    return this.dispatchEvent(gvjs_pt)
}
;
gvjs_.Zz = function() {
    this.dispatchEvent(gvjs_Sw)
}
;
gvjs_.yw = function(a) {
    this.dispatchEvent({
        type: gvjs_1u,
        target: a
    })
}
;
gvjs_.Cda = function(a) {
    a = a.target;
    gvjs_rh(this.H, a) || gvjs_eB(this, a) || this.x7 && !gvjs_rh(this.x7, a) || 150 > Date.now() - this.j0 || this.$C(a)
}
;
gvjs_.nua = function(a) {
    27 == a.keyCode && this.$C(a.target) && (a.preventDefault(),
    a.stopPropagation())
}
;
gvjs_.Bda = function(a) {
    if (this.zna) {
        var b = gvjs_5g(this.H);
        if ("undefined" != typeof document.activeElement) {
            if (a = b.activeElement,
            !a || gvjs_rh(this.H, a) || "BODY" == a.tagName || gvjs_eB(this, a))
                return
        } else if (a.target != b)
            return;
        150 > Date.now() - this.j0 || this.$C()
    }
}
;
function gvjs_eB(a, b) {
    return gvjs_Fe(a.w7 || [], function(c) {
        return b === c || gvjs_rh(c, b)
    })
}
gvjs_.M = function() {
    gvjs_cB.G.M.call(this);
    this.pd.pa();
    gvjs_E(this.UE);
    gvjs_E(this.ZC);
    delete this.H;
    delete this.pd;
    delete this.w7
}
;
function gvjs_fB(a, b) {
    this.bva = 8;
    this.Qa = b || void 0;
    gvjs_cB.call(this, a)
}
gvjs_t(gvjs_fB, gvjs_cB);
gvjs_fB.prototype.getPosition = function() {
    return this.Qa || null
}
;
gvjs_fB.prototype.setPosition = function(a) {
    this.Qa = a || void 0;
    this.isVisible() && this.Mf()
}
;
gvjs_fB.prototype.Mf = function() {
    if (this.Qa) {
        var a = !this.isVisible() && this.getType() != gvjs_Yv
          , b = this.j();
        a && (b.style.visibility = gvjs_0u,
        gvjs_6(b, !0));
        this.Qa.Mf(b, this.bva, this.$Da);
        a && gvjs_6(b, !1)
    }
}
;
var gvjs_gB = [];
function gvjs_hB(a, b) {
    gvjs_9A.call(this, a, b)
}
gvjs_t(gvjs_hB, gvjs_9A);
gvjs_hB.prototype.Mf = function(a, b, c) {
    b = gvjs_tz(a);
    b = gvjs_wz(b);
    c = c ? new gvjs_B(c.top + 10,c.right,c.bottom,c.left + 10) : new gvjs_B(10,0,0,10);
    gvjs_6A(this.Na, a, 8, c, b, 9) & 496 && gvjs_6A(this.Na, a, 8, c, b, 5)
}
;
function gvjs_iB(a) {
    gvjs_8A.call(this, a, 5)
}
gvjs_t(gvjs_iB, gvjs_8A);
gvjs_iB.prototype.Mf = function(a, b, c) {
    var d = new gvjs_z(10,0);
    gvjs_7A(this.element, this.lH, a, b, d, c, 9) & 496 && gvjs_7A(this.element, 4, a, 1, d, c, 5)
}
;
function gvjs_jB(a, b, c) {
    this.D = c || (a ? gvjs_3g(gvjs_6g(document, a)) : gvjs_3g());
    gvjs_fB.call(this, this.D.J(gvjs_b, {
        style: "position:absolute;display:none;"
    }));
    this.xb = new gvjs_z(1,1);
    this.hb = new gvjs_hj;
    this.WA = null;
    a && this.CB(a);
    null != b && this.du(b)
}
gvjs_t(gvjs_jB, gvjs_fB);
gvjs_ = gvjs_jB.prototype;
gvjs_.qf = null;
gvjs_.className = "goog-tooltip";
gvjs_.JT = 500;
gvjs_.Xaa = 0;
gvjs_.wa = function() {
    return this.D
}
;
gvjs_.CB = function(a) {
    a = gvjs_6g(document, a);
    this.hb.add(a);
    gvjs_G(a, gvjs_ld, this.Lo, !1, this);
    gvjs_G(a, gvjs_kd, this.QP, !1, this);
    gvjs_G(a, gvjs_jd, this.uaa, !1, this);
    gvjs_G(a, gvjs_xu, this.Iv, !1, this);
    gvjs_G(a, gvjs_Yo, this.QP, !1, this)
}
;
gvjs_.detach = function(a) {
    if (a)
        a = gvjs_6g(document, a),
        gvjs_kB(this, a),
        this.hb.remove(a);
    else {
        for (var b = this.hb.ob(), c = 0; a = b[c]; c++)
            gvjs_kB(this, a);
        this.hb.clear()
    }
}
;
function gvjs_kB(a, b) {
    gvjs_ji(b, gvjs_ld, a.Lo, !1, a);
    gvjs_ji(b, gvjs_kd, a.QP, !1, a);
    gvjs_ji(b, gvjs_jd, a.uaa, !1, a);
    gvjs_ji(b, gvjs_xu, a.Iv, !1, a);
    gvjs_ji(b, gvjs_Yo, a.QP, !1, a)
}
gvjs_.du = function(a) {
    gvjs_th(this.j(), a)
}
;
gvjs_.BT = gvjs_n(40);
gvjs_.sA = function(a) {
    var b = this.j();
    b && gvjs_kh(b);
    gvjs_jB.G.sA.call(this, a);
    a ? (b = this.D.kc().body,
    b.insertBefore(a, b.lastChild),
    gvjs_E(this.WA),
    this.WA = new gvjs_1A(this.j()),
    gvjs_6x(this, this.WA),
    gvjs_G(this.WA, gvjs_zu, this.XG, void 0, this),
    gvjs_G(this.WA, gvjs_Au, this.YT, void 0, this)) : (gvjs_E(this.WA),
    this.WA = null)
}
;
gvjs_.dn = gvjs_n(44);
gvjs_.qP = function() {
    return this.j().innerHTML
}
;
gvjs_.getState = function() {
    return this.Sw ? this.isVisible() ? 4 : 1 : this.RI ? 3 : this.isVisible() ? 2 : 0
}
;
gvjs_.N1 = function() {
    if (!gvjs_cB.prototype.N1.call(this))
        return !1;
    if (this.anchor)
        for (var a, b = 0; a = gvjs_gB[b]; b++)
            gvjs_rh(a.j(), this.anchor) || a.setVisible(!1);
    gvjs_Gy(gvjs_gB, this);
    a = this.j();
    a.className = this.className;
    this.XG();
    gvjs_G(a, gvjs_ld, this.Haa, !1, this);
    gvjs_G(a, gvjs_kd, this.Gaa, !1, this);
    gvjs_lB(this);
    return !0
}
;
gvjs_.yw = function() {
    gvjs_Ie(gvjs_gB, this);
    for (var a = this.j(), b, c = 0; b = gvjs_gB[c]; c++)
        b.anchor && gvjs_rh(a, b.anchor) && b.setVisible(!1);
    this.Yda && this.Yda.YT();
    gvjs_ji(a, gvjs_ld, this.Haa, !1, this);
    gvjs_ji(a, gvjs_kd, this.Gaa, !1, this);
    this.anchor = void 0;
    0 == this.getState() && (this.ZS = !1);
    gvjs_cB.prototype.yw.call(this)
}
;
gvjs_.Nca = function(a, b) {
    this.anchor == a && this.hb.contains(this.anchor) && (this.ZS || !this.oEa ? (this.setVisible(!1),
    this.isVisible() || (this.anchor = a,
    this.setPosition(b || this.uP(0)),
    this.setVisible(!0))) : this.anchor = void 0);
    this.Sw = void 0
}
;
gvjs_.rI = function() {
    return this.hb
}
;
gvjs_.Ly = function() {
    return this.qf
}
;
gvjs_.ita = function(a) {
    this.RI = void 0;
    if (a == this.anchor) {
        a = this.wa();
        var b = a.Ly();
        a = b && this.j() && a.contains(this.j(), b);
        null != this.qf && (this.qf == this.j() || this.hb.contains(this.qf)) || a || this.m8 && this.m8.qf || this.setVisible(!1)
    }
}
;
function gvjs_mB(a, b) {
    var c = gvjs_2x(a.D.dd);
    a.xb.x = b.clientX + c.x;
    a.xb.y = b.clientY + c.y
}
gvjs_.Lo = function(a) {
    var b = gvjs_nB(this, a.target);
    this.qf = b;
    this.XG();
    b != this.anchor && (this.anchor = b,
    this.Sw || (this.Sw = gvjs_pl(gvjs_s(this.Nca, this, b, void 0), this.JT)),
    gvjs_oB(this),
    gvjs_mB(this, a))
}
;
function gvjs_nB(a, b) {
    try {
        for (; b && !a.hb.contains(b); )
            b = b.parentNode;
        return b
    } catch (c) {
        return null
    }
}
gvjs_.uaa = function(a) {
    gvjs_mB(this, a);
    this.ZS = !0
}
;
gvjs_.Iv = function(a) {
    this.qf = a = gvjs_nB(this, a.target);
    this.ZS = !0;
    if (this.anchor != a) {
        this.anchor = a;
        var b = this.uP(1);
        this.XG();
        this.Sw || (this.Sw = gvjs_pl(gvjs_s(this.Nca, this, a, b), this.JT));
        gvjs_oB(this)
    }
}
;
gvjs_.uP = function(a) {
    return 0 == a ? (a = this.xb.clone(),
    new gvjs_hB(a)) : new gvjs_iB(this.qf)
}
;
function gvjs_oB(a) {
    if (a.anchor)
        for (var b, c = 0; b = gvjs_gB[c]; c++)
            gvjs_rh(b.j(), a.anchor) && (b.m8 = a,
            a.Yda = b)
}
gvjs_.QP = function(a) {
    var b = gvjs_nB(this, a.target)
      , c = gvjs_nB(this, a.relatedTarget);
    b != c && (b == this.qf && (this.qf = null),
    gvjs_lB(this),
    this.ZS = !1,
    !this.isVisible() || a.relatedTarget && gvjs_rh(this.j(), a.relatedTarget) ? this.anchor = void 0 : this.YT())
}
;
gvjs_.Haa = function() {
    var a = this.j();
    this.qf != a && (this.XG(),
    this.qf = a)
}
;
gvjs_.Gaa = function(a) {
    var b = this.j();
    this.qf != b || a.relatedTarget && gvjs_rh(b, a.relatedTarget) || (this.qf = null,
    this.YT())
}
;
function gvjs_lB(a) {
    a.Sw && (gvjs_ql(a.Sw),
    a.Sw = void 0)
}
gvjs_.YT = function() {
    2 == this.getState() && (this.RI = gvjs_pl(gvjs_s(this.ita, this, this.anchor), this.Xaa))
}
;
gvjs_.XG = function() {
    this.RI && (gvjs_ql(this.RI),
    this.RI = void 0)
}
;
gvjs_.M = function() {
    this.setVisible(!1);
    gvjs_lB(this);
    this.detach();
    this.j() && gvjs_kh(this.j());
    this.qf = null;
    delete this.D;
    gvjs_jB.G.M.call(this)
}
;
function gvjs_pB(a, b) {
    gvjs_XA.call(this, a, b);
    this.gv = gvjs_3g(a);
    this.zO = this.gv.kc();
    this.qu = [];
    this.ea = new gvjs_KA
}
gvjs_t(gvjs_pB, gvjs_XA);
function gvjs_Sda(a, b, c, d) {
    b = new gvjs_jB(b);
    var e = a.gv.J(gvjs_b);
    c = c.split("\n");
    e.appendChild(a.gv.createTextNode(c[0]));
    for (var f = 1; f < c.length; ++f)
        e.appendChild(a.gv.J("BR")),
        e.appendChild(a.gv.createTextNode(c[f]));
    gvjs_C(e, d);
    b.j().appendChild(e);
    b.JT = 100;
    b.Xaa = 100;
    a.qu.push(b)
}
gvjs_ = gvjs_pB.prototype;
gvjs_.Re = function(a) {
    this.gv.removeNode(a);
    gvjs_li(a)
}
;
gvjs_.clear = function() {
    this.ea.removeAll();
    gvjs_E(this.ea);
    this.ea = new gvjs_KA;
    gvjs_pB.G.clear.call(this)
}
;
gvjs_.He = function() {
    gvjs_pB.G.He.call(this);
    gvjs_u(this.qu, function(a) {
        gvjs_E(a)
    });
    gvjs_Fy(this.qu);
    this.gv.qc(this.container);
    this.ea.removeAll();
    gvjs_E(this.ea)
}
;
gvjs_.Qj = function(a) {
    var b = gvjs_0A(a);
    return b ? (b = gvjs_Az(a, b),
    a = gvjs_Dz(a),
    new gvjs_B(b.y,b.x + a.width,b.y + a.height,b.x)) : null
}
;
function gvjs_qB(a) {
    for (var b = a.target; b.parentNode; )
        b = b.parentNode;
    9 === b.nodeType || 11 === b.nodeType ? (b = gvjs_0A(a.target),
    a = gvjs_Az(a, b)) : a = null;
    return a
}
gvjs_.ic = function(a, b, c) {
    a.constructor == gvjs_QA && (a = a.j());
    this.ea.o(a, b, c)
}
;
gvjs_.replaceChild = function(a, b, c) {
    gvjs_pB.G.replaceChild.call(this, a, b, c);
    gvjs_li(c)
}
;
function gvjs_rB(a, b) {
    gvjs_pB.call(this, a, b);
    this.Ba = null;
    a = gvjs_3g(b).createElement(gvjs_Gt);
    this.jF.appendChild(a);
    this.sga = a.getContext("2d");
    this.vn = this.ya = this.NN = null;
    this.i2 = !1
}
gvjs_t(gvjs_rB, gvjs_pB);
function gvjs_sB(a) {
    a.i2 || (a.Ba.beginPath(),
    a.vn = new gvjs_B(Infinity,-Infinity,-Infinity,Infinity),
    a.i2 = !0)
}
function gvjs_tB(a, b, c) {
    a.vn && (a.vn.left = Math.min(a.vn.left, b),
    a.vn.top = Math.min(a.vn.top, c),
    a.vn.right = Math.max(a.vn.right, b),
    a.vn.bottom = Math.max(a.vn.bottom, c))
}
gvjs_ = gvjs_rB.prototype;
gvjs_.bO = function(a, b) {
    var c = gvjs_3g(this.container).createElement(gvjs_Gt);
    c.setAttribute(gvjs_Xd, a);
    c.setAttribute(gvjs_4c, b);
    this.ya = new gvjs_A(a,b);
    this.container.appendChild(c);
    this.Ba = c.getContext("2d");
    return new gvjs_QA(c)
}
;
gvjs_.WX = function() {
    var a = this.kw.j();
    this.Ba.clearRect(0, 0, a.width, a.height)
}
;
function gvjs_uB(a) {
    return gvjs_3g(a.container).createElement("empty")
}
function gvjs_vB(a, b) {
    if (a == gvjs_f)
        return gvjs_yw;
    b == gvjs_f && (b = 1);
    return "rgba(" + gvjs_vj(gvjs_qj(a).hex) + "," + b + ")"
}
function gvjs_wB(a, b) {
    "undefined" !== typeof a.setLineDash ? a.setLineDash(b) : a.dEa = b
}
function gvjs_xB(a, b, c, d, e) {
    var f = /^(\d+(\.\d*)?)%$/;
    typeof b === gvjs_l && f.test(b) ? (b = parseFloat(f.exec(b)[1]) / 100,
    c && null != e ? b = d ? e.height * b + e.top : e.width * b + e.left : null != a.ya && (b = d ? a.ya.height * b : a.ya.width * b)) : b = +b;
    return b
}
gvjs_.Li = function(a, b) {
    this.Ba.strokeStyle = gvjs_vB(a.Uj(), a.strokeOpacity);
    this.Ba.fillStyle = gvjs_vB(a.fill, a.fillOpacity);
    var c = a.Mi;
    null != c && c == gvjs_9t ? gvjs_wB(this.Ba, [8, 2]) : Array.isArray(c) ? gvjs_wB(this.Ba, c) : gvjs_wB(this.Ba, []);
    var d = a.pattern;
    c = a.gradient;
    if (null != d) {
        c = null;
        switch (d.getStyle()) {
        case gvjs_rw:
            c = this.zO.createElement(gvjs_Gt),
            c.setAttribute(gvjs_Xd, 4),
            c.setAttribute(gvjs_4c, 4),
            b = c.getContext("2d"),
            b.fillStyle = d.getBackgroundColor(),
            b.fillRect(0, 0, 4, 4),
            b.strokeStyle = d.ee(),
            b.beginPath(),
            b.lineWidth = 2,
            b.lineCap = gvjs_1w,
            b.moveTo(2, 0),
            b.lineTo(4, 2),
            b.moveTo(0, 2),
            b.lineTo(2, 4),
            b.stroke()
        }
        this.Ba.fillStyle = this.Ba.createPattern(c, "repeat")
    } else if (null != c) {
        var e = c.Sn || !1;
        d = gvjs_xB(this, c.x1, e, !1, b);
        var f = gvjs_xB(this, c.y1, e, !0, b)
          , g = gvjs_xB(this, c.x2, e, !1, b);
        b = gvjs_xB(this, c.y2, e, !0, b);
        b = this.Ba.createLinearGradient(d, f, g, b);
        b.addColorStop(0, c.Vf);
        b.addColorStop(1, c.sf);
        this.Ba.fillStyle = b
    }
    this.Ba.lineWidth = a.strokeWidth
}
;
function gvjs_yB(a, b) {
    b.Lb && b.Lb != gvjs_f ? (a.strokeStyle = b.Lb,
    a.lineWidth = 3) : a.strokeStyle = gvjs_yw;
    a.fillStyle = gvjs_vB(b.color, b.opacity ? b.opacity : 1);
    gvjs_wB(a, []);
    var c = "";
    b.Nc && (c = "italic ");
    b.bold && (c += "bold ");
    c += b.fontSize + "px " + b.bb;
    a.font = c
}
gvjs_.$x = function(a, b, c, d) {
    this.Ba.beginPath();
    this.Li(d, new gvjs_5(a - c,b - c,2 * c,2 * c));
    this.Ba.arc(a, b, c, 0, 2 * Math.PI);
    this.Ba.closePath();
    this.Ba.fill();
    this.Ba.stroke();
    return gvjs_uB(this)
}
;
gvjs_.mX = function(a, b, c, d, e) {
    this.Ba.save();
    this.Li(e, new gvjs_5(a - c,b - d,2 * c,2 * d));
    this.Ba.translate(a, b);
    c > d ? (this.Ba.scale(1, d / c),
    a = c) : (this.Ba.scale(c / d, 1),
    a = d);
    this.Ba.arc(0, 0, a, 0, 2 * Math.PI, !1);
    this.Ba.fill();
    this.Ba.stroke();
    this.Ba.restore();
    return gvjs_uB(this)
}
;
gvjs_.Bl = function(a, b, c, d, e) {
    this.Li(e, new gvjs_5(a,b,c,d));
    this.Ba.fillRect(a, b, c, d);
    this.Ba.strokeRect(a, b, c, d);
    return gvjs_uB(this)
}
;
gvjs_.AD = gvjs_n(47);
gvjs_.tX = function(a, b) {
    this.Li(b, gvjs_pz(this.vn));
    this.Ba.fill();
    this.Ba.stroke();
    this.i2 = !1;
    this.vn = null;
    return gvjs_uB(this)
}
;
gvjs_.by = function(a, b, c, d, e, f, g) {
    return this.ys(a, b, c, d, 0, e, f, g)
}
;
gvjs_.pH = function(a, b, c, d, e, f, g, h) {
    var k = gvjs_WA(b, d, f)
      , l = gvjs_WA(c, e, f);
    return this.ys(a, k, l, Math.sqrt(gvjs_cA(new gvjs_bA(b,c,d,e))), gvjs_5y(gvjs_7y(Math.atan2(e - c, d - b))), f, g, h)
}
;
gvjs_.ys = function(a, b, c, d, e, f, g, h) {
    gvjs_yB(this.Ba, h);
    this.Ba.save();
    e = gvjs_6y(e);
    d = b * Math.sin(-e) + c * Math.cos(-e);
    b = b * Math.cos(-e) - c * Math.sin(-e);
    this.Ba.rotate(e);
    g == gvjs_2 ? d += 4 * h.fontSize / 5 : g == gvjs_0 ? d += h.fontSize / 3 : g == gvjs_R && (d -= h.fontSize / 5);
    f != gvjs_2 && (f == gvjs_0 ? b -= this.KC(a, h).width / 2 : f == gvjs_R && (b -= this.KC(a, h).width));
    this.Ba.strokeText(a, b, d);
    this.Ba.fillText(a, b, d);
    h.Ue && (this.Ba.beginPath(),
    e = h.fontSize / 15,
    d += e + 1,
    1 > e && (e = 1),
    this.Ba.lineWidth = e,
    this.Ba.moveTo(b, d),
    this.Ba.lineTo(this.Ba.measureText(a).width + b, d),
    this.Ba.strokeStyle = this.Ba.fillStyle,
    this.Ba.stroke());
    this.Ba.restore();
    return gvjs_uB(this)
}
;
gvjs_.nX = function() {
    return gvjs_uB(this)
}
;
gvjs_.dC = function(a) {
    null !== a && (this.NN = a,
    this.Ba.save(),
    this.Ba.beginPath(),
    this.Ba.fillStyle = gvjs_yw,
    this.Ba.rect(a.left, a.top, a.width, a.height),
    this.Ba.clip())
}
;
gvjs_.HH = function() {
    var a = this.NN;
    this.NN && (this.NN = null,
    this.Ba.restore());
    return a
}
;
gvjs_.ZG = function() {
    return gvjs_uB(this)
}
;
gvjs_.nd = function(a, b, c) {
    gvjs_sB(this);
    this.Ba.moveTo(b, c);
    gvjs_tB(this, b, c)
}
;
gvjs_.Ma = function(a, b, c) {
    gvjs_sB(this);
    this.Ba.lineTo(b, c);
    gvjs_tB(this, b, c)
}
;
gvjs_.Yr = function(a, b, c, d, e, f, g) {
    gvjs_sB(this);
    this.Ba.bezierCurveTo(b, c, d, e, f, g);
    gvjs_tB(this, b, c);
    gvjs_tB(this, d, e);
    gvjs_tB(this, f, g)
}
;
gvjs_.Qi = function() {
    gvjs_sB(this);
    this.Ba.closePath()
}
;
gvjs_.Bm = function(a, b, c, d, e, f, g, h) {
    gvjs_sB(this);
    f = gvjs_6y(f - 90);
    g = gvjs_6y(g - 90);
    a = Math.max(d, e);
    this.Ba.save();
    this.Ba.translate(b, c);
    this.Ba.scale(d / a, e / a);
    this.Ba.arc(0, 0, a, f, g, !h);
    this.Ba.restore()
}
;
gvjs_.mp = function() {}
;
gvjs_.Ug = function() {}
;
gvjs_.fl = function() {}
;
gvjs_.tA = gvjs_n(50);
gvjs_.xA = gvjs_n(53);
gvjs_.rd = function() {}
;
gvjs_.KC = function(a, b) {
    gvjs_yB(this.sga, b);
    return new gvjs_A(this.sga.measureText(a).width,b.fontSize)
}
;
gvjs_.IC = gvjs_n(56);
gvjs_.rj = function() {}
;
function gvjs_Tda() {
    var a = [0, 10, 1, 2, 1, 18, 95, 33, 13, 1, 594, 112, 275, 7, 263, 45, 1, 1, 1, 2, 1, 2, 1, 1, 56, 6, 10, 11, 1, 1, 46, 21, 16, 1, 101, 7, 1, 1, 6, 2, 2, 1, 4, 33, 1, 1, 1, 30, 27, 91, 11, 58, 9, 34, 4, 1, 9, 1, 3, 1, 5, 43, 3, 120, 14, 1, 32, 1, 17, 37, 1, 1, 1, 1, 3, 8, 4, 1, 2, 1, 7, 8, 2, 2, 21, 7, 1, 1, 2, 17, 39, 1, 1, 1, 2, 6, 6, 1, 9, 5, 4, 2, 2, 12, 2, 15, 2, 1, 17, 39, 2, 3, 12, 4, 8, 6, 17, 2, 3, 14, 1, 17, 39, 1, 1, 3, 8, 4, 1, 20, 2, 29, 1, 2, 17, 39, 1, 1, 2, 1, 6, 6, 9, 6, 4, 2, 2, 13, 1, 16, 1, 18, 41, 1, 1, 1, 12, 1, 9, 1, 40, 1, 3, 17, 31, 1, 5, 4, 3, 5, 7, 8, 3, 2, 8, 2, 29, 1, 2, 17, 39, 1, 1, 1, 1, 2, 1, 3, 1, 5, 1, 8, 9, 1, 3, 2, 29, 1, 2, 17, 38, 3, 1, 2, 5, 7, 1, 1, 8, 1, 10, 2, 30, 2, 22, 48, 5, 1, 2, 6, 7, 1, 18, 2, 13, 46, 2, 1, 1, 1, 6, 1, 12, 8, 50, 46, 2, 1, 1, 1, 9, 11, 6, 14, 2, 58, 2, 27, 1, 1, 1, 1, 1, 4, 2, 49, 14, 1, 4, 1, 1, 2, 5, 48, 9, 1, 57, 33, 12, 4, 1, 6, 1, 2, 2, 2, 1, 16, 2, 4, 2, 2, 4, 3, 1, 3, 2, 7, 3, 4, 13, 1, 1, 1, 2, 6, 1, 1, 14, 1, 98, 96, 72, 88, 349, 3, 931, 15, 2, 1, 14, 15, 2, 1, 14, 15, 2, 15, 15, 14, 35, 17, 2, 1, 7, 8, 1, 2, 9, 1, 1, 9, 1, 45, 3, 1, 118, 2, 34, 1, 87, 28, 3, 3, 4, 2, 9, 1, 6, 3, 20, 19, 29, 44, 84, 23, 2, 2, 1, 4, 45, 6, 2, 1, 1, 1, 8, 1, 1, 1, 2, 8, 6, 13, 48, 84, 1, 14, 33, 1, 1, 5, 1, 1, 5, 1, 1, 1, 7, 31, 9, 12, 2, 1, 7, 23, 1, 4, 2, 2, 2, 2, 2, 11, 3, 2, 36, 2, 1, 1, 2, 3, 1, 1, 3, 2, 12, 36, 8, 8, 2, 2, 21, 3, 128, 3, 1, 13, 1, 7, 4, 1, 4, 2, 1, 3, 2, 198, 64, 523, 1, 1, 1, 2, 24, 7, 49, 16, 96, 33, 1324, 1, 34, 1, 1, 1, 82, 2, 98, 1, 14, 1, 1, 4, 86, 1, 1418, 3, 141, 1, 96, 32, 554, 6, 105, 2, 30164, 4, 1, 10, 32, 2, 80, 2, 272, 1, 3, 1, 4, 1, 23, 2, 2, 1, 24, 30, 4, 4, 3, 8, 1, 1, 13, 2, 16, 34, 16, 1, 1, 26, 18, 24, 24, 4, 8, 2, 23, 11, 1, 1, 12, 32, 3, 1, 5, 3, 3, 36, 1, 2, 4, 2, 1, 3, 1, 36, 1, 32, 35, 6, 2, 2, 2, 2, 12, 1, 8, 1, 1, 18, 16, 1, 3, 6, 1, 1, 1, 3, 48, 1, 1, 3, 2, 2, 5, 2, 1, 1, 32, 9, 1, 2, 2, 5, 1, 1, 201, 14, 2, 1, 1, 9, 8, 2, 1, 2, 1, 2, 1, 1, 1, 18, 11184, 27, 49, 1028, 1024, 6942, 1, 737, 16, 16, 16, 207, 1, 158, 2, 89, 3, 513, 1, 226, 1, 149, 5, 1670, 15, 40, 7, 1, 165, 2, 1305, 1, 1, 1, 53, 14, 1, 56, 1, 2, 1, 45, 3, 4, 2, 1, 1, 2, 1, 66, 3, 36, 5, 1, 6, 2, 62, 1, 12, 2, 1, 48, 3, 9, 1, 1, 1, 2, 6, 3, 95, 3, 3, 2, 1, 1, 2, 6, 1, 160, 1, 3, 7, 1, 21, 2, 2, 56, 1, 1, 1, 1, 1, 12, 1, 9, 1, 10, 4, 15, 192, 3, 8, 2, 1, 2, 1, 1, 105, 1, 2, 6, 1, 1, 2, 1, 1, 2, 1, 1, 1, 235, 1, 2, 6, 4, 2, 1, 1, 1, 27, 2, 82, 3, 8, 2, 1, 1, 1, 1, 106, 1, 1, 1, 2, 6, 1, 1, 101, 3, 2, 4, 1, 4, 1, 1283, 1, 14, 1, 1, 82, 23, 1, 7, 1, 2, 1, 2, 20025, 5, 59, 7, 1050, 62, 4, 19722, 2, 1, 4, 5313, 1, 1, 3, 3, 1, 5, 8, 8, 2, 7, 30, 4, 148, 3, 1979, 55, 4, 50, 8, 1, 14, 1, 22, 1424, 2213, 7, 109, 7, 2203, 26, 264, 1, 53, 1, 52, 1, 17, 1, 13, 1, 16, 1, 3, 1, 25, 3, 2, 1, 2, 3, 30, 1, 1, 1, 13, 5, 66, 2, 2, 11, 21, 4, 4, 1, 1, 9, 3, 1, 4, 3, 1, 3, 3, 1, 30, 1, 16, 2, 106, 1, 4, 1, 71, 2, 4, 1, 21, 1, 4, 2, 81, 1, 92, 3, 3, 5, 48, 1, 17, 1, 16, 1, 16, 3, 9, 1, 11, 1, 587, 5, 1, 1, 7, 1, 9, 10, 3, 2, 788162, 31];
    this.rva = a;
    for (var b = 1; b < a.length; b++)
        null == a[b] ? a[b] = a[b - 1] + 1 : a[b] += a[b - 1];
    this.values = [1, 13, 1, 12, 1, 0, 1, 0, 1, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 3, 0, 2, 0, 1, 0, 2, 0, 2, 0, 2, 3, 0, 2, 0, 2, 0, 2, 0, 3, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 3, 2, 4, 0, 5, 2, 4, 2, 0, 4, 2, 4, 6, 4, 0, 2, 5, 0, 2, 0, 5, 0, 2, 4, 0, 5, 2, 0, 2, 4, 2, 4, 6, 0, 2, 5, 0, 2, 0, 5, 0, 2, 4, 0, 5, 2, 4, 2, 6, 2, 5, 0, 2, 0, 2, 4, 0, 5, 2, 0, 4, 2, 4, 6, 0, 2, 0, 2, 4, 0, 5, 2, 0, 2, 4, 2, 4, 6, 2, 5, 0, 2, 0, 5, 0, 2, 0, 5, 2, 4, 2, 4, 6, 0, 2, 0, 2, 4, 0, 5, 0, 5, 0, 2, 4, 2, 6, 2, 5, 0, 2, 0, 2, 4, 0, 5, 2, 0, 4, 2, 4, 2, 4, 2, 4, 2, 6, 2, 5, 0, 2, 0, 2, 4, 0, 5, 0, 2, 4, 2, 4, 6, 3, 0, 2, 0, 2, 0, 4, 0, 5, 6, 2, 4, 2, 4, 2, 0, 4, 0, 5, 0, 2, 0, 4, 2, 6, 0, 2, 0, 5, 0, 2, 0, 4, 2, 0, 2, 0, 5, 0, 2, 0, 2, 0, 2, 0, 2, 0, 4, 5, 2, 4, 2, 6, 0, 2, 0, 2, 0, 2, 0, 5, 0, 2, 4, 2, 0, 6, 4, 2, 5, 0, 5, 0, 4, 2, 5, 2, 5, 0, 5, 0, 5, 2, 5, 2, 0, 4, 2, 0, 2, 5, 0, 2, 0, 7, 8, 9, 0, 2, 0, 5, 2, 6, 0, 5, 2, 6, 0, 5, 2, 0, 5, 2, 5, 0, 2, 4, 2, 4, 2, 4, 2, 6, 2, 0, 2, 0, 2, 1, 0, 2, 0, 2, 0, 5, 0, 2, 4, 2, 4, 2, 4, 2, 0, 5, 0, 5, 0, 5, 2, 4, 2, 0, 5, 0, 5, 4, 2, 4, 2, 6, 0, 2, 0, 2, 4, 2, 0, 2, 4, 0, 5, 2, 4, 2, 4, 2, 4, 2, 4, 6, 5, 0, 2, 0, 2, 4, 0, 5, 4, 2, 4, 2, 6, 2, 5, 0, 5, 0, 5, 0, 2, 4, 2, 4, 2, 4, 2, 6, 0, 5, 4, 2, 4, 2, 0, 5, 0, 2, 0, 2, 4, 2, 0, 2, 0, 4, 2, 0, 2, 0, 2, 0, 1, 2, 15, 1, 0, 1, 0, 1, 0, 2, 0, 16, 0, 17, 0, 17, 0, 17, 0, 16, 0, 17, 0, 16, 0, 17, 0, 2, 0, 6, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 6, 5, 2, 5, 4, 2, 4, 0, 5, 0, 5, 0, 5, 0, 5, 0, 4, 0, 5, 4, 6, 2, 0, 2, 0, 5, 0, 2, 0, 5, 2, 4, 6, 0, 7, 2, 4, 0, 5, 0, 5, 2, 4, 2, 4, 2, 4, 6, 0, 2, 0, 5, 2, 4, 2, 4, 2, 0, 2, 0, 2, 4, 0, 5, 0, 5, 0, 5, 0, 2, 0, 5, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 5, 4, 2, 4, 0, 4, 6, 0, 5, 0, 5, 0, 5, 0, 4, 2, 4, 2, 4, 0, 4, 6, 0, 11, 8, 9, 0, 2, 0, 2, 0, 2, 0, 2, 0, 1, 0, 2, 0, 1, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 6, 0, 2, 0, 4, 2, 4, 0, 2, 6, 0, 6, 2, 4, 0, 4, 2, 4, 6, 2, 0, 3, 0, 2, 0, 2, 4, 2, 6, 0, 2, 0, 2, 4, 0, 4, 2, 4, 6, 0, 3, 0, 2, 0, 4, 2, 4, 2, 6, 2, 0, 2, 0, 2, 4, 2, 6, 0, 2, 4, 0, 2, 0, 2, 4, 2, 4, 6, 0, 2, 0, 4, 2, 0, 4, 2, 4, 6, 2, 4, 2, 0, 2, 4, 2, 4, 2, 4, 2, 4, 2, 4, 6, 2, 0, 2, 4, 2, 4, 2, 4, 6, 2, 0, 2, 0, 4, 2, 4, 2, 4, 6, 2, 0, 2, 4, 2, 4, 2, 6, 2, 0, 2, 4, 2, 4, 2, 6, 0, 4, 2, 4, 6, 0, 2, 4, 2, 4, 2, 4, 2, 0, 2, 0, 2, 0, 4, 2, 0, 2, 0, 1, 0, 2, 4, 2, 0, 4, 2, 1, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 14, 0, 17, 0, 17, 0, 17, 0, 16, 0, 17, 0, 17, 0, 17, 0, 16, 0, 16, 0, 16, 0, 17, 0, 17, 0, 18, 0, 16, 0, 16, 0, 19, 0, 16, 0, 16, 0, 16, 0, 16, 0, 16, 0, 17, 0, 16, 0, 17, 0, 17, 0, 17, 0, 16, 0, 16, 0, 16, 0, 16, 0, 17, 0, 16, 0, 16, 0, 17, 0, 17, 0, 16, 0, 16, 0, 16, 0, 16, 0, 16, 0, 16, 0, 16, 0, 16, 0, 16, 0, 1, 2]
}
var gvjs_zB = null;
function gvjs_AB(a, b) {
    var c = a.charCodeAt(b);
    55296 <= c && 56319 >= c && b + 1 < a.length ? (a = a.charCodeAt(b + 1),
    56320 <= a && 57343 >= a && (c = 55296 <= c && 56319 >= c && 56320 <= a && 57343 >= a ? (c << 10) - 56623104 + (a - 56320 + 65536) : null)) : 56320 <= c && 57343 >= c && 0 < b && (a = a.charCodeAt(b - 1),
    55296 <= a && 56319 >= a && (c = -(55296 <= a && 56319 >= a && 56320 <= c && 57343 >= c ? (a << 10) - 56623104 + (c - 56320 + 65536) : 0)));
    return 0 > c ? -c : c
}
function gvjs_BB(a) {
    if (44032 <= a && 55203 >= a)
        return 16 === a % 28 ? 10 : 11;
    gvjs_zB || (gvjs_zB = new gvjs_Tda);
    for (var b = gvjs_zB, c = b.rva, d = 0, e = c.length; 8 < e - d; ) {
        var f = e + d >> 1;
        c[f] <= a ? d = f : e = f
    }
    for (; d < e && !(a < c[d]); ++d)
        ;
    a = d - 1;
    return 0 > a ? null : b.values[a]
}
function gvjs_Uda(a, b) {
    var c = typeof a === gvjs_l ? gvjs_AB(a, a.length - 1) : a
      , d = typeof b === gvjs_l ? gvjs_AB(b, 0) : b;
    b = gvjs_BB(c);
    var e = gvjs_BB(d)
      , f = typeof a === gvjs_l;
    if (12 === b && 13 === e)
        return !1;
    if (1 === b || 12 === b || 13 === b || 1 === e || 12 === e || 13 === e)
        return !0;
    if (7 === b && (7 === e || 8 === e || 10 === e || 11 === e) || !(10 !== b && 8 !== b || 8 !== e && 9 !== e) || (11 === b || 9 === b) && 9 === e || 2 === e || 15 === e || 6 === e)
        return !1;
    var g;
    if (f) {
        if (18 === e) {
            d = a;
            var h = d.length - 1;
            var k = c;
            for (g = b; 0 < h && 2 === g; )
                h -= 65536 <= k && 1114111 >= k ? 2 : 1,
                k = gvjs_AB(d, h),
                g = gvjs_BB(k);
            if (16 === g || 19 === g)
                return !1
        }
    } else if ((16 === b || 19 === b) && 18 === e)
        return !1;
    if (15 === b && (17 === e || 19 === e))
        return !1;
    if (f) {
        if (14 === e) {
            e = 0;
            d = a;
            h = d.length - 1;
            k = c;
            for (g = b; 0 < h && 14 === g; )
                e++,
                h -= 65536 <= k && 1114111 >= k ? 2 : 1,
                k = gvjs_AB(d, h),
                g = gvjs_BB(k);
            14 === g && e++;
            if (1 === e % 2)
                return !1
        }
    } else if (14 === b && 14 === e)
        return !1;
    return !0
}
function gvjs_Vda(a) {
    if (null != a)
        switch (a.TN) {
        case 1:
            return 1;
        case -1:
            return -1;
        case 0:
            return 0
        }
    return null
}
function gvjs_CB(a, b) {
    for (var c in b)
        c in a || (a[c] = b[c]);
    return a
}
var gvjs_Wda = /<(?:!|\/?([a-zA-Z][a-zA-Z0-9:\-]*))(?:[^>'"]|"[^"]*"|'[^']*')*>/g
  , gvjs_Xda = /</g
  , gvjs_Yda = {
    "\x00": "&#0;",
    "\t": "&#9;",
    "\n": "&#10;",
    "\x0B": "&#11;",
    "\f": "&#12;",
    "\r": "&#13;",
    " ": "&#32;",
    '"': gvjs_ga,
    "&": "&amp;",
    "'": "&#39;",
    "-": "&#45;",
    "/": "&#47;",
    "<": gvjs_fa,
    "=": "&#61;",
    ">": "&gt;",
    "`": "&#96;",
    "\u0085": "&#133;",
    "\u00a0": "&#160;",
    "\u2028": "&#8232;",
    "\u2029": "&#8233;"
};
function gvjs_DB(a) {
    return gvjs_Yda[a]
}
var gvjs_EB = /[\x00\x22\x26\x27\x3c\x3e]/g;
function gvjs_FB(a) {
    return null != a && a.eq === gvjs_pq ? a : a instanceof gvjs_Zf ? gvjs_W(gvjs_0f(a), a.getDirection()) : gvjs_W(String(String(a)).replace(gvjs_EB, gvjs_DB), gvjs_Vda(a))
}
var gvjs_Zda = /[\x00\x22\x27\x3c\x3e]/g;
function gvjs_GB(a) {
    return String(a).replace(gvjs_Zda, gvjs_DB)
}
function gvjs_7(a) {
    null != a && a.eq === gvjs_pq ? (a = a.getContent(),
    a = String(a).replace(gvjs_Wda, "").replace(gvjs_Xda, gvjs_fa),
    a = gvjs_GB(a)) : a = String(a).replace(gvjs_EB, gvjs_DB);
    return a
}
var gvjs__da = /^[a-zA-Z0-9+\/_-]+={0,2}$/;
function gvjs_HB(a) {
    a = String(a);
    return gvjs__da.test(a) ? a : "zSoyz"
}
function gvjs_IB(a) {
    return gvjs_r(a) ? a instanceof gvjs_qq ? gvjs_wy(a) : gvjs_2f("zSoyz") : gvjs_2f(String(a))
}
var gvjs_JB = {};
function gvjs_KB(a, b, c, d) {
    b = gvjs_IB(b(c || gvjs_JB, d));
    gvjs_cg(a, b)
}
function gvjs_LB(a, b, c, d) {
    a = a(b || gvjs_JB, c);
    d = (d || gvjs_3g()).createElement(gvjs_b);
    a = gvjs_IB(a);
    gvjs_cg(d, a);
    1 == d.childNodes.length && (a = d.firstChild,
    1 == a.nodeType && (d = a));
    return d
}
function gvjs_0da(a, b) {
    var c = a.YDa
      , d = a.frameId
      , e = a.width;
    a = a.height;
    d = '<iframe name="' + gvjs_7(d) + gvjs_ir + gvjs_7(d) + '" type="' + (c ? "" : "image/svg+xml") + '" frameBorder="0" scrolling="no" marginHeight="0" marginWidth="0" width="' + gvjs_7(e) + '" height="' + gvjs_7(a) + '" allowTransparency="true" srcdoc="';
    e = b && b.CCa;
    b = b && b.DCa;
    c = gvjs_W((c ? '<html xmlns:v="urn:schemas-microsoft-com:vml"><head>\n          <style' + (b ? ' nonce="' + gvjs_7(gvjs_HB(b)) + '"' : "") + ">\n            v\\:* {\n              behavior:url(#default#VML);\n            }\n          </style>\n        </head>" : '<?xml version="1.0"?><html xmlns="http://www.w3.org/1999/xhtml" xmlns:svg="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><head></head>') + '<body marginwidth="0" marginheight="0" style="background:transparent"><div id="renderers"></div>\n      <script' + (e ? ' nonce="' + gvjs_7(gvjs_HB(e)) + '"' : "") + ">\n        var _loaded = false;\n        function CHART_loaded() {\n          _loaded = true;\n        }\n        document.body.onload = CHART_loaded;\n      \x3c/script>\n      </body></html>");
    return gvjs_W(d + gvjs_7(String(gvjs_FB(c))) + '"></iframe>')
}
function gvjs_MB(a) {
    gvjs_F.call(this);
    this.ma = a;
    this.ea = new gvjs_KA
}
gvjs_o(gvjs_MB, gvjs_F);
gvjs_ = gvjs_MB.prototype;
gvjs_.getContainer = function() {
    return this.ma
}
;
gvjs_.clear = function() {
    this.YG();
    this.ea = new gvjs_KA
}
;
gvjs_.YG = function() {
    gvjs_hh(this.ma);
    this.ea.removeAll();
    gvjs_E(this.ea)
}
;
gvjs_.M = function() {
    this.YG();
    gvjs_F.prototype.M.call(this)
}
;
gvjs_.ic = function(a, b, c) {
    this.ea.o(a, b, c)
}
;
function gvjs_NB(a, b) {
    var c = Array.prototype.slice.call(arguments)
      , d = c.shift();
    if ("undefined" == typeof d)
        throw Error("[goog.string.format] Template required");
    return d.replace(/%([0\- \+]*)(\d+)?(\.(\d+))?([%sfdiu])/g, function(e, f, g, h, k, l, m, n) {
        if ("%" == l)
            return "%";
        var p = c.shift();
        if ("undefined" == typeof p)
            throw Error("[goog.string.format] Not enough arguments");
        arguments[0] = p;
        return gvjs_tq[l].apply(null, arguments)
    })
}
function gvjs_OB(a, b) {
    if (Array.isArray(a))
        return a.join(",");
    switch (a) {
    case gvjs_Zw:
        return "0";
    case gvjs_9t:
        return String(4 * b) + "," + String(b);
    default:
        return gvjs_OB(gvjs_Zw, b)
    }
}
function gvjs_PB(a, b) {
    gvjs_pB.call(this, a, b);
    this.jq = null;
    this.hS = {};
    this.IZ = {};
    this.X3 = {};
    this.KC("-._.-*^*-._.-*^*-._.-", {
        fontSize: 8,
        bb: gvjs_2r,
        bold: !1,
        Nc: !1
    });
    this.AQ = !1;
    for (a = this.container.parentElement.parentElement; a; ) {
        if (null != a.getAttribute("dir")) {
            this.AQ = a.getAttribute("dir") === gvjs_Up;
            break
        }
        a = a.parentElement
    }
}
gvjs_o(gvjs_PB, gvjs_pB);
function gvjs_QB(a, b) {
    a.jq = a.kb(gvjs_hp);
    var c = gvjs__A();
    a.jq.setAttribute(gvjs_5c, c);
    a.hS = {};
    a.IZ = {};
    a.X3 = {};
    b.appendChild(a.jq)
}
gvjs_ = gvjs_PB.prototype;
gvjs_.bO = function(a, b) {
    this.width = a;
    this.height = b;
    var c = this.kb(gvjs_9p);
    c.setAttribute(gvjs_Xd, a);
    c.setAttribute(gvjs_4c, b);
    c.style.overflow = gvjs_0u;
    c.setAttribute(gvjs_et, "A chart.");
    this.container.appendChild(c);
    gvjs_QB(this, c);
    return new gvjs_QA(c)
}
;
gvjs_.Qj = function(a) {
    var b = gvjs_Oh().Vj().SVGElement;
    return typeof b === gvjs_h && a instanceof b && a.tagName.toLowerCase() !== gvjs_Lp && a.tagName.toLowerCase() !== gvjs_9p ? (b = a.getBBox(),
    b.y | b.x | b.height | b.width ? new gvjs_B(b.y,b.x + b.width,b.y + b.height,b.x) : gvjs_pB.prototype.Qj.call(this, a)) : gvjs_pB.prototype.Qj.call(this, a)
}
;
gvjs_.WX = function() {
    for (var a = this.kw.j(), b = a.childNodes, c = b.length; 1 < c; )
        a.removeChild(b[0]),
        c--;
    gvjs_QB(this, a)
}
;
gvjs_.Poa = function() {
    return this.container.innerHTML
}
;
gvjs_.round = function(a) {
    return Math.round(100 * a) / 100
}
;
gvjs_.$x = function(a, b, c, d) {
    var e = this.kb(gvjs_4o);
    e.setAttribute("cx", a);
    e.setAttribute("cy", b);
    e.setAttribute("r", c);
    this.rj(e, d);
    return e
}
;
gvjs_.mX = function(a, b, c, d, e) {
    var f = this.kb(gvjs_jp);
    f.setAttribute("cx", a);
    f.setAttribute("cy", b);
    f.setAttribute("rx", c);
    f.setAttribute("ry", d);
    this.rj(f, e);
    return f
}
;
gvjs_.Bl = function(a, b, c, d, e) {
    var f = this.kb(gvjs_Qp);
    f.setAttribute("x", a);
    f.setAttribute("y", b);
    f.setAttribute(gvjs_Xd, c);
    f.setAttribute(gvjs_4c, d);
    this.rj(f, e);
    return f
}
;
gvjs_.AD = gvjs_n(46);
gvjs_.tX = function(a, b) {
    var c = this.kb(gvjs_Lp);
    0 < a.length && c.setAttribute("d", a.join(""));
    this.rj(c, b);
    return c
}
;
gvjs_.by = function(a, b, c, d, e, f, g, h) {
    return this.ys(a, b, c, d, 0, e, f, g, h)
}
;
gvjs_.pH = function(a, b, c, d, e, f, g, h, k) {
    var l = gvjs_WA(b, d, f, k)
      , m = gvjs_WA(c, e, f, k);
    return this.ys(a, l, m, Math.sqrt(gvjs_cA(new gvjs_bA(b,c,d,e))), gvjs_5y(gvjs_7y(Math.atan2(e - c, d - b))), f, g, h, k)
}
;
gvjs_.ys = function(a, b, c, d, e, f, g, h, k) {
    var l = void 0 !== h.opacity ? h.opacity : 1
      , m = new gvjs_3({
        fill: h.color,
        fillOpacity: l
    });
    if (h.color && h.color != gvjs_f && h.Lb && h.Lb != gvjs_f) {
        l = new gvjs_3({
            fill: h.color,
            fillOpacity: l,
            stroke: h.Lb,
            strokeOpacity: l,
            strokeWidth: h.tG
        });
        var n = this.Sa();
        this.RH(a, b, c, d, e, f, g, h, l, n, k).setAttribute(gvjs_dt, gvjs_Rd);
        this.RH(a, b, c, d, e, f, g, h, m, n, k);
        return n.j()
    }
    return this.oH(a, b, c, d, e, f, g, h, m, k)
}
;
gvjs_.oH = function(a, b, c, d, e, f, g, h, k, l) {
    d = this.kb(gvjs_m);
    g = gvjs_VA(0, h.fontSize, g);
    g = gvjs_WA(g.start, g.end, gvjs_R);
    g -= .15 * h.fontSize;
    g = new gvjs_ok(0,g);
    g.rotate(gvjs_6y(e));
    c = new gvjs_ok(b,c);
    c.add(g);
    b = c.x;
    c = c.y;
    d.appendChild(this.zO.createTextNode(a));
    switch (f) {
    case gvjs_2:
        d.setAttribute(gvjs_$p, gvjs_2);
        break;
    case gvjs_0:
        d.setAttribute(gvjs_$p, gvjs_Nv);
        break;
    case gvjs_R:
        d.setAttribute(gvjs_$p, gvjs_R)
    }
    d.setAttribute("x", b);
    d.setAttribute("y", c);
    d.setAttribute("font-family", h.bb);
    d.setAttribute("font-size", h.fontSize || 0);
    h.bold && d.setAttribute(gvjs_Cu, gvjs_st);
    h.Nc && d.setAttribute(gvjs_Bu, gvjs_Gp);
    h.Ue && d.setAttribute(gvjs_ax, gvjs_bq);
    l && d.setAttribute(gvjs_iu, gvjs_Up);
    0 != e && d.setAttribute(gvjs_aq, gvjs_Tp + e + " " + b + " " + c + ")");
    this.rj(d, k);
    return d
}
;
gvjs_.RH = function(a, b, c, d, e, f, g, h, k, l, m) {
    a = this.oH(a, b, c, d, e, f, g, h, k, m);
    this.appendChild(l, a);
    return a
}
;
gvjs_.nX = function() {
    return this.kb("g")
}
;
gvjs_.ZG = function(a, b, c) {
    var d = gvjs__A()
      , e = this.kb("clipPath");
    c ? (c = this.kb(gvjs_jp),
    c.setAttribute("cx", b.left + b.width / 2),
    c.setAttribute("cy", b.top + b.height / 2),
    c.setAttribute("rx", b.width / 2),
    c.setAttribute("ry", b.height / 2),
    e.appendChild(c)) : (c = this.kb(gvjs_Qp),
    c.setAttribute("x", b.left),
    c.setAttribute("y", b.top),
    c.setAttribute(gvjs_Xd, b.width),
    c.setAttribute(gvjs_4c, b.height),
    e.appendChild(c));
    e.setAttribute(gvjs_5c, d);
    this.jq.appendChild(e);
    a = a.j();
    a.setAttribute(gvjs_5o, gvjs_RB(d));
    return a
}
;
function gvjs_RB(a) {
    var b = "";
    gvjs_y && "9.0" === gvjs_Dg || (b = window.location.href.split("#")[0]);
    return "url(" + b + "#" + a + ")"
}
gvjs_.nd = function(a, b, c) {
    a.push("M" + b + "," + c)
}
;
gvjs_.Ma = function(a, b, c) {
    a.push("L" + b + "," + c)
}
;
gvjs_.Yr = function(a, b, c, d, e, f, g) {
    a.push("C" + b + "," + c + "," + d + "," + e + "," + f + "," + g)
}
;
gvjs_.Qi = function(a) {
    a.push("Z")
}
;
gvjs_.Bm = function(a, b, c, d, e, f, g, h) {
    if (0 < d && 0 < e) {
        var k = gvjs_5y(g) - gvjs_5y(f);
        180 < k ? k -= 360 : -180 >= k && (k = 360 + k);
        var l = 2 * Math.PI * Math.min(d, e);
        .1 > Math.abs(k / 360 * l) && (k = (.1 / l * 360 - Math.abs(k)) * gvjs_$y(k) / 2,
        f -= k,
        g += k)
    }
    f = gvjs_5y(f);
    g = gvjs_5y(g);
    l = gvjs_8y(g - 90, d);
    var m = gvjs_9y(g - 90, e);
    k = h ? g - f : f - g;
    0 > k && (k += 360);
    a.push("A" + d + "," + e + ",0," + (180 < k ? 1 : 0) + "," + (h ? 1 : 0) + "," + (b + l) + "," + (c + m))
}
;
gvjs_.mp = function(a, b, c) {
    a.setAttribute(gvjs_aq, "translate(" + b + gvjs_ha + c + ")")
}
;
gvjs_.Ug = function(a, b) {
    a.setAttribute(gvjs_Xd, b)
}
;
gvjs_.fl = function(a, b) {
    a.setAttribute(gvjs_4c, b)
}
;
gvjs_.tA = gvjs_n(49);
gvjs_.xA = gvjs_n(52);
gvjs_.rd = function(a, b, c) {
    a.setAttribute(gvjs_2p, c);
    b && a.setAttribute(gvjs_0p, b)
}
;
gvjs_.KC = function(a, b, c) {
    var d = this.jF;
    if (3 === d.firstChild.nodeType)
        d.firstChild.data = a;
    else
        throw Error("Unexpected type of text node " + d.firstChild.nodeType);
    a = d.style;
    a.fontFamily = b.bb;
    a.fontSize = b.fontSize + gvjs_T;
    a.fontWeight = b.bold ? gvjs_st : "";
    a.fontStyle = b.Nc ? gvjs_Gp : "";
    a.display = gvjs_xb;
    null != c && (b = gvjs_NB("rotate(%ddeg)", c),
    a.transform = b,
    a.transformOrigin = gvjs_Mr,
    a.WebkitTransform = b,
    a.WebkitTransformOrigin = gvjs_Mr,
    a.MozTransform = b,
    a.MozTransformOrigin = gvjs_Mr,
    a.WAa = b,
    a.XAa = gvjs_Mr,
    a.msTransform = b,
    a.eEa = gvjs_Mr);
    b = d.clientWidth;
    d = d.clientHeight;
    a.display = gvjs_f;
    return new gvjs_A(b,d)
}
;
gvjs_.IC = gvjs_n(55);
gvjs_.kb = function(a) {
    return this.zO.createElementNS(gvjs_Ep, a)
}
;
gvjs_.rj = function(a, b) {
    gvjs_ey(b) ? (a.setAttribute(gvjs_0p, b.Uj()),
    a.setAttribute(gvjs_2p, b.strokeWidth),
    gvjs_ey(b) && 1 <= b.strokeOpacity ? a.removeAttribute(gvjs_1p) : a.setAttribute(gvjs_1p, b.strokeOpacity),
    b.Mi !== gvjs_Zw ? a.setAttribute(gvjs_7w, gvjs_OB(b.Mi, b.strokeWidth)) : a.removeAttribute(gvjs_7w)) : (a.setAttribute(gvjs_0p, gvjs_f),
    a.setAttribute(gvjs_2p, 0));
    gvjs_hy(b) ? a.removeAttribute(gvjs_op) : a.setAttribute(gvjs_op, b.fillOpacity);
    var c = b.radiusX;
    typeof c === gvjs_g && a.setAttribute("rx", c);
    c = b.radiusY;
    typeof c === gvjs_g && a.setAttribute("ry", c);
    var d = b.gradient
      , e = b.pattern;
    if (d) {
        e = gvjs_Wz(d, 1).toString();
        c = this.IZ[e];
        if (!c) {
            c = gvjs__A();
            this.IZ[e] = c;
            e = this.kb(gvjs_Ip);
            var f = d.x1
              , g = d.x2
              , h = d.y1
              , k = d.y2
              , l = d.Vf
              , m = d.sf
              , n = 1;
            if (0 === d.tn || d.tn)
                n = d.tn;
            var p = 1;
            if (0 === d.un || d.un)
                p = d.un;
            var q = d.Sn ? "objectBoundingBox" : gvjs_Bx;
            e.setAttribute(gvjs_5c, c);
            e.setAttribute("x1", f);
            e.setAttribute("y1", h);
            e.setAttribute("x2", g);
            e.setAttribute("y2", k);
            e.setAttribute("gradientUnits", q);
            f = gvjs_6w + l + gvjs_Xr + n;
            m = gvjs_6w + m + gvjs_Xr + p;
            p = this.kb(gvjs__p);
            p.setAttribute(gvjs_Jp, gvjs_Ro);
            p.setAttribute(gvjs_Jd, f);
            e.appendChild(p);
            d.sp && (d = this.kb(gvjs__p),
            d.setAttribute(gvjs_Jp, "49.99%"),
            d.setAttribute(gvjs_Jd, f),
            e.appendChild(d),
            d = this.kb(gvjs__p),
            d.setAttribute(gvjs_Jp, "50%"),
            d.setAttribute(gvjs_Jd, m),
            e.appendChild(d));
            d = this.kb(gvjs__p);
            d.setAttribute(gvjs_Jp, gvjs_So);
            d.setAttribute(gvjs_Jd, m);
            e.appendChild(d);
            this.jq.appendChild(e)
        }
        a.setAttribute(gvjs_np, gvjs_RB(c))
    } else if (e) {
        c = e.getStyle() + "_" + e.ee() + "_" + e.getBackgroundColor();
        if (!(c in this.hS)) {
            d = null;
            switch (e.getStyle()) {
            case gvjs_rw:
                d = this.kb(gvjs_td);
                d.setAttribute("patternUnits", gvjs_Bx);
                d.setAttribute("x", "0");
                d.setAttribute("y", "0");
                d.setAttribute(gvjs_Xd, "4");
                d.setAttribute(gvjs_4c, "4");
                d.setAttribute("viewBox", "0 0 4 4");
                m = this.kb(gvjs_Qp);
                m.setAttribute("x", "0");
                m.setAttribute("y", "0");
                m.setAttribute(gvjs_Xd, "4");
                m.setAttribute(gvjs_4c, "4");
                m.setAttribute(gvjs_np, e.getBackgroundColor());
                d.appendChild(m);
                m = this.kb("g");
                m.setAttribute(gvjs_0p, e.ee());
                m.setAttribute(gvjs_8w, gvjs_1w);
                e = this.kb(gvjs_e);
                e.setAttribute("x1", "2");
                e.setAttribute("y1", "0");
                e.setAttribute("x2", "4");
                e.setAttribute("y2", "2");
                e.setAttribute(gvjs_2p, "2");
                m.appendChild(e);
                e = this.kb(gvjs_e);
                e.setAttribute("x1", "0");
                e.setAttribute("y1", "2");
                e.setAttribute("x2", "2");
                e.setAttribute("y2", "4");
                e.setAttribute(gvjs_2p, "2");
                m.appendChild(e);
                d.appendChild(m);
                break;
            case gvjs_Hw:
                d = this.kb(gvjs_td),
                d.setAttribute("patternUnits", gvjs_Bx),
                d.setAttribute("x", "0"),
                d.setAttribute("y", "0"),
                d.setAttribute(gvjs_Xd, "6"),
                d.setAttribute(gvjs_4c, "6"),
                d.setAttribute("viewBox", "0 0 4 4"),
                m = this.kb(gvjs_Qp),
                m.setAttribute("x", "0"),
                m.setAttribute("y", "0"),
                m.setAttribute(gvjs_Xd, "4"),
                m.setAttribute(gvjs_4c, "4"),
                m.setAttribute(gvjs_np, e.getBackgroundColor()),
                d.appendChild(m),
                m = this.kb("g"),
                m.setAttribute(gvjs_0p, e.ee()),
                m.setAttribute(gvjs_8w, gvjs_1w),
                e = this.kb(gvjs_e),
                e.setAttribute("x1", "2"),
                e.setAttribute("y1", "0"),
                e.setAttribute("x2", "0"),
                e.setAttribute("y2", "2"),
                e.setAttribute(gvjs_2p, "2"),
                m.appendChild(e),
                e = this.kb(gvjs_e),
                e.setAttribute("x1", "4"),
                e.setAttribute("y1", "2"),
                e.setAttribute("x2", "2"),
                e.setAttribute("y2", "4"),
                e.setAttribute(gvjs_2p, "2"),
                m.appendChild(e),
                d.appendChild(m)
            }
            e = gvjs__A();
            d.setAttribute(gvjs_5c, e);
            this.jq.appendChild(d);
            this.hS[c] = e
        }
        c = this.hS[c];
        a.setAttribute(gvjs_np, gvjs_RB(c))
    } else
        a.setAttribute(gvjs_np, b.fill);
    null != b.Rw && (e = b.Rw,
    c = gvjs_Wz(e, 1).toString(),
    b = this.X3[c],
    b || (b = gvjs__A(),
    this.X3[c] = b,
    c = this.kb(gvjs_tp),
    c.setAttribute(gvjs_5c, b),
    d = this.kb(gvjs_lp),
    d.setAttribute(gvjs_Fp, "SourceAlpha"),
    d.setAttribute("stdDeviation", e.radius || 0),
    c.appendChild(d),
    d = this.kb("feOffset"),
    d.setAttribute("dx", e.xOffset || 0),
    d.setAttribute("dy", e.yOffset || 0),
    c.appendChild(d),
    null != e.opacity && (d = this.kb(gvjs_kp),
    m = this.kb("feFuncA"),
    m.setAttribute(gvjs_Sd, gvjs_Hp),
    m.setAttribute("slope", e.opacity),
    d.appendChild(m),
    c.appendChild(d)),
    e = this.kb("feMerge"),
    d = this.kb(gvjs_mp),
    e.appendChild(d),
    d = this.kb(gvjs_mp),
    d.setAttribute(gvjs_Fp, "SourceGraphic"),
    e.appendChild(d),
    c.appendChild(e),
    this.jq.appendChild(c)),
    a.setAttribute(gvjs_tp, gvjs_RB(b)))
}
;
gvjs_.ws = function() {
    var a = gvjs_4(gvjs_b, {
        "aria-label": "A tabular representation of the data in the chart.",
        style: "position:absolute;left:" + (this.AQ ? 1E4 : -1E4) + "px;top:auto;width:1px;height:1px;overflow:hidden"
    });
    this.container.appendChild(a);
    this.container.setAttribute(gvjs_et, "A chart.");
    return a
}
;
function gvjs_SB(a) {
    if (Array.isArray(a))
        return a.join(" ");
    switch (a) {
    case gvjs_Zw:
        return gvjs_Zw;
    case gvjs_9t:
        return "shortdash";
    default:
        return gvjs_SB(gvjs_Zw)
    }
}
function gvjs_TB(a, b) {
    gvjs_pB.call(this, a, b);
    this.Xw = null
}
gvjs_o(gvjs_TB, gvjs_pB);
gvjs_ = gvjs_TB.prototype;
gvjs_.bO = function(a, b) {
    this.width = a;
    this.height = b;
    var c = this.Qd(gvjs_Ob);
    this.qk(c, -5E4, -5E4, this.width + 1E5, this.height + 1E5);
    this.container.appendChild(c);
    var d = this.Sa()
      , e = d.j();
    e.coordorigin = gvjs_Mr;
    e.coordsize = a + " " + b;
    e.style.top = this.Ub(5E4);
    e.style.left = this.Ub(5E4);
    c.appendChild(e);
    return d
}
;
gvjs_.WX = function() {
    for (var a = this.kw.j(), b = a.childNodes, c = b.length; 1 < c; )
        a.removeChild(b[0]),
        c--
}
;
gvjs_.round = function(a) {
    return Math.round(a)
}
;
gvjs_.$x = function(a, b, c, d) {
    var e = this.Qd(gvjs_Ex)
      , f = 2 * c;
    this.qk(e, a - c, b - c, f, f);
    this.rj(e, d, !1);
    return e
}
;
gvjs_.mX = function(a, b, c, d, e) {
    var f = this.Qd(gvjs_Ex);
    this.qk(f, a - c, b - d, 2 * c, 2 * d);
    this.rj(f, e, !1);
    return f
}
;
gvjs_.Bl = function(a, b, c, d, e) {
    var f = this.Qd("v:rect")
      , g = gvjs_hy(e) && 1 <= d && 1 <= c && null == e.gradient;
    this.rj(f, e, g);
    if (gvjs_ey(e) || g)
        c = Math.max(c - 1, 0),
        d = Math.max(d - 1, 0);
    this.qk(f, a, b, c, d);
    return f
}
;
gvjs_.AD = gvjs_n(45);
gvjs_.tX = function(a, b) {
    for (var c = this.Qd(gvjs_Gx), d = this.Qd(gvjs_Fx); 0 < a.length && gvjs_hf(gvjs_Ae(a), "M"); )
        a = gvjs_Oe(a, 0, a.length - 1);
    d.setAttribute("v", a.join(""));
    this.qk(c, 0, 0, this.width, this.height);
    c.appendChild(d);
    this.rj(c, b, !1);
    return c
}
;
gvjs_.by = function(a, b, c, d, e, f, g) {
    b = gvjs_VA(b, d, e);
    c = gvjs_VA(c, g.fontSize, f);
    f = gvjs_0;
    c = gvjs_WA(c.start, c.end, f);
    return this.pH(a, b.start, c, b.end, c, e, f, g)
}
;
gvjs_.pH = function(a, b, c, d, e, f, g, h) {
    var k = new gvjs_3({
        fill: h.color
    });
    if (h.color && h.color != gvjs_f && h.Lb && h.Lb != gvjs_f) {
        var l = new gvjs_3({
            fill: h.color,
            stroke: h.Lb,
            strokeWidth: 2
        })
          , m = this.Sa();
        this.RH(a, b, c, d, e, f, g, h, l, m);
        this.RH(a, b, c, d, e, f, g, h, k, m);
        return m.j()
    }
    return this.oH(a, b, c, d, e, f, g, h, k)
}
;
gvjs_.ys = function(a, b, c, d, e, f, g, h) {
    e = gvjs_6y(e);
    d = gvjs_VA(b, d, f);
    b = new gvjs_ok(b,c);
    var k = new gvjs_ok(d.start,c);
    k = k.clone().aU(b).rotate(e).add(b);
    c = new gvjs_ok(d.end,c);
    c = c.clone().aU(b).rotate(e).add(b);
    return this.pH(a, k.x, k.y, c.x, c.y, f, g, h)
}
;
gvjs_.oH = function(a, b, c, d, e, f, g, h, k) {
    var l = this.Qd(gvjs_Gx);
    this.qk(l, 0, 0, this.width, this.height);
    g != gvjs_0 && (g = gvjs_VA(0, h.fontSize, g),
    g = gvjs_WA(g.start, g.end, gvjs_0),
    g = new gvjs_ok(0,g),
    g.rotate(gvjs_6y(gvjs_5y(gvjs_7y(Math.atan2(e - c, d - b))))),
    c = new gvjs_ok(b,c),
    e = new gvjs_ok(d,e),
    c.add(g),
    e.add(g),
    b = c.x,
    c = c.y,
    d = e.x,
    e = e.y);
    b = Math.round(b);
    c = Math.round(c);
    d = Math.round(d);
    e = Math.round(e);
    g = this.Qd(gvjs_Fx);
    g.setAttribute("v", "M" + b + "," + c + "L" + d + "," + e + "E");
    g.setAttribute(gvjs_cx, gvjs_Rd);
    b = this.Qd("v:textpath");
    b.setAttribute("on", gvjs_Rd);
    d = b.style;
    d.fontSize = h.fontSize || "";
    d.fontFamily = h.bb || "";
    switch (f) {
    case gvjs_2:
        d.setAttribute(gvjs_Cx, gvjs_$c);
        break;
    case gvjs_0:
        d.setAttribute(gvjs_Cx, gvjs_0);
        break;
    case gvjs_R:
        d.setAttribute(gvjs_Cx, gvjs_j)
    }
    h.bold && (d.fontWeight = gvjs_st);
    h.Nc && (d.fontStyle = gvjs_Gp);
    b.setAttribute(gvjs_l, a);
    l.appendChild(g);
    l.appendChild(b);
    this.rj(l, k, !1);
    return l
}
;
gvjs_.RH = function(a, b, c, d, e, f, g, h, k, l) {
    a = this.oH(a, b, c, d, e, f, g, h, k);
    this.appendChild(l, a);
    return a
}
;
gvjs_.nX = function() {
    var a = this.Qd("v:group");
    this.qk(a, 0, 0, this.width, this.height);
    return a
}
;
gvjs_.ZG = function(a, b) {
    var c = this.Qd(gvjs_Ob);
    c.style.clip = "rect(" + [this.Ub(5E4 + b.top), this.Ub(5E4 + b.left + b.width), this.Ub(5E4 + b.top + b.height), this.Ub(5E4 + b.left)].join(gvjs_ha) + ")";
    this.qk(c, 0, 0, this.width + 1E5, this.height + 1E5);
    a.j();
    b = new gvjs_QA(c);
    this.appendChild(b, a);
    this.yb(1, 1, 1, 1, new gvjs_3({
        fill: gvjs_Ox
    }), b);
    return c
}
;
gvjs_.nd = function(a, b, c) {
    a.push("M" + Math.round(b) + "," + Math.round(c))
}
;
gvjs_.Ma = function(a, b, c) {
    a.push("L" + Math.round(b) + "," + Math.round(c))
}
;
gvjs_.Yr = function(a, b, c, d, e, f, g) {
    a.push("C" + Math.round(b) + "," + Math.round(c) + "," + Math.round(d) + "," + Math.round(e) + "," + Math.round(f) + "," + Math.round(g))
}
;
gvjs_.Qi = function(a) {
    a.push("X")
}
;
gvjs_.Bm = function(a, b, c, d, e, f, g, h) {
    f = gvjs_5y(f);
    g = gvjs_5y(g);
    var k = Math.round(gvjs_8y(f - 90, d))
      , l = Math.round(gvjs_9y(f - 90, e))
      , m = Math.round(gvjs_8y(g - 90, d))
      , n = Math.round(gvjs_9y(g - 90, e));
    d = Math.round(d);
    e = Math.round(e);
    b = Math.round(b);
    c = Math.round(c);
    k === m && l === n && (h && 180 > gvjs_5y(g - f) || !h && 180 > gvjs_5y(f - g)) || a.push((h ? "WA" : "AT") + (b - d) + "," + (c - e) + "," + (b + d) + "," + (c + e) + "," + (b + k) + "," + (c + l) + "," + (b + m) + "," + (c + n))
}
;
gvjs_.mp = function(a, b, c) {
    a.style.top = this.Ub(c);
    a.style.left = this.Ub(b)
}
;
gvjs_.Ug = function(a, b) {
    a.style.width = this.Ub(b)
}
;
gvjs_.fl = function(a, b) {
    a.style.height = this.Ub(b)
}
;
gvjs_.tA = gvjs_n(48);
gvjs_.xA = gvjs_n(51);
gvjs_.rd = function(a, b, c) {
    0 == c ? a.stroked = !1 : (a.stroked = !0,
    b && (a.strokecolor = b),
    a.strokeweight = c)
}
;
gvjs_.KC = function(a, b) {
    var c = this.jF;
    c.firstChild.data = a;
    a = c.style;
    a.fontFamily = b.bb;
    a.fontSize = this.Ub(b.fontSize || 0);
    a.fontWeight = b.bold ? gvjs_st : "";
    a.fontStyle = b.Nc ? gvjs_Gp : "";
    a.display = gvjs_xb;
    var d = c.clientWidth;
    c = c.clientHeight;
    a.display = gvjs_f;
    b.bold && (d *= 1.1);
    b.Nc && (d *= .9);
    return new gvjs_A(d,c)
}
;
gvjs_.IC = gvjs_n(54);
gvjs_.Ub = function(a) {
    return Math.round(a) + gvjs_T
}
;
gvjs_.Qd = function(a) {
    return this.zO.createElement(a)
}
;
gvjs_.rj = function(a, b, c) {
    for (var d = a.children, e = 0; e < d.length; e++)
        a.children[e].tagName != gvjs_np && a.children[e].tagName != gvjs_0p || a.removeChild(d[e]);
    c = null != c ? c : !0;
    if (gvjs_ey(b)) {
        if (a.stroked = !0,
        a.strokeweight = b.strokeWidth,
        a.strokecolor = b.Uj(),
        c = !(gvjs_ey(b) && 1 <= b.strokeOpacity),
        d = b.Mi !== gvjs_Zw,
        c || d)
            e = this.Qd("v:stroke"),
            c && (e.opacity = String(Math.round(100 * b.strokeOpacity)) + "%"),
            d && (e.dashstyle = gvjs_SB(b.Mi)),
            a.appendChild(e)
    } else
        c && gvjs_hy(b) ? (a.stroked = !0,
        a.strokeweight = 1,
        a.strokecolor = b.fill) : a.stroked = !1;
    void 0 !== a.filled && (a.filled = !0);
    c = b.gradient;
    if (null != c) {
        b = this.Qd(gvjs_Dx);
        b.setAttribute(gvjs_1, c.Vf);
        b.setAttribute("color2", c.sf);
        b.setAttribute(gvjs_Kp, c.tn || 1);
        b.setAttribute("opacity2", c.un || 1);
        d = c.x1;
        e = c.y1;
        var f = c.x2;
        c = c.y2;
        typeof d == gvjs_l && (d = parseInt(d, 10));
        typeof e == gvjs_l && (e = parseInt(e, 10));
        typeof f == gvjs_l && (f = parseInt(f, 10));
        typeof c == gvjs_l && (c = parseInt(c, 10));
        c = gvjs_5y(gvjs_7y(Math.atan2(c - e, f - d)));
        c = gvjs_3y(270 - c, 360);
        b.setAttribute("angle", c);
        b.setAttribute(gvjs_Sd, gvjs_Bp);
        a.appendChild(b)
    } else
        b.pattern ? (c = b.pattern,
        b = this.Qd(gvjs_Dx),
        b.setAttribute(gvjs_Sd, gvjs_td),
        b.setAttribute(gvjs_1, c.ee()),
        b.setAttribute("color2", c.getBackgroundColor()),
        c = gvjs_je("google.charts.loader.makeCssUrl")({
            subdir1: "core",
            subdir2: "patterns",
            filename: c.getStyle() + ".gif"
        }),
        b.setAttribute("src", c),
        a.appendChild(b)) : b.fill == gvjs_f ? a.filled = !1 : gvjs_hy(b) ? a.fillcolor = b.fill : (c = this.Qd(gvjs_Dx),
        c.opacity = String(Math.round(100 * b.fillOpacity)) + "%",
        c.color = b.fill,
        a.appendChild(c))
}
;
gvjs_.qk = function(a, b, c, d, e) {
    a = a.style;
    a.position = gvjs_c;
    a.left = this.Ub(b);
    a.top = this.Ub(c);
    a.width = this.Ub(d);
    a.height = this.Ub(e)
}
;
gvjs_.cw = gvjs_n(35);
var gvjs_UB;
function gvjs_VB(a, b) {
    b ? a.setAttribute(gvjs_Bd, b) : a.removeAttribute(gvjs_Bd)
}
function gvjs_WB(a, b, c) {
    Array.isArray(c) && (c = c.join(" "));
    var d = "aria-" + b;
    "" === c || void 0 == c ? (gvjs_UB || (gvjs_UB = {
        atomic: !1,
        autocomplete: gvjs_f,
        dropeffect: gvjs_f,
        haspopup: !1,
        live: "off",
        multiline: !1,
        multiselectable: !1,
        orientation: gvjs_U,
        readonly: !1,
        relevant: "additions text",
        required: !1,
        sort: gvjs_f,
        busy: !1,
        disabled: !1,
        hidden: !1,
        invalid: gvjs_Sb
    }),
    c = gvjs_UB,
    b in c ? a.setAttribute(d, c[b]) : a.removeAttribute(d)) : a.setAttribute(d, c)
}
function gvjs_XB(a, b) {
    a = a.getAttribute("aria-" + b);
    return null == a || void 0 == a ? "" : String(a)
}
function gvjs_YB(a) {
    var b = gvjs_XB(a, gvjs_Ts);
    return gvjs_5g(a).getElementById(b)
}
function gvjs_ZB(a, b) {
    var c = "";
    b && (c = b.id);
    gvjs_WB(a, gvjs_Ts, c)
}
function gvjs__B(a) {
    return gvjs_XB(a, gvjs_8c)
}
function gvjs_0B(a, b) {
    gvjs_WB(a, gvjs_8c, b)
}
function gvjs_1B(a, b) {
    var c = gvjs_3g(a)
      , d = c.createElement(gvjs_Ob)
      , e = d.style
      , f = b ? b.height + 10 : 0;
    b = b ? b.width + 10 : 0;
    e.display = gvjs_f;
    e.position = gvjs_c;
    e.top = f + gvjs_T;
    e.left = b + gvjs_T;
    e.whiteSpace = gvjs_1v;
    gvjs_WB(d, gvjs_0u, !0);
    d.setAttribute(gvjs_dt, !0);
    c.appendChild(d, c.createTextNode(" "));
    c.appendChild(a, d);
    return d
}
function gvjs_2B(a, b, c, d) {
    a.call() ? b.call() : gvjs_1da(a, b, c, d)
}
function gvjs_1da(a, b, c, d) {
    d = null != d ? d : 10;
    setTimeout(c(function() {
        gvjs_2B(a, b, c, d)
    }), d)
}
function gvjs_3B(a, b, c, d) {
    gvjs_F.call(this);
    if (!(gvjs_y ? 0 <= gvjs_tf(gvjs_Dg, "5.5") : gvjs_sg ? 0 <= gvjs_tf(gvjs_Dg, "1.8") : gvjs_qg ? 0 <= gvjs_tf(gvjs_Dg, "9.0") : gvjs_tg ? 0 <= gvjs_tf(gvjs_Dg, "420+") : gvjs_rg))
        throw Error("Graphics is not supported");
    for (var e = Math.floor(1E5 * Math.random()); window.frames[gvjs_bs + e]; )
        e++;
    this.Pl = gvjs_bs + e;
    (a = this.jM = a) && (a.referencepoint = !0);
    gvjs_hh(this.jM);
    this.El = gvjs_3g(this.jM);
    this.container = this.El.createElement(gvjs_Ob);
    this.container.style.position = gvjs_zd;
    this.jM.appendChild(this.container);
    this.dimensions = b;
    this.W4 = this.km = null;
    this.ot = !1;
    this.tE = [];
    this.Hi = null;
    b = gvjs_Ph();
    this.Dva = (b = gvjs_y ? null != b.documentMode ? 9 > b.documentMode : !gvjs_Eg("9") : !1) ? gvjs_TB : gvjs_PB;
    if (this.OU = b || d)
        a = d = "",
        this.dimensions && (d = this.dimensions.width.toString() + gvjs_T,
        a = this.dimensions.height.toString() + gvjs_T),
        d = gvjs_LB(gvjs_0da, {
            isVml: b,
            frameId: this.Pl,
            width: d,
            height: a
        }),
        this.El.appendChild(this.container, d);
    gvjs_4B(this, c)
}
gvjs_o(gvjs_3B, gvjs_F);
function gvjs_4B(a, b) {
    var c = a.esa.bind(a);
    a = a.sua.bind(a);
    gvjs_2B(c, a, b)
}
gvjs_ = gvjs_3B.prototype;
gvjs_.sua = function() {
    if (this.OU) {
        var a = (a = this.El.j(this.Pl)) ? this.El.Noa(a) : null;
        var b = this.km = a.getElementById("renderers");
        b && (b.referencepoint = !0);
        this.W4 = gvjs_1B(a.body, this.dimensions)
    } else
        this.km = this.El.createElement(gvjs_Ob),
        gvjs_C(this.km, gvjs_vd, gvjs_zd),
        this.dimensions && gvjs_Cz(this.km, this.dimensions),
        this.km.dir = gvjs_Dv,
        this.container.appendChild(this.km),
        this.W4 = gvjs_1B(this.container, this.dimensions);
    this.ot = !0
}
;
gvjs_.esa = function() {
    if (!this.OU)
        return !0;
    var a = this.El.j(this.Pl);
    if (a)
        a: {
            try {
                var b = a.contentWindow || (a.contentDocument ? gvjs_3x(a.contentDocument) : null);
                break a
            } catch (c) {}
            b = null
        }
    else
        b = null;
    return (a = b) ? 1 == a._loaded : !1
}
;
gvjs_.Oa = function(a) {
    var b = void 0 === b ? !0 : b;
    if (!this.ot)
        return null;
    for (a = null != a ? a : 0; this.tE.length <= a; ) {
        var c = b;
        c = void 0 === c ? !0 : c;
        var d = gvjs_3g(this.km).createElement(gvjs_Ob);
        c && (gvjs_C(d, gvjs_vd, gvjs_c),
        gvjs_sz(d, 0, 0));
        gvjs_Cz(d, gvjs_So, gvjs_So);
        this.km.appendChild(d);
        c = new this.Dva(d,this.W4);
        gvjs_6x(this, c);
        this.tE.push(c)
    }
    return this.tE[a]
}
;
gvjs_.yq = function() {
    if (!this.ot)
        return null;
    if (!this.Hi) {
        var a = this.El.createElement(gvjs_Ob);
        this.Hi = new gvjs_MB(a);
        this.El.appendChild(this.container, this.Hi.getContainer())
    }
    return this.Hi
}
;
gvjs_.rl = function(a, b) {
    var c = this;
    gvjs_2B(function() {
        return null != c.km
    }, a, b)
}
;
gvjs_.update = function(a, b) {
    if (null != a && !gvjs_fz(this.dimensions, a))
        if (this.dimensions = a,
        this.OU) {
            if (a = this.El.j(this.Pl))
                a.width = this.dimensions.width.toString(),
                a.height = this.dimensions.height.toString()
        } else
            this.ot && gvjs_Cz(this.km, this.dimensions);
    this.ot || gvjs_4B(this, b)
}
;
gvjs_.M = function() {
    try {
        this.El.qc(this.jM),
        gvjs_E(this.Hi),
        gvjs_u(this.tE, function(a) {
            gvjs_E(a)
        })
    } catch (a) {}
    gvjs_F.prototype.M.call(this)
}
;
function gvjs_5B(a) {
    switch (a.type) {
    case gvjs_Xv:
    case gvjs_e:
    case gvjs_7t:
        return a = a.data,
        new gvjs_z(a.x,a.y);
    case "arc":
        a = a.data;
        var b = gvjs_5y(a.ou);
        return new gvjs_z(a.cx + gvjs_8y(b - 90, a.rx),a.cy + gvjs_9y(b - 90, a.ry));
    default:
        return new gvjs_z(0,0)
    }
}
function gvjs_6B() {
    this.vc = []
}
gvjs_ = gvjs_6B.prototype;
gvjs_.Cj = function(a, b) {
    this.vc.push({
        brush: a,
        s3: b
    })
}
;
gvjs_.move = function(a, b) {
    this.Cj(null, gvjs_RA(a, b))
}
;
gvjs_.va = function(a, b, c) {
    this.Cj(a, {
        type: gvjs_e,
        data: {
            x: b,
            y: c
        }
    })
}
;
gvjs_.Jp = function(a, b, c, d, e, f, g) {
    this.Cj(a, {
        type: gvjs_7t,
        data: {
            x1: b,
            y1: c,
            x2: d,
            y2: e,
            x: f,
            y: g
        }
    })
}
;
gvjs_.Sf = function(a, b, c, d, e, f, g) {
    this.Cj(a, {
        type: "arc",
        data: {
            cx: b,
            cy: c,
            rx: d,
            ry: e,
            Gy: f,
            ou: g,
            zba: void 0
        }
    })
}
;
gvjs_.close = function(a) {
    var b = this.vc[0].s3.data;
    this.va(a, b.x, b.y)
}
;
gvjs_.Dc = function(a) {
    for (var b = [], c = null, d = 0; d < this.vc.length; d++) {
        var e = this.vc[d]
          , f = e.s3;
        if (f.type == gvjs_Xv)
            c = gvjs_5B(f);
        else {
            a: {
                var g = b;
                e = e.brush;
                for (var h = 0; h < g.length; h++) {
                    var k = g[h];
                    if (gvjs_$z(e, k.brush)) {
                        g = k;
                        break a
                    }
                }
                k = {
                    brush: e,
                    vc: new gvjs_SA,
                    ef: null
                };
                g.push(k);
                g = k
            }
            gvjs_2g(g.ef, c) || g.vc.move(c.x, c.y);
            g.vc.Cj(f);
            c = g.ef = gvjs_5B(f)
        }
    }
    if (0 == b.length)
        a = null;
    else if (1 == b.length)
        a = a.Dc(b[0].vc, b[0].brush);
    else {
        c = a.Sa();
        for (d = 0; d < b.length; d++)
            f = b[d],
            f = a.Dc(f.vc, f.brush),
            a.appendChild(c, f);
        a = c.j()
    }
    return a
}
;
function gvjs_7B(a) {
    for (var b = new gvjs_SA, c = 0; c < a.vc.length; c++)
        b.Cj(a.vc[c].s3);
    return b
}
function gvjs_8B(a, b) {
    if (null == b)
        return a;
    b = new gvjs_O(b,b);
    return a ? new gvjs_O(Math.min(a.start, b.start),Math.max(a.end, b.end)) : b
}
function gvjs_9B(a, b, c) {
    var d = null != b ? b : a && null != c && c < a.start ? c : a ? a.start : null;
    a = null != c ? c : a && null != b && b > a.end ? b : a ? a.end : null;
    return null != d && null != a ? new gvjs_O(d,a) : null
}
function gvjs_$B(a) {
    if (0 == a.length)
        return null;
    for (var b = a[0].clone(), c = 1; c < a.length; c++)
        gvjs_5x(b, a[c]);
    return b
}
function gvjs_aC(a, b) {
    var c = a.dm;
    a = a.n;
    var d = b.dm;
    b = b.n;
    isFinite(c) || (c = Infinity);
    isFinite(d) || (d = Infinity);
    if (c == d || 1E-5 >= Math.abs(c - d))
        return a == b || 1E-5 >= Math.abs(a - b) ? Infinity : null;
    if (Infinity == c)
        return new gvjs_z(a,d * a + b);
    if (Infinity == d)
        return new gvjs_z(b,c * b + a);
    var e = d - c;
    return new gvjs_z(-(b - a) / e,(a * d - c * b) / e)
}
function gvjs_bC(a, b) {
    b = (a.x - b.x) / (b.y - a.y);
    isFinite(b) ? a = a.y - b * a.x : (b = Infinity,
    a = a.x);
    return {
        dm: b,
        n: a
    }
}
function gvjs_cC(a, b) {
    var c = new gvjs_SA;
    a = a.vc;
    if (0 == a.length || 1 == a.length)
        return c;
    for (var d = [null], e = 0; e < a.length; e++) {
        var f = a[e];
        f.data && d.push(new gvjs_z(f.data.x,f.data.y))
    }
    d.push(null);
    f = a[a.length - 1].type == gvjs_Yt;
    e = d[1].clone();
    var g = d[2].clone()
      , h = d[d.length - 3].clone()
      , k = d[d.length - 2].clone();
    f ? (d[0] = k,
    d[d.length - 1] = e) : gvjs_2g(e, k) ? (d[0] = h,
    d[d.length - 1] = g) : (d[0] = gvjs_dA(new gvjs_bA(e.x,e.y,g.x,g.y), -1),
    d[d.length - 1] = gvjs_dA(new gvjs_bA(k.x,k.y,h.x,h.y), -1));
    g = 0 > b;
    var l = null
      , m = null;
    k = null;
    h = d.length - 2;
    for (e = 0; e <= h; e++)
        if (!gvjs_2g(d[e], d[e + 1])) {
            var n = d[e];
            var p = d[e + 1]
              , q = (p.y - n.y) / (p.x - n.x);
            var r = isFinite(q) ? {
                dm: q,
                n: n.y - q * n.x
            } : {
                dm: Infinity,
                n: n.x
            };
            q = r.dm;
            r = r.n;
            if (Infinity == q)
                n = {
                    dm: Infinity,
                    n: 0 > p.y - n.y ? r + b : r - b
                };
            else {
                var t = b * Math.sqrt(1 + q * q);
                n = {
                    dm: q,
                    n: 0 < p.x - n.x ? r + t : r - t
                }
            }
            if (l) {
                q = gvjs_aC(l, n);
                gvjs_r(q) ? (p = gvjs_aC(gvjs_bC(m, d[e]), l),
                r = gvjs_aC(gvjs_bC(d[e], m), l),
                p = gvjs_Bl(new gvjs_O(p.x,r.x), q.x) && gvjs_Bl(new gvjs_O(p.y,r.y), q.y)) : p = Infinity == q;
                l = p && Infinity != q ? q : gvjs_aC(gvjs_bC(d[e], m), l);
                m = c;
                q = m.Cj;
                t = k;
                var u = l;
                k = gvjs_0e(t);
                switch (t.type) {
                case gvjs_Xv:
                case gvjs_e:
                    k.data.x = u.x;
                    k.data.y = u.y;
                    break;
                case gvjs_7t:
                    k.data.x = u.x,
                    k.data.y = u.y,
                    r = u.x - t.data.x,
                    t = u.y - t.data.y,
                    k.data.x1 += r,
                    k.data.y1 += t,
                    k.data.x2 += r,
                    k.data.y2 += t
                }
                q.call(m, k);
                p || (k = gvjs_aC(gvjs_bC(d[e], d[e + 1]), n),
                c.Sf(d[e].x, d[e].y, Math.abs(b), Math.abs(b), 180 - gvjs_7y(Math.atan2(l.x - d[e].x, l.y - d[e].y)), 180 - gvjs_7y(Math.atan2(k.x - d[e].x, k.y - d[e].y)), g));
                l = n;
                m = d[e];
                k = a[e]
            } else
                l = n,
                m = d[e],
                k = gvjs_RA(a[e].data.x, a[e].data.y)
        }
    f && c.close();
    return c
}
function gvjs_dC(a, b, c) {
    this.c8 = b;
    this.b8 = c;
    this.cI = {
        add: [],
        click: [],
        mousemove: [],
        mouseenter: [],
        mouseleave: [],
        redraw: [],
        remove: []
    }
}
gvjs_o(gvjs_dC, gvjs_uq);
gvjs_dC.prototype.width = function() {
    return this.c8
}
;
gvjs_dC.prototype.height = function() {
    return this.b8
}
;
var gvjs_eC = {
    NONE: gvjs_f,
    z6: gvjs_fw,
    u6: gvjs_d,
    wV: gvjs_Dd,
    Iza: gvjs_yt,
    Cia: gvjs_4u
}
  , gvjs_fC = {
    NONE: gvjs_f,
    LINE: gvjs_e,
    AREA: gvjs_at,
    yBa: gvjs_4w,
    nV: gvjs_lt,
    Lza: gvjs_Ft,
    wV: gvjs_Dd,
    Jza: gvjs_At
}
  , gvjs_gC = {
    nV: gvjs_lt,
    ABa: "sticks",
    Hza: "boxes",
    POINTS: gvjs_mw,
    LINE: gvjs_e,
    AREA: gvjs_at,
    NONE: gvjs_f
}
  , gvjs_hC = {
    Yza: gvjs_Ow,
    DAa: gvjs_Pw,
    COLOR: gvjs_Nw
}
  , gvjs_2da = {
    oV: gvjs_Ht,
    L6: gvjs_Vd,
    Nza: gvjs_It
}
  , gvjs_3da = {
    cBa: gvjs_qw,
    IAa: gvjs_Lv,
    qV: gvjs_su
}
  , gvjs_4da = {
    NONE: gvjs_f,
    rja: gvjs_j,
    Dia: gvjs_$c,
    I6: gvjs_vx,
    p6: gvjs_vt,
    INSIDE: gvjs_Fp,
    AAa: gvjs_ov,
    Eza: gvjs_xt
}
  , gvjs_5da = {
    NONE: gvjs_f,
    I6: gvjs_vx,
    p6: gvjs_vt,
    INSIDE: gvjs_Fp
}
  , gvjs_iC = {
    MM: gvjs_U,
    IM: gvjs_S
}
  , gvjs_6da = {
    Gja: gvjs_2,
    CENTER: gvjs_0,
    sia: gvjs_R
}
  , gvjs_jC = {
    NONE: gvjs_f,
    INSIDE: gvjs_Fp,
    OUTSIDE: gvjs_aw
}
  , gvjs_7da = {
    Fza: "bound",
    PBa: "unbound"
}
  , gvjs_8da = {
    nAa: "high",
    FAa: "low"
}
  , gvjs_9da = {
    NONE: gvjs_f,
    zAa: gvjs_8c,
    L6: gvjs_Vd,
    mja: gvjs_ew,
    TBa: gvjs_Ix
}
  , gvjs_kC = {
    NONE: gvjs_f,
    HM: gvjs_ut,
    L6: gvjs_Vd,
    mja: gvjs_ew
}
  , gvjs_lC = {
    RAa: "multiple",
    tBa: gvjs_Ww
}
  , gvjs_mC = {
    NONE: gvjs_f,
    xia: gvjs_xu,
    wja: gvjs_Jw,
    HM: gvjs_ut
}
  , gvjs_$da = {
    NONE: gvjs_f,
    xia: gvjs_xu,
    wja: gvjs_Jw,
    HM: gvjs_ut
}
  , gvjs_nC = {
    IM: gvjs_S,
    MM: gvjs_U,
    HM: gvjs_ut
}
  , gvjs_aea = {
    DEFAULT: gvjs_eu,
    dAa: gvjs_lu
}
  , gvjs_bea = {
    cAa: gvjs_gp,
    oV: gvjs_Ht,
    yja: gvjs_Mw
}
  , gvjs_cea = {
    YF: gvjs_ub,
    oV: gvjs_Ht,
    yja: gvjs_Mw,
    NONE: gvjs_f
}
  , gvjs_oC = {
    NONE: gvjs_f,
    u6: gvjs_d,
    $Aa: "phase",
    Sza: gvjs_Zt
}
  , gvjs_dea = {
    xza: "attachToStart",
    wza: "attachToEnd"
}
  , gvjs_pC = {
    CAa: "letter",
    POINT: gvjs_Np,
    LINE: gvjs_e
};
function gvjs_qC(a, b, c, d, e) {
    this.Sg = !!b;
    this.node = null;
    this.tj = 0;
    this.K4 = !1;
    this.SN = !c;
    a && this.setPosition(a, d);
    this.depth = void 0 != e ? e : this.tj || 0;
    this.Sg && (this.depth *= -1)
}
gvjs_t(gvjs_qC, gvjs_5i);
gvjs_ = gvjs_qC.prototype;
gvjs_.setPosition = function(a, b, c) {
    if (this.node = a)
        this.tj = typeof b === gvjs_g ? b : 1 != this.node.nodeType ? 0 : this.Sg ? -1 : 1;
    typeof c === gvjs_g && (this.depth = c)
}
;
gvjs_.$N = function(a) {
    this.node = a.node;
    this.tj = a.tj;
    this.depth = a.depth;
    this.Sg = a.Sg;
    this.SN = a.SN
}
;
gvjs_.clone = function() {
    return new gvjs_qC(this.node,this.Sg,!this.SN,this.tj,this.depth)
}
;
gvjs_.rg = function() {
    if (this.K4) {
        if (!this.node || this.SN && 0 == this.depth)
            throw gvjs_4i;
        var a = this.node;
        var b = this.Sg ? -1 : 1;
        if (this.tj == b) {
            var c = this.Sg ? a.lastChild : a.firstChild;
            c ? this.setPosition(c) : this.setPosition(a, -1 * b)
        } else
            (c = this.Sg ? a.previousSibling : a.nextSibling) ? this.setPosition(c) : this.setPosition(a.parentNode, -1 * b);
        this.depth += this.tj * (this.Sg ? -1 : 1)
    } else
        this.K4 = !0;
    a = this.node;
    if (!this.node)
        throw gvjs_4i;
    return a
}
;
gvjs_.next = gvjs_qC.prototype.rg;
gvjs_.equals = function(a) {
    return a.node == this.node && (!this.node || a.tj == this.tj)
}
;
gvjs_.splice = function(a) {
    var b = this.node
      , c = this.Sg ? 1 : -1;
    this.tj == c && (this.tj = -1 * c,
    this.depth += this.tj * (this.Sg ? -1 : 1));
    this.Sg = !this.Sg;
    gvjs_qC.prototype.next.call(this);
    this.Sg = !this.Sg;
    c = gvjs_ne(arguments[0]) ? arguments[0] : arguments;
    for (var d = c.length - 1; 0 <= d; d--)
        gvjs_jh(c[d], b);
    gvjs_kh(b)
}
;
function gvjs_rC() {}
gvjs_rC.prototype.Nba = function() {
    return !1
}
;
gvjs_rC.prototype.kc = function() {
    return gvjs_5g(gvjs_y ? this.getContainer() : this.ej())
}
;
gvjs_rC.prototype.Vj = function() {
    return gvjs_3x(this.kc())
}
;
function gvjs_sC(a, b) {
    gvjs_qC.call(this, a, b, !0)
}
gvjs_t(gvjs_sC, gvjs_qC);
function gvjs_tC(a, b, c, d, e) {
    this.fd = this.sd = null;
    this.Ad = this.td = 0;
    this.kj = !!e;
    if (a) {
        this.sd = a;
        this.td = b;
        this.fd = c;
        this.Ad = d;
        if (1 == a.nodeType && "BR" != a.tagName)
            if (a = a.childNodes,
            b = a[b])
                this.sd = b,
                this.td = 0;
            else {
                a.length && (this.sd = gvjs_Ae(a));
                var f = !0
            }
        1 == c.nodeType && ((this.fd = c.childNodes[d]) ? this.Ad = 0 : this.fd = c)
    }
    gvjs_qC.call(this, this.kj ? this.fd : this.sd, this.kj, !0);
    if (f)
        try {
            this.next()
        } catch (g) {
            if (g != gvjs_4i)
                throw g;
        }
}
gvjs_t(gvjs_tC, gvjs_sC);
gvjs_ = gvjs_tC.prototype;
gvjs_.ej = function() {
    return this.sd
}
;
gvjs_.Sl = function() {
    return this.fd
}
;
gvjs_.rg = function() {
    if (this.K4 && (this.node != (this.kj ? this.sd : this.fd) ? 0 : this.kj ? this.td ? -1 != this.tj : 1 == this.tj : !this.Ad || 1 != this.tj))
        throw gvjs_4i;
    return gvjs_tC.G.next.call(this)
}
;
gvjs_.next = gvjs_tC.prototype.rg;
gvjs_.$N = function(a) {
    this.sd = a.sd;
    this.fd = a.fd;
    this.td = a.td;
    this.Ad = a.Ad;
    this.kj = a.kj;
    gvjs_tC.G.$N.call(this, a)
}
;
gvjs_.clone = function() {
    var a = new gvjs_tC(this.sd,this.td,this.fd,this.Ad,this.kj);
    a.$N(this);
    return a
}
;
function gvjs_uC() {}
gvjs_uC.prototype.WB = function(a, b) {
    b = b && !a.isCollapsed();
    a = a.Ua;
    try {
        return b ? 0 <= this.Hm(a, 0, 1) && 0 >= this.Hm(a, 1, 0) : 0 <= this.Hm(a, 0, 0) && 0 >= this.Hm(a, 1, 1)
    } catch (c) {
        if (!gvjs_y)
            throw c;
        return !1
    }
}
;
gvjs_uC.prototype.containsNode = function(a, b) {
    return this.WB(gvjs_vC(a), b)
}
;
gvjs_uC.prototype.xk = function() {
    return new gvjs_tC(this.ej(),this.cn(),this.Sl(),this.Eo())
}
;
function gvjs_wC(a) {
    this.Ua = a
}
gvjs_t(gvjs_wC, gvjs_uC);
function gvjs_xC(a) {
    var b = gvjs_5g(a).createRange();
    if (3 == a.nodeType)
        b.setStart(a, 0),
        b.setEnd(a, a.length);
    else if (gvjs_yC(a)) {
        for (var c, d = a; (c = d.firstChild) && gvjs_yC(c); )
            d = c;
        b.setStart(d, 0);
        for (d = a; (c = d.lastChild) && gvjs_yC(c); )
            d = c;
        b.setEnd(d, 1 == d.nodeType ? d.childNodes.length : d.length)
    } else
        c = a.parentNode,
        a = Array.prototype.indexOf.call(c.childNodes, a),
        b.setStart(c, a),
        b.setEnd(c, a + 1);
    return b
}
function gvjs_zC(a, b, c, d) {
    var e = gvjs_5g(a).createRange();
    e.setStart(a, b);
    e.setEnd(c, d);
    return e
}
gvjs_ = gvjs_wC.prototype;
gvjs_.clone = function() {
    return new this.constructor(this.Ua.cloneRange())
}
;
gvjs_.getContainer = function() {
    return this.Ua.commonAncestorContainer
}
;
gvjs_.ej = function() {
    return this.Ua.startContainer
}
;
gvjs_.cn = function() {
    return this.Ua.startOffset
}
;
gvjs_.Sl = function() {
    return this.Ua.endContainer
}
;
gvjs_.Eo = function() {
    return this.Ua.endOffset
}
;
gvjs_.Hm = function(a, b, c) {
    return this.Ua.compareBoundaryPoints(1 == c ? 1 == b ? gvjs_p.Range.START_TO_START : gvjs_p.Range.START_TO_END : 1 == b ? gvjs_p.Range.END_TO_START : gvjs_p.Range.END_TO_END, a)
}
;
gvjs_.isCollapsed = function() {
    return this.Ua.collapsed
}
;
gvjs_.dn = gvjs_n(43);
gvjs_.select = function(a) {
    var b = gvjs_3x(gvjs_5g(this.ej()));
    this.cL(b.getSelection(), a)
}
;
gvjs_.cL = function(a) {
    a.removeAllRanges();
    a.addRange(this.Ua)
}
;
gvjs_.surroundContents = function(a) {
    this.Ua.surroundContents(a);
    return a
}
;
gvjs_.insertNode = function(a, b) {
    var c = this.Ua.cloneRange();
    c.collapse(b);
    c.insertNode(a);
    c.detach();
    return a
}
;
gvjs_.collapse = function(a) {
    this.Ua.collapse(a)
}
;
function gvjs_AC(a) {
    this.Ua = a
}
gvjs_t(gvjs_AC, gvjs_wC);
gvjs_AC.prototype.cL = function(a, b) {
    !b || this.isCollapsed() ? gvjs_AC.G.cL.call(this, a, b) : (a.collapse(this.Sl(), this.Eo()),
    a.extend(this.ej(), this.cn()))
}
;
function gvjs_BC(a, b) {
    this.fd = this.sd = this.Zq = null;
    this.Ad = this.td = -1;
    this.Ua = a;
    this.Kj = b
}
gvjs_t(gvjs_BC, gvjs_uC);
function gvjs_CC(a) {
    var b = gvjs_5g(a).body.createTextRange();
    if (1 == a.nodeType)
        b.moveToElementText(a),
        gvjs_yC(a) && !a.childNodes.length && b.collapse(!1);
    else {
        for (var c = 0, d = a; d = d.previousSibling; ) {
            var e = d.nodeType;
            if (3 == e)
                c += d.length;
            else if (1 == e) {
                b.moveToElementText(d);
                break
            }
        }
        d || b.moveToElementText(a.parentNode);
        b.collapse(!d);
        c && b.move(gvjs_Lt, c);
        b.moveEnd(gvjs_Lt, a.length)
    }
    return b
}
gvjs_ = gvjs_BC.prototype;
gvjs_.clone = function() {
    var a = new gvjs_BC(this.Ua.duplicate(),this.Kj);
    a.Zq = this.Zq;
    a.sd = this.sd;
    a.fd = this.fd;
    return a
}
;
gvjs_.WG = function() {
    this.Zq = this.sd = this.fd = null;
    this.td = this.Ad = -1
}
;
gvjs_.getContainer = function() {
    if (!this.Zq) {
        var a = this.Ua.text
          , b = this.Ua.duplicate()
          , c = a.replace(/ +$/, "");
        (c = a.length - c.length) && b.moveEnd(gvjs_Lt, -c);
        c = b.parentElement();
        b = b.htmlText.replace(/(\r\n|\r|\n)+/g, " ").length;
        if (this.isCollapsed() && 0 < b)
            return this.Zq = c;
        for (; b > c.outerHTML.replace(/(\r\n|\r|\n)+/g, " ").length; )
            c = c.parentNode;
        for (; 1 == c.childNodes.length && c.innerText == gvjs_eea(c.firstChild) && gvjs_yC(c.firstChild); )
            c = c.firstChild;
        0 == a.length && (c = gvjs_DC(this, c));
        this.Zq = c
    }
    return this.Zq
}
;
function gvjs_DC(a, b) {
    for (var c = b.childNodes, d = 0, e = c.length; d < e; d++) {
        var f = c[d];
        if (gvjs_yC(f)) {
            var g = gvjs_CC(f)
              , h = g.htmlText != f.outerHTML;
            if (a.isCollapsed() && h ? 0 <= a.Hm(g, 1, 1) && 0 >= a.Hm(g, 1, 0) : a.Ua.inRange(g))
                return gvjs_DC(a, f)
        }
    }
    return b
}
gvjs_.ej = function() {
    this.sd || (this.sd = gvjs_EC(this, 1),
    this.isCollapsed() && (this.fd = this.sd));
    return this.sd
}
;
gvjs_.cn = function() {
    0 > this.td && (this.td = this.FC(1),
    this.isCollapsed() && (this.Ad = this.td));
    return this.td
}
;
gvjs_.Sl = function() {
    if (this.isCollapsed())
        return this.ej();
    this.fd || (this.fd = gvjs_EC(this, 0));
    return this.fd
}
;
gvjs_.Eo = function() {
    if (this.isCollapsed())
        return this.cn();
    0 > this.Ad && (this.Ad = this.FC(0),
    this.isCollapsed() && (this.td = this.Ad));
    return this.Ad
}
;
gvjs_.Hm = function(a, b, c) {
    return this.Ua.compareEndPoints((1 == b ? "Start" : "End") + "To" + (1 == c ? "Start" : "End"), a)
}
;
function gvjs_EC(a, b, c) {
    c = c || a.getContainer();
    if (!c || !c.firstChild)
        return c;
    for (var d = 1 == b, e = 0, f = c.childNodes.length; e < f; e++) {
        var g = d ? e : f - e - 1
          , h = c.childNodes[g];
        try {
            var k = gvjs_vC(h)
        } catch (m) {
            continue
        }
        var l = k.Ua;
        if (a.isCollapsed())
            if (!gvjs_yC(h)) {
                if (0 == a.Hm(l, 1, 1)) {
                    a.td = a.Ad = g;
                    break
                }
            } else {
                if (k.WB(a))
                    return gvjs_EC(a, b, h)
            }
        else {
            if (a.WB(k)) {
                if (!gvjs_yC(h)) {
                    d ? a.td = g : a.Ad = g + 1;
                    break
                }
                return gvjs_EC(a, b, h)
            }
            if (0 > a.Hm(l, 1, 0) && 0 < a.Hm(l, 0, 1))
                return gvjs_EC(a, b, h)
        }
    }
    return c
}
gvjs_.FC = function(a) {
    var b = 1 == a
      , c = b ? this.ej() : this.Sl();
    if (1 == c.nodeType) {
        c = c.childNodes;
        for (var d = c.length, e = b ? 1 : -1, f = b ? 0 : d - 1; 0 <= f && f < d; f += e) {
            var g = c[f];
            if (!gvjs_yC(g) && 0 == this.Ua.compareEndPoints((1 == a ? "Start" : "End") + "To" + (1 == a ? "Start" : "End"), gvjs_vC(g).Ua))
                return b ? f : f + 1
        }
        return -1 == f ? 0 : f
    }
    a = this.Ua.duplicate();
    d = gvjs_CC(c);
    a.setEndPoint(b ? "EndToEnd" : "StartToStart", d);
    a = a.text.length;
    return b ? c.length - a : a
}
;
function gvjs_eea(a) {
    return 3 == a.nodeType ? a.nodeValue : a.innerText
}
gvjs_.isCollapsed = function() {
    return 0 == this.Ua.compareEndPoints("StartToEnd", this.Ua)
}
;
gvjs_.dn = gvjs_n(42);
gvjs_.select = function() {
    this.Ua.select()
}
;
function gvjs_FC(a, b, c) {
    c = c || gvjs_3g(a.parentElement());
    var d, e = d = b.id;
    d || (d = b.id = "goog_" + gvjs_ig++);
    a.pasteHTML(b.outerHTML);
    (b = c.j(d)) && (e || b.removeAttribute(gvjs_5c));
    return b
}
gvjs_.surroundContents = function(a) {
    gvjs_kh(a);
    var b = gvjs_3f(this.Ua.htmlText, null);
    gvjs_cg(a, b);
    (a = gvjs_FC(this.Ua, a)) && this.Ua.moveToElementText(a);
    this.WG();
    return a
}
;
gvjs_.insertNode = function(a, b) {
    var c = this.Ua.duplicate();
    var d = d || gvjs_3g(c.parentElement());
    if (1 != a.nodeType) {
        var e = !0;
        a = d.J(gvjs_b, null, a)
    }
    c.collapse(b);
    a = gvjs_FC(c, a, d);
    if (e) {
        b = a.firstChild;
        c = a;
        if ((d = c.parentNode) && 11 != d.nodeType)
            if (c.removeNode)
                c.removeNode(!1);
            else {
                for (; a = c.firstChild; )
                    d.insertBefore(a, c);
                gvjs_kh(c)
            }
        a = b
    }
    b = a;
    this.WG();
    return b
}
;
gvjs_.collapse = function(a) {
    this.Ua.collapse(a);
    a ? (this.fd = this.sd,
    this.Ad = this.td) : (this.sd = this.fd,
    this.td = this.Ad)
}
;
function gvjs_GC(a) {
    this.Ua = a
}
gvjs_t(gvjs_GC, gvjs_wC);
gvjs_GC.prototype.cL = function(a) {
    a.collapse(this.ej(), this.cn());
    this.Sl() == this.ej() && this.Eo() == this.cn() || a.extend(this.Sl(), this.Eo());
    0 == a.rangeCount && a.addRange(this.Ua)
}
;
function gvjs_HC(a) {
    this.Ua = a
}
gvjs_t(gvjs_HC, gvjs_wC);
gvjs_HC.prototype.Hm = function(a, b, c) {
    return gvjs_Eg("528") ? gvjs_HC.G.Hm.call(this, a, b, c) : this.Ua.compareBoundaryPoints(1 == c ? 1 == b ? gvjs_p.Range.START_TO_START : gvjs_p.Range.END_TO_START : 1 == b ? gvjs_p.Range.START_TO_END : gvjs_p.Range.END_TO_END, a)
}
;
gvjs_HC.prototype.cL = function(a, b) {
    b ? a.setBaseAndExtent(this.Sl(), this.Eo(), this.ej(), this.cn()) : a.setBaseAndExtent(this.ej(), this.cn(), this.Sl(), this.Eo())
}
;
function gvjs_vC(a) {
    if (gvjs_y && !gvjs_Fg(9)) {
        var b = new gvjs_BC(gvjs_CC(a),gvjs_5g(a));
        if (gvjs_yC(a)) {
            for (var c, d = a; (c = d.firstChild) && gvjs_yC(c); )
                d = c;
            b.sd = d;
            b.td = 0;
            for (d = a; (c = d.lastChild) && gvjs_yC(c); )
                d = c;
            b.fd = d;
            b.Ad = 1 == d.nodeType ? d.childNodes.length : d.length;
            b.Zq = a
        } else
            b.sd = b.fd = b.Zq = a.parentNode,
            b.td = Array.prototype.indexOf.call(b.Zq.childNodes, a),
            b.Ad = b.td + 1;
        a = b
    } else
        a = gvjs_tg ? new gvjs_HC(gvjs_xC(a)) : gvjs_sg ? new gvjs_AC(gvjs_xC(a)) : gvjs_qg ? new gvjs_GC(gvjs_xC(a)) : new gvjs_wC(gvjs_xC(a));
    return a
}
function gvjs_yC(a) {
    return gvjs_fh(a) || 3 == a.nodeType
}
;function gvjs_IC() {
    this.Ad = this.fd = this.td = this.sd = this.Lu = null;
    this.kj = !1
}
gvjs_t(gvjs_IC, gvjs_rC);
gvjs_ = gvjs_IC.prototype;
gvjs_.clone = function() {
    var a = new gvjs_IC;
    a.Lu = this.Lu && this.Lu.clone();
    a.sd = this.sd;
    a.td = this.td;
    a.fd = this.fd;
    a.Ad = this.Ad;
    a.kj = this.kj;
    return a
}
;
gvjs_.getType = function() {
    return gvjs_m
}
;
gvjs_.WG = function() {
    this.sd = this.td = this.fd = this.Ad = null
}
;
function gvjs_JC(a) {
    var b;
    if (!(b = a.Lu)) {
        b = a.ej();
        var c = a.cn()
          , d = a.Sl()
          , e = a.Eo();
        if (gvjs_y && !gvjs_Fg(9)) {
            var f = b
              , g = c
              , h = d
              , k = e
              , l = !1;
            1 == f.nodeType && (g = f.childNodes[g],
            l = !g,
            f = g || f.lastChild || f,
            g = 0);
            var m = gvjs_CC(f);
            g && m.move(gvjs_Lt, g);
            f == h && g == k ? m.collapse(!0) : (l && m.collapse(!1),
            l = !1,
            1 == h.nodeType && (h = (g = h.childNodes[k]) || h.lastChild || h,
            k = 0,
            l = !g),
            f = gvjs_CC(h),
            f.collapse(!l),
            k && f.moveEnd(gvjs_Lt, k),
            m.setEndPoint("EndToEnd", f));
            k = new gvjs_BC(m,gvjs_5g(b));
            k.sd = b;
            k.td = c;
            k.fd = d;
            k.Ad = e;
            b = k
        } else
            b = gvjs_tg ? new gvjs_HC(gvjs_zC(b, c, d, e)) : gvjs_sg ? new gvjs_AC(gvjs_zC(b, c, d, e)) : gvjs_qg ? new gvjs_GC(gvjs_zC(b, c, d, e)) : new gvjs_wC(gvjs_zC(b, c, d, e));
        b = a.Lu = b
    }
    return b
}
gvjs_.getContainer = function() {
    return gvjs_JC(this).getContainer()
}
;
gvjs_.ej = function() {
    return this.sd || (this.sd = gvjs_JC(this).ej())
}
;
gvjs_.cn = function() {
    return null != this.td ? this.td : this.td = gvjs_JC(this).cn()
}
;
gvjs_.Sl = function() {
    return this.fd || (this.fd = gvjs_JC(this).Sl())
}
;
gvjs_.Eo = function() {
    return null != this.Ad ? this.Ad : this.Ad = gvjs_JC(this).Eo()
}
;
gvjs_.Nba = function() {
    return this.kj
}
;
gvjs_.WB = function(a, b) {
    var c = a.getType();
    return c == gvjs_m ? gvjs_JC(this).WB(gvjs_JC(a), b) : "control" == c ? (a = a.rI(),
    (b ? gvjs_Fe : gvjs_Ge)(a, function(d) {
        return this.containsNode(d, b)
    }, this)) : !1
}
;
gvjs_.containsNode = function(a, b) {
    var c = this.WB;
    a = gvjs_vC(a);
    var d = new gvjs_IC;
    d.Lu = a;
    d.kj = !1;
    return c.call(this, d, b)
}
;
gvjs_.isCollapsed = function() {
    return gvjs_JC(this).isCollapsed()
}
;
gvjs_.dn = gvjs_n(41);
gvjs_.xk = function() {
    return new gvjs_tC(this.ej(),this.cn(),this.Sl(),this.Eo())
}
;
gvjs_.select = function() {
    gvjs_JC(this).select(this.kj)
}
;
gvjs_.surroundContents = function(a) {
    a = gvjs_JC(this).surroundContents(a);
    this.WG();
    return a
}
;
gvjs_.insertNode = function(a, b) {
    a = gvjs_JC(this).insertNode(a, b);
    this.WG();
    return a
}
;
gvjs_.collapse = function(a) {
    a = this.Nba() ? !a : a;
    this.Lu && this.Lu.collapse(a);
    a ? (this.fd = this.sd,
    this.Ad = this.td) : (this.sd = this.fd,
    this.td = this.Ad);
    this.kj = !1
}
;
function gvjs_fea(a, b, c, d) {
    if (a == c)
        return d < b;
    var e;
    if (1 == a.nodeType && b)
        if (e = a.childNodes[b])
            a = e,
            b = 0;
        else if (gvjs_rh(a, c))
            return !0;
    if (1 == c.nodeType && d)
        if (e = c.childNodes[d])
            c = e,
            d = 0;
        else if (gvjs_rh(c, a))
            return !1;
    return 0 < (gvjs_wda(a, c) || b - d)
}
;function gvjs_KC() {}
gvjs_le(gvjs_KC);
gvjs_KC.prototype.Lta = 0;
gvjs_KC.prototype.Dra = "";
function gvjs_LC(a) {
    return a.Dra + ":" + (a.Lta++).toString(36)
}
;function gvjs_MC(a) {
    gvjs_H.call(this);
    this.D = a || gvjs_3g();
    this.gr = gvjs_gea;
    this.ac = null;
    this.Bb = !1;
    this.H = null;
    this.Fv = void 0;
    this.jo = this.Uc = this.qd = this.Zh = null;
    this.eA = this.sha = !1
}
gvjs_t(gvjs_MC, gvjs_H);
gvjs_MC.prototype.Bra = gvjs_KC.Lc();
var gvjs_gea = null;
function gvjs_NC(a, b) {
    switch (a) {
    case 1:
        return b ? gvjs_ju : gvjs_qu;
    case 2:
        return b ? gvjs_3u : gvjs_yx;
    case 4:
        return b ? "activate" : "deactivate";
    case 8:
        return b ? gvjs_k : "unselect";
    case 16:
        return b ? "check" : "uncheck";
    case 32:
        return b ? gvjs_xu : gvjs_Yo;
    case 64:
        return b ? "open" : gvjs_Yt
    }
    throw Error("Invalid component state");
}
gvjs_ = gvjs_MC.prototype;
gvjs_.getId = function() {
    return this.ac || (this.ac = gvjs_LC(this.Bra))
}
;
gvjs_.lL = function(a) {
    this.qd && this.qd.jo && (gvjs_Qy(this.qd.jo, this.ac),
    gvjs_Ry(this.qd.jo, a, this));
    this.ac = a
}
;
gvjs_.j = function() {
    return this.H
}
;
gvjs_.wq = function(a) {
    return this.H ? this.D.wq(a, this.H) : []
}
;
gvjs_.hd = gvjs_n(1);
gvjs_.yP = gvjs_n(3);
gvjs_.hc = function() {
    this.Fv || (this.Fv = new gvjs_KA(this));
    return this.Fv
}
;
function gvjs_OC(a, b) {
    if (a == b)
        throw Error(gvjs_xs);
    if (b && a.qd && a.ac && a.qd.CC(a.ac) && a.qd != b)
        throw Error(gvjs_xs);
    a.qd = b;
    gvjs_MC.G.uA.call(a, b)
}
gvjs_.getParent = function() {
    return this.qd
}
;
gvjs_.uA = function(a) {
    if (this.qd && this.qd != a)
        throw Error("Method not supported");
    gvjs_MC.G.uA.call(this, a)
}
;
gvjs_.wa = function() {
    return this.D
}
;
gvjs_.J = function() {
    this.H = this.D.createElement(gvjs_b)
}
;
gvjs_.R = function(a) {
    this.sE(a)
}
;
gvjs_.sE = function(a, b) {
    if (this.Bb)
        throw Error(gvjs_8r);
    this.H || this.J();
    a ? a.insertBefore(this.H, b || null) : this.D.kc().body.appendChild(this.H);
    this.qd && !this.qd.Bb || this.Nb()
}
;
gvjs_.fb = function(a) {
    if (this.Bb)
        throw Error(gvjs_8r);
    if (a && this.Fh(a)) {
        this.sha = !0;
        var b = gvjs_5g(a);
        this.D && this.D.kc() == b || (this.D = gvjs_3g(a));
        this.vf(a);
        this.Nb()
    } else
        throw Error("Invalid element to decorate");
}
;
gvjs_.Fh = function() {
    return !0
}
;
gvjs_.vf = function(a) {
    this.H = a
}
;
gvjs_.Nb = function() {
    this.Bb = !0;
    gvjs_PC(this, function(a) {
        !a.Bb && a.j() && a.Nb()
    })
}
;
gvjs_.Le = function() {
    gvjs_PC(this, function(a) {
        a.Bb && a.Le()
    });
    this.Fv && this.Fv.removeAll();
    this.Bb = !1
}
;
gvjs_.M = function() {
    this.Bb && this.Le();
    this.Fv && (this.Fv.pa(),
    delete this.Fv);
    gvjs_PC(this, function(a) {
        a.pa()
    });
    !this.sha && this.H && gvjs_kh(this.H);
    this.qd = this.Zh = this.H = this.jo = this.Uc = null;
    gvjs_MC.G.M.call(this)
}
;
gvjs_.addChild = function(a, b) {
    this.zx(a, this.ze(), b)
}
;
gvjs_.zx = function(a, b, c) {
    if (a.Bb && (c || !this.Bb))
        throw Error(gvjs_8r);
    if (0 > b || b > this.ze())
        throw Error("Child component index out of bounds");
    this.jo && this.Uc || (this.jo = {},
    this.Uc = []);
    if (a.getParent() == this) {
        var d = a.getId();
        this.jo[d] = a;
        gvjs_Ie(this.Uc, a)
    } else
        gvjs_Ry(this.jo, a.getId(), a);
    gvjs_OC(a, this);
    gvjs_fq(this.Uc, a, b);
    a.Bb && this.Bb && a.getParent() == this ? (c = this.ib(),
    (c.childNodes[b] || null) != a.j() && (a.j().parentElement == c && c.removeChild(a.j()),
    b = c.childNodes[b] || null,
    c.insertBefore(a.j(), b))) : c ? (this.H || this.J(),
    b = this.Ye(b + 1),
    a.sE(this.ib(), b ? b.H : null)) : this.Bb && !a.Bb && a.H && a.H.parentNode && 1 == a.H.parentNode.nodeType && a.Nb()
}
;
gvjs_.ib = function() {
    return this.H
}
;
gvjs_.gh = function() {
    null == this.gr && (this.gr = gvjs_Gz(this.Bb ? this.H : this.D.kc().body));
    return this.gr
}
;
gvjs_.vA = function(a) {
    if (this.Bb)
        throw Error(gvjs_8r);
    this.gr = a
}
;
gvjs_.ze = function() {
    return this.Uc ? this.Uc.length : 0
}
;
gvjs_.CC = function(a) {
    return this.jo && a ? gvjs_Sy(this.jo, a) || null : null
}
;
gvjs_.Ye = function(a) {
    return this.Uc ? this.Uc[a] || null : null
}
;
function gvjs_PC(a, b, c) {
    a.Uc && a.Uc.forEach(b, c)
}
function gvjs_QC(a, b) {
    return a.Uc && b ? a.Uc.indexOf(b) : -1
}
gvjs_.removeChild = function(a, b) {
    if (a) {
        var c = typeof a === gvjs_l ? a : a.getId();
        a = this.CC(c);
        c && a && (gvjs_Qy(this.jo, c),
        gvjs_Ie(this.Uc, a),
        b && (a.Le(),
        a.H && gvjs_kh(a.H)),
        gvjs_OC(a, null))
    }
    if (!a)
        throw Error("Child is not in parent component");
    return a
}
;
gvjs_.qc = function(a) {
    for (var b = []; this.Uc && 0 != this.Uc.length; ) {
        var c = b
          , d = c.push;
        var e = a;
        e = this.removeChild(this.Ye(0), e);
        d.call(c, e)
    }
    return b
}
;
function gvjs_RC(a) {
    return typeof a.className == gvjs_l ? a.className : a.getAttribute && a.getAttribute(gvjs_Cb) || ""
}
function gvjs_SC(a) {
    return a.classList ? a.classList : gvjs_RC(a).match(/\S+/g) || []
}
function gvjs_TC(a, b) {
    typeof a.className == gvjs_l ? a.className = b : a.setAttribute && a.setAttribute(gvjs_Cb, b)
}
function gvjs_UC(a, b) {
    return a.classList ? a.classList.contains(b) : gvjs_He(gvjs_SC(a), b)
}
function gvjs_VC(a, b) {
    if (a.classList)
        a.classList.add(b);
    else if (!gvjs_UC(a, b)) {
        var c = gvjs_RC(a);
        gvjs_TC(a, c + (0 < c.length ? " " + b : b))
    }
}
function gvjs_WC(a, b) {
    if (a.classList)
        Array.prototype.forEach.call(b, function(e) {
            gvjs_VC(a, e)
        });
    else {
        var c = {};
        Array.prototype.forEach.call(gvjs_SC(a), function(e) {
            c[e] = !0
        });
        Array.prototype.forEach.call(b, function(e) {
            c[e] = !0
        });
        b = "";
        for (var d in c)
            b += 0 < b.length ? " " + d : d;
        gvjs_TC(a, b)
    }
}
function gvjs_XC(a, b) {
    a.classList ? a.classList.remove(b) : gvjs_UC(a, b) && gvjs_TC(a, Array.prototype.filter.call(gvjs_SC(a), function(c) {
        return c != b
    }).join(" "))
}
function gvjs_YC(a, b) {
    a.classList ? Array.prototype.forEach.call(b, function(c) {
        gvjs_XC(a, c)
    }) : gvjs_TC(a, Array.prototype.filter.call(gvjs_SC(a), function(c) {
        return !gvjs_He(b, c)
    }).join(" "))
}
function gvjs_ZC(a, b, c) {
    c ? gvjs_VC(a, b) : gvjs_XC(a, b)
}
;function gvjs__C(a, b, c) {
    gvjs_H.call(this);
    this.target = a;
    this.SC = b || a;
    this.u0 = c || new gvjs_5(NaN,NaN,NaN,NaN);
    this.dd = gvjs_5g(a);
    this.ea = new gvjs_KA(this);
    gvjs_6x(this, this.ea);
    this.deltaY = this.deltaX = this.xp = this.wL = this.screenY = this.screenX = this.clientY = this.clientX = 0;
    this.kg = !0;
    this.lq = !1;
    this.qea = !0;
    this.gba = 0;
    this.bB = this.Era = !1;
    gvjs_G(this.SC, ["touchstart", gvjs_gd], this.ega, !1, this);
    this.PU = gvjs_hea
}
gvjs_t(gvjs__C, gvjs_H);
var gvjs_hea = gvjs_p.document && gvjs_p.document.documentElement && !!gvjs_p.document.documentElement.setCapture && !!gvjs_p.document.releaseCapture;
gvjs_ = gvjs__C.prototype;
gvjs_.pq = gvjs_n(58);
gvjs_.hc = function() {
    return this.ea
}
;
function gvjs_0C(a, b) {
    a.u0 = b || new gvjs_5(NaN,NaN,NaN,NaN)
}
gvjs_.Gb = function(a) {
    this.kg = a
}
;
gvjs_.M = function() {
    gvjs__C.G.M.call(this);
    gvjs_ji(this.SC, ["touchstart", gvjs_gd], this.ega, !1, this);
    this.ea.removeAll();
    this.PU && this.dd.releaseCapture();
    this.SC = this.target = null
}
;
gvjs_.jJ = function() {
    void 0 === this.gr && (this.gr = gvjs_Gz(this.target));
    return this.gr
}
;
gvjs_.ega = function(a) {
    var b = a.type == gvjs_gd;
    if (!this.kg || this.lq || b && !gvjs_7x(a))
        this.dispatchEvent("earlycancel");
    else {
        if (0 == this.gba)
            if (this.dispatchEvent(new gvjs_1C(gvjs_2,this,a.clientX,a.clientY,a)))
                this.lq = !0,
                this.qea && b && a.preventDefault();
            else
                return;
        else
            this.qea && b && a.preventDefault();
        b = this.dd;
        var c = b.documentElement
          , d = !this.PU;
        this.ea.o(b, ["touchmove", gvjs_jd], this.TP, {
            capture: d,
            passive: !1
        });
        this.ea.o(b, ["touchend", gvjs_md], this.PO, d);
        this.PU ? (c.setCapture(!1),
        this.ea.o(c, "losecapture", this.PO)) : this.ea.o(gvjs_3x(b), gvjs_Yo, this.PO);
        gvjs_y && this.Era && this.ea.o(b, gvjs_pu, gvjs_Lz);
        this.iwa && this.ea.o(this.iwa, gvjs_Gw, this.Bua, d);
        this.clientX = this.wL = a.clientX;
        this.clientY = this.xp = a.clientY;
        this.screenX = a.screenX;
        this.screenY = a.screenY;
        this.deltaX = this.bB ? gvjs_3A(this.target) : this.target.offsetLeft;
        this.deltaY = this.target.offsetTop;
        this.d2 = gvjs_2x(gvjs_3g(this.dd).dd)
    }
}
;
gvjs_.PO = function(a, b) {
    this.ea.removeAll();
    this.PU && this.dd.releaseCapture();
    this.lq ? (this.lq = !1,
    this.dispatchEvent(new gvjs_1C(gvjs_R,this,a.clientX,a.clientY,a,gvjs_2C(this, this.deltaX),gvjs_3C(this, this.deltaY),b || "touchcancel" == a.type))) : this.dispatchEvent("earlycancel")
}
;
gvjs_.TP = function(a) {
    if (this.kg) {
        var b = (this.bB && this.jJ() ? -1 : 1) * (a.clientX - this.clientX)
          , c = a.clientY - this.clientY;
        this.clientX = a.clientX;
        this.clientY = a.clientY;
        this.screenX = a.screenX;
        this.screenY = a.screenY;
        if (!this.lq) {
            var d = this.wL - this.clientX
              , e = this.xp - this.clientY;
            if (d * d + e * e > this.gba)
                if (this.dispatchEvent(new gvjs_1C(gvjs_2,this,a.clientX,a.clientY,a)))
                    this.lq = !0;
                else {
                    this.xf || this.PO(a);
                    return
                }
        }
        c = gvjs_4C(this, b, c);
        b = c.x;
        c = c.y;
        this.lq && this.dispatchEvent(new gvjs_1C(gvjs_nt,this,a.clientX,a.clientY,a,b,c)) && (gvjs_5C(this, a, b, c),
        a.preventDefault())
    }
}
;
function gvjs_4C(a, b, c) {
    var d = gvjs_2x(gvjs_3g(a.dd).dd);
    b += d.x - a.d2.x;
    c += d.y - a.d2.y;
    a.d2 = d;
    a.deltaX += b;
    a.deltaY += c;
    return new gvjs_z(gvjs_2C(a, a.deltaX),gvjs_3C(a, a.deltaY))
}
gvjs_.Bua = function(a) {
    var b = gvjs_4C(this, 0, 0);
    a.clientX = this.clientX;
    a.clientY = this.clientY;
    gvjs_5C(this, a, b.x, b.y)
}
;
function gvjs_5C(a, b, c, d) {
    a.ky(c, d);
    a.dispatchEvent(new gvjs_1C(gvjs_nu,a,b.clientX,b.clientY,b,c,d))
}
function gvjs_2C(a, b) {
    var c = a.u0;
    a = isNaN(c.left) ? null : c.left;
    c = isNaN(c.width) ? 0 : c.width;
    return Math.min(null != a ? a + c : Infinity, Math.max(null != a ? a : -Infinity, b))
}
function gvjs_3C(a, b) {
    var c = a.u0;
    a = isNaN(c.top) ? null : c.top;
    c = isNaN(c.height) ? 0 : c.height;
    return Math.min(null != a ? a + c : Infinity, Math.max(null != a ? a : -Infinity, b))
}
gvjs_.ky = function(a, b) {
    this.bB && this.jJ() ? this.target.style.right = a + gvjs_T : this.target.style.left = a + gvjs_T;
    this.target.style.top = b + gvjs_T
}
;
function gvjs_1C(a, b, c, d, e, f, g) {
    gvjs_1h.call(this, a);
    this.clientX = c;
    this.clientY = d;
    this.Wka = e;
    this.left = void 0 !== f ? f : b.deltaX;
    this.top = void 0 !== g ? g : b.deltaY;
    this.eY = b
}
gvjs_t(gvjs_1C, gvjs_1h);
function gvjs_6C(a) {
    this.qa = new Map;
    var b = arguments.length;
    if (1 < b) {
        if (b % 2)
            throw Error(gvjs_kb);
        for (var c = 0; c < b; c += 2)
            this.set(arguments[c], arguments[c + 1])
    } else
        a && this.addAll(a)
}
gvjs_ = gvjs_6C.prototype;
gvjs_.Cd = function() {
    return this.qa.size
}
;
gvjs_.ob = function() {
    return Array.from(this.qa.values())
}
;
gvjs_.cj = function() {
    return Array.from(this.qa.keys())
}
;
gvjs_.tf = function(a) {
    return this.qa.has(a)
}
;
gvjs_.XB = function(a) {
    return this.ob().some(function(b) {
        return b == a
    })
}
;
gvjs_.equals = function(a, b) {
    var c = this;
    b = void 0 === b ? function(d, e) {
        return d === e
    }
    : b;
    return this === a ? !0 : this.qa.size != a.Cd() ? !1 : this.cj().every(function(d) {
        return b(c.qa.get(d), a.get(d))
    })
}
;
gvjs_.isEmpty = function() {
    return 0 == this.qa.size
}
;
gvjs_.clear = function() {
    this.qa.clear()
}
;
gvjs_.remove = function(a) {
    return this.qa.delete(a)
}
;
gvjs_.get = function(a, b) {
    return this.qa.has(a) ? this.qa.get(a) : b
}
;
gvjs_.set = function(a, b) {
    this.qa.set(a, b);
    return this
}
;
gvjs_.addAll = function(a) {
    if (a instanceof gvjs_6C) {
        a = gvjs_8d(a.qa);
        for (var b = a.next(); !b.done; b = a.next()) {
            var c = gvjs_8d(b.value);
            b = c.next().value;
            c = c.next().value;
            this.qa.set(b, c)
        }
    } else if (a)
        for (a = gvjs_8d(Object.entries(a)),
        b = a.next(); !b.done; b = a.next())
            c = gvjs_8d(b.value),
            b = c.next().value,
            c = c.next().value,
            this.qa.set(b, c)
}
;
gvjs_.forEach = function(a, b) {
    var c = this;
    b = void 0 === b ? this : b;
    this.qa.forEach(function(d, e) {
        return a.call(b, d, e, c)
    })
}
;
gvjs_.clone = function() {
    return new gvjs_6C(this)
}
;
(function() {
    for (var a = ["ms", "moz", "webkit", "o"], b, c = 0; b = a[c] && !gvjs_p.requestAnimationFrame; ++c)
        gvjs_p.requestAnimationFrame = gvjs_p[b + "RequestAnimationFrame"],
        gvjs_p.cancelAnimationFrame = gvjs_p[b + "CancelAnimationFrame"] || gvjs_p[b + "CancelRequestAnimationFrame"];
    if (!gvjs_p.requestAnimationFrame) {
        var d = 0;
        gvjs_p.requestAnimationFrame = function(e) {
            var f = (new Date).getTime()
              , g = Math.max(0, 16 - (f - d));
            d = f + g;
            return gvjs_p.setTimeout(function() {
                e(f + g)
            }, g)
        }
        ;
        gvjs_p.cancelAnimationFrame || (gvjs_p.cancelAnimationFrame = function(e) {
            clearTimeout(e)
        }
        )
    }
}
)();
var gvjs_7C = [[], []]
  , gvjs_8C = 0
  , gvjs_9C = !1
  , gvjs_iea = 0;
function gvjs_jea(a, b) {
    var c = gvjs_iea++
      , d = {
        kta: {
            id: c,
            Xs: a.measure,
            context: b
        },
        Ita: {
            id: c,
            Xs: a.Hta,
            context: b
        },
        state: {},
        Ch: void 0,
        BQ: !1
    };
    return function() {
        0 < arguments.length ? (d.Ch || (d.Ch = []),
        d.Ch.length = 0,
        d.Ch.push.apply(d.Ch, arguments),
        d.Ch.push(d.state)) : d.Ch && 0 != d.Ch.length ? (d.Ch[0] = d.state,
        d.Ch.length = 1) : d.Ch = [d.state];
        d.BQ || (d.BQ = !0,
        gvjs_7C[gvjs_8C].push(d));
        gvjs_9C || (gvjs_9C = !0,
        window.requestAnimationFrame(gvjs_kea))
    }
}
function gvjs_kea() {
    gvjs_9C = !1;
    var a = gvjs_7C[gvjs_8C]
      , b = a.length;
    gvjs_8C = (gvjs_8C + 1) % 2;
    for (var c, d = 0; d < b; ++d) {
        c = a[d];
        var e = c.kta;
        c.BQ = !1;
        e.Xs && e.Xs.apply(e.context, c.Ch)
    }
    for (d = 0; d < b; ++d)
        c = a[d],
        e = c.Ita,
        c.BQ = !1,
        e.Xs && e.Xs.apply(e.context, c.Ch),
        c.state = {};
    a.length = 0
}
;var gvjs_$C = gvjs_y ? gvjs_gf(gvjs_8e(gvjs_9e('javascript:""'))) : gvjs_gf(gvjs_8e(gvjs_9e("about:blank")));
gvjs_ef(gvjs_$C);
var gvjs_lea = gvjs_y ? gvjs_gf(gvjs_8e(gvjs_9e('javascript:""'))) : gvjs_gf(gvjs_8e(gvjs_9e("javascript:undefined")));
gvjs_ef(gvjs_lea);
function gvjs_mea(a, b) {
    this.H = a;
    this.D = b
}
;function gvjs_aD(a, b) {
    gvjs_MC.call(this, b);
    this.Rya = !!a;
    this.qD = null;
    this.Pea = gvjs_jea({
        Hta: this.FS
    }, this)
}
gvjs_t(gvjs_aD, gvjs_MC);
gvjs_ = gvjs_aD.prototype;
gvjs_.KY = null;
gvjs_.Db = !1;
gvjs_.ul = null;
gvjs_.Si = null;
gvjs_.yp = null;
gvjs_.dW = !1;
gvjs_.sa = function() {
    return "goog-modalpopup"
}
;
gvjs_.AC = function() {
    return this.ul
}
;
gvjs_.J = function() {
    gvjs_aD.G.J.call(this);
    var a = this.j()
      , b = gvjs_kf(this.sa()).split(" ");
    gvjs_WC(a, b);
    gvjs_jz(a, !0);
    gvjs_6(a, !1);
    gvjs_bD(this);
    gvjs_cD(this)
}
;
function gvjs_bD(a) {
    if (a.Rya && !a.Si) {
        var b = a.wa().J(gvjs_Ma, {
            frameborder: 0,
            style: "border:0;vertical-align:bottom;"
        });
        b.src = gvjs_ef(gvjs_$C);
        a.Si = b;
        a.Si.className = a.sa() + "-bg";
        gvjs_6(a.Si, !1);
        gvjs_Fz(a.Si, 0)
    }
    a.ul || (a.ul = a.wa().J(gvjs_b, a.sa() + "-bg"),
    gvjs_6(a.ul, !1))
}
function gvjs_cD(a) {
    a.yp || (a.yp = a.wa().createElement(gvjs_6a),
    gvjs_6(a.yp, !1),
    gvjs_jz(a.yp, !0),
    a.yp.style.position = gvjs_c)
}
gvjs_.Oea = function() {
    this.dW = !1
}
;
gvjs_.Fh = function(a) {
    return !!a && a.tagName == gvjs_b
}
;
gvjs_.vf = function(a) {
    gvjs_aD.G.vf.call(this, a);
    a = gvjs_kf(this.sa()).split(" ");
    gvjs_WC(this.j(), a);
    gvjs_bD(this);
    gvjs_cD(this);
    gvjs_jz(this.j(), !0);
    gvjs_6(this.j(), !1)
}
;
gvjs_.Nb = function() {
    this.Si && gvjs_ih(this.Si, this.j());
    gvjs_ih(this.ul, this.j());
    gvjs_aD.G.Nb.call(this);
    gvjs_jh(this.yp, this.j());
    this.KY = new gvjs_1A(this.wa().kc());
    this.hc().o(this.KY, gvjs_zu, this.rua);
    gvjs_dD(this, !1)
}
;
gvjs_.Le = function() {
    this.isVisible() && this.setVisible(!1);
    gvjs_E(this.KY);
    gvjs_aD.G.Le.call(this);
    gvjs_kh(this.Si);
    gvjs_kh(this.ul);
    gvjs_kh(this.yp)
}
;
gvjs_.setVisible = function(a) {
    a != this.Db && (this.gA && this.gA.stop(),
    this.GB && this.GB.stop(),
    this.fA && this.fA.stop(),
    this.FB && this.FB.stop(),
    this.Bb && gvjs_dD(this, a),
    a ? this.i4() : this.$C())
}
;
function gvjs_dD(a, b) {
    a.$ca || (a.$ca = new gvjs_mea(a.H,a.D));
    a = a.$ca;
    if (b) {
        a.XC || (a.XC = []);
        b = a.D.getChildren(a.D.kc().body);
        for (var c = 0; c < b.length; c++) {
            var d = b[c];
            d == a.H || gvjs_XB(d, gvjs_0u) || (gvjs_WB(d, gvjs_0u, !0),
            a.XC.push(d))
        }
    } else if (a.XC) {
        for (c = 0; c < a.XC.length; c++)
            a.XC[c].removeAttribute(gvjs_dt);
        a.XC = null
    }
}
gvjs_.QE = gvjs_n(38);
gvjs_.i4 = function() {
    if (this.dispatchEvent(gvjs_pt)) {
        try {
            this.qD = this.wa().kc().activeElement
        } catch (a) {}
        this.FS();
        this.Mf();
        this.hc().o(this.wa().Vj(), gvjs_vw, this.FS).o(this.wa().Vj(), gvjs_$v, this.Pea);
        gvjs_eD(this, !0);
        this.focus();
        this.Db = !0;
        this.gA && this.GB ? (gvjs_ei(this.gA, gvjs_R, this.Zz, !1, this),
        this.GB.play(),
        this.gA.play()) : this.Zz()
    }
}
;
gvjs_.$C = function() {
    if (this.dispatchEvent(gvjs_ot)) {
        this.hc().Ab(this.wa().Vj(), gvjs_vw, this.FS).Ab(this.wa().Vj(), gvjs_$v, this.Pea);
        this.Db = !1;
        this.fA && this.FB ? (gvjs_ei(this.fA, gvjs_R, this.yw, !1, this),
        this.FB.play(),
        this.fA.play()) : this.yw();
        a: {
            try {
                var a = this.wa()
                  , b = a.kc().body
                  , c = a.kc().activeElement || b;
                if (!this.qD || this.qD == b) {
                    this.qD = null;
                    break a
                }
                (c == b || a.contains(this.j(), c)) && this.qD.focus()
            } catch (d) {}
            this.qD = null
        }
    }
}
;
function gvjs_eD(a, b) {
    a.Si && gvjs_6(a.Si, b);
    a.ul && gvjs_6(a.ul, b);
    gvjs_6(a.j(), b);
    gvjs_6(a.yp, b)
}
gvjs_.Zz = function() {
    this.dispatchEvent(gvjs_Sw)
}
;
gvjs_.yw = function() {
    gvjs_eD(this, !1);
    this.dispatchEvent(gvjs_1u)
}
;
gvjs_.isVisible = function() {
    return this.Db
}
;
gvjs_.focus = function() {
    this.q$()
}
;
gvjs_.FS = function() {
    this.Si && gvjs_6(this.Si, !1);
    this.ul && gvjs_6(this.ul, !1);
    var a = this.wa().kc()
      , b = gvjs_0x(gvjs_3x(a) || window || window)
      , c = Math.max(b.width, Math.max(a.body.scrollWidth, a.documentElement.scrollWidth));
    a = Math.max(b.height, Math.max(a.body.scrollHeight, a.documentElement.scrollHeight));
    this.Si && (gvjs_6(this.Si, !0),
    gvjs_Cz(this.Si, c, a));
    this.ul && (gvjs_6(this.ul, !0),
    gvjs_Cz(this.ul, c, a))
}
;
gvjs_.Mf = function() {
    var a = this.wa().kc()
      , b = gvjs_3x(a) || window;
    if (gvjs_Eh(this.j()) == gvjs_wu)
        var c = a = 0;
    else
        c = gvjs_2x(this.wa().dd),
        a = c.x,
        c = c.y;
    var d = gvjs_Dz(this.j());
    b = gvjs_0x(b || window);
    a = Math.max(a + b.width / 2 - d.width / 2, 0);
    c = Math.max(c + b.height / 2 - d.height / 2, 0);
    gvjs_sz(this.j(), a, c);
    gvjs_sz(this.yp, a, c)
}
;
gvjs_.rua = function(a) {
    this.dW ? this.Oea() : a.target == this.yp && gvjs_pl(this.q$, 0, this)
}
;
gvjs_.q$ = function() {
    try {
        gvjs_y && this.wa().kc().body.focus(),
        this.j().focus()
    } catch (a) {}
}
;
gvjs_.M = function() {
    gvjs_E(this.gA);
    this.gA = null;
    gvjs_E(this.fA);
    this.fA = null;
    gvjs_E(this.GB);
    this.GB = null;
    gvjs_E(this.FB);
    this.FB = null;
    gvjs_aD.G.M.call(this)
}
;
function gvjs_fD(a, b, c) {
    gvjs_aD.call(this, b, c);
    this.Fj = a || "modal-dialog";
    this.ki = (new gvjs_gD).Pi(gvjs_hD, !0).Pi(gvjs_iD, !1, !0)
}
gvjs_t(gvjs_fD, gvjs_aD);
gvjs_ = gvjs_fD.prototype;
gvjs_.Tna = !0;
gvjs_.JI = !0;
gvjs_.WJ = !0;
gvjs_.dY = !0;
gvjs_.fN = .5;
gvjs_.Pn = "";
gvjs_.Wi = null;
gvjs_.Lj = null;
gvjs_.JH = !1;
gvjs_.ml = null;
gvjs_.tk = null;
gvjs_.PL = null;
gvjs_.vj = null;
gvjs_.Gk = null;
gvjs_.Dh = null;
gvjs_.xK = "dialog";
gvjs_.Yra = !1;
gvjs_.sa = function() {
    return this.Fj
}
;
gvjs_.setTitle = function(a) {
    this.Pn = a;
    this.tk && gvjs_th(this.tk, a)
}
;
gvjs_.getTitle = function() {
    return this.Pn
}
;
gvjs_.V3 = gvjs_n(7);
function gvjs_jD(a, b) {
    a.Wi = b;
    a.Gk && gvjs_cg(a.Gk, b)
}
gvjs_.getContent = function() {
    return null != this.Wi ? gvjs_0f(this.Wi) : ""
}
;
gvjs_.yv = function() {
    return this.xK
}
;
gvjs_.R3 = function(a) {
    this.xK = a
}
;
function gvjs_kD(a) {
    a.j() || a.R()
}
gvjs_.ib = function() {
    gvjs_kD(this);
    return this.Gk
}
;
gvjs_.AC = function() {
    gvjs_kD(this);
    return gvjs_fD.G.AC.call(this)
}
;
function gvjs_lD(a, b) {
    a.fN = b;
    a.j() && (b = a.AC()) && gvjs_Fz(b, a.fN)
}
function gvjs_mD(a, b) {
    a.WJ = b;
    if (a.Bb) {
        var c = a.wa()
          , d = a.AC()
          , e = a.Si;
        b ? (e && c.H_(e, a.j()),
        c.H_(d, a.j())) : (c.removeNode(e),
        c.removeNode(d))
    }
    a.isVisible() && gvjs_dD(a, b)
}
gvjs_.setDraggable = function(a) {
    this.dY = a;
    gvjs_nD(this, a && this.Bb)
}
;
gvjs_.getDraggable = function() {
    return this.dY
}
;
function gvjs_nD(a, b) {
    var c = gvjs_kf(a.Fj + "-title-draggable").split(" ");
    a.j() && (b ? gvjs_WC(a.ml, c) : gvjs_YC(a.ml, c));
    b && !a.Lj ? (b = new gvjs__C(a.j(),a.ml),
    a.Lj = b,
    gvjs_WC(a.ml, c),
    gvjs_G(a.Lj, gvjs_2, a.I3, !1, a)) : !b && a.Lj && (a.Lj.pa(),
    a.Lj = null)
}
gvjs_.J = function() {
    gvjs_fD.G.J.call(this);
    var a = this.j()
      , b = this.wa();
    this.PL = this.getId();
    var c = this.getId() + ".contentEl";
    this.ml = b.J(gvjs_b, this.Fj + "-title", this.tk = b.J(gvjs_6a, {
        className: this.Fj + "-title-text",
        id: this.PL
    }, this.Pn), this.vj = b.J(gvjs_6a, this.Fj + "-title-close"));
    gvjs_gh(a, this.ml, this.Gk = b.J(gvjs_b, {
        className: this.Fj + gvjs_Er,
        id: c
    }), this.Dh = b.J(gvjs_b, this.Fj + "-buttons"));
    gvjs_VB(this.tk, "heading");
    gvjs_VB(this.vj, gvjs_Bt);
    gvjs_jz(this.vj, !0);
    gvjs_0B(this.vj, "Close");
    gvjs_VB(a, this.yv());
    gvjs_WB(a, gvjs_pv, this.PL || "");
    this.Wi && (gvjs_cg(this.Gk, this.Wi),
    this.Yra && c && gvjs_WB(a, "describedby", c));
    gvjs_6(this.vj, this.JI);
    this.ki && (a = this.ki,
    a.H = this.Dh,
    a.R());
    gvjs_6(this.Dh, !!this.ki);
    gvjs_lD(this, this.fN)
}
;
gvjs_.vf = function(a) {
    gvjs_fD.G.vf.call(this, a);
    a = this.j();
    var b = this.Fj + gvjs_Er;
    this.Gk = gvjs_gz(null, b, a)[0];
    this.Gk || (this.Gk = this.wa().J(gvjs_b, b),
    this.Wi && gvjs_cg(this.Gk, this.Wi),
    a.appendChild(this.Gk));
    b = this.Fj + "-title";
    var c = this.Fj + "-title-text"
      , d = this.Fj + "-title-close";
    (this.ml = gvjs_gz(null, b, a)[0]) ? (this.tk = gvjs_gz(null, c, this.ml)[0],
    this.vj = gvjs_gz(null, d, this.ml)[0]) : (this.ml = this.wa().J(gvjs_b, b),
    a.insertBefore(this.ml, this.Gk));
    this.tk ? (this.Pn = gvjs_wh(this.tk),
    this.tk.id || (this.tk.id = this.getId())) : (this.tk = gvjs_4(gvjs_6a, {
        className: c,
        id: this.getId()
    }),
    this.ml.appendChild(this.tk));
    this.PL = this.tk.id;
    gvjs_WB(a, gvjs_pv, this.PL || "");
    this.vj || (this.vj = this.wa().J(gvjs_6a, d),
    this.ml.appendChild(this.vj));
    gvjs_6(this.vj, this.JI);
    b = this.Fj + "-buttons";
    (this.Dh = gvjs_gz(null, b, a)[0]) ? (this.ki = new gvjs_gD(this.wa()),
    this.ki.fb(this.Dh)) : (this.Dh = this.wa().J(gvjs_b, b),
    a.appendChild(this.Dh),
    this.ki && (a = this.ki,
    a.H = this.Dh,
    a.R()),
    gvjs_6(this.Dh, !!this.ki));
    gvjs_lD(this, this.fN)
}
;
gvjs_.Nb = function() {
    gvjs_fD.G.Nb.call(this);
    this.hc().o(this.j(), gvjs_lv, this.Eda).o(this.j(), gvjs_7c, this.Eda);
    this.hc().o(this.Dh, gvjs_Wt, this.hua);
    gvjs_nD(this, this.dY);
    this.hc().o(this.vj, gvjs_Wt, this.Dua);
    var a = this.j();
    gvjs_VB(a, this.yv());
    "" !== this.tk.id && gvjs_WB(a, gvjs_pv, this.tk.id);
    this.WJ || gvjs_mD(this, !1)
}
;
gvjs_.Le = function() {
    this.isVisible() && this.setVisible(!1);
    gvjs_nD(this, !1);
    gvjs_fD.G.Le.call(this)
}
;
gvjs_.setVisible = function(a) {
    a != this.isVisible() && (this.Bb || this.R(),
    gvjs_fD.G.setVisible.call(this, a))
}
;
gvjs_.Zz = function() {
    gvjs_fD.G.Zz.call(this);
    this.dispatchEvent("aftershow")
}
;
gvjs_.yw = function() {
    gvjs_fD.G.yw.call(this);
    this.dispatchEvent("afterhide");
    this.JH && this.pa()
}
;
gvjs_.I3 = function() {
    var a = this.wa().kc()
      , b = gvjs_0x(gvjs_3x(a) || window || window)
      , c = Math.max(a.body.scrollWidth, b.width);
    a = Math.max(a.body.scrollHeight, b.height);
    var d = gvjs_Dz(this.j());
    gvjs_Eh(this.j()) == gvjs_wu ? gvjs_0C(this.Lj, new gvjs_5(0,0,Math.max(0, b.width - d.width),Math.max(0, b.height - d.height))) : gvjs_0C(this.Lj, new gvjs_5(0,0,c - d.width,a - d.height))
}
;
gvjs_.Dua = function() {
    gvjs_oD(this)
}
;
function gvjs_oD(a) {
    if (a.JI) {
        var b = a.ki
          , c = b && b.zN;
        c ? (b = b.get(c),
        a.dispatchEvent(new gvjs_pD(c,b)) && a.setVisible(!1)) : a.setVisible(!1)
    }
}
gvjs_.qT = gvjs_n(59);
gvjs_.M = function() {
    this.Dh = this.vj = null;
    gvjs_fD.G.M.call(this)
}
;
gvjs_.hua = function(a) {
    a: {
        for (a = a.target; null != a && a != this.Dh; ) {
            if (a.tagName == gvjs_To)
                break a;
            a = a.parentNode
        }
        a = null
    }
    if (a && !a.disabled) {
        a = a.name;
        var b = this.ki.get(a);
        this.dispatchEvent(new gvjs_pD(a,b)) && this.setVisible(!1)
    }
}
;
gvjs_.Eda = function(a) {
    var b = !1
      , c = !1
      , d = this.ki
      , e = a.target;
    if (a.type == gvjs_lv)
        if (this.Tna && 27 == a.keyCode) {
            var f = d && d.zN;
            e = e.tagName == gvjs_Uo && !e.disabled;
            f && !e ? (c = !0,
            b = d.get(f),
            b = this.dispatchEvent(new gvjs_pD(f,b))) : e || (b = !0)
        } else {
            if (9 == a.keyCode && a.shiftKey && e == this.j()) {
                this.dW = !0;
                try {
                    this.yp.focus()
                } catch (k) {}
                gvjs_pl(this.Oea, 0, this)
            }
        }
    else if (13 == a.keyCode) {
        if (e.tagName == gvjs_To && !e.disabled)
            f = e.name;
        else if (e == this.vj)
            gvjs_oD(this);
        else if (d) {
            var g = d.qO
              , h = g && gvjs_qD(d, g);
            e = (e.tagName == gvjs_Vo || e.tagName == gvjs_Uo || "A" == e.tagName) && !e.disabled;
            !h || h.disabled || e || (f = g)
        }
        f && d && (c = !0,
        b = this.dispatchEvent(new gvjs_pD(f,String(d.get(f)))))
    } else
        e != this.vj || 32 != a.keyCode && " " != a.key || gvjs_oD(this);
    if (b || c)
        a.stopPropagation(),
        a.preventDefault();
    b && this.setVisible(!1)
}
;
function gvjs_pD(a, b) {
    this.type = gvjs_fu;
    this.key = a;
    this.caption = b
}
gvjs_t(gvjs_pD, gvjs_1h);
function gvjs_gD(a) {
    gvjs_6C.call(this);
    this.D = a || gvjs_3g();
    this.Fj = "goog-buttonset";
    this.zN = this.H = this.qO = null
}
gvjs_t(gvjs_gD, gvjs_6C);
gvjs_ = gvjs_gD.prototype;
gvjs_.clear = function() {
    gvjs_6C.prototype.clear.call(this);
    this.qO = this.zN = null
}
;
gvjs_.set = function(a, b, c, d) {
    gvjs_6C.prototype.set.call(this, a, b);
    c && (this.qO = a);
    d && (this.zN = a);
    return this
}
;
gvjs_.Pi = function(a, b, c) {
    return this.set(a.key, a.caption, b, c)
}
;
gvjs_.R = function() {
    if (this.H) {
        gvjs_cg(this.H, gvjs_9f);
        var a = gvjs_3g(this.H);
        this.forEach(function(b, c) {
            b = a.J(gvjs_To, {
                name: c
            }, b);
            c == this.qO && (b.className = this.Fj + gvjs_Fr);
            this.H.appendChild(b)
        }, this)
    }
}
;
gvjs_.fb = function(a) {
    if (a && 1 == a.nodeType) {
        this.H = a;
        a = (this.H || document).getElementsByTagName(gvjs_To);
        for (var b = 0, c, d, e; c = a[b]; b++)
            if (d = c.name || c.id,
            e = gvjs_wh(c) || c.value,
            d) {
                var f = 0 == b;
                this.set(d, e, f, c.name == gvjs_Ab);
                f && gvjs_VC(c, this.Fj + gvjs_Fr)
            }
    }
}
;
gvjs_.j = function() {
    return this.H
}
;
gvjs_.wa = function() {
    return this.D
}
;
function gvjs_qD(a, b) {
    a = (a.H || document).getElementsByTagName(gvjs_To);
    for (var c = 0, d; d = a[c]; c++)
        if (d.name == b || d.id == b)
            return d;
    return null
}
var gvjs_hD = {
    key: "ok",
    caption: "OK"
}
  , gvjs_iD = {
    key: gvjs_Ab,
    caption: "Cancel"
}
  , gvjs_rD = {
    key: "yes",
    caption: "Yes"
}
  , gvjs_sD = {
    key: "no",
    caption: "No"
}
  , gvjs_nea = {
    key: "save",
    caption: "Save"
}
  , gvjs_oea = {
    key: "continue",
    caption: "Continue"
};
"undefined" != typeof document && ((new gvjs_gD).Pi(gvjs_hD, !0, !0),
(new gvjs_gD).Pi(gvjs_hD, !0).Pi(gvjs_iD, !1, !0),
(new gvjs_gD).Pi(gvjs_rD, !0).Pi(gvjs_sD, !1, !0),
(new gvjs_gD).Pi(gvjs_rD).Pi(gvjs_sD, !0).Pi(gvjs_iD, !1, !0),
(new gvjs_gD).Pi(gvjs_oea).Pi(gvjs_nea).Pi(gvjs_iD, !0, !0));
function gvjs_tD(a, b, c, d) {
    gvjs_5h.call(this, d);
    this.type = gvjs_kv;
    this.keyCode = a;
    this.charCode = b;
    this.repeat = c
}
gvjs_t(gvjs_tD, gvjs_5h);
function gvjs_uD(a, b) {
    gvjs_H.call(this);
    a && this.CB(a, b)
}
gvjs_t(gvjs_uD, gvjs_H);
gvjs_ = gvjs_uD.prototype;
gvjs_.H = null;
gvjs_.FQ = null;
gvjs_.a0 = null;
gvjs_.GQ = null;
gvjs_.Yk = -1;
gvjs_.ih = -1;
gvjs_.Mp = !1;
var gvjs_vD = {
    3: 13,
    12: 144,
    63232: 38,
    63233: 40,
    63234: 37,
    63235: 39,
    63236: 112,
    63237: 113,
    63238: 114,
    63239: 115,
    63240: 116,
    63241: 117,
    63242: 118,
    63243: 119,
    63244: 120,
    63245: 121,
    63246: 122,
    63247: 123,
    63248: 44,
    63272: 46,
    63273: 36,
    63275: 35,
    63276: 33,
    63277: 34,
    63289: 144,
    63302: 45
}
  , gvjs_wD = {
    Up: 38,
    Down: 40,
    Left: 37,
    Right: 39,
    Enter: 13,
    F1: 112,
    F2: 113,
    F3: 114,
    F4: 115,
    F5: 116,
    F6: 117,
    F7: 118,
    F8: 119,
    F9: 120,
    F10: 121,
    F11: 122,
    F12: 123,
    "U+007F": 46,
    Home: 36,
    End: 35,
    PageUp: 33,
    PageDown: 34,
    Insert: 45
}
  , gvjs_xD = !gvjs_tg || gvjs_Eg("525")
  , gvjs_yD = gvjs_ug && gvjs_sg;
gvjs_ = gvjs_uD.prototype;
gvjs_.gn = function(a) {
    if (gvjs_tg || gvjs_rg)
        if (17 == this.Yk && !a.ctrlKey || 18 == this.Yk && !a.altKey || gvjs_ug && 91 == this.Yk && !a.metaKey)
            this.ih = this.Yk = -1;
    -1 == this.Yk && (a.ctrlKey && 17 != a.keyCode ? this.Yk = 17 : a.altKey && 18 != a.keyCode ? this.Yk = 18 : a.metaKey && 91 != a.keyCode && (this.Yk = 91));
    gvjs_xD && !gvjs_bB(a.keyCode, this.Yk, a.shiftKey, a.ctrlKey, a.altKey, a.metaKey) ? this.handleEvent(a) : (this.ih = gvjs_aB(a.keyCode),
    gvjs_yD && (this.Mp = a.altKey))
}
;
gvjs_.kqa = function(a) {
    this.ih = this.Yk = -1;
    this.Mp = a.altKey
}
;
gvjs_.handleEvent = function(a) {
    var b = a.$i
      , c = b.altKey;
    if (gvjs_y && a.type == gvjs_7c) {
        var d = this.ih;
        var e = 13 != d && 27 != d ? b.keyCode : 0
    } else
        (gvjs_tg || gvjs_rg) && a.type == gvjs_7c ? (d = this.ih,
        e = 0 <= b.charCode && 63232 > b.charCode && gvjs_$A(d) ? b.charCode : 0) : gvjs_qg && !gvjs_tg ? (d = this.ih,
        e = gvjs_$A(d) ? b.keyCode : 0) : (a.type == gvjs_7c ? (gvjs_yD && (c = this.Mp),
        b.keyCode == b.charCode ? 32 > b.keyCode ? (d = b.keyCode,
        e = 0) : (d = this.ih,
        e = b.charCode) : (d = b.keyCode || this.ih,
        e = b.charCode || 0)) : (d = b.keyCode || this.ih,
        e = b.charCode || 0),
        gvjs_ug && 63 == e && 224 == d && (d = 191));
    var f = d = gvjs_aB(d);
    d ? 63232 <= d && d in gvjs_vD ? f = gvjs_vD[d] : 25 == d && a.shiftKey && (f = 9) : b.keyIdentifier && b.keyIdentifier in gvjs_wD && (f = gvjs_wD[b.keyIdentifier]);
    gvjs_sg && gvjs_xD && a.type == gvjs_7c && !gvjs_bB(f, this.Yk, a.shiftKey, a.ctrlKey, c, a.metaKey) || (a = f == this.Yk,
    this.Yk = f,
    b = new gvjs_tD(f,e,a,b),
    b.altKey = c,
    this.dispatchEvent(b))
}
;
gvjs_.j = function() {
    return this.H
}
;
gvjs_.CB = function(a, b) {
    this.GQ && this.detach();
    this.H = a;
    this.FQ = gvjs_G(this.H, gvjs_7c, this, b);
    this.a0 = gvjs_G(this.H, gvjs_lv, this.gn, b, this);
    this.GQ = gvjs_G(this.H, gvjs_mv, this.kqa, b, this)
}
;
gvjs_.detach = function() {
    this.FQ && (gvjs_ki(this.FQ),
    gvjs_ki(this.a0),
    gvjs_ki(this.GQ),
    this.GQ = this.a0 = this.FQ = null);
    this.H = null;
    this.ih = this.Yk = -1
}
;
gvjs_.M = function() {
    gvjs_uD.G.M.call(this);
    this.detach()
}
;
function gvjs_zD() {}
var gvjs_AD;
gvjs_le(gvjs_zD);
var gvjs_pea = {
    button: "pressed",
    checkbox: gvjs_Vt,
    menuitem: gvjs_Iw,
    menuitemcheckbox: gvjs_Vt,
    menuitemradio: gvjs_Vt,
    radio: gvjs_Vt,
    tab: gvjs_Iw,
    treeitem: gvjs_Iw
};
gvjs_ = gvjs_zD.prototype;
gvjs_.Qk = function() {}
;
gvjs_.J = function(a) {
    return a.wa().J(gvjs_b, this.Rl(a).join(" "), a.getContent())
}
;
gvjs_.ib = function(a) {
    return a
}
;
gvjs_.Qs = function(a, b, c) {
    if (a = a.j ? a.j() : a) {
        var d = [b];
        gvjs_y && !gvjs_Eg("7") && (d = gvjs_BD(gvjs_SC(a), b),
        d.push(b));
        (c ? gvjs_WC : gvjs_YC)(a, d)
    }
}
;
gvjs_.Fh = function() {
    return !0
}
;
gvjs_.fb = function(a, b) {
    b.id && a.lL(b.id);
    var c = this.ib(b);
    c && c.firstChild ? a.JE(c.firstChild.nextSibling ? gvjs_Le(c.childNodes) : c.firstChild) : a.JE(null);
    var d = 0
      , e = this.sa()
      , f = this.sa()
      , g = !1
      , h = !1
      , k = !1
      , l = gvjs_Le(gvjs_SC(b));
    l.forEach(function(n) {
        g || n != e ? h || n != f ? d |= this.BP(n) : h = !0 : (g = !0,
        f == e && (h = !0));
        1 == this.BP(n) && gvjs_Sx(c) && gvjs_jz(c, !1)
    }, this);
    a.K = d;
    g || (l.push(e),
    f == e && (h = !0));
    h || l.push(f);
    (a = a.yo) && l.push.apply(l, a);
    if (gvjs_y && !gvjs_Eg("7")) {
        var m = gvjs_BD(l);
        0 < m.length && (l.push.apply(l, m),
        k = !0)
    }
    g && h && !a && !k || gvjs_TC(b, l.join(" "));
    return b
}
;
gvjs_.ln = function(a) {
    a.gh() && this.vA(a.j(), !0);
    a.isEnabled() && this.jp(a, a.isVisible())
}
;
function gvjs_CD(a, b, c) {
    if (a = c || a.Qk())
        c = b.getAttribute(gvjs_Bd) || null,
        a != c && gvjs_VB(b, a)
}
function gvjs_DD(a, b, c) {
    var d = b.r7;
    null != d && a.B3(c, d);
    b.isVisible() || gvjs_WB(c, gvjs_0u, !b.isVisible());
    b.isEnabled() || a.Lr(c, 1, !b.isEnabled());
    gvjs_ED(b, 8) && a.Lr(c, 8, b.CQ());
    gvjs_ED(b, 16) && a.Lr(c, 16, b.nn());
    gvjs_ED(b, 64) && a.Lr(c, 64, gvjs_FD(b, 64))
}
gvjs_.B3 = function(a, b) {
    gvjs_0B(a, b)
}
;
gvjs_.gL = function(a, b) {
    gvjs_Hz(a, !b, !gvjs_y && !gvjs_qg)
}
;
gvjs_.vA = function(a, b) {
    this.Qs(a, this.sa() + "-rtl", b)
}
;
gvjs_.Gq = function(a) {
    var b;
    return gvjs_ED(a, 32) && (b = a.Kg()) ? gvjs_Sx(b) : !1
}
;
gvjs_.jp = function(a, b) {
    var c;
    if (gvjs_ED(a, 32) && (c = a.Kg())) {
        if (!b && gvjs_FD(a, 32)) {
            try {
                c.blur()
            } catch (d) {}
            gvjs_FD(a, 32) && a.$y(null)
        }
        gvjs_Sx(c) != b && gvjs_jz(c, b)
    }
}
;
gvjs_.setVisible = function(a, b) {
    gvjs_6(a, b);
    a && gvjs_WB(a, gvjs_0u, !b)
}
;
gvjs_.setState = function(a, b, c) {
    var d = a.j();
    if (d) {
        var e = this.oI(b);
        e && this.Qs(a, e, c);
        this.Lr(d, b, c)
    }
}
;
gvjs_.Lr = function(a, b, c) {
    gvjs_AD || (gvjs_AD = {
        1: "disabled",
        8: gvjs_Iw,
        16: gvjs_Vt,
        64: "expanded"
    });
    b = gvjs_AD[b];
    var d = a.getAttribute(gvjs_Bd) || null;
    d && (d = gvjs_pea[d] || b,
    b = b == gvjs_Vt || b == gvjs_Iw ? d : b);
    b && gvjs_WB(a, b, c)
}
;
gvjs_.setContent = function(a, b) {
    var c = this.ib(a);
    c && (gvjs_hh(c),
    b && (typeof b === gvjs_l ? gvjs_th(c, b) : (a = function(d) {
        if (d) {
            var e = gvjs_5g(c);
            c.appendChild(typeof d === gvjs_l ? e.createTextNode(d) : d)
        }
    }
    ,
    Array.isArray(b) ? b.forEach(a) : !gvjs_ne(b) || gvjs_pd in b ? a(b) : gvjs_Le(b).forEach(a))))
}
;
gvjs_.Kg = function(a) {
    return a.j()
}
;
gvjs_.sa = function() {
    return gvjs_Gs
}
;
gvjs_.Rl = function(a) {
    var b = this.sa()
      , c = [b]
      , d = this.sa();
    d != b && c.push(d);
    b = a.getState();
    for (d = []; b; ) {
        var e = b & -b;
        d.push(this.oI(e));
        b &= ~e
    }
    c.push.apply(c, d);
    (a = a.yo) && c.push.apply(c, a);
    gvjs_y && !gvjs_Eg("7") && c.push.apply(c, gvjs_BD(c));
    return c
}
;
function gvjs_BD(a, b) {
    var c = [];
    b && (a = gvjs_Ke(a, [b]));
    [].forEach(function(d) {
        !gvjs_Ge(d, gvjs_re(gvjs_He, a)) || b && !gvjs_He(d, b) || c.push(d.join("_"))
    });
    return c
}
gvjs_.oI = function(a) {
    this.HN || gvjs_GD(this);
    return this.HN[a]
}
;
gvjs_.BP = function(a) {
    this.jga || (this.HN || gvjs_GD(this),
    this.jga = gvjs_Uy(this.HN));
    a = parseInt(this.jga[a], 10);
    return isNaN(a) ? 0 : a
}
;
function gvjs_GD(a) {
    var b = a.sa();
    gvjs_sf(b.replace(/\xa0|\s/g, " "), " ");
    a.HN = {
        1: b + gvjs_Gr,
        2: b + "-hover",
        4: b + "-active",
        8: b + "-selected",
        16: b + "-checked",
        32: b + "-focused",
        64: b + "-open"
    }
}
;function gvjs_HD(a, b) {
    if (!a)
        throw Error("Invalid class name " + a);
    if (typeof b !== gvjs_d)
        throw Error("Invalid decorator function " + b);
    gvjs_ID[a] = b
}
function gvjs_JD(a) {
    a = gvjs_SC(a);
    for (var b = 0, c = a.length; b < c; b++) {
        var d = a[b];
        if (d = d in gvjs_ID ? gvjs_ID[d]() : null)
            return d
    }
    return null
}
var gvjs_KD = {}
  , gvjs_ID = {};
function gvjs_LD(a, b, c) {
    gvjs_MC.call(this, c);
    if (!b) {
        for (b = this.constructor; b; ) {
            var d = gvjs_pe(b);
            if (d = gvjs_KD[d])
                break;
            b = (b = Object.getPrototypeOf(b.prototype)) && b.constructor
        }
        b = d ? typeof d.Lc === gvjs_d ? d.Lc() : new d : null
    }
    this.F = b;
    this.JE(void 0 !== a ? a : null);
    this.r7 = null
}
gvjs_t(gvjs_LD, gvjs_MC);
gvjs_ = gvjs_LD.prototype;
gvjs_.Wi = null;
gvjs_.K = 0;
gvjs_.BL = 39;
gvjs_.cs = 255;
gvjs_.ju = 0;
gvjs_.Db = !0;
gvjs_.yo = null;
gvjs_.OP = !0;
gvjs_.YM = !1;
gvjs_.xK = null;
function gvjs_MD(a, b) {
    a.Bb && b != a.OP && gvjs_ND(a, b);
    a.OP = b
}
gvjs_.Kg = function() {
    return this.F.Kg(this)
}
;
gvjs_.rP = function() {
    return this.Gf || (this.Gf = new gvjs_uD)
}
;
gvjs_.Oa = function() {
    return this.F
}
;
gvjs_.AT = gvjs_n(61);
gvjs_.Xr = function(a) {
    a && (this.yo ? gvjs_He(this.yo, a) || this.yo.push(a) : this.yo = [a],
    this.F.Qs(this, a, !0))
}
;
gvjs_.Qs = function(a, b) {
    b ? this.Xr(a) : a && this.yo && gvjs_Ie(this.yo, a) && (0 == this.yo.length && (this.yo = null),
    this.F.Qs(this, a, !1))
}
;
gvjs_.J = function() {
    var a = this.F.J(this);
    this.H = a;
    gvjs_CD(this.F, a, this.yv());
    this.YM || this.F.gL(a, !1);
    this.isVisible() || this.F.setVisible(a, !1)
}
;
gvjs_.yv = function() {
    return this.xK
}
;
gvjs_.R3 = function(a) {
    this.xK = a
}
;
gvjs_.B3 = function(a) {
    this.r7 = a;
    var b = this.j();
    b && this.F.B3(b, a)
}
;
gvjs_.ib = function() {
    return this.F.ib(this.j())
}
;
gvjs_.Fh = function(a) {
    return this.F.Fh(a)
}
;
gvjs_.vf = function(a) {
    this.H = a = this.F.fb(this, a);
    gvjs_CD(this.F, a, this.yv());
    this.YM || this.F.gL(a, !1);
    this.Db = a.style.display != gvjs_f
}
;
gvjs_.Nb = function() {
    gvjs_LD.G.Nb.call(this);
    gvjs_DD(this.F, this, this.H);
    this.F.ln(this);
    if (this.BL & -2 && (this.OP && gvjs_ND(this, !0),
    gvjs_ED(this, 32))) {
        var a = this.Kg();
        if (a) {
            var b = this.rP();
            b.CB(a);
            this.hc().o(b, gvjs_kv, this.gj).o(a, gvjs_xu, this.Iv).o(a, gvjs_Yo, this.$y)
        }
    }
}
;
function gvjs_ND(a, b) {
    var c = a.eA ? gvjs_4h : gvjs_Mz
      , d = a.hc()
      , e = a.j();
    b ? (d.o(e, c.ux, a.Cf).o(e, [c.wx, c.mB], a.Mo).o(e, gvjs_ld, a.Lo).o(e, gvjs_kd, a.PP),
    a.eA && d.o(e, gvjs_Ou, a.nS),
    a.CI != gvjs_ke && d.o(e, gvjs_3t, a.CI),
    gvjs_y && (gvjs_Eg(9) || d.o(e, gvjs_du, a.maa),
    a.XI || (a.XI = new gvjs_OD(a),
    gvjs_6x(a, a.XI)))) : (d.Ab(e, c.ux, a.Cf).Ab(e, [c.wx, c.mB], a.Mo).Ab(e, gvjs_ld, a.Lo).Ab(e, gvjs_kd, a.PP),
    a.eA && d.Ab(e, gvjs_Ou, a.nS),
    a.CI != gvjs_ke && d.Ab(e, gvjs_3t, a.CI),
    gvjs_y && (gvjs_Eg(9) || d.Ab(e, gvjs_du, a.maa),
    gvjs_E(a.XI),
    a.XI = null))
}
gvjs_.Le = function() {
    gvjs_LD.G.Le.call(this);
    this.Gf && this.Gf.detach();
    this.isVisible() && this.isEnabled() && this.F.jp(this, !1)
}
;
gvjs_.M = function() {
    gvjs_LD.G.M.call(this);
    this.Gf && (this.Gf.pa(),
    delete this.Gf);
    delete this.F;
    this.XI = this.yo = this.Wi = null
}
;
gvjs_.getContent = function() {
    return this.Wi
}
;
gvjs_.setContent = function(a) {
    this.F.setContent(this.j(), a);
    this.JE(a)
}
;
gvjs_.JE = function(a) {
    this.Wi = a
}
;
gvjs_.bj = function() {
    var a = this.getContent();
    if (!a)
        return "";
    a = typeof a === gvjs_l ? a : Array.isArray(a) ? a.map(gvjs_kz).join("") : gvjs_wh(a);
    return gvjs_Zy(a)
}
;
gvjs_.vA = function(a) {
    gvjs_LD.G.vA.call(this, a);
    var b = this.j();
    b && this.F.vA(b, a)
}
;
gvjs_.gL = function(a) {
    this.YM = a;
    var b = this.j();
    b && this.F.gL(b, a)
}
;
gvjs_.isVisible = function() {
    return this.Db
}
;
gvjs_.setVisible = function(a, b) {
    return b || this.Db != a && this.dispatchEvent(a ? gvjs_Sw : gvjs_1u) ? ((b = this.j()) && this.F.setVisible(b, a),
    this.isEnabled() && this.F.jp(this, a),
    this.Db = a,
    !0) : !1
}
;
gvjs_.isEnabled = function() {
    return !gvjs_FD(this, 1)
}
;
gvjs_.Gb = function(a) {
    var b = this.getParent();
    b && typeof b.isEnabled == gvjs_d && !b.isEnabled() || !gvjs_PD(this, 1, !a) || (a || (this.setActive(!1),
    this.ci(!1)),
    this.isVisible() && this.F.jp(this, a),
    this.setState(1, !a, !0))
}
;
gvjs_.ci = function(a) {
    gvjs_PD(this, 2, a) && this.setState(2, a)
}
;
gvjs_.ak = function() {
    return gvjs_FD(this, 4)
}
;
gvjs_.setActive = function(a) {
    gvjs_PD(this, 4, a) && this.setState(4, a)
}
;
gvjs_.CQ = function() {
    return gvjs_FD(this, 8)
}
;
gvjs_.qp = function(a) {
    gvjs_PD(this, 8, a) && this.setState(8, a)
}
;
gvjs_.nn = function() {
    return gvjs_FD(this, 16)
}
;
gvjs_.bi = function(a) {
    gvjs_PD(this, 16, a) && this.setState(16, a)
}
;
gvjs_.KE = function(a) {
    gvjs_PD(this, 32, a) && this.setState(32, a)
}
;
gvjs_.Kd = function(a) {
    gvjs_PD(this, 64, a) && this.setState(64, a)
}
;
gvjs_.getState = function() {
    return this.K
}
;
function gvjs_FD(a, b) {
    return !!(a.K & b)
}
gvjs_.setState = function(a, b, c) {
    c || 1 != a ? gvjs_ED(this, a) && b != gvjs_FD(this, a) && (this.F.setState(this, a, b),
    this.K = b ? this.K | a : this.K & ~a) : this.Gb(!b)
}
;
function gvjs_ED(a, b) {
    return !!(a.BL & b)
}
gvjs_.eg = function(a, b) {
    if (this.Bb && gvjs_FD(this, a) && !b)
        throw Error(gvjs_8r);
    !b && gvjs_FD(this, a) && this.setState(a, !1);
    this.BL = b ? this.BL | a : this.BL & ~a
}
;
function gvjs_QD(a, b) {
    return !!(a.cs & b) && gvjs_ED(a, b)
}
function gvjs_PD(a, b, c) {
    return gvjs_ED(a, b) && gvjs_FD(a, b) != c && (!(a.ju & b) || a.dispatchEvent(gvjs_NC(b, c))) && !a.xf
}
gvjs_.Lo = function(a) {
    !gvjs_RD(a, this.j()) && this.dispatchEvent("enter") && this.isEnabled() && gvjs_QD(this, 2) && this.ci(!0)
}
;
gvjs_.PP = function(a) {
    !gvjs_RD(a, this.j()) && this.dispatchEvent("leave") && (gvjs_QD(this, 4) && this.setActive(!1),
    gvjs_QD(this, 2) && this.ci(!1))
}
;
gvjs_.nS = function(a) {
    var b = a.target;
    b.releasePointerCapture && b.releasePointerCapture(a.pointerId)
}
;
gvjs_.CI = gvjs_ke;
function gvjs_RD(a, b) {
    return !!a.relatedTarget && gvjs_rh(b, a.relatedTarget)
}
gvjs_.Cf = function(a) {
    this.isEnabled() && (gvjs_QD(this, 2) && this.ci(!0),
    gvjs_7x(a) && (gvjs_QD(this, 4) && this.setActive(!0),
    this.F && this.F.Gq(this) && this.Kg().focus()));
    !this.YM && gvjs_7x(a) && a.preventDefault()
}
;
gvjs_.Mo = function(a) {
    this.isEnabled() && (gvjs_QD(this, 2) && this.ci(!0),
    this.ak() && this.$h(a) && gvjs_QD(this, 4) && this.setActive(!1))
}
;
gvjs_.maa = function(a) {
    this.isEnabled() && this.$h(a)
}
;
gvjs_.$h = function(a) {
    gvjs_QD(this, 16) && this.bi(!this.nn());
    gvjs_QD(this, 8) && this.qp(!0);
    gvjs_QD(this, 64) && this.Kd(!gvjs_FD(this, 64));
    var b = new gvjs_1h(gvjs_Ss,this);
    a && (b.altKey = a.altKey,
    b.ctrlKey = a.ctrlKey,
    b.metaKey = a.metaKey,
    b.shiftKey = a.shiftKey,
    b.m2 = a.m2);
    return this.dispatchEvent(b)
}
;
gvjs_.Iv = function() {
    gvjs_QD(this, 32) && this.KE(!0)
}
;
gvjs_.$y = function() {
    gvjs_QD(this, 4) && this.setActive(!1);
    gvjs_QD(this, 32) && this.KE(!1)
}
;
gvjs_.gj = function(a) {
    return this.isVisible() && this.isEnabled() && this.Wj(a) ? (a.preventDefault(),
    a.stopPropagation(),
    !0) : !1
}
;
gvjs_.Wj = function(a) {
    return 13 == a.keyCode && this.$h(a)
}
;
if (typeof gvjs_LD !== gvjs_d)
    throw Error("Invalid component class " + gvjs_LD);
if (typeof gvjs_zD !== gvjs_d)
    throw Error("Invalid renderer class " + gvjs_zD);
var gvjs_qea = gvjs_pe(gvjs_LD);
gvjs_KD[gvjs_qea] = gvjs_zD;
gvjs_HD(gvjs_Gs, function() {
    return new gvjs_LD(null)
});
function gvjs_OD(a) {
    gvjs_F.call(this);
    this.ZN = a;
    this.MN = !1;
    this.pd = new gvjs_KA(this);
    gvjs_6x(this, this.pd);
    var b = this.ZN.H;
    a = a.eA ? gvjs_4h : gvjs_Mz;
    this.pd.o(b, a.ux, this.UC).o(b, a.wx, this.RP).o(b, gvjs_Wt, this.et)
}
gvjs_t(gvjs_OD, gvjs_F);
var gvjs_SD = !gvjs_y || gvjs_Fg(9);
gvjs_OD.prototype.UC = function() {
    this.MN = !1
}
;
gvjs_OD.prototype.RP = function() {
    this.MN = !0
}
;
function gvjs_TD(a, b) {
    if (!gvjs_SD)
        return a.button = 0,
        a.type = b,
        a;
    var c = document.createEvent("MouseEvents");
    c.initMouseEvent(b, a.bubbles, a.cancelable, a.view || null, a.detail, a.screenX, a.screenY, a.clientX, a.clientY, a.ctrlKey, a.altKey, a.shiftKey, a.metaKey, 0, a.relatedTarget || null);
    return c
}
gvjs_OD.prototype.et = function(a) {
    if (this.MN)
        this.MN = !1;
    else {
        var b = a.$i
          , c = b.button
          , d = b.type
          , e = gvjs_TD(b, gvjs_gd);
        this.ZN.Cf(new gvjs_5h(e,a.currentTarget));
        e = gvjs_TD(b, gvjs_md);
        this.ZN.Mo(new gvjs_5h(e,a.currentTarget));
        gvjs_SD || (b.button = c,
        b.type = d)
    }
}
;
gvjs_OD.prototype.M = function() {
    this.ZN = null;
    gvjs_OD.G.M.call(this)
}
;
function gvjs_UD() {
    this.SW = []
}
gvjs_t(gvjs_UD, gvjs_zD);
gvjs_le(gvjs_UD);
function gvjs_VD(a, b) {
    var c = a.SW[b];
    if (!c) {
        switch (b) {
        case 0:
            c = a.sa() + "-highlight";
            break;
        case 1:
            c = a.sa() + "-checkbox";
            break;
        case 2:
            c = a.sa() + gvjs_Er
        }
        a.SW[b] = c
    }
    return c
}
gvjs_ = gvjs_UD.prototype;
gvjs_.Qk = function() {
    return "menuitem"
}
;
gvjs_.J = function(a) {
    var b = a.wa().J(gvjs_b, this.Rl(a).join(" "), gvjs_WD(this, a.getContent(), a.wa()));
    gvjs_XD(this, a, b, gvjs_ED(a, 8) || gvjs_ED(a, 16));
    return b
}
;
gvjs_.ib = function(a) {
    return a && a.firstChild
}
;
gvjs_.fb = function(a, b) {
    var c = gvjs_mh(b)
      , d = gvjs_VD(this, 2);
    c && gvjs_UC(c, d) || b.appendChild(gvjs_WD(this, b.childNodes, a.wa()));
    gvjs_UC(b, gvjs_Ms) && (a.kT(!0),
    this.kT(a, b, !0));
    return gvjs_UD.G.fb.call(this, a, b)
}
;
gvjs_.setContent = function(a, b) {
    var c = this.ib(a)
      , d = gvjs_YD(this, a) ? c.firstChild : null;
    gvjs_UD.G.setContent.call(this, a, b);
    d && !gvjs_YD(this, a) && c.insertBefore(d, c.firstChild || null)
}
;
function gvjs_WD(a, b, c) {
    a = gvjs_VD(a, 2);
    return c.J(gvjs_b, a, b)
}
gvjs_.S3 = function(a, b, c) {
    a && b && gvjs_XD(this, a, b, c)
}
;
gvjs_.kT = function(a, b, c) {
    a && b && gvjs_XD(this, a, b, c)
}
;
function gvjs_YD(a, b) {
    return (b = a.ib(b)) ? (b = b.firstChild,
    a = gvjs_VD(a, 1),
    !!b && gvjs_ph(b) && gvjs_UC(b, a)) : !1
}
function gvjs_XD(a, b, c, d) {
    gvjs_CD(a, c, b.yv());
    gvjs_DD(a, b, c);
    d != gvjs_YD(a, c) && (gvjs_ZC(c, gvjs_Ms, d),
    c = a.ib(c),
    d ? (a = gvjs_VD(a, 1),
    c.insertBefore(b.wa().J(gvjs_b, a), c.firstChild || null)) : c.removeChild(c.firstChild))
}
gvjs_.oI = function(a) {
    switch (a) {
    case 2:
        return gvjs_VD(this, 0);
    case 16:
    case 8:
        return gvjs_Ns;
    default:
        return gvjs_UD.G.oI.call(this, a)
    }
}
;
gvjs_.BP = function(a) {
    var b = gvjs_VD(this, 0);
    switch (a) {
    case gvjs_Ns:
        return 16;
    case b:
        return 2;
    default:
        return gvjs_UD.G.BP.call(this, a)
    }
}
;
gvjs_.sa = function() {
    return gvjs__
}
;
function gvjs_ZD(a, b, c, d) {
    gvjs_LD.call(this, a, d || gvjs_UD.Lc(), c);
    this.Wa(b)
}
gvjs_t(gvjs_ZD, gvjs_LD);
gvjs_ = gvjs_ZD.prototype;
gvjs_.getValue = function() {
    var a = this.Zh;
    return null != a ? a : this.bj()
}
;
gvjs_.Wa = function(a) {
    this.Zh = a
}
;
gvjs_.eg = function(a, b) {
    gvjs_ZD.G.eg.call(this, a, b);
    switch (a) {
    case 8:
        this.nn() && !b && this.bi(!1);
        (a = this.j()) && this.Oa().S3(this, a, b);
        break;
    case 16:
        (a = this.j()) && this.Oa().kT(this, a, b)
    }
}
;
gvjs_.S3 = function(a) {
    this.eg(8, a)
}
;
gvjs_.kT = function(a) {
    this.eg(16, a)
}
;
gvjs_.bj = function() {
    var a = this.getContent();
    return Array.isArray(a) ? (a = gvjs_v(a, function(b) {
        return gvjs_ph(b) && (gvjs_UC(b, "goog-menuitem-accel") || gvjs_UC(b, "goog-menuitem-mnemonic-separator")) ? "" : gvjs_kz(b)
    }).join(""),
    gvjs_Zy(a)) : gvjs_ZD.G.bj.call(this)
}
;
gvjs_.Mo = function(a) {
    var b = this.getParent();
    if (b) {
        var c = b.Nda;
        b.Nda = null;
        if (c && typeof a.clientX === gvjs_g && gvjs_2g(c, new gvjs_z(a.clientX,a.clientY)))
            return
    }
    gvjs_ZD.G.Mo.call(this, a)
}
;
gvjs_.Wj = function(a) {
    return a.keyCode == this.g1 && this.$h(a) ? !0 : gvjs_ZD.G.Wj.call(this, a)
}
;
gvjs_.Soa = function() {
    return this.g1
}
;
gvjs_HD(gvjs__, function() {
    return new gvjs_ZD(null)
});
gvjs_ZD.prototype.yv = function() {
    return gvjs_ED(this, 16) ? "menuitemcheckbox" : gvjs_ED(this, 8) ? "menuitemradio" : gvjs_ZD.G.yv.call(this)
}
;
gvjs_ZD.prototype.getParent = function() {
    return gvjs_LD.prototype.getParent.call(this)
}
;
gvjs_ZD.prototype.GC = function() {
    return gvjs_LD.prototype.GC.call(this)
}
;
function gvjs__D(a, b, c, d) {
    gvjs_8A.call(this, a, b);
    this.MQ = c ? 5 : 0;
    this.Z1 = d || void 0
}
gvjs_t(gvjs__D, gvjs_8A);
gvjs__D.prototype.Qoa = function() {
    return this.MQ
}
;
gvjs__D.prototype.Mf = function(a, b, c, d) {
    var e = gvjs_7A(this.element, this.lH, a, b, null, c, 10, d, this.Z1);
    if (e & 496) {
        var f = gvjs_0D(e, this.lH);
        b = gvjs_0D(e, b);
        e = gvjs_7A(this.element, f, a, b, null, c, 10, d, this.Z1);
        e & 496 && (f = gvjs_0D(e, f),
        b = gvjs_0D(e, b),
        gvjs_7A(this.element, f, a, b, null, c, this.MQ, d, this.Z1))
    }
}
;
function gvjs_0D(a, b) {
    a & 48 && (b ^= 4);
    a & 192 && (b ^= 1);
    return b
}
;function gvjs_1D(a, b, c, d) {
    gvjs__D.call(this, a, b, c || d);
    if (c || d)
        this.MQ = 65 | (d ? 32 : 132)
}
gvjs_t(gvjs_1D, gvjs__D);
function gvjs_2D() {}
gvjs_t(gvjs_2D, gvjs_zD);
gvjs_le(gvjs_2D);
gvjs_ = gvjs_2D.prototype;
gvjs_.Qk = function() {
    return gvjs_Bt
}
;
gvjs_.Lr = function(a, b, c) {
    switch (b) {
    case 8:
    case 16:
        gvjs_WB(a, "pressed", c);
        break;
    default:
    case 64:
    case 1:
        gvjs_2D.G.Lr.call(this, a, b, c)
    }
}
;
gvjs_.J = function(a) {
    var b = gvjs_2D.G.J.call(this, a);
    this.il(b, a.en());
    var c = a.getValue();
    c && this.Wa(b, c);
    gvjs_ED(a, 16) && this.Lr(b, 16, a.nn());
    return b
}
;
gvjs_.fb = function(a, b) {
    b = gvjs_2D.G.fb.call(this, a, b);
    var c = this.getValue(b);
    a.$d = c;
    a.PE(this.en(b));
    gvjs_ED(a, 16) && this.Lr(b, 16, a.nn());
    return b
}
;
gvjs_.getValue = gvjs_ke;
gvjs_.Wa = gvjs_ke;
gvjs_.en = function(a) {
    return a.title
}
;
gvjs_.il = function(a, b) {
    a && (b ? a.title = b : a.removeAttribute(gvjs_fx))
}
;
gvjs_.Lw = function(a, b) {
    var c = a.gh()
      , d = this.sa() + "-collapse-left"
      , e = this.sa() + "-collapse-right";
    a.Qs(c ? e : d, !!(b & 1));
    a.Qs(c ? d : e, !!(b & 2))
}
;
gvjs_.sa = function() {
    return gvjs_Es
}
;
function gvjs_3D() {}
gvjs_t(gvjs_3D, gvjs_2D);
gvjs_le(gvjs_3D);
gvjs_ = gvjs_3D.prototype;
gvjs_.Qk = function() {}
;
gvjs_.J = function(a) {
    gvjs_MD(a, !1);
    a.cs &= -256;
    a.eg(32, !1);
    return a.wa().J(gvjs_To, {
        "class": this.Rl(a).join(" "),
        disabled: !a.isEnabled(),
        title: a.en() || "",
        value: a.getValue() || ""
    }, a.bj() || "")
}
;
gvjs_.Fh = function(a) {
    return a.tagName == gvjs_To || a.tagName == gvjs_Na && (a.type == gvjs_Bt || "submit" == a.type || "reset" == a.type)
}
;
gvjs_.fb = function(a, b) {
    gvjs_MD(a, !1);
    a.cs &= -256;
    a.eg(32, !1);
    if (b.disabled) {
        var c = this.oI(1);
        gvjs_VC(b, c)
    }
    return gvjs_3D.G.fb.call(this, a, b)
}
;
gvjs_.ln = function(a) {
    a.hc().o(a.j(), gvjs_Wt, a.$h)
}
;
gvjs_.gL = gvjs_ke;
gvjs_.vA = gvjs_ke;
gvjs_.Gq = function(a) {
    return a.isEnabled()
}
;
gvjs_.jp = gvjs_ke;
gvjs_.setState = function(a, b, c) {
    gvjs_3D.G.setState.call(this, a, b, c);
    (a = a.j()) && 1 == b && (a.disabled = c)
}
;
gvjs_.getValue = function(a) {
    return a.value
}
;
gvjs_.Wa = function(a, b) {
    a && (a.value = b)
}
;
gvjs_.Lr = gvjs_ke;
function gvjs_4D(a, b, c) {
    gvjs_LD.call(this, a, b || gvjs_3D.Lc(), c)
}
gvjs_t(gvjs_4D, gvjs_LD);
gvjs_ = gvjs_4D.prototype;
gvjs_.getValue = function() {
    return this.$d
}
;
gvjs_.Wa = function(a) {
    this.$d = a;
    this.Oa().Wa(this.j(), a)
}
;
gvjs_.en = function() {
    return this.xa
}
;
gvjs_.il = function(a) {
    this.xa = a;
    this.Oa().il(this.j(), a)
}
;
gvjs_.PE = function(a) {
    this.xa = a
}
;
gvjs_.Lw = function(a) {
    this.Oa().Lw(this, a)
}
;
gvjs_.M = function() {
    gvjs_4D.G.M.call(this);
    delete this.$d;
    delete this.xa
}
;
gvjs_.Nb = function() {
    gvjs_4D.G.Nb.call(this);
    if (gvjs_ED(this, 32)) {
        var a = this.Kg();
        a && this.hc().o(a, gvjs_mv, this.Wj)
    }
}
;
gvjs_.Wj = function(a) {
    return 13 == a.keyCode && a.type == gvjs_kv || 32 == a.keyCode && a.type == gvjs_mv ? this.$h(a) : 32 == a.keyCode
}
;
gvjs_HD(gvjs_Es, function() {
    return new gvjs_4D(null)
});
function gvjs_5D(a) {
    this.dN = a
}
gvjs_le(gvjs_5D);
gvjs_ = gvjs_5D.prototype;
gvjs_.Qk = function() {
    return this.dN
}
;
function gvjs_6D(a, b) {
    a && (a.tabIndex = b ? 0 : -1)
}
gvjs_.J = function(a) {
    return a.wa().J(gvjs_b, this.Rl(a).join(" "))
}
;
gvjs_.ib = function(a) {
    return a
}
;
gvjs_.Fh = function(a) {
    return a.tagName == gvjs_b
}
;
gvjs_.fb = function(a, b) {
    b.id && a.lL(b.id);
    var c = this.sa()
      , d = !1
      , e = gvjs_SC(b);
    e && Array.prototype.forEach.call(e, function(f) {
        f == c ? d = !0 : f && this.T3(a, f, c)
    }, this);
    d || gvjs_VC(b, c);
    gvjs_7D(this, a, this.ib(b));
    return b
}
;
gvjs_.T3 = function(a, b, c) {
    b == c + gvjs_Gr ? a.Gb(!1) : b == c + "-horizontal" ? a.setOrientation(gvjs_S) : b == c + "-vertical" && a.setOrientation(gvjs_U)
}
;
function gvjs_7D(a, b, c) {
    if (c)
        for (var d = c.firstChild, e; d && d.parentNode == c; ) {
            e = d.nextSibling;
            if (1 == d.nodeType) {
                var f = a.lZ(d);
                f && (f.H = d,
                b.isEnabled() || f.Gb(!1),
                b.addChild(f),
                f.fb(d))
            } else
                d.nodeValue && "" != gvjs_kf(d.nodeValue) || c.removeChild(d);
            d = e
        }
}
gvjs_.lZ = function(a) {
    return gvjs_JD(a)
}
;
gvjs_.ln = function(a) {
    a = a.j();
    gvjs_Hz(a, !0, gvjs_sg);
    gvjs_y && (a.hideFocus = !0);
    var b = this.Qk();
    b && gvjs_VB(a, b)
}
;
gvjs_.Kg = function(a) {
    return a.j()
}
;
gvjs_.sa = function() {
    return "goog-container"
}
;
gvjs_.Rl = function(a) {
    var b = this.sa()
      , c = a.vi() == gvjs_S;
    c = [b, c ? b + "-horizontal" : b + "-vertical"];
    a.isEnabled() || c.push(b + gvjs_Gr);
    return c
}
;
function gvjs_8D(a, b, c) {
    gvjs_MC.call(this, c);
    this.F = b || gvjs_5D.Lc();
    this.tb = a || gvjs_U
}
gvjs_t(gvjs_8D, gvjs_MC);
gvjs_ = gvjs_8D.prototype;
gvjs_.b0 = null;
gvjs_.Gf = null;
gvjs_.F = null;
gvjs_.tb = null;
gvjs_.Db = !0;
gvjs_.kg = !0;
gvjs_.MY = !0;
gvjs_.fe = -1;
gvjs_.Pg = null;
gvjs_.Uq = !1;
gvjs_.oka = !1;
gvjs_.Eua = !0;
gvjs_.os = null;
gvjs_.Kg = function() {
    return this.b0 || this.F.Kg(this)
}
;
gvjs_.rP = function() {
    return this.Gf || (this.Gf = new gvjs_uD(this.Kg()))
}
;
gvjs_.Oa = function() {
    return this.F
}
;
gvjs_.AT = gvjs_n(60);
gvjs_.J = function() {
    this.H = this.F.J(this)
}
;
gvjs_.ib = function() {
    return this.F.ib(this.j())
}
;
gvjs_.Fh = function(a) {
    return this.F.Fh(a)
}
;
gvjs_.vf = function(a) {
    this.H = this.F.fb(this, a);
    a.style.display == gvjs_f && (this.Db = !1)
}
;
gvjs_.Nb = function() {
    gvjs_8D.G.Nb.call(this);
    gvjs_PC(this, function(c) {
        c.Bb && gvjs_9D(this, c)
    }, this);
    var a = this.j();
    this.F.ln(this);
    this.setVisible(this.Db, !0);
    var b = this.eA ? gvjs_4h : gvjs_Mz;
    this.hc().o(this, "enter", this.VZ).o(this, gvjs_3u, this.DI).o(this, gvjs_yx, this.c_).o(this, "open", this.Cqa).o(this, gvjs_Yt, this.OZ).o(a, b.ux, this.Cf).o(gvjs_5g(a), [b.wx, b.mB], this.Tpa).o(a, [b.ux, b.wx, b.mB, gvjs_ld, gvjs_kd, gvjs_3t], this.Hpa);
    this.eA && this.hc().o(a, gvjs_Ou, this.nS);
    this.Gq() && gvjs_$D(this, !0)
}
;
gvjs_.nS = function(a) {
    var b = a.target;
    b.releasePointerCapture && b.releasePointerCapture(a.pointerId)
}
;
function gvjs_$D(a, b) {
    var c = a.hc()
      , d = a.Kg();
    b ? c.o(d, gvjs_xu, a.Iv).o(d, gvjs_Yo, a.$y).o(a.rP(), gvjs_kv, a.gj) : c.Ab(d, gvjs_xu, a.Iv).Ab(d, gvjs_Yo, a.$y).Ab(a.rP(), gvjs_kv, a.gj)
}
gvjs_.Le = function() {
    this.Tg(-1);
    this.Pg && this.Pg.Kd(!1);
    this.Uq = !1;
    gvjs_8D.G.Le.call(this)
}
;
gvjs_.M = function() {
    gvjs_8D.G.M.call(this);
    this.Gf && (this.Gf.pa(),
    this.Gf = null);
    this.F = this.Pg = this.os = this.b0 = null
}
;
gvjs_.VZ = function() {
    return !0
}
;
gvjs_.DI = function(a) {
    var b = gvjs_QC(this, a.target);
    if (-1 < b && b != this.fe) {
        var c = gvjs_aE(this);
        c && c.ci(!1);
        this.fe = b;
        c = gvjs_aE(this);
        this.Uq && c.setActive(!0);
        this.Eua && this.Pg && c != this.Pg && (gvjs_ED(c, 64) ? c.Kd(!0) : this.Pg.Kd(!1))
    }
    b = this.j();
    null != a.target.j() && gvjs_WB(b, gvjs_Ts, a.target.j().id)
}
;
gvjs_.c_ = function(a) {
    a.target == gvjs_aE(this) && (this.fe = -1);
    this.j().removeAttribute(gvjs_ct)
}
;
gvjs_.Cqa = function(a) {
    (a = a.target) && a != this.Pg && a.getParent() == this && (this.Pg && this.Pg.Kd(!1),
    this.Pg = a)
}
;
gvjs_.OZ = function(a) {
    a.target == this.Pg && (this.Pg = null);
    var b = this.j()
      , c = a.target.j();
    b && gvjs_FD(a.target, 2) && c && gvjs_ZB(b, c)
}
;
gvjs_.Cf = function(a) {
    this.kg && (this.Uq = !0);
    var b = this.Kg();
    b && gvjs_Sx(b) ? b.focus() : a.preventDefault()
}
;
gvjs_.Tpa = function() {
    this.Uq = !1
}
;
gvjs_.Hpa = function(a) {
    var b = this.eA ? gvjs_4h : gvjs_Mz;
    a: {
        var c = a.target;
        if (this.os)
            for (var d = this.j(); c && c !== d; ) {
                var e = c.id;
                if (e in this.os) {
                    c = this.os[e];
                    break a
                }
                c = c.parentNode
            }
        c = null
    }
    if (c)
        switch (a.type) {
        case b.ux:
            c.Cf(a);
            break;
        case b.wx:
        case b.mB:
            c.Mo(a);
            break;
        case gvjs_ld:
            c.Lo(a);
            break;
        case gvjs_kd:
            c.PP(a);
            break;
        case gvjs_3t:
            c.CI(a)
        }
}
;
gvjs_.Iv = function() {}
;
gvjs_.$y = function() {
    this.Tg(-1);
    this.Uq = !1;
    this.Pg && this.Pg.Kd(!1)
}
;
gvjs_.gj = function(a) {
    return this.isEnabled() && this.isVisible() && (0 != this.ze() || this.b0) && this.Wj(a) ? (a.preventDefault(),
    a.stopPropagation(),
    !0) : !1
}
;
gvjs_.Wj = function(a) {
    var b = gvjs_aE(this);
    if (b && typeof b.gj == gvjs_d && b.gj(a) || this.Pg && this.Pg != b && typeof this.Pg.gj == gvjs_d && this.Pg.gj(a))
        return !0;
    if (a.shiftKey || a.ctrlKey || a.metaKey || a.altKey)
        return !1;
    switch (a.keyCode) {
    case 27:
        if (this.Gq())
            this.Kg().blur();
        else
            return !1;
        break;
    case 36:
        gvjs_bE(this);
        break;
    case 35:
        gvjs_rea(this);
        break;
    case 38:
        if (this.tb == gvjs_U)
            gvjs_cE(this);
        else
            return !1;
        break;
    case 37:
        if (this.tb == gvjs_S)
            this.gh() ? gvjs_dE(this) : gvjs_cE(this);
        else
            return !1;
        break;
    case 40:
        if (this.tb == gvjs_U)
            gvjs_dE(this);
        else
            return !1;
        break;
    case 39:
        if (this.tb == gvjs_S)
            this.gh() ? gvjs_cE(this) : gvjs_dE(this);
        else
            return !1;
        break;
    default:
        return !1
    }
    return !0
}
;
function gvjs_9D(a, b) {
    var c = b.j();
    c = c.id || (c.id = b.getId());
    a.os || (a.os = {});
    a.os[c] = b
}
gvjs_.addChild = function(a, b) {
    gvjs_8D.G.addChild.call(this, a, b)
}
;
gvjs_.zx = function(a, b, c) {
    a.ju |= 2;
    a.ju |= 64;
    !this.Gq() && this.oka || a.eg(32, !1);
    gvjs_MD(a, !1);
    var d = a.getParent() == this ? gvjs_QC(this, a) : -1;
    gvjs_8D.G.zx.call(this, a, b, c);
    a.Bb && this.Bb && gvjs_9D(this, a);
    a = d;
    -1 == a && (a = this.ze());
    a == this.fe ? this.fe = Math.min(this.ze() - 1, b) : a > this.fe && b <= this.fe ? this.fe++ : a < this.fe && b > this.fe && this.fe--
}
;
gvjs_.removeChild = function(a, b) {
    if (a = typeof a === gvjs_l ? this.CC(a) : a) {
        var c = gvjs_QC(this, a);
        -1 != c && (c == this.fe ? (a.ci(!1),
        this.fe = -1) : c < this.fe && this.fe--);
        (c = a.j()) && c.id && this.os && gvjs_Qy(this.os, c.id)
    }
    a = gvjs_8D.G.removeChild.call(this, a, b);
    gvjs_MD(a, !0);
    return a
}
;
gvjs_.vi = function() {
    return this.tb
}
;
gvjs_.setOrientation = function(a) {
    if (this.j())
        throw Error(gvjs_8r);
    this.tb = a
}
;
gvjs_.isVisible = function() {
    return this.Db
}
;
gvjs_.setVisible = function(a, b) {
    if (b || this.Db != a && this.dispatchEvent(a ? gvjs_Sw : gvjs_1u)) {
        this.Db = a;
        var c = this.j();
        c && (gvjs_6(c, a),
        this.Gq() && gvjs_6D(this.Kg(), this.kg && this.Db),
        b || this.dispatchEvent(this.Db ? "aftershow" : "afterhide"));
        return !0
    }
    return !1
}
;
gvjs_.isEnabled = function() {
    return this.kg
}
;
gvjs_.Gb = function(a) {
    this.kg != a && this.dispatchEvent(a ? gvjs_qu : gvjs_ju) && (a ? (this.kg = !0,
    gvjs_PC(this, function(b) {
        b.tha ? delete b.tha : b.Gb(!0)
    })) : (gvjs_PC(this, function(b) {
        b.isEnabled() ? b.Gb(!1) : b.tha = !0
    }),
    this.Uq = this.kg = !1),
    this.Gq() && gvjs_6D(this.Kg(), a && this.Db))
}
;
gvjs_.Gq = function() {
    return this.MY
}
;
gvjs_.jp = function(a) {
    a != this.MY && this.Bb && gvjs_$D(this, a);
    this.MY = a;
    this.kg && this.Db && gvjs_6D(this.Kg(), a)
}
;
gvjs_.Tg = function(a) {
    (a = this.Ye(a)) ? a.ci(!0) : -1 < this.fe && gvjs_aE(this).ci(!1)
}
;
gvjs_.ci = function(a) {
    this.Tg(gvjs_QC(this, a))
}
;
function gvjs_aE(a) {
    return a.Ye(a.fe)
}
function gvjs_bE(a) {
    gvjs_eE(a, function(b, c) {
        return (b + 1) % c
    }, a.ze() - 1)
}
function gvjs_rea(a) {
    gvjs_eE(a, function(b, c) {
        b--;
        return 0 > b ? c - 1 : b
    }, 0)
}
function gvjs_dE(a) {
    gvjs_eE(a, function(b, c) {
        return (b + 1) % c
    }, a.fe)
}
function gvjs_cE(a) {
    gvjs_eE(a, function(b, c) {
        b--;
        return 0 > b ? c - 1 : b
    }, a.fe)
}
function gvjs_eE(a, b, c) {
    c = 0 > c ? gvjs_QC(a, a.Pg) : c;
    var d = a.ze();
    c = b.call(a, c, d);
    for (var e = 0; e <= d; ) {
        var f = a.Ye(c);
        if (f && a.a8(f)) {
            a.N3(c);
            break
        }
        e++;
        c = b.call(a, c, d)
    }
}
gvjs_.a8 = function(a) {
    return a.isVisible() && a.isEnabled() && gvjs_ED(a, 2)
}
;
gvjs_.N3 = function(a) {
    this.Tg(a)
}
;
function gvjs_fE() {}
gvjs_t(gvjs_fE, gvjs_zD);
gvjs_le(gvjs_fE);
gvjs_fE.prototype.sa = function() {
    return gvjs_Ks
}
;
function gvjs_gE(a, b, c) {
    gvjs_LD.call(this, a, c || gvjs_fE.Lc(), b);
    this.eg(1, !1);
    this.eg(2, !1);
    this.eg(4, !1);
    this.eg(32, !1);
    this.K = 1
}
gvjs_t(gvjs_gE, gvjs_LD);
gvjs_HD(gvjs_Ks, function() {
    return new gvjs_gE(null)
});
function gvjs_hE() {}
gvjs_t(gvjs_hE, gvjs_zD);
gvjs_le(gvjs_hE);
gvjs_hE.prototype.J = function(a) {
    return a.wa().J(gvjs_b, this.sa())
}
;
gvjs_hE.prototype.fb = function(a, b) {
    b.id && a.lL(b.id);
    if ("HR" == b.tagName) {
        var c = b;
        b = this.J(a);
        gvjs_ih(b, c);
        gvjs_kh(c)
    } else
        gvjs_VC(b, this.sa());
    return b
}
;
gvjs_hE.prototype.setContent = function() {}
;
gvjs_hE.prototype.sa = function() {
    return gvjs_Ls
}
;
function gvjs_iE(a, b) {
    gvjs_LD.call(this, null, a || gvjs_hE.Lc(), b);
    this.eg(1, !1);
    this.eg(2, !1);
    this.eg(4, !1);
    this.eg(32, !1);
    this.K = 1
}
gvjs_t(gvjs_iE, gvjs_LD);
gvjs_iE.prototype.Nb = function() {
    gvjs_iE.G.Nb.call(this);
    var a = this.j();
    gvjs_VB(a, gvjs_Lw)
}
;
gvjs_HD(gvjs_Ls, function() {
    return new gvjs_iE
});
function gvjs_jE(a) {
    this.dN = a || "menu"
}
gvjs_t(gvjs_jE, gvjs_5D);
gvjs_le(gvjs_jE);
gvjs_ = gvjs_jE.prototype;
gvjs_.Fh = function(a) {
    return "UL" == a.tagName || gvjs_jE.G.Fh.call(this, a)
}
;
gvjs_.lZ = function(a) {
    return "HR" == a.tagName ? new gvjs_iE : gvjs_jE.G.lZ.call(this, a)
}
;
gvjs_.vs = function(a, b) {
    return gvjs_rh(a.j(), b)
}
;
gvjs_.sa = function() {
    return gvjs_Z
}
;
gvjs_.ln = function(a) {
    gvjs_jE.G.ln.call(this, a);
    a = a.j();
    gvjs_WB(a, gvjs_Yu, gvjs_Rd)
}
;
gvjs_HD(gvjs_Ls, function() {
    return new gvjs_iE
});
function gvjs_kE(a, b) {
    gvjs_8D.call(this, gvjs_U, b || gvjs_jE.Lc(), a);
    this.jp(!1)
}
gvjs_t(gvjs_kE, gvjs_8D);
gvjs_ = gvjs_kE.prototype;
gvjs_.kG = !0;
gvjs_.Z6 = !1;
gvjs_.sa = function() {
    return this.Oa().sa()
}
;
gvjs_.vs = function(a) {
    if (this.Oa().vs(this, a))
        return !0;
    for (var b = 0, c = this.ze(); b < c; b++) {
        var d = this.Ye(b);
        if (typeof d.vs == gvjs_d && d.vs(a))
            return !0
    }
    return !1
}
;
gvjs_.Bj = function(a) {
    this.addChild(a, !0)
}
;
gvjs_.Bu = function(a, b) {
    this.zx(a, b, !0)
}
;
gvjs_.removeItem = function(a) {
    (a = this.removeChild(a, !0)) && a.pa()
}
;
gvjs_.od = function(a) {
    return this.Ye(a)
}
;
gvjs_.bh = function() {
    return this.ze()
}
;
gvjs_.Qy = function() {
    var a = [];
    gvjs_PC(this, function(b) {
        a.push(b)
    });
    return a
}
;
gvjs_.setPosition = function(a, b) {
    var c = this.isVisible();
    c || gvjs_6(this.j(), !0);
    var d = this.j()
      , e = gvjs_vz(d);
    a instanceof gvjs_z && (b = a.y,
    a = a.x);
    gvjs_sz(d, d.offsetLeft + (a - e.x), d.offsetTop + (Number(b) - e.y));
    c || gvjs_6(this.j(), !1)
}
;
gvjs_.getPosition = function() {
    return this.isVisible() ? gvjs_vz(this.j()) : null
}
;
gvjs_.setVisible = function(a, b, c) {
    (b = gvjs_kE.G.setVisible.call(this, a, b)) && a && this.Bb && this.kG && this.Kg().focus();
    this.Nda = a && c && typeof c.clientX === gvjs_g ? new gvjs_z(c.clientX,c.clientY) : null;
    return b
}
;
gvjs_.VZ = function(a) {
    this.kG && this.Kg().focus();
    return gvjs_kE.G.VZ.call(this, a)
}
;
gvjs_.a8 = function(a) {
    return (this.Z6 || a.isEnabled()) && a.isVisible() && gvjs_ED(a, 2)
}
;
gvjs_.vf = function(a) {
    for (var b = this.Oa(), c = gvjs_zh(this.wa(), gvjs_b, b.sa() + gvjs_Er, a), d = c.length, e = 0; e < d; e++)
        gvjs_7D(b, this, c[e]);
    gvjs_kE.G.vf.call(this, a)
}
;
gvjs_.Wj = function(a) {
    var b = gvjs_kE.G.Wj.call(this, a);
    b || gvjs_PC(this, function(c) {
        !b && c.Soa && c.g1 == a.keyCode && (this.isEnabled() && this.ci(c),
        b = c.gj(a))
    }, this);
    return b
}
;
gvjs_.Tg = function(a) {
    gvjs_kE.G.Tg.call(this, a);
    (a = this.Ye(a)) && gvjs_Iz(a.j(), this.j())
}
;
function gvjs_lE() {}
gvjs_t(gvjs_lE, gvjs_2D);
gvjs_le(gvjs_lE);
gvjs_ = gvjs_lE.prototype;
gvjs_.J = function(a) {
    var b = this.Rl(a);
    b = a.wa().J(gvjs_b, gvjs_Is + b.join(" "), this.aO(a.getContent(), a.wa()));
    this.il(b, a.en());
    return b
}
;
gvjs_.Qk = function() {
    return gvjs_Bt
}
;
gvjs_.ib = function(a) {
    return a && a.firstChild && a.firstChild.firstChild
}
;
gvjs_.aO = function(a, b) {
    return b.J(gvjs_b, gvjs_Is + (this.sa() + gvjs_Jr), b.J(gvjs_b, gvjs_Is + (this.sa() + gvjs_Ir), a))
}
;
gvjs_.Fh = function(a) {
    return a.tagName == gvjs_b
}
;
gvjs_.fb = function(a, b) {
    gvjs_mE(b, !0);
    gvjs_mE(b, !1);
    a: {
        var c = a.wa().O$(b);
        var d = this.sa() + gvjs_Jr;
        if (c && gvjs_UC(c, d) && (c = a.wa().O$(c),
        d = this.sa() + gvjs_Ir,
        c && gvjs_UC(c, d))) {
            c = !0;
            break a
        }
        c = !1
    }
    c || b.appendChild(this.aO(b.childNodes, a.wa()));
    gvjs_WC(b, [gvjs_Y, this.sa()]);
    return gvjs_lE.G.fb.call(this, a, b)
}
;
gvjs_.sa = function() {
    return gvjs_Hs
}
;
function gvjs_mE(a, b) {
    if (a)
        for (var c = b ? a.firstChild : a.lastChild, d; c && c.parentNode == a; ) {
            d = b ? c.nextSibling : c.previousSibling;
            if (3 == c.nodeType) {
                var e = c.nodeValue;
                if ("" == gvjs_kf(e))
                    a.removeChild(c);
                else {
                    c.nodeValue = b ? e.replace(/^[\s\xa0]+/, "") : e.replace(/[\s\xa0]+$/, "");
                    break
                }
            } else
                break;
            c = d
        }
}
;function gvjs_nE() {}
gvjs_t(gvjs_nE, gvjs_lE);
gvjs_le(gvjs_nE);
gvjs_ = gvjs_nE.prototype;
gvjs_.ib = function(a) {
    return gvjs_nE.G.ib.call(this, a && a.firstChild)
}
;
gvjs_.fb = function(a, b) {
    var c = gvjs_gz("*", gvjs_Z, b)[0];
    if (c) {
        gvjs_6(c, !1);
        gvjs_5g(c).body.appendChild(c);
        var d = new gvjs_kE;
        d.fb(c);
        a.lp(d)
    }
    return gvjs_nE.G.fb.call(this, a, b)
}
;
gvjs_.aO = function(a, b) {
    return gvjs_nE.G.aO.call(this, [this.createCaption(a, b), this.cO(b)], b)
}
;
gvjs_.createCaption = function(a, b) {
    return gvjs_oE(a, this.sa(), b)
}
;
function gvjs_oE(a, b, c) {
    return c.J(gvjs_b, gvjs_Is + (b + gvjs_Dr), a)
}
gvjs_.cO = function(a) {
    return a.J(gvjs_b, gvjs_Is + (this.sa() + gvjs_Hr), "\u00a0")
}
;
gvjs_.sa = function() {
    return gvjs_Js
}
;
function gvjs_pE() {
    this.SW = []
}
gvjs_t(gvjs_pE, gvjs_UD);
gvjs_le(gvjs_pE);
gvjs_pE.prototype.J = function(a) {
    var b = gvjs_pE.G.J.call(this, a);
    gvjs_VC(b, gvjs_Ps);
    gvjs_qE(this, a, b);
    return b
}
;
gvjs_pE.prototype.fb = function(a, b) {
    b = gvjs_pE.G.fb.call(this, a, b);
    gvjs_VC(b, gvjs_Ps);
    gvjs_qE(this, a, b);
    var c = gvjs_gz(gvjs_b, gvjs_Z, b);
    if (c.length) {
        var d = new gvjs_kE(a.wa());
        c = c[0];
        gvjs_6(c, !1);
        a.wa().kc().body.appendChild(c);
        d.fb(c);
        a.lp(d, !0)
    }
    return b
}
;
gvjs_pE.prototype.setContent = function(a, b) {
    var c = this.ib(a)
      , d = c && c.lastChild;
    gvjs_pE.G.setContent.call(this, a, b);
    d && c.lastChild != d && gvjs_UC(d, gvjs_Qs) && c.appendChild(d)
}
;
gvjs_pE.prototype.ln = function(a) {
    gvjs_pE.G.ln.call(this, a);
    var b = a.ib()
      , c = gvjs_zh(a.wa(), gvjs_6a, gvjs_Qs, b)[0];
    gvjs_rE(a, c);
    c != b.lastChild && b.appendChild(c);
    a = a.j();
    gvjs_WB(a, gvjs_Yu, gvjs_Rd)
}
;
function gvjs_qE(a, b, c) {
    var d = b.wa().J(gvjs_6a);
    d.className = gvjs_Qs;
    gvjs_rE(b, d);
    a.ib(c).appendChild(d)
}
function gvjs_rE(a, b) {
    a.gh() ? (gvjs_VC(b, gvjs_Rs),
    gvjs_th(b, a.VM ? "\u25c4" : "\u25ba")) : (gvjs_XC(b, gvjs_Rs),
    gvjs_th(b, a.VM ? "\u25ba" : "\u25c4"))
}
;function gvjs_sE(a, b, c, d) {
    gvjs_ZD.call(this, a, b, c, d || gvjs_pE.Lc())
}
gvjs_t(gvjs_sE, gvjs_ZD);
gvjs_ = gvjs_sE.prototype;
gvjs_.kq = null;
gvjs_.g4 = null;
gvjs_.S0 = !1;
gvjs_.Ah = null;
gvjs_.UO = !1;
gvjs_.VM = !0;
gvjs_.msa = !1;
gvjs_.Nb = function() {
    gvjs_sE.G.Nb.call(this);
    this.hc().o(this.getParent(), gvjs_1u, this.Ida);
    this.Ah && gvjs_tE(this, this.Ah, !0)
}
;
gvjs_.Le = function() {
    this.hc().Ab(this.getParent(), gvjs_1u, this.Ida);
    this.Ah && (gvjs_tE(this, this.Ah, !1),
    this.UO || (this.Ah.Le(),
    gvjs_kh(this.Ah.j())));
    gvjs_sE.G.Le.call(this)
}
;
gvjs_.M = function() {
    this.Ah && !this.UO && this.Ah.pa();
    this.Ah = null;
    gvjs_sE.G.M.call(this)
}
;
gvjs_.ci = function(a) {
    gvjs_sE.G.ci.call(this, a);
    a || (this.kq && gvjs_ql(this.kq),
    this.kq = gvjs_pl(this.Hs, 218, this))
}
;
gvjs_.LT = function() {
    var a = this.getParent();
    a && gvjs_aE(a) == this && (gvjs_uE(this, !0),
    gvjs_vE(this))
}
;
gvjs_.Hs = function() {
    var a = this.Ah;
    a && a.getParent() == this && (gvjs_uE(this, !1),
    gvjs_PC(a, function(b) {
        typeof b.Hs == gvjs_d && b.Hs()
    }))
}
;
function gvjs_wE(a) {
    a.kq && gvjs_ql(a.kq);
    a.g4 && gvjs_ql(a.g4)
}
gvjs_.setVisible = function(a, b) {
    (a = gvjs_sE.G.setVisible.call(this, a, b)) && !this.isVisible() && this.Hs();
    return a
}
;
function gvjs_vE(a) {
    gvjs_PC(a.getParent(), function(b) {
        b != this && typeof b.Hs == gvjs_d && (b.Hs(),
        gvjs_wE(b))
    }, a)
}
gvjs_.gj = function(a) {
    var b = a.keyCode
      , c = this.gh() ? 37 : 39
      , d = this.gh() ? 39 : 37;
    if (!this.S0) {
        if (!this.isEnabled() || b != c && 13 != b && b != this.g1)
            return !1;
        this.LT();
        gvjs_bE(this.Td());
        gvjs_wE(this)
    } else if (!this.Td().gj(a))
        if (b == d)
            this.Hs();
        else
            return !1;
    a.preventDefault();
    return !0
}
;
gvjs_.jua = function() {
    this.Ah.getParent() == this && (gvjs_wE(this),
    this.GC().ci(this),
    gvjs_vE(this))
}
;
gvjs_.Ida = function(a) {
    a.target == this.GC() && (this.Hs(),
    gvjs_wE(this))
}
;
gvjs_.Lo = function(a) {
    this.isEnabled() && (gvjs_wE(this),
    this.g4 = gvjs_pl(this.LT, 218, this));
    gvjs_sE.G.Lo.call(this, a)
}
;
gvjs_.$h = function(a) {
    gvjs_wE(this);
    if (gvjs_ED(this, 8) || gvjs_ED(this, 16))
        return gvjs_sE.G.$h.call(this, a);
    this.LT();
    return !0
}
;
function gvjs_uE(a, b) {
    !b && a.Td() && a.Td().Tg(-1);
    a.dispatchEvent(gvjs_NC(64, b));
    var c = a.Td();
    b != a.S0 && gvjs_ZC(a.j(), "goog-submenu-open", b);
    if (b != c.isVisible() && (b && (c.Bb || c.R(),
    c.Tg(-1)),
    c.setVisible(b),
    b)) {
        c = new gvjs__D(a.j(),a.VM ? 12 : 8,a.msa);
        var d = a.Td()
          , e = d.j();
        d.isVisible() || (e.style.visibility = gvjs_0u,
        gvjs_6(e, !0));
        c.Mf(e, a.VM ? 8 : 12);
        d.isVisible() || (gvjs_6(e, !1),
        e.style.visibility = gvjs_Mx)
    }
    a.S0 = b
}
function gvjs_tE(a, b, c) {
    var d = a.hc();
    (c ? d.o : d.Ab).call(d, b, "enter", a.jua)
}
gvjs_.Bj = function(a) {
    this.Td().addChild(a, !0)
}
;
gvjs_.Bu = function(a, b) {
    this.Td().zx(a, b, !0)
}
;
gvjs_.removeItem = function(a) {
    (a = this.Td().removeChild(a, !0)) && a.pa()
}
;
gvjs_.od = function(a) {
    return this.Td().Ye(a)
}
;
gvjs_.bh = function() {
    return this.Td().ze()
}
;
gvjs_.Qy = function() {
    return this.Td().Qy()
}
;
gvjs_.Td = function() {
    this.Ah ? this.UO && this.Ah.getParent() != this && gvjs_OC(this.Ah, this) : this.lp(new gvjs_kE(this.wa()), !0);
    this.Ah.j() || this.Ah.J();
    return this.Ah
}
;
gvjs_.lp = function(a, b) {
    var c = this.Ah;
    a != c && (c && (this.Hs(),
    this.Bb && gvjs_tE(this, c, !1)),
    this.Ah = a,
    this.UO = !b,
    a && (gvjs_OC(a, this),
    a.setVisible(!1, !0),
    a.kG = !1,
    a.jp(!1),
    this.Bb && gvjs_tE(this, a, !0)))
}
;
gvjs_.vs = function(a) {
    return this.Td().vs(a)
}
;
gvjs_HD(gvjs_Ps, function() {
    return new gvjs_sE(null)
});
function gvjs_xE(a, b, c, d, e) {
    gvjs_4D.call(this, a, c || gvjs_nE.Lc(), d);
    this.eg(64, !0);
    this.lR = new gvjs_1D(null,9);
    b && this.lp(b);
    this.lta = null;
    this.Hc = new gvjs_IA(500);
    !gvjs_Ig && !gvjs_Jg || gvjs_Eg("533.17.9") || (this.iD = !0);
    this.Gla = !0;
    this.mta = e || gvjs_jE.Lc()
}
gvjs_t(gvjs_xE, gvjs_4D);
gvjs_ = gvjs_xE.prototype;
gvjs_.iD = !1;
gvjs_.Bva = !1;
gvjs_.kwa = !1;
gvjs_.Nb = function() {
    gvjs_xE.G.Nb.call(this);
    gvjs_yE(this, !0);
    this.la && gvjs_zE(this, this.la, !0);
    gvjs_WB(this.H, gvjs_Yu, !!this.la)
}
;
gvjs_.Le = function() {
    gvjs_xE.G.Le.call(this);
    gvjs_yE(this, !1);
    if (this.la) {
        this.Kd(!1);
        this.la.Le();
        gvjs_zE(this, this.la, !1);
        var a = this.la.j();
        a && gvjs_kh(a)
    }
}
;
gvjs_.M = function() {
    gvjs_xE.G.M.call(this);
    this.la && (this.la.pa(),
    delete this.la);
    delete this.cva;
    this.Hc.pa()
}
;
gvjs_.Cf = function(a) {
    gvjs_xE.G.Cf.call(this, a);
    this.ak() && (this.Kd(!gvjs_FD(this, 64), a),
    this.la && (this.la.Uq = gvjs_FD(this, 64)))
}
;
gvjs_.Mo = function(a) {
    gvjs_xE.G.Mo.call(this, a);
    this.la && !this.ak() && (this.la.Uq = !1)
}
;
gvjs_.$h = function() {
    this.setActive(!1);
    return !0
}
;
gvjs_.Rpa = function(a) {
    this.la && this.la.isVisible() && !this.vs(a.target) && this.Kd(!1)
}
;
gvjs_.vs = function(a) {
    return a && gvjs_rh(this.j(), a) || this.la && this.la.vs(a) || !1
}
;
gvjs_.Wj = function(a) {
    if (32 == a.keyCode) {
        if (a.preventDefault(),
        a.type != gvjs_mv)
            return !0
    } else if (a.type != gvjs_kv)
        return !1;
    if (this.la && this.la.isVisible()) {
        var b = 13 == a.keyCode || 32 == a.keyCode
          , c = this.la.gj(a);
        return c && this.la && this.la.Pg instanceof gvjs_sE || !(27 == a.keyCode || b && this.Gla) ? c : (this.Kd(!1),
        !0)
    }
    return 40 == a.keyCode || 38 == a.keyCode || 32 == a.keyCode || 13 == a.keyCode ? (this.Kd(!0, a),
    !0) : !1
}
;
gvjs_.az = function() {
    this.Kd(!1)
}
;
gvjs_.uqa = function() {
    this.ak() || this.Kd(!1)
}
;
gvjs_.$y = function(a) {
    this.iD || this.Kd(!1);
    gvjs_xE.G.$y.call(this, a)
}
;
gvjs_.Td = function() {
    this.la || this.lp(new gvjs_kE(this.wa(),this.mta));
    return this.la || null
}
;
gvjs_.lp = function(a) {
    var b = this.la;
    if (a != b && (b && (this.Kd(!1),
    this.Bb && gvjs_zE(this, b, !1),
    delete this.la),
    this.Bb && gvjs_WB(this.H, gvjs_Yu, !!a),
    a)) {
        this.la = a;
        gvjs_OC(a, this);
        a.setVisible(!1);
        var c = this.iD;
        (a.kG = c) && a.jp(!0);
        this.Bb && gvjs_zE(this, a, !0)
    }
    return b
}
;
gvjs_.Bj = function(a) {
    this.Td().addChild(a, !0)
}
;
gvjs_.Bu = function(a, b) {
    this.Td().zx(a, b, !0)
}
;
gvjs_.removeItem = function(a) {
    (a = this.Td().removeChild(a, !0)) && a.pa()
}
;
gvjs_.od = function(a) {
    return this.la ? this.la.Ye(a) : null
}
;
gvjs_.bh = function() {
    return this.la ? this.la.ze() : 0
}
;
gvjs_.setVisible = function(a, b) {
    (a = gvjs_xE.G.setVisible.call(this, a, b)) && !this.isVisible() && this.Kd(!1);
    return a
}
;
gvjs_.Gb = function(a) {
    gvjs_xE.G.Gb.call(this, a);
    this.isEnabled() || this.Kd(!1)
}
;
gvjs_.c4 = gvjs_n(62);
gvjs_.Ov = gvjs_n(63);
gvjs_.Kd = function(a, b) {
    gvjs_xE.G.Kd.call(this, a);
    if (this.la && gvjs_FD(this, 64) == a) {
        if (a) {
            if (!this.la.Bb)
                if (this.Bva) {
                    var c = gvjs_oh(this.j());
                    c ? this.la.sE(c.parentNode, c) : this.la.R(this.j().parentNode)
                } else
                    this.la.R();
            this.UU = gvjs_wz(this.j());
            this.S7 = gvjs_Ez(this.j());
            this.mS();
            c = !!b && (13 == b.keyCode || 32 == b.keyCode);
            b && (40 == b.keyCode || 38 == b.keyCode) || c && this.kwa ? gvjs_bE(this.la) : this.la.Tg(-1)
        } else {
            this.setActive(!1);
            this.la.Uq = !1;
            if (c = this.j())
                gvjs_WB(c, gvjs_Ts, ""),
                gvjs_WB(c, "owns", "");
            null != this.bS && (this.bS = void 0,
            (c = this.la.j()) && gvjs_Cz(c, "", ""))
        }
        this.la.setVisible(a, !1, b);
        this.xf || (b = this.hc(),
        c = a ? b.o : b.Ab,
        c.call(b, this.wa().kc(), gvjs_gd, this.Rpa, !0),
        this.iD && c.call(b, this.la, gvjs_Yo, this.uqa),
        c.call(b, this.Hc, gvjs_dx, this.Cua),
        a ? this.Hc.start() : this.Hc.stop())
    }
    this.la && this.la.j() && this.la.H.removeAttribute(gvjs_dt)
}
;
gvjs_.mS = function() {
    if (this.la.Bb) {
        var a = this.cva || this.j()
          , b = this.lR;
        this.lR.element = a;
        a = this.la.j();
        this.la.isVisible() || (a.style.visibility = gvjs_0u,
        gvjs_6(a, !0));
        !this.bS && this.lR.Qoa && this.lR.MQ & 32 && (this.bS = gvjs_Dz(a));
        b.Mf(a, b.lH ^ 1, this.lta, this.bS);
        this.la.isVisible() || (gvjs_6(a, !1),
        a.style.visibility = gvjs_Mx)
    }
}
;
gvjs_.Cua = function() {
    var a = gvjs_Ez(this.j()), b = gvjs_wz(this.j()), c;
    (c = !gvjs_nz(this.S7, a)) || (c = this.UU,
    c = !(c == b || c && b && c.top == b.top && c.right == b.right && c.bottom == b.bottom && c.left == b.left));
    c && (this.la.Bb && b && this.UU && b.La() < this.UU.La() && (c = this.la.j(),
    this.la.isVisible() || (c.style.visibility = gvjs_0u,
    gvjs_6(c, !0)),
    gvjs_sz(c, new gvjs_z(0,0))),
    this.S7 = a,
    this.UU = b,
    this.mS())
}
;
function gvjs_zE(a, b, c) {
    var d = a.hc();
    c = c ? d.o : d.Ab;
    c.call(d, b, gvjs_Ss, a.az);
    c.call(d, b, gvjs_Yt, a.OZ);
    c.call(d, b, gvjs_3u, a.DI);
    c.call(d, b, gvjs_yx, a.c_)
}
function gvjs_yE(a, b) {
    var c = a.hc();
    (b ? c.o : c.Ab).call(c, a.j(), gvjs_lv, a.iqa)
}
gvjs_.DI = function(a) {
    (a = a.target.j()) && gvjs_AE(this, a)
}
;
gvjs_.iqa = function(a) {
    gvjs_ED(this, 32) && this.Kg() && this.la && this.la.isVisible() && a.stopPropagation()
}
;
gvjs_.c_ = function() {
    if (!gvjs_aE(this.la)) {
        var a = this.j();
        gvjs_WB(a, gvjs_Ts, "");
        gvjs_WB(a, "owns", "")
    }
}
;
gvjs_.OZ = function(a) {
    if (gvjs_FD(this, 64) && a.target instanceof gvjs_ZD) {
        a = a.target;
        var b = a.j();
        a.isVisible() && gvjs_FD(a, 2) && null != b && gvjs_AE(this, b)
    }
}
;
function gvjs_AE(a, b) {
    a = a.j();
    b = gvjs_YB(b) || b;
    if (!b.id) {
        var c = gvjs_KC.Lc();
        b.id = gvjs_LC(c)
    }
    gvjs_ZB(a, b);
    gvjs_WB(a, "owns", b.id)
}
gvjs_HD(gvjs_Js, function() {
    return new gvjs_xE(null)
});
function gvjs_BE(a) {
    gvjs_H.call(this);
    this.Iq = [];
    gvjs_CE(this, a)
}
gvjs_t(gvjs_BE, gvjs_H);
gvjs_ = gvjs_BE.prototype;
gvjs_.Wt = null;
gvjs_.bT = null;
gvjs_.bh = function() {
    return this.Iq.length
}
;
gvjs_.od = function(a) {
    return this.Iq[a] || null
}
;
function gvjs_CE(a, b) {
    b && (b.forEach(function(c) {
        this.BE(c, !1)
    }, a),
    gvjs_Me(a.Iq, b))
}
gvjs_.Bj = function(a) {
    this.Bu(a, this.bh())
}
;
gvjs_.Bu = function(a, b) {
    a && (this.BE(a, !1),
    gvjs_fq(this.Iq, a, b))
}
;
gvjs_.removeItem = function(a) {
    a && gvjs_Ie(this.Iq, a) && a == this.Wt && (this.Wt = null,
    this.dispatchEvent(gvjs_k))
}
;
gvjs_.Be = function() {
    return this.Wt
}
;
gvjs_.Qy = function() {
    return gvjs_Le(this.Iq)
}
;
gvjs_.gl = function(a) {
    a != this.Wt && (this.BE(this.Wt, !1),
    this.Wt = a,
    this.BE(a, !0));
    this.dispatchEvent(gvjs_k)
}
;
gvjs_.Vl = function() {
    var a = this.Wt;
    return a ? this.Iq.indexOf(a) : -1
}
;
gvjs_.rk = function(a) {
    this.gl(this.od(a))
}
;
gvjs_.clear = function() {
    gvjs_Fy(this.Iq);
    this.Wt = null
}
;
gvjs_.M = function() {
    gvjs_BE.G.M.call(this);
    delete this.Iq;
    this.Wt = null
}
;
gvjs_.BE = function(a, b) {
    a && (typeof this.bT == gvjs_d ? this.bT(a, b) : typeof a.qp == gvjs_d && a.qp(b))
}
;
function gvjs_DE(a, b, c, d, e) {
    gvjs_xE.call(this, a, b, c, d, e || new gvjs_jE("listbox"));
    this.rO = this.getContent();
    this.A_ = null;
    this.R3("listbox")
}
gvjs_t(gvjs_DE, gvjs_xE);
gvjs_ = gvjs_DE.prototype;
gvjs_.Ca = null;
gvjs_.Nb = function() {
    gvjs_DE.G.Nb.call(this);
    gvjs_EE(this);
    gvjs_FE(this)
}
;
gvjs_.vf = function(a) {
    gvjs_DE.G.vf.call(this, a);
    (a = this.bj()) ? (this.rO = a,
    gvjs_EE(this)) : this.Be() || this.rk(0)
}
;
gvjs_.M = function() {
    gvjs_DE.G.M.call(this);
    this.Ca && (this.Ca.pa(),
    this.Ca = null);
    this.rO = null
}
;
gvjs_.az = function(a) {
    this.gl(a.target);
    gvjs_DE.G.az.call(this, a);
    a.stopPropagation();
    this.dispatchEvent(gvjs_Ss)
}
;
gvjs_.b_ = function() {
    var a = this.Be();
    gvjs_DE.G.Wa.call(this, a && a.getValue());
    gvjs_EE(this)
}
;
gvjs_.lp = function(a) {
    var b = gvjs_DE.G.lp.call(this, a);
    a != b && (this.Ca && this.Ca.clear(),
    a && (this.Ca ? gvjs_PC(a, function(c) {
        gvjs_GE(c);
        this.Ca.Bj(c)
    }, this) : gvjs_HE(this, a)));
    return b
}
;
gvjs_.Bj = function(a) {
    gvjs_GE(a);
    gvjs_DE.G.Bj.call(this, a);
    this.Ca ? this.Ca.Bj(a) : gvjs_HE(this, this.Td());
    gvjs_IE(this)
}
;
gvjs_.Bu = function(a, b) {
    gvjs_GE(a);
    gvjs_DE.G.Bu.call(this, a, b);
    this.Ca ? this.Ca.Bu(a, b) : gvjs_HE(this, this.Td())
}
;
gvjs_.removeItem = function(a) {
    gvjs_DE.G.removeItem.call(this, a);
    this.Ca && this.Ca.removeItem(a)
}
;
gvjs_.gl = function(a) {
    if (this.Ca) {
        var b = this.Be();
        this.Ca.gl(a);
        a != b && this.dispatchEvent(gvjs_Kt)
    }
}
;
gvjs_.rk = function(a) {
    this.Ca && this.gl(this.Ca.od(a))
}
;
gvjs_.Wa = function(a) {
    if (null != a && this.Ca)
        for (var b = 0, c; c = this.Ca.od(b); b++)
            if (c && typeof c.getValue == gvjs_d && c.getValue() == a) {
                this.gl(c);
                return
            }
    this.gl(null)
}
;
gvjs_.getValue = function() {
    var a = this.Be();
    return a ? a.getValue() : null
}
;
gvjs_.Be = function() {
    return this.Ca ? this.Ca.Be() : null
}
;
gvjs_.Vl = function() {
    return this.Ca ? this.Ca.Vl() : -1
}
;
function gvjs_HE(a, b) {
    a.Ca = new gvjs_BE;
    b && gvjs_PC(b, function(c) {
        gvjs_GE(c);
        this.Ca.Bj(c)
    }, a);
    gvjs_FE(a)
}
function gvjs_FE(a) {
    a.Ca && a.hc().o(a.Ca, gvjs_k, a.b_)
}
function gvjs_EE(a) {
    var b = a.Be();
    a.setContent(b ? b.bj() : a.rO);
    var c = a.Oa().ib(a.j());
    c && a.wa().O_(c) && (null == a.A_ && (a.A_ = gvjs__B(c)),
    b = b ? b.j() : null,
    gvjs_0B(c, b ? gvjs__B(b) : a.A_),
    gvjs_IE(a))
}
function gvjs_IE(a) {
    var b = a.Oa();
    if (b && (b = b.ib(a.j()))) {
        var c = a.H;
        b.id || (b.id = gvjs_LC(gvjs_KC.Lc()));
        gvjs_VB(b, "option");
        gvjs_WB(b, gvjs_Iw, !0);
        gvjs_WB(c, gvjs_Ts, b.id);
        a.Ca && (c = a.Ca.Qy(),
        gvjs_WB(b, "setsize", gvjs_JE(c)),
        a = a.Ca.Vl(),
        gvjs_WB(b, "posinset", 0 <= a ? gvjs_JE(c.slice(0, a + 1)) : 0))
    }
}
function gvjs_JE(a) {
    return a.filter(function(b) {
        return b instanceof gvjs_ZD
    }).length
}
function gvjs_GE(a) {
    a.R3(a instanceof gvjs_ZD ? "option" : gvjs_Lw)
}
gvjs_.Kd = function(a, b) {
    gvjs_DE.G.Kd.call(this, a, b);
    gvjs_FD(this, 64) ? this.Td().Tg(this.Vl()) : gvjs_IE(this)
}
;
gvjs_HD(gvjs_Os, function() {
    return new gvjs_DE(null)
});
function gvjs_KE(a, b) {
    this.D = gvjs_Oh();
    this.ma = a;
    this.Z7 = [];
    this.Mj(b)
}
function gvjs_LE(a, b) {
    var c = gvjs_Oh()
      , d = gvjs_9f
      , e = null;
    switch (a) {
    case 2:
        var f = new gvjs_fD("google-visualization-toolbar-small-dialog");
        e = gvjs_sw + f.getId();
        d = gvjs_$f(gvjs_5f(gvjs_Ob, {
            "class": gvjs_Mu
        }, gvjs_9r), gvjs_bg, gvjs_5f("pre", {}, gvjs_5f(gvjs_Ob, {
            id: e
        }, b.message)));
        break;
    case 3:
        f = new gvjs_fD("google-visualization-toolbar-big-dialog"),
        d = gvjs_$f(gvjs_5f(gvjs_Ob, {
            "class": gvjs_Mu
        }, gvjs_9r), gvjs_bg, gvjs_5f(gvjs_Ob, {}, gvjs_5f("pre", {}, b.message)))
    }
    gvjs_jD(f, d);
    a = f;
    gvjs_kD(a);
    gvjs_th(a.tk, "Google Visualization");
    a = f;
    gvjs_kD(a);
    gvjs_hh(a.Dh);
    f.setVisible(!0);
    e && (c = f = c.j(e),
    e = 0,
    a = 1,
    b = new gvjs_IC,
    b.kj = gvjs_fea(c, e, f, a),
    gvjs_ph(c) && !gvjs_fh(c) && (d = c.parentNode,
    e = Array.prototype.indexOf.call(d.childNodes, c),
    c = d),
    gvjs_ph(f) && !gvjs_fh(f) && (d = f.parentNode,
    a = Array.prototype.indexOf.call(d.childNodes, f),
    f = d),
    b.kj ? (b.sd = f,
    b.td = a,
    b.fd = c,
    b.Ad = e) : (b.sd = c,
    b.td = e,
    b.fd = f,
    b.Ad = a),
    b.select())
}
gvjs_KE.prototype.Mj = function(a) {
    a = a || [];
    var b = this.ma
      , c = this.D;
    c.qc(b);
    if (!b)
        throw Error(gvjs_za);
    var d = c.J(gvjs_6a, null)
      , e = [c.J(gvjs_6a, null, "Chart options")];
    this.zE = new gvjs_DE(e);
    if (a)
        for (e = 0; e < a.length; e++) {
            var f = null;
            f = a[e];
            var g = f.datasource
              , h = f.gadget
              , k = f.userprefs
              , l = f.visualization
              , m = f["package"]
              , n = f.style || "width: 700px; height: 500px;";
            switch (f.type) {
            case "csv":
                f = gvjs_ME(this, e, gvjs_re(function(p) {
                    gvjs_Xy((new gvjs_Xm(p)).Ld("tqx", "out:csv;").toString(), window, gvjs_9e(gvjs_ds))
                }, g), "Export data as CSV");
                break;
            case "htmlcode":
                f = gvjs_ME(this, e, gvjs_re(function(p, q) {
                    p = '<iframe style="' + n + '" src="http://www.google.com/ig/ifr?url=' + encodeURIComponent(p) + gvjs_Cr + encodeURIComponent(q) + gvjs_NE(k) + '" />';
                    gvjs_LE(2, {
                        message: p
                    })
                }, h, g), "Publish to web page");
                break;
            case "jscode":
                f = gvjs_ME(this, e, gvjs_re(function(p, q, r) {
                    p = '<html>\n <head>\n  <title>Google Visualization API</title>\n  <script type="text/javascript" src="https://www.google.com/jsapi">\x3c/script>\n  <script type="text/javascript">\n   google.load(\'visualization\', \'1\', {packages: [\'' + encodeURIComponent(q) + "']});\n\n   function drawVisualization() {\n    new google.visualization.Query('" + p + "').send(\n     function(response) {\n      new " + encodeURIComponent(r) + '(\n       document.getElementById(\'visualization\')).\n        draw(response.getDataTable(), null);\n      });\n   }\n\n   google.setOnLoadCallback(drawVisualization);\n  \x3c/script>\n </head>\n <body>\n  <div id="visualization" style="width: 500px; height: 500px;"></div>\n </body>\n</html>';
                    gvjs_LE(3, {
                        message: p
                    })
                }, g, m, l), "Javascript code");
                break;
            case gvjs_av:
                f = gvjs_ME(this, e, gvjs_re(function(p) {
                    gvjs_Xy((new gvjs_Xm(p)).Ld("tqx", "out:html;").toString(), window, gvjs_9e(gvjs_ds))
                }, g), "Export data as HTML");
                break;
            case "igoogle":
                f = gvjs_ME(this, e, gvjs_re(function(p, q, r) {
                    gvjs_Xy("http://www.google.com/ig/adde?moduleurl=" + encodeURIComponent(p) + gvjs_Cr + encodeURIComponent(q) + gvjs_NE(r))
                }, h, g, k), "Add to iGoogle");
                break;
            default:
                throw Error("No such toolbar component as: " + f.toSource());
            }
            f && this.zE.Bj(f)
        }
    gvjs_G(this.zE, gvjs_Ss, gvjs_s(this.Xqa, this));
    this.zE.R(d);
    c.appendChild(b, d)
}
;
gvjs_KE.prototype.Xqa = function() {
    var a = this.zE.Vl();
    this.Z7[a]();
    this.zE.rk(-1)
}
;
function gvjs_ME(a, b, c, d) {
    d = new gvjs_ZD(d);
    a.Z7[b] = c;
    return d
}
function gvjs_NE(a) {
    if (!a)
        return "";
    var b = "", c;
    for (c in a)
        b += "&up_" + c + "=" + encodeURIComponent(a[c]);
    return b
}
gvjs_KE.prototype.zE = null;
function gvjs_OE() {}
gvjs_t(gvjs_OE, gvjs_zD);
gvjs_le(gvjs_OE);
gvjs_OE.prototype.J = function(a) {
    var b = a.wa().J(gvjs_6a, this.Rl(a).join(" "));
    a = a.jZ();
    gvjs_PE(this, b, a);
    return b
}
;
gvjs_OE.prototype.fb = function(a, b) {
    b = gvjs_OE.G.fb.call(this, a, b);
    var c = gvjs_SC(b)
      , d = !1;
    gvjs_He(c, gvjs_QE(this, null)) ? d = null : gvjs_He(c, gvjs_QE(this, !0)) ? d = !0 : gvjs_He(c, gvjs_QE(this, !1)) && (d = !1);
    a.ns = d;
    gvjs_WB(b, gvjs_Vt, null == d ? "mixed" : 1 == d ? gvjs_Rd : gvjs_Sb);
    return b
}
;
gvjs_OE.prototype.Qk = function() {
    return gvjs_Ut
}
;
function gvjs_PE(a, b, c) {
    if (b) {
        var d = gvjs_QE(a, c);
        gvjs_UC(b, d) || (gvjs_w(gvjs_sea, function(e) {
            e = gvjs_QE(this, e);
            gvjs_ZC(b, e, e == d)
        }, a),
        gvjs_WB(b, gvjs_Vt, null == c ? "mixed" : 1 == c ? gvjs_Rd : gvjs_Sb))
    }
}
gvjs_OE.prototype.sa = function() {
    return gvjs_Fs
}
;
function gvjs_QE(a, b) {
    a = a.sa();
    if (1 == b)
        return a + "-checked";
    if (0 == b)
        return a + "-unchecked";
    if (null == b)
        return a + "-undetermined";
    throw Error("Invalid checkbox state: " + b);
}
;function gvjs_RE(a, b, c) {
    c = c || gvjs_OE.Lc();
    gvjs_LD.call(this, null, c, b);
    this.ns = void 0 !== a ? a : !1
}
gvjs_t(gvjs_RE, gvjs_LD);
var gvjs_sea = {
    Rza: !0,
    QBa: !1,
    RBa: null
};
gvjs_ = gvjs_RE.prototype;
gvjs_.Qb = null;
gvjs_.jZ = function() {
    return this.ns
}
;
gvjs_.nn = function() {
    return 1 == this.ns
}
;
gvjs_.bi = function(a) {
    a != this.ns && (this.ns = a,
    gvjs_PE(this.Oa(), this.j(), this.ns))
}
;
gvjs_.In = function(a) {
    if (this.Bb) {
        var b = gvjs_FD(this, 32);
        this.Le();
        this.Qb = a;
        this.Nb();
        b && this.H.focus()
    } else
        this.Qb = a
}
;
gvjs_.toggle = function() {
    this.bi(this.ns ? !1 : !0)
}
;
gvjs_.Nb = function() {
    gvjs_RE.G.Nb.call(this);
    if (this.OP) {
        var a = this.hc();
        this.Qb && a.o(this.Qb, gvjs_Wt, this.NZ).o(this.Qb, gvjs_ld, this.Lo).o(this.Qb, gvjs_kd, this.PP).o(this.Qb, gvjs_gd, this.Cf).o(this.Qb, gvjs_md, this.Mo);
        a.o(this.j(), gvjs_Wt, this.NZ)
    }
    a = this.H;
    this.Qb && a != this.Qb && gvjs_jf(gvjs__B(a)) && (this.Qb.id || (this.Qb.id = this.getId() + ".lbl"),
    gvjs_WB(a, gvjs_pv, this.Qb.id))
}
;
gvjs_.NZ = function(a) {
    a.stopPropagation();
    var b = this.ns ? "uncheck" : "check";
    this.isEnabled() && !a.target.href && this.dispatchEvent(b) && (a.preventDefault(),
    this.toggle(),
    this.dispatchEvent(gvjs_Kt))
}
;
gvjs_.Wj = function(a) {
    32 == a.keyCode && (this.$h(a),
    this.NZ(a));
    return !1
}
;
gvjs_HD(gvjs_Fs, function() {
    return new gvjs_RE
});
function gvjs_SE(a, b, c) {
    gvjs_F.call(this);
    this.Bt = a;
    this.Zv = b || 0;
    this.pd = c;
    this.KG = gvjs_s(this.gC, this)
}
gvjs_t(gvjs_SE, gvjs_F);
gvjs_ = gvjs_SE.prototype;
gvjs_.ac = 0;
gvjs_.M = function() {
    gvjs_SE.G.M.call(this);
    this.stop();
    delete this.Bt;
    delete this.pd
}
;
gvjs_.start = function(a) {
    this.stop();
    this.ac = gvjs_pl(this.KG, void 0 !== a ? a : this.Zv)
}
;
gvjs_.stop = function() {
    this.ak() && gvjs_ql(this.ac);
    this.ac = 0
}
;
gvjs_.fI = gvjs_n(64);
gvjs_.ak = function() {
    return 0 != this.ac
}
;
gvjs_.gC = function() {
    this.ac = 0;
    this.Bt && this.Bt.call(this.pd)
}
;
function gvjs_TE(a, b) {
    gvjs_H.call(this);
    this.H = a;
    a = gvjs_ph(this.H) ? this.H : this.H ? this.H.body : null;
    this.AQ = !!a && gvjs_Gz(a);
    this.mca = gvjs_G(this.H, gvjs_sg ? "DOMMouseScroll" : gvjs_Wv, this, b)
}
gvjs_t(gvjs_TE, gvjs_H);
gvjs_TE.prototype.handleEvent = function(a) {
    var b = 0
      , c = 0
      , d = a.$i;
    d.type == gvjs_Wv ? (a = gvjs_UE(-d.wheelDelta),
    void 0 !== d.wheelDeltaX ? (b = gvjs_UE(-d.wheelDeltaX),
    c = gvjs_UE(-d.wheelDeltaY)) : c = a) : (a = d.detail,
    100 < a ? a = 3 : -100 > a && (a = -3),
    void 0 !== d.axis && d.axis === d.HORIZONTAL_AXIS ? b = a : c = a);
    typeof this.Eca === gvjs_g && (b = gvjs_0g(b, -this.Eca, this.Eca));
    typeof this.Fca === gvjs_g && (c = gvjs_0g(c, -this.Fca, this.Fca));
    this.AQ && (b = -b);
    b = new gvjs_VE(a,d,b,c);
    this.dispatchEvent(b)
}
;
function gvjs_UE(a) {
    return gvjs_tg && (gvjs_ug || gvjs_wg) && 0 != a % 40 ? a : a / 40
}
gvjs_TE.prototype.M = function() {
    gvjs_TE.G.M.call(this);
    gvjs_ki(this.mca);
    this.mca = null
}
;
function gvjs_VE(a, b, c, d) {
    gvjs_5h.call(this, b);
    this.type = gvjs_Wv;
    this.detail = a;
    this.deltaX = c;
    this.deltaY = d
}
gvjs_t(gvjs_VE, gvjs_5h);
var gvjs_WE = {}
  , gvjs_XE = null;
function gvjs_YE(a) {
    a = gvjs_pe(a);
    delete gvjs_WE[a];
    gvjs_Py(gvjs_WE) && gvjs_XE && gvjs_XE.stop()
}
function gvjs_ZE() {
    gvjs_XE || (gvjs_XE = new gvjs_SE(function() {
        gvjs_tea()
    }
    ,20));
    var a = gvjs_XE;
    a.ak() || a.start()
}
function gvjs_tea() {
    var a = gvjs_se();
    gvjs_w(gvjs_WE, function(b) {
        gvjs__E(b, a)
    });
    gvjs_Py(gvjs_WE) || gvjs_ZE()
}
;function gvjs_0E() {
    gvjs_H.call(this);
    this.K = 0;
    this.endTime = this.startTime = null
}
gvjs_t(gvjs_0E, gvjs_H);
gvjs_ = gvjs_0E.prototype;
gvjs_.So = function() {
    return 1 == this.K
}
;
gvjs_.Ef = function() {
    return 0 == this.K
}
;
gvjs_.jK = function() {
    this.Jh("begin")
}
;
gvjs_.Xz = function() {
    this.Jh(gvjs_R)
}
;
gvjs_.Jh = function(a) {
    this.dispatchEvent(a)
}
;
function gvjs_1E(a, b, c, d) {
    gvjs_0E.call(this);
    if (!Array.isArray(a) || !Array.isArray(b))
        throw Error("Start and end parameters must be arrays");
    if (a.length != b.length)
        throw Error("Start and end points must be the same length");
    this.wp = a;
    this.YH = b;
    this.duration = c;
    this.N6 = d;
    this.coords = [];
    this.bB = !1;
    this.progress = 0
}
gvjs_t(gvjs_1E, gvjs_0E);
gvjs_ = gvjs_1E.prototype;
gvjs_.pq = gvjs_n(57);
gvjs_.play = function(a) {
    if (a || this.Ef())
        this.progress = 0,
        this.coords = this.wp;
    else if (this.So())
        return !1;
    gvjs_YE(this);
    this.startTime = a = gvjs_se();
    -1 == this.K && (this.startTime -= this.duration * this.progress);
    this.endTime = this.startTime + this.duration;
    this.progress || this.jK();
    this.Jh("play");
    -1 == this.K && this.Jh("resume");
    this.K = 1;
    var b = gvjs_pe(this);
    b in gvjs_WE || (gvjs_WE[b] = this);
    gvjs_ZE();
    gvjs__E(this, a);
    return !0
}
;
gvjs_.stop = function(a) {
    gvjs_YE(this);
    this.K = 0;
    a && (this.progress = 1);
    gvjs_2E(this, this.progress);
    this.Jh(gvjs__p);
    this.Xz()
}
;
gvjs_.pause = function() {
    this.So() && (gvjs_YE(this),
    this.K = -1,
    this.Jh("pause"))
}
;
gvjs_.M = function() {
    this.Ef() || this.stop(!1);
    this.Jh("destroy");
    gvjs_1E.G.M.call(this)
}
;
gvjs_.destroy = function() {
    this.pa()
}
;
function gvjs__E(a, b) {
    b < a.startTime && (a.endTime = b + a.endTime - a.startTime,
    a.startTime = b);
    a.progress = (b - a.startTime) / (a.endTime - a.startTime);
    1 < a.progress && (a.progress = 1);
    gvjs_2E(a, a.progress);
    1 == a.progress ? (a.K = 0,
    gvjs_YE(a),
    a.Jh(gvjs_vu),
    a.Xz()) : a.So() && a.M1()
}
function gvjs_2E(a, b) {
    typeof a.N6 === gvjs_d && (b = a.N6(b));
    a.coords = Array(a.wp.length);
    for (var c = 0; c < a.wp.length; c++)
        a.coords[c] = (a.YH[c] - a.wp[c]) * b + a.wp[c]
}
gvjs_.M1 = function() {
    this.Jh("animate")
}
;
gvjs_.Jh = function(a) {
    this.dispatchEvent(new gvjs_3E(a,this))
}
;
function gvjs_3E(a, b) {
    gvjs_1h.call(this, a);
    this.coords = b.coords;
    this.x = b.coords[0];
    this.y = b.coords[1];
    this.z = b.coords[2];
    this.duration = b.duration;
    this.progress = b.progress;
    this.state = b.K
}
gvjs_t(gvjs_3E, gvjs_1h);
gvjs_q("google.visualization.drawToolbar", function(a, b) {
    new gvjs_KE(a,b)
}, void 0);
function gvjs_4E(a) {
    return a.join("#")
}
var gvjs_5E = ["minorgridline", "gridline", gvjs_at, gvjs_Jt, gvjs_5w, gvjs_wb, "pathinterval", gvjs_Xo, gvjs_iv, gvjs_e, gvjs_Ct, gvjs_yt, gvjs_Zs, gvjs_ow, gvjs_Np, gvjs_fx, "axistick", "axistitle", gvjs_$s, gvjs_rv, gvjs_Av, gvjs_zv, "colorbar", gvjs_Pd, gvjs_Ss];
function gvjs_6E(a, b, c, d, e) {
    this.iq = b;
    this.JB = e;
    a = gvjs_7E(this, a);
    this.ny = (d - c) / (gvjs_7E(this, b) - a);
    this.YK = this.ny * a - c
}
gvjs_6E.prototype.Ya = function(a) {
    return gvjs_7E(this, a) * this.ny - this.YK
}
;
gvjs_6E.prototype.Ae = function(a) {
    a: switch (a = (a + this.YK) / this.ny,
    this.JB) {
    case 0:
        a = Math.pow(Math.E, a);
        break a;
    case 1:
        break a;
    default:
        a = Math.pow(a * this.JB + 1, 1 / this.JB)
    }
    return isFinite(a) ? a : this.iq
}
;
function gvjs_7E(a, b) {
    switch (a.JB) {
    case 0:
        return Math.log(b);
    case 1:
        return b;
    default:
        return (Math.pow(b, a.JB) - 1) / a.JB
    }
}
;function gvjs_8E(a, b) {
    return 0 > b ? a / Math.pow(10, -b) : a * Math.pow(10, b)
}
function gvjs_9E(a) {
    return Math.floor(.4342944819032518 * Math.log(a))
}
function gvjs_$E(a) {
    return Math.ceil(.4342944819032518 * Math.log(a))
}
;function gvjs_aF(a, b, c, d, e, f) {
    this.iy = a;
    this.zH = b;
    this.ZK = c;
    this.XK = d;
    this.Ku = e;
    this.U9 = f;
    this.ym = this.iy == this.zH ? this.iy / 2 : isNaN(this.U9) ? gvjs_8E(1, gvjs_9E(this.zH - this.iy)) / 1E3 : this.U9 / 2;
    a >= this.ym ? (this.Zk = new gvjs_6E(a,b,c,d,this.Ku),
    this.Ki = Math.round(this.Zk.Ya(this.ym))) : b <= -this.ym ? (this.Zk = new gvjs_6E(-b,-a,d,c,this.Ku),
    this.Ki = Math.round(this.Zk.Ya(this.ym)),
    f = 2 * this.Ki - d,
    e = 2 * this.Ki - c,
    this.Zk = new gvjs_6E(-b,-a,f,e,this.Ku)) : a >= -this.ym ? (this.Ki = Math.round(c),
    this.Zk = new gvjs_6E(this.ym,b,this.Ki,d,this.Ku)) : b <= this.ym ? (this.Ki = Math.round(d),
    e = 2 * this.Ki - c,
    this.Zk = new gvjs_6E(this.ym,-a,this.Ki,e,this.Ku)) : (this.Zk = new gvjs_6E(this.ym,b,0,1,this.Ku),
    e = this.Zk.Ya(-a),
    this.Ki = Math.round(c + e / (e + 1) * (d - c)),
    b >= -a ? this.Zk = new gvjs_6E(this.ym,b,this.Ki,d,this.Ku) : (e = 2 * this.Ki - c,
    this.Zk = new gvjs_6E(this.ym,-a,this.Ki,e,this.Ku)));
    this.Sg = d < c
}
gvjs_ = gvjs_aF.prototype;
gvjs_.Yb = function() {
    return this.iy
}
;
gvjs_.$b = function() {
    return this.zH
}
;
gvjs_.Ho = function() {
    return this.ZK
}
;
gvjs_.an = function() {
    return this.XK
}
;
gvjs_.Ae = function(a) {
    if (this.iy == this.zH)
        return this.iy;
    var b = this.Sg ? -1 : 1;
    return a * b > this.Ki * b ? this.Zk.Ae(a) : a * b < this.Ki * b ? -this.Zk.Ae(2 * this.Ki - a) : 0
}
;
gvjs_.Ya = function(a) {
    return this.iy == this.zH ? Math.abs(this.ZK - this.XK) / 2 : a > this.ym ? this.Zk.Ya(a) : a < -this.ym ? 2 * this.Ki - this.Zk.Ya(-a) : this.Ki
}
;
var gvjs_uea = {
    aBa: gvjs_iw,
    LOG: "log",
    OAa: gvjs_Vv
};
function gvjs_bF() {
    return {
        transform: function(a) {
            return a
        },
        inverse: function(a) {
            return a
        }
    }
}
function gvjs_vea(a) {
    var b = gvjs_wea(a);
    return {
        transform: function(c) {
            var d = gvjs_cF(b, c, function(e) {
                return e.source
            });
            return null === d ? c : d.target + (c - d.source) * d.xC
        },
        inverse: function(c) {
            var d = gvjs_cF(b, c, function(e) {
                return e.target
            });
            return null === d ? c : 0 == d.xC ? d.source : d.source + (c - d.target) / d.xC
        }
    }
}
function gvjs_wea(a) {
    for (var b = [], c = 0, d = null, e = 0; e < a.length; e++) {
        var f = a[e]
          , g = f.voa
          , h = f.start;
        f = f.end;
        var k = g / (f - h);
        null === d || d != h ? b.push({
            source: h,
            target: h + c,
            xC: k
        }) : b[b.length - 1].xC = k;
        b.push({
            source: f,
            target: h + c + g,
            xC: 1
        });
        c += g - (f - h);
        d = f
    }
    return b
}
function gvjs_cF(a, b, c) {
    b = gvjs_Iy(a, {
        source: b,
        target: b,
        xC: 0
    }, function(d, e) {
        d = c(d);
        e = c(e);
        return d < e ? -1 : d > e ? 1 : 0
    });
    0 > b && (b = -b - 2);
    return 0 > b ? null : a[b]
}
function gvjs_xea(a) {
    var b = new gvjs_aF(.5 * a,a,0,1,0);
    return {
        transform: function(c) {
            return null == c ? c : b.Ya(c)
        },
        inverse: function(c) {
            return null == c ? c : b.Ae(c)
        }
    }
}
function gvjs_yea(a) {
    var b = new gvjs_aF(-a,a,-1,1,0,a);
    return {
        transform: function(c) {
            return null == c ? c : b.Ya(c)
        },
        inverse: function(c) {
            return null == c ? c : b.Ae(c)
        }
    }
}
function gvjs_dF(a, b, c) {
    return (c = a.cb(c, gvjs_uea)) ? c : gvjs_K(a, b) ? "log" : gvjs_iw
}
function gvjs_eF(a, b, c) {
    switch (a) {
    case gvjs_iw:
        return 0 == c.length ? gvjs_bF() : gvjs_vea(c);
    case "log":
        return gvjs_xea(b);
    case gvjs_Vv:
        return gvjs_yea(b);
    default:
        return gvjs_bF()
    }
}
;function gvjs_fF(a, b, c) {
    this.ra = [];
    this.Lca = a;
    this.Jha = b;
    this.hC = c || gvjs_bF()
}
function gvjs_gF(a, b) {
    if (0 < a.ra.length) {
        var c = a.ra[a.ra.length - 1][0]
          , d = b - c;
        if (d > a.Lca && (d = Math.round(d / a.Lca),
        1 < d))
            for (var e = 1; e < d; e++) {
                var f = e / d * (b - c) + c;
                a.ra.push([f, a.Jha(f)])
            }
    }
    a.ra.push([b, a.Jha(b)])
}
gvjs_fF.prototype.cd = function() {
    return this.ra
}
;
function gvjs_hF() {}
gvjs_hF.prototype.qm = function() {
    return this
}
;
gvjs_hF.prototype.vz = function() {
    return !1
}
;
gvjs_hF.prototype.isNumber = function() {
    return !1
}
;
function gvjs_iF() {}
gvjs_iF.prototype.zq = function() {
    return ")"
}
;
function gvjs_jF() {}
gvjs_jF.prototype.zq = function() {
    return "("
}
;
function gvjs_kF(a) {
    this.Eg = a
}
gvjs_o(gvjs_kF, gvjs_hF);
gvjs_kF.prototype.join = function(a) {
    var b = [];
    gvjs_u(this.Eg, function(c, d) {
        0 < d && b.push(a);
        d = !1;
        c instanceof gvjs_kF && 1 < c.Eg.length && this.HC() > c.HC() && (d = !0);
        d && b.push(new gvjs_jF);
        gvjs_Me(b, c.Im());
        d && b.push(new gvjs_iF)
    }, this);
    return b
}
;
gvjs_kF.prototype.qm = function() {
    if (1 === this.Eg.length)
        return this.Eg[0];
    var a = [];
    gvjs_u(this.Eg, function(b) {
        a.push(b.qm())
    });
    this.Eg = a;
    return this
}
;
function gvjs_lF(a) {
    this.value = a
}
gvjs_lF.prototype.zq = function() {
    return gvjs_g
}
;
function gvjs_mF(a) {
    this.value = a
}
gvjs_o(gvjs_mF, gvjs_hF);
gvjs_mF.prototype.Im = function() {
    return [new gvjs_lF(this.value)]
}
;
gvjs_mF.prototype.vz = function() {
    return 0 > this.value
}
;
gvjs_mF.prototype.getValue = function() {
    return this.value
}
;
gvjs_mF.prototype.isNumber = function() {
    return !0
}
;
function gvjs_nF() {}
gvjs_nF.prototype.zq = function() {
    return "--"
}
;
function gvjs_oF(a) {
    this.Eg = [a]
}
gvjs_o(gvjs_oF, gvjs_kF);
function gvjs_pF(a) {
    this.Eg = [a]
}
gvjs_o(gvjs_pF, gvjs_oF);
gvjs_pF.prototype.qm = function() {
    var a = this.Eg[0].qm();
    if (a.vz()) {
        if (a instanceof gvjs_pF)
            return a.Eg[0];
        if (a instanceof gvjs_mF)
            return new gvjs_mF(-a.getValue());
        throw Error("Unknown type of negative.");
    }
    return new gvjs_pF(a)
}
;
gvjs_pF.prototype.Im = function() {
    return gvjs_Ke([new gvjs_nF], this.Eg[0].Im())
}
;
gvjs_pF.prototype.vz = function() {
    return this.qm()instanceof gvjs_pF
}
;
gvjs_pF.prototype.HC = function() {
    return -1
}
;
function gvjs_qF() {}
gvjs_qF.prototype.zq = function() {
    return "-"
}
;
function gvjs_rF() {}
gvjs_rF.prototype.zq = function() {
    return "+"
}
;
function gvjs_sF(a) {
    this.Eg = a
}
gvjs_o(gvjs_sF, gvjs_kF);
gvjs_sF.prototype.HC = function() {
    return 1
}
;
gvjs_sF.prototype.Im = function() {
    for (var a = [], b = 0; b < this.Eg.length; b++) {
        var c = this.Eg[b];
        0 < a.length && c.vz() ? (a.push(new gvjs_qF),
        c = (new gvjs_pF(c)).qm()) : 0 < a.length && a.push(new gvjs_rF);
        a = gvjs_Ke(a, c.Im())
    }
    return a
}
;
function gvjs_tF() {}
gvjs_tF.prototype.zq = function() {
    return "="
}
;
function gvjs_uF(a) {
    this.Eg = a
}
gvjs_o(gvjs_uF, gvjs_kF);
gvjs_uF.prototype.HC = function() {
    return 0
}
;
gvjs_uF.prototype.Im = function() {
    return this.join(new gvjs_tF)
}
;
function gvjs_vF() {}
gvjs_vF.prototype.zq = function() {
    return "*"
}
;
function gvjs_wF(a, b) {
    this.Eg = a;
    this.r8 = null != b ? b : !1
}
gvjs_o(gvjs_wF, gvjs_kF);
gvjs_wF.prototype.HC = function() {
    return 2
}
;
gvjs_wF.prototype.qm = function() {
    gvjs_kF.prototype.qm.call(this);
    var a = 0
      , b = []
      , c = 1;
    gvjs_u(this.Eg, function(e) {
        e.vz() && (e = (new gvjs_pF(e)).qm(),
        a++);
        e.isNumber() && (c *= e.getValue(),
        e = null);
        e && b.push(e)
    });
    1 !== c && gvjs_Ne(b, 0, 0, new gvjs_mF(c));
    var d = new gvjs_wF(b,this.r8);
    a % 2 && (d = new gvjs_pF(d));
    return d
}
;
gvjs_wF.prototype.Im = function() {
    return this.r8 ? gvjs_Ke.apply(null, gvjs_v(this.Eg, function(a) {
        return a.Im()
    })) : this.join(new gvjs_vF)
}
;
gvjs_wF.prototype.vz = function() {
    var a = 0;
    gvjs_u(this.Eg, function(b) {
        b.vz() && a++
    });
    return !!(a % 2)
}
;
function gvjs_xF() {}
gvjs_xF.prototype.zq = function() {
    return "^"
}
;
function gvjs_yF(a) {
    this.Eg = a
}
gvjs_o(gvjs_yF, gvjs_kF);
gvjs_yF.prototype.HC = function() {
    return 3
}
;
gvjs_yF.prototype.Im = function() {
    return this.join(new gvjs_xF)
}
;
function gvjs_zF(a) {
    this.name = a
}
gvjs_zF.prototype.zq = function() {
    return "identifier"
}
;
function gvjs_AF(a) {
    this.name = a
}
gvjs_o(gvjs_AF, gvjs_hF);
gvjs_AF.prototype.Im = function() {
    return [new gvjs_zF(this.name)]
}
;
gvjs_AF.prototype.getName = function() {
    return this.name
}
;
function gvjs_BF(a, b) {
    if (a instanceof gvjs_BF)
        this.yd = a.um();
    else {
        var c;
        if (c = gvjs_ne(a))
            a: {
                for (var d = c = 0; d < a.length; d++) {
                    if (!gvjs_ne(a[d]) || 0 < c && a[d].length != c) {
                        c = !1;
                        break a
                    }
                    for (var e = 0; e < a[d].length; e++)
                        if (typeof a[d][e] !== gvjs_g) {
                            c = !1;
                            break a
                        }
                    0 == c && (c = a[d].length)
                }
                c = 0 != c
            }
        if (c)
            this.yd = gvjs_Le(a);
        else if (a instanceof gvjs_A)
            this.yd = gvjs_CF(a.height, a.width);
        else if (typeof a === gvjs_g && typeof b === gvjs_g && 0 < a && 0 < b)
            this.yd = gvjs_CF(a, b);
        else
            throw Error("Invalid argument(s) for Matrix contructor");
    }
    this.ya = new gvjs_A(this.yd[0].length,this.yd.length)
}
function gvjs_DF(a, b, c) {
    for (var d = 0; d < a.Tb().height; d++)
        for (var e = 0; e < a.Tb().width; e++)
            b.call(c, a.yd[d][e], d, e, a)
}
function gvjs_EF(a, b) {
    var c = new gvjs_BF(a.Tb());
    gvjs_DF(a, function(d, e, f) {
        c.yd[e][f] = b.call(void 0, d, e, f, a)
    });
    return c
}
function gvjs_CF(a, b) {
    for (var c = [], d = 0; d < a; d++) {
        c[d] = [];
        for (var e = 0; e < b; e++)
            c[d][e] = 0
    }
    return c
}
gvjs_ = gvjs_BF.prototype;
gvjs_.add = function(a) {
    if (!gvjs_fz(this.ya, a.Tb()))
        throw Error("Matrix summation is only supported on arrays of equal size");
    return gvjs_EF(this, function(b, c, d) {
        return b + a.yd[c][d]
    })
}
;
function gvjs_zea(a, b) {
    if (a.ya.height != b.Tb().height)
        throw Error("The given matrix has height " + b.ya.height + ", but  needs to have height " + a.ya.height + ".");
    var c = new gvjs_BF(a.ya.height,a.ya.width + b.ya.width);
    gvjs_DF(a, function(d, e, f) {
        c.yd[e][f] = d
    });
    gvjs_DF(b, function(d, e, f) {
        c.yd[e][this.ya.width + f] = d
    }, a);
    return c
}
gvjs_.equals = function(a, b) {
    if (this.ya.width != a.ya.width || this.ya.height != a.ya.height)
        return !1;
    b = b || 0;
    for (var c = 0; c < this.ya.height; c++)
        for (var d = 0; d < this.ya.width; d++)
            if (!(Math.abs(this.yd[c][d] - a.yd[c][d]) <= (b || 1E-6)))
                return !1;
    return !0
}
;
gvjs_.uZ = gvjs_n(65);
function gvjs_FF(a) {
    for (var b = new gvjs_BF(a), c = 0, d = 0; d < b.ya.height && !(c >= b.ya.width); d++) {
        for (var e = d; 0 == b.yd[e][c]; )
            if (e++,
            e == b.ya.height && (e = d,
            c++,
            c == b.ya.width))
                return b;
        var f = a
          , g = d
          , h = f.yd[e];
        f.yd[e] = f.yd[g];
        f.yd[g] = h;
        e = b.yd[d][c];
        for (f = c; f < b.ya.width; f++)
            b.yd[d][f] /= e;
        for (e = 0; e < b.ya.height; e++)
            if (e != d)
                for (g = b.yd[e][c],
                f = c; f < b.ya.width; f++)
                    b.yd[e][f] -= g * b.yd[d][f];
        c++
    }
    return b
}
gvjs_.Tb = function() {
    return this.ya
}
;
function gvjs_GF(a, b, c) {
    return 0 <= b && b < a.ya.height && 0 <= c && c < a.ya.width ? a.yd[b][c] : null
}
gvjs_.multiply = function(a) {
    if (a instanceof gvjs_BF) {
        if (this.ya.width != a.Tb().height)
            throw Error("Invalid matrices for multiplication. Second matrix should have the same number of rows as the first has columns.");
        return gvjs_Aea(this, a)
    }
    if (typeof a === gvjs_g)
        return gvjs_Bea(this, a);
    throw Error("A matrix can only be multiplied by a number or another matrix.");
}
;
gvjs_.aU = function(a) {
    if (!gvjs_fz(this.ya, a.Tb()))
        throw Error("Matrix subtraction is only supported on arrays of equal size.");
    return gvjs_EF(this, function(b, c, d) {
        return b - a.yd[c][d]
    })
}
;
gvjs_.um = function() {
    return this.yd
}
;
function gvjs_HF(a, b, c, d) {
    var e = new gvjs_BF((c ? c : a.ya.height - 1) - 0 + 1,(d ? d : a.ya.width - 1) - b + 1);
    gvjs_DF(e, function(f, g, h) {
        e.yd[g][h] = this.yd[0 + g][b + h]
    }, a);
    return e
}
function gvjs_Aea(a, b) {
    var c = new gvjs_BF(a.ya.height,b.Tb().width);
    gvjs_DF(c, function(d, e, f) {
        for (var g = d = 0; g < this.ya.width; g++)
            d += gvjs_GF(this, e, g) * gvjs_GF(b, g, f);
        if (!(0 <= e && e < c.ya.height && 0 <= f && f < c.ya.width))
            throw Error("Index out of bounds when setting matrix value, (" + e + "," + f + ") in size (" + c.ya.height + "," + c.ya.width + ")");
        c.yd[e][f] = d
    }, a);
    return c
}
function gvjs_Bea(a, b) {
    return gvjs_EF(a, function(c) {
        return c * b
    })
}
;function gvjs_IF(a) {
    this.tO = a.fv + 1;
    this.Ua = a.range;
    this.dta = a.Gca;
    this.ZY = 0;
    this.hC = a.$X || gvjs_bF();
    this.h6 = 0;
    this.ra = []
}
gvjs_IF.prototype.add = function(a, b) {
    if (isFinite(this.hC.transform(a))) {
        if (0 < this.ra.length) {
            var c = a - this.ra[this.ra.length - 1].x;
            0 < c && (this.ZY += c)
        }
        this.h6 += b;
        this.ra.push({
            x: a,
            y: b
        })
    }
}
;
function gvjs_Cea(a) {
    var b = a.dta;
    b || (b = null != a.Ua && null != a.Ua.min && isFinite(a.Ua.min) && null != a.Ua.max && isFinite(a.Ua.max) ? (a.Ua.max - a.Ua.min) / 100 : void 0);
    null != b && isFinite(b) || (b = a.ZY / (a.ra.length - 1));
    return b
}
function gvjs_Dea(a, b) {
    return gvjs_Ee(a.ra, function(c, d) {
        return c + Math.pow(this.hC.inverse(d.x), b)
    }, 0, a)
}
function gvjs_Eea(a, b) {
    return gvjs_Ee(a.ra, function(c, d) {
        return c + Math.pow(this.hC.inverse(d.x), b) * d.y
    }, 0, a)
}
function gvjs_Fea(a) {
    for (var b = [], c = a.tO, d = 0; d < c; d++) {
        for (var e = Array(c + 1), f = 0; f <= c; f++)
            e[f] = f < c ? gvjs_Dea(a, d + f) : gvjs_Eea(a, d);
        b.push(e)
    }
    return new gvjs_BF(b)
}
function gvjs_Gea(a) {
    var b = gvjs_FF(gvjs_Fea(a));
    return gvjs_v(gvjs_Ky(a.tO), function(c) {
        return gvjs_GF(b, c, this.tO)
    }, a)
}
function gvjs_Hea(a, b) {
    var c = a.tO;
    return gvjs_s(function(d) {
        d = this.hC.inverse(d);
        for (var e = 0, f = 0; f < c; f++)
            e += b[f] * Math.pow(d, f);
        return e
    }, a)
}
function gvjs_Iea(a, b) {
    b = gvjs_Hea(a, b);
    var c = gvjs_Cea(a);
    if (null == c || isNaN(c) || !isFinite(c) || 0 === c)
        return null;
    c = new gvjs_fF(c,b,a.hC);
    var d = a.ra;
    gvjs_Qe(d, function(q, r) {
        return q.x > r.x ? 1 : q.x < r.x ? -1 : 0
    });
    var e = a.h6 / d.length
      , f = a.Ua;
    null != a.Ua && null != a.Ua.min && isFinite(a.Ua.min) && 0 < d.length && f.min < d[0].x && gvjs_gF(c, f.min);
    for (var g = 0, h = 0, k = !0, l = 0; l < d.length; l++) {
        var m = d[l].x
          , n = d[l].y
          , p = b(m);
        k = k && p === n;
        gvjs_gF(c, m);
        g += Math.pow(n - p, 2);
        h += Math.pow(n - e, 2)
    }
    b = k ? 1 : 1 - g / h;
    null != a.Ua && null != a.Ua.max && isFinite(a.Ua.max) && 1 < d.length && f.max > d[d.length - 1].x && gvjs_gF(c, f.max);
    return {
        data: c.cd(),
        r2: b
    }
}
function gvjs_Jea(a) {
    function b(d, e) {
        for (var f = [], g = c.length - 1; 0 <= g; g--) {
            var h = c[g];
            if (null != h && 0 !== h) {
                h = new gvjs_mF(h);
                if (0 < g) {
                    var k = new gvjs_AF(d || "x");
                    1 < g && (k = new gvjs_yF([k, new gvjs_mF(g)]));
                    h = new gvjs_wF([h, k],!0)
                }
                f.push(h)
            }
        }
        return new gvjs_uF([new gvjs_AF(e || "y"), new gvjs_sF(f)])
    }
    var c = gvjs_Gea(a);
    a = gvjs_Iea(a, c);
    return null == a || 0 === a.data.length ? null : {
        $p: c,
        data: a.data,
        r2: a.r2,
        rv: b().qm(),
        bR: b
    }
}
;function gvjs_JF(a, b, c, d) {
    var e = new gvjs_IF(d);
    gvjs_Pz(gvjs_Qz(a), function(f) {
        var g = b(f);
        f = c(f);
        null != g && isFinite(g) && null != f && isFinite(f) && e.add(g, f)
    });
    return gvjs_Jea(e)
}
;function gvjs_KF(a, b, c, d) {
    a = gvjs_JF(a, b, c, {
        range: d.range,
        Gca: d.Gca,
        fv: 1,
        $X: d.$X
    });
    return null === a || isNaN(a.r2) ? null : {
        data: a.data,
        r2: a.r2,
        rv: {
            offset: a.$p[0],
            slope: a.$p[1]
        }
    }
}
;var gvjs_LF = {
    linear: function(a, b, c, d) {
        function e(g, h) {
            return new gvjs_uF([new gvjs_AF(h || "y"), new gvjs_sF([new gvjs_wF([new gvjs_mF(f.rv.slope), new gvjs_AF(g || "x")]), new gvjs_mF(f.rv.offset)])])
        }
        var f = gvjs_KF(a, b, c, d);
        return null === f ? null : {
            data: f.data,
            r2: f.r2,
            rv: e().qm(),
            bR: e
        }
    },
    exponential: function(a, b, c, d) {
        function e(m, n) {
            m = new gvjs_wF([new gvjs_mF(Math.exp(l.rv.offset)), new gvjs_yF([new gvjs_AF("e"), new gvjs_wF([new gvjs_mF(l.rv.slope), new gvjs_AF(m || "x")])])],!0);
            null !== f && (m = new gvjs_sF([m, new gvjs_mF(f)]));
            return m = new gvjs_uF([new gvjs_AF(n || "y"), m])
        }
        for (var f = Infinity, g = 0; g < a; g++) {
            var h = b(g)
              , k = c(g);
            null != k && k < f && (f = k)
        }
        f = 0 < f ? null : f - 1;
        var l = gvjs_KF(a, b, function(m) {
            m = c(m);
            if (null == m)
                return null;
            null != f && (m -= f);
            return Math.log(m)
        }, d);
        if (null === l)
            return null;
        a = [];
        for (g = 0; g < l.data.length; g++)
            h = l.data[g][0],
            k = Math.exp(l.data[g][1]),
            null != f && (k += f),
            a.push([h, k]);
        return {
            data: a,
            r2: l.r2,
            rv: e().qm(),
            bR: e
        }
    }
};
gvjs_LF.polynomial = gvjs_JF;
var gvjs_MF = [{
    color: "#3366CC",
    lighter: "#45AFE2"
}, {
    color: gvjs_vr,
    lighter: "#FF3300"
}, {
    color: gvjs_wr,
    lighter: "#FFCC00"
}, {
    color: gvjs_lr,
    lighter: "#14C21D"
}, {
    color: "#990099",
    lighter: "#DF51FD"
}, {
    color: "#0099C6",
    lighter: "#15CBFF"
}, {
    color: "#DD4477",
    lighter: "#FF97D2"
}, {
    color: "#66AA00",
    lighter: "#97FB00"
}, {
    color: "#B82E2E",
    lighter: "#DB6651"
}, {
    color: "#316395",
    lighter: "#518BC6"
}, {
    color: gvjs_rr,
    lighter: "#BD6CBD"
}, {
    color: "#22AA99",
    lighter: "#35D7C2"
}, {
    color: "#AAAA11",
    lighter: "#E9E91F"
}, {
    color: "#6633CC",
    lighter: "#9877DD"
}, {
    color: "#E67300",
    lighter: "#FF8F20"
}, {
    color: "#8B0707",
    lighter: "#D20B0B"
}, {
    color: "#651067",
    lighter: "#B61DBA"
}, {
    color: "#329262",
    lighter: "#40BD7E"
}, {
    color: "#5574A6",
    lighter: "#6AA7C4"
}, {
    color: "#3B3EAC",
    lighter: "#6D70CD"
}, {
    color: "#B77322",
    lighter: "#DA9136"
}, {
    color: "#16D620",
    lighter: "#2DEA36"
}, {
    color: "#B91383",
    lighter: "#E81EA6"
}, {
    color: "#F4359E",
    lighter: "#F558AE"
}, {
    color: "#9C5935",
    lighter: "#C07145"
}, {
    color: "#A9C413",
    lighter: "#D7EE53"
}, {
    color: "#2A778D",
    lighter: "#3EA7C6"
}, {
    color: "#668D1C",
    lighter: "#97D129"
}, {
    color: "#BEA413",
    lighter: "#E9CA1D"
}, {
    color: "#0C5922",
    lighter: "#149638"
}, {
    color: "#743411",
    lighter: "#C5571D"
}]
  , gvjs_NF = {
    color: "#EEEEEE",
    lighter: "#FEFEFE"
}
  , gvjs_Kea = {
    milliseconds: {
        format: ["ss.SSS", "SSS"],
        interval: [1, 2, 5, 10, 20, 50, 100, 200, 500]
    },
    seconds: {
        format: [gvjs_Ja, "ss.SSS"],
        interval: [1, 2, 5, 10, 15, 30]
    },
    minutes: {
        format: [gvjs_Ia, "mm"],
        interval: [1, 2, 5, 10, 15, 30]
    },
    hours: {
        format: [gvjs_Ia, "HH"],
        interval: [1, 2, 3, 4, 6, 12]
    },
    days: {
        format: ["d"],
        interval: [1, 2, 7]
    },
    months: {
        format: ["MM"],
        interval: [1, 2, 3, 4, 6]
    },
    years: {
        format: ["y"],
        interval: [1, 2, 5, 10, 20, 25, 50, 100, 200, 250, 500, 1E3]
    }
}
  , gvjs_Lea = {
    milliseconds: {
        format: [".SSS"],
        interval: [50, 100, 200, 500]
    },
    seconds: {
        format: [":ss"],
        interval: [5, 10, 15, 30]
    },
    minutes: {
        format: [":mm"],
        interval: [5, 10, 15, 30]
    },
    hours: {
        format: ["HH"],
        interval: [1, 2, 3, 4, 6, 12]
    },
    days: {
        format: ["d"],
        interval: [1, 2, 7]
    },
    months: {
        format: ["MM"],
        interval: [1, 2, 3, 4, 6, 12]
    },
    years: {
        format: ["y"],
        interval: [1, 2, 5, 10, 20, 50, 100, 200, 500, 1E3]
    }
}
  , gvjs_OF = {
    titleTextStyle: {
        color: gvjs_mr,
        italic: !0
    },
    viewWindow: {
        maxPadding: "50%"
    },
    minTextSpacing: 10,
    gridlines: {
        baseline: gvjs_ub,
        minorTextOpacity: .7,
        minorGridlineOpacity: .4,
        allowMinor: !0,
        minStrongLineDistance: 40,
        minWeakLineDistance: 20,
        minStrongToWeakLineDistance: 0,
        minNotchDistance: 5,
        minMajorTextDistance: 20,
        minMinorTextDistance: 20,
        unitThreshold: 2.2,
        units: {
            milliseconds: {
                format: [gvjs_Ka],
                interval: [1, 2, 5, 10, 20, 50, 100, 200, 500]
            },
            seconds: {
                format: [5, 6],
                interval: [1, 2, 5, 10, 15, 30]
            },
            minutes: {
                format: [7],
                interval: [1, 2, 5, 10, 15, 30]
            },
            hours: {
                format: [7],
                interval: [1, 2, 3, 4, 6, 12]
            },
            days: {
                format: [1, 2, 3, gvjs_Vj.MONTH_DAY_YEAR_MEDIUM, gvjs_Vj.MONTH_DAY_FULL, gvjs_Vj.MONTH_DAY_MEDIUM, gvjs_Vj.MONTH_DAY_SHORT, gvjs_Vj.MONTH_DAY_ABBR, gvjs_Vj.DAY_ABBR],
                interval: [1, 2, 7]
            },
            months: {
                format: [gvjs_Vj.YEAR_MONTH_FULL, gvjs_Vj.YEAR_MONTH_ABBR, "MMM"],
                interval: [1, 2, 3, 4, 6]
            },
            years: {
                format: [gvjs_Vj.YEAR_FULL],
                interval: [1, 2, 5, 10, 20, 25, 50, 100, 200, 250, 500, 1E3]
            }
        }
    },
    minorGridlines: {
        count: 1,
        units: {
            milliseconds: {
                format: [".SSS"],
                interval: [50, 100, 200, 250, 500]
            },
            seconds: {
                format: [":ss"],
                interval: [5, 10, 15, 30]
            },
            minutes: {
                format: [":mm"],
                interval: [5, 10, 15, 30]
            },
            hours: {
                format: [7],
                interval: [1, 2, 3, 4, 6, 12]
            },
            days: {
                format: ["d"],
                interval: [1, 2, 7]
            },
            months: {
                format: ["MMMMM", "MMM", "MM"],
                interval: [1, 2, 3, 4, 6, 12]
            },
            years: {
                format: ["y"],
                interval: [1, 2, 5, 10, 20, 25, 50, 100, 200, 250, 500, 1E3]
            }
        }
    }
}
  , gvjs_PF = {
    histogram: {
        bar: {
            gap: 1,
            group: {
                gap: 2
            }
        },
        histogram: {
            lastBucketPercentile: 0,
            hideBucketItems: !1,
            bucketSize: null,
            numBucketsRule: "rice",
            minSpacing: 1
        },
        domainAxis: {
            baselineColor: gvjs_f,
            gridlines: {
                color: gvjs_f
            },
            showTextEvery: 0,
            maxAlternation: 2
        },
        targetAxis: {
            format: "#",
            gridlines: {
                multiple: 1
            }
        }
    }
}
  , gvjs_QF = {
    vAxis: gvjs_OF,
    hAxis: gvjs_OF,
    domainAxis: {
        maxPadding: "5%"
    },
    sizeAxis: {
        minSize: 5,
        maxSize: 30
    },
    fontName: gvjs_2r,
    titleTextStyle: {
        color: gvjs_ca,
        bold: !0
    },
    bubble: {
        textStyle: {
            color: gvjs_ca
        }
    },
    candlestick: {
        hollowIsRising: !1
    },
    annotations: {
        datum: {
            textStyle: {
                color: gvjs_Nw
            },
            stemColor: gvjs_tr
        },
        domain: {
            textStyle: {
                color: gvjs_mr
            },
            stemColor: gvjs_tr
        }
    },
    majorAxisTextColor: gvjs_mr,
    minorAxisTextColor: gvjs_or,
    backgroundColor: {
        fill: gvjs_Br,
        stroke: gvjs_pr,
        strokeWidth: 0
    },
    chartArea: {
        backgroundColor: {
            fill: gvjs_f
        }
    },
    baselineColor: gvjs_nr,
    gridlineColor: gvjs_zr,
    pieSliceBorderColor: gvjs_ea,
    pieResidueSliceColor: gvjs_zr,
    pieSliceTextStyle: {
        color: gvjs_ea
    },
    areaOpacity: .3,
    intervals: {
        style: gvjs_lt,
        color: gvjs_Ow,
        lineWidth: 1,
        fillOpacity: .3,
        barWidth: .25,
        shortBarWidth: .1,
        boxWidth: .25,
        dataOpacity: 1,
        pointSize: 6
    },
    actionsMenu: {
        textStyle: {
            color: gvjs_ca
        },
        disabledTextStyle: {
            color: "#c0c0c0"
        }
    },
    legend: {
        newLegend: !0,
        textStyle: {
            color: gvjs_mr
        },
        pagingTextStyle: {
            color: "#0011cc"
        },
        scrollArrows: {
            activeColor: "#0011cc",
            inactiveColor: gvjs_zr
        }
    },
    tooltip: {
        textStyle: {
            color: gvjs_ca
        },
        boxStyle: {
            stroke: gvjs_zr,
            strokeOpacity: 1,
            strokeWidth: 1,
            fill: gvjs_Ox,
            fillOpacity: 1,
            shadow: {
                radius: 2,
                opacity: .1,
                xOffset: 1,
                yOffset: 1
            }
        }
    },
    aggregationTarget: gvjs_ub,
    colorAxis: {
        legend: {
            textStyle: {
                color: gvjs_ca
            }
        }
    }
};
function gvjs_RF(a) {
    var b = gvjs_v(a.lines, function(c) {
        var d = a.anchor ? a.anchor : {
            x: 0,
            y: 0
        }
          , e = gvjs_VA(c.x + d.x, c.length, a.ld);
        c = gvjs_VA(c.y + d.y, a.ja.fontSize, a.Pc);
        return e.start == e.end || c.start == c.end ? null : new gvjs_B(c.start,e.end,c.end,e.start)
    });
    b = gvjs_De(b, function(c) {
        return null != c
    });
    return gvjs_$B(b)
}
;/*

 Copyright 2021 Google LLC
 This code is released under the MIT license.
 SPDX-License-Identifier: MIT
*/
var gvjs_SF = {
    100: "#c6dafc",
    500: "#5e97f6",
    800: "#2a56c6"
}
  , gvjs_TF = {
    100: "#f4c7c3",
    500: "#db4437",
    900: "#a52714"
}
  , gvjs_UF = {
    100: "#fce8b2",
    600: "#f2a600",
    700: "#f09300",
    800: "#ee8100"
}
  , gvjs_VF = {
    100: "#b7e1cd",
    500: "#0f9d58",
    700: "#0b8043"
}
  , gvjs_WF = {
    100: "#e1bee7",
    400: "#ab47bc",
    800: "#6a1b9a"
}
  , gvjs_XF = {
    100: "#b2ebf2",
    600: "#00acc1",
    800: "#00838f"
}
  , gvjs_YF = {
    100: "#ffccbc",
    400: "#ff7043",
    700: "#e64a19"
}
  , gvjs_ZF = {
    100: "#f0f4c3",
    800: "#9e9d24",
    900: "#827717"
}
  , gvjs__F = {
    100: "#c5cae9",
    400: "#5c6bc0",
    600: "#3949ab"
}
  , gvjs_0F = {
    100: "#f8bbd0",
    200: "#f48fb1",
    300: "#f06292",
    500: "#e91e63",
    700: "#c2185b",
    900: "#880e4f"
}
  , gvjs_1F = {
    100: "#b2dfdb",
    700: "#00796b",
    900: "#004d40"
};
var gvjs_2F = {}
  , gvjs_3F = !1;
function gvjs_4F(a) {
    if (!gvjs_3F) {
        var b = {
            colors: [{
                color: "#dea19b",
                dark: "#ad7d79",
                light: "#ffd1c9"
            }, {
                color: "#cdc785",
                dark: "#aea971",
                light: "#eeeeac"
            }, {
                color: "#d6b9db",
                dark: "#a992ad",
                light: "#fff0db"
            }, {
                color: "#a2c488",
                dark: "#7f9a6b",
                light: "#d2feb0"
            }, {
                color: "#ffbc46",
                dark: "#ce9839",
                light: "#eeee5b"
            }, {
                color: "#9bbdde",
                dark: "#7993ad",
                light: "#c991ff"
            }],
            backgroundColor: {
                gradient: {
                    color1: "#8080ff",
                    color2: "#000020",
                    x1: gvjs_Ro,
                    y1: gvjs_Ro,
                    x2: gvjs_So,
                    y2: gvjs_So
                }
            },
            titleTextStyle: {
                color: gvjs_Ox
            },
            hAxis: {
                textStyle: {
                    color: gvjs_Ox
                },
                titleTextStyle: {
                    color: gvjs_Ox
                }
            },
            vAxis: {
                textStyle: {
                    color: gvjs_Ox
                },
                titleTextStyle: {
                    color: gvjs_Ox
                }
            },
            legend: {
                textStyle: {
                    color: gvjs_Ox
                }
            },
            chartArea: {
                backgroundColor: {
                    stroke: gvjs_Ar,
                    fill: gvjs_f
                }
            },
            areaOpacity: .8
        };
        gvjs_2F.classic = b;
        b = {
            titlePosition: gvjs_Fp,
            axisTitlesPosition: gvjs_Fp,
            legend: {
                position: gvjs_Fp
            },
            chartArea: {
                width: gvjs_So,
                height: gvjs_So
            },
            vAxis: {
                textPosition: gvjs_Fp
            },
            hAxis: {
                textPosition: gvjs_Fp
            }
        };
        gvjs_2F.maximized = b;
        b = {
            enableInteractivity: !1,
            legend: {
                position: gvjs_f
            },
            seriesType: gvjs_at,
            lineWidth: 1.6,
            chartArea: {
                width: gvjs_So,
                height: gvjs_So
            },
            vAxis: {
                textPosition: gvjs_f,
                gridlines: {
                    color: gvjs_f
                },
                baselineColor: gvjs_f
            },
            hAxis: {
                textPosition: gvjs_f,
                gridlines: {
                    color: gvjs_f
                },
                baselineColor: gvjs_f
            }
        };
        gvjs_2F.sparkline = b;
        b = {
            bar: {
                groupWidth: "65%"
            },
            textStyle: {
                color: gvjs_qr,
                fontName: gvjs_qs
            },
            annotations: {
                textStyle: {
                    color: gvjs_qr,
                    fontName: gvjs_qs
                }
            },
            bubble: {
                highContrast: !0,
                textStyle: {
                    auraColor: gvjs_f,
                    color: "#636363",
                    fontName: gvjs_qs
                }
            },
            tooltip: {
                textStyle: {
                    color: gvjs_qr,
                    fontName: gvjs_qs
                },
                boxStyle: {
                    stroke: "#b2b2b2",
                    strokeOpacity: 1,
                    strokeWidth: 1.5,
                    fill: gvjs_Ox,
                    fillOpacity: 1,
                    shadow: {
                        radius: 1,
                        opacity: .2,
                        xOffset: 0,
                        yOffset: 2
                    }
                }
            },
            vAxis: {
                textStyle: {
                    color: gvjs_qr,
                    fontName: gvjs_qs,
                    fontSize: 12
                },
                gridlines: {
                    color: gvjs_Ar
                },
                baselineColor: "#9e9e9e"
            },
            legend: {
                newLegend: !0,
                pagingTextStyle: {
                    fontName: gvjs_qs
                },
                textStyle: {
                    auraColor: gvjs_f,
                    color: gvjs_qr,
                    fontName: gvjs_qs,
                    fontSize: 12
                }
            },
            hAxis: {
                textStyle: {
                    color: gvjs_qr,
                    fontName: gvjs_qs,
                    fontSize: 12
                },
                gridlines: {
                    color: gvjs_Ar
                },
                baselineColor: "#9e9e9e"
            },
            pieSliceTextStyle: {
                color: gvjs_ea,
                fontName: gvjs_qs,
                fontSize: 14
            },
            pieResidueSliceColor: gvjs_qr,
            titleTextStyle: {
                color: gvjs_qr,
                fontName: gvjs_qs,
                fontSize: 16,
                bold: gvjs_Sb
            },
            scatter: {
                dataOpacity: .6
            },
            colorAxis: {
                colors: [],
                "one-sided-colors": [gvjs_ea, gvjs_SF[gvjs_Sr]],
                "two-sided-colors": [gvjs_SF[gvjs_Sr], gvjs_ea, gvjs_UF[gvjs_Tr]],
                legend: {
                    textStyle: {
                        color: gvjs_qr,
                        fontName: gvjs_qs,
                        fontSize: 12
                    }
                }
            },
            colors: [{
                color: gvjs_SF[gvjs_Sr],
                dark: gvjs_SF[gvjs_Vr],
                light: gvjs_SF[gvjs_Or]
            }, {
                color: gvjs_TF[gvjs_Sr],
                dark: gvjs_TF[gvjs_Wr],
                light: gvjs_TF[gvjs_Or]
            }, {
                color: gvjs_UF[gvjs_Tr],
                dark: gvjs_UF[gvjs_Vr],
                light: gvjs_UF[gvjs_Or]
            }, {
                color: gvjs_VF[gvjs_Sr],
                dark: gvjs_VF[gvjs_Ur],
                light: gvjs_VF[gvjs_Or]
            }, {
                color: gvjs_WF[gvjs_Rr],
                dark: gvjs_WF[gvjs_Vr],
                light: gvjs_WF[gvjs_Or]
            }, {
                color: gvjs_XF[gvjs_Tr],
                dark: gvjs_XF[gvjs_Vr],
                light: gvjs_XF[gvjs_Or]
            }, {
                color: gvjs_YF[gvjs_Rr],
                dark: gvjs_YF[gvjs_Ur],
                light: gvjs_YF[gvjs_Or]
            }, {
                color: gvjs_ZF[gvjs_Vr],
                dark: gvjs_ZF[gvjs_Wr],
                light: gvjs_ZF[gvjs_Or]
            }, {
                color: gvjs__F[gvjs_Rr],
                dark: gvjs__F[gvjs_Tr],
                light: gvjs__F[gvjs_Or]
            }, {
                color: gvjs_0F["300"],
                dark: gvjs_0F[gvjs_Sr],
                light: gvjs_0F[gvjs_Or]
            }, {
                color: gvjs_1F[gvjs_Ur],
                dark: gvjs_1F[gvjs_Wr],
                light: gvjs_1F[gvjs_Or]
            }, {
                color: gvjs_0F[gvjs_Ur],
                dark: gvjs_0F[gvjs_Wr],
                light: gvjs_0F["200"]
            }]
        };
        gvjs_2F.material = b;
        gvjs_3F = !0
    }
    return gvjs_2F[a]
}
function gvjs_5F(a) {
    var b = {};
    b.color = a.color || a;
    var c = gvjs_yj(b.color);
    c == gvjs_f ? (b.qb = a.darker || c,
    b.jh = a.lighter || c) : (c = gvjs_vj(c),
    b.qb = a.darker || gvjs_uj(gvjs_1z(c, .25)),
    b.jh = a.lighter || gvjs_uj(gvjs_2z(c, .25)));
    return b
}
;var gvjs_Mea = {
    NONE: gvjs_f,
    rza: gvjs_c,
    hBa: gvjs_zd,
    PERCENT: gvjs_ud
};
function gvjs_6F() {}
function gvjs_7F(a, b, c) {
    b = a.C[b];
    return b.ag && void 0 !== b.Sda ? (a = a.C[b.Sda].points[c],
    a = null != a ? a.Kf.d : a,
    null != a ? gvjs_Iy(b.points, a, function(d, e) {
        return d - e.Kf.d
    }) : c) : c
}
gvjs_ = gvjs_6F.prototype;
gvjs_.iP = function(a) {
    var b = a.Hb;
    a = a.Eb;
    var c = gvjs_7F(this, b, a);
    return this.C[b].points[c].wd.Mx || (this.$a[c] ? this.$a[a].$w[0] : null)
}
;
function gvjs_8F(a, b) {
    var c = b.Hb;
    b = gvjs_7F(a, c, b.Eb);
    a = a.C[c].points[b].wd.En || a.C[c].title;
    return null == a ? null : a
}
gvjs_.dZ = function(a) {
    return a.Eb
}
;
gvjs_.eZ = function(a) {
    return {
        row: a.Eb,
        column: this.C[a.Hb].Cs
    }
}
;
gvjs_.lP = function(a) {
    var b = this.Jk[a.column].Vb;
    return null == b ? null : {
        Hb: b,
        Eb: this.Ds[a.row]
    }
}
;
gvjs_.xI = function(a, b) {
    return this.C[a].points[b].wd
}
;
/*

 Copyright 2021 Google LLC
 This code is released under the MIT license.
 SPDX-License-Identifier: MIT

*/
function gvjs_9F(a) {
    this.Gd = gvjs_Te({}, a);
    this.fX = gvjs_Te({}, a)
}
function gvjs_$F(a, b, c) {
    var d = a.Gd.length;
    for (a.Gd[b] = c; b < d; ++b)
        a.fX[b] = gvjs_aG(a, 0 === b ? {} : a.fX[b - 1], a.Gd[b])
}
gvjs_9F.prototype.$v = function(a) {
    var b = gvjs_me(a);
    return b !== gvjs_h && b !== gvjs_sb || b === gvjs_h && typeof a.clone === gvjs_d || gvjs_oe(a)
}
;
function gvjs_aG(a, b, c) {
    if (a.$v(c) || a.$v(b) || Array.isArray(c))
        return c;
    if (gvjs_me(b) === gvjs_h) {
        var d = gvjs_x(b);
        gvjs_w(c, function(f, g) {
            d[g] = gvjs_Ze(b, g) && null != b[g] ? gvjs_aG(this, b[g], f) : f
        }, a);
        return d
    }
    var e = gvjs_Le(b);
    gvjs_w(c, function(f, g) {
        e[g] = gvjs_aG(this, b[g], f)
    }, a);
    return e
}
gvjs_9F.prototype.compact = function() {
    return gvjs_Ae(this.fX)
}
;
function gvjs_bG(a) {
    this.focused = {
        Hb: null,
        datum: null,
        Eb: null
    };
    this.annotations = {
        focused: null,
        dI: null
    };
    this.legend = {
        focused: {
            Xc: null
        },
        Xi: null,
        xF: null
    };
    this.gi = {
        focused: {
            wy: null
        }
    };
    this.cursor = {
        position: null,
        p2: null
    };
    this.Ii = this.gm = null;
    this.selected = new gvjs_$n;
    a && (this.selected.setSelection(a.selected),
    a.focused && (this.focused = gvjs_cG(this.focused, a.focused)),
    a.annotations && (this.annotations = gvjs_cG(this.annotations, a.annotations)),
    a.legend && (this.legend = gvjs_cG(this.legend, a.legend)),
    a.gi && (this.gi = gvjs_cG(this.gi, a.gi)),
    a.gm && (this.gm = gvjs_cG(this.gm, a.gm)),
    a.Ii && gvjs_cG(this.Ii, a.Ii))
}
gvjs_bG.prototype.clone = function() {
    var a = new gvjs_bG;
    a.selected = this.selected.clone();
    a.focused = gvjs_jj(this.focused);
    a.annotations = gvjs_jj(this.annotations);
    a.legend = gvjs_jj(this.legend);
    a.gi = gvjs_jj(this.gi);
    a.cursor = gvjs_jj(this.cursor);
    a.gm = gvjs_jj(this.gm);
    a.Ii = gvjs_jj(this.Ii);
    return a
}
;
gvjs_bG.prototype.equals = function(a, b) {
    b = void 0 === b ? !1 : b;
    return this.selected.equals(a.selected) && gvjs_Uz(this.focused, a.focused) && gvjs_Uz(this.annotations, a.annotations) && gvjs_Uz(this.legend, a.legend) && gvjs_Uz(this.gi, a.gi) && (b || gvjs_Uz(this.cursor, a.cursor)) && gvjs_Uz(this.gm, a.gm) && gvjs_Uz(this.Ii, a.Ii)
}
;
function gvjs_cG(a, b) {
    var c = new gvjs_9F(2);
    gvjs_$F(c, 0, a);
    gvjs_$F(c, 1, b);
    return c.compact()
}
;function gvjs_Nea(a) {
    if (0 == a.entries.length)
        return gvjs_5f(gvjs_Ob, {
            "class": gvjs_Nu
        });
    var b = a.entries.findIndex(function(d) {
        return d.type == gvjs_Lw
    })
      , c = [];
    -1 == b ? c.push(gvjs_dG(a.entries)) : (c.push(gvjs_dG(a.entries.slice(0, b))),
    c.push(gvjs_5f(gvjs_Ob, {
        "class": "google-visualization-tooltip-separator"
    })),
    c.push(gvjs_Oea(a.entries.slice(b + 1))));
    return gvjs_5f(gvjs_Ob, {
        "class": gvjs_Nu
    }, gvjs_$f(c))
}
function gvjs_dG(a) {
    a = a.map(function(b) {
        return gvjs_5f("li", {
            "class": "google-visualization-tooltip-item"
        }, gvjs_$f(gvjs_eG(b.data)))
    });
    return gvjs_5f("ul", {
        "class": "google-visualization-tooltip-item-list"
    }, gvjs_$f(a))
}
function gvjs_Oea(a) {
    a = a.map(function(b) {
        return gvjs_5f("li", {
            "data-logicalname": gvjs_4E([gvjs_Ss, b.data.id]),
            "class": "google-visualization-tooltip-action"
        }, gvjs_$f(gvjs_eG(b.data)))
    });
    return gvjs_5f("ul", {
        "class": "google-visualization-tooltip-action-list"
    }, gvjs_$f(a))
}
function gvjs_eG(a) {
    return a.items.map(function(b, c) {
        switch (b.type) {
        case gvjs_m:
            var d = b.html ? gvjs_OA(b.data.text) : gvjs_2f(b.data.text);
            b = b.data.style;
            var e = {
                "font-family": b.bb,
                "font-size": b.fontSize + gvjs_T,
                color: b.color,
                opacity: b.opacity,
                margin: gvjs_9e("0"),
                "font-style": b.Nc ? gvjs_9e(gvjs_Gp) : gvjs_9e(gvjs_f),
                "text-decoration": b.Ue ? gvjs_9e(gvjs_bq) : gvjs_9e(gvjs_f),
                "font-weight": b.bold ? gvjs_9e(gvjs_st) : gvjs_9e(gvjs_f)
            };
            b.Nc && (e["padding-right"] = gvjs_9e("0.04em"));
            b = gvjs_Hf(e);
            return gvjs_5f(gvjs_0w, {
                style: b
            }, gvjs_$f(0 == c ? "" : " ", d));
        case gvjs_1w:
            return gvjs_5f(gvjs_Ob, {
                "class": "google-visualization-tooltip-square",
                style: {
                    "background-color": b.data.brush && b.data.brush.fill
                }
            })
        }
    })
}
;function gvjs_fG(a, b, c, d, e) {
    var f = b.left + d;
    b = b.right - d;
    if (!(a.box.left >= f && a.box.right <= b)) {
        d = gvjs_0e(a);
        var g = d.box.left;
        d.box.left = gvjs_4y(c.x, d.box.right, -1);
        d.box.right = gvjs_4y(c.x, g, -1);
        if (g = d.hj) {
            var h = g[0];
            g[0] = g[2];
            g[2] = h;
            g[0].x = gvjs_4y(c.x, g[0].x, -1);
            g[1].x = gvjs_4y(c.x, g[1].x, -1);
            g[2].x = gvjs_4y(c.x, g[2].x, -1)
        }
        d.box.left >= f && d.box.right <= b ? (a.box = d.box,
        a.hj = d.hj) : (a.hj && (c = new gvjs_O(f + e,b - e),
        e = new gvjs_O(d.hj[0].x,d.hj[2].x),
        g = new gvjs_O(a.hj[0].x,a.hj[2].x),
        !(c.start <= g.start && c.end >= g.end) && c.start <= e.start && c.end >= e.end && (a.box = d.box,
        a.hj = d.hj)),
        a.box.right > b && (a.box.left -= a.box.right - b,
        a.box.right = b),
        a.box.left < f && (a.box.right += f - a.box.left,
        a.box.left = f))
    }
}
function gvjs_gG(a, b, c, d) {
    var e = b.top + d;
    b = b.bottom - d;
    if (!(a.box.top >= e && a.box.bottom <= b)) {
        d = gvjs_0e(a);
        var f = d.box.top;
        d.box.top = gvjs_4y(c.y, d.box.bottom, -1);
        d.box.bottom = gvjs_4y(c.y, f, -1);
        if (f = d.hj) {
            var g = f[0];
            f[0] = f[2];
            f[2] = g;
            f[0].y = gvjs_4y(c.y, f[0].y, -1);
            f[1].y = gvjs_4y(c.y, f[1].y, -1);
            f[2].y = gvjs_4y(c.y, f[2].y, -1)
        }
        d.box.top >= e && d.box.bottom <= b ? (a.box = d.box,
        a.hj = d.hj) : (a.box.bottom > b && (a.box.top -= a.box.bottom - b,
        a.box.bottom = b),
        a.box.top < e && (a.box.bottom += e - a.box.top,
        a.box.top = e),
        delete a.hj)
    }
}
;function gvjs_hG(a, b, c, d, e, f, g, h, k) {
    var l = {
        items: []
    };
    null != e && (e = gvjs_8z(e, f),
    l.items.push({
        type: gvjs_1w,
        data: {
            size: b.fontSize / 2,
            brush: e
        }
    }));
    null != g && l.items.push(gvjs_iG(g, b));
    if (null != c && "" !== c) {
        if (null == d)
            throw Error("Line title is specified without a text style.");
        l.items.push(gvjs_iG(c + ":", d))
    }
    l.items.push(gvjs_iG(a, b, h));
    null != k && (l.id = k,
    l.background = {
        brush: new gvjs_3(gvjs_iy)
    });
    return {
        type: gvjs_e,
        data: l
    }
}
function gvjs_jG() {
    return {
        type: gvjs_Lw,
        data: {
            brush: gvjs_9z("#eee", 1)
        }
    }
}
function gvjs_iG(a, b, c) {
    a = {
        type: gvjs_m,
        data: {
            text: a || "",
            style: b
        }
    };
    c && (a.html = !0);
    return a
}
function gvjs_kG(a, b, c, d, e, f, g, h, k, l) {
    if (h)
        return {
            html: gvjs_Nea(a),
            hO: !1,
            pivot: f,
            anchor: d,
            HG: e,
            spacing: 20,
            margin: 5
        };
    for (var m = h = 0; m < a.entries.length; m++) {
        var n = a.entries[m];
        if (n.type == gvjs_e) {
            n = n.data;
            for (var p = 0; p < n.items.length; p++) {
                var q = n.items[p];
                q.type == gvjs_m && (h = Math.max(h, q.data.style.fontSize))
            }
        }
    }
    g = 0 == h ? g || 0 : h;
    for (n = m = h = 0; n < a.entries.length; n++)
        switch (p = a.entries[n],
        p.type) {
        case gvjs_e:
            p = gvjs_lG(p.data, b);
            m += p.height + (0 < n ? p.bx : 0);
            h = Math.max(h, p.width);
            break;
        case gvjs_Lw:
            m += 1.5 * g + p.data.brush.strokeWidth
        }
    h = Math.max(h, 2 * g);
    var r = new gvjs_A(Math.round(h + 2 * g / 1.618),Math.round(m + 2 * g / 1.618));
    m = gvjs_$y(d.x - f.x);
    n = gvjs_$y(d.y - f.y);
    var t = c ? new gvjs_z(d.x + m * g,d.y + n * (g + r.height / 2)) : new gvjs_z(d.x + m * r.width / 2,d.y + n * r.height / 2);
    p = t.x - r.width / 2;
    q = p + r.width;
    var u = t.y - r.height / 2
      , v = u + r.height;
    h = {};
    c && (c = new gvjs_z(t.x,gvjs_4y(d.y, t.y, g / (g + r.height / 2))),
    t = new gvjs_z(gvjs_4y(t.x, d.x, -1),c.y),
    c.x = Math.round(c.x),
    c.y = Math.round(c.y),
    t.x = Math.round(t.x),
    t.y = Math.round(t.y),
    h.hj = 1 == m * n ? [c, d, t] : [t, d, c]);
    h.box = new gvjs_B(Math.round(u),Math.round(q),Math.round(v),Math.round(p));
    gvjs_fG(h, e, f, 5, 4);
    gvjs_gG(h, e, f, 5);
    d = {};
    e = g / 1.618;
    e = new gvjs_B(h.box.top + e,h.box.right - e,h.box.bottom - e,h.box.left + e);
    f = [];
    v = e.top;
    c = a.entries.length;
    r = !1;
    for (m = 0; m < c; m++)
        if (a.entries[m].gG) {
            r = !0;
            break
        }
    t = [];
    n = [];
    for (m = 0; m < c; m++)
        if (p = a.entries[m],
        p.type === gvjs_e) {
            q = p.data;
            u = [];
            n.push(u);
            for (var w = 0, x = q.items.length; w < x; w++) {
                var y = gvjs_mG(q.items[w], b);
                u.push(y);
                p.gG && (w > t.length - 1 ? t.push(y.width) : t[w] = Math.max(t[w], y.width))
            }
        }
    p = [];
    q = [];
    u = 0;
    if (r)
        for (m = 0; m < c; m++)
            if (y = a.entries[m],
            y.type == gvjs_e) {
                r = [];
                q.push(r);
                w = 0;
                if (y.gG)
                    for (x = 0,
                    y = y.data.items.length; x < y; x++) {
                        var z = t[x] - n[u][x].width;
                        r.push(z);
                        w += z
                    }
                p.push(w);
                u++
            }
    for (m = u = 0; m < c; m++) {
        r = a.entries[m];
        t = {
            Xc: r,
            data: {}
        };
        switch (r.type) {
        case gvjs_e:
            var A = r.data;
            w = t.data;
            x = gvjs_lG(A, b);
            r.gG && (x.width += p[u]);
            0 < m && (v += x.bx);
            A.background && (w.background = {
                box: new gvjs_B(v - x.bx / 2,h.box.right,v + x.height + x.bx,h.box.left)
            });
            y = [];
            z = e.left;
            var B = 0;
            for (A = A.items.length; B < A; B++) {
                var D = {}
                  , C = n[u][B];
                r.gG && (C.width += q[u][B]);
                0 < B && (z += C.RQ);
                var G = v + (x.height - C.height) / 2;
                D.box = new gvjs_B(Math.round(G),Math.round(z + C.width),Math.round(G + C.height),Math.round(z));
                k && (G = e.right - (D.box.left - e.left) - D.box.left - C.width,
                D.box.left += G,
                D.box.right += G);
                y.push(D);
                z += C.width
            }
            w.items = y;
            v += x.height;
            u++;
            break;
        case gvjs_Lw:
            r = r.data,
            w = v + g + r.brush.strokeWidth / 2,
            t.data.line = new gvjs_bA(h.box.left,w,h.box.right,w),
            v += 1.5 * g + r.brush.strokeWidth / 2
        }
        f.push(t)
    }
    d.entries = f;
    d.Xea = !!k;
    l = l || new gvjs_3({
        fill: gvjs_Ox,
        stroke: gvjs_yr,
        strokeWidth: 1
    });
    return {
        vl: l,
        outline: h,
        EG: d
    }
}
function gvjs_lG(a, b) {
    for (var c = 0, d = 0, e = 0, f = 0; f < a.items.length; f++) {
        var g = gvjs_mG(a.items[f], b);
        c += g.width + (0 < f ? g.RQ : 0);
        d = Math.max(d, g.height);
        e = Math.max(e, g.height / 2 + g.bx)
    }
    return {
        width: c,
        height: d,
        bx: e - d / 2
    }
}
function gvjs_mG(a, b) {
    switch (a.type) {
    case gvjs_m:
        var c = a.data.style;
        return {
            width: b ? b(String(a.data.text), c).width : 0,
            height: c.fontSize,
            bx: c.fontSize / 3.236,
            RQ: c.fontSize / 3.236
        };
    case gvjs_1w:
        return a = a.data.size,
        {
            width: a,
            height: a,
            bx: a,
            RQ: a
        };
    default:
        return a = a.data.size,
        {
            width: a,
            height: a,
            bx: a,
            RQ: a
        }
    }
}
;function gvjs_nG(a, b) {
    this.qv = {};
    this.yu = {};
    this.qB = [];
    this.updateOptions(a, b)
}
function gvjs_Pea(a) {
    gvjs_u(a.qB, function(b) {
        gvjs_oG(this, this.yu[b])
    }, a)
}
gvjs_ = gvjs_nG.prototype;
gvjs_.updateOptions = function(a, b) {
    this.Za = gvjs_ry(a, "actionsMenu.textStyle", b);
    this.Uma = gvjs_ry(a, "actionsMenu.disabledTextStyle", b);
    gvjs_Pea(this)
}
;
gvjs_.getEntries = function() {
    for (var a = [], b = 0, c = this.qB.length; b < c; b++) {
        var d = this.qB[b]
          , e = this.yu[d];
        if (!e.visible || e.visible())
            d = e.enabled && !e.enabled() ? gvjs_hG(e.text || "", this.Uma, null, null, null, null, null, !1, null) : gvjs_0e(this.qv[d]),
            a.push(d)
    }
    return a
}
;
function gvjs_oG(a, b) {
    if (!b.id)
        throw Error("Missing mandatory ID for action.");
    if (a.yu[b.id])
        var c = a.yu[b.id];
    else
        c = a.yu[b.id] = {
            id: b.id,
            text: void 0,
            visible: void 0,
            enabled: void 0,
            action: void 0
        },
        a.qB.push(b.id);
    gvjs_2e(c, b);
    a.qv[b.id] = gvjs_hG(c.text || "", a.Za, null, null, null, null, null, !1, c.id)
}
gvjs_.ng = function(a) {
    (a = this.yu[a]) && (a = gvjs_0e(a));
    return a
}
;
gvjs_.removeEntry = function(a) {
    a in this.qv && delete this.qv[a];
    a in this.yu && delete this.yu[a];
    a = gvjs_Be(this.qB, a);
    0 <= a && this.qB.splice(a, 1)
}
;
function gvjs_Qea(a, b) {
    a.EG = a.EG || {};
    a = a.EG;
    a.entries = a.entries || {};
    a = a.entries;
    a[b] = a[b] || {};
    b = a[b];
    b.Xc = b.Xc || {};
    return b.Xc
}
gvjs_.Us = function(a, b, c) {
    if (!a.html) {
        var d = b.focused.wy;
        null != d && (a = gvjs_Xx(a.EG.entries, function(e) {
            return e.Xc.data.id == d
        }),
        -1 !== a && (c = gvjs_Qea(c, a),
        c.data = c.data || {},
        c.data.background = c.data.background || {},
        c.data.background.brush = gvjs_8z("#DDD")))
    }
}
;
function gvjs_pG(a, b, c, d) {
    var e = gvjs_ry(a, gvjs_px, {
        bb: b.bb,
        fontSize: b.fontSize
    });
    this.fu = gvjs_K(a, gvjs_ox, c.has(gvjs_Ht));
    this.bxa = gvjs_K(a, gvjs_ox, !0);
    this.cxa = gvjs_K(a, "tooltip.showEmpty", !0);
    this.Za = e;
    this.FG = gvjs_ry(a, gvjs_px, {
        bb: b.bb,
        fontSize: b.fontSize,
        bold: !0
    });
    this.le = d || null;
    this.r9 = gvjs_J(a, "diff.newData.tooltip.prefix", "Current: ");
    this.s9 = gvjs_J(a, "diff.oldData.tooltip.prefix", "Previous: ")
}
gvjs_pG.prototype.ov = function() {}
;
function gvjs_qG(a) {
    this.Ea = a
}
gvjs_qG.prototype.aggregate = function(a) {
    var b = this
      , c = {
        index: {},
        order: [],
        $w: {}
    };
    gvjs_u(a, function(d) {
        var e = b.getKey(d);
        if (null != e) {
            typeof e !== gvjs_l && (e = e.toString());
            if (!c.$w.hasOwnProperty(e)) {
                var f = b.getTitle(d);
                f && (c.$w[e] = f)
            }
            c.index.hasOwnProperty(e) || (c.index[e] = [],
            c.order.push(e));
            c.index[e].push(d)
        }
    });
    return c
}
;
function gvjs_rG() {
    this.Ik = this.nf = null
}
gvjs_ = gvjs_rG.prototype;
gvjs_.adoptText = function(a) {
    this.nf = a
}
;
gvjs_.first = function() {
    return this.Ik = 0
}
;
gvjs_.current = function() {
    return this.Ik || 0
}
;
gvjs_.next = function(a) {
    a = this.peek(a);
    return null == a ? a : this.Ik = a
}
;
function gvjs_sG(a, b) {
    b.lastIndex = a.Ik;
    b = b.exec(a.nf);
    return !b || 0 > b.index ? a.nf.length : b.index + b[0].length
}
gvjs_.peek = function(a) {
    if (0 === a)
        a = gvjs_sG(this, /(\r\n|\n|\r)/g);
    else if (1 === a)
        a = gvjs_sG(this, /([`~!@#$%^&*()_+\-=\[\]\\{}|;':",\.\/<>?]|[ \t\u2009\u200b]+)/g);
    else if (2 === a)
        a = gvjs_sG(this, /[\u00ad]/g);
    else if (3 === a)
        a: {
            a = this.Ik + 1;
            for (var b = this.nf.length; a < b; a++)
                if (gvjs_Uda(this.nf.charCodeAt(a - 1), this.nf.charCodeAt(a)))
                    break a;
            a = this.nf.length
        }
    else
        a = this.nf.length;
    return a
}
;
function gvjs_tG() {
    this.At = {}
}
gvjs_tG.prototype.add = function(a, b, c, d) {
    null == b ? this.At[a] = d ? {
        Rx: d,
        levels: c
    } : c : (a in this.At || (this.At[a] = {}),
    this.At[a][b] = d ? {
        Rx: d,
        levels: c
    } : c)
}
;
function gvjs_uG(a, b) {
    if (null == b)
        return Object.keys(a.At);
    var c = [], d;
    for (d in a.At) {
        var e = a.At[d];
        if (typeof e === gvjs_g)
            e === b && c.push(d);
        else if (e.Rx)
            0 <= e.levels.indexOf(b) && c.push(d);
        else
            for (var f in e) {
                var g = e[f];
                if (typeof g === gvjs_g)
                    g === b && c.push(d);
                else if (g.Rx)
                    0 <= g.levels.indexOf(b) && c.push(d);
                else
                    throw Error("Unknown type");
            }
    }
    return c
}
gvjs_tG.prototype.VG = function(a, b, c) {
    if (!(a in this.At))
        throw Error("Error: unknown iterator type " + a);
    a = this.At[a];
    if (typeof a === gvjs_g)
        return a;
    if (a.Rx)
        return a.Rx(c);
    if (b in a) {
        a = a[b];
        if (typeof a === gvjs_g)
            return a;
        if (a.Rx)
            return a.Rx(c)
    }
    return null
}
;
function gvjs_vG(a) {
    this.Vsa = a;
    this.pJ = {};
    this.IN = new gvjs_tG;
    this.Lt = {};
    this.nf = this.Ik = null;
    this.VG(gvjs_e, gvjs_g, 0);
    this.VG(gvjs_e, gvjs_f, [1, 2], gvjs_s(function(b) {
        return "\u00ad" === this.nf[b - 1] ? 2 : 1
    }, this));
    this.VG(gvjs_Lt, null, 3)
}
gvjs_ = gvjs_vG.prototype;
gvjs_.adoptText = function(a) {
    this.nf = a;
    for (var b in this.pJ)
        this.pJ[b].adoptText(a)
}
;
function gvjs_wG(a, b) {
    var c = a.pJ[b];
    c || (c = a.pJ[b] = new window.Intl.v8BreakIterator(a.Vsa,{
        type: b
    }),
    null != a.nf && c.adoptText(a.nf),
    null != a.Ik && c.first());
    return c
}
gvjs_.VG = function(a, b, c, d) {
    this.IN.add(a, b, c, d)
}
;
function gvjs_xG(a, b, c) {
    c.next();
    if (c.current() >= a.nf.length)
        return !0;
    if (c.current() > a.Ik) {
        var d = c.breakType();
        c = c.current();
        var e = a.IN.VG(b, d, c);
        if (null == e)
            throw Error("Break type " + d + " in " + b + " iterator was classified as null.");
        e in a.Lt || (a.Lt[e] = []);
        a.Lt[e].push(c)
    }
    return !1
}
function gvjs_yG(a, b) {
    for (var c = a.Lt[b]; c && 0 < c.length && c[0] <= a.Ik; )
        c.shift();
    c = gvjs_uG(a.IN, b);
    for (var d = {}, e = !1; !(e || a.Lt[b] && 0 !== a.Lt[b].length); ) {
        e = !0;
        for (var f = 0, g = c.length; f < g; f++) {
            var h = c[f]
              , k = gvjs_wG(a, h);
            d[h] || (e = !1,
            gvjs_xG(a, h, k) && (d[h] = !0))
        }
    }
}
gvjs_.first = function() {
    for (var a = gvjs_uG(this.IN, void 0), b = 0, c = a.length; b < c; b++)
        gvjs_wG(this, a[b]).first();
    this.Lt = {};
    return this.Ik = 0
}
;
gvjs_.current = function() {
    return this.Ik || 0
}
;
gvjs_.next = function(a) {
    gvjs_yG(this, a);
    a = this.Lt[a];
    if (null != a && 0 < a.length) {
        a = this.Ik = a.shift();
        for (var b in this.pJ)
            for (var c = gvjs_wG(this, b); c.current() <= a; )
                gvjs_xG(this, b, c);
        return this.Ik
    }
    return this.nf.length
}
;
gvjs_.peek = function(a) {
    gvjs_yG(this, a);
    a = this.Lt[a];
    return null != a && 0 < a.length ? a[0] : this.nf.length
}
;
function gvjs_zG(a) {
    if (a.pz && a.hasOwnProperty("pz"))
        return a.pz;
    var b = new a;
    return a.pz = b
}
;function gvjs_Rea() {
    this.Tya = window.Intl && !!window.Intl.v8BreakIterator
}
function gvjs_AG() {
    var a = ["en"];
    return gvjs_zG(gvjs_Rea).Tya ? new gvjs_vG(a) : new gvjs_rG
}
;function gvjs_Sea(a, b, c, d, e, f) {
    var g = null;
    f = f ? 2 : 3;
    for (var h = 0; h <= f; h++) {
        var k = c.peek(h);
        if (null == g || k < g.position)
            g = {
                position: k,
                level: h
            };
        if (a(b(d, k)) <= e)
            return h
    }
    return g && g.level || f
}
function gvjs_Tea(a) {
    return function(b, c) {
        b = gvjs_kf(a.slice(b, c));
        "\u00ad" === b[b.length - 1] && (b = b.slice(0, b.length - 1) + "-");
        return b
    }
}
function gvjs_BG(a, b) {
    b = null == b ? a.length : b;
    return 0 <= b ? gvjs_kf(a.slice(0, b)) + "\u2026" : gvjs_Kr.slice(0, b)
}
function gvjs_Uea(a, b, c, d) {
    if (a(gvjs_BG(b)) <= c)
        return gvjs_BG(b);
    var e = gvjs_AG();
    e.adoptText(b);
    e.first();
    var f = e.next(3)
      , g = a(b.slice(0, f)) <= c;
    if (d && !g || !d && a(gvjs_BG(b, f)) > c)
        for (d = 0; -3 <= d && !(b = gvjs_BG(b, d),
        a(b) <= c); d--)
            ;
    else {
        for (; a(gvjs_BG(b, e.peek(3))) <= c; )
            f = e.next(3);
        if (d && a(gvjs_BG(b, f)) > c)
            for (e = b.slice(0, f),
            d = 0; -3 <= d && !(b = e + gvjs_BG(b, d),
            a(b) <= c); d--)
                ;
        else
            b = gvjs_BG(b, f)
    }
    return b
}
var gvjs_CG = gvjs_Tz(function(a, b, c, d, e, f) {
    if ("" === b)
        return {
            lines: [],
            hx: !1
        };
    var g = null == f || null == f.truncate ? !0 : f.truncate
      , h = null == f || null == f.Nea ? !1 : f.Nea;
    f = null == f || null == f.y9 ? !1 : f.y9;
    var k = a;
    a = function(w) {
        return k(w, c).width
    }
    ;
    var l = gvjs_AG();
    l.adoptText(b);
    l.first();
    for (var m = !1, n = gvjs_Tea(b), p = !1, q = [], r = 0; ; ) {
        var t = gvjs_Sea(a, n, l, r, d, f)
          , u = l.next(t);
        if (0 !== t)
            for (; u < b.length && a(n(r, l.peek(t))) <= d; )
                u = l.next(t);
        q.push(n(r, u));
        var v = a(q[q.length - 1]) <= d;
        if (u >= b.length || q.length >= e || !v) {
            (u < b.length || !v) && g ? (0 !== t && (q[q.length - 1] = n(r, l.peek(t))),
            p = !0) : u < b.length && (m = !0);
            break
        }
        r = u
    }
    p && (q[q.length - 1] = gvjs_Uea(a, q[q.length - 1], d, h && 1 === q.length),
    m = !0);
    1 === q.length && "" === q[0] && (q = []);
    return {
        lines: q,
        hx: m
    }
}, {
    gT: function(a, b) {
        a = [a];
        for (var c = 1, d = b.length; c < d; c++)
            a.push(b[c]);
        return gvjs_Hi(a)
    }
});
function gvjs_DG(a, b, c, d, e, f) {
    function g(h) {
        return a(h, c)
    }
    e = null != e ? Math.floor(e) : 1;
    if (0 >= d)
        return {
            lines: [],
            oe: 0 < b.length,
            Oq: 0
        };
    if (0 == e)
        return {
            lines: [],
            oe: !1,
            Oq: 0
        };
    b = gvjs_CG(g, b, c, d, e, {
        truncate: !0,
        Nea: null != f ? f : !1,
        y9: !0
    });
    return {
        lines: b.lines,
        oe: b.hx,
        Oq: 0 < b.lines.length ? Math.max.apply(null, gvjs_v(gvjs_v(b.lines, g), function(h) {
            return h.width
        })) : 0
    }
}
function gvjs_Vea(a) {
    var b = {
        background: gvjs_dv,
        padding: gvjs_Pr,
        border: gvjs_Qr
    };
    null != a.fontSize && (b.fontSize = a.fontSize + gvjs_T,
    b.margin = a.fontSize + gvjs_T);
    null != a.bb && (b.fontFamily = a.bb);
    return b
}
;function gvjs_EG(a, b, c) {
    for (var d = 0; d < a.length; ++d)
        b.yb(a[d].sh.left, a[d].sh.top, a[d].sh.width, a[d].sh.height, a[d].brush, c)
}
function gvjs_FG(a, b, c) {
    for (var d = 0; d < a.length; ++d) {
        var e = new gvjs_SA;
        e.move(a[d].path[0], a[d].path[1]);
        e.va(a[d].path[2], a[d].path[3]);
        e.va(a[d].path[4], a[d].path[5]);
        e.close();
        b.Ia(e, a[d].brush, c)
    }
}
function gvjs_GG(a, b, c) {
    for (var d = 0; d < a.length; ++d)
        b.ce(a[d].text, a[d].x, a[d].y, 1, gvjs_2, gvjs_2, a[d].style, c)
}
;function gvjs_HG(a, b) {
    this.x = void 0 === a ? 0 : a;
    this.y = void 0 === b ? 0 : b
}
gvjs_HG.prototype.clone = function() {
    return new gvjs_HG(this.x,this.y)
}
;
function gvjs_IG(a, b) {
    var c = a.html
      , d = gvjs_3g(b);
    c = gvjs_Bda(d, c);
    b.appendChild(c);
    var e = a.anchor;
    b = a.pivot;
    d = a.HG;
    var f = a.spacing;
    a = a.margin;
    var g = new gvjs_A(c.clientWidth,c.clientHeight)
      , h = d.right - e.x >= g.width + a
      , k = e.x - d.left >= g.width + a
      , l = d.bottom - e.y >= g.height + a
      , m = e.y - d.top >= g.height + a
      , n = gvjs_$y(e.x - b.x)
      , p = gvjs_$y(e.y - b.y);
    0 === n && n === p && (n = !k || h || l || m ? 1 : -1,
    p = m || h ? -1 : 1);
    h = e.x + (f + g.width / 2) * n;
    e = e.y + (f + g.height / 2) * p;
    e = {
        box: new gvjs_B(e - g.height / 2,h + g.width / 2,e + g.height / 2,h - g.width / 2),
        hj: null
    };
    gvjs_fG(e, d, b, a, 0);
    gvjs_gG(e, d, b, a);
    b = new gvjs_z(e.box.left,e.box.top);
    c.style.width = c.clientWidth + 1 + gvjs_T;
    c.style.height = c.clientHeight + gvjs_T;
    c.style.left = b.x + gvjs_T;
    c.style.top = b.y + gvjs_T;
    return c
}
;function gvjs_JG(a, b, c) {
    a = gvjs_KG(a, b);
    b.appendChild(c, a);
    return a
}
function gvjs_KG(a, b) {
    var c = b.Sa();
    c.j().setAttribute(gvjs_Cb, gvjs_Nu);
    var d = a.outline
      , e = new gvjs_SA
      , f = new gvjs_B(d.box.top + .5,d.box.right + .5,d.box.bottom + .5,d.box.left + .5)
      , g = d.hj;
    e.move(f.left + 1, f.bottom);
    e.Sf(f.left + 1, f.bottom - 1, 1, 1, 180, 270, !0);
    e.va(f.left, f.top + 1);
    e.Sf(f.left + 1, f.top + 1, 1, 1, 270, 0, !0);
    if (null != g && g[0].y == d.box.top)
        for (var h = 0; 3 > h; ++h)
            e.va(g[h].x + .5, g[h].y + .5);
    e.va(f.right - 1, f.top);
    e.Sf(f.right - 1, f.top + 1, 1, 1, 0, 90, !0);
    e.va(f.right, f.bottom - 1);
    e.Sf(f.right - 1, f.bottom - 1, 1, 1, 90, 180, !0);
    if (null != g && g[0].y == d.box.bottom)
        for (d = 0; 3 > d; ++d)
            e.va(g[d].x + .5, g[d].y + .5);
    e.close();
    b.Ia(e, a.vl, c);
    a = a.EG;
    for (e = 0; e < a.entries.length; e++)
        switch (f = a.entries[e],
        d = f.Xc,
        g = b.Sa(),
        b.appendChild(c, g),
        d.type) {
        case gvjs_e:
            d = d.data;
            f = f.data;
            f.background && b.yb(f.background.box.left, f.background.box.top, f.background.box.right - f.background.box.left, f.background.box.bottom - f.background.box.top, d.background.brush, g);
            for (h = 0; h < f.items.length; h++) {
                var k = d.items[h]
                  , l = f.items[h];
                switch (k.type) {
                case gvjs_m:
                    b.ce(k.data.text, a.Xea ? l.box.right : l.box.left, l.box.top, 1, gvjs_2, gvjs_2, k.data.style, g, a.Xea);
                    break;
                case gvjs_1w:
                    b.yb(l.box.left, l.box.top, l.box.right - l.box.left, l.box.bottom - l.box.top, k.data.brush, g)
                }
            }
            null != d.id && (d = gvjs_4E([gvjs_Ss, d.id]),
            b.kp(g, d));
            break;
        case gvjs_Lw:
            d = d.data,
            f = f.data,
            h = new gvjs_SA,
            h.move(f.line.x0, f.line.y0),
            h.va(f.line.x1, f.line.y1),
            b.Ia(h, d.brush, g)
        }
    return c
}
;function gvjs_LG(a, b) {
    this.renderer = b;
    this.zw = a;
    this.Ms = null;
    this.Fd = {};
    this.Wy = {};
    this.Hh = this.yt = this.n5 = this.Ea = null
}
gvjs_ = gvjs_LG.prototype;
gvjs_.Fl = function(a, b) {
    this.Fd = {};
    this.Wy = {};
    this.renderer.clear();
    this.zw.clear();
    gvjs_MG(this, a, b);
    a = this.Ea;
    a = this.renderer.Lm(a.width, a.height);
    gvjs_NG(this, b, a)
}
;
function gvjs_OG(a, b, c) {
    a.Fd = {};
    a.Wy = {};
    gvjs_MG(a, b, c);
    a.renderer.deleteContents(!0);
    gvjs_NG(a, c, a.renderer.kw);
    a.renderer.flush()
}
function gvjs_MG(a, b, c) {
    var d = new gvjs_9F(2);
    gvjs_$F(d, 0, b);
    gvjs_$F(d, 1, c);
    a.Ea = d.compact()
}
function gvjs_NG(a, b, c) {
    a.registerElement(c.j(), gvjs_Bb);
    var d = a.Ea
      , e = a.renderer
      , f = d.xG;
    !gvjs_gy(f) && !gvjs_ey(f) || e.yb(0, 0, d.width, d.height, f, c);
    d.oF == gvjs_aw && (f = a.mv(d.title, c, !0),
    a.registerElement(f, gvjs_fx));
    a.yt = e.Sa(!0);
    f = d.legend;
    a.PH(f);
    f && (e.appendChild(c, a.yt),
    a.registerElement(a.yt.j(), gvjs_rv));
    a.Hh = e.Sa(!0);
    f = d.Vi;
    a.OH(f);
    f && f.position != gvjs_Fp && (e.appendChild(c, a.Hh),
    a.Fd.colorbar = a.Hh.j());
    a.n5 = e.Sa(!1);
    a.C9(d, c) || a.gY(d, c);
    e.appendChild(c, a.n5);
    a.Ms = b
}
function gvjs_PG(a, b, c) {
    var d = gvjs_Ye({
        C: null,
        $a: null,
        legend: null,
        Jq: null,
        Vi: null,
        Ii: null
    });
    gvjs_tA(c, d) && gvjs_tA(a.Ms, d) ? (gvjs_Uz(c.legend, a.Ms.legend) || (a.renderer.qc(a.yt),
    d = new gvjs_9F(2),
    gvjs_$F(d, 0, b.legend || {}),
    gvjs_$F(d, 1, c.legend || {}),
    d = d.compact(),
    a.PH(d)),
    gvjs_Uz(c.Vi, a.Ms.Vi) || (a.renderer.qc(a.Hh),
    d = new gvjs_9F(2),
    gvjs_$F(d, 0, b.Vi || {}),
    gvjs_$F(d, 1, c.Vi || {}),
    d = d.compact(),
    a.OH(d)),
    a.Dea(b, c),
    gvjs_Uz(c.Ii, a.Ms.Ii) || (gvjs_QG(a, "overlaybox"),
    b = c.Ii,
    d = new gvjs_3,
    d.Te(b.color),
    d.mf(b.opacity),
    b = a.renderer.yb(b.left, b.top, b.width, b.height, d, a.renderer.kw),
    a.registerElement(b, "overlaybox")),
    a.Ms = c) : a.Fl(b, c)
}
gvjs_.gY = function(a, b) {
    var c = {
        color: gvjs_rt,
        bb: a.Hj,
        fontSize: a.Dl,
        bold: !1,
        Nc: !1,
        Ue: !1
    };
    this.Oj(gvjs_ms, c, a.O.width);
    var d = a.O.top + Math.round(a.O.height / 2);
    this.renderer.Zi(gvjs_ms, a.O.left, d, a.O.left + a.O.width, d, gvjs_0, gvjs_0, c, b)
}
;
gvjs_.PH = function(a) {
    if (a) {
        var b = a.ev;
        if (b) {
            var c = a.Xi || 0
              , d = a.Pe.length;
            if (a.$K)
                var e = a.area;
            else
                e = gvjs_v(b, function(f) {
                    return gvjs_RG(f)
                }, this),
                e = gvjs_$B(e);
            e && (e = gvjs_pz(e),
            this.renderer.yb(e.left, e.top, e.width, e.height, new gvjs_3(gvjs_iy), this.yt));
            for (e = 0; e < b.length; e++)
                gvjs_Wea(this, b[e]);
            gvjs_Xea(this, a.$K, c, d)
        }
    }
}
;
function gvjs_RG(a) {
    var b = [];
    if (a.Da) {
        var c = gvjs_RF(a.Da);
        c && b.push(c)
    }
    a.square && b.push(gvjs_oz(a.square.coordinates));
    return gvjs_$B(b)
}
function gvjs_SG(a, b, c, d, e, f, g) {
    var h = a.renderer.HH()
      , k = f.type
      , l = Number(f.sides);
    null != l && isFinite(l) || (l = 5);
    var m = Number(f.rotation);
    null != m && isFinite(m) || (m = 0);
    m = m / 180 * Math.PI - Math.PI / 2;
    "triangle" === k ? (k = gvjs_pw,
    l = 3) : k === gvjs_1w ? (k = gvjs_pw,
    l = 4,
    m += Math.PI / 4) : "diamond" === k && (k = gvjs_pw,
    l = 4);
    var n = k === gvjs_3w;
    500 < l && (k === gvjs_pw || k === gvjs_3w) && (k = gvjs_4o);
    if (k === gvjs_pw || k === gvjs_3w) {
        f = Number(f.dent);
        null != f && isFinite(f) || (5 <= l ? (f = Math.cos(Math.PI / l),
        f -= Math.pow(Math.sin(Math.PI / l), 2) / Math.sin(Math.PI / 2 - Math.PI / l)) : f = .3);
        f *= d;
        k === gvjs_3w && (l *= 2);
        k = new gvjs_SA;
        for (var p = 0; p < l; p++) {
            var q = d;
            n && p % 2 && (q = f);
            var r = 2 * Math.PI / l * p + m
              , t = Math.cos(r) * q + b;
            q = Math.sin(r) * q + c;
            0 < p ? k.va(t, q) : k.move(t, q)
        }
        k.close();
        b = a.renderer.Dc(k, e)
    } else
        b = a.renderer.$x(b, c, d, e);
    b && g && a.renderer.appendChild(g, b);
    a.renderer.dC(h);
    return b
}
gvjs_.iY = function(a, b) {
    var c = this.Ea.C[a.index];
    if (this.Ea.O5 && c && !c.Ih && c.hE) {
        var d = a.square.coordinates.left
          , e = a.square.coordinates.width
          , f = a.square.coordinates.height
          , g = d + e / 2;
        a = a.square.coordinates.top + f / 2;
        c.$r && this.renderer.yb(d, a, e, f / 2, c.$r, b);
        var h = .5 * f
          , k = c.Oc;
        k && (k.strokeWidth > h && (k = k.clone(),
        k.hl(h)),
        this.renderer.jY(d, a, d + e, a, k, b));
        c.Qg && c.rM && ((d = c.hE) || (d = {
            type: gvjs_4o
        }),
        gvjs_SG(this, g, a, Math.min(c.pointRadius, f / 2, e / 2), c.Qg, d, b))
    } else
        this.renderer.yb(a.square.coordinates.left, a.square.coordinates.top, a.square.coordinates.width, a.square.coordinates.height, a.square.brush, b)
}
;
function gvjs_Wea(a, b) {
    if (b.isVisible) {
        var c = a.renderer.Sa(!1)
          , d = c.j();
        b.id && d.setAttribute("column-id", b.id);
        var e = gvjs_4E([gvjs_zv, b.index]);
        a.registerElement(d, e, gvjs_zv);
        if (d = gvjs_RG(b))
            d = gvjs_pz(d),
            a.renderer.yb(d.left, d.top, d.width, d.height, new gvjs_3(gvjs_iy), c);
        b.Da && a.mv(b.Da, c);
        b.square && a.iY(b, c);
        if (b.Rg && b.Rg.isVisible) {
            var f = b.Rg.coordinates.x
              , g = b.Rg.coordinates.y
              , h = b.Rg.brush;
            d = a.renderer;
            e = d.Sa();
            d.yb(f, g, 12, 12, h, e);
            d.appendChild(c, e);
            h = new gvjs_SA;
            h.move(f + 2, g + 2);
            h.va(f + 12 - 2, g + 12 - 2);
            h.move(f + 12 - 2, g + 2);
            h.va(f + 2, g + 12 - 2);
            f = new gvjs_3;
            f.rd(gvjs_ea);
            f.hl(2);
            d.Ia(h, f, e);
            d = e.j();
            b = gvjs_4E([gvjs_uw, b.index]);
            a.registerElement(d, b)
        }
        a.renderer.appendChild(a.yt, c)
    }
}
function gvjs_Xea(a, b, c, d) {
    b && (gvjs_TG(a, b.w2, c, d, -1),
    b.a2 && a.mv(b.a2, a.yt),
    gvjs_TG(a, b.s1, c, d, 1))
}
function gvjs_TG(a, b, c, d, e) {
    if (b) {
        var f = gvjs_UA(b.path);
        f = a.renderer.Ia(f, b.brush, a.yt);
        b.active && (b = gvjs_4E([gvjs_Av, e, c, d]),
        a.registerElement(f, b))
    }
}
gvjs_.OH = function(a) {
    if (a) {
        var b = a.definition
          , c = this.renderer
          , d = this.Hh;
        gvjs_EG(b.XW, c, d);
        gvjs_FG(b.G0, c, d);
        gvjs_GG(b.V4, c, d);
        a = this.renderer.yb(a.SH.left, a.SH.top, a.SH.width, a.SH.height, new gvjs_3(gvjs_iy), this.Hh);
        this.registerElement(a, "colorbar")
    }
}
;
gvjs_.Oj = function(a, b, c) {
    var d = b.fontSize;
    a = this.renderer.Wl(a, b);
    a > c && (d = Math.max(1, Math.floor(d * c / a)));
    return d
}
;
function gvjs_UG(a, b) {
    var c = a.Fd[b];
    c && (a.renderer.Re(c),
    delete a.Fd[b])
}
gvjs_.nK = function(a, b) {
    a = a.html ? gvjs_IG(a, this.zw.getContainer()) : gvjs_JG(a, this.renderer, this.n5).j();
    this.registerElement(a, b)
}
;
gvjs_.mv = function(a, b, c) {
    (a = gvjs_VG(this, a, c)) && this.renderer.appendChild(b, a);
    return a
}
;
function gvjs_VG(a, b, c) {
    var d = b.lines;
    if (!d || 0 == d.length)
        return null;
    a = a.renderer;
    var e = b.ja
      , f = b.vl
      , g = null != b.angle ? b.angle : 0
      , h = b.anchor ? b.anchor : {
        x: 0,
        y: 0
    }
      , k = b.tooltip
      , l = !!k || c || !1;
    c = a.Sa();
    if (0 === g && f) {
        var m = gvjs_RF(b);
        if (m) {
            var n = Math.ceil(m.left - 3) + .5
              , p = Math.floor(m.top - 1) + .5;
            a.yb(n, p, Math.floor(m.right + 3) + .5 - n, Math.floor(m.bottom + 1) + .5 - p, f, c)
        }
    }
    for (f = 0; f < d.length; f++)
        m = d[f],
        0 === g ? a.ce(m.text, m.x + h.x, m.y + h.y, m.length, b.ld, b.Pc, e, c) : gvjs_Qda(a, m.text, m.x + h.x, m.y + h.y, m.length, g, b.ld, b.Pc, e, c);
    if (l) {
        l = null;
        if (0 === g)
            (d = gvjs_RF(b)) && (l = a.yb(d.left, d.top, d.right - d.left, d.bottom - d.top, new gvjs_3(gvjs_iy), c));
        else {
            var q = gvjs_6y(g);
            b = gvjs_0e(b);
            b.angle = 0;
            h = (new gvjs_ok(h.x,h.y)).rotate(-q);
            b.anchor = new gvjs_HG(h.x,h.y);
            for (f = 0; f < d.length; f++)
                h = (new gvjs_ok(d[f].x,d[f].y)).rotate(-q),
                b.lines[f].x = h.x,
                b.lines[f].y = h.y;
            if (d = gvjs_RF(b))
                d = [new gvjs_ok(d.left,d.top), new gvjs_ok(d.right,d.top), new gvjs_ok(d.right,d.bottom), new gvjs_ok(d.left,d.bottom)],
                gvjs_u(d, function(r) {
                    r.rotate(q)
                }),
                d = gvjs_UA(d, !1),
                l = a.Ia(d, new gvjs_3(gvjs_iy), c)
        }
        k && l && gvjs_Sda(a, l, k, gvjs_Vea(e))
    }
    return c.j()
}
gvjs_.we = function(a, b, c) {
    var d = this.Fd[b];
    null == d ? this.renderer.appendChild(a, c) : this.renderer.replaceChild(a, c, d);
    this.registerElement(c, b)
}
;
gvjs_.registerElement = function(a, b, c) {
    a && (this.renderer.kp(a, b),
    this.Fd[b] = a,
    c && (this.Wy[c] || (this.Wy[c] = []),
    gvjs_He(this.Wy[c], b) || this.Wy[c].push(b)))
}
;
function gvjs_QG(a, b) {
    var c = a.Fd[b];
    c && (a.renderer.Re(c),
    delete a.Fd[b])
}
gvjs_.Qj = function(a) {
    var b = [];
    if (this.Fd[a]) {
        var c = this.renderer.Qj(this.Fd[a]);
        c && b.push(c)
    }
    a = this.Wy[a] || [];
    for (var d = 0; d < a.length; ++d)
        (c = this.renderer.Qj(this.Fd[a[d]])) && b.push(c);
    return gvjs_$B(b)
}
;
function gvjs_WG(a, b) {
    return a.ia && a.ia.brush || a.brush || b.Qg
}
function gvjs_XG(a) {
    return !a || a.$l
}
function gvjs_YG(a) {
    return a.type == gvjs_e || a.type == gvjs_at || a.type == gvjs_Dd
}
function gvjs_ZG(a, b) {
    return null != a.visible ? a.visible : b.rM
}
function gvjs__G(a, b) {
    var c = a.points[b]
      , d = a.points[b - 1];
    a = a.points[b + 1];
    d = !d || !d.ia || d.$l;
    a = !a || !a.ia || a.$l;
    return !(!c || !c.ia || c.$l) && d && a
}
function gvjs_0G(a, b) {
    return a.ia && null != a.ia.radius ? a.ia.radius : null != a.radius ? a.radius : b.pointRadius
}
function gvjs_1G(a, b) {
    return gvjs_0G(a, b) + gvjs_fy(gvjs_WG(a, b)) / 2
}
function gvjs_2G(a) {
    return a.vp !== gvjs_f && a.Fa == gvjs_d && a.orientation == gvjs_S
}
function gvjs_3G(a, b) {
    for (var c = new gvjs_6B, d = !0, e = !0, f = null, g = null, h = 0; h < a.points.length; h++) {
        var k = a.points[h];
        if (k && k.ia && null != k.ia.x && null != k.ia.y) {
            d && (f = h,
            d = !1);
            var l = k.ia
              , m = k && k.jt || a.Oc;
            if (e || null === m)
                c.move(l.x, l.y),
                e = !1;
            else {
                var n = a.points[g];
                a.N_ && n.fr ? c.Jp(m, a.points[g].fr.x, a.points[g].fr.y, k.wt.x, k.wt.y, l.x, l.y) : c.va(m, l.x, l.y)
            }
            g = h
        } else
            e = !b || d
    }
    !d & a.Zra && (d = b ? g : a.points.length - 1,
    f = b ? f : 0,
    b = a.points[f],
    null != d && null != f && a.points[d] && !gvjs_XG(b) && (f = b && b.jt || a.Oc,
    a.N_ ? c.Jp(f, a.points[d].fr.x, a.points[d].fr.y, b.wt.x, b.wt.y, b.ia.x, b.ia.y) : c.close(f)));
    return c
}
function gvjs_4G(a) {
    for (var b = new gvjs_6B, c = !0, d = 0; d < a.points.length; d++) {
        var e = a.points[d]
          , f = e && e.ia;
        gvjs_XG(e) || !f || null == f.x || null == f.y ? c = !0 : (c || b.va(e && e.jt || a.Oc, f.WN, f.XN),
        (c || f.WN != f.UN || f.XN != f.VN) && b.move(f.UN, f.VN),
        c = !1)
    }
    return b
}
function gvjs_5G(a, b, c) {
    return (c = (a = a.jd) && a[c || 0]) && c.position.hf(b)
}
function gvjs_6G(a, b, c) {
    return (c = (a = a.wc) && a[c || 0]) && c.position.hf(b)
}
function gvjs_7G(a, b, c) {
    return (c = (a = a.jd) && a[c || 0]) && c.position.ol(b)
}
function gvjs_8G(a, b, c) {
    return (c = (a = a.wc) && a[c || 0]) && c.position.ol(b)
}
function gvjs_9G(a, b, c, d) {
    for (var e = a.C, f = null, g = Infinity, h, k = new gvjs_z(b,c), l = 0, m = e.length; l < m; l++) {
        var n = e[l];
        if (!n.ag) {
            var p = n;
            if (a.Fa === gvjs_fw) {
                n = p.fD.x - b;
                var q = p.fD.y - c;
                h = 0 < -n * (p.fD.y - p.gf.y) + q * (p.fD.x - p.gf.x);
                if (0 < -(p.Uv.x - p.ei.x) * q + (p.Uv.y - p.ei.y) * n && h && Math.sqrt(Math.pow(p.Uv.x - b, 2) + Math.pow(p.Uv.y - c, 2)) < Math.sqrt(Math.pow(p.Uv.x - p.ei.x, 2) + Math.pow(p.Uv.y - p.ei.y, 2)) + d)
                    return {
                        row: l
                    }
            } else {
                p = 0;
                for (q = n.points.length; p < q; p++)
                    if ((h = n.points[p]) && null != h.ia)
                        switch (h = h.ia,
                        n.type) {
                        case gvjs_e:
                        case gvjs_At:
                        case gvjs_Dd:
                            h = gvjs_cz(k, h);
                            h < d && h < g && (f = {
                                $G: p,
                                row: l
                            },
                            g = h);
                            break;
                        case gvjs_Ft:
                        case gvjs_lt:
                            var r = null;
                            if (n.type === gvjs_lt)
                                r = new gvjs_5(h.left,h.top,h.width,h.height);
                            else if (n.type === gvjs_Ft) {
                                r = h.line;
                                var t = Math.min(h.rect.top, r.top);
                                r = new gvjs_5(h.rect.left,t,h.rect.width,Math.max(h.rect.top + h.rect.height, r.top + r.height) - t)
                            }
                            h = d;
                            r = r.distance(k);
                            (h = r > h ? null : r) && h < g && (f = {
                                $G: p,
                                row: l
                            },
                            g = h);
                            break;
                        default:
                            throw Error("Unknown chart type for getPointDatum.");
                        }
                if (0 === g)
                    break
            }
        }
    }
    return f
}
function gvjs_$G(a, b) {
    b = b || {};
    switch (a) {
    case gvjs_Ow:
        return b.qb;
    case gvjs_Pw:
        return b.jh;
    case gvjs_Nw:
        return b.color;
    default:
        return a
    }
}
;function gvjs_aH(a, b) {
    gvjs_LG.call(this, a, b);
    this.df = null;
    this.o5 = []
}
gvjs_o(gvjs_aH, gvjs_LG);
function gvjs_bH(a, b, c) {
    a.o5.push({
        definition: b,
        id: c
    })
}
function gvjs_cH(a) {
    var b = a.renderer.HH();
    gvjs_u(a.o5, function(c) {
        a.nK(c.definition, c.id)
    });
    a.renderer.dC(b);
    a.o5 = []
}
gvjs_ = gvjs_aH.prototype;
gvjs_.C9 = function(a, b) {
    function c(m) {
        m = a.C[m];
        return !a.kd || m.type !== gvjs_Dd || m.rM
    }
    var d = this;
    gvjs_Yea(this, a);
    var e = this.renderer.Sa(!1);
    this.renderer.appendChild(b, e);
    this.registerElement(e.j(), gvjs_Tt);
    gvjs_w(this.df, function(m) {
        m.Kc || (m.Kc = d.renderer.Sa(!(void 0 !== m.a7 && !m.a7)))
    });
    this.renderer.yb(a.O.left, a.O.top, a.O.width, a.O.height, a.h8, e);
    a.oF == gvjs_Fp && this.mv(a.title, this.df.title.Kc, !0);
    a.cJ && this.mv(a.cJ, this.df.axistitle.Kc, !0);
    gvjs_u(a.$a, function(m, n) {
        m.Bc && gvjs_dH(d, m.Bc, null, n)
    });
    gvjs_w(a.jd, function(m) {
        gvjs_Zea(d, a, m)
    });
    gvjs_w(a.wc, function(m) {
        gvjs__ea(d, a, m)
    });
    var f = new gvjs_5(a.O.left,a.O.top,a.O.width,a.O.height);
    this.renderer.dC(f);
    for (var g = [], h = 0; h < a.C.length; h++)
        c(h) && g.push({
            wM: a.C[h].wM,
            index: h
        });
    gvjs_Se(g, function(m, n) {
        return gvjs_Re(m.wM, n.wM)
    });
    for (h = 0; h < g.length; h++) {
        var k = g[h].index;
        gvjs_eH(this, a.C[k], k)
    }
    a.kd && a.C[0].type === gvjs_Dd && gvjs_0ea(this, a, b);
    for (g = 0; g < a.$a.length; g++)
        a.$a[g].tooltip && (h = gvjs_4E([gvjs_Pd, g]),
        gvjs_bH(this, a.$a[g].tooltip, h));
    g = this.renderer.HH();
    gvjs_w(a.jd, function(m) {
        gvjs_fH(d, m)
    });
    gvjs_w(a.wc, function(m) {
        gvjs_fH(d, m)
    });
    this.renderer.dC(g);
    gvjs_cH(this);
    var l = this.renderer.Sa(!1);
    f = this.renderer.ZG(l, f);
    this.renderer.appendChild(e, f);
    gvjs_u(gvjs_5E, function(m) {
        var n = d.df[m].Kc;
        if (n) {
            switch (d.df[m].position) {
            case gvjs_Xt:
                var p = l;
                break;
            case gvjs_gv:
                p = e;
                break;
            case gvjs_bw:
                p = b
            }
            d.renderer.appendChild(p, n)
        }
    });
    return !0
}
;
function gvjs_Yea(a, b) {
    a.df = {};
    var c = a.df;
    c.action = {
        position: gvjs_bw
    };
    c.annotation = {
        position: gvjs_Xt
    };
    c.annotationtext = {
        position: gvjs_gv
    };
    c.area = {
        position: gvjs_Xt
    };
    c.bar = {
        position: gvjs_Xt
    };
    c.baseline = {
        position: gvjs_Xt
    };
    c.bubble = {
        position: gvjs_Xt
    };
    c.categorysensitivityarea = {
        position: gvjs_Xt
    };
    c.candlestick = {
        position: gvjs_Xt
    };
    c.histogram = {
        position: gvjs_Xt
    };
    c.gridline = {
        position: gvjs_Xt
    };
    c.interval = {
        position: gvjs_Xt
    };
    c.line = {
        position: gvjs_Xt
    };
    c.minorgridline = {
        position: gvjs_Xt
    };
    c.overlaybox = {
        position: gvjs_Xt
    };
    c.pathinterval = {
        position: gvjs_Xt
    };
    c.point = {
        position: gvjs_gv,
        a7: !1
    };
    c.pointsensitivityarea = {
        position: gvjs_gv
    };
    c.steppedareabar = {
        position: gvjs_Xt
    };
    c.tooltip = {
        position: gvjs_bw
    };
    c.title = {
        position: b.oF == gvjs_Fp ? gvjs_gv : gvjs_bw
    };
    c.axistick = {
        position: gvjs_gv
    };
    c.axistitle = {
        position: b.DB == gvjs_Fp ? gvjs_gv : gvjs_bw
    };
    var d = b.legend && b.legend.position == gvjs_Fp
      , e = d ? a.yt : null;
    d = d ? gvjs_gv : gvjs_bw;
    c.legend = {
        Kc: e,
        position: d
    };
    c.legendscrollbutton = {
        Kc: e,
        position: d
    };
    c.legendentry = {
        Kc: e,
        position: d
    };
    b = b.Vi && b.Vi.position == gvjs_Fp;
    c.colorbar = {
        Kc: b ? a.Hh : null,
        position: b ? gvjs_gv : gvjs_bw
    }
}
function gvjs_eH(a, b, c) {
    if (b.type == gvjs_At)
        gvjs_1ea(a, b, c);
    else if (b.type == gvjs_lt)
        gvjs_gH(a, b, c);
    else if (b.type == gvjs_4w)
        gvjs_gH(a, b, c);
    else if (b.type == gvjs_Ft)
        for (var d = 0; d < b.points.length; d++)
            gvjs_hH(a, c, b.points[d], d);
    else if (b.type == gvjs_at) {
        d = a.Ea.vp !== gvjs_f;
        var e = a.Ea.Zj;
        if (0 != b.points.length) {
            e = e && !d;
            for (var f = [], g = {
                start: null,
                end: null,
                brush: null
            }, h = 0; h <= b.points.length; h++) {
                var k = b.points[h];
                gvjs_XG(k) ? e && h !== b.points.length || (null !== g.start && null !== g.end && f.push(g),
                h < b.points.length && (g = {
                    start: null,
                    end: null,
                    brush: null
                })) : null === g.start ? g.start = h : (k = k && k.nQ || b.$r,
                null === g.brush || gvjs_$z(g.brush, k) ? (g.end = h,
                g.brush = k) : (f.push(g),
                g = {
                    start: h - 1,
                    end: h,
                    brush: k
                }))
            }
            h = a.renderer.Sa();
            for (k = 0; k < f.length; k++) {
                g = f[k];
                var l = g.brush
                  , m = new gvjs_SA
                  , n = m
                  , p = b
                  , q = d
                  , r = g.start;
                g = g.end;
                var t = !0
                  , u = null;
                n.move(p.points[r].ia.kW, p.points[r].ia.lW);
                for (var v = r; v <= g; v++) {
                    var w = p.points[v];
                    gvjs_XG(w) || (w = w.ia,
                    n.va(w.WN, w.XN),
                    w.UN == w.WN && w.VN == w.XN || n.va(w.UN, w.VN),
                    null != w.x && null != w.y && (t = !1,
                    u = v))
                }
                if (!t)
                    if (q)
                        for (q = g; q >= r; q--)
                            g = p.points[q].ia,
                            n.va(g.mW, g.nW),
                            g.kW == g.mW && g.lW == g.nW || n.va(g.kW, g.lW);
                    else
                        p = p.points[u].ia,
                        n.va(p.mW, p.nW),
                        n.close();
                a.renderer.Ia(m, l, h)
            }
            f = gvjs_4E([gvjs_at, c]);
            a.we(a.df.area.Kc, f, h.j());
            if (d) {
                e = gvjs_4G(b);
                d = gvjs_4E([gvjs_e, c]);
                e = e.Dc(a.renderer);
                f = gvjs_iH(a, b);
                if (e) {
                    h = b.Ko;
                    k = b.nj;
                    if (h || k) {
                        f = f || a.renderer.Sa();
                        if (h)
                            for (l = 0; l < h.levels.length; l++)
                                a.renderer.Ia(h.levels[l].path, h.levels[l].brush, f);
                        k && a.renderer.Ia(k.path, k.brush, f)
                    }
                    f && a.renderer.appendChild(f, e)
                }
                e = f ? f.j() : e;
                null != e && a.we(a.df.line.Kc, d, e);
                gvjs_jH(a, b, c)
            } else
                gvjs_kH(a, b, c, e)
        }
    } else
        gvjs_kH(a, b, c, a.Ea.Zj);
    if (b.Df && b.Df.paths)
        for (b = b.Df.paths,
        d = 0; e = b[d]; ++d)
            0 != e.line.length && (f = new gvjs_SA,
            gvjs_TA(f, e.line, e.kX),
            e.bottom && gvjs_TA(f, e.bottom, e.Pka),
            h = a.renderer.Sa(),
            a.renderer.Ia(f, e.brush, h),
            e = h.j(),
            f = gvjs_4E(["pathinterval", c, d]),
            a.we(a.df.pathinterval.Kc, f, e))
}
function gvjs_lH(a, b, c, d, e) {
    b.type == gvjs_lt || b.type == gvjs_4w ? a.Je(b, c, d, e) : b.type == gvjs_Ft ? gvjs_hH(a, c, d, e) : b.type == gvjs_At ? gvjs_mH(a, b, c, d, e, a.df.bubble.Kc) : gvjs_mH(a, b, c, d, e, a.df.point.Kc)
}
function gvjs_1ea(a, b, c) {
    var d = a.df.bubble.Kc
      , e = gvjs_lA(b.points.length, function(l) {
        return l
    });
    b.wxa && gvjs_Qe(e, function(l, m) {
        l = b.points[l];
        m = b.points[m];
        return (m ? m.ia.radius : 0) - (l ? l.ia.radius : 0)
    });
    for (var f = 0; f < e.length; f++) {
        var g = e[f]
          , h = b.points[g];
        if (h) {
            gvjs_mH(a, b, c, h, g, a.df.bubble.Kc);
            var k = a.renderer.me(h.text, h.ja);
            if (k.width < 2 * h.ia.radius || k.height < 2 * h.ia.radius)
                h = a.renderer.ce(h.text, h.ia.x, h.ia.y, h.textLength, gvjs_0, gvjs_0, h.ja, d),
                g = gvjs_4E([gvjs_yt, c, g]),
                a.renderer.kp(h, g)
        }
    }
}
function gvjs_gH(a, b, c) {
    for (var d = 0; d < b.points.length; d++)
        a.Je(b, c, b.points[d], d)
}
gvjs_.Je = function(a, b, c, d) {
    if (!gvjs_XG(c) && c.ia) {
        var e = c.brush || gvjs_WG(c, a)
          , f = a.type == gvjs_lt ? gvjs_wb : gvjs_5w
          , g = gvjs_4E([f, b, d])
          , h = c.ia.bar || c.ia;
        e = this.renderer.Bl(h.left, h.top, h.width, h.height, e);
        h = null;
        var k = c.ia.outline
          , l = c.Ko
          , m = c.nj;
        if (k || l || m) {
            h = this.renderer.Sa();
            this.renderer.appendChild(h, e);
            if (k) {
                var n = c.Oc || a.Oc;
                k = gvjs_UA(k, !0);
                this.renderer.Ia(k, n, h)
            }
            if (l)
                for (n = 0; n < l.levels.length; n++)
                    k = l.levels[n].rect,
                    this.renderer.yb(k.left, k.top, k.width, k.height, l.levels[n].brush, h);
            m && this.renderer.yb(m.rect.left, m.rect.top, m.rect.width, m.rect.height, m.brush, h)
        }
        e = h ? h.j() : e;
        this.we(this.df[f].Kc, g, e);
        c.tooltip && (f = gvjs_4E([gvjs_Pd, b, d]),
        gvjs_bH(this, c.tooltip, f));
        c.Bc && gvjs_dH(this, c.Bc, b, d);
        c.ia.mt && gvjs_nH(this, a, b, d, c.ia.mt)
    }
}
;
function gvjs_iH(a, b) {
    var c = null
      , d = null;
    gvjs_u(b.points, function(e, f) {
        gvjs__G(b, f) && (c || (c = a.renderer.Sa()),
        d || (d = gvjs_8z(b.Oc.Uj(), b.Oc.strokeOpacity)),
        e && !gvjs_ZG(e, b) && a.renderer.Ke(e.ia.x, e.ia.y, b.lineWidth, d, c))
    }, a);
    return c
}
function gvjs_kH(a, b, c, d) {
    var e = gvjs_4E([gvjs_e, c]);
    if (0 >= b.lineWidth)
        gvjs_QG(a, e),
        gvjs_jH(a, b, c);
    else {
        var f = gvjs_3G(b, d);
        if (0 != f.vc.length) {
            d = (f = f.Dc(a.renderer)) && d ? null : gvjs_iH(a, b);
            if (f) {
                var g = b.Ko
                  , h = b.nj;
                if (g || h) {
                    d || (d = a.renderer.Sa());
                    if (g)
                        for (var k = 0; k < g.levels.length; k++)
                            a.renderer.Ia(g.levels[k].path, g.levels[k].brush, d);
                    h && a.renderer.Ia(h.path, h.brush, d)
                }
                d && a.renderer.appendChild(d, f)
            }
            f = d ? d.j() : f;
            null != f && a.we(a.df.line.Kc, e, f);
            gvjs_jH(a, b, c)
        }
    }
}
function gvjs_0ea(a, b, c) {
    for (var d = 0, e = b.C.length; d < e; d += 2) {
        var f = b.C[d]
          , g = b.C[d + 1]
          , h = f.points.length;
        if (0 != h)
            for (var k = new gvjs_3({
                stroke: f.Qg.fill,
                strokeOpacity: f.Qg.fillOpacity,
                strokeWidth: 1
            }), l = 0; l < h; l++) {
                var m = f.points[l]
                  , n = g.points[l];
                !gvjs_XG(m) && m.ia && a.renderer.jY(m.ia.x, m.ia.y, n.ia.x, n.ia.y, k, c)
            }
    }
}
function gvjs_jH(a, b, c) {
    for (var d = 0; d < b.points.length; d++)
        gvjs_mH(a, b, c, b.points[d], d, a.df.point.Kc)
}
function gvjs_mH(a, b, c, d, e, f) {
    var g;
    if (g = !gvjs_XG(d) && d.ia)
        a: {
            var h = d.ia;
            g = gvjs_1G(d, b);
            var k = a.Ea.O;
            if (h.x - g >= k.right || h.x + g <= k.left || h.y - g >= k.bottom || h.y + g <= k.top)
                g = !1;
            else {
                if ((h.x >= k.right || h.x <= k.left) && (h.y >= k.bottom || h.y <= k.top)) {
                    g *= g;
                    var l = h.x - k.right
                      , m = h.x - k.left
                      , n = h.y - k.bottom;
                    h = h.y - k.top;
                    k = l * l;
                    m *= m;
                    n *= n;
                    h *= h;
                    if (k + n >= g && k + h >= g && m + h >= g && m + n >= g) {
                        g = !1;
                        break a
                    }
                }
                g = !0
            }
        }
    if (g) {
        g = gvjs_4E([b.type == gvjs_At ? gvjs_yt : gvjs_Np, c, e]);
        if (gvjs_ZG(d, b)) {
            n = a.we;
            h = gvjs_0G(d, b);
            k = gvjs_WG(d, b);
            m = null;
            var p = d.nj;
            l = d.Ko;
            var q = d.P8;
            if (p || l || q)
                m = a.renderer.Sa();
            q && a.renderer.Ia(q.path, q.brush, m);
            (q = d.shape) && q.type || (q = {
                type: gvjs_4o
            });
            p && gvjs_SG(a, p.x, p.y, p.radius + .5, p.brush, q, m);
            if (l)
                for (p = 0; p < l.levels.length; p++)
                    gvjs_SG(a, l.x, l.y, l.levels[p].radius, l.levels[p].brush, q, m);
            h = gvjs_SG(a, d.ia.x, d.ia.y, h, k, q);
            m && a.renderer.appendChild(m, h);
            m = m ? m.j() : h;
            n.call(a, f, g, m)
        } else
            gvjs_QG(a, g);
        d.tooltip && (f = gvjs_4E([gvjs_Pd, c, e]),
        gvjs_bH(a, d.tooltip, f));
        d.Bc && gvjs_dH(a, d.Bc, c, e);
        d.ia.mt && gvjs_nH(a, b, c, e, d.ia.mt)
    }
}
function gvjs_hH(a, b, c, d) {
    if (c && c.ia) {
        var e = a.renderer.Bl(c.ia.line.left, c.ia.line.top, c.ia.line.width, c.ia.line.height, c.Oc)
          , f = a.renderer.Bl(c.ia.rect.left, c.ia.rect.top, c.ia.rect.width, c.ia.rect.height, c.yG)
          , g = a.renderer.Sa();
        a.renderer.appendChild(g, e);
        a.renderer.appendChild(g, f);
        if (e = c.Ko)
            for (f = 0; f < e.levels.length; f++) {
                var h = e.levels[f].rect;
                a.renderer.yb(h.left, h.top, h.width, h.height, e.levels[f].brush, g)
            }
        (e = c.nj) && a.renderer.yb(e.rect.left, e.rect.top, e.rect.width, e.rect.height, e.brush, g);
        e = gvjs_4E([gvjs_Ct, b, d]);
        a.we(a.df.candlestick.Kc, e, g.j());
        c.tooltip && (b = gvjs_4E([gvjs_Pd, b, d]),
        gvjs_bH(a, c.tooltip, b))
    }
}
function gvjs_dH(a, b, c, d) {
    if (b) {
        var e = b.kga
          , f = a.Ea.O;
        if (!(!e || e.x < f.left || e.x > f.right) && (f = b.labels) && 0 != f.length) {
            var g = [gvjs_Zs, d];
            gvjs_fq(g, c, 1);
            g = gvjs_4E(g);
            var h = e.x
              , k = e.y
              , l = e.length;
            l = e.orientation == gvjs_S ? [l, 1] : [1, l];
            e = a.renderer.Bl(Math.min(h, h + l[0]), Math.min(k, k + l[1]), Math.abs(l[0]), Math.abs(l[1]), new gvjs_3({
                fill: e.color
            }));
            a.we(a.df.annotation.Kc, g, e);
            e = a.renderer.Sa();
            g = [gvjs_$s, d];
            gvjs_fq(g, c, 1);
            h = null;
            b.Rp && !b.Rp.Eba && (f = [b.Rp.label],
            h = -1);
            b = a.renderer.HH();
            for (k = 0; k < f.length; k++) {
                var m = f[k];
                if (l = gvjs_VG(a, m, !0)) {
                    if (m.xa) {
                        var n = gvjs_4E([gvjs_Pd, c, d, k]);
                        gvjs_bH(a, m.xa, n)
                    }
                    a.renderer.appendChild(e, l);
                    m = gvjs_Le(g);
                    m.push(h || k);
                    m = gvjs_4E(m);
                    a.registerElement(l, m)
                }
            }
            a.renderer.dC(b);
            c = gvjs_4E(g);
            a.we(a.df.annotationtext.Kc, c, e.j())
        }
    }
}
function gvjs_nH(a, b, c, d, e) {
    if (null != b.Df) {
        var f = a.renderer.Sa();
        b = b.Df.eu;
        for (var g = 0; g < e.length; g++) {
            var h = e[g].rect
              , k = b[e[g].ss];
            if (k && k.style != gvjs_at && k.style != gvjs_e) {
                var l = e[g].brush;
                0 == h.width && 0 == h.height ? (k = k.ava / 2,
                0 < k && (h = a.renderer.$x(h.left, h.top, k, l),
                a.renderer.appendChild(f, h))) : 0 == h.width || 0 == h.height ? (k = new gvjs_SA,
                k.move(h.left, h.top),
                k.va(h.left + h.width, h.top + h.height),
                a.renderer.Ia(k, l, f)) : a.renderer.appendChild(f, a.renderer.Bl(h.left, h.top, h.width, h.height, l))
            }
        }
        f.H && (c = gvjs_4E([gvjs_iv, c, d]),
        f = f.j(),
        a.we(a.df.interval.Kc, c, f))
    }
}
function gvjs_Zea(a, b, c) {
    gvjs_oH(a, c, function(d, e) {
        var f = null != d.length ? d.length : b.O.height
          , g = c.zp.Na;
        return a.renderer.yb(Math.floor(d.Na), Math.min(g, g + c.zp.direction * f), 1, f, d.brush, e)
    })
}
function gvjs__ea(a, b, c) {
    gvjs_oH(a, c, function(d, e) {
        var f = null != d.length ? d.length : b.O.width
          , g = c.zp.Na;
        return a.renderer.yb(Math.min(g, g + c.zp.direction * f), Math.floor(d.Na), f, 1, d.brush, e)
    })
}
function gvjs_oH(a, b, c) {
    (function(f, g, h) {
        if (f) {
            var k = a.df[g].Kc
              , l = gvjs_4E([b.name, g]);
            gvjs_u(f, function(m, n) {
                n = gvjs_4E([b.name, g, n]);
                gvjs_pH(a, m, h, k, n, l)
            })
        }
    }
    )(b.Ja, "gridline", c);
    var d = a.df.baseline.Kc
      , e = gvjs_4E([b.name, gvjs_Xo]);
    b.baseline && b.baseline.isVisible && null != b.baseline.za && Infinity != b.baseline.Na && gvjs_pH(a, b.baseline, c, d, e)
}
function gvjs_pH(a, b, c, d, e, f) {
    var g;
    if (g = b && b.isVisible)
        g = b.brush,
        g = !(!gvjs_gy(g) && !gvjs_ey(g));
    g && (b = c(b, d),
    a.registerElement(b, e, f))
}
function gvjs_fH(a, b) {
    var c = a.df
      , d = a.mv(b.title, c.axistitle.Kc, !0)
      , e = gvjs_4E([b.name, gvjs_fx]);
    a.registerElement(d, e);
    if (b.text) {
        var f = c.axistick.Kc
          , g = gvjs_4E([b.name, gvjs_8c]);
        gvjs_u(b.text, function(h, k) {
            h.isVisible && (h = a.mv(h.Da, f),
            k = gvjs_4E([b.name, gvjs_8c, k]),
            a.registerElement(h, k, g))
        })
    }
}
gvjs_.Dea = function(a, b) {
    this.VK(a);
    this.TV(a, b)
}
;
gvjs_.VK = function(a) {
    var b = this.Ms;
    if (b) {
        for (var c in b.C) {
            var d = Number(c)
              , e = a.C[d];
            if (gvjs_tA(b.C[d], gvjs_Ye({
                points: null
            }))) {
                var f = b.C[d].points, g;
                for (g in f) {
                    var h = Number(g)
                      , k = f[h];
                    if (k.tooltip) {
                        var l = gvjs_4E([gvjs_Pd, Number(d), Number(h)]);
                        gvjs_UG(this, l)
                    }
                    if (k = k.Bc)
                        for (var m in k.labels)
                            k.labels[m].xa && (l = gvjs_4E([gvjs_Pd, Number(d), Number(h), Number(m)]),
                            gvjs_UG(this, l));
                    gvjs_lH(this, e, Number(d), e.points[h], Number(h))
                }
            } else {
                for (var n in b.C[d].points)
                    b.C[d].points[n].tooltip && (f = gvjs_4E([gvjs_Pd, Number(d), Number(n)]),
                    gvjs_UG(this, f));
                gvjs_eH(this, e, Number(d))
            }
        }
        for (var p in b.$a)
            if (c = Number(p),
            d = b.$a[c],
            d.tooltip && (e = gvjs_4E([gvjs_Pd, Number(c)]),
            gvjs_UG(this, e)),
            d = d.Bc) {
                for (var q in d.labels)
                    d.labels[q].xa && (e = gvjs_4E([gvjs_Pd, null, Number(c), Number(q)]),
                    gvjs_UG(this, e));
                gvjs_dH(this, a.$a[c].Bc, null, Number(c))
            }
        gvjs_cH(this)
    }
}
;
gvjs_.TV = function(a, b) {
    for (var c in b.C) {
        var d = Number(c)
          , e = a.C[d];
        if (gvjs_tA(b.C[d], gvjs_Ye({
            points: null
        })))
            for (var f in b.C[d].points) {
                var g = Number(f)
                  , h = new gvjs_9F(2);
                gvjs_$F(h, 0, e.points[g]);
                gvjs_$F(h, 1, b.C[d].points[g]);
                h = h.compact();
                gvjs_lH(this, e, Number(d), h, Number(g))
            }
        else
            g = new gvjs_9F(2),
            gvjs_$F(g, 0, e),
            gvjs_$F(g, 1, b.C[d]),
            e = g.compact(),
            gvjs_eH(this, e, Number(d))
    }
    for (var k in b.$a)
        c = Number(k),
        b.$a[c].tooltip && (d = gvjs_4E([gvjs_Pd, Number(c)]),
        gvjs_bH(this, b.$a[c].tooltip, d)),
        b.$a[c].Bc && (d = new gvjs_9F(2),
        gvjs_$F(d, 0, a.$a[c].Bc),
        gvjs_$F(d, 1, b.$a[c].Bc),
        d = d.compact(),
        gvjs_dH(this, d, null, Number(c)));
    gvjs_cH(this)
}
;
function gvjs_qH(a, b, c, d, e, f) {
    this.$d = a;
    this.Qa = b;
    this.dz = c;
    this.Lv = d;
    this.ssa = e;
    this.Qb = f
}
function gvjs_rH(a, b, c) {
    return new gvjs_qH(a,b,!1,!1,!1,c)
}
gvjs_qH.prototype.getPosition = function() {
    return Math.round(this.Qa)
}
;
gvjs_qH.prototype.getValue = function() {
    return this.$d
}
;
gvjs_qH.prototype.Dd = function() {
    return this.Qb
}
;
gvjs_qH.prototype.In = function(a) {
    this.Qb = a
}
;
function gvjs_sH() {}
gvjs_sH.prototype.floor = function() {}
;
gvjs_sH.prototype.ceil = function() {}
;
gvjs_sH.prototype.round = function() {}
;
function gvjs_tH() {}
gvjs_tH.prototype.La = function() {}
;
gvjs_tH.prototype.getHeight = function() {}
;
gvjs_tH.prototype.bt = function() {}
;
function gvjs_uH(a, b) {
    this.WT = a;
    this.UR = void 0 === b ? 0 : b;
    this.Qa = 0
}
gvjs_o(gvjs_uH, gvjs_sH);
gvjs_ = gvjs_uH.prototype;
gvjs_.next = function() {
    this.Qa++;
    return this.getValue()
}
;
gvjs_.he = function() {
    this.Qa--;
    return this.getValue()
}
;
gvjs_.getValue = function() {
    return gvjs_qA(15, this.Qa * this.WT + this.UR)
}
;
gvjs_.floor = function(a) {
    this.Qa = Math.floor((a - this.UR) / this.WT);
    return this.getValue()
}
;
gvjs_.ceil = function(a) {
    this.Qa = Math.ceil((a - this.UR) / this.WT);
    return this.getValue()
}
;
gvjs_.round = function(a) {
    this.Qa = Math.round((a - this.UR) / this.WT);
    return this.getValue()
}
;
function gvjs_vH(a) {
    this.Gta = a.concat();
    this.DJ = a.length;
    this.Qa = 0
}
gvjs_o(gvjs_vH, gvjs_sH);
gvjs_ = gvjs_vH.prototype;
gvjs_.next = function() {
    this.Qa++;
    return this.getValue()
}
;
gvjs_.he = function() {
    this.Qa--;
    return this.getValue()
}
;
gvjs_.getValue = function() {
    var a = Math.floor(this.Qa / this.DJ);
    return gvjs_8E(this.Gta[this.Qa - a * this.DJ], a)
}
;
gvjs_.floor = function(a) {
    this.Qa = this.DJ * gvjs_$E(a);
    if (this.getValue() != a)
        for (; this.he() > a; )
            ;
    return this.getValue()
}
;
gvjs_.ceil = function(a) {
    this.Qa = this.DJ * gvjs_9E(a);
    if (this.getValue() != a)
        for (; this.next() < a; )
            ;
    return this.getValue()
}
;
gvjs_.round = function(a) {
    this.Qa = this.DJ * gvjs_$E(a);
    if (this.getValue() != a) {
        for (; this.he() > a; )
            ;
        if (a - this.getValue() < this.next() - a)
            return this.he()
    }
    return this.getValue()
}
;
function gvjs_wH(a) {
    var b = 0;
    gvjs_u(a, function(c) {
        b = Math.max(b, gvjs_pA(c))
    });
    return b
}
;function gvjs_xH(a, b, c, d) {
    this.aR = b;
    this.Yc = new gvjs_gk({
        pattern: a
    });
    this.lxa = c;
    this.$ua = d
}
gvjs_xH.prototype.format = function(a) {
    a /= this.aR;
    return this.Yc.Ob(a) + " " + (2 > Math.abs(a) ? this.lxa : this.$ua)
}
;
gvjs_Xi.prototype.format = gvjs_Xi.prototype.format;
gvjs_Xi.Format = {
    FULL_DATE: 0,
    LONG_DATE: 1,
    MEDIUM_DATE: 2,
    SHORT_DATE: 3,
    FULL_TIME: 4,
    LONG_TIME: 5,
    MEDIUM_TIME: 6,
    SHORT_TIME: 7,
    FULL_DATETIME: 8,
    LONG_DATETIME: 9,
    MEDIUM_DATETIME: 10,
    SHORT_DATETIME: 11
};
var gvjs_yH = gvjs_2i;
gvjs_1j.Format = {
    DECIMAL: 1,
    SCIENTIFIC: 2,
    PERCENT: 3,
    CURRENCY: 4,
    COMPACT_SHORT: 5,
    COMPACT_LONG: 6
};
gvjs_1j.prototype.format = gvjs_1j.prototype.format;
gvjs_1j.prototype.setMinimumFractionDigits = gvjs_1j.prototype.setMinimumFractionDigits;
gvjs_1j.prototype.setMaximumFractionDigits = gvjs_1j.prototype.setMaximumFractionDigits;
gvjs_1j.prototype.setSignificantDigits = gvjs_1j.prototype.setSignificantDigits;
gvjs_1j.setEnforceAsciiDigits = function(a) {
    gvjs_3j = a
}
;
gvjs_1j.isEnforceAsciiDigits = function() {
    return gvjs_3j
}
;
gvjs_Ui.createTimeZone = gvjs_Vi;
function gvjs_zH() {
    this.jR = this.RJ = null;
    this.ZD = [];
    this.y$ = this.$A = this.hK = null;
    this.DF = !0
}
gvjs_ = gvjs_zH.prototype;
gvjs_.yR = function(a) {
    this.RJ = a;
    this.DF = !0;
    return this
}
;
gvjs_.nw = function(a) {
    this.jR = a;
    this.DF = !0;
    return this
}
;
gvjs_.gK = function(a) {
    this.hK = a;
    this.DF = !0;
    return this
}
;
gvjs_.unit = function(a) {
    this.$A = a;
    this.DF = !0;
    return this
}
;
gvjs_.M5 = function(a) {
    a = gvjs_aA(0, typeof a === gvjs_g ? a : 3);
    this.ZD = [new gvjs_xH(a,Math.pow(10, 15),"Quadrillion","Quadrillion"), new gvjs_xH(a,Math.pow(10, 12),"Trillion","Trillion"), new gvjs_xH(a,Math.pow(10, 9),"Billion","Billion"), new gvjs_xH(a,Math.pow(10, 6),"Million","Million")];
    return this
}
;
gvjs_.P5 = function(a) {
    a = gvjs_aA(0, typeof a === gvjs_g ? a : 3);
    this.ZD = [new gvjs_xH(a,Math.pow(10, 15),"Q","Q"), new gvjs_xH(a,Math.pow(10, 12),"T","T"), new gvjs_xH(a,Math.pow(10, 9),"B","B"), new gvjs_xH(a,Math.pow(10, 6),"M","M")];
    return this
}
;
gvjs_.cd = function() {
    var a = gvjs_x(this.y$);
    if (this.DF && null == a.pattern)
        if (typeof this.RJ === gvjs_g || typeof this.jR === gvjs_g) {
            var b = typeof this.RJ === gvjs_g ? this.RJ : 0;
            a.pattern = gvjs_aA(b, typeof this.jR === gvjs_g ? this.jR : typeof this.RJ === gvjs_g ? b : 15)
        } else
            a.pattern = gvjs_Nb,
            null == a.significantDigits && (a.significantDigits = this.hK);
    return new gvjs_AH(new gvjs_gk(a),this.ZD,this.hK,this.$A)
}
;
function gvjs_AH(a, b, c, d) {
    this.o9 = a;
    this.ZD = b || [];
    this.hK = c || null;
    this.$A = d || null
}
gvjs_AH.prototype.format = function(a) {
    var b = 0 > a;
    a = Math.abs(a);
    a = gvjs_qA(this.hK || 15, a);
    for (var c = null, d = 0; d < this.ZD.length; d++) {
        var e = this.ZD[d];
        if (a >= e.aR) {
            c = e.format(a);
            break
        }
    }
    null == c && (c = this.o9.Ob(a));
    this.$A && (a = this.$A.symbol,
    d = this.$A.usePadding ? " " : "",
    c = this.$A.position == gvjs_j ? c + d + a : a + d + c);
    return b ? "-" + c : c
}
;
gvjs_AH.prototype.Ob = function(a) {
    return this.format(a)
}
;
gvjs_AH.prototype.parse = function(a) {
    return this.o9.parse(a)
}
;
function gvjs_BH(a, b, c, d) {
    this.na = a;
    this.Qf = b;
    this.tb = c;
    this.uq = d;
    this.Jt = this.Yc = null
}
function gvjs_CH(a) {
    a.uq && (a.uq.gK(15),
    a.Yc = a.uq.cd())
}
function gvjs_2ea(a, b) {
    a.uq && (b = gvjs_wH(b),
    a.uq.yR(b),
    a.uq.nw(b))
}
function gvjs_DH(a, b, c) {
    var d;
    return gvjs_Ge(b, function(e, f) {
        f = 0 == f ? !0 : Math.abs(a.na.Ya(e) - a.na.Ya(d)) >= c;
        d = e;
        return f
    })
}
function gvjs_EH(a, b, c) {
    if (null == c)
        return !0;
    a.Jt && a.Jt.multiple === c || (a.Jt = {},
    a.Jt.multiple = c,
    a.Jt.gda = Math.pow(10, gvjs_pA(c || 1)),
    a.Jt.xta = Math.round(c * a.Jt.gda));
    return 1E-15 > Math.abs(gvjs_qA(15, b * a.Jt.gda) % a.Jt.xta)
}
function gvjs_FH(a, b) {
    if (!a.Yc)
        return !0;
    var c = {};
    return gvjs_Ge(b, function(d) {
        var e = a.Yc.Ob(d);
        return null == c[e] ? (c[e] = d,
        !0) : !1
    })
}
function gvjs_GH(a, b) {
    if (!a.Yc)
        return !0;
    var c = b.length;
    if (0 < c) {
        if (gvjs_HH(a, b[0], b[1]))
            return !1;
        for (; 1 < --c; )
            if (gvjs_HH(a, b[c - 1], b[c]))
                return !1
    }
    return !0
}
function gvjs_HH(a, b, c) {
    var d = gvjs_IH(a, b)
      , e = gvjs_IH(a, c);
    return Math.abs(a.na.Ya(b) - a.na.Ya(c)) < (d + e) / 2
}
function gvjs_IH(a, b) {
    b = a.Yc.Ob(b);
    return a.Qf.bt(b, a.tb)
}
function gvjs_JH(a, b, c) {
    b = a.na.Ae(b);
    a = a.na.Ae(c);
    return Math.abs(a - b)
}
function gvjs_KH(a, b) {
    return gvjs_v(b, function(c) {
        c = gvjs_qA(15, c);
        var d = a.na.Ya(c)
          , e = a.Yc ? a.Yc.Ob(c) : "";
        return new gvjs_qH(c,d,!0,!0,!0,e)
    })
}
function gvjs_LH(a, b) {
    for (var c = [], d = 0; d < b.length; d++) {
        var e = b[d]
          , f = c
          , g = f.push
          , h = a.na.Ya(e);
        g.call(f, new gvjs_qH(e,h,!0,!0,!1,null))
    }
    return c
}
function gvjs_MH(a, b, c, d, e, f) {
    if (c == d)
        return [c];
    if (!isFinite(c))
        return [d];
    var g = []
      , h = b.floor(c);
    c = null;
    do
        (null == e || gvjs_EH(a, h, e)) && (0 === h || null == f || Math.abs(h) >= f) && (g.push(h),
        c = h),
        h = b.next();
    while (null == c || c < d);
    return g
}
;function gvjs_NH(a, b, c, d, e, f) {
    var g = this;
    this.na = a;
    this.m = f;
    this.Gt = gvjs_L(this.m, gvjs_Vu);
    this.a1 = gvjs_L(this.m, gvjs_Tv, this.Gt / 2);
    this.Pd = new gvjs_BH(a,c,e,b);
    this.PA = d;
    a = this.m.fa(gvjs_Uu, gvjs_3ea);
    a = typeof a === gvjs_g ? [a] : Array.isArray(a) ? a : [];
    b = this.m.fa(gvjs_Sv, gvjs_4ea);
    var h = typeof b === gvjs_g ? [b] : Array.isArray(b) ? b : [];
    this.JR = this.m.Aa(gvjs_Wu);
    this.OD = this.m.Aa(gvjs_Uv);
    this.GA = new gvjs_vH(a);
    this.zL = {};
    gvjs_u(a, function(k) {
        var l = [];
        gvjs_u(h, function(m) {
            Number.isInteger(10 * k / m) && l.push(m)
        });
        g.zL[k.toString()] = l
    })
}
gvjs_NH.prototype.mP = function(a, b) {
    function c(n) {
        return d.PA ? (n = gvjs_KH(d.Pd, n),
        d.PA(n)) : gvjs_GH(d.Pd, n)
    }
    var d = this;
    a = null != a ? a : this.na.Yb();
    b = null != b ? b : this.na.$b();
    var e = b - a
      , f = Math.min(e, gvjs_5ea(this));
    if (0 === f)
        return {
            dk: [],
            DR: []
        };
    this.GA.floor(f);
    var g = !1
      , h = null
      , k = null
      , l = null;
    do {
        var m = new gvjs_uH(f);
        h = [];
        gvjs_EH(this.Pd, f, this.JR) && (h = gvjs_MH(this.Pd, m, a, b, this.JR, null));
        if (h.length)
            if (gvjs_2ea(this.Pd, h),
            gvjs_CH(this.Pd),
            gvjs_DH(this.Pd, h, this.Gt) && gvjs_FH(this.Pd, h) && c(h)) {
                g = !0;
                break
            } else if (g)
                break;
        f = this.GA.next()
    } while (f <= e);
    return function() {
        k || (k = h,
        l = f);
        var n = gvjs_KH(d.Pd, k)
          , p = d.EZ(l);
        return {
            dk: n,
            DR: p
        }
    }()
}
;
gvjs_NH.prototype.EZ = function(a) {
    var b = this.na.Yb()
      , c = this.na.$b()
      , d = []
      , e = gvjs_qA(15, a / Math.pow(10, Math.floor(Math.log10(a))));
    e = this.zL[e.toString()] || [];
    if (0 === e.length)
        return d;
    var f = new gvjs_vH(e);
    f.floor(a / 20);
    e = f.getValue();
    do {
        if (Number.isInteger(a / e)) {
            var g = new gvjs_uH(e)
              , h = [];
            gvjs_EH(this.Pd, e, this.OD) && (h = gvjs_MH(this.Pd, g, b, c, this.OD, null));
            if (h.length && gvjs_DH(this.Pd, h, this.a1)) {
                d = gvjs_LH(this.Pd, h);
                break
            }
        }
        e = f.next()
    } while (e < a);
    return d
}
;
function gvjs_5ea(a) {
    var b = a.na.Ho()
      , c = a.na.an()
      , d = gvjs_JH(a.Pd, c, c - a.Gt)
      , e = gvjs_JH(a.Pd, b, b + a.Gt);
    d = Math.max(e, d);
    e = a.na.Ya(0);
    b <= e === e <= c && (b = a.na.Ae(e + a.Gt),
    d = Math.max(d, b));
    return 0 === d ? 0 : a.GA.ceil(d)
}
var gvjs_3ea = [1, 2, 2.5, 5]
  , gvjs_4ea = [1, 1.5, 2, 2.5, 5];
function gvjs_OH(a, b, c, d) {
    this.so = a;
    this.iq = b;
    this.o3 = c;
    this.hfa = d;
    this.ny = (this.hfa - this.o3) / (this.iq - this.so);
    this.YK = this.ny * this.so - this.o3
}
gvjs_ = gvjs_OH.prototype;
gvjs_.Ae = function(a) {
    return (a + this.YK) / this.ny
}
;
gvjs_.Ya = function(a) {
    return a * this.ny - this.YK
}
;
gvjs_.Ho = function() {
    return this.o3
}
;
gvjs_.an = function() {
    return this.hfa
}
;
gvjs_.Yb = function() {
    return this.so
}
;
gvjs_.$b = function() {
    return this.iq
}
;
function gvjs_PH(a, b) {
    this.PR = a;
    this.eK = Math.floor(a / 10);
    this.Wr = a - this.eK;
    this.lc = 0;
    this.uR = gvjs_9E(Math.abs(b));
    this.jB = this.Wr * this.uR;
    this.Qa = 0
}
gvjs_o(gvjs_PH, gvjs_sH);
function gvjs_QH(a) {
    var b = Math.floor(a.Qa / a.Wr);
    a = 10 * (a.Qa + a.eK - b * a.Wr) / a.PR;
    0 == a && (a = 1);
    return gvjs_8E(a, b)
}
gvjs_ = gvjs_PH.prototype;
gvjs_.getValue = function() {
    this.Qa = Math.abs(this.lc) + this.jB;
    return 0 < this.lc ? gvjs_QH(this) : 0 > this.lc ? -gvjs_QH(this) : 0
}
;
gvjs_.next = function() {
    this.lc++;
    return this.getValue()
}
;
gvjs_.he = function() {
    this.lc--;
    return this.getValue()
}
;
gvjs_.floor = function(a) {
    var b = this.eK
      , c = gvjs_9E(Math.abs(a));
    if (Math.abs(a) <= Math.pow(10, this.uR))
        return this.lc = 0 > a ? -1 : 0,
        this.getValue();
    0 < a ? this.lc = this.Wr * c - this.jB : 0 > a && (this.lc = this.jB - this.Wr * c,
    b = -b);
    this.getValue() != a && (c = this.PR * a / gvjs_8E(1, gvjs_$E(Math.abs(a))),
    this.lc += Math.floor(c) - b);
    return this.getValue()
}
;
gvjs_.ceil = function(a) {
    var b = this.eK
      , c = gvjs_9E(Math.abs(a));
    if (Math.abs(a) <= Math.pow(10, this.uR))
        return this.lc = 0 < a ? 1 : 0,
        this.getValue();
    0 < a ? this.lc = this.Wr * c - this.jB : 0 > a && (this.lc = this.jB - this.Wr * c,
    b = -b);
    this.getValue() != a && (c = this.PR * a / gvjs_8E(1, gvjs_$E(Math.abs(a))),
    this.lc += Math.ceil(c) - b);
    return this.getValue()
}
;
gvjs_.round = function(a) {
    var b = gvjs_9E(Math.abs(a));
    if (Math.abs(a) <= Math.pow(10, this.uR))
        return this.lc = 0;
    if (0 < a) {
        this.lc = this.Wr * b - this.jB;
        if (this.next() > a)
            return a - this.getValue() >= this.he() - a ? this.next() : this.getValue();
        this.he()
    } else if (0 > a) {
        this.lc = this.jB - this.Wr * b;
        if (this.he() < a)
            return a - this.getValue() < this.next() - a ? this.he() : this.getValue();
        this.next()
    }
    this.getValue() != a && (b = this.PR * a / gvjs_8E(1, gvjs_$E(Math.abs(a))),
    this.lc += Math.round(b) - this.eK);
    return this.getValue()
}
;
function gvjs_RH(a, b, c, d, e, f, g) {
    var h = this;
    this.na = a;
    this.Yf = Math.abs(g) || 1;
    this.m = f;
    this.Gt = gvjs_L(this.m, gvjs_Vu);
    this.a1 = gvjs_L(this.m, gvjs_Tv, this.Gt / 5);
    this.Pd = new gvjs_BH(a,c,e,b);
    this.PA = d;
    a = this.m.fa(gvjs_Uu, gvjs_6ea);
    a = typeof a === gvjs_g ? [a] : Array.isArray(a) ? a : [];
    b = this.m.fa(gvjs_Sv, gvjs_7ea);
    var k = typeof b === gvjs_g ? [b] : Array.isArray(b) ? b : [];
    this.GA = new gvjs_vH(a);
    b = gvjs_v(a, function(l) {
        for (l = 10 / l; 10 <= l; )
            l /= 10;
        return l
    }).sort();
    this.bF = new gvjs_vH(b);
    this.zL = {};
    gvjs_u(a, function(l) {
        var m = [];
        gvjs_u(k, function(n) {
            Number.isInteger(10 * l / n) && m.push(n)
        });
        h.zL[l.toString()] = m
    });
    this.JR = this.m.Aa(gvjs_Wu);
    this.OD = this.m.Aa(gvjs_Uv)
}
gvjs_RH.prototype.mP = function(a, b) {
    function c(q) {
        return 0 < q.length && (q[0] > a || q[q.length - 1] < b) || !gvjs_DH(e.Pd, q, e.Gt) || !gvjs_FH(e.Pd, q) ? !1 : e.PA ? (q = gvjs_KH(e.Pd, q),
        e.PA(q)) : gvjs_GH(e.Pd, q)
    }
    function d(q, r) {
        var t = e.Pd
          , u = []
          , v = q.length
          , w = t.na.Ya(0);
        if (w != t.na.Ya(q[0]) && w != t.na.Ya(q[v - 1])) {
            for (var x = 0; x < v; x++)
                0 !== q[x] && w == t.na.Ya(q[x]) || u.push(q[x]);
            q = u
        }
        t = gvjs_KH(e.Pd, q);
        r = e.EZ(r);
        return {
            dk: t,
            DR: r
        }
    }
    var e = this;
    a = null != a ? a : this.na.Yb();
    b = null != b ? b : this.na.$b();
    var f = b - a
      , g = this.Yf
      , h = gvjs_8ea(this)
      , k = gvjs_MH(this.Pd, new gvjs_PH(h,g), a, b, null, this.Yf)
      , l = Math.min(f, 10 / h)
      , m = k
      , n = l;
    gvjs_CH(this.Pd);
    if (2 > k.length)
        return d(k, l);
    var p = !1;
    if (c(k))
        p = !0;
    else {
        l = k[0] || g;
        k = k[1];
        l === k && (l /= 10);
        this.bF.ceil(Math.max(1, gvjs_8E(1, gvjs_$E(Math.abs(l))) / Math.abs(k - l)));
        h = this.bF.getValue();
        this.GA.floor(10 / h);
        l = this.GA.getValue();
        do {
            h = 10 / l;
            h = new gvjs_PH(h,g);
            k = [];
            gvjs_EH(this.Pd, l, this.OD) && (k = gvjs_MH(this.Pd, h, a, b, this.JR, this.Yf));
            if (c(k)) {
                p = !0;
                break
            }
            l = this.GA.next()
        } while (l < f);
        p || (k = m,
        l = n)
    }
    return d(k, l)
}
;
gvjs_RH.prototype.EZ = function(a) {
    var b = this.na.Yb()
      , c = this.na.$b()
      , d = []
      , e = gvjs_qA(15, a / Math.pow(10, Math.floor(Math.log10(a))));
    e = this.zL[e.toString()] || [];
    if (0 === e.length)
        return d;
    var f = new gvjs_vH(e);
    f.floor(a / 20);
    e = f.getValue();
    do {
        if (Number.isInteger(a / e)) {
            var g = new gvjs_PH(gvjs_qA(15, 10 / e),this.Yf)
              , h = [];
            gvjs_EH(this.Pd, e, this.OD) && (h = gvjs_MH(this.Pd, g, b, c, this.OD, this.Yf));
            if (h.length && gvjs_DH(this.Pd, h, this.a1)) {
                d = gvjs_LH(this.Pd, h);
                break
            }
        }
        e = f.next()
    } while (e < a);
    return d
}
;
function gvjs_8ea(a) {
    var b = a.na.Ya(10 * a.Yf);
    a.bF.floor(1);
    do {
        var c = a.bF.next();
        c = a.na.Ya(10 * a.Yf * (c - 1) / c)
    } while (Math.abs(b - c) >= a.Gt);
    c = a.bF.he();
    1 > c && (c = a.bF.next());
    return c
}
var gvjs_6ea = [1, 2, 5]
  , gvjs_7ea = [1, 2, 5];
function gvjs_SH(a, b, c, d, e, f, g, h, k, l, m, n, p) {
    e && (e = c,
    c = d,
    d = e);
    this.so = a;
    this.iq = b;
    this.Jw = c;
    this.xE = d;
    this.d0 = f;
    this.Yf = g;
    this.tb = h;
    this.m = k;
    this.Qf = l;
    this.uq = m;
    this.PA = n;
    this.xca = p;
    gvjs_TH(this)
}
function gvjs_TH(a) {
    a.na = 1 == a.d0 ? new gvjs_OH(a.so,a.iq,a.Jw,a.xE) : new gvjs_aF(a.so,a.iq,a.Jw,a.xE,a.d0,a.Yf);
    a.xca && a.xca(a.na)
}
function gvjs_UH(a, b, c) {
    if (a.so == a.iq)
        return b = a.Jw + (a.xE - a.Jw) / 2,
        c = "",
        a.uq && (c = a.uq.cd().format(a.so)),
        {
            dk: [gvjs_rH(a.so, b, c)]
        };
    var d = a.na
      , e = a.m
      , f = a.Yf
      , g = a.d0
      , h = a.tb
      , k = a.Qf
      , l = a.uq;
    a = a.PA;
    return (.65 < gvjs_9ea(d) && .5 < g ? new gvjs_NH(d,l,k,a,h,e) : new gvjs_RH(d,l,k,a,h,e,f)).mP(b, c)
}
function gvjs_VH(a, b, c, d, e) {
    var f = 100;
    do {
        if (0 > f--)
            break;
        a.so = b;
        a.iq = c;
        gvjs_TH(a);
        var g = b;
        var h = c;
        var k = gvjs_UH(a, b, c);
        var l = k.dk;
        1 < l.length && (null != d && (b = l[0].getValue()),
        null != e && (c = l[l.length - 1].getValue()));
        g = b != g || c != h;
        if (isNaN(b) || isNaN(c))
            g = !1,
            b = null != d ? d : b,
            c = null != e ? e : c
    } while (g);
    k.min = b;
    k.max = c;
    return k
}
function gvjs_$ea(a, b, c, d, e) {
    var f = .005 * (b - a);
    return gvjs_VH(new gvjs_SH(a - f,b + f,c,d,!1,1,0,gvjs_S,e,null,null,null,null), a, b, null, null).dk
}
function gvjs_9ea(a) {
    function b(l, m) {
        var n = m.Ae(l);
        l = m.Ae(l + 10);
        return Math.abs(l - n)
    }
    if (a.Yb() == a.$b())
        return 1;
    var c = Math.min(a.Ho(), a.an())
      , d = Math.max(a.Ho(), a.an())
      , e = a.Ya(0)
      , f = Math.abs(a.Ae(c))
      , g = Math.abs(a.Ae(d))
      , h = Math.max(f, g)
      , k = 0;
    if (c > e || e > d)
        k = Math.min(f, g);
    c = a.Ya(k);
    h = a.Ya(h);
    return b(c, a) / b(h, a)
}
;function gvjs_WH(a, b) {
    this.Ww = a;
    this.Za = b
}
gvjs_o(gvjs_WH, gvjs_tH);
gvjs_WH.prototype.La = function(a) {
    return this.Ww(a, this.Za).width
}
;
gvjs_WH.prototype.getHeight = function(a) {
    return this.Ww(a, this.Za).height
}
;
gvjs_WH.prototype.bt = function(a, b) {
    return b == gvjs_S ? this.La(a) : this.getHeight(a)
}
;
function gvjs_afa(a, b) {
    if (a) {
        if (b.length != a.length)
            throw Error("colorsScale and valuesScale must be of the same length");
    } else if (1 !== b.length)
        throw Error("colorsScale must contain exactly one element when no valueScale is provided");
    this.pl = a;
    this.Zu = gvjs_v(b, function(c) {
        return gvjs_qj(c).hex
    })
}
function gvjs_XH(a, b) {
    if (!a.pl)
        return a.Zu[0];
    if (b >= a.pl[a.pl.length - 1])
        return a.Zu[a.Zu.length - 1];
    if (b <= a.pl[0])
        return a.Zu[0];
    var c = gvjs_Iy(a.pl, b);
    if (0 <= c)
        return a.Zu[c];
    var d = -c - 2;
    c = -c - 1;
    return gvjs_7z(a.Zu[c], a.Zu[d], (b - a.pl[d]) / (a.pl[c] - a.pl[d]))
}
function gvjs_bfa(a, b) {
    b && 0 !== b.length ? 1 === b.length && (b = [gvjs_YH[0], b[0]]) : b = a && 3 === a.length ? gvjs_ZH : gvjs_YH;
    if (!a || 2 > a.length)
        return {
            values: null,
            dX: [gvjs_Ae(b)]
        };
    var c = a[0]
      , d = a[a.length - 1]
      , e = d - c;
    if (0 === e)
        return {
            values: [d],
            dX: [gvjs_Ae(b)]
        };
    if (2 === a.length)
        for (a = [],
        d = e / (b.length - 1),
        e = 0; e < b.length; e++)
            a.push(c + d * e);
    return {
        values: a,
        dX: b
    }
}
function gvjs__H(a, b) {
    var c = a.view("colorAxis")
      , d = null
      , e = c.$I("values");
    if (e && 0 < e.length) {
        1 === e.length && (e = [e[0], e[0]]);
        b && (null == e[0] && (e[0] = b.start),
        null == e[e.length - 1] && (e[e.length - 1] = b.end));
        if (null == e[0])
            throw Error(gvjs_0t);
        for (d = 1; d < e.length; d++) {
            if (null == e[d])
                throw Error(gvjs_0t);
            if (e[d] < e[d - 1])
                throw Error("colorAxis.values must be a monotonically increasing series");
        }
        d = e
    } else {
        e = c.Aa(gvjs_ed);
        var f = c.Aa(gvjs_cd);
        if (null != e && null != f && e > f)
            throw Error("colorAxis.minValue (" + e + ") must be at most colorAxis.maxValue (" + f + ")");
        (b = gvjs_9B(b, e, f)) && (d = [b.start, b.end])
    }
    a = gvjs_Fj(a, gvjs_Ij, [], gvjs_2t, void 0, void 0);
    a = gvjs_Fj(c, gvjs_Ij, [], gvjs_2t, a, void 0);
    b = c.fa("one-sided-colors", gvjs_YH);
    c = c.fa("two-sided-colors", gvjs_ZH);
    a && 0 !== a.length ? 1 === a.length && (a = [b[0], a[0]]) : a = d && 3 === d.length ? c : b;
    c = gvjs_bfa(d, a);
    return new gvjs_afa(c.values,c.dX)
}
var gvjs_YH = ["#EFE6DC", gvjs_lr]
  , gvjs_ZH = [gvjs_vr, "#EFE6DC", gvjs_lr];
function gvjs_0H(a, b, c, d) {
    var e = {}
      , f = b.numberFormat || gvjs_mk;
    if (b.orientation == gvjs_S) {
        e = b.ja;
        var g = a.pl[0];
        var h = a.pl[a.pl.length - 1];
        f = new gvjs_gk({
            pattern: f
        });
        g = f.Ob(g);
        h = f.Ob(h);
        e = {
            minValue: {
                text: g,
                width: d ? d(g, e).width : 0,
                height: e.fontSize
            },
            maxValue: {
                text: h,
                width: d ? d(h, e).width : 0,
                height: e.fontSize
            }
        };
        d = e.minValue.height / 4;
        g = new gvjs_5(e.minValue.width + d,0,b.width - (e.minValue.width + e.maxValue.width + 2 * d),b.height)
    } else
        g = new gvjs_5(0,0,b.width,b.height);
    d = .33 * g.height;
    h = d / Math.sqrt(3) * 2;
    f = new gvjs_5(g.left + h / 2,g.top + d + 1,g.width - h,g.height - d - 1);
    var k = a.Zu
      , l = a.pl
      , m = l[l.length - 1] - l[0];
    if (0 == m)
        var n = [{
            sh: new gvjs_5(f.left,f.top,f.width,f.height),
            brush: new gvjs_3({
                fill: k[0]
            })
        }];
    else {
        n = [];
        m = f.width / m;
        for (var p = f.left, q, r = 0; r < l.length - 1; ++r)
            q = p + (l[r + 1] - l[r]) * m,
            n[r] = {
                sh: new gvjs_5(p,f.top,q - p,f.height),
                brush: new gvjs_3({
                    gradient: {
                        x1: p,
                        y1: 0,
                        x2: q,
                        y2: 0,
                        Vf: k[r],
                        sf: k[r + 1]
                    }
                })
            },
            p = q
    }
    f = n;
    if (null != f && 0 < f.length && (0 > f[0].sh.width || 0 > f[0].sh.height))
        return null;
    k = g;
    l = b.zca;
    g = [];
    for (n = 0; n < c.length; ++n)
        m = c[n].value,
        p = a.pl,
        m < p[0] ? m = 0 : (q = k.width - h,
        m > p[p.length - 1] ? m = q : (r = p[p.length - 1] - p[0],
        m = 0 == r ? .5 * q : (m - p[0]) / r * q)),
        m = k.left + m + h / 2,
        m = [m - h / 2, k.top, m + h / 2, k.top, m, k.top + d],
        p = new gvjs_3({
            fill: l,
            stroke: l
        }),
        g[n] = {
            path: m,
            brush: p
        };
    a = [];
    b.orientation == gvjs_S && (a = e,
    c = [],
    c[0] = {
        x: 0,
        y: b.height - a.minValue.height,
        text: a.minValue.text,
        style: b.ja
    },
    c[1] = {
        x: b.width - a.maxValue.width,
        y: b.height - a.maxValue.height,
        text: a.maxValue.text,
        style: b.ja
    },
    a = c);
    a = {
        XW: f,
        G0: g,
        V4: a
    };
    e = a.XW;
    for (c = 0; c < e.length; ++c)
        d = e[c],
        b.orientation == gvjs_U && (h = d.sh.left,
        d.sh.left = d.sh.top,
        d.sh.top = h,
        h = d.sh.width,
        d.sh.width = d.sh.height,
        d.sh.height = h),
        d.sh.left += b.left,
        d.sh.top += b.top,
        h = d.brush.clone(),
        d.brush = h,
        d = h.gradient,
        b.orientation == gvjs_U && (d.y1 = d.x1,
        d.x1 = 0,
        d.y2 = d.x2,
        d.x2 = 0),
        null != d && (d.x1 += b.left,
        d.y1 += b.top,
        d.x2 += b.left,
        d.y2 += b.top);
    e = a.G0;
    for (c = 0; c < e.length; ++c)
        for (d = 0; 3 > d; ++d)
            b.orientation == gvjs_U && (h = e[c].path[2 * d],
            e[c].path[2 * d] = e[c].path[2 * d + 1],
            e[c].path[2 * d + 1] = h),
            e[c].path[2 * d] += b.left,
            e[c].path[2 * d + 1] += b.top;
    e = a.V4;
    for (c = 0; c < e.length; ++c)
        e[c].x += b.left,
        e[c].y += b.top;
    return a
}
;function gvjs_1H(a, b, c) {
    this.xl = a;
    this.Qa = c ? gvjs_J(b, "colorAxis.legend.position", c, gvjs_5da) : gvjs_f;
    this.Za = gvjs_ry(b, "colorAxis.legend.textStyle", {
        bb: a.Hj,
        fontSize: a.Dl,
        Lb: this.Qa == gvjs_Fp ? a.oz : gvjs_f
    });
    this.G1 = b.cb("colorAxis.legend.numberFormat");
    this.qe = this.fc = null
}
gvjs_ = gvjs_1H.prototype;
gvjs_.getPosition = function() {
    return this.Qa
}
;
gvjs_.getHeight = function() {
    return 1.5 * this.Za.fontSize
}
;
gvjs_.getArea = function() {
    return this.fc
}
;
gvjs_.qr = function(a) {
    this.fc = a
}
;
gvjs_.setScale = function(a) {
    this.qe = a
}
;
gvjs_.define = function() {
    if (!this.fc || !this.qe)
        return null;
    var a = {
        top: this.fc.top,
        left: this.fc.left,
        width: this.fc.right - this.fc.left,
        height: this.fc.bottom - this.fc.top,
        orientation: gvjs_S,
        ja: this.Za,
        zca: gvjs_rt,
        numberFormat: this.G1
    }
      , b = gvjs_0H(this.qe, a, [], this.xl.sc);
    return null == b ? null : {
        position: this.Qa,
        scale: this.qe,
        SH: a,
        definition: b
    }
}
;
function gvjs_2H(a, b, c, d, e) {
    var f = gvjs_cfa;
    this.Wea = gvjs_dfa;
    this.mY = f;
    this.m = a;
    f = a.fa(gvjs_Fu);
    this.Xe = null == f ? null : typeof f === gvjs_l ? {
        pattern: f
    } : {
        pattern: f.pattern,
        formatType: f.formatType,
        timeZone: f.timeZone
    };
    this.sta = gvjs_Oj(a, [gvjs_Vu, "gridlines.minStrongLineDistance"]);
    this.vta = gvjs_Oj(a, [gvjs_Tv, "gridlines.minWeakLineDistance"]);
    this.tta = gvjs_Oj(a, "gridlines.minStrongToWeakLineDistance");
    this.rta = gvjs_Oj(a, "gridlines.minNotchDistance");
    this.pta = gvjs_Oj(a, "gridlines.minMajorTextDistance");
    this.qta = gvjs_Oj(a, "gridlines.minMinorTextDistance");
    this.Hya = gvjs_Oj(a, "gridlines.unitThreshold");
    this.b7 = gvjs_K(a, "gridlines.allowMinor");
    0 === a.Aa(gvjs_Rv) && (this.b7 = !1);
    this.Ff = b;
    this.QA = c;
    this.RR = d;
    this.jta = e;
    this.Yca = this.qca = null
}
function gvjs_3H(a, b, c, d, e) {
    return new gvjs_2H(a,b,c,d,e)
}
gvjs_2H.prototype.generate = function gvjs_efa(a, b, c, d) {
    var f = this, g, h, k, l, m, n, p, q, r, t, u, v, w, x, y, z, A, B, D, C, G, J, I, M, H, Q;
    return gvjs_Dy(gvjs_efa, function(R) {
        switch (R.Fi) {
        case 1:
            g = gvjs_ffa(f, a, b, c),
            h = f.m.pb("gridlines.units." + g.unit),
            k = gvjs_sk[g.unit],
            l = gvjs_HA[k],
            m = [],
            n = {
                minValue: g.minValue,
                maxValue: g.maxValue,
                unitName: g.unit,
                Yga: k,
                Wga: l,
                Xga: h.format,
                z5: h.interval,
                Rca: f.sta,
                dt: d.dt,
                ud: d.ud,
                uta: f.pta,
                LZ: m,
                Qca: 0
            },
            f.qca = n,
            p = gvjs_4H(f, n),
            q = null;
        case 2:
            if (!(q = p.next().value)) {
                R.hh(3);
                break
            }
            if (0 == q.Ja.length) {
                R.hh(2);
                break
            }
            r = d.W6;
            if (!(f.b7 && 1 == q.multiple && 0 < k))
                return I = 1 != q.multiple ? 0 : r,
                M = gvjs_5H(d.ud, I, q.Ja, q.KL),
                H = void 0,
                1 < q.multiple ? (Q = gvjs_gfa(f, g, q, l, d),
                H = gvjs_Ke(q.Ja, Q)) : H = q.Ja,
                gvjs_zy(R, {
                    Ja: H,
                    ec: M
                }, 2);
            t = k - 1;
            u = gvjs_rk[t];
            v = f.m.pb("minorGridlines.units." + u);
            w = gvjs_HA[t];
            x = {
                minValue: g.minValue,
                maxValue: g.maxValue,
                unitName: u,
                Yga: t,
                Wga: w,
                Xga: v.format,
                z5: v.interval,
                Rca: f.vta,
                dt: d.CR,
                ud: d.UJ,
                uta: f.qta,
                LZ: q.Ja,
                Qca: f.tta
            };
            f.Yca = x;
            y = gvjs_4H(f, x);
            z = null;
            A = !1;
        case 6:
            if (A) {
                R.hh(2);
                break
            }
            z = y.next().value;
            A = null == z;
            if (null == z || !z.Ja.length)
                return J = gvjs_5H(d.ud, 2, q.Ja, q.KL),
                gvjs_zy(R, {
                    Ja: q.Ja,
                    ec: J
                }, 6);
            B = gvjs_5H(d.ud, r, q.Ja, q.KL);
            D = gvjs_5H(d.UJ, r, z.Ja, z.KL);
            gvjs_u(D, function(T) {
                T.optional = !0
            });
            C = gvjs_Ke(z.Ja, q.Ja);
            G = gvjs_Ke(B, D);
            return gvjs_zy(R, {
                Ja: C,
                ec: G
            }, 6);
        case 3:
            return R.return({
                Ja: [],
                ec: []
            })
        }
    })
}
;
function gvjs_ffa(a, b, c, d) {
    gvjs_FA(d, gvjs_hfa, a.mY);
    a = gvjs_FA((c - b) / a.Hya, a.Wea, a.mY);
    var e = gvjs_ifa(a);
    a = gvjs_Xx(gvjs_HA, function(f) {
        return gvjs_Jy(f, e)
    });
    return {
        minValue: b,
        maxValue: c,
        unit: gvjs_rk[a]
    }
}
var gvjs_4H = function gvjs_jfa(a, b) {
    var d, e, f, g, h, k, l, m, n, p, q, r, t, u, v, w, x, y, z, A, B;
    return gvjs_Dy(gvjs_jfa, function(D) {
        switch (D.Fi) {
        case 1:
            d = b.z5.length,
            e = 0;
        case 2:
            if (!(e < d)) {
                D.hh(4);
                break
            }
            f = b.z5[e];
            g = 0;
            h = gvjs_Pda(b.Wga, f);
            k = gvjs_yA(new Date(b.minValue + a.QA), h);
            if ("days" === b.unitName) {
                var C = k;
                C = gvjs_yA(C, [0, 0, 0, 0, 1]);
                k = C = gvjs_zA(C, [0, 0, 0, 0, (7 + C.getDay() - 1) % 7])
            }
            l = new gvjs_AA(k,new Date(b.maxValue + a.QA),b.Yga,f);
            m = [];
            n = !0;
            p = a.RR(b.minValue);
            for (q = -1; l.Qz <= l.tY; )
                if (r = l.next(),
                t = a.RR(r.getTime() - a.QA),
                !(t < p)) {
                    -1 == q && t >= p && (q = m.length);
                    u = l.peek();
                    if (null != u && (v = a.RR(u.getTime() - a.QA),
                    Math.abs(v - t) < b.Rca)) {
                        n = !1;
                        break
                    }
                    for (w = !1; g < b.LZ.length; ) {
                        x = b.LZ[g];
                        if (Math.abs(x.Na - t) < b.Qca) {
                            w = !0;
                            break
                        }
                        if (x.Na > t) {
                            g = Math.max(0, g - 1);
                            break
                        }
                        g++
                    }
                    w || m.push({
                        za: r,
                        Na: t,
                        isVisible: !0,
                        brush: b.dt,
                        length: null,
                        S_: !1
                    })
                }
            if (!n) {
                D.hh(3);
                break
            }
            y = gvjs_6H(a, m, b);
            z = null;
        case 5:
            if (!(z = y.next().value)) {
                D.hh(6);
                break
            }
            if (null == z) {
                D.hh(5);
                break
            }
            A = Infinity;
            for (B = 0; B < m.length - 1; ++B)
                A = Math.min(A, m[B + 1].Na - m[B].Na);
            return gvjs_zy(D, {
                Ja: m,
                KL: z,
                multiple: f,
                Xca: A
            }, 5);
        case 6:
            m = [];
        case 3:
            ++e;
            D.hh(2);
            break;
        case 4:
            return D.return({
                Ja: [],
                KL: [],
                multiple: 1,
                Xca: Infinity
            })
        }
    })
}
  , gvjs_6H = function gvjs_kfa(a, b, c) {
    var e, f, g, h, k, l, m, n, p, q, r;
    return gvjs_Dy(gvjs_kfa, function(t) {
        1 == t.Fi && (e = c.Xga,
        Array.isArray(e) || (e = [e]),
        f = [],
        null != a.Xe && null != a.Xe.pattern ? f = [new gvjs_Tj(a.Xe)] : (g = a.Xe || {},
        f = gvjs_v(e, function(u) {
            g.pattern = u;
            return new gvjs_Tj(g)
        })),
        h = 0);
        if (3 != t.Fi) {
            if (!(h < f.length))
                return t.hh(0);
            k = f[h];
            l = [];
            for (m = 0; m < b.length; ++m)
                n = b[m],
                p = n.Me || k.Ob(n.za),
                q = a.jta(p, c.ud),
                r = a.Ff ? q.height : q.width,
                l.push({
                    text: p,
                    size: r
                });
            return gvjs_zy(t, l, 3)
        }
        ++h;
        return t.hh(2)
    })
};
function gvjs_gfa(a, b, c, d, e) {
    if (c.Xca / c.multiple < a.rta)
        return [];
    e = e.dt;
    var f = []
      , g = new Date(b.maxValue + a.QA);
    d = gvjs_yA(new Date(b.minValue + a.QA), d);
    b = new gvjs_AA(d,g,gvjs_sk[b.unit],1);
    for (d = 0; b.Qz <= b.tY; ) {
        if (0 != d % c.multiple) {
            g = b.next();
            var h = a.RR(g.getTime() - a.QA);
            f.push({
                za: g,
                Na: h,
                isVisible: !0,
                brush: e,
                length: 5,
                S_: !0
            })
        }
        d++
    }
    return f
}
function gvjs_5H(a, b, c, d) {
    for (var e = [], f = 1 == b ? gvjs_2 : 3 == b ? gvjs_R : gvjs_0, g = 0, h = [], k = 1 < c.length ? c[1].Na - c[0].Na : 0, l = 0; l < c.length; ++l) {
        var m = c[l]
          , n = Math.round(b == k)
          , p = d[l].size;
        if (f == gvjs_2) {
            var q = n;
            var r = n + p
        } else
            f == gvjs_R ? (q = n - p,
            r = n) : (q = Math.round(n - p / 2),
            r = Math.round(n + p / 2));
        for (r = new gvjs_O(q - 0,r + 0); g < e.length; )
            e[g].start > r.end && (g = Math.max(0, g - 1)),
            g++;
        h.push({
            za: m.za,
            isVisible: !0,
            Na: n,
            Da: {
                text: d[l].text,
                ja: a,
                lines: [{
                    x: n,
                    y: 0,
                    text: d[l].text,
                    length: p
                }],
                ld: f,
                Pc: gvjs_R,
                BEa: d[l].text,
                anchor: null,
                angle: 0
            }
        })
    }
    return h
}
function gvjs_ifa(a) {
    return gvjs_v(a, function(b) {
        return 0 < b ? 1 : 0
    })
}
var gvjs_hfa = [[1], [50], [500], [0, 1], [0, 15], [0, 30], [0, 0, 1], [0, 0, 15], [0, 0, 30], [0, 0, 0, 1], [0, 0, 0, 6], [0, 0, 0, 12], [0, 0, 0, 0, 1], [0, 0, 0, 0, 7], [0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 3], [0, 0, 0, 0, 0, 6], [0, 0, 0, 0, 0, 0, 1]]
  , gvjs_dfa = [[1], [2], [5], [10], [20], [50], [100], [200], [500], [0, 1], [0, 2], [0, 5], [0, 10], [0, 15], [0, 30], [0, 0, 1], [0, 0, 2], [0, 0, 5], [0, 0, 10], [0, 0, 15], [0, 0, 30], [0, 0, 0, 1], [0, 0, 0, 2], [0, 0, 0, 3], [0, 0, 0, 4], [0, 0, 0, 6], [0, 0, 0, 12], [0, 0, 0, 0, 1], [0, 0, 0, 0, 2], [0, 0, 0, 0, 7], [0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 3], [0, 0, 0, 0, 0, 6], [0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 10], [0, 0, 0, 0, 0, 0, 50], [0, 0, 0, 0, 0, 0, 100]]
  , gvjs_cfa = 3;
function gvjs_7H(a) {
    switch (a) {
    case gvjs_Lb:
    case gvjs_Mb:
        return {
            toNumber: gvjs_8H,
            Hy: gvjs_9H
        };
    case gvjs_Od:
        return {
            toNumber: gvjs_lfa,
            Hy: gvjs_mfa
        };
    case gvjs_g:
    case gvjs_l:
        return {
            toNumber: gvjs_$H,
            Hy: gvjs_aI
        };
    default:
        return {
            toNumber: gvjs_$H,
            Hy: gvjs_aI
        }
    }
}
function gvjs_$H(a) {
    return Number(a)
}
function gvjs_aI(a) {
    return a
}
function gvjs_8H(a) {
    return a.getTime()
}
function gvjs_9H(a) {
    return new Date(a)
}
function gvjs_lfa(a) {
    return gvjs_GA(a)
}
function gvjs_mfa(a) {
    return gvjs_DA(a).reverse()
}
;function gvjs_bI() {}
gvjs_ = gvjs_bI.prototype;
gvjs_.init = function(a) {
    this.options = a;
    this.ticks = [];
    this.sn = Infinity;
    this.rn = -Infinity;
    this.wda = null;
    this.Xe = a.cb(gvjs_Fu);
    a.fa("valueFormatter", function(b, c) {
        return c
    });
    this.gd = this.Vz = null
}
;
gvjs_.dD = function(a, b, c) {
    if (0 != c.length && a != gvjs_iw)
        throw Error("Non-linear scale with gaps is not supported.");
    for (var d = [], e = 0; e < c.length; e++) {
        a: {
            var f = c[e];
            var g = this.$Y(f.woa);
            var h = this.oM(f.Gc);
            f = this.oM(f.xe);
            if (0 < g)
                if (h + g < f)
                    h += g;
                else {
                    g = null;
                    break a
                }
            g = {
                voa: 0,
                start: h,
                end: f
            }
        }
        g && d.push(g)
    }
    this.Vz = gvjs_eF(a, gvjs_8E(1, gvjs_9E(b)), d)
}
;
gvjs_.OE = gvjs_n(67);
function gvjs_cI(a, b) {
    a.Xe || (a.Xe = b)
}
function gvjs_dI(a) {
    a.gd || a.dv();
    return a.gd
}
gvjs_.zc = function(a) {
    a = gvjs_eI(this, a);
    if (null == a)
        return null;
    a = gvjs_fI(this, a);
    return isFinite(a) ? a : null
}
;
function gvjs_eI(a, b) {
    return null == b ? null : a.oM(b)
}
gvjs_.Xq = function(a) {
    return this.QR(this.Vz.inverse(a))
}
;
function gvjs_fI(a, b) {
    return a.Vz.transform(b)
}
gvjs_.gX = function(a, b) {
    return a < b ? -1 : a > b ? 1 : 0
}
;
gvjs_.oc = function(a) {
    null != a && (a < this.sn && null != a && (this.sn = a),
    a > this.rn && null != a && (this.rn = a))
}
;
function gvjs_gI(a, b, c) {
    this.Wea = a;
    this.mY = b;
    this.JX = c
}
gvjs_o(gvjs_gI, gvjs_bI);
gvjs_ = gvjs_gI.prototype;
gvjs_.mZ = function() {
    return null
}
;
gvjs_.init = function(a, b) {
    gvjs_bI.prototype.init.call(this, a, b);
    a = a.pb("formatOptions");
    b = [];
    b.push(a.millisecond);
    b.push(a.second);
    b.push(a.minute);
    b.push(a.hour);
    b.push(a.day);
    b.push(a.month);
    b.push(a.year);
    this.JX = gvjs_nfa([b, gvjs_Te(this.Xe, b.length), this.JX])
}
;
function gvjs_nfa(a) {
    a = gvjs_My.apply(null, a);
    return gvjs_v(a, function(b) {
        return gvjs_Yx(b, function(c) {
            return c
        })
    })
}
gvjs_.fa = function(a, b) {
    return a.fa(b)
}
;
gvjs_.oM = function(a) {
    return gvjs_8H(a)
}
;
gvjs_.QR = function(a) {
    return gvjs_9H(a)
}
;
gvjs_.$Y = function(a) {
    return a
}
;
gvjs_.dv = function() {
    var a = gvjs_BA(this.xEa);
    a = this.JX[a];
    this.gd = typeof a === gvjs_h ? new gvjs_Tj(a) : new gvjs_Tj({
        pattern: a
    })
}
;
var gvjs_ofa = [[0, 0, 0, 0, 1], [0, 0, 0, 0, 2], [0, 0, 0, 0, 7], [0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 3], [0, 0, 0, 0, 0, 6], [0, 0, 0, 0, 0, 12], [0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 5], [0, 0, 0, 0, 0, 0, 10], [0, 0, 0, 0, 0, 0, 25], [0, 0, 0, 0, 0, 0, 50], [0, 0, 0, 0, 0, 0, 100]]
  , gvjs_pfa = [2, 2, 2, 2, 2, gvjs_Vj.YEAR_MONTH_ABBR, "y"]
  , gvjs_qfa = [[1], [2], [5], [10], [20], [50], [100], [200], [500], [0, 1], [0, 2], [0, 5], [0, 10], [0, 15], [0, 30], [0, 0, 1], [0, 0, 2], [0, 0, 5], [0, 0, 10], [0, 0, 15], [0, 0, 30], [0, 0, 0, 1], [0, 0, 0, 2], [0, 0, 0, 3], [0, 0, 0, 4], [0, 0, 0, 6], [0, 0, 0, 12], [0, 0, 0, 0, 1], [0, 0, 0, 0, 2], [0, 0, 0, 0, 7], [0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 3], [0, 0, 0, 0, 0, 6], [0, 0, 0, 0, 0, 12], [0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 5], [0, 0, 0, 0, 0, 0, 10], [0, 0, 0, 0, 0, 0, 25], [0, 0, 0, 0, 0, 0, 50], [0, 0, 0, 0, 0, 0, 100]]
  , gvjs_rfa = [6, 6, 7, {
    pattern: 7,
    clearMinutes: !0
}, 2, gvjs_Vj.YEAR_MONTH_ABBR, "y"];
function gvjs_hI(a, b, c) {
    this.GX = a;
    this.Pa = b;
    this.JQ = a - b / 2;
    this.Asa = c;
    this.index = 0
}
gvjs_hI.prototype.Ev = function() {
    return this.JQ
}
;
gvjs_hI.prototype.Kn = function(a) {
    this.JQ = a
}
;
gvjs_hI.prototype.getCenter = function() {
    return this.JQ + this.Pa / 2
}
;
gvjs_hI.prototype.getHeight = function() {
    return this.Pa
}
;
function gvjs_sfa(a, b) {
    this.wF = a;
    this.yz = b;
    a = 0;
    for (var c = b.length; a < c; a++)
        b[a].index = a
}
function gvjs_tfa(a) {
    for (var b = 0, c = 0, d = a.yz.length; c < d; c++)
        b += a.yz[c].getHeight();
    if (b > a.wF)
        throw Error("Not enough space for labels. Need: " + b + " got: " + a.wF);
    a.yz.sort(function(f, g) {
        var h = f.GX
          , k = g.GX;
        return h == k ? f.index > g.index ? 1 : 0 : h > k ? 1 : -1
    });
    c = 0;
    for (d = a.yz.length; c < d; c++) {
        b = a.yz[c];
        var e = gvjs_iI(a, b.Ev(), b.getHeight());
        b.Kn(e)
    }
    c = [];
    b = 0;
    for (d = a.yz.length; b < d; b++)
        c.push([a.yz[b]]);
    for (; gvjs_ufa(a, c); )
        ;
}
function gvjs_ufa(a, b) {
    for (var c = 0; c < b.length - 1; c++) {
        var d = b[c]
          , e = b[c + 1]
          , f = d[d.length - 1];
        if (f.JQ + f.Pa > e[0].Ev()) {
            f = e;
            for (e = 0; e < f.length; e++)
                d.push(f[e]);
            var g = 0;
            for (e = f = 0; e < d.length; e++)
                g += d[e].GX,
                f += d[e].getHeight();
            g = g / d.length - f / 2;
            g = gvjs_iI(a, g, f);
            for (e = 0; e < d.length; e++)
                a = d[e],
                a.Kn(g),
                g += a.getHeight();
            b.splice(c + 1, 1);
            return !0
        }
    }
    return !1
}
function gvjs_iI(a, b, c) {
    return gvjs_0g(b, 0, a.wF - c)
}
;function gvjs_jI(a, b, c, d) {
    this.xl = a;
    this.Qa = c ? gvjs_J(b, gvjs_uv, c, gvjs_4da) : gvjs_f;
    this.WM = gvjs_J(b, gvjs_sv, this.Qa == gvjs_vt ? gvjs_0 : gvjs_2, gvjs_6da);
    c = gvjs_S;
    if (this.Qa == gvjs_$c || this.Qa == gvjs_j || this.Qa == gvjs_ov || this.Qa == gvjs_xt)
        c = gvjs_U;
    this.tb = c;
    this.Za = gvjs_ry(b, gvjs_vv, {
        bb: a.Hj,
        fontSize: a.Dl,
        Lb: this.Qa == gvjs_Fp ? a.oz : gvjs_f
    });
    this.gu = !1;
    this.Xda = gvjs_ry(b, "legend.pagingTextStyle", this.Za);
    this.Zd = gvjs_Tz(a.sc, {
        size: 1E4
    });
    this.hQ = this.Za.fontSize;
    d = d ? gvjs_0g(d, 1, 4) : 1;
    this.kz = this.hQ * d;
    this.Jy = Math.round(this.Za.fontSize / (1.618 * 1.618));
    this.iG = this.fc = null;
    this.d4 = gvjs_K(b, "legend.showPageIndex", !0);
    this.gwa = gvjs_J(b, "legend.scrollArrows.orientation", this.tb, gvjs_iC);
    this.ewa = gvjs_qy(b, "legend.scrollArrows.activeColor");
    this.fwa = gvjs_qy(b, "legend.scrollArrows.inactiveColor");
    this.Xi = gvjs_Oj(b, "legend.pageIndex", 0);
    this.Pe = null;
    this.mI = this.Jy;
    this.oA = this.pA = this.r3 = 0;
    this.Hca = this.Qa == gvjs_vx ? gvjs_Oj(b, gvjs_tv, 1) : 1;
    this.eG = 0
}
gvjs_jI.prototype.getPosition = function() {
    return this.Qa
}
;
gvjs_jI.prototype.getArea = function() {
    return this.fc
}
;
gvjs_jI.prototype.qr = function(a) {
    this.fc = a
}
;
function gvjs_vfa(a) {
    a.iG = gvjs_De(a.xl.Vo, function(b) {
        return b.isVisible
    })
}
gvjs_jI.prototype.define = function() {
    if (!this.fc)
        return null;
    if (this.Qa != gvjs_f)
        if (this.tb == gvjs_U)
            gvjs_wfa(this);
        else {
            for (var a = [1, 9, 99, 0], b = 0; b < a.length; ++b) {
                a: {
                    var c = a[b];
                    var d = this.fc.right - this.fc.left
                      , e = !1
                      , f = Math.round(1.618 * this.Za.fontSize);
                    1 != c && (d -= f + this.mI + 2 * this.Za.fontSize,
                    e = !0,
                    0 != c && (d -= gvjs_kI(this, c) + this.Jy));
                    f = gvjs_lI(this, this.iG, d);
                    if (0 == f.length)
                        this.gu = !1;
                    else {
                        this.Pe = [];
                        for (var g = this.iG; 0 < g.length; ) {
                            if (0 < c && this.Pe.length == c) {
                                c = !1;
                                break a
                            }
                            for (var h = [gvjs_mI(this, f, g, e)], k = 1; k < this.eG && g.length != f.length; k++)
                                g = gvjs_Oe(g, f.length),
                                f = gvjs_lI(this, g, d),
                                h.push(gvjs_mI(this, f, g, e));
                            h = gvjs_xfa(this, h);
                            this.Pe.push(h);
                            g = gvjs_Oe(g, f.length);
                            f = gvjs_lI(this, g, d)
                        }
                        this.gu = 1 < this.Pe.length
                    }
                    c = !0
                }
                if (c)
                    break
            }
            this.gu && (this.r3 = Math.round((this.fc.top + this.fc.bottom - this.Za.fontSize) / 2),
            this.oA = this.fc.right - this.Za.fontSize,
            this.pA = this.oA - this.mI - this.Za.fontSize,
            this.d4 && (a = gvjs_kI(this, this.Pe.length),
            this.pA -= a + this.mI))
        }
    a = 0;
    c = b = null;
    if (this.Pe && 0 < this.Pe.length)
        if (1 < this.Pe.length && (a = this.Xi < this.Pe.length ? this.Xi : this.Pe.length - 1),
        b = this.Pe[a],
        this.gu) {
            c = 0 < a;
            d = a < this.Pe.length - 1;
            e = this.r3;
            f = null;
            this.d4 && (f = a + 1 + "/" + this.Pe.length,
            g = this.pA + this.Za.fontSize,
            h = this.oA - g,
            f = {
                text: f,
                ja: this.Xda,
                vl: null,
                lines: [{
                    x: g + h / 2,
                    y: e,
                    text: f,
                    length: h
                }],
                ld: gvjs_0,
                Pc: gvjs_2,
                tooltip: "",
                anchor: null,
                angle: 0
            });
            h = this.Za.fontSize;
            k = Math.round(h / 2);
            g = this.pA;
            var l = this.oA;
            this.gwa == gvjs_U ? (g = [{
                x: g + h,
                y: e + h
            }, {
                x: g + k,
                y: e
            }, {
                x: g,
                y: e + h
            }],
            e = [{
                x: l,
                y: e
            }, {
                x: l + h,
                y: e
            }, {
                x: l + k,
                y: e + h
            }]) : (g = [{
                x: g + h,
                y: e + h
            }, {
                x: g + h,
                y: e
            }, {
                x: g,
                y: e + k
            }],
            e = [{
                x: l,
                y: e
            }, {
                x: l + h,
                y: e + k
            }, {
                x: l,
                y: e + h
            }]);
            h = {
                active: this.ewa,
                mQ: this.fwa
            };
            c = {
                w2: {
                    path: g,
                    active: c,
                    Rb: h,
                    brush: c ? h.active : h.mQ
                },
                s1: {
                    path: e,
                    active: d,
                    Rb: h,
                    brush: d ? h.active : h.mQ
                },
                a2: f
            }
        } else
            c = null;
    return {
        position: this.Qa,
        area: this.fc,
        Pe: this.Pe,
        ev: b,
        Xi: a,
        $K: c
    }
}
;
function gvjs_wfa(a) {
    var b = Math.max(a.fc.right - a.fc.left - (a.kz + a.Jy), 0)
      , c = a.fc.bottom - a.fc.top
      , d = Math.max(c - 2 * a.hQ, 0)
      , e = a.iG
      , f = a.xl;
    gvjs_2G(f) && e.reverse();
    var g = gvjs_v(e, function(h) {
        h = gvjs_DG(this.Zd, h.text, this.Za, b, Infinity);
        0 == h.lines.length && (h.lines = [""]);
        return h
    }, a);
    if (a.Qa != gvjs_ov || f.DH != gvjs_e && f.DH != gvjs_at)
        if (c = gvjs_nI(a, g, c),
        a.gu = gvjs_yfa(e, c),
        a.gu)
            if (c = gvjs_nI(a, g, d),
            void 0 === c[0] || 0 == c[0].length)
                a.gu = !1;
            else {
                for (a.Pe = []; 0 < e.length; ) {
                    f = gvjs_oI(a, c, e);
                    a.Pe.push(f);
                    for (f = 0; void 0 !== c[f] && 0 != c[f].length; )
                        ++f;
                    g = gvjs_Oe(g, f);
                    c = gvjs_nI(a, g, d);
                    e = gvjs_Oe(e, f)
                }
                a.gu && (a.r3 = Math.round(a.fc.bottom - a.Za.fontSize),
                a.pA = a.fc.left,
                a.oA = a.pA + a.Za.fontSize + a.mI,
                a.d4 && (d = gvjs_kI(a, a.Pe.length),
                a.oA += d + a.mI))
            }
        else
            f = gvjs_oI(a, c, e),
            a.Pe = [f];
    else
        f = gvjs_zfa(a, g, c, e),
        a.Pe = [f]
}
function gvjs_nI(a, b, c) {
    var d = a.Za.fontSize;
    a = gvjs_Afa(a, b, d + Math.round(d / 1.618), d + Math.round(d / 3.236));
    return gvjs_oA(a, c)
}
function gvjs_Bfa(a, b) {
    var c = gvjs_Oy(a.xl.jd);
    b = a.xl.C[b];
    a = gvjs_v(b.points, function(d) {
        return gvjs_XG(d) ? null : new gvjs_z(d.ia.x,d.ia.y)
    });
    b = gvjs_wA(a, c.ef, b.Zj);
    return null !== b ? b : gvjs_Cfa(a, c.ef)
}
function gvjs_Cfa(a, b) {
    a = gvjs_De(a, function(c) {
        return null != c
    });
    b = -(gvjs_Iy(a, b, function(c, d) {
        return gvjs_Re(c, d.x)
    }) + 1);
    a = gvjs_Oe(a, 0, b);
    return (a = gvjs_Ey(a, function(c) {
        return null !== c.y
    })) ? a.y : null
}
function gvjs_zfa(a, b, c, d) {
    for (var e = a.fc.right - a.fc.left, f = Math.round(a.fc.left), g = [], h = [], k = a.xl.qz == gvjs_lu, l = 0; l < d.length; l++) {
        var m = d[l]
          , n = gvjs_DG(a.Zd, m.text, a.Za, e, b[l].lines.length)
          , p = {};
        p.id = m.id;
        p.brush = m.brush.clone();
        var q = gvjs_x(a.Za);
        q.color = p.brush.fill;
        p.Da = {
            text: m.text,
            ja: q,
            vl: null,
            lines: [],
            ld: gvjs_2,
            Pc: gvjs_2,
            tooltip: n.oe ? m.text : "",
            anchor: null,
            angle: 0
        };
        q.Lb && p.brush.rd(q.Lb, 1);
        p.isVisible = !0;
        for (var r = 0; r < n.lines.length; r++)
            p.Da.lines.push({
                length: e,
                text: n.lines[r]
            });
        k && (r = a.Zd(p.Da.lines[0].text, q).width,
        p.Rg = {},
        p.Rg.coordinates = {
            x: f + r + 5
        },
        p.Rg.brush = p.brush,
        p.Rg.isVisible = !1);
        p.index = m.index;
        r = gvjs_Bfa(a, p.index) || 0;
        q = a.Zd(p.Da.lines[0], q).height;
        m = new gvjs_hI(r,p.Da.lines.length * q,p);
        g.push(m);
        h.push(p)
    }
    gvjs_tfa(new gvjs_sfa(c,g));
    for (r = 0; r < g.length; r++)
        for (m = g[r],
        a = m.Ev(),
        p = m.Asa,
        b = p.Da.lines,
        l = 0; l < b.length; l++)
            b[l].y = Math.round(l * q + a),
            b[l].x = f,
            k && (p.Rg.coordinates.y = b[l].y);
    return h
}
function gvjs_oI(a, b, c) {
    var d = a.kz + a.Jy
      , e = a.fc.right - a.fc.left - d
      , f = a.Za.fontSize
      , g = Math.round(f / 1.618)
      , h = f + g
      , k = f + Math.round(f / 3.236);
    f = [];
    for (var l = 0, m = Math.round(a.fc.left), n = 0; n < c.length; n++) {
        var p = c[n]
          , q = b[n].length;
        if (0 != q) {
            var r = gvjs_DG(a.Zd, p.text, a.Za, e, q);
            q = {};
            q.id = p.id;
            q.Da = {
                text: p.text,
                ja: a.Za,
                vl: null,
                lines: [],
                anchor: new gvjs_HG(m,0),
                ld: gvjs_2,
                Pc: gvjs_2,
                tooltip: r.oe ? p.text : "",
                angle: 0
            };
            q.square = {};
            q.square.coordinates = new gvjs_5(m,l,a.kz,a.hQ);
            q.square.brush = p.brush.clone();
            a.Za.Lb && q.square.brush.rd(a.Za.Lb, 1);
            q.isVisible = !0;
            for (var t = 0; t < r.lines.length; t++)
                0 < t && (l += k),
                q.Da.lines.push({
                    x: d,
                    y: l,
                    length: e,
                    text: r.lines[t]
                });
            q.index = p.index;
            l += h;
            f.push(q)
        }
    }
    b = Math.round(a.fc.top);
    a.gu || (g = l - g,
    c = a.fc.bottom - a.fc.top,
    a.WM == gvjs_R ? b += c - g : a.WM == gvjs_0 && (b += Math.floor((c - g) / 2)));
    for (n = 0; n < f.length; n++)
        q = f[n],
        q.square.coordinates.top += b,
        q.Da.anchor.y += b;
    return f
}
function gvjs_Afa(a, b, c, d) {
    for (var e = gvjs_Ee(b, function(k, l) {
        return Math.max(k, l.lines.length)
    }, 0), f = [], g = 0; g < e; g++) {
        var h = 0 == g ? c : d;
        gvjs_u(b, function(k, l) {
            g < k.lines.length && f.push({
                key: l,
                min: 0 == g && 0 == l ? this.Za.fontSize : h,
                extra: []
            })
        }, a)
    }
    return f
}
function gvjs_yfa(a, b) {
    var c = a.length - 1;
    return 1 < a.length && 1 > b[c].length
}
function gvjs_xfa(a, b) {
    var c = a.fc.bottom - a.fc.top
      , d = a.Za.fontSize
      , e = c - a.eG * d
      , f = 1 < a.eG ? e / (a.eG - 1) : 0
      , g = (c - ((d + f) * b.length - f)) / 2
      , h = [];
    gvjs_u(b, function(k) {
        var l = Math.round(g);
        gvjs_u(k, function(m) {
            m.Da.anchor.y += l;
            m.square.coordinates.top += l
        });
        g += d + f;
        gvjs_Me(h, k)
    });
    return h
}
function gvjs_lI(a, b, c) {
    var d = Math.min(a.xl.width * (2 - 1.618) / 2, c);
    if (d < a.kz + a.Jy)
        return [];
    a = gvjs_Dfa(a, d, b);
    return gvjs_nA(a, c)
}
function gvjs_mI(a, b, c, d) {
    for (var e = a.fc.right - a.fc.left, f = a.kz + a.Jy, g = Math.round(1.618 * a.Za.fontSize), h = [], k = 0, l = Math.round(a.fc.top), m = 0; m < b.length; m++) {
        var n = c[m]
          , p = gvjs_DG(a.Zd, n.text, a.Za, b[m] - f - (0 < m ? g : 0), 1)
          , q = 0 < p.lines.length ? p.lines[0] : ""
          , r = a.Zd(q, a.Za).width
          , t = [{
            x: k + f,
            y: 0,
            length: r,
            text: q
        }]
          , u = {};
        u.id = n.id;
        u.Da = {
            text: n.text,
            ja: a.Za,
            vl: null,
            lines: q ? t : [],
            anchor: new gvjs_HG(0,l),
            ld: gvjs_2,
            Pc: gvjs_2,
            tooltip: p.oe ? n.text : "",
            angle: 0
        };
        u.isVisible = !0;
        u.square = {};
        u.square.brush = n.brush.clone();
        a.Za.Lb && u.square.brush.rd(a.Za.Lb, 1);
        u.square.coordinates = new gvjs_5(k,l,a.kz,a.hQ);
        u.index = n.index;
        h.push(u);
        k += r + f + g
    }
    b = a.fc.left;
    d || (d = k - g,
    a.WM == gvjs_R ? b += e - d : a.WM == gvjs_0 && (b += Math.floor((e - d) / 2)));
    for (m = 0; m < h.length; m++)
        u = h[m],
        u.square.coordinates.left += b,
        u.Da.anchor.x += b;
    return h
}
function gvjs_Dfa(a, b, c) {
    var d = a.kz + a.Jy
      , e = Math.round(1.618 * a.Za.fontSize);
    return gvjs_v(c, function(f, g) {
        var h = this.Zd(f.text, this.Za).width + d;
        f = Math.min(b, h);
        h -= f;
        0 < g && (f += e);
        return {
            min: f,
            extra: [h]
        }
    }, a)
}
function gvjs_kI(a, b) {
    for (var c = "0"; 10 <= b; )
        c += "0",
        b /= 10;
    return a.Zd(c + "/" + c, a.Xda).width
}
;var gvjs_pI = null;
function gvjs_qI() {
    this.SK = {}
}
function gvjs_rI() {
    return gvjs_pI ? gvjs_pI : gvjs_pI = new gvjs_qI
}
gvjs_qI.prototype.dh = function(a) {
    return (a = this.SK[a]) ? a.apply(null, []) : null
}
;
function gvjs_sI() {
    this.Y$ = 1
}
gvjs_o(gvjs_sI, gvjs_bI);
gvjs_ = gvjs_sI.prototype;
gvjs_.mZ = function() {
    return [0, 0, 0, 0]
}
;
gvjs_.fa = function(a, b) {
    return a.fa(b)
}
;
gvjs_.gX = function(a, b) {
    a = gvjs_GA(a);
    b = gvjs_GA(b);
    return a < b ? -1 : a > b ? 1 : 0
}
;
gvjs_.oM = function(a) {
    return gvjs_GA(a)
}
;
gvjs_.QR = function(a) {
    return gvjs_DA(a).reverse()
}
;
gvjs_.$Y = function(a) {
    return a
}
;
gvjs_.dv = function() {
    var a = new gvjs_Tj({
        pattern: this.Xe || (1 < this.Y$ ? gvjs_Ia : 1 === this.Y$ ? gvjs_Ja : gvjs_Ka),
        timeZone: 0
    });
    this.gd = {
        Ob: function(b) {
            b = gvjs_qk(b);
            return a.Ob(b)
        }
    }
}
;
function gvjs_tI(a, b, c, d, e, f) {
    this.V = a;
    this.Fka = c[0];
    this.options = b.view(c);
    this.index = d;
    this.type = gvjs_J(this.options, gvjs_Sd, e, gvjs_2da);
    this.maxValue = this.minValue = null;
    this.hG = [];
    this.pO = this.cB = null;
    this.nka = 0 < a.wh.bars;
    b = gvjs_J(this.options, gvjs_fx);
    c = a.DB === gvjs_Fp ? a.oz : gvjs_f;
    c = gvjs_ry(this.options, gvjs_ix, {
        bb: a.Hj,
        fontSize: a.Dl,
        Lb: c
    });
    this.title = {
        text: b,
        ja: c,
        vl: null,
        lines: [],
        ld: gvjs_0,
        Pc: gvjs_2,
        tooltip: "",
        anchor: null,
        angle: 0
    };
    this.ticks = [];
    this.ec = this.yg = null;
    this.uj = gvjs_J(this.options, "textPosition", gvjs_aw, gvjs_jC);
    b = this.type != gvjs_Vd || a.Fa == gvjs_Dd ? gvjs_oy(this.options, "majorAxisTextColor", gvjs_QF.majorAxisTextColor) : gvjs_oy(this.options, "minorAxisTextColor", gvjs_QF.minorAxisTextColor);
    c = this.uj === gvjs_Fp ? a.oz : gvjs_f;
    b = {
        color: b,
        bb: a.Hj,
        fontSize: a.Dl,
        Lb: c
    };
    this.ud = gvjs_ry(this.options, gvjs_bx, b);
    c = gvjs_Oj(this.options, "gridlines.minorTextOpacity");
    c = gvjs_7z(this.ud.color, a.SM || gvjs_Br, c);
    this.UJ = gvjs_ry(this.options, gvjs_bx, b);
    this.UJ.color = c;
    this.Xxa = gvjs_J(this.options, "outTextPosition", "unbound", gvjs_7da);
    this.zga = gvjs_J(this.options, "inTextPosition", "low", gvjs_8da);
    b = gvjs_oy(this.options, gvjs_mt, a.Kka);
    this.Jka = new gvjs_3({
        fill: b
    });
    b = gvjs_oy(this.options, gvjs_Su, a.baa);
    this.dt = new gvjs_3({
        fill: b
    });
    this.Gv = this.options.Aa(gvjs_Tu);
    this.caa = this.options.Aa(gvjs_Vu);
    this.wta = this.options.Aa(gvjs_Rv);
    c = gvjs_Oj(this.options, "gridlines.minorGridlineOpacity");
    a = b == gvjs_f ? gvjs_f : gvjs_7z(b, a.SM || gvjs_Br, c);
    a = gvjs_oy(this.options, gvjs_Qv, a);
    this.CR = new gvjs_3({
        fill: a
    });
    this.Yo = 2;
    this.D$ = Math.max(this.Yo, Math.round(this.title.ja.fontSize / 3.236));
    this.vG = 0;
    this.direction = this.ro = gvjs_L(this.options, gvjs_iu, 1);
    this.ef = this.Pf = null;
    this.nM = this.ww = 0;
    this.nb = {
        min: -Infinity,
        max: Infinity
    };
    this.qM = this.Hma = f;
    this.n3 = gvjs_dF(this.options, gvjs_Cv, gvjs_Ew);
    this.mga = (this.gw = (this.Zca = this.n3 === gvjs_Vv) || "log" === this.n3) && !this.Zca;
    this.type == gvjs_Vd && (this.baseline = this.ta = null,
    this.eV = Infinity,
    this.aca = this.o0 = null)
}
function gvjs_uI(a, b) {
    typeof b !== gvjs_g || 0 === b || isNaN(b) || (b = Math.abs(b),
    a.eV = Math.min(b - b / 10, a.eV))
}
gvjs_ = gvjs_tI.prototype;
gvjs_.dD = function(a) {
    this.yg && gvjs_u(this.yg, function(b) {
        gvjs_uI(this, b.v)
    }, this);
    a = a || [];
    this.ta.dD(this.n3, this.eV, a)
}
;
gvjs_.initScale = function(a) {
    var b = gvjs_rI().dh(a);
    this.ta = b;
    this.dataType = a;
    gvjs_vI(this) && (a = {},
    gvjs_gq(a, [gvjs_Iv], 1),
    gvjs_gq(a, ["slantedText"], !1),
    gvjs_hq(this.options, 1, a),
    this.oS());
    a = this.vi();
    if (this.options.fa(gvjs_tu) && (!this.options.fa("explorer.axis") || this.options.cb("explorer.axis." + a)) || null != this.Gv && 0 > this.Gv)
        this.Gv = -1;
    b.init(this.options, this.Gv);
    this.minValue = b.fa(this.options, gvjs_ed);
    this.maxValue = b.fa(this.options, gvjs_cd);
    this.cB = this.options.fa(gvjs_Xo, gvjs_QF.vAxis.gridlines.baseline);
    this.pO = void 0 !== this.cB && this.cB !== gvjs_ub ? this.cB : this.pO || b.mZ();
    gvjs_Efa(this)
}
;
function gvjs_Efa(a) {
    var b = a.options.fa(gvjs_ex);
    Array.isArray(b) && (a.yg = b);
    a.yg && (a.yg = gvjs_v(a.yg, function(c) {
        var d = {};
        d.v = void 0 !== c.v ? c.v : c;
        typeof c.f === gvjs_l && (d.f = c.f);
        return d
    }),
    0 < a.yg.length && (gvjs_Qe(a.yg, function(c, d) {
        return a.ta.gX(c.v, d.v)
    }),
    null == a.minValue && (a.minValue = a.yg[0].v),
    null == a.maxValue && (a.maxValue = gvjs_Ae(a.yg).v)))
}
function gvjs_wI(a) {
    a.qM = gvjs_J(a.options, gvjs_Lx, a.qM, gvjs_3da);
    var b = a.ta;
    if (a.type == gvjs_Vd) {
        var c = b.fa(a.options, "viewWindow.numericMin");
        typeof c !== gvjs_g && (c = b.zc(b.fa(a.options, gvjs_Kx)));
        var d = b.fa(a.options, "viewWindow.numericMax");
        typeof d !== gvjs_g && (d = b.zc(b.fa(a.options, gvjs_Jx)));
        null != c && (a.nb.min = c);
        null != d && (a.nb.max = d)
    } else
        a.nb.min = gvjs_L(a.options, gvjs_Kx, a.nb.min),
        a.nb.max = gvjs_L(a.options, gvjs_Jx, a.nb.max),
        a.nb.max = Math.max(a.nb.min + 1, a.nb.max);
    a.nb.min > a.nb.max && (c = a.nb.min,
    a.nb.min = a.nb.max,
    a.nb.max = c);
    a.type == gvjs_Vd && (-Infinity != a.nb.min && (c = a.nb.min,
    null != c && (b.sn = c)),
    Infinity != a.nb.max && (c = a.nb.max,
    null != c && (b.rn = c)),
    gvjs_xI(a))
}
function gvjs_yI(a) {
    if (a.type == gvjs_Vd && !a.ta)
        throw Error("Axis type/data type mismatch for " + a.Fka);
}
function gvjs_zI(a, b, c, d, e) {
    a.Pf = c + (1 == a.direction ? .5 : -.5);
    a.vG = b - 1;
    a.ef = c + b * a.direction;
    b = a.Y7();
    a.ne = d;
    a.Dg = e;
    a.type != gvjs_Vd ? d = gvjs_Ffa(a, a.vG + 1) : (null != a.cB && a.cB !== gvjs_ub && a.oc(a.ta.zc(a.cB)),
    null != a.minValue && a.oc(a.ta.zc(a.minValue)),
    null != a.maxValue && a.oc(a.ta.zc(a.maxValue)),
    gvjs_Gfa(a),
    d = gvjs_vI(a) ? gvjs_Hfa(a) : gvjs_Ifa(a));
    return {
        title: a.title,
        name: a.H$(),
        type: a.type,
        Mq: a.gw,
        dataType: a.dataType,
        ro: a.ro,
        Pf: a.Pf,
        ef: a.ef,
        number: {
            hf: a.sda.bind(a),
            ol: a.Xq.bind(a)
        },
        position: {
            hf: a.vN.bind(a),
            ol: a.U7.bind(a)
        },
        zp: b,
        baseline: d.baseline,
        Ja: d.Ja,
        text: d.ec,
        Tn: a.ta ? {
            min: a.ta.sn,
            max: a.ta.rn
        } : {
            min: a.nb.min,
            max: a.nb.max
        }
    }
}
function gvjs_Ffa(a, b) {
    var c = a.V.$a;
    -Infinity == a.nb.min && (a.nb.min = Math.min(0, a.nb.max - 1));
    Infinity == a.nb.max && (a.nb.max = Math.max(c.length, a.nb.min + 1));
    a.nb.max = Math.max(a.nb.min + 1, a.nb.max);
    var d = a.nb.max - a.nb.min;
    a.nka && (d = Math.min(d, Math.floor((b + 1) / 2)));
    a.type == gvjs_It && (d = Math.max(1, d - 1));
    a.nM = gvjs_AI(a);
    a.ww = a.vG / d;
    var e = gvjs_Jfa(a);
    b = gvjs_lA(c.length, function(f) {
        var g = e.Ob(c[f].$w[0])
          , h = f - a.nM;
        return {
            za: c[f].data,
            Na: a.Jc(f),
            text: g,
            isVisible: 0 <= h && h <= d,
            optional: !0
        }
    });
    return {
        Ja: [],
        baseline: null,
        ec: gvjs_BI(a, b),
        ticks: []
    }
}
function gvjs_Jfa(a) {
    if (a.ta) {
        if (gvjs_vI(a)) {
            var b = gvjs_3H(a.options, a.XDa, a.AEa, a.qCa, a.V.sc);
            gvjs_CI(a, b, 0);
            return new gvjs_Tj({
                pattern: gvjs_Xi.Format.FULL_DATETIME
            })
        }
        b = gvjs_v(a.yg, function(c) {
            return c.v
        });
        b = gvjs_wH(b);
        a = gvjs_DI(a);
        a.nw(b);
        return a.cd()
    }
    return {
        Ob: function(c) {
            return c
        }
    }
}
function gvjs_Hfa(a) {
    function b(C) {
        C = c(C);
        var G = gvjs_BI(a, C);
        if (null == G)
            return !1;
        gvjs_Ce(G, function(J) {
            var I = J.Da.anchor.x;
            u && (I = J.Da.anchor.y);
            J.isVisible && gvjs_EI(a, I) || gvjs_Ie(G, J)
        });
        return G
    }
    function c(C) {
        a.yg ? C = gvjs_CI(a, w, v) : (C = C || [],
        C = gvjs_v(C, function(G) {
            var J = G.za;
            J = (Array.isArray(J) ? d.zc(J) : J.getTime()) - v;
            if (null != J && (J = a.Jc(J),
            null != J && !isNaN(J)))
                return {
                    za: G.za,
                    Na: J,
                    text: G.Da.text,
                    isVisible: G.isVisible,
                    optional: G.optional
                }
        }));
        return C
    }
    var d = a.ta
      , e = !0
      , f = !0;
    a.qM != gvjs_Lv && (e = isFinite(a.nb.min),
    f = isFinite(a.nb.max));
    var g = gvjs_FI(a)
      , h = g
      , k = h.min;
    h = h.max;
    gvjs_GI(a, g);
    gvjs_xI(a);
    var l = k
      , m = h;
    g = Math.abs(h - k);
    var n = a.cZ()
      , p = a.baseline.za
      , q = null == p ? null : d.zc(p);
    p = Math.abs(a.ef - a.Pf);
    var r = a.options.Mg("viewWindow.maxPadding", p) / p;
    r *= g;
    e || (k = null != q && q <= k && k - g < q ? q : k - r);
    f || (h = null != q && q >= h && h + g > q ? q : h + r);
    g = {
        min: k,
        max: h
    };
    gvjs_GI(a, g);
    gvjs_xI(a);
    gvjs_Qe(a.hG);
    var t = Infinity;
    for (g = 1; g < a.hG.length; ++g)
        (q = Math.abs(a.hG[g] - a.hG[g - 1])) && (t = Math.min(t, q));
    Infinity === t && (t = 0);
    var u = n.orientation === gvjs_U;
    n = {};
    var v = 0;
    d instanceof gvjs_sI && (v = (new Date(1970,0,1)).getTime(),
    n = {
        gridlines: {
            units: gvjs_Kea
        },
        minorGridlines: {
            units: gvjs_Lea
        }
    });
    g = null != a.Gv && 0 <= a.Gv ? a.Gv : -1;
    q = a.caa;
    0 <= g && (q = p / (g + 1));
    null != q && gvjs_gq(n, [gvjs_Ru, "minStrongLineDistance"], q);
    gvjs_hq(a.options, 1, n);
    var w = gvjs_3H(a.options, u, v, function(C) {
        return a.Jc(C)
    }, a.V.sc)
      , x = {
        ud: a.ud,
        dt: a.dt,
        UJ: a.UJ,
        CR: a.CR,
        W6: 1 == a.direction ? 1 : 0
    }
      , y = a.direction;
    p = function I(G, J) {
        var M, H, Q, R;
        return gvjs_Dy(I, function(T) {
            1 == T.Fi && (M = w.generate(G, J, t, x),
            H = null,
            Q = function() {
                a.direction = 1;
                return H = M.next().value
            }
            ,
            R = {});
            if (4 != T.Fi) {
                if (!Q())
                    return T.hh(0);
                H.Ja = gvjs_Le(H.Ja);
                H.ec = gvjs_Le(H.ec);
                R.RF = function(O) {
                    return Math.round(100 * O) / 100
                }
                ;
                -1 === y && (a.direction = y,
                gvjs_u(H.Ja, function(O) {
                    return function(K, E) {
                        K = gvjs_x(K);
                        H.Ja[E] = K;
                        K.Na = O.RF(gvjs_HI(a, K.Na))
                    }
                }(R)),
                gvjs_u(H.ec, function(O) {
                    return function(K, E) {
                        K = gvjs_x(K);
                        H.ec[E] = K;
                        K.Na = O.RF(gvjs_HI(a, K.Na));
                        K.Da = gvjs_x(K.Da);
                        K.Da.lines[0] = gvjs_x(K.Da.lines[0]);
                        K.Da.lines[0].x = O.RF(gvjs_HI(a, K.Da.lines[0].x))
                    }
                }(R)));
                gvjs_Ce(H.ec, function(O) {
                    O.za = d.Xq(O.za.getTime());
                    O.Da = gvjs_x(O.Da);
                    var K = gvjs_x(O.Da.lines[0]);
                    O.Da.lines[0] = K;
                    u && (O = gvjs_8d([K.y, K.x]),
                    K.x = O.next().value,
                    K.y = O.next().value)
                });
                gvjs_Ce(H.Ja, function(O, K) {
                    O = gvjs_x(O);
                    H.Ja[K] = O;
                    gvjs_EI(a, O.Na) ? O.za = d.Xq(O.za.getTime() - v) : (O.isVisible = !1,
                    gvjs_Ie(H.Ja, O))
                });
                gvjs_Se(H.Ja, function(O, K) {
                    return d.gX(O.za, K.za)
                });
                return gvjs_zy(T, H, 4)
            }
            R = {
                RF: R.RF
            };
            return T.hh(2)
        })
    }
    ;
    q = !0;
    n = null;
    for (var z, A; q; ) {
        g = k;
        q = h;
        var B = p(k, h);
        r = null;
        for (var D = !1; !D && (r = B.next().value); )
            if (n = r.Ja,
            D = b(r.ec))
                A = a.o0,
                z = a.aca;
        D && 1 < n.length && (e || (z = gvjs_Ee(r.Ja, function(G, J) {
            var I = d.zc(J.za);
            return J.S_ || I > l ? G : Math.max(G, I)
        }, -Infinity),
        k = Math.max(k, z)),
        f || (r = gvjs_Ee(r.Ja, function(G, J) {
            var I = d.zc(J.za);
            return J.S_ || I < m ? G : Math.min(G, I)
        }, Infinity),
        h = Math.min(h, r)));
        q = k != g || h != q;
        g = {
            min: k,
            max: h
        };
        gvjs_GI(a, g);
        gvjs_xI(a)
    }
    a.yg = null;
    A = A || [];
    z = c(A);
    return {
        Ja: n,
        baseline: gvjs_II(a),
        ec: A,
        ticks: z
    }
}
function gvjs_CI(a, b, c) {
    var d = []
      , e = gvjs_v(a.yg, function(g) {
        var h = a.ta.zc(g.v);
        return {
            za: new Date(h + c),
            Me: g.f,
            brush: a.dt
        }
    })
      , f = null;
    if (f = gvjs_6H(b, e, b.Yca || b.qca).next().value)
        if (null == f || 0 === f.length)
            return [];
    gvjs_u(e, function(g, h) {
        var k = g.za
          , l = k.getTime() - c;
        null != l && (l = a.Jc(l),
        null == l || isNaN(l) || (g.Na = l,
        g.isVisible = !0,
        d.push({
            za: k,
            Na: l,
            text: f[h].text,
            isVisible: !0
        })))
    });
    return d
}
function gvjs_Ifa(a) {
    function b(z) {
        z = c({
            dk: z
        });
        return gvjs_BI(a, z)
    }
    function c(z) {
        return a.yg ? gvjs_Kfa(a, v) : gvjs_Lfa(a, z.dk)
    }
    var d = a.ta
      , e = !0
      , f = !0;
    a.qM != gvjs_Lv && (e = isFinite(a.nb.min),
    f = isFinite(a.nb.max));
    var g = gvjs_FI(a)
      , h = g
      , k = h.min;
    h = h.max;
    gvjs_GI(a, g);
    gvjs_xI(a);
    var l = k
      , m = h
      , n = Math.abs(h - k);
    isFinite(n) || (n = 1);
    var p = a.baseline.za;
    g = null == p ? null : d.zc(p);
    var q = a.cZ();
    p = d.Vz.inverse(d.sn);
    var r = d.Vz.inverse(d.rn);
    gvjs_uI(a, p);
    gvjs_uI(a, r);
    r = Math.abs(a.ef - a.Pf);
    var t = a.gw ? 0 : 1
      , u = new gvjs_WH(a.V.sc,a.ud);
    gvjs_hq(a.options, 1, {
        format: d.Xe
    });
    var v = gvjs_DI(a);
    p = a.Gv;
    -1 === p && (p = null);
    var w = a.caa;
    null != p && 2 < p && (a.gw && (p *= 2),
    w = r / Math.max(1, p + 1));
    null == w && (w = 40,
    a.vi() === gvjs_S && (w *= 2));
    a.gw && (w /= 2);
    e || (null != g && g <= k && k - n < g && (k = g,
    e = !0),
    a.mga && 0 >= k && (k = .1 * l));
    !f && null != g && g >= h && h + n < g && (h = g,
    f = !0);
    gvjs_hq(a.options, 0, {
        gridlines: {
            minSpacing: w
        }
    });
    n = function(z, A) {
        function B(I) {
            return gvjs_qA(13, d.Vz.inverse(I))
        }
        var D = B(z)
          , C = B(A)
          , G = e ? null : B(l)
          , J = f ? null : B(m);
        if (isNaN(D) || isNaN(C))
            return {
                dk: [],
                DR: [],
                min: z,
                max: A
            };
        z = q.ZK + .5;
        A = q.XK - .5;
        a.gw && (A -= .5);
        return gvjs_VH(new gvjs_SH(D,C,z,A,q.Sg,t,a.eV || 1,q.orientation,a.options,u,v,b,function(I) {
            a.Jc = function(M) {
                if (null == M)
                    return null;
                M = B(M);
                return I.Ya(M)
            }
            ;
            a.uN = function(M) {
                if (null == M)
                    return null;
                M = I.Ae(M);
                return gvjs_fI(d, M)
            }
        }
        ), D, C, G, J)
    }(k, h);
    k = gvjs_fI(d, n.min);
    h = gvjs_fI(d, n.max);
    g = {
        min: k,
        max: h
    };
    gvjs_GI(a, g);
    gvjs_xI(a);
    k = a.o0 || [];
    if (0 === p || 1 === p)
        n.dk = gvjs_Oe(n.dk, 0, p);
    2 === p && (n.dk = [n.dk[0], n.dk[n.dk.length - 1]]);
    h = c(n);
    var x = [];
    if (!a.yg) {
        var y = {};
        gvjs_u(h, function(z) {
            y[(Math.round(1E4 * z.Na) / 1E4).toString()] = !0
        });
        a.wta && (null == p || 2 <= p) && gvjs_u(n.DR || [], function(z) {
            z = z.getValue();
            z = gvjs_fI(d, z);
            z = a.Jc(z);
            z = Math.round(1E4 * z) / 1E4;
            y[z.toString()] || x.push(z)
        })
    }
    p = gvjs_v(h, function(z) {
        return {
            tick: z,
            za: z.za,
            Na: z.Na,
            isVisible: gvjs_EI(this, z.Na),
            length: null,
            brush: this.dt
        }
    }, a);
    0 < x.length && (n = gvjs_v(x, function(z) {
        return {
            za: this.U7(z),
            Na: z,
            isVisible: !0,
            length: null,
            brush: this.CR
        }
    }, a),
    gvjs_Me(p, n));
    if (n = gvjs_II(a))
        n.isVisible = gvjs_EI(a, n.Na);
    return {
        Ja: p,
        baseline: n,
        ec: k,
        ticks: h
    }
}
function gvjs_Lfa(a, b) {
    var c = [];
    gvjs_u(b, function(d) {
        var e = d.Dd()
          , f = d.getValue()
          , g = null == f ? null : a.ta.QR(f);
        f = gvjs_fI(a.ta, f);
        f = a.Jc(f);
        if (!isNaN(f)) {
            f = Math.round(1E4 * f) / 1E4;
            var h = gvjs_EI(a, f);
            d.ssa && h && c.push({
                za: g,
                Na: f,
                text: e || "",
                isVisible: h
            })
        }
    });
    return c
}
function gvjs_Kfa(a, b) {
    var c = gvjs_v(a.yg, function(f) {
        return f.v
    });
    c = gvjs_wH(c);
    b.nw(c);
    var d = b.cd()
      , e = [];
    gvjs_u(a.yg, function(f) {
        var g = f.v
          , h = a.ta.zc(g);
        null != h && (h = a.Jc(h),
        null != h && !isNaN(h) && gvjs_EI(a, h) && (f = f.f,
        typeof f !== gvjs_l && (f = d.Ob(g)),
        e.push({
            za: g,
            Na: h,
            text: f,
            isVisible: !0
        })))
    });
    return e
}
function gvjs_DI(a) {
    var b = a.options;
    a = new gvjs_zH;
    var c = {
        pattern: b.cb([gvjs_Fu, "format.pattern"]),
        fractionDigits: b.Aa(["format.fractionDigits", "formatOptions.fractionDigits"]),
        significantDigits: b.Aa(["format.significantDigits"]),
        scaleFactor: b.Aa(["format.scaleFactor", gvjs_Hu, "formatter.scaleFactor"]),
        prefix: b.cb(["format.prefix", gvjs_Gu, "formatter.prefix"]),
        suffix: b.cb(["format.suffix", gvjs_Iu, "formatter.suffix"]),
        decimalSymbol: b.cb(["format.decimalSymbol"]),
        groupingSymbol: b.cb(["format.groupingSymbol"]),
        negativeColor: b.cb(["format.negativeColor"]),
        negativeParens: b.cb(["format.negativeParens"])
    };
    a.y$ = c;
    a.DF = !1;
    c = b.Aa(["format.numDecimals", "formatter.numDecimals", "formatOptions.numDecimals"]);
    typeof c === gvjs_g && (a.yR(c),
    a.nw(c));
    c = b.Aa(["format.maxNumDecimals", "formatter.maxNumDecimals", "formatOptions.maxNumDecimals"]);
    typeof c === gvjs_g && a.nw(c);
    var d = b.Aa(["format.minNumDecimals", "formatter.minNumDecimals", "formatOptions.minNumDecimals"]);
    typeof d === gvjs_g && a.yR(d);
    d = b.Aa(["format.numSignificantDigits", "formatter.numSignificantDigits", "formatOptions.numSignificantDigits"]);
    typeof d === gvjs_g && a.gK(d);
    (d = b.fa(["format.unit", "formatter.unit", "formatOptions.unit"])) && a.unit({
        symbol: d.symbol,
        position: d.position,
        usePadding: d.usePadding
    });
    b = b.fa(["format.useMagnitudes", "formatter.useMagnitudes", "formatOptions.useMagnitudes"]);
    null != b && (d = a.P5.bind(a),
    "long" === b && (d = a.M5.bind(a)),
    d(typeof c === gvjs_g ? c : 5));
    return a
}
function gvjs_II(a) {
    var b = null;
    a.type == gvjs_Vd && a.baseline && (b = {
        za: a.baseline.za,
        Na: a.baseline.Na,
        isVisible: !0,
        length: null,
        brush: a.Jka
    });
    return b
}
function gvjs_Gfa(a) {
    if (a.yg) {
        var b = Infinity
          , c = -Infinity;
        gvjs_u(a.yg, function(e) {
            e = this.ta.zc(e.v);
            b = Math.min(b, e);
            c = Math.max(c, e);
            this.oc(e)
        }, a);
        if (1 < a.yg.length) {
            var d = a.ta.rn;
            b <= a.ta.sn && !isFinite(a.nb.min) && (a.nb.min = b);
            c >= d && !isFinite(a.nb.max) && (a.nb.max = c)
        }
    }
}
function gvjs_FI(a) {
    var b = isFinite(a.nb.min) ? a.nb.min : a.ta.sn;
    isFinite(b) || (b = 0);
    var c = isFinite(a.nb.max) ? a.nb.max : a.ta.rn;
    isFinite(c) || (c = 1);
    if (b === c) {
        if (gvjs_vI(a)) {
            a = new Date(b);
            a = gvjs_BA([a.getMilliseconds(), a.getSeconds(), a.getMinutes(), a.getHours(), a.getDate() - 1, a.getMonth(), a.getFullYear()]);
            var d = [1, 1E3, 6E4, 36E5, 864E5, 26784E5];
            a = a < d.length ? d[a] : 316224E5
        } else
            a = 1;
        b -= a;
        c += a
    }
    return {
        min: b,
        max: c
    }
}
function gvjs_GI(a, b) {
    var c = b.min;
    null != c && (a.ta.sn = c);
    c = b.max;
    null != c && (a.ta.rn = c);
    a.nb = b;
    a.ww = a.vG / Math.max(1, b.max - b.min);
    Infinity !== b.min && (a.nM = b.min)
}
function gvjs_xI(a) {
    var b = null == a.pO ? null : a.ta.zc(a.pO);
    a.ta.wda = b;
    if (null != b) {
        var c = a.Jc(b);
        isNaN(c) && (c = Infinity);
        a.baseline = {
            za: a.ta.Xq(b),
            Na: c
        }
    } else
        a.baseline = {
            za: null,
            Na: Infinity,
            isVisible: !1
        }
}
gvjs_.oc = function(a) {
    this.type == gvjs_Vd && null != a && (!this.mga || 0 <= a) && (this.ta.oc(a),
    this.hG.push(a))
}
;
function gvjs_JI(a) {
    if (a.type == gvjs_Vd) {
        var b = a.ta
          , c = b.sn
          , d = b.rn
          , e = .01 * (d - c);
        0 < c && -Infinity == a.nb.min && (c = Math.max(c - e, 0),
        null != c && (b.sn = c));
        0 > d && Infinity == a.nb.max && (a = Math.min(d + e, 0),
        null != a && (b.rn = a))
    }
}
gvjs_.Jc = function(a) {
    return null == a || 0 === this.ww ? null : this.Pf + (a - this.nM) * this.direction * this.ww
}
;
gvjs_.uN = function(a) {
    return null == a || 0 === this.ww ? null : (a - this.Pf) * this.direction / this.ww + this.nM
}
;
gvjs_.U7 = function(a) {
    a = this.uN(a);
    return null == a ? null : this.Xq(a)
}
;
gvjs_.vN = function(a) {
    a = this.sda(a);
    return null == a ? null : this.Jc(a)
}
;
function gvjs_HI(a, b) {
    return null == b ? null : 2 * a.Pf - b
}
function gvjs_KI(a, b) {
    return isNaN(b) ? !0 : b * a.direction > a.ef * a.direction
}
function gvjs_EI(a, b) {
    return !isNaN(b) && Infinity != b && !(isNaN(b) || b * a.direction < a.Pf * a.direction) && !gvjs_KI(a, b)
}
gvjs_.sda = function(a) {
    return this.type == gvjs_Vd ? this.ta.zc(a) : a
}
;
gvjs_.Xq = function(a) {
    return null == a ? null : this.type == gvjs_Vd ? this.ta.Xq(a) : a
}
;
function gvjs_AI(a) {
    switch (a.type) {
    case gvjs_Ht:
        return a.nb.min - .5
    }
    return a.nb.min
}
function gvjs_LI(a, b) {
    return null == b ? !1 : a.type == gvjs_Vd ? b >= a.nb.min && b <= a.nb.max : b >= Math.floor(a.nb.min) && b < Math.ceil(a.nb.max)
}
function gvjs_vI(a) {
    return null != a.ta && (a.ta instanceof gvjs_gI || a.ta instanceof gvjs_sI)
}
function gvjs_BI(a, b) {
    a.ticks = b;
    a.ec = null;
    b = a.uj;
    b === gvjs_f && (a.uj = gvjs_Fp);
    a.W7();
    a.V7();
    var c = null;
    b === gvjs_f && (a.ec = []);
    a.ec && a.o7() && (a.o0 = a.ec,
    a.aca = a.ticks,
    c = a.ec);
    a.uj = b;
    return c
}
;function gvjs_Mfa(a, b, c, d) {
    this.Y0 = Math.pow(a, 2);
    this.K0 = Math.pow(b, 2);
    this.Fma = b;
    this.M2 = (this.Or = c ? new gvjs_O(d.transform(c.start),d.transform(c.end)) : null) ? this.Or.end - this.Or.start : null;
    this.vda = d
}
function gvjs_MI(a, b) {
    var c = null;
    null != b && null != a.vda && (b = a.vda.transform(b));
    if (null != b && null != a.Or)
        0 === a.M2 && b === a.Or.start ? c = (a.K0 + a.Y0) / 2 : b <= a.Or.start ? c = a.Y0 : b >= a.Or.end && (c = a.K0);
    else if (!a.M2 || null == b)
        return a.Fma;
    null == c && (b = gvjs_0g(b, a.Or.start, a.Or.end),
    c = gvjs_4y(a.Y0, a.K0, (b - a.Or.start) / a.M2));
    return Math.round(Math.sqrt(c))
}
function gvjs_NI(a, b) {
    var c = gvjs_Oj(a, "sizeAxis.minSize")
      , d = gvjs_Oj(a, "sizeAxis.maxSize");
    if (c > d)
        throw Error("sizeAxis.minSize (" + c + ") must be at most sizeAxis.maxSize (" + d + ")");
    var e = a.Aa("sizeAxis.minValue")
      , f = a.Aa("sizeAxis.maxValue");
    if (null != e && null != f && e > f)
        throw Error("sizeAxis.minValue (" + e + ") must be at most sizeAxis.maxValue (" + f + ")");
    b = gvjs_9B(b, e, f);
    a = gvjs_dF(a, "sizeAxis.logScale", "sizeAxis.scaleType");
    a = gvjs_eF(a, 1, []);
    return new gvjs_Mfa(c,d,b,a)
}
;function gvjs_OI(a, b, c, d) {
    this.Cl = a;
    this.m = b;
    this.xl = d;
    this.Zd = c;
    this.Za = gvjs_ry(this.m, "bubble.textStyle", {
        bb: d.Hj,
        fontSize: d.Dl,
        Lb: d.oz
    });
    this.Qya = gvjs_K(this.m, "bubble.highContrast", !1);
    this.$T = gvjs_oy(this.m, "bubble.stroke", gvjs_yr);
    this.lK = gvjs_ny(this.m, gvjs_zt, .8);
    this.gla = [[255, 255, 255], [97, 97, 97]];
    this.m1 = 0;
    this.tM = 1;
    this.vM = 2;
    this.qs = 3;
    this.iu = 4;
    this.aq = this.Wfa = this.t8 = this.Iha = this.Cha = "";
    this.YX = this.m.fa(gvjs_2t, gvjs_MF);
    this.sO = gvjs_5F(this.YX[0]).color;
    this.tL = this.rs = this.t4 = this.aX = this.$D = this.TB = null;
    this.Yj()
}
gvjs_OI.prototype.Yj = function() {
    function a(k, l, m) {
        if (c.$() <= k)
            return "";
        var n = c.W(k);
        if (l && !gvjs_He(m, n))
            throw Error(gvjs_wa + k + " must be of type " + m.join("/"));
        if (!l && gvjs_He(m, n))
            throw Error(gvjs_wa + k + " cannot be of type " + m.join("/"));
        return n
    }
    var b = this.xl
      , c = this.Cl
      , d = c.$();
    if (3 > d)
        throw Error("Data table should have at least 3 columns");
    a(this.m1, !0, [gvjs_l]);
    var e = a(this.tM, !1, [gvjs_l])
      , f = a(this.vM, !1, [gvjs_l]);
    this.Cha = c.Ga(this.tM);
    this.Iha = c.Ga(this.vM);
    typeof this.qs === gvjs_g && this.qs < d ? (this.aq = a(this.qs, !0, [gvjs_g, gvjs_l]),
    this.aq == gvjs_l && (this.TB = {},
    this.$D = []),
    this.t8 = c.Ga(this.qs)) : this.qs = null;
    var g = !1;
    typeof this.iu === gvjs_g && this.iu < d ? (a(this.iu, !0, [gvjs_g]),
    this.Wfa = c.Ga(this.iu),
    g = gvjs_K(this.m, "sortBubblesBySize", !0)) : this.iu = null;
    b.$a = [];
    b.Ds = {};
    for (d = 0; d < c.ca(); d++) {
        var h = c.fj(d);
        b.Ds[h] = d
    }
    b.C = [{
        type: gvjs_At,
        Yg: gvjs_K(this.m, ["series.0.enableInteractivity", gvjs_ru], !0),
        rM: !0,
        NT: !0,
        wxa: g,
        points: [],
        uCa: this.TB,
        hEa: this.$D
    }];
    b.hv = e;
    b.HL = [f];
    b.wh = {};
    b.wh.bubbles = 1;
    b.Vo = []
}
;
function gvjs_Nfa(a, b, c) {
    for (var d = a.Cl, e = 0; e < d.ca(); e++) {
        var f = d.getValue(e, a.tM)
          , g = d.getValue(e, a.vM);
        f = gvjs_eI(b.ta, f);
        g = gvjs_eI(c.ta, g);
        null != f && gvjs_uI(b, f);
        null != g && gvjs_uI(c, g)
    }
}
gvjs_OI.prototype.fka = function(a) {
    if (a) {
        var b = gvjs_vj(gvjs_PI(this, a.Kf))
          , c = gvjs_x(a.ja);
        b = gvjs_uj(gvjs_4z(b, this.gla));
        c.color = b;
        a.ja = c
    }
}
;
gvjs_OI.prototype.AW = function(a, b) {
    var c = this.Cl
      , d = c.Ha(a, this.tM)
      , e = c.Ha(a, this.vM);
    d = [{
        title: this.Cha || "X",
        value: d
    }, {
        title: this.Iha || "Y",
        value: e
    }];
    null != this.qs && (e = c.Ha(a, this.qs),
    d.push({
        title: this.t8 || gvjs_7r,
        value: e
    }));
    null != this.iu && (a = c.Ha(a, this.iu),
    d.push({
        title: this.Wfa || "Size",
        value: a
    }));
    return {
        title: b,
        lines: d
    }
}
;
function gvjs_PI(a, b) {
    return a.aq == gvjs_g ? gvjs_XH(a.rs, b.color) : a.aq == gvjs_l ? a.TB[b.color].color : a.sO
}
;function gvjs_QI(a, b, c, d, e) {
    this.lb = this.Ta = a;
    this.options = b;
    this.sc = c;
    this.Dg = this.ne = null;
    a = this.V = this.B8();
    a.sc = c;
    a.width = d;
    a.height = e;
    a.Fa = gvjs_J(b, gvjs_Sd, gvjs_f, gvjs_eC);
    a.Hj = gvjs_J(b, gvjs_yp);
    a.Dl = gvjs_Oj(b, gvjs_zp, Math.round(Math.pow(2 * (a.width + a.height), 1 / 3)));
    a.DH = gvjs_J(b, "seriesType", gvjs_e, gvjs_fC);
    a.Yg = gvjs_K(b, gvjs_ru, !0);
    a.$f = gvjs_K(b, gvjs_nx);
    a.ax = gvjs_qy(b, "tooltip.boxStyle");
    a.FE = gvjs_J(b, gvjs_Kw, gvjs_Ww, gvjs_lC);
    a.O5 = gvjs_K(b, "legend.newLegend");
    a.xG = gvjs_qy(b, gvjs_ht);
    a.h8 = gvjs_qy(b, gvjs_Nt);
    c = a.h8;
    d = a.xG;
    c = gvjs_hy(c) ? c.fill : gvjs_hy(d) ? gvjs_gy(c) ? gvjs_7z(c.fill, d.fill, c.fillOpacity) : d.fill : null;
    a.SM = c;
    a.Kka = gvjs_oy(b, gvjs_mt, "");
    a.baa = gvjs_oy(b, gvjs_Qu, "");
    a.oz = a.SM || "";
    c = gvjs_J(b, gvjs_fx);
    a.oF = gvjs_J(b, "titlePosition", gvjs_aw, gvjs_jC);
    d = gvjs_ry(b, gvjs_ix, {
        bb: a.Hj,
        fontSize: a.Dl,
        Lb: a.oF == gvjs_Fp ? a.oz : gvjs_f
    });
    a.title = {
        text: c,
        ja: d,
        vl: null,
        lines: [],
        ld: gvjs_2,
        Pc: gvjs_R,
        tooltip: "",
        anchor: null,
        angle: 0
    };
    a.DB = gvjs_J(b, "axisTitlesPosition", gvjs_aw, gvjs_jC);
    a.$c = gvjs_K(b, "is3D");
    a.bw = gvjs_K(b, "isRtl", !1);
    a.Mfa = gvjs_K(b, "shouldHighlightSelection", !0);
    a.Zj = gvjs_K(b, gvjs_hv);
    a.qz = gvjs_J(b, "interactivityModel", gvjs_eu, gvjs_aea);
    this.M8()
}
gvjs_ = gvjs_QI.prototype;
gvjs_.$g = function() {
    return this.V
}
;
gvjs_.B8 = function() {
    return new gvjs_6F
}
;
gvjs_.ti = function() {
    return this.V
}
;
gvjs_.init = function(a, b) {
    var c = this
      , d = Infinity;
    if (null != b) {
        var e = this.options.fa("async", null);
        d = typeof e === gvjs_g ? e : (e = gvjs_K(this.options, "async", !1)) ? 100 : Infinity
    }
    var f = gvjs_Ke([this.ala.bind(this)], this.nz())
      , g = a(function() {
        for (var h = Date.now(), k = 0; 0 < f.length && k <= d; )
            (k = f.shift()()) && (f = gvjs_Ke(k, f)),
            k = Date.now() - h;
        if (0 === f.length) {
            if (c.V.qz == gvjs_lu && (!c.V.wh || c.V.wh.line != c.V.C.length))
                throw Error("DIVE interactivity model is only supported when all series are of type line.");
            b && b(c)
        } else
            setTimeout(g, 0)
    });
    g()
}
;
gvjs_.nz = function() {
    var a = this, b;
    return [function() {
        b = a.ti()
    }
    , function() {
        var c = a.N$()
          , d = a.M$()
          , e = null
          , f = b.Fa;
        !b.kd || f !== gvjs_fw && f !== gvjs_Dd ? b.O5 && f !== gvjs_fw && f !== gvjs_yt && (e = 2) : e = 2;
        e = a.options.Aa("legend.iconAspectRatio") || e;
        a.ne = new gvjs_jI(b,a.options,c,e);
        a.Dg = new gvjs_1H(b,a.options,d)
    }
    , this.tN.bind(this), function() {
        gvjs_vfa(a.ne);
        var c = a.V
          , d = c.title.ja.fontSize
          , e = a.ne.Za.fontSize
          , f = a.ne.getPosition()
          , g = a.Dg.Za.fontSize
          , h = a.Dg.getPosition()
          , k = c.oF == gvjs_aw ? c.title.text : ""
          , l = gvjs_DG(a.sc, k, c.title.ja, c.O.width, Infinity)
          , m = Math.max(2, Math.round(d / 3.236))
          , n = Math.max(2, Math.round(e / 1.618))
          , p = Math.max(2, Math.round(g / 1.618));
        g = [];
        g.push({
            key: gvjs_wt,
            min: 2,
            extra: [Math.max(2, Math.round(1.618 * c.Dl)) - 2]
        });
        g.push({
            key: gvjs_wx,
            min: 0,
            extra: [Infinity]
        });
        0 < l.lines.length && g.push({
            key: gvjs_fx,
            min: d + 2,
            extra: []
        });
        if (f == gvjs_vx) {
            f = a.ne;
            for (var q = c.O.width, r = f.iG, t = gvjs_lI(f, r, q), u = 1; (0 == f.Hca || f.Hca > u) && t.length < r.length; )
                ++u,
                r = gvjs_Oe(r, t.length),
                t = gvjs_lI(f, r, q);
            f = u;
            for (q = 0; q < f; ++q)
                g.push({
                    key: gvjs_rv,
                    min: e + 2,
                    extra: [n - 2]
                })
        }
        h == gvjs_vx && g.push({
            key: gvjs_1t,
            min: a.Dg.getHeight() + 2,
            extra: [p - 2]
        });
        for (h = 1; h < l.lines.length; h++)
            g.push({
                key: gvjs_fx,
                min: d + 2,
                extra: [m - 2]
            });
        l = gvjs_oA(g, c.O.top);
        d = l[gvjs_wx][0] || 0;
        m = l.title || [];
        h = gvjs_DG(a.sc, k, c.title.ja, c.O.width, m.length);
        for (n = 0; n < h.lines.length; n++)
            d += m[n],
            c.title.lines.push({
                text: h.lines[n],
                x: c.O.left,
                y: d,
                length: c.O.width
            });
        c.title.tooltip = h.oe ? k : "";
        k = l.legend || [];
        0 < k.length && (a.ne.eG = k.length,
        e = d + k[0] - e,
        d += gvjs_az.apply(null, k),
        a.ne.qr(new gvjs_B(e,c.O.right,d,c.O.left)));
        e = l.colorBar || [];
        0 < e.length && (d += e[0],
        c = new gvjs_B(d - a.Dg.getHeight(),c.O.right,d,c.O.left),
        a.Dg.qr(c));
        b.legend = a.ne.define();
        b.Vi = a.Dg.define()
    }
    ]
}
;
gvjs_.M8 = function() {
    this.lb = new gvjs_N(this.Ta);
    if (2 > this.lb.$())
        throw Error("Not enough columns given to draw the requested chart.");
}
;
gvjs_.mea = function() {}
;
gvjs_.ala = function() {
    var a = this.V
      , b = {
        width: this.options.Mg(gvjs_3o, a.width),
        left: this.options.Mg(gvjs_0o, a.width),
        right: this.options.Mg(gvjs_1o, a.width),
        height: this.options.Mg(gvjs__o, a.height),
        top: this.options.Mg(gvjs_2o, a.height),
        bottom: this.options.Mg(gvjs_Zo, a.height)
    };
    a.O = gvjs_$q(a.width, a.height, b)
}
;
function gvjs_RI(a, b, c, d, e, f, g, h, k, l) {
    this.DU = a;
    this.fg = b;
    this.goa = c;
    this.eta = d;
    this.Cca = e;
    this.bP = f;
    this.rxa = g;
    this.d1 = h;
    this.mka = k;
    this.X7 = l
}
function gvjs_SI(a, b, c, d) {
    switch (d) {
    case "attachToEnd":
        return (b - 1 - a) % c;
    default:
        return a
    }
}
function gvjs_TI(a, b, c) {
    b = Math.ceil((a.fg.length - 0) / (b * c));
    return 2 > a.fg.length || 2 > b
}
function gvjs_Ofa(a, b, c, d, e) {
    b = gvjs_SI(b, a.fg.length, d, a.rxa);
    for (var f = 1 >= a.fg.length ? a.DU : Math.max(0, Math.abs(a.fg[1].Na - a.fg[0].Na) * d - a.d1), g = []; b < a.fg.length; b += d) {
        var h = a.fg[b]
          , k = h.isVisible && !a.mka ? Math.min(f, 2 * h.Na, 2 * (a.DU - h.Na)) : f
          , l = a.X7(h.text, k, e)
          , m = l.oe;
        k < f && (m = a.X7(h.text, f, e).oe);
        g.push({
            za: h.za,
            isVisible: h.isVisible,
            optional: h.optional,
            Na: h.Na,
            jca: c,
            text: h.text,
            width: l.Oq,
            layout: l,
            oe: m
        })
    }
    return g
}
function gvjs_UI(a, b, c, d) {
    var e = b * c;
    d = 1 < b ? 1 : d;
    for (var f = [], g = 0; g < b; g++) {
        var h = gvjs_Ofa(a, a.goa + g * c, g * d, e, d);
        gvjs_Me(f, h)
    }
    gvjs_Qe(f, function(k, l) {
        return k.Na - l.Na
    });
    return f
}
function gvjs_VI(a, b, c) {
    a = gvjs_UI(a, b, c, a.eta);
    return gvjs_Ee(a, function(d, e) {
        return {
            vw: Math.max(d.vw, e.layout.lines.length),
            oe: d.oe || e.oe
        }
    }, {
        vw: 0,
        oe: !1
    })
}
function gvjs_WI(a) {
    for (var b = 1, c = a.bP || 1, d = gvjs_VI(a, b, c), e = b; d.oe && b < a.Cca; ) {
        b++;
        if (gvjs_TI(a, b, c))
            break;
        e = b;
        d = gvjs_VI(a, e, c)
    }
    b = c;
    if (!a.bP) {
        c = a.fg.length / e * a.d1 / a.DU;
        if (isNaN(c) || !isFinite(c) || 1 > c)
            c = 1;
        var f = new gvjs_vH(gvjs_XI);
        f.floor(c);
        for (c = f.next(); d.oe && c < a.fg.length && !gvjs_TI(a, e, c); )
            b = c,
            d = gvjs_VI(a, e, b),
            c = f.next()
    }
    return {
        PV: e,
        skip: b,
        vw: d.vw * e
    }
}
function gvjs_YI(a, b, c, d, e) {
    a = gvjs_UI(a, b, c, d);
    e = gvjs_Ee(a, function(f, g) {
        var h = g.oe ? 1 : 0;
        delete g.oe;
        return f + h
    }, 0) <= a.length * e;
    return {
        jU: a,
        O6: e
    }
}
function gvjs_ZI(a, b, c, d, e) {
    var f = Math.min(a.Cca, d)
      , g = Math.min(b, f)
      , h = a.bP || c;
    c = gvjs_YI(a, g, h, d, e);
    for (b = g; !c.O6 && g < f; ) {
        g++;
        if (gvjs_TI(a, g, h))
            break;
        b = g;
        c = gvjs_YI(a, b, h, d, e)
    }
    f = h;
    if (!a.bP) {
        h = a.fg.length / b * a.d1 / a.DU;
        if (isNaN(h) || !isFinite(h) || 1 > h)
            h = 1;
        g = new gvjs_vH(gvjs_XI);
        g.floor(h);
        for (h = g.next(); !c.O6 && h < a.fg.length && !gvjs_TI(a, b, h); )
            f = h,
            c = gvjs_YI(a, b, f, d, e),
            h = g.next()
    }
    return {
        PV: b,
        skip: f,
        jU: c.jU
    }
}
var gvjs_XI = [1, 2, 3, 4, 5];
function gvjs__I(a, b, c, d, e, f) {
    gvjs_tI.call(this, a, b, gvjs_Ke(["hAxes." + d, gvjs_Xu], c), d, e, f);
    this.Y6 = !1;
    this.oS()
}
gvjs_o(gvjs__I, gvjs_tI);
gvjs_ = gvjs__I.prototype;
gvjs_.oS = function() {
    var a = this.options;
    this.w4 = a.Dq("slantedText");
    var b = gvjs_L(a, "slantedTextAngle", 30);
    this.Yfa = b = gvjs_3y(b, 360);
    this.PT = gvjs_6y(b);
    this.Eka = gvjs_Oj(a, gvjs_Ev, .5 * this.ud.fontSize);
    this.l$ = gvjs_Oj(a, "firstVisibleText");
    this.kR = gvjs_Oj(a, "maxTextLines", Infinity);
    this.J0 = gvjs_Oj(a, gvjs_Iv, 2);
    this.aP = gvjs_Oj(a, "showTextEvery", 0);
    this.v4 = gvjs_J(a, "showTextEveryMode", "attachToStart", gvjs_dea);
    this.Vca = gvjs_Oj(a, "minTextSpacing", this.ud.fontSize);
    gvjs_K(a, ["allowContainerBoundaryTextCutoff", "allowContainerBoundaryTextCufoff"], !1)
}
;
gvjs_.H$ = function() {
    return "hAxis#" + this.index
}
;
gvjs_.wW = function(a, b) {
    var c = this.V.O;
    return gvjs_zI(this, c.width, 1 == this.direction ? c.left : c.right, a, b)
}
;
gvjs_.W7 = function() {
    var a = this
      , b = null != this.ec;
    if (0 == this.index) {
        var c = this.V.sc
          , d = this.ud.fontSize
          , e = this.title.ja.fontSize
          , f = this.V.DB == gvjs_aw ? this.title.text : ""
          , g = new gvjs_RI(this.V.width,this.ticks,this.l$,this.kR,this.J0,this.aP,this.v4,this.Vca,this.Y6,function(y, z, A) {
            return gvjs_DG(c, y, a.ud, z, A)
        }
        )
          , h = this.aP || 1;
        if (this.uj == gvjs_aw)
            if (null == this.w4)
                if (this.ticks.length * d / (this.J0 * h) <= this.V.width) {
                    var k = gvjs_WI(g);
                    if (k.skip > h || 0 == k.vw) {
                        var l = gvjs_0I(this, c);
                        k = null
                    }
                } else
                    l = gvjs_0I(this, c);
            else
                this.w4 ? l = gvjs_0I(this, c) : k = gvjs_WI(g);
        var m = gvjs_DG(c, f, this.title.ja, this.V.O.width, Infinity)
          , n = this.Yo
          , p = Math.max(n, Math.round(d / 1.618))
          , q = Math.max(n, Math.round(d / 3.236));
        f = function() {
            return {
                key: gvjs_ex,
                min: l.minHeight + n,
                max: l.maxHeight + n,
                extra: [p - n]
            }
        }
        ;
        var r = [];
        r.push({
            key: gvjs_wt,
            min: n,
            extra: [Infinity]
        });
        0 < m.lines.length && r.push({
            key: gvjs_fx,
            min: e + n,
            extra: [Infinity]
        });
        var t = this.ne.Za.fontSize;
        this.ne.getPosition() == gvjs_vt && r.push({
            key: gvjs_rv,
            min: t + this.Yo,
            extra: [Infinity]
        });
        this.Dg.getPosition() == gvjs_vt && r.push({
            key: gvjs_1t,
            min: this.Dg.getHeight() + n,
            extra: [Infinity]
        });
        t = r.length;
        k && 0 < k.vw ? r.push({
            key: gvjs_ex,
            min: d + n,
            extra: [p - n]
        }) : l && r.push(f());
        var u = r.length;
        if (k)
            for (var v = 1; v < k.vw; v++)
                r.push({
                    key: gvjs_ex,
                    min: d + n,
                    extra: [q - n]
                });
        d = r.length;
        for (q = 1; q < m.lines.length; q++)
            r.push({
                key: gvjs_fx,
                min: e + n,
                extra: [this.D$ - n]
            });
        this.LV = e = gvjs_oA(r, this.V.height - this.V.O.bottom);
        var w = e.ticks || [];
        if (k) {
            var x = gvjs_ZI(g, k.PV, k.skip, w.length, 0);
            null == this.w4 && x.skip > h && (x = k = null,
            l = gvjs_0I(this, c),
            r[t] = f(),
            r = gvjs_Ida(r, 0, u, d, void 0),
            e = gvjs_oA(r, this.V.height - this.V.O.bottom))
        }
        this.ij = this.V.O.bottom;
        w = e.ticks || [];
        if (0 < w.length) {
            for (g = 1; g < w.length; g++)
                w[g] += w[g - 1];
            if (b && 1 == w.length)
                for (b = this.ij + w[0],
                g = 0; g < this.ec.length; g++)
                    h = this.ec[g].Da,
                    h.anchor = h.anchor || new gvjs_HG(0,0),
                    h.anchor.y = b;
            k ? this.ec = gvjs_v(x.jU, function(y, z) {
                var A = gvjs_v(y.layout.lines, function(B, D) {
                    return {
                        x: 0,
                        y: w[y.jca + D],
                        length: y.width,
                        text: B
                    }
                });
                z = a.ec && a.ec[z] && a.ec[z].Da;
                return {
                    za: y.za,
                    isVisible: y.isVisible,
                    optional: y.optional,
                    Da: {
                        text: y.text,
                        ja: a.ud,
                        lines: A,
                        ld: z ? z.ld : gvjs_0,
                        Pc: z ? z.Pc : gvjs_R,
                        tooltip: y.layout.oe ? y.text : "",
                        anchor: new gvjs_HG(y.Na,a.ij),
                        angle: 0
                    }
                }
            }) : l && (k = w[0],
            x = Math.min(k - n, l.maxHeight),
            this.ec = gvjs_Pfa(this, c, this.ij + k - x, x, l.skip));
            this.ij += gvjs_Ae(w)
        }
        gvjs_Qfa(this);
        gvjs_Rfa(this);
        gvjs_Sfa(this)
    }
}
;
function gvjs_Qfa(a) {
    var b = a.V.sc
      , c = a.V.DB == gvjs_aw ? a.title.text : ""
      , d = a.LV.title || [];
    if (0 < d.length)
        for (b = gvjs_DG(b, c, a.title.ja, a.V.O.width, d.length),
        a.title.tooltip = b.oe ? c : "",
        a.title.lines = [],
        c = 0; c < d.length; c++)
            a.ij += d[c],
            a.title.Pc = gvjs_R,
            a.title.lines.push({
                x: a.V.O.left + a.V.O.width / 2,
                y: a.ij,
                length: a.V.O.width,
                text: b.lines[c]
            })
}
function gvjs_Rfa(a) {
    var b = a.ne.Za.fontSize
      , c = a.LV.legend || [];
    0 < c.length && (a.ij += c[0],
    a.ne.qr(new gvjs_B(a.ij - b,a.V.O.right,a.ij,a.V.O.left)))
}
function gvjs_Sfa(a) {
    var b = a.LV.colorBar || [];
    0 < b.length && (a.ij += b[0],
    b = new gvjs_B(a.ij - a.Dg.getHeight(),a.V.O.right,a.ij,a.V.O.left),
    a.Dg.qr(b))
}
function gvjs_0I(a, b) {
    function c(m) {
        m = b(m.text, d).width;
        return Math.ceil(Math.abs(m * f) + Math.abs(e * g))
    }
    var d = a.ud
      , e = d.fontSize
      , f = Math.sin(a.PT % Math.PI)
      , g = Math.cos(a.PT % Math.PI)
      , h = a.aP;
    h || (h = 2 > a.ticks.length ? 1 : Math.ceil((e + a.Yo) / f / Math.abs(a.ticks[1].Na - a.ticks[0].Na)));
    for (var k = 0, l = 0; l < a.ticks.length; l += h)
        k = Math.max(c(a.ticks[l]), k);
    a = c({
        text: gvjs_Kr
    });
    return {
        minHeight: Math.min(k, a),
        maxHeight: k,
        skip: h
    }
}
function gvjs_Pfa(a, b, c, d, e) {
    var f = gvjs_SI(0, a.ticks.length, e, a.v4);
    d = Math.floor((d - a.ud.fontSize * Math.cos(a.PT % Math.PI)) / Math.sin(a.PT % Math.PI));
    var g = [];
    for (c += a.Eka; f < a.ticks.length; f += e) {
        var h = a.ticks[f]
          , k = gvjs_DG(b, h.text, a.ud, d, 1)
          , l = {
            text: h.text,
            ja: a.ud,
            lines: [],
            angle: -a.Yfa,
            ld: 180 < a.Yfa ? gvjs_2 : gvjs_R,
            Pc: gvjs_0,
            tooltip: k.oe ? h.text : "",
            anchor: new gvjs_HG(h.Na,c)
        };
        0 < k.lines.length && l.lines.push({
            x: 0,
            y: 0,
            length: d,
            text: k.lines[0]
        });
        g.push({
            za: h.za,
            isVisible: h.isVisible,
            optional: h.optional,
            Da: l
        })
    }
    return g
}
gvjs_.V7 = function() {
    var a = this;
    if (0 == this.index) {
        var b = this.V.sc, c = this.ud.fontSize, d = new gvjs_RI(this.V.width,this.ticks,this.l$,this.kR,this.J0,this.aP,this.v4,this.Vca,this.Y6,function(q, r, t) {
            return gvjs_DG(b, q, a.ud, r, t)
        }
        ), e, f = this.zga;
        this.uj == gvjs_Fp && (e = gvjs_WI(d));
        var g = this.Yo
          , h = Math.max(this.Yo, Math.round(c / 3.236))
          , k = Math.max(this.Yo, Math.round(c / 1.618));
        k = this.type == gvjs_Vd ? h : k;
        var l = Math.max(g, Math.round(c / 3.236));
        if (this.type == gvjs_Vd)
            if ("high" === f) {
                var m = gvjs_2;
                var n = h
            } else
                m = gvjs_R,
                n = -h;
        else
            m = gvjs_0,
            n = 0;
        f = [];
        f.push({
            key: gvjs_wx,
            min: g,
            extra: [Infinity]
        });
        if (e)
            for (h = 0; h < e.vw; h++)
                f.push({
                    key: gvjs_ex,
                    min: c + g,
                    extra: [(0 == h ? k : l) - g]
                });
        var p = gvjs_oA(f, Math.floor(this.V.O.height / 2)).ticks || [];
        if (0 < p.length) {
            for (c = 1; c < p.length; c++)
                p[c] += p[c - 1];
            d = gvjs_ZI(d, e.PV, e.skip, p.length, .5);
            this.ec = gvjs_v(d.jU, function(q) {
                var r = q.layout.lines;
                r.reverse();
                r = gvjs_v(r, function(t, u) {
                    return {
                        x: 0,
                        y: -p[q.jca + u],
                        length: q.width,
                        text: t
                    }
                }, this);
                return {
                    za: q.za,
                    isVisible: q.isVisible,
                    optional: q.optional,
                    Da: {
                        text: q.text,
                        ja: this.ud,
                        lines: r,
                        ld: m,
                        Pc: gvjs_2,
                        tooltip: q.layout.oe ? q.text : "",
                        anchor: new gvjs_HG(n + q.Na,this.V.O.bottom),
                        angle: 0
                    }
                }
            }, this)
        }
    }
}
;
gvjs_.o7 = function() {
    function a(h, k) {
        var l = h[0].anchor;
        gvjs_u(h, function(m) {
            var n = m.anchor
              , p = n.x;
            n = n.y;
            var q = l.x
              , r = l.y
              , t = k;
            t = t * Math.PI / 180;
            p -= q;
            n -= r;
            var u = Math.sin(t);
            t = Math.cos(t);
            m.anchor = new gvjs_HG(t * p - u * n + q,u * p + t * n + r);
            m.angle = 0
        })
    }
    var b = this;
    if (this.uj == gvjs_f)
        return !0;
    var c = this.options.fa(gvjs_ex, null)
      , d = null != c && Array.isArray(c);
    gvjs_Se(this.ec, function(h, k) {
        return h.optional && !k.optional ? 1 : k.optional && !h.optional ? -1 : 0
    });
    c = gvjs_v(this.ec, function(h) {
        return gvjs_x(h.Da)
    });
    var e = 0 < c.length ? c[0].angle : 0;
    e && (0 < e ? a(c, 360 - e) : a(c, -e));
    var f = []
      , g = [];
    return gvjs_Ge(c, function(h, k) {
        function l(n) {
            return gvjs_lz(m, n)
        }
        var m = gvjs_RF(h);
        if (!m)
            return !0;
        h = Math.round(h.ja.fontSize / 4);
        m.expand(new gvjs_B(0,h,0,h));
        if (gvjs_Yx(f, l))
            return d || b.ec[k].optional ? (b.ec[k].isVisible = !1,
            !0) : !1;
        if (d || b.ec[k].optional) {
            if (gvjs_Yx(g, l))
                return b.ec[k].isVisible = !1,
                0 === f.length;
            g.push(m)
        } else
            f.push(m);
        return !0
    })
}
;
gvjs_.cZ = function() {
    var a = {};
    a.Sg = -1 == this.direction;
    a.ZK = this.V.O.left;
    a.XK = this.V.O.right;
    a.orientation = this.vi();
    return a
}
;
gvjs_.vi = function() {
    return gvjs_S
}
;
gvjs_.Y7 = function() {
    return 0 == this.index ? {
        Na: this.V.O.bottom,
        direction: -1
    } : {
        Na: this.V.O.top,
        direction: 1
    }
}
;
function gvjs_1I() {
    this.h9 = 0
}
gvjs_o(gvjs_1I, gvjs_bI);
gvjs_ = gvjs_1I.prototype;
gvjs_.mZ = function() {
    return 0
}
;
gvjs_.init = function(a, b) {
    gvjs_bI.prototype.init.call(this, a, b);
    this.gd = null;
    this.dfa = gvjs_L(a, gvjs_Hu, 1);
    a.fa("tickScoringWeights", gvjs_x(gvjs_Tfa))
}
;
gvjs_.OE = gvjs_n(66);
gvjs_.dv = function() {
    var a = this.Xe;
    a = {
        pattern: a,
        fractionDigits: a ? null : this.h9,
        scaleFactor: this.dfa,
        prefix: this.options.cb(gvjs_Gu),
        suffix: this.options.cb(gvjs_Iu),
        significantDigits: this.options.bD("formatOptions.significantDigits")
    };
    this.gd = new gvjs_gk(a)
}
;
gvjs_.fa = function(a, b) {
    return a.Aa(b)
}
;
gvjs_.oM = function(a) {
    return Number(a)
}
;
gvjs_.QR = function(a) {
    return a
}
;
gvjs_.$Y = function(a) {
    return a
}
;
var gvjs_Tfa = {
    zEa: 10,
    ODa: 10,
    TDa: 10,
    jEa: 10,
    yEa: 10
};
gvjs_rI().SK.timeofday = function() {
    return new gvjs_sI
}
;
gvjs_rI().SK.date = function() {
    return new gvjs_gI(gvjs_ofa,3,gvjs_pfa)
}
;
gvjs_rI().SK.datetime = function() {
    return new gvjs_gI(gvjs_qfa,3,gvjs_rfa)
}
;
gvjs_rI().SK.number = function() {
    return new gvjs_1I
}
;
function gvjs_2I(a) {
    return new gvjs_ok(Math.round(a.x),Math.round(a.y))
}
function gvjs_Ufa(a) {
    return Array.prototype.reduce.call(arguments, gvjs_eA, new gvjs_ok(0,0))
}
function gvjs_Vfa(a) {
    return Array.prototype.reduce.call(arguments, function(b, c) {
        return new gvjs_A(b.width + c.width,b.height + c.height)
    }, new gvjs_A(0,0))
}
function gvjs_3I(a, b, c) {
    return new gvjs_ok(Math.cos(a) * b,Math.sin(a) * c)
}
function gvjs_Wfa(a) {
    return new gvjs_ok(a[0],a[1])
}
function gvjs_4I(a, b) {
    return gvjs_v([[a.x - b.width / 2, a.y - b.height / 2], [a.x + b.width / 2, a.y - b.height / 2], [a.x + b.width / 2, a.y + b.height / 2], [a.x - b.width / 2, a.y + b.height / 2]], gvjs_Wfa)
}
function gvjs_5I(a, b, c, d) {
    return new gvjs_5(Math.min(a, c),Math.min(b, d),Math.abs(c - a),Math.abs(d - b))
}
;function gvjs_6I(a, b, c, d, e, f) {
    gvjs_tI.call(this, a, b, gvjs_Ke(["vAxes." + d, gvjs_Ud], c), d, e, f);
    this.type == gvjs_Vd && (this.direction = -this.direction);
    this.oS()
}
gvjs_o(gvjs_6I, gvjs_tI);
gvjs_ = gvjs_6I.prototype;
gvjs_.oS = function() {
    this.kR = gvjs_Oj(this.options, "maxTextLines", 3)
}
;
gvjs_.H$ = function() {
    return "vAxis#" + this.index
}
;
gvjs_.wW = function(a, b) {
    var c = this.V.O;
    return gvjs_zI(this, c.height, 1 == this.direction ? c.top : c.bottom, a, b)
}
;
function gvjs_7I(a) {
    var b = a.V.sc;
    return gvjs_Ee(a.ticks, function(c, d) {
        return Math.max(c, b(d.text, this.ud).width)
    }, 0, a)
}
function gvjs_Xfa(a) {
    var b = a.V.sc
      , c = gvjs_7I(a);
    a = b(gvjs_Kr, a.ud).width;
    return Math.min(a, c)
}
gvjs_.W7 = function() {
    var a = this
      , b = this.V.sc
      , c = this.ud.fontSize
      , d = this.title.ja.fontSize
      , e = this.V.DB == gvjs_aw ? this.title.text : ""
      , f = gvjs_DG(b, e, this.title.ja, this.V.O.height, Infinity)
      , g = this.Yo
      , h = gvjs_7I(this)
      , k = gvjs_Xfa(this)
      , l = [];
    this.uj == gvjs_aw ? l.push({
        key: gvjs_zw,
        min: g,
        extra: [c - g]
    }) : l.push({
        key: gvjs_zw,
        min: 0,
        extra: [Infinity]
    });
    0 < f.lines.length && l.push({
        key: gvjs_fx,
        min: d + g,
        extra: [Infinity]
    });
    this.uj == gvjs_aw && l.push({
        key: gvjs_ex,
        min: k + g,
        max: h + g,
        extra: [Infinity]
    });
    for (c = 1; c < f.lines.length; c++)
        l.push({
            key: gvjs_fx,
            min: d + g,
            extra: [this.D$ - g]
        });
    d = this.V.O;
    l = gvjs_oA(l, 0 == this.index ? d.left : this.V.width - d.right);
    var m = 0 == this.index ? 0 : this.V.width;
    f = l.title || [];
    if (0 < f.length)
        for (b = gvjs_DG(b, e, this.title.ja, d.height, f.length),
        1 === this.index && b.lines.reverse(),
        this.title.tooltip = b.oe ? e : "",
        this.title.lines = [],
        e = 0; e < f.length; e++)
            m += f[e] * (0 == this.index ? 1 : -1),
            this.title.angle = -90,
            this.title.Pc = 0 == this.index ? gvjs_R : gvjs_2,
            this.title.lines.push({
                x: m,
                y: d.top + d.height / 2,
                length: d.height,
                text: b.lines[e]
            });
    if (this.uj == gvjs_aw) {
        e = l.ticks[0] || 0;
        m += e * (0 == this.index ? 1 : -1);
        var n = Math.min(h, e - g);
        this.ec = n < k ? [] : gvjs_v(this.ticks, function(p, q) {
            var r = 0 == a.index ? gvjs_R : gvjs_2
              , t = gvjs_0;
            "bound" == a.Xxa && (0 == q && (t = 1 == a.direction ? gvjs_2 : gvjs_R),
            q == a.ticks.length - 1 && (t = 1 == a.direction ? gvjs_R : gvjs_2));
            return gvjs_8I(a, p, m, n, r, t, 0)
        })
    }
}
;
gvjs_.o7 = function() {
    var a = this;
    if (this.uj == gvjs_f)
        return !0;
    var b = gvjs_v(this.ec, function(g) {
        return g.Da
    })
      , c = this.options.fa(gvjs_ex, null)
      , d = null != c && Array.isArray(c)
      , e = []
      , f = [];
    return gvjs_Ge(b, function(g, h) {
        var k = gvjs_RF(g)
          , l = g.ja.fontSize / 8;
        if (!k)
            return !0;
        if (gvjs_Yx(e, function(m) {
            return gvjs_mz(k, m, l)
        }))
            return d || a.ec[h].optional ? (a.ec[h].isVisible = !1,
            !0) : !1;
        if (d || a.ec[h].optional) {
            if (gvjs_Yx(f, function(m) {
                return gvjs_mz(k, m, l)
            }))
                return a.ec[h].isVisible = !1,
                0 === e.length;
            f.push(k)
        } else
            e.push(k);
        return !0
    })
}
;
gvjs_.V7 = function() {
    var a = this.V.sc
      , b = this.ud.fontSize
      , c = this.Yo
      , d = Math.max(this.Yo, Math.round(b / 3.236));
    b = Math.max(this.Yo, Math.round(b / 1.618));
    b = this.type == gvjs_Vd ? d : b;
    if (this.type == gvjs_Vd)
        if ("high" == this.zga) {
            var e = gvjs_R;
            var f = d
        } else
            e = gvjs_2,
            f = -d;
    else
        e = gvjs_0,
        f = 0;
    d = gvjs_Ee(this.ticks, function(m, n) {
        return Math.max(m, a(n.text, this.ud).width)
    }, 0, this);
    var g = a(gvjs_Kr, this.ud).width;
    g = Math.min(g, d);
    var h = [];
    h.push({
        key: gvjs_zw,
        min: c,
        extra: [Infinity]
    });
    this.uj == gvjs_Fp && h.push({
        key: gvjs_ex,
        min: g + c,
        max: d + b,
        extra: []
    });
    b = gvjs_oA(h, this.V.O.width);
    var k = 0 == this.index ? this.V.O.left : this.V.O.right;
    if (this.uj == gvjs_Fp) {
        b = b.ticks[0] || 0;
        var l = Math.min(d, b - c);
        k += (b - l) * (0 == this.index ? 1 : -1);
        this.ec = gvjs_v(this.ticks, function(m) {
            return gvjs_8I(this, m, k, l, 0 == this.index ? gvjs_2 : gvjs_R, e, f)
        }, this)
    }
}
;
function gvjs_8I(a, b, c, d, e, f, g) {
    var h = gvjs_DG(a.V.sc, b.text, a.ud, d, a.kR)
      , k = a.ud.fontSize
      , l = Math.max(2, Math.round(k / 3.236))
      , m = h.lines.length
      , n = gvjs_v(h.lines, function(p, q) {
        return {
            x: 0,
            y: (k + l) * (q - (m - 1) / 2),
            length: d,
            text: p
        }
    });
    return {
        za: b.za,
        isVisible: b.isVisible,
        optional: b.optional,
        text: b.text,
        Da: {
            text: b.text,
            ja: a.ud,
            vl: null,
            lines: n,
            ld: e,
            Pc: f,
            tooltip: h.oe ? b.text : "",
            anchor: new gvjs_HG(c,b.Na - g),
            angle: 0
        }
    }
}
gvjs_.cZ = function() {
    var a = {};
    a.Sg = -1 == this.direction;
    a.ZK = this.V.O.top;
    a.XK = this.V.O.bottom;
    a.orientation = this.vi();
    return a
}
;
gvjs_.vi = function() {
    return gvjs_U
}
;
gvjs_.Y7 = function() {
    return 0 == this.index ? {
        Na: this.V.O.left,
        direction: 1
    } : {
        Na: this.V.O.right,
        direction: -1
    }
}
;
function gvjs_9I(a) {
    this.gd = a = void 0 === a ? String : a;
    this.tE = gvjs_Yfa()
}
function gvjs_Yfa() {
    var a = new Map;
    a.set(gvjs_g, function(b, c) {
        return c.gd(b.value)
    });
    a.set("identifier", function(b) {
        return b.name
    });
    a.set("+", function() {
        return " + "
    });
    a.set("-", function() {
        return gvjs_ar
    });
    a.set("--", function() {
        return "-"
    });
    a.set("=", function() {
        return " = "
    });
    a.set("*", function() {
        return " * "
    });
    a.set("(", function() {
        return "("
    });
    a.set(")", function() {
        return ")"
    });
    a.set(",", function() {
        return gvjs_ha
    });
    a.set("^", function() {
        return "^"
    });
    return a
}
gvjs_9I.prototype.R = function(a) {
    var b = this;
    return gvjs_v(a, function(c) {
        return b.tE.get(c.zq())(c, b)
    }, this).join("")
}
;
function gvjs_$I(a) {
    a = gvjs_De(a.split("}"), function(g) {
        return null != g && "" !== gvjs_kf(g)
    });
    for (var b = {}, c = {}, d = 0; d < a.length; c = {
        CM: c.CM
    },
    d++) {
        var e = a[d].split("{")
          , f = gvjs_v(e[0].split(","), gvjs_kf);
        c.CM = gvjs_Jz(gvjs_kf(e[1]));
        0 === f.length ? Object.assign(b, c.CM) : gvjs_u(f, function(g) {
            return function(h) {
                b[h] = b[h] || {};
                Object.assign(b[h], g.CM)
            }
        }(c))
    }
    return b
}
var gvjs_Zfa = [{
    input: gvjs_1,
    bg: [gvjs_pp, gvjs_3p]
}, {
    input: gvjs_Kp,
    bg: [gvjs_qp, gvjs_4p]
}, {
    input: gvjs_rp,
    bg: [gvjs_pp]
}, {
    input: gvjs_sp,
    bg: [gvjs_qp]
}, {
    input: gvjs_6p,
    bg: [gvjs_3p]
}, {
    input: gvjs_7p,
    bg: [gvjs_4p]
}, {
    input: gvjs_8p,
    bg: [gvjs_5p]
}];
function gvjs_aJ(a, b) {
    var c = {
        fill: {},
        stroke: {}
    };
    a = new gvjs_Aj([a]);
    for (var d = 0; d < b.length; d++) {
        var e = b[d]
          , f = e.bg;
        e = a.fa(e.input);
        if (null != e)
            for (var g = 0; g < f.length; g++)
                gvjs_q(f[g], e, c)
    }
    return c
}
function gvjs__fa(a) {
    return gvjs_aJ(a, gvjs_Zfa)
}
function gvjs_bJ(a, b) {
    b = void 0 === b ? gvjs__fa : b;
    if (null == a)
        return {};
    a = gvjs_kf(a);
    if (gvjs_0z(a))
        var c = b({
            color: a
        });
    else if ("{" === a.charAt(0))
        try {
            var d = gvjs_Gi(a);
            null != d && (c = d)
        } catch (e) {}
    null == c && (gvjs_sf(a, "{") ? (c = gvjs_Ny(gvjs_$I(a), b),
    gvjs_Ze(c, "") && (Object.assign(c, c[""]),
    gvjs_Qy(c, "")),
    gvjs_Ze(c, "*") && (Object.assign(c, c["*"]),
    gvjs_Qy(c, "*"))) : c = b(gvjs_Jz(a)));
    return c
}
;function gvjs_cJ(a) {
    this.x = a.x || 0;
    this.y = a.y || 0;
    this.length = a.length;
    this.text = a.text
}
;function gvjs_dJ(a) {
    this.text = a.text;
    this.ja = a.ja;
    this.vl = a.vl;
    this.lines = a.lines;
    this.ld = a.ld;
    this.Pc = a.Pc;
    this.tooltip = void 0 !== a.tooltip ? a.tooltip : "";
    this.wd = a.wd;
    this.angle = null != a.angle ? a.angle : 0;
    this.anchor = void 0 !== a.anchor ? a.anchor : null;
    this.hx = !!a.hx
}
gvjs_dJ.prototype.xW = gvjs_n(68);
function gvjs_eJ(a, b, c, d, e) {
    gvjs_QI.call(this, a, b, c, d, e);
    this.gs = this.S4 = this.hU = this.je = this.ed = this.ke = this.Bf = this.Kb = null;
    this.Tz = 1;
    this.jN = this.LH = null;
    this.Pr = !1
}
gvjs_o(gvjs_eJ, gvjs_QI);
gvjs_ = gvjs_eJ.prototype;
gvjs_.nz = function() {
    var a = this, b;
    return [function() {
        var c = a.options;
        b = a.V;
        b.kd = gvjs_K(c, "isDiff");
        b.kd || b.Fa !== gvjs_Dd || (b.Fa = gvjs_d,
        gvjs_hq(c, 1, {
            pointSize: 7,
            trendlines: {
                pointsVisible: !1,
                lineWidth: 2
            },
            lineWidth: 0,
            orientation: gvjs_S,
            domainAxis: {
                viewWindowMode: gvjs_qw
            }
        }));
        var d = c.cb(gvjs_qx, gvjs_mC);
        a.wz = d != gvjs_f;
        d = b;
        var e = Set;
        var f = gvjs_Fj(c, gvjs_Ij, [], gvjs_yu, [gvjs_gp], gvjs_bea);
        d.Ig = new e(f);
        if (b.Ig.has(gvjs_Ht) && b.Fa != gvjs_d)
            throw Error("Focus target category is not supported for the chosen chart type, " + b.Fa);
        b.Fa == gvjs_yt ? a.gs = new gvjs_OI(a.lb,a.options,a.sc,b) : (a.Kb = c.fa(gvjs_2t, gvjs_MF),
        gvjs_fJ(a));
        c = 0 < b.wh.bars || 0 < b.wh.area || 0 < b.wh.steppedArea;
        d = a.options.cb(gvjs_jv, gvjs_Mea);
        null == d && (d = gvjs_K(a.options, gvjs_jv) ? gvjs_c : gvjs_f);
        b.vp = c && d || gvjs_f;
        b.Ofa = gvjs_K(a.options, "showRemoveSeriesButton", !1)
    }
    , this.$la.bind(this), this.mea.bind(this), function() {
        b.Fa === gvjs_4u && gvjs_fJ(a)
    }
    , this.Kra.bind(this), gvjs_QI.prototype.nz.bind(this)]
}
;
function gvjs_fJ(a) {
    var b = a.V
      , c = a.lb
      , d = b.Fa == gvjs_Dd ? function() {
        return gvjs_Dd
    }
    : b.Fa === gvjs_4u ? function() {
        return gvjs_lt
    }
    : function(l) {
        return gvjs_J(a.options, gvjs_Qw + l + ".type", b.DH, gvjs_fC)
    }
    ;
    d = b.kd ? gvjs_0fa(c, d, b.Fa) : gvjs_1fa(c, d);
    a.jN = d.I7;
    b.$a = [];
    b.Ds = {};
    for (var e = d.Mk, f = {
        Tr: 0
    }; f.Tr < c.ca(); f = {
        Tr: f.Tr
    },
    f.Tr++) {
        var g = c.fj(f.Tr)
          , h = c.getValue(f.Tr, 0)
          , k = gvjs_v(e, function(l) {
            return function(m) {
                return c.Ha(l.Tr, m.columns.domain[0]) || ""
            }
        }(f));
        h = {
            data: h,
            $w: k,
            Cs: g
        };
        if (k = e[0].columns.tooltip)
            h.wd = gvjs_gJ(a, k[0], f.Tr);
        b.$a.push(h);
        b.Ds[g] = f.Tr
    }
    b.C = [];
    for (e = 0; e < d.y3.length; e++)
        f = gvjs_2fa(a, e, d.y3[e]),
        b.C.push(f),
        gvjs_Py(c.Rj(e)) || (b.C[e].properties = c.Rj(e));
    b.Jk = d.y8;
    b.Mk = d.Mk;
    b.hv = d.hv;
    b.HL = {};
    b.wh = {};
    a.hU = new Set;
    a.S4 = [];
    for (d = 0; d < b.C.length; ++d) {
        e = b.C[d];
        a.hU.add(e.Qc);
        f = b.HL[e.Qc];
        if (null == f)
            b.HL[e.Qc] = e.dataType;
        else if (f != e.dataType)
            throw Error("All series on a given axis must be of the same data type");
        b.wh[e.type] = (b.wh[e.type] || 0) + 1;
        f = a.S4[e.Qc] || {};
        a.S4[e.Qc] = f;
        f[e.type] = (f[e.type] || 0) + 1
    }
}
function gvjs_3fa(a) {
    function b(e) {
        var f = d.C[e];
        if (d.kd && f.type === gvjs_Dd) {
            var g = [a.options.fa(gvjs_hu, .5), a.options.fa(gvjs_gu, 1)]
              , h = f.color.color;
            d.Vo.push({
                id: f.id,
                text: f.mD,
                brush: new gvjs_3({
                    gradient: {
                        Vf: h,
                        sf: h,
                        tn: g[0],
                        un: g[1],
                        x1: gvjs_So,
                        y1: gvjs_Ro,
                        x2: gvjs_Ro,
                        y2: gvjs_Ro,
                        Sn: !0,
                        sp: !0
                    }
                }),
                index: e,
                isVisible: f.GF
            })
        } else
            g = new gvjs_3({
                fill: f.color.color
            }),
            f.dH ? g.mf(f.dH) : f.$r && g.mf(f.$r.fillOpacity),
            d.Vo.push({
                id: f.id,
                text: f.mD,
                brush: g,
                index: e,
                isVisible: f.GF
            });
        c[e] = !0
    }
    var c = {}
      , d = a.V;
    d.Vo = [];
    gvjs_u(d.C, function(e, f) {
        c[f] || (b(f),
        null != e.XL && b(e.XL))
    }, a);
    d.kd && d.C[0].type === gvjs_lt && d.Vo.push({
        id: -1,
        text: "Previous data",
        brush: new gvjs_3({
            fill: gvjs_NF.color
        }),
        index: -1,
        isVisible: !0
    })
}
function gvjs_4fa(a, b) {
    function c(H) {
        return H = 864E5 * H + e
    }
    function d(H) {
        H -= e;
        return H / 864E5
    }
    for (var e = (new Date(1900,0,1,0,0,0)).getTime(), f = new gvjs_1j("0.###E0"), g = new gvjs_1j("#.###"), h = new gvjs_9I(function(H) {
        return 0 !== H && (1E5 < Math.abs(H) || .01 > Math.abs(H)) ? f.format(H) : g.format(H)
    }
    ), k = a.V, l = 0, m = k.orientation === gvjs_U, n = k.C.length, p = {
        wu: 0
    }; p.wu < n; p = {
        wu: p.wu,
        vu: p.vu,
        WF: p.WF,
        tx: p.tx,
        FM: p.FM,
        xM: p.xM
    },
    p.wu++) {
        var q = k.C[p.wu]
          , r = function(H) {
            return function(Q, R) {
                return [gvjs_xx + H.wu + "." + Q, gvjs_xx + Q].concat(R || [])
            }
        }(p);
        if (null != a.options.fa(gvjs_xx + p.wu)) {
            l++;
            var t = gvjs_J(a.options, r(gvjs_Sd), gvjs_Hp, gvjs_LF.Type)
              , u = a.options.fa(r(gvjs_1), "<default>")
              , v = "<default>" === u;
            v && (u = q.Qg.fill);
            v = gvjs_ny(a.options, r(gvjs_Kp, [gvjs_cu]), v ? .5 : 1);
            var w = gvjs_Oj(a.options, r(gvjs_jw, [gvjs_jw]), 0)
              , x = gvjs_K(a.options, r(gvjs_nw, [gvjs_nw]), 0 < w);
            0 >= w && (w = 6);
            w /= 2;
            0 < w && (w += 1);
            var y = {};
            null != q.columns.data && (y.data = q.columns.data);
            var z = gvjs_Oj(a.options, r(gvjs_Bv, [gvjs_Bv]), 2)
              , A = gvjs_J(a.options, r(gvjs_8t), gvjs_f, gvjs_oC)
              , B = gvjs_K(a.options, r(gvjs_Nx), !1);
            u = gvjs_5F(u);
            t = gvjs_LF[t];
            var D = (m ? a.ke : a.Bf)[0]
              , C = (m ? a.Bf : a.ke)[q.Qc];
            if (D.type === gvjs_Vd) {
                p.vu = D.ta;
                p.FM = C.ta;
                D = b.Ga(0);
                p.xM = q.columns.data[0];
                p.tx = gvjs_Wx;
                p.WF = gvjs_Wx;
                C = null;
                0 < b.ca() && gvjs_oe(b.getValue(0, 0)) ? (p.tx = d,
                p.WF = c) : C = {
                    transform: function(H) {
                        return function(Q) {
                            return gvjs_fI(H.vu, H.WF(Q))
                        }
                    }(p),
                    inverse: function(H) {
                        return function(Q) {
                            return H.tx(H.vu.Vz.inverse(Q))
                        }
                    }(p)
                };
                var G = {
                    min: p.tx(p.vu.sn),
                    max: p.tx(p.vu.rn)
                };
                t = t(b.ca(), function(H) {
                    return function(Q) {
                        Q = b.getValue(Q, 0);
                        Q = H.vu.zc(Q);
                        return H.tx(Q)
                    }
                }(p), function(H) {
                    return function(Q) {
                        return H.FM.zc(b.getValue(Q, H.xM))
                    }
                }(p), {
                    range: G,
                    $X: C,
                    fv: gvjs_L(a.options, r("degree"), 3)
                });
                if (null !== t) {
                    C = gvjs_J(a.options, r(gvjs_8c), b.Ga(p.xM));
                    D = t.bR ? t.bR(D, C).qm() : t.rv;
                    D = h.R(D.Im()) || "Trendline " + l;
                    D = gvjs_J(a.options, r(gvjs_fx), D);
                    C = gvjs_v(t.data, function(H) {
                        return function(Q) {
                            var R = H.WF(Q[0]);
                            return [H.vu.Xq(R), H.FM.Xq(Q[1])]
                        }
                    }(p));
                    q.XL = k.C.length;
                    G = gvjs_9z(u.color, z);
                    gvjs_ay(G, v);
                    var J = gvjs_8z(u.color);
                    J.mf(v);
                    var I = gvjs_J(a.options, r(gvjs_nv), D);
                    gvjs_K(a.options, r("showR2"), !1) && (I += "\n" + h.R((new gvjs_uF([new gvjs_yF([new gvjs_AF("r"), new gvjs_mF(2)]), new gvjs_mF(t.r2)])).Im()));
                    t = !1 !== a.options.fa(r(gvjs_Pd));
                    var M = a.options.fa(r(gvjs_Op), {
                        type: gvjs_4o
                    });
                    q = {
                        id: q.id + "_trendline",
                        title: D,
                        ag: !0,
                        data: C,
                        dataType: q.dataType,
                        Yg: gvjs_K(a.options, r(gvjs_ru, [gvjs_ru]), !0),
                        NT: t,
                        isVisible: !0,
                        Cs: 0,
                        columns: y,
                        Sda: p.wu,
                        We: q.We,
                        Df: null,
                        color: u,
                        dH: v,
                        Qg: J,
                        Oc: G,
                        $r: null,
                        NG: null,
                        type: gvjs_e,
                        wM: gvjs_L(a.options, r("zOrder"), 0),
                        lineWidth: z,
                        pointRadius: w,
                        hE: M,
                        jea: 12,
                        ey: A,
                        RT: gvjs_Oj(a.options, r(gvjs_Yw, [gvjs_Yw]), 1),
                        rM: x,
                        points: [],
                        kX: [],
                        Qc: q.Qc,
                        GF: B,
                        mD: I
                    };
                    k.C.push(q)
                }
            }
        }
    }
}
function gvjs_1fa(a, b) {
    for (var c = [], d = [], e = null, f = null, g = 0, h = [], k = new Set, l = a.$(), m = !1, n, p = 0; p < l; ++p) {
        var q = a.W(p)
          , r = a.Bd(p, gvjs_Bd) || (0 == p ? gvjs_mu : gvjs_$t);
        if (0 == p && r !== gvjs_mu)
            throw Error(gvjs_cs);
        if (r == gvjs_mu) {
            if (m || 0 < g)
                throw Error(gvjs_ys + p + ")");
            m = !0;
            e = {
                columns: {},
                dataType: q
            };
            f = {
                Vb: null,
                We: d.length
            };
            d.push(e)
        } else if (r === gvjs_$t) {
            0 === g && (f = c.length,
            n = b(f),
            e = {
                type: n,
                dataType: q,
                columns: {}
            },
            f = {
                Vb: f,
                We: null
            },
            c.push(e),
            g = n === gvjs_Ft ? 4 : 1);
            g--;
            if (q !== e.dataType)
                throw Error(gvjs_0r + p + gvjs_fr + q + gvjs_cr + e.dataType);
            n !== gvjs_lt && n !== gvjs_Ft || k.add(p)
        } else if (r === gvjs_Pd && e.columns[r])
            throw Error("Only one column with role 'tooltip' per series is allowed");
        r !== gvjs_mu && (m = !1);
        e.columns[r] = e.columns[r] || [];
        h.push({
            Vb: f.Vb,
            We: f.We,
            role: r,
            wE: e.columns[r].length
        });
        e.columns[r].push(p)
    }
    if (0 < g)
        throw Error(gvjs_js + g + ")");
    a = 0;
    b = d[0].dataType;
    for (e = 0; e < c.length; ++e) {
        if (d.length <= a)
            throw Error("Series #" + e + gvjs_er);
        l = d[a + 1];
        m = c[e].columns.data;
        if (l && l.columns.domain[0] <= m[0] && (++a,
        b !== d[a].dataType))
            throw Error(gvjs_1r);
        c[e].We = a
    }
    return {
        y3: c,
        Mk: d,
        hv: b,
        y8: h,
        I7: k
    }
}
function gvjs_hJ(a, b) {
    if (a !== b)
        throw Error("Column types must be consistent: equal for domain columns and for columns in the same serie.");
}
function gvjs_0fa(a, b, c) {
    var d = []
      , e = []
      , f = null
      , g = []
      , h = new Set;
    if (c === gvjs_Dd) {
        c = a.$() - 2;
        var k = function(t) {
            if (t !== gvjs_$t && t !== gvjs_3v)
                throw Error("All columns must be either data or old-data columns");
        }
          , l = {
            data: null,
            "old-data": null
        };
        f = a.W(0);
        for (var m = 0; 2 > m; ++m) {
            var n = a.W(m)
              , p = a.Bd(m, gvjs_Bd);
            k(p);
            gvjs_hJ(f, n);
            n = {
                columns: {},
                dataType: n
            };
            n.columns.domain = [m];
            e.push(n);
            l[p] = m;
            g.push({
                We: m,
                role: gvjs_mu,
                wE: 0,
                Vb: null
            })
        }
        for (m = 0; m < c; ++m) {
            p = 2 + m;
            var q = a.W(m);
            n = a.Bd(m, gvjs_Bd);
            k(n);
            m % 2 && gvjs_hJ(d[m - 1].dataType, q);
            var r = l[n];
            q = {
                type: b(m),
                dataType: q,
                We: r,
                columns: {}
            };
            q.columns[n] = [p];
            d.push(q);
            g.push({
                We: r,
                role: n,
                wE: 0,
                Vb: m
            })
        }
    } else if (c === gvjs_d) {
        n = f = null;
        r = 0;
        c = a.$();
        for (k = 0; k < c; ++k) {
            l = a.W(k);
            m = a.Bd(k, gvjs_Bd) || (0 === k ? gvjs_mu : gvjs_$t);
            if (0 === k && m !== gvjs_mu)
                throw Error(gvjs_cs);
            if (m === gvjs_mu) {
                if (0 < r)
                    throw Error(gvjs_ys + k + ")");
                f = {
                    columns: {},
                    dataType: l
                };
                n = {
                    Vb: null,
                    We: e.length
                };
                e.push(f)
            }
            0 !== r || m !== gvjs_$t && m !== gvjs_3v || (n = d.length,
            p = b(n),
            f = {
                type: p,
                dataType: l,
                columns: {}
            },
            n = {
                Vb: n,
                We: null
            },
            d.push(f),
            r = p === gvjs_Ft ? 4 : m === gvjs_3v ? 2 : 1,
            p !== gvjs_lt && p !== gvjs_Ft || h.add(k));
            if (m === gvjs_$t || m === gvjs_3v)
                if (r--,
                l !== f.dataType)
                    throw Error(gvjs_0r + k + gvjs_fr + l + gvjs_cr + f.dataType);
            if (m === gvjs_Pd && f.columns[m])
                throw Error("Only one data column with role 'tooltip' per series is allowed");
            f.columns[m] = f.columns[m] || [];
            g.push({
                Vb: n.Vb,
                We: n.We,
                role: m,
                wE: f.columns[m].length
            });
            f.columns[m].push(k)
        }
        if (0 < r)
            throw Error(gvjs_js + r + ")");
        a = 0;
        f = e[0].dataType;
        for (b = 0; b < d.length; ++b) {
            if (e.length <= a)
                throw Error("Series #" + b + gvjs_er);
            c = e[a + 1];
            k = d[b].columns[gvjs_3v] || d[b].columns.data;
            if (c && c.columns.domain[0] <= k[0] && (++a,
            f !== e[a].dataType))
                throw Error(gvjs_1r);
            d[b].We = a
        }
    }
    return {
        y3: d,
        Mk: e,
        hv: f,
        y8: g,
        I7: h
    }
}
gvjs_.fL = function(a) {
    a = a.columns[gvjs_3v];
    return null != a && 0 < a.length
}
;
function gvjs_2fa(a, b, c) {
    var d = c.type
      , e = c.columns
      , f = c.We
      , g = a.options
      , h = gvjs_Qw + b + "."
      , k = d + "."
      , l = e.data || e[gvjs_3v]
      , m = a.lb.jf(l[0])
      , n = a.lb.Ga(l[0]) || ""
      , p = d == gvjs_Dd ? 0 : 2
      , q = gvjs_Oj(g, [h + gvjs_jw, gvjs_jw], d == gvjs_Dd ? 7 : 0);
    var r = gvjs_K(g, [h + gvjs_nw, gvjs_nw], d == gvjs_e || d == gvjs_at || d == gvjs_Dd ? 0 < q : !0);
    0 == q && (q = d == gvjs_Dd ? 7 : 6);
    q /= 2;
    0 < q && (q += 1);
    b = g.fa(h + gvjs_1, a.Kb[(a.V.kd && d == gvjs_Dd ? Math.floor(b / 2) : b) % a.Kb.length]);
    b = gvjs_5F(b);
    var t = null;
    if (d == gvjs_at || d == gvjs_4w)
        t = gvjs_ny(g, [h + gvjs_bt, gvjs_bt]),
        t = gvjs_8z(b.color, t);
    var u = null;
    if (d == gvjs_Ft) {
        u = new gvjs_3({
            stroke: b.color,
            strokeWidth: 2,
            fill: b.color
        });
        var v = new gvjs_3({
            stroke: b.color,
            strokeWidth: 2,
            fill: gvjs_Br
        })
          , w = gvjs_K(g, "candlestick.hollowIsRising")
          , x = w ? u : v;
        u = {
            Uea: gvjs_qy(g, [h + gvjs_Et, gvjs_Et], w ? v : u),
            g$: gvjs_qy(g, [h + gvjs_Dt, gvjs_Dt], x)
        }
    }
    p = gvjs_Oj(g, [h + gvjs_Bv, gvjs_Bv], p);
    v = gvjs_9z(b.color, p);
    (w = g.$I([h + "lineDashStyle", "lineDashStyle"])) && null != w && (v.Mi = w);
    k = gvjs_Oj(g, [h + gvjs_cu, k + gvjs_cu, gvjs_cu], 1);
    w = null;
    if (d === gvjs_Dd || d === gvjs_e || d === gvjs_at)
        w = g.fa([h + gvjs_Op, gvjs_Op], {
            type: gvjs_4o
        }),
        typeof w === gvjs_l && (w = {
            type: w
        });
    x = null;
    if (a.V.kd && d === gvjs_Dd) {
        var y = a.fL(c);
        k = y ? a.options.fa(gvjs_hu, .5) : a.options.fa(gvjs_gu, 1);
        y && (x = !1)
    }
    y = d == gvjs_4w ? t : gvjs_8z(b.color, k);
    if (a.V.kd)
        if (d === gvjs_lt) {
            var z = g.fa("diff.oldData.color", gvjs_NF);
            z = gvjs_5F(z);
            z = {
                background: {
                    Qg: gvjs_8z(z.color, k)
                }
            }
        } else
            d === gvjs_Dd && a.fL(c) && (r = !1);
    else
        d === gvjs_Dd && (d = gvjs_e);
    var A = gvjs_5fa(a, e, g, h, b)
      , B = !1 !== a.options.fa(h + gvjs_Pd);
    return {
        id: a.lb.Ne(l[0]),
        title: n,
        dataType: c.dataType,
        isVisible: !0,
        NT: B,
        Cs: m,
        columns: e,
        We: f,
        Yg: gvjs_K(g, [h + gvjs_ru, gvjs_ru], !0),
        Df: A,
        color: b,
        dH: k,
        Qg: y,
        Oc: v,
        $r: t,
        hE: w,
        Ih: z,
        NG: u,
        type: d,
        wM: gvjs_L(g, h + "zOrder", 0),
        lineWidth: p,
        pointRadius: q,
        jea: 12,
        ey: gvjs_J(g, [h + gvjs_8t, gvjs_8t], gvjs_f, gvjs_oC),
        RT: gvjs_Oj(g, [h + gvjs_Yw, gvjs_Yw], 1),
        rM: r,
        points: [],
        kX: [],
        Qc: gvjs_Oj(g, [h + gvjs_$w, gvjs_$w], 0),
        GF: null != x ? x : gvjs_K(g, h + gvjs_Nx, !0),
        mD: gvjs_J(g, h + gvjs_nv, n)
    }
}
function gvjs_5fa(a, b, c, d, e) {
    function f(v, w) {
        return g(v, w).concat([d + w, w])
    }
    function g(v, w) {
        return [d + "interval." + v + "." + w, d + "intervals." + w, "interval." + v + "." + w, "intervals." + w]
    }
    var h = b.interval;
    if (!h)
        return null;
    b = {
        Mb: [],
        IA: [],
        qN: [],
        points: [],
        areas: [],
        lines: [],
        eu: {}
    };
    for (var k = {}, l = 0; l < h.length; l++) {
        var m = h[l]
          , n = a.lb.Ne(m) || a.lb.Ga(m) || gvjs_eu
          , p = c.cb(g(n, gvjs_Jd), gvjs_gC);
        switch (p) {
        case gvjs_lt:
            b.Mb.push(m);
            a.jN.add(m);
            break;
        case "sticks":
            b.IA.push(m);
            break;
        case "boxes":
            b.qN.push(m);
            a.jN.add(m);
            break;
        case gvjs_mw:
            b.points.push(m);
            break;
        case gvjs_at:
            b.areas.push(m);
            break;
        case gvjs_e:
            b.lines.push(m);
            break;
        case gvjs_f:
            break;
        default:
            throw Error("Invalid interval style: " + p);
        }
        n in k ? k[n].push(m) : k[n] = [m]
    }
    1 < b.Mb.length && 0 == b.IA.length && (b.IA = [b.Mb[0], b.Mb[b.Mb.length - 1]]);
    if (0 != b.IA.length % 2)
        throw Error("Stick-intervals must be defined by an even number of columns");
    if (0 != b.areas.length % 2)
        throw Error("Area-intervals must be defined by an even number of columns");
    for (var q in k) {
        a = gvjs_Oj(c, g(q, gvjs_Bv));
        h = gvjs_ny(c, g(q, gvjs_sp));
        l = gvjs_oy(c, g(q, gvjs_1), "", gvjs_Xe(gvjs_hC));
        l = gvjs_$G(l, e);
        a = new gvjs_3({
            stroke: l,
            strokeWidth: a,
            fill: l,
            fillOpacity: h
        });
        h = gvjs_Oj(c, g(q, "barWidth"));
        l = gvjs_Oj(c, g(q, "shortBarWidth"));
        m = gvjs_Oj(c, g(q, "boxWidth"));
        n = gvjs_Oj(c, g(q, gvjs_jw));
        p = c.cb(g(q, gvjs_Jd), gvjs_gC);
        var r = gvjs_K(c, f(q, gvjs_hv))
          , t = gvjs_J(c, f(q, gvjs_8t), gvjs_f, gvjs_oC)
          , u = gvjs_Oj(c, f(q, gvjs_Yw), 1);
        a = {
            style: p,
            brush: a,
            Ika: h,
            Qwa: l,
            Vka: m,
            ava: n,
            Zj: r,
            ey: t,
            RT: u
        };
        h = k[q];
        for (l = 0; l < h.length; ++l)
            b.eu[h[l]] = a
    }
    return b
}
gvjs_.$la = function() {
    var a = this.V;
    switch (a.Fa) {
    case gvjs_d:
    case gvjs_4u:
        a.orientation = gvjs_J(this.options, gvjs_9v, "", gvjs_iC);
        if (!a.orientation)
            throw Error("Unspecified orientation.");
        this.je = {};
        this.Bf = {};
        this.ke = {};
        switch (a.orientation) {
        case gvjs_S:
            var b = gvjs__I;
            var c = this.Bf;
            var d = gvjs_6I;
            var e = this.ke;
            break;
        case gvjs_U:
            b = gvjs_6I,
            c = this.ke,
            d = gvjs__I,
            e = this.Bf
        }
        for (var f = null == this.hU ? [] : gvjs_nj(this.hU), g = 0; g < f.length; ++g) {
            var h = f[g]
              , k = new d(a,this.options,["targetAxes." + h, gvjs_Md],h,gvjs_Vd,gvjs_qw);
            if (k.type != gvjs_Vd)
                throw Error("Target-axis must be of type value");
            this.je[h] = k;
            e[h] = k
        }
        d = b;
        e = this.options;
        if (this.lb.W(0) == gvjs_l)
            b: {
                switch (gvjs_6fa(this)) {
                case gvjs_at:
                    b = 1 < this.V.$a.length ? gvjs_It : gvjs_Ht;
                    break b;
                case gvjs_e:
                case gvjs_Dd:
                case gvjs_lt:
                case gvjs_4w:
                case gvjs_Ft:
                    b = gvjs_Ht;
                    break b
                }
                b = null
            }
        else
            b = gvjs_Vd;
        this.ed = new d(a,e,[gvjs_Pb],0,b,gvjs_Lv);
        c[0] = this.ed;
        break;
    case gvjs_Dd:
    case gvjs_yt:
        this.Bf = {
            0: new gvjs__I(a,this.options,[],0,gvjs_Vd,gvjs_qw)
        },
        this.ke = {
            0: new gvjs_6I(a,this.options,[],0,gvjs_Vd,gvjs_qw)
        },
        a.orientation === gvjs_S ? (this.ed = this.Bf[0],
        this.je = this.ke) : (this.ed = this.ke[0],
        this.je = this.Bf)
    }
}
;
function gvjs_6fa(a) {
    var b = [gvjs_e, gvjs_Dd, gvjs_at, gvjs_4w, gvjs_lt, gvjs_Ft]
      , c = {};
    gvjs_u(b, function(d, e) {
        c[d] = e
    });
    a = gvjs_Ee(a.V.C, function(d, e) {
        return Math.max(d, c[e.type])
    }, 0);
    return b[a]
}
gvjs_.Kra = function() {
    var a = this.V;
    switch (a.Fa) {
    case gvjs_Dd:
    case gvjs_yt:
        if (a.hv == gvjs_l)
            throw Error("X values column cannot be of type string");
        var b = a.HL[0];
        if (b == gvjs_l)
            throw Error("Data column(s) cannot be of type string");
        var c = this.Bf[0]
          , d = this.ke[0];
        if (c.type != gvjs_Vd)
            throw Error("The x-axis must be of type value");
        c.initScale(a.hv);
        if (d.type != gvjs_Vd)
            throw Error("The y-axis must be of type value");
        d.initScale(b);
        break;
    case gvjs_d:
    case gvjs_4u:
        b = this.ed;
        a.Fa === gvjs_4u && (c = this.lb.Bd(0, gvjs_8u),
        gvjs_hq(b.options, 1, {
            ticks: c
        }));
        if (b.type == gvjs_Vd) {
            if (a.hv == gvjs_l)
                throw Error("Domain column cannot be of type string, it should be the X values on a continuous domain axis");
            b.initScale(a.hv)
        }
        gvjs_w(this.je, function(e, f) {
            var g = a.HL[f];
            if (g == gvjs_l)
                throw Error("Data column(s) for axis #" + f + " cannot be of type string");
            e.initScale(g)
        }, this)
    }
    gvjs_w(this.Bf, function(e) {
        gvjs_yI(e)
    });
    gvjs_w(this.ke, function(e) {
        gvjs_yI(e)
    })
}
;
function gvjs_7fa(a) {
    if (null === gvjs_iJ(a))
        return [];
    for (var b = (a.V.Mk[0].columns.domain || [])[0], c = [], d = null, e = a.lb, f = 0; f < e.ca(); f++) {
        var g = e.getValue(f, b)
          , h = gvjs_jJ(a, f);
        if (null !== d && null != h) {
            if (0 > h)
                throw Error("Invalid gap value (" + h + ") in data row #" + f + ". Gap value must be non-negative.");
            c.push({
                Gc: d,
                xe: g,
                woa: h
            })
        }
        d = g
    }
    return c
}
gvjs_.N$ = function() {
    return this.gs && this.gs.aq == gvjs_g ? null : null != this.ke[0] && null != this.ke[1] ? gvjs_vx : null != this.ke[1] ? gvjs_$c : gvjs_j
}
;
gvjs_.M$ = function() {
    return this.gs && this.gs.aq == gvjs_g ? gvjs_vx : null
}
;
function gvjs_kJ(a) {
    var b = a.columns.data;
    return b ? b[0] : a.columns[gvjs_3v][0]
}
function gvjs_8fa(a) {
    for (var b = a.V, c = a.lb, d = a.ed, e = 0; e < b.$a.length; e++) {
        for (var f = 0; f < b.C.length; f++) {
            var g = b.C[f]
              , h = a.je[g.Qc];
            g = c.getValue(e, gvjs_kJ(g));
            g = gvjs_eI(h.ta, g);
            null != g && gvjs_uI(h, g)
        }
        d.type == gvjs_Vd && (f = c.getValue(e, 0),
        f = gvjs_eI(d.ta, f),
        gvjs_uI(d, f))
    }
}
function gvjs_9fa(a) {
    var b = a.V
      , c = a.lb
      , d = a.Bf[0];
    a = a.ke[0];
    for (var e = 0; e < c.ca(); e++)
        for (var f = 0; f < b.C.length; f++) {
            var g = b.C[f]
              , h = gvjs_kJ(g);
            g = c.getValue(e, b.Mk[g.We].columns.domain[0]);
            h = c.getValue(e, h);
            g = gvjs_eI(d.ta, g);
            h = gvjs_eI(a.ta, h);
            null != g && gvjs_uI(d, g);
            null != h && gvjs_uI(a, h)
        }
}
gvjs_.tN = function() {
    var a = this, b;
    return [function() {
        b = a.ti()
    }
    , this.cla.bind(this), function() {
        (b.vp !== gvjs_f || b.kd || b.Fa === gvjs_4u) && gvjs_w(a.je, function(c) {
            c.oc(0)
        })
    }
    , function() {
        if (b.Fa === gvjs_d || b.Fa === gvjs_4u)
            gvjs_8fa(a),
            a.ed.type == gvjs_Vd && a.ed.dD(gvjs_7fa(a)),
            gvjs_wI(a.ed),
            gvjs_w(a.je, function(e) {
                e.dD();
                gvjs_wI(e)
            }, a);
        else {
            var c = a.Bf[0]
              , d = a.ke[0];
            b.Fa == gvjs_yt ? gvjs_Nfa(a.gs, c, d) : b.Fa == gvjs_Dd && gvjs_9fa(a);
            c.dD();
            gvjs_wI(c);
            d.dD();
            gvjs_wI(d)
        }
    }
    , function() {
        a.Pr = a.Pr || gvjs_K(a.options, "bar.variableWidth");
        b.Fa === gvjs_4u && (a.Pr = !1)
    }
    , function() {
        b.wh.bars && gvjs_lJ(a, gvjs_lt);
        b.wh.steppedArea && (a.ed.type == gvjs_Vd && (a.Pr = !0),
        gvjs_lJ(a, gvjs_4w));
        b.wh.candlesticks && gvjs_$fa(a);
        if (b.wh.line) {
            for (var c = a.V, d = 0; d < c.C.length; d++)
                gvjs_mJ(a, d);
            gvjs_nJ(a);
            gvjs_oJ(a);
            gvjs_pJ(a)
        }
        b.wh.area && gvjs_aga(a);
        if (b.wh.scatter) {
            c = a.V;
            for (d = 0; d < c.C.length; d++)
                gvjs_qJ(a, d);
            gvjs_oJ(a);
            gvjs_pJ(a)
        }
        if (b.wh.bubbles) {
            c = a.gs;
            d = a.Bf[0];
            for (var e = a.ke[0], f = a.Dg, g = 0; g < c.Cl.ca(); g++) {
                a: {
                    var h = c;
                    var k = d
                      , l = e
                      , m = g
                      , n = h.Cl
                      , p = n.getValue(m, h.m1)
                      , q = n.Ha(m, h.m1)
                      , r = n.getValue(m, h.tM)
                      , t = n.getValue(m, h.vM)
                      , u = null;
                    if (null != h.qs && (u = n.getValue(m, h.qs),
                    null == u)) {
                        h = null;
                        break a
                    }
                    var v = null;
                    if (null != h.iu && (v = n.getValue(m, h.iu),
                    null == v)) {
                        h = null;
                        break a
                    }
                    n = h.Zd(q, h.Za).width;
                    if (h.aq == gvjs_g)
                        h.aX = gvjs_8B(h.aX, u);
                    else if (h.aq == gvjs_l) {
                        var w = u
                          , x = h.TB[w];
                        if (!x) {
                            x = gvjs_Qw + w + ".";
                            var y = gvjs_oy(h.m, x + gvjs_1, h.YX[h.$D.length % h.YX.length]);
                            y = gvjs_5F(y);
                            var z = gvjs_K(h.m, x + gvjs_Nx, !0);
                            x = gvjs_J(h.m, x + gvjs_nv, w);
                            x = {
                                color: y.color,
                                GF: z,
                                mD: x
                            };
                            h.TB[w] = x;
                            h.$D.push(w)
                        }
                    }
                    h.t4 = gvjs_8B(h.t4, v);
                    r = k.ta.zc(r);
                    t = l.ta.zc(t);
                    null === r || null === t ? h = null : (gvjs_LI(k, r) && gvjs_LI(l, t) && (k.oc(r),
                    l.oc(t)),
                    k = h.AW(m, q),
                    h = {
                        id: p,
                        text: q,
                        textLength: n,
                        ja: h.Za,
                        wd: k,
                        Kf: {
                            x: r,
                            y: t,
                            color: u,
                            size: v
                        }
                    })
                }
                c.xl.C[0].points.push(h)
            }
            if (c.aq == gvjs_g)
                c.rs = gvjs__H(c.m, c.aX),
                f.setScale(c.rs);
            else if (c.aq == gvjs_l)
                for (d = 0; d < c.$D.length; d++)
                    e = c.$D[d],
                    f = c.TB[e],
                    f.GF && c.xl.Vo.push({
                        index: d,
                        id: e,
                        text: f.mD,
                        brush: new gvjs_3({
                            fill: f.color
                        }),
                        isVisible: !0
                    });
            c.tL = gvjs_NI(c.m, c.t4);
            c.Qya && gvjs_u(c.xl.C[0].points, c.fka, c)
        }
    }
    , function() {
        var c = b.Fa === gvjs_4u
          , d = b.wh.bars || b.wh.candlesticks
          , e = null != gvjs_Yx(b.C, function(f) {
            return null != f.Df
        });
        (d && !c && !a.Pr || e) && gvjs_bga(a)
    }
    , function() {
        b.jd = gvjs_Ny(a.Bf, function(c) {
            return c.wW(this.ne, this.Dg)
        }, a);
        b.wc = gvjs_Ny(a.ke, function(c) {
            return c.wW(this.ne, this.Dg)
        }, a);
        gvjs_cga(a)
    }
    , this.$ka.bind(this), this.dva.bind(this), function() {
        gvjs_dga(new gvjs_rJ(a,a.options))
    }
    , function() {
        var c = a.ne.getPosition()
          , d = a.ne.Za.fontSize
          , e = null;
        c != gvjs_j && c != gvjs_ov || null != a.ke[1] || (e = new gvjs_B(b.O.top,b.width - d,b.O.bottom,b.O.right + d));
        c != gvjs_$c || null != a.ke[0] || (e = new gvjs_B(b.O.top,b.O.left - d,b.O.bottom,d));
        e && e.right >= e.left && a.ne.qr(e)
    }
    , this.Iva.bind(this), function() {
        a.gs || (gvjs_4fa(a, a.lb),
        gvjs_3fa(a),
        gvjs_ega(a))
    }
    ]
}
;
gvjs_.cla = function() {
    var a = this.V
      , b = this.sc
      , c = (gvjs_Oy(this.Bf) || gvjs_Oy(this.ke)).title.ja
      , d = Math.max(a.title.ja.fontSize, c.fontSize)
      , e = this.ne.Za.fontSize
      , f = this.ne.getPosition()
      , g = this.Dg.Za.fontSize
      , h = this.Dg.getPosition()
      , k = a.oF == gvjs_Fp ? a.title.text : ""
      , l = ""
      , m = "";
    if (a.DB == gvjs_Fp) {
        var n = function(w) {
            var x = gvjs_Ye(w);
            gvjs_Qe(x);
            x = gvjs_v(x, function(y) {
                return w[y].title.text
            });
            return gvjs_De(x, function(y) {
                return "" != y
            }).join(gvjs_ha)
        };
        switch (a.Fa) {
        case gvjs_Dd:
        case gvjs_yt:
            l = n(this.Bf);
            m = n(this.ke);
            break;
        case gvjs_d:
            l = n({
                0: this.ed
            }),
            m = n(this.je)
        }
    }
    l = l && m ? l + " / " + m : l ? l : m ? m : "";
    m = Math.max(2, Math.round(d / 1.618));
    var p = Math.max(2, Math.round(e / 1.618))
      , q = Math.max(2, Math.round(g / 1.618))
      , r = a.O.width - 2 * m;
    g = gvjs_DG(b, k, a.title.ja, r, 1);
    n = 0 < g.lines.length ? g.lines[0] : "";
    var t = b(n, a.title.ja).width;
    r = Math.max(r - t - Math.round(Math.max(2, 1.618 * d)), 0);
    b = gvjs_DG(b, l, c, r, 1);
    var u = 0 < b.lines.length ? b.lines[0] : ""
      , v = [];
    v.push({
        key: gvjs_wt,
        min: 2,
        extra: [Infinity]
    });
    (n || u) && v.push({
        key: gvjs_fx,
        min: d + 2,
        extra: [m - 2]
    });
    f == gvjs_Fp && v.push({
        key: gvjs_rv,
        min: e + 2,
        extra: [p - 2]
    });
    h == gvjs_Fp && v.push({
        key: gvjs_1t,
        min: this.Dg.getHeight() + 2,
        extra: [q - 2]
    });
    f = gvjs_oA(v, Math.floor(a.O.height / 2));
    d = a.O.top;
    h = f.title || [];
    0 < h.length && (d += h[0],
    n && (a.title.lines.push({
        text: n,
        x: a.O.left + m,
        y: d,
        length: t
    }),
    a.title.tooltip = g.oe ? k : ""),
    u && (a.cJ = {
        text: l,
        ja: c,
        vl: null,
        lines: [],
        ld: gvjs_R,
        Pc: gvjs_R,
        tooltip: b.oe ? l : "",
        anchor: null,
        angle: 0
    },
    a.cJ.lines.push({
        text: u,
        x: a.O.right - m,
        y: d,
        length: r
    })));
    c = f.legend || [];
    0 < c.length && (d += c[0],
    this.ne.qr(new gvjs_B(d - e,a.O.right,d,a.O.left)));
    e = f.colorBar || [];
    0 < e.length && (d += e[0],
    a = new gvjs_B(d - this.Dg.getHeight(),a.O.right,d,a.O.left),
    this.Dg.qr(a))
}
;
function gvjs_lJ(a, b) {
    var c = a.V;
    c.kd ? gvjs_fga(a, b) : gvjs_gga(a, b, c.vp)
}
function gvjs_bga(a) {
    var b = a.ed;
    if (b.ta) {
        var c = gvjs_De(a.V.$a, function(f, g) {
            return 0 != gvjs_jJ(this, g)
        }, a), d = Infinity, e;
        gvjs_u(c, function(f) {
            f = b.ta.zc(f.data);
            if (null != e) {
                var g = Math.abs(f - e);
                0 < g && (d = Math.min(d, g))
            }
            e = f
        }, a);
        isFinite(d) && (a = d / 2,
        b.oc(b.ta.sn - a),
        b.oc(b.ta.rn + a))
    }
}
function gvjs_sJ(a, b) {
    for (var c = a.V, d = [], e = 0; e < c.$a.length; e++) {
        var f = {
            positive: 0,
            negative: 0
        };
        d[e] = f;
        for (var g = 0; g < c.C.length; g++) {
            var h = c.C[g];
            if (h.type == b) {
                var k = a.je[h.Qc];
                h = a.lb.getValue(e, h.columns.data[0]);
                null != h && (k = k.ta.zc(h),
                0 < k ? f.positive += k : f.negative -= k)
            }
        }
    }
    return d
}
function gvjs_tJ(a, b) {
    for (var c = a.V, d = 0; d < c.C.length; d++) {
        var e = c.C[d];
        e.type == b && (a.je[e.Qc].qM = gvjs_Lv)
    }
}
function gvjs_gga(a, b, c) {
    var d = a.V
      , e = a.lb
      , f = a.ed
      , g = a.V.Fa === gvjs_4u
      , h = a.Pr
      , k = c !== gvjs_f
      , l = k && d.vp !== gvjs_c;
    c = d.vp === gvjs_ud ? "#.##%" : "0.00#";
    if (g) {
        var m = (d.O.height - 1) / gvjs_hga(a, k);
        a.V.fz = gvjs_uJ(m, gvjs_K(a.options, gvjs_6u))
    }
    m = [];
    l && (m = gvjs_sJ(a, b),
    gvjs_tJ(a, b));
    var n = null
      , p = f.ta ? f.ta.wda : null;
    h && f.oc(p);
    for (h = {
        zm: 0
    }; h.zm < d.$a.length; h = {
        kV: h.kV,
        zm: h.zm
    },
    h.zm++) {
        var q = 0 == gvjs_jJ(a, h.zm)
          , r = gvjs_Ny(a.je, function() {
            return {
                positive: 0,
                negative: 0
            }
        })
          , t = -1;
        null != p && (n = p);
        p = gvjs_vJ(a, h.zm);
        f.oc(p);
        h.kV = gvjs_LI(f, p);
        for (var u = {
            lB: 0
        }; u.lB < d.C.length; u = {
            iV: u.iV,
            uu: u.uu,
            Ur: u.Ur,
            UF: u.UF,
            DM: u.DM,
            Vr: u.Vr,
            Ip: u.Ip,
            sx: u.sx,
            lB: u.lB,
            yM: u.yM
        },
        u.lB++)
            if (u.Ip = d.C[u.lB],
            u.Ip.type == b)
                if (t++,
                k || (r[u.Ip.Qc] = {
                    positive: 0,
                    negative: 0
                }),
                u.sx = u.Ip.points,
                q)
                    u.sx.push(null);
                else {
                    var v = u.Ip.Qc;
                    u.Vr = a.je[v];
                    u.DM = u.Vr.gw;
                    var w = e.getValue(h.zm, u.Ip.columns.data[0]);
                    w = u.DM ? w : u.Vr.ta.zc(w);
                    u.yM = void 0;
                    l && (gvjs_cI(u.Vr.ta, c),
                    u.yM = gvjs_dI(u.Vr.ta));
                    u.Ur = 0 <= w ? "positive" : "negative";
                    u.uu = r[v];
                    k || (a.Tz = Math.max(a.Tz, t + 1));
                    u.iV = m[h.zm] && m[h.zm][u.Ur] || 1;
                    u.UF = function(A) {
                        return function(B) {
                            return null == B ? null : B / A.iV
                        }
                    }(u);
                    v = function(A, B) {
                        return function(D, C, G) {
                            var J = null;
                            null == D || isNaN(D) || (J = D + (k || g ? A.uu[A.Ur] : 0));
                            l && (J = A.UF(J),
                            G = A.UF(G));
                            A.DM && (J = A.Vr.ta.zc(J),
                            G = A.Vr.ta.zc(G));
                            B.kV && A.Vr.oc(J);
                            var I;
                            null != D && (I = gvjs_wJ(a, A.Ip, B.zm, A.uu[A.Ur], A.UF, !0));
                            C = {
                                Kf: {
                                    Js: B.zm,
                                    cF: C,
                                    from: G,
                                    uk: J,
                                    hy: n,
                                    d: p,
                                    fJ: I
                                }
                            };
                            null == D && (C.$l = !0);
                            A.Ip.type == gvjs_4w && (I = A.sx.length,
                            C.Kf.tea = 0 == I || null == A.sx[I - 1] ? null : A.sx[I - 1].Kf.uk);
                            gvjs_xJ(a, C, A.Ip, A.lB, B.zm);
                            l && C.wd && (C.wd.content = C.wd.content + " (" + A.yM.Ob(J - G) + ")");
                            A.sx.push(C);
                            null == D || isNaN(D) || (A.uu[A.Ur] += D)
                        }
                    }(u, h);
                    var x = k ? 0 : t
                      , y = k || g ? u.uu[u.Ur] : null;
                    if (g && !a.V.fz)
                        for (var z = 0; z < (w || 0); z++)
                            y = k || g ? u.uu[u.Ur] : null,
                            v(1, x, y);
                    else
                        v(w, x, y)
                }
    }
    k || gvjs_w(a.je, function(A) {
        gvjs_JI(A)
    })
}
function gvjs_fga(a, b) {
    for (var c = a.V, d = a.lb, e = a.ed, f = gvjs_De(c.C, function(w) {
        return w.type == b
    }), g = 0; g < c.$a.length; ++g) {
        var h = 0 == gvjs_jJ(a, g)
          , k = gvjs_vJ(a, g);
        e.oc(k);
        for (var l = gvjs_LI(e, k), m = [gvjs_3v, gvjs_$t], n = 0; n < f.length; ++n) {
            var p = f[n];
            if (h) {
                p.points.push(null);
                return
            }
            for (var q = a.je[p.Qc], r = q.ta, t = 0; t < m.length; ++t) {
                var u = m[t]
                  , v = d.getValue(g, p.columns[u][0]);
                v = r.zc(v);
                if (null === v) {
                    p.points.push(null);
                    return
                }
                l && q.oc(v);
                a.Tz = Math.max(a.Tz, n + 1);
                u = {
                    brush: u == gvjs_3v ? p.Ih.background.Qg : null,
                    Kf: {
                        Js: g,
                        cF: n,
                        from: null,
                        uk: v,
                        d: k,
                        bsa: u == gvjs_$t,
                        fJ: gvjs_wJ(a, p, g, 0, null, !0)
                    }
                };
                gvjs_xJ(a, u, p, n, g);
                p.points.push(u)
            }
        }
    }
    gvjs_w(a.je, function(w) {
        gvjs_JI(w)
    })
}
function gvjs_$fa(a) {
    var b = a.V
      , c = a.lb
      , d = a.ed
      , e = gvjs_De(b.C, function(f) {
        return f.type == gvjs_Ft
    });
    gvjs_u(b.$a, function(f, g) {
        var h = 0 == gvjs_jJ(this, g);
        gvjs_u(e, function(k, l) {
            if (h)
                k.points.push(null);
            else {
                var m = k.columns.data
                  , n = this.je[k.Qc];
                this.Tz = Math.max(this.Tz, l + 1);
                var p = c.getValue(g, m[0])
                  , q = c.getValue(g, m[1])
                  , r = c.getValue(g, m[2]);
                m = c.getValue(g, m[3]);
                p = n.ta.zc(p);
                q = n.ta.zc(q);
                r = n.ta.zc(r);
                m = n.ta.zc(m);
                if (null === p || null === m || null === q || null === r)
                    k.points.push(null);
                else {
                    var t = gvjs_vJ(this, g);
                    d.oc(t);
                    var u = r < q;
                    gvjs_LI(d, t) && (n.oc(p),
                    n.oc(m));
                    n = {
                        yG: u ? k.NG.g$ : k.NG.Uea,
                        Oc: gvjs_8z(k.color.color),
                        Kf: {
                            Js: g,
                            cF: l,
                            Qsa: p,
                            lineTo: m,
                            vva: u ? r : q,
                            wva: u ? q : r,
                            Xra: u,
                            d: t
                        }
                    };
                    gvjs_xJ(this, n, k, l, g);
                    k.points.push(n)
                }
            }
        }, this)
    }, a)
}
function gvjs_mJ(a, b) {
    var c = a.V
      , d = a.lb
      , e = a.ed
      , f = c.C[b];
    if (f.type == gvjs_e) {
        c = f.ag ? f.data : c.$a;
        for (var g = 0; g < c.length; g++) {
            var h = a.je[f.Qc]
              , k = f.columns.data[0];
            k = f.ag ? f.data[g][1] : d.getValue(g, k);
            k = h.ta.zc(k);
            var l;
            if (null != k) {
                var m = gvjs_vJ(a, g, f);
                e.oc(m);
                (l = gvjs_LI(e, m) && !f.ag) && h.oc(k);
                h = f.ag ? null : gvjs_wJ(a, f, g, 0, null, l)
            } else
                l = !1,
                h = null;
            h = {
                Kf: {
                    Js: g,
                    cF: 0,
                    d: m,
                    t: k,
                    fJ: h
                },
                shape: f.hE,
                Lfa: l
            };
            null == k && (h.$l = !0);
            gvjs_xJ(a, h, f, b, g);
            f.points.push(h)
        }
    }
}
function gvjs_nJ(a) {
    for (var b = a.ed, c = a.V.C, d = 0; d < c.length; d++) {
        var e = c[d];
        if ((e.type == gvjs_e || e.type == gvjs_at) && 0 != e.lineWidth) {
            var f = a.je[e.Qc]
              , g = gvjs_v(e.points, function(l) {
                return gvjs_XG(l) ? null : new gvjs_z(l.Kf.d,l.Kf.t)
            })
              , h = a.V.Zj;
            e = gvjs_wA(g, gvjs_AI(b), h);
            a: {
                switch (b.type) {
                case gvjs_It:
                    var k = b.nb.max - 1;
                    break a;
                case gvjs_Ht:
                    k = b.nb.max - .5;
                    break a
                }
                k = b.nb.max
            }
            g = gvjs_wA(g, k, h);
            f.oc(e);
            f.oc(g)
        }
    }
}
function gvjs_aga(a) {
    var b = a.V
      , c = a.lb
      , d = a.ed
      , e = b.Zj
      , f = b.vp !== gvjs_f
      , g = f && b.vp !== gvjs_c
      , h = b.vp === gvjs_ud ? "#.##%" : "0.00#"
      , k = [];
    g && (k = gvjs_sJ(a, gvjs_at),
    gvjs_tJ(a, gvjs_at));
    for (var l = {}, m = 0; m < b.$a.length; l = {
        jV: l.jV
    },
    m++) {
        var n = gvjs_Ny(a.je, function() {
            return 0
        });
        l.jV = k[m] && k[m].positive + k[m].negative || 1;
        for (var p = function(I) {
            return function(M) {
                return null == M ? null : M / I.jV
            }
        }(l), q = null, r = null, t = 0; t < b.C.length; t++) {
            var u = b.C[t];
            if (u.type == gvjs_at) {
                var v = u.Qc
                  , w = a.je[v]
                  , x = null
                  , y = null
                  , z = u.columns.data[0]
                  , A = c.getValue(m, z)
                  , B = gvjs_eI(w.ta, A)
                  , D = null == B || isNaN(B);
                D && (B = 0);
                var C = gvjs_vJ(a, m);
                if (null != C) {
                    A = void 0;
                    g && (gvjs_cI(w.ta, h),
                    A = gvjs_dI(w.ta));
                    var G = void 0
                      , J = void 0;
                    G = void 0;
                    G = 0 < m ? c.getValue(m - 1, z) : null;
                    J = 0 === m || null === G && !isNaN(G);
                    z = m < c.ca() - 1 ? c.getValue(m + 1, z) : null;
                    z = m === c.ca() - 1 || null === z && !isNaN(z);
                    f ? (G = n[v],
                    D || (G += B),
                    x = r,
                    y = q,
                    D || (z || (r = G),
                    J || (q = G))) : (r = q = G = B,
                    e || (z && (r = null),
                    J && (q = null)));
                    d.oc(C);
                    J = gvjs_LI(d, C);
                    G = p(G);
                    q = p(q);
                    r = p(r);
                    J && !D && (z = gvjs_fI(w.ta, G),
                    w.oc(z));
                    z = gvjs_wJ(a, u, m, n[v], p, J);
                    f && !D && (n[v] += B);
                    G = {
                        d: C,
                        t: gvjs_fI(w.ta, G),
                        Js: m,
                        cF: 0,
                        Wla: C,
                        Xla: gvjs_fI(w.ta, q),
                        Ula: C,
                        Vla: gvjs_fI(w.ta, r),
                        Ska: C,
                        Tka: gvjs_fI(w.ta, x),
                        Qka: C,
                        Rka: gvjs_fI(w.ta, y),
                        fJ: z
                    };
                    v = {
                        Kf: G,
                        shape: u.hE,
                        Lfa: J,
                        $l: D
                    };
                    D || (gvjs_xJ(a, v, u, t, m),
                    g && v.wd && (w = p(B),
                    v.wd.content = v.wd.content + " (" + A.Ob(w) + ")"));
                    u.points.push(v)
                }
            }
        }
    }
    gvjs_nJ(a);
    gvjs_oJ(a)
}
function gvjs_ega(a) {
    gvjs_u(a.V.C, function(b, c) {
        b.ag && (b.type === gvjs_Dd ? gvjs_qJ(this, c) : b.type === gvjs_e && gvjs_mJ(this, c),
        gvjs_yJ(this, c))
    }, a)
}
function gvjs_qJ(a, b) {
    var c = a.V
      , d = a.lb
      , e = a.Bf[0]
      , f = a.ke[0]
      , g = c.C[b]
      , h = g.We;
    if (g.type === gvjs_Dd)
        for (var k = g.ag ? g.data.length : d.ca(), l = 0; l < k; l++) {
            var m = c.Mk[h].columns.domain[0]
              , n = gvjs_kJ(g);
            m = g.ag ? g.data[l][0] : d.getValue(l, m);
            var p = g.ag ? g.data[l][1] : d.getValue(l, n);
            n = e.ta.zc(m);
            m = f.ta.zc(p);
            null !== n && null !== m ? ((p = gvjs_LI(e, n) && gvjs_LI(f, m)) && !g.ag && (e.oc(n),
            f.oc(m)),
            n = {
                Kf: {
                    x: n,
                    y: m
                },
                shape: g.hE,
                Twa: p
            },
            gvjs_xJ(a, n, g, b, l),
            g.points.push(n)) : g.points.push(null)
        }
}
function gvjs_oJ(a) {
    function b(q) {
        var r = null != q.Kf ? q.Kf.Js : null;
        return {
            Nx: null != q.Nx ? q.Nx : 1,
            ty: null != q.ty ? q.ty : 1,
            scope: null != q.scope ? q.scope : !0,
            uoa: null != r ? gvjs_jJ(a, r) : null
        }
    }
    function c(q) {
        return !gvjs_XG(q)
    }
    for (var d = null === gvjs_iJ(a), e = 0; e < a.V.C.length; e++) {
        var f = a.V.C[e]
          , g = f.$r
          , h = f.columns.emphasis || []
          , k = f.columns.scope || [];
        if (0 != (f.columns.certainty || []).length || 0 != h.length || 0 != k.length || !d) {
            h = gvjs_Ey(f.points, c);
            k = b(h || {});
            for (var l = 0; l < f.points.length; l++) {
                var m = f.points[l];
                if (!gvjs_XG(m)) {
                    var n = b(m)
                      , p = f.Oc;
                    n.scope || k.scope || (f.$$ = f.$$ || p.yI(),
                    p = f.$$,
                    m.jt = p,
                    g && (f.Z$ = f.Z$ || g.yI(),
                    m.nQ = f.Z$));
                    if (1 > n.Nx || 1 > k.Nx)
                        p = gvjs_zJ(p, !1),
                        m.jt = p;
                    1 != n.ty && 1 != k.ty && (p = gvjs_iga(p, Math.min(k.ty, n.ty)),
                    m.jt = p);
                    0 != n.uoa || gvjs_XG(h) || (m.jt = null);
                    k = n
                }
                h = m
            }
        }
    }
}
function gvjs_AJ(a) {
    var b = {
        fill: {},
        stroke: {},
        shape: {}
    };
    null != a && (null != a.visible && (b.visible = a.visible),
    null != a.size && (b.size = a.size),
    null != a.color && (b.fill.color = b.stroke.color = a.color),
    null != a.opacity && (b.fill.opacity = b.stroke.opacity = a.opacity),
    null != a.fillColor && (b.fill.color = a.fillColor),
    null != a.fillOpacity && (b.fill.opacity = a.fillOpacity),
    null == b.fill.color && null == b.fill.opacity && delete b.fill,
    null != a.strokeColor && (b.stroke.color = a.strokeColor),
    null != a.strokeOpacity && (b.stroke.opacity = a.strokeOpacity),
    null != a.strokeWidth && (b.stroke.width = a.strokeWidth),
    null == b.stroke.color && null == b.stroke.opacity && null == b.stroke.width && delete b.stroke,
    null != a.shapeType && (b.shape.type = a.shapeType),
    null != a.shapeSides && (b.shape.sides = a.shapeSides),
    null != a.shapeRotation && (b.shape.rotation = a.shapeRotation),
    null != a.shapeDent && (b.shape.dent = a.shapeDent),
    null != a.shortSize && (b.shortSize = a.shortSize));
    return b
}
function gvjs_BJ(a, b, c) {
    var d = void 0;
    b = null != b.columns.style ? b.columns.style[0] : void 0;
    if (null != b && a.lb.W(b) === gvjs_l && (a = a.lb.getValue(c, b),
    null != a)) {
        d = gvjs_kf(a);
        if (gvjs_0z(d))
            var e = {
                fill: {
                    color: d
                },
                stroke: {
                    color: d
                }
            };
        else if ("{" === d.charAt(0)) {
            try {
                var f = gvjs_Gi(d)
            } catch (g) {}
            null != f && (e = f)
        }
        null == e && (gvjs_sf(d, "{") ? (e = gvjs_Ny(gvjs_$I(d), gvjs_AJ),
        gvjs_Ze(e, "") && (Object.assign(e, e[""]),
        gvjs_Qy(e, "")),
        gvjs_Ze(e, "*") && (Object.assign(e, e["*"]),
        gvjs_Qy(e, "*"))) : e = gvjs_AJ(gvjs_Jz(d)));
        d = e
    }
    if (null != d)
        return new gvjs_Aj([d])
}
function gvjs_CJ(a, b, c) {
    c !== gvjs_0p && (a.Te(gvjs_oy(b, [gvjs_pp, gvjs_np], a.fill)),
    a.mf(gvjs_ny(b, gvjs_qp, a.fillOpacity)));
    c !== gvjs_np && (a.rd(gvjs_oy(b, [gvjs_3p, gvjs_0p], a.Uj())),
    gvjs_ay(a, gvjs_ny(b, gvjs_4p, a.strokeOpacity)),
    a.hl(gvjs_L(b, gvjs_5p, a.strokeWidth)))
}
function gvjs_xJ(a, b, c, d, e) {
    if (a.wz) {
        a: {
            d = a.AW(c, d, e);
            var f = c.columns.tooltip;
            if (f && !c.ag) {
                f = f[0];
                if (a.lb.W(f) === gvjs_d) {
                    d.T8 = a.lb.getValue(e, f);
                    d.Nh = !0;
                    d.wi = !0;
                    break a
                }
                (f = gvjs_gJ(a, f, e)) && f.wi && Object.assign(d, f)
            }
            d.Nh = !!d.Nh
        }
        b.wd = d
    }
    d = gvjs_BJ(a, c, e);
    a: {
        f = a.lb;
        var g = c.columns.certainty || [];
        if (g.length) {
            var h = f.getValue(e, g[0]);
            if (null != h) {
                f = f.W(g[0]) == gvjs_zb ? h ? 1 : 0 : h;
                break a
            }
        }
        f = 1
    }
    a: {
        g = a.lb;
        h = c.columns.emphasis || [];
        if (h.length) {
            var k = g.getValue(e, h[0]);
            if (null != k) {
                g = g.W(h[0]) == gvjs_zb ? k ? 2 : 1 : k;
                break a
            }
        }
        g = 1
    }
    a: {
        a = a.lb;
        h = c.columns.scope || [];
        if (h.length && (e = a.getValue(e, h[0]),
        null != e)) {
            e = !!e;
            break a
        }
        e = !0
    }
    a = gvjs_1G(b, c);
    h = c.Qg;
    if (null != d) {
        h = h.clone();
        b.radius = a = gvjs_Oj(d, "point.size", a);
        k = d.fa("point.shape");
        null != k && (b.shape = k);
        k = d.Dq("point.visible");
        null != k && (b.visible = k);
        gvjs_CJ(h, d);
        switch (c.type) {
        case gvjs_e:
        case gvjs_Dd:
        case gvjs_at:
            gvjs_CJ(h, d.view(gvjs_Np));
            null != c.Oc && (b.jt = (b.jt || b.Oc || c.Oc).clone(),
            gvjs_CJ(b.jt, d.view([gvjs_e, ""]), gvjs_0p));
            null != c.$r && (b.nQ = (b.nQ || b.Oc || c.$r).clone(),
            gvjs_CJ(b.nQ, d.view([gvjs_at, ""]), gvjs_np));
            break;
        case gvjs_4w:
            gvjs_CJ(h, d.view(gvjs_at), gvjs_np),
            null != c.Oc && (b.Oc = (b.Oc || c.Oc).clone(),
            gvjs_CJ(b.Oc, d.view([gvjs_e, ""]), gvjs_0p));
        case gvjs_lt:
            gvjs_CJ(h, d.view(gvjs_wb));
            break;
        case gvjs_Ft:
            b.yG = b.yG.clone(),
            gvjs_CJ(b.yG, d.view([gvjs_wb, ""])),
            gvjs_CJ(b.Oc, d.view([gvjs_e, ""]))
        }
        b.brush = h
    }
    e || (b.scope = e,
    c.aaa = c.aaa || h.yI(),
    h = c.aaa,
    b.brush = h);
    1 != g && (b.ty = g,
    c.type == gvjs_e || c.type == gvjs_at || c.type == gvjs_Dd) && (a = Math.round(a * Math.sqrt(g) * 10) / 10,
    b.radius = a);
    if (1 > f)
        switch (b.Nx = f,
        c.type) {
        case gvjs_e:
        case gvjs_at:
        case gvjs_Dd:
            b.brush = gvjs_zJ(h, !0);
            b.radius = Math.max(a - gvjs_fy(b.brush) / 2, 0);
            break;
        case gvjs_lt:
        case gvjs_4w:
            b.brush = gvjs_zJ(h, !1)
        }
}
function gvjs_gJ(a, b, c) {
    var d = a.lb;
    a = a.V.$f && (d.getProperty(c, b, gvjs_av) || d.Bd(b, gvjs_av));
    b = d.Ha(c, b);
    return {
        Nh: !!a,
        wi: b ? !0 : !1,
        content: b
    }
}
gvjs_.AW = function(a, b, c) {
    if (this.V.Fa === gvjs_Dd || a.ag || 0 === a.lineWidth) {
        var d = this.lb
          , e = this.V;
        if (a.ag) {
            var f = a.data[c][0];
            var g = a.data[c][1];
            null != f && (f = gvjs_Hk(f, d.W(a.We)));
            null != g && (g = gvjs_Hk(g, a.dataType));
            var h = e.Ig.has(gvjs_Ht) ? g : f + gvjs_ha + g;
            var k = f
        } else if (this.V.kd) {
            var l = this.Bf[0].title.text || "X"
              , m = this.ke[0].title.text || "Y";
            f = b % 2 ? b - 1 : b;
            b = e.C[f];
            h = e.C[f + 1];
            f = e.Mk[h.We].columns.domain[0];
            g = gvjs_kJ(h);
            f = d.Ha(c, f);
            g = d.Ha(c, g);
            h = l + ": " + f + gvjs_ha + m + ": " + g;
            f = e.Mk[b.We].columns.domain[0];
            g = gvjs_kJ(b);
            f = d.Ha(c, f);
            g = d.Ha(c, g);
            h += "\n" + l + ": " + f + gvjs_ha + m + ": " + g
        } else
            l = gvjs_kJ(a),
            f = d.Ha(c, e.Mk[a.We].columns.domain[0]),
            g = d.Ha(c, l),
            h = e.Ig.has(gvjs_Ht) ? g : f + gvjs_ha + g;
        a = {
            wi: !1,
            content: h,
            En: a.title,
            Mx: k
        }
    } else
        a = gvjs_jga(this, a, c);
    return a
}
;
function gvjs_jga(a, b, c) {
    var d = a.lb
      , e = a.V.$a[c];
    e = b.ag ? b.data[c][0].toString() : e.$w[b.We];
    if (b.type == gvjs_Ft)
        a = b.columns.data,
        a = d.Ha(c, a[0]) + gvjs_ar + d.Ha(c, a[3]) + gvjs_ha + d.Ha(c, a[1]) + gvjs_ar + d.Ha(c, a[2]);
    else if (a.V.kd) {
        var f = b.columns[gvjs_3v]
          , g = b.columns.data
          , h = a.lb.getValue(c, f[0]);
        a = a.lb.getValue(c, g[0]);
        f = d.Ha(c, f[0]);
        g = d.Ha(c, g[0]);
        if (null === h && gvjs_jf(f) && null === a && gvjs_jf(g))
            return {
                wi: !1,
                content: null
            };
        a = g + "\n" + f
    } else {
        g = b.columns.data;
        h = b.ag ? b.data[c][1] : a.lb.getValue(c, g[0]);
        a = b.ag ? b.data[c][1].toString() : a.lb.Ha(c, g[0]);
        if (null === h && gvjs_jf(a))
            return {
                wi: !1,
                content: null
            };
        h = b.columns.interval || [];
        h.length && (h = gvjs_v(h, function(k) {
            return d.Ha(c, k)
        }),
        a += " [" + h.join(gvjs_ha) + "]")
    }
    return {
        wi: !1,
        content: a,
        Mx: e,
        En: b.title,
        Nh: !1
    }
}
function gvjs_pJ(a) {
    function b(x, y, z) {
        k.oc(z.d);
        y.Lfa && a.je[x.Qc].oc(z.t)
    }
    function c(x) {
        return {
            d: x.x,
            t: x.y
        }
    }
    function d(x) {
        return new gvjs_ok(x.d,x.t)
    }
    function e(x, y, z) {
        y.Twa && (a.Bf[0].oc(z.x),
        a.ke[0].oc(z.y))
    }
    function f(x) {
        return {
            x: x.x,
            y: x.y
        }
    }
    function g(x) {
        return new gvjs_ok(x.x,x.y)
    }
    var h = a.V
      , k = a.ed;
    switch (h.Fa) {
    case gvjs_Dd:
        var l = g;
        var m = f;
        var n = e;
        break;
    case gvjs_d:
        l = d,
        m = c,
        n = b
    }
    for (var p = 0; p < h.C.length; p++) {
        var q = h.C[p];
        if (q.type == gvjs_Dd || q.type == gvjs_e)
            if (gvjs_He([gvjs_d, "phase", gvjs_Zt], q.ey)) {
                var r = q.type == gvjs_Dd && q.ey == gvjs_Zt
                  , t = q.ey == gvjs_d;
                q.N_ = !0;
                q.Zra = r;
                r = gvjs_jA(gvjs_v(q.points, function(x) {
                    return gvjs_XG(x) ? null : l(x.Kf)
                }), q.RT, t, r, h.Zj);
                for (t = 0; t < q.points.length; ++t) {
                    var u = q.points[t];
                    if (r[t]) {
                        var v = m(r[t][0])
                          , w = m(r[t][1]);
                        u.nda = v;
                        u.oda = w;
                        n(q, u, v);
                        n(q, u, w)
                    }
                }
            } else
                q.N_ = !1
    }
}
gvjs_.$ka = function() {
    if (this.V.Ig.has(gvjs_Ht)) {
        var a = this.V.$a
          , b = gvjs_v(a, function(n, p) {
            return gvjs_DJ(this, p)
        }, this)
          , c = this.ed;
        a = gvjs_Ky(a.length);
        gvjs_Se(a, function(n, p) {
            return gvjs_Re(b[n], b[p])
        });
        var d = c.Pf
          , e = c.ef;
        if (d > e) {
            var f = d;
            d = e;
            e = f
        }
        for (f = 0; f < a.length; f++) {
            var g = gvjs_DJ(this, a[f]);
            if (null != g) {
                if (gvjs_KI(c, g))
                    return;
                if (!(isNaN(g) || g * c.direction < c.Pf * c.direction)) {
                    var h = f;
                    break
                }
            }
        }
        if (void 0 !== h) {
            f = d;
            d = null;
            for (var k = h; k < a.length; k++) {
                null != d && k < d && (k = d,
                d = null);
                var l = a[k];
                h = f;
                if (k == a.length - 1) {
                    gvjs_EJ(this, l, h, e);
                    break
                }
                var m = gvjs_DJ(this, a[k + 1]);
                if (null == m) {
                    for (f = k + 2; f < a.length; f++)
                        if (m = gvjs_DJ(this, a[f]),
                        null != m) {
                            d = f;
                            break
                        }
                    if (null == m) {
                        gvjs_EJ(this, l, h, e);
                        break
                    }
                }
                if (gvjs_KI(c, m)) {
                    gvjs_EJ(this, l, h, e);
                    break
                }
                f = gvjs_bz(g, m);
                gvjs_EJ(this, l, h, f);
                g = m
            }
        }
    }
}
;
function gvjs_DJ(a, b) {
    var c = a.V.$a;
    a = a.ed;
    return a.type == gvjs_Vd ? null == c[b].data ? null : a.vN(c[b].data) : a.Jc(b)
}
function gvjs_EJ(a, b, c, d) {
    function e() {
        var m = c;
        c = d;
        d = m
    }
    var f = a.V.O.top
      , g = a.V.O.bottom
      , h = a.V.O.left
      , k = a.V.O.right
      , l = a.ed.direction;
    b = a.V.$a[b];
    a.V.orientation == gvjs_S ? 1 == l ? (d < c && e(),
    b.dT = new gvjs_B(f,d,g,c)) : (d > c && e(),
    b.dT = new gvjs_B(f,c,g,d)) : 1 == l ? (d < c && e(),
    b.dT = new gvjs_B(c,k,d,h)) : (d > c && e(),
    b.dT = new gvjs_B(d,k,c,h))
}
gvjs_.Iva = function() {
    gvjs_kga(this);
    gvjs_lga(this)
}
;
function gvjs_kga(a) {
    var b = a.V;
    gvjs_w(b.wc, function(c, d) {
        gvjs_FJ(this, this.ke[d], b.wc[d], this.usa)
    }, a);
    gvjs_w(b.jd, function(c, d) {
        gvjs_FJ(this, this.Bf[d], b.jd[d], this.fsa)
    }, a)
}
function gvjs_lga(a) {
    var b = a.V;
    gvjs_w(b.wc, function(c, d) {
        gvjs_FJ(a, a.ke[d], c, function() {
            return !0
        })
    });
    gvjs_w(b.jd, function(c, d) {
        gvjs_FJ(a, a.Bf[d], c, function(e, f) {
            return gvjs_mga(a, f)
        })
    })
}
function gvjs_FJ(a, b, c, d) {
    c.text && (c.text = gvjs_De(c.text, d.bind(a, b)))
}
gvjs_.fsa = function(a, b) {
    var c = this.V;
    b = b.Da;
    return b.angle ? !0 : (b = gvjs_RF(b)) ? a.uj != gvjs_Fp || (new gvjs_B(c.O.top,c.O.right,c.O.bottom,c.O.left)).contains(b) ? !0 : !1 : !0
}
;
function gvjs_mga(a, b) {
    var c = a.V
      , d = b.Da;
    if (d.angle)
        return !0;
    b = gvjs_RF(d);
    if (!b)
        return !0;
    d = Math.ceil(d.ja.fontSize / 8);
    var e = new gvjs_B(b.top,b.right + d,b.bottom,b.left - d), f;
    for (f in c.wc) {
        var g = Number(f);
        if (a.ke[g].uj == gvjs_Fp && !(1 > (c.wc[g].text ? c.wc[g].text.length : 0))) {
            var h = gvjs_RF(c.wc[g].text[0].Da)
              , k = gvjs_RF(gvjs_Ae(c.wc[g].text).Da);
            if (h || k) {
                if (h && gvjs_lz(e, h) || k && gvjs_lz(e, k))
                    return !1;
                h ? k ? (g = Math.min(h.left, k.left),
                h = Math.max(h.right, k.right)) : (g = h.left,
                h = h.right) : (g = k.left,
                h = k.right);
                if (Math.abs(b.left - g) < d || Math.abs(b.right - h) < d)
                    return !1
            }
        }
    }
    return !0
}
gvjs_.usa = function(a, b) {
    var c = this.V
      , d = new gvjs_B(c.O.top,c.O.right,c.O.bottom,c.O.left)
      , e = b.Da;
    b = e.ja.fontSize / 8;
    e = gvjs_RF(e);
    if (!e)
        return !0;
    if (a.uj == gvjs_Fp && !d.contains(e))
        return !1;
    a = new gvjs_B(e.top,e.right + b,e.bottom,e.left - b);
    return (d = gvjs_RF(c.title)) && gvjs_lz(a, d) || (c = c.cJ ? gvjs_RF(c.cJ) : null) && gvjs_lz(a, c) ? !1 : (c = this.ne.getArea()) && gvjs_lz(a, c) ? !1 : !0
}
;
function gvjs_yJ(a, b) {
    b = a.V.C[b];
    var c = gvjs_nga(a, b);
    b.points && gvjs_u(b.points, function(d) {
        null == d || d.$l || (d.ia = c(d.Kf),
        null != d.nda && (d.wt = c(d.nda)),
        null != d.oda && (d.fr = c(d.oda)))
    });
    b.Df && (0 < b.Df.lines.length || 0 < b.Df.areas.length) && gvjs_oga(b)
}
gvjs_.dva = function() {
    gvjs_u(this.V.C, function(a, b) {
        gvjs_yJ(this, b)
    }, this)
}
;
function gvjs_oga(a) {
    function b(q) {
        var r = e[q];
        delete e[q];
        if (r && 1 < r.line.length) {
            r.bottom && r.bottom.reverse();
            if (f[q].ey != gvjs_f) {
                var t = f[q].ey == gvjs_d;
                q = f[q].RT;
                r.kX = gvjs_jA(r.line, q, t, !1, !1);
                r.bottom && (r.Pka = gvjs_jA(r.bottom, q, t, !1, !1))
            }
            a.Df.paths.push(r)
        }
    }
    function c(q, r) {
        if (!e[q]) {
            var t = f[q].brush.clone()
              , u = f[q].style
              , v = {};
            v.ss = q;
            v.line = [];
            u == gvjs_at ? (t.hl(0),
            v.bottom = []) : t.mf(0);
            v.brush = t;
            e[q] = v
        }
        e[q].line.push(new gvjs_ok(r.left,r.top));
        e[q].bottom && e[q].bottom.push(new gvjs_ok(r.left + r.width,r.top + r.height))
    }
    function d(q) {
        q = f[q].style;
        return q == gvjs_at || q == gvjs_e
    }
    var e = {}
      , f = a.Df.eu;
    a.Df.paths = [];
    for (var g = 0; g < a.points.length; g++) {
        var h = {}
          , k = a.points[g];
        if (k && k.ia && k.ia.mt) {
            k = k.ia.mt;
            for (var l = 0; l < k.length; ++l) {
                var m = k[l].ss;
                d(m) && (h[m] = !0,
                c(m, k[l].rect))
            }
        }
        for (var n in e)
            k = Number(n),
            h[k] || f[k].Zj || b(k)
    }
    for (var p in e)
        b(Number(p))
}
function gvjs_nga(a, b) {
    switch (b.type) {
    case gvjs_Dd:
        return a.awa.bind(a, b);
    case gvjs_At:
        return a.Yva.bind(a, b);
    case gvjs_e:
        return a.$va.bind(a, b);
    case gvjs_lt:
        return a.Xva.bind(a, b);
    case gvjs_4w:
        return a.bwa.bind(a, b);
    case gvjs_Ft:
        return a.Zva.bind(a, b);
    case gvjs_at:
        return a.Wva.bind(a, b)
    }
    return null
}
gvjs_.awa = function(a, b) {
    a = this.Bf[0].Jc(b.x);
    b = this.ke[0].Jc(b.y);
    return {
        x: a,
        y: b
    }
}
;
gvjs_.Yva = function(a, b) {
    var c = this.gs
      , d = this.ke[0];
    a = this.Bf[0].Jc(b.x);
    d = d.Jc(b.y);
    var e = gvjs_PI(c, b);
    e = new gvjs_3({
        fill: e,
        fillOpacity: c.lK,
        stroke: c.$T
    });
    b = gvjs_MI(c.tL, b.size);
    return {
        x: a,
        y: d,
        brush: e,
        radius: b,
        eT: b
    }
}
;
gvjs_.$va = function(a, b) {
    var c = gvjs_GJ(this, a.Qc, b.d, b.t);
    c.mt = gvjs_HJ(this, a, b);
    return c
}
;
gvjs_.Xva = function(a, b) {
    var c = gvjs_IJ(this, a, b, b.from, b.uk);
    return c ? {
        top: c.top,
        left: c.left,
        width: Math.max(.5, c.width),
        height: Math.max(.5, c.height),
        mt: gvjs_HJ(this, a, b)
    } : null
}
;
gvjs_.Zva = function(a, b) {
    var c = gvjs_IJ(this, a, b, b.vva, b.wva)
      , d = gvjs_IJ(this, a, b, b.Qsa, b.lineTo);
    if (!c || !d)
        return null;
    var e = gvjs_JJ(this, d.left, d.top)
      , f = gvjs_JJ(this, c.width, c.height)
      , g = gvjs_JJ(this, d.width, d.height);
    g.domain = 2;
    e.domain += (f.domain - (f.domain % 2 ? 3 : 2)) / 2;
    e = gvjs_KJ(this, e.domain, e.target);
    g = gvjs_KJ(this, g.domain, g.target);
    d.width = g.x;
    d.height = g.y;
    d.left = e.x;
    d.top = e.y;
    a = b.Xra ? a.NG.g$ : a.NG.Uea;
    gvjs_ey(a) && (a = a.strokeWidth / 2,
    c.height -= 2 * a,
    c.width -= 2 * a,
    c.left += a,
    c.top += a);
    c.height = Math.max(c.height, 2);
    c.width = Math.max(c.width, 1);
    return {
        rect: c,
        line: d
    }
}
;
gvjs_.bwa = function(a, b) {
    var c = this.je[a.Qc];
    null == b.from && (b.from = c.ta.zc(c.baseline.za),
    null == b.from && (b.from = 0));
    var d = this.ed
      , e = b.Js;
    if (this.Pr || d.ta) {
        if (null == b.hy)
            return null;
        e = Math.floor(d.Jc(b.hy));
        var f = Math.floor(d.Jc(b.d));
        d.oc(b.hy)
    } else {
        var g = d.ticks[e].Na;
        f = d.ww;
        e = Math.floor(g - d.direction * f / 2);
        f = Math.floor(g + d.direction * f / 2)
    }
    d.oc(b.d);
    d = c.Jc(b.from);
    var h = c.Jc(b.uk);
    d = gvjs_KJ(this, e, d);
    g = gvjs_KJ(this, e, h);
    f = gvjs_KJ(this, f, h);
    h = [];
    gvjs_K(this.options, "connectSteps", !0) && null != b.tea && (c = c.Jc(b.tea),
    c = gvjs_KJ(this, e, c),
    h.push(c));
    h.push(g);
    h.push(f);
    return {
        bar: gvjs_5I(d.x, d.y, f.x, f.y),
        outline: h,
        mt: gvjs_HJ(this, a, b)
    }
}
;
function gvjs_IJ(a, b, c, d, e) {
    var f = a.ed
      , g = a.je[b.Qc];
    b = a.LH;
    var h = g.ta.zc(g.baseline.za);
    null == d && (d = h || 0);
    null == e && (e = h || 0);
    h = e;
    h = Math.min(g.Jc(d), g.Jc(h));
    d = Math.max(g.Jc(d), g.Jc(e));
    g = a.V.Fa === gvjs_4u ? gvjs_uJ(g.ww, gvjs_K(a.options, gvjs_6u)) ? 0 : 1 : Math.min(1, .2 * (d - h));
    0 === g || Math.floor(h + g) < Math.floor(d) && Math.floor(h + g) > Math.floor(h) ? (h = Math.floor(h + g),
    d = Math.floor(d)) : h += g;
    g = gvjs_L(a.options, "diff.newData.widthFactor", .3);
    g = c.bsa ? g : 1;
    if (a.Pr) {
        if (null == c.hy)
            return null;
        g = Math.floor(f.Jc(c.hy));
        b = Math.floor(f.Jc(c.d));
        f.oc(c.hy)
    } else
        c = gvjs_LJ(a, c),
        e = g * b.P4 / 2,
        g = b.j3(c - e),
        b = b.j3(c + e);
    f.oc(f.uN(g));
    f.oc(f.uN(b));
    f = gvjs_KJ(a, g, h);
    a = gvjs_KJ(a, b, d);
    return gvjs_5I(f.x, f.y, a.x, a.y)
}
gvjs_.Wva = function(a, b) {
    function c(l) {
        return null != l ? l : e
    }
    var d = this.je[a.Qc];
    d = d.ta.zc(d.baseline.za);
    var e = null != d ? d : 0;
    d = gvjs_GJ(this, a.Qc, b.d, b.t);
    var f = gvjs_GJ(this, a.Qc, b.Qka, c(b.Rka))
      , g = gvjs_GJ(this, a.Qc, b.Ska, c(b.Tka))
      , h = gvjs_GJ(this, a.Qc, b.Ula, c(b.Vla))
      , k = gvjs_GJ(this, a.Qc, b.Wla, c(b.Xla));
    a = gvjs_HJ(this, a, b);
    return {
        x: d.x,
        y: d.y,
        kW: f.x,
        lW: f.y,
        mW: g.x,
        nW: g.y,
        UN: h.x,
        VN: h.y,
        WN: k.x,
        XN: k.y,
        mt: a
    }
}
;
function gvjs_HJ(a, b, c) {
    if (!c.fJ)
        return [];
    var d = a.ed;
    b = a.je[b.Qc];
    var e = a.LH;
    if (c.cF >= e.Zta || d.type != gvjs_Vd && c.Js >= d.ticks.length)
        return [];
    var f = gvjs_LJ(a, c)
      , g = e.j3;
    a.Pr ? (d = d.Jc(c.d) - d.Jc(c.hy),
    f -= d / 2) : d = e.P4 + e.pga;
    e = [];
    for (var h = 0, k; k = c.fJ[h]; h++) {
        var l = b.Jc(k.rra)
          , m = b.Jc(k.Wsa)
          , n = d * k.xxa / 2
          , p = g(f - n);
        n = g(f + n);
        p = gvjs_KJ(a, p, Math.min(m, l));
        l = gvjs_KJ(a, n, Math.max(m, l));
        e.push({
            rect: gvjs_5I(p.x, p.y, l.x, l.y),
            ss: k.ss,
            brush: k.brush
        })
    }
    return e
}
function gvjs_LJ(a, b) {
    var c = a.ed
      , d = a.LH;
    c = c.type == gvjs_Vd ? c.Jc(b.d) : c.ticks && c.ticks[b.Js] && c.ticks[b.Js].Na;
    if (a.Pr)
        return c;
    a = d.P4;
    return c - d.ena + (a + d.pga) * b.cF + a / 2
}
function gvjs_JJ(a, b, c) {
    switch (a.V.orientation) {
    case gvjs_S:
        return {
            domain: b,
            target: c
        };
    case gvjs_U:
        return {
            domain: c,
            target: b
        }
    }
    throw Error(gvjs_is);
}
function gvjs_KJ(a, b, c) {
    switch (a.V.orientation) {
    case gvjs_S:
        return {
            x: b,
            y: c
        };
    case gvjs_U:
        return {
            x: c,
            y: b
        }
    }
    throw Error(gvjs_is);
}
function gvjs_GJ(a, b, c, d) {
    b = a.je[b];
    c = a.ed.Jc(c);
    d = b.Jc(d);
    return gvjs_KJ(a, c, d)
}
function gvjs_zJ(a, b) {
    a = a.clone();
    gvjs_gy(a) && a.fill != gvjs_ea ? (gvjs_by(a, new gvjs_$x(gvjs_rw,a.fill)),
    !gvjs_ey(a) && b && (a.rd(a.fill),
    a.hl(1))) : gvjs_ey(a) && (a.Mi = gvjs_9t);
    return a
}
function gvjs_iga(a, b) {
    a = a.clone();
    a.hl(a.strokeWidth * b);
    return a
}
function gvjs_jJ(a, b) {
    var c = gvjs_iJ(a);
    return null !== c ? a.lb.getValue(b, c) : null
}
function gvjs_iJ(a) {
    if (null === a.ed || a.ed.type != gvjs_Vd)
        return null;
    a = a.V.Mk[0].columns.gap || [];
    return 0 == a.length ? null : a[0]
}
function gvjs_wJ(a, b, c, d, e, f) {
    function g(u, v, w, x, y) {
        var z = h.eu[u]
          , A = p.getValue(c, u);
        A = m ? A : n(A);
        v = p.getValue(c, v);
        v = m ? v : n(v);
        null != A && null != v && (A += d,
        v += d,
        e && (A = e(A),
        v = e(v)),
        m && (A = n(A),
        v = n(v)),
        f && (l.oc(A),
        l.oc(v)),
        z = z.brush,
        null != k && (z = z.clone(),
        gvjs_CJ(z, k.view([x, ""])),
        y = y || gvjs_Xw,
        w = gvjs_L(k, [x + "." + y, y], w)),
        q.push({
            Wsa: A,
            rra: v,
            xxa: w,
            ss: u,
            brush: z
        }))
    }
    var h = b.Df;
    if (!h)
        return null;
    var k = gvjs_BJ(a, b, c)
      , l = a.je[b.Qc]
      , m = l.gw
      , n = l.ta.zc.bind(l.ta)
      , p = a.lb
      , q = [];
    for (a = 0; a < h.IA.length; a += 2)
        g(h.IA[a], h.IA[a + 1], 0, "interval stick");
    a = 0;
    for (b = h.qN.length - 1; a <= b; a++,
    b--) {
        var r = h.qN[a];
        g(r, h.qN[b], h.eu[r].Vka, "interval box")
    }
    for (a = 0; a < h.points.length; a++)
        b = h.points[a],
        g(b, b, 0, "interval point");
    for (a = 0; a < h.Mb.length; a++) {
        b = h.Mb[a];
        r = h.eu[b];
        var t = !(0 == a || a == h.Mb.length - 1);
        g(b, b, t ? r.Qwa : r.Ika, "interval bar", t ? "shortSize" : void 0)
    }
    a = 0;
    for (b = h.areas.length - 1; a <= b; a++,
    b--)
        g(h.areas[a], h.areas[b], 0, "interval area");
    for (a = 0; a < h.lines.length; a++)
        b = h.lines[a],
        g(b, b, 0, "interval line");
    return q.length ? q : null
}
function gvjs_cga(a) {
    function b() {
        m = h / f;
        7 > m && (m = Math.floor(m));
        m = Math.max(1, m);
        n = a.options.Mg("bar.gap", m);
        p = gvjs_Fj(a.options, gvjs_Rj, 0, gvjs_kt, gvjs_So, m);
        null == n && (n = Math.max(1 < f ? 1 : 0, m - p));
        p = m - n
    }
    var c = a.V.Fa === gvjs_4u
      , d = a.ed
      , e = gvjs_pga(a)
      , f = a.Tz
      , g = a.options.Mg("bar.group.gap", e)
      , h = a.options.Mg(["bar.group.width", gvjs_jt], e);
    1 == f && (null == g && (g = a.options.Mg("bar.gap", e)),
    null == h && (h = a.options.Mg([gvjs_kt], e)));
    null == g && c && (g = 1);
    if (null == h) {
        var k = a.options.Aa("bar.gap") || 1
          , l = a.options.Aa(gvjs_kt);
        null != l ? h = f * (l + k) - k : c || (h = gvjs_Rj(100 / 1.618 + "%", e))
    }
    null == g && (g = Math.max(0, e - h));
    h = Math.max(f, e - g);
    g = e - h;
    var m, n = null;
    b();
    n > g && (g = n,
    h = e - g);
    g -= n;
    h += n;
    b();
    var p = gvjs_qA(10, p);
    n = gvjs_qA(10, n);
    h = gvjs_qA(10, h);
    g = gvjs_qA(10, g);
    d = d.direction;
    e = g + n;
    a.LH = {
        Zta: f,
        ena: gvjs_qA(10, c ? (-1 === d ? h + g : 0) + -(g + n) / 2 : (h - n) / 2),
        GCa: g,
        HCa: h,
        P4: p,
        pga: n,
        j3: 7 > p && 0 == p % 2 || 7 > e && 0 == e % 2 ? function(q) {
            return Math.floor(q) + .5
        }
        : function(q) {
            return Math.floor(q + .5)
        }
    }
}
function gvjs_pga(a) {
    var b = a.ed
      , c = a.V.$a;
    c = gvjs_De(c, function(h, k) {
        return 0 != gvjs_jJ(a, k)
    });
    if (0 == c.length)
        return 0;
    var d = a.jN;
    if (!d || 0 === d.size)
        return 0;
    if (b.type == gvjs_Vd) {
        d = b.vG;
        for (var e = null, f = 0; f < c.length; f++) {
            var g = gvjs_vJ(a, f);
            g = null == g ? null : b.Jc(g);
            null != g && null != e && (e = Math.abs(g - e),
            0 < e && (d = Math.min(d, e)));
            e = g
        }
        return d
    }
    return Math.abs(b.vN(1) - b.vN(0))
}
function gvjs_vJ(a, b, c) {
    var d = a.lb;
    a = a.ed;
    a.type == gvjs_Vd && (b = c && c.ag ? c.data[b][0] : d.getValue(b, 0),
    b = a.ta.zc(b));
    return b
}
function gvjs_rJ(a, b) {
    this.Ti = a;
    this.m = b
}
function gvjs_dga(a) {
    var b = a.Ti.ti()
      , c = a.m
      , d = a.Ti.ed
      , e = b.orientation || gvjs_S;
    if (d) {
        var f = d.direction
          , g = -1;
        e === gvjs_U && (f = 1,
        g = d.direction);
        var h = a.Ti.LH
          , k = h && h.GEa;
        h = {
            bb: b.Hj,
            fontSize: b.Dl,
            Lb: b.oz
        };
        var l = gvjs_ry(c, [gvjs_2s, gvjs_9s], h)
          , m = gvjs_qy(c, ["annotations.domain.boxStyle", gvjs__s])
          , n = gvjs_oy(c, ["annotations.domain.stem.color", gvjs_0s, gvjs_4s, gvjs_6s], "")
          , p = gvjs_L(c, ["annotations.domain.stem.length", "annotations.domain.stemLength", gvjs_5s, gvjs_7s], 5)
          , q = 90;
        e === gvjs_U && (q = 0);
        gvjs_L(c, ["annotations.domain.stem.angle", "annotations.stem.angle"], q);
        var r = gvjs_J(c, [gvjs_1s, gvjs_8s], gvjs_Np, gvjs_pC);
        "letter" === r && (r = gvjs_Np);
        gvjs_u(b.$a, function(B, D) {
            var C = []
              , G = [];
            gvjs_u(b.Mk, function(H) {
                H = this.VO(D, H.columns, r);
                gvjs_Me(C, H.point);
                gvjs_Me(G, H.line)
            }, this);
            if (C.length || G.length) {
                var J = gvjs_vJ(this.Ti, D);
                J = d.Jc(J);
                var I = null
                  , M = null;
                e === gvjs_U ? (I = b.O.left,
                M = J) : (I = J,
                M = b.O.top + b.O.height);
                C.length && (B.Bc = gvjs_MJ(this, I, M, null, gvjs_f, "", e, f, g, C, l, m, p, n));
                G.length && (b.orientation === gvjs_U ? I = null : M = null,
                B.Bc = gvjs_NJ(this, I, M, e, G, l, n))
            }
        }, a);
        var t = gvjs_Xe(gvjs_hC)
          , u = gvjs_K(c, ["annotations.datum.highContrast", gvjs_3s], !0)
          , v = gvjs_K(c, ["annotations.datum.alwaysOutside", "annotations.alwaysOutside"], !1)
          , w = gvjs_ry(c, ["annotations.datum.textStyle", gvjs_9s], h, t)
          , x = gvjs_qy(c, ["annotations.datum.boxStyle", gvjs__s])
          , y = gvjs_oy(c, ["annotations.datum.stem.color", "annotations.datum.stemColor", gvjs_4s, gvjs_6s], "", t)
          , z = gvjs_L(c, ["annotations.datum.stem.length", "annotations.datum.stemLength", gvjs_5s, gvjs_7s], 12)
          , A = gvjs_J(c, ["annotations.datum.style", gvjs_8s], gvjs_Np, gvjs_pC);
        "letter" === A && (A = gvjs_Np);
        gvjs_u(b.C, function(B, D) {
            if (B.type == gvjs_at || B.type == gvjs_lt || B.type == gvjs_e || B.type == gvjs_Dd || B.type == gvjs_4w) {
                var C = gvjs_Qw + D + ".annotations.";
                D = gvjs_K(c, C + gvjs_2u, u);
                var G = gvjs_K(c, C + "alwaysOutside", v)
                  , J = gvjs_ry(c, C + gvjs_bx, w, t);
                J.color = gvjs_$G(J.color, B.color);
                var I = gvjs_qy(c, [C + "boxStyle"], x)
                  , M = gvjs_oy(c, [C + "stemColor", C + "stem.color"], y, t)
                  , H = gvjs_L(c, [C + "stemLength", C + "stem.length"], z);
                gvjs_L(c, [C + "stem.angle"], z);
                M = gvjs_$G(M, B.color);
                gvjs_J(c, C + gvjs_Jd, A, gvjs_pC);
                C = a.Ti.je[B.Qc];
                for (var Q = 0; Q < B.points.length; ++Q)
                    if (null != B.points[Q] && null != B.points[Q].ia) {
                        var R = B.points[Q]
                          , T = a.VO(Q, B.columns, A)
                          , O = R.ia
                          , K = gvjs_gy(B.Qg) ? B.Qg.fill : D ? gvjs_Br : gvjs_kr;
                        R = R.brush && gvjs_gy(R.brush) ? R.brush.fill : K;
                        if (R !== K && D) {
                            K = gvjs_x(J);
                            var E = [.1, .2, .3]
                              , F = gvjs_vj(R)
                              , L = gvjs_vj(b.xG.fill)
                              , N = gvjs_v(E, gvjs_re(gvjs_1z, F));
                            E = gvjs_v(E, gvjs_re(gvjs_2z, F));
                            F = gvjs_Ke([F], N, E);
                            L = gvjs_uj(gvjs_4z(L, F));
                            K.color = L
                        } else
                            K = J;
                        N = F = L = null;
                        E = d;
                        var P = C;
                        e === gvjs_U && (E = C,
                        P = d);
                        if (null != O.x)
                            L = O.x,
                            F = O.y;
                        else if (null != O.bar || null != O.left)
                            N = O.bar,
                            null == N && (N = new gvjs_5(O.left,O.top,O.width,O.height)),
                            L = N.left,
                            F = N.top,
                            k ? (1 == E.direction && (L = N.left + N.width),
                            1 == P.direction && (F = N.top + N.height)) : e === gvjs_U ? (F = N.top + N.height / 2,
                            1 == E.direction && (L = N.left + N.width)) : (L = N.left + N.width / 2,
                            1 == P.direction && (F = N.top + N.height));
                        T.point.length && (B.points[Q].Bc = gvjs_MJ(a, L, F, N, B.type, R, e, E.direction, P.direction, T.point, K, I, H, M, D, G));
                        T.line.length && (B.points[Q].Bc = gvjs_NJ(a, L, F, e, T.line, J, M))
                    }
            }
        })
    }
}
gvjs_rJ.prototype.VO = function(a, b, c) {
    var d = this.Ti.lb
      , e = b.annotation
      , f = {
        line: [],
        point: []
    };
    if (null == e)
        return f;
    b = b.annotationText || [];
    for (var g = 0; g < e.length; ++g) {
        var h = e[g]
          , k = h + 1;
        0 <= gvjs_Be(b, k) && d.Ha(a, k) || (k = null);
        null != d.getValue(a, h) && (k = {
            text: d.Ha(a, h),
            pF: k,
            rowIndex: a
        },
        gvjs_J(this.m, "annotation." + h + ".style", c, gvjs_pC) == gvjs_e ? f.line.push(k) : f.point.push(k))
    }
    return f
}
;
function gvjs_MJ(a, b, c, d, e, f, g, h, k, l, m, n, p, q, r, t) {
    var u = a.Ti.ti()
      , v = l.length
      , w = [[64, 64, 64], [128, 128, 128], [255, 255, 255]];
    r = null == r ? !0 : r;
    var x = e === gvjs_lt || e === gvjs_4w;
    x && d && (g === gvjs_U ? c = Math.floor(d.top + d.height / 2) : b = Math.floor(d.left + d.width / 2));
    if (g === gvjs_S && 1 === k || g === gvjs_U && 1 === h)
        p *= -1;
    var y = g === gvjs_S ? 1 === k ? gvjs_vt : gvjs_vx : 1 === h ? gvjs_j : gvjs_$c
      , z = b
      , A = c - p;
    g === gvjs_U && (z = b - p,
    A = c);
    e = -p;
    var B = !1
      , D = p + m.fontSize * v;
    c - D < u.O.top && c + D < u.O.bottom && (A = c + D,
    e = p);
    p = [];
    for (u = 0; u < v; u++) {
        D = l[u];
        var C = (0,
        a.Ti.sc)(D.text, m)
          , G = {}
          , J = new gvjs_HG(null == z ? void 0 : z,null == A ? void 0 : A)
          , I = null;
        G.ja = new gvjs_ly(m);
        if (!x)
            G.ld = gvjs_0,
            G.Pc = gvjs_R;
        else if (d && !t && 1 === v) {
            I = gvjs_vj(f);
            I = gvjs_uj(gvjs_4z(I, w));
            var M = gvjs_Ji(m, gvjs_Ki);
            r && (M.Lb = gvjs_f,
            M.color = I);
            a: {
                var H = D.text;
                I = new gvjs_5(d.left,d.top + 0,d.width,d.height);
                var Q = a.Ti.sc
                  , R = a.Ti.wz
                  , T = Q(H, M)
                  , O = I.Tb();
                var K = T.width <= O.width && T.height <= O.height;
                O = {};
                var E = [];
                O.text = H;
                O.ja = M;
                if (y === gvjs_vx) {
                    var F = Math.floor(I.getCenter().x)
                      , L = I.top + 2;
                    O.ld = gvjs_0;
                    O.Pc = gvjs_2
                } else if (y === gvjs_j)
                    F = I.left + I.width - 4,
                    L = Math.floor(I.getCenter().y),
                    O.ld = gvjs_R,
                    O.Pc = gvjs_0;
                else if (y === gvjs_vt)
                    F = Math.floor(I.getCenter().x),
                    L = I.top + I.height - 2,
                    O.ld = gvjs_0,
                    O.Pc = gvjs_R;
                else if (y === gvjs_$c)
                    F = I.left + 4,
                    L = Math.floor(I.getCenter().y),
                    O.ld = gvjs_2,
                    O.Pc = gvjs_0;
                else
                    throw Error("Invalid text block position.");
                if (!K || T.width > I.width - 4)
                    if (T.height < I.height) {
                        if (M = gvjs_DG(Q, H, M, I.width - 4, I.height / (T.height + 2)),
                        E = M.lines,
                        M.oe) {
                            var N = H;
                            O.hx = !0
                        }
                    } else if (I.height > M.fontSize / 3)
                        N = H,
                        E = [gvjs_Kr],
                        L = Math.floor(I.getCenter().y),
                        O.Pc = gvjs_0,
                        O.hx = !0;
                    else {
                        I = null;
                        break a
                    }
                O.lines = [];
                if (E.length)
                    for (H = M = 0,
                    Q = E.length; H < Q; H++)
                        O.lines.push(new gvjs_cJ({
                            x: 0,
                            y: M,
                            length: I.width,
                            text: E[H]
                        })),
                        M += T.height;
                else
                    O.lines.push(new gvjs_cJ({
                        x: 0,
                        y: 0,
                        length: T.width,
                        text: H
                    }));
                O.angle = 0;
                O.anchor = new gvjs_HG(F,L);
                R && N && (O.wd = {
                    Nh: !1,
                    wi: !1,
                    content: N
                });
                I = new gvjs_dJ(O)
            }
        }
        if (I && !I.hx && 1 === v)
            p.push(I),
            B = !0;
        else {
            switch (g) {
            case gvjs_S:
                G.ld = gvjs_0;
                G.Pc = -1 === k ? gvjs_R : gvjs_2;
                break;
            case gvjs_U:
                G.ld = 1 === h ? gvjs_2 : gvjs_R,
                G.Pc = gvjs_0
            }
            G.text = D.text;
            G.ja = m;
            G.vl = n;
            G.anchor = J;
            G.hx = !1;
            G.lines = [{
                x: 0,
                y: 0,
                length: C.width,
                text: D.text
            }];
            G.angle = 0;
            C = D.pF;
            a.Ti.wz && null != C && (G.wd = gvjs_gJ(a.Ti, C, D.rowIndex));
            p.push(new gvjs_dJ(G));
            A += k * m.fontSize * G.lines.length
        }
    }
    a = gvjs_U;
    g === gvjs_U && (a = gvjs_S);
    return {
        kga: {
            x: b,
            y: c,
            length: B ? 0 : e,
            orientation: a,
            color: q
        },
        labels: p,
        Rp: null
    }
}
function gvjs_NJ(a, b, c, d, e, f, g) {
    for (var h = a.Ti.ti(), k = f.fontSize, l = [], m = a.Ti.sc, n = 0; n < e.length; n++) {
        var p = gvjs_DG(m, e[n].text, f, h.O.height - k);
        l.push(p)
    }
    m = gvjs_U;
    n = 270;
    var q = c
      , r = h.O.top;
    p = h.O.bottom;
    d === gvjs_U && (m = gvjs_S,
    n = 0,
    q = b,
    r = h.O.left,
    p = h.O.right);
    if (null != b && null != c) {
        for (var t = h = 0; t < l.length; t++)
            h = Math.max(h, l[t].Oq);
        h += k;
        k = Math.max(Math.round(q - h / 2), r);
        p = Math.min(k + h, p);
        k = p - h
    } else
        k = r;
    r = Math.round((k + p) / 2);
    h = b;
    q = k;
    d === gvjs_U && (h = k,
    q = c);
    d === gvjs_U ? (b = r,
    c += 2) : (b += 2,
    c = r);
    r = [];
    for (t = 0; t < e.length; t++) {
        var u = e[t]
          , v = l[t];
        v = {
            text: u,
            ja: f,
            lines: [{
                x: b,
                y: c,
                length: v.Oq,
                text: v.lines[0] || ""
            }],
            ld: gvjs_0,
            Pc: gvjs_2,
            anchor: null,
            angle: n
        };
        var w = u.pF;
        a.Ti.wz && null != w && (v.wd = gvjs_gJ(a.Ti, w, u.rowIndex));
        r.push(v);
        d === gvjs_U ? c += f.fontSize : b += f.fontSize
    }
    return {
        kga: {
            x: h,
            y: q,
            length: p - k,
            orientation: m,
            color: g
        },
        labels: r,
        Rp: null
    }
}
;function gvjs_OJ(a) {
    gvjs_F.call(this);
    this.Vk = a;
    this.h1 = [];
    this.xQ = !1;
    this.Kh = {
        De: null,
        wL: 0,
        xp: 0,
        rH: 0,
        sH: 0
    }
}
gvjs_o(gvjs_OJ, gvjs_F);
gvjs_OJ.prototype.Cf = function(a, b, c) {
    this.h1[c] = !0;
    0 === c && (this.Kh.De = b,
    this.Kh.wL = a.x,
    this.Kh.xp = a.y,
    this.Kh.rH = a.x,
    this.Kh.sH = a.y)
}
;
gvjs_OJ.prototype.dispatchEvent = function(a, b) {
    this.Vk.dispatchEvent({
        type: a,
        data: b
    })
}
;
gvjs_OJ.prototype.M = function() {
    this.Vk = null;
    gvjs_F.prototype.M.call(this)
}
;
function gvjs_PJ(a, b, c, d) {
    gvjs_F.call(this);
    this.Vk = a;
    this.renderer = b;
    this.zw = c;
    this.Xg = d;
    this.hz = null;
    this.fP = new gvjs_OJ(a);
    gvjs_6x(this, this.fP);
    this.TS = null
}
gvjs_t(gvjs_PJ, gvjs_F);
gvjs_ = gvjs_PJ.prototype;
gvjs_.M = function() {
    this.Vk = null;
    gvjs_E(this.TS);
    gvjs_PJ.G.M.call(this)
}
;
function gvjs_QJ(a) {
    var b = a.renderer.kw;
    gvjs_RJ(a, gvjs_s(function(c, d) {
        this.renderer.ic(b, c, d)
    }, a));
    gvjs_E(a.TS);
    a.TS = new gvjs_TE(a.renderer.getContainer());
    gvjs_G(a.TS, gvjs_Wv, gvjs_s(a.Tqa, a))
}
function gvjs_SJ(a) {
    var b = a.zw.getContainer();
    gvjs_RJ(a, gvjs_s(function(c, d) {
        this.zw.ic(b, c, d)
    }, a))
}
function gvjs_TJ(a) {
    var b = gvjs_Ph();
    gvjs_qga(a, gvjs_s(function(c, d) {
        this.zw.ic(b, c, d)
    }, a))
}
function gvjs_qga(a, b) {
    b(gvjs_jd, gvjs_s(a.Dqa, a));
    b(gvjs_md, gvjs_s(a.Eqa, a))
}
function gvjs_RJ(a, b) {
    b(gvjs_ld, gvjs_s(a.waa, a));
    b(gvjs_kd, gvjs_s(a.Bqa, a));
    b(gvjs_jd, gvjs_s(a.waa, a));
    b(gvjs_md, gvjs_s(a.Aqa, a));
    b(gvjs_gd, gvjs_s(a.vqa, a));
    b(gvjs_Wt, gvjs_s(a.Ipa, a));
    b(gvjs_3t, gvjs_s(a.Rqa, a));
    b(gvjs_du, gvjs_s(a.Qpa, a))
}
gvjs_.Dqa = function(a) {
    var b = gvjs_zz(this.renderer.getContainer());
    a = gvjs_zz(a);
    a.x -= b.x;
    a.y -= b.y;
    b = this.fP;
    b.h1[0] && (b.Kh.rH = a.x,
    b.Kh.sH = a.y,
    b.xQ || b.dispatchEvent(gvjs_Ot, {
        De: b.Kh.De,
        xb: {
            x: b.Kh.wL,
            y: b.Kh.xp
        }
    }),
    b.xQ = !0,
    b.dispatchEvent("chartDrag", {
        De: b.Kh.De,
        xb: {
            x: b.Kh.rH,
            y: b.Kh.sH
        }
    }))
}
;
gvjs_.Eqa = function(a) {
    var b = gvjs_zz(this.renderer.getContainer())
      , c = gvjs_zz(a);
    c.x -= b.x;
    c.y -= b.y;
    b = this.fP;
    a = a.button;
    b.h1[a] = !1;
    0 === a && b.xQ && (b.xQ = !1,
    b.Kh.rH = c.x,
    b.Kh.sH = c.y,
    b.dispatchEvent("chartDragEnd", {
        De: b.Kh.De,
        xb: {
            x: b.Kh.rH,
            y: b.Kh.sH
        }
    }))
}
;
gvjs_.waa = function(a) {
    var b = gvjs_qB(a);
    try {
        gvjs_qB(a)
    } catch (d) {
        return
    }
    if (b) {
        var c = this.Gs(a);
        a.type == gvjs_jd && this.dispatchEvent(gvjs_Qt, {
            xb: b,
            De: c
        });
        c != this.hz && (null != this.hz && gvjs_UJ(this, this.hz),
        this.dispatchEvent("chartHoverIn", {
            xb: b
        }),
        gvjs_VJ(this, "HoverIn", c),
        this.hz = c)
    }
}
;
gvjs_.Bqa = function(a) {
    a = this.Gs(a);
    a == this.hz && (gvjs_UJ(this, a),
    this.hz = null)
}
;
function gvjs_UJ(a, b) {
    a.dispatchEvent("chartHoverOut", null);
    gvjs_VJ(a, "HoverOut", b)
}
gvjs_.Aqa = function(a) {
    var b = gvjs_qB(a);
    b && (a = this.Gs(a),
    this.dispatchEvent("chartMouseUp", {
        xb: b,
        De: a
    }),
    gvjs_VJ(this, "MouseUp", a))
}
;
gvjs_.vqa = function(a) {
    var b = gvjs_qB(a)
      , c = this.Gs(a);
    this.dispatchEvent(gvjs_Pt, {
        xb: b,
        De: c,
        preventDefault: gvjs_s(a.preventDefault, a)
    });
    gvjs_VJ(this, "MouseDown", c);
    this.fP.Cf(b, c, a.button)
}
;
gvjs_.Ipa = function(a) {
    var b = gvjs_qB(a);
    a = this.Gs(a);
    this.dispatchEvent("chartClick", {
        xb: b,
        De: a
    });
    gvjs_VJ(this, "Click", a)
}
;
gvjs_.Rqa = function(a) {
    var b = gvjs_qB(a)
      , c = this.Gs(a);
    this.dispatchEvent(gvjs_Rt, {
        xb: b,
        De: c
    });
    gvjs_VJ(this, "RightClick", c);
    gvjs_Lz(a)
}
;
gvjs_.Qpa = function(a) {
    var b = gvjs_qB(a);
    a = this.Gs(a);
    this.dispatchEvent("chartDblClick", {
        xb: b,
        De: a
    });
    gvjs_VJ(this, "DblClick", a)
}
;
gvjs_.Tqa = function(a) {
    var b = gvjs_qB(a)
      , c = this.Gs(a);
    this.dispatchEvent("chartScroll", {
        xb: b,
        De: c,
        wheelDelta: a.detail,
        preventDefault: gvjs_s(a.preventDefault, a)
    });
    gvjs_VJ(this, "Scroll", c)
}
;
function gvjs_VJ(a, b, c) {
    var d = c.split("#");
    switch (d[0]) {
    case gvjs_Pd:
        var e = c = null
          , f = null;
        a.Xg == gvjs_fw ? c = gvjs_gA(d[1]) : 4 == d.length ? (c = gvjs_gA(d[1]),
        e = gvjs_gA(d[2]),
        f = gvjs_gA(d[3])) : 3 == d.length ? (c = gvjs_gA(d[1]),
        e = gvjs_gA(d[2])) : e = gvjs_gA(d[1]);
        d = {
            Vb: c,
            Kk: e,
            lG: f
        };
        a.dispatchEvent(gvjs_Pd + b, d);
        break;
    case gvjs_Ss:
        d = {
            wy: d[1]
        };
        a.dispatchEvent("actionsMenuEntry" + b, d);
        break;
    case gvjs_zv:
        d = gvjs_gA(d[1]);
        if (0 > d)
            break;
        d = {
            TQ: d
        };
        a.dispatchEvent("legendEntry" + b, d);
        break;
    case gvjs_Av:
        d = {
            hwa: gvjs_gA(d[1]),
            Xi: gvjs_gA(d[2]),
            xF: gvjs_gA(d[3])
        };
        a.dispatchEvent("legendScrollButton" + b, d);
        break;
    case gvjs_uw:
        d = gvjs_gA(d[1]);
        d = {
            TQ: d
        };
        a.dispatchEvent("removeSerieButton" + b, d);
        break;
    default:
        a.v9(b, c)
    }
}
gvjs_.dispatchEvent = function(a, b) {
    this.Vk && this.Vk.dispatchEvent({
        type: a,
        data: b
    })
}
;
function gvjs_WJ(a, b, c, d) {
    gvjs_PJ.call(this, a, b, c, d.Fa);
    this.ha = d;
    this.o2 = gvjs_XJ(this)
}
gvjs_t(gvjs_WJ, gvjs_PJ);
gvjs_WJ.prototype.I5 = function(a) {
    this.ha = a;
    this.o2 = gvjs_XJ(this)
}
;
function gvjs_XJ(a) {
    var b = a.ha;
    if (b.Fa != gvjs_d && b.Fa != gvjs_Dd)
        return {};
    a = {};
    b = b.C;
    for (var c = 0; c < b.length; c++) {
        var d = b[c];
        if (gvjs_YG(d))
            for (var e = d.points, f = 0; f < e.length; f++) {
                var g = e[f];
                if (g && g.ia && !g.$l) {
                    var h = gvjs_4E([gvjs_Np, c, f]);
                    a[h] = {
                        center: g.ia,
                        radius: g.ia && null != g.ia.eT ? g.ia.eT : null != g.eT ? g.eT : d.jea,
                        Vb: c,
                        Kk: f
                    }
                }
            }
    }
    return a
}
gvjs_WJ.prototype.Gs = function(a) {
    var b = this.renderer.xv(a.target)
      , c = gvjs_qB(a);
    if (!c)
        return gvjs_Bb;
    if ((new gvjs_5(this.ha.O.left + 1,this.ha.O.top + 1,this.ha.O.width - 2,this.ha.O.height - 2)).contains(c)) {
        var d = this.ha.Ig
          , e = null;
        if (d.has(gvjs_gp)) {
            e = c.x;
            var f = c.y, g = null, h = Infinity, k;
            for (k in this.o2) {
                var l = this.o2[k]
                  , m = l.center.x
                  , n = l.center.y
                  , p = l.radius;
                m - e <= p && m - e >= -p && n - f <= p && n - f >= -p && (m = (m - e) * (m - e) + (n - f) * (n - f),
                m <= p * p && m <= h && (g = gvjs_4E([gvjs_ow, l.Vb, l.Kk]),
                h = m))
            }
            e = g
        }
        if (null == e && d.has(gvjs_Ht))
            b: {
                d = this.ha.$a;
                for (k = 0; k < d.length; k++)
                    if ((e = d[k].dT) && e.contains(c)) {
                        e = gvjs_4E([gvjs_Jt, k]);
                        break b
                    }
                e = null
            }
        c = e
    } else
        c = null;
    if (a.type == gvjs_kd) {
        a = this.hz;
        if (null == a)
            return b;
        c = c == a ? null : a
    }
    null != c && (gvjs_YJ(this, b) ? (a = gvjs_Be(gvjs_5E, b.split("#")[0]),
    d = gvjs_Be(gvjs_5E, c.split("#")[0]),
    b = a > d ? b : c) : b = c);
    return gvjs_YJ(this, b) ? b : gvjs_Bb
}
;
function gvjs_YJ(a, b) {
    a = a.ha.Ig;
    return a.has(gvjs_Ht) && !a.has(gvjs_gp) ? (b = b.split("#")[0],
    b != gvjs_wb && b != gvjs_yt && b != gvjs_Ct && b != gvjs_Np && b != gvjs_ow && b != gvjs_5w) : !0
}
gvjs_WJ.prototype.v9 = function(a, b) {
    b = b.split("#");
    switch (b[0]) {
    case gvjs_wb:
    case gvjs_yt:
    case gvjs_Ct:
    case gvjs_Np:
    case gvjs_ow:
    case gvjs_5w:
        var c = gvjs_gA(b[1]);
        b = {
            Vb: c,
            Kk: gvjs_gA(b[2])
        };
        this.dispatchEvent(gvjs_gp + a, b);
        break;
    case gvjs_Jt:
        b = gvjs_gA(b[1]);
        b = {
            Vb: null,
            Kk: b
        };
        this.dispatchEvent(gvjs_Ht + a, b);
        break;
    case gvjs_$s:
        c = gvjs_gA(gvjs_Ae(b));
        this.dispatchEvent(gvjs_Zs + a, 3 == b.length ? {
            Vb: null,
            Kk: gvjs_gA(b[1]),
            lG: c
        } : {
            Vb: gvjs_gA(b[1]),
            Kk: gvjs_gA(b[2]),
            lG: c
        });
        break;
    case gvjs_e:
    case gvjs_at:
        c = gvjs_gA(b[1]),
        b = {
            Vb: c,
            Kk: null
        },
        this.dispatchEvent("serie" + a, b)
    }
}
;
function gvjs_ZJ(a) {
    this.Ea = a
}
gvjs_o(gvjs_ZJ, gvjs_qG);
gvjs_ZJ.prototype.getKey = function(a) {
    return this.Ea.dZ(a)
}
;
gvjs_ZJ.prototype.getTitle = function(a) {
    return this.Ea.iP(a)
}
;
gvjs_ZJ.prototype.getContent = function(a, b, c) {
    var d = gvjs_8F(this.Ea, c);
    return gvjs__J(a, d, b.content || "", !0, a.bxa, this.Ea.C[c.Hb])
}
;
function gvjs_0J(a) {
    this.Ea = a
}
gvjs_o(gvjs_0J, gvjs_qG);
gvjs_0J.prototype.getKey = function(a) {
    return a.Hb
}
;
gvjs_0J.prototype.getTitle = function(a) {
    return gvjs_8F(this.Ea, a)
}
;
gvjs_0J.prototype.getContent = function(a, b, c) {
    c = this.Ea.iP(c) || "";
    return [c ? gvjs_hG(b.content || "", a.FG, c, a.Za) : null]
}
;
function gvjs_1J(a, b, c, d) {
    gvjs_pG.call(this, a, b, c, d)
}
gvjs_o(gvjs_1J, gvjs_pG);
gvjs_1J.prototype.N8 = function(a, b, c) {
    var d = a.Ea
      , e = d.C[b];
    c = d.xI(b, c);
    var f = !1
      , g = null
      , h = null
      , k = null != d.kd && d.kd;
    if (d.kd)
        if (f = !0,
        h = [this.r9, this.s9],
        d = e.type,
        d === gvjs_lt)
            g = [{
                color: e.Qg.fill,
                alpha: e.Qg.fillOpacity
            }, {
                color: e.Ih.background.Qg.fill,
                alpha: e.Ih.background.Qg.fillOpacity
            }];
        else if (d === gvjs_Dd)
            d = b % 2 ? b - 1 : b,
            b = a.Ea.C[d],
            d = a.Ea.C[d + 1],
            g = [{
                color: d.Qg.fill,
                alpha: d.Qg.fillOpacity
            }, {
                color: b.Qg.fill,
                alpha: b.Qg.fillOpacity
            }];
        else
            throw Error("Diff chart not supported for the chosen chart type.");
    b = {
        entries: []
    };
    if (c.lines)
        for (c.title && gvjs_2J(this, b, c.title),
        e = 0; e < c.lines.length; e++)
            f = c.lines[e],
            f = (h = f.title) ? gvjs_hG(f.value, this.FG, h, this.Za) : null,
            null != f && b.entries.push(f);
    else
        c.Mx && !c.wi ? (gvjs_2J(this, b, c.Mx),
        gvjs_3J(this, b, c.En, c.content, !0, this.fu, e, f, g, h, k)) : c.En && !c.wi ? gvjs_3J(this, b, c.En, c.content, !0, this.fu, e, !0, g, h, k) : null != c.content && gvjs_3J(this, b, null, c.content, !1, this.fu, e);
    this.ov(b, a.yk);
    return b
}
;
function gvjs_4J(a, b, c, d) {
    var e = b.Ea
      , f = new gvjs_ZJ(e)
      , g = new gvjs_0J(e)
      , h = null;
    d == gvjs_Ht ? h = f : d == gvjs_Mw && (h = g);
    if (h)
        var k = h.aggregate(c);
    else {
        d = f.aggregate(c);
        var l = g.aggregate(c);
        h = g;
        k = l;
        1 == d.order.length && 1 < l.order.length && (h = f,
        k = d)
    }
    var m = {
        entries: []
    };
    gvjs_u(k.order, function(n) {
        gvjs_2J(this, m, (k.$w[n] || "").toString());
        gvjs_u(k.index[n], function(p) {
            var q = e.xI(p.Hb, p.Eb);
            q.wi ? gvjs_3J(this, m, null, q.content, !1, this.fu, e.C[p.Hb]) : m.entries.push.apply(m.entries, h.getContent(this, q, p))
        }, this)
    }, a);
    a.ov(m, b.yk, 0 < c.length);
    return m
}
gvjs_1J.prototype.O8 = function(a, b) {
    var c = a.Ea
      , d = c.C[b]
      , e = d.wd
      , f = null
      , g = null
      , h = null != c.kd && c.kd;
    c.kd && (f = c.C.length,
    f = (b + f / c.pie.Gd.length) % f,
    g = c.C[f],
    c = {
        color: d.brush.fill,
        alpha: d.brush.fillOpacity
    },
    g = {
        color: g.brush.fill,
        alpha: g.brush.fillOpacity
    },
    f = b > f ? [c, g] : [g, c],
    g = [this.r9, this.s9]);
    b = {
        entries: []
    };
    e.En ? gvjs_3J(this, b, e.En, e.content, !0, this.fu, d, !0, f, g, h) : gvjs_3J(this, b, null, e.content, !1, this.fu, d);
    this.ov(b, a.yk);
    return b
}
;
function gvjs_rga(a, b, c) {
    var d = b.Ea
      , e = {
        entries: []
    };
    gvjs_u(c, function(f) {
        f = d.C[f];
        var g = f.wd;
        g.En ? gvjs_3J(a, e, g.En, g.content, !0, a.fu, f, !0) : gvjs_3J(a, e, null, g.content, !1, a.fu, f)
    });
    a.ov(e, b.yk);
    return e
}
gvjs_1J.prototype.L8 = function(a, b) {
    var c = a.Ea
      , d = c.$a[b].wd
      , e = !1
      , f = {
        entries: []
    };
    if (d && d.content)
        gvjs_3J(this, f, null, d.content, !1, !1);
    else {
        var g = 0
          , h = 1
          , k = c.C.length;
        gvjs_2G(c) && (g = c.C.length - 1,
        k = h = -1);
        for (var l = null; g != k; g += h) {
            var m = c.C[g];
            if (m.NT) {
                d = gvjs_7F(c, g, b);
                if (l != m.We) {
                    l = m.We;
                    var n = c.$a[b].$w[l];
                    gvjs_jf(gvjs_gg(n)) || gvjs_2J(this, f, n)
                }
                m.points[d] && m.points[d].wd && m.points[d].wd.content && (d = m.points[d].wd,
                gvjs_3J(this, f, d.En, d.content, !0, this.fu, m, void 0, void 0, void 0, void 0, d.wi && d.Nh),
                e = !0)
            }
        }
    }
    null != a.yk && 0 < a.yk.length && (e = !0);
    this.ov(f, a.yk);
    return e || this.cxa ? f : null
}
;
function gvjs_2J(a, b, c) {
    a = gvjs_hG(c, a.FG);
    b.entries.push(a)
}
function gvjs__J(a, b, c, d, e, f, g, h, k, l, m) {
    d = d ? a.FG : a.Za;
    c = c.split("\n");
    g = (null != g ? g : !1) || null != h;
    var n = e ? f.color.color : null;
    n = g && null != b ? gvjs_hG(b, a.Za, null, null, n, f && f.dH) : gvjs_hG(c[0], d, b, a.Za, n, f && f.dH, null, m);
    a = [n];
    for (g = g ? 0 : 1; g < c.length; g++)
        n = null != h ? h[g].color : e ? gvjs_f : null,
        b = null != h ? h[g].alpha : null,
        k = null != k ? k[g] : null,
        n = gvjs_hG(c[g], d, null, null, n, b, k, m),
        n.gG = l,
        a.push(n);
    return a
}
function gvjs_3J(a, b, c, d, e, f, g, h, k, l, m, n) {
    b.entries.push.apply(b.entries, gvjs__J(a, c, d, e, f, g, h, k, l, m, n))
}
gvjs_1J.prototype.ov = function(a, b, c) {
    b && 0 !== b.length && ((void 0 == c || c) && a.entries.push(gvjs_jG()),
    gvjs_Me(a.entries, b))
}
;
function gvjs_5J(a, b, c) {
    gvjs_pG.call(this, a, b, c, void 0);
    this.nha = this.FG;
    this.pU = gvjs_x(this.Za);
    this.pU.color = gvjs_pr;
    this.pU.fontSize -= 2
}
gvjs_o(gvjs_5J, gvjs_1J);
gvjs_5J.prototype.N8 = function(a, b, c) {
    b = a.Ea.C[b];
    a = b.points[c].wd;
    c = [];
    b.GF || (b = gvjs_hG(b.title || "", this.nha),
    c.push(b));
    b = gvjs_hG(a.content, this.nha);
    c.push(b);
    a = gvjs_hG(a.Mx, this.pU);
    c.push(a);
    return {
        entries: c
    }
}
;
gvjs_5J.prototype.O8 = function() {
    return {
        entries: []
    }
}
;
gvjs_5J.prototype.L8 = function() {
    return {
        entries: []
    }
}
;
function gvjs_sga(a, b, c) {
    this.es = b;
    this.af = new gvjs_B(0,c.width,c.height,0);
    gvjs_K(a, ["tooltip.ignoreBounds.left", gvjs_mx], !1) ? this.af.left = -Infinity : this.af.left -= gvjs_L(a, ["tooltip.bounds.left", gvjs_lx], 0);
    gvjs_K(a, ["tooltip.ignoreBounds.top", gvjs_mx], !1) ? this.af.top = -Infinity : this.af.top -= gvjs_L(a, ["tooltip.bounds.top", gvjs_lx], 0);
    gvjs_K(a, ["tooltip.ignoreBounds.right", gvjs_mx], !1) ? this.af.right = Infinity : this.af.right += gvjs_L(a, ["tooltip.bounds.right", gvjs_lx], 0);
    gvjs_K(a, ["tooltip.ignoreBounds.bottom", gvjs_mx], !1) ? this.af.bottom = Infinity : this.af.bottom += gvjs_L(a, ["tooltip.bounds.bottom", gvjs_lx], 0);
    this.gy = null;
    c = a.Aa("tooltip.pivot.x");
    var d = a.Aa("tooltip.pivot.y");
    null != c && typeof c === gvjs_g && isFinite(c) && null != d && typeof d === gvjs_g && isFinite(d) && (this.gy = new gvjs_z(c,d));
    b = null != b.le && 0 < b.le.getEntries().length ? gvjs_ut : gvjs_xu;
    this.u5 = gvjs_J(a, gvjs_qx, b, gvjs_mC)
}
function gvjs_6J(a) {
    if (a.Fa == gvjs_fw) {
        var b = a.pie.center;
        return new gvjs_z(b.x,b.y)
    }
    b = gvjs_Oy(a.jd);
    a = gvjs_Oy(a.wc);
    return new gvjs_z(null != b.baseline ? b.baseline.Na : Math.min(b.Pf, b.ef),null != a.baseline ? a.baseline.Na : Math.max(a.Pf, a.ef))
}
function gvjs_tga(a, b) {
    a.af = b
}
function gvjs_7J(a, b, c) {
    var d = b.ia;
    a = gvjs_6J(a);
    b = 1 + Math.ceil(gvjs_1G(b, c) / Math.sqrt(2));
    return new gvjs_z(d.x + (d.x >= a.x ? b : -b),d.y + (d.y <= a.y ? -b : b))
}
function gvjs_8J(a, b) {
    var c = gvjs_eA(a.pie.center, gvjs_3I(((b.rt ? 45 : (b.de + b.vd) / 2) / 180 - .5) * Math.PI, a.pie.radiusX, a.pie.radiusY));
    b = new gvjs_z(c.x + b.offset.x,c.y + b.offset.y);
    b.x = gvjs_0g(b.x, 0, a.width);
    b.y = gvjs_0g(b.y, 0, a.height);
    return b
}
function gvjs_9J(a) {
    var b = a.anchor ? a.anchor : new gvjs_z(0,0)
      , c = a.lines[0]
      , d = a.ja.fontSize;
    return 270 == a.angle ? new gvjs_z(b.x + c.x + d,b.y + c.y - c.length / 2) : new gvjs_z(b.x + c.x + c.length / 2,b.y + c.y - d)
}
function gvjs_$J(a, b, c) {
    var d = a.C[b]
      , e = d.type;
    c = gvjs_7F(a, b, c);
    b = d.points[c];
    if (!b)
        return new gvjs_z(0,0);
    switch (a.Fa) {
    case gvjs_d:
    case gvjs_4u:
        switch (e) {
        case gvjs_lt:
        case gvjs_4w:
            return d = b.ia.bar || b.ia,
            e = gvjs_6J(a),
            d = new gvjs_z(d.left + (d.left < e.x ? 0 : d.width),d.top + (d.top < e.y ? 0 : d.height)),
            gvjs_aK(a, d),
            d;
        case gvjs_e:
        case gvjs_at:
        case gvjs_Dd:
            return gvjs_7J(a, b, d);
        case gvjs_Ft:
            return d = b.ia.rect,
            e = gvjs_6J(a),
            d = new gvjs_z(d.left + d.width > e.x ? d.left + d.width : d.left,d.top < e.y ? d.top : d.top + d.height),
            gvjs_aK(a, d),
            d
        }
    case gvjs_Dd:
        return gvjs_7J(a, b, d);
    case gvjs_yt:
        e = b.ia;
        d = gvjs_7J(a, b, d);
        if (d.x < a.O.left || d.x > a.O.right)
            d.x += 2 * (e.x - d.x);
        if (d.y < a.O.top || d.y > a.O.bottom)
            d.y += 2 * (e.y - d.y);
        return d
    }
    return new gvjs_z(0,0)
}
function gvjs_aK(a, b) {
    a = a.O;
    b.x = gvjs_0g(b.x, a.left, a.right);
    b.y = gvjs_0g(b.y, a.top, a.bottom)
}
function gvjs_bK(a, b, c, d) {
    var e = null
      , f = null
      , g = gvjs_Oy(b.jd)
      , h = gvjs_Oy(b.wc)
      , k = g.ro
      , l = h.ro
      , m = d;
    b.orientation && b.orientation !== gvjs_S ? (l = -l,
    h.type === gvjs_Vd && (m = b.$a[d].data),
    f = h.position.hf(m)) : (g.type === gvjs_Vd && (m = b.$a[d].data),
    e = g.position.hf(m));
    a = a.es.Za.fontSize;
    c.x = null === e ? c.x : e;
    c.y = null === f ? c.y : f;
    e = c.x - k * a;
    f = c.y + l * a;
    return new gvjs_z(e,f)
}
function gvjs_cK(a, b) {
    a = gvjs_eA(a.pie.center, gvjs_3I(((b.rt ? 45 : (b.de + b.vd) / 2) / 180 - .5) * Math.PI, a.pie.radiusX - .1, a.pie.radiusY - .1));
    return new gvjs_z(a.x + b.offset.x,a.y + b.offset.y)
}
function gvjs_dK(a) {
    var b = a.anchor ? a.anchor : new gvjs_z(0,0)
      , c = a.lines[0]
      , d = a.ja.fontSize;
    return 270 == a.angle ? new gvjs_z(b.x + c.x + d / 2,b.y + c.y) : new gvjs_z(b.x + c.x,b.y + c.y - d / 2)
}
function gvjs_eK(a, b, c) {
    c = gvjs_7F(a, b, c);
    var d = a.C[b];
    b = d.type;
    c = d.points[c].ia;
    if (b == gvjs_lt || b == gvjs_4w || b == gvjs_Ft) {
        var e = c.bar || c.rect || c;
        c = e.left;
        b = e.width;
        d = e.top;
        e = e.height;
        var f = d + e
          , g = gvjs_6J(a);
        a = a.orientation == gvjs_S ? f > g.y ? new gvjs_z(c + b / 2,f - .1) : new gvjs_z(c + b / 2,d + .1) : c < g.x ? new gvjs_z(c + .1,d + e / 2) : new gvjs_z(c + b - .1,d + e / 2)
    } else
        a = new gvjs_z(c.x,c.y);
    return a
}
function gvjs_fK(a, b, c, d, e, f) {
    if (null !== c && null !== d && null !== e) {
        var g = b.Ea
          , h = g.C[c].points[d].Bc.labels[e]
          , k = h.wd;
        k ? (f = gvjs_9J(h),
        h = gvjs_dK(h),
        k.Nh && k.wi ? (b = gvjs_OA(k.content || ""),
        a = gvjs_gK(a, b, f, h)) : (k = a.es,
        d = {
            entries: [gvjs_hG(b.Ea.C[c].points[d].Bc.labels[e].wd.content, k.Za)]
        },
        k.ov(d, b.yk),
        a = gvjs_kG(d, g.sc, !1, f, a.af, h, void 0, g.$f, g.bw, g.ax))) : a = null
    } else if (null !== c && null !== d)
        if (g = b.Ea,
        g.C[c].NT)
            if (e = gvjs_$J(g, c, d),
            f = a.gy ? gvjs_ez(e, a.gy) : gvjs_eK(g, c, d),
            h = g.C[c].points[d].wd)
                if (typeof h.T8 === gvjs_d) {
                    b = h.T8(g, c, d);
                    d = null;
                    b instanceof gvjs_Zf ? d = b : typeof b === gvjs_l && (d = (new gvjs_wm).cd().sanitize(b));
                    if (!d)
                        throw Error("Custom calc function for tooltip content should produce string literal or safe HTML.");
                    a = gvjs_gK(a, d, e, f)
                } else
                    h.Nh && h.wi ? (b = gvjs_OA(h.content || ""),
                    a = gvjs_gK(a, b, e, f)) : (b = a.es.N8(b, c, d),
                    a = gvjs_kG(b, g.sc, !0, e, a.af, f, void 0, g.$f, g.bw, g.ax));
            else
                a = null;
        else
            a = null;
    else
        null !== c && null === d ? (e = b.Ea,
        f = e.C[c],
        null == f.offset ? a = null : (d = gvjs_8J(e, f),
        f = gvjs_cK(e, f),
        g = e.C[c].wd,
        g.Nh && g.wi ? (b = gvjs_OA(g.content || ""),
        a = gvjs_gK(a, b, d, f)) : (b = a.es.O8(b, c),
        a = gvjs_kG(b, e.sc, !0, d, a.af, f, void 0, e.$f, e.bw, e.ax)))) : null === c && null !== d && null !== e ? (f = b.Ea,
        g = f.$a[d].Bc.labels[e],
        (h = g.wd) ? (c = gvjs_9J(g),
        g = gvjs_dK(g),
        h.Nh && h.wi ? (b = gvjs_OA(h.content || ""),
        a = gvjs_gK(a, b, c, g)) : (h = a.es,
        d = b.Ea.$a[d],
        d = {
            entries: [gvjs_hG((d.Bc && d.Bc.labels[e]).wd.content, h.Za)]
        },
        0 < b.yk.length && h.ov(d, b.yk),
        a = gvjs_kG(d, f.sc, !1, c, a.af, g, void 0, f.$f, f.bw, f.ax))) : a = null) : null === c && null !== d ? (c = b.Ea,
        e = f.clone(),
        f = gvjs_bK(a, c, e, d),
        e = a.gy ? gvjs_ez(f, a.gy) : e,
        (g = c.$a[d].wd) && g.Nh && g.wi ? (b = gvjs_OA(g.content),
        a = gvjs_gK(a, b, f, e)) : (b = a.es.L8(b, d),
        a = null === b ? null : gvjs_kG(b, c.sc, !1, f, a.af, e, void 0, c.$f, c.bw, c.ax))) : a = null;
    return a
}
function gvjs_uga(a, b, c, d, e) {
    var f = b.Ea;
    d = d.clone();
    var g = gvjs_bK(a, f, d, c[c.length - 1]);
    d = a.gy ? gvjs_ez(g, a.gy) : d;
    var h = [];
    gvjs_u(c, function(k) {
        gvjs_u(f.C, function(l, m) {
            h.push({
                Hb: m,
                Eb: k
            })
        })
    });
    b = gvjs_4J(a.es, b, h, e);
    return null === b ? null : gvjs_kG(b, f.sc, !1, g, a.af, d, void 0, f.$f, f.bw, f.ax)
}
function gvjs_gK(a, b, c, d) {
    return {
        html: gvjs_5f(gvjs_Ob, {
            "class": gvjs_Nu
        }, b),
        hO: !0,
        pivot: d,
        anchor: c,
        HG: a.af,
        spacing: 20,
        margin: 5
    }
}
;function gvjs_hK(a, b, c, d, e, f) {
    this.le = f;
    d == gvjs_lu || this.le ? null != this.le && this.le.updateOptions(a, c) : this.le = new gvjs_nG(a,c);
    c = d == gvjs_lu ? new gvjs_5J(a,c,e) : new gvjs_1J(a,c,e,this.le);
    this.Cp = new gvjs_sga(a,c,b)
}
function gvjs_iK(a, b, c) {
    var d = {};
    if (null != c.legend.Xi) {
        d.legend = d.legend || {};
        var e = b.legend
          , f = c.legend.Xi;
        d.legend.ev = e.Pe[f];
        var g = f + 1 + "/" + e.Pe.length
          , h = e.$K.w2
          , k = 0 < f;
        e = e.$K.s1;
        f = f < b.legend.Pe.length - 1;
        d.legend.$K = {
            w2: {
                brush: k ? h.Rb.active : h.Rb.mQ,
                active: k
            },
            s1: {
                brush: f ? e.Rb.active : e.Rb.mQ,
                active: f
            },
            a2: {
                text: g,
                lines: {
                    0: {
                        text: g
                    }
                }
            }
        }
    }
    a.Us(b, c, d);
    return d
}
gvjs_hK.prototype.xh = function(a) {
    this.le && gvjs_oG(this.le, a)
}
;
gvjs_hK.prototype.ng = function(a) {
    if (this.le)
        return this.le.ng(a)
}
;
gvjs_hK.prototype.th = function(a) {
    this.le && this.le.removeEntry(a)
}
;
function gvjs_jK(a, b, c, d, e, f, g) {
    gvjs_hK.call(this, a, b, c, d, e, g);
    this.dO = a.cb("crosshair.trigger", gvjs_$da);
    this.jma = gvjs_J(a, ["crosshair.selected.orientation", gvjs_6t], gvjs_ut, gvjs_nC);
    this.gma = gvjs_J(a, ["crosshair.focused.orientation", gvjs_6t], gvjs_ut, gvjs_nC);
    this.hma = a.mz(["crosshair.selected.color", gvjs_4t]);
    this.ema = a.mz(["crosshair.focused.color", gvjs_4t]);
    this.ima = gvjs_ny(a, ["crosshair.selected.opacity", gvjs_5t], 1);
    this.fma = gvjs_ny(a, ["crosshair.focused.opacity", gvjs_5t], 1);
    this.KV = gvjs_J(a, "aggregationTarget", gvjs_f, gvjs_cea);
    this.jQ = !0
}
gvjs_o(gvjs_jK, gvjs_hK);
gvjs_jK.prototype.Us = function(a, b, c) {
    this.jQ = !0;
    switch (a.qz) {
    case gvjs_eu:
        this.QX(a, b, c);
        break;
    case gvjs_lu:
        gvjs_vga(this, a, b, c)
    }
}
;
gvjs_jK.prototype.xY = function(a, b) {
    return a.equals(b, this.jQ)
}
;
function gvjs_wga(a) {
    return gvjs_Fe(a.C, function(b) {
        return b.Yg
    })
}
function gvjs_kK(a, b, c) {
    a.C = a.C || {};
    a = a.C;
    a[b] = a[b] || {};
    b = a[b];
    b.points = b.points || {};
    b = b.points;
    b[c] = b[c] || {};
    return b[c]
}
function gvjs_lK(a, b, c) {
    if (null != b)
        return a = gvjs_kK(a, b, c),
        a.Bc = a.Bc || {},
        a.Bc;
    a = gvjs_mK(a, c);
    a.Bc = a.Bc || {};
    return a.Bc
}
function gvjs_nK(a, b) {
    a.C = a.C || {};
    a = a.C;
    a[b] = a[b] || {};
    return a[b]
}
function gvjs_mK(a, b) {
    a.$a = a.$a || {};
    a = a.$a;
    a[b] = a[b] || {};
    return a[b]
}
function gvjs_oK(a, b) {
    a.legend = a.legend || {};
    a = a.legend;
    a.ev = a.ev || {};
    a = a.ev;
    a[b] = a[b] || {};
    return a[b]
}
gvjs_jK.prototype.QX = function(a, b, c) {
    var d = {
        Ea: a,
        yk: this.le.getEntries(),
        Yv: c,
        zk: b.gi
    }
      , e = b.gi.focused.wy;
    null != e && (b.gi.focused.action = this.le.ng(e).action);
    e = this.Cp.u5;
    var f = e == gvjs_Jw || e == gvjs_ut;
    e = e == gvjs_xu || e == gvjs_ut;
    for (var g = this.KV != gvjs_f, h = this.le && 0 < d.yk.length, k = gvjs_co(b.selected), l = 1 < k.length && (g || h), m = 0; m < k.length; ++m) {
        var n = k[m]
          , p = n.column
          , q = a.Jk[p]
          , r = q.Vb;
        if (n = a.lP({
            column: p,
            row: n.row
        }))
            switch (q.role) {
            case gvjs_$t:
                gvjs_pK(this, a, n.Hb, n.Eb, c);
                f && !l && gvjs_qK(this, d, n.Hb, n.Eb);
                break;
            case gvjs_Zs:
                if (null != r ? a.C[r].Yg : a.Yg)
                    q = q.wE,
                    null != q && (gvjs_xga(n.Hb, n.Eb, q, c),
                    f && gvjs_rK(this, d, n.Hb, n.Eb, q))
            }
    }
    f && l && !a.fz && (k = gvjs_De(gvjs_v(k, function(t) {
        return a.lP({
            column: t.column,
            row: t.row
        })
    }), function(t) {
        return null != t
    }),
    0 < k.length && gvjs_yga(this, d, g ? k : [], k[k.length - 1]));
    m = gvjs_ao(b.selected, gvjs_Fb);
    for (k = 0; k < m.length; ++k)
        l = a.Jk[m[k]],
        null != l && (l = l.Vb,
        null != l && gvjs_sK(this, a, l, c));
    m = a.Fa === gvjs_yt;
    q = gvjs_bo(b.selected);
    g = 1 < q.length && (g || h);
    for (k = 0; k < q.length; ++k)
        h = a.Ds[q[k]],
        m ? (l = 0,
        gvjs_pK(this, a, l, h, c),
        f && !g && gvjs_qK(this, d, l, h)) : (gvjs_zga(this, a, h, c),
        f && !g && gvjs_tK(this, d, b.cursor.p2, h));
    g && (m ? gvjs_qK(this, d, 0, a.Ds[q[q.length - 1]]) : f && (f = gvjs_v(q, function(t) {
        return a.Ds[t]
    }),
    0 < f.length && gvjs_Aga(this, d, b.cursor.p2, f)));
    f = b.focused.Hb;
    g = b.focused.datum;
    null != g ? a.C[f].Yg && (gvjs_uK(this, a, f, g, c),
    e && gvjs_qK(this, d, f, g),
    gvjs_Bga(a, f, g, c)) : null != f && a.C[f].Yg && gvjs_vK(this, a, f, c);
    f = b.legend.focused.Xc;
    null != f && a.C[f].Yg && gvjs_vK(this, a, f, c);
    f = b.focused.Eb;
    null != f && a.$a[f] && (gvjs_Cga(this, a, f, c),
    e && gvjs_wga(d.Ea) && (gvjs_tK(this, d, b.cursor.position, f),
    this.jQ = !1));
    if (f = b.annotations.dI)
        f = gvjs_lK(c, f.Vb, f.oO),
        f.Rp = f.Rp || {},
        f.Rp.Eba = !0;
    (f = b.annotations.focused) && e && (g = a.Jk[f.column],
    e = g.Vb,
    f = a.Ds[f.row],
    g = g.wE,
    (null != e ? a.C[e].Yg : a.Yg) && gvjs_rK(this, d, e, f, g));
    if (b = b.Ii)
        c.Ii = b
}
;
function gvjs_uK(a, b, c, d, e) {
    var f = b.C[c]
      , g = f.points[d];
    if (!gvjs_XG(g) && g.ia && (!gvjs_YG(f) || 0 != f.lineWidth || gvjs_ZG(g, f))) {
        var h = f.type == gvjs_lt ? gvjs_Dga : gvjs_Ega;
        e = gvjs_kK(e, c, d);
        e.Ko = {};
        c = e.Ko;
        c.levels = [];
        for (d = 0; d < h.length; d++) {
            var k = new gvjs_3({
                fill: gvjs_f,
                stroke: gvjs_rt,
                strokeOpacity: h[d],
                strokeWidth: 1
            });
            c.levels.push({
                brush: k
            })
        }
        switch (f.type) {
        case gvjs_lt:
        case gvjs_4w:
        case gvjs_Ft:
            a = g.ia.bar || g.ia.rect || g.ia;
            b = new gvjs_5(a.left,a.top,a.width,a.height);
            for (d = 0; d < h.length; d++)
                a = c.levels[d].brush.strokeWidth,
                c.levels[d].rect = new gvjs_5(b.left - a / 2,b.top - a / 2,b.width + a,b.height + a),
                b.left -= a,
                b.top -= a,
                b.width += 2 * a,
                b.height += 2 * a;
            break;
        case gvjs_e:
        case gvjs_at:
        case gvjs_Dd:
        case gvjs_At:
            e.visible = !0;
            c.x = g.ia.x;
            c.y = g.ia.y;
            if (a.dO === gvjs_ut || a.dO === gvjs_xu)
                d = gvjs_WG(g, f),
                d = gvjs_9z(a.ema || d.fill, 1, !1, a.fma),
                gvjs_wK(b, g, e, d, a.gma);
            e.nj ? (a = e.nj,
            b = a.radius + a.brush.strokeWidth / 2) : b = gvjs_1G(g, f);
            for (d = 0; d < h.length; d++)
                a = c.levels[d].brush.strokeWidth,
                c.levels[d].radius = b + a / 2,
                b += a
        }
    }
}
function gvjs_vK(a, b, c, d) {
    var e = b.C[c];
    if (gvjs_YG(e) && 0 < e.lineWidth) {
        var f = gvjs_nK(d, c);
        f.Ko = {};
        f = f.Ko;
        f.levels = [];
        var g = e.type == gvjs_at ? b.vp !== gvjs_f ? gvjs_4G(e) : gvjs_3G(e, !1) : gvjs_3G(e, b.Zj);
        g = gvjs_7B(g);
        for (var h = e.Oc.strokeWidth / 2, k = 0; k < gvjs_xK.length; k++) {
            var l = new gvjs_3({
                fill: gvjs_f,
                stroke: gvjs_rt,
                strokeOpacity: gvjs_xK[k],
                strokeWidth: 1
            })
              , m = gvjs_cC(g, h + l.strokeWidth / 2);
            f.levels.push({
                brush: l,
                path: m
            });
            h += l.strokeWidth
        }
    }
    f = (f = (f = d.C) && f[c]) && f.points;
    for (g = 0; g < e.points.length; ++g)
        h = e.points[g],
        gvjs_XG(h) || (gvjs_ZG(h, e) || f && f[g] && f[g].visible) && gvjs_uK(a, b, c, g, d);
    b.kd && e.type === gvjs_Dd && !a.fL(e.columns) && gvjs_vK(a, b, c - 1, d)
}
gvjs_jK.prototype.fL = function(a) {
    a = a[gvjs_3v];
    return null != a && 0 < a.length
}
;
function gvjs_Cga(a, b, c, d) {
    for (var e = b.C, f = 0; f < e.length; ++f) {
        var g = gvjs_7F(b, f, c);
        b.C[f].Yg && null != g && gvjs_uK(a, b, f, g, d)
    }
}
function gvjs_pK(a, b, c, d, e) {
    var f = b.C[c]
      , g = f.points[d];
    if (!gvjs_XG(g) && g.ia && (!gvjs_YG(f) || 0 != f.lineWidth || gvjs_ZG(g, f))) {
        var h = gvjs_WG(g, f);
        c = gvjs_kK(e, c, d);
        c.nj = {};
        d = c.nj;
        var k = b.SM;
        e = 1;
        null == k && (k = gvjs_Ox,
        e = 0);
        switch (f.type) {
        case gvjs_lt:
        case gvjs_4w:
        case gvjs_Ft:
            e = 1;
            d.brush = new gvjs_3(gvjs_iy);
            d.brush.rd(k);
            f.type == gvjs_Ft && (a = gvjs_vj(gvjs_qj(h.fill).hex),
            b = gvjs_vj(gvjs_qj(k).hex),
            f = gvjs_vj(gvjs_qj(g.yG.fill).hex),
            d.brush.rd(gvjs_uj(gvjs_4z(f, [a, b]))));
            gvjs_ay(d.brush, e);
            d.brush.hl(1);
            g = g.ia.bar || g.ia.rect || g.ia;
            h = h.strokeWidth;
            a = d.brush.strokeWidth;
            d.rect = new gvjs_5(g.left + h / 2 + 1.5 + a / 2,g.top + h / 2 + 1.5 + a / 2,g.width - (h + 3 + a),g.height - (h + 3 + a));
            (0 >= d.rect.width || 0 >= d.rect.height) && delete c.nj;
            break;
        case gvjs_e:
        case gvjs_at:
        case gvjs_Dd:
        case gvjs_At:
            c.visible = !0;
            d.x = g.ia.x;
            d.y = g.ia.y;
            if (a.dO === gvjs_ut || a.dO === gvjs_Jw) {
                var l = gvjs_9z(a.hma || h.fill, 1, !1, a.ima);
                gvjs_wK(b, g, c, l, a.jma)
            }
            d.brush = new gvjs_3({
                fill: k,
                fillOpacity: e,
                stroke: h.fill,
                strokeWidth: 1
            });
            d.radius = gvjs_1G(g, f) + 1.5 + d.brush.strokeWidth / 2
        }
    }
}
function gvjs_wK(a, b, c, d, e) {
    c = c.P8 || (c.P8 = {});
    c.x = b.ia.x;
    c.y = b.ia.y;
    c.brush = d;
    b = new gvjs_z(a.O.left,c.y);
    d = new gvjs_z(a.O.right,c.y);
    var f = new gvjs_z(c.x,a.O.top);
    a = new gvjs_z(c.x,a.O.bottom);
    c.path = c.path || new gvjs_SA;
    if (e === gvjs_ut || e === gvjs_U)
        for (f = gvjs_UA([f, a]),
        a = 0; a < f.vc.length - 1; a++)
            c.path.Cj(f.vc[a]);
    if (e === gvjs_ut || e === gvjs_S)
        for (e = gvjs_UA([b, d]),
        a = 0; a < e.vc.length - 1; a++)
            c.path.Cj(e.vc[a]);
    c.path.close()
}
function gvjs_sK(a, b, c, d) {
    var e = b.C[c];
    if ((e.type == gvjs_e || e.type == gvjs_at || e.type == gvjs_Dd) && 0 < e.lineWidth) {
        var f = gvjs_nK(d, c);
        f.nj = {};
        f = f.nj;
        var g = e.type == gvjs_at ? b.vp !== gvjs_f ? gvjs_4G(e) : gvjs_3G(e, !1) : gvjs_3G(e, b.Zj);
        g = gvjs_7B(g);
        f.brush = new gvjs_3({
            stroke: e.Oc.Uj(),
            strokeWidth: Math.min(1, e.Oc.strokeWidth / 2)
        });
        f.path = gvjs_cC(g, -(e.Oc.strokeWidth / 2 + 2 + f.brush.strokeWidth / 2))
    }
    for (f = 0; f < e.points.length; ++f)
        g = e.points[f],
        gvjs_XG(g) || (gvjs_ZG(g, e) || gvjs__G(e, f) && !b.Zj) && gvjs_pK(a, b, c, f, d);
    b.kd && e.type === gvjs_Dd && !a.fL(e.columns) && gvjs_sK(a, b, c - 1, d)
}
function gvjs_zga(a, b, c, d) {
    for (var e = b.C, f = 0; f < e.length; ++f) {
        var g = gvjs_7F(b, f, c);
        null != g && gvjs_pK(a, b, f, g, d)
    }
}
function gvjs_yK(a, b, c, d) {
    c = gvjs_kK(b.Yv, c.Hb, c.Eb);
    var e = null != b.zk;
    c.tooltip = d;
    e && a.le.Us(d, b.zk, c.tooltip)
}
function gvjs_qK(a, b, c, d) {
    var e = gvjs_fK(a.Cp, b, c, d, null);
    null != e && gvjs_yK(a, b, {
        Hb: c,
        Eb: d
    }, e)
}
function gvjs_yga(a, b, c, d) {
    var e = a.Cp;
    var f = a.KV
      , g = b.Ea
      , h = gvjs_$J(g, d.Hb, d.Eb)
      , k = gvjs_eK(g, d.Hb, d.Eb);
    c = gvjs_4J(e.es, b, c, f);
    e = gvjs_kG(c, g.sc, !0, h, e.af, k, void 0, g.$f, g.bw, g.ax);
    gvjs_yK(a, b, d, e)
}
function gvjs_Aga(a, b, c, d) {
    if (c) {
        c = gvjs_uga(a.Cp, b, d, c, a.KV);
        d = gvjs_mK(b.Yv, d[d.length - 1]);
        var e = null != b.zk;
        d.tooltip = c;
        e && a.le.Us(c, b.zk, d.tooltip)
    }
}
function gvjs_tK(a, b, c, d) {
    if (c) {
        var e = gvjs_mK(b.Yv, d)
          , f = null != b.zk;
        c = gvjs_fK(a.Cp, b, null, d, null, c);
        null !== c && (e.tooltip = c,
        f && a.le.Us(c, b.zk, e.tooltip))
    }
}
function gvjs_rK(a, b, c, d, e) {
    if (null != c && null != e) {
        var f = gvjs_lK(b.Yv, c, d);
        f.labels = f.labels || {};
        f = f.labels;
        f[e] = f[e] || {};
        f = f[e];
        var g = null != b.zk;
        c = gvjs_fK(a.Cp, b, c, d, e);
        f.xa = c;
        g && c && a.le.Us(c, b.zk, f.xa)
    }
}
function gvjs_Bga(a, b, c, d) {
    if (a.Vi) {
        var e = a.Vi;
        a = gvjs_0H(e.scale, e.SH, [{
            value: a.C[b].points[c].Kf.color
        }], a.sc);
        d.Vi = {
            definition: a
        }
    }
}
function gvjs_xga(a, b, c, d) {
    a = gvjs_lK(d, a, b);
    a.labels = a.labels || {};
    a = a.labels;
    a[c] = a[c] || {};
    c = a[c];
    c.ja = c.ja || {};
    c.ja.bold = !0
}
function gvjs_vga(a, b, c, d) {
    var e = {
        Ea: b,
        yk: [],
        Yv: d,
        zk: null
    }
      , f = c.focused.Hb
      , g = c.focused.datum;
    b.legend && gvjs_tga(a.Cp, new gvjs_B(0,b.legend.area.left,b.height,0));
    var h = a.Cp.u5;
    if (null != f && null == g) {
        var k = c.cursor.position.x
          , l = b.C[f].points;
        g = gvjs_De(l, function(p) {
            return null != p
        });
        for (var m = 0; m < g.length && g[m].ia.x < k; )
            m++;
        0 == m ? g = 0 : m == g.length ? g = g.length - 1 : (k = k < gvjs_bz(g[m - 1].ia.x, g[m].ia.x) ? m - 1 : m,
        g = gvjs_Be(l, g[k]));
        a.jQ = !1
    }
    l = null;
    if (null != g)
        for (l = gvjs_kK(d, f, g),
        l.visible = !0,
        h == gvjs_xu && gvjs_qK(a, e, f, g),
        b.legend && (l = gvjs_oK(d, f),
        l.Rg = {
            isVisible: b.Ofa
        }),
        l = 0; l < b.C.length; l++)
            l != f && (b.legend && (g = gvjs_oK(d, l),
            g.Da = {
                ja: {
                    color: gvjs_ur
                }
            }),
            g = gvjs_nK(d, l),
            k = b.C[l],
            g.Oc = k.Oc.clone(),
            gvjs_ay(g.Oc, .3));
    if (f = c.annotations.dI)
        f = gvjs_lK(d, f.Vb, f.oO),
        f.Rp = f.Rp || {},
        f.Rp.Eba = !0;
    if (g = c.annotations.focused)
        l = b.Jk[g.column],
        f = l.Vb,
        g = b.Ds[g.row],
        l = l.wE,
        (null != f ? b.C[f].Yg : b.Yg) && gvjs_rK(a, e, f, g, l);
    if (b.legend && b.legend.position == gvjs_ov && null != c.legend.focused.Xc) {
        c = c.legend.focused.Xc;
        l = gvjs_oK(d, c);
        l.Rg = {
            isVisible: b.Ofa
        };
        f = b.C[c].points;
        for (l = f.length - 1; 0 <= l; l--)
            if (g = f[l],
            !gvjs_XG(g) && g.ia && (new gvjs_B(b.O.top,b.O.right,b.O.bottom,b.O.left)).contains(new gvjs_z(g.ia.x,g.ia.y))) {
                var n = l;
                break
            }
        null != n && (l = gvjs_kK(d, c, n),
        l.visible = !0,
        h == gvjs_xu && gvjs_qK(a, e, c, n));
        for (l = 0; l < b.C.length; l++)
            l != c && (g = gvjs_oK(d, l),
            g.Da = {
                ja: {
                    color: gvjs_ur
                }
            },
            g = gvjs_nK(d, l),
            k = b.C[l],
            g.Oc = k.Oc.clone(),
            gvjs_ay(g.Oc, .3))
    }
}
var gvjs_Ega = [.25, .1, .05]
  , gvjs_xK = [.3, .1, .05]
  , gvjs_Dga = [.3, .15, .05];
function gvjs_zK(a, b) {
    this.ks = a;
    this.Qx = b;
    this.$j = gvjs_x(a);
    var c = a.width != b.width || a.height != b.height;
    !c && a.O && b.O && (c = a.O.width != b.O.width || a.O.height != b.O.height || a.O.left != b.O.left || a.O.top != b.O.top);
    this.$j.title && c && (this.$j.title.ja.opacity = 0);
    this.$j.jd && (this.$j.jd = gvjs_Ny(this.$j.jd, gvjs_x),
    this.hpa = gvjs_Ny(a.jd, function(d, e) {
        return gvjs_AK(a.jd[e], b.jd[e], this.$j.jd[e], !0, !1, c)
    }, this));
    this.$j.wc && (this.$j.wc = gvjs_Ny(this.$j.wc, gvjs_x),
    this.Uya = gvjs_Ny(a.wc, function(d, e) {
        return gvjs_AK(a.wc[e], b.wc[e], this.$j.wc[e], !1, !0, c)
    }, this));
    this.Gn = this.qj = null;
    gvjs_Fga(this);
    this.hca = this.gca = null;
    gvjs_Gga(this)
}
function gvjs_AK(a, b, c, d, e, f) {
    if (!a || !b)
        return null;
    var g = gvjs_x(a)
      , h = gvjs_x(a);
    h.zp = b.zp;
    h.Pf = b.Pf;
    h.ef = b.ef;
    c.title && f && (c.title.ja.opacity = 0);
    if (a.type == gvjs_Vd && b.type == gvjs_Vd && a.dataType === b.dataType) {
        a.baseline && b.baseline && (h.baseline = b.baseline,
        c.baseline = gvjs_x(c.baseline));
        h.number = gvjs_x(h.number);
        h.position = gvjs_x(h.position);
        c.number = gvjs_x(c.number);
        c.position = gvjs_x(c.position);
        h.position.hf = b.position.hf;
        if (a.Ja && b.Ja) {
            h.Ja = gvjs_Le(h.Ja);
            c.Ja = gvjs_Le(c.Ja);
            var k = h.Ja
              , l = c.Ja;
            for (f = 0; f < k.length; f++) {
                k[f] = gvjs_x(k[f]);
                l[f] = gvjs_x(l[f]);
                var m = k[f]
                  , n = a.number.hf(m.za);
                n = b.number.ol(n);
                m.Na = b.position.hf(n)
            }
        }
        if (a.text && b.text)
            for (h.text = gvjs_Le(h.text),
            c.text = gvjs_Le(c.text),
            k = h.text,
            c = c.text,
            gvjs_BK(k),
            gvjs_BK(c),
            f = 0; f < k.length; f++)
                gvjs_Hga(a, b, a.text[f], b.text[f], k[f], d, e)
    } else if (a.text && b.text) {
        var p = gvjs_sA(a.text, b.text, function(q, r) {
            return q.za == r.za
        });
        g.text = gvjs_De(a.text, function(q, r) {
            return null != p.vca[r]
        });
        h.text = gvjs_De(b.text, function(q, r) {
            return null != p.wca[r]
        });
        c.text = gvjs_Le(g.text);
        gvjs_BK(g.text);
        gvjs_BK(h.text);
        gvjs_BK(c.text)
    }
    return [g, h]
}
function gvjs_Hga(a, b, c, d, e, f, g) {
    var h = e.Da
      , k = a.number.hf(e.za);
    k = b.number.ol(k);
    a = a.position.hf(e.za);
    b = b.position.hf(k);
    f && (f = c.Da.anchor.x - a,
    h.anchor.x = b + f,
    d && (h.anchor.y = d.Da.anchor.y));
    g && (f = c.Da.anchor.y - a,
    h.anchor.y = b + f,
    d && (h.anchor.x = d.Da.anchor.x))
}
function gvjs_BK(a) {
    gvjs_u(a, function(b, c) {
        a[c] = gvjs_x(a[c]);
        b = a[c];
        b.Da = gvjs_x(b.Da);
        b = b.Da;
        b.anchor && (c = b.anchor,
        b.anchor = new gvjs_HG(c.x,c.y))
    })
}
function gvjs_Fga(a) {
    var b = a.ks
      , c = a.Qx;
    if (b.C && c.C) {
        var d = gvjs_sA(b.C, c.C, function(e, f) {
            return e.id == f.id
        });
        a.qj = gvjs_De(b.C, function(e, f) {
            return null != d.vca[f]
        });
        a.Gn = gvjs_De(c.C, function(e, f) {
            return null != d.wca[f]
        });
        b.Fa == gvjs_d || b.Fa == gvjs_Dd ? (b = null == b.orientation || b.orientation == gvjs_S ? b.jd[0] : b.wc[0],
        c = null == c.orientation || c.orientation == gvjs_S ? c.jd[0] : c.wc[0],
        b.type == gvjs_Vd && c.type == gvjs_Vd && b.dataType === c.dataType ? gvjs_Iga(a, b.number.hf, b.number.ol) : gvjs_Jga(a)) : b.Fa == gvjs_yt && gvjs_Kga(a)
    }
}
function gvjs_Jga(a) {
    var b = a.ks.$a
      , c = a.Qx.$a;
    if (b && c) {
        var d = {}
          , e = {}
          , f = {}
          , g = {};
        gvjs_u(b, function(p, q) {
            null != p.data && (f[p.data] = q)
        });
        gvjs_u(c, function(p, q) {
            null != p.data && (g[p.data] = q)
        });
        gvjs_u(b, function(p, q) {
            null != p.data && (d[q] = g[p.data])
        });
        gvjs_u(c, function(p, q) {
            null != p.data && (p = f[p.data],
            d[p] !== q && (p = null),
            e[q] = p)
        });
        gvjs_u(b, function(p, q) {
            null != p.data && e[g[p.data]] !== q && (d[q] = null)
        });
        for (var h = 0, k = 0, l = [], m = []; h < b.length || k < c.length; )
            h < b.length && null == d[h] ? (m.push({
                Ix: {
                    idx: h,
                    zy: !0
                },
                Jx: {
                    idx: k,
                    zy: !1
                }
            }),
            l.push({
                data: b[h].data
            }),
            h++) : (k < c.length && null == e[k] ? (m.push({
                Ix: {
                    idx: h,
                    zy: !1
                },
                Jx: {
                    idx: k,
                    zy: !0
                }
            }),
            l.push({
                data: c[k].data
            })) : (m.push({
                Ix: {
                    idx: h,
                    zy: !0
                },
                Jx: {
                    idx: k,
                    zy: !0
                }
            }),
            l.push({
                data: b[h].data
            }),
            h++),
            k++);
        a.$j.$a = l;
        var n = function(p, q) {
            return 0 == q ? p[0] : q >= p.length ? gvjs_Ae(p) : gvjs_CK(p[q - 1], p[q], .5)
        };
        a.ks.kd ? gvjs_DK(a, m, function(p, q, r, t) {
            return q.zy ? p[q.idx * r + t] : n(p, q.idx * r + t)
        }) : gvjs_EK(a, m, function(p, q) {
            return q.zy ? p[q.idx] : n(p, q.idx)
        })
    }
}
function gvjs_Iga(a, b, c) {
    var d = a.ks.$a
      , e = a.Qx.$a;
    if (d && e)
        if (0 == d.length || 0 == e.length)
            a.$j.$a = [],
            gvjs_EK(a, [], function() {
                return null
            });
        else {
            var f = function(l) {
                return b(l.data)
            }
              , g = []
              , h = [];
            if (d.length === e.length)
                for (var k = 0; k < d.length; k++)
                    h.push({
                        Ix: k,
                        Jx: k
                    }),
                    g.push({
                        data: c(gvjs_bz(f(d[k]), f(e[k])))
                    });
            else
                k = gvjs_Kda(d, e, f),
                gvjs_u(k, function(l) {
                    var m = l.yB;
                    l = l.zB;
                    var n;
                    null != d[m] && null != e[l] && (n = c(gvjs_bz(f(d[m]), f(e[l]))));
                    null != n && (h.push({
                        Ix: m,
                        Jx: l
                    }),
                    g.push({
                        data: n
                    }))
                });
            a.$j.$a = g;
            a.ks.kd ? gvjs_DK(a, h, function(l, m, n, p) {
                return l[m * n + p]
            }) : gvjs_EK(a, h, function(l, m) {
                return l[m]
            })
        }
}
function gvjs_Kga(a) {
    function b(l) {
        l = gvjs_x(l);
        l.ia = gvjs_x(l.ia);
        l.ia.brush = l.ia.brush.clone();
        l.ia.brush.mf(0);
        gvjs_ay(l.ia.brush, 0);
        l.ja = gvjs_x(l.ja);
        l.ja.opacity = 0;
        return l
    }
    var c = a.qj[0].points
      , d = a.Gn[0].points
      , e = []
      , f = []
      , g = []
      , h = {};
    gvjs_u(d, function(l, m) {
        null != l && (void 0 === h[l.id] && (h[l.id] = []),
        h[l.id].push(m))
    });
    gvjs_w(c, function(l, m) {
        if (null != l) {
            var n = l.id && h[l.id];
            n = n && n.shift();
            void 0 !== n ? g.push({
                Ix: m,
                Jx: n
            }) : e.push(l)
        }
    });
    gvjs_w(h, function(l) {
        gvjs_u(l, function(m) {
            f.push(d[m])
        })
    });
    gvjs_EK(a, g, function(l, m) {
        return l[m]
    });
    c = gvjs_v(e, b);
    var k = gvjs_v(f, b);
    a.qj[0].nC = gvjs_Ke(e, k);
    a.Gn[0].nC = gvjs_Ke(c, f)
}
function gvjs_EK(a, b, c) {
    for (var d = 0; d < a.qj.length; d++) {
        var e = a.qj[d].points
          , f = a.Gn[d].points
          , g = []
          , h = [];
        if (a.qj[d].ag)
            g = gvjs_Le(a.qj[d].points),
            h = gvjs_Le(a.Gn[d].points);
        else
            for (var k = 0; k < b.length; k++) {
                var l = b[k]
                  , m = c(e, l.Ix);
                l = c(f, l.Jx);
                m && l && (g.push(m),
                h.push(l))
            }
        a.qj[d] = gvjs_FK(a.qj[d], g);
        a.Gn[d] = gvjs_FK(a.Gn[d], h)
    }
}
function gvjs_DK(a, b, c) {
    for (var d = 0; d < a.qj.length; d++) {
        var e = a.qj[d].points
          , f = a.Gn[d].points
          , g = []
          , h = [];
        if (0 < b.length)
            for (var k = Math.ceil(e.length / b.length), l = Math.ceil(f.length / b.length), m = 0; m < b.length; m++) {
                for (var n = b[m], p = 0; p < k; p++) {
                    var q = c(e, n.Ix, k, p);
                    q && g.push(q)
                }
                for (p = 0; p < l; p++)
                    (q = c(f, n.Jx, l, p)) && h.push(q)
            }
        a.qj[d] = gvjs_FK(a.qj[d], g);
        a.Gn[d] = gvjs_FK(a.Gn[d], h)
    }
}
function gvjs_FK(a, b) {
    a = gvjs_x(a);
    a.points = b;
    return a
}
function gvjs_Gga(a) {
    var b = a.ks
      , c = a.Qx;
    b.legend && b.legend.Pe && c.legend && c.legend.Pe && (a.$j.legend = null)
}
function gvjs_GK(a, b, c) {
    if (a === b)
        return a;
    if (a && a.constructor == gvjs_3 && b && b.constructor == gvjs_3)
        return new gvjs_3({
            fill: gvjs_7z(a.fill, b.fill, 1 - c),
            fillOpacity: gvjs_GK(a.fillOpacity, b.fillOpacity, c),
            stroke: gvjs_7z(a.Uj(), b.Uj(), 1 - c),
            strokeWidth: gvjs_GK(a.strokeWidth, b.strokeWidth, c),
            strokeOpacity: gvjs_GK(a.strokeOpacity, b.strokeOpacity, c),
            Mi: a.Mi,
            gradient: a.gradient,
            pattern: a.pattern
        });
    if (Array.isArray(a) && Array.isArray(b)) {
        if (a)
            if (b) {
                for (var d = [], e = Math.min(a.length, b.length), f = 0; f < e; f++)
                    d.push(gvjs_GK(a[f], b[f], c));
                c = d
            } else
                c = a;
        else
            c = b;
        return c
    }
    return gvjs_r(a) || gvjs_r(b) ? gvjs_HK(a, b, c) : typeof a === gvjs_l || typeof b === gvjs_l ? a : typeof a === gvjs_g && typeof b === gvjs_g ? (a = isNaN(a) ? 0 : a,
    b = isNaN(b) ? 0 : b,
    isFinite(a) && isFinite(b) ? a * (1 - c) + b * c : Infinity) : null
}
function gvjs_HK(a, b, c) {
    if (!a)
        return b;
    if (!b)
        return a;
    var d = {};
    gvjs_w(a, function(e, f) {
        void 0 !== b[f] && (d[f] = gvjs_GK(a[f], b[f], c))
    });
    return d
}
function gvjs_IK(a, b, c, d, e) {
    b = !e || (c ? b >= c.top && b <= c.bottom : !1);
    return (!d || (c ? a >= c.left && a <= c.right : !1)) && b
}
function gvjs_JK(a, b, c, d, e) {
    a.position && a.position.hf && b.position && b.position.hf && (c.position.hf = function(f) {
        var g = a.position.hf(f);
        f = b.position.hf(f);
        return gvjs_GK(g, f, e)
    }
    );
    a.title && b.title && gvjs_u(c.title.lines, function(f, g) {
        f.x = gvjs_GK(a.title.lines[g].x, b.title.lines[g].x, e);
        f.y = gvjs_GK(a.title.lines[g].y, b.title.lines[g].y, e)
    });
    a.baseline && b.baseline && (c.baseline.Na = gvjs_GK(a.baseline.Na, b.baseline.Na, e));
    a.Ja && b.Ja && gvjs_u(c.Ja, function(f, g) {
        f.Na = gvjs_GK(a.Ja[g].Na, b.Ja[g].Na, e);
        f.isVisible = d(f.Na, f.Na)
    });
    a.zp && b.zp && (c.zp = gvjs_HK(a.zp, b.zp, e));
    null != a.Pf && null != b.Pf && (c.Pf = gvjs_GK(a.Pf, b.Pf, e));
    null != a.ef && null != b.ef && (c.ef = gvjs_GK(a.ef, b.ef, e));
    a.text && b.text && gvjs_u(c.text, function(f, g) {
        if (f) {
            var h = a.text[g].Da;
            g = b.text[g].Da;
            var k = f.Da;
            k && k.anchor && (k.anchor.x = gvjs_GK(h.anchor.x, g.anchor.x, e),
            k.anchor.y = gvjs_GK(h.anchor.y, g.anchor.y, e));
            f.Da && (h = 0 < f.Da.lines.length,
            f.isVisible = d((h ? f.Da.lines[0].x : 0) + f.Da.anchor.x, (h ? f.Da.lines[0].y : 0) + f.Da.anchor.y))
        }
    })
}
function gvjs_CK(a, b, c) {
    if (!a || !b)
        return null;
    var d = gvjs_x(a);
    if (a.$l || b.$l)
        d.$l = !0;
    if (void 0 !== a.ia || void 0 !== b.ia)
        d.ia = gvjs_GK(a.ia || {}, b.ia || {}, c),
        d.Kf = gvjs_GK(a.Kf || {}, b.Kf || {}, c);
    void 0 !== a.wt && void 0 !== b.wt && (d.wt = gvjs_GK(a.wt, b.wt, c));
    void 0 !== a.fr && void 0 !== b.fr && (d.fr = gvjs_GK(a.fr, b.fr, c));
    void 0 !== a.ja && void 0 !== b.ja && a.ja !== b.ja && (d.ja = gvjs_x(a.ja),
    d.ja.color = gvjs_7z(a.ja.color, b.ja.color, 1 - c),
    d.ja.opacity = gvjs_GK(void 0 !== a.ja.opacity ? a.ja.opacity : 1, void 0 !== b.ja.opacity ? b.ja.opacity : 1, c));
    null != a.Bc && null != b.Bc && a.Bc.labels[0].text === b.Bc.labels[0].text ? d.Bc = gvjs_GK(a.Bc, b.Bc, c) : delete d.Bc;
    return d
}
gvjs_zK.prototype.interpolate = function(a) {
    var b = this.$j;
    if (b.jd) {
        var c = function(r, t) {
            return gvjs_IK(r, t, b.O, !0, !1)
        };
        gvjs_w(b.jd, function(r, t) {
            (t = this.hpa[t]) && gvjs_JK(t[0], t[1], r, c, a)
        }, this)
    }
    if (b.wc) {
        var d = function(r, t) {
            return gvjs_IK(r, t, b.O, !1, !0)
        };
        gvjs_w(b.wc, function(r, t) {
            (t = this.Uya[t]) && gvjs_JK(t[0], t[1], r, d, a)
        }, this)
    }
    if (this.qj && this.Gn) {
        b.C = [];
        for (var e = 0; e < this.qj.length; ++e) {
            var f = this.qj[e]
              , g = this.Gn[e]
              , h = gvjs_x(g);
            if (f && g && f.type == g.type) {
                if (f.points && g.points) {
                    h.points = [];
                    for (var k = 0; k < f.points.length; k++)
                        h.points[k] = gvjs_CK(f.points[k], g.points[k], a);
                    if (f.nC && g.nC)
                        for (k = 0; k < f.nC.length; k++)
                            h.points.push(gvjs_CK(f.nC[k], g.nC[k], a))
                }
                f.Df && f.Df.paths && g.Df && g.Df.paths && (h.Df = gvjs_x(h.Df),
                h.Df.paths = gvjs_GK(f.Df.paths, g.Df.paths, a))
            }
            b.C[e] = h
        }
    }
    b.height && (b.height = gvjs_GK(this.ks.height, this.Qx.height, a));
    b.width && (b.width = gvjs_GK(this.ks.width, this.Qx.width, a));
    b.O && (b.O = gvjs_GK(this.ks.O, this.Qx.O, a));
    if (this.gca && this.hca && b.legend && b.legend.ev)
        for (e = 0; e < b.legend.ev.length; e++) {
            f = b.legend.ev[e];
            g = this.gca[e];
            h = this.hca[e];
            if (f.Da && f.Da.lines && g.Da && g.Da.lines && 0 != g.Da.lines.length && h.Da && h.Da.lines) {
                var l = f.Da.lines
                  , m = g.Da.lines
                  , n = h.Da.lines
                  , p = m.length;
                for (k = 0; k < l.length; k++) {
                    var q = k < p ? m[k] : m[p - 1];
                    l[k].x = gvjs_GK(q.x, n[k].x, a);
                    l[k].y = gvjs_GK(q.y, n[k].y, a)
                }
            }
            f.square && f.square.coordinates && g.square && g.square.coordinates && h.square && h.square.coordinates && (k = gvjs_GK(g.square.coordinates, h.square.coordinates, a),
            f.square.coordinates = new gvjs_5(k.left,k.top,k.width,k.height));
            f.Rg && f.Rg.coordinates && g.Rg && g.Rg.coordinates && h.Rg && h.Rg.coordinates && (f.Rg.coordinates = gvjs_GK(g.Rg.coordinates, h.Rg.coordinates, a))
        }
    return b
}
;
function gvjs_KK(a) {
    gvjs_F.call(this);
    this.KG = a;
    this.fq = Infinity;
    this.zJ = 0;
    a = new gvjs_IA(15);
    gvjs_6x(this, a);
    gvjs_G(a, gvjs_dx, gvjs_s(this.Y4, this));
    this.Hc = a
}
gvjs_o(gvjs_KK, gvjs_F);
function gvjs_LK(a, b) {
    var c = a.fq;
    a.fq = Math.min(a.fq, b);
    isFinite(a.fq) ? isFinite(c) || a.Hc.start() : a.Hc.stop()
}
gvjs_KK.prototype.Y4 = function() {
    var a = Date.now();
    this.fq -= a - this.zJ;
    this.zJ = a;
    0 >= this.fq && (this.KG(),
    this.fq = Infinity,
    this.Hc.stop())
}
;
function gvjs_MK(a, b, c, d, e, f) {
    gvjs_F.call(this);
    this.ha = a;
    this.Ra = b;
    this.Vk = c;
    this.zd = d;
    this.zb = new gvjs_KK(e);
    gvjs_6x(this, this.zb);
    this.zo = f;
    this.zo.zb = this.zb;
    this.S2()
}
gvjs_o(gvjs_MK, gvjs_F);
gvjs_ = gvjs_MK.prototype;
gvjs_.M = function() {
    gvjs_li(this.Vk);
    gvjs_F.prototype.M.call(this)
}
;
gvjs_.xpa = function(a) {
    this.Ra.cursor.position = a.data.xb;
    gvjs_LK(this.zb, 5)
}
;
gvjs_.ypa = function() {}
;
gvjs_.Apa = function(a) {
    this.Ra.cursor.position = a.data.xb;
    this.zd.dispatchEvent(gvjs_5v, {
        targetID: a.data.De,
        x: a.data.xb.x,
        y: a.data.xb.y
    })
}
;
gvjs_.Bpa = function(a) {
    this.zd.dispatchEvent("onmouseup", {
        targetID: a.data.De,
        x: a.data.xb.x,
        y: a.data.xb.y
    })
}
;
gvjs_.zpa = function(a) {
    var b = {
        targetID: a.data.De,
        x: a.data.xb.x,
        y: a.data.xb.y
    };
    this.zd.dispatchEvent(gvjs_4v, b);
    this.zo.xn(gvjs_4v, b, a.data.preventDefault)
}
;
gvjs_.spa = function(a) {
    this.zd.dispatchEvent(gvjs_Wt, {
        targetID: a.data.De,
        x: a.data.xb.x,
        y: a.data.xb.y
    })
}
;
gvjs_.Fpa = function(a) {
    var b = {
        targetID: a.data.De,
        x: a.data.xb.x,
        y: a.data.xb.y
    };
    this.zd.dispatchEvent(gvjs_Aw, b);
    this.zo.xn(gvjs_Aw, b, a.data.preventDefault)
}
;
gvjs_.tpa = function(a) {
    this.zd.dispatchEvent(gvjs_du, {
        targetID: a.data.De,
        x: a.data.xb.x,
        y: a.data.xb.y
    })
}
;
gvjs_.Gpa = function(a) {
    var b = {
        targetID: a.data.De,
        x: a.data.xb.x,
        y: a.data.xb.y,
        wheelDelta: a.data.wheelDelta
    };
    this.zd.dispatchEvent(gvjs_Gw, b);
    this.zo.xn(gvjs_Gw, b, a.data.preventDefault)
}
;
gvjs_.vpa = function(a) {
    a = {
        targetID: a.data.De,
        x: a.data.xb.x,
        y: a.data.xb.y
    };
    this.zd.dispatchEvent(gvjs_pu, a);
    this.zo.xn(gvjs_pu, a)
}
;
gvjs_.wpa = function(a) {
    a = {
        targetID: a.data.De,
        x: a.data.xb.x,
        y: a.data.xb.y
    };
    this.zd.dispatchEvent(gvjs_nu, a);
    this.zo.xn(gvjs_nu, a)
}
;
gvjs_.upa = function(a) {
    a = {
        targetID: a.data.De,
        x: a.data.xb.x,
        y: a.data.xb.y
    };
    this.zd.dispatchEvent(gvjs_ou, a);
    this.zo.xn(gvjs_ou, a)
}
;
gvjs_.Dpa = function(a) {
    this.zo.xn("pinchstart", {
        targetID: a.data.De,
        x: a.data.xb.x,
        y: a.data.xb.y,
        gesture: a.data.F$
    }, a.data.preventDefault)
}
;
gvjs_.Epa = function(a) {
    this.zo.xn("pinch", {
        targetID: a.data.De,
        x: a.data.xb.x,
        y: a.data.xb.y,
        gesture: a.data.F$
    }, a.data.preventDefault)
}
;
gvjs_.Cpa = function(a) {
    this.zo.xn("pinchend", {
        targetID: a.data.De,
        x: a.data.xb.x,
        y: a.data.xb.y,
        gesture: a.data.F$
    }, a.data.preventDefault)
}
;
gvjs_.jaa = function(a) {
    this.Ra.focused.Eb = a.data.Kk;
    gvjs_LK(this.zb, 50)
}
;
gvjs_.kaa = function() {
    this.Ra.cursor.position = null;
    this.Ra.focused.Eb = null;
    gvjs_LK(this.zb, 50)
}
;
gvjs_.iaa = function(a) {
    var b = this
      , c = this.ha;
    this.Ra.cursor.p2 = this.Ra.cursor.position.clone();
    a = a.data.Kk;
    if (gvjs_Fe(c.C, function(g) {
        return g.Yg
    })) {
        var d = c.$a[a].Cs;
        a = c.FE == gvjs_Ww;
        if (!a && c.Ig.has(gvjs_gp)) {
            var e = new Set
              , f = new Set;
            gvjs_u(this.ha.C, function(g) {
                var h = g.points[d];
                null == h || h.$l || (g = g.Cs,
                gvjs_fo(this.Ra.selected, d, g) ? e.add(g) : f.add(g))
            }, this);
            c = f.size;
            0 < e.size && 0 === c ? e.forEach(function(g) {
                b.Ra.selected.MK(d, g)
            }) : 0 < c && f.forEach(function(g) {
                gvjs_go(b.Ra.selected, d, g)
            })
        } else
            gvjs_ty(this.Ra.selected, d, a);
        gvjs_LK(this.zb, 0)
    }
}
;
gvjs_.saa = function(a) {
    this.ha.Fa != gvjs_yt && (this.Ra.legend.focused.Xc = a.data.TQ,
    gvjs_LK(this.zb, 50))
}
;
gvjs_.taa = function() {
    this.ha.Fa != gvjs_yt && (this.Ra.legend.focused.Xc = null,
    gvjs_LK(this.zb, 250))
}
;
gvjs_.nqa = function(a) {
    this.ha.Fa != gvjs_yt && (gvjs_NK(this, a.data.TQ),
    gvjs_LK(this.zb, 0))
}
;
gvjs_.oqa = function(a) {
    null == this.Ra.legend.Xi && (this.Ra.legend.Xi = a.data.Xi || 0,
    this.Ra.legend.xF = a.data.xF || 0);
    this.Ra.legend.Xi += a.data.hwa;
    gvjs_LK(this.zb, 0)
}
;
gvjs_.Baa = function(a) {
    if (this.ha.Fa != gvjs_yt) {
        var b = this.ha.qz;
        if (this.ha.Ig.has(gvjs_Mw) || b == gvjs_lu)
            this.Ra.focused.Hb = a.data.Vb,
            gvjs_LK(this.zb, 50)
    }
}
;
gvjs_.Caa = function() {
    if (this.ha.Fa != gvjs_yt) {
        var a = this.ha.qz;
        if (this.ha.Ig.has(gvjs_Mw) || a == gvjs_lu)
            this.Ra.focused.Hb = null,
            gvjs_LK(this.zb, 250)
    }
}
;
gvjs_.Aaa = function(a) {
    this.ha.Fa != gvjs_yt && this.ha.Ig.has(gvjs_Mw) && (gvjs_NK(this, a.data.Vb),
    gvjs_LK(this.zb, 0))
}
;
gvjs_.Nqa = function(a) {
    this.saa(a)
}
;
gvjs_.Oqa = function(a) {
    this.taa(a)
}
;
gvjs_.Mqa = function(a) {
    this.zd.dispatchEvent("removeserie", {
        index: a.data.TQ
    })
}
;
gvjs_.Opa = function(a) {
    var b = this.ha.Ig;
    if (b.has(gvjs_gp))
        this.Ra.focused.Hb = a.data.Vb,
        this.Ra.focused.datum = a.data.Kk;
    else {
        if (b.has(gvjs_Mw)) {
            this.Baa(a);
            return
        }
        if (b.has(gvjs_Ht)) {
            this.jaa(a);
            return
        }
    }
    gvjs_LK(this.zb, 50)
}
;
gvjs_.Ppa = function(a) {
    var b = this.ha.Ig;
    if (b.has(gvjs_gp))
        this.Ra.focused.Hb = null,
        this.Ra.focused.datum = null;
    else {
        if (b.has(gvjs_Mw)) {
            this.Caa(a);
            return
        }
        if (b.has(gvjs_Ht)) {
            this.kaa(a);
            return
        }
    }
    gvjs_LK(this.zb, 250)
}
;
gvjs_.Npa = function(a) {
    var b = this.ha;
    if (b.Ig.has(gvjs_gp)) {
        var c = b.FE == gvjs_Ww;
        a = {
            Eb: a.data.Kk,
            Hb: a.data.Vb
        };
        var d = b.C[a.Hb];
        d.Yg && (b.Fa == gvjs_yt ? gvjs_ty(this.Ra.selected, a.Eb, c) : d.ag || (b = b.eZ(a),
        a = this.ha.Ig,
        a.has(gvjs_gp) ? gvjs_vy(this.Ra.selected, b.row, b.column, c) : a.has(gvjs_Mw) && gvjs_uy(this.Ra.selected, b.column, c)));
        gvjs_LK(this.zb, 0)
    } else
        b.Ig.has(gvjs_Mw) ? this.Aaa(a) : b.Ig.has(gvjs_Ht) && this.iaa(a)
}
;
gvjs_.opa = function(a) {
    var b = a.data.lG;
    -1 != b && (this.Ra.annotations.focused = {
        row: a.data.Kk,
        column: gvjs_OK(this, a.data.Vb, b)
    },
    this.Ra.focused.Hb = null,
    this.Ra.focused.datum = null,
    gvjs_LK(this.zb, 50))
}
;
gvjs_.ppa = function(a) {
    -1 != a.data.lG && (this.Ra.annotations.focused = null,
    gvjs_LK(this.zb, 250))
}
;
gvjs_.npa = function(a) {
    var b = this.ha
      , c = b.FE == gvjs_Ww
      , d = a.data.Kk
      , e = a.data.Vb;
    a = a.data.lG;
    if (null == e || b.C[e].Yg)
        -1 == a ? this.Ra.annotations.dI = {
            Vb: e,
            oO: d
        } : gvjs_vy(this.Ra.selected, d, gvjs_OK(this, e, a), c);
    gvjs_LK(this.zb, 0)
}
;
gvjs_.bra = function() {}
;
gvjs_.cra = function() {}
;
gvjs_.kpa = function(a) {
    this.Ra.gi.focused.wy = a.data.wy;
    gvjs_LK(this.zb, 50)
}
;
gvjs_.lpa = function() {
    this.Ra.gi.focused.wy = null;
    gvjs_LK(this.zb, 250)
}
;
gvjs_.jpa = function() {
    var a = this.Ra.gi.focused.action;
    a && a();
    gvjs_LK(this.zb, 250)
}
;
gvjs_.Bq = function() {
    this.zo.xn(gvjs_i)
}
;
function gvjs_OK(a, b, c) {
    a = a.ha;
    var d = null;
    if (null != b)
        d = a.C[b].columns.annotation;
    else
        for (b = 0; b < a.Mk.length; ++b)
            d = a.Mk[b].columns.annotation;
    return d[c]
}
gvjs_.S2 = function() {
    var a = gvjs_s(function(b, c) {
        gvjs_G(this.Vk, b, gvjs_s(c, this))
    }, this);
    a("chartHoverIn", this.xpa);
    a("chartHoverOut", this.ypa);
    a(gvjs_Qt, this.Apa);
    a("chartMouseUp", this.Bpa);
    a(gvjs_Pt, this.zpa);
    a("chartClick", this.spa);
    a(gvjs_Rt, this.Fpa);
    a("chartDblClick", this.tpa);
    a("chartScroll", this.Gpa);
    a(gvjs_Ot, this.vpa);
    a("chartDrag", this.wpa);
    a("chartDragEnd", this.upa);
    a("chartPinchStart", this.Dpa);
    a("chartPinch", this.Epa);
    a("chartPinchEnd", this.Cpa);
    a("categoryHoverIn", this.jaa);
    a("categoryHoverOut", this.kaa);
    a("categoryClick", this.iaa);
    a("legendEntryHoverIn", this.saa);
    a("legendEntryHoverOut", this.taa);
    a("legendEntryClick", this.nqa);
    a("legendScrollButtonClick", this.oqa);
    a("serieHoverIn", this.Baa);
    a("serieHoverOut", this.Caa);
    a("serieClick", this.Aaa);
    a("removeSerieButtonHoverIn", this.Nqa);
    a("removeSerieButtonHoverOut", this.Oqa);
    a("removeSerieButtonClick", this.Mqa);
    a("datumHoverIn", this.Opa);
    a("datumHoverOut", this.Ppa);
    a("datumClick", this.Npa);
    a("annotationHoverIn", this.opa);
    a("annotationHoverOut", this.ppa);
    a("annotationClick", this.npa);
    a("tooltipHoverIn", this.bra);
    a("tooltipHoverOut", this.cra);
    a("actionsMenuEntryHoverIn", this.kpa);
    a("actionsMenuEntryHoverOut", this.lpa);
    a("actionsMenuEntryClick", this.jpa)
}
;
function gvjs_NK(a, b) {
    var c = a.ha;
    if (c.C[b].Yg) {
        var d = c.FE == gvjs_Ww
          , e = c.Ig
          , f = c.C[b].Cs;
        if (c.Fa == gvjs_fw)
            gvjs_ty(a.Ra.selected, f, d);
        else if (!d && e.has(gvjs_gp)) {
            var g = new Set
              , h = new Set;
            gvjs_u(a.ha.C[b].points, function(k, l) {
                null == k || k.$l || (gvjs_fo(this.Ra.selected, l, f) ? g.add(l) : h.add(l))
            }, a);
            b = h.size;
            0 < g.size && 0 === b ? g.forEach(function(k) {
                a.Ra.selected.MK(k, f)
            }) : 0 < b && h.forEach(function(k) {
                gvjs_go(a.Ra.selected, k, f)
            })
        } else
            gvjs_uy(a.Ra.selected, f, d)
    }
}
;function gvjs_PK() {}
gvjs_o(gvjs_PK, gvjs_6F);
gvjs_ = gvjs_PK.prototype;
gvjs_.iP = function(a) {
    var b = a.Hb
      , c = a.Eb;
    return this.fz ? gvjs_6F.prototype.iP.call(this, a) : this.C[b].properties.histogramBucketItems[c].label.Mx
}
;
gvjs_.dZ = function(a) {
    return this.fz ? gvjs_6F.prototype.dZ.call(this, a) : this.C[a.Hb].properties.histogramBucketItems[a.Eb].row
}
;
gvjs_.eZ = function(a) {
    if (this.fz)
        return gvjs_6F.prototype.eZ.call(this, a);
    a = this.C[a.Hb].properties.histogramBucketItems[a.Eb];
    return {
        row: a.row,
        column: a.column
    }
}
;
gvjs_.lP = function(a) {
    var b = this.Jk[a.column].Vb;
    return null == b ? null : this.fz ? gvjs_6F.prototype.lP.call(this, a) : {
        Hb: b,
        Eb: this.C[b].properties.histogramElementIndexes[a.row]
    }
}
;
gvjs_.xI = function(a, b) {
    a = this.C[a];
    var c = a.points[b];
    return this.fz ? {
        lines: [{
            title: "Items",
            value: gvjs_qA(15, (this.orientation === gvjs_S ? this.wc[a.Qc] : this.jd[a.Qc]).number.ol(c.Kf.uk - c.Kf.from))
        }]
    } : a.properties.histogramBucketItems[b].label
}
;
function gvjs_QK(a, b, c, d, e) {
    gvjs_eJ.call(this, a, b, c, d, e)
}
gvjs_o(gvjs_QK, gvjs_eJ);
gvjs_QK.prototype.nz = function() {
    return gvjs_eJ.prototype.nz.call(this)
}
;
gvjs_QK.prototype.B8 = function() {
    return new gvjs_PK
}
;
gvjs_QK.prototype.M8 = function() {
    var a = this.Ta
      , b = a.W(0) === gvjs_l ? 1 : 0
      , c = a.$();
    this.cQ = new gvjs_M;
    for (this.cQ.xd(gvjs_g, gvjs_8c); b < c; b++) {
        var d = a.Ga(b) + " (count)";
        this.cQ.xd(gvjs_g, d)
    }
    this.lb = this.cQ
}
;
gvjs_QK.prototype.mea = function() {
    var a = this.Ta
      , b = a.W(0) === gvjs_l
      , c = b ? 1 : 0
      , d = a.ca()
      , e = a.$();
    this.toNumber = [];
    for (var f = c; f < e; f++)
        this.toNumber[f] = gvjs_7H(a.W(f)).toNumber;
    a = gvjs_Lga(this);
    var g = gvjs_Le(a)
      , h = gvjs_v(a, function(u) {
        return gvjs_r(u) ? u.v : u
    })
      , k = h.length
      , l = (h[1] - h[0]).toPrecision(15) - 0
      , m = h[0].toPrecision(15) - 0
      , n = h[k - 1].toPrecision(15) - 0;
    a = [];
    for (f = c; f < e; f++) {
        a[f - c] = [];
        for (var p = 0; p < k; p++)
            a[f - c].push([])
    }
    f = this.cQ;
    f.rA(0, gvjs_8u, g);
    for (g = 0; g < k; g++) {
        p = [h[g]];
        for (var q = c; q < e; q++)
            p.push(0);
        f.Kp(p)
    }
    for (h = 0; h < d; h++)
        for (g = b ? this.Ta.getValue(h, 0) : "",
        p = c; p < e; p++)
            if (q = this.Ta.getValue(h, p),
            q = null != q ? this.toNumber[p](q) : null,
            (typeof q !== gvjs_g || isFinite(q)) && (null != q || this.V.Zj)) {
                q = q || 0;
                q = 0 == l || q < m ? 0 : q >= n ? k - 1 : Math.floor((q - m) / l);
                var r = p + 1 - c;
                f.Wa(q, r, (f.getValue(q, r) || 0) + 1);
                r = this.Ta.Ga(p) || "Value";
                r = {
                    row: h,
                    column: p,
                    label: {
                        title: g,
                        Mx: g,
                        En: r,
                        content: this.Ta.Ha(h, p),
                        lines: [{
                            title: r,
                            value: this.Ta.Ha(h, p) || 0
                        }]
                    }
                };
                a[p - c][q].push(r)
            }
    var t = [];
    for (b = c; b < e; b++)
        t[b] = [];
    b = gvjs_K(this.options, "histogram.sortBucketItems");
    for (d = c; d < e; d++)
        k = gvjs_Ly(a[d - c]),
        b && k.sort(function(u, v) {
            u = u.label.lines[0].value;
            v = v.label.lines[0].value;
            return u < v ? -1 : u > v ? 1 : 0
        }),
        f.rA(d - c, "histogramBucketItems", k),
        gvjs_u(k, function(u, v) {
            t[u.column][u.row] = v
        });
    for (a = c; a < e; a++)
        f.rA(a - c, "histogramElementIndexes", t[a])
}
;
function gvjs_Lga(a) {
    var b = a.Ta
      , c = b.ca()
      , d = b.$()
      , e = b.W(0) === gvjs_l ? 1 : 0
      , f = a.options.$I("histogram.buckets");
    if (f)
        return f;
    f = [];
    for (var g = 0; g < c; g++)
        for (var h = e; h < d; h++) {
            var k = b.getValue(g, h);
            k = null != k ? a.toNumber[h](k) : null;
            typeof k === gvjs_g && !isFinite(k) || null == k && !a.V.Zj || (k = k || 0,
            f.push(k))
        }
    f = f.sort(function(m, n) {
        return m - n
    });
    d = gvjs_L(a.options, gvjs_7u, 0);
    b = f[Math.max(0, Math.ceil(d / 100 * f.length) - 1)];
    f = f[Math.min(f.length - 1, Math.ceil((100 - d) / 100 * f.length) - 1)];
    d = a.options.Aa("histogram.minValue");
    e = a.options.Aa("histogram.maxValue");
    null != d && (b = Math.min(d, b));
    null != e && (f = Math.max(e, f));
    d = a.V.O.left;
    e = d + a.V.O.width;
    g = gvjs_L(a.options, "histogram.minSpacing", 1);
    k = gvjs_L(a.options, "histogram.minNumBuckets", 2);
    h = gvjs_L(a.options, "histogram.maxNumBuckets", (e - d) / g);
    var l = a.options.cb("histogram.numBucketsRule", gvjs_Mga);
    c = (0,
    gvjs_Nga[l])(c);
    c = Math.max(k, Math.min(h, c));
    c == k && (c = Math.min(2 * c, (k + h) / 2));
    k = Math.max(g, (e - d) / (2 + c));
    l = (f - b) / c;
    a = a.options.Aa(gvjs_5u);
    null != a && (0 >= a ? a = null : l = a,
    c = Math.min(h, (f - b) / l),
    k = Math.max(g, (e - d) / (2 * c)));
    b -= Math.min(l, Math.abs(b));
    f += Math.min(l, Math.abs(f));
    a = gvjs_$ea(b, f, d, e, new gvjs_Aj([{
        gridlines: {
            minSpacing: k
        }
    }]));
    return f = gvjs_v(a, function(m) {
        return m.getValue()
    })
}
function gvjs_uJ(a, b) {
    return 4 > a || b
}
function gvjs_hga(a, b) {
    var c = a.lb
      , d = a.V;
    a = [];
    for (var e = 0; e < d.$a.length; e++) {
        a[e] = [];
        for (var f = 0; f < d.C.length; f++) {
            var g = d.C[f];
            if (g.type == gvjs_lt) {
                var h = b ? 0 : f;
                a[e][h] = (a[e][h] || 0) + c.getValue(e, g.columns.data[0])
            }
        }
    }
    for (c = b = 0; c < a.length; c++)
        for (d = 0; d < a[c].length; d++)
            b = Math.max(a[c][d], b);
    return b
}
var gvjs_Mga = {
    SQRT: "sqrt",
    CBa: "sturges",
    jBa: "rice"
}
  , gvjs_Nga = {
    sqrt: function(a) {
        return Math.sqrt(a)
    },
    rice: function(a) {
        return 2 * Math.cbrt(a)
    },
    sturges: function(a) {
        return 1 + Math.log2(a)
    }
};
function gvjs_RK(a, b, c, d, e) {
    var f = a.right - a.left
      , g = gvjs_x(d)
      , h = gvjs_x(d);
    h.color = "9e9e9e";
    d = d.fontSize / 3.236;
    var k = g.fontSize + d
      , l = h.fontSize + d
      , m = gvjs_Oga(a, f, b, g, h, d, e)
      , n = [];
    if (2 == c) {
        c = a.right;
        a = a.left;
        var p = gvjs_R
    } else
        c = a.left,
        a = a.right,
        p = gvjs_2;
    for (var q = 0; q < e.length; ++q) {
        var r = e[q]
          , t = m[q];
        if (null != t) {
            var u = gvjs_DG(b, r.pB, g, f, t.dG)
              , v = gvjs_DG(b, r.EB, h, f, t.DG)
              , w = gvjs_2I(new gvjs_ok(c,t.y));
            n.push({
                gga: 2,
                wp: gvjs_2I(r.Rda(gvjs_0g(t.y, r.aS.start, r.aS.end))),
                K8: a,
                YH: w,
                Bxa: new gvjs_3({
                    fill: "636363",
                    fillOpacity: .7
                }),
                Oc: new gvjs_3({
                    stroke: "636363",
                    strokeWidth: 1,
                    strokeOpacity: .7
                }),
                HEa: d,
                pB: {
                    text: r.pB,
                    ja: g,
                    anchor: new gvjs_HG(w.x,w.y),
                    lines: gvjs_v(u.lines, function(x, y) {
                        return {
                            x: 0,
                            y: (y - u.lines.length) * k,
                            length: u.Oq,
                            text: x
                        }
                    }),
                    ld: p,
                    Pc: gvjs_2,
                    tooltip: u.oe ? r.pB : "",
                    angle: 0
                },
                aCa: g,
                EB: {
                    text: r.EB,
                    ja: h,
                    anchor: new gvjs_HG(w.x,w.y),
                    lines: gvjs_v(v.lines, function(x, y) {
                        return {
                            x: 0,
                            y: (y + 1) * l,
                            length: v.Oq,
                            text: x
                        }
                    }),
                    ld: p,
                    Pc: gvjs_R,
                    tooltip: v.oe ? r.EB : "",
                    angle: 0
                },
                pCa: h,
                W6: p,
                index: r.index
            })
        }
    }
    return n
}
function gvjs_Oga(a, b, c, d, e, f, g) {
    var h = d.fontSize + f
      , k = e.fontSize + f
      , l = gvjs_v(g, function(r, t) {
        var u = gvjs_DG(c, r.pB, d, b, Infinity)
          , v = gvjs_DG(c, r.EB, e, b, Infinity);
        return {
            $H: t,
            u2: r.oea,
            Cx: r.oea,
            dG: u.lines.length,
            DG: v.lines.length,
            PM: f,
            mN: f
        }
    });
    gvjs_Qe(l, function(r, t) {
        return r.Cx - t.Cx
    });
    l = gvjs_Le(l);
    gvjs_Qe(l, function(r, t) {
        return g[r.$H].kba - g[t.$H].kba
    });
    var m = [];
    0 < l.length && m.push(l.pop());
    for (var n = null, p = 0, q; q = gvjs_SK(a, h, k, g, m, !1),
    !(0 === l.length || q.aM && 15 < p); )
        q.aM ? (p++,
        n && gvjs_Ie(m, n)) : p = 0,
        n = l.pop(),
        m.push(n),
        gvjs_Qe(m, function(r, t) {
            return r.Cx - t.Cx
        });
    q.aM && n && (gvjs_Ie(m, n),
    q = gvjs_SK(a, h, k, g, m, !1));
    a = gvjs_SK(a, h, k, g, m, !0);
    a.aM || (q = a);
    return q.layout
}
function gvjs_SK(a, b, c, d, e, f) {
    0 < e.length && (e[0].PM = 0,
    gvjs_Ae(e).mN = 0);
    for (var g = 0; g < e.length; g++) {
        var h = e[g]
          , k = e[g - 1]
          , l = e[g + 1];
        h.e7 = new gvjs_O(Math.min(h.u2, k ? d[k.$H].aS.start + 5 : a.top),Math.max(h.u2, l ? d[l.$H].aS.end - 5 : a.bottom))
    }
    a = gvjs_Pga(a, b, c, e, f);
    d = !1;
    f = {};
    for (g = 0; g < e.length; g++) {
        h = e[g];
        k = a[g];
        l = (k.anchor - k.top - h.PM) / b;
        var m = (k.bottom - k.anchor - h.mN) / c;
        l = Math.floor(l + .1);
        m = Math.floor(m + .1);
        var n = l < h.dG || m < h.DG;
        d = d || n;
        f[h.$H] = {
            y: k.anchor,
            dG: l,
            DG: m,
            aM: n
        }
    }
    return {
        layout: f,
        aM: d
    }
}
function gvjs_Pga(a, b, c, d, e) {
    var f = gvjs_v(d, function(k) {
        return {
            anchor: k.Cx,
            top: k.Cx - (k.dG * b + k.PM),
            bottom: k.Cx + (k.DG * c + k.mN)
        }
    })
      , g = [];
    g.push(function(k, l) {
        var m = k[l].top;
        if (0 == l)
            return {
                top: Math.max(a.top - m, 0)
            };
        l = gvjs_jg(l) - 1;
        return {
            top: Math.max(k[l].bottom - m, 0) / 2
        }
    });
    g.push(function(k, l) {
        var m = k[l].bottom;
        if (l == d.length - 1)
            return {
                bottom: Math.min(a.bottom - m, 0)
            };
        l = gvjs_jg(l) + 1;
        return {
            bottom: Math.min(k[l].top - m, 0) / 2
        }
    });
    g.push(function(k, l, m) {
        k = k[l].anchor - k[l].top;
        var n = Math;
        l = d[l];
        m = (Math.max(-k, 0) + n.max.call(n, l.dG * b + l.PM - Math.max(k, 0), 0) * (e ? 1 : m)) / 2;
        return {
            anchor: m,
            top: -m
        }
    });
    g.push(function(k, l, m) {
        k = k[l].bottom - k[l].anchor;
        var n = Math;
        l = d[l];
        m = (Math.max(-k, 0) + n.max.call(n, l.DG * c + l.mN - Math.max(k, 0), 0) * (e ? 1 : m)) / 2;
        return {
            anchor: -m,
            bottom: m
        }
    });
    g.push(function(k, l) {
        k = k[l].anchor;
        l = d[l];
        return {
            anchor: gvjs_0g(k, l.e7.start, l.e7.end) - k
        }
    });
    e && g.push(function(k, l, m) {
        return {
            anchor: (d[l].u2 - k[l].anchor) * m
        }
    });
    var h = gvjs_Lda(f, g, function(k, l) {
        return {
            anchor: k.anchor + (l.anchor || 0),
            top: k.top + (l.top || 0),
            bottom: k.bottom + (l.bottom || 0)
        }
    }, function(k, l) {
        return Math.max(Math.abs(k.anchor - l.anchor), Math.abs(k.top - l.top), Math.abs(k.bottom - l.bottom))
    });
    return gvjs_v(d, function(k, l) {
        k = h[String(l)];
        return {
            anchor: k.anchor,
            top: k.top,
            bottom: k.bottom
        }
    })
}
function gvjs_Qga(a, b) {
    a = gvjs_Xx(a, function(d) {
        return d.index == b
    });
    if (0 > a)
        return {};
    var c = {};
    c[a] = {
        gga: 4,
        Oc: new gvjs_3({
            stroke: "636363",
            strokeWidth: 2,
            strokeOpacity: .7
        })
    };
    return c
}
;function gvjs_TK(a, b) {
    gvjs_LG.call(this, a, b);
    this.KQ = this.Um = null
}
gvjs_o(gvjs_TK, gvjs_LG);
gvjs_ = gvjs_TK.prototype;
gvjs_.C9 = function(a, b) {
    var c = this.renderer;
    if (1 > a.C.length)
        return !1;
    this.Um = b;
    b = a.pie.Gd;
    for (var d = a.C.length / b.length, e = 0; e < b.length; ++e) {
        for (var f = b[e].radiusX, g = b[e].radiusY, h = b[e].cS, k = e * d, l = k + d; k < l && 180 > a.C[k].vd; )
            gvjs_UK(this, a.C[k], f, g),
            k += 1;
        h && gvjs_UK(this, h, f, g);
        for (h = l - 1; h >= k; --h)
            gvjs_UK(this, a.C[h], f, g)
    }
    a.Jq && (this.KQ = c.Sa(),
    gvjs_VK(this, a.Jq),
    c.appendChild(this.Um, this.KQ));
    return !0
}
;
gvjs_.iY = function(a, b) {
    if (this.Ea.O5) {
        var c = a.square.coordinates.height
          , d = a.square.coordinates.left + a.square.coordinates.width / 2
          , e = a.square.coordinates.top + c / 2;
        a = a.square.brush.clone();
        a.mf(1);
        gvjs_SG(this, d, e, c / 2, a, {
            type: gvjs_4o
        }, b)
    } else
        gvjs_LG.prototype.iY.call(this, a, b)
}
;
function gvjs_UK(a, b, c, d) {
    if (b.isVisible) {
        var e = a.renderer.Sa()
          , f = a.Ea
          , g = f.pie.center
          , h = b.offset;
        if (b.dc) {
            var k = f.pie.eE;
            var l = b.dc
              , m = new gvjs_SA;
            m.move(h.x + l.gf.x, h.y + l.gf.y);
            m.va(h.x + l.gf.x, h.y + l.gf.y + k);
            m.Sf(h.x + g.x, h.y + g.y + k, c, d, l.de, l.vd, !0);
            m.va(h.x + l.ei.x, h.y + l.ei.y);
            m.Sf(h.x + g.x, h.y + g.y, c, d, l.vd, l.de, !1);
            a.renderer.Ia(m, l.brush, e)
        }
        if (b.kv || b.sy)
            k = f.pie.eE,
            l = new gvjs_SA,
            l.move(h.x + g.x, h.y + g.y),
            l.va(h.x + g.x, h.y + g.y + k),
            b.sy && (l.va(h.x + b.ei.x, h.y + b.ei.y + k),
            l.va(h.x + b.ei.x, h.y + b.ei.y)),
            b.kv && (l.va(h.x + b.gf.x, h.y + b.gf.y + k),
            l.va(h.x + b.gf.x, h.y + b.gf.y)),
            a.renderer.Ia(l, b.qQ, e);
        l = b.highlight ? b.highlight.brush : b.brush;
        b.rt ? 0 == b.eJ && 0 == b.gD ? a.renderer.Gl(g.x, g.y, c, d, l, e) : (m = new gvjs_SA,
        m.move(g.x, g.y - d),
        m.Sf(g.x, g.y, c, d, 0, 180, !0),
        m.Sf(g.x, g.y, c, d, 180, 360, !0),
        m.move(g.x, g.y - b.gD),
        m.Sf(g.x, g.y, b.eJ, b.gD, 360, 180, !1),
        m.Sf(g.x, g.y, b.eJ, b.gD, 180, 0, !1),
        m.close(),
        a.renderer.Ia(m, l, e)) : (m = new gvjs_SA,
        m.move(h.x + b.fD.x, h.y + b.fD.y),
        m.va(h.x + b.gf.x, h.y + b.gf.y),
        m.Sf(h.x + g.x, h.y + g.y, c, d, b.de, b.vd, !0),
        m.va(h.x + b.Uv.x, h.y + b.Uv.y),
        m.Sf(h.x + g.x, h.y + g.y, b.eJ, b.gD, b.vd, b.de, !1),
        a.renderer.Ia(m, l, e));
        b.nj && f.Mfa && gvjs_WK(a, b.nj, e);
        if (c = b.Ko) {
            c.dc && (d = new gvjs_SA,
            d.move(c.dc.gf.x, c.dc.gf.y),
            d.va(c.dc.gf.x, c.dc.gf.y + k),
            d.Sf(c.dc.di.x, c.dc.di.y + k, c.dc.radiusX, c.dc.radiusY, c.dc.de, c.dc.vd, !0),
            d.va(c.dc.ei.x, c.dc.ei.y),
            d.Sf(c.dc.di.x, c.dc.di.y, c.dc.radiusX, c.dc.radiusY, c.dc.vd, c.dc.de, !1),
            a.renderer.Ia(d, c.dc.brush, e));
            if (c.kv || c.sy)
                d = new gvjs_SA,
                d.move(c.eD.x, c.eD.y),
                d.va(c.rQ.x, c.rQ.y),
                d.va(c.rQ.x, c.rQ.y + k),
                d.va(c.eD.x, c.eD.y + k),
                d.va(c.eD.x, c.eD.y),
                a.renderer.Ia(d, c.qQ, e);
            gvjs_WK(a, c, e)
        }
        b.X_ && a.renderer.ce(b.text, b.U4.x + h.x, b.U4.y + h.y, b.iU.width, gvjs_2, gvjs_2, b.ja, e);
        h = gvjs_4E([gvjs_Zp, b.index]);
        e = e.j();
        a.we(a.Um, h, e);
        b.tooltip && (e = gvjs_4E([gvjs_Pd, b.index]),
        a.nK(b.tooltip, e))
    }
}
function gvjs_WK(a, b, c) {
    if (b.rt)
        a.renderer.Gl(b.di.x, b.di.y, b.radiusX, b.radiusY, b.brush, c);
    else {
        var d = new gvjs_SA;
        d.move(b.gf.x, b.gf.y);
        d.Sf(b.di.x, b.di.y, b.radiusX, b.radiusY, b.de, b.vd, !0);
        a.renderer.Ia(d, b.brush, c)
    }
}
function gvjs_VK(a, b) {
    var c = gvjs_s(a.mv, a)
      , d = gvjs_s(a.registerElement, a)
      , e = a.renderer;
    a = a.KQ;
    for (var f = 0; f < b.length; ++f) {
        var g = b[f]
          , h = e.Sa()
          , k = e.Sa()
          , l = new gvjs_SA;
        l.move(g.wp.x + .5, g.wp.y + .5);
        l.va(g.K8 + .5, g.wp.y + .5);
        l.va(g.K8 + .5, g.YH.y + .5);
        l.va(g.YH.x + .5, g.YH.y + .5);
        e.Ia(l, g.Oc, k);
        e.Ke(g.wp.x + .5, g.wp.y + .5, g.gga, g.Bxa, k);
        c(g.pB, h);
        c(g.EB, h);
        e.appendChild(a, h);
        e.appendChild(a, k);
        g = gvjs_4E([gvjs_zv, g.index]);
        d(h.j(), g)
    }
}
gvjs_.Dea = function(a, b) {
    if (!gvjs_Uz(b.Jq, this.Ms.Jq)) {
        this.renderer.qc(this.KQ);
        var c = new gvjs_9F(2);
        gvjs_$F(c, 0, a.Jq || {});
        gvjs_$F(c, 1, b.Jq || {});
        c = c.compact();
        gvjs_VK(this, c)
    }
    this.VK(a);
    this.TV(a, b)
}
;
gvjs_.VK = function(a) {
    var b = this.Ms;
    if (b)
        for (var c in b.C) {
            var d = Number(c);
            if (b.C[d].tooltip) {
                var e = gvjs_4E([gvjs_Pd, Number(d)]);
                gvjs_UG(this, e)
            }
            e = a.pie.Gd[d < a.C.length / a.pie.Gd.length ? 0 : 1];
            gvjs_UK(this, a.C[d], e.radiusX, e.radiusY)
        }
}
;
gvjs_.TV = function(a, b) {
    for (var c in b.C) {
        var d = Number(c)
          , e = new gvjs_9F(2);
        gvjs_$F(e, 0, a.C[d]);
        gvjs_$F(e, 1, b.C[d]);
        var f = a.pie.Gd[d < a.C.length / a.pie.Gd.length ? 0 : 1];
        d = f.radiusX;
        f = f.radiusY;
        gvjs_UK(this, e.compact(), d, f)
    }
}
;
function gvjs_XK(a, b, c, d, e) {
    gvjs_QI.call(this, a, b, c, d, e);
    this.Kb = b.fa(gvjs_2t, gvjs_MF);
    this.cga = gvjs_L(b, "pieStartAngle", 0);
    this.Ova = 0 > gvjs_L(b, gvjs_iu, 1);
    this.Nva = gvjs_K(b, gvjs_xw, !1);
    a = b.pb("pieSlicePercentFormat");
    gvjs_Py(a) && (a = {
        pattern: "#.#%"
    });
    this.Sua = new gvjs_gk(a);
    b = b.pb("pieSliceValueFormat");
    gvjs_Py(b) && (b = {
        pattern: gvjs_Nb
    });
    this.mha = new gvjs_gk(b)
}
gvjs_o(gvjs_XK, gvjs_QI);
gvjs_XK.prototype.nz = function() {
    var a = this;
    return [function() {
        a.V.Ig = new Set([gvjs_Mw]);
        a.V.kd = gvjs_K(a.options, "isDiff");
        a.V.$c &= !a.V.kd;
        a.V.kd && (a.V.Ih = a.V.Ih || {},
        a.V.Ih.pie = a.V.Ih.pie || {},
        a.V.Ih.pie.Kba = a.options.fa("diff.oldData.inCenter", !0),
        a.V.Ih.pie.F_ = a.options.fa("diff.innerCircle.radiusFactor", .6));
        for (var b = 0; b < a.lb.ca(); b++)
            if (0 > a.lb.getValue(b, 1))
                throw Error("Negative values are invalid for a pie chart.");
    }
    , gvjs_QI.prototype.nz.bind(this)]
}
;
gvjs_XK.prototype.N$ = function() {
    return gvjs_j
}
;
gvjs_XK.prototype.M$ = function() {
    return null
}
;
gvjs_XK.prototype.tN = function() {
    var a = this;
    return [function() {
        var b = a.ti();
        if (a.lb.W(0) != gvjs_l)
            throw Error("Pie chart should have a first column of type string");
        var c = a.V;
        var d = c.O
          , e = a.ne.getPosition()
          , f = null
          , g = Math.round(1.618 * c.Dl)
          , h = Math.round(d.width * (1 - 1 / 1.618) - g);
        e == gvjs_$c ? (f = new gvjs_B(d.top,d.left + h,d.bottom,d.left),
        e = new gvjs_B(d.top,d.right,d.bottom,f.right + g)) : e == gvjs_j ? (f = new gvjs_B(d.top,d.right,d.bottom,d.right - h),
        e = new gvjs_B(d.top,f.left - g,d.bottom,d.left)) : e == gvjs_xt ? (e = new gvjs_B(d.top,d.right,d.top + 1 / 1.618 * (d.bottom - d.top - g),d.left),
        f = new gvjs_B(e.bottom + g,d.right,d.bottom,d.left)) : e = new gvjs_B(d.top,d.right,d.bottom,d.left);
        d = 0;
        var k = h = Math.floor(Math.min(e.right - e.left, e.bottom - e.top) / 2);
        g = Math.round((e.right + e.left) / 2);
        e = Math.round((e.bottom + e.top) / 2);
        c.$c && (k *= .8,
        d = h / 5,
        e -= d / 2);
        if (c.kd) {
            var l = {
                radiusX: h * c.Ih.pie.F_,
                radiusY: k * c.Ih.pie.F_
            };
            h = {
                radiusX: h,
                radiusY: k
            };
            c = {
                pie: {
                    center: new gvjs_ok(g,e),
                    radiusX: h.radiusX,
                    radiusY: h.radiusY,
                    eE: d,
                    Gd: c.Ih.pie.Kba ? [l, h] : [h, l]
                },
                legend: f
            }
        } else
            c = {
                pie: {
                    center: new gvjs_ok(g,e),
                    radiusX: h,
                    radiusY: k,
                    eE: d,
                    Gd: [{
                        radiusX: h,
                        radiusY: k
                    }]
                },
                legend: f
            };
        gvjs_Rga(a, c);
        f = a.ne.getPosition();
        c.legend ? a.ne.qr(c.legend) : f == gvjs_vt ? (b = a.ne,
        c = b.qr,
        f = a.V,
        e = f.height - f.O.bottom,
        d = a.ne.Za.fontSize,
        h = [],
        h.push({
            min: 2,
            extra: [Infinity]
        }),
        g = h.length,
        h.push({
            min: d + 2,
            extra: [Infinity]
        }),
        e = gvjs_nA(h, e),
        e.length > g ? (g = f.O.bottom + e[g],
        f = new gvjs_B(g - d,f.O.right,g,f.O.left)) : f = null,
        c.call(b, f)) : f == gvjs_ov && gvjs_Sga(a, b.O, c, a.ne.Za)
    }
    ]
}
;
function gvjs_YK(a, b, c) {
    var d = a.V
      , e = {}
      , f = gvjs_oy(a.options, gvjs_gw, "");
    a = b.color;
    var g = b.qb;
    b = b.jh;
    if (d.$c) {
        d = a;
        var h = g;
        f = b
    } else
        h = d = f;
    e.Hd = new gvjs_3({
        stroke: d,
        strokeWidth: 1,
        fill: a,
        fillOpacity: null != c ? c : 1
    });
    e.qb = new gvjs_3({
        stroke: h,
        strokeWidth: 1,
        fill: g,
        fillOpacity: null != c ? c : 1
    });
    e.jh = new gvjs_3({
        stroke: f,
        strokeWidth: 1,
        fill: b,
        fillOpacity: null != c ? c : 1
    });
    return e
}
function gvjs_Rga(a, b) {
    function c(ma, da, ea, va, Z) {
        f.kd ? f.Vo.push({
            id: ma,
            text: da,
            brush: new gvjs_3({
                gradient: {
                    Vf: ea,
                    sf: ea,
                    tn: z[0],
                    un: z[1],
                    x1: gvjs_So,
                    y1: gvjs_Ro,
                    x2: gvjs_Ro,
                    y2: gvjs_Ro,
                    Sn: !0,
                    sp: !0
                }
            }),
            index: va,
            isVisible: Z
        }) : f.Vo.push({
            id: ma,
            text: da,
            brush: new gvjs_3({
                fill: ea
            }),
            index: va,
            isVisible: Z
        })
    }
    function d(ma) {
        var da = f.pie.Gd[ma - 1].cS
          , ea = f.pie.Gd[0].cS;
        1 == ma && da ? gvjs_ZK(da, r, da) : 1 < ma && (da && ea ? (gvjs_ZK(da, r, da, ea),
        gvjs_ZK(ea, r, da, ea)) : da ? (ea = {
            dE: "0",
            Me: "0"
        },
        gvjs_ZK(da, r, da, ea)) : ea && (da = {
            dE: "0",
            Me: "0"
        },
        gvjs_ZK(ea, r, da, ea)))
    }
    function e(ma, da, ea, va) {
        var Z = f.C[ma];
        1 == da ? null != ea ? Z.wd = {
            Nh: !!va,
            wi: !0,
            content: ea
        } : gvjs_ZK(Z, r, Z) : (ma = f.C[ma - l],
        gvjs_ZK(Z, r, Z, ma),
        gvjs_ZK(ma, r, Z, ma))
    }
    var f = a.V
      , g = a.lb
      , h = b.pie.center
      , k = b.pie.eE
      , l = g.ca()
      , m = gvjs_5F(gvjs_oy(a.options, "pieResidueSliceColor", ""))
      , n = gvjs_YK(a, m, 1)
      , p = gvjs_ry(a.options, "pieSliceTextStyle", {
        bb: f.Hj,
        fontSize: f.Dl
    })
      , q = gvjs_J(a.options, gvjs_hw, f.kd ? gvjs_f : gvjs_ew, gvjs_9da)
      , r = gvjs_J(a.options, "tooltip.text", gvjs_ut, gvjs_kC)
      , t = gvjs_ny(a.options, "sliceVisibilityThreshold", 1 / 720)
      , u = gvjs_K(a.options, "displayTinySlicesInLegend")
      , v = gvjs_J(a.options, "pieResidueSliceLabel", "Other")
      , w = gvjs_ny(a.options, "pieHole", 0);
    f.C = [];
    f.Vo = [];
    if (f.kd) {
        var x = a.options.fa("diff.innerCircle.borderFactor", .01);
        x = f.Ih.pie.F_ * (1 + x);
        x = f.Ih.pie.Kba ? [0, x] : [x, 0];
        var y = [!1, !0];
        var z = [a.options.fa(gvjs_hu, .5), a.options.fa(gvjs_gu, 1)]
    } else
        x = [0],
        y = [!0],
        z = [1];
    f.pie = {
        center: h,
        eE: k,
        radiusX: b.pie.radiusX,
        radiusY: b.pie.radiusY,
        Gd: []
    };
    k = f.pie.Gd;
    b = b.pie.Gd;
    for (var A = b.length, B = 0, D = 0; D < A; ++D) {
        var C = b[D]
          , G = null
          , J = C.radiusX;
        C = C.radiusY;
        for (var I = x[D], M = y[D], H = 0, Q = 0, R = 0, T = 0; T < l; T++)
            R += g.getValue(T, D + 1) || 0;
        for (T = 0; T < l; ++T) {
            var O = a.Nva ? l - T - 1 : T
              , K = 1 === A && g.$() > D + 2 && g.Jg(D + 2) === gvjs_Pd && g.W(D + 2) === gvjs_l
              , E = f.$f && K && !(!g.getProperty(O, D + 2, gvjs_av) && !g.Bd(D + 2, gvjs_av))
              , F = g.getValue(O, D + 1) || 0
              , L = g.Ha(O, D + 1, a.mha)
              , N = g.getValue(O, 0)
              , P = g.Ha(O, 0)
              , S = 0 === R ? 0 : Q / R
              , U = 0 === R ? 0 : S + F / R
              , fa = U - S >= t;
            K = K && g.getStringValue(O, D + 2) || null;
            fa ? Q += F : H += F;
            var V = "slices." + B
              , pa = a.options.fa(V + ".color", a.Kb[T % a.Kb.length]);
            pa = gvjs_5F(pa);
            var W = gvjs_YK(a, pa, z[D])
              , ja = gvjs_L(a.options, V + ".offset", 0)
              , ia = gvjs_ny(a.options, V + ".hole", w) + I
              , Da = gvjs_ry(a.options, V + ".textStyle", p)
              , Ea = gvjs_K(a.options, [V + gvjs_Lr, gvjs_ru], !0);
            O = gvjs__K(a, B, O, S, U, F, L, P, fa, h, J, C, ia, ja, q, Da, pa, W, Ea);
            f.C.push(O);
            fa = gvjs_K(a.options, V + ".visibleInLegend", M && (fa || u));
            c(N, P, pa.color, B, fa);
            D == A - 1 && e(B, A, K, E);
            B += 1
        }
        0 < H && (G = 1 - (0 === R ? 0 : H / R),
        Q = H,
        R = a.mha.Ob(H),
        H = v,
        G = gvjs__K(a, -1, -1, G, 1, Q, R, H, !0, h, J, C, w + I, 0, q, p, m, n, !1),
        M && !u && c("", H, m.color, -1, !0));
        k.push({
            radiusX: J,
            radiusY: C,
            cS: G
        });
        D == A - 1 && d(A)
    }
}
function gvjs_0K(a, b) {
    switch (b) {
    case gvjs_ew:
        return a.dE;
    case gvjs_Vd:
        return a.Me;
    case gvjs_ut:
        return a.Me + " (" + a.dE + ")"
    }
    return ""
}
function gvjs__K(a, b, c, d, e, f, g, h, k, l, m, n, p, q, r, t, u, v, w) {
    var x = a.V;
    if (x.$c || 1 <= p)
        p = 0;
    var y = {}
      , z = e - d;
    y.value = f;
    y.Me = g;
    y.color = u;
    y.Rb = v;
    y.brush = y.Rb.Hd;
    y.title = h;
    y.index = b;
    y.Yg = w;
    y.Cs = 0 <= c ? a.lb.fj(c) : null;
    y.isVisible = k;
    b = m * p;
    p *= n;
    y.eJ = b;
    y.gD = p;
    y.de = 360 * d + a.cga;
    y.vd = 360 * e + a.cga;
    a.Ova && (c = 360 - y.de,
    y.de = 360 - y.vd,
    y.vd = c);
    c = Math.PI * (y.de - 90) / 180;
    f = Math.PI * (y.vd - 90) / 180;
    y.dE = a.Sua.Ob(z);
    h = "";
    switch (r) {
    case gvjs_ew:
        h = y.dE;
        break;
    case gvjs_8c:
        h = y.title;
        break;
    case gvjs_Vd:
        h = g;
        break;
    case gvjs_Ix:
        h = g + " (" + y.dE + ")"
    }
    y.text = h;
    if (!k)
        return y;
    y.ja = t;
    a = a.sc(y.text, t).width;
    t = t.fontSize;
    y.iU = new gvjs_A(a,t);
    y.rt = 1 == z;
    if (y.text)
        if (y.rt)
            y.U4 = gvjs_fA(l, new gvjs_ok(a / 2,t / 2)),
            y.X_ = !0;
        else {
            z = m - t;
            t = n - t;
            a = y.iU;
            a = new gvjs_A(a.width / z,a.height / t);
            g = new gvjs_A(2 / z,2 / t);
            k = gvjs_3I((c + f) / 2 + Math.PI, 1, 1);
            b: {
                r = gvjs_4I(new gvjs_ok(0,0), a);
                h = 1;
                u = Math.min;
                for (v = 0; v < r.length; ++v) {
                    var A = r[v];
                    w = k.x * A.x + k.y * A.y;
                    A = w * w + 1 - (A.x * A.x + A.y * A.y);
                    0 > A ? w = null : (A = Math.sqrt(A),
                    w = [w - A, w + A]);
                    if (null === w || 0 > w[1]) {
                        r = null;
                        break b
                    }
                    h = u(h, w[1])
                }
                r = h
            }
            if (.4 > r)
                a = null;
            else {
                k = k.clone();
                k.scale(-r);
                a = gvjs_Vfa(a, g, g);
                b: {
                    a = gvjs_4I(k, a);
                    g = gvjs_3y(f - c, 2 * Math.PI);
                    r = 0;
                    h = g;
                    for (u = 0; u < a.length; ++u) {
                        v = gvjs_3y(Math.atan2(a[u].y, a[u].x) - c, 2 * Math.PI);
                        if (v >= g || 0 == v) {
                            a = !1;
                            break b
                        }
                        h = Math.min(v, h);
                        r = Math.max(v, r)
                    }
                    a = r - h < Math.PI
                }
                a = a ? k : null
            }
            z = a && new gvjs_ok(a.x * z,a.y * t);
            null !== z && (y.X_ = !0,
            y.U4 = gvjs_Ufa(l, z, new gvjs_ok(-y.iU.width / 2,-y.iU.height / 2)))
        }
    else
        y.X_ = !1;
    y.offset = gvjs_3I((c + f) / 2, m, n).scale(q);
    q = gvjs_3I(f, m, n);
    y.gf = gvjs_eA(l, gvjs_3I(c, m, n));
    y.ei = gvjs_eA(l, q);
    n = gvjs_3I(f, b, p);
    y.fD = gvjs_eA(l, gvjs_3I(c, b, p));
    y.Uv = gvjs_eA(l, n);
    x.$c && 270 >= y.de && 90 <= y.vd && (n = {},
    90 > y.de ? (n.de = 90,
    n.gf = new gvjs_ok(l.x + m,l.y)) : (n.de = y.de,
    n.gf = y.gf),
    270 < y.vd ? (n.vd = 270,
    n.ei = new gvjs_ok(l.x - m,l.y)) : (n.vd = y.vd,
    n.ei = y.ei),
    n.brush = y.Rb.qb,
    y.dc = n);
    y.kv = x.$c && .5 < d;
    y.sy = x.$c && .5 > e;
    if (y.kv || y.sy)
        y.qQ = y.Rb.qb;
    return y
}
function gvjs_ZK(a, b, c, d) {
    c = gvjs_0K(c, b);
    d && (c += "\n" + gvjs_0K(d, b));
    a.wd = {
        En: a.title,
        content: c
    }
}
function gvjs_Sga(a, b, c, d) {
    var e = a.V
      , f = e.pie.radiusX
      , g = e.pie.radiusY
      , h = c.pie.center
      , k = gvjs_J(a.options, "legend.labeledValueText", gvjs_ew, gvjs_kC)
      , l = Math.PI * (3 * (f + g) - Math.sqrt((3 * f + g) * (f + 3 * g)))
      , m = [];
    c = [];
    for (var n = {}, p = 0; p < e.Vo.length; n = {
        zM: n.zM,
        PF: n.PF,
        QF: n.QF,
        AM: n.AM
    },
    ++p) {
        var q = e.Vo[p];
        if (q.isVisible) {
            var r = void 0;
            if (0 <= q.index)
                r = e.C[q.index];
            else {
                var t = e.pie.Gd;
                r = t[t.length - 1].cS
            }
            n.zM = Math.max((f + r.eJ) / 2, .75 * f);
            n.PF = Math.max((g + r.gD) / 2, .75 * g);
            var u = (r.vd + r.de) / 2;
            t = gvjs_5y(u);
            var v = gvjs_bz(f - n.zM, g - n.PF) / l * 360
              , w = void 0
              , x = void 0;
            2 * v < r.vd - r.de ? (w = r.de + v,
            x = r.vd - v,
            180 > t ? x = Math.min(x, 180) : w = Math.max(w, 180)) : x = w = u;
            n.QF = function(A) {
                return function(B) {
                    return gvjs_eA(h, gvjs_3I(B, A.zM, A.PF))
                }
            }(n);
            var y = function(A) {
                return function(B) {
                    return A.QF(gvjs_6y(B - 90))
                }
            }(n);
            n.AM = function(A) {
                return function(B) {
                    return Math.asin(gvjs_0g((B - h.y) / A.PF, -1, 1))
                }
            }(n);
            v = function(A) {
                return function(B) {
                    return A.QF(A.AM(B))
                }
            }(n);
            var z = function(A) {
                return function(B) {
                    return A.QF(Math.PI - A.AM(B))
                }
            }(n);
            q = {
                oea: y(u).y,
                aS: new gvjs_O(y(w).y,y(x).y),
                pB: q.text,
                EB: gvjs_0K(r, k),
                kba: r.value,
                index: r.index
            };
            180 > t ? (q.Rda = v,
            m.push(q)) : (q.Rda = z,
            c.push(q))
        }
    }
    f = b.width / 2 - f - d.fontSize;
    e = gvjs_RK(new gvjs_B(b.top,b.right,b.bottom,b.right - f), a.sc, 2, d, m);
    b = gvjs_RK(new gvjs_B(b.top,b.left + f,b.bottom,b.left), a.sc, 1, d, c);
    d = [];
    gvjs_Me(d, e, b);
    a.V.Jq = d
}
;function gvjs_1K(a, b, c) {
    gvjs_PJ.call(this, a, b, c, gvjs_fw)
}
gvjs_t(gvjs_1K, gvjs_PJ);
gvjs_1K.prototype.Gs = function(a) {
    return this.renderer.xv(a.target)
}
;
gvjs_1K.prototype.v9 = function(a, b) {
    b = b.split("#");
    switch (b[0]) {
    case gvjs_Zp:
        b = Number(b[1]),
        0 > b || this.dispatchEvent("serie" + a, {
            Vb: b,
            Kk: null
        })
    }
}
;
function gvjs_2K(a, b, c, d, e, f, g) {
    gvjs_hK.call(this, a, b, c, d, e, g);
    var h = gvjs_K(a, gvjs_ru, !0);
    this.Dna = gvjs_lA(f, function(k) {
        return gvjs_K(a, "slices." + k + gvjs_Lr, h)
    });
    this.Vwa = gvjs_K(a, "shouldHighlightHover", !0)
}
gvjs_o(gvjs_2K, gvjs_hK);
gvjs_2K.prototype.Us = function(a, b, c) {
    this.QX(a, b, c)
}
;
gvjs_2K.prototype.xY = function(a, b) {
    return a.equals(b, !0)
}
;
function gvjs_3K(a, b) {
    a.C = a.C || {};
    a = a.C;
    a[b] = a[b] || {};
    return a[b]
}
gvjs_2K.prototype.QX = function(a, b, c) {
    function d(q, r) {
        if (null != q) {
            if (a.kd) {
                var t = a.C.length;
                t = [q, (q + t / a.pie.Gd.length) % t]
            } else
                t = [q];
            for (var u = !1, v = 0; v < t.length; ++v) {
                var w = t[v];
                null != w && e.Dna[w] && (u = u || !0,
                a.kd || e.Vwa && gvjs_Tga(a, w, c),
                a.Jq && (c.Jq = gvjs_Qga(a.Jq, w)))
            }
            r && k && u && gvjs_4K(e, f, q)
        }
    }
    var e = this
      , f = {
        Ea: a,
        yk: this.le.getEntries(),
        Yv: c,
        zk: b.gi
    }
      , g = b.gi.focused.wy;
    null != g && (b.gi.focused.action = this.le.ng(g).action);
    var h = this.Cp.u5;
    g = h == gvjs_Jw || h == gvjs_ut;
    var k = h == gvjs_xu || h == gvjs_ut
      , l = this.le && 0 < f.yk.length;
    h = gvjs_bo(b.selected);
    l = 1 < h.length && l;
    for (var m = 0; m < h.length; ++m) {
        var n = h[m]
          , p = a.pie.Gd.length;
        n += a.C.length / p * (p - 1);
        gvjs_Uga(a, n, c);
        g && !l && gvjs_4K(this, f, n)
    }
    g && l && gvjs_Vga(this, f, h, h[h.length - 1]);
    if (g = b.Ii)
        c.Ii = g;
    d(b.focused.Hb, !0);
    d(b.legend.focused.Xc, !1)
}
;
function gvjs_Tga(a, b, c) {
    var d = a.pie
      , e = a.C[b];
    if (null != e.offset) {
        c = gvjs_3K(c, b);
        c.Ko = {};
        b = c.Ko;
        b.brush = new gvjs_3({
            stroke: e.brush.fill,
            strokeWidth: 6.5,
            strokeOpacity: .3
        });
        b.di = new gvjs_z(d.center.x + e.offset.x,d.center.y + e.offset.y);
        b.de = e.de;
        b.vd = e.vd;
        b.rt = e.rt;
        (c = c.nj) && a.Mfa ? (a = c.radiusX + c.brush.strokeWidth / 2,
        c = c.radiusY + c.brush.strokeWidth / 2) : (c = e.brush.strokeWidth / 2,
        a = d.radiusX + c,
        c = d.radiusY + c);
        d = b.brush.strokeWidth / 2;
        b.radiusX = a + d;
        b.radiusY = c + d;
        a = gvjs_6y(b.de - 90);
        c = gvjs_6y(b.vd - 90);
        b.gf = gvjs_ez(b.di, gvjs_3I(a, b.radiusX, b.radiusY));
        b.ei = gvjs_ez(b.di, gvjs_3I(c, b.radiusX, b.radiusY));
        var f = e.dc;
        f && (b.dc = b.dc || {},
        b.dc.brush = gvjs_8z(f.brush.fill, .3),
        b.dc.di = b.di.clone(),
        b.dc.de = f.de,
        b.dc.vd = f.vd,
        b.dc.radiusX = b.radiusX + d,
        b.dc.radiusY = b.radiusY + d,
        a = gvjs_6y(b.dc.de - 90),
        c = gvjs_6y(b.dc.vd - 90),
        b.dc.gf = gvjs_ez(b.dc.di, gvjs_3I(a, b.dc.radiusX, b.dc.radiusY)),
        b.dc.ei = gvjs_ez(b.dc.di, gvjs_3I(c, b.dc.radiusX, b.dc.radiusY)));
        b.kv = e.kv;
        b.sy = e.sy;
        if (b.kv || b.sy)
            b.qQ = gvjs_8z(e.qQ.fill, .3),
            b.pva = b.kv ? a : c,
            e = function(g, h) {
                return gvjs_ez(g.di, gvjs_3I(g.pva, g.radiusX + h * g.brush.strokeWidth / 2, g.radiusY + h * g.brush.strokeWidth / 2))
            }
            ,
            b.eD = e(b, -1),
            b.rQ = e(b, 1)
    }
}
function gvjs_Uga(a, b, c) {
    var d = a.pie;
    0 < d.eE || (a = a.C[b],
    null != a.offset && (b = gvjs_3K(c, b),
    b.nj = {},
    b = b.nj,
    b.brush = gvjs_9z(a.brush.fill, 2),
    b.di = new gvjs_z(d.center.x + a.offset.x,d.center.y + a.offset.y),
    b.de = a.de,
    b.vd = a.vd,
    b.rt = a.rt,
    a = a.brush.strokeWidth / 2 + 2.5 + b.brush.strokeWidth / 2,
    b.radiusX = d.radiusX + a,
    b.radiusY = d.radiusY + a,
    d = gvjs_6y(b.vd - 90),
    b.gf = gvjs_ez(b.di, gvjs_3I(gvjs_6y(b.de - 90), b.radiusX, b.radiusY)),
    b.ei = gvjs_ez(b.di, gvjs_3I(d, b.radiusX, b.radiusY))))
}
function gvjs_4K(a, b, c) {
    var d = gvjs_3K(b.Yv, c);
    if (c = gvjs_fK(a.Cp, b, c, null, null))
        d.tooltip = c,
        b.zk && a.le.Us(c, b.zk, d.tooltip)
}
function gvjs_Vga(a, b, c, d) {
    var e = gvjs_3K(b.Yv, d);
    var f = a.Cp;
    var g = b.Ea
      , h = b.Ea.C[d];
    d = gvjs_8J(g, h);
    h = gvjs_cK(g, h);
    c = gvjs_rga(f.es, b, c);
    f = gvjs_kG(c, g.sc, !0, d, f.af, h, void 0, g.$f, g.bw, g.ax);
    e.tooltip = f;
    b.zk && a.le.Us(f, b.zk, e.tooltip)
}
;function gvjs_Wga(a) {
    return Math.pow(a, 3)
}
function gvjs_Xga(a) {
    return 1 - Math.pow(1 - a, 3)
}
function gvjs_Yga(a) {
    return 3 * a * a - 2 * a * a * a
}
;var gvjs_Zga = {
    LINEAR: gvjs_Hp,
    sAa: gvjs_Fp,
    YAa: gvjs_aw,
    xAa: gvjs_cv
};
function gvjs__ga(a) {
    switch (a) {
    case gvjs_Hp:
        return gvjs_Wx;
    case gvjs_Fp:
        return gvjs_Wga;
    case gvjs_aw:
        return gvjs_Xga;
    case gvjs_cv:
        return gvjs_Yga;
    default:
        return gvjs_Wx
    }
}
function gvjs_5K(a, b, c) {
    var d = gvjs_K(a, "animation.startup", !1);
    b = gvjs_Oj(a, gvjs_Ws, b);
    if (!b)
        return null;
    var e = gvjs_Oj(a, "animation.maxFramesPerSecond", 30);
    a = gvjs_J(a, "animation.easing", c, gvjs_Zga);
    return {
        iga: d,
        duration: b,
        easing: gvjs__ga(a),
        HD: e
    }
}
;function gvjs_6K(a, b) {
    this.kI = a || [];
    gvjs_0ga(this, b)
}
function gvjs_7K() {
    return function(a, b) {
        return b === gvjs_yp && typeof a === gvjs_l && !gvjs_He(gvjs_1ga, a.toLowerCase())
    }
}
function gvjs_0ga(a, b) {
    var c = gvjs_p.WebFont;
    0 !== a.kI.length && c ? c.load({
        google: {
            families: a.kI
        },
        active: function() {
            b.resolve()
        },
        fontinactive: function() {
            b.reject("One or more fonts could not be loaded")
        }
    }) : b.resolve(null)
}
var gvjs_1ga = [gvjs_ft, "comic sans ms", "courier new", "georgia", "impact", "times new roman", "trebuchet ms", "verdana"];
function gvjs_2ga(a, b) {
    this.Qv = a;
    this.vertical = b
}
;function gvjs_3ga(a, b, c, d, e, f) {
    var g = a.jd[0] ? 0 : 1
      , h = a.wc[0] ? 0 : 1
      , k = a.jd[g];
    a = a.wc[h];
    var l = k.dataType && gvjs_7H(k.dataType).toNumber
      , m = a.dataType && gvjs_7H(a.dataType).toNumber;
    this.ew = b;
    this.DC = gvjs_s(function(n) {
        return l ? l(this.ew.getHAxisValue(n, g)) : n
    }, this);
    this.MC = gvjs_s(function(n) {
        return m ? m(this.ew.getVAxisValue(n, h)) : n
    }, this);
    b = this.ew.getChartAreaBoundingBox();
    this.Rq = this.DC(b.left);
    this.Sq = this.MC(b.top + b.height);
    this.Et = this.DC(b.left + b.width);
    this.Ft = this.MC(b.top);
    this.YR = this.Rq;
    this.ZR = this.Sq;
    this.XR = this.Et - this.Rq;
    this.WR = this.Ft - this.Sq;
    this.scale = 1;
    this.hta = c;
    this.P0 = d;
    this.Mha = e;
    this.EQ = f
}
;function gvjs_8K(a, b, c, d) {
    this.Wm = c;
    this.Ra = a;
    this.dj = b;
    this.Wg = null;
    this.gk = d;
    this.gk.subscribe(gvjs_i, gvjs_s(this.Bq, this))
}
gvjs_8K.prototype.FT = function(a) {
    this.Wg = a
}
;
gvjs_8K.prototype.getState = function() {
    return this.Ra
}
;
gvjs_8K.prototype.Bq = function() {}
;
gvjs_8K.prototype.updateOptions = function() {
    var a = {
        hAxis: {
            viewWindowMode: gvjs_su,
            viewWindow: {}
        },
        vAxis: {
            viewWindowMode: gvjs_su,
            viewWindow: {}
        }
    };
    this.Wm.Qv && (isNaN(this.Wg.Rq) || (a.hAxis.viewWindow.numericMin = this.Wg.Rq),
    isNaN(this.Wg.Et) || (a.hAxis.viewWindow.numericMax = this.Wg.Et));
    this.Wm.vertical && (isNaN(this.Wg.Sq) || (a.vAxis.viewWindow.numericMin = this.Wg.Sq),
    isNaN(this.Wg.Ft) || (a.vAxis.viewWindow.numericMax = this.Wg.Ft));
    this.Ra.gm = a
}
;
function gvjs_9K(a, b) {
    return gvjs_0g(a.x, b.left, b.left + b.width) === a.x && gvjs_0g(a.y, b.top, b.top + b.height) === a.y ? !0 : !1
}
;function gvjs_$K(a, b, c, d) {
    gvjs_8K.call(this, a, b, c, d);
    this.Dz = null
}
gvjs_o(gvjs_$K, gvjs_8K);
gvjs_ = gvjs_$K.prototype;
gvjs_.Bq = function() {
    var a = this.gk;
    a.subscribe(gvjs_pu, gvjs_s(this.TZ, this));
    a.subscribe(gvjs_nu, gvjs_s(this.RZ, this));
    a.subscribe(gvjs_ou, gvjs_s(this.SZ, this));
    a.subscribe(gvjs_4v, gvjs_s(this.Cf, this))
}
;
gvjs_.TZ = function(a) {
    var b = this.dj().getChartAreaBoundingBox();
    gvjs_9K(a, b) && (this.Dz = new gvjs_ok(a.x,a.y))
}
;
gvjs_.RZ = function(a) {
    this.Dz && (this.C5(a.x, a.y),
    this.Dz.x = a.x,
    this.Dz.y = a.y)
}
;
gvjs_.SZ = function() {
    this.Dz = null
}
;
gvjs_.Cf = function(a, b) {
    var c = this.dj().getChartAreaBoundingBox();
    gvjs_9K(a, c) && b()
}
;
gvjs_.C5 = function(a, b) {
    var c = this.Wg;
    if (c) {
        var d = this.dj();
        c.ew = d;
        var e = this.Wm;
        if (e.Qv) {
            var f = c.DC(a) - c.DC(this.Dz.x)
              , g = c.Rq - f
              , h = c.Et - f;
            a = Math.max(g, c.YR);
            d = Math.min(h, c.YR + c.XR);
            if (c.EQ && (a === g || 0 > f) && (d === h || 0 < f) || !c.EQ)
                c.Rq = g,
                c.Et = h
        }
        e.vertical && (b = c.MC(b) - c.MC(this.Dz.y),
        e = c.Sq - b,
        f = c.Ft - b,
        a = Math.max(e, c.ZR),
        d = Math.min(f, c.ZR + c.WR),
        c.EQ && (a === e || 0 > b) && (d === f || 0 < b) || !c.EQ) && (c.Sq = e,
        c.Ft = f);
        this.updateOptions()
    }
}
;
function gvjs_aL(a, b, c, d) {
    gvjs_8K.call(this, a, b, c, d);
    this.Uw = null
}
gvjs_o(gvjs_aL, gvjs_8K);
gvjs_ = gvjs_aL.prototype;
gvjs_.Bq = function() {
    var a = this.gk;
    a.subscribe(gvjs_pu, gvjs_s(this.TZ, this));
    a.subscribe(gvjs_nu, gvjs_s(this.RZ, this));
    a.subscribe(gvjs_ou, gvjs_s(this.SZ, this));
    a.subscribe(gvjs_4v, gvjs_s(this.Cf, this))
}
;
gvjs_.TZ = function(a) {
    var b = this.dj().getChartAreaBoundingBox();
    gvjs_9K(a, b) && (this.Uw = new gvjs_ok(a.x,a.y))
}
;
gvjs_.RZ = function(a) {
    if (this.Uw) {
        var b = this.dj().getChartAreaBoundingBox()
          , c = this.Wm;
        this.mva(a, b);
        if (c.Qv)
            var d = Math.min(this.Uw.x, a.x)
              , e = Math.abs(this.Uw.x - a.x);
        else
            d = b.left,
            e = b.width;
        c.vertical ? (c = Math.min(this.Uw.y, a.y),
        a = Math.abs(this.Uw.y - a.y)) : (c = b.top,
        a = b.height);
        this.getState().Ii = {
            left: d,
            top: c,
            width: e,
            height: a,
            color: "blue",
            opacity: .2
        }
    }
}
;
gvjs_.SZ = function() {
    this.Uw && (this.C5(),
    this.Uw = null)
}
;
gvjs_.Cf = function(a, b) {
    var c = this.dj().getChartAreaBoundingBox();
    gvjs_9K(a, c) && b()
}
;
gvjs_.C5 = function() {
    var a = this.Wm
      , b = this.Wg
      , c = this.dj();
    b.ew = c;
    var d = this.getState().Ii
      , e = b.DC(d.left)
      , f = b.DC(d.left + d.width);
    c = b.MC(d.top);
    d = b.MC(d.top + d.height);
    if (e !== f && c !== d) {
        var g = b.XR * b.P0;
        if (a.Qv) {
            var h = Math.min(e, f);
            e = Math.max(e, f);
            e - h < g && (e = (h + e) / 2,
            h = e - g / 2,
            e += g / 2);
            b.Rq = h;
            b.Et = e
        }
        g = b.WR * b.P0;
        a.vertical && (a = Math.min(c, d),
        c = Math.max(c, d),
        c - a < g && (e = (a + c) / 2,
        a = e - g / 2,
        c = e + g / 2),
        b.Sq = a,
        b.Ft = c);
        this.updateOptions()
    }
}
;
gvjs_.mva = function(a, b) {
    a.x = gvjs_0g(a.x, b.left, b.left + b.width);
    a.y = gvjs_0g(a.y, b.top, b.top + b.height)
}
;
function gvjs_bL(a, b, c, d) {
    gvjs_8K.call(this, a, b, c, d)
}
gvjs_o(gvjs_bL, gvjs_8K);
gvjs_bL.prototype.Bq = function() {
    this.gk.subscribe(gvjs_Aw, gvjs_s(this.Qqa, this))
}
;
gvjs_bL.prototype.Qqa = function() {
    var a = this.Wg;
    a.scale = 1;
    a.Rq = a.YR;
    a.Et = a.YR + a.XR;
    a.Sq = a.ZR;
    a.Ft = a.ZR + a.WR;
    this.updateOptions()
}
;
function gvjs_cL(a, b, c, d) {
    gvjs_8K.call(this, a, b, c, d)
}
gvjs_o(gvjs_cL, gvjs_8K);
gvjs_cL.prototype.Bq = function() {
    this.gk.subscribe(gvjs_Gw, gvjs_s(this.Sqa, this))
}
;
gvjs_cL.prototype.Sqa = function(a, b) {
    var c = this.Wm
      , d = this.dj().getChartAreaBoundingBox();
    gvjs_9K(a, d) && (b(),
    b = this.Wg,
    a = 0 > a.wheelDelta ? b.scale * b.Mha : b.scale / b.Mha,
    a = gvjs_0g(a, b.P0, b.hta),
    a !== b.scale && (b.scale = a,
    c.Qv && (a = (b.Et + b.Rq) / 2,
    d = b.XR * b.scale / 2,
    b.Rq = a - d,
    b.Et = a + d),
    c.vertical && (c = (b.Ft + b.Sq) / 2,
    a = b.WR * b.scale / 2,
    b.Sq = c - a,
    b.Ft = c + a),
    this.updateOptions()))
}
;
function gvjs_dL(a, b, c, d, e) {
    if (c.fa(gvjs_Sd) === gvjs_fw)
        throw Error("Cannot use explorer with a pie chart");
    this.Ra = a;
    this.dj = b;
    this.m = c;
    this.ha = d;
    this.gk = e;
    this.Wg = this.Wm = null;
    this.R9 = [];
    this.init()
}
gvjs_dL.prototype.Bq = function() {
    var a = gvjs_L(this.m, "explorer.maxZoomOut", 4);
    1 > a && (a = 1 / a);
    var b = gvjs_L(this.m, "explorer.maxZoomIn", .25);
    1 < b && (b = 1 / b);
    var c = gvjs_L(this.m, "explorer.zoomDelta", 1.5)
      , d = gvjs_K(this.m, "explorer.keepInBounds", !1);
    this.Wg = new gvjs_3ga(this.ha,this.dj(),a,b,c,d);
    gvjs_u(this.R9, function(e) {
        e.FT(this.Wg)
    }, this)
}
;
gvjs_dL.prototype.init = function() {
    var a = this.ha.jd[0] ? 0 : 1
      , b = this.ha.wc[0] ? 0 : 1
      , c = this.ha.jd[a]
      , d = this.ha.wc[b];
    a = !this.ha.jd[1 - a] && c.type === gvjs_Vd && !c.Mq;
    b = !this.ha.wc[1 - b] && d.type === gvjs_Vd && !d.Mq;
    d = this.m.fa(gvjs_tu).axis;
    d === gvjs_S ? b = !1 : d === gvjs_U && (a = !1);
    this.Wm = new gvjs_2ga(a,b);
    b = this.R9;
    d = this.m.fa(gvjs_uu);
    (null == d || Array.isArray(d) && gvjs_He(d, "dragToPan")) && b.push(new gvjs_$K(this.Ra,this.dj,this.Wm,this.gk));
    d = this.m.fa(gvjs_uu);
    Array.isArray(d) && gvjs_He(d, "dragToZoom") && b.push(new gvjs_aL(this.Ra,this.dj,this.Wm,this.gk));
    d = this.m.fa(gvjs_uu);
    (null == d || Array.isArray(d) && gvjs_He(d, "rightClickToReset")) && b.push(new gvjs_bL(this.Ra,this.dj,this.Wm,this.gk));
    d = this.m.fa(gvjs_uu);
    Array.isArray(d) && gvjs_He(d, "pinchToZoom");
    d = this.m.fa(gvjs_uu);
    (null == d || Array.isArray(d) && gvjs_He(d, "scrollToZoom")) && b.push(new gvjs_cL(this.Ra,this.dj,this.Wm,this.gk));
    this.gk.subscribe(gvjs_i, gvjs_s(this.Bq, this))
}
;
function gvjs_eL(a) {
    gvjs_F.call(this);
    this.xz = 1;
    this.jS = [];
    this.qS = 0;
    this.kl = [];
    this.Hr = {};
    this.Bka = !!a
}
gvjs_t(gvjs_eL, gvjs_F);
gvjs_ = gvjs_eL.prototype;
gvjs_.subscribe = function(a, b, c) {
    var d = this.Hr[a];
    d || (d = this.Hr[a] = []);
    var e = this.xz;
    this.kl[e] = a;
    this.kl[e + 1] = b;
    this.kl[e + 2] = c;
    this.xz = e + 3;
    d.push(e);
    return e
}
;
gvjs_.unsubscribe = function(a, b, c) {
    if (a = this.Hr[a]) {
        var d = this.kl;
        if (a = a.find(function(e) {
            return d[e + 1] == b && d[e + 2] == c
        }))
            return this.B5(a)
    }
    return !1
}
;
gvjs_.B5 = function(a) {
    var b = this.kl[a];
    if (b) {
        var c = this.Hr[b];
        0 != this.qS ? (this.jS.push(a),
        this.kl[a + 1] = gvjs_ke) : (c && gvjs_Ie(c, a),
        delete this.kl[a],
        delete this.kl[a + 1],
        delete this.kl[a + 2])
    }
    return !!b
}
;
gvjs_.xn = function(a, b) {
    var c = this.Hr[a];
    if (c) {
        for (var d = Array(arguments.length - 1), e = 1, f = arguments.length; e < f; e++)
            d[e - 1] = arguments[e];
        if (this.Bka)
            for (e = 0; e < c.length; e++) {
                var g = c[e];
                gvjs_4ga(this.kl[g + 1], this.kl[g + 2], d)
            }
        else {
            this.qS++;
            try {
                for (e = 0,
                f = c.length; e < f && !this.xf; e++)
                    g = c[e],
                    this.kl[g + 1].apply(this.kl[g + 2], d)
            } finally {
                if (this.qS--,
                0 < this.jS.length && 0 == this.qS)
                    for (; c = this.jS.pop(); )
                        this.B5(c)
            }
        }
        return 0 != e
    }
    return !1
}
;
function gvjs_4ga(a, b, c) {
    gvjs_5k(function() {
        a.apply(b, c)
    })
}
gvjs_.clear = function(a) {
    if (a) {
        var b = this.Hr[a];
        b && (b.forEach(this.B5, this),
        delete this.Hr[a])
    } else
        this.kl.length = 0,
        this.Hr = {}
}
;
gvjs_.Cd = function(a) {
    if (a) {
        var b = this.Hr[a];
        return b ? b.length : 0
    }
    a = 0;
    for (b in this.Hr)
        a += this.Cd(b);
    return a
}
;
gvjs_.M = function() {
    gvjs_eL.G.M.call(this);
    this.clear();
    this.jS.length = 0
}
;
function gvjs_fL(a, b, c, d) {
    this.m = a;
    this.K = b;
    this.dj = c;
    this.ha = d;
    this.Kna = [];
    this.zb = null;
    this.gk = new gvjs_eL;
    this.init()
}
gvjs_fL.prototype.init = function() {
    gvjs_r(this.m.fa(gvjs_tu)) && this.Kna.push(new gvjs_dL(this.K,this.dj,this.m,this.ha,this.gk))
}
;
gvjs_fL.prototype.xn = function(a, b) {
    var c = gvjs_5ga[a];
    c && this.zb && !this.zb.xf && gvjs_LK(this.zb, c);
    c = Array(arguments.length);
    c[0] = a;
    for (var d = 1, e = arguments.length; d < e; d++)
        c[d] = arguments[d];
    this.gk.xn.apply(this.gk, c)
}
;
var gvjs_5ga = {
    dragstart: 15,
    drag: 5,
    dragend: 5,
    scroll: 5,
    rightclick: 5,
    pinch: 5,
    pinchend: 15
};
function gvjs_gL(a) {
    for (var b = gvjs_5f("thead", {}, gvjs_hL(a, gvjs_6ga)), c = [], d = a.ca(), e = {
        SF: 0
    }; e.SF < d; e = {
        SF: e.SF
    },
    ++e.SF)
        c.push(gvjs_hL(a, function(f) {
            return function(g, h) {
                g = g.Ha(f.SF, h);
                return gvjs_5f("td", {}, g)
            }
        }(e)));
    a = gvjs_5f("tbody", {}, gvjs_$f(c));
    return gvjs_5f(gvjs_Ld, {}, gvjs_$f(b, a))
}
function gvjs_hL(a, b) {
    for (var c = [], d = a.$(), e = 0; e < d; ++e)
        "" === a.Jg(e) && c.push(b(a, e));
    a = gvjs_$f(c);
    return gvjs_5f("tr", {}, a)
}
function gvjs_6ga(a, b) {
    a = a.Ga(b) || a.Ne(b);
    return gvjs_5f("th", {}, a)
}
;function gvjs_iL(a) {
    gvjs_Qn.call(this, a);
    this.Xg = null;
    this.tb = gvjs_S;
    this.Zf = this.Tc = this.m = this.ha = this.tga = null;
    this.RM = [];
    this.Tf = this.ab = this.Ls = this.Ra = null;
    this.Vk = new gvjs_H;
    this.ea = null;
    this.zd = new gvjs_8q(this);
    gvjs_6x(this, this.zd);
    this.my = this.ls = null
}
gvjs_o(gvjs_iL, gvjs_Qn);
gvjs_ = gvjs_iL.prototype;
gvjs_.M = function() {
    this.He();
    gvjs_E(this.Vk);
    gvjs_E(this.ea);
    gvjs_E(this.ls);
    gvjs_E(this.my);
    gvjs_Qn.prototype.M.call(this)
}
;
gvjs_.us = function(a, b, c, d, e, f) {
    if (this.Xg === gvjs_fw)
        return gvjs_jL.prototype.us.apply(this, arguments);
    var g = this.Xg === gvjs_4u ? new gvjs_QK(a,b,c,d,e) : new gvjs_eJ(a,b,c,d,e);
    this.oQ(g, f);
    return g
}
;
gvjs_.oQ = function(a, b) {
    a.init(this.Bk, b)
}
;
gvjs_.hH = function(a, b, c, d, e, f, g) {
    return this.Xg === gvjs_fw ? gvjs_jL.prototype.hH.apply(this, arguments) : new gvjs_jK(a,b,c,d,e,f,g)
}
;
gvjs_.gH = function(a, b, c, d) {
    return this.Xg === gvjs_fw ? gvjs_jL.prototype.gH.apply(this, arguments) : new gvjs_WJ(a,b,c,d)
}
;
gvjs_.Wx = function(a, b) {
    return this.Xg === gvjs_fw ? gvjs_jL.prototype.Wx.apply(this, arguments) : new gvjs_aH(a,b)
}
;
gvjs_.cc = function(a, b, c, d) {
    this.Xg = a;
    null != b && (this.Gma = b);
    null != c && (this.tb = c);
    null != d && (this.tga = d)
}
;
gvjs_.Mca = function(a) {
    a && this.constructor !== gvjs_jL && (this.__proto__ ? (this.__proto__ = gvjs_jL.prototype,
    this.constructor = gvjs_jL,
    this.constructor.call(this, this.container)) : this.cc(gvjs_fw))
}
;
gvjs_.draw = function(a, b, c) {
    this.Mca(gvjs_r(b) && b.type === gvjs_fw);
    gvjs_Qn.prototype.draw.call(this, a, b, c)
}
;
gvjs_.Rd = function(a, b, c, d) {
    this.Bk = a;
    c = c || {};
    c = gvjs_Li(gvjs_Ii(c));
    gvjs_7ga(this, c);
    gvjs_8ga(this, c);
    c.orientation = c.orientation || this.tb;
    c.theme = c.theme || this.tga;
    this.Xg != gvjs_f && gvjs_9ga(c);
    if (this.Xg != gvjs_fw && gvjs_Jj(c.reverseCategories)) {
        var e = c.orientation === gvjs_U ? gvjs_Ud : gvjs_Xu;
        c[e] = c[e] || {};
        c[e].direction = -1;
        delete c.reverseCategories
    }
    gvjs_$ga(c);
    gvjs_iba(this.container);
    if (!b)
        throw Error(gvjs_as);
    gvjs_Fe(gvjs_Ky(b.$()), function(h) {
        return b.Jg(h) == gvjs_3v
    }) && (c.isDiff = !0);
    this.Cy = b.W(0) != gvjs_g ? 1 : 0;
    this.Gi = b.ca();
    gvjs_kL(this);
    c = gvjs_aha(c);
    var f = []
      , g = gvjs_7K();
    gvjs_u(c, function(h) {
        f.push.apply(f, gvjs_9d(gvjs_Vz(h, g)))
    });
    this.cfa = c;
    this.m = new gvjs_Aj(gvjs_Le(this.cfa));
    this.Xg = gvjs_J(this.m, gvjs_Sd, gvjs_f, gvjs_eC);
    this.ga = this.La(this.m);
    this.Pa = this.getHeight(this.m);
    c = new gvjs_A(this.ga,this.Pa);
    e = gvjs_K(this.m, gvjs_Eu);
    if (!this.ab || this.ab.xf)
        try {
            this.ab = new gvjs_3B(this.container,c,a,e)
        } catch (h) {
            throw Error(gvjs_As);
        }
    else
        this.ab.update(c, a);
    this.Ra = new gvjs_bG(d);
    this.Z = b;
    f.length && this.Lh ? (this.Lh.promise.then(function() {
        this.ab.rl(gvjs_s(this.no, this), a)
    }, null, this),
    gvjs_sy(this, gvjs_s(function() {
        this.ab.rl(gvjs_s(this.no, this), a)
    }, this)),
    new gvjs_6K(f,this.Lh)) : this.ab.rl(gvjs_s(this.no, this), a)
}
;
function gvjs_aha(a) {
    if (a.isStacked && a.vAxis && a.vAxis.baseline)
        throw Error(gvjs_5r);
    var b = a.theme || [];
    b && !Array.isArray(b) && (b = [b]);
    for (var c = [a], d = 0; d < b.length; d++) {
        var e = b[d];
        if (typeof e === gvjs_l)
            e = gvjs_4F(e);
        else if (gvjs_r(e))
            e instanceof gvjs_Aj && (e = gvjs_jq(e));
        else
            throw Error(gvjs_ws);
        e && c.push(e)
    }
    a = a.type.toLowerCase();
    gvjs_PF[a] && c.push(gvjs_PF[a]);
    c.push(gvjs_QF);
    return c
}
gvjs_.no = function() {
    var a = this.ab.Oa()
      , b = this.ab.yq()
      , c = this.m
      , d = gvjs_s(function(e) {
        gvjs_lL(this);
        e = e.ti();
        var f = new gvjs_fL(c,this.Ra,gvjs_s(this.Ql, this),e);
        gvjs_E(this.ea);
        this.ea = new gvjs_MK(e,this.Ra,this.Vk,this.zd,gvjs_s(this.hk, this, !0),f);
        this.Zf = this.hH(this.m, new gvjs_A(this.ga,this.Pa), {
            bb: e.Hj,
            fontSize: e.Dl
        }, e.qz, e.Ig, e.C.length, this.Zf ? this.Zf.le : void 0);
        gvjs_bha(this);
        this.Tc = this.Wx(b, a);
        gvjs_cha(this, e) || (this.ha = e,
        gvjs_mL(this),
        gvjs_nL(this));
        gvjs_dha(this);
        this.zd.dispatchEvent(gvjs_i);
        this.ea.Bq()
    }, this);
    this.us(this.Z, c, gvjs_s(a.me, a), this.ga, this.Pa, d)
}
;
function gvjs_dha(a) {
    var b = a.ab.Oa();
    gvjs_Oh().Vj().setTimeout(gvjs_s(function() {
        if (b && b.ws) {
            var c = b.ws();
            if (c && this.Z) {
                var d = gvjs_gL(this.Z);
                gvjs_cg(c, d)
            }
        }
    }, a), 0)
}
gvjs_.Jm = gvjs_n(70);
gvjs_.av = function(a, b) {
    var c = new gvjs_M
      , d = b.ca()
      , e = b.$()
      , f = a.W(0) != gvjs_g;
    f && c.xd(a.W(0), a.Ga(0));
    for (var g = f ? 1 : 0, h = g; h < e; ++h)
        c.xd({
            type: a.W(h),
            label: a.Ga(h),
            role: gvjs_3v
        }),
        c.xd({
            type: b.W(h),
            label: b.Ga(h),
            role: gvjs_$t
        });
    c.Yn(d);
    for (var k = 0; k < d; ++k) {
        f && (h = b.getValue(k, 0),
        c.Wb(k, 0, h));
        var l = g;
        for (h = g; h < e; ++h) {
            var m = a.getValue(k, h);
            c.Wb(k, l, m);
            l += 1;
            m = b.getValue(k, h);
            c.Wb(k, l, m);
            l += 1
        }
    }
    return c
}
;
function gvjs_7ga(a, b) {
    switch (b.type) {
    case gvjs_e:
        a.cc(gvjs_d, gvjs_e, gvjs_S);
        b.type = null;
        break;
    case gvjs_at:
        a.cc(gvjs_d, gvjs_at, gvjs_S);
        b.type = null;
        break;
    case "columns":
        a.cc(gvjs_d, gvjs_lt, gvjs_S);
        b.type = null;
        break;
    case gvjs_lt:
        a.cc(gvjs_d, gvjs_lt, gvjs_U);
        b.type = null;
        break;
    case gvjs_Dd:
        a.cc(gvjs_Dd);
        b.type = null;
        break;
    case gvjs_fw:
        a.cc(gvjs_fw),
        b.type = null
    }
    a = a.Xg;
    a == gvjs_f && (a = null);
    var c = b.type || gvjs_f;
    c == gvjs_f && (c = null);
    if (!a && !c)
        throw Error(gvjs_zs);
    if (a && c && a != c)
        throw Error(gvjs_es);
    b.type = a || c
}
function gvjs_8ga(a, b) {
    if (b.type == gvjs_d) {
        a = a.Gma;
        a == gvjs_f && (a = null);
        var c = b.seriesType || gvjs_f;
        c == gvjs_f && (c = null);
        if (a && c && a != c)
            throw Error(gvjs_fs);
        b.seriesType = a || c
    }
}
function gvjs_9ga(a) {
    a.hAxis = a.hAxis || {};
    a.vAxis = a.vAxis || {};
    var b = a.hAxis
      , c = a.vAxis
      , d = null;
    switch (a.type) {
    case gvjs_Dd:
        d = c;
        break;
    case gvjs_d:
        a.targetAxis = a.targetAxis || {},
        d = a.targetAxis
    }
    d && (gvjs_oL(a, gvjs_Ov, d, gvjs_ed),
    gvjs_oL(a, gvjs_Gv, d, gvjs_cd),
    gvjs_oL(a, gvjs_Cv, d, gvjs_Cv));
    b && (gvjs_oL(a, "logScaleX", b, gvjs_Cv),
    gvjs_oL(a, "titleX", b, gvjs_fx));
    c && gvjs_oL(a, gvjs_jx, c, gvjs_fx);
    a.smoothLine && void 0 === a.curveType && (a.curveType = gvjs_d);
    gvjs_oL(a, "lineSize", a, gvjs_Bv);
    gvjs_oL(a, gvjs_ww, a, gvjs_xw);
    a.chartArea = a.chartArea || {};
    gvjs_oL(a, gvjs_gt, a.chartArea, gvjs_ht)
}
function gvjs_$ga(a) {
    gvjs_pL(a, gvjs_gx, gvjs_hx, gvjs_ix);
    gvjs_pL(a, gvjs_xv, gvjs_wv, gvjs_yv);
    gvjs_qL(a.hAxis);
    for (var b in a.hAxes)
        gvjs_qL(a.hAxes[b]);
    gvjs_qL(a.vAxis);
    for (b in a.vAxes)
        gvjs_qL(a.vAxes[b]);
    b = a.tooltip;
    null == b && (b = {},
    a.tooltip = b);
    gvjs_pL(a, gvjs_sx, gvjs_rx, gvjs_tx);
    gvjs_oL(a, gvjs_tx, b, gvjs_bx);
    gvjs_oL(a, "tooltipText", b, gvjs_m);
    gvjs_oL(a, gvjs_ux, b, "trigger");
    "hover" == b.trigger && (b.trigger = gvjs_xu);
    b = a.legend;
    if (null == b)
        b = {},
        a.legend = b;
    else if (typeof b == gvjs_l) {
        var c = b;
        b = {};
        a.legend = b;
        b.position = c
    }
    gvjs_oL(a, gvjs_yv, b, gvjs_bx);
    b = a.animation;
    null == b ? (b = {},
    a.animation = b) : typeof b == gvjs_g && (c = 1E3 * b,
    b = {},
    a.animation = b,
    b.duration = c);
    gvjs_oL(a, gvjs_Xs, b, "easing")
}
function gvjs_qL(a) {
    if (null != a) {
        gvjs_pL(a, "textColor", "textFontSize", gvjs_bx);
        gvjs_pL(a, gvjs_gx, gvjs_hx, gvjs_ix);
        a.gridlines = a.gridlines || {};
        var b = a.gridlines
          , c = a.numberOfSections;
        void 0 === b.count && void 0 !== c && typeof c == gvjs_g && (b.count = c + 1);
        a = a.gridlineColor;
        void 0 === b.color && void 0 !== a && (b.color = a)
    }
}
function gvjs_pL(a, b, c, d) {
    a[d] = a[d] || {};
    d = a[d];
    gvjs_oL(a, b, d, gvjs_1);
    gvjs_oL(a, c, d, gvjs_zp)
}
function gvjs_oL(a, b, c, d) {
    void 0 !== a[b] && void 0 === c[d] && (c[d] = a[b])
}
gvjs_.He = function() {
    this.ku();
    gvjs_kL(this);
    gvjs_lL(this);
    gvjs_E(this.ab);
    gvjs_li(this)
}
;
function gvjs_kL(a) {
    if (a.ea && !a.ea.xf) {
        var b = a.ea.zb;
        b.fq = Infinity;
        b.Hc.stop()
    }
    gvjs_E(a.ea);
    if (a.ab && !a.ab.xf) {
        b = a.ab.Oa();
        var c = a.ab.yq();
        a.my = b;
        c.clear()
    }
    gvjs_E(a.ls);
    gvjs_li(a.Vk)
}
function gvjs_lL(a) {
    var b = a.my || a.ab && a.ab.Oa();
    a.my = null;
    b && b.clear()
}
function gvjs_bha(a) {
    gvjs_u(a.RM, gvjs_s(function(b) {
        typeof b === gvjs_l ? this.th(b) : this.xh(b)
    }, a));
    a.RM = []
}
gvjs_.xh = function(a) {
    null != this.Zf ? this.Zf.xh(a) : this.RM.push(a)
}
;
function gvjs_eha(a, b) {
    var c = new gvjs_$n;
    c.setSelection(b);
    b = gvjs_co(c);
    c = !1;
    for (var d = 0; d < b.length; d++) {
        var e = b[d]
          , f = e.column;
        e = e.row;
        f = a.ha.Jk && a.ha.Jk[f];
        if (!f)
            return !1;
        var g = f.Vb, h, k;
        null != g ? h = a.ha.C[g].points[e] : k = a.ha.$a[e];
        if (!h && !k)
            return !1;
        if (f.role == gvjs_Zs) {
            if (c)
                return !1;
            c = !0;
            if (!(h || k).Bc)
                return !1
        }
    }
    return !0
}
gvjs_.setSelection = function(a) {
    if (gvjs_eha(this, a)) {
        var b = null;
        if (this.ha.Fa != gvjs_fw) {
            var c = new gvjs_$n;
            c.setSelection(a);
            c = gvjs_co(c);
            for (var d = 0; d < c.length; d++) {
                var e = c[d]
                  , f = this.ha.Jk[e.column];
                if (f.role == gvjs_Zs) {
                    b = {
                        Vb: f.Vb,
                        oO: e.row
                    };
                    break
                }
            }
        }
        this.hk(!0);
        this.Ra.selected.setSelection(a);
        b && (this.Ra.annotations.dI = b);
        this.hk(!1)
    }
}
;
gvjs_.hk = function(a) {
    if (this.Ls) {
        var b = this.Ls;
        if (!this.Zf.xY(this.Ra, this.Ls)) {
            var c = this.Ra.gm;
            if (c) {
                this.m = new gvjs_Aj(gvjs_Le(this.cfa));
                gvjs_hq(this.m, 0, c);
                c = this.ab.Oa();
                var d = this.us(this.Z, this.m, gvjs_s(c.me, c), this.ga, this.Pa).ti();
                this.ea.ha = d;
                this.my && (this.my.clear(),
                this.my = null);
                this.ls.I5 && this.ls.I5(d);
                c = gvjs_iK(this.Zf, d, this.Ra);
                this.ha = d;
                this.Tc.VK(this.ha);
                gvjs_OG(this.Tc, this.ha, c);
                this.Ra.gm = null;
                this.Ls = this.Ra.clone()
            } else
                this.Ls = this.Ra.clone(),
                c = gvjs_iK(this.Zf, this.ha, this.Ra),
                gvjs_PG(this.Tc, this.ha, c)
        }
        a && this.zd.Is(b, this.Ls, this.ha.Fa, this.ha.C)
    }
}
;
gvjs_.getSelection = function() {
    return this.Ls ? this.Ls.selected.getSelection() : []
}
;
gvjs_.ng = function(a) {
    if (this.Zf)
        return this.Zf.ng(a)
}
;
gvjs_.th = function(a) {
    null != this.Zf ? this.Zf.th(a) : this.RM.push(a)
}
;
gvjs_.dump = function() {
    var a = this.ab.Oa();
    return a.Poa ? a.container.innerHTML : ""
}
;
function gvjs_mL(a) {
    var b = gvjs_iK(a.Zf, a.ha, a.Ra);
    a.Tc.Fl(a.ha, b);
    a.Ls = a.Ra.clone()
}
function gvjs_nL(a) {
    var b = a.ab.Oa()
      , c = a.ab.yq();
    gvjs_E(a.ls);
    a.ls = a.gH(a.Vk, b, c, a.ha);
    gvjs_QJ(a.ls);
    gvjs_SJ(a.ls);
    gvjs_TJ(a.ls)
}
function gvjs_cha(a, b) {
    var c = gvjs_5K(a.m, 0, gvjs_Hp);
    if (a.Tf) {
        var d = a.Tf.zK;
        a.ku()
    } else
        d = a.ha;
    if (!c || !(c.iga || d && d.Fa === b.Fa) || b.Fa === gvjs_4u || b.Fa === gvjs_fw)
        return !1;
    if (!d) {
        var e = gvjs_Ky(a.Z.$())
          , f = a.Z.bf;
        f || (f = a.Ta.Do().map(function(q) {
            return gvjs_r(q) ? q : {
                sourceColumn: q,
                properties: a.Z.Rj(q)
            }
        }));
        var g = b.C;
        d = b.Jk;
        b.Fa === gvjs_yt && (d = [{
            role: gvjs_5c
        }, {
            role: gvjs_mu
        }, {
            role: gvjs_$t,
            Vb: 0
        }]);
        var h, k;
        gvjs_u(d, function(q, r) {
            if (q.role === gvjs_$t || q.role === gvjs_iv) {
                var t = gvjs_x(f[r]);
                if (q.role === gvjs_$t) {
                    q = g[q.Vb];
                    if (q.ag)
                        return;
                    q = q.Qc || 0;
                    if (null != q) {
                        var u = b.orientation && b.orientation !== gvjs_S ? b.jd[q] : b.wc[q];
                        h = function() {
                            return u.baseline.za
                        }
                        ;
                        k = u.dataType
                    }
                } else
                    t.role = gvjs_iv;
                t.calc = h;
                t.type = k;
                e[r] = t
            }
        });
        d = new gvjs_N(a.Z);
        d.Hn(e);
        var l = {};
        b.jd && gvjs_w(b.jd, function(q, r) {
            q.Tn && (l[r] = {
                viewWindow: {
                    numericMin: q.Tn.min,
                    numericMax: q.Tn.max
                }
            })
        });
        var m = {};
        b.wc && gvjs_w(b.wc, function(q, r) {
            q.Tn && (m[r] = {
                viewWindow: {
                    numericMin: q.Tn.min,
                    numericMax: q.Tn.max
                }
            })
        });
        gvjs_hq(a.m, 0, {
            hAxes: l,
            vAxes: m
        });
        var n = a.ab.Oa();
        d = a.us(d, a.m, gvjs_s(n.me, n), a.ga, a.Pa).ti()
    }
    a.ha = null;
    n = Date.now();
    var p = a.Tf && a.Tf.iA || 0;
    a.ku();
    a.Tf = {
        bua: d,
        $J: b,
        interpolator: new gvjs_zK(d,b),
        zK: d,
        startTime: n,
        endTime: n + c.duration,
        iA: p,
        timer: new gvjs_IA(10),
        oY: c.easing,
        HD: c.HD,
        done: !1
    };
    a.faa();
    gvjs_G(a.Tf.timer, gvjs_dx, gvjs_s(a.faa, a));
    a.Tf.timer.start();
    a.ha = b;
    return !0
}
gvjs_.faa = function() {
    var a = this.Tf;
    this.ha = null;
    if (a.done)
        this.ku(),
        this.ha = a.$J,
        gvjs_mL(this),
        gvjs_nL(this),
        this.zd.dispatchEvent(gvjs_Ys);
    else {
        var b = Date.now()
          , c = (b - a.startTime) / (a.endTime - a.startTime);
        if (1 > c) {
            if (b - a.iA < 1E3 / this.Tf.HD)
                return
        } else
            c = 1,
            a.done = !0;
        c = a.interpolator.interpolate(a.oY(c));
        a.zK = c;
        a.iA = b;
        this.Tc.Fl(c, {});
        this.zd.dispatchEvent("animationframefinish")
    }
    this.ha = a.$J
}
;
gvjs_.ku = function() {
    this.Tf && (gvjs_E(this.Tf.timer),
    this.Tf = null)
}
;
gvjs_.fZ = function() {
    var a = this.ha.O;
    return {
        left: a.left,
        top: a.top,
        width: a.width,
        height: a.height
    }
}
;
gvjs_.Qj = function(a) {
    return null == this.Tc ? null : (a = this.Tc.Qj(a)) ? {
        left: a.left,
        top: a.top,
        width: a.right - a.left,
        height: a.bottom - a.top
    } : null
}
;
gvjs_.Ql = function() {
    var a = this.ha;
    return {
        getChartAreaBoundingBox: gvjs_s(this.fZ, this),
        getBoundingBox: gvjs_s(this.Qj, this),
        getXLocation: gvjs_s(gvjs_5G, null, a),
        getYLocation: gvjs_s(gvjs_6G, null, a),
        getHAxisValue: gvjs_s(gvjs_7G, null, a),
        getVAxisValue: gvjs_s(gvjs_8G, null, a),
        getPointDatum: gvjs_s(gvjs_9G, null, a)
    }
}
;
gvjs_.pZ = gvjs_n(71);
gvjs_.ti = function() {
    return this.ha
}
;
gvjs_.ah = function() {
    if (!this.m || !this.ha || !this.Ra)
        throw Error(gvjs_6r);
    var a = new gvjs_A(this.ga,this.Pa)
      , b = gvjs_3g(this.container).createElement(gvjs_Ob);
    a = gvjs_1B(b, a);
    a = new gvjs_rB(b,a);
    a = this.Wx(new gvjs_MB(b), a);
    var c = gvjs_iK(this.Zf, this.ha, this.Ra);
    a.Fl(this.ha, c);
    return b.childNodes[0].toDataURL(gvjs_bv)
}
;
gvjs_.Se = null;
function gvjs_jL(a) {
    gvjs_iL.call(this, a);
    this.cc(gvjs_fw)
}
gvjs_o(gvjs_jL, gvjs_iL);
gvjs_ = gvjs_jL.prototype;
gvjs_.Mca = function() {}
;
gvjs_.us = function(a, b, c, d, e, f) {
    a = new gvjs_XK(a,b,c,d,e);
    this.oQ(a, f);
    return a
}
;
gvjs_.hH = function(a, b, c, d, e, f, g) {
    return new gvjs_2K(a,b,c,d,e,f,g)
}
;
gvjs_.gH = function(a, b, c) {
    return new gvjs_1K(a,b,c)
}
;
gvjs_.Wx = function(a, b) {
    return new gvjs_TK(a,b)
}
;
gvjs_.Jm = gvjs_n(69);
function gvjs_rL(a) {
    gvjs_iL.call(this, a);
    this.cc(gvjs_d, gvjs_f, gvjs_S)
}
gvjs_o(gvjs_rL, gvjs_iL);
function gvjs_fha(a) {
    return a
}
function gvjs_sL(a) {
    if (void 0 === a)
        return gvjs_fha;
    if (typeof a == gvjs_d)
        return a;
    if (typeof a == gvjs_l)
        return function(b) {
            return b[a]
        }
        ;
    throw "Bad type for verbal.evaluator: " + a;
}
function gvjs_tL(a, b) {
    var c = gvjs_sL(b);
    return gvjs_Ee(a, function(d, e) {
        return d + c(e)
    }, 0)
}
function gvjs_uL(a, b) {
    return gvjs_tL(a, b) / a.length
}
function gvjs_vL(a, b) {
    return Math.sqrt(gvjs_wL(a, b))
}
function gvjs_wL(a, b) {
    var c = gvjs_sL(b);
    b = gvjs_uL(a, function(d) {
        d = c(d);
        return d * d
    });
    a = gvjs_uL(a, c);
    return Math.max(b - a * a, 0)
}
function gvjs_xL(a, b) {
    var c = gvjs_sL(b), d, e;
    gvjs_u(a, function(f) {
        var g = c(f);
        d >= g || (d = g,
        e = f)
    });
    return e
}
function gvjs_yL(a, b) {
    var c = gvjs_sL(b);
    return gvjs_xL(a, function(d) {
        return -c(d)
    })
}
var gvjs_gha = 1 / Math.sqrt(2 * Math.PI);
function gvjs_zL(a, b, c) {
    if (0 > c)
        throw "Bad normal distribution: sigma = " + c + ".";
    if (0 == c)
        return a == b ? Infinity : 0;
    a = (a - b) / c;
    return gvjs_gha * Math.exp(-.5 * a * a) / c
}
function gvjs_AL(a, b, c) {
    b = b || 0;
    c = c || 1;
    if (0 == c)
        return a >= b ? 1 : 0;
    if (0 != b || 1 != c)
        return gvjs_AL((a - b) / c);
    if (0 < a)
        return 1 - gvjs_AL(-a);
    var d = Math.abs(a);
    a = Math.exp(-d * d / 2);
    c = [.65, 4, 3, 2, 1];
    if (37 < d)
        return 0;
    if (7.07106781186547 <= d) {
        var e = 1;
        c.forEach(function(h) {
            e = d + h / e
        });
        return a / e / 2.506628274631
    }
    var f = 0
      , g = 0;
    [.0352624965998911, .700383064443688, 6.37396220353165, 33.912866078383, 112.079291497871, 221.213596169931, 220.206867912376].forEach(function(h) {
        f = f * d + h
    });
    [.0883883476483184, 1.75566716318264, 16.064177579207, 86.7807322029461, 296.564248779674, 637.333633378831, 793.826512519948, 440.413735824752].forEach(function(h) {
        g = g * d + h
    });
    return a * f / g
}
function gvjs_BL(a) {
    this.params = a || {};
    this.Rf = this.Vd = 0;
    this.name = "AbstractStatsModel"
}
function gvjs_CL(a, b) {
    gvjs_w(b, function(c, d) {
        gvjs_Ty(this.params, d, c)
    }, a)
}
;function gvjs_DL() {
    this.Ot = this.GV = null
}
function gvjs_EL(a) {
    var b = new gvjs_DL;
    b.GV = a;
    return b
}
function gvjs_FL(a) {
    var b = new gvjs_DL;
    b.Ot = a;
    return b
}
function gvjs_GL(a) {
    if (null != a.GV)
        return a.GV;
    throw Error("AbstractRenderer not set");
}
gvjs_DL.prototype.cp = gvjs_n(72);
function gvjs_HL() {}
;function gvjs_IL(a, b) {
    this.pf = a;
    this.rb = null != b && gvjs_x(b) || {}
}
function gvjs_JL(a, b) {
    a = gvjs_KL(new gvjs_IL(gvjs_os), gvjs_ps, a);
    null != b && gvjs_KL(a, gvjs_rs, b);
    return a
}
function gvjs_LL(a) {
    a = gvjs_Gi(a);
    return new gvjs_IL(a.pf,a.rb)
}
gvjs_ = gvjs_IL.prototype;
gvjs_.clone = function() {
    return gvjs_LL(this.ie())
}
;
gvjs_.equals = function(a) {
    if (!a || this.pf != a.pf)
        return !1;
    var b = gvjs_Ye(this.rb);
    return b.length !== gvjs_Ye(a.rb).length ? !1 : gvjs_Ge(gvjs_v(b, gvjs_s(function(c) {
        return this.rb[c] === a.rb[c]
    }, this)), gvjs_Wx)
}
;
function gvjs_KL(a, b, c) {
    a.rb[b] = c;
    return a
}
gvjs_.kD = function(a) {
    return this.pf === a.pf && gvjs_Ve(this.rb, function(b, c) {
        return a.rb[c] === b
    })
}
;
gvjs_.type = function() {
    return this.pf
}
;
gvjs_.ie = function() {
    return gvjs_Hi(this)
}
;
function gvjs_ML() {
    this.selected = new gvjs_$n;
    this.Rn = this.ff = null;
    this.Cn = new Set
}
gvjs_ML.prototype.clone = function() {
    var a = new gvjs_ML;
    a.selected = this.selected.clone();
    a.ff = this.ff ? this.ff.clone() : null;
    a.Rn = this.Rn ? this.Rn.clone() : null;
    a.Cn = new Set(this.Cn);
    return a
}
;
gvjs_ML.prototype.equals = function(a) {
    return this.selected.equals(a.selected) && (this.ff ? this.ff.equals(a.ff) : !a.ff) && (this.Rn ? this.Rn.equals(a.Rn) : !a.Rn) && gvjs_Xz(this.Cn, a.Cn)
}
;
function gvjs_NL(a, b) {
    this.bI = a;
    this.b$ = b || null;
    this.K = null
}
gvjs_NL.prototype.setState = function(a) {
    this.K = a.clone()
}
;
function gvjs_OL(a, b) {
    if (!b)
        return null;
    var c = {};
    c.row = b.rb.ROW_INDEX;
    c.column = b.rb.COLUMN_INDEX;
    a.b$ && gvjs_w(a.b$, function(d, e) {
        e = b.rb[e];
        null != e && (c[d] = e)
    });
    return c
}
gvjs_NL.prototype.Is = function(a) {
    var b = this.K
      , c = [];
    a.selected.equals(b.selected) && gvjs_Xz(a.Cn, b.Cn) || c.push({
        event: gvjs_k,
        data: null
    });
    var d = a.ff;
    b = b.ff;
    if (!d && b || d && !d.equals(b)) {
        var e = !!b && !!d && !b.equals(d);
        !e && d || c.push({
            event: gvjs_6v,
            data: gvjs_OL(this, b)
        });
        !e && b || c.push({
            event: gvjs_7v,
            data: gvjs_OL(this, d)
        })
    }
    this.K = a.clone();
    gvjs_u(c, function(f) {
        this.dispatchEvent(f.event, f.data)
    }, this)
}
;
gvjs_NL.prototype.dispatchEvent = function(a, b) {
    gvjs_I(this.bI, a, b)
}
;
function gvjs_PL(a, b) {
    gvjs_F.call(this);
    this.K = null;
    this.Kv = b;
    this.zb = new gvjs_KK(a);
    gvjs_6x(this, this.zb)
}
gvjs_o(gvjs_PL, gvjs_F);
gvjs_PL.prototype.setState = function(a) {
    this.K = a
}
;
gvjs_PL.prototype.sI = function() {
    return gvjs_s(this.handleEvent, this)
}
;
gvjs_PL.prototype.handleEvent = function(a, b) {
    if (null != this.Kv) {
        var c = !1;
        gvjs_u(this.Kv, function(d) {
            d.Vna(a, b) && (d = d.QG(a, b, this.K),
            c = c || d)
        }, this);
        c && gvjs_LK(this.zb, 50)
    }
}
;
function gvjs_hha() {
    this.Os = [];
    this.Ps = [];
    this.KN = !1
}
;function gvjs_QL(a) {
    this.K = null;
    this.nv = [];
    this.Kv = a
}
gvjs_ = gvjs_QL.prototype;
gvjs_.JG = function(a) {
    if (this.K.equals(a))
        return {
            KN: !1,
            Os: [],
            Ps: []
        };
    var b = this.nv;
    a = this.Dk(a);
    return this.fH(a, b)
}
;
gvjs_.Dk = function(a) {
    if (null == this.Kv)
        return [];
    var b = gvjs_Ee(this.Kv, function(c, d) {
        gvjs_Me(c, d.Dk(a));
        return c
    }, [], this);
    this.nv = b;
    this.K = a.clone();
    return b
}
;
gvjs_.fH = function(a, b) {
    a = this.Nu(a);
    var c = this.Nu(b);
    b = gvjs_Yz(a, c);
    a = gvjs_Yz(c, a);
    c = new gvjs_hha;
    c.Os = this.Aw(b);
    c.Ps = this.Aw(a);
    return c
}
;
gvjs_.Nu = function(a) {
    a = gvjs_v(a, function(b) {
        return gvjs_Hi(b)
    });
    return new Set(a)
}
;
gvjs_.Aw = function(a) {
    a = gvjs_nj(a);
    return gvjs_v(a, function(b) {
        b = gvjs_Gi(b);
        b.targets = gvjs_v(b.targets, function(c) {
            return new gvjs_IL(c.pf,c.rb)
        });
        return b
    })
}
;
function gvjs_RL(a, b, c, d, e, f) {
    gvjs_F.call(this);
    this.Ay = a;
    this.IO = this.state = null;
    this.c$ = this.Ay.xq();
    a = this.Ay.xs(e);
    this.Ai = new gvjs_QL(a);
    e = f(gvjs_s(this.hk, this, !0));
    this.pi = new gvjs_PL(e,a);
    gvjs_6x(this, this.pi);
    this.fo = this.Ay.po(b, c, this.pi.sI(), f);
    this.AY = new gvjs_NL(d,this.c$)
}
gvjs_o(gvjs_RL, gvjs_F);
gvjs_RL.prototype.draw = function(a, b) {
    this.state = b.clone();
    this.pi.setState(this.state);
    this.AY.setState(this.state);
    b = this.Ai.Dk(this.state);
    this.fo.draw(a, b);
    this.IO = this.state.clone();
    this.AY.dispatchEvent(gvjs_i, null)
}
;
gvjs_RL.prototype.hk = function(a) {
    var b = this.Ai.JG(this.state);
    this.fo.refresh(b);
    this.IO = this.state.clone();
    a && this.AY.Is(this.state)
}
;
gvjs_RL.prototype.setSelection = function(a) {
    this.hk(!0);
    this.state.selected.setSelection(a);
    this.hk(!1)
}
;
gvjs_RL.prototype.getSelection = function() {
    var a = this
      , b = this.IO.selected.getSelection()
      , c = [];
    this.IO.Cn.forEach(function(d) {
        d = gvjs_LL(d);
        var e = {};
        gvjs_w(a.c$, function(f, g) {
            g = d.rb[g];
            null != g && (e[f] = g)
        });
        c.push(e)
    });
    gvjs_Me(b, c);
    return b
}
;
function gvjs_SL(a) {
    gvjs_Qn.call(this, a);
    this.fp = null
}
gvjs_o(gvjs_SL, gvjs_Qn);
gvjs_ = gvjs_SL.prototype;
gvjs_.xq = function() {
    return null
}
;
gvjs_.og = function() {}
;
gvjs_.po = function() {}
;
gvjs_.Mm = function() {}
;
gvjs_.Al = function() {}
;
gvjs_.xs = function() {
    return null
}
;
gvjs_.He = function() {
    gvjs_E(this.fp);
    this.fp = null
}
;
gvjs_.setSelection = function(a) {
    this.fp && this.fp.setSelection(a)
}
;
gvjs_.getSelection = function() {
    return this.fp ? this.fp.getSelection() : []
}
;
function gvjs_TL(a, b, c, d, e) {
    this.Ay = a;
    this.renderer = b;
    this.re = gvjs_EL(b);
    this.zw = c;
    this.vt = null;
    this.Ez = gvjs_iha;
    this.pi = d;
    this.BB = e;
    this.ho = null
}
gvjs_t(gvjs_TL, gvjs_HL);
gvjs_ = gvjs_TL.prototype;
gvjs_.draw = function(a) {
    this.vt = {};
    var b = this.renderer;
    b.clear();
    this.ho = this.Ay.Mm(a, this.zw);
    a = this.ho.Tb();
    a = b.Lm(a.width, a.height);
    for (var c = 0; c < this.Ez.length; c++) {
        var d = this.Ez[c]
          , e = b.Sa();
        b.appendChild(a, e);
        this.vt[d] = e
    }
    this.ho.draw(this);
    this.M3(a)
}
;
gvjs_.$t = gvjs_n(73);
gvjs_.refresh = function(a) {
    this.kL(a.Ps, !1);
    this.kL(a.Os, !0);
    this.ho.draw(this)
}
;
gvjs_.kL = function(a, b) {
    for (var c = 0; c < a.length; c++)
        for (var d = a[c], e = d.targets, f = 0; f < e.length; f++)
            this.ho.nm(e[f], d.effect, b)
}
;
gvjs_.M3 = function(a) {
    var b = this.renderer;
    b.ic(a, gvjs_3t, gvjs_Lz);
    b.ic(a, gvjs_ld, this.BB(gvjs_s(this.handleEvent, this, gvjs_9u)));
    b.ic(a, gvjs_kd, this.BB(gvjs_s(this.handleEvent, this, gvjs_$u)));
    b.ic(a, gvjs_Wt, this.BB(gvjs_s(this.handleEvent, this, gvjs_Wt)))
}
;
gvjs_.handleEvent = function(a, b) {
    b.stopPropagation && b.stopPropagation();
    b = this.renderer.xv(b.target);
    b != gvjs_Bs && (b = gvjs_LL(b),
    this.pi(b, a))
}
;
gvjs_.Oa = function() {
    return this.re
}
;
gvjs_.we = function(a, b, c, d) {
    null != b ? this.e3(a, b) : this.$n(a, c, d)
}
;
gvjs_.$n = function(a, b, c) {
    this.renderer.appendChild(this.vt[c], a);
    this.renderer.kp(a, b.ie())
}
;
gvjs_.e3 = function(a, b) {
    gvjs_qh(b).replaceChild(a, b);
    b = this.renderer.xv(b);
    this.renderer.kp(a, b)
}
;
gvjs_.Re = function(a) {
    this.renderer.Re(a)
}
;
var gvjs_iha = [gvjs_Wo, gvjs_Cw, gvjs_Bw, gvjs_Ds, gvjs_Cs];
function gvjs_UL(a) {
    gvjs_SL.call(this, a);
    this.sb = null
}
gvjs_o(gvjs_UL, gvjs_SL);
gvjs_ = gvjs_UL.prototype;
gvjs_.po = function(a, b, c, d) {
    if (null == b)
        throw Error("Internal error: missing overlayArea");
    a = gvjs_GL(a);
    return new gvjs_TL(this,a,b,c,d)
}
;
gvjs_.Rd = function(a, b, c) {
    (0,
    gvjs_D.removeAll)(this.container);
    c = c || {};
    var d = this.og() || {};
    c = new gvjs_Aj([c, d]);
    d = this.La(c);
    var e = this.getHeight(c);
    d = new gvjs_A(d,e);
    e = gvjs_K(c, gvjs_Eu);
    this.nH(d, a, e);
    this.sb.rl(this.no.bind(this, b, c, d, a), a)
}
;
gvjs_.nH = function(a, b, c) {
    null == this.sb ? this.sb = new gvjs_3B(this.container,a,b,c) : this.sb.update(a, b)
}
;
gvjs_.no = function(a, b, c, d) {
    var e = this.sb.Oa()
      , f = this.sb.yq();
    c = this.Al(a, b, e.me.bind(e), c).$g();
    gvjs_E(this.fp);
    if (e instanceof gvjs_XA)
        var g = gvjs_EL(e);
    else if (e instanceof gvjs_dC)
        g = gvjs_FL(e);
    else
        throw Error("Unknown renderer type");
    this.fp = new gvjs_RL(this,g,f,this,b,d);
    this.fp.draw(c, new gvjs_ML);
    e.ws && (b = e.ws()) && a && (a = gvjs_gL(a),
    gvjs_cg(b, a))
}
;
gvjs_.He = function() {
    gvjs_SL.prototype.He.call(this);
    gvjs_E(this.sb);
    this.sb = null
}
;
gvjs_q("gviz.fw.FrameworkVisualization.convertOptions", function(a) {
    return a || {}
}, void 0);
function gvjs_VL() {
    this.cca = null;
    this.cua = {};
    this.LR = {};
    this.t9 = new Set;
    this.Qma = new Set
}
gvjs_VL.prototype.set = function(a, b) {
    this.cua[a] !== b ? this.t9.add(a) : this.t9.delete(a);
    this.cca && this.cca[a] === b || (this.Qma.add(a),
    this.LR[a] = b)
}
;
gvjs_VL.prototype.get = function(a) {
    return this.LR[a]
}
;
gvjs_VL.prototype.keys = function() {
    return gvjs_Ye(this.LR)
}
;
function gvjs_WL(a, b, c) {
    this.pf = a;
    this.h$ = b;
    this.Bi = new gvjs_VL;
    this.yn = null;
    this.Gsa = c;
    a === gvjs_Lp && (this.Bi.set(gvjs_np, gvjs_f),
    this.Bi.set(gvjs_0p, gvjs_kr),
    this.yn = new gvjs_Uq(this.ar()))
}
gvjs_ = gvjs_WL.prototype;
gvjs_.Hl = gvjs_n(74);
gvjs_.ar = function() {
    return this.Bi.LR
}
;
function gvjs_XL(a, b) {
    a.Bi.set("x", b);
    return a
}
function gvjs_YL(a, b) {
    a.Bi.set("y", b);
    return a
}
gvjs_.Ug = function(a) {
    this.Bi.set(gvjs_Xd, a);
    return this
}
;
gvjs_.fl = function(a) {
    this.Bi.set(gvjs_4c, a);
    return this
}
;
gvjs_.du = function(a) {
    this.Bi.set(gvjs_m, a);
    return this
}
;
gvjs_.setRadius = function(a) {
    this.Bi.set("radius", a);
    return this
}
;
gvjs_.rd = function(a) {
    this.Bi.set(gvjs_0p, a);
    this.yn && this.yn.style(gvjs_0p, a)
}
;
gvjs_.hl = function(a) {
    this.Bi.set(gvjs_8p, a);
    this.yn && this.yn.style(gvjs_8p, a)
}
;
gvjs_.Te = function(a) {
    this.Bi.set(gvjs_np, a);
    return this
}
;
gvjs_.mf = function(a) {
    this.Bi.set(gvjs_sp, a);
    return this
}
;
gvjs_.move = function(a, b) {
    this.yn.move(a, b);
    return this
}
;
gvjs_.va = function(a, b) {
    this.yn.line(a, b)
}
;
gvjs_.Sf = function(a, b, c, d, e, f, g) {
    this.yn.arc(a, b, c, d, e, f, g)
}
;
gvjs_.om = function(a) {
    this.Bi.set(gvjs_zp, a);
    return this
}
;
function gvjs_ZL(a) {
    this.Vg = [];
    this.ya = a;
    this.rz = 0
}
gvjs_ = gvjs_ZL.prototype;
gvjs_.Tb = function() {
    return this.ya
}
;
gvjs_.zP = gvjs_n(75);
gvjs_.va = function(a, b, c) {
    a = gvjs_YL(gvjs_XL(new gvjs_WL(gvjs_e,a || this.ay(),b || gvjs_Wo), c), void 0);
    a.Bi.set("x2", void 0);
    a.Bi.set("y2", void 0);
    this.Vg.push(a)
}
;
gvjs_.addPath = function(a, b) {
    a = new gvjs_WL(gvjs_Lp,a || this.ay(),b || gvjs_Wo);
    this.Vg.push(a);
    return a
}
;
gvjs_.tB = function(a, b, c, d, e, f) {
    a = gvjs_YL(gvjs_XL((new gvjs_WL(gvjs_m,a || this.ay(),b || gvjs_Wo)).du(c), d), e).Ug(f);
    this.Vg.push(a);
    return a
}
;
gvjs_.ay = function() {
    var a = new gvjs_IL(gvjs_3r);
    gvjs_KL(a, gvjs_rs, "__internal_" + this.rz);
    this.rz += 1;
    return a
}
;
function gvjs__L(a, b) {
    gvjs_F.call(this);
    this.ac = a;
    this.Ei = b
}
gvjs_t(gvjs__L, gvjs_F);
var gvjs_jha = [];
gvjs_ = gvjs__L.prototype;
gvjs_.qd = null;
gvjs_.Uc = null;
gvjs_.lL = function(a) {
    this.ac = a
}
;
gvjs_.getId = function() {
    return this.ac
}
;
gvjs_.getName = function() {
    return this.Ei
}
;
gvjs_.getParent = function() {
    return this.qd
}
;
gvjs_.$v = function() {
    return !this.ze()
}
;
gvjs_.getChildren = function() {
    return this.Uc || gvjs_jha
}
;
gvjs_.Ye = function(a) {
    return this.getChildren()[a] || null
}
;
gvjs_.ze = function() {
    return this.getChildren().length
}
;
gvjs_.getHeight = function() {
    var a = this.getChildren();
    return gvjs_Ee(a, function(b, c) {
        return Math.max(b, c.getHeight())
    }, -1) + 1
}
;
gvjs_.contains = function(a) {
    do
        a = a.getParent();
    while (a && a != this);
    return !!a
}
;
gvjs_.VL = function(a, b) {
    function c(d, e) {
        !1 !== a.call(b, d, e) && gvjs_u(d.getChildren(), function(f) {
            c(f, e + 1)
        })
    }
    c(this, 0)
}
;
gvjs_.find = function(a, b) {
    var c = [];
    this.VL(function(d) {
        a.call(b, d) && c.push(d)
    });
    return c
}
;
gvjs_.MB = gvjs_n(77);
gvjs_.addChild = function(a) {
    a.qd = this;
    this.Uc = this.Uc || [];
    this.Uc.push(a);
    gvjs_6x(this, a)
}
;
function gvjs_0L(a, b, c) {
    gvjs__L.call(this, c, a);
    this.Z = b
}
gvjs_o(gvjs_0L, gvjs__L);
gvjs_ = gvjs_0L.prototype;
gvjs_.mb = function() {
    return this.Z
}
;
function gvjs_1L(a) {
    return a.Ha(0) || a.getName()
}
gvjs_.Ul = function(a) {
    return this.BZ(this.Z.Ul, a)
}
;
gvjs_.getValue = function(a) {
    return this.BZ(this.Z.getValue, a)
}
;
gvjs_.Ha = function(a) {
    return this.BZ(this.Z.Ha, a)
}
;
gvjs_.BZ = function(a, b) {
    var c = this.getId();
    return null != c ? (c = [c],
    gvjs_Me(c, Array.prototype.slice.call(arguments, 1)),
    a.apply(this.Z, c)) : null
}
;
function gvjs_2L() {
    gvjs_F.call(this);
    this.ep = [];
    this.uw = {}
}
gvjs_t(gvjs_2L, gvjs_F);
gvjs_ = gvjs_2L.prototype;
gvjs_.sB = function(a) {
    var b = a.getId();
    null != b && (this.uw[b] = a)
}
;
gvjs_.getHeight = function() {
    return gvjs_Ee(this.ep, function(a, b) {
        return Math.max(a, b.getHeight())
    }, -1)
}
;
gvjs_.VL = function(a, b) {
    for (var c = this.ep, d = 0; d < c.length; d++)
        c[d].VL(a, b)
}
;
gvjs_.find = function(a, b) {
    for (var c = [], d = this.ep, e = 0; e < d.length; e++)
        gvjs_Me(c, d[e].find(a, b));
    return c
}
;
gvjs_.MB = gvjs_n(76);
function gvjs_3L(a, b) {
    gvjs_2L.call(this);
    if (2 > a.$())
        throw Error("Data table should have at least 2 columns");
    if (a.W(0) != gvjs_l)
        throw Error("Column 0 must be of type string");
    if (a.W(1) != gvjs_l)
        throw Error("Column 1 must be of type string");
    b = this.Kt(b);
    for (var c = b.W9, d = b.X9, e = b.v$, f = {}, g = [], h = 0; h < a.ca(); h++)
        if (b = a.getValue(h, 0)) {
            var k = f[b];
            k ? null == k.getId() && k.lL(h) : (f[b] = k = new gvjs_0L(b,a,h),
            g.push(k));
            var l = k.getValue(1);
            if (l)
                if (b = f[l],
                b || (f[l] = b = new gvjs_0L(l,a,null),
                g.push(b)),
                k.getParent()) {
                    if (d)
                        throw Error("More than one row with the same id (" + k.getName() + ").");
                } else if (k != b && !k.contains(b))
                    b.addChild(k);
                else if (c) {
                    a = Error;
                    e = gvjs_kha;
                    g = b;
                    c = [];
                    for (b = b.getParent(); b; )
                        c.push(b),
                        b = b.getParent();
                    throw a("Data contains a cycle: " + e(this, gvjs_Ke(g, c)) + ".");
                }
        }
    for (b = 0; b < g.length; b++) {
        k = g[b];
        if (e && null === k.getId())
            throw Error('Failed to find row with id "' + k.getName() + '".');
        k.getParent() ? this.sB(k) : (a = k,
        this.ep.push(a),
        gvjs_6x(this, a),
        this.sB(a))
    }
}
gvjs_t(gvjs_3L, gvjs_2L);
function gvjs_kha(a, b) {
    return gvjs_v(b, function(c) {
        return c.getName()
    }).toString()
}
gvjs_3L.prototype.Kt = function(a) {
    var b = new gvjs_9F(2);
    gvjs_$F(b, 0, {
        W9: !0,
        X9: !0,
        v$: !0
    });
    null != a && gvjs_$F(b, 1, a);
    return b.compact()
}
;
function gvjs_4L(a, b, c, d, e) {
    gvjs_2L.call(this);
    a = a.ep;
    for (var f = 0; f < a.length; f++) {
        var g = gvjs_5L(this, a[f], b, c, d, e);
        this.ep.push(g);
        gvjs_6x(this, g);
        this.sB(g)
    }
}
gvjs_o(gvjs_4L, gvjs_2L);
function gvjs_5L(a, b, c, d, e, f) {
    var g = c.call(d, b)
      , h = null != e && null != f;
    if (h) {
        var k = e || 0
          , l = f || 0;
        g.NDa = (k + l / 2 * b.ze()) % 360
    }
    b = b.getChildren();
    for (f = 0; f < b.length; f++)
        e = b[f],
        h ? (e = gvjs_5L(a, e, c, d, k, e.$v() ? 0 : l / e.ze()),
        k = (k + l) % 360) : e = gvjs_5L(a, e, c, d),
        a.sB(e),
        g.addChild(e);
    return g
}
;function gvjs_6L(a, b, c) {
    c = null != c ? gvjs_v(c, function(l) {
        return [l, 0]
    }) : b ? gvjs_lha : gvjs_mha;
    var d = c.length;
    this.oh = [];
    for (var e = 1 + Math.floor((a - 1) / d), f = Math.ceil(a / e), g = [], h = 0; h < d; h++)
        c[h][1] < f && g.push(c[h][0]);
    for (h = 0; h < a; h++) {
        var k = Math.pow(b ? .7 : .85, b ? Math.floor(h / f) : h % e);
        this.oh[h] = gvjs_v(g[b ? h % f : Math.floor(h / e)], function(l) {
            return ~~(k * l + 255 * (1 - k))
        })
    }
}
gvjs_6L.prototype.Tb = function() {
    return this.oh.length
}
;
gvjs_6L.prototype.ee = function(a) {
    return "rgb(" + this.oh[a] + ")"
}
;
function gvjs_7L(a, b) {
    function c(d) {
        d = d.toString(16);
        1 == d.length && (d = "0" + d);
        return d
    }
    a = a.oh[b];
    return "#" + (c(a[0]) + c(a[1]) + c(a[2])).toUpperCase()
}
var gvjs_mha = [[[66, 133, 244], 0], [[219, 68, 55], 0], [[244, 180, 0], 0], [[15, 157, 88], 0], [[171, 71, 188], 0], [[0, 172, 193], 0], [[255, 112, 67], 0], [[158, 157, 36], 0], [[92, 107, 192], 0], [[240, 98, 146], 0], [[0, 121, 107], 0], [[194, 24, 91], 0]]
  , gvjs_lha = [[[67, 69, 157], 6], [[83, 168, 251], 8], [[95, 150, 84], 10], [[241, 202, 58], 2], [[231, 113, 27], 5], [[135, 27, 71], 4], [[67, 116, 224], 0], [[26, 135, 99], 1], [[185, 194, 70], 9], [[228, 147, 7], 7], [[211, 54, 45], 3]];
function gvjs_8L(a, b, c, d) {
    this.AH = a;
    this.LM = b;
    this.c2 = c;
    this.bna = d
}
gvjs_8L.prototype.qp = function(a) {
    this.Oba = a
}
;
gvjs_8L.prototype.CQ = function() {
    return this.Oba
}
;
gvjs_8L.prototype.Oba = !1;
function gvjs_9L(a, b, c) {
    this.Cl = a;
    a = a.ca();
    var d = b.cb("pagingButtons");
    null === this.uda && (d = b.cb("pagingButtonsConfiguration"));
    var e = null;
    null !== d && (e = parseInt(d, 10) || 0);
    var f = b.Aa("pageSize");
    0 === f && (f = null);
    this.e2 = gvjs_J(b, gvjs_cw, gvjs_ju) !== gvjs_ju || null != d || null != f;
    this.Wda = d || gvjs_ub;
    this.uda = e;
    this.e2 && (null != f || e || (f = 10),
    typeof f !== gvjs_g || e || (e = Math.ceil(a / f)),
    null == f && typeof e === gvjs_g && (f = Math.ceil(a / e)));
    this.aA = f || a;
    this.iK = Math.ceil(a / this.aA);
    this.foa = gvjs_L(b, "firstRowNumber", 1);
    this.Ena = c == gvjs_qu
}
function gvjs_$L(a, b) {
    a.Nm = Math.max(0, Math.min(a.iK - 1, b))
}
function gvjs_aM(a) {
    for (var b = gvjs_bM(a), c = [], d = {}, e = b.start; e <= b.end; e++) {
        var f = gvjs_cM(a, e);
        d[f.AH] = f.c2;
        c.push(f)
    }
    a.b2 = d;
    return c
}
gvjs_ = gvjs_9L.prototype;
gvjs_.AP = function() {
    return {
        column: this.FA,
        ascending: !this.jD,
        sortedIndexes: this.YE
    }
}
;
function gvjs_dM(a) {
    return gvjs_cM(a, gvjs_bM(a).start)
}
function gvjs_eM(a, b) {
    a.b2 || gvjs_aM(a);
    a = a.b2[b];
    return null != a ? a : -1
}
function gvjs_bM(a) {
    var b = a.aA * a.Nm
      , c = b + a.aA - 1;
    c = Math.min(a.Cl.ca() - 1, c);
    return new gvjs_O(b,c)
}
function gvjs_cM(a, b) {
    var c = a.YE
      , d = a.foa;
    a = gvjs_bM(a).start;
    return new gvjs_8L(c ? c[b] : b,b,b - a,b + d)
}
function gvjs_fM(a) {
    if (a.Ena && -1 != a.FA) {
        var b = a.Cl.bn([{
            column: a.FA,
            desc: a.jD
        }])
          , c = a.Cl.T$()
          , d = gvjs_v(b, function(e) {
            return c[e]
        }, a);
        a.Cl.pp(d);
        a.YE = a.YE ? gvjs_v(b, function(e) {
            return this.YE[e]
        }, a) : b
    } else
        a.YE = null
}
gvjs_.Nm = 0;
gvjs_.YE = null;
gvjs_.FA = -1;
gvjs_.jD = !1;
gvjs_.b2 = null;
function gvjs_gM(a, b, c) {
    gvjs_4D.call(this, a, b || gvjs_lE.Lc(), c)
}
gvjs_t(gvjs_gM, gvjs_4D);
gvjs_HD(gvjs_Hs, function() {
    return new gvjs_gM(null)
});
function gvjs_hM(a) {
    gvjs_Qn.call(this, a);
    this.D = gvjs_Oh();
    this.Of = new gvjs_$n;
    this.mq = {};
    this.VY = this.eP = this.Iy = this.XS = this.m_ = this.VS = this.Ut = null
}
gvjs_o(gvjs_hM, gvjs_Qn);
gvjs_ = gvjs_hM.prototype;
gvjs_.Rd = function(a, b, c) {
    if (!b)
        throw Error(gvjs_as);
    a = this.m = new gvjs_Aj([c]);
    this.NV = gvjs_K(a, gvjs_Us, !1);
    this.MV = gvjs_K(a, "allowHtmlSafely", !1);
    gvjs_K(a, "sanitizeHtml", !1);
    this.f4 = gvjs_K(a, "showRowNumber", !1);
    this.UT = gvjs_J(a, "sort", gvjs_qu);
    this.Of.clear();
    this.ra = b;
    this.Cl = new gvjs_N(this.ra);
    this.ge = new gvjs_9L(this.Cl,this.m,this.UT);
    if (this.i_ = 0 < this.ra.ca()) {
        (b = a.Aa("startPage")) && gvjs_$L(this.ge, b);
        b = a.Aa(gvjs__w);
        if (this.UT != gvjs_ju && null != b) {
            c = gvjs_K(a, "sortAscending", !0);
            var d = this.ge;
            d.FA = b;
            d.jD = !c;
            gvjs_fM(d)
        }
        this.wJ = gvjs_dM(this.ge)
    }
    this.US = gvjs_L(a, "scrollLeftStartPosition", 0);
    this.OR = Math.max(-1, gvjs_L(a, "frozenColumns", -1));
    this.gq = gvjs_x(gvjs_nha);
    gvjs_oha(this);
    a = !0;
    this.n$ && (a = gvjs_iM(this),
    this.n$ = !1);
    this.Qt();
    a ? (this.D.removeNode(this.FN),
    this.gx()) : this.rha(0)
}
;
gvjs_.gx = function() {
    gvjs_I(this, gvjs_i, null)
}
;
gvjs_.AP = function() {
    return this.ge ? this.ge.AP() : null
}
;
gvjs_.Qt = function(a) {
    var b = this.m
      , c = this.D;
    a || (this.YG(),
    this.oba = gvjs_Gh(this.container));
    this.qK = null;
    this.ea || (this.ea = new gvjs_KA);
    a = this.OR;
    var d = gvjs_J(b, gvjs_Xd, "")
      , e = gvjs_J(b, gvjs_4c, "")
      , f = this.mq.content;
    f || (f = c.J(gvjs_b, {
        "class": "google-visualization-table",
        style: "position:relative; z-index:0"
    }),
    this.mq.content = f,
    c.appendChild(this.container, f));
    gvjs_C(f, {
        visibility: gvjs_0u,
        "max-width": gvjs_So,
        "max-height": gvjs_So
    });
    d && (d = gvjs_jM(d),
    gvjs_C(f, {
        width: d
    }));
    e && (e = gvjs_jM(e));
    var g = this.Ut = gvjs_pha(this, f)
      , h = this.VS = gvjs_zh(c, gvjs_Ld, null, g)[0]
      , k = gvjs_K(b, "keepScrollPosition", !1)
      , l = this.US
      , m = 0;
    k && this.Ut && (l = this.Ut.scrollLeft,
    m = this.Ut.scrollTop);
    gvjs_C(g, {
        overflow: gvjs_ub,
        "max-width": gvjs_So,
        "max-height": gvjs_So
    });
    k = e && -1 === e.toString().indexOf("%");
    d && (gvjs_C(f, {
        width: d
    }),
    gvjs_C(g, {
        width: gvjs_So
    }),
    gvjs_C(h, {
        width: gvjs_So
    }));
    e && (gvjs_C(f, {
        height: e
    }),
    d = e,
    -1 < e.toString().indexOf("%") && (d = gvjs_So),
    gvjs_C(g, {
        height: d
    }),
    gvjs_C(h, {
        height: d
    }));
    !e && 0 < this.oba.height && (e = gvjs_Gh(f).height,
    h = gvjs_Gh(g).height,
    e < h && gvjs_C(f, {
        height: gvjs_So
    }),
    gvjs_C(g, {
        height: gvjs_So
    }));
    this.Iy = null;
    this.GI();
    this.ge.e2 && (e = this.mq[gvjs_dw],
    e || (e = c.J(gvjs_b),
    gvjs_WC(e, this.gq.fja),
    this.mq[gvjs_dw] = e,
    h = c.J(gvjs_b),
    gvjs_C(h, {
        clear: gvjs_ut,
        width: gvjs_So,
        height: gvjs_Nr
    }),
    this.mq["clear-float"] = h),
    c.qc(e),
    gvjs_C(g, {
        height: ""
    }),
    gvjs_qha(this, f),
    c = gvjs_Gh(f).height - (new gvjs_A(e.offsetWidth,e.offsetHeight)).height,
    0 < c && (0 < this.oba.height || k) && gvjs_C(g, {
        height: c + gvjs_T
    }));
    gvjs_K(b, "rtlTable", !1) && -1 == a && (this.VS.style.direction = gvjs_Up);
    g.scrollTop = m;
    g.scrollLeft = l;
    gvjs_C(f, {
        visibility: ""
    })
}
;
gvjs_.GI = function() {
    function a() {
        b.XS = null;
        var h = c.scrollTop
          , k = h + gvjs_T
          , l = c.scrollLeft
          , m = l + gvjs_T;
        f && (gvjs_VC(c, "doneScrolling"),
        gvjs_XC(c, "scrolling"));
        gvjs_sg ? (h != e && gvjs_u(b.Iy, function(n) {
            gvjs_C(n, {
                "-moz-transform": "translateY(" + (h - 1) + "px)"
            })
        }),
        l != g && gvjs_u(b.eP, function(n) {
            gvjs_C(n, {
                "-moz-transform": "translateX(" + m + ")"
            })
        }),
        gvjs_u(b.VY, function(n) {
            gvjs_C(n, {
                "-moz-transform": "translate3D(" + m + "," + (h - 1) + "px,0)"
            })
        })) : (h != e && gvjs_u(b.Iy, function(n) {
            gvjs_C(n, {
                top: k
            })
        }),
        l != g && gvjs_u(b.eP, function(n) {
            gvjs_C(n, {
                left: m
            })
        }));
        e = h;
        g = l
    }
    var b = this, c = this.Ut, d = this.D, e, f = gvjs_J(this.m, "scrollTransition", gvjs_ju) === gvjs_qu;
    f && (gvjs_VC(c, "scrolling"),
    gvjs_XC(c, "doneScrolling"));
    if (!this.Iy) {
        var g = e = 0;
        this.Iy = gvjs_Le(this.m_.childNodes);
        this.eP = gvjs_Le(d.wq(gvjs_Ju, this.VS));
        gvjs_sg && (this.VY = [],
        gvjs_u(gvjs_Le(this.Iy), function(h) {
            gvjs_UC(h, gvjs_Ju) && (b.VY.push(h),
            gvjs_Ie(b.Iy, h),
            gvjs_Ie(b.eP, h))
        }))
    }
    this.XS && clearTimeout(this.XS);
    f ? this.XS = setTimeout(a, 10) : a();
    return !0
}
;
function gvjs_pha(a, b) {
    var c = a.D
      , d = a.m
      , e = a.gq
      , f = a.ra
      , g = gvjs_kM(f);
    e = gvjs_rha(f, e);
    f = !1;
    var h = null
      , k = a.mq["scroll-pane"];
    k ? (f = !0,
    h = gvjs_zh(c, gvjs_Ld, null, k)[0],
    b = a.m_,
    gvjs_lM(a, b, e)) : (k = a.D.J(gvjs_b, {
        style: "position: relative;"
    }),
    c.appendChild(b, k),
    a.mq["scroll-pane"] = k,
    a.ea.o(k, gvjs_Gw, function() {
        a.GI()
    }),
    b = a.m_ = gvjs_lM(a, null, e));
    var l = d.mz(gvjs_Ku)
      , m = a.OR + (a.f4 ? 1 : 0)
      , n = c.getChildren(b);
    gvjs_u(n, function(p, q) {
        q < m && (gvjs_VC(p, gvjs_Ju),
        l && gvjs_C(p, {
            "background-color": l
        }))
    });
    0 < m && n.length > m && gvjs_VC(n[m - 1], gvjs_qv);
    f ? gvjs_mM(a, h, b, d, e, g) : (h = gvjs_mM(a, null, b, d, e, g),
    c.appendChild(k, h));
    return k
}
function gvjs_mM(a, b, c, d, e, f) {
    var g = a.ra
      , h = a.D
      , k = a.gq;
    if (b)
        c = gvjs_zh(h, "tbody", null, b)[0],
        gvjs_hh(c);
    else {
        b = h.J(gvjs_ss, {
            cellspacing: "0"
        });
        gvjs_WC(b, k.G6);
        var l = h.J("THEAD");
        h.appendChild(b, l);
        h.appendChild(l, c);
        c = h.J(gvjs_ts);
        h.appendChild(b, c)
    }
    l = new gvjs_gk({
        fractionDigits: 0,
        pattern: "#"
    });
    var m = d.mz(gvjs_Ku);
    null == a.qK && (a.qK = a.i_ ? gvjs_aM(a.ge) : []);
    var n = a.qK
      , p = a.OR;
    d = gvjs_K(d, gvjs_Vs, !0);
    d = null != d ? d : !0;
    for (var q = 0; q < n.length; q++) {
        var r = 0 == q % 2
          , t = n[q]
          , u = t.AH
          , v = gvjs_do(a.Of, u)
          , w = g.Ul(u, "rowColor")
          , x = g.Ul(u, gvjs_Db);
        t.qp(v);
        u = h.J(gvjs_vs);
        x && gvjs_TC(u, x);
        v && gvjs_WC(u, k.KM);
        d ? gvjs_WC(u, r ? k.zV : k.K6) : gvjs_WC(u, k.zV);
        a.ea.o(u, gvjs_gd, a.ZZ.bind(a, t));
        a.ea.o(u, gvjs_ld, a.a_.bind(a, t));
        a.ea.o(u, gvjs_kd, a.$Z.bind(a, t));
        h.appendChild(c, u);
        a.f4 && (r = h.J(gvjs_us),
        gvjs_WC(r, k.xV),
        gvjs_WC(r, k.D6),
        h.appendChild(u, r),
        h.appendChild(r, h.createTextNode(l.Ob(t.bna))),
        w && gvjs_C(r, {
            "background-color": w
        }),
        0 <= p && (gvjs_VC(r, gvjs_Ju),
        0 === p && gvjs_VC(r, gvjs_qv),
        m && gvjs_C(r, {
            "background-color": m
        })));
        r = g.$();
        for (v = 0; v < r; v += x) {
            var y = t.AH
              , z = e[v];
            (x = g.getProperty(y, v, gvjs_Db)) && typeof x === gvjs_l && (z = gvjs_Ke(z, gvjs_kf(x).split(/\s+/)));
            x = (x = Number(g.getProperty(y, v, "__td-colSpan"))) && Math.min(x, r - v);
            if (!x || 1 >= x)
                x = 1;
            var A = h.J(gvjs_us, {
                colSpan: x
            });
            gvjs_WC(A, z || []);
            gvjs_WC(A, k.xV);
            h.appendChild(u, A);
            w && gvjs_C(A, {
                "background-color": w
            });
            z = g.getValue(y, v);
            var B = g.Ha(y, v);
            null == z ? B = gvjs_jf(gvjs_gg(B)) ? "\u00a0" : B : f[v] == gvjs_zb && (B = z ? "\u2714" : "\u2717");
            if (a.NV || a.MV) {
                if (z = gvjs_OA(B),
                gvjs_cg(A, z),
                y = g.getProperty(y, v, gvjs_Jd))
                    y = gvjs_PA(String(y)),
                    A.style.cssText = gvjs_Ff(y)
            } else
                h.appendChild(A, h.createTextNode(B));
            v <= p - 1 && (gvjs_VC(A, gvjs_Ju),
            v === p - 1 && gvjs_VC(A, gvjs_qv),
            m && gvjs_C(A, {
                "background-color": m
            }))
        }
    }
    return b
}
function gvjs_lM(a, b, c) {
    function d(q) {
        var r = ["unsorted", "sort-descending", "sort-ascending"]
          , t = a.ge.FA;
        gvjs_u(q.childNodes, function(u) {
            var v = u.index;
            gvjs_YC(u, r);
            if (g) {
                var w = 0;
                t === v && (w = a.ge.jD ? 1 : 2);
                gvjs_VC(u, r[w])
            }
        })
    }
    var e = a.ra
      , f = a.gq
      , g = a.UT != gvjs_ju && 0 < e.ca();
    if (b)
        return d(b),
        b;
    b = a.D;
    var h = e.$()
      , k = b.J(gvjs_vs);
    gvjs_WC(k, f.J6);
    if (a.f4 && 0 < e.$()) {
        var l = b.J("TH");
        gvjs_WC(l, f.yV);
        l.innerText = "\u00a0";
        b.appendChild(k, l)
    }
    for (var m = 0; m < h; m++) {
        l = b.J("TH", {
            index: m
        });
        gvjs_WC(l, f.yV);
        gvjs_WC(l, c[m] || []);
        b.appendChild(k, l);
        var n = e.Ga(m)
          , p = l;
        a.NV || a.MV ? gvjs__x(p, gvjs_OA(n)) : b.appendChild(p, b.createTextNode(n));
        g && (n = b.J(gvjs_6a),
        gvjs_WC(n, f.Dja),
        b.appendChild(l, n),
        l.setAttribute(gvjs_9w, 0),
        l.setAttribute(gvjs_Bd, gvjs_Bt),
        l.setAttribute(gvjs_et, "Sort column"));
        a.ea.o(l, gvjs_Wt, a.raa.bind(a, m), !0);
        a.ea.o(l, gvjs_7c, a.dqa.bind(a, m), !0)
    }
    d(k);
    return k
}
function gvjs_qha(a, b) {
    var c = a.D
      , d = a.gq
      , e = a.m.pb("pagingSymbols", {})
      , f = e.prev;
    e = e.next;
    var g = a.NV || a.MV;
    if (f)
        if (g) {
            var h = c.J(gvjs_6a);
            gvjs__x(h, gvjs_OA(f))
        } else
            h = String(f);
    else
        h = c.J(gvjs_6a, {
            alt: "previous"
        }),
        gvjs_WC(h, d.jja);
    e ? g ? (f = c.J(gvjs_6a),
    gvjs__x(f, gvjs_OA(e))) : f = String(e) : (f = c.J(gvjs_6a, {
        alt: "next"
    }),
    gvjs_WC(f, d.gja));
    gvjs_E(a.yK);
    gvjs_E(a.aK);
    e = a.yK = new gvjs_gM(h);
    f = a.aK = new gvjs_gM(f);
    e.Lw(2);
    f.Lw(1);
    gvjs_MA(a.ea, e, gvjs_Ss, function() {
        gvjs_nM(this, !1)
    }, a);
    gvjs_MA(a.ea, f, gvjs_Ss, function() {
        gvjs_nM(this, !0)
    }, a);
    gvjs_oM(a);
    h = a.mq[gvjs_dw];
    c.appendChild(b, h);
    c.appendChild(b, a.mq["clear-float"]);
    e.R(h);
    f.R(h);
    if (!(1 >= a.ge.iK)) {
        var k = c.J(gvjs_b);
        gvjs_WC(k, d.ija);
        c.appendChild(h, k);
        f = a.ge.iK;
        var l = a.ge.Nm;
        b = a.ge.uda;
        null == b && (b = f);
        if (null == b || 0 < b)
            h = gvjs_pM(0, l - 1),
            e = gvjs_pM(l + 1, f - 1),
            e = gvjs_v(gvjs_Ke(h, l, e), function(m, n) {
                return {
                    n: m,
                    current: l === n
                }
            }),
            h = Math.max(0, h.length - Math.floor((b - 1) / 2)),
            f = Math.min(f, h + b),
            h = Math.max(0, f - b),
            e = gvjs_Oe(e, h, f),
            gvjs_u(e, function(m) {
                var n = m.n;
                m = c.J("A", {
                    href: "javascript:void(0)",
                    "class": m.current ? "current" : ""
                });
                gvjs_WC(m, d.hja);
                m.innerText = String(Number(n) + 1);
                gvjs_MA(this.ea, m, gvjs_Wt, function(p) {
                    p.preventDefault();
                    gvjs_qM(this, n)
                }, this);
                c.appendChild(k, m)
            }, a)
    }
}
function gvjs_pM(a, b) {
    var c = [];
    if (a + 10 > b)
        for (; a <= b; a++)
            c.push(a);
    else {
        c.push(a);
        c.push(b);
        for (var d = 10; a < b; )
            a = d * Math.ceil((a + 2) / d) - 1,
            a < b && c.push(a),
            b = d * Math.floor(b / d) - 1,
            a < b && c.push(b),
            d *= 10;
        gvjs_Qe(c)
    }
    return c
}
function gvjs_oha(a) {
    var b = a.gq
      , c = a.m.pb("cssClassNames");
    c && gvjs_w(gvjs_sha, function(d, e) {
        d = c[d];
        gvjs_ne(d) ? b[e] = d : d && (b[e] = gvjs_kf(d).split(/\s+/))
    })
}
function gvjs_nM(a, b) {
    var c = a.ge.iK
      , d = a.ge.Nm;
    gvjs_qM(a, b ? Math.min(c, d + 1) : Math.max(0, d - 1))
}
function gvjs_qM(a, b) {
    a.ge.e2 && (gvjs_$L(a.ge, b),
    a.Ut && (a.US = a.Ut.scrollLeft),
    a.Qt(!0));
    gvjs_oM(a);
    gvjs_I(a, gvjs_cw, {
        page: b
    })
}
function gvjs_oM(a) {
    a: {
        var b = a.ge;
        switch (b.Wda) {
        case "prev":
            b = !1;
            break a;
        case "next":
        case gvjs_ut:
            b = !0;
            break a;
        default:
            b = b.Nm != b.iK - 1
        }
    }
    a.aK.Gb(b);
    a: switch (b = a.ge,
    b.Wda) {
    case "next":
        b = !1;
        break a;
    case "prev":
    case gvjs_ut:
        b = !0;
        break a;
    default:
        b = 0 != b.Nm
    }
    a.yK.Gb(b)
}
function gvjs_iM(a) {
    var b = a.FN;
    if (!b) {
        var c = a.container;
        b = a.D.J(gvjs_b, {
            style: "position: absolute; top: -5000px;",
            "class": "google-visualization-table-loadtest"
        }, a.D.createTextNode("\u00a0"));
        a.D.appendChild(c, b);
        a.FN = b
    }
    return "6" == gvjs_Ih(b).left
}
gvjs_.rha = function(a) {
    if (10 > a)
        if (gvjs_iM(this))
            this.draw(this.ra, this.m);
        else {
            var b = 200 * a;
            a++;
            setTimeout(this.rha.bind(this, a), b)
        }
    else
        this.D.removeNode(this.FN),
        this.gx()
}
;
gvjs_.getSelection = function() {
    return this.Of.getSelection()
}
;
gvjs_.setSelection = function(a) {
    if (this.ra) {
        var b = this.Of.setSelection(a);
        a = this.qK;
        this.wJ = gvjs_dM(this.ge);
        for (var c = gvjs_rM(this), d, e = this.gq, f = gvjs_bo(b.An), g = 0; g < f.length; g++)
            d = gvjs_eM(this.ge, f[g]),
            -1 != d && (a[d].qp(!1),
            (d = c[d]) && gvjs_YC(d, e.KM));
        b = gvjs_bo(b.uB);
        for (f = 0; f < b.length; f++)
            d = gvjs_eM(this.ge, b[f]),
            -1 != d && (a[d].qp(!0),
            (d = c[d]) && gvjs_WC(d, e.KM))
    }
}
;
gvjs_.ZZ = function(a, b) {
    var c = this.wJ
      , d = a.AH;
    var e = gvjs_ug ? b.metaKey : b.ctrlKey;
    if (b.shiftKey) {
        b.preventDefault();
        var f = Math.min(a.LM, c.LM);
        d = Math.max(a.LM, c.LM);
        e = e ? this.Of.getSelection() : [];
        for (var g = this.ge, h = []; f <= d; f++) {
            var k = gvjs_cM(g, f);
            h.push(k)
        }
        for (d = 0; d < h.length; d++)
            e.push({
                row: h[d].AH
            })
    } else
        e ? (b.preventDefault(),
        e = this.Of.getSelection(),
        gvjs_do(this.Of, d) ? (h = new gvjs_$n,
        h.setSelection(e),
        h.qE(d),
        e = h.getSelection()) : e.push({
            row: d
        })) : e = gvjs_do(this.Of, d) ? null : [{
            row: d
        }];
    this.setSelection(e);
    this.wJ = b.shiftKey ? c : a;
    gvjs_I(this, gvjs_k, {})
}
;
gvjs_.a_ = function(a) {
    var b = gvjs_rM(this)
      , c = this.gq;
    (a = b[a.c2]) && gvjs_WC(a, c.AV)
}
;
gvjs_.$Z = function(a) {
    var b = gvjs_rM(this)
      , c = this.gq;
    (a = b[a.c2]) && gvjs_YC(a, c.AV)
}
;
function gvjs_rM(a) {
    return gvjs_zh(a.D, "tbody", null, a.VS)[0].childNodes
}
gvjs_.raa = function(a) {
    var b = this.ge
      , c = !b.jD;
    c = b.FA == a ? !c : !0;
    "event" != this.UT ? (b.FA = a,
    b.jD = !c,
    gvjs_fM(b),
    gvjs_$L(this.ge, 0),
    this.wJ = gvjs_dM(this.ge),
    this.Ut && (this.US = this.Ut.scrollLeft),
    this.Qt(!0),
    gvjs_I(this, "sort", this.ge.AP())) : gvjs_I(this, "sort", {
        column: a,
        ascending: c,
        sortedIndexes: null
    })
}
;
gvjs_.dqa = function(a, b) {
    13 == b.keyCode && this.raa(a)
}
;
gvjs_.YG = function() {
    gvjs_E(this.ea);
    this.ea = null;
    this.D.qc(this.container);
    gvjs_E(this.yK);
    this.yK = null;
    gvjs_E(this.aK);
    this.aK = null;
    this.mq = {}
}
;
gvjs_.Jb = function() {
    this.YG();
    this.Of.clear();
    this.ge = null
}
;
function gvjs_jM(a) {
    if (gvjs_jf(gvjs_gg(a)))
        return a;
    var b = a;
    gvjs_Yy(a) && "0" !== String(a) && (b += gvjs_T);
    return b
}
function gvjs_rha(a, b) {
    return gvjs_v(gvjs_kM(a), function(c, d) {
        var e = [];
        switch (c) {
        case gvjs_zb:
            e = b.Yha;
            break;
        case gvjs_g:
            e = b.$ha;
            break;
        case gvjs_Lb:
        case gvjs_Mb:
        case gvjs_Od:
            e = b.Zha
        }
        (c = a.Bd(d, gvjs_Db)) && typeof c === gvjs_l && (e = gvjs_Ke(e, gvjs_kf(c).split(/\s+/)));
        return e
    })
}
function gvjs_kM(a) {
    for (var b = [], c = 0; c < a.$(); c++)
        b.push(a.W(c));
    return b
}
var gvjs_nha = {
    G6: ["google-visualization-table-table"],
    J6: ["google-visualization-table-tr-head"],
    zV: ["google-visualization-table-tr-even"],
    K6: ["google-visualization-table-tr-odd"],
    KM: ["google-visualization-table-tr-sel"],
    AV: ["google-visualization-table-tr-over"],
    yV: ["google-visualization-table-th", gvjs_Bp],
    xV: ["google-visualization-table-td"],
    $ha: ["google-visualization-table-type-number"],
    Zha: ["google-visualization-table-type-date"],
    Yha: ["google-visualization-table-type-bool"],
    D6: ["google-visualization-table-seq"],
    uBa: ["google-visualization-table-sorthdr"],
    Dja: ["google-visualization-table-sortind"],
    fja: ["google-visualization-table-div-page", gvjs_Bp],
    ija: ["google-visualization-table-page-numbers"],
    hja: ["google-visualization-table-page-number", gvjs_Bp],
    jja: ["google-visualization-table-page-prev"],
    gja: ["google-visualization-table-page-next"]
}
  , gvjs_sha = {
    J6: "headerRow",
    zV: "tableRow",
    K6: "oddTableRow",
    KM: "selectedTableRow",
    AV: "hoverTableRow",
    yV: "headerCell",
    xV: "tableCell",
    D6: "rowNumberCell"
};
gvjs_ = gvjs_hM.prototype;
gvjs_.n$ = !0;
gvjs_.FN = null;
gvjs_.gq = null;
gvjs_.wJ = null;
gvjs_.ra = null;
gvjs_.Cl = null;
gvjs_.m = null;
gvjs_.ge = null;
gvjs_.qK = null;
gvjs_.OR = -1;
gvjs_.i_ = !1;
gvjs_.yK = null;
gvjs_.aK = null;
gvjs_.US = 0;
gvjs_.ea = null;
function gvjs_tha(a, b) {
    Array.isArray(b) || (b = [b]);
    b = b.map(function(c) {
        return typeof c === gvjs_l ? c : c.property + " " + c.duration + "s " + c.timing + " " + c.delay + "s"
    });
    gvjs_sM(a, b.join(","))
}
var gvjs_uha = gvjs_ze(function() {
    if (gvjs_y)
        return gvjs_Eg("10.0");
    var a = gvjs_dh(gvjs_b)
      , b = gvjs_tg ? "-webkit" : gvjs_sg ? "-moz" : gvjs_y ? "-ms" : gvjs_qg ? "-o" : null
      , c = {
        transition: gvjs_8v
    };
    b && (c[b + "-transition"] = gvjs_8v);
    b = gvjs_5f(gvjs_Ob, {
        style: c
    });
    gvjs_cg(a, b);
    return "" != gvjs_qz(a.firstChild, "transition")
});
function gvjs_sM(a, b) {
    gvjs_C(a, "transition", b)
}
;function gvjs_tM(a, b, c, d, e) {
    gvjs_0E.call(this);
    this.H = a;
    this.Nk = b;
    this.Nra = c;
    this.j$ = d;
    this.YA = Array.isArray(e) ? e : [e]
}
gvjs_t(gvjs_tM, gvjs_0E);
gvjs_ = gvjs_tM.prototype;
gvjs_.play = function() {
    if (this.So())
        return !1;
    this.jK();
    this.Jh("play");
    this.startTime = gvjs_se();
    this.K = 1;
    if (gvjs_uha())
        return gvjs_C(this.H, this.Nra),
        this.tm = gvjs_pl(this.Zua, void 0, this),
        !0;
    this.KA(!1);
    return !1
}
;
gvjs_.Zua = function() {
    gvjs_Dz(this.H);
    gvjs_tha(this.H, this.YA);
    gvjs_C(this.H, this.j$);
    this.tm = gvjs_pl(gvjs_s(this.KA, this, !1), 1E3 * this.Nk)
}
;
gvjs_.stop = function() {
    this.So() && this.KA(!0)
}
;
gvjs_.KA = function(a) {
    gvjs_sM(this.H, "");
    gvjs_ql(this.tm);
    gvjs_C(this.H, this.j$);
    this.endTime = gvjs_se();
    this.K = 0;
    a ? this.Jh(gvjs__p) : this.Jh(gvjs_vu);
    this.Xz()
}
;
gvjs_.M = function() {
    this.stop();
    gvjs_tM.G.M.call(this)
}
;
gvjs_.pause = function() {}
;
function gvjs_uM(a, b, c, d, e) {
    return new gvjs_tM(a,b,{
        opacity: d
    },{
        opacity: e
    },{
        property: gvjs_Kp,
        duration: b,
        timing: c,
        delay: 0
    })
}
function gvjs_vM(a, b) {
    return gvjs_uM(a, b, "ease-out", 0, 1)
}
function gvjs_wM(a, b) {
    return gvjs_uM(a, b, "ease-in", 1, 0)
}
;