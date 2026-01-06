var gvjs_GQ = '". Axis does not exist.'
  , gvjs_HQ = "CELL"
  , gvjs_IQ = "COLUMN"
  , gvjs_JQ = "DOMAIN_INDEX"
  , gvjs_KQ = "OBJECT_INDEX"
  , gvjs_LQ = "Roboto:medium"
  , gvjs_MQ = "Shape does not exist in this group."
  , gvjs_NQ = "TOOLTIP"
  , gvjs_OQ = "Unknown granularity."
  , gvjs_PQ = "above"
  , gvjs_QQ = "chart.style.text"
  , gvjs_RQ = "fgrid"
  , gvjs_SQ = "legend.style.text"
  , gvjs_TQ = "links"
  , gvjs_UQ = "margin.bottom"
  , gvjs_VQ = "max-lines"
  , gvjs_WQ = "min-width"
  , gvjs_XQ = "remove"
  , gvjs_YQ = "selectedRows"
  , gvjs_ZQ = "subtitle"
  , gvjs__Q = "ticks.pixelsPerTick"
  , gvjs_0Q = "tooltip-shapes";
function gvjs_1Q(a, b, c, d) {
    gvjs_wq.call(this, d);
    null != a && this.setStyle("x", a);
    null != b && this.setStyle("y", b);
    null != c && this.setStyle(gvjs_m, c)
}
gvjs_o(gvjs_1Q, gvjs_wq);
gvjs_1Q.prototype.Rk = gvjs_n(31);
function gvjs_2Q(a, b, c, d) {
    gvjs_wq.call(this, d);
    null != a && this.setStyle("r", a);
    null != b && this.setStyle("x", b);
    null != c && this.setStyle("y", c)
}
gvjs_o(gvjs_2Q, gvjs_wq);
gvjs_2Q.prototype.Rk = gvjs_n(30);
gvjs_2Q.prototype.Ou = function() {
    var a = this.style("r")
      , b = this.style("x")
      , c = this.style("y");
    this.eo = {
        x: b - a,
        y: c - a,
        width: 2 * a,
        height: 2 * a
    };
    return !0
}
;
function gvjs_3Q(a, b, c, d, e) {
    gvjs_wq.call(this, e);
    null != a && this.setStyle("x1", a);
    null != b && this.setStyle("y1", b);
    null != c && this.setStyle("x2", c);
    null != d && this.setStyle("y2", d)
}
gvjs_o(gvjs_3Q, gvjs_wq);
gvjs_3Q.prototype.Rk = gvjs_n(29);
gvjs_3Q.prototype.Ou = function() {
    var a = this.style("x1")
      , b = this.style("y1")
      , c = this.style("x2")
      , d = this.style("y2");
    this.eo = {
        x: Math.min(a, c),
        y: Math.min(b, d),
        width: Math.abs(c - a),
        height: Math.abs(d - b)
    };
    return !0
}
;
function gvjs_4Q(a, b, c, d, e) {
    gvjs_wq.call(this, e);
    null != a && this.setStyle("x", a);
    null != b && this.setStyle("y", b);
    null != c && this.setStyle(gvjs_Xd, c);
    null != d && this.setStyle(gvjs_4c, d)
}
gvjs_o(gvjs_4Q, gvjs_wq);
gvjs_4Q.prototype.Rk = gvjs_n(28);
gvjs_4Q.prototype.Ou = function() {
    var a = gvjs_xq(this);
    this.eo = {
        x: gvjs_L(a, "x"),
        y: gvjs_L(a, "y"),
        width: gvjs_L(a, gvjs_Xd),
        height: gvjs_L(a, gvjs_4c)
    };
    return !0
}
;
gvjs_4Q.prototype.clone = function() {
    var a = gvjs_xq(this);
    return new gvjs_4Q(a.Aa("x"),a.Aa("y"),a.Aa(gvjs_Xd),a.Aa(gvjs_4c),this.md)
}
;
var gvjs_Cia = {
    circle: function(a) {
        return new gvjs_2Q(a.radius,a.x,a.y,{
            fill: a.fill
        })
    },
    line: function(a) {
        return new gvjs_3Q(a.x,a.y,a.x2,a.y2,a)
    },
    rect: function(a) {
        return new gvjs_4Q(a.x,a.y,a.width,a.height,a)
    },
    text: function(a) {
        return new gvjs_1Q(a.x,a.y,a.text,a)
    }
};
gvjs_ZL.prototype.zP = gvjs_V(75, function() {
    return this.Vg
});
gvjs_WL.prototype.Hl = gvjs_V(74, function() {
    if (null == this.yn) {
        var a = gvjs_Cia[this.pf];
        if (!a)
            throw Error("No draw routine for " + this.pf + ".");
        this.yn = a.call(null, this.ar());
        this.yn.data({
            idStr: this.h$.ie()
        })
    }
    return this.yn
});
gvjs_TL.prototype.$t = gvjs_V(73, function(a) {
    this.Ez = a
});
gvjs_DL.prototype.cp = gvjs_V(72, function() {
    if (null != this.Ot)
        return this.Ot;
    throw Error("RaBl not set");
});
gvjs_Uq.prototype.Rk = gvjs_V(32, function() {
    return "Path"
});
gvjs_1Q.prototype.Rk = gvjs_V(31, function() {
    return "Text"
});
gvjs_2Q.prototype.Rk = gvjs_V(30, function() {
    return "Circle"
});
gvjs_3Q.prototype.Rk = gvjs_V(29, function() {
    return "Line"
});
gvjs_4Q.prototype.Rk = gvjs_V(28, function() {
    return "Rect"
});
function gvjs_5Q(a, b) {
    a.start = Math.min(a.start, b);
    a.end = Math.max(a.end, b)
}
function gvjs_Dia(a) {
    var b = {}, c;
    for (c in a.rb)
        b[c] = a.rb[c];
    return b
}
function gvjs_6Q(a) {
    return function() {
        return !a.apply(this, arguments)
    }
}
function gvjs_7Q(a, b, c) {
    a /= 255;
    b /= 255;
    c /= 255;
    var d = Math.max(a, b, c)
      , e = Math.min(a, b, c)
      , f = 0
      , g = 0
      , h = .5 * (d + e);
    d != e && (d == a ? f = 60 * (b - c) / (d - e) : d == b ? f = 60 * (c - a) / (d - e) + 120 : d == c && (f = 60 * (a - b) / (d - e) + 240),
    g = 0 < h && .5 >= h ? (d - e) / (2 * h) : (d - e) / (2 - 2 * h));
    return [Math.round(f + 360) % 360, g, h]
}
function gvjs_8Q(a, b) {
    return typeof a === gvjs_l ? [a + "." + b] : gvjs_v(a, function(c) {
        return c + "." + b
    })
}
function gvjs_9Q(a, b) {
    return Math.max(a.start, b.start) <= Math.min(a.end, b.end)
}
function gvjs_$Q(a) {
    this.yi = a;
    this.i3 = new gvjs_aj
}
gvjs_$Q.prototype.index = function() {
    return this.yi
}
;
function gvjs_aR() {}
gvjs_o(gvjs_aR, gvjs_Cl);
gvjs_aR.prototype.Pb = function(a) {
    try {
        this.Ac(a)
    } catch (b) {
        return !1
    }
    return !0
}
;
gvjs_aR.prototype.Ac = function(a) {
    gvjs_Dl(a);
    var b = a.$();
    if (2 > b)
        throw Error(gvjs_gs);
    for (var c = !0, d = [], e = 0; e < b; e++) {
        var f = a.Jg(e);
        gvjs_jf(f) && (c ? (f = gvjs_mu,
        c = !1) : f = gvjs_$t);
        d.push(f)
    }
    if (d[0] !== gvjs_mu)
        throw Error("Invalid data format: first column must be domain.");
    a = gvjs_Eia(d);
    return {
        Nf: a.Nf,
        Sm: gvjs_v(a.groups, function(g) {
            return {
                Yi: g.column,
                Nf: g.Nf,
                C: gvjs_v(g.groups, function(h) {
                    return {
                        Bs: h.column,
                        Nf: h.Nf
                    }
                })
            }
        })
    }
}
;
function gvjs_Eia(a) {
    for (var b = [gvjs_mu, gvjs_$t], c = {
        groups: [],
        Nf: {}
    }, d = [c], e = -1, f = 0; f < a.length; f++) {
        var g = a[f]
          , h = gvjs_Be(b, g)
          , k = null;
        0 <= h && (k = {
            column: f,
            role: g,
            groups: [],
            Nf: {}
        });
        if (0 <= h && h < e) {
            e -= h;
            for (g = 0; g <= e; g++)
                d.pop();
            e = h;
            h = d[d.length - 1];
            d.push(k);
            h.groups.push(k)
        } else
            0 <= e && g === b[e] ? (d.pop(),
            h = d[d.length - 1],
            d.push(k),
            h.groups.push(k)) : e + 1 < b.length && g === b[e + 1] ? (h = d[d.length - 1],
            e++,
            d.push(k),
            h.groups.push(k)) : (k = d[d.length - 1],
            g in k.Nf || (k.Nf[g] = []),
            k.Nf[g].push(f))
    }
    return c
}
var gvjs_Fia = {
    Gja: gvjs_2,
    CENTER: gvjs_0,
    sia: gvjs_R
};
function gvjs_bR(a) {
    return function(b, c) {
        b = new gvjs_1Q(0,0,b,c);
        if (b.yr)
            throw Error("can't stage a shape that's already staged.");
        if (-1 !== a.ur.indexOf(b))
            throw Error("can't stage a shape that's already drawn.");
        b.yr = !0;
        a.ur.push(b);
        a.elements.push(null);
        b.o("box", a.O1);
        b.o(gvjs_Rp, a.Yz);
        b.o(gvjs_XQ, a.VD);
        b.o(gvjs_Ap, a.SD);
        b.o("add", a.L1);
        b.o(gvjs_Mp, a.R1);
        c = b.Qj();
        a.CS(b);
        delete c.x;
        delete c.y;
        return c
    }
}
function gvjs_cR(a, b) {
    var c = function() {
        return this || window
    }(), d, e = !1, f = !1;
    b && b.fonts && c.WebFont ? c.WebFont.load({
        google: {
            families: b.fonts
        },
        active: function() {
            f = !0;
            d && d(a)
        },
        fontinactive: function() {
            throw Error("one or more fonts could not be loaded.");
        }
    }) : e = !0;
    return {
        then: function(g) {
            f || e ? (e || f) && c.setTimeout(g.bind(c, a), 0) : d = g
        }
    }
}
function gvjs_dR(a, b, c, d, e) {
    gvjs_wq.call(this, e);
    null != a && this.setStyle("rx", a);
    null != b && this.setStyle("ry", b);
    null != c && this.setStyle("x", c);
    null != d && this.setStyle("y", d)
}
gvjs_o(gvjs_dR, gvjs_wq);
gvjs_dR.prototype.Rk = function() {
    return "Ellipse"
}
;
gvjs_dR.prototype.Ou = function() {
    var a = this.style("rx")
      , b = this.style("ry")
      , c = this.style("x")
      , d = this.style("y");
    this.eo = {
        x: c - a,
        y: d - b,
        width: 2 * a,
        height: 2 * b
    };
    return !0
}
;
var gvjs_eR = []
  , gvjs_fR = null;
function gvjs_gR(a) {
    gvjs_eR.push(a);
    null == gvjs_fR && (gvjs_fR = gvjs_hda.call(gvjs_p, function(b) {
        gvjs_eR = [];
        gvjs_fR = null;
        gvjs_Pz(gvjs_eR, function(c) {
            c(b)
        })
    }))
}
var gvjs_hR = []
  , gvjs_Gia = 0;
