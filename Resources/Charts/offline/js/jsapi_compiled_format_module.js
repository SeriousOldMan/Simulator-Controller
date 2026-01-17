var gvjs_Qo = " 0 0 1 "
  , gvjs_Ro = "0%"
  , gvjs_So = "100%"
  , gvjs_To = "BUTTON"
  , gvjs_Uo = "SELECT"
  , gvjs_Vo = "TEXTAREA"
  , gvjs_Wo = "background"
  , gvjs_Xo = "baseline"
  , gvjs_Yo = "blur"
  , gvjs_Zo = "chartArea.bottom"
  , gvjs__o = "chartArea.height"
  , gvjs_0o = "chartArea.left"
  , gvjs_1o = "chartArea.right"
  , gvjs_2o = "chartArea.top"
  , gvjs_3o = "chartArea.width"
  , gvjs_4o = "circle"
  , gvjs_5o = "clip-path"
  , gvjs_6o = "corners.bottomleft.rx"
  , gvjs_7o = "corners.bottomleft.ry"
  , gvjs_8o = "corners.bottomright.rx"
  , gvjs_9o = "corners.bottomright.ry"
  , gvjs_$o = "corners.rx"
  , gvjs_ap = "corners.ry"
  , gvjs_bp = "corners.topleft.rx"
  , gvjs_cp = "corners.topleft.ry"
  , gvjs_dp = "corners.topright.rx"
  , gvjs_ep = "corners.topright.ry"
  , gvjs_fp = "datatable"
  , gvjs_gp = "datum"
  , gvjs_hp = "defs"
  , gvjs_ip = "discrete"
  , gvjs_jp = "ellipse"
  , gvjs_R = "end"
  , gvjs_kp = "feComponentTransfer"
  , gvjs_lp = "feGaussianBlur"
  , gvjs_mp = "feMergeNode"
  , gvjs_np = "fill"
  , gvjs_op = "fill-opacity"
  , gvjs_pp = "fill.color"
  , gvjs_qp = "fill.opacity"
  , gvjs_rp = "fillColor"
  , gvjs_sp = "fillOpacity"
  , gvjs_tp = "filter"
  , gvjs_up = "finishAnimation"
  , gvjs_vp = "font.family"
  , gvjs_wp = "font.size"
  , gvjs_xp = "fontFamily"
  , gvjs_yp = "fontName"
  , gvjs_zp = "fontSize"
  , gvjs_Ap = "getcontext"
  , gvjs_Bp = "gradient"
  , gvjs_Cp = "group"
  , gvjs_Dp = "halign"
  , gvjs_S = "horizontal"
  , gvjs_Ep = "http://www.w3.org/2000/svg"
  , gvjs_Fp = "in"
  , gvjs_Gp = "italic"
  , gvjs_Hp = "linear"
  , gvjs_Ip = "linearGradient"
  , gvjs_Jp = "offset"
  , gvjs_Kp = "opacity"
  , gvjs_Lp = "path"
  , gvjs_Mp = "playAnimation"
  , gvjs_Np = "point"
  , gvjs_Op = "pointShape"
  , gvjs_T = "px"
  , gvjs_Pp = "rabl-use-parent"
  , gvjs_Qp = "rect"
  , gvjs_Rp = "redraw"
  , gvjs_Sp = "rotate"
  , gvjs_Tp = "rotate("
  , gvjs_Up = "rtl"
  , gvjs_Vp = "shadow.opacity"
  , gvjs_Wp = "shadow.radius"
  , gvjs_Xp = "shadow.xoffset"
  , gvjs_Yp = "shadow.yoffset"
  , gvjs_Zp = "slice"
  , gvjs__p = "stop"
  , gvjs_0p = "stroke"
  , gvjs_1p = "stroke-opacity"
  , gvjs_2p = "stroke-width"
  , gvjs_3p = "stroke.color"
  , gvjs_4p = "stroke.opacity"
  , gvjs_5p = "stroke.width"
  , gvjs_6p = "strokeColor"
  , gvjs_7p = "strokeOpacity"
  , gvjs_8p = "strokeWidth"
  , gvjs_9p = "svg"
  , gvjs_$p = "text-anchor"
  , gvjs_aq = "transform"
  , gvjs_bq = "underline"
  , gvjs_cq = 'unknown property on ellipse "'
  , gvjs_dq = "url(#"
  , gvjs_eq = "valign"
  , gvjs_U = "vertical";
function gvjs_V(a, b) {
    return gvjs_2d[a] = b
}
gvjs_B.prototype.La = gvjs_V(10, function() {
    return this.right - this.left
});
gvjs_Qn.prototype.La = gvjs_V(9, function(a, b) {
    return a.bD(gvjs_Xd) || gvjs_Gh(this.container).width || b || 400
});
function gvjs_fq(a, b, c) {
    gvjs_Ne(a, c, 0, b)
}
function gvjs_gq(a, b, c) {
    b = gvjs_iaa(b, function(d, e) {
        var f = {};
        return f[e] = d,
        f
    }, c);
    gvjs_mj(a, b)
}
function gvjs_hq(a, b, c) {
    if (a.lN) {
        var d = {};
        gvjs_gq(d, a.lN[0].split("."), c);
        c = d
    }
    for (var e = d = 0; e < b; e++)
        e === a.AJ.length && a.AJ.push(0),
        d += a.AJ[e];
    a.AJ[b]++;
    gvjs_fq(a.Gd, c, d)
}
function gvjs_iq(a, b) {
    for (var c = gvjs_8d(Object.keys(b)), d = c.next(); !d.done; d = c.next()) {
        d = d.value;
        var e = b[d];
        null != e && e instanceof Object && !Array.isArray(e) ? (a[d] = a[d] || {},
        gvjs_iq(a[d], e)) : null != e && (a[d] = e)
    }
}
function gvjs_jq(a) {
    var b = void 0 === b ? {} : b;
    gvjs_Ce(a.Gd, function(c) {
        gvjs_iq(b, c)
    });
    return b
}
function gvjs_kq(a, b, c) {
    return gvjs_Fj(a, gvjs_Lj, 0, b, c)
}
function gvjs_lq(a) {
    var b = arguments.length;
    if (1 == b && Array.isArray(arguments[0]))
        return gvjs_lq.apply(null, arguments[0]);
    for (var c = {}, d = 0; d < b; d++)
        c[arguments[d]] = !0;
    return c
}
var gvjs_ada = /<[^>]*>|&[^;]+;/g
  , gvjs_bda = /[A-Za-z\u00c0-\u00d6\u00d8-\u00f6\u00f8-\u02b8\u0300-\u0590\u0900-\u1fff\u200e\u2c00-\ud801\ud804-\ud839\ud83c-\udbff\uf900-\ufb1c\ufe00-\ufe6f\ufefd-\uffff]/
  , gvjs_cda = /^[^A-Za-z\u00c0-\u00d6\u00d8-\u00f6\u00f8-\u02b8\u0300-\u0590\u0900-\u1fff\u200e\u2c00-\ud801\ud804-\ud839\ud83c-\udbff\uf900-\ufb1c\ufe00-\ufe6f\ufefd-\uffff]*[\u0591-\u06ef\u06fa-\u08ff\u200f\ud802-\ud803\ud83a-\ud83b\ufb1d-\ufdff\ufe70-\ufefc]/
  , gvjs_dda = /^http:\/\/.*/
  , gvjs_eda = /\s+/
  , gvjs_fda = /[\d\u06f0-\u06f9]/;
