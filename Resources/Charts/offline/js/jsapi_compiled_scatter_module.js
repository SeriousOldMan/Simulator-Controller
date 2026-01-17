function gvjs_63(a) {
    gvjs_aT.call(this, a)
}
gvjs_o(gvjs_63, gvjs_aT);
gvjs_63.prototype.rI = function() {
    var a = [];
    gvjs_u(this.layout, function(b) {
        b.C.forEach(function(c) {
            var d = []
              , e = c.color;
            gvjs_u(c.data, function(f) {
                null != f.Tt && null != f.Iw && isFinite(f.Tt) && isFinite(f.Iw) && (f.color = e,
                d.push((new gvjs_2Q).style("x", f.Tt).style("y", f.Iw).style("r", 6).style(gvjs_rp, e).style(gvjs_sp, .6).data({
                    value: f,
                    id: gvjs_KL(gvjs_wR(c.sourceColumn, f.ZE), gvjs_JQ, b.column)
                })))
            });
            gvjs_Me(a, d)
        })
    });
    return a
}
;
function gvjs_73(a, b, c, d) {
    gvjs_DS.call(this, a, b, c, d)
}
gvjs_o(gvjs_73, gvjs_DS);
gvjs_73.prototype.vi = function() {
    return gvjs_J(this.options, gvjs_9v, gvjs_S, gvjs_CS)
}
;
gvjs_73.prototype.hZ = function(a, b, c) {
    return new gvjs_63({
        options: this.options,
        Zna: !0,
        $na: !0,
        table: this.Ta,
        Sm: this.jO.Sm,
        rK: c,
        axes: {
            domain: a,
            target: b
        }
    })
}
;
function gvjs_83(a, b) {
    gvjs_GS.call(this, a, b);
    this.q8 = !1
}
gvjs_o(gvjs_83, gvjs_GS);
gvjs_ = gvjs_83.prototype;
gvjs_.Lp = function(a) {
    a.style(gvjs_Xp, 0).style(gvjs_Yp, 1).style(gvjs_Vp, .4).style(gvjs_Wp, 2);
    return a
}
;
gvjs_.dr = function(a) {
    a.style(gvjs_Xp, null).style(gvjs_Yp, null).style(gvjs_Vp, null).style(gvjs_Wp, null);
    return a
}
;
gvjs_.CT = function(a) {
    var b = a.data().value.color;
    this.Lp(a).style(gvjs_pp, b).style(gvjs_qp, 1)
}
;
gvjs_.tT = function(a) {
    a.data();
    this.Lp(a).style(gvjs_qp, 1)
}
;
gvjs_.pT = function(a) {
    a.data();
    this.dr(a).style(gvjs_qp, .3)
}
;
gvjs_.zT = function(a) {
    a.data();
    this.dr(a).style(gvjs_qp, .6)
}
;
function gvjs_93(a) {
    gvjs_UL.call(this, a)
}
gvjs_o(gvjs_93, gvjs_UL);
gvjs_ = gvjs_93.prototype;
gvjs_.xq = function() {
    return null
}
;
gvjs_.og = function() {
    return gvjs_mj({}, gvjs_FS, {
        axes: {
            domain: {
                all: {
                    gridlines: !0
                }
            },
            target: {
                all: {
                    gridlines: !0
                }
            }
        }
    })
}
;
gvjs_.po = function(a, b, c, d) {
    a = new gvjs_AR(this,a,b,c,d);
    a.$t([gvjs_Wo, gvjs_Pu, gvjs_Cw, gvjs_YQ, gvjs_RQ, gvjs_Ds, gvjs_Cs, gvjs_Pd]);
    return a
}
;
gvjs_.Mm = function(a, b) {
    return new gvjs_83(a,b)
}
;
gvjs_.Al = function(a, b, c, d) {
    return new gvjs_73(a,b,c,d)
}
;
gvjs_.xs = function(a) {
    return [new gvjs_IR([new gvjs_IL(gvjs_3r)]), new gvjs_KR([new gvjs_IL(gvjs_HQ), new gvjs_IL(gvjs_IQ)],gvjs_J(a, gvjs_Kw) === gvjs_Ww), new gvjs_JR([new gvjs_IL(gvjs_3r), new gvjs_IL(gvjs_HQ), new gvjs_IL(gvjs_IQ), new gvjs_IL(gvjs_NQ)]), new gvjs_MR([new gvjs_IL(gvjs_HQ)])]
}
;
gvjs_.nH = function(a, b) {
    null == this.sb ? this.sb = new gvjs_oR(this.container,a,b,[gvjs_qs, gvjs_LQ]) : this.sb.update(a, b)
}
;
gvjs_q(gvjs_0b, gvjs_93, void 0);
gvjs_93.convertOptions = function(a) {
    return gvjs__S(a)
}
;
gvjs_93.prototype.draw = gvjs_93.prototype.draw;
gvjs_93.prototype.clearChart = gvjs_93.prototype.Jb;
gvjs_93.prototype.getSelection = gvjs_93.prototype.getSelection;
gvjs_93.prototype.setSelection = gvjs_93.prototype.setSelection;