function gvjs_iR(a) {
    for (var b in a)
        if (Object.hasOwnProperty.call(a, b)) {
            var c = a[b]
              , d = c.getAttribute(gvjs_5c);
            gvjs_hR.push(d);
            d = c.parentNode;
            null != d && d.removeChild(c)
        }
}
function gvjs_jR(a) {
    return gvjs_jda[typeof a === gvjs_l ? a : a.Rk()]
}
function gvjs_kR(a, b, c) {
    gvjs_dC.call(this, a, b, c);
    this.svg = a;
    this.clear();
    var d = gvjs_Ph()
      , e = this.svg = d.createElementNS(gvjs_Ep, gvjs_9p);
    e.setAttribute(gvjs_Xd, b);
    e.setAttribute(gvjs_4c, c);
    e.appendChild(d.createElementNS(gvjs_Ep, gvjs_hp));
    var f = d.createElement(gvjs_Ob);
    f.style.position = gvjs_c;
    f.style.left = gvjs_Nr;
    f.style.top = gvjs_Nr;
    f.style.width = gvjs_So;
    f.style.height = gvjs_So;
    d = d.createElement(gvjs_Ob);
    d.style.position = gvjs_zd;
    d.style.width = String(b) + gvjs_T;
    d.style.height = String(c) + gvjs_T;
    d.appendChild(f);
    f.appendChild(e);
    a.appendChild(d);
    this.SD = this.P1.bind(this);
    this.O1 = this.gua.bind(this);
    this.Yz = this.S1.bind(this);
    this.VD = this.T1.bind(this);
    this.L1 = this.xda.bind(this);
    this.hm = this.Q1.bind(this);
    this.R1 = this.xua.bind(this);
    e.addEventListener(gvjs_Wt, this.hm);
    e.addEventListener(gvjs_jd, this.hm);
    e.addEventListener(gvjs_ld, this.hm);
    e.addEventListener(gvjs_kd, this.hm);
    this.ur = [];
    this.elements = [];
    this.filters = {};
    this.XT = {};
    this.Zn = null
}
gvjs_o(gvjs_kR, gvjs_dC);
gvjs_ = gvjs_kR.prototype;
gvjs_.resize = function(a, b) {
    this.svg.setAttribute(gvjs_Xd, this.c8 = a);
    this.svg.setAttribute(gvjs_4c, this.b8 = b)
}
;
gvjs_.yZ = function() {
    return 0 < gvjs_hR.length ? gvjs_hR.shift() : "rablfilter" + gvjs_Gia++
}
;
gvjs_.g3 = function(a, b) {
    return (b ? this.XT : this.filters)[a] || null
}
;
gvjs_.N4 = function(a, b, c) {
    (c ? this.XT : this.filters)[a] = b
}
;
function gvjs_lR(a, b, c, d) {
    var e = a.ur.indexOf(b);
    if (0 <= e) {
        if (null != a.elements[e] || !b.yr)
            throw "Shape exists and is not a staged shape.";
        b.yr = !1;
        a.elements[e] = c
    } else
        a.ur.push(b),
        a.elements.push(c);
    c = b.Rk();
    "Text" !== c && "Group" !== c || b.o("box", a.O1);
    b.o(gvjs_Rp, a.Yz);
    b.o("add", a.L1);
    b.o(gvjs_Mp, a.R1);
    b.o(gvjs_XQ, a.VD);
    d && b.o(gvjs_Ap, a.SD)
}
gvjs_.xda = function(a, b) {
    var c = b ? this.svg : gvjs_mR(this, a.getContext());
    c = gvjs_jR(a).draw(this, a, c);
    gvjs_lR(this, a, c, !!b);
    gvjs_nR(this, a, c);
    return a
}
;
gvjs_.lv = function(a) {
    return gvjs_mR(this, a) || a.getContext() ? (a.fireEvent(gvjs_Rp, [a]),
    a) : this.xda(a, !0)
}
;
function gvjs_nR(a, b, c) {
    if (b.zP) {
        b = b.Vg;
        for (var d = 0, e = b.length; d < e; d++) {
            var f = b[d]
              , g = gvjs_jR(f).draw(a, f, c);
            gvjs_lR(a, f, g, !1);
            gvjs_nR(a, f, g)
        }
    }
}
gvjs_.Ke = function(a, b, c, d) {
    a = new gvjs_2Q(a,b,c,d);
    this.lv(a);
    return a
}
;
gvjs_.Gl = function(a, b, c, d, e) {
    a = new gvjs_dR(a,b,c,d,e);
    this.lv(a);
    return a
}
;
gvjs_.yb = function(a, b, c, d, e) {
    a = new gvjs_4Q(a,b,c,d,e);
    this.lv(a);
    return a
}
;
gvjs_.ce = function(a, b, c, d) {
    a = new gvjs_1Q(a,b,c,d);
    this.lv(a);
    return a
}
;
gvjs_.jY = function(a, b, c, d, e) {
    a = new gvjs_3Q(a,b,c,d,e);
    this.lv(a)
}
;
gvjs_.CS = function(a) {
    if (null == a.getContext())
        throw "Attempted to remove shape that doesn't have a context.";
    return a.fireEvent(gvjs_XQ, [a])
}
;
gvjs_.T1 = function(a) {
    var b = this.ur.indexOf(a);
    if (0 > b)
        return !1;
    if (a.zP) {
        b = a.Vg;
        for (var c = 0, d = b.length; c < d; c++)
            a.fireEvent(gvjs_XQ, [b[c]]);
        b = this.ur.indexOf(a)
    }
    a.yr ? a.yr = !1 : this.elements[b].parentNode.removeChild(this.elements[b]);
    this.ur.splice(b, 1);
    this.elements.splice(b, 1);
    a.Ab("box", this.O1);
    a.Ab(gvjs_Rp, this.Yz);
    a.Ab(gvjs_XQ, this.VD);
    a.Ab(gvjs_Ap, this.SD);
    a.Ab("add", this.L1);
    a.Ab(gvjs_Mp, this.R1);
    a.Sb = null;
    return !0
}
;
gvjs_.Q1 = function(a) {
    for (var b = a.target; null != b.getAttribute(gvjs_Pp); )
        b = b.parentNode;
    var c = this.elements.indexOf(b);
    if (0 <= c) {
        b = a.offsetX;
        var d = a.offsetY;
        a = a.type;
        a === gvjs_ld ? a = gvjs_hd : a === gvjs_kd && (a = gvjs_id);
        c = this.ur[c];
        c.fireEvent(a, [{
            point: {
                x: b,
                y: d
            },
            type: a,
            target: c
        }])
    }
}
;
gvjs_.S1 = function(a, b) {
    var c = a.getContext() || this
      , d = gvjs_mR(this, a);
    c = gvjs_mR(this, c);
    a = gvjs_jR(a).Lf(this, a, b, c, d);
    null != a && a != d && (this.elements[this.elements.indexOf(d)] = a,
    b = d.parentNode,
    b.insertBefore(a, d),
    b.removeChild(d))
}
;
gvjs_.P1 = function(a) {
    a.Sb = this
}
;
gvjs_.gua = function(a) {
    if ("Path" !== a.Rk()) {
        if (a.yr) {
            if (!this.Oca) {
                var b = gvjs_Ph();
                var c = this.Oca = b.createElement(gvjs_Ob);
                c.style.position = gvjs_c;
                c.style.top = "-1000px";
                c.style.left = "-1000px";
                c.style.whiteSpace = gvjs_1v;
                var d = b.createElementNS(gvjs_Ep, gvjs_9p);
                c.appendChild(d);
                b.body.appendChild(c)
            }
            b = this.Oca;
            b.style.display = gvjs_xb;
            c = gvjs_jR(a).draw(this, a, b.firstChild)
        } else
            c = gvjs_mR(this, a);
        d = c.getBBox();
        a.eo = {
            width: d.width,
            height: d.height,
            x: d.x,
            y: d.y
        };
        a.yr && (b.style.display = gvjs_f,
        c.parentNode.removeChild(c))
    }
}
;
gvjs_.xua = function(a, b) {
    b = {
        start: null,
        end: null,
        interpolate: null,
        shape: a,
        animation: b
    };
    a.dCa = !0;
    if (null != this.Zn)
        this.Zn.push(b);
    else {
        this.Zn = [b];
        var c = this.$V.xha(gvjs_s(function(d) {
            this.Zn = this.Zn.filter(function(e) {
                null == e.start && (e.start = d);
                null == e.interpolate && (e.interpolate = e.animation.UDa(e.animation.ADa, e.animation.iya, e.animation.Nk, e.start));
                null == e.end && (e.end = e.start + e.animation.Nk);
                if (d >= e.end || e.animation.MG())
                    return e.shape.style(e.animation.lva, e.animation.iya),
                    e.animation.fireEvent(gvjs_up, [e.shape, e.animation]),
                    !1;
                e.shape.style(e.animation.lva, e.interpolate(d));
                return !0
            });
            0 < this.Zn.length ? gvjs_gR(c) : this.Zn = null
        }, this));
        gvjs_gR(c)
    }
}
;
function gvjs_mR(a, b) {
    if (b === a)
        return a.svg;
    b = a.ur.indexOf(b);
    return 0 > b ? null : a.elements[b]
}
gvjs_.clear = function() {
    var a = gvjs_Ph(), b = this.svg, c;
    gvjs_iR(this.filters);
    gvjs_iR(this.XT);
    this.filters = {};
    for (this.XT = {}; b.firstChild; )
        b.firstChild.tagName === gvjs_hp && (c = !0),
        b.removeChild(b.firstChild);
    c && b.appendChild(a.createElementNS(gvjs_Ep, gvjs_hp));
    this.ur = [];
    this.elements = [];
    this.Zn = null;
    this.$V && (this.$V.vQ = !0);
    this.$V = new gvjs_Yg
}
;
function gvjs_oR(a, b, c, d) {
    gvjs_3B.call(this, a, b, c, !1);
    this.container = a;
    this.dimensions = new gvjs_A(0,0);
    this.kI = d || null;
    this.update(b, c)
}
gvjs_o(gvjs_oR, gvjs_3B);
gvjs_ = gvjs_oR.prototype;
gvjs_.Oa = function() {
    return this.cp
}
;
gvjs_.yq = function() {
    return {}
}
;
gvjs_.rl = function(a, b) {
    gvjs_3B.prototype.rl.call(this, a, b)
}
;
gvjs_.update = function(a) {
    var b = this;
    gvjs_fz(this.dimensions, a) || (this.dimensions = a.clone(),
    this.km = null,
    this.cp && this.cp.clear(),
    a = new gvjs_kR(this.container,a.width || 0,a.height || 0),
    gvjs_cR(a, this.kI ? {
        fonts: this.kI
    } : void 0).then(function(c) {
        b.cp = c;
        b.cp.me = gvjs_Tz(gvjs_bR(b.cp), {
            gT: function(d, e) {
                d = [d, e[0]];
                d.push(JSON.stringify(e[1]));
                return d.join("_")
            }
        });
        b.km = {}
    }))
}
;
gvjs_.M = function() {}
;
function gvjs_pR() {
    this.Pa = this.ga = this.pN = this.xj = this.NS = this.If = 0
}
gvjs_ = gvjs_pR.prototype;
gvjs_.left = function() {
    return this.If
}
;
gvjs_.top = function() {
    return this.xj
}
;
gvjs_.right = function() {
    return this.NS
}
;
gvjs_.bottom = function() {
    return this.pN
}
;
gvjs_.au = function(a) {
    this.If = a;
    this.ga = this.If + this.NS;
    return this
}
;
gvjs_.Kn = function(a) {
    this.xj = a;
    this.Pa = this.xj + this.pN;
    return this
}
;
function gvjs_qR(a, b) {
    a.NS = b;
    a.ga = a.If + a.NS;
    return a
}
function gvjs_rR(a, b) {
    a.pN = b;
    a.Pa = a.xj + a.pN;
    return a
}
gvjs_.width = function() {
    return this.ga
}
;
gvjs_.height = function() {
    return this.Pa
}
;
function gvjs_sR(a, b, c, d, e, f, g, h, k) {
    this.H = a;
    this.pw = b;
    this.Uc = c;
    this.If = d;
    this.xj = e;
    this.ga = f;
    this.Pa = g;
    this.oC = h;
    this.jE = k
}
gvjs_ = gvjs_sR.prototype;
gvjs_.properties = function() {
    return this.jE
}
;
gvjs_.property = function(a) {
    return this.jE[a]
}
;
gvjs_.element = function() {
    return this.H
}
;
gvjs_.children = function() {
    return this.Uc
}
;
gvjs_.left = function() {
    return this.If
}
;
gvjs_.top = function() {
    return this.xj
}
;
gvjs_.width = function() {
    return this.ga
}
;
gvjs_.height = function() {
    return this.Pa
}
;
gvjs_.extra = function() {
    return this.oC
}
;
gvjs_.rect = function() {
    return new gvjs_5(this.If,this.xj,this.ga,this.Pa)
}
;
gvjs_.box = function() {
    return new gvjs_B(this.xj,this.If + this.ga,this.xj + this.Pa,this.If)
}
;
function gvjs_tR(a, b, c, d) {
    (null == a || !isFinite(a) || a > d) && b > d && (a = d);
    (null == a || !isFinite(a) || a < c) && b < c && (a = c);
    return a
}
function gvjs_uR(a, b, c, d) {
    d = null == d ? "." : d;
    for (var e in a)
        if (a.hasOwnProperty(e))
            if (a[e]instanceof Object && !(a[e]instanceof Array))
                gvjs_uR(a[e], b.concat(e), c, d);
            else {
                var f = b.concat(e).join(d);
                c.hasOwnProperty(f) || (c[f] = a[e])
            }
}
function gvjs_vR(a) {
    var b = {};
    gvjs_uR(a, [], b, void 0);
    return b
}
function gvjs_wR(a, b) {
    return gvjs_KL(gvjs_KL(new gvjs_IL(gvjs_HQ), gvjs_ps, b), "COLUMN_INDEX", a)
}
function gvjs_xR(a, b) {
    a = gvjs_KL(new gvjs_IL(gvjs_IQ), "COLUMN_INDEX", a);
    null != b && gvjs_KL(a, gvjs_rs, b);
    return a
}
function gvjs_Hia(a) {
    this.type = a;
    this.data = null
}
function gvjs_yR(a, b) {
    typeof a === gvjs_l && (a = new gvjs_Hia(a));
    this.effect = a;
    this.targets = [];
    b && this.targets.push(b)
}
;function gvjs_zR(a, b) {
    gvjs_wq.call(this, b);
    this.Vg = [];
    if (a)
        throw "prepopulating a group is unimplemented.";
    this.Yz = gvjs_s(this.S1, this);
    this.hm = gvjs_s(this.Q1, this);
    this.SD = gvjs_s(this.P1, this);
    this.VD = gvjs_s(this.T1, this)
}
gvjs_o(gvjs_zR, gvjs_wq);
gvjs_ = gvjs_zR.prototype;
gvjs_.Rk = function() {
    return "Group"
}
;
gvjs_.lv = function(a) {
    if (a.getContext())
        throw "cannot add a shape to a group that already has a context.";
    this.Vg.push(a);
    a.o(gvjs_Rp, this.Yz);
    a.o(gvjs_Wt, this.hm);
    a.o(gvjs_jd, this.hm);
    a.o(gvjs_hd, this.hm);
    a.o(gvjs_id, this.hm);
    a.o(gvjs_Ap, this.SD);
    a.o(gvjs_XQ, this.VD);
    this.fireEvent("add", [a, !1]);
    return this
}
;
gvjs_.clear = function() {
    for (var a = 0, b = this.Vg.length; a < b; a++)
        this.Vg[a].Ab(gvjs_Rp, this.Yz),
        this.fireEvent(gvjs_XQ, [this.Vg[a]]);
    this.Vg = [];
    this.fireEvent(gvjs_Rp, [this]);
    return this
}
;
gvjs_.contains = function(a) {
    return 0 <= this.Vg.indexOf(a)
}
;
gvjs_.S1 = function() {}
;
gvjs_.Q1 = function(a) {
    this.fireEvent(a.type, [a])
}
;
gvjs_.P1 = function(a) {
    a.Sb = this;
    return !0
}
;
gvjs_.T1 = function(a) {
    var b = this.Vg.indexOf(a);
    if (0 > b)
        throw gvjs_MQ;
    a.Ab(gvjs_Rp, this.Yz);
    a.Ab(gvjs_Wt, this.hm);
    a.Ab(gvjs_jd, this.hm);
    a.Ab(gvjs_hd, this.hm);
    a.Ab(gvjs_id, this.hm);
    a.Ab(gvjs_Ap, this.SD);
    a.Ab(gvjs_XQ, this.VD);
    a.Sb = null;
    this.Vg.splice(b, 1);
    return !0
}
;
gvjs_.CS = function(a) {
    if (0 > this.Vg.indexOf(a))
        throw gvjs_MQ;
    a.fireEvent(gvjs_XQ, [a]);
    return this
}
;
gvjs_.zP = function() {
    return this.Vg
}
;
gvjs_.add = gvjs_zR.prototype.lv;
gvjs_.remove = gvjs_zR.prototype.CS;
function gvjs_AR(a, b, c, d, e) {
    this.Ay = a;
    this.renderer = b.cp();
    this.re = b;
    this.vt = null;
    this.Ez = gvjs_Iia;
    this.pi = d;
    this.BB = e;
    this.ho = null
}
gvjs_t(gvjs_AR, gvjs_HL);
gvjs_ = gvjs_AR.prototype;
gvjs_.draw = function(a) {
    this.vt = {};
    this.renderer.clear();
    this.ho = this.Ay.Mm(a, null);
    this.ho.Tb();
    for (a = 0; a < this.Ez.length; a++) {
        var b = this.vt[this.Ez[a]] = new gvjs_zR;
        this.M3(b)
    }
    this.ho.draw(this);
    gvjs_BR(this)
}
;
function gvjs_BR(a) {
    var b = a.re.cp();
    gvjs_u(gvjs_Xe(a.vt), function(c) {
        b.lv(c)
    }, a)
}
gvjs_.$t = function(a) {
    this.Ez = a
}
;
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
    function b(c, d) {
        return function(e) {
            c.apply(d, [this, e])
        }
    }
    a.o(gvjs_Wt, b(function(c, d) {
        gvjs_CR(this, gvjs_Wt, c, d)
    }, this));
    a.o(gvjs_jd, b(function(c, d) {
        gvjs_CR(this, gvjs_9u, c, d)
    }, this));
    a.o(gvjs_id, b(function(c, d) {
        gvjs_CR(this, gvjs_$u, c, d)
    }, this))
}
;
function gvjs_CR(a, b, c, d) {
    c = d.target;
    (c = c.data() && c.data().idStr) && c != gvjs_Bs && (c = gvjs_LL(c),
    a.pi(c, b))
}
gvjs_.Oa = function() {
    return this.re
}
;
gvjs_.$n = function(a, b, c) {
    var d = a.data() || {};
    d.idStr = b.ie();
    a.data(d);
    this.vt[c].add(a)
}
;
gvjs_.we = function(a, b, c, d) {
    b !== a && (b && this.Re(b),
    this.$n(a, c, d))
}
;
gvjs_.Re = function(a) {
    a && this.renderer.CS(a)
}
;
var gvjs_Iia = [gvjs_Wo, gvjs_Cw, gvjs_Bw, gvjs_Ds, gvjs_Cs];
function gvjs_DR() {}
function gvjs_ER(a, b) {
    return new gvjs_FR(a,b)
}
function gvjs_FR(a, b) {
    this.vya = a;
    this.wya = b
}
gvjs_t(gvjs_FR, gvjs_DR);
gvjs_FR.prototype.transform = function(a) {
    a = this.vya.transform(a);
    return this.wya.transform(a)
}
;
function gvjs_GR(a) {
    this.ex = a
}
gvjs_t(gvjs_GR, gvjs_DR);
gvjs_GR.prototype.transform = function(a) {
    return gvjs_v(a, function(b) {
        return this.ex.transform(b)
    }, this)
}
;
function gvjs_HR(a, b) {
    this.coa = a;
    this.Fua = new Set(b)
}
gvjs_HR.prototype.Vna = function(a, b) {
    return gvjs_Fe(this.coa, function(c) {
        return c.kD(a)
    }) && this.Fua.has(b)
}
;
function gvjs_IR(a) {
    gvjs_HR.call(this, a, [gvjs_Wt])
}
gvjs_o(gvjs_IR, gvjs_HR);
gvjs_IR.prototype.QG = function(a, b, c) {
    c.selected.clear();
    return !0
}
;
gvjs_IR.prototype.Dk = function() {
    return []
}
;
function gvjs_JR(a) {
    gvjs_HR.call(this, a, [gvjs_9u, gvjs_$u])
}
gvjs_o(gvjs_JR, gvjs_HR);
gvjs_JR.prototype.QG = function(a, b, c) {
    if (b == gvjs_9u) {
        if (!a.equals(c.ff))
            return c.ff = a,
            !0
    } else if (null != c.ff)
        return c.ff = null,
        !0;
    return !1
}
;
gvjs_JR.prototype.Dk = function(a) {
    return null != a.ff ? [new gvjs_yR(gvjs_xu,a.ff)] : []
}
;
function gvjs_KR(a, b) {
    gvjs_HR.call(this, a, [gvjs_Wt]);
    this.U_ = null == b ? !0 : b
}
gvjs_o(gvjs_KR, gvjs_HR);
gvjs_KR.prototype.QG = function(a, b, c) {
    switch (a.type()) {
    case gvjs_os:
        gvjs_ty(c.selected, a.rb.ROW_INDEX, this.U_);
        break;
    case gvjs_HQ:
        gvjs_vy(c.selected, a.rb.ROW_INDEX, a.rb.COLUMN_INDEX, this.U_);
        break;
    case gvjs_IQ:
        gvjs_uy(c.selected, a.rb.COLUMN_INDEX, this.U_)
    }
    return !0
}
;
gvjs_KR.prototype.Dk = function(a) {
    a = a.selected.getSelection();
    return gvjs_v(a, function(b) {
        var c = b.row;
        b = b.column;
        if (null != c && null != b)
            c = gvjs_wR(b, c);
        else if (null != c)
            c = gvjs_JL(c);
        else if (null != b)
            c = gvjs_xR(b);
        else
            throw Error("Invalid selection. No row or column");
        return new gvjs_yR(gvjs_k,c)
    })
}
;
function gvjs_LR(a, b) {
    gvjs_HR.call(this, a, [gvjs_Wt]);
    this.kxa = null == b ? !0 : b
}
gvjs_o(gvjs_LR, gvjs_HR);
gvjs_LR.prototype.QG = function(a, b, c) {
    a = a.ie();
    c.Cn.has(a) ? c.Cn.delete(a) : (this.kxa && c.Cn.clear(),
    c.Cn.add(a));
    return !0
}
;
gvjs_LR.prototype.Dk = function(a) {
    var b = [];
    a = gvjs_8d(a.Cn);
    for (var c = a.next(); !c.done; c = a.next())
        b.push(new gvjs_yR(gvjs_k,gvjs_LL(c.value)));
    return b
}
;
function gvjs_MR(a) {
    gvjs_HR.call(this, a, [gvjs_9u, gvjs_$u])
}
gvjs_o(gvjs_MR, gvjs_HR);
gvjs_MR.prototype.QG = function(a, b, c) {
    if (b == gvjs_9u) {
        if (!a.equals(c.Rn))
            return c.Rn = a,
            !0
    } else if (null != c.Rn)
        return c.Rn = null,
        !0;
    return !1
}
;
gvjs_MR.prototype.Dk = function(a) {
    return null != a.Rn ? [new gvjs_yR(gvjs_Pd,a.ff)] : []
}
;
function gvjs_NR(a, b, c) {
    this.Hl = a;
    this.featureId = b.clone();
    this.layer = c
}
;function gvjs_OR() {
    this.Rt = new gvjs_aj;
    this.DS = null;
    this.z7 = !0
}
gvjs_OR.prototype.ZV = function() {
    return []
}
;
gvjs_OR.prototype.draw = function(a) {
    if (null == this.DS) {
        this.DS = new gvjs_aj;
        var b = this.ZV(a);
        gvjs_u(b, gvjs_s(this.Kea, this, a, this.DS))
    }
    b = this.AB(a);
    var c = new Set(this.Rt.cj());
    gvjs_u(b, function(f) {
        var g = f.featureId.ie();
        c.delete(g);
        this.Kea(a, this.Rt, f)
    }, this);
    if (this.z7) {
        b = gvjs_8d(c);
        for (var d = b.next(); !d.done; d = b.next()) {
            d = d.value;
            var e = this.Rt.get(d);
            a.Re(e.Hl);
            this.Rt.remove(d)
        }
    }
}
;
gvjs_OR.prototype.Kea = function(a, b, c) {
    var d = c.featureId.ie()
      , e = b.get(d, null);
    e && e.A4 && a.Re(e.A4);
    "_" === c.layer[0] ? (gvjs_6(e.Hl, !1),
    e.A4 = c.Hl,
    e.yxa = c.layer,
    a.$n(e.A4, e.featureId, e.yxa)) : e != c && (null === e || e.layer !== c.layer ? (null != e && a.Re(e.Hl),
    a.$n(c.Hl, c.featureId, c.layer)) : a.we(c.Hl, e.Hl, c.featureId, c.layer),
    b.set(d, c))
}
;
function gvjs_PR() {
    this.Ck = 0
}
gvjs_ = gvjs_PR.prototype;
gvjs_.mo = gvjs_n(81);
gvjs_.ko = gvjs_n(85);
gvjs_.BC = function() {
    return this.fi(this.Ck)
}
;
gvjs_.Fo = function() {
    return this.Ck
}
;
gvjs_.Zt = function(a) {
    this.Ck = this.scale(a)
}
;
gvjs_.Pw = function(a) {
    this.Ck = a
}
;
function gvjs_QR(a, b) {
    this.Dy = a;
    this.bL = b
}
gvjs_ = gvjs_QR.prototype;
gvjs_.mo = gvjs_n(80);
gvjs_.ko = gvjs_n(84);
gvjs_.BC = function() {
    return this.Dy.BC()
}
;
gvjs_.Fo = function() {
    return this.bL.Fo()
}
;
gvjs_.isDiscrete = function() {
    return this.Dy.isDiscrete()
}
;
gvjs_.Zt = function(a) {
    this.Pw(this.Dy.scale(a))
}
;
gvjs_.Pw = function(a) {
    this.Dy.Pw(a);
    this.bL.Zt(a)
}
;
gvjs_.scale = function(a) {
    a = this.Dy.scale(a);
    return this.bL.scale(a)
}
;
gvjs_.fi = function(a) {
    a = this.bL.fi(a);
    return this.Dy.fi(a)
}
;
function gvjs_RR() {
    this.Ck = 0
}
gvjs_o(gvjs_RR, gvjs_PR);
gvjs_RR.prototype.scale = function(a) {
    return null == a ? null : a.getTime()
}
;
gvjs_RR.prototype.fi = function(a) {
    if (null === a)
        return null;
    var b = new Date;
    b.setTime(a);
    return b
}
;
gvjs_RR.prototype.isDiscrete = function() {
    return !1
}
;
function gvjs_SR() {
    this.Ck = 0;
    this.yi = {};
    this.pK = []
}
gvjs_o(gvjs_SR, gvjs_PR);
gvjs_ = gvjs_SR.prototype;
gvjs_.isDiscrete = function() {
    return !0
}
;
gvjs_.getMapping = function() {
    return gvjs_v(this.pK, function(a, b) {
        return {
            v: b + .5,
            f: a
        }
    })
}
;
gvjs_.scale = function(a) {
    if (null === a)
        return null;
    a = String(a);
    return a in this.yi ? this.yi[a] + .5 : null
}
;
gvjs_.fi = function(a) {
    return null != a && (a -= .5,
    0 <= a && a < this.pK.length) ? this.pK[a] : null
}
;
gvjs_.add = function(a, b) {
    var c = null;
    a = String(a);
    a in this.yi && b || (this.yi[a] = c = this.pK.length,
    this.pK.push(a));
    return c + .5
}
;
function gvjs_TR(a) {
    this.qe = a
}
gvjs_ = gvjs_TR.prototype;
gvjs_.mo = gvjs_n(79);
gvjs_.ko = gvjs_n(83);
gvjs_.BC = function() {
    return this.qe.Fo()
}
;
gvjs_.Fo = function() {
    return this.qe.BC()
}
;
gvjs_.Zt = function(a) {
    this.qe.Pw(a)
}
;
gvjs_.Pw = function(a) {
    this.qe.Zt(a)
}
;
gvjs_.isDiscrete = function() {
    return this.qe.isDiscrete()
}
;
gvjs_.scale = function(a) {
    return this.qe.fi(a)
}
;
gvjs_.fi = function(a) {
    return this.qe.scale(a)
}
;
function gvjs_UR() {
    this.Ck = 0
}
gvjs_o(gvjs_UR, gvjs_PR);
gvjs_UR.prototype.scale = function(a) {
    return null == a ? null : Number(a)
}
;
gvjs_UR.prototype.fi = function(a) {
    return null == a ? null : a
}
;
gvjs_UR.prototype.isDiscrete = function() {
    return !1
}
;
function gvjs_VR(a, b) {
    this.Ck = 0;
    this.Bo = {
        start: a ? a.start : 0,
        end: a ? a.end : 1
    };
    this.UA = {
        start: b ? b.start : 0,
        end: b ? b.end : 1
    }
}
gvjs_o(gvjs_VR, gvjs_UR);
gvjs_VR.prototype.domain = function(a, b) {
    a = null != a ? this.Bo.start : a;
    b = null != b ? this.Bo.end : b;
    this.Bo = {
        start: a,
        end: b
    };
    return this
}
;
gvjs_VR.prototype.range = function(a, b) {
    a = null != a ? this.Bo.start : a;
    b = null != b ? this.Bo.end : b;
    this.UA = {
        start: a,
        end: b
    };
    return this
}
;
gvjs_VR.prototype.scale = function(a) {
    return null == a ? null : (a - this.Bo.start) / (this.Bo.end - this.Bo.start) * (this.UA.end - this.UA.start) + this.UA.start
}
;
gvjs_VR.prototype.fi = function(a) {
    return null == a ? null : (a - this.UA.start) / (this.UA.end - this.UA.start) * (this.Bo.end - this.Bo.start) + this.Bo.start
}
;
function gvjs_WR() {
    this.Ck = 0
}
gvjs_o(gvjs_WR, gvjs_PR);
gvjs_WR.prototype.scale = function(a) {
    return gvjs_GA(a)
}
;
gvjs_WR.prototype.fi = function(a) {
    return null === a ? null : gvjs_DA(a).reverse()
}
;
gvjs_WR.prototype.isDiscrete = function() {
    return !1
}
;
var gvjs_XR = {};
gvjs_XR[gvjs_zb] = gvjs_SR;
gvjs_XR.string = gvjs_SR;
gvjs_XR.number = gvjs_UR;
gvjs_XR.date = gvjs_RR;
gvjs_XR.datetime = gvjs_RR;
gvjs_XR.timeofday = gvjs_WR;
function gvjs_YR() {
    this.Ck = this.scale([0, 0, 0]);
    this.nU = new gvjs_WR;
    this.BH = new gvjs_RR
}
gvjs_ = gvjs_YR.prototype;
gvjs_.mo = gvjs_n(78);
gvjs_.ko = gvjs_n(82);
gvjs_.BC = function() {
    return this.fi(this.Ck)
}
;
gvjs_.Fo = function() {
    return this.Ck
}
;
gvjs_.Zt = function(a) {
    this.Ck = this.scale(a)
}
;
gvjs_.Pw = function(a) {
    this.Ck = a
}
;
gvjs_.isDiscrete = function() {
    return !1
}
;
gvjs_.scale = function(a) {
    return null === a ? null : gvjs_qk(a)
}
;
gvjs_.fi = function(a) {
    return null === a ? null : gvjs_DA(gvjs_EA([a.getUTCMilliseconds(), a.getUTCSeconds(), a.getUTCMinutes(), a.getUTCHours(), a.getUTCDate() - 1, a.getUTCMonth(), a.getUTCFullYear() - 1970])).reverse()
}
;
function gvjs_ZR(a) {
    this.oh = a;
    this.Ru = new gvjs_aj;
    this.lu = new gvjs_aj
}
gvjs_ZR.prototype.Cq = function(a, b) {
    a = gvjs_7L(this.oh, this.Ru.get(a));
    if (2 > this.lu.Cd() || null == b)
        return a;
    a = gvjs_vj(a);
    b = this.lu.get(b);
    return gvjs_uj(gvjs_xj(a, [255, 255, 255], 1 - b / this.lu.Cd()))
}
;
function gvjs__R(a, b) {
    this.bQ = a;
    this.qma = b;
    this.Ru = new gvjs_aj;
    this.lu = new gvjs_aj
}
gvjs__R.prototype.Au = function(a, b) {
    this.Ru.tf(a) || this.Ru.set(a, this.Ru.Cd());
    null == b || this.lu.tf(b) || this.lu.set(b, this.lu.Cd())
}
;
gvjs__R.prototype.cd = function() {
    var a = new gvjs_6L(this.Ru.Cd(),this.bQ,this.qma);
    a = new gvjs_ZR(a);
    a.Ru = this.Ru.clone();
    a.lu = this.lu.clone();
    return a
}
;
function gvjs_0R(a, b) {
    this.label = a;
    this.ja = b;
    this.textAlign = null
}
gvjs_0R.prototype.La = function(a) {
    for (var b = this.label.split("\n"), c = 0, d = 0, e = b.length; d < e; d++)
        c = Math.max(c, a(b[d], this.ja));
    return c
}
;
var gvjs_1R = {
    Dia: gvjs_$c,
    rja: gvjs_j
}
  , gvjs_2R = {
    I6: gvjs_vx,
    p6: gvjs_vt
};
function gvjs_3R(a) {
    this.fg = a.ticks;
    this.qe = a.scale;
    this.Ua = a.range;
    this.Qb = a.label || void 0;
    this.BG = a.J7;
    this.l4 = a.sk || gvjs_vt;
    this.Ci = a.layer;
    this.Z4 = a.Bga || {};
    this.Tla = a.Sla || {};
    this.Oe = a.Xba || {}
}
gvjs_3R.prototype.R = function(a, b) {
    var c = []
      , d = new gvjs_B(b.top,b.left + b.width,b.top + b.height,b.left)
      , e = this.l4 === gvjs_vt ? gvjs_2 : gvjs_R
      , f = null;
    gvjs_u(this.fg.ticks, function(k, l) {
        var m = k.value;
        if (!(this.Ua.start > m || this.Ua.end < m)) {
            var n = k.label;
            k = n.textAlign || gvjs_0;
            m = this.qe.scale(m) * b.width + b.left;
            var p = {};
            gvjs_2e(p, this.Z4);
            n.ja.bold && gvjs_2e(p, this.Tla);
            n = n.label;
            var q = b.top;
            switch (e) {
            case gvjs_0:
                q += b.height / 2;
                break;
            case gvjs_R:
                q += b.height
            }
            var r = a.me(n, p);
            q = new gvjs_B(q,m + r.width,q + r.height,m);
            switch (k) {
            case gvjs_0:
                var t = r.width / 2;
                q.left -= t;
                q.right -= t;
                break;
            case gvjs_R:
                q.left -= r.width,
                q.right -= r.width
            }
            switch (e) {
            case gvjs_0:
                r = r.height / 2;
                q.top -= r;
                q.bottom -= r;
                break;
            case gvjs_R:
                q.top -= r.height,
                q.bottom -= r.height
            }
            f && 8 > q.left - f.right || (f = q,
            gvjs_5x(d, q),
            k = (new gvjs_1Q(m,b.top,n,p)).style(gvjs_Dp, k === gvjs_R ? 1 : k === gvjs_0 ? .5 : 0).style(gvjs_eq, e === gvjs_R ? 1 : e === gvjs_0 ? .5 : 0),
            l = gvjs_KL(this.BG.clone(), gvjs_5a, l),
            c.push(new gvjs_NR(k,l,this.Ci)))
        }
    }, this);
    if (this.Qb) {
        var g = this.Qb
          , h = a.me(g, this.Oe);
        e === gvjs_2 ? (g = (new gvjs_1Q((d.right - d.left) / 2 + d.left,d.bottom + 18,g,this.Oe)).style(gvjs_Dp, .5).style(gvjs_eq, 0),
        d.bottom += h.height + 18) : (g = (new gvjs_1Q((d.right - d.left) / 2 + d.left,d.top - 18,g,this.Oe)).style(gvjs_Dp, .5).style(gvjs_eq, 1),
        d.top -= h.height + 18);
        c.push(new gvjs_NR(g,gvjs_KL(this.BG.clone(), gvjs_5a, gvjs_8c),this.Ci))
    }
    return {
        size: new gvjs_5(d.left,d.top,d.right - d.left,d.bottom - d.top),
        elements: c
    }
}
;
function gvjs_4R(a) {
    this.ta = a.scale;
    this.fla = a.expand;
    this.Gra = a.e9;
    this.uK = a.uK || 50;
    this.size = a.size;
    this.Gc = a.Gc;
    this.xe = a.xe;
    this.format = a.format;
    this.gd = null;
    this.ticks = gvjs_Jia(this)
}
gvjs_4R.prototype.pQ = function() {}
;
function gvjs_Jia(a) {
    var b = a.wI(a.Gc, a.xe);
    a.pQ(b);
    b = gvjs_v(b, function(g) {
        g = g.v;
        return {
            value: g,
            label: this.Zs(g)
        }
    }, a);
    if (0 === b.length)
        b.push({
            value: a.Gc,
            label: a.Zs(a.Gc)
        }),
        a.Gc != a.xe && b.push({
            value: a.xe,
            label: a.Zs(a.xe)
        });
    else if (a.fla) {
        var c = a.Gc
          , d = a.xe
          , e = d - c
          , f = Math.min(b[0].value.valueOf(), c.valueOf());
        .25 >= (c - f) / e && (a.Gc = f);
        c = Math.max(b[b.length - 1].value.valueOf(), d.valueOf());
        .25 >= (c - d) / e && (a.xe = c)
    }
    if (a.Gra) {
        for (; b[0].value < a.Gc; )
            b.shift();
        b[0].value != a.Gc && (d = a.Zs(a.Gc),
        null != d && b.unshift({
            value: a.Gc,
            label: d
        }));
        for (; b[b.length - 1].value > a.xe; )
            b.pop();
        b[b.length - 1].value != a.xe && (d = a.Zs(a.xe),
        null != d && b.push({
            value: a.xe,
            label: d
        }))
    }
    return gvjs_De(b, function(g) {
        return null != g.label
    })
}
gvjs_4R.prototype.Zs = function(a) {
    a = this.ta.fi(a);
    return null == a ? null : {
        label: null != this.gd ? this.gd.Ob(a) : String(a),
        ja: {}
    }
}
;
function gvjs_5R(a) {
    this.fg = a.ticks;
    this.qe = a.scale;
    this.Ua = a.range;
    this.Qb = a.label || void 0;
    this.BG = a.J7;
    this.Ci = a.layer;
    this.l4 = a.sk || gvjs_$c;
    this.Z4 = a.Bga || {};
    this.Oe = a.Xba || {}
}
gvjs_5R.prototype.R = function(a, b) {
    var c = []
      , d = new gvjs_B(b.top,b.left + b.width,b.top + b.height,b.left)
      , e = this.l4 === gvjs_$c ? gvjs_R : gvjs_2;
    gvjs_u(this.fg.ticks, function(k, l) {
        var m = k.value;
        if (!(this.Ua.start > m || this.Ua.end < m)) {
            var n = k.label;
            k = n.textAlign || gvjs_0;
            m = this.qe.scale(m) * b.height + b.top;
            var p = {};
            gvjs_2e(p, n.ja, this.Z4);
            n = n.label;
            var q = b.left;
            switch (e) {
            case gvjs_0:
                q += b.width / 2;
                break;
            case gvjs_R:
                q += b.width
            }
            var r = a.me(n, p);
            q = new gvjs_B(m,q + r.width,m + r.height,q);
            switch (e) {
            case gvjs_0:
                var t = r.width / 2;
                q.left -= t;
                q.right -= t;
                break;
            case gvjs_R:
                q.left -= r.width,
                q.right -= r.width
            }
            switch (k) {
            case gvjs_0:
                r = r.height / 2;
                q.top -= r;
                q.bottom -= r;
                break;
            case gvjs_R:
                q.top -= r.height,
                q.bottom -= r.height
            }
            gvjs_5x(d, q);
            k = [(new gvjs_1Q(b.left,m,n,p)).style(gvjs_Dp, e === gvjs_R ? 1 : e === gvjs_0 ? .5 : 0).style(gvjs_eq, k === gvjs_R ? 1 : k === gvjs_0 ? .5 : 0)];
            gvjs_u(k, function(u, v) {
                v = gvjs_KL(gvjs_KL(this.BG.clone(), gvjs_5a, l), gvjs_KQ, v);
                c.push(new gvjs_NR(u,v,this.Ci))
            }, this)
        }
    }, this);
    if (this.Qb) {
        var f = this.Qb
          , g = a.me(f, this.Oe);
        if (e === gvjs_2) {
            var h = (new gvjs_1Q(d.right + 18,(d.bottom - d.top) / 2 + d.top,f,this.Oe)).style(gvjs_Sp, 90).style(gvjs_Dp, .5).style(gvjs_eq, 1);
            d.right += g.height + 18
        } else
            e === gvjs_R && (h = (new gvjs_1Q(d.left - 18,(d.bottom - d.top) / 2 + d.top,f,this.Oe)).style(gvjs_Sp, -90).style(gvjs_Dp, .5).style(gvjs_eq, 1),
            d.left -= g.height + 18);
        c.push(new gvjs_NR(h,gvjs_KL(this.BG.clone(), gvjs_5a, gvjs_8c),this.Ci))
    }
    return {
        size: new gvjs_5(d.left,d.top,d.right - d.left,d.bottom - d.top),
        elements: c
    }
}
;
var gvjs_6R = {
    50: "#FAFAFA",
    100: "#F5F5F5",
    200: "#EEEEEE",
    300: "#E0E0E0",
    400: "#BDBDBD",
    500: "#9E9E9E",
    600: gvjs_qr,
    700: "#616161",
    800: "#424242",
    900: "#212121"
};
var gvjs_7R = {};
gvjs_7R[gvjs_zb] = gvjs_nk;
gvjs_7R.string = gvjs_nk;
gvjs_7R.number = gvjs_gk;
gvjs_7R.date = gvjs_Tj;
gvjs_7R.datetime = gvjs_Tj;
gvjs_7R.timeofday = gvjs_tk;
function gvjs_8R(a, b) {
    if (a = gvjs_7R[a])
        return new a(b)
}
;function gvjs_9R(a) {
    this.fg = a.ticks;
    this.qe = a.scale;
    this.AG = a.hW;
    this.Ci = a.layer;
    this.PK = a.Ja || !1;
    this.W2 = a.baseline || !1;
    this.zI = a.style.Ja;
    this.CG = gvjs_mj({}, this.zI, a.style.baseline)
}
gvjs_9R.prototype.RK = function(a, b, c) {
    if (null == b)
        return null;
    b = b * a.height + a.top;
    return new gvjs_3Q(a.left,b,a.left + a.width,b,c)
}
;
gvjs_9R.prototype.R = function(a, b) {
    var c = []
      , d = !1;
    this.PK && gvjs_u(this.fg.ticks, function(f, g) {
        f = f.value;
        f = this.qe.scale(f);
        if (!(0 > f || 1 < f)) {
            var h = this.zI;
            f === this.qe.Fo() && (h = this.CG,
            d = !0);
            f = this.RK(b, f, h);
            null != f && (g = gvjs_KL(this.AG.clone(), gvjs_KQ, g),
            c.push(new gvjs_NR(f,g,this.Ci)))
        }
    }, this);
    if (!d && this.W2 && (a = this.qe.Fo(),
    0 <= a && 1 >= a && (a = this.RK(b, a, this.CG),
    null != a))) {
        var e = gvjs_KL(this.AG.clone(), gvjs_KQ, this.fg.ticks.length);
        c.push(new gvjs_NR(a,e,this.Ci))
    }
    return c
}
;
function gvjs_$R(a) {
    this.fg = a.ticks;
    this.qe = a.scale;
    this.AG = a.hW;
    this.Ci = a.layer;
    this.PK = a.Ja || !1;
    this.W2 = a.baseline || !1;
    this.zI = a.style.Ja;
    this.CG = gvjs_mj({}, this.zI, a.style.baseline)
}
gvjs_$R.prototype.RK = function(a, b, c) {
    if (null == b)
        return null;
    b = b * a.width + a.left;
    return new gvjs_3Q(b,a.top,b,a.top + a.height,c)
}
;
gvjs_$R.prototype.R = function(a, b) {
    var c = []
      , d = !1;
    this.PK && gvjs_u(this.fg.ticks, function(f, g) {
        f = f.value;
        f = this.qe.scale(f);
        if (!(0 > f || 1 < f)) {
            var h = this.zI;
            f === this.qe.Fo() && (h = this.CG,
            d = !0);
            f = this.RK(b, f, h);
            null != f && (g = gvjs_KL(this.AG.clone(), gvjs_KQ, g),
            c.push(new gvjs_NR(f,g,this.Ci)))
        }
    }, this);
    if (!d && this.W2 && (a = this.qe.Fo(),
    0 <= a && 1 >= a && (a = this.RK(b, a, this.CG),
    null != a))) {
        var e = gvjs_KL(this.AG.clone(), gvjs_KQ, this.fg.ticks.length);
        c.push(new gvjs_NR(a,e,this.Ci))
    }
    return c
}
;
function gvjs_aS(a) {
    this.H = a ? a.element() : null;
    this.pw = a ? a.pw : null;
    this.If = a ? a.left() : null;
    this.xj = a ? a.top() : null;
    this.ga = a ? a.width() : null;
    this.Pa = a ? a.height() : null;
    this.oC = a ? a.extra() : null;
    this.Uc = a ? gvjs_Le(a.children()) : [];
    this.jE = a ? gvjs_x(a.properties()) : {}
}
gvjs_ = gvjs_aS.prototype;
gvjs_.cd = function() {
    return new gvjs_sR(this.H,this.pw,this.Uc,this.If,this.xj,this.ga,this.Pa,this.oC,this.jE)
}
;
gvjs_.property = function(a, b) {
    return null != b ? (this.jE[a] = b,
    this) : this.jE[a]
}
;
gvjs_.addChild = function(a) {
    this.Uc.push(a);
    return this
}
;
gvjs_.sA = function(a) {
    this.H = a;
    return this
}
;
gvjs_.j = function() {
    return this.H
}
;
gvjs_.au = function(a) {
    this.If = a;
    return this
}
;
gvjs_.Kn = function(a) {
    this.xj = a;
    return this
}
;
gvjs_.Ev = function() {
    return this.xj
}
;
gvjs_.Ug = function(a) {
    this.ga = a;
    return this
}
;
gvjs_.La = function() {
    return this.ga
}
;
gvjs_.fl = function(a) {
    this.Pa = a;
    return this
}
;
gvjs_.getHeight = function() {
    return this.Pa
}
;
function gvjs_bS(a) {
    this.md = a || {}
}
gvjs_ = gvjs_bS.prototype;
gvjs_.children = function() {
    return null
}
;
gvjs_.clone = function() {
    var a = gvjs_0e(this.md);
    return new gvjs_bS(a)
}
;
gvjs_.getStyle = function(a, b) {
    a = this.md[a];
    return null == a && null != b ? b : a
}
;
gvjs_.setStyle = function(a, b) {
    if ("padding" === a || a === gvjs_Ev)
        return this.setStyle(a + ".left", b).setStyle(a + ".right", b).setStyle(a + ".top", b).setStyle(a + ".bottom", b);
    this.md[a] = b;
    return this
}
;
function gvjs_cS(a, b) {
    for (var c in b)
        a.setStyle(c, b[c]);
    return a
}
gvjs_.layout = function(a, b, c) {
    b = {};
    gvjs_mj(b, this.md);
    var d = gvjs_rR(gvjs_qR((new gvjs_pR).au(this.getStyle("padding.left", 0)), this.getStyle("padding.right", 0)), this.getStyle("padding.bottom", 0)).Kn(this.getStyle("padding.top", 0));
    var e = gvjs_rR(gvjs_qR((new gvjs_pR).au(this.getStyle("margin.left", 0)), this.getStyle("margin.right", 0)), this.getStyle(gvjs_UQ, 0)).Kn(this.getStyle("margin.top", 0));
    var f = gvjs_rR(gvjs_qR((new gvjs_pR).au(this.getStyle("border.left", 0)), this.getStyle("border.right", 0)), this.getStyle("border.bottom", 0)).Kn(this.getStyle("border.top", 0))
      , g = gvjs_rR(gvjs_qR((new gvjs_pR).au(d.left() + e.left() + f.left()), d.right() + e.right() + f.right()).Kn(d.top() + e.top() + f.top()), d.bottom() + e.bottom() + f.bottom())
      , h = c ? c.width : null
      , k = c ? c.height : null
      , l = this.getStyle(gvjs_Xd);
    null != l && isFinite(l) || (l = null);
    null != h && isFinite(h) && (null == l || Infinity == l || l > h) && (l = h);
    null != l && isFinite(l) && (l -= g.width());
    h = this.getStyle(gvjs_4c);
    null != h && isFinite(h) || (h = null);
    null != k && isFinite(k) && (null == h || Infinity == h || h > k) && (h = k);
    null != h && isFinite(h) && (h -= g.height());
    e = {
        padding: d,
        margin: e,
        border: f,
        al: g,
        content: {
            width: null != l ? l : null,
            height: null != h ? h : null
        }
    };
    null != e.content.width && (e.content.width = Math.max(0, e.content.width));
    null != e.content.height && (e.content.height = Math.max(0, e.content.height));
    d = (new gvjs_aS).sA(this);
    d.pw = e;
    null != e.content.width && d.Ug(e.content.width + e.al.width());
    null != e.content.height && d.fl(e.content.height + e.al.height());
    f = d;
    d = (d = this.p0(a, d, e)) || f;
    a = b.halign || 0;
    e = b.valign || 0;
    d.au(d.If || 0);
    d.Kn(d.Ev() || 0);
    f = b[gvjs_WQ];
    null != f && isFinite(f) && d.Ug(f);
    b = b["min-height"];
    null != b && isFinite(b) && d.fl(b);
    b = (f = d.oC) ? f.width : 0;
    f = f ? f.height : 0;
    c && (d.La() > c.width && d.Ug(c.width),
    d.getHeight() > c.height && d.fl(c.height));
    d.oC = new gvjs_A(b,f);
    c && null != c.width && a && d.La() < c.width && d.au(a * c.width - d.La() * a + d.If);
    c && null != c.height && e && d.getHeight() < c.height && d.Kn(e * c.height - d.getHeight() * e + d.Ev());
    return d.cd()
}
;
gvjs_.p0 = function(a, b, c) {
    a = b.La();
    var d = b.getHeight();
    return b.Ug(null == a ? c.al.width() : a).fl(null == d ? c.al.height() : d)
}
;
function gvjs_dS(a, b, c) {
    this.md = c || {};
    this.wf = new gvjs_A(a,b);
    this.OB = gvjs_Te(null, this.wf.width * this.wf.height)
}
gvjs_o(gvjs_dS, gvjs_bS);
gvjs_ = gvjs_dS.prototype;
gvjs_.dimensions = function() {
    return this.wf.clone()
}
;
gvjs_.clone = function() {
    var a = gvjs_0e(this.md)
      , b = this.wf.width
      , c = this.wf.height;
    a = new gvjs_dS(b,c,a);
    for (var d = 0; d < b; d++)
        for (var e = 0; e < c; e++) {
            var f = this.si(d, e);
            f && a.Wb(d, e, f.clone())
        }
    return a
}
;
gvjs_.children = function() {
    return gvjs_De(this.OB, gvjs_6Q(function(a) {
        return null === a
    }))
}
;
gvjs_.MK = function(a, b) {
    this.OB[b * this.wf.width + a] = null
}
;
gvjs_.si = function(a, b) {
    return this.OB[b * this.wf.width + a]
}
;
gvjs_.Wb = function(a, b, c) {
    this.OB[b * this.wf.width + a] = c;
    return this
}
;
function gvjs_eS(a, b, c, d, e) {
    var f = null == d ? !1 : d
      , g = null == e ? !1 : e
      , h = a.wf.width;
    e = c && c.SO || {};
    d = c && c.RO || {};
    for (var k = gvjs_Te(0, h), l = gvjs_Te(0, a.wf.height), m = [], n = {}, p = 0; p < a.OB.length; p++)
        if (n[p])
            m.push(void 0);
        else {
            var q = p % h
              , r = (p - q) / h
              , t = a.OB[p] || new gvjs_bS
              , u = t.getStyle("colspan");
            if (typeof u !== gvjs_g || 1 > u)
                u = 1;
            var v = t.getStyle("rowspan");
            if (typeof v !== gvjs_g || 1 > v)
                v = 1;
            var w = void 0;
            if (c && (!f || !g)) {
                var x = f ? Infinity : 0
                  , y = g ? Infinity : 0;
                w = q;
                for (var z = q + u; w < z; w++) {
                    x += c.Ic[w];
                    for (var A = r, B = r + v; A < B; A++)
                        n[A * a.wf.width + w] = !0,
                        y += c.Ec[A]
                }
                w = new gvjs_A(x,y)
            }
            var D = t.layout(b, {}, w);
            x = t.getStyle(gvjs_Xd);
            y = t.getStyle(gvjs_4c);
            if (!w && (Infinity == x || Infinity == y)) {
                if (Infinity == x)
                    for (w = q,
                    z = q + u; w < z; w++)
                        e[w] = !0;
                if (Infinity == y)
                    for (A = r,
                    B = r + v; A < B; A++)
                        d[A] = !0
            }
            m.push(D);
            1 >= u && (k[q] = Math.max(D.width(), k[q]));
            if (c && !f)
                for (w = q,
                z = q + u; w < z; w++)
                    isFinite(c.Ic[w]) && (k[w] = Math.max(k[w], c.Ic[w]));
            1 >= v && (l[r] = Math.max(D.height(), l[r]));
            if (c && !g)
                for (A = r,
                B = r + v; A < B; A++)
                    isFinite(c.Ec[A]) && (l[A] = Math.max(l[A], c.Ec[A]))
        }
    a = gvjs_az.apply(null, k);
    b = gvjs_az.apply(null, l);
    return {
        cells: m,
        SO: e,
        RO: d,
        Ic: k,
        Ec: l,
        size: new gvjs_A(a,b)
    }
}
function gvjs_fS(a, b, c) {
    for (var d = 0, e = gvjs_v(b.Ic, function(v, w) {
        b.SO[w] && d++;
        for (var x = Infinity, y = 0, z = this.wf.height; y < z; y++) {
            var A = b.cells[y * this.wf.width + w]
              , B = this.si(w, y);
            A && B && (B = B.getStyle("colspan"),
            typeof B === gvjs_g && 1 < B || (x = Math.min(x, v - A.width() + A.extra().width)))
        }
        return Infinity > x ? x : 0
    }, a), f = [], g = 0, h = a.wf.width; g < h; g++)
        for (var k = 0, l = a.wf.height; k < l; k++) {
            var m = k * a.wf.width + g
              , n = b.cells[m];
            if (n = a.si(g, k)) {
                n = n.getStyle("colspan");
                if (typeof n !== gvjs_g || 1 > n)
                    n = 1;
                if (1 < n) {
                    var p = {
                        index: m,
                        columns: {
                            lA: [],
                            xo: []
                        }
                    };
                    f.push(p);
                    m = g;
                    for (n = g + n; m < n; m++)
                        b.SO[m] ? p.columns.xo.push(m) : p.columns.lA.push(m)
                }
            }
        }
    g = 0;
    for (h = f.length; g < h; g++) {
        p = f[g];
        n = b.cells[p.index];
        var q = 0
          , r = 0;
        gvjs_u(p.columns.lA, function(v) {
            q += e[v];
            b.Ic[v] -= e[v];
            b.size.width -= e[v];
            r += b.Ic[v];
            e[v] = 0
        });
        gvjs_u(p.columns.xo, function(v) {
            q += e[v];
            b.Ic[v] -= e[v];
            b.size.width -= e[v];
            r += b.Ic[v];
            e[v] = 0
        });
        if (r < n.width())
            if (0 < p.columns.xo.length)
                q = Math.max(0, n.width() - r),
                gvjs_u(p.columns.xo, function(v) {
                    var w = b.Ic[v];
                    b.Ic[v] += q / p.columns.xo.length;
                    b.size.width += b.Ic[v] - w
                });
            else {
                q = Math.max(0, Math.min(q, r - n.width() + n.extra().width));
                var t = n.width() - q;
                gvjs_u(p.columns.lA, function(v) {
                    var w = b.Ic[v];
                    b.Ic[v] = b.Ic[v] / r * t;
                    b.size.width += b.Ic[v] - w
                })
            }
    }
    b.Ic = gvjs_v(gvjs_My(b.Ic, e), function(v) {
        b.size.width -= v[1];
        return v[0] - v[1]
    });
    f = a.getStyle(gvjs_Hv, Infinity) - c.al.width();
    a = a.getStyle(gvjs_WQ, -Infinity) - c.al.width();
    c = gvjs_tR(c.content.width, b.size.width, a, f);
    if (null != c) {
        if (b.size.width < c) {
            if (a = c - b.size.width,
            0 < d) {
                for (var u in b.SO)
                    b.Ic[Number(u)] += a / d;
                b.size.width = c
            }
        } else if (b.size.width > c)
            if (1 === b.Ic.length)
                b.size.width = b.Ic[0] = c;
            else
                for (u = gvjs_Ky(b.Ic.length),
                gvjs_Qe(u, function(v, w) {
                    return -gvjs_Re(b.Ic[v], b.Ic[w])
                }),
                g = 0,
                h = u.length - 1; g < h; g++)
                    if (a = b.Ic[u[g]],
                    f = b.Ic[u[g + 1]],
                    a !== f) {
                        f = a * (g + 1) - f;
                        k = b.size.width - c;
                        a = f;
                        f >= k && (a = k);
                        f = 0;
                        for (k = g; f <= k; f++)
                            b.Ic[u[f]] -= a / (g + 1);
                        b.size.width -= a;
                        if (b.size.width <= c)
                            break
                    }
        if (b.size.width !== c) {
            g = 0;
            for (h = b.Ic.length; g < h; g++)
                b.Ic[g] = 0 >= b.size.width ? c / b.Ic.length : b.Ic[g] / b.size.width * c;
            b.size.width = c
        }
    }
}
function gvjs_gS(a, b, c) {
    for (var d = 0, e = gvjs_v(b.Ec, function(v, w) {
        b.RO[w] && d++;
        for (var x = Infinity, y = 0, z = this.wf.width; y < z; y++) {
            var A = b.cells[w * this.wf.width + y]
              , B = this.si(y, w);
            A && B && (B = B.getStyle("rowspan"),
            typeof B === gvjs_g && 1 < B || (x = Math.min(x, v - A.height() + A.extra().height)))
        }
        return Infinity > x ? x : 0
    }, a), f = [], g = 0, h = a.wf.height; g < h; g++)
        for (var k = 0, l = a.wf.width; k < l; k++) {
            var m = g * a.wf.width + k
              , n = b.cells[m];
            if (n = a.si(k, g)) {
                n = n.getStyle("rowspan");
                if (typeof n !== gvjs_g || 1 > n)
                    n = 1;
                if (1 < n) {
                    var p = {
                        index: m,
                        rows: {
                            lA: [],
                            xo: []
                        }
                    };
                    f.push(p);
                    m = g;
                    for (n = g + n; m < n; m++)
                        b.RO[m] ? p.rows.xo.push(m) : p.rows.lA.push(m)
                }
            }
        }
    g = 0;
    for (h = f.length; g < h; g++) {
        p = f[g];
        n = b.cells[p.index];
        var q = 0
          , r = 0;
        gvjs_u(p.rows.lA, function(v) {
            q += e[v];
            b.Ec[v] -= e[v];
            b.size.height -= e[v];
            r += b.Ec[v];
            e[v] = 0
        });
        gvjs_u(p.rows.xo, function(v) {
            q += e[v];
            b.Ec[v] -= e[v];
            b.size.height -= e[v];
            r += b.Ec[v];
            e[v] = 0
        });
        if (r < n.height())
            if (0 < p.rows.xo.length)
                q = Math.max(0, n.height() - r),
                gvjs_u(p.rows.xo, function(v) {
                    var w = b.Ec[v];
                    b.Ec[v] += q / p.rows.xo.length;
                    b.size.height += b.Ec[v] - w
                });
            else {
                q = Math.max(0, Math.min(q, r - n.height() + n.extra().height));
                var t = n.height() - q;
                gvjs_u(p.rows.lA, function(v) {
                    var w = b.Ec[v];
                    b.Ec[v] = b.Ec[v] / r * t;
                    b.size.height += b.Ec[v] - w
                })
            }
    }
    b.Ec = gvjs_v(gvjs_My(b.Ec, e), function(v) {
        b.size.height -= v[1];
        return v[0] - v[1]
    });
    f = a.getStyle("max-height", Infinity) - c.al.height();
    a = a.getStyle("min-height", -Infinity) - c.al.height();
    c = gvjs_tR(c.content.height, b.size.height, a, f);
    if (null != c) {
        if (b.size.height < c) {
            if (a = c - b.size.height,
            0 < d) {
                for (var u in b.RO)
                    b.Ec[Number(u)] += a / d;
                b.size.height = c
            }
        } else if (b.size.height > c)
            if (1 === b.Ec.length)
                b.size.height = b.Ec[0] = c;
            else
                for (u = gvjs_Ky(b.Ec.length),
                gvjs_Qe(u, function(v, w) {
                    return -gvjs_Re(b.Ec[v], b.Ec[w])
                }),
                g = 0,
                h = u.length - 1; g < h; g++)
                    if (a = b.Ec[u[g]],
                    f = b.Ec[u[g + 1]],
                    a !== f) {
                        f = a * (g + 1) - f;
                        k = b.size.height - c;
                        a = f;
                        f >= k && (a = k);
                        f = 0;
                        for (k = g; f <= k; f++)
                            b.Ec[u[f]] -= a / (g + 1);
                        b.size.height -= a;
                        if (b.size.height <= c)
                            break
                    }
        if (b.size.height !== c) {
            g = 0;
            for (h = b.Ec.length; g < h; g++)
                b.Ec[g] = 0 >= b.size.height ? c / b.Ec.length : b.Ec[g] / b.size.height * c;
            b.size.height = c
        }
    }
}
gvjs_.p0 = function(a, b, c) {
    var d = gvjs_eS(this, a);
    gvjs_fS(this, d, c);
    gvjs_gS(this, d, c);
    d = gvjs_eS(this, a, d, !1, !0);
    gvjs_fS(this, d, c);
    gvjs_gS(this, d, c);
    d = gvjs_eS(this, a, d, !1, !1);
    a = this.wf.width;
    for (var e = this.wf.height, f = d.Ic, g = d.Ec, h = d.cells, k = gvjs_Te(Infinity, a), l = gvjs_Te(Infinity, e), m = d = 0, n = 0; n < e; n++) {
        for (var p = 0, q = 0; q < a; q++) {
            var r = h[n * a + q];
            if (null != r) {
                k[q] = Math.min(k[q], f[q] - r.width() + r.extra().width);
                l[n] = Math.min(l[n], g[n] - r.height() + r.extra().height);
                var t = (r.left() || 0) + p
                  , u = (r.top() || 0) + m;
                r = (new gvjs_aS(r)).au(t).Kn(u).cd();
                b.addChild(r)
            }
            p += f[q]
        }
        d = Math.max(d, p);
        m += g[n]
    }
    a = new gvjs_A(gvjs_az.apply(null, k),gvjs_az.apply(null, l));
    b.oC = a;
    a = new gvjs_A(d,m);
    b.Ug(a.width + c.al.width());
    b.fl(a.height + c.al.height());
    b.au(null != b.If ? b.If : 0);
    b.Kn(null != b.Ev() ? b.Ev() : 0);
    return b
}
;
function gvjs_hS(a, b) {
    this.md = b || {};
    this.Wi = a
}
gvjs_o(gvjs_hS, gvjs_bS);
gvjs_hS.prototype.clone = function() {
    var a = gvjs_0e(this.md);
    return new gvjs_hS(this.getContent(),a)
}
;
gvjs_hS.prototype.getContent = function() {
    return this.Wi
}
;
gvjs_hS.prototype.setContent = function(a) {
    this.Wi = a;
    return this
}
;
gvjs_hS.prototype.p0 = function(a, b, c) {
    var d = this.md
      , e = this.getContent();
    if (null === e)
        return b.Ug(0),
        b.fl(0),
        b;
    var f = b.La();
    f = (null == f ? Infinity : f) - c.al.width();
    var g = d[gvjs_VQ];
    null == g && (g = Infinity);
    0 >= g ? e = [] : (e = gvjs_CG(a, e, d, f, g),
    e = gvjs_v(e.lines, gvjs_kf));
    e = e.join("\n");
    a = a(e, d);
    b.Ug(Math.min(a.width + c.al.width(), b.La() || Infinity));
    b.property(gvjs_m, e);
    d.width = b.La() - c.al.width();
    b.property(gvjs_Jd, d);
    b.fl(a.height + c.al.height());
    return b
}
;
function gvjs_iS() {
    this.Pq = {}.maxWidth || null
}
gvjs_iS.prototype.define = function(a, b) {
    var c = 20;
    if (1 < b.length)
        b = gvjs_Kia(b);
    else {
        b = b[0];
        b.title || (c = 7);
        var d = new gvjs_dS(1,2)
          , e = gvjs_jS(b);
        e && (e.setStyle(gvjs_UQ, b.subtitle ? 15 : 5),
        d.Wb(0, 0, e));
        d.Wb(0, 1, gvjs_cS(new gvjs_hS(b.value), gvjs_kS).setStyle(gvjs_np, b.color));
        b = d
    }
    a = (new gvjs_dS(1,2)).Wb(0, 0, gvjs_cS(new gvjs_hS(a), gvjs_Lia).setStyle(gvjs_UQ, c)).Wb(0, 1, b);
    this.Pq && a.setStyle(gvjs_Hv, this.Pq);
    return gvjs_cS(a, gvjs_Mia)
}
;
function gvjs_jS(a) {
    return a.subtitle ? (new gvjs_dS(1,2)).Wb(0, 0, gvjs_cS(new gvjs_hS(a.title || "\u2014"), gvjs_lS).setStyle(gvjs_VQ, 1).setStyle(gvjs_UQ, 5)).Wb(0, 1, gvjs_cS(new gvjs_hS(a.subtitle), gvjs_Nia)) : a.title ? gvjs_cS(new gvjs_hS(a.title), gvjs_lS).setStyle("line-spacing", 5).setStyle(gvjs_VQ, 2) : null
}
function gvjs_Oia(a) {
    for (var b = (new gvjs_dS(1,a.length)).setStyle(gvjs_Xd, Infinity), c = 0, d = a.length; c < d; c++) {
        var e = a[c];
        e = gvjs_cS(new gvjs_hS(e.value), gvjs_kS).setStyle(gvjs_VQ, 1).setStyle(gvjs_np, e.color);
        b.Wb(0, c, e);
        c < d - 1 && e.setStyle(gvjs_UQ, 15)
    }
    return b
}
function gvjs_Pia(a) {
    for (var b = (new gvjs_dS(3,a.length)).setStyle(gvjs_Xd, Infinity), c = 0, d = a.length; c < d; c++) {
        var e = a[c]
          , f = gvjs_jS(e);
        f || (f = gvjs_cS(new gvjs_hS("\u2014"), gvjs_lS).setStyle(gvjs_VQ, 1));
        e = gvjs_cS(new gvjs_hS(e.value), gvjs_Qia).setStyle(gvjs_Dp, 1).setStyle(gvjs_VQ, 1).setStyle(gvjs_np, e.color);
        c < d - 1 && f.setStyle(gvjs_UQ, 15);
        b.Wb(0, c, f);
        b.Wb(1, c, (new gvjs_bS).setStyle(gvjs_Xd, Infinity).setStyle(gvjs_WQ, 15));
        b.Wb(2, c, e)
    }
    return b
}
function gvjs_Kia(a) {
    return gvjs_Ge(a, function(b) {
        return !(b.title || b.subtitle)
    }) ? gvjs_Oia(a) : gvjs_Pia(a)
}
var gvjs_Lia = {
    "line-spacing": 5,
    "max-lines": 2,
    fill: gvjs_6R[gvjs_Vr],
    "font.family": gvjs_qs,
    "font.size": 14,
    "font.weight": 500
}
  , gvjs_lS = {
    fill: gvjs_6R[gvjs_Tr],
    "font.family": gvjs_qs,
    "font.size": 14
}
  , gvjs_Nia = {
    "max-lines": 1,
    fill: gvjs_6R[gvjs_Rr],
    "font.family": gvjs_qs,
    "font.size": 14
}
  , gvjs_Qia = {
    "font.family": gvjs_qs,
    "font.size": 14
}
  , gvjs_kS = {
    "font.family": gvjs_qs,
    "font.size": 24,
    "max-lines": 1
}
  , gvjs_Mia = {
    "corners.rx": 2,
    "corners.ry": 2,
    "fill.color": gvjs_Ox,
    "stroke.color": "#c1c1c1",
    "stroke.width": 1.1,
    "padding.left": 15,
    "padding.right": 15,
    "padding.top": 18,
    "padding.bottom": 18,
    "shadow.xoffset": 0,
    "shadow.yoffset": 2,
    "shadow.radius": 1,
    "shadow.opacity": .2
};
function gvjs_mS(a, b, c, d) {
    this.Km = a;
    this.Wd = b;
    this.jj = c;
    this.gQ = 10;
    this.to = d
}
gvjs_mS.prototype.position = function(a, b) {
    if (null == a) {
        var c = 0 === this.to.x && 0 === this.to.y ? gvjs_PQ : 0 !== this.to.x && 0 !== this.to.y ? gvjs_PQ : 0 > this.to.y ? gvjs_PQ : 0 < this.to.x ? gvjs_j : 0 < this.to.y ? gvjs_qt : gvjs_$c;
        a = [];
        for (var d = 0, e = gvjs_nS.length; d < e; d++)
            a.push(c),
            c = gvjs_Be(gvjs_nS, c),
            c = gvjs_nS[(c + 1) % gvjs_nS.length]
    }
    d = 0;
    for (e = a.length; d < e; d++)
        if (c = a[d],
        !b && d === e - 1 || gvjs_Ria(this, c))
            return gvjs_oS(this, c);
    return null != b ? gvjs_oS(this, b) : null
}
;
function gvjs_Ria(a, b) {
    switch (b) {
    case gvjs_PQ:
        return a.Wd.top - a.Km.top >= a.jj.height;
    case gvjs_qt:
        return a.Km.top + a.Km.height - (a.Wd.top + a.Wd.height) >= a.jj.height;
    case gvjs_j:
        return a.Km.left + a.Km.width - (a.Wd.left + a.Wd.width) >= a.jj.width;
    case gvjs_$c:
        return a.Wd.left - a.Km.left >= a.jj.width;
    case gvjs_0:
        return b = new gvjs_5(a.Wd.left - (a.jj.width / 2 - a.Wd.width / 2),a.Wd.top - (a.jj.height / 2 - a.Wd.height / 2),a.jj.width,a.jj.height),
        b.left >= a.Km.left && b.top >= a.Km.top && b.left + b.width <= a.Km.left + a.Km.width && b.top + b.height <= a.Km.top + a.Km.height
    }
}
function gvjs_pS(a) {
    return 0 > a.to.x ? a.Wd.left + a.gQ : 0 < a.to.x ? a.Wd.left + a.Wd.width - a.jj.width - a.gQ : a.Wd.left + a.Wd.width / 2 - a.jj.width / 2
}
function gvjs_qS(a) {
    return 0 > a.to.y ? a.Wd.top + a.gQ : 0 < a.to.y ? a.Wd.top + a.Wd.height - a.jj.height - a.gQ : a.Wd.top + a.Wd.height / 2 - a.jj.height / 2
}
function gvjs_oS(a, b) {
    switch (b) {
    case gvjs_PQ:
        return new gvjs_z(gvjs_pS(a),a.Wd.top - a.jj.height);
    case gvjs_qt:
        return new gvjs_z(gvjs_pS(a),a.Wd.top + a.Wd.height);
    case gvjs_j:
        return new gvjs_z(a.Wd.left + a.Wd.width,gvjs_qS(a));
    case gvjs_$c:
        return new gvjs_z(a.Wd.left - a.jj.width,gvjs_qS(a));
    case gvjs_0:
        return new gvjs_z(a.Wd.left - (a.jj.width / 2 - a.Wd.width / 2),a.Wd.top - (a.jj.height / 2 - a.Wd.height / 2))
    }
}
var gvjs_nS = [gvjs_PQ, gvjs_j, gvjs_qt, gvjs_$c];
function gvjs_rS(a) {
    this.Kv = gvjs_Ke(a, [gvjs_s(this.Cva, this), gvjs_s(this.Ava, this)]);
    this.debug = !1
}
gvjs_rS.prototype.Cva = function(a, b) {
    if (a.element()instanceof gvjs_hS) {
        var c = a.pw
          , d = c.margin
          , e = c.padding;
        c = b.x + a.left() + d.left() + e.left();
        b = b.y + a.top() + d.top() + e.top();
        var f = a.width() - d.width() - e.width();
        d = a.height() - d.height() - e.height();
        e = a.element().getStyle(gvjs_Dp);
        typeof e === gvjs_g && isFinite(e) || (e = 0);
        var g = a.element().getStyle(gvjs_eq);
        typeof g === gvjs_g && isFinite(g) || (g = 0);
        c = new gvjs_1Q(c + f * e,b + d * g,void 0,a.property(gvjs_Jd));
        c.setStyle(gvjs_m, a.property(gvjs_m));
        return [c]
    }
    return null
}
;
gvjs_rS.prototype.Ava = function(a, b) {
    var c = a.element()
      , d = a.children()
      , e = []
      , f = a.pw
      , g = f.margin;
    f = f.padding;
    (c.getStyle(gvjs_3p) || c.getStyle(gvjs_pp) || c.getStyle(gvjs_6p) || c.getStyle(gvjs_rp)) && e.push(new gvjs_4Q(b.x + a.left() + g.left(),b.y + a.top() + g.top(),a.width() - g.width(),a.height() - g.height(),c.md));
    c = 0;
    for (var h = d.length; c < h; c++)
        gvjs_Me(e, this.R(d[c], new gvjs_z(b.x + a.left() + g.left() + f.left(),b.y + a.top() + g.top() + f.top())));
    return e
}
;
gvjs_rS.prototype.R = function(a, b) {
    b = b || new gvjs_z(0,0);
    for (var c = [], d = 0, e = this.Kv.length; d < e; d++) {
        var f = (0,
        this.Kv[d])(a, b);
        if (null !== f) {
            gvjs_Me(c, f);
            break
        }
    }
    this.debug && (e = a.pw,
    d = e.margin,
    e = e.padding,
    gvjs_Me(c, [new gvjs_4Q(b.x + a.left(),b.y + a.top(),a.width(),a.height(),{
        strokeColor: "red",
        fillColor: gvjs_f
    }), new gvjs_4Q(b.x + a.left() + d.left(),b.y + a.top() + d.top(),a.width() - d.width(),a.height() - d.height(),{
        strokeColor: "green",
        fillColor: gvjs_f
    }), new gvjs_4Q(b.x + a.left() + d.left() + e.left(),b.y + a.top() + d.top() + e.top(),a.width() - d.width() - e.width(),a.height() - d.height() - e.height(),{
        strokeColor: "blue",
        fillColor: gvjs_f
    })]));
    return c
}
;
function gvjs_sS(a) {
    a = a || {};
    this.Sba = a.style && a.style.spacing || 0;
    this.Rla = a.style && a.style.container || {};
    this.yra = a.style && a.style.icon || {};
    this.gya = a.style && a.style.title || {};
    this.Fxa = a.style && a.style.subtitle || {}
}
gvjs_sS.prototype.define = function(a) {
    var b = gvjs_cS(new gvjs_dS(2,2 * a.length - 1), this.Rla);
    gvjs_u(a, function(c, d) {
        d *= 2;
        var e = gvjs_cS((new gvjs_bS).setStyle(gvjs_pp, c.color), this.yra).setStyle(gvjs_5c, c.xra);
        b.Wb(0, d, e);
        e = c.subtitle;
        if (null != c.title || e) {
            var f = gvjs_cS(new gvjs_hS(c.title), this.gya).setStyle(gvjs_5c, c.eya), g;
            e && (g = gvjs_cS(new gvjs_hS(c.subtitle), this.Fxa).setStyle(gvjs_5c, c.Exa));
            null == f.getStyle(gvjs_VQ) && f.setStyle(gvjs_VQ, g ? 1 : 2);
            g ? (c = (new gvjs_dS(1,2)).Wb(0, 0, f),
            c.Wb(1, 0, g),
            b.Wb(1, d, c)) : b.Wb(1, d, f)
        }
        d / 2 + 1 < a.length && 0 < this.Sba && b.Wb(1, d + 1, (new gvjs_bS).setStyle(gvjs_4c, this.Sba))
    }, this);
    return b
}
;
function gvjs_tS(a) {
    this.window = {
        x: a.x,
        y: a.y
    };
    this.Ao = a.hoa || !1
}
gvjs_o(gvjs_tS, gvjs_DR);
function gvjs_Sia(a, b, c) {
    function d(p, q, r) {
        return (0 < q ? gvjs_vt : gvjs_vx) + (0 < p ? gvjs_j : gvjs_$c) + (0 < r ? ".ry" : ".rx")
    }
    var e = a.Ao;
    c.style(gvjs_6o, null).style(gvjs_7o, null).style(gvjs_8o, null).style(gvjs_9o, null).style(gvjs_dp, null).style(gvjs_ep, null).style(gvjs_bp, null).style(gvjs_cp, null);
    for (var f = 0; 2 > f; f++)
        for (var g = 0; 2 > g; g++)
            for (var h = 0; 2 > h; h++) {
                var k = "corners." + d(f, g, h)
                  , l = 0 === g ? -Infinity : Infinity
                  , m = 0 === h ? -Infinity : Infinity
                  , n = a.window.x.fi(0 === f ? -Infinity : Infinity);
                l = a.window.y.fi(l);
                m = "corners." + d(e ? l : n, e ? n : l, e ? -m : m);
                m = b.getStyle(m);
                null != m && c.style(k, m)
            }
}
function gvjs_Tia(a, b) {
    var c = b.$u
      , d = (new gvjs_Uq(b.md)).setData(b.data());
    gvjs_u(c, function(e) {
        switch (e[0]) {
        case "M":
            d.move(this.window.x.scale(this.Ao ? e[2] : e[1]), this.window.y.scale(this.Ao ? e[1] : e[2]));
            break;
        case "L":
            d.line(this.window.x.scale(this.Ao ? e[2] : e[1]), this.window.y.scale(this.Ao ? e[1] : e[2]));
            break;
        default:
            throw Error("Unrecognized command " + e[0]);
        }
    }, a);
    return d
}
gvjs_tS.prototype.transform = function(a) {
    if (a instanceof gvjs_4Q) {
        var b = gvjs_xq(a)
          , c = this.Ao ? gvjs_L(b, "y") : gvjs_L(b, "x")
          , d = this.Ao ? gvjs_L(b, "x") : gvjs_L(b, "y")
          , e = this.Ao ? gvjs_L(b, gvjs_4c) : gvjs_L(b, gvjs_Xd)
          , f = this.Ao ? gvjs_L(b, gvjs_Xd) : gvjs_L(b, gvjs_4c);
        b = c + e;
        e = d + f;
        c = this.window.x.scale(c);
        b = this.window.x.scale(b);
        d = this.window.y.scale(d);
        e = this.window.y.scale(e);
        d = new gvjs_4Q(c,d,b - c,e - d,a.md);
        gvjs_Sia(this, a, d);
        d.data(a.data());
        return d
    }
    if (a instanceof gvjs_Uq)
        return gvjs_Tia(this, a);
    if (a instanceof gvjs_2Q)
        return d = gvjs_xq(a),
        c = a.md,
        (new gvjs_2Q(gvjs_L(d, "r"),this.window.x.scale(gvjs_L(d, this.Ao ? "y" : "x")),this.window.y.scale(gvjs_L(d, this.Ao ? "x" : "y")),c)).setData(a.data());
    throw Error("Projection unknown type: " + a);
}
;
function gvjs_uS(a) {
    this.PC = 0;
    gvjs_4R.call(this, a)
}
gvjs_t(gvjs_uS, gvjs_4R);
gvjs_uS.prototype.pQ = function() {
    null != this.format && 0 < gvjs_Ye(this.format).length && (this.gd = new gvjs_Tj(this.format))
}
;
gvjs_uS.prototype.Zs = function(a) {
    if (this.gd)
        return {
            label: this.gd.Ob(new Date(a)),
            ja: {}
        };
    var b = !1;
    a = new Date(a);
    switch (this.PC) {
    case Dygraph.SECONDLY:
    case Dygraph.TWO_SECONDLY:
    case Dygraph.FIVE_SECONDLY:
    case Dygraph.THIRTY_SECONDLY:
        var c = "s";
        break;
    case Dygraph.MINUTELY:
    case Dygraph.TWO_MINUTELY:
    case Dygraph.FIVE_MINUTELY:
    case Dygraph.TEN_MINUTELY:
    case Dygraph.THIRTY_MINUTELY:
        c = ":mm";
        0 === a.getMinutes() || this.fs ? (b = !0,
        c = 7) : b = !1;
        this.fs = !1;
        break;
    case Dygraph.HOURLY:
    case Dygraph.TWO_HOURLY:
    case Dygraph.SIX_HOURLY:
        c = "h";
        b = a.getHours();
        0 !== a.getMinutes() && (c += ":mm");
        b = 12 === b || 0 === b || this.fs;
        this.fs = this.Gc > a.valueOf();
        b && (c += "\n a");
        break;
    case Dygraph.DAILY:
    case Dygraph.TWO_DAILY:
        c = "E";
        0 === a.getDay() || this.fs ? (c += "\n" + gvjs_2i.MONTH_DAY_SHORT,
        b = !0) : b = !1;
        this.fs = !1;
        break;
    case Dygraph.WEEKLY:
        c = gvjs_2i.MONTH_DAY_ABBR;
        b = this.fs;
        this.fs = !1;
        break;
    case Dygraph.MONTHLY:
    case Dygraph.QUARTERLY:
    case Dygraph.BIANNUAL:
        c = "LLL";
        b = 0 === a.getMonth() || this.fs;
        this.fs = this.Gc > a.valueOf();
        b && (c += "\n" + gvjs_2i.YEAR_FULL);
        break;
    case Dygraph.ANNUAL:
    case Dygraph.DECADAL:
    case Dygraph.CENTENNIAL:
        c = gvjs_2i.YEAR_FULL
    }
    if (null != c)
        return c = (new gvjs_Xi(c)).format(a),
        {
            label: c,
            ja: {
                bold: b
            }
        };
    throw gvjs_OQ;
}
;
gvjs_uS.prototype.wI = function(a, b) {
    var c = this.mH()
      , d = Dygraph.pickDateTickGranularity(a, b, this.size, c);
    return Dygraph.getDateAxis(a, b, d, c)
}
;
gvjs_uS.prototype.mH = function() {
    var a = this
      , b = {
        axisLabelFormatter: function(c, d) {
            a.PC = d;
            return "" + c
        },
        pixelsPerLabel: this.uK
    };
    return function(c) {
        return b[c]
    }
}
;
function gvjs_vS(a) {
    gvjs_4R.call(this, a)
}
gvjs_o(gvjs_vS, gvjs_4R);
gvjs_vS.prototype.Zs = function(a) {
    return {
        label: String(this.ta.fi(a)),
        ja: {
            Lb: "",
            bold: !1,
            color: gvjs_rt,
            bb: gvjs_2r,
            fontSize: 13,
            Nc: !1,
            Ue: !1
        }
    }
}
;
gvjs_vS.prototype.wI = function(a, b) {
    var c = this.mH()
      , d = gvjs_v(this.ta.getMapping(), function(e) {
        return e.v
    });
    return Dygraph.numericTicks(a, b, this.size, c, void 0, d)
}
;
gvjs_vS.prototype.mH = function() {
    var a = {
        axisLabelFormatter: function(b) {
            return "" + b
        },
        pixelsPerLabel: this.uK
    };
    return function(b) {
        return a[b]
    }
}
;
function gvjs_wS(a) {
    this.gd = null;
    gvjs_4R.call(this, a)
}
gvjs_t(gvjs_wS, gvjs_4R);
gvjs_wS.prototype.Zs = function(a) {
    return {
        label: this.gd.Ob(a),
        ja: {
            Lb: "",
            bold: !1,
            color: gvjs_rt,
            bb: gvjs_2r,
            fontSize: 13,
            Nc: !1,
            Ue: !1
        }
    }
}
;
gvjs_wS.prototype.pQ = function(a) {
    var b = 0;
    gvjs_u(a, function(c) {
        b = Math.max(b, gvjs_pA(c.v))
    }, this);
    a = {
        fractionDigits: b
    };
    this.format && gvjs_2e(a, this.format);
    this.gd = new gvjs_gk(a)
}
;
gvjs_wS.prototype.wI = function(a, b) {
    return Dygraph.numericTicks(a, b, this.size, this.mH())
}
;
gvjs_wS.prototype.mH = function() {
    var a = {
        axisLabelFormatter: function(b) {
            return "" + b
        },
        pixelsPerLabel: this.uK
    };
    return function(b) {
        return a[b]
    }
}
;
function gvjs_xS(a) {
    this.nU = new gvjs_WR;
    this.BH = new gvjs_QR(new gvjs_TR(this.nU),new gvjs_QR(new gvjs_YR,new gvjs_RR));
    gvjs_uS.call(this, a)
}
gvjs_t(gvjs_xS, gvjs_uS);
gvjs_xS.prototype.pQ = function() {
    this.gd = new gvjs_tk(this.format)
}
;
gvjs_xS.prototype.wI = function(a, b) {
    a = this.BH.scale(a);
    b = this.BH.scale(b);
    b = gvjs_xS.G.wI.call(this, a, b);
    return gvjs_v(b, function(c) {
        return {
            v: this.BH.fi(c.v)
        }
    }, this)
}
;
gvjs_xS.prototype.Zs = function(a) {
    a = this.nU.fi(a);
    return {
        label: this.gd.Ob(a),
        ja: {}
    }
}
;
var gvjs_yS = {};
gvjs_yS[gvjs_zb] = gvjs_vS;
gvjs_yS.string = gvjs_vS;
gvjs_yS.number = gvjs_wS;
gvjs_yS.date = gvjs_uS;
gvjs_yS.datetime = gvjs_uS;
gvjs_yS.timeofday = gvjs_xS;
function gvjs_zS() {}
gvjs_o(gvjs_zS, gvjs_DR);
gvjs_zS.prototype.transform = function(a) {
    var b = {}
      , c = {}
      , d = [];
    gvjs_u(a, function(e) {
        if (e instanceof gvjs_4Q) {
            var f = e.data().id
              , g = gvjs_v([f.rb.DOMAIN_INDEX, f.rb.group, f.rb.stack], String).join("-");
            f = f.rb.OBJECT_INDEX;
            var h = 0 < f ? b : c, k = h[g], l;
            if (l = k)
                l = k.data().id.rb.OBJECT_INDEX;
            !k || Math.abs(f) > Math.abs(l) ? (k && d.push(k),
            h[g] = e) : d.push(e)
        } else
            d.push(e)
    });
    gvjs_w(b, function(e) {
        d.push(e.clone().data(e.data()).style(gvjs_6o, 2).style(gvjs_7o, 2).style(gvjs_8o, 2).style(gvjs_9o, 2))
    });
    gvjs_w(c, function(e) {
        d.push(e.clone().data(e.data()).style(gvjs_bp, 2).style(gvjs_cp, 2).style(gvjs_dp, 2).style(gvjs_ep, 2))
    });
    return d
}
;
function gvjs_AS(a, b) {
    this.ura = a;
    this.$ya = b
}
gvjs_o(gvjs_AS, gvjs_DR);
gvjs_AS.prototype.transform = function(a) {
    var b = {};
    return gvjs_v(a, function(c) {
        var d = c.data().value
          , e = d.BO;
        e in b || (b[e] = {});
        var f = b[e];
        d = d.GL;
        if (!(d in f)) {
            e = this.ura[e];
            var g = this.$ya[d];
            f[d] = new gvjs_tS({
                x: new gvjs_QR(e.QB,e.p3),
                y: new gvjs_QR(g.QB,g.p3)
            })
        }
        return f[d].transform(c)
    }, this)
}
;
function gvjs_BS(a) {
    this.d7 = a
}
gvjs_o(gvjs_BS, gvjs_DR);
gvjs_BS.prototype.transform = function(a) {
    if (a instanceof gvjs_4Q) {
        var b = this.d7
          , c = this.d7 + 1
          , d = gvjs_xq(a)
          , e = gvjs_L(d, "x")
          , f = gvjs_L(d, gvjs_Xd);
        if (Math.abs(f) > c) {
            var g = gvjs_$y(f);
            f -= g * b;
            e += g * b / 2
        }
        g = gvjs_L(d, "y");
        d = gvjs_L(d, gvjs_4c);
        Math.abs(d) > c && (c = gvjs_$y(d),
        d -= c * b,
        g += c * b / 2);
        b = a.data();
        null == b && (b = null);
        return (new gvjs_4Q(e,g,f,d,a.md)).setData(b)
    }
    return a
}
;
var gvjs_CS = {
    IM: gvjs_S,
    MM: gvjs_U
};
function gvjs_DS(a, b, c, d) {
    this.Ta = a;
    this.options = b;
    this.sc = c;
    this.xla = d;
    this.jO = (new gvjs_aR).Ac(a)
}
gvjs_DS.prototype.vi = function() {
    return gvjs_S
}
;
function gvjs_ES(a, b) {
    if (a)
        return gvjs_SR;
    if (b in gvjs_XR)
        return gvjs_XR[b];
    throw Error("Unrecognized type: " + b);
}
function gvjs_Uia(a, b, c, d) {
    var e = []
      , f = {}
      , g = {}
      , h = 0
      , k = d === gvjs_U;
    b.Sm.forEach(function(n, p) {
        n = a.W(n.Yi);
        var q = gvjs_K(c, "domain." + p + ".discrete", !1);
        q = gvjs_ES(q, n);
        var r = null;
        q.nia && (n = "_discrete",
        n in f && (r = e[f[n][0]]));
        var t = c.cb("domain." + p + ".axis");
        null != t ? r = t : null === r && (r = h++);
        e.push(r);
        null == t && gvjs_Ty(f, n, []).push(p);
        gvjs_Ty(g, r, q)
    });
    var l = {}
      , m = !0;
    e.forEach(function(n, p) {
        p = b.Sm[p].Yi;
        if (!(n in l)) {
            var q = k ? "y" : "x"
              , r = c.pb(gvjs_QQ);
            q = c.view(["axes.domain." + n, "axes." + q + "." + n, "axes.domain.all", "axes." + q + ".all", "axes.all"]);
            var t = q.view(gvjs_Jd)
              , u = gvjs_J(q, "side", k ? m ? gvjs_$c : gvjs_j : gvjs_vt, k ? gvjs_1R : gvjs_2R)
              , v = a.W(p)
              , w = new g[n]
              , x = q.fa(gvjs_Xo)
              , y = !1;
            null != x && (y = !0,
            typeof x === gvjs_g ? w.Pw(x) : w.Zt(x));
            x = q.pb(gvjs_Fu);
            gvjs_Py(x) && v === gvjs_g && (x = {
                pattern: gvjs_Gd
            });
            l[n] = {
                name: n,
                type: v,
                scale: w,
                label: gvjs_J(q, gvjs_8c, a.Ga(p)),
                columns: [],
                Ja: gvjs_K(q, gvjs_Ru, !1),
                baseline: gvjs_K(q, gvjs_Ru, y),
                margin: gvjs_Oj(q, gvjs_Ev),
                sk: u,
                range: null,
                options: q,
                format: x,
                style: {
                    label: t.pb([gvjs_8c, gvjs_m], r),
                    ticks: t.pb([gvjs_ex, gvjs_m], r),
                    E8: t.pb(["contextTicks", gvjs_m], r),
                    Ja: t.pb(gvjs_Ru),
                    baseline: t.pb(gvjs_Xo)
                }
            }
        }
        l[n].columns.push(p);
        m = !1
    });
    return l
}
function gvjs_Via(a, b, c, d) {
    var e = []
      , f = {}
      , g = {}
      , h = 0
      , k = d === gvjs_U;
    gvjs_u(b.Sm, function(n) {
        var p = [];
        e.push(p);
        n.C.forEach(function(q, r) {
            q = a.W(q.Bs);
            var t = gvjs_K(c, gvjs_Qw + r + ".discrete", !1);
            t = gvjs_ES(t, q);
            t.nia && (q = "_discrete");
            r = c.cb(gvjs_Qw + r + ".axis");
            null == r && (q in f ? r = f[q][0] : (f[q] = [],
            r = h++),
            f[q].push(r));
            p.push(r);
            gvjs_Ty(g, String(r), t)
        })
    });
    var l = {}
      , m = !0;
    e.forEach(function(n, p) {
        gvjs_u(n, function(q, r) {
            r = b.Sm[p].C[r].Bs;
            if (!(q in l)) {
                var t = k ? "x" : "y"
                  , u = c.pb([gvjs_QQ]);
                t = c.view(["axes.target." + q, "axes." + t + "." + q, "axes.target.all", "axes." + t + ".all", "axes.all"]);
                var v = t.view(gvjs_Jd)
                  , w = gvjs_J(t, "side", k ? gvjs_vt : m ? gvjs_$c : gvjs_j, k ? gvjs_2R : gvjs_1R)
                  , x = new g[q]
                  , y = t.fa(gvjs_Xo)
                  , z = !1;
                null != y && (z = !0,
                typeof y === gvjs_g ? x.Pw(y) : x.Zt(y));
                y = a.W(r);
                var A = t.pb(gvjs_Fu);
                gvjs_Py(A) && y === gvjs_g && (A = {
                    pattern: gvjs_Gd
                });
                l[q] = {
                    name: q,
                    columns: [],
                    label: gvjs_J(t, gvjs_8c),
                    Ja: gvjs_K(t, gvjs_Ru, !0),
                    baseline: gvjs_K(t, gvjs_Ru, z),
                    scale: x,
                    type: y,
                    margin: gvjs_Oj(t, gvjs_Ev),
                    sk: w,
                    range: null,
                    options: t,
                    format: A,
                    style: {
                        label: v.pb([gvjs_8c, gvjs_m], u),
                        ticks: v.pb([gvjs_ex, gvjs_m], u),
                        E8: v.pb(["contextTicks", gvjs_m], u),
                        Ja: v.pb(gvjs_Ru),
                        baseline: v.pb(gvjs_Xo)
                    }
                }
            }
            l[q].columns.push(r);
            m = !1
        })
    });
    return l
}
gvjs_DS.prototype.$g = function() {
    var a = this.Ta
      , b = this.jO
      , c = this.options
      , d = gvjs_K(c, gvjs_2u, !1)
      , e = c.cD(gvjs_2t);
    null != e && (e = gvjs_v(gvjs_v(e, function(l) {
        try {
            return gvjs_qj(l).hex
        } catch (m) {
            return null
        }
    }).filter(function(l) {
        return null != l
    }), gvjs_vj));
    d = new gvjs__R(d,null != e ? e : null);
    e = this.vi();
    var f = gvjs_Uia(a, b, c, e);
    b = gvjs_Via(a, b, c, e);
    c = this.hZ(f, b, d);
    for (var g in f) {
        var h = f[g];
        null == h.range ? h.range = new gvjs_O(0,1) : h.range.start === h.range.end && (--h.range.start,
        h.range.end += 1)
    }
    for (var k in b)
        h = b[k],
        null == h.range ? h.range = new gvjs_O(0,1) : h.range.start === h.range.end && (--h.range.start,
        h.range.end += 1);
    return {
        table: a,
        title: gvjs_J(this.options, "chart.title"),
        subtitle: gvjs_J(this.options, "chart.subtitle"),
        orientation: e,
        NH: f,
        FL: b,
        options: this.options,
        rK: d,
        size: this.xla,
        layout: c,
        style: {
            title: this.options.pb(["chart.style.title", gvjs_QQ]),
            subtitle: this.options.pb(["chart.style.subtitle", gvjs_QQ]),
            titlePadding: gvjs_Oj(this.options, "chart.style.titleSpacing"),
            subtitlePadding: gvjs_Oj(this.options, "chart.style.subtitleSpacing"),
            background: gvjs_vR(this.options.pb("chart.style.background")),
            O: gvjs_vR(this.options.pb("chart.style.chartArea")),
            legend: {
                container: gvjs_vR(this.options.pb("legend.style.container")),
                spacing: gvjs_Oj(this.options, "legend.style.spacing", 0),
                icon: gvjs_vR(this.options.pb("legend.style.icon")),
                title: gvjs_vR(this.options.pb(["legend.style.title", gvjs_SQ, gvjs_QQ])),
                subtitle: gvjs_vR(this.options.pb(["legend.style.subtitle", gvjs_SQ, gvjs_QQ])),
                selected: {
                    icon: gvjs_vR(this.options.pb("legend.style.selected.icon")),
                    title: gvjs_vR(this.options.pb("legend.style.selected.title")),
                    subtitle: gvjs_vR(this.options.pb("legend.style.selected.subtitle"))
                },
                focused: {
                    icon: gvjs_vR(this.options.pb("legend.style.focused.icon")),
                    title: gvjs_vR(this.options.pb("legend.style.focused.title")),
                    subtitle: gvjs_vR(this.options.pb("legend.style.focused.subtitle"))
                }
            }
        }
    }
}
;
var gvjs_FS = {
    selectionMode: gvjs_Ww,
    groupSize: .65,
    collapseGaps: !0,
    blendingMode: "rgb",
    orientation: gvjs_S,
    stacked: !1,
    chart: {
        style: {
            titleSpacing: 36,
            subtitleSpacing: 4,
            background: {
                fillColor: gvjs_Ox,
                stroke: gvjs_rt,
                "stroke.width": 0
            },
            chartArea: {
                fillColor: gvjs_f
            },
            title: {
                fontSize: 16,
                fillColor: gvjs_6R[gvjs_Tr]
            },
            subtitle: {
                fontSize: 14,
                fillColor: gvjs_6R[gvjs_Rr]
            },
            text: {
                fontName: gvjs_qs
            }
        }
    },
    legend: {
        style: {
            margin: 40,
            spacing: 16,
            icon: {
                rowspan: 2,
                "corners.rx": 2,
                "corners.ry": 2,
                width: 20,
                height: 12,
                "margin.right": 8
            },
            title: {
                fillColor: gvjs_6R[gvjs_Tr]
            },
            subtitle: {
                fillColor: gvjs_6R[gvjs_Rr],
                "padding.top": 4,
                "max-lines": 1
            },
            selected: {
                title: {
                    fontWeight: 500,
                    fillColor: gvjs_6R[gvjs_Vr]
                },
                subtitle: {
                    fontWeight: 500,
                    fillColor: gvjs_6R[gvjs_Tr]
                }
            }
        }
    },
    axes: {
        all: {
            margin: 6,
            style: {
                baseline: {
                    strokeColor: gvjs_6R[gvjs_Sr],
                    strokeWidth: 1
                },
                contextTicks: {
                    fillColor: gvjs_6R[gvjs_Vr]
                },
                gridlines: {
                    strokeColor: gvjs_6R["300"],
                    strokeWidth: 1
                },
                label: {
                    fillColor: gvjs_6R[gvjs_Vr]
                },
                text: {
                    fontSize: 12
                },
                ticks: {
                    fillColor: gvjs_6R[gvjs_Tr]
                }
            }
        },
        domain: {
            all: {
                gridlines: !1
            }
        },
        target: {
            all: {
                gridlines: !0
            }
        },
        x: {
            all: {
                ticks: {
                    pixelsPerTick: 100
                }
            }
        },
        y: {
            all: {
                ticks: {
                    pixelsPerTick: 40
                }
            }
        }
    }
};
function gvjs_GS(a, b) {
    gvjs_OR.call(this);
    this.q8 = !0;
    this.Rv = new Set;
    this.hp = new Set;
    this.definition = a;
    this.Eh = {};
    this.HT = {};
    this.Hi = b;
    this.HB = gvjs_J(this.definition.options, "blendingMode", "rgb");
    this.dQ = gvjs_ny(this.definition.options, "hoverDarkenAmount", .15);
    this.nfa = gvjs_ny(this.definition.options, "selectLightenAmount", .7)
}
gvjs_t(gvjs_GS, gvjs_OR);
function gvjs_HS(a, b, c) {
    a = gvjs_vj(a);
    "hsl" === c ? (c = gvjs_7Q(a[0], a[1], a[2]),
    c[2] = Math.max(c[2] - b, 0),
    a = gvjs__z(c[0], c[1], c[2])) : a = gvjs_1z(a, b);
    return gvjs_uj(a)
}
function gvjs_IS(a, b, c) {
    a = gvjs_vj(a);
    "hsl" === c ? (c = gvjs_7Q(a[0], a[1], a[2]),
    c[2] = Math.min(c[2] + b, 1),
    a = gvjs__z(c[0], c[1], c[2])) : a = gvjs_2z(a, b);
    return gvjs_uj(a)
}
gvjs_ = gvjs_GS.prototype;
gvjs_.cache = function(a, b, c) {
    a = a in this.Eh ? this.Eh[a] : this.Eh[a] = {
        dirty: !0,
        value: null
    };
    a.dirty && (a.dirty = !1,
    Date.now(),
    a.value = c ? b.call(c) : b());
    return a.value
}
;
gvjs_.dirty = function(a) {
    a in this.Eh && (this.Eh[a].dirty = !0)
}
;
function gvjs_JS(a, b, c) {
    var d = a.definition.orientation === gvjs_U;
    c = a.definition.FL[c];
    a = a.definition.NH[b];
    return {
        Qv: d ? c : a,
        vertical: d ? a : c
    }
}
function gvjs_KS(a) {
    return a.definition.orientation === gvjs_U ? a.definition.FL : a.definition.NH
}
function gvjs_LS(a) {
    return a.definition.orientation === gvjs_U ? a.definition.NH : a.definition.FL
}
function gvjs_MS(a) {
    switch (a.type()) {
    case gvjs_HQ:
        return gvjs_wR(a.rb.COLUMN_INDEX, a.rb.ROW_INDEX);
    case gvjs_IQ:
        return gvjs_xR(a.rb.COLUMN_INDEX)
    }
    return null
}
gvjs_.CT = function() {}
;
gvjs_.tT = function() {}
;
gvjs_.pT = function() {}
;
gvjs_.zT = function() {}
;
gvjs_.Hfa = function() {}
;
gvjs_.Cfa = function() {}
;
gvjs_.Afa = function() {}
;
gvjs_.Ffa = function() {}
;
function gvjs_NS(a, b, c) {
    var d = c.type();
    if (d === gvjs_HQ) {
        d = gvjs_MS(c);
        c = d.ie();
        d = gvjs_xR(d.rb.COLUMN_INDEX).ie();
        var e = 0 < a.hp.size
          , f = a.Rv.has(c) || a.Rv.has(d);
        a.hp.has(c) || a.hp.has(d) ? a.CT(b) : f ? a.tT(b) : e ? a.pT(b) : a.zT(b)
    } else
        d === gvjs_IQ && (d = gvjs_MS(c),
        c = d.ie(),
        d = gvjs_xR(d.rb.COLUMN_INDEX).ie(),
        e = 0 < a.hp.size,
        f = a.Rv.has(c) || a.Rv.has(d),
        a.hp.has(c) || a.hp.has(d) ? a.Hfa(b) : f ? a.Cfa(b) : e ? a.Afa(b) : a.Ffa(b))
}
function gvjs_Wia(a) {
    gvjs_w(a.HT, function(b, c) {
        c = gvjs_LL(c);
        gvjs_NS(this, b, c)
    }, a)
}
function gvjs_Xia(a, b) {
    b = gvjs_xR(b);
    var c = b.ie();
    gvjs_OS(a, b).forEach(function(d) {
        var e = d.id.rb.SUBTYPE;
        switch (e) {
        case gvjs_fx:
        case gvjs_ZQ:
            break;
        default:
            return
        }
        var f = this.definition.style.legend
          , g = e === gvjs_fx ? f.title : f.subtitle
          , h = e === gvjs_fx ? f.selected.title : f.selected.subtitle
          , k = e === gvjs_fx ? f.focused.title : f.focused.subtitle
          , l = this.hp.has(c)
          , m = this.Rv.has(c)
          , n = new Set(gvjs_Ye(g))
          , p = new Set(gvjs_Ye(h))
          , q = new Set(gvjs_Ye(k));
        e = new Set([].concat(gvjs_9d(n), gvjs_9d(p), gvjs_9d(q)));
        var r = d.shape;
        e.forEach(function(t) {
            try {
                var u = q.has(t)
                  , v = p.has(t);
                if (m && u)
                    r.style(t, k[t]);
                else if (l && v)
                    r.style(t, h[t]);
                else if (u || v)
                    n.has(t) ? r.style(t, g[t]) : r.style(t, null)
            } catch (w) {}
        })
    }, a)
}
gvjs_.a3 = function(a, b) {
    this.ex || (this.ex = gvjs_ER(gvjs_ER(new gvjs_zS, new gvjs_AS(this.definition.NH,this.definition.FL)), new gvjs_GR(gvjs_ER(new gvjs_BS(1), new gvjs_tS({
        x: new gvjs_UR,
        y: new gvjs_UR,
        hoa: this.definition.orientation === gvjs_U
    })))));
    return this.cache("chart-shapes", gvjs_s(function() {
        var c = this.ex.transform(this.definition.layout.rI());
        gvjs_u(c, function(d) {
            this.q8 && d.style("clip.x", b.left).style("clip.y", b.top).style("clip.width", b.width).style("clip.height", b.height);
            gvjs_NS(this, d, d.data().id)
        }, this);
        return gvjs_v(c, function(d) {
            var e = d.data().id;
            var f = gvjs_MS(d.data().id).ie();
            f = this.hp.has(f) || this.Rv.has(f) ? gvjs_YQ : gvjs_Cw;
            return new gvjs_NR(d,e,f)
        }, this)
    }, this))
}
;
function gvjs_PS(a, b, c) {
    var d = a.scale;
    var e = a.type;
    return (d = d && d.isDiscrete() ? gvjs_vS : gvjs_yS[e]) && new d({
        expand: a.expand,
        e9: a.e9,
        format: a.format,
        scale: a.scale,
        size: b,
        Gc: a.range.start,
        xe: a.range.end,
        uK: c
    })
}
function gvjs_QS(a, b) {
    return {
        ticks: a.ticks,
        scale: a.QB,
        label: a.label,
        sk: a.sk,
        range: a.range,
        layer: gvjs_RQ,
        Bga: gvjs_vR(a.style.ticks),
        Sla: gvjs_vR(a.style.E8),
        Xba: gvjs_vR(a.style.label),
        J7: b
    }
}
function gvjs_OS(a, b) {
    var c = []
      , d = gvjs_Dia(b);
    gvjs_w(a.HT, function(e, f) {
        f = gvjs_LL(f);
        gvjs_Ve(d, function(g, h) {
            return f.rb[h] === g
        }) && c.push({
            id: f,
            shape: e
        })
    });
    return c
}
function gvjs_RS(a, b, c, d) {
    var e = []
      , f = c;
    c = c.clone();
    var g = 0
      , h = 0;
    gvjs_w(gvjs_KS(a), function(k) {
        var l = k.name
          , m = k.margin
          , n = k.ticks;
        n && n.size == f.right - f.left || (n = gvjs_JS(this, l, l).Qv,
        n = null != n ? gvjs_PS(n, f.right - f.left, gvjs_Oj(n.options, gvjs__Q)) : void 0,
        n = k.ticks = n);
        if (n) {
            gvjs_5Q(k.range, n.Gc);
            gvjs_5Q(k.range, n.xe);
            gvjs_SS(k);
            if (k.sk == gvjs_vx && 0 < g || k.sk == gvjs_vt && 0 < h)
                m = 12;
            n = new gvjs_VR({
                start: k.range.start,
                end: k.range.end
            });
            n.Zt(k.scale.Fo());
            k.QB = n;
            k.p3 = new gvjs_VR({
                start: 0,
                end: 1
            },{
                start: f.left + d.left,
                end: f.right - d.right
            });
            n = k.sk == gvjs_vx ? f.top - g - m : f.bottom + h + m;
            var p = gvjs_JS(this, l, l).Qv;
            if (null == p)
                throw Error('Could not construct axis renderer for horizontal axis named "' + l + gvjs_GQ);
            l = (new gvjs_3R(gvjs_QS(p, gvjs_KL(new gvjs_IL("haxis"), "LAYER", l)))).R(b, new gvjs_5(f.left + d.left,n,f.right - f.left - d.left - d.right,0));
            gvjs_5x(c, gvjs_oz(l.size));
            k.sk === gvjs_vx ? g += l.size.height + m : h += l.size.height + m;
            gvjs_Me(e, l.elements)
        }
    }, a);
    return {
        box: c,
        elements: e
    }
}
function gvjs_TS(a, b, c, d) {
    var e = a.definition.orientation === gvjs_U
      , f = []
      , g = c;
    c = c.clone();
    var h = 0
      , k = 0;
    gvjs_w(gvjs_LS(a), function(l) {
        var m = l.name
          , n = l.ticks
          , p = l.margin;
        n && n.size == g.bottom - g.top || (n = gvjs_JS(this, m, m).vertical,
        n = null != n ? gvjs_PS(n, c.bottom - c.top, gvjs_Oj(n.options, gvjs__Q)) : void 0,
        n = l.ticks = n);
        if (n) {
            gvjs_5Q(l.range, n.Gc);
            gvjs_5Q(l.range, n.xe);
            gvjs_SS(l);
            if (l.sk == gvjs_$c && 0 < h || l.sk == gvjs_j && 0 < k)
                p = 12;
            n = new gvjs_VR({
                start: e ? l.range.start : l.range.end,
                end: e ? l.range.end : l.range.start
            });
            n.Zt(l.scale.Fo());
            l.QB = n;
            l.p3 = new gvjs_VR({
                start: 0,
                end: 1
            },{
                start: g.top + d.top,
                end: g.bottom - d.bottom
            });
            n = l.sk == gvjs_$c ? g.left - h - p : g.right + k + p;
            var q = gvjs_JS(this, m, m).vertical;
            if (null == q)
                throw Error('Could not construct axis renderer for vertical axis named "' + m + gvjs_GQ);
            m = (new gvjs_5R(gvjs_QS(q, gvjs_KL(new gvjs_IL("vaxis"), "LAYER", m)))).R(b, new gvjs_5(n,g.top + d.top,0,g.bottom - g.top - d.top - d.bottom));
            gvjs_5x(c, gvjs_oz(m.size));
            l.sk == gvjs_$c ? h += m.size.width + p : k += m.size.width + p;
            gvjs_Me(f, m.elements)
        }
    }, a);
    return {
        box: c,
        elements: f
    }
}
function gvjs_US(a) {
    var b = new gvjs_5(0,0,0,0);
    b.left = Math.min(a.left, a.right);
    b.top = Math.min(a.top, a.bottom);
    b.width = Math.abs(a.right - a.left);
    b.height = Math.abs(a.bottom - a.top);
    return b
}
gvjs_.PK = function(a, b, c) {
    var d = [];
    gvjs_w(gvjs_LS(this), function(e) {
        if (e.Ja) {
            var f = gvjs_oz(b);
            f.top += c.top;
            f.bottom -= c.bottom;
            e = new gvjs_9R({
                ticks: e.ticks,
                scale: e.QB,
                Ja: e.Ja,
                baseline: e.baseline,
                hW: gvjs_KL(gvjs_KL(new gvjs_IL(gvjs_3r), gvjs_rs, "hgridline"), gvjs_5a, e.name),
                layer: gvjs_Pu,
                style: {
                    Ja: e.style.Ja,
                    baseline: e.style.baseline
                }
            });
            gvjs_Me(d, e.R(a, gvjs_pz(f)))
        }
    }, this);
    gvjs_w(gvjs_KS(this), function(e) {
        var f = gvjs_oz(b);
        f.left += c.left;
        f.right -= c.right;
        e = new gvjs_$R({
            ticks: e.ticks,
            scale: e.QB,
            Ja: e.Ja,
            baseline: e.baseline,
            hW: gvjs_KL(gvjs_KL(new gvjs_IL(gvjs_3r), gvjs_rs, "vgridline"), gvjs_5a, e.name),
            layer: gvjs_Pu,
            style: {
                Ja: e.style.Ja,
                baseline: e.style.baseline
            }
        });
        gvjs_Me(d, e.R(a, gvjs_pz(f)))
    }, this);
    return d
}
;
function gvjs_Yia(a, b, c, d) {
    function e(q) {
        q.left < c.left && (l.left += c.left - q.left);
        q.top < c.top && (l.top += c.top - q.top);
        q.right > c.left + c.width && (l.right -= q.right - (c.left + c.width));
        q.bottom > c.top + c.height && (l.bottom -= q.bottom - (c.top + c.height))
    }
    for (var f = null, g = 10, h = null, k = null, l = gvjs_oz(c), m = gvjs_US(l), n = 0, p = 0; !gvjs_nz(m, f) && 0 < --g; )
        f = m,
        n++,
        p++,
        h = gvjs_RS(a, b, l, d),
        e(h.box),
        k = gvjs_TS(a, b, l, d),
        e(k.box),
        m = gvjs_US(l);
    return {
        rect: m,
        elements: h.elements.concat(k.elements)
    }
}
function gvjs_SS(a) {
    var b = a.options.fa("range.min");
    if (null != b) {
        var c = typeof b === gvjs_g;
        b = c ? b : a.scale.scale(b);
        !c && a.scale.isDiscrete() && (b -= .5);
        null != b && isFinite(b) && (a.range.start = b)
    }
    b = a.options.fa("range.max");
    null != b && (b = (c = typeof b === gvjs_g) ? b : a.scale.scale(b),
    !c && a.scale.isDiscrete() && (b += .5),
    null != b && isFinite(b) && (a.range.end = b));
    a.range.start > a.range.end && (c = a.range.start,
    a.range.start = a.range.end,
    a.range.end = c)
}
function gvjs_Zia(a) {
    if (gvjs_J(a.definition.options, gvjs_uv) == gvjs_f)
        return null;
    var b = new gvjs_sS({
        maxWidth: null,
        style: {
            container: a.definition.style.legend.container,
            spacing: a.definition.style.legend.spacing,
            icon: a.definition.style.legend.icon,
            title: a.definition.style.legend.title,
            subtitle: a.definition.style.legend.subtitle
        }
    })
      , c = a.definition.layout.Ry()
      , d = c.map(function(e, f) {
        return {
            index: f,
            column: e.column
        }
    });
    d.sort(function(e, f) {
        return gvjs_Re(e.column, f.column)
    });
    return b.define(gvjs_De(d.map(function(e, f) {
        e = c[e.index];
        var g = this.definition.table.Ga(e.column);
        this.definition.table.Ga(e.column);
        return gvjs_K(this.definition.options, gvjs_Qw + f + ".inLegend", !0) ? {
            color: e.color,
            title: gvjs_J(this.definition.options, gvjs_Qw + f + ".title", g),
            subtitle: gvjs_J(this.definition.options, gvjs_Qw + f + ".subtitle"),
            xra: gvjs_xR(e.column, "icon").ie(),
            eya: gvjs_xR(e.column, gvjs_fx).ie(),
            Exa: gvjs_xR(e.column, gvjs_ZQ).ie()
        } : null
    }, a), gvjs_6Q(function(e) {
        return null === e
    }), a)).setStyle(gvjs_Sd, gvjs_rv)
}
gvjs_.AB = function(a) {
    Date.now();
    var b = a.Oa().cp();
    this.F = b;
    var c = this.Tb()
      , d = this.cache("chart-layout", function() {
        var f = c;
        null == f && (f = new gvjs_A(Infinity,Infinity));
        var g = gvjs_cS(gvjs_cS(new gvjs_dS(1,5), this.definition.style.background), {
            width: f.width,
            height: f.height,
            id: (new gvjs_IL(gvjs_3r)).ie(),
            layer: gvjs_Wo
        })
          , h = this.definition.title ? gvjs_cS(new gvjs_hS(this.definition.title), this.definition.style.title).setStyle(gvjs_5c, (new gvjs_IL(gvjs_fx)).ie()).setStyle("layer", gvjs_Wo) : null
          , k = this.definition.subtitle ? gvjs_cS(new gvjs_hS(this.definition.subtitle), this.definition.style.subtitle).setStyle(gvjs_5c, gvjs_KL(new gvjs_IL(gvjs_fx), gvjs_rs, gvjs_ZQ).ie()).setStyle("layer", gvjs_Wo) : null;
        h && g.Wb(0, 0, h);
        k && g.Wb(0, 2, k);
        h && k && g.Wb(0, 1, (new gvjs_bS).setStyle(gvjs_4c, this.definition.style.subtitlePadding));
        (h || k) && g.Wb(0, 3, (new gvjs_bS).setStyle(gvjs_4c, this.definition.style.titlePadding));
        h = gvjs_cS(new gvjs_bS, this.definition.style.O).setStyle(gvjs_Sd, gvjs_Bb).setStyle(gvjs_4c, Infinity).setStyle(gvjs_Xd, Infinity);
        if (k = gvjs_Zia(this)) {
            k.setStyle(gvjs_Hv, f.width / 3);
            f = gvjs_Oj(this.definition.options, "legend.style.margin", 0);
            var l = gvjs_J(this.definition.options, gvjs_uv)
              , m = l === gvjs_$c ? 0 : 2;
            l = l === gvjs_$c ? 2 : 0;
            g.Wb(0, 4, (new gvjs_dS(3,1)).setStyle(gvjs_4c, Infinity).Wb(1, 0, (new gvjs_bS).setStyle(gvjs_Xd, f)).Wb(m, 0, k).Wb(l, 0, h))
        } else
            g.Wb(0, 4, h);
        return g.layout(b.me, {})
    }, this)
      , e = this.definition.orientation === gvjs_U ? new gvjs_B(0,0,12,0) : new gvjs_B(0,12,0,12);
    a = [];
    gvjs_Me(a, this.cache("chart-chrome", function() {
        var f = this
          , g = []
          , h = null
          , k = null
          , l = 0
          , m = null
          , n = new gvjs_rS([function(v, w) {
            var x = v.element();
            if (x.getStyle(gvjs_Sd) === gvjs_Bb) {
                var y = v.pw;
                x = y.margin;
                var z = y.padding;
                y = w.x + v.left() + x.left() + z.left();
                w = w.y + v.top() + x.top() + z.top();
                var A = v.width() - x.width() - z.width();
                v = v.height() - x.height() - z.height();
                v = new gvjs_5(y,w,A,v);
                x = gvjs_Yia(f, b, v, e);
                x.rect.top = Math.ceil(x.rect.top) + .5;
                x.rect.height = Math.floor(x.rect.height) - 1;
                x.rect.left = Math.ceil(x.rect.left) + .5;
                x.rect.width = Math.floor(x.rect.width) - 1;
                m = x.rect.clone();
                l = m.top - v.top;
                return []
            }
            return x.getStyle(gvjs_Sd) === gvjs_rv ? (h = v,
            k = w,
            []) : null
        }
        ]);
        n.debug = !1;
        var p = n.R(d);
        this.definition.O = m;
        var q = gvjs_oz(m);
        gvjs_Me(g, gvjs_RS(this, b, q, e).elements);
        gvjs_Me(g, gvjs_TS(this, b, q, e).elements);
        q = new gvjs_rS([]);
        q.debug = n.debug;
        var r = [];
        h && (r = q.R(h.element().layout(b.me, {}, new gvjs_A(h.width(),m.height)), gvjs_ez(k, new gvjs_z(h.left(),l))));
        var t = 0
          , u = 0;
        gvjs_Pz(gvjs_Rz(gvjs_Oz(p), gvjs_Oz(r)), function(v) {
            var w = v.style(gvjs_5c)
              , x = v.style("layer") || gvjs_Wo;
            null == w && n.debug ? g.push(new gvjs_NR(v,gvjs_KL(new gvjs_IL("debug"), gvjs_KQ, t++),gvjs_Wo)) : null != w && g.push(new gvjs_NR(v,gvjs_KL(gvjs_LL(w), gvjs_KQ, u++),x))
        });
        g.push(new gvjs_NR((new gvjs_4Q(m.left,m.top,m.width,m.height)).styles(this.definition.style.O),gvjs_KL(new gvjs_IL(gvjs_3r), gvjs_rs, gvjs_Mt),gvjs_Wo));
        return g
    }, this));
    gvjs_Me(a, this.cache("chart-gridlines", function() {
        return this.PK(b, this.definition.O, e)
    }, this));
    gvjs_Me(a, this.a3(b, this.definition.O));
    this.HT = {};
    a.forEach(function(f) {
        this.HT[f.featureId.ie()] = f.Hl
    }, this);
    this.xa && a.push(this.cache(gvjs_0Q, function() {
        var f = (new gvjs_rS([])).R(this.xa.layout, this.xa.offset)
          , g = new gvjs_zR;
        f.forEach(function(h) {
            g.add(h)
        });
        return new gvjs_NR(g,new gvjs_IL(gvjs_NQ),gvjs_Pd)
    }, this));
    return a
}
;
gvjs_.bz = function(a, b) {
    this.dirty(gvjs_0Q);
    if (b && !this.xa && a.type() === gvjs_HQ) {
        Date.now();
        var c = a.rb.DOMAIN_INDEX
          , d = a.rb.COLUMN_INDEX
          , e = a.rb.ROW_INDEX
          , f = this.definition.table.Ga(d);
        b = gvjs_OS(this, a)[0].shape;
        var g = b.data().value;
        a = this.definition.orientation === gvjs_U;
        var h = this.definition.NH[g.BO];
        h = h.ticks.gd || gvjs_8R(h.type, h.format);
        c = this.definition.table.Ha(e, c, h);
        h = this.definition.FL[g.GL];
        h = h.ticks.gd || gvjs_8R(h.type, h.format);
        d = this.definition.table.Ha(e, d, h);
        f = (new gvjs_iS).define(c, [{
            title: f,
            value: d,
            color: gvjs_HS(g.color, this.dQ, this.HB)
        }]).layout(this.F.me, {});
        d = f.width();
        e = f.height();
        c = new gvjs_A(f.width(),f.height());
        g = this.definition.O;
        var k = gvjs_xq(b);
        h = b instanceof gvjs_4Q ? new gvjs_5((0 > gvjs_L(k, gvjs_Xd) ? gvjs_L(k, gvjs_Xd) : 0) + gvjs_L(k, "x") - 10,(0 > gvjs_L(k, gvjs_4c) ? gvjs_L(k, gvjs_4c) : 0) + gvjs_L(k, "y") - 10,Math.abs(gvjs_L(k, gvjs_Xd)) + 20,Math.abs(gvjs_L(k, gvjs_4c)) + 20) : new gvjs_5(gvjs_L(k, "x") - gvjs_L(k, "r") - 10,gvjs_L(k, "y") - gvjs_L(k, "r") - 10,2 * gvjs_L(k, "r") + 20,2 * gvjs_L(k, "r") + 20);
        b instanceof gvjs_4Q ? (b = a ? gvjs_$y(gvjs_L(k, gvjs_Xd)) : 0,
        a = a ? 0 : gvjs_$y(gvjs_L(k, gvjs_4c))) : a = b = 0;
        a = (new gvjs_mS(g,h,c,new gvjs_z(b,a))).position();
        this.xa = {
            layout: f,
            offset: new gvjs_z(gvjs_0g(a.x, g.left, g.left + g.width - d),gvjs_0g(a.y, g.top, g.top + g.height - e))
        }
    } else
        b || (this.xa = null)
}
;
gvjs_.Tb = function() {
    return this.definition.size
}
;
gvjs_.nm = function(a, b, c) {
    if (a)
        if (b.type === gvjs_Pd)
            this.bz(a, c);
        else {
            var d = this.hp.size;
            b = b.type === gvjs_k ? this.hp : this.Rv;
            var e = a.type();
            switch (e) {
            case gvjs_IQ:
            case gvjs_HQ:
                var f = gvjs_MS(a);
                c ? b.add(f.ie()) : b.delete(f.ie());
                break;
            case gvjs_3r:
            case gvjs_NQ:
                this.Rv.clear()
            }
            if (this.hp.size !== d || e === gvjs_IQ)
                Date.now(),
                gvjs_Wia(this);
            e === gvjs_IQ ? gvjs_Xia(this, a.rb.COLUMN_INDEX) : f && e === gvjs_HQ && (a = gvjs_OS(this, f)) && a.forEach(function(g) {
                gvjs_NS(this, g.shape, f)
            }, this)
        }
}
;
function gvjs_VS(a) {
    if (null != a)
        try {
            a = gvjs_qj(a).hex
        } catch (b) {}
    return a
}
function gvjs_WS(a, b) {
    return {
        fillColor: gvjs_VS(a.cb(gvjs_8Q(b, gvjs_1))),
        opacity: a.bD(gvjs_8Q(b, gvjs_Kp)),
        fontName: a.cb(gvjs_8Q(b, gvjs_yp)),
        fontSize: a.Aa(gvjs_8Q(b, gvjs_zp)),
        fontWeight: a.Dq(gvjs_8Q(b, gvjs_st)) ? gvjs_st : null,
        italic: a.Dq(gvjs_8Q(b, gvjs_Gp)),
        underline: a.Dq(gvjs_8Q(b, gvjs_bq))
    }
}
function gvjs_XS(a, b, c) {
    a = gvjs_qy(a, b, c);
    return {
        fillColor: gvjs_VS(a.fill),
        fillOpacity: a.fillOpacity,
        strokeColor: gvjs_VS(a.Uj()),
        strokeWidth: a.strokeWidth,
        strokeOpacity: a.strokeOpacity
    }
}
function gvjs_YS(a, b) {
    return {
        axis: a.cb(gvjs_8Q(b, gvjs_$w)),
        title: a.cb(gvjs_8Q(b, gvjs_nv)),
        inLegend: a.Dq(gvjs_8Q(b, gvjs_Nx))
    }
}
function gvjs__ia(a) {
    return (a = a.cb(gvjs_sv, gvjs_Fia)) ? a === gvjs_2 ? 0 : a === gvjs_0 ? .5 : 1 : null
}
function gvjs_ZS(a, b) {
    var c = a.Aa(gvjs_8Q(b, gvjs_Tu));
    c = {
        baseline: a.fa(gvjs_8Q(b, gvjs_Xo)),
        discrete: a.cb(gvjs_8Q(b, gvjs_Sd)) !== gvjs_Vd,
        label: a.cb(gvjs_8Q(b, gvjs_fx)),
        gridlines: null != c ? 0 !== c : null,
        range: {
            min: a.fa(gvjs_8Q(b, gvjs_Kx)),
            max: a.fa(gvjs_8Q(b, gvjs_Jx))
        },
        format: {},
        style: {
            gridlines: {
                strokeColor: gvjs_VS(a.cb(gvjs_8Q(b, gvjs_Su)))
            },
            baseline: {
                strokeColor: gvjs_VS(a.cb(gvjs_8Q(b, gvjs_mt)))
            },
            label: gvjs_WS(a, gvjs_8Q(b, gvjs_ix)),
            ticks: gvjs_WS(a, gvjs_8Q(b, gvjs_bx)),
            text: gvjs_WS(a, gvjs_8Q(b, gvjs_bx))
        }
    };
    var d = a.cb(gvjs_8Q(b, gvjs_Fu));
    a = a.pb(gvjs_8Q(b, "formatOptions"));
    null != d && (a.pattern = d);
    c.format = a;
    return c
}
function gvjs__S(a) {
    if (!a)
        return {};
    var b = new gvjs_Aj([a]);
    a = gvjs_8z(gvjs_Ox, 1);
    return gvjs_mj(gvjs_jq(b), {
        width: b.Aa(gvjs_Xd),
        height: b.Aa(gvjs_4c),
        stacked: b.Dq(gvjs_jv),
        selectionMode: b.cb(gvjs_Kw, gvjs_lC),
        groupSize: b.Mg(gvjs_jt, 1),
        chart: {
            title: b.cb(gvjs_fx),
            subtitle: b.cb(gvjs_ZQ),
            style: {
                background: gvjs_XS(b, gvjs_ht, a),
                chartArea: gvjs_XS(b, gvjs_Nt, a),
                text: {
                    fontName: b.cb(gvjs_yp),
                    fontSize: b.Aa(gvjs_zp)
                },
                title: gvjs_WS(b, gvjs_ix)
            }
        },
        legend: {
            position: b.cb(gvjs_uv),
            style: {
                container: {
                    valign: gvjs__ia(b)
                },
                text: gvjs_WS(b, gvjs_vv),
                title: {
                    "max-lines": b.Aa(gvjs_tv)
                }
            }
        },
        axes: {
            all: {
                style: {
                    gridlines: {
                        strokeColor: gvjs_VS(b.cb(gvjs_Qu))
                    },
                    baseline: {
                        strokeColor: gvjs_VS(b.cb(gvjs_mt))
                    }
                }
            },
            domain: gvjs_mj(gvjs_Ny(b.pb("domainAxes"), function(c, d) {
                return gvjs_ZS(b, "domainAxes." + d)
            }), {
                all: gvjs_ZS(b, gvjs_Pb)
            }),
            target: gvjs_mj(gvjs_Ny(b.pb("targetAxes"), function(c, d) {
                return gvjs_ZS(b, "targetAxes." + d)
            }), {
                all: gvjs_ZS(b, gvjs_Md)
            }),
            x: gvjs_mj(gvjs_Ny(b.pb("hAxes"), function(c, d) {
                return gvjs_ZS(b, "hAxes." + d)
            }), {
                all: gvjs_ZS(b, gvjs_Xu)
            }),
            y: gvjs_mj(gvjs_Ny(b.pb(gvjs_Hx), function(c, d) {
                return gvjs_ZS(b, "vAxes." + d)
            }), {
                all: gvjs_ZS(b, gvjs_Ud)
            })
        },
        series: gvjs_mj(gvjs_Ny(b.pb(gvjs_Mw), function(c, d) {
            return gvjs_YS(b, gvjs_Qw + d)
        }), {
            all: gvjs_YS(b, "")
        })
    })
}
;function gvjs_0S() {
    this.Ioa = gvjs_Tz(this.Joa.bind(this));
    this.format = this.Moa.bind(this)
}
gvjs_0S.prototype.Moa = function(a, b) {
    return this.Ioa(a).Ob(b)
}
;
gvjs_0S.prototype.Joa = function(a) {
    return new gvjs_Tj({
        pattern: a,
        valueType: "time"
    })
}
;
function gvjs_1S(a, b, c, d, e, f, g) {
    this.ga = a;
    this.Gc = b;
    this.xe = c;
    this.Fz = e;
    this.Qva = f;
    this.Qm = !0;
    this.xg = [];
    this.J4 = d;
    this.xp = null;
    this.PC = 0;
    this.poa = g || null;
    a = gvjs_s(this.ria, this);
    b = Dygraph.pickDateTickGranularity(this.Gc, this.xe, this.ga, a);
    this.sm = Dygraph.getDateAxis(this.Gc, this.xe, b, a);
    0 == this.sm.length && (this.sm = [{
        v: this.Gc,
        label: ""
    }],
    this.xg = [{
        label: ""
    }]);
    this.sm[0].v.valueOf() > this.Gc && (this.sm.unshift({
        v: this.Gc,
        label: ""
    }),
    this.xg.unshift(new gvjs_0R("",{})));
    this.Gc = Math.min(this.sm[0].v.valueOf(), this.Gc);
    a = this.sm[this.sm.length - 1].v.valueOf();
    a > this.xe.valueOf() && (this.xe = a);
    this.W5 = this.ga / (this.xe - this.Gc);
    this.vh = [];
    a = 0;
    for (b = this.sm.length; a < b; a++)
        this.vh.push(this.scale(this.sm[a].v))
}
gvjs_1S.prototype.draw = function(a, b, c) {
    if (this.Qm) {
        if (null == this.xp)
            throw Error("startY must be set before calling draw().");
        var d = this.sm.length - 1;
        if (0 !== d) {
            var e = this.xg[0]
              , f = e.La(a)
              , g = [new gvjs_O(this.vh[0] - f / 2,this.vh[0] + f / 2)]
              , h = [];
            this.vh[0] - f / 2 < this.J4 - this.Fz && (e.textAlign = gvjs_2,
            g[0].start = this.vh[0],
            g[0].end = this.vh[0] + f);
            e = this.xg[d];
            f = e.La(a);
            var k = new gvjs_O(this.vh[d] - f / 2,this.vh[d] + f / 2);
            f / 2 + this.vh[d] - this.Qva > this.ga + this.J4 && (e.textAlign = gvjs_R,
            k.start = this.vh[d] - f,
            k.end = this.vh[d]);
            gvjs_9Q(k, g[0]) ? h.push(d) : g.push(k);
            for (e = 1; e < d; e++) {
                var l = this.xg[e];
                switch (l.textAlign) {
                case gvjs_2:
                    l = new gvjs_O(this.vh[e],this.vh[e] + l.La(a));
                    break;
                case gvjs_0:
                case null:
                    l = new gvjs_O(this.vh[e] - l.La(a) / 2,this.vh[e] + l.La(a) / 2);
                    break;
                case gvjs_R:
                    l = new gvjs_O(this.vh[e] - l.La(a),this.vh[e]);
                    break;
                default:
                    throw Error("unknown alignment in tick label.");
                }
                var m = !1;
                f = 0;
                for (k = g.length; f < k; f++)
                    if (gvjs_9Q(g[f], l)) {
                        m = !0;
                        break
                    }
                m ? h.push(e) : g.push(l)
            }
            f = 0;
            for (k = h.length; f < k; f++)
                l = this.xg[h[f]],
                l.label = ""
        }
        a = {};
        d = 0;
        for (g = this.sm.length; d < g; d++)
            if (m = this.xg[d],
            !(this.Gc > this.sm[d].v) && m.label) {
                h = b;
                e = this.vh[d];
                f = this.xp + 10;
                k = m.textAlign || gvjs_0;
                l = m.ja;
                m = m.label.split("\n");
                for (var n = [], p = 0, q = m.length; p < q; p++)
                    n.push(h(m[p], e, f, 15, k, gvjs_2, l)),
                    f += 15;
                h = n;
                e = 0;
                for (f = h.length; e < f; e++)
                    c(h[e], null, a)
            }
        this.Qm = !1
    }
}
;
gvjs_1S.prototype.scale = function(a) {
    return (a - this.Gc) * this.W5 + this.J4
}
;
gvjs_1S.prototype.ria = function(a) {
    function b(g, h) {
        return e(c.poa || g, h)
    }
    var c = this, d = !0, e = gvjs_zG(gvjs_0S).format, f;
    switch (a) {
    case "axisLabelFormatter":
        return function(g, h) {
            c.PC = h;
            if (h <= Dygraph.THIRTY_SECONDLY)
                return g = b("s", g),
                f = new gvjs_ly(gvjs_0ia),
                c.xg.push(new gvjs_0R(g,f)),
                c.xg.length - 1 + "";
            if (h <= Dygraph.THIRTY_MINUTELY) {
                var k = ":mm";
                0 === g.getMinutes() || d ? (h = !0,
                k = gvjs_Ia) : h = !1;
                d = !1;
                g = b(k, g);
                f = new gvjs_ly(gvjs_1ia);
                gvjs_jy(f, h);
                c.xg.push(new gvjs_0R(g,f));
                return c.xg.length - 1 + ""
            }
            if (h <= Dygraph.SIX_HOURLY)
                return k = "h",
                h = g.getHours(),
                0 !== g.getMinutes() && (k += ":m"),
                h = 12 === h || 0 === h || d,
                d = c.Gc > g.valueOf() ? !0 : !1,
                h && (k += "\n a"),
                g = b(k, g),
                f = new gvjs_ly(gvjs_2ia),
                gvjs_jy(f, h),
                c.xg.push(new gvjs_0R(g,f)),
                c.xg.length - 1 + "";
            if (h <= Dygraph.DAILY)
                return k = "E",
                0 === g.getDay() || d ? (k += "\n M/d",
                h = !0) : h = !1,
                d = !1,
                g = b(k, g),
                f = new gvjs_ly(gvjs_3ia),
                gvjs_jy(f, h),
                c.xg.push(new gvjs_0R(g,f)),
                c.xg.length - 1 + "";
            if (h <= Dygraph.WEEKLY)
                return h = d,
                d = !1,
                g = b("MMM d", g),
                f = new gvjs_ly(gvjs_4ia),
                gvjs_jy(f, h),
                c.xg.push(new gvjs_0R(g,f)),
                c.xg.length - 1 + "";
            if (h <= Dygraph.BIANNUAL)
                return k = "MMM",
                h = 0 === g.getMonth() || d,
                d = c.Gc > g.valueOf() ? !0 : !1,
                h && (k += "\n yyyy"),
                g = b(k, g),
                f = new gvjs_ly(gvjs_5ia),
                gvjs_jy(f, h),
                c.xg.push(new gvjs_0R(g,f)),
                c.xg.length - 1 + "";
            if (h <= Dygraph.CENTENNIAL)
                return g = b("yyyy", g),
                f = new gvjs_ly(gvjs_6ia),
                c.xg.push(new gvjs_0R(g,f)),
                c.xg.length - 1 + "";
            throw Error(gvjs_OQ);
        }
        ;
    case "pixelsPerLabel":
        return 50
    }
}
;
var gvjs_0ia = {
    Lb: "",
    bold: !1,
    color: gvjs_rt,
    opacity: 1,
    bb: gvjs_2r,
    fontSize: 13,
    Nc: !1,
    Ue: !1
}
  , gvjs_1ia = {
    Lb: "",
    bold: !1,
    color: gvjs_rt,
    opacity: 1,
    bb: gvjs_2r,
    fontSize: 13,
    Nc: !1,
    Ue: !1
}
  , gvjs_2ia = {
    Lb: "",
    bold: !1,
    color: gvjs_rt,
    opacity: 1,
    bb: gvjs_2r,
    fontSize: 13,
    Nc: !1,
    Ue: !1
}
  , gvjs_3ia = {
    Lb: "",
    bold: !1,
    color: gvjs_rt,
    opacity: 1,
    bb: gvjs_2r,
    fontSize: 13,
    Nc: !1,
    Ue: !1
}
  , gvjs_4ia = {
    Lb: "",
    bold: !1,
    color: gvjs_rt,
    opacity: 1,
    bb: gvjs_2r,
    fontSize: 13,
    Nc: !1,
    Ue: !1
}
  , gvjs_5ia = {
    Lb: "",
    bold: !1,
    color: gvjs_rt,
    opacity: 1,
    bb: gvjs_2r,
    fontSize: 13,
    Nc: !1,
    Ue: !1
}
  , gvjs_6ia = {
    Lb: "",
    bold: !1,
    color: gvjs_rt,
    opacity: 1,
    bb: gvjs_2r,
    fontSize: 13,
    Nc: !1,
    Ue: !1
};
function gvjs_2S(a, b) {
    return 1 === a ? b : b + "s"
}
;function gvjs_3S() {}
gvjs_3S.prototype.format = function(a, b) {
    var c = "MMM dd, yyyy"
      , d = "MMM dd, yyyy";
    a.getYear() === b.getYear() && (c = "MMM dd",
    a.getMonth() === b.getMonth() && (d = "dd, yyyy"));
    c = new gvjs_Xi(c);
    d = new gvjs_Xi(d);
    return [c.format(a), d.format(b)].join(gvjs_ar)
}
;
gvjs_3S.prototype.tv = function(a, b) {
    a = Math.ceil(Math.abs(b - a) / 864E5);
    return a + gvjs_2S(parseFloat(a), " day")
}
;
function gvjs_4S() {}
gvjs_4S.prototype.format = function(a, b) {
    var c = new gvjs_Xi("h:mm a")
      , d = c.format(a).toLowerCase();
    c = c.format(b).toLowerCase();
    if (864E5 > Math.abs(b - a))
        return [d, c].join(gvjs_ar);
    var e = new gvjs_Xi("MMM d");
    a = e.format(a);
    b = e.format(b);
    return [a, d, "-", b, c].join(" ")
}
;
gvjs_4S.prototype.tv = function(a, b) {
    a = (Math.abs(b - a) / 36E5).toFixed(2).replace(/\.?0*$/, "");
    return a + gvjs_2S(parseFloat(a), " hour")
}
;
function gvjs_5S() {}
gvjs_5S.prototype.format = function(a, b) {
    var c = gvjs_Ia;
    if (0 !== a.getMilliseconds() || 0 !== b.getMilliseconds())
        c += ":ss.SSS";
    else if (0 !== a.getSeconds() || 0 !== b.getSeconds())
        c += ":ss";
    c = new gvjs_Xi(c);
    return [c.format(a), c.format(b)].join(gvjs_ar)
}
;
gvjs_5S.prototype.tv = function(a, b) {
    a = b - a;
    var c = Math.floor(a / 36E5)
      , d = Math.floor(a / 6E4 % 60)
      , e = Math.floor(a / 1E3 % 60);
    b = a % 1E3;
    a = [];
    0 < c && a.push(c + "h");
    0 < d && a.push(d + "m");
    if (e || b)
        c = e.toString(),
        0 < b && (d = b.toString(),
        3 <= d.length ? b = d : (b = "000" + b.toString(),
        b = b.substr(b.length - 3)),
        c += "." + b),
        a.push(c + "s");
    return 0 == a.length ? "0s" : a.join(" ")
}
;
function gvjs_6S() {}
gvjs_6S.prototype.format = function(a, b) {
    var c = new gvjs_Xi("MMM yyyy")
      , d = c.format(a);
    a.getYear() === b.getYear() && (d = d.substr(0, 3));
    return [d, c.format(b)].join(gvjs_ar)
}
;
gvjs_6S.prototype.tv = function(a, b) {
    var c = b.getYear()
      , d = b.getMonth()
      , e = c - a.getYear()
      , f = d - a.getMonth()
      , g = b.getDate() - a.getDate();
    0 > g && (f--,
    g += gvjs_Pi(c, (d + 11) % 12));
    0 > f && (e--,
    f += 12);
    c = [];
    0 < e && (d = gvjs_2S(e, " year"),
    c.push(e.toString() + d));
    0 < f && (d = gvjs_2S(f, " month"),
    c.push(f.toString() + d));
    0 < g && (d = gvjs_2S(g, " day"),
    c.push(g.toString() + d));
    return 0 === e && 0 === f && 0 === g ? gvjs_7S(2).tv(a, b) : c.join(gvjs_ha)
}
;
function gvjs_8S() {}
gvjs_8S.prototype.format = function(a, b) {
    var c = "s";
    if (0 !== a.getMilliseconds() || 0 !== b.getMilliseconds())
        c += ".SSS";
    c += "'s'";
    if (a.getSeconds() > b.getSeconds() || 6E4 < b - a)
        c = "m'm' " + c;
    c = new gvjs_Xi(c);
    return [c.format(a), c.format(b)].join(gvjs_ar)
}
;
gvjs_8S.prototype.tv = function(a, b) {
    a = Math.abs(b - a) / 1E3;
    return a.toString() + gvjs_2S(a, " second")
}
;
var gvjs_9S = {};
gvjs_9S[0] = gvjs_8S;
gvjs_9S[1] = gvjs_5S;
gvjs_9S[2] = gvjs_4S;
gvjs_9S[3] = gvjs_3S;
gvjs_9S[4] = gvjs_6S;
function gvjs_$S(a) {
    return a < Dygraph.MINUTELY ? 0 : a < Dygraph.HOURLY ? 1 : a < Dygraph.DAILY ? 2 : a < Dygraph.MONTHLY ? 3 : 4
}
function gvjs_7S(a) {
    var b = gvjs_9S[a];
    if (!b)
        throw Error("Formatter not found for granularity: " + a + ".");
    return new b
}
;function gvjs_aT(a) {
    this.m = a.options;
    this.eF = a.table;
    this.aY = a.Sm;
    this.oh = a.rK;
    this.AO = a.axes.domain;
    this.R4 = a.axes.target;
    this.layout = this.tN()
}
gvjs_aT.prototype.Ry = function() {
    var a = [];
    gvjs_u(this.layout, function(b) {
        b.C.forEach(function(c) {
            a.push({
                column: c.sourceColumn,
                color: c.color
            })
        })
    });
    return a
}
;
gvjs_aT.prototype.tN = function() {
    var a = this
      , b = this.AO
      , c = this.R4;
    gvjs_w(c, function(m) {
        m.expand = !0
    });
    gvjs_w(b, function(m) {
        m.expand = !0
    });
    var d = {}, e;
    for (e in c)
        c[e].columns.forEach(function(m) {
            d[m] = {
                name: e,
                axis: c[e]
            }
        });
    var f = {};
    for (e in b)
        b[e].columns.forEach(function(m) {
            f[m] = {
                name: e,
                axis: b[e]
            }
        });
    var g = this.eF
      , h = gvjs_v(this.aY, function(m, n) {
        for (var p = this, q = f[m.Yi], r = q.axis.scale, t = {
            column: m.Yi,
            C: m.C.map(function(y, z) {
                p.oh.Au(n + "/" + z);
                return {
                    sourceColumn: y.Bs,
                    BO: q.name,
                    data: []
                }
            })
        }, u = 0, v = g.ca(); u < v; u++) {
            var w = g.getValue(u, m.Yi)
              , x = null;
            x = r.isDiscrete() ? r.add(w) : r.scale(w);
            null != x && isFinite(x) && (null === q.axis.range ? q.axis.range = new gvjs_O(x,x) : gvjs_5Q(q.axis.range, x));
            m.C.forEach(function(y, z) {
                var A = d[y.Bs];
                t.C[z].GL = A.name;
                y = g.getValue(u, y.Bs);
                var B = A.axis.scale.scale(y);
                null != B && isFinite(B) && (null === A.axis.range ? A.axis.range = new gvjs_O(B,B) : null != x && gvjs_5Q(A.axis.range, B));
                t.C[z].data.push({
                    BO: q.name,
                    Gg: w,
                    Tt: x,
                    GL: A.name,
                    za: y,
                    Iw: B,
                    ZE: u
                })
            }, this)
        }
        return t
    }, this)
      , k = this.oh.cd()
      , l = 0;
    h.forEach(function(m, n) {
        gvjs_u(m.C, function(p, q) {
            p.color = gvjs_qj(gvjs_J(a.m, gvjs_Qw + l + ".color", k.Cq(n + "/" + q))).hex;
            l++
        })
    });
    return h
}
;