function gvjs_mq(a, b) {
    var c = 0
      , d = 0
      , e = !1;
    a = (b ? a.replace(gvjs_ada, "") : a).split(gvjs_eda);
    for (b = 0; b < a.length; b++) {
        var f = a[b];
        gvjs_cda.test(f) ? (c++,
        d++) : gvjs_dda.test(f) ? e = !0 : gvjs_bda.test(f) ? d++ : gvjs_fda.test(f) && (e = !0)
    }
    return 0 == d ? e ? 1 : 0 : .4 < c / d ? -1 : 1
}
;/*

 Copyright The Closure Library Authors.
 SPDX-License-Identifier: Apache-2.0
*/
var gvjs_gda = function() {
    if (gvjs_vg) {
        var a = /Windows NT ([0-9.]+)/;
        return (a = a.exec(gvjs_Rf)) ? a[1] : "0"
    }
    return gvjs_ug ? (a = /1[0|1][_.][0-9_.]+/,
    (a = a.exec(gvjs_Rf)) ? a[0].replace(/_/g, ".") : "10") : gvjs_Eaa ? (a = /Android\s+([^\);]+)(\)|;)/,
    (a = a.exec(gvjs_Rf)) ? a[1] : "") : gvjs_Faa || gvjs_Gaa || gvjs_Haa ? (a = /(?:iPhone|CPU)\s+OS\s+(\S+)/,
    (a = a.exec(gvjs_Rf)) ? a[1].replace(/_/g, ".") : "") : ""
}();
function gvjs_nq(a) {
    return (a = a.exec(gvjs_Rf)) ? a[1] : ""
}
var gvjs_oq = function() {
    if (gvjs_Laa)
        return gvjs_nq(/Firefox\/([0-9.]+)/);
    if (gvjs_y || gvjs_rg || gvjs_qg)
        return gvjs_Dg;
    if (gvjs_Kg)
        return gvjs_mg() ? gvjs_nq(/CriOS\/([0-9.]+)/) : gvjs_nq(/Chrome\/([0-9.]+)/);
    if (gvjs_Lg && !gvjs_mg())
        return gvjs_nq(/Version\/([0-9.]+)/);
    if (gvjs_Ig || gvjs_Jg) {
        var a = /Version\/(\S+).*Mobile\/(\S+)/.exec(gvjs_Rf);
        if (a)
            return a[1] + "." + a[2]
    } else if (gvjs_Maa)
        return (a = gvjs_nq(/Android\s+([0-9.]+)/)) ? a : gvjs_nq(/Version\/([0-9.]+)/);
    return ""
}();
var gvjs_pq = {};
function gvjs_qq() {
    throw Error("Do not instantiate directly");
}
gvjs_qq.prototype.TN = null;
gvjs_qq.prototype.getContent = function() {
    return this.content
}
;
gvjs_qq.prototype.toString = function() {
    return this.content
}
;
function gvjs_rq() {
    gvjs_qq.call(this)
}
gvjs_t(gvjs_rq, gvjs_qq);
gvjs_rq.prototype.eq = gvjs_pq;
gvjs_y && gvjs_Eg(8);
var gvjs_W = function(a) {
    function b(c) {
        this.content = c
    }
    b.prototype = a.prototype;
    return function(c, d) {
        c = new b(String(c));
        void 0 !== d && (c.TN = d);
        return c
    }
}(gvjs_rq)
  , gvjs_sq = function(a) {
    function b(c) {
        this.content = c
    }
    b.prototype = a.prototype;
    return function(c, d) {
        c = String(c);
        if (!c)
            return "";
        c = new b(c);
        void 0 !== d && (c.TN = d);
        return c
    }
}(gvjs_rq);
var gvjs_tq = {
    s: function(a, b, c) {
        return isNaN(c) || "" == c || a.length >= Number(c) ? a : a = -1 < b.indexOf("-", 0) ? a + gvjs_eg(" ", Number(c) - a.length) : gvjs_eg(" ", Number(c) - a.length) + a
    },
    f: function(a, b, c, d, e) {
        d = a.toString();
        isNaN(e) || "" == e || (d = parseFloat(a).toFixed(e));
        var f = 0 > Number(a) ? "-" : 0 <= b.indexOf("+") ? "+" : 0 <= b.indexOf(" ") ? " " : "";
        0 <= Number(a) && (d = f + d);
        if (isNaN(c) || d.length >= Number(c))
            return d;
        d = isNaN(e) ? Math.abs(Number(a)).toString() : Math.abs(Number(a)).toFixed(e);
        a = Number(c) - d.length - f.length;
        0 <= b.indexOf("-", 0) ? d = f + d + gvjs_eg(" ", a) : (b = 0 <= b.indexOf("0", 0) ? "0" : " ",
        d = f + gvjs_eg(b, a) + d);
        return d
    },
    d: function(a, b, c, d, e, f, g, h) {
        return gvjs_tq.f(parseInt(a, 10), b, c, d, 0, f, g, h)
    }
};
gvjs_tq.i = gvjs_tq.d;
gvjs_tq.u = gvjs_tq.d;
gvjs_lq(["A", "AREA", gvjs_To, "HEAD", gvjs_Na, "LINK", "MENU", "META", "OPTGROUP", "OPTION", "PROGRESS", gvjs_7a, gvjs_Uo, gvjs_5a, gvjs_Vo, "TITLE", "TRACK"]);
function gvjs_uq() {}
gvjs_uq.prototype.o = function(a, b) {
    gvjs_vq(this, a);
    this.cI[a].push(b);
    return this
}
;
gvjs_uq.prototype.Ab = function(a, b) {
    gvjs_vq(this, a);
    a = this.cI[a];
    for (var c = null, d = 0, e = a.length; d < e; d++)
        if (a[d] === b) {
            c = d;
            break
        }
    return null != c ? (a.splice(c, 1),
    !0) : !1
}
;
gvjs_uq.prototype.fireEvent = function(a, b) {
    gvjs_vq(this, a);
    a = this.cI[a];
    for (var c = [], d = 0, e = a.length; d < e; d++)
        c.push(a[d]);
    for (d = 0; d < e; d++)
        c[d].apply(this, b);
    return 0 < e
}
;
function gvjs_vq(a, b) {
    if (!a.cI.hasOwnProperty(b))
        throw 'event type "' + b + '" unknown.';
}
;function gvjs_wq(a) {
    this.cI = {
        add: [],
        click: [],
        getcontext: [],
        mousemove: [],
        mouseenter: [],
        mouseleave: [],
        box: [],
        redraw: [],
        remove: [],
        playAnimation: [],
        finishAnimation: []
    };
    this.Sb = this.ra = null;
    this.md = {};
    this.Zn = [];
    this.lS = [];
    if (null != a)
        for (var b in a)
            this.setStyle(b, a[b]);
    this.f6 = null
}
gvjs_t(gvjs_wq, gvjs_uq);
gvjs_ = gvjs_wq.prototype;
gvjs_.data = function(a) {
    return void 0 !== a ? (this.ra = a,
    this) : this.ra
}
;
gvjs_.setData = function(a) {
    this.ra = a;
    return this
}
;
gvjs_.setStyle = function(a, b) {
    b instanceof Object && null != b && (b = b.toString());
    if (this.md[a] === b)
        return !1;
    this.md[a] = b;
    this.eo = null;
    return !0
}
;
gvjs_.getStyle = function(a) {
    return this.md[a]
}
;
function gvjs_xq(a) {
    null == a.f6 && (a.f6 = new gvjs_Aj([a.md],void 0,!0));
    return a.f6
}
gvjs_.style = function(a, b) {
    return void 0 !== b ? (this.setStyle(a, b) && this.fireEvent(gvjs_Rp, [this, a]),
    this) : this.getStyle(a)
}
;
gvjs_.styles = function(a) {
    for (var b in a)
        a.hasOwnProperty(b) && this.style(b, a[b]);
    return this
}
;
gvjs_.getContext = function() {
    this.Sb || this.fireEvent(gvjs_Ap, [this]);
    return this.Sb
}
;
gvjs_.Qj = gvjs_n(25);
gvjs_.Ou = gvjs_n(27);
gvjs_.kEa = function() {
    for (var a = this; 0 < this.Zn.length; ) {
        var b = this.Zn.shift();
        a.lS.push(b);
        b.o(gvjs_up, function(c, d) {
            c = a.lS.indexOf(d);
            if (0 > c)
                throw "Animation not found.";
            a.lS.splice(c, 1);
            0 === a.lS.length && a.fireEvent(gvjs_up, [a])
        });
        if (!this.fireEvent(gvjs_Mp, [this, b]))
            throw "Cannot play animations for shape not in a scene.";
    }
    return this
}
;
var gvjs_hda = gvjs_p.requestAnimationFrame || gvjs_p.mozRequestAnimationFrame || gvjs_p.webkitRequestAnimationFrame || gvjs_p.msRequestAnimationFrame || function(a) {
    return gvjs_p.setTimeout(function() {
        return a.call(this, Date.now())
    }, 1E3 / 60)
}
;
function gvjs_yq(a) {
    for (var b = 0, c = arguments.length; b < c; b++)
        if (null != arguments[b])
            return arguments[b]
}
function gvjs_zq(a, b, c, d) {
    gvjs_Aq(a, b, c, d);
    gvjs_Bq(a, b, c, d);
    gvjs_Cq(a, b, c, d);
    gvjs_Dq(a, b, c, d);
    gvjs_Eq(a, b, c, d);
    gvjs_Fq(a, b, c, d);
    gvjs_Gq(a, b, c, d);
    var e = gvjs_xq(c)
      , f = gvjs_L(e, "clip.width")
      , g = gvjs_L(e, "clip.height");
    if (f && g) {
        var h = gvjs_L(e, "clip.x", 0);
        e = gvjs_L(e, "clip.y", 0);
        var k = ["clip", h, e, f, g].join()
          , l = c.yr;
        if (c = a.g3(k, l))
            n = c.getAttribute(gvjs_5c);
        else {
            var m = gvjs_Ph();
            c = m.createElementNS(gvjs_Ep, "clipPath");
            var n = a.yZ();
            c.setAttribute(gvjs_5c, n);
            m = m.createElementNS(gvjs_Ep, gvjs_Qp);
            m.setAttribute("x", h);
            m.setAttribute("y", e);
            m.setAttribute(gvjs_Xd, f);
            m.setAttribute(gvjs_4c, g);
            c.appendChild(m);
            a.N4(k, c, l);
            for (a = d; a.nodeName !== gvjs_9p; )
                a = a.parentNode;
            a = a.querySelector(gvjs_hp) || a;
            a.insertBefore(c, a.firstChild)
        }
        b.setAttribute(gvjs_5o, gvjs_dq + n + ")")
    } else
        b.hasAttribute(gvjs_5o) && b.removeAttribute(gvjs_5o)
}
function gvjs_Bq(a, b, c, d) {
    gvjs_Hq(a, b, c, d, !1);
    a = gvjs_yq(c.style(gvjs_pp), c.style(gvjs_rp), c.style(gvjs_np));
    typeof a === gvjs_l || typeof a === gvjs_g ? b.setAttribute(gvjs_np, a) : null === a && b.removeAttribute(gvjs_np)
}
function gvjs_Cq(a, b, c) {
    a = gvjs_yq(c.style(gvjs_qp), c.style(gvjs_sp), c.style(gvjs_op));
    typeof a === gvjs_l || typeof a === gvjs_g ? b.setAttribute(gvjs_op, a) : null === a && b.removeAttribute(gvjs_op)
}
function gvjs_Dq(a, b, c, d) {
    gvjs_Hq(a, b, c, d, !0);
    a = gvjs_yq(c.style(gvjs_3p), c.style(gvjs_6p), c.style(gvjs_0p));
    typeof a === gvjs_l || typeof a === gvjs_g ? b.setAttribute(gvjs_0p, a) : null === a && b.removeAttribute(gvjs_0p)
}
function gvjs_Eq(a, b, c) {
    a = gvjs_yq(c.style(gvjs_4p), c.style(gvjs_7p), c.style(gvjs_1p));
    typeof a === gvjs_l || typeof a === gvjs_g ? b.setAttribute(gvjs_1p, a) : null === a && b.removeAttribute(gvjs_1p)
}
function gvjs_Fq(a, b, c) {
    a = gvjs_yq(c.style(gvjs_5p), c.style(gvjs_8p), c.style(gvjs_2p));
    typeof a === gvjs_l || typeof a === gvjs_g ? b.setAttribute(gvjs_2p, a) : null === a && b.removeAttribute(gvjs_2p)
}
function gvjs_Aq(a, b, c) {
    a = c.style(gvjs_Kp);
    typeof a === gvjs_l || typeof a === gvjs_g ? b.setAttribute(gvjs_Kp, a) : null === a && b.removeAttribute(gvjs_Kp)
}
function gvjs_Hq(a, b, c, d, e) {
    var f = gvjs_xq(c)
      , g = e ? gvjs_0p : gvjs_np
      , h = f.kt(g + ".gradient.from")
      , k = f.kt(g + ".gradient.to");
    e = b.getAttribute(g);
    if (h && k) {
        var l = gvjs_kq(f, g + ".gradient.x1", gvjs_Ro)
          , m = gvjs_kq(f, g + ".gradient.y1", gvjs_Ro)
          , n = gvjs_kq(f, g + ".gradient.x2", gvjs_So)
          , p = gvjs_kq(f, g + ".gradient.y2", gvjs_Ro);
        f = [gvjs_Bp, h, k, l, m, n, p].join();
        var q = c.yr;
        if (c = a.g3(f, q))
            g = c.getAttribute(gvjs_5c);
        else {
            var r = gvjs_Ph();
            c = r.createElementNS(gvjs_Ep, gvjs_Ip);
            g = a.yZ();
            c.setAttribute(gvjs_5c, g);
            c.setAttribute("x1", l);
            c.setAttribute("y1", m);
            c.setAttribute("x2", n);
            c.setAttribute("y2", p);
            l = r.createElementNS(gvjs_Ep, gvjs__p);
            l.setAttribute("stop-color", h);
            l.setAttribute(gvjs_Jp, gvjs_Ro);
            h = r.createElementNS(gvjs_Ep, gvjs__p);
            h.setAttribute("stop-color", k);
            h.setAttribute(gvjs_Jp, gvjs_So);
            c.appendChild(l);
            c.appendChild(h);
            a.N4(f, c, q);
            for (a = d; a.nodeName !== gvjs_9p; )
                a = a.parentNode;
            a = a.querySelector(gvjs_hp) || a;
            a.insertBefore(c, a.firstChild)
        }
        a = gvjs_dq + g + ")";
        e !== a && b.setAttribute(gvjs_np, a)
    } else
        e && e.substr(0, 5) === gvjs_dq && b.removeAttribute(g)
}
function gvjs_Gq(a, b, c, d) {
    var e = gvjs_xq(c)
      , f = gvjs_kq(e, gvjs_Wp, 0)
      , g = gvjs_kq(e, gvjs_Vp, 0);
    if (f || g) {
        var h = e.kt("shadow.xOffset") || e.kt("shadow.x-offset") || e.kt(gvjs_Xp) || 0
          , k = e.kt("shadow.yOffset") || e.kt("shadow.y-offset") || e.kt(gvjs_Yp) || 0;
        e = [gvjs_Yo, f, g, h, k].join();
        var l = c.yr
          , m = a.g3(e, l);
        if (m)
            c = m.getAttribute(gvjs_5c);
        else {
            var n = gvjs_Ph();
            m = n.createElementNS(gvjs_Ep, gvjs_tp);
            m.setAttribute("x", "-100%");
            m.setAttribute("y", "-100%");
            m.setAttribute(gvjs_Xd, "300%");
            m.setAttribute(gvjs_4c, "300%");
            c = a.yZ();
            m.setAttribute(gvjs_5c, c);
            var p = n.createElementNS(gvjs_Ep, gvjs_lp);
            p.setAttribute(gvjs_Fp, "SourceAlpha");
            p.setAttribute("stdDeviation", f);
            f = n.createElementNS(gvjs_Ep, "feOffset");
            f.setAttribute("dx", h);
            f.setAttribute("dy", k);
            if (null != g) {
                var q = n.createElementNS(gvjs_Ep, gvjs_kp);
                var r = n.createElementNS(gvjs_Ep, "feFuncA");
                r.setAttribute(gvjs_Sd, gvjs_Hp);
                r.setAttribute("slope", g)
            }
            g = n.createElementNS(gvjs_Ep, "feMerge");
            h = n.createElementNS(gvjs_Ep, gvjs_mp);
            n = n.createElementNS(gvjs_Ep, gvjs_mp);
            n.setAttribute(gvjs_Fp, "SourceGraphic");
            m.appendChild(p);
            m.appendChild(f);
            null != r && (q.appendChild(r),
            m.appendChild(q));
            g.appendChild(h);
            g.appendChild(n);
            m.appendChild(g);
            a.N4(e, m, l);
            for (a = d; a.nodeName !== gvjs_9p; )
                a = a.parentNode;
            a = a.querySelector(gvjs_hp) || a;
            a.insertBefore(m, a.firstChild)
        }
        a = b.getAttribute(gvjs_tp);
        d = gvjs_dq + c + ")";
        a !== d && b.setAttribute(gvjs_tp, d)
    } else
        b.hasAttribute(gvjs_tp) && b.removeAttribute(gvjs_tp)
}
var gvjs_ida = {
    "fill.color": gvjs_Bq,
    fillColor: gvjs_Bq,
    fill: gvjs_Bq,
    "fill.gradient.from": gvjs_Bq,
    "fill.gradient.to": gvjs_Bq,
    "fill.gradient.x1": gvjs_Bq,
    "fill.gradient.y1": gvjs_Bq,
    "fill.gradient.x2": gvjs_Bq,
    "fill.gradient.y2": gvjs_Bq,
    "fill.opacity": gvjs_Cq,
    fillOpacity: gvjs_Cq,
    "fill-opacity": gvjs_Cq,
    height: function(a, b, c) {
        a = gvjs_L(gvjs_xq(c), gvjs_4c);
        b.setAttribute(gvjs_4c, a)
    },
    opacity: gvjs_Aq,
    "shadow.radius": gvjs_Gq,
    "shadow.opacity": gvjs_Gq,
    "shadow.xOffset": gvjs_Gq,
    "shadow.x-offset": gvjs_Gq,
    "shadow.xoffset": gvjs_Gq,
    "shadow.yOffset": gvjs_Gq,
    "shadow.y-offset": gvjs_Gq,
    "shadow.yoffset": gvjs_Gq,
    "stroke.color": gvjs_Dq,
    strokeColor: gvjs_Dq,
    stroke: gvjs_Dq,
    "stroke.gradient.from": gvjs_Dq,
    "stroke.gradient.to": gvjs_Dq,
    "stroke.gradient.x1": gvjs_Dq,
    "stroke.gradient.y1": gvjs_Dq,
    "stroke.gradient.x2": gvjs_Dq,
    "stroke.gradient.y2": gvjs_Dq,
    "stroke.opacity": gvjs_Eq,
    strokeOpacity: gvjs_Eq,
    "stroke-opacity": gvjs_Eq,
    "stroke.width": gvjs_Fq,
    strokeWidth: gvjs_Fq,
    "stroke-width": gvjs_Fq,
    width: function(a, b, c) {
        a = gvjs_L(gvjs_xq(c), gvjs_Xd);
        b.setAttribute(gvjs_Xd, a)
    },
    x: function(a, b, c) {
        a = gvjs_L(gvjs_xq(c), "x");
        b.setAttribute("x", a)
    },
    y: function(a, b, c) {
        a = gvjs_L(gvjs_xq(c), "y");
        b.setAttribute("y", a)
    }
};
function gvjs_Iq(a, b, c, d, e, f) {
    f = f || {};
    return (c = f[c] || gvjs_ida[c]) ? (c(a, b, d, e),
    !0) : !1
}
;var gvjs_Jq = {
    applyX: function(a, b, c) {
        a = gvjs_xq(c).Aa("x");
        null != a && b.setAttribute("cx", a)
    },
    applyY: function(a, b, c) {
        a = gvjs_xq(c).Aa("y");
        null != a && b.setAttribute("cy", a)
    },
    j7: function(a, b, c) {
        a = gvjs_xq(c).Aa("r");
        null != a && b.setAttribute("r", a)
    }
};
gvjs_Jq.DK = {
    r: gvjs_Jq.j7,
    x: gvjs_Jq.applyX,
    y: gvjs_Jq.applyY
};
gvjs_Jq.draw = function(a, b, c, d) {
    var e = gvjs_Ph();
    d = d || e.createElementNS(gvjs_Ep, gvjs_4o);
    gvjs_Jq.applyX(a, d, b);
    gvjs_Jq.applyY(a, d, b);
    gvjs_Jq.j7(a, d, b);
    gvjs_zq(a, d, b, c);
    c && d.parentNode !== c && c.appendChild(d);
    return d
}
;
gvjs_Jq.Lf = function(a, b, c, d, e) {
    if (!gvjs_Iq(a, e, c, b, d, gvjs_Jq.DK))
        throw 'unknown property on circle "' + c + '".';
}
;
var gvjs_Kq = {};
function gvjs_Lq(a, b, c) {
    a = gvjs_L(gvjs_xq(c), "x");
    b.setAttribute("cx", a)
}
function gvjs_Mq(a, b, c) {
    a = gvjs_L(gvjs_xq(c), "y");
    b.setAttribute("cy", a)
}
function gvjs_Nq(a, b, c) {
    a = gvjs_L(gvjs_xq(c), "rx");
    b.setAttribute("rx", a)
}
function gvjs_Oq(a, b, c) {
    a = gvjs_L(gvjs_xq(c), "ry");
    b.setAttribute("ry", a)
}
var gvjs_Pq = {
    x: gvjs_Lq,
    y: gvjs_Mq,
    rx: gvjs_Nq,
    ry: gvjs_Oq
};
gvjs_Kq.kCa = gvjs_Nq;
gvjs_Kq.lCa = gvjs_Oq;
gvjs_Kq.applyX = gvjs_Lq;
gvjs_Kq.applyY = gvjs_Mq;
gvjs_Kq.draw = function(a, b, c, d) {
    var e = gvjs_Ph();
    d = d || e.createElementNS(gvjs_Ep, gvjs_jp);
    gvjs_Lq(a, d, b);
    gvjs_Mq(a, d, b);
    gvjs_Nq(a, d, b);
    gvjs_Oq(a, d, b);
    gvjs_zq(a, d, b, c);
    c && d.parentNode !== c && c.appendChild(d);
    return d
}
;
gvjs_Kq.DK = gvjs_Pq;
gvjs_Kq.Lf = function(a, b, c, d, e) {
    if (!gvjs_Iq(a, e, c, b, d, gvjs_Pq))
        throw gvjs_cq + c + '".';
}
;
var gvjs_Qq = {
    k7: function(a, b, c) {
        a = gvjs_L(gvjs_xq(c), "x1");
        b.setAttribute("x1", a)
    },
    m7: function(a, b, c) {
        a = gvjs_L(gvjs_xq(c), "y1");
        b.setAttribute("y1", a)
    },
    l7: function(a, b, c) {
        a = gvjs_L(gvjs_xq(c), "x2");
        b.setAttribute("x2", a)
    },
    n7: function(a, b, c) {
        a = gvjs_L(gvjs_xq(c), "y2");
        b.setAttribute("y2", a)
    }
};
gvjs_Qq.DK = {
    x1: gvjs_Qq.k7,
    x2: gvjs_Qq.l7,
    y1: gvjs_Qq.m7,
    y2: gvjs_Qq.n7
};
gvjs_Qq.draw = function(a, b, c, d) {
    var e = gvjs_Ph();
    d = d || e.createElementNS(gvjs_Ep, gvjs_e);
    gvjs_Qq.k7(a, d, b);
    gvjs_Qq.l7(a, d, b);
    gvjs_Qq.m7(a, d, b);
    gvjs_Qq.n7(a, d, b);
    gvjs_zq(a, d, b, c);
    c && d.parentNode !== c && c.appendChild(d);
    return d
}
;
gvjs_Qq.Lf = function(a, b, c, d, e) {
    if (!gvjs_Iq(a, e, c, b, d, gvjs_Qq.DK))
        throw gvjs_cq + c + '".';
}
;
function gvjs_Rq(a) {
    a %= 360;
    return 0 > 360 * a ? a + 360 : a
}
;function gvjs_Sq(a, b, c, d) {
    var e = gvjs_Ph();
    e = d || e.createElementNS(gvjs_Ep, gvjs_Lp);
    d || e.setAttribute("d", gvjs_Tq(c));
    gvjs_zq(a, e, c, b);
    return e
}
function gvjs_Tq(a) {
    a = a.$u;
    for (var b = [], c = 0, d = a.length; c < d; c++) {
        var e = a[c];
        if ("GVIZARC" === e[0]) {
            var f = e
              , g = Number(f[1])
              , h = Number(f[2]);
            e = Number(f[3]);
            var k = Number(f[4])
              , l = gvjs_Rq(Number(f[5]))
              , m = gvjs_Rq(Number(f[6]));
            f = !!Number(f[7]);
            270 === l && 0 === m ? e = "A " + e + " " + k + gvjs_Qo + (e + g) + " " + h : 180 === l && 270 === m ? e = "A " + e + " " + k + gvjs_Qo + g + " " + (h - k) : 0 === l && 90 === m ? e = "A " + e + " " + k + gvjs_Qo + g + " " + (h + k) : 90 === l && 180 === m ? e = "A " + e + " " + k + gvjs_Qo + (g - e) + " " + h : (g += Math.cos(m / 180 * Math.PI) * e,
            h += Math.sin(m / 180 * Math.PI) * k,
            l = f ? m - l : l - m,
            0 > l && (l += 360),
            e = "A " + e + " " + k + " 0 " + Number(180 < l) + " " + Number(f) + " " + g + " " + h)
        } else
            e = e.join(" ");
        b.push(e)
    }
    return b.join(" ")
}
;function gvjs_Uq(a) {
    gvjs_wq.call(this, a);
    this.eo = {
        x1: null,
        y1: null,
        x2: null,
        y2: null,
        width: 0,
        height: 0
    };
    this.$u = []
}
gvjs_o(gvjs_Uq, gvjs_wq);
gvjs_ = gvjs_Uq.prototype;
gvjs_.Rk = gvjs_n(32);
gvjs_.Ou = gvjs_n(26);
gvjs_.clear = function() {
    this.eo = {
        x1: null,
        y1: null,
        x2: null,
        y2: null,
        width: 0,
        height: 0
    };
    this.$u = []
}
;
gvjs_.move = function(a, b) {
    this.$u.push(["M", a, b]);
    return this
}
;
gvjs_.line = function(a, b) {
    this.$u.push(["L", a, b]);
    return this
}
;
gvjs_.arc = function(a, b, c, d, e, f, g) {
    e = gvjs_Rq(e);
    f = gvjs_Rq(f);
    this.$u.push(["GVIZARC", a, b, c, d, e, f, Number(g)]);
    return this
}
;
gvjs_.curve = function(a, b, c, d, e, f) {
    this.$u.push(["C", a, b, c, d, e, f]);
    return this
}
;
gvjs_.close = function() {
    this.$u.push(["Z"]);
    return this
}
;
function gvjs_Vq(a) {
    var b = gvjs_xq(a);
    a = b.Aa(gvjs_bp) || 0;
    var c = b.Aa(gvjs_cp) || 0
      , d = b.Aa(gvjs_dp) || 0
      , e = b.Aa(gvjs_ep) || 0
      , f = b.Aa(gvjs_6o) || 0
      , g = b.Aa(gvjs_7o) || 0
      , h = b.Aa(gvjs_8o) || 0;
    b = b.Aa(gvjs_9o) || 0;
    return !!(a || c || d || e || f || g || h || b)
}
function gvjs_Wq(a) {
    var b = gvjs_xq(a)
      , c = gvjs_L(b, gvjs_$o, 0)
      , d = gvjs_L(b, gvjs_ap, 0)
      , e = gvjs_L(b, gvjs_bp, c)
      , f = gvjs_L(b, gvjs_cp, d)
      , g = gvjs_L(b, gvjs_dp, c)
      , h = gvjs_L(b, gvjs_ep, d)
      , k = gvjs_L(b, gvjs_6o, c)
      , l = gvjs_L(b, gvjs_7o, d);
    c = gvjs_L(b, gvjs_8o, c);
    d = gvjs_L(b, gvjs_9o, d);
    var m = gvjs_L(b, gvjs_Xd)
      , n = gvjs_L(b, gvjs_4c)
      , p = gvjs_L(b, "x");
    b = gvjs_L(b, "y");
    p = 0 <= m ? p : p + m;
    b = 0 <= n ? b : b + n;
    m = Math.abs(m);
    n = Math.abs(n);
    if (e + g > m) {
        var q = m / (e + g);
        e *= q;
        f *= q;
        g *= q;
        h *= q
    }
    k + c > m && (q = m / (k + c),
    k *= q,
    l *= q,
    c *= q,
    d *= q);
    f + l > n && (q = n / (f + l),
    e *= q,
    f *= q,
    k *= q,
    l *= q);
    h + d > n && (q = n / (h + d),
    g *= q,
    h *= q,
    c *= q,
    d *= q);
    return (new gvjs_Uq(a.md)).move(p + m - g, b).arc(p + m - g, b + h, g, h, 270, 0, !0).line(p + m, b + n - d).arc(p + m - c, b + n - d, c, d, 0, 90, !0).line(p + k, b + n).arc(p + k, b + n - l, k, l, 90, 180, !0).line(p, b + f).arc(p + e, b + f, e, f, 180, 270, !0).close()
}
;var gvjs_Xq = {
    draw: function(a, b, c, d) {
        var e = b.style(gvjs_$o)
          , f = b.style(gvjs_ap)
          , g = gvjs_xq(b)
          , h = gvjs_L(g, gvjs_Xd)
          , k = gvjs_L(g, gvjs_4c)
          , l = gvjs_L(g, "x");
        g = gvjs_L(g, "y");
        l = 0 <= h ? l : l + h;
        g = 0 <= k ? g : g + k;
        h = Math.abs(h);
        k = Math.abs(k);
        if (typeof e === gvjs_g && typeof f === gvjs_g || !gvjs_Vq(b)) {
            var m = gvjs_Ph();
            d = d || m.createElementNS(gvjs_Ep, gvjs_Qp);
            d.setAttribute("x", l);
            d.setAttribute("y", g);
            d.setAttribute(gvjs_Xd, h);
            d.setAttribute(gvjs_4c, k);
            null != e && typeof e === gvjs_g && d.setAttribute("rx", e);
            null != f && typeof f === gvjs_g && d.setAttribute("ry", f);
            gvjs_zq(a, d, b, c)
        } else
            b = gvjs_Wq(b),
            d = gvjs_Sq(a, c, b, d);
        c && d.parentNode !== c && c.appendChild(d);
        return d
    },
    Lf: function(a, b, c, d, e) {
        if (!gvjs_Iq(a, e, c, b, d))
            switch (c) {
            case gvjs_$o:
            case gvjs_ap:
            case gvjs_bp:
            case gvjs_cp:
            case gvjs_dp:
            case gvjs_ep:
            case gvjs_6o:
            case gvjs_7o:
            case gvjs_8o:
            case gvjs_9o:
                var f = gvjs_Vq(b)
                  , g = e.tagName.toLowerCase();
                if (g === gvjs_Lp && !f || g === gvjs_Qp && f)
                    return gvjs_Xq.draw(a, b, d);
                g === gvjs_Lp ? (a = gvjs_Wq(b),
                a = gvjs_Tq(a),
                e.setAttribute("d", a)) : c === gvjs_$o ? e.setAttribute("rx", gvjs_L(gvjs_xq(b), gvjs_$o)) : c === gvjs_ap && e.setAttribute("ry", gvjs_L(gvjs_xq(b), gvjs_ap));
                break;
            default:
                throw 'unknown property on rect "' + c + '".';
            }
    }
};
var gvjs_Yq = {};
function gvjs_Zq(a, b, c) {
    a = c.style(gvjs_vp) || c.style(gvjs_xp) || c.style(gvjs_yp);
    b.style.fontFamily = typeof a === gvjs_l ? a : ""
}
function gvjs__q(a, b, c) {
    a = c.style(gvjs_wp) || c.style(gvjs_zp);
    b.style.fontSize = typeof a === gvjs_g ? a + gvjs_T : typeof a === gvjs_l ? a : ""
}
function gvjs_0q(a, b, c) {
    a = c.style("font.weight") || c.style("fontWeight");
    b.style.fontWeight = typeof a === gvjs_l || typeof a === gvjs_g ? String(a) : ""
}
function gvjs_1q(a, b, c) {
    !0 === c.style(gvjs_Gp) ? b.style.fontStyle = gvjs_Gp : b.style.fontStyle = ""
}
function gvjs_2q(a, b, c) {
    !0 === c.style(gvjs_bq) ? b.style.textDecoration = gvjs_bq : b.style.textDecoration = ""
}
var gvjs_3q = {
    "font.family": gvjs_Zq,
    fontFamily: gvjs_Zq,
    fontName: gvjs_Zq,
    "font.size": gvjs__q,
    fontSize: gvjs__q,
    "font.weight": gvjs_0q,
    fontWeight: gvjs_0q,
    italic: gvjs_1q,
    underline: gvjs_2q
};
function gvjs_4q(a, b, c, d, e, f, g, h) {
    var k = gvjs_Ph();
    f = f || gvjs_m;
    e = !e || f && e.tagName !== f ? k.createElementNS(gvjs_Ep, f) : e;
    e.textContent = c;
    c = gvjs_xq(d);
    e.setAttribute("x", null == g ? gvjs_kq(c, "x") : g);
    e.setAttribute("y", null == h ? gvjs_kq(c, "y") : h);
    e.setAttribute(gvjs_Jd, "cursor:default;-webkit-user-select:none;-moz-osx-font-smoothing:grayscale;");
    e.style.webkitFontSmoothing = "antialiased";
    gvjs_zq(a, e, d, b);
    gvjs_1q(a, e, d);
    gvjs_2q(a, e, d);
    gvjs_Zq(a, e, d);
    gvjs__q(a, e, d);
    gvjs_0q(a, e, d);
    return e
}
function gvjs_5q(a, b, c, d) {
    var e = b.style("lineSpacing") || b.style("line-spacing") || 0
      , f = gvjs_xq(b)
      , g = gvjs_J(f, gvjs_m, "")
      , h = -1 == gvjs_mq(g, void 0) && gvjs_y;
    typeof g === gvjs_l && (g = g.split("\n"));
    var k = gvjs_L(f, "y", 0)
      , l = !0;
    1 === g.length && (g = g[0],
    l = !1);
    a = gvjs_4q(a, c, l ? "" : g, b, d, null, gvjs_L(f, "x", 0), k);
    c && a.parentNode !== c && c.appendChild(a);
    c = [];
    if (l)
        for (b = gvjs_Ph(),
        d = 0,
        k = g.length; d < k; d++) {
            var m = b.createElementNS(gvjs_Ep, "tspan");
            m.textContent = g[d];
            m.setAttribute(gvjs_Pp, !0);
            m.setAttribute("x", gvjs_kq(f, "x"));
            m.setAttribute("y", gvjs_kq(f, "y"));
            var n = a.getBBox().height;
            0 < d && (n += e);
            m.setAttribute("dy", n + gvjs_T);
            a.appendChild(m);
            c.push(m)
        }
    h && (a.setAttribute("dir", gvjs_Up),
    a.setAttribute(gvjs_$p, gvjs_R));
    return {
        group: a,
        lines: l ? c : [a]
    }
}
function gvjs_6q(a, b, c, d) {
    c = gvjs_5q(a, b, c, d);
    a = c.lines;
    c = c.group;
    d = Math.max(0, Math.min(1, b.style(gvjs_Dp) || 0));
    if (isNaN(d) || !isFinite(d))
        d = 0;
    var e = b.style(gvjs_eq);
    if (typeof e === gvjs_g) {
        if (e = Math.max(0, Math.min(1, e)),
        isNaN(e) || !isFinite(e))
            e = 0
    } else
        e = gvjs_Xo;
    var f = c.getBBox()
      , g = b.style("y") - f.y;
    var h = "tspan" === a[a.length - 1].tagName.toLowerCase() ? a[a.length - 1].getBoundingClientRect().top - c.getBoundingClientRect().top : a[a.length - 1].getBBox().y - f.y;
    var k = b.style("y");
    if (null == k)
        return c;
    if (typeof e === gvjs_g)
        k = k + g - f.height * e;
    else if (e === gvjs_Xo)
        k = k + g - h;
    else
        throw "Unrecognized valign value: " + e;
    c.setAttribute("y", k);
    e = 0;
    for (f = a.length; e < f; e++)
        g = a[e],
        g.setAttribute("dx", -g.getComputedTextLength() * d + gvjs_T),
        g.setAttribute("y", k);
    a = b.style(gvjs_Sp);
    null != a && 0 != a && c.setAttribute(gvjs_aq, gvjs_Tp + a + " " + b.style("x") + " " + b.style("y") + ")");
    return c
}
gvjs_Yq.gCa = gvjs_Zq;
gvjs_Yq.hCa = gvjs__q;
gvjs_Yq.iCa = gvjs_0q;
gvjs_Yq.jCa = gvjs_1q;
gvjs_Yq.mCa = gvjs_2q;
gvjs_Yq.BCa = gvjs_4q;
gvjs_Yq.draw = gvjs_6q;
gvjs_Yq.ICa = gvjs_5q;
gvjs_Yq.DK = gvjs_3q;
gvjs_Yq.Lf = function(a, b, c, d, e) {
    var f = "x" === c || "y" === c;
    if (f || !gvjs_Iq(a, e, c, b, d, gvjs_3q))
        if (c === gvjs_m || c === gvjs_Dp || c === gvjs_eq || f) {
            for (; e && e.firstChild; )
                e.removeChild(e.firstChild);
            a = gvjs_6q(a, b, d, e);
            if (e !== a)
                throw "error redrawing text";
        } else
            throw 'error redrawing text element with changed property "' + c + '".';
}
;
var gvjs_7q = {
    draw: function(a, b, c, d) {
        var e = gvjs_Ph();
        d = d || e.createElementNS(gvjs_Ep, "g");
        gvjs_zq(a, d, b, c);
        c && d.parentNode !== c && c.appendChild(d);
        return d
    },
    Lf: function(a, b, c, d) {
        a = gvjs_7q.draw(a, b, c, d);
        d !== a && b.getContext().fireEvent("add", [b, a, !1])
    }
};
var gvjs_jda = {
    Circle: gvjs_Jq,
    Ellipse: gvjs_Kq,
    Line: gvjs_Qq,
    Path: {
        draw: function(a, b, c, d) {
            a = gvjs_Sq(a, c, b, d);
            c && a.parentNode !== c && c.appendChild(a);
            return a
        },
        Lf: function(a, b, c, d, e) {
            if (!gvjs_Iq(a, e, c, b, d))
                throw gvjs_cq + c + '".';
        }
    },
    Rect: gvjs_Xq,
    Text: gvjs_Yq,
    Group: gvjs_7q
};
/*

 Copyright 2021 Google LLC
 This code is released under the MIT license.
 SPDX-License-Identifier: MIT

*/
/*

 Copyright 2021 Google LLC
 This code is released under the MIT license.
 SPDX-License-Identifier: MIT
*/
function gvjs_8q(a) {
    gvjs_F.call(this);
    this.Y9 = a
}
gvjs_o(gvjs_8q, gvjs_F);
gvjs_8q.prototype.Is = gvjs_n(33);
gvjs_8q.prototype.dispatchEvent = function(a, b) {
    gvjs_I(this.Y9, a, void 0 === b ? null : b)
}
;
gvjs_8q.prototype.M = function() {
    this.Y9 = null;
    gvjs_F.prototype.M.call(this)
}
;
function gvjs_9q(a, b, c, d, e) {
    if (null == a || null == b)
        null == c && (c = e),
        c = Math.max(0, d - c),
        null == a && null == b ? a = b = c / 2 : null == a ? a = Math.max(0, c - b) : b = Math.max(0, c - a);
    c = Math.max(0, Math.round(d - (a + b)));
    a = Math.round(a);
    d = Math.min(d, a + c);
    return {
        before: a,
        after: d,
        size: d - a
    }
}
function gvjs_$q(a, b, c) {
    var d = a / 1.618
      , e = a - b * (1.618 - 1)
      , f = b / 1.618
      , g = b - a * (1.618 - 1);
    a = gvjs_9q(c.left, c.right, c.width, a, Math.round(d > e ? d : (d + 2 * e) / 3));
    b = gvjs_9q(c.top, c.bottom, c.height, b, Math.round(f > g ? f : (f + 2 * g) / 3));
    return {
        left: a.before,
        right: a.after,
        width: a.size,
        top: b.before,
        bottom: b.after,
        height: b.size
    }
}
;