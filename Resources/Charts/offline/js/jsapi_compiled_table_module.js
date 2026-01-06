function gvjs_LU(a) {
    return a instanceof gvjs_Xm ? a.clone() : new gvjs_Xm(a,void 0)
}
;function gvjs_MU(a, b, c, d) {
    this.cf = a;
    this.eF = new gvjs_hM(b);
    this.Sna = c;
    gvjs_oi(this.eF, gvjs_cw, gvjs_s(this.yaa, this));
    gvjs_oi(this.eF, "sort", gvjs_s(this.Wqa, this));
    this.fU = a = void 0 !== d ? gvjs_x(d) : {};
    this.P9 = d.page == gvjs_qu;
    a.showRowNumber = !0;
    a.pagingButtonsConfiguration = d.pagingButtonsConfiguration || gvjs_ut;
    a.sort = null == d.sort || d.sort == gvjs_qu ? "event" : gvjs_ju;
    this.P9 && (a.page = "event",
    d = d.pageSize || 0,
    this.aA = 0 >= d ? 10 : d,
    a.pageSize = this.aA,
    this.Nm = 0,
    gvjs_NU(this, 0))
}
gvjs_ = gvjs_MU.prototype;
gvjs_.GE = function() {
    this.DX && this.DX();
    var a = gvjs_LU(this.cf).cg.get("tq") || "";
    a += " " + this.Zfa + " " + this.Vda;
    this.Dw = new gvjs_En(this.cf);
    this.Dw.Jn(a);
    this.np(this.Ew);
    this.abort();
    this.eF.setSelection([]);
    this.mE = new gvjs_uo(this.Dw,this.eF,this.fU,this.Sna);
    this.mE.oT(gvjs_s(this.Hw, this));
    this.mE.nT(this.X8);
    this.mE.GE()
}
;
gvjs_.abort = function() {
    this.mE && this.mE.abort()
}
;
gvjs_.Wqa = function(a) {
    var b = a.column;
    a = a.ascending;
    this.fU.sortColumn = b;
    this.fU.sortAscending = a;
    this.Zfa = "order by `" + this.zs.Ne(b) + (a ? "`" : "` desc");
    this.P9 ? this.yaa({
        page: 0
    }) : this.GE()
}
;
gvjs_.np = function(a) {
    this.Ew = Math.max(0, a);
    this.Dw && this.Dw.np(this.Ew)
}
;
gvjs_.yaa = function(a) {
    var b = this.Nm
      , c = 0;
    switch (a.page) {
    case 0:
        c = 0;
        break;
    case 1:
        c = b + 1;
        break;
    case -1:
        c = b - 1
    }
    gvjs_NU(this, c);
    this.GE()
}
;
function gvjs_NU(a, b) {
    var c = a.Nm, d = a.aA, e;
    if (!(e = 0 > b || b > c + 1)) {
        if (c = b == c + 1)
            c = -1,
            a.zs && (c = a.zs.ca()),
            c = c <= d;
        e = c
    }
    e || (a.Nm = b,
    b = a.Nm * d,
    a.Vda = "limit " + (d + 1) + " offset " + b,
    a.fU.firstRowNumber = b + 1)
}
gvjs_.Hw = function(a) {
    this.CX && this.CX(a);
    this.zs = a.Xk() ? null : a.mb()
}
;
gvjs_.oT = function(a) {
    if (null != a) {
        if (typeof a != gvjs_d)
            throw Error(gvjs_Aa);
        this.CX = a
    }
}
;
gvjs_.nT = function(a) {
    if (null != a) {
        if (typeof a != gvjs_d)
            throw Error("Custom post-response handler must be a function.");
        this.X8 = a
    }
}
;
gvjs_.ywa = function(a) {
    if (null != a) {
        if (typeof a != gvjs_d)
            throw Error("Custom sendAndDraw must be a function.");
        this.DX = a
    }
}
;
gvjs_.mE = null;
gvjs_.Dw = null;
gvjs_.zs = null;
gvjs_.Zfa = "";
gvjs_.Vda = "";
gvjs_.aA = -1;
gvjs_.Nm = -1;
gvjs_.Ew = 0;
gvjs_.DX = null;
gvjs_.CX = null;
gvjs_.X8 = null;
gvjs_q(gvjs_Vc, gvjs_hM, void 0);
gvjs_hM.prototype.draw = gvjs_hM.prototype.draw;
gvjs_hM.prototype.getSelection = gvjs_hM.prototype.getSelection;
gvjs_hM.prototype.setSelection = gvjs_hM.prototype.setSelection;
gvjs_hM.prototype.getSortInfo = gvjs_hM.prototype.AP;
gvjs_hM.prototype.clearChart = gvjs_hM.prototype.Jb;
gvjs_q("google.visualization.TableQueryWrapper", gvjs_MU, void 0);
gvjs_MU.prototype.sendAndDrawTable = gvjs_MU.prototype.GE;
gvjs_MU.prototype.abort = gvjs_MU.prototype.abort;
gvjs_MU.prototype.setCustomSendAndDraw = gvjs_MU.prototype.ywa;
gvjs_MU.prototype.setCustomPostResponseHandler = gvjs_MU.prototype.nT;
gvjs_MU.prototype.setCustomResponseHandler = gvjs_MU.prototype.oT;
gvjs_MU.prototype.setRefreshInterval = gvjs_MU.prototype.np;
gvjs_MU.prototype.abort = gvjs_MU.prototype.abort;
