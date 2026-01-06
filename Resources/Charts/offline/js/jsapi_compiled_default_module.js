/*

 Copyright The Closure Library Authors.
 SPDX-License-Identifier: Apache-2.0
*/
var gvjs_aa = " does not match type ", gvjs_ba = " must be of type '", gvjs_ca = "#000000", gvjs_da = "#808080", gvjs_ea = "#ffffff", gvjs_fa = "&lt;", gvjs_ga = "&quot;", gvjs_ha = ", ", gvjs_ia = ', for column "', gvjs_ja = ".format", gvjs_ka = "0000000000000000", gvjs_a = "</div>", gvjs_la = "<br>", gvjs_ma = "AnnotatedTimeLine", gvjs_na = "AreaChart", gvjs_oa = "AreaChart-stacked", gvjs_pa = "August", gvjs_qa = "BarChart", gvjs_ra = "BubbleChart", gvjs_sa = "CSSStyleDeclaration", gvjs_ta = "Can't combine significant digits and minimum fraction digits", gvjs_ua = "CandlestickChart", gvjs_va = "Clobbering detected", gvjs_wa = "Column ", gvjs_xa = "ColumnChart", gvjs_ya = "ComboChart", gvjs_za = "Container is not defined", gvjs_Aa = "Custom response handler must be a function.", gvjs_b = "DIV", gvjs_Ba = "December", gvjs_Ca = "Edge", gvjs_Da = "Element", gvjs_Ea = "February", gvjs_Fa = "Friday", gvjs_Ga = "Gauge", gvjs_Ha = "GeoChart", gvjs_Ia = "HH:mm", gvjs_Ja = "HH:mm:ss", gvjs_Ka = "HH:mm:ss.SSS", gvjs_La = "Histogram", gvjs_Ma = "IFRAME", gvjs_Na = "INPUT", gvjs_Oa = "ImageRadarChart", gvjs_Pa = "ImageSparkLine", gvjs_Qa = "Inconsistent use of percent/permill characters", gvjs_Ra = "Invalid DataView column type.", gvjs_Sa = "Invalid data table format: column #", gvjs_Ta = "Invalid value for numOrArray: ", gvjs_Ua = "January", gvjs_Va = "LineChart", gvjs_Wa = "Map", gvjs_Xa = "May", gvjs_Ya = "Monday", gvjs_Za = "MotionChart", gvjs__a = "November", gvjs_0a = "OBJECT", gvjs_1a = "October", gvjs_2a = "OrgChart", gvjs_3a = "PieChart", gvjs_4a = "Request timed out", gvjs_5a = "SOURCE", gvjs_6a = "SPAN", gvjs_7a = "STYLE", gvjs_8a = "Saturday", gvjs_9a = "ScatterChart", gvjs_$a = "September", gvjs_ab = "SteppedAreaChart", gvjs_bb = "Sunday", gvjs_cb = "Symbol.iterator", gvjs_db = "Table", gvjs_eb = "Thursday", gvjs_fb = "Timeline", gvjs_gb = "Too many percent/permill", gvjs_hb = "TreeMap", gvjs_ib = "Tuesday", gvjs_jb = "Type mismatch. Value ", gvjs_kb = "Uneven number of arguments", gvjs_lb = "Wednesday", gvjs_mb = "WordTree", gvjs_nb = "_bar_format_old_value", gvjs_ob = "about:invalid#zClosurez", gvjs_c = "absolute", gvjs_pb = "addTrendLine", gvjs_qb = "annotatedtimeline", gvjs_rb = "annotationchart", gvjs_sb = "array", gvjs_tb = "attributes", gvjs_ub = "auto", gvjs_vb = "background-color:", gvjs_wb = "bar", gvjs_xb = "block", gvjs_yb = "body", gvjs_zb = "boolean", gvjs_Ab = "cancel", gvjs_Bb = "chart", gvjs_Cb = "class", gvjs_Db = "className", gvjs_Eb = "color:", gvjs_Fb = "column", gvjs_Gb = "columnFilters[", gvjs_Hb = "complete", gvjs_Ib = "controls", gvjs_Jb = "corechart", gvjs_Kb = "data-sanitizer-", gvjs_Lb = "date", gvjs_Mb = "datetime", gvjs_Nb = "decimal", gvjs_Ob = "div", gvjs_Pb = "domainAxis", gvjs_Qb = "drawing", gvjs_Rb = "error", gvjs_Sb = "false", gvjs_Tb = "full", gvjs_d = "function", gvjs_Ub = "geochart", gvjs_Vb = "getAttribute", gvjs_Wb = "getElementsByTagName", gvjs_Xb = "getPropertyValue", gvjs_Yb = "google.charts.", gvjs_Zb = "google.charts.Bar", gvjs__b = "google.charts.Line", gvjs_0b = "google.charts.Scatter", gvjs_1b = "google.visualization.", gvjs_2b = "google.visualization.AnnotatedTimeLine", gvjs_3b = "google.visualization.AnnotationChart", gvjs_4b = "google.visualization.AreaChart", gvjs_5b = "google.visualization.BarChart", gvjs_6b = "google.visualization.BubbleChart", gvjs_7b = "google.visualization.Bubbles", gvjs_8b = "google.visualization.CandlestickChart", gvjs_9b = "google.visualization.CategoryFilter", gvjs_$b = "google.visualization.ChartRangeFilter", gvjs_ac = "google.visualization.ChartRangeFilterUi", gvjs_bc = "google.visualization.ClusterChart", gvjs_cc = "google.visualization.ColumnChart", gvjs_dc = "google.visualization.ColumnSelector", gvjs_ec = "google.visualization.ComboChart", gvjs_fc = "google.visualization.CoreChart", gvjs_gc = "google.visualization.Dashboard", gvjs_hc = "google.visualization.DashboardWrapper", gvjs_ic = "google.visualization.DateRangeFilter", gvjs_jc = "google.visualization.DateRangeFilterUi", gvjs_kc = "google.visualization.Filter", gvjs_lc = "google.visualization.Gantt", gvjs_mc = "google.visualization.Gauge", gvjs_nc = "google.visualization.GeoChart", gvjs_oc = "google.visualization.GeoMap", gvjs_pc = "google.visualization.HeadlessUi", gvjs_qc = "google.visualization.HelloWorld", gvjs_rc = "google.visualization.Histogram", gvjs_sc = "google.visualization.ImageAreaChart", gvjs_tc = "google.visualization.ImageBarChart", gvjs_uc = "google.visualization.ImageCandlestickChart", gvjs_vc = "google.visualization.ImageChart", gvjs_wc = "google.visualization.ImageLineChart", gvjs_xc = "google.visualization.ImagePieChart", gvjs_yc = "google.visualization.ImageSparkLine", gvjs_zc = "google.visualization.LineChart", gvjs_Ac = "google.visualization.Map", gvjs_Bc = "google.visualization.Matrix", gvjs_Cc = "google.visualization.MotionChart", gvjs_Dc = "google.visualization.NumberFormat", gvjs_Ec = "google.visualization.NumberRangeFilter", gvjs_Fc = "google.visualization.NumberRangeSetter", gvjs_Gc = "google.visualization.NumberRangeUi", gvjs_Hc = "google.visualization.Operator", gvjs_Ic = "google.visualization.OrgChart", gvjs_Jc = "google.visualization.PieChart", gvjs_Kc = "google.visualization.Query", gvjs_Lc = "google.visualization.RangeSelector", gvjs_Mc = "google.visualization.Sankey", gvjs_Nc = "google.visualization.ScatterChart", gvjs_Oc = "google.visualization.SelectorUi", gvjs_Pc = "google.visualization.SparklineChart", gvjs_Qc = "google.visualization.SteppedAreaChart", gvjs_Rc = "google.visualization.Streamgraph", gvjs_Sc = "google.visualization.StringFilter", gvjs_Tc = "google.visualization.StringFilterUi", gvjs_Uc = "google.visualization.Sunburst", gvjs_Vc = "google.visualization.Table", gvjs_Wc = "google.visualization.TableTextChart", gvjs_Xc = "google.visualization.Timeline", gvjs_Yc = "google.visualization.TreeMap", gvjs_Zc = "google.visualization.VegaChart", gvjs__c = "google.visualization.Version", gvjs_0c = "google.visualization.WordTree", gvjs_1c = "google.visualization.WordcloudChart", gvjs_2c = "hasAttribute", gvjs_3c = "hasLabelsColumn", gvjs_4c = "height", gvjs_5c = "id", gvjs_6c = "imagechart", gvjs_7c = "keypress", gvjs_8c = "label", gvjs_9c = "latlng", gvjs_$c = "left", gvjs_e = "line", gvjs_ad = "makeRequest", gvjs_bd = "markers", gvjs_cd = "maxValue", gvjs_dd = "medium", gvjs_ed = "minValue", gvjs_fd = "motionchart", gvjs_gd = "mousedown", gvjs_hd = "mouseenter", gvjs_id = "mouseleave", gvjs_jd = "mousemove", gvjs_kd = "mouseout", gvjs_ld = "mouseover", gvjs_md = "mouseup", gvjs_nd = "msMatchesSelector", gvjs_od = "nodeName", gvjs_pd = "nodeType", gvjs_qd = "nonce", gvjs_f = "none", gvjs_rd = "null", gvjs_g = "number", gvjs_h = "object", gvjs_sd = "orgchart", gvjs_td = "pattern", gvjs_ud = "percent", gvjs_vd = "position", gvjs_wd = "prefix", gvjs_i = "ready", gvjs_xd = "regioncode", gvjs_yd = "regions", gvjs_zd = "relative", gvjs_Ad = "removeAttribute", gvjs_j = "right", gvjs_Bd = "role", gvjs_Cd = "row", gvjs_Dd = "scatter", gvjs_Ed = "script[nonce]", gvjs_k = "select", gvjs_Fd = "setAttribute", gvjs_Gd = "short", gvjs_Hd = "statechange", gvjs_l = "string", gvjs_Id = "stringify", gvjs_Jd = "style", gvjs_Kd = "suffix", gvjs_Ld = "table", gvjs_Md = "targetAxis", gvjs_m = "text", gvjs_Nd = "timeline", gvjs_Od = "timeofday", gvjs_Pd = "tooltip", gvjs_Qd = "transparent", gvjs_Rd = "true", gvjs_Sd = "type", gvjs_Td = "unhandledrejection", gvjs_Ud = "vAxis", gvjs_Vd = "value", gvjs_Wd = "warning", gvjs_Xd = "width", gvjs_Yd = "withCredentials", gvjs_Zd = "wordtree", gvjs__d = "zClosurez", gvjs_0d = "{1} 'at' {0}", gvjs_1d = "{1}, {0}", gvjs_, gvjs_2d = [];
function gvjs_n(a) {
    return function() {
        return gvjs_2d[a].apply(this, arguments)
    }
}
function gvjs_3d(a) {
    var b = 0;
    return function() {
        return b < a.length ? {
            done: !1,
            value: a[b++]
        } : {
            done: !0
        }
    }
}
var gvjs_4d = typeof Object.defineProperties == gvjs_d ? Object.defineProperty : function(a, b, c) {
    if (a == Array.prototype || a == Object.prototype)
        return a;
    a[b] = c.value;
    return a
}
;
function gvjs_aaa(a) {
    a = [gvjs_h == typeof globalThis && globalThis, a, gvjs_h == typeof window && window, gvjs_h == typeof self && self, gvjs_h == typeof global && global];
    for (var b = 0; b < a.length; ++b) {
        var c = a[b];
        if (c && c.Math == Math)
            return c
    }
    throw Error("Cannot find global object");
}
var gvjs_5d = gvjs_aaa(this);
function gvjs_6d(a, b) {
    if (b)
        a: {
            var c = gvjs_5d;
            a = a.split(".");
            for (var d = 0; d < a.length - 1; d++) {
                var e = a[d];
                if (!(e in c))
                    break a;
                c = c[e]
            }
            a = a[a.length - 1];
            d = c[a];
            b = b(d);
            b != d && null != b && gvjs_4d(c, a, {
                configurable: !0,
                writable: !0,
                value: b
            })
        }
}
gvjs_6d("Symbol", function(a) {
    function b(f) {
        if (this instanceof b)
            throw new TypeError("Symbol is not a constructor");
        return new c(d + (f || "") + "_" + e++,f)
    }
    function c(f, g) {
        this.Nha = f;
        gvjs_4d(this, "description", {
            configurable: !0,
            writable: !0,
            value: g
        })
    }
    if (a)
        return a;
    c.prototype.toString = function() {
        return this.Nha
    }
    ;
    var d = "jscomp_symbol_" + (1E9 * Math.random() >>> 0) + "_"
      , e = 0;
    return b
});
gvjs_6d(gvjs_cb, function(a) {
    if (a)
        return a;
    a = Symbol(gvjs_cb);
    for (var b = "Array Int8Array Uint8Array Uint8ClampedArray Int16Array Uint16Array Int32Array Uint32Array Float32Array Float64Array".split(" "), c = 0; c < b.length; c++) {
        var d = gvjs_5d[b[c]];
        typeof d === gvjs_d && typeof d.prototype[a] != gvjs_d && gvjs_4d(d.prototype, a, {
            configurable: !0,
            writable: !0,
            value: function() {
                return gvjs_7d(gvjs_3d(this))
            }
        })
    }
    return a
});
function gvjs_7d(a) {
    a = {
        next: a
    };
    a[Symbol.iterator] = function() {
        return this
    }
    ;
    return a
}
function gvjs_8d(a) {
    var b = "undefined" != typeof Symbol && Symbol.iterator && a[Symbol.iterator];
    return b ? b.call(a) : {
        next: gvjs_3d(a)
    }
}
function gvjs_9d(a) {
    if (!(a instanceof Array)) {
        a = gvjs_8d(a);
        for (var b, c = []; !(b = a.next()).done; )
            c.push(b.value);
        a = c
    }
    return a
}
var gvjs_baa = typeof Object.create == gvjs_d ? Object.create : function(a) {
    function b() {}
    b.prototype = a;
    return new b
}
, gvjs_$d;
if (typeof Object.setPrototypeOf == gvjs_d)
    gvjs_$d = Object.setPrototypeOf;
else {
    var gvjs_ae;
    a: {
        var gvjs_caa = {
            a: !0
        }
          , gvjs_be = {};
        try {
            gvjs_be.__proto__ = gvjs_caa;
            gvjs_ae = gvjs_be.a;
            break a
        } catch (a) {}
        gvjs_ae = !1
    }
    gvjs_$d = gvjs_ae ? function(a, b) {
        a.__proto__ = b;
        if (a.__proto__ !== b)
            throw new TypeError(a + " is not extensible");
        return a
    }
    : null
}
var gvjs_ce = gvjs_$d;
function gvjs_o(a, b) {
    a.prototype = gvjs_baa(b.prototype);
    a.prototype.constructor = a;
    if (gvjs_ce)
        gvjs_ce(a, b);
    else
        for (var c in b)
            if ("prototype" != c)
                if (Object.defineProperties) {
                    var d = Object.getOwnPropertyDescriptor(b, c);
                    d && Object.defineProperty(a, c, d)
                } else
                    a[c] = b[c];
    a.G = b.prototype
}
function gvjs_de(a, b) {
    return Object.prototype.hasOwnProperty.call(a, b)
}
gvjs_6d("WeakMap", function(a) {
    function b(k) {
        this.ac = (h += Math.random() + 1).toString();
        if (k) {
            k = gvjs_8d(k);
            for (var l; !(l = k.next()).done; )
                l = l.value,
                this.set(l[0], l[1])
        }
    }
    function c() {}
    function d(k) {
        var l = typeof k;
        return l === gvjs_h && null !== k || l === gvjs_d
    }
    function e(k) {
        if (!gvjs_de(k, g)) {
            var l = new c;
            gvjs_4d(k, g, {
                value: l
            })
        }
    }
    function f(k) {
        var l = Object[k];
        l && (Object[k] = function(m) {
            if (m instanceof c)
                return m;
            Object.isExtensible(m) && e(m);
            return l(m)
        }
        )
    }
    if (function() {
        if (!a || !Object.seal)
            return !1;
        try {
            var k = Object.seal({})
              , l = Object.seal({})
              , m = new a([[k, 2], [l, 3]]);
            if (2 != m.get(k) || 3 != m.get(l))
                return !1;
            m.delete(k);
            m.set(l, 4);
            return !m.has(k) && 4 == m.get(l)
        } catch (n) {
            return !1
        }
    }())
        return a;
    var g = "$jscomp_hidden_" + Math.random();
    f("freeze");
    f("preventExtensions");
    f("seal");
    var h = 0;
    b.prototype.set = function(k, l) {
        if (!d(k))
            throw Error("Invalid WeakMap key");
        e(k);
        if (!gvjs_de(k, g))
            throw Error("WeakMap key fail: " + k);
        k[g][this.ac] = l;
        return this
    }
    ;
    b.prototype.get = function(k) {
        return d(k) && gvjs_de(k, g) ? k[g][this.ac] : void 0
    }
    ;
    b.prototype.has = function(k) {
        return d(k) && gvjs_de(k, g) && gvjs_de(k[g], this.ac)
    }
    ;
    b.prototype.delete = function(k) {
        return d(k) && gvjs_de(k, g) && gvjs_de(k[g], this.ac) ? delete k[g][this.ac] : !1
    }
    ;
    return b
});
gvjs_6d(gvjs_Wa, function(a) {
    function b() {
        var h = {};
        return h.he = h.next = h.head = h
    }
    function c(h, k) {
        var l = h.pc;
        return gvjs_7d(function() {
            if (l) {
                for (; l.head != h.pc; )
                    l = l.he;
                for (; l.next != l.head; )
                    return l = l.next,
                    {
                        done: !1,
                        value: k(l)
                    };
                l = null
            }
            return {
                done: !0,
                value: void 0
            }
        })
    }
    function d(h, k) {
        var l = k && typeof k;
        l == gvjs_h || l == gvjs_d ? f.has(k) ? l = f.get(k) : (l = "" + ++g,
        f.set(k, l)) : l = "p_" + k;
        var m = h.ra[l];
        if (m && gvjs_de(h.ra, l))
            for (h = 0; h < m.length; h++) {
                var n = m[h];
                if (k !== k && n.key !== n.key || k === n.key)
                    return {
                        id: l,
                        list: m,
                        index: h,
                        Xc: n
                    }
            }
        return {
            id: l,
            list: m,
            index: -1,
            Xc: void 0
        }
    }
    function e(h) {
        this.ra = {};
        this.pc = b();
        this.size = 0;
        if (h) {
            h = gvjs_8d(h);
            for (var k; !(k = h.next()).done; )
                k = k.value,
                this.set(k[0], k[1])
        }
    }
    if (function() {
        if (!a || typeof a != gvjs_d || !a.prototype.entries || typeof Object.seal != gvjs_d)
            return !1;
        try {
            var h = Object.seal({
                x: 4
            })
              , k = new a(gvjs_8d([[h, "s"]]));
            if ("s" != k.get(h) || 1 != k.size || k.get({
                x: 4
            }) || k.set({
                x: 4
            }, "t") != k || 2 != k.size)
                return !1;
            var l = k.entries()
              , m = l.next();
            if (m.done || m.value[0] != h || "s" != m.value[1])
                return !1;
            m = l.next();
            return m.done || 4 != m.value[0].x || "t" != m.value[1] || !l.next().done ? !1 : !0
        } catch (n) {
            return !1
        }
    }())
        return a;
    var f = new WeakMap;
    e.prototype.set = function(h, k) {
        h = 0 === h ? 0 : h;
        var l = d(this, h);
        l.list || (l.list = this.ra[l.id] = []);
        l.Xc ? l.Xc.value = k : (l.Xc = {
            next: this.pc,
            he: this.pc.he,
            head: this.pc,
            key: h,
            value: k
        },
        l.list.push(l.Xc),
        this.pc.he.next = l.Xc,
        this.pc.he = l.Xc,
        this.size++);
        return this
    }
    ;
    e.prototype.delete = function(h) {
        h = d(this, h);
        return h.Xc && h.list ? (h.list.splice(h.index, 1),
        h.list.length || delete this.ra[h.id],
        h.Xc.he.next = h.Xc.next,
        h.Xc.next.he = h.Xc.he,
        h.Xc.head = null,
        this.size--,
        !0) : !1
    }
    ;
    e.prototype.clear = function() {
        this.ra = {};
        this.pc = this.pc.he = b();
        this.size = 0
    }
    ;
    e.prototype.has = function(h) {
        return !!d(this, h).Xc
    }
    ;
    e.prototype.get = function(h) {
        return (h = d(this, h).Xc) && h.value
    }
    ;
    e.prototype.entries = function() {
        return c(this, function(h) {
            return [h.key, h.value]
        })
    }
    ;
    e.prototype.keys = function() {
        return c(this, function(h) {
            return h.key
        })
    }
    ;
    e.prototype.values = function() {
        return c(this, function(h) {
            return h.value
        })
    }
    ;
    e.prototype.forEach = function(h, k) {
        for (var l = this.entries(), m; !(m = l.next()).done; )
            m = m.value,
            h.call(k, m[1], m[0], this)
    }
    ;
    e.prototype[Symbol.iterator] = e.prototype.entries;
    var g = 0;
    return e
});
function gvjs_ee(a, b, c) {
    if (null == a)
        throw new TypeError("The 'this' value for String.prototype." + c + " must not be null or undefined");
    if (b instanceof RegExp)
        throw new TypeError("First argument to String.prototype." + c + " must not be a regular expression");
    return a + ""
}
gvjs_6d("String.prototype.endsWith", function(a) {
    return a ? a : function(b, c) {
        var d = gvjs_ee(this, b, "endsWith");
        b += "";
        void 0 === c && (c = d.length);
        c = Math.max(0, Math.min(c | 0, d.length));
        for (var e = b.length; 0 < e && 0 < c; )
            if (d[--c] != b[--e])
                return !1;
        return 0 >= e
    }
});
function gvjs_fe(a, b, c) {
    a instanceof String && (a = String(a));
    for (var d = a.length, e = 0; e < d; e++) {
        var f = a[e];
        if (b.call(c, f, e, a))
            return {
                Ud: e,
                v: f
            }
    }
    return {
        Ud: -1,
        v: void 0
    }
}
gvjs_6d("Array.prototype.find", function(a) {
    return a ? a : function(b, c) {
        return gvjs_fe(this, b, c).v
    }
});
gvjs_6d("String.prototype.startsWith", function(a) {
    return a ? a : function(b, c) {
        var d = gvjs_ee(this, b, "startsWith");
        b += "";
        var e = d.length
          , f = b.length;
        c = Math.max(0, Math.min(c | 0, d.length));
        for (var g = 0; g < f && c < e; )
            if (d[c++] != b[g++])
                return !1;
        return g >= f
    }
});
gvjs_6d("String.prototype.repeat", function(a) {
    return a ? a : function(b) {
        var c = gvjs_ee(this, null, "repeat");
        if (0 > b || 1342177279 < b)
            throw new RangeError("Invalid count value");
        b |= 0;
        for (var d = ""; b; )
            if (b & 1 && (d += c),
            b >>>= 1)
                c += c;
        return d
    }
});
function gvjs_ge(a, b) {
    a instanceof String && (a += "");
    var c = 0
      , d = !1
      , e = {
        next: function() {
            if (!d && c < a.length) {
                var f = c++;
                return {
                    value: b(f, a[f]),
                    done: !1
                }
            }
            d = !0;
            return {
                done: !0,
                value: void 0
            }
        }
    };
    e[Symbol.iterator] = function() {
        return e
    }
    ;
    return e
}
gvjs_6d("Array.prototype.entries", function(a) {
    return a ? a : function() {
        return gvjs_ge(this, function(b, c) {
            return [b, c]
        })
    }
});
var gvjs_daa = typeof Object.assign == gvjs_d ? Object.assign : function(a, b) {
    for (var c = 1; c < arguments.length; c++) {
        var d = arguments[c];
        if (d)
            for (var e in d)
                gvjs_de(d, e) && (a[e] = d[e])
    }
    return a
}
;
gvjs_6d("Object.assign", function(a) {
    return a || gvjs_daa
});
gvjs_6d("Promise", function(a) {
    function b(g) {
        this.K = 0;
        this.ik = void 0;
        this.WD = [];
        this.Mba = !1;
        var h = this.vX();
        try {
            g(h.resolve, h.reject)
        } catch (k) {
            h.reject(k)
        }
    }
    function c() {
        this.Iu = null
    }
    function d(g) {
        return g instanceof b ? g : new b(function(h) {
            h(g)
        }
        )
    }
    if (a)
        return a;
    c.prototype.u7 = function(g) {
        if (null == this.Iu) {
            this.Iu = [];
            var h = this;
            this.v7(function() {
                h.Wna()
            })
        }
        this.Iu.push(g)
    }
    ;
    var e = gvjs_5d.setTimeout;
    c.prototype.v7 = function(g) {
        e(g, 0)
    }
    ;
    c.prototype.Wna = function() {
        for (; this.Iu && this.Iu.length; ) {
            var g = this.Iu;
            this.Iu = [];
            for (var h = 0; h < g.length; ++h) {
                var k = g[h];
                g[h] = null;
                try {
                    k()
                } catch (l) {
                    this.Aka(l)
                }
            }
        }
        this.Iu = null
    }
    ;
    c.prototype.Aka = function(g) {
        this.v7(function() {
            throw g;
        })
    }
    ;
    b.prototype.vX = function() {
        function g(l) {
            return function(m) {
                k || (k = !0,
                l.call(h, m))
            }
        }
        var h = this
          , k = !1;
        return {
            resolve: g(this.Kva),
            reject: g(this.T2)
        }
    }
    ;
    b.prototype.Kva = function(g) {
        if (g === this)
            this.T2(new TypeError("A Promise cannot resolve to itself"));
        else if (g instanceof b)
            this.Mwa(g);
        else {
            a: switch (typeof g) {
            case gvjs_h:
                var h = null != g;
                break a;
            case gvjs_d:
                h = !0;
                break a;
            default:
                h = !1
            }
            h ? this.Jva(g) : this.B$(g)
        }
    }
    ;
    b.prototype.Jva = function(g) {
        var h = void 0;
        try {
            h = g.then
        } catch (k) {
            this.T2(k);
            return
        }
        typeof h == gvjs_d ? this.Nwa(h, g) : this.B$(g)
    }
    ;
    b.prototype.T2 = function(g) {
        this.Kfa(2, g)
    }
    ;
    b.prototype.B$ = function(g) {
        this.Kfa(1, g)
    }
    ;
    b.prototype.Kfa = function(g, h) {
        if (0 != this.K)
            throw Error("Cannot settle(" + g + gvjs_ha + h + "): Promise already settled in state" + this.K);
        this.K = g;
        this.ik = h;
        2 === this.K && this.cwa();
        this.Yna()
    }
    ;
    b.prototype.cwa = function() {
        var g = this;
        e(function() {
            if (g.Xta()) {
                var h = gvjs_5d.console;
                "undefined" !== typeof h && h.error(g.ik)
            }
        }, 1)
    }
    ;
    b.prototype.Xta = function() {
        if (this.Mba)
            return !1;
        var g = gvjs_5d.CustomEvent
          , h = gvjs_5d.Event
          , k = gvjs_5d.dispatchEvent;
        if ("undefined" === typeof k)
            return !0;
        typeof g === gvjs_d ? g = new g(gvjs_Td,{
            cancelable: !0
        }) : typeof h === gvjs_d ? g = new h(gvjs_Td,{
            cancelable: !0
        }) : (g = gvjs_5d.document.createEvent("CustomEvent"),
        g.initCustomEvent(gvjs_Td, !1, !0, g));
        g.promise = this;
        g.reason = this.ik;
        return k(g)
    }
    ;
    b.prototype.Yna = function() {
        if (null != this.WD) {
            for (var g = 0; g < this.WD.length; ++g)
                f.u7(this.WD[g]);
            this.WD = null
        }
    }
    ;
    var f = new c;
    b.prototype.Mwa = function(g) {
        var h = this.vX();
        g.xN(h.resolve, h.reject)
    }
    ;
    b.prototype.Nwa = function(g, h) {
        var k = this.vX();
        try {
            g.call(h, k.resolve, k.reject)
        } catch (l) {
            k.reject(l)
        }
    }
    ;
    b.prototype.then = function(g, h) {
        function k(p, q) {
            return typeof p == gvjs_d ? function(r) {
                try {
                    l(p(r))
                } catch (t) {
                    m(t)
                }
            }
            : q
        }
        var l, m, n = new b(function(p, q) {
            l = p;
            m = q
        }
        );
        this.xN(k(g, l), k(h, m));
        return n
    }
    ;
    b.prototype.catch = function(g) {
        return this.then(void 0, g)
    }
    ;
    b.prototype.xN = function(g, h) {
        function k() {
            switch (l.K) {
            case 1:
                g(l.ik);
                break;
            case 2:
                h(l.ik);
                break;
            default:
                throw Error("Unexpected state: " + l.K);
            }
        }
        var l = this;
        null == this.WD ? f.u7(k) : this.WD.push(k);
        this.Mba = !0
    }
    ;
    b.resolve = d;
    b.reject = function(g) {
        return new b(function(h, k) {
            k(g)
        }
        )
    }
    ;
    b.race = function(g) {
        return new b(function(h, k) {
            for (var l = gvjs_8d(g), m = l.next(); !m.done; m = l.next())
                d(m.value).xN(h, k)
        }
        )
    }
    ;
    b.all = function(g) {
        var h = gvjs_8d(g)
          , k = h.next();
        return k.done ? d([]) : new b(function(l, m) {
            function n(r) {
                return function(t) {
                    p[r] = t;
                    q--;
                    0 == q && l(p)
                }
            }
            var p = []
              , q = 0;
            do
                p.push(void 0),
                q++,
                d(k.value).xN(n(p.length - 1), m),
                k = h.next();
            while (!k.done)
        }
        )
    }
    ;
    return b
});
gvjs_6d("Array.prototype.keys", function(a) {
    return a ? a : function() {
        return gvjs_ge(this, function(b) {
            return b
        })
    }
});
gvjs_6d("Array.from", function(a) {
    return a ? a : function(b, c, d) {
        c = null != c ? c : function(h) {
            return h
        }
        ;
        var e = []
          , f = "undefined" != typeof Symbol && Symbol.iterator && b[Symbol.iterator];
        if (typeof f == gvjs_d) {
            b = f.call(b);
            for (var g = 0; !(f = b.next()).done; )
                e.push(c.call(d, f.value, g++))
        } else
            for (f = b.length,
            g = 0; g < f; g++)
                e.push(c.call(d, b[g], g));
        return e
    }
});
gvjs_6d("Array.prototype.values", function(a) {
    return a ? a : function() {
        return gvjs_ge(this, function(b, c) {
            return c
        })
    }
});
gvjs_6d("Set", function(a) {
    function b(c) {
        this.qa = new Map;
        if (c) {
            c = gvjs_8d(c);
            for (var d; !(d = c.next()).done; )
                this.add(d.value)
        }
        this.size = this.qa.size
    }
    if (function() {
        if (!a || typeof a != gvjs_d || !a.prototype.entries || typeof Object.seal != gvjs_d)
            return !1;
        try {
            var c = Object.seal({
                x: 4
            })
              , d = new a(gvjs_8d([c]));
            if (!d.has(c) || 1 != d.size || d.add(c) != d || 1 != d.size || d.add({
                x: 4
            }) != d || 2 != d.size)
                return !1;
            var e = d.entries()
              , f = e.next();
            if (f.done || f.value[0] != c || f.value[1] != c)
                return !1;
            f = e.next();
            return f.done || f.value[0] == c || 4 != f.value[0].x || f.value[1] != f.value[0] ? !1 : e.next().done
        } catch (g) {
            return !1
        }
    }())
        return a;
    b.prototype.add = function(c) {
        c = 0 === c ? 0 : c;
        this.qa.set(c, c);
        this.size = this.qa.size;
        return this
    }
    ;
    b.prototype.delete = function(c) {
        c = this.qa.delete(c);
        this.size = this.qa.size;
        return c
    }
    ;
    b.prototype.clear = function() {
        this.qa.clear();
        this.size = 0
    }
    ;
    b.prototype.has = function(c) {
        return this.qa.has(c)
    }
    ;
    b.prototype.entries = function() {
        return this.qa.entries()
    }
    ;
    b.prototype.values = function() {
        return this.qa.values()
    }
    ;
    b.prototype.keys = b.prototype.values;
    b.prototype[Symbol.iterator] = b.prototype.values;
    b.prototype.forEach = function(c, d) {
        var e = this;
        this.qa.forEach(function(f) {
            return c.call(d, f, f, e)
        })
    }
    ;
    return b
});
gvjs_6d("Array.prototype.fill", function(a) {
    return a ? a : function(b, c, d) {
        var e = this.length || 0;
        0 > c && (c = Math.max(0, e + c));
        if (null == d || d > e)
            d = e;
        d = Number(d);
        0 > d && (d = Math.max(0, e + d));
        for (c = Number(c || 0); c < d; c++)
            this[c] = b;
        return this
    }
});
function gvjs_he(a) {
    return a ? a : Array.prototype.fill
}
gvjs_6d("Int8Array.prototype.fill", gvjs_he);
gvjs_6d("Uint8Array.prototype.fill", gvjs_he);
gvjs_6d("Uint8ClampedArray.prototype.fill", gvjs_he);
gvjs_6d("Int16Array.prototype.fill", gvjs_he);
gvjs_6d("Uint16Array.prototype.fill", gvjs_he);
gvjs_6d("Int32Array.prototype.fill", gvjs_he);
gvjs_6d("Uint32Array.prototype.fill", gvjs_he);
gvjs_6d("Float32Array.prototype.fill", gvjs_he);
gvjs_6d("Float64Array.prototype.fill", gvjs_he);
gvjs_6d("Object.values", function(a) {
    return a ? a : function(b) {
        var c = [], d;
        for (d in b)
            gvjs_de(b, d) && c.push(b[d]);
        return c
    }
});
gvjs_6d("Math.hypot", function(a) {
    return a ? a : function(b) {
        if (2 > arguments.length)
            return arguments.length ? Math.abs(arguments[0]) : 0;
        var c, d, e;
        for (c = e = 0; c < arguments.length; c++)
            e = Math.max(e, Math.abs(arguments[c]));
        if (1E100 < e || 1E-100 > e) {
            if (!e)
                return e;
            for (c = d = 0; c < arguments.length; c++) {
                var f = Number(arguments[c]) / e;
                d += f * f
            }
            return Math.sqrt(d) * e
        }
        for (c = d = 0; c < arguments.length; c++)
            f = Number(arguments[c]),
            d += f * f;
        return Math.sqrt(d)
    }
});
gvjs_6d("Array.prototype.findIndex", function(a) {
    return a ? a : function(b, c) {
        return gvjs_fe(this, b, c).Ud
    }
});
gvjs_6d("Math.log10", function(a) {
    return a ? a : function(b) {
        return Math.log(b) / Math.LN10
    }
});
gvjs_6d("Object.is", function(a) {
    return a ? a : function(b, c) {
        return b === c ? 0 !== b || 1 / b === 1 / c : b !== b && c !== c
    }
});
gvjs_6d("Array.prototype.includes", function(a) {
    return a ? a : function(b, c) {
        var d = this;
        d instanceof String && (d = String(d));
        var e = d.length;
        c = c || 0;
        for (0 > c && (c = Math.max(c + e, 0)); c < e; c++) {
            var f = d[c];
            if (f === b || Object.is(f, b))
                return !0
        }
        return !1
    }
});
gvjs_6d("String.prototype.includes", function(a) {
    return a ? a : function(b, c) {
        return -1 !== gvjs_ee(this, b, "includes").indexOf(b, c || 0)
    }
});
gvjs_6d("Object.entries", function(a) {
    return a ? a : function(b) {
        var c = [], d;
        for (d in b)
            gvjs_de(b, d) && c.push([d, b[d]]);
        return c
    }
});
gvjs_6d("Number.isFinite", function(a) {
    return a ? a : function(b) {
        return typeof b !== gvjs_g ? !1 : !isNaN(b) && Infinity !== b && -Infinity !== b
    }
});
gvjs_6d("Number.isInteger", function(a) {
    return a ? a : function(b) {
        return Number.isFinite(b) ? b === Math.floor(b) : !1
    }
});
gvjs_6d("Math.cbrt", function(a) {
    return a ? a : function(b) {
        if (0 === b)
            return b;
        b = Number(b);
        var c = Math.pow(Math.abs(b), 1 / 3);
        return 0 > b ? -c : c
    }
});
gvjs_6d("Math.log2", function(a) {
    return a ? a : function(b) {
        return Math.log(b) / Math.LN2
    }
});
gvjs_6d("Number.isNaN", function(a) {
    return a ? a : function(b) {
        return typeof b === gvjs_g && isNaN(b)
    }
});
var gvjs_ie = gvjs_ie || {}
  , gvjs_p = this || self;
function gvjs_q(a, b, c) {
    a = a.split(".");
    c = c || gvjs_p;
    a[0]in c || "undefined" == typeof c.execScript || c.execScript("var " + a[0]);
    for (var d; a.length && (d = a.shift()); )
        a.length || void 0 === b ? c = c[d] && c[d] !== Object.prototype[d] ? c[d] : c[d] = {} : c[d] = b
}
function gvjs_je(a, b) {
    a = a.split(".");
    b = b || gvjs_p;
    for (var c = 0; c < a.length; c++)
        if (b = b[a[c]],
        null == b)
            return null;
    return b
}
function gvjs_ke() {}
function gvjs_le(a) {
    a.pz = void 0;
    a.Lc = function() {
        return a.pz ? a.pz : a.pz = new a
    }
}
function gvjs_me(a) {
    var b = typeof a;
    return b != gvjs_h ? b : a ? Array.isArray(a) ? gvjs_sb : b : gvjs_rd
}
function gvjs_ne(a) {
    var b = gvjs_me(a);
    return b == gvjs_sb || b == gvjs_h && typeof a.length == gvjs_g
}
function gvjs_oe(a) {
    return gvjs_r(a) && typeof a.getFullYear == gvjs_d
}
function gvjs_r(a) {
    var b = typeof a;
    return b == gvjs_h && null != a || b == gvjs_d
}
function gvjs_pe(a) {
    return Object.prototype.hasOwnProperty.call(a, gvjs_qe) && a[gvjs_qe] || (a[gvjs_qe] = ++gvjs_eaa)
}
var gvjs_qe = "closure_uid_" + (1E9 * Math.random() >>> 0)
  , gvjs_eaa = 0;
function gvjs_faa(a, b, c) {
    return a.call.apply(a.bind, arguments)
}
function gvjs_gaa(a, b, c) {
    if (!a)
        throw Error();
    if (2 < arguments.length) {
        var d = Array.prototype.slice.call(arguments, 2);
        return function() {
            var e = Array.prototype.slice.call(arguments);
            Array.prototype.unshift.apply(e, d);
            return a.apply(b, e)
        }
    }
    return function() {
        return a.apply(b, arguments)
    }
}
function gvjs_s(a, b, c) {
    gvjs_s = Function.prototype.bind && -1 != Function.prototype.bind.toString().indexOf("native code") ? gvjs_faa : gvjs_gaa;
    return gvjs_s.apply(null, arguments)
}
function gvjs_re(a, b) {
    var c = Array.prototype.slice.call(arguments, 1);
    return function() {
        var d = c.slice();
        d.push.apply(d, arguments);
        return a.apply(this, d)
    }
}
function gvjs_se() {
    return Date.now()
}
function gvjs_te(a) {
    (0,
    eval)(a)
}
function gvjs_t(a, b) {
    function c() {}
    c.prototype = b.prototype;
    a.G = b.prototype;
    a.prototype = new c;
    a.prototype.constructor = a;
    a.base = function(d, e, f) {
        for (var g = Array(arguments.length - 2), h = 2; h < arguments.length; h++)
            g[h - 2] = arguments[h];
        return b.prototype[e].apply(d, g)
    }
}
function gvjs_ue(a) {
    return a
}
;function gvjs_ve(a) {
    if (Error.captureStackTrace)
        Error.captureStackTrace(this, gvjs_ve);
    else {
        var b = Error().stack;
        b && (this.stack = b)
    }
    a && (this.message = String(a))
}
gvjs_t(gvjs_ve, Error);
gvjs_ve.prototype.name = "CustomError";
var gvjs_we;
function gvjs_xe(a, b) {
    a = a.split("%s");
    for (var c = "", d = a.length - 1, e = 0; e < d; e++)
        c += a[e] + (e < b.length ? b[e] : "%s");
    gvjs_ve.call(this, c + a[d])
}
gvjs_t(gvjs_xe, gvjs_ve);
gvjs_xe.prototype.name = "AssertionError";
function gvjs_ye() {
    return null
}
function gvjs_ze(a) {
    var b = !1, c;
    return function() {
        b || (c = a(),
        b = !0);
        return c
    }
}
;function gvjs_Ae(a) {
    return a[a.length - 1]
}
var gvjs_Be = Array.prototype.indexOf ? function(a, b) {
    return Array.prototype.indexOf.call(a, b, void 0)
}
: function(a, b) {
    if (typeof a === gvjs_l)
        return typeof b !== gvjs_l || 1 != b.length ? -1 : a.indexOf(b, 0);
    for (var c = 0; c < a.length; c++)
        if (c in a && a[c] === b)
            return c;
    return -1
}
  , gvjs_haa = Array.prototype.lastIndexOf ? function(a, b) {
    return Array.prototype.lastIndexOf.call(a, b, a.length - 1)
}
: function(a, b) {
    var c = a.length - 1;
    0 > c && (c = Math.max(0, a.length + c));
    if (typeof a === gvjs_l)
        return typeof b !== gvjs_l || 1 != b.length ? -1 : a.lastIndexOf(b, c);
    for (; 0 <= c; c--)
        if (c in a && a[c] === b)
            return c;
    return -1
}
  , gvjs_u = Array.prototype.forEach ? function(a, b, c) {
    Array.prototype.forEach.call(a, b, c)
}
: function(a, b, c) {
    for (var d = a.length, e = typeof a === gvjs_l ? a.split("") : a, f = 0; f < d; f++)
        f in e && b.call(c, e[f], f, a)
}
;
function gvjs_Ce(a, b) {
    for (var c = typeof a === gvjs_l ? a.split("") : a, d = a.length - 1; 0 <= d; --d)
        d in c && b.call(void 0, c[d], d, a)
}
var gvjs_De = Array.prototype.filter ? function(a, b, c) {
    return Array.prototype.filter.call(a, b, c)
}
: function(a, b, c) {
    for (var d = a.length, e = [], f = 0, g = typeof a === gvjs_l ? a.split("") : a, h = 0; h < d; h++)
        if (h in g) {
            var k = g[h];
            b.call(c, k, h, a) && (e[f++] = k)
        }
    return e
}
  , gvjs_v = Array.prototype.map ? function(a, b, c) {
    return Array.prototype.map.call(a, b, c)
}
: function(a, b, c) {
    for (var d = a.length, e = Array(d), f = typeof a === gvjs_l ? a.split("") : a, g = 0; g < d; g++)
        g in f && (e[g] = b.call(c, f[g], g, a));
    return e
}
  , gvjs_Ee = Array.prototype.reduce ? function(a, b, c, d) {
    d && (b = gvjs_s(b, d));
    return Array.prototype.reduce.call(a, b, c)
}
: function(a, b, c, d) {
    var e = c;
    gvjs_u(a, function(f, g) {
        e = b.call(d, e, f, g, a)
    });
    return e
}
  , gvjs_iaa = Array.prototype.reduceRight ? function(a, b, c) {
    return Array.prototype.reduceRight.call(a, b, c)
}
: function(a, b, c) {
    var d = c;
    gvjs_Ce(a, function(e, f) {
        d = b.call(void 0, d, e, f, a)
    });
    return d
}
  , gvjs_Fe = Array.prototype.some ? function(a, b, c) {
    return Array.prototype.some.call(a, b, c)
}
: function(a, b, c) {
    for (var d = a.length, e = typeof a === gvjs_l ? a.split("") : a, f = 0; f < d; f++)
        if (f in e && b.call(c, e[f], f, a))
            return !0;
    return !1
}
  , gvjs_Ge = Array.prototype.every ? function(a, b, c) {
    return Array.prototype.every.call(a, b, c)
}
: function(a, b, c) {
    for (var d = a.length, e = typeof a === gvjs_l ? a.split("") : a, f = 0; f < d; f++)
        if (f in e && !b.call(c, e[f], f, a))
            return !1;
    return !0
}
;
function gvjs_He(a, b) {
    return 0 <= gvjs_Be(a, b)
}
function gvjs_Ie(a, b) {
    b = gvjs_Be(a, b);
    var c;
    (c = 0 <= b) && gvjs_Je(a, b);
    return c
}
function gvjs_Je(a, b) {
    Array.prototype.splice.call(a, b, 1)
}
function gvjs_Ke(a) {
    return Array.prototype.concat.apply([], arguments)
}
function gvjs_Le(a) {
    var b = a.length;
    if (0 < b) {
        for (var c = Array(b), d = 0; d < b; d++)
            c[d] = a[d];
        return c
    }
    return []
}
function gvjs_Me(a, b) {
    for (var c = 1; c < arguments.length; c++) {
        var d = arguments[c];
        if (gvjs_ne(d)) {
            var e = a.length || 0
              , f = d.length || 0;
            a.length = e + f;
            for (var g = 0; g < f; g++)
                a[e + g] = d[g]
        } else
            a.push(d)
    }
}
function gvjs_Ne(a, b, c, d) {
    return Array.prototype.splice.apply(a, gvjs_Oe(arguments, 1))
}
function gvjs_Oe(a, b, c) {
    return 2 >= arguments.length ? Array.prototype.slice.call(a, b) : Array.prototype.slice.call(a, b, c)
}
function gvjs_Pe(a, b, c) {
    function d(l) {
        return gvjs_r(l) ? "o" + gvjs_pe(l) : (typeof l).charAt(0) + l
    }
    b = b || a;
    c = c || d;
    for (var e = 0, f = 0, g = {}; f < a.length; ) {
        var h = a[f++]
          , k = c(h);
        Object.prototype.hasOwnProperty.call(g, k) || (g[k] = !0,
        b[e++] = h)
    }
    b.length = e
}
function gvjs_Qe(a, b) {
    a.sort(b || gvjs_Re)
}
function gvjs_Se(a, b) {
    for (var c = Array(a.length), d = 0; d < a.length; d++)
        c[d] = {
            index: d,
            value: a[d]
        };
    var e = b || gvjs_Re;
    gvjs_Qe(c, function(f, g) {
        return e(f.value, g.value) || f.index - g.index
    });
    for (b = 0; b < a.length; b++)
        a[b] = c[b].value
}
function gvjs_Re(a, b) {
    return a > b ? 1 : a < b ? -1 : 0
}
function gvjs_Te(a, b) {
    for (var c = [], d = 0; d < b; d++)
        c[d] = a;
    return c
}
function gvjs_jaa(a, b) {
    return gvjs_Ke.apply([], gvjs_v(a, b, void 0))
}
;function gvjs_w(a, b, c) {
    for (var d in a)
        b.call(c, a[d], d, a)
}
function gvjs_Ue(a, b) {
    for (var c in a)
        if (b.call(void 0, a[c], c, a))
            return !0;
    return !1
}
function gvjs_Ve(a, b, c) {
    for (var d in a)
        if (!b.call(c, a[d], d, a))
            return !1;
    return !0
}
function gvjs_We(a) {
    var b = 0, c;
    for (c in a)
        b++;
    return b
}
function gvjs_Xe(a) {
    var b = [], c = 0, d;
    for (d in a)
        b[c++] = a[d];
    return b
}
function gvjs_Ye(a) {
    var b = [], c = 0, d;
    for (d in a)
        b[c++] = d;
    return b
}
function gvjs_Ze(a, b) {
    return null !== a && b in a
}
function gvjs__e(a, b) {
    for (var c in a)
        if (a[c] == b)
            return !0;
    return !1
}
function gvjs_x(a) {
    var b = {}, c;
    for (c in a)
        b[c] = a[c];
    return b
}
function gvjs_0e(a) {
    if (!a || typeof a !== gvjs_h)
        return a;
    if (typeof a.clone === gvjs_d)
        return a.clone();
    if ("undefined" !== typeof Map && a instanceof Map)
        return new Map(a);
    if ("undefined" !== typeof Set && a instanceof Set)
        return new Set(a);
    var b = Array.isArray(a) ? [] : typeof ArrayBuffer !== gvjs_d || typeof ArrayBuffer.isView !== gvjs_d || !ArrayBuffer.isView(a) || a instanceof DataView ? {} : new a.constructor(a.length), c;
    for (c in a)
        b[c] = gvjs_0e(a[c]);
    return b
}
var gvjs_1e = "constructor hasOwnProperty isPrototypeOf propertyIsEnumerable toLocaleString toString valueOf".split(" ");
function gvjs_2e(a, b) {
    for (var c, d, e = 1; e < arguments.length; e++) {
        d = arguments[e];
        for (c in d)
            a[c] = d[c];
        for (var f = 0; f < gvjs_1e.length; f++)
            c = gvjs_1e[f],
            Object.prototype.hasOwnProperty.call(d, c) && (a[c] = d[c])
    }
}
;var gvjs_kaa = {
    area: !0,
    base: !0,
    br: !0,
    col: !0,
    command: !0,
    embed: !0,
    hr: !0,
    img: !0,
    input: !0,
    keygen: !0,
    link: !0,
    meta: !0,
    param: !0,
    source: !0,
    track: !0,
    wbr: !0
};
var gvjs_3e;
function gvjs_4e() {
    if (void 0 === gvjs_3e) {
        var a = null
          , b = gvjs_p.trustedTypes;
        if (b && b.createPolicy)
            try {
                a = b.createPolicy("goog#html", {
                    createHTML: gvjs_ue,
                    createScript: gvjs_ue,
                    createScriptURL: gvjs_ue
                })
            } catch (c) {
                gvjs_p.console && gvjs_p.console.error(c.message)
            }
        gvjs_3e = a
    }
    return gvjs_3e
}
;function gvjs_5e(a, b) {
    this.nga = a === gvjs_6e && b || "";
    this.Hja = gvjs_7e
}
gvjs_5e.prototype.Po = !0;
gvjs_5e.prototype.Tk = function() {
    return this.nga
}
;
function gvjs_8e(a) {
    return a instanceof gvjs_5e && a.constructor === gvjs_5e && a.Hja === gvjs_7e ? a.nga : "type_error:Const"
}
function gvjs_9e(a) {
    return new gvjs_5e(gvjs_6e,a)
}
var gvjs_7e = {}
  , gvjs_6e = {};
var gvjs_$e = {};
function gvjs_af(a, b) {
    this.B2 = b === gvjs_$e ? a : "";
    this.Po = !0
}
gvjs_af.prototype.Tk = function() {
    return this.B2.toString()
}
;
function gvjs_bf(a) {
    if (a instanceof gvjs_af && a.constructor === gvjs_af)
        return a.B2;
    gvjs_me(a);
    return "type_error:SafeScript"
}
function gvjs_laa(a) {
    var b = gvjs_4e();
    a = b ? b.createScript(a) : a;
    return new gvjs_af(a,gvjs_$e)
}
gvjs_af.prototype.toString = function() {
    return this.B2.toString()
}
;
function gvjs_cf(a, b) {
    this.G2 = b === gvjs_df ? a : ""
}
gvjs_ = gvjs_cf.prototype;
gvjs_.Po = !0;
gvjs_.Tk = function() {
    return this.G2.toString()
}
;
gvjs_.s_ = !0;
gvjs_.getDirection = function() {
    return 1
}
;
gvjs_.toString = function() {
    return this.G2 + ""
}
;
function gvjs_ef(a) {
    return gvjs_ff(a).toString()
}
function gvjs_ff(a) {
    if (a instanceof gvjs_cf && a.constructor === gvjs_cf)
        return a.G2;
    gvjs_me(a);
    return "type_error:TrustedResourceUrl"
}
var gvjs_df = {};
function gvjs_gf(a) {
    var b = gvjs_4e();
    a = b ? b.createScriptURL(a) : a;
    return new gvjs_cf(a,gvjs_df)
}
;function gvjs_hf(a, b) {
    return 0 == a.lastIndexOf(b, 0)
}
function gvjs_if(a) {
    var b = a.length - 1;
    return 0 <= b && a.indexOf("%", b) == b
}
function gvjs_jf(a) {
    return /^[\s\xa0]*$/.test(a)
}
var gvjs_kf = String.prototype.trim ? function(a) {
    return a.trim()
}
: function(a) {
    return /^[\s\xa0]*([\s\S]*?)[\s\xa0]*$/.exec(a)[1]
}
;
function gvjs_lf(a, b) {
    if (b)
        a = a.replace(gvjs_mf, "&amp;").replace(gvjs_nf, gvjs_fa).replace(gvjs_of, "&gt;").replace(gvjs_pf, gvjs_ga).replace(gvjs_qf, "&#39;").replace(gvjs_rf, "&#0;");
    else {
        if (!gvjs_maa.test(a))
            return a;
        -1 != a.indexOf("&") && (a = a.replace(gvjs_mf, "&amp;"));
        -1 != a.indexOf("<") && (a = a.replace(gvjs_nf, gvjs_fa));
        -1 != a.indexOf(">") && (a = a.replace(gvjs_of, "&gt;"));
        -1 != a.indexOf('"') && (a = a.replace(gvjs_pf, gvjs_ga));
        -1 != a.indexOf("'") && (a = a.replace(gvjs_qf, "&#39;"));
        -1 != a.indexOf("\x00") && (a = a.replace(gvjs_rf, "&#0;"))
    }
    return a
}
var gvjs_mf = /&/g
  , gvjs_nf = /</g
  , gvjs_of = />/g
  , gvjs_pf = /"/g
  , gvjs_qf = /'/g
  , gvjs_rf = /\x00/g
  , gvjs_maa = /[\x00&<>"']/;
function gvjs_sf(a, b) {
    return -1 != a.indexOf(b)
}
function gvjs_tf(a, b) {
    var c = 0;
    a = gvjs_kf(String(a)).split(".");
    b = gvjs_kf(String(b)).split(".");
    for (var d = Math.max(a.length, b.length), e = 0; 0 == c && e < d; e++) {
        var f = a[e] || ""
          , g = b[e] || "";
        do {
            f = /(\d*)(\D*)(.*)/.exec(f) || ["", "", "", ""];
            g = /(\d*)(\D*)(.*)/.exec(g) || ["", "", "", ""];
            if (0 == f[0].length && 0 == g[0].length)
                break;
            c = gvjs_uf(0 == f[1].length ? 0 : parseInt(f[1], 10), 0 == g[1].length ? 0 : parseInt(g[1], 10)) || gvjs_uf(0 == f[2].length, 0 == g[2].length) || gvjs_uf(f[2], g[2]);
            f = f[3];
            g = g[3]
        } while (0 == c)
    }
    return c
}
function gvjs_uf(a, b) {
    return a < b ? -1 : a > b ? 1 : 0
}
;function gvjs_vf(a, b) {
    this.E2 = b === gvjs_wf ? a : ""
}
gvjs_ = gvjs_vf.prototype;
gvjs_.Po = !0;
gvjs_.Tk = function() {
    return this.E2.toString()
}
;
gvjs_.s_ = !0;
gvjs_.getDirection = function() {
    return 1
}
;
gvjs_.toString = function() {
    return this.E2.toString()
}
;
function gvjs_xf(a) {
    if (a instanceof gvjs_vf && a.constructor === gvjs_vf)
        return a.E2;
    gvjs_me(a);
    return "type_error:SafeUrl"
}
var gvjs_naa = /^(?:audio\/(?:3gpp2|3gpp|aac|L16|midi|mp3|mp4|mpeg|oga|ogg|opus|x-m4a|x-matroska|x-wav|wav|webm)|font\/\w+|image\/(?:bmp|gif|jpeg|jpg|png|tiff|webp|x-icon)|video\/(?:mpeg|mp4|ogg|webm|quicktime|x-matroska))(?:;\w+=(?:\w+|"[\w;,= ]+"))*$/i
  , gvjs_oaa = /^data:(.*);base64,[a-z0-9+\/]+=*$/i;
function gvjs_yf(a) {
    a = String(a);
    a = a.replace(/(%0A|%0D)/g, "");
    var b = a.match(gvjs_oaa);
    return b && gvjs_naa.test(b[1]) ? gvjs_zf(a) : null
}
var gvjs_Af = /^(?:(?:https?|mailto|ftp):|[^:/?#]*(?:[/?#]|$))/i;
function gvjs_Bf(a) {
    a instanceof gvjs_vf || (a = typeof a == gvjs_h && a.Po ? a.Tk() : String(a),
    a = gvjs_Af.test(a) ? gvjs_zf(a) : gvjs_yf(a));
    return a || gvjs_Cf
}
var gvjs_wf = {};
function gvjs_zf(a) {
    return new gvjs_vf(a,gvjs_wf)
}
var gvjs_Cf = gvjs_zf(gvjs_ob);
function gvjs_Df(a, b) {
    this.D2 = b === gvjs_Ef ? a : ""
}
gvjs_Df.prototype.Po = !0;
gvjs_Df.prototype.Tk = function() {
    return this.D2
}
;
gvjs_Df.prototype.toString = function() {
    return this.D2.toString()
}
;
function gvjs_Ff(a) {
    if (a instanceof gvjs_Df && a.constructor === gvjs_Df)
        return a.D2;
    gvjs_me(a);
    return "type_error:SafeStyle"
}
var gvjs_Ef = {}
  , gvjs_Gf = new gvjs_Df("",gvjs_Ef);
function gvjs_Hf(a) {
    var b = "", c;
    for (c in a)
        if (Object.prototype.hasOwnProperty.call(a, c)) {
            if (!/^[-_a-zA-Z0-9]+$/.test(c))
                throw Error("Name allows only [-_a-zA-Z0-9], got: " + c);
            var d = a[c];
            null != d && (d = Array.isArray(d) ? d.map(gvjs_If).join(" ") : gvjs_If(d),
            b += c + ":" + d + ";")
        }
    return b ? new gvjs_Df(b,gvjs_Ef) : gvjs_Gf
}
function gvjs_If(a) {
    if (a instanceof gvjs_vf)
        return 'url("' + gvjs_xf(a).replace(/</g, "%3c").replace(/[\\"]/g, "\\$&") + '")';
    a = a instanceof gvjs_5e ? gvjs_8e(a) : gvjs_paa(String(a));
    if (/[{;}]/.test(a))
        throw new gvjs_xe("Value does not allow [{;}], got: %s.",[a]);
    return a
}
function gvjs_paa(a) {
    var b = a.replace(gvjs_Jf, "$1").replace(gvjs_Jf, "$1").replace(gvjs_Kf, "url");
    if (gvjs_qaa.test(b)) {
        if (gvjs_raa.test(a))
            return gvjs__d;
        for (var c = b = !0, d = 0; d < a.length; d++) {
            var e = a.charAt(d);
            "'" == e && c ? b = !b : '"' == e && b && (c = !c)
        }
        if (!b || !c || !gvjs_saa(a))
            return gvjs__d
    } else
        return gvjs__d;
    return gvjs_taa(a)
}
function gvjs_saa(a) {
    for (var b = !0, c = /^[-_a-zA-Z0-9]$/, d = 0; d < a.length; d++) {
        var e = a.charAt(d);
        if ("]" == e) {
            if (b)
                return !1;
            b = !0
        } else if ("[" == e) {
            if (!b)
                return !1;
            b = !1
        } else if (!b && !c.test(e))
            return !1
    }
    return b
}
var gvjs_qaa = /^[-,."'%_!# a-zA-Z0-9\[\]]+$/
  , gvjs_Kf = /\b(url\([ \t\n]*)('[ -&(-\[\]-~]*'|"[ !#-\[\]-~]*"|[!#-&*-\[\]-~]*)([ \t\n]*\))/g
  , gvjs_Jf = /\b(calc|cubic-bezier|fit-content|hsl|hsla|linear-gradient|matrix|minmax|repeat|rgb|rgba|(rotate|scale|translate)(X|Y|Z|3d)?)\([-+*/0-9a-z.%\[\], ]+\)/g
  , gvjs_raa = /\/\*/;
function gvjs_taa(a) {
    return a.replace(gvjs_Kf, function(b, c, d, e) {
        var f = "";
        d = d.replace(/^(['"])(.*)\1$/, function(g, h, k) {
            f = h;
            return k
        });
        b = gvjs_Bf(d).Tk();
        return c + f + b + f + e
    })
}
;var gvjs_Lf = {};
function gvjs_Mf(a, b) {
    this.C2 = b === gvjs_Lf ? a : "";
    this.Po = !0
}
function gvjs_Nf(a, b) {
    if (gvjs_sf(a, "<"))
        throw Error("Selector does not allow '<', got: " + a);
    var c = a.replace(/('|")((?!\1)[^\r\n\f\\]|\\[\s\S])*\1/g, "");
    if (!/^[-_a-zA-Z0-9#.:* ,>+~[\]()=^$|]+$/.test(c))
        throw Error("Selector allows only [-_a-zA-Z0-9#.:* ,>+~[\\]()=^$|] and strings, got: " + a);
    a: {
        for (var d = {
            "(": ")",
            "[": "]"
        }, e = [], f = 0; f < c.length; f++) {
            var g = c[f];
            if (d[g])
                e.push(d[g]);
            else if (gvjs__e(d, g) && e.pop() != g) {
                c = !1;
                break a
            }
        }
        c = 0 == e.length
    }
    if (!c)
        throw Error("() and [] in selector must be balanced, got: " + a);
    b instanceof gvjs_Df || (b = gvjs_Hf(b));
    a = a + "{" + gvjs_Ff(b).replace(/</g, "\\3C ") + "}";
    return new gvjs_Mf(a,gvjs_Lf)
}
function gvjs_Of(a) {
    function b(d) {
        Array.isArray(d) ? d.forEach(b) : c += gvjs_Pf(d)
    }
    var c = "";
    Array.prototype.forEach.call(arguments, b);
    return new gvjs_Mf(c,gvjs_Lf)
}
gvjs_Mf.prototype.Tk = function() {
    return this.C2
}
;
function gvjs_Pf(a) {
    if (a instanceof gvjs_Mf && a.constructor === gvjs_Mf)
        return a.C2;
    gvjs_me(a);
    return "type_error:SafeStyleSheet"
}
gvjs_Mf.prototype.toString = function() {
    return this.C2.toString()
}
;
var gvjs_Qf = new gvjs_Mf("",gvjs_Lf);
var gvjs_Rf;
a: {
    var gvjs_Sf = gvjs_p.navigator;
    if (gvjs_Sf) {
        var gvjs_Tf = gvjs_Sf.userAgent;
        if (gvjs_Tf) {
            gvjs_Rf = gvjs_Tf;
            break a
        }
    }
    gvjs_Rf = ""
}
function gvjs_Uf(a) {
    return gvjs_sf(gvjs_Rf, a)
}
;function gvjs_Vf() {
    return gvjs_Uf("Firefox") || gvjs_Uf("FxiOS")
}
function gvjs_Wf() {
    return gvjs_Uf("Safari") && !(gvjs_Xf() || gvjs_Uf("Coast") || gvjs_Uf("Opera") || gvjs_Uf(gvjs_Ca) || gvjs_Uf("Edg/") || gvjs_Uf("OPR") || gvjs_Vf() || gvjs_Uf("Silk") || gvjs_Uf("Android"))
}
function gvjs_Xf() {
    return (gvjs_Uf("Chrome") || gvjs_Uf("CriOS")) && !gvjs_Uf(gvjs_Ca)
}
function gvjs_Yf() {
    return gvjs_Uf("Android") && !(gvjs_Xf() || gvjs_Vf() || gvjs_Uf("Opera") || gvjs_Uf("Silk"))
}
;function gvjs_Zf(a, b, c) {
    this.A2 = c === gvjs__f ? a : "";
    this.Rma = b
}
gvjs_ = gvjs_Zf.prototype;
gvjs_.s_ = !0;
gvjs_.getDirection = function() {
    return this.Rma
}
;
gvjs_.Po = !0;
gvjs_.Tk = function() {
    return this.A2.toString()
}
;
gvjs_.toString = function() {
    return this.A2.toString()
}
;
function gvjs_0f(a) {
    return gvjs_1f(a).toString()
}
function gvjs_1f(a) {
    if (a instanceof gvjs_Zf && a.constructor === gvjs_Zf)
        return a.A2;
    gvjs_me(a);
    return "type_error:SafeHtml"
}
function gvjs_2f(a) {
    if (a instanceof gvjs_Zf)
        return a;
    var b = typeof a == gvjs_h
      , c = null;
    b && a.s_ && (c = a.getDirection());
    return gvjs_3f(gvjs_lf(b && a.Po ? a.Tk() : String(a)), c)
}
var gvjs_4f = /^[a-zA-Z0-9-]+$/
  , gvjs_uaa = {
    action: !0,
    cite: !0,
    data: !0,
    formaction: !0,
    href: !0,
    manifest: !0,
    poster: !0,
    src: !0
}
  , gvjs_vaa = {
    APPLET: !0,
    BASE: !0,
    EMBED: !0,
    IFRAME: !0,
    LINK: !0,
    MATH: !0,
    META: !0,
    OBJECT: !0,
    SCRIPT: !0,
    STYLE: !0,
    SVG: !0,
    TEMPLATE: !0
};
function gvjs_5f(a, b, c) {
    gvjs_6f(String(a));
    return gvjs_7f(String(a), b, c)
}
function gvjs_6f(a) {
    if (!gvjs_4f.test(a))
        throw Error("");
    if (a.toUpperCase()in gvjs_vaa)
        throw Error("");
}
function gvjs_waa(a) {
    var b = {
        nonce: gvjs_8f(gvjs_Ed, void 0)
    };
    for (d in b)
        if (Object.prototype.hasOwnProperty.call(b, d)) {
            var c = d.toLowerCase();
            if ("language" == c || "src" == c || c == gvjs_m || c == gvjs_Sd)
                throw Error("");
        }
    var d = "";
    a = gvjs_Ke(a);
    for (c = 0; c < a.length; c++)
        d += gvjs_bf(a[c]).toString();
    a = gvjs_3f(d, 0);
    return gvjs_7f("script", b, a)
}
function gvjs_xaa(a) {
    function b(f) {
        Array.isArray(f) ? f.forEach(b) : (f = gvjs_2f(f),
        e.push(gvjs_0f(f)),
        f = f.getDirection(),
        0 == d ? d = f : 0 != f && d != f && (d = null))
    }
    var c = gvjs_2f(gvjs_9f)
      , d = c.getDirection()
      , e = [];
    a.forEach(b);
    return gvjs_3f(e.join(gvjs_0f(c)), d)
}
function gvjs_$f(a) {
    return gvjs_xaa(Array.prototype.slice.call(arguments))
}
var gvjs__f = {};
function gvjs_3f(a, b) {
    var c = gvjs_4e();
    a = c ? c.createHTML(a) : a;
    return new gvjs_Zf(a,b,gvjs__f)
}
function gvjs_7f(a, b, c) {
    var d = null;
    var e = "<" + a + gvjs_ag(b);
    null == c ? c = [] : Array.isArray(c) || (c = [c]);
    !0 === gvjs_kaa[a.toLowerCase()] ? e += ">" : (d = gvjs_$f(c),
    e += ">" + gvjs_0f(d) + "</" + a + ">",
    d = d.getDirection());
    (a = b && b.dir) && (d = /^(ltr|rtl|auto)$/i.test(a) ? 0 : null);
    return gvjs_3f(e, d)
}
function gvjs_ag(a) {
    var b = "";
    if (a)
        for (var c in a)
            if (Object.prototype.hasOwnProperty.call(a, c)) {
                if (!gvjs_4f.test(c))
                    throw Error("");
                var d = a[c];
                if (null != d) {
                    var e = c;
                    if (d instanceof gvjs_5e)
                        d = gvjs_8e(d);
                    else if (e.toLowerCase() == gvjs_Jd) {
                        if (!gvjs_r(d))
                            throw Error("");
                        d instanceof gvjs_Df || (d = gvjs_Hf(d));
                        d = gvjs_Ff(d)
                    } else {
                        if (/^on/i.test(e))
                            throw Error("");
                        if (e.toLowerCase()in gvjs_uaa)
                            if (d instanceof gvjs_cf)
                                d = gvjs_ef(d);
                            else if (d instanceof gvjs_vf)
                                d = gvjs_xf(d);
                            else if (typeof d === gvjs_l)
                                d = gvjs_Bf(d).Tk();
                            else
                                throw Error("");
                    }
                    d.Po && (d = d.Tk());
                    e = e + '="' + gvjs_lf(String(d)) + '"';
                    b += " " + e
                }
            }
    return b
}
var gvjs_yaa = gvjs_3f("<!DOCTYPE html>", 0)
  , gvjs_9f = new gvjs_Zf(gvjs_p.trustedTypes && gvjs_p.trustedTypes.emptyHTML || "",0,gvjs__f)
  , gvjs_bg = gvjs_3f(gvjs_la, 0);
var gvjs_zaa = gvjs_ze(function() {
    var a = document.createElement(gvjs_Ob)
      , b = document.createElement(gvjs_Ob);
    b.appendChild(document.createElement(gvjs_Ob));
    a.appendChild(b);
    b = a.firstChild.firstChild;
    a.innerHTML = gvjs_1f(gvjs_9f);
    return !b.parentElement
});
function gvjs_cg(a, b) {
    if (gvjs_zaa())
        for (; a.lastChild; )
            a.removeChild(a.lastChild);
    a.innerHTML = gvjs_1f(b)
}
var gvjs_Aaa = /^[\w+/_-]+[=]{0,2}$/;
function gvjs_8f(a, b) {
    b = (b || gvjs_p).document;
    return b.querySelector ? (a = b.querySelector(a)) && (a = a.nonce || a.getAttribute(gvjs_qd)) && gvjs_Aaa.test(a) ? a : "" : ""
}
;function gvjs_dg(a, b) {
    return a = gvjs_lf(a, b)
}
var gvjs_eg = String.prototype.repeat ? function(a, b) {
    return a.repeat(b)
}
: function(a, b) {
    return Array(b + 1).join(a)
}
;
function gvjs_fg(a, b) {
    a = String(a);
    var c = a.indexOf(".");
    -1 == c && (c = a.length);
    return gvjs_eg("0", Math.max(0, b - c)) + a
}
function gvjs_gg(a) {
    return null == a ? "" : String(a)
}
function gvjs_hg() {
    return Math.floor(2147483648 * Math.random()).toString(36) + Math.abs(Math.floor(2147483648 * Math.random()) ^ gvjs_se()).toString(36)
}
var gvjs_ig = 2147483648 * Math.random() | 0;
function gvjs_jg(a) {
    var b = Number(a);
    return 0 == b && gvjs_jf(a) ? NaN : b
}
function gvjs_kg(a) {
    return String(a).replace(/\-([a-z])/g, function(b, c) {
        return c.toUpperCase()
    })
}
function gvjs_Baa(a) {
    return a.replace(/(^|[\s]+)([a-z])/g, function(b, c, d) {
        return c + d.toUpperCase()
    })
}
;function gvjs_lg() {
    return gvjs_Uf("iPhone") && !gvjs_Uf("iPod") && !gvjs_Uf("iPad")
}
function gvjs_mg() {
    return gvjs_lg() || gvjs_Uf("iPad") || gvjs_Uf("iPod")
}
;function gvjs_ng(a) {
    gvjs_ng[" "](a);
    return a
}
gvjs_ng[" "] = gvjs_ke;
function gvjs_og(a, b) {
    try {
        return gvjs_ng(a[b]),
        !0
    } catch (c) {}
    return !1
}
function gvjs_pg(a, b, c) {
    return Object.prototype.hasOwnProperty.call(a, b) ? a[b] : a[b] = c(b)
}
;var gvjs_qg = gvjs_Uf("Opera")
  , gvjs_y = gvjs_Uf("Trident") || gvjs_Uf("MSIE")
  , gvjs_rg = gvjs_Uf(gvjs_Ca)
  , gvjs_Caa = gvjs_rg || gvjs_y
  , gvjs_sg = gvjs_Uf("Gecko") && !(gvjs_sf(gvjs_Rf.toLowerCase(), "webkit") && !gvjs_Uf(gvjs_Ca)) && !(gvjs_Uf("Trident") || gvjs_Uf("MSIE")) && !gvjs_Uf(gvjs_Ca)
  , gvjs_tg = gvjs_sf(gvjs_Rf.toLowerCase(), "webkit") && !gvjs_Uf(gvjs_Ca)
  , gvjs_Daa = gvjs_tg && gvjs_Uf("Mobile")
  , gvjs_ug = gvjs_Uf("Macintosh")
  , gvjs_vg = gvjs_Uf("Windows")
  , gvjs_wg = gvjs_Uf("Linux") || gvjs_Uf("CrOS")
  , gvjs_xg = gvjs_p.navigator || null;
gvjs_xg && gvjs_sf(gvjs_xg.appVersion || "", "X11");
var gvjs_Eaa = gvjs_Uf("Android")
  , gvjs_Faa = gvjs_lg()
  , gvjs_Gaa = gvjs_Uf("iPad")
  , gvjs_Haa = gvjs_Uf("iPod")
  , gvjs_Iaa = gvjs_mg();
gvjs_sf(gvjs_Rf.toLowerCase(), "kaios");
function gvjs_yg() {
    var a = gvjs_p.document;
    return a ? a.documentMode : void 0
}
var gvjs_zg;
a: {
    var gvjs_Ag = ""
      , gvjs_Bg = function() {
        var a = gvjs_Rf;
        if (gvjs_sg)
            return /rv:([^\);]+)(\)|;)/.exec(a);
        if (gvjs_rg)
            return /Edge\/([\d\.]+)/.exec(a);
        if (gvjs_y)
            return /\b(?:MSIE|rv)[: ]([^\);]+)(\)|;)/.exec(a);
        if (gvjs_tg)
            return /WebKit\/(\S+)/.exec(a);
        if (gvjs_qg)
            return /(?:Version)[ \/]?(\S+)/.exec(a)
    }();
    gvjs_Bg && (gvjs_Ag = gvjs_Bg ? gvjs_Bg[1] : "");
    if (gvjs_y) {
        var gvjs_Cg = gvjs_yg();
        if (null != gvjs_Cg && gvjs_Cg > parseFloat(gvjs_Ag)) {
            gvjs_zg = String(gvjs_Cg);
            break a
        }
    }
    gvjs_zg = gvjs_Ag
}
var gvjs_Dg = gvjs_zg
  , gvjs_Jaa = {};
function gvjs_Eg(a) {
    return gvjs_pg(gvjs_Jaa, a, function() {
        return 0 <= gvjs_tf(gvjs_Dg, a)
    })
}
function gvjs_Fg(a) {
    return Number(gvjs_Kaa) >= a
}
var gvjs_Gg;
if (gvjs_p.document && gvjs_y) {
    var gvjs_Hg = gvjs_yg();
    gvjs_Gg = gvjs_Hg ? gvjs_Hg : parseInt(gvjs_Dg, 10) || void 0
} else
    gvjs_Gg = void 0;
var gvjs_Kaa = gvjs_Gg;
var gvjs_Laa = gvjs_Vf()
  , gvjs_Ig = gvjs_lg() || gvjs_Uf("iPod")
  , gvjs_Jg = gvjs_Uf("iPad")
  , gvjs_Maa = gvjs_Yf()
  , gvjs_Kg = gvjs_Xf()
  , gvjs_Lg = gvjs_Wf() && !gvjs_mg();
var gvjs_Mg = {}
  , gvjs_Ng = null;
var gvjs_Og = typeof Uint8Array === gvjs_d;
function gvjs_Naa(a) {
    return gvjs_Pg(a, function(b) {
        return b
    }, function(b) {
        return new Uint8Array(b)
    })
}
function gvjs_Qg(a, b, c) {
    return typeof a === gvjs_h ? gvjs_Og && !Array.isArray(a) && a instanceof Uint8Array ? c(a) : gvjs_Pg(a, b, c) : b(a)
}
function gvjs_Pg(a, b, c) {
    if (Array.isArray(a)) {
        for (var d = Array(a.length), e = 0; e < a.length; e++) {
            var f = a[e];
            null != f && (d[e] = gvjs_Qg(f, b, c))
        }
        Array.isArray(a) && a.osa && gvjs_Rg(d);
        return d
    }
    d = {};
    for (e in a)
        f = a[e],
        null != f && (d[e] = gvjs_Qg(f, b, c));
    return d
}
var gvjs_Oaa = {
    osa: {
        value: !0,
        configurable: !0
    }
};
function gvjs_Rg(a) {
    Array.isArray(a) && !Object.isFrozen(a) && Object.defineProperties(a, gvjs_Oaa);
    return a
}
;function gvjs_Sg() {}
var gvjs_Tg;
function gvjs_Ug(a, b, c) {
    a.se = null;
    gvjs_Tg && (b || (b = gvjs_Tg),
    gvjs_Tg = null);
    var d = a.constructor.aEa;
    b || (b = d ? [d] : []);
    a.qG = d ? 0 : -1;
    a.array = b;
    a: {
        if (b = a.array.length)
            if (--b,
            d = a.array[b],
            !(null === d || typeof d != gvjs_h || Array.isArray(d) || gvjs_Og && d instanceof Uint8Array)) {
                a.tK = b - a.qG;
                a.Kl = d;
                break a
            }
        a.tK = Number.MAX_VALUE
    }
    a.xCa = {};
    if (c)
        for (b = 0; b < c.length; b++)
            if (d = c[b],
            d < a.tK) {
                d += a.qG;
                var e = a.array[d];
                e ? gvjs_Rg(e) : a.array[d] = gvjs_Vg
            } else
                gvjs_Wg(a),
                (e = a.Kl[d]) ? gvjs_Rg(e) : a.Kl[d] = gvjs_Vg
}
var gvjs_Vg = Object.freeze(gvjs_Rg([]));
function gvjs_Wg(a) {
    var b = a.tK + a.qG;
    a.array[b] || (a.Kl = a.array[b] = {})
}
function gvjs_Xg(a, b) {
    if (b < a.tK) {
        b += a.qG;
        var c = a.array[b];
        return c !== gvjs_Vg ? c : a.array[b] = gvjs_Rg([])
    }
    if (a.Kl)
        return c = a.Kl[b],
        c !== gvjs_Vg ? c : a.Kl[b] = gvjs_Rg([])
}
gvjs_ = gvjs_Sg.prototype;
gvjs_.um = function() {
    if (this.se)
        for (var a in this.se) {
            var b = this.se[a];
            if (Array.isArray(b))
                for (var c = 0; c < b.length; c++)
                    b[c] && b[c].um();
            else
                b && b.um()
        }
    return this.array
}
;
gvjs_.ie = function() {
    return JSON.stringify(this.array && this.um(), gvjs_Paa)
}
;
function gvjs_Paa(a, b) {
    switch (typeof b) {
    case gvjs_g:
        return isNaN(b) || Infinity === b || -Infinity === b ? String(b) : b;
    case gvjs_h:
        if (gvjs_Og && null != b && b instanceof Uint8Array) {
            var c;
            void 0 === c && (c = 0);
            if (!gvjs_Ng) {
                gvjs_Ng = {};
                a = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".split("");
                for (var d = ["+/=", "+/", "-_=", "-_.", "-_"], e = 0; 5 > e; e++) {
                    var f = a.concat(d[e].split(""));
                    gvjs_Mg[e] = f;
                    for (var g = 0; g < f.length; g++) {
                        var h = f[g];
                        void 0 === gvjs_Ng[h] && (gvjs_Ng[h] = g)
                    }
                }
            }
            c = gvjs_Mg[c];
            a = Array(Math.floor(b.length / 3));
            d = c[64] || "";
            for (e = f = 0; f < b.length - 2; f += 3) {
                var k = b[f]
                  , l = b[f + 1];
                h = b[f + 2];
                g = c[k >> 2];
                k = c[(k & 3) << 4 | l >> 4];
                l = c[(l & 15) << 2 | h >> 6];
                h = c[h & 63];
                a[e++] = "" + g + k + l + h
            }
            g = 0;
            h = d;
            switch (b.length - f) {
            case 2:
                g = b[f + 1],
                h = c[(g & 15) << 2] || d;
            case 1:
                b = b[f],
                a[e] = "" + c[b >> 2] + c[(b & 3) << 4 | g >> 4] + h + d
            }
            return a.join("")
        }
    }
    return b
}
gvjs_.toString = function() {
    return this.um().toString()
}
;
gvjs_.getExtension = function(a) {
    gvjs_Wg(this);
    this.se || (this.se = {});
    var b = a.vDa;
    return a.WDa ? a.jsa() ? (this.se[b] || (this.se[b] = gvjs_v(this.Kl[b] || [], function(c) {
        return new a.nma(c)
    })),
    this.se[b]) : this.Kl[b] = this.Kl[b] || gvjs_Rg([]) : a.jsa() ? (!this.se[b] && this.Kl[b] && (this.se[b] = new a.nma(this.Kl[b])),
    this.se[b]) : this.Kl[b]
}
;
gvjs_.clone = function() {
    var a = gvjs_Naa(this.um());
    gvjs_Tg = a;
    a = new this.constructor(a);
    gvjs_Tg = null;
    return a
}
;
/*

 Copyright 2021 Google LLC
 This code is released under the MIT license.
 SPDX-License-Identifier: MIT

*/
function gvjs_Yg(a) {
    this.vQ = !1;
    this.Hg = a || null
}
gvjs_Yg.prototype.xha = function(a, b) {
    var c = this;
    return function(d) {
        for (var e = [], f = 0; f < arguments.length; ++f)
            e[f - 0] = arguments[f];
        if (!c.vQ)
            return c.Hg ? gvjs_Zg(c.Hg, function() {
                return a.apply(b, e)
            }) : a.apply(b, e)
    }
}
;
try {
    (new self.OffscreenCanvas(0,0)).getContext("2d")
} catch (a) {}
var gvjs_Qaa = !gvjs_y || gvjs_Fg(9)
  , gvjs_Raa = !gvjs_sg && !gvjs_y || gvjs_y && gvjs_Fg(9) || gvjs_sg && gvjs_Eg("1.9.1")
  , gvjs__g = gvjs_y && !gvjs_Eg("9")
  , gvjs_Saa = gvjs_y || gvjs_qg || gvjs_tg;
function gvjs_0g(a, b, c) {
    return Math.min(Math.max(a, b), c)
}
function gvjs_1g(a) {
    return isFinite(a) && 0 == a % 1
}
;function gvjs_z(a, b) {
    this.x = void 0 !== a ? a : 0;
    this.y = void 0 !== b ? b : 0
}
gvjs_ = gvjs_z.prototype;
gvjs_.clone = function() {
    return new gvjs_z(this.x,this.y)
}
;
gvjs_.equals = function(a) {
    return a instanceof gvjs_z && gvjs_2g(this, a)
}
;
function gvjs_2g(a, b) {
    return a == b ? !0 : a && b ? a.x == b.x && a.y == b.y : !1
}
gvjs_.ceil = function() {
    this.x = Math.ceil(this.x);
    this.y = Math.ceil(this.y);
    return this
}
;
gvjs_.floor = function() {
    this.x = Math.floor(this.x);
    this.y = Math.floor(this.y);
    return this
}
;
gvjs_.round = function() {
    this.x = Math.round(this.x);
    this.y = Math.round(this.y);
    return this
}
;
gvjs_.translate = function(a, b) {
    a instanceof gvjs_z ? (this.x += a.x,
    this.y += a.y) : (this.x += Number(a),
    typeof b === gvjs_g && (this.y += b));
    return this
}
;
gvjs_.scale = function(a, b) {
    this.x *= a;
    this.y *= typeof b === gvjs_g ? b : a;
    return this
}
;
function gvjs_A(a, b) {
    this.width = a;
    this.height = b
}
gvjs_ = gvjs_A.prototype;
gvjs_.clone = function() {
    return new gvjs_A(this.width,this.height)
}
;
gvjs_.area = function() {
    return this.width * this.height
}
;
gvjs_.aspectRatio = function() {
    return this.width / this.height
}
;
gvjs_.isEmpty = function() {
    return !this.area()
}
;
gvjs_.ceil = function() {
    this.width = Math.ceil(this.width);
    this.height = Math.ceil(this.height);
    return this
}
;
gvjs_.floor = function() {
    this.width = Math.floor(this.width);
    this.height = Math.floor(this.height);
    return this
}
;
gvjs_.round = function() {
    this.width = Math.round(this.width);
    this.height = Math.round(this.height);
    return this
}
;
gvjs_.scale = function(a, b) {
    this.width *= a;
    this.height *= typeof b === gvjs_g ? b : a;
    return this
}
;
function gvjs_3g(a) {
    return a ? new gvjs_4g(gvjs_5g(a)) : gvjs_we || (gvjs_we = new gvjs_4g)
}
function gvjs_6g(a, b) {
    return typeof b === gvjs_l ? a.getElementById(b) : b
}
function gvjs_7g(a, b, c, d) {
    a = d || a;
    b = b && "*" != b ? String(b).toUpperCase() : "";
    if (a.querySelectorAll && a.querySelector && (b || c))
        return a.querySelectorAll(b + (c ? "." + c : ""));
    if (c && a.getElementsByClassName) {
        a = a.getElementsByClassName(c);
        if (b) {
            d = {};
            for (var e = 0, f = 0, g; g = a[f]; f++)
                b == g.nodeName && (d[e++] = g);
            d.length = e;
            return d
        }
        return a
    }
    a = a.getElementsByTagName(b || "*");
    if (c) {
        d = {};
        for (f = e = 0; g = a[f]; f++)
            b = g.className,
            typeof b.split == gvjs_d && gvjs_He(b.split(/\s+/), c) && (d[e++] = g);
        d.length = e;
        return d
    }
    return a
}
function gvjs_8g(a, b) {
    gvjs_w(b, function(c, d) {
        c && typeof c == gvjs_h && c.Po && (c = c.Tk());
        d == gvjs_Jd ? a.style.cssText = c : d == gvjs_Cb ? a.className = c : "for" == d ? a.htmlFor = c : gvjs_9g.hasOwnProperty(d) ? a.setAttribute(gvjs_9g[d], c) : gvjs_hf(d, "aria-") || gvjs_hf(d, "data-") ? a.setAttribute(d, c) : a[d] = c
    })
}
var gvjs_9g = {
    cellpadding: "cellPadding",
    cellspacing: "cellSpacing",
    colspan: "colSpan",
    frameborder: "frameBorder",
    height: gvjs_4c,
    maxlength: "maxLength",
    nonce: gvjs_qd,
    role: gvjs_Bd,
    rowspan: "rowSpan",
    type: gvjs_Sd,
    usemap: "useMap",
    valign: "vAlign",
    width: gvjs_Xd
};
function gvjs_$g(a, b) {
    var c = String(b[0])
      , d = b[1];
    if (!gvjs_Qaa && d && (d.name || d.type)) {
        c = ["<", c];
        d.name && c.push(' name="', gvjs_dg(d.name), '"');
        if (d.type) {
            c.push(' type="', gvjs_dg(d.type), '"');
            var e = {};
            gvjs_2e(e, d);
            delete e.type;
            d = e
        }
        c.push(">");
        c = c.join("")
    }
    c = gvjs_ah(a, c);
    d && (typeof d === gvjs_l ? c.className = d : Array.isArray(d) ? c.className = d.join(" ") : gvjs_8g(c, d));
    2 < b.length && gvjs_bh(a, c, b, 2);
    return c
}
function gvjs_bh(a, b, c, d) {
    function e(h) {
        h && b.appendChild(typeof h === gvjs_l ? a.createTextNode(h) : h)
    }
    for (; d < c.length; d++) {
        var f = c[d];
        if (gvjs_ne(f) && !gvjs_ch(f)) {
            a: {
                if (f && typeof f.length == gvjs_g) {
                    if (gvjs_r(f)) {
                        var g = typeof f.item == gvjs_d || typeof f.item == gvjs_l;
                        break a
                    }
                    if (typeof f === gvjs_d) {
                        g = typeof f.item == gvjs_d;
                        break a
                    }
                }
                g = !1
            }
            gvjs_u(g ? gvjs_Le(f) : f, e)
        } else
            e(f)
    }
}
function gvjs_dh(a) {
    return gvjs_ah(document, a)
}
function gvjs_ah(a, b) {
    b = String(b);
    "application/xhtml+xml" === a.contentType && (b = b.toLowerCase());
    return a.createElement(b)
}
function gvjs_eh(a) {
    return "CSS1Compat" == a.compatMode
}
function gvjs_fh(a) {
    if (1 != a.nodeType)
        return !1;
    switch (a.tagName) {
    case "APPLET":
    case "AREA":
    case "BASE":
    case "BR":
    case "COL":
    case "COMMAND":
    case "EMBED":
    case "FRAME":
    case "HR":
    case "IMG":
    case gvjs_Na:
    case gvjs_Ma:
    case "ISINDEX":
    case "KEYGEN":
    case "LINK":
    case "NOFRAMES":
    case "NOSCRIPT":
    case "META":
    case gvjs_0a:
    case "PARAM":
    case "SCRIPT":
    case gvjs_5a:
    case gvjs_7a:
    case "TRACK":
    case "WBR":
        return !1
    }
    return !0
}
function gvjs_gh(a, b) {
    gvjs_bh(gvjs_5g(a), a, arguments, 1)
}
function gvjs_hh(a) {
    for (var b; b = a.firstChild; )
        a.removeChild(b)
}
function gvjs_ih(a, b) {
    b.parentNode && b.parentNode.insertBefore(a, b)
}
function gvjs_jh(a, b) {
    b.parentNode && b.parentNode.insertBefore(a, b.nextSibling)
}
function gvjs_kh(a) {
    return a && a.parentNode ? a.parentNode.removeChild(a) : null
}
function gvjs_lh(a) {
    return gvjs_Raa && void 0 != a.children ? a.children : Array.prototype.filter.call(a.childNodes, function(b) {
        return 1 == b.nodeType
    })
}
function gvjs_mh(a) {
    return void 0 !== a.firstElementChild ? a.firstElementChild : gvjs_nh(a.firstChild, !0)
}
function gvjs_oh(a) {
    return void 0 !== a.nextElementSibling ? a.nextElementSibling : gvjs_nh(a.nextSibling, !0)
}
function gvjs_nh(a, b) {
    for (; a && 1 != a.nodeType; )
        a = b ? a.nextSibling : a.previousSibling;
    return a
}
function gvjs_ch(a) {
    return gvjs_r(a) && 0 < a.nodeType
}
function gvjs_ph(a) {
    return gvjs_r(a) && 1 == a.nodeType
}
function gvjs_qh(a) {
    var b;
    if (gvjs_Saa && !(gvjs_y && gvjs_Eg("9") && !gvjs_Eg("10") && gvjs_p.SVGElement && a instanceof gvjs_p.SVGElement) && (b = a.parentElement))
        return b;
    b = a.parentNode;
    return gvjs_ph(b) ? b : null
}
function gvjs_rh(a, b) {
    if (!a || !b)
        return !1;
    if (a.contains && 1 == b.nodeType)
        return a == b || a.contains(b);
    if ("undefined" != typeof a.compareDocumentPosition)
        return a == b || !!(a.compareDocumentPosition(b) & 16);
    for (; b && a != b; )
        b = b.parentNode;
    return b == a
}
function gvjs_5g(a) {
    return 9 == a.nodeType ? a : a.ownerDocument || a.document
}
function gvjs_sh(a) {
    return a.contentDocument || a.contentWindow.document
}
function gvjs_th(a, b) {
    if ("textContent"in a)
        a.textContent = b;
    else if (3 == a.nodeType)
        a.data = String(b);
    else if (a.firstChild && 3 == a.firstChild.nodeType) {
        for (; a.lastChild != a.firstChild; )
            a.removeChild(a.lastChild);
        a.firstChild.data = String(b)
    } else
        gvjs_hh(a),
        a.appendChild(gvjs_5g(a).createTextNode(String(b)))
}
function gvjs_uh(a) {
    if ("outerHTML"in a)
        return a.outerHTML;
    var b = gvjs_ah(gvjs_5g(a), gvjs_b);
    b.appendChild(a.cloneNode(!0));
    return b.innerHTML
}
var gvjs_Taa = {
    SCRIPT: 1,
    STYLE: 1,
    HEAD: 1,
    IFRAME: 1,
    OBJECT: 1
}
  , gvjs_vh = {
    IMG: " ",
    BR: "\n"
};
function gvjs_wh(a) {
    if (gvjs__g && null !== a && "innerText"in a)
        a = a.innerText.replace(/(\r\n|\r|\n)/g, "\n");
    else {
        var b = [];
        gvjs_xh(a, b, !0);
        a = b.join("")
    }
    a = a.replace(/ \xAD /g, " ").replace(/\xAD/g, "");
    a = a.replace(/\u200B/g, "");
    gvjs__g || (a = a.replace(/ +/g, " "));
    " " != a && (a = a.replace(/^\s*/, ""));
    return a
}
function gvjs_xh(a, b, c) {
    if (!(a.nodeName in gvjs_Taa))
        if (3 == a.nodeType)
            c ? b.push(String(a.nodeValue).replace(/(\r\n|\r|\n)/g, "")) : b.push(a.nodeValue);
        else if (a.nodeName in gvjs_vh)
            b.push(gvjs_vh[a.nodeName]);
        else
            for (a = a.firstChild; a; )
                gvjs_xh(a, b, c),
                a = a.nextSibling
}
function gvjs_yh(a, b, c, d) {
    a && !c && (a = a.parentNode);
    for (c = 0; a && (null == d || c <= d); ) {
        if (b(a))
            return a;
        a = a.parentNode;
        c++
    }
    return null
}
function gvjs_4g(a) {
    this.dd = a || gvjs_p.document || document
}
gvjs_ = gvjs_4g.prototype;
gvjs_.wa = gvjs_3g;
gvjs_.kc = function() {
    return this.dd
}
;
gvjs_.j = function(a) {
    return gvjs_6g(this.dd, a)
}
;
gvjs_.getElementsByTagName = function(a, b) {
    return (b || this.dd).getElementsByTagName(String(a))
}
;
function gvjs_zh(a, b, c, d) {
    return gvjs_7g(a.dd, b, c, d)
}
gvjs_.wq = gvjs_n(0);
gvjs_.hd = gvjs_n(2);
gvjs_.yP = gvjs_n(4);
gvjs_.sr = gvjs_8g;
gvjs_.J = function(a, b, c) {
    return gvjs_$g(this.dd, arguments)
}
;
gvjs_.createElement = function(a) {
    return gvjs_ah(this.dd, a)
}
;
gvjs_.createTextNode = function(a) {
    return this.dd.createTextNode(String(a))
}
;
gvjs_.wX = gvjs_n(5);
gvjs_.Vj = function() {
    var a = this.dd;
    return a.parentWindow || a.defaultView
}
;
gvjs_.Ly = gvjs_n(6);
gvjs_.appendChild = function(a, b) {
    a.appendChild(b)
}
;
gvjs_.append = gvjs_gh;
gvjs_.canHaveChildren = gvjs_fh;
gvjs_.qc = gvjs_hh;
gvjs_.H_ = gvjs_ih;
gvjs_.Sra = gvjs_jh;
gvjs_.removeNode = gvjs_kh;
gvjs_.getChildren = gvjs_lh;
gvjs_.O$ = gvjs_mh;
gvjs_.P$ = gvjs_oh;
gvjs_.Qo = gvjs_ch;
gvjs_.O_ = gvjs_ph;
gvjs_.isWindow = function(a) {
    return gvjs_r(a) && a.window == a
}
;
gvjs_.tP = gvjs_qh;
gvjs_.contains = gvjs_rh;
gvjs_.Toa = gvjs_5g;
gvjs_.Noa = gvjs_sh;
gvjs_.V3 = gvjs_th;
gvjs_.Gq = gvjs_n(8);
gvjs_.Voa = gvjs_wh;
gvjs_.G$ = gvjs_yh;
function gvjs_B(a, b, c, d) {
    this.top = a;
    this.right = b;
    this.bottom = c;
    this.left = d
}
gvjs_ = gvjs_B.prototype;
gvjs_.La = gvjs_n(10);
gvjs_.getHeight = function() {
    return this.bottom - this.top
}
;
gvjs_.clone = function() {
    return new gvjs_B(this.top,this.right,this.bottom,this.left)
}
;
gvjs_.contains = function(a) {
    return this && a ? a instanceof gvjs_B ? a.left >= this.left && a.right <= this.right && a.top >= this.top && a.bottom <= this.bottom : a.x >= this.left && a.x <= this.right && a.y >= this.top && a.y <= this.bottom : !1
}
;
gvjs_.expand = function(a, b, c, d) {
    gvjs_r(a) ? (this.top -= a.top,
    this.right += a.right,
    this.bottom += a.bottom,
    this.left -= a.left) : (this.top -= a,
    this.right += Number(b),
    this.bottom += Number(c),
    this.left -= Number(d));
    return this
}
;
gvjs_.ceil = function() {
    this.top = Math.ceil(this.top);
    this.right = Math.ceil(this.right);
    this.bottom = Math.ceil(this.bottom);
    this.left = Math.ceil(this.left);
    return this
}
;
gvjs_.floor = function() {
    this.top = Math.floor(this.top);
    this.right = Math.floor(this.right);
    this.bottom = Math.floor(this.bottom);
    this.left = Math.floor(this.left);
    return this
}
;
gvjs_.round = function() {
    this.top = Math.round(this.top);
    this.right = Math.round(this.right);
    this.bottom = Math.round(this.bottom);
    this.left = Math.round(this.left);
    return this
}
;
gvjs_.translate = function(a, b) {
    a instanceof gvjs_z ? (this.left += a.x,
    this.right += a.x,
    this.top += a.y,
    this.bottom += a.y) : (this.left += a,
    this.right += a,
    typeof b === gvjs_g && (this.top += b,
    this.bottom += b));
    return this
}
;
gvjs_.scale = function(a, b) {
    b = typeof b === gvjs_g ? b : a;
    this.left *= a;
    this.right *= a;
    this.top *= b;
    this.bottom *= b;
    return this
}
;
function gvjs_C(a, b, c) {
    if (typeof b === gvjs_l)
        (b = gvjs_Ah(a, b)) && (a.style[b] = c);
    else
        for (var d in b) {
            c = a;
            var e = b[d]
              , f = gvjs_Ah(c, d);
            f && (c.style[f] = e)
        }
}
var gvjs_Bh = {};
function gvjs_Ah(a, b) {
    var c = gvjs_Bh[b];
    if (!c) {
        var d = gvjs_kg(b);
        c = d;
        void 0 === a.style[d] && (d = (gvjs_tg ? "Webkit" : gvjs_sg ? "Moz" : gvjs_y ? "ms" : gvjs_qg ? "O" : null) + gvjs_Baa(d),
        void 0 !== a.style[d] && (c = d));
        gvjs_Bh[b] = c
    }
    return c
}
function gvjs_Ch(a, b) {
    var c = gvjs_5g(a);
    return c.defaultView && c.defaultView.getComputedStyle && (a = c.defaultView.getComputedStyle(a, null)) ? a[b] || a.getPropertyValue(b) || "" : ""
}
function gvjs_Dh(a, b) {
    return gvjs_Ch(a, b) || (a.currentStyle ? a.currentStyle[b] : null) || a.style && a.style[b]
}
function gvjs_Eh(a) {
    return gvjs_Dh(a, gvjs_vd)
}
var gvjs_Fh = gvjs_sg ? "MozUserSelect" : gvjs_tg || gvjs_rg ? "WebkitUserSelect" : null;
function gvjs_Gh(a) {
    var b = gvjs_5g(a)
      , c = gvjs_y && a.currentStyle;
    if (c && gvjs_eh(gvjs_3g(b).dd) && c.width != gvjs_ub && c.height != gvjs_ub && !c.boxSizing)
        return b = gvjs_Hh(a, c.width, gvjs_Xd, "pixelWidth"),
        a = gvjs_Hh(a, c.height, gvjs_4c, "pixelHeight"),
        new gvjs_A(b,a);
    c = new gvjs_A(a.offsetWidth,a.offsetHeight);
    b = gvjs_Ih(a);
    a = gvjs_Jh(a);
    return new gvjs_A(c.width - a.left - b.left - b.right - a.right,c.height - a.top - b.top - b.bottom - a.bottom)
}
function gvjs_Hh(a, b, c, d) {
    if (/^\d+px?$/.test(b))
        return parseInt(b, 10);
    var e = a.style[c]
      , f = a.runtimeStyle[c];
    a.runtimeStyle[c] = a.currentStyle[c];
    a.style[c] = b;
    b = a.style[d];
    a.style[c] = e;
    a.runtimeStyle[c] = f;
    return +b
}
function gvjs_Kh(a, b) {
    return (b = a.currentStyle ? a.currentStyle[b] : null) ? gvjs_Hh(a, b, gvjs_$c, "pixelLeft") : 0
}
function gvjs_Ih(a) {
    if (gvjs_y) {
        var b = gvjs_Kh(a, "paddingLeft")
          , c = gvjs_Kh(a, "paddingRight")
          , d = gvjs_Kh(a, "paddingTop");
        a = gvjs_Kh(a, "paddingBottom");
        return new gvjs_B(d,c,a,b)
    }
    b = gvjs_Ch(a, "paddingLeft");
    c = gvjs_Ch(a, "paddingRight");
    d = gvjs_Ch(a, "paddingTop");
    a = gvjs_Ch(a, "paddingBottom");
    return new gvjs_B(parseFloat(d),parseFloat(c),parseFloat(a),parseFloat(b))
}
var gvjs_Lh = {
    thin: 2,
    medium: 4,
    thick: 6
};
function gvjs_Mh(a, b) {
    if ((a.currentStyle ? a.currentStyle[b + "Style"] : null) == gvjs_f)
        return 0;
    b = a.currentStyle ? a.currentStyle[b + "Width"] : null;
    return b in gvjs_Lh ? gvjs_Lh[b] : gvjs_Hh(a, b, gvjs_$c, "pixelLeft")
}
function gvjs_Jh(a) {
    if (gvjs_y && !gvjs_Fg(9)) {
        var b = gvjs_Mh(a, "borderLeft")
          , c = gvjs_Mh(a, "borderRight")
          , d = gvjs_Mh(a, "borderTop");
        a = gvjs_Mh(a, "borderBottom");
        return new gvjs_B(d,c,a,b)
    }
    b = gvjs_Ch(a, "borderLeftWidth");
    c = gvjs_Ch(a, "borderRightWidth");
    d = gvjs_Ch(a, "borderTopWidth");
    a = gvjs_Ch(a, "borderBottomWidth");
    return new gvjs_B(parseFloat(d),parseFloat(c),parseFloat(a),parseFloat(b))
}
;/*

 Copyright 2021 Google LLC
 This code is released under the MIT license.
 SPDX-License-Identifier: MIT
*/
var gvjs_Nh = null;
function gvjs_Oh() {
    null == gvjs_Nh && (gvjs_Nh = new gvjs_4g);
    return gvjs_Nh
}
function gvjs_Ph() {
    return gvjs_Oh().kc()
}
function gvjs_Qh(a) {
    var b = gvjs_Oh();
    if (!a || !b.Qo(a))
        throw Error(gvjs_za);
    return a
}
;var gvjs_D = {
    rV: "google-visualization-errors"
};
gvjs_D.s6 = gvjs_D.rV + "-";
gvjs_D.v6 = gvjs_D.rV + ":";
gvjs_D.mV = gvjs_D.rV + "-all-";
gvjs_D.r6 = gvjs_D.v6 + " container is null";
gvjs_D.tia = "background-color: #c00000; color: white; padding: 2px;";
gvjs_D.Qja = "background-color: #fff4c2; color: black; white-space: nowrap; padding: 2px; border: 1px solid black;";
gvjs_D.Sja = "font: normal 0.8em arial,sans-serif; margin-bottom: 5px;";
gvjs_D.qja = "font-size: 1.1em; color: #00c; font-weight: bold; cursor: pointer; padding-left: 10px; color: black;text-align: right; vertical-align: top;";
var gvjs_Rh = 0;
function gvjs_Sh(a, b, c, d) {
    if (!gvjs_Th(a))
        throw Error(gvjs_D.r6 + ". message: " + b);
    d = gvjs_Uh(b, c, d);
    var e = d.errorMessage;
    c = d.detailedMessage;
    d = d.options;
    var f = null != d.showInTooltip ? !!d.showInTooltip : !0
      , g = (d.type === gvjs_Wd ? gvjs_Wd : gvjs_Rb) === gvjs_Rb ? gvjs_D.tia : gvjs_D.Qja;
    g += d.style ? d.style : "";
    var h = !!d.removable;
    b = gvjs_Oh();
    e = b.J(gvjs_6a, {
        style: g
    }, b.createTextNode(e));
    g = "" + gvjs_D.s6 + gvjs_Rh++;
    var k = b.J(gvjs_b, {
        id: g,
        style: gvjs_D.Sja
    }, e);
    c && (f ? e.title = c : (c = b.J(gvjs_6a, {}, b.createTextNode(c)),
    b.appendChild(k, b.J(gvjs_b, {
        style: "padding: 2px"
    }, c))));
    h && (c = b.J(gvjs_6a, {
        style: gvjs_D.qja
    }, b.createTextNode("\u00d7")),
    c.onclick = gvjs_re(gvjs_Vh, k),
    b.appendChild(e, c));
    gvjs_Wh(a, k);
    d.removeDuplicates && gvjs_Xh(a, k);
    return g
}
gvjs_D.Sc = gvjs_Sh;
gvjs_D.removeAll = function(a) {
    gvjs_Yh(a);
    if (a = gvjs_Zh(a, !1))
        a.style.display = gvjs_f,
        gvjs_hh(a)
}
;
gvjs_D.yva = function(a) {
    a = gvjs_Ph().getElementById(a);
    return null != a && gvjs__h(a) ? (gvjs_Vh(a),
    !0) : !1
}
;
gvjs_D.getContainer = function(a) {
    a = gvjs_Ph().getElementById(a);
    return null != a && gvjs__h(a) && null != a.parentNode && null != a.parentNode.parentNode ? a.parentNode.parentNode : null
}
;
gvjs_D.uX = function(a, b) {
    return function() {
        try {
            a.apply(null, arguments)
        } catch (c) {
            typeof b === gvjs_d ? b(c) : gvjs_Sh(b, c.message)
        }
    }
}
;
function gvjs_Vh(a) {
    var b = a.parentNode;
    gvjs_kh(a);
    b && 0 === b.childNodes.length && (b.style.display = gvjs_f)
}
gvjs_D.LDa = gvjs_Vh;
function gvjs__h(a) {
    return gvjs_ch(a) && a.id && gvjs_hf(a.id, gvjs_D.s6) && (a = a.parentNode) && a.id && gvjs_hf(a.id, gvjs_D.mV) && a.parentNode ? !0 : !1
}
gvjs_D.FEa = gvjs__h;
function gvjs_Uh(a, b, c) {
    var d = null != a && a ? a : gvjs_Rb
      , e = "";
    c = c || {};
    var f = arguments.length;
    2 === f ? b && typeof b === gvjs_h ? c = b : e = null != b ? b : e : 3 === f && (e = null != b ? b : e);
    d = gvjs_kf(d);
    e = gvjs_kf(e || "");
    return {
        errorMessage: d,
        detailedMessage: e,
        options: c
    }
}
gvjs_D.SDa = gvjs_Uh;
function gvjs_Th(a) {
    return null != a && gvjs_ch(a)
}
gvjs_D.EEa = gvjs_Th;
function gvjs_Yh(a, b) {
    if (!gvjs_Th(a))
        throw Error((void 0 === b ? "" : b) || gvjs_D.r6);
}
gvjs_D.Vya = gvjs_Yh;
function gvjs_Zh(a, b) {
    for (var c = a.childNodes, d = null, e = gvjs_Oh(), f = 0; f < c.length; f++) {
        var g = c[f];
        if (g.id && gvjs_hf(g.id, gvjs_D.mV)) {
            d = g;
            e.removeNode(d);
            break
        }
    }
    !d && b && (d = "" + gvjs_D.mV + gvjs_Rh++,
    d = e.J(gvjs_b, {
        id: d,
        style: "display: none; padding-top: 2px"
    }, null));
    d && ((b = a.firstChild) ? e.H_(d, b) : e.appendChild(a, d));
    return d
}
gvjs_D.CDa = gvjs_Zh;
function gvjs_Wh(a, b) {
    a = gvjs_Zh(a, !0);
    a.style.display = gvjs_xb;
    a.appendChild(b)
}
gvjs_D.addElement = gvjs_Wh;
function gvjs_0h(a, b) {
    a = (a = gvjs_Zh(a, !0)) && gvjs_lh(a);
    gvjs_u(a, function(c) {
        gvjs__h(c) && b(c)
    })
}
gvjs_D.zDa = gvjs_0h;
function gvjs_Xh(a, b) {
    var c = /id="?google-visualization-errors-[0-9]*"?/
      , d = gvjs_uh(b);
    d = d.replace(c, "");
    var e = [];
    gvjs_0h(a, function(f) {
        if (f !== b) {
            var g = gvjs_uh(f);
            g = g.replace(c, "");
            g === d && e.push(f)
        }
    });
    gvjs_u(e, gvjs_Vh);
    return e.length
}
gvjs_D.mEa = gvjs_Xh;
function gvjs_E(a) {
    a && typeof a.pa == gvjs_d && a.pa()
}
;function gvjs_F() {
    this.xf = this.xf;
    this.Wz = this.Wz
}
gvjs_F.prototype.xf = !1;
gvjs_F.prototype.fh = gvjs_n(11);
gvjs_F.prototype.pa = function() {
    this.xf || (this.xf = !0,
    this.M())
}
;
gvjs_F.prototype.M = function() {
    if (this.Wz)
        for (; this.Wz.length; )
            this.Wz.shift()()
}
;
function gvjs_1h(a, b) {
    this.type = a;
    this.currentTarget = this.target = b;
    this.defaultPrevented = this.CK = !1
}
gvjs_1h.prototype.stopPropagation = function() {
    this.CK = !0
}
;
gvjs_1h.prototype.preventDefault = function() {
    this.defaultPrevented = !0
}
;
var gvjs_2h = "PointerEvent"in gvjs_p
  , gvjs_3h = "MSPointerEvent"in gvjs_p && !(!gvjs_p.navigator || !gvjs_p.navigator.msPointerEnabled)
  , gvjs_Uaa = function() {
    if (!gvjs_p.addEventListener || !Object.defineProperty)
        return !1;
    var a = !1
      , b = Object.defineProperty({}, "passive", {
        get: function() {
            a = !0
        }
    });
    try {
        gvjs_p.addEventListener("test", gvjs_ke, b),
        gvjs_p.removeEventListener("test", gvjs_ke, b)
    } catch (c) {}
    return a
}();
var gvjs_4h = {
    ux: gvjs_2h ? "pointerdown" : gvjs_3h ? "MSPointerDown" : gvjs_gd,
    wx: gvjs_2h ? "pointerup" : gvjs_3h ? "MSPointerUp" : gvjs_md,
    mB: gvjs_2h ? "pointercancel" : gvjs_3h ? "MSPointerCancel" : "mousecancel",
    Yia: gvjs_2h ? "pointermove" : gvjs_3h ? "MSPointerMove" : gvjs_jd,
    $ia: gvjs_2h ? "pointerover" : gvjs_3h ? "MSPointerOver" : gvjs_ld,
    Zia: gvjs_2h ? "pointerout" : gvjs_3h ? "MSPointerOut" : gvjs_kd,
    Wia: gvjs_2h ? "pointerenter" : gvjs_3h ? "MSPointerEnter" : gvjs_hd,
    Xia: gvjs_2h ? "pointerleave" : gvjs_3h ? "MSPointerLeave" : gvjs_id
};
function gvjs_5h(a, b) {
    gvjs_1h.call(this, a ? a.type : "");
    this.relatedTarget = this.currentTarget = this.target = null;
    this.button = this.screenY = this.screenX = this.clientY = this.clientX = this.offsetY = this.offsetX = 0;
    this.key = "";
    this.charCode = this.keyCode = 0;
    this.metaKey = this.shiftKey = this.altKey = this.ctrlKey = !1;
    this.state = null;
    this.m2 = !1;
    this.pointerId = 0;
    this.pointerType = "";
    this.$i = null;
    a && this.init(a, b)
}
gvjs_t(gvjs_5h, gvjs_1h);
var gvjs_Vaa = {
    2: "touch",
    3: "pen",
    4: "mouse"
};
gvjs_5h.prototype.init = function(a, b) {
    var c = this.type = a.type
      , d = a.changedTouches && a.changedTouches.length ? a.changedTouches[0] : null;
    this.target = a.target || a.srcElement;
    this.currentTarget = b;
    (b = a.relatedTarget) ? gvjs_sg && (gvjs_og(b, gvjs_od) || (b = null)) : c == gvjs_ld ? b = a.fromElement : c == gvjs_kd && (b = a.toElement);
    this.relatedTarget = b;
    d ? (this.clientX = void 0 !== d.clientX ? d.clientX : d.pageX,
    this.clientY = void 0 !== d.clientY ? d.clientY : d.pageY,
    this.screenX = d.screenX || 0,
    this.screenY = d.screenY || 0) : (this.offsetX = gvjs_tg || void 0 !== a.offsetX ? a.offsetX : a.layerX,
    this.offsetY = gvjs_tg || void 0 !== a.offsetY ? a.offsetY : a.layerY,
    this.clientX = void 0 !== a.clientX ? a.clientX : a.pageX,
    this.clientY = void 0 !== a.clientY ? a.clientY : a.pageY,
    this.screenX = a.screenX || 0,
    this.screenY = a.screenY || 0);
    this.button = a.button;
    this.keyCode = a.keyCode || 0;
    this.key = a.key || "";
    this.charCode = a.charCode || (c == gvjs_7c ? a.keyCode : 0);
    this.ctrlKey = a.ctrlKey;
    this.altKey = a.altKey;
    this.shiftKey = a.shiftKey;
    this.metaKey = a.metaKey;
    this.m2 = gvjs_ug ? a.metaKey : a.ctrlKey;
    this.pointerId = a.pointerId || 0;
    this.pointerType = typeof a.pointerType === gvjs_l ? a.pointerType : gvjs_Vaa[a.pointerType] || "";
    this.state = a.state;
    this.$i = a;
    a.defaultPrevented && gvjs_5h.G.preventDefault.call(this)
}
;
gvjs_5h.prototype.stopPropagation = function() {
    gvjs_5h.G.stopPropagation.call(this);
    this.$i.stopPropagation ? this.$i.stopPropagation() : this.$i.cancelBubble = !0
}
;
gvjs_5h.prototype.preventDefault = function() {
    gvjs_5h.G.preventDefault.call(this);
    var a = this.$i;
    a.preventDefault ? a.preventDefault() : a.returnValue = !1
}
;
var gvjs_6h = "closure_listenable_" + (1E6 * Math.random() | 0);
function gvjs_7h(a) {
    return !(!a || !a[gvjs_6h])
}
;var gvjs_Waa = 0;
function gvjs_Xaa(a, b, c, d, e) {
    this.listener = a;
    this.pS = null;
    this.src = b;
    this.type = c;
    this.capture = !!d;
    this.handler = e;
    this.key = ++gvjs_Waa;
    this.An = this.wN = !1
}
function gvjs_8h(a) {
    a.An = !0;
    a.listener = null;
    a.pS = null;
    a.src = null;
    a.handler = null
}
;function gvjs_9h(a) {
    this.src = a;
    this.Rh = {};
    this.ZL = 0
}
gvjs_ = gvjs_9h.prototype;
gvjs_.add = function(a, b, c, d, e) {
    var f = a.toString();
    a = this.Rh[f];
    a || (a = this.Rh[f] = [],
    this.ZL++);
    var g = gvjs_$h(a, b, d, e);
    -1 < g ? (b = a[g],
    c || (b.wN = !1)) : (b = new gvjs_Xaa(b,this.src,f,!!d,e),
    b.wN = c,
    a.push(b));
    return b
}
;
gvjs_.remove = function(a, b, c, d) {
    a = a.toString();
    if (!(a in this.Rh))
        return !1;
    var e = this.Rh[a];
    b = gvjs_$h(e, b, c, d);
    return -1 < b ? (gvjs_8h(e[b]),
    gvjs_Je(e, b),
    0 == e.length && (delete this.Rh[a],
    this.ZL--),
    !0) : !1
}
;
function gvjs_ai(a, b) {
    var c = b.type;
    if (!(c in a.Rh))
        return !1;
    var d = gvjs_Ie(a.Rh[c], b);
    d && (gvjs_8h(b),
    0 == a.Rh[c].length && (delete a.Rh[c],
    a.ZL--));
    return d
}
gvjs_.removeAll = function(a) {
    a = a && a.toString();
    var b = 0, c;
    for (c in this.Rh)
        if (!a || c == a) {
            for (var d = this.Rh[c], e = 0; e < d.length; e++)
                ++b,
                gvjs_8h(d[e]);
            delete this.Rh[c];
            this.ZL--
        }
    return b
}
;
gvjs_.EC = gvjs_n(13);
gvjs_.uI = function(a, b, c, d) {
    a = this.Rh[a.toString()];
    var e = -1;
    a && (e = gvjs_$h(a, b, c, d));
    return -1 < e ? a[e] : null
}
;
gvjs_.hasListener = function(a, b) {
    var c = void 0 !== a
      , d = c ? a.toString() : ""
      , e = void 0 !== b;
    return gvjs_Ue(this.Rh, function(f) {
        for (var g = 0; g < f.length; ++g)
            if (!(c && f[g].type != d || e && f[g].capture != b))
                return !0;
        return !1
    })
}
;
function gvjs_$h(a, b, c, d) {
    for (var e = 0; e < a.length; ++e) {
        var f = a[e];
        if (!f.An && f.listener == b && f.capture == !!c && f.handler == d)
            return e
    }
    return -1
}
;var gvjs_bi = "closure_lm_" + (1E6 * Math.random() | 0)
  , gvjs_ci = {}
  , gvjs_di = 0;
function gvjs_G(a, b, c, d, e) {
    if (d && d.once)
        return gvjs_ei(a, b, c, d, e);
    if (Array.isArray(b)) {
        for (var f = 0; f < b.length; f++)
            gvjs_G(a, b[f], c, d, e);
        return null
    }
    c = gvjs_fi(c);
    return gvjs_7h(a) ? a.o(b, c, gvjs_r(d) ? !!d.capture : !!d, e) : gvjs_gi(a, b, c, !1, d, e)
}
function gvjs_gi(a, b, c, d, e, f) {
    if (!b)
        throw Error("Invalid event type");
    var g = gvjs_r(e) ? !!e.capture : !!e
      , h = gvjs_hi(a);
    h || (a[gvjs_bi] = h = new gvjs_9h(a));
    c = h.add(b, c, d, g, f);
    if (c.pS)
        return c;
    d = gvjs_Yaa();
    c.pS = d;
    d.src = a;
    d.listener = c;
    if (a.addEventListener)
        gvjs_Uaa || (e = g),
        void 0 === e && (e = !1),
        a.addEventListener(b.toString(), d, e);
    else if (a.attachEvent)
        a.attachEvent(gvjs_ii(b.toString()), d);
    else if (a.addListener && a.removeListener)
        a.addListener(d);
    else
        throw Error("addEventListener and attachEvent are unavailable.");
    gvjs_di++;
    return c
}
function gvjs_Yaa() {
    function a(c) {
        return b.call(a.src, a.listener, c)
    }
    var b = gvjs_Zaa;
    return a
}
function gvjs_ei(a, b, c, d, e) {
    if (Array.isArray(b)) {
        for (var f = 0; f < b.length; f++)
            gvjs_ei(a, b[f], c, d, e);
        return null
    }
    c = gvjs_fi(c);
    return gvjs_7h(a) ? a.vD(b, c, gvjs_r(d) ? !!d.capture : !!d, e) : gvjs_gi(a, b, c, !0, d, e)
}
function gvjs_ji(a, b, c, d, e) {
    if (Array.isArray(b))
        for (var f = 0; f < b.length; f++)
            gvjs_ji(a, b[f], c, d, e);
    else
        d = gvjs_r(d) ? !!d.capture : !!d,
        c = gvjs_fi(c),
        gvjs_7h(a) ? a.Ab(b, c, d, e) : a && (a = gvjs_hi(a)) && (b = a.uI(b, c, d, e)) && gvjs_ki(b)
}
function gvjs_ki(a) {
    if (typeof a === gvjs_g || !a || a.An)
        return !1;
    var b = a.src;
    if (gvjs_7h(b))
        return gvjs_ai(b.Jl, a);
    var c = a.type
      , d = a.pS;
    b.removeEventListener ? b.removeEventListener(c, d, a.capture) : b.detachEvent ? b.detachEvent(gvjs_ii(c), d) : b.addListener && b.removeListener && b.removeListener(d);
    gvjs_di--;
    (c = gvjs_hi(b)) ? (gvjs_ai(c, a),
    0 == c.ZL && (c.src = null,
    b[gvjs_bi] = null)) : gvjs_8h(a);
    return !0
}
function gvjs_li(a) {
    if (!a)
        return 0;
    if (gvjs_7h(a))
        return a.Jl ? a.Jl.removeAll(void 0) : 0;
    a = gvjs_hi(a);
    if (!a)
        return 0;
    var b = 0, c;
    for (c in a.Rh)
        for (var d = a.Rh[c].concat(), e = 0; e < d.length; ++e)
            gvjs_ki(d[e]) && ++b;
    return b
}
function gvjs_ii(a) {
    return a in gvjs_ci ? gvjs_ci[a] : gvjs_ci[a] = "on" + a
}
function gvjs_Zaa(a, b) {
    if (a.An)
        a = !0;
    else {
        b = new gvjs_5h(b,this);
        var c = a.listener
          , d = a.handler || a.src;
        a.wN && gvjs_ki(a);
        a = c.call(d, b)
    }
    return a
}
function gvjs_hi(a) {
    a = a[gvjs_bi];
    return a instanceof gvjs_9h ? a : null
}
var gvjs_mi = "__closure_events_fn_" + (1E9 * Math.random() >>> 0);
function gvjs_fi(a) {
    if (typeof a === gvjs_d)
        return a;
    a[gvjs_mi] || (a[gvjs_mi] = function(b) {
        return a.handleEvent(b)
    }
    );
    return a[gvjs_mi]
}
;function gvjs_H() {
    gvjs_F.call(this);
    this.Jl = new gvjs_9h(this);
    this.cka = this;
    this.g2 = null
}
gvjs_t(gvjs_H, gvjs_F);
gvjs_H.prototype[gvjs_6h] = !0;
gvjs_ = gvjs_H.prototype;
gvjs_.GC = function() {
    return this.g2
}
;
gvjs_.uA = gvjs_n(14);
gvjs_.addEventListener = function(a, b, c, d) {
    gvjs_G(this, a, b, c, d)
}
;
gvjs_.removeEventListener = function(a, b, c, d) {
    gvjs_ji(this, a, b, c, d)
}
;
gvjs_.dispatchEvent = function(a) {
    var b, c = this.GC();
    if (c)
        for (b = []; c; c = c.GC())
            b.push(c);
    c = this.cka;
    var d = a.type || a;
    if (typeof a === gvjs_l)
        a = new gvjs_1h(a,c);
    else if (a instanceof gvjs_1h)
        a.target = a.target || c;
    else {
        var e = a;
        a = new gvjs_1h(d,c);
        gvjs_2e(a, e)
    }
    e = !0;
    if (b)
        for (var f = b.length - 1; !a.CK && 0 <= f; f--) {
            var g = a.currentTarget = b[f];
            e = gvjs_ni(g, d, !0, a) && e
        }
    a.CK || (g = a.currentTarget = c,
    e = gvjs_ni(g, d, !0, a) && e,
    a.CK || (e = gvjs_ni(g, d, !1, a) && e));
    if (b)
        for (f = 0; !a.CK && f < b.length; f++)
            g = a.currentTarget = b[f],
            e = gvjs_ni(g, d, !1, a) && e;
    return e
}
;
gvjs_.M = function() {
    gvjs_H.G.M.call(this);
    this.Jl && this.Jl.removeAll(void 0);
    this.g2 = null
}
;
gvjs_.o = function(a, b, c, d) {
    return this.Jl.add(String(a), b, !1, c, d)
}
;
gvjs_.vD = function(a, b, c, d) {
    return this.Jl.add(String(a), b, !0, c, d)
}
;
gvjs_.Ab = function(a, b, c, d) {
    return this.Jl.remove(String(a), b, c, d)
}
;
function gvjs_ni(a, b, c, d) {
    b = a.Jl.Rh[String(b)];
    if (!b)
        return !0;
    b = b.concat();
    for (var e = !0, f = 0; f < b.length; ++f) {
        var g = b[f];
        if (g && !g.An && g.capture == c) {
            var h = g.listener
              , k = g.handler || g.src;
            g.wN && gvjs_ai(a.Jl, g);
            e = !1 !== h.call(k, d) && e
        }
    }
    return e && !d.defaultPrevented
}
gvjs_.EC = gvjs_n(12);
gvjs_.uI = function(a, b, c, d) {
    return this.Jl.uI(String(a), b, c, d)
}
;
gvjs_.hasListener = function(a, b) {
    return this.Jl.hasListener(void 0 !== a ? String(a) : void 0, b)
}
;
function gvjs_oi(a, b, c) {
    a = gvjs_pi(a);
    b = gvjs_G(a, b, gvjs_qi(c));
    return new gvjs_ri(b)
}
function gvjs_si(a, b, c) {
    a = gvjs_pi(a);
    b = gvjs_ei(a, b, gvjs_qi(c));
    return new gvjs_ri(b)
}
function gvjs_I(a, b, c) {
    gvjs_pi(a).dispatchEvent(new gvjs_ti(b,c))
}
function gvjs_ui(a) {
    return (a = a && typeof a.getKey === gvjs_d && a.getKey()) ? gvjs_ki(a) : !1
}
function gvjs_vi(a) {
    var b = gvjs_pi(a);
    b = gvjs_li(b);
    gvjs_E(a.__eventTarget);
    a.__eventTarget = void 0;
    return b
}
function gvjs_pi(a) {
    var b = a.__eventTarget;
    null != b ? a = b : (b = new gvjs_H,
    a = a.__eventTarget = b);
    return a
}
function gvjs_qi(a) {
    return function(b) {
        b && b.Loa ? a(b.properties) : a()
    }
}
function gvjs_ri(a) {
    this.key = a
}
gvjs_ri.prototype.getKey = function() {
    return this.key
}
;
function gvjs_ti(a, b) {
    gvjs_1h.call(this, a);
    this.properties = b
}
gvjs_o(gvjs_ti, gvjs_1h);
gvjs_ti.prototype.Loa = function() {
    return this.properties
}
;
function gvjs_wi(a, b, c) {
    this.visualization = a;
    this.container = b;
    this.lC = null;
    this.visualization = a;
    this.container = b;
    if (void 0 === c ? 0 : c)
        a = gvjs_Eh(b),
        "" !== a && "static" !== a || gvjs_C(b, gvjs_vd, gvjs_zd),
        this.lC = document.createElement(gvjs_Ob),
        gvjs_C(this.lC, {
            position: gvjs_c,
            top: 0,
            left: 0,
            "z-index": 1
        })
}
function gvjs_xi(a) {
    return a.lC ? (a.lC.parentNode !== a.container && a.container.appendChild(a.lC),
    a.lC) : a.container
}
gvjs_wi.prototype.Sc = function(a) {
    gvjs_yi(this, a, gvjs_Rb)
}
;
function gvjs_yi(a, b, c, d) {
    d = void 0 === d ? !0 : d;
    var e = gvjs_xi(a);
    c = {
        removable: !0,
        type: c
    };
    e = (0,
    gvjs_D.Sc)(e, b, null, c);
    (null == d || d) && gvjs_I(a.visualization, gvjs_Rb, {
        id: e,
        message: b,
        detailedMessage: "",
        options: c
    })
}
gvjs_wi.prototype.removeAll = function() {
    var a = gvjs_xi(this);
    (0,
    gvjs_D.removeAll)(a)
}
;
function gvjs_Zg(a, b, c) {
    try {
        return c ? b.call(c) : b()
    } catch (d) {
        a.Sc(d.message)
    }
}
;var gvjs_zi = {
    Dza: gvjs_zb,
    UAa: gvjs_g,
    BBa: gvjs_l,
    aAa: gvjs_Lb,
    bAa: gvjs_Mb,
    TIME: "time",
    JBa: gvjs_Od,
    u6: gvjs_d
};
function gvjs_Ai() {
    this.cq = null
}
gvjs_Ai.prototype.jf = function(a) {
    if (typeof a === gvjs_g) {
        var b = this.$();
        return 0 > a || a >= b ? -1 : a
    }
    if (!this.cq) {
        this.cq = {};
        b = this.$();
        for (var c = 0; c < b; c++) {
            var d = this.Ne(c);
            null == d || "" === d || d in this.cq || (this.cq[d] = c)
        }
        for (c = 0; c < b; c++)
            d = this.Ga(c),
            null == d || "" === d || d in this.cq || (this.cq[d] = c)
    }
    a = this.cq[a];
    return null == a ? -1 : a
}
;
gvjs_Ai.prototype.getStringValue = function(a, b) {
    var c = this.W(b);
    if (c !== gvjs_l)
        throw Error(gvjs_wa + b + " must be of type string, but is " + (c + "."));
    return this.getValue(a, b)
}
;
function gvjs_Bi(a, b) {
    return (new gvjs_Ci(b)).ie(a)
}
function gvjs_Ci(a) {
    this.ES = a
}
gvjs_Ci.prototype.ie = function(a) {
    var b = [];
    gvjs_Di(this, a, b);
    return b.join("")
}
;
function gvjs_Di(a, b, c) {
    if (null == b)
        c.push(gvjs_rd);
    else {
        if (typeof b == gvjs_h) {
            if (Array.isArray(b)) {
                var d = b;
                b = d.length;
                c.push("[");
                for (var e = "", f = 0; f < b; f++)
                    c.push(e),
                    e = d[f],
                    gvjs_Di(a, a.ES ? a.ES.call(d, String(f), e) : e, c),
                    e = ",";
                c.push("]");
                return
            }
            if (b instanceof String || b instanceof Number || b instanceof Boolean)
                b = b.valueOf();
            else {
                c.push("{");
                f = "";
                for (d in b)
                    Object.prototype.hasOwnProperty.call(b, d) && (e = b[d],
                    typeof e != gvjs_d && (c.push(f),
                    gvjs_Ei(d, c),
                    c.push(":"),
                    gvjs_Di(a, a.ES ? a.ES.call(b, d, e) : e, c),
                    f = ","));
                c.push("}");
                return
            }
        }
        switch (typeof b) {
        case gvjs_l:
            gvjs_Ei(b, c);
            break;
        case gvjs_g:
            c.push(isFinite(b) && !isNaN(b) ? String(b) : gvjs_rd);
            break;
        case gvjs_zb:
            c.push(String(b));
            break;
        case gvjs_d:
            c.push(gvjs_rd);
            break;
        default:
            throw Error("Unknown type: " + typeof b);
        }
    }
}
var gvjs_Fi = {
    '"': '\\"',
    "\\": "\\\\",
    "/": "\\/",
    "\b": "\\b",
    "\f": "\\f",
    "\n": "\\n",
    "\r": "\\r",
    "\t": "\\t",
    "\x0B": "\\u000b"
}
  , gvjs__aa = /\uffff/.test("\uffff") ? /[\\"\x00-\x1f\x7f-\uffff]/g : /[\\"\x00-\x1f\x7f-\xff]/g;
function gvjs_Ei(a, b) {
    b.push('"', a.replace(gvjs__aa, function(c) {
        var d = gvjs_Fi[c];
        d || (d = "\\u" + (c.charCodeAt(0) | 65536).toString(16).substr(1),
        gvjs_Fi[c] = d);
        return d
    }), '"')
}
;var gvjs_Gi = JSON.parse
  , gvjs_Hi = gvjs_p.JSON && gvjs_p.JSON.stringify || gvjs_Bi;
function gvjs_Ii(a) {
    return gvjs_Bi(gvjs_Ji(a, gvjs_Ki))
}
function gvjs_Li(a) {
    return gvjs_Mi(JSON.parse(a))
}
function gvjs_Ji(a, b) {
    a = b(a);
    var c = gvjs_me(a);
    if (c === gvjs_h || c === gvjs_sb) {
        c = c === gvjs_sb ? [] : {};
        for (var d in a)
            if (!gvjs_sf(d, "___clazz$") && a.hasOwnProperty(d)) {
                var e = gvjs_Ji(a[d], b);
                void 0 !== e && (c[d] = e)
            }
    } else
        c = a;
    return c
}
function gvjs_Mi(a) {
    if (typeof a === gvjs_l) {
        var b = a.match(/^Date\(\s*([\d,\s]*)\)$/);
        b && (a = b[1].split(/,\s*/),
        a = 1 === a.length ? new Date(Number(a[0]) || 0) : new Date(Number(a[0]) || 0,Number(a[1]) || 0,Number(a[2]) || 1,Number(a[3]) || 0,Number(a[4]) || 0,Number(a[5]) || 0,Number(a[6]) || 0));
        return a
    }
    if (Array.isArray(a))
        return gvjs_v(a, gvjs_Mi);
    if (gvjs_r(a))
        for (b in a)
            if (a.hasOwnProperty(b)) {
                var c = a[b];
                Object.prototype.hasOwnProperty.call(a, b) && (a[b] = gvjs_Mi(c))
            }
    return a
}
function gvjs_Ki(a) {
    var b = a;
    gvjs_oe(b) && (b = "Date(" + (0 !== a.getMilliseconds() ? [a.getFullYear(), a.getMonth(), a.getDate(), a.getHours(), a.getMinutes(), a.getSeconds(), a.getMilliseconds()] : 0 !== a.getSeconds() || 0 !== a.getMinutes() || 0 !== a.getHours() ? [a.getFullYear(), a.getMonth(), a.getDate(), a.getHours(), a.getMinutes(), a.getSeconds()] : [a.getFullYear(), a.getMonth(), a.getDate()]).join(gvjs_ha) + ")");
    return b
}
;var gvjs_Ni = {
    ERAS: ["BC", "AD"],
    ERANAMES: ["Before Christ", "Anno Domini"],
    NARROWMONTHS: "JFMAMJJASOND".split(""),
    STANDALONENARROWMONTHS: "JFMAMJJASOND".split(""),
    MONTHS: [gvjs_Ua, gvjs_Ea, "March", "April", gvjs_Xa, "June", "July", gvjs_pa, gvjs_$a, gvjs_1a, gvjs__a, gvjs_Ba],
    STANDALONEMONTHS: [gvjs_Ua, gvjs_Ea, "March", "April", gvjs_Xa, "June", "July", gvjs_pa, gvjs_$a, gvjs_1a, gvjs__a, gvjs_Ba],
    SHORTMONTHS: ["Jan", "Feb", "Mar", "Apr", gvjs_Xa, "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
    STANDALONESHORTMONTHS: ["Jan", "Feb", "Mar", "Apr", gvjs_Xa, "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
    WEEKDAYS: [gvjs_bb, gvjs_Ya, gvjs_ib, gvjs_lb, gvjs_eb, gvjs_Fa, gvjs_8a],
    STANDALONEWEEKDAYS: [gvjs_bb, gvjs_Ya, gvjs_ib, gvjs_lb, gvjs_eb, gvjs_Fa, gvjs_8a],
    SHORTWEEKDAYS: "Sun Mon Tue Wed Thu Fri Sat".split(" "),
    STANDALONESHORTWEEKDAYS: "Sun Mon Tue Wed Thu Fri Sat".split(" "),
    NARROWWEEKDAYS: "SMTWTFS".split(""),
    STANDALONENARROWWEEKDAYS: "SMTWTFS".split(""),
    SHORTQUARTERS: ["Q1", "Q2", "Q3", "Q4"],
    QUARTERS: ["1st quarter", "2nd quarter", "3rd quarter", "4th quarter"],
    AMPMS: ["AM", "PM"],
    DATEFORMATS: ["EEEE, MMMM d, y", "MMMM d, y", "MMM d, y", "M/d/yy"],
    TIMEFORMATS: ["h:mm:ss a zzzz", "h:mm:ss a z", "h:mm:ss a", "h:mm a"],
    DATETIMEFORMATS: [gvjs_0d, gvjs_0d, gvjs_1d, gvjs_1d],
    FIRSTDAYOFWEEK: 6,
    WEEKENDRANGE: [5, 6],
    FIRSTWEEKCUTOFFDAY: 5
}
  , gvjs_Oi = gvjs_Ni;
gvjs_Oi = gvjs_Ni;
function gvjs_Pi(a, b) {
    switch (b) {
    case 1:
        return 0 != a % 4 || 0 == a % 100 && 0 != a % 400 ? 28 : 29;
    case 5:
    case 8:
    case 10:
    case 3:
        return 30
    }
    return 31
}
function gvjs_Qi(a, b, c, d, e) {
    a = new Date(a,b,c);
    e = e || 0;
    return a.valueOf() + 864E5 * (((void 0 !== d ? d : 3) - e + 7) % 7 - ((a.getDay() + 6) % 7 - e + 7) % 7)
}
function gvjs_Ri(a, b, c) {
    typeof a === gvjs_g ? (this.date = gvjs_Si(a, b || 0, c || 1),
    gvjs_Ti(this, c || 1)) : gvjs_r(a) ? (this.date = gvjs_Si(a.getFullYear(), a.getMonth(), a.getDate()),
    gvjs_Ti(this, a.getDate())) : (this.date = new Date(gvjs_se()),
    a = this.date.getDate(),
    this.date.setHours(0),
    this.date.setMinutes(0),
    this.date.setSeconds(0),
    this.date.setMilliseconds(0),
    gvjs_Ti(this, a))
}
function gvjs_Si(a, b, c) {
    b = new Date(a,b,c);
    0 <= a && 100 > a && b.setFullYear(b.getFullYear() - 1900);
    return b
}
gvjs_ = gvjs_Ri.prototype;
gvjs_.tC = gvjs_Oi.FIRSTDAYOFWEEK;
gvjs_.uC = gvjs_Oi.FIRSTWEEKCUTOFFDAY;
gvjs_.clone = function() {
    var a = new gvjs_Ri(this.date);
    a.tC = this.tC;
    a.uC = this.uC;
    return a
}
;
gvjs_.getFullYear = function() {
    return this.date.getFullYear()
}
;
gvjs_.getYear = function() {
    return this.getFullYear()
}
;
gvjs_.getMonth = function() {
    return this.date.getMonth()
}
;
gvjs_.getDate = function() {
    return this.date.getDate()
}
;
gvjs_.getTime = function() {
    return this.date.getTime()
}
;
gvjs_.getDay = function() {
    return this.date.getDay()
}
;
gvjs_.getUTCFullYear = function() {
    return this.date.getUTCFullYear()
}
;
gvjs_.getUTCMonth = function() {
    return this.date.getUTCMonth()
}
;
gvjs_.getUTCDate = function() {
    return this.date.getUTCDate()
}
;
gvjs_.getUTCDay = function() {
    return this.date.getDay()
}
;
gvjs_.getUTCHours = function() {
    return this.date.getUTCHours()
}
;
gvjs_.getUTCMinutes = function() {
    return this.date.getUTCMinutes()
}
;
gvjs_.getTimezoneOffset = function() {
    return this.date.getTimezoneOffset()
}
;
gvjs_.set = function(a) {
    this.date = new Date(a.getFullYear(),a.getMonth(),a.getDate())
}
;
gvjs_.setFullYear = function(a) {
    this.date.setFullYear(a)
}
;
gvjs_.setYear = function(a) {
    this.setFullYear(a)
}
;
gvjs_.setMonth = function(a) {
    this.date.setMonth(a)
}
;
gvjs_.setDate = function(a) {
    this.date.setDate(a)
}
;
gvjs_.setTime = function(a) {
    this.date.setTime(a)
}
;
gvjs_.setUTCFullYear = function(a) {
    this.date.setUTCFullYear(a)
}
;
gvjs_.setUTCMonth = function(a) {
    this.date.setUTCMonth(a)
}
;
gvjs_.setUTCDate = function(a) {
    this.date.setUTCDate(a)
}
;
gvjs_.add = function(a) {
    if (a.Aj || a.months) {
        var b = this.getMonth() + a.months + 12 * a.Aj
          , c = this.getYear() + Math.floor(b / 12);
        b %= 12;
        0 > b && (b += 12);
        var d = Math.min(gvjs_Pi(c, b), this.getDate());
        this.setDate(1);
        this.setFullYear(c);
        this.setMonth(b);
        this.setDate(d)
    }
    a.days && (a = new Date((new Date(this.getYear(),this.getMonth(),this.getDate(),12)).getTime() + 864E5 * a.days),
    this.setDate(1),
    this.setFullYear(a.getFullYear()),
    this.setMonth(a.getMonth()),
    this.setDate(a.getDate()),
    gvjs_Ti(this, a.getDate()))
}
;
gvjs_.TA = function(a) {
    return [this.getFullYear(), gvjs_fg(this.getMonth() + 1, 2), gvjs_fg(this.getDate(), 2)].join(a ? "-" : "") + ""
}
;
gvjs_.equals = function(a) {
    return !(!a || this.getYear() != a.getYear() || this.getMonth() != a.getMonth() || this.getDate() != a.getDate())
}
;
gvjs_.toString = function() {
    return this.TA()
}
;
function gvjs_Ti(a, b) {
    a.getDate() != b && a.date.setUTCHours(a.date.getUTCHours() + (a.getDate() < b ? 1 : -1))
}
gvjs_.valueOf = function() {
    return this.date.valueOf()
}
;
function gvjs_Ui() {}
function gvjs_Vi(a) {
    if (typeof a == gvjs_g) {
        var b = new gvjs_Ui;
        b.D4 = a;
        var c = a;
        if (0 == c)
            c = "Etc/GMT";
        else {
            var d = ["Etc/GMT", 0 > c ? "-" : "+"];
            c = Math.abs(c);
            d.push(Math.floor(c / 60) % 100);
            c %= 60;
            0 != c && d.push(":", gvjs_fg(c, 2));
            c = d.join("")
        }
        b.f5 = c;
        c = a;
        0 == c ? c = "UTC" : (d = ["UTC", 0 > c ? "+" : "-"],
        c = Math.abs(c),
        d.push(Math.floor(c / 60) % 100),
        c %= 60,
        0 != c && d.push(":", c),
        c = d.join(""));
        a = gvjs_Wi(a);
        b.IU = [c, c];
        b.ix = {
            xBa: a,
            E6: a
        };
        b.YA = [];
        return b
    }
    b = new gvjs_Ui;
    b.f5 = a.id;
    b.D4 = -a.std_offset;
    b.IU = a.names;
    b.ix = a.names_ext;
    b.YA = a.transitions;
    return b
}
function gvjs_Wi(a) {
    var b = ["GMT"];
    b.push(0 >= a ? "+" : "-");
    a = Math.abs(a);
    b.push(gvjs_fg(Math.floor(a / 60) % 100, 2), ":", gvjs_fg(a % 60, 2));
    return b.join("")
}
gvjs_ = gvjs_Ui.prototype;
gvjs_.getTimeZoneData = function() {
    return {
        id: this.f5,
        std_offset: -this.D4,
        names: gvjs_Le(this.IU),
        names_ext: gvjs_x(this.ix),
        transitions: gvjs_Le(this.YA)
    }
}
;
gvjs_.getDaylightAdjustment = function(a) {
    a = Date.UTC(a.getUTCFullYear(), a.getUTCMonth(), a.getUTCDate(), a.getUTCHours(), a.getUTCMinutes()) / 36E5;
    for (var b = 0; b < this.YA.length && a >= this.YA[b]; )
        b += 2;
    return 0 == b ? 0 : this.YA[b - 1]
}
;
gvjs_.getGMTString = function(a) {
    return gvjs_Wi(this.getOffset(a))
}
;
gvjs_.getLongName = function(a) {
    return this.IU[this.isDaylightTime(a) ? 3 : 1]
}
;
gvjs_.getOffset = function(a) {
    return this.D4 - this.getDaylightAdjustment(a)
}
;
gvjs_.getRFCTimeZoneString = function(a) {
    a = -this.getOffset(a);
    var b = [0 > a ? "-" : "+"];
    a = Math.abs(a);
    b.push(gvjs_fg(Math.floor(a / 60) % 100, 2), gvjs_fg(a % 60, 2));
    return b.join("")
}
;
gvjs_.getShortName = function(a) {
    return this.IU[this.isDaylightTime(a) ? 2 : 0]
}
;
gvjs_.getTimeZoneId = function() {
    return this.f5
}
;
gvjs_.isDaylightTime = function(a) {
    return 0 < this.getDaylightAdjustment(a)
}
;
function gvjs_Xi(a) {
    this.iS = [];
    this.Ie = gvjs_Oi;
    typeof a == gvjs_g ? this.aN(a) : this.Zr(a)
}
var gvjs_Yi = [/^'(?:[^']|'')*('|$)/, /^(?:G+|y+|Y+|M+|k+|S+|E+|a+|h+|K+|H+|c+|L+|Q+|d+|m+|s+|v+|V+|w+|z+|Z+)/, /^[^'GyYMkSEahKHcLQdmsvVwzZ]+/];
function gvjs_Zi(a) {
    return a.getHours ? a.getHours() : 0
}
gvjs_Xi.prototype.Zr = function(a) {
    for (gvjs_0aa && (a = a.replace(/\u200f/g, "")); a; ) {
        for (var b = a, c = 0; c < gvjs_Yi.length; ++c) {
            var d = a.match(gvjs_Yi[c]);
            if (d) {
                var e = d[0];
                a = a.substring(e.length);
                0 == c && ("''" == e ? e = "'" : (e = e.substring(1, "'" == d[1] ? e.length - 1 : e.length),
                e = e.replace(/''/g, "'")));
                this.iS.push({
                    text: e,
                    type: c
                });
                break
            }
        }
        if (b === a)
            throw Error("Malformed pattern part: " + a);
    }
}
;
gvjs_Xi.prototype.format = function(a, b) {
    if (!a)
        throw Error("The date to format must be non-null.");
    var c = b ? 6E4 * (a.getTimezoneOffset() - b.getOffset(a)) : 0
      , d = c ? new Date(a.getTime() + c) : a
      , e = d;
    b && d.getTimezoneOffset() != a.getTimezoneOffset() && (e = 6E4 * (d.getTimezoneOffset() - a.getTimezoneOffset()),
    d = new Date(d.getTime() + e),
    c += 0 < c ? -864E5 : 864E5,
    e = new Date(a.getTime() + c));
    c = [];
    for (var f = 0; f < this.iS.length; ++f) {
        var g = this.iS[f].text;
        1 == this.iS[f].type ? c.push(gvjs_1aa(this, g, a, d, e, b)) : c.push(g)
    }
    return c.join("")
}
;
gvjs_Xi.prototype.aN = function(a) {
    if (4 > a)
        var b = this.Ie.DATEFORMATS[a];
    else if (8 > a)
        b = this.Ie.TIMEFORMATS[a - 4];
    else if (12 > a)
        b = this.Ie.DATETIMEFORMATS[a - 8],
        b = b.replace("{1}", this.Ie.DATEFORMATS[a - 8]),
        b = b.replace("{0}", this.Ie.TIMEFORMATS[a - 8]);
    else {
        this.aN(10);
        return
    }
    this.Zr(b)
}
;
function gvjs__i(a, b) {
    b = String(b);
    a = a.Ie || gvjs_Oi;
    if (void 0 !== a.Tja) {
        for (var c = [], d = 0; d < b.length; d++) {
            var e = b.charCodeAt(d);
            c.push(48 <= e && 57 >= e ? String.fromCharCode(a.Tja + e - 48) : b.charAt(d))
        }
        b = c.join("")
    }
    return b
}
var gvjs_0aa = !1;
function gvjs_0i(a) {
    if (!(a.getHours && a.getSeconds && a.getMinutes))
        throw Error("The date to format has no time (probably a goog.date.Date). Use Date or goog.date.DateTime, or use a pattern without time fields.");
}
function gvjs_1aa(a, b, c, d, e, f) {
    var g = b.length;
    switch (b.charAt(0)) {
    case "G":
        return c = 0 < d.getFullYear() ? 1 : 0,
        4 <= g ? a.Ie.ERANAMES[c] : a.Ie.ERAS[c];
    case "y":
        return c = d.getFullYear(),
        0 > c && (c = -c),
        2 == g && (c %= 100),
        gvjs__i(a, gvjs_fg(c, g));
    case "Y":
        return c = (new Date(gvjs_Qi(d.getFullYear(), d.getMonth(), d.getDate(), a.Ie.FIRSTWEEKCUTOFFDAY, a.Ie.FIRSTDAYOFWEEK))).getFullYear(),
        0 > c && (c = -c),
        2 == g && (c %= 100),
        gvjs__i(a, gvjs_fg(c, g));
    case "M":
        a: switch (c = d.getMonth(),
        g) {
        case 5:
            g = a.Ie.NARROWMONTHS[c];
            break a;
        case 4:
            g = a.Ie.MONTHS[c];
            break a;
        case 3:
            g = a.Ie.SHORTMONTHS[c];
            break a;
        default:
            g = gvjs__i(a, gvjs_fg(c + 1, g))
        }
        return g;
    case "k":
        return gvjs_0i(e),
        gvjs__i(a, gvjs_fg(gvjs_Zi(e) || 24, g));
    case "S":
        return gvjs__i(a, (e.getMilliseconds() / 1E3).toFixed(Math.min(3, g)).substr(2) + (3 < g ? gvjs_fg(0, g - 3) : ""));
    case "E":
        return c = d.getDay(),
        4 <= g ? a.Ie.WEEKDAYS[c] : a.Ie.SHORTWEEKDAYS[c];
    case "a":
        return gvjs_0i(e),
        g = gvjs_Zi(e),
        a.Ie.AMPMS[12 <= g && 24 > g ? 1 : 0];
    case "h":
        return gvjs_0i(e),
        gvjs__i(a, gvjs_fg(gvjs_Zi(e) % 12 || 12, g));
    case "K":
        return gvjs_0i(e),
        gvjs__i(a, gvjs_fg(gvjs_Zi(e) % 12, g));
    case "H":
        return gvjs_0i(e),
        gvjs__i(a, gvjs_fg(gvjs_Zi(e), g));
    case "c":
        a: switch (c = d.getDay(),
        g) {
        case 5:
            g = a.Ie.STANDALONENARROWWEEKDAYS[c];
            break a;
        case 4:
            g = a.Ie.STANDALONEWEEKDAYS[c];
            break a;
        case 3:
            g = a.Ie.STANDALONESHORTWEEKDAYS[c];
            break a;
        default:
            g = gvjs__i(a, gvjs_fg(c, 1))
        }
        return g;
    case "L":
        a: switch (c = d.getMonth(),
        g) {
        case 5:
            g = a.Ie.STANDALONENARROWMONTHS[c];
            break a;
        case 4:
            g = a.Ie.STANDALONEMONTHS[c];
            break a;
        case 3:
            g = a.Ie.STANDALONESHORTMONTHS[c];
            break a;
        default:
            g = gvjs__i(a, gvjs_fg(c + 1, g))
        }
        return g;
    case "Q":
        return c = Math.floor(d.getMonth() / 3),
        4 > g ? a.Ie.SHORTQUARTERS[c] : a.Ie.QUARTERS[c];
    case "d":
        return gvjs__i(a, gvjs_fg(d.getDate(), g));
    case "m":
        return gvjs_0i(e),
        gvjs__i(a, gvjs_fg(e.getMinutes(), g));
    case "s":
        return gvjs_0i(e),
        gvjs__i(a, gvjs_fg(e.getSeconds(), g));
    case "v":
        return g = f || gvjs_Vi(c.getTimezoneOffset()),
        g.getTimeZoneId();
    case "V":
        return a = f || gvjs_Vi(c.getTimezoneOffset()),
        2 >= g ? g = a.getTimeZoneId() : (g = a,
        g = g.isDaylightTime(c) ? void 0 !== g.ix.qia ? g.ix.qia : g.ix.DST_GENERIC_LOCATION : void 0 !== g.ix.E6 ? g.ix.E6 : g.ix.STD_GENERIC_LOCATION),
        g;
    case "w":
        return c = gvjs_Qi(e.getFullYear(), e.getMonth(), e.getDate(), a.Ie.FIRSTWEEKCUTOFFDAY, a.Ie.FIRSTDAYOFWEEK),
        gvjs__i(a, gvjs_fg(Math.floor(Math.round((c - (new Date((new Date(c)).getFullYear(),0,1)).valueOf()) / 864E5) / 7) + 1, g));
    case "z":
        return a = f || gvjs_Vi(c.getTimezoneOffset()),
        4 > g ? a.getShortName(c) : a.getLongName(c);
    case "Z":
        return b = f || gvjs_Vi(c.getTimezoneOffset()),
        4 > g ? b.getRFCTimeZoneString(c) : gvjs__i(a, b.getGMTString(c));
    default:
        return ""
    }
}
;var gvjs_1i = {
    YEAR_FULL: "y",
    YEAR_FULL_WITH_ERA: "y G",
    YEAR_MONTH_ABBR: "MMM y",
    YEAR_MONTH_FULL: "MMMM y",
    YBa: "MM/y",
    MONTH_DAY_ABBR: "MMM d",
    MONTH_DAY_FULL: "MMMM dd",
    MONTH_DAY_SHORT: "M/d",
    MONTH_DAY_MEDIUM: "MMMM d",
    MONTH_DAY_YEAR_MEDIUM: "MMM d, y",
    WEEKDAY_MONTH_DAY_MEDIUM: "EEE, MMM d",
    WEEKDAY_MONTH_DAY_YEAR_MEDIUM: "EEE, MMM d, y",
    DAY_ABBR: "d",
    PAa: "MMM d, h:mm a zzzz"
}
  , gvjs_2i = gvjs_1i;
gvjs_2i = gvjs_1i;
function gvjs_3i(a, b) {
    this.Ala = a[gvjs_p.Symbol.iterator]();
    this.Zsa = b;
    this.Mta = 0
}
gvjs_3i.prototype[Symbol.iterator] = function() {
    return this
}
;
gvjs_3i.prototype.next = function() {
    var a = this.Ala.next();
    return {
        value: a.done ? void 0 : this.Zsa.call(void 0, a.value, this.Mta++),
        done: a.done
    }
}
;
function gvjs_2aa(a, b) {
    return new gvjs_3i(a,b)
}
;var gvjs_4i = "StopIteration"in gvjs_p ? gvjs_p.StopIteration : {
    message: "StopIteration",
    stack: ""
};
function gvjs_5i() {}
gvjs_5i.prototype.next = function() {
    return gvjs_5i.prototype.rg.call(this)
}
;
gvjs_5i.prototype.rg = function() {
    throw gvjs_4i;
}
;
gvjs_5i.prototype.xk = function() {
    return this
}
;
function gvjs_6i(a) {
    if (a instanceof gvjs_7i || a instanceof gvjs_8i || a instanceof gvjs_9i)
        return a;
    if (typeof a.next == gvjs_d)
        return new gvjs_7i(function() {
            return gvjs_$i(a)
        }
        );
    if (typeof a[Symbol.iterator] == gvjs_d)
        return new gvjs_7i(function() {
            return a[Symbol.iterator]()
        }
        );
    if (typeof a.xk == gvjs_d)
        return new gvjs_7i(function() {
            return gvjs_$i(a.xk())
        }
        );
    throw Error("Not an iterator or iterable.");
}
function gvjs_$i(a) {
    if (!(a instanceof gvjs_5i))
        return a;
    var b = !1;
    return {
        next: function() {
            for (var c; !b; )
                try {
                    c = a.next();
                    break
                } catch (d) {
                    if (d !== gvjs_4i)
                        throw d;
                    b = !0
                }
            return {
                value: c,
                done: b
            }
        }
    }
}
function gvjs_7i(a) {
    this.YY = a
}
gvjs_7i.prototype.xk = function() {
    return new gvjs_8i(this.YY())
}
;
gvjs_7i.prototype[Symbol.iterator] = function() {
    return new gvjs_9i(this.YY())
}
;
gvjs_7i.prototype.k5 = function() {
    return new gvjs_9i(this.YY())
}
;
function gvjs_8i(a) {
    this.oJ = a
}
gvjs_o(gvjs_8i, gvjs_5i);
gvjs_8i.prototype.rg = function() {
    var a = this.oJ.next();
    if (a.done)
        throw gvjs_4i;
    return a.value
}
;
gvjs_8i.prototype.next = function() {
    return gvjs_8i.prototype.rg.call(this)
}
;
gvjs_8i.prototype[Symbol.iterator] = function() {
    return new gvjs_9i(this.oJ)
}
;
gvjs_8i.prototype.k5 = function() {
    return new gvjs_9i(this.oJ)
}
;
function gvjs_9i(a) {
    gvjs_7i.call(this, function() {
        return a
    });
    this.oJ = a
}
gvjs_o(gvjs_9i, gvjs_7i);
gvjs_9i.prototype.next = function() {
    return this.oJ.next()
}
;
function gvjs_aj(a, b) {
    this.qa = {};
    this.ad = [];
    this.pM = this.size = 0;
    var c = arguments.length;
    if (1 < c) {
        if (c % 2)
            throw Error(gvjs_kb);
        for (var d = 0; d < c; d += 2)
            this.set(arguments[d], arguments[d + 1])
    } else
        a && this.addAll(a)
}
gvjs_ = gvjs_aj.prototype;
gvjs_.Cd = function() {
    return this.size
}
;
gvjs_.ob = function() {
    gvjs_bj(this);
    for (var a = [], b = 0; b < this.ad.length; b++)
        a.push(this.qa[this.ad[b]]);
    return a
}
;
gvjs_.cj = function() {
    gvjs_bj(this);
    return this.ad.concat()
}
;
gvjs_.tf = function(a) {
    return this.has(a)
}
;
gvjs_.has = function(a) {
    return gvjs_cj(this.qa, a)
}
;
gvjs_.XB = function(a) {
    for (var b = 0; b < this.ad.length; b++) {
        var c = this.ad[b];
        if (gvjs_cj(this.qa, c) && this.qa[c] == a)
            return !0
    }
    return !1
}
;
gvjs_.equals = function(a, b) {
    if (this === a)
        return !0;
    if (this.size != a.Cd())
        return !1;
    b = b || gvjs_3aa;
    gvjs_bj(this);
    for (var c, d = 0; c = this.ad[d]; d++)
        if (!b(this.get(c), a.get(c)))
            return !1;
    return !0
}
;
function gvjs_3aa(a, b) {
    return a === b
}
gvjs_.isEmpty = function() {
    return 0 == this.size
}
;
gvjs_.clear = function() {
    this.qa = {};
    this.ad.length = 0;
    this.cu(0);
    this.pM = 0
}
;
gvjs_.remove = function(a) {
    return this.delete(a)
}
;
gvjs_.delete = function(a) {
    return gvjs_cj(this.qa, a) ? (delete this.qa[a],
    this.cu(this.size - 1),
    this.pM++,
    this.ad.length > 2 * this.size && gvjs_bj(this),
    !0) : !1
}
;
function gvjs_bj(a) {
    if (a.size != a.ad.length) {
        for (var b = 0, c = 0; b < a.ad.length; ) {
            var d = a.ad[b];
            gvjs_cj(a.qa, d) && (a.ad[c++] = d);
            b++
        }
        a.ad.length = c
    }
    if (a.size != a.ad.length) {
        var e = {};
        for (c = b = 0; b < a.ad.length; )
            d = a.ad[b],
            gvjs_cj(e, d) || (a.ad[c++] = d,
            e[d] = 1),
            b++;
        a.ad.length = c
    }
}
gvjs_.get = function(a, b) {
    return gvjs_cj(this.qa, a) ? this.qa[a] : b
}
;
gvjs_.set = function(a, b) {
    gvjs_cj(this.qa, a) || (this.cu(this.size + 1),
    this.ad.push(a),
    this.pM++);
    this.qa[a] = b
}
;
gvjs_.addAll = function(a) {
    if (a instanceof gvjs_aj)
        for (var b = a.cj(), c = 0; c < b.length; c++)
            this.set(b[c], a.get(b[c]));
    else
        for (b in a)
            this.set(b, a[b])
}
;
gvjs_.forEach = function(a, b) {
    for (var c = this.cj(), d = 0; d < c.length; d++) {
        var e = c[d]
          , f = this.get(e);
        a.call(b, f, e, this)
    }
}
;
gvjs_.clone = function() {
    return new gvjs_aj(this)
}
;
gvjs_.transpose = function() {
    for (var a = new gvjs_aj, b = 0; b < this.ad.length; b++) {
        var c = this.ad[b];
        a.set(this.qa[c], c)
    }
    return a
}
;
gvjs_.keys = function() {
    return gvjs_6i(this.xk(!0)).k5()
}
;
gvjs_.values = function() {
    return gvjs_6i(this.xk(!1)).k5()
}
;
gvjs_.entries = function() {
    var a = this;
    return gvjs_2aa(this.keys(), function(b) {
        return [b, a.get(b)]
    })
}
;
gvjs_.xk = function(a) {
    gvjs_bj(this);
    var b = 0
      , c = this.pM
      , d = this
      , e = new gvjs_5i;
    e.rg = function() {
        if (c != d.pM)
            throw Error("The map has changed since the iterator was created");
        if (b >= d.ad.length)
            throw gvjs_4i;
        var f = d.ad[b++];
        return a ? f : d.qa[f]
    }
    ;
    e.next = e.rg.bind(e);
    return e
}
;
gvjs_.cu = function(a) {
    this.size = a
}
;
function gvjs_cj(a, b) {
    return Object.prototype.hasOwnProperty.call(a, b)
}
;function gvjs_dj(a) {
    return a.Cd && typeof a.Cd == gvjs_d ? a.Cd() : gvjs_ne(a) || typeof a === gvjs_l ? a.length : gvjs_We(a)
}
function gvjs_ej(a) {
    if (a.ob && typeof a.ob == gvjs_d)
        return a.ob();
    if ("undefined" !== typeof Map && a instanceof Map || "undefined" !== typeof Set && a instanceof Set)
        return Array.from(a.values());
    if (typeof a === gvjs_l)
        return a.split("");
    if (gvjs_ne(a)) {
        for (var b = [], c = a.length, d = 0; d < c; d++)
            b.push(a[d]);
        return b
    }
    return gvjs_Xe(a)
}
function gvjs_fj(a) {
    if (a.cj && typeof a.cj == gvjs_d)
        return a.cj();
    if (!a.ob || typeof a.ob != gvjs_d) {
        if ("undefined" !== typeof Map && a instanceof Map)
            return Array.from(a.keys());
        if (!("undefined" !== typeof Set && a instanceof Set)) {
            if (gvjs_ne(a) || typeof a === gvjs_l) {
                var b = [];
                a = a.length;
                for (var c = 0; c < a; c++)
                    b.push(c);
                return b
            }
            return gvjs_Ye(a)
        }
    }
}
function gvjs_gj(a, b, c) {
    if (a.forEach && typeof a.forEach == gvjs_d)
        a.forEach(b, c);
    else if (gvjs_ne(a) || typeof a === gvjs_l)
        Array.prototype.forEach.call(a, b, c);
    else
        for (var d = gvjs_fj(a), e = gvjs_ej(a), f = e.length, g = 0; g < f; g++)
            b.call(c, e[g], d && d[g], a)
}
function gvjs_4aa(a, b) {
    if (typeof a.every == gvjs_d)
        return a.every(b, void 0);
    if (gvjs_ne(a) || typeof a === gvjs_l)
        return Array.prototype.every.call(a, b, void 0);
    for (var c = gvjs_fj(a), d = gvjs_ej(a), e = d.length, f = 0; f < e; f++)
        if (!b.call(void 0, d[f], c && c[f], a))
            return !1;
    return !0
}
;function gvjs_hj(a) {
    this.qa = new gvjs_aj;
    this.size = 0;
    a && this.addAll(a)
}
function gvjs_ij(a) {
    var b = typeof a;
    return b == gvjs_h && a || b == gvjs_d ? "o" + gvjs_pe(a) : b.substr(0, 1) + a
}
gvjs_ = gvjs_hj.prototype;
gvjs_.Cd = function() {
    return this.qa.size
}
;
gvjs_.add = function(a) {
    this.qa.set(gvjs_ij(a), a);
    this.cu(this.qa.size)
}
;
gvjs_.addAll = function(a) {
    a = gvjs_ej(a);
    for (var b = a.length, c = 0; c < b; c++)
        this.add(a[c]);
    this.cu(this.qa.size)
}
;
gvjs_.removeAll = function(a) {
    a = gvjs_ej(a);
    for (var b = a.length, c = 0; c < b; c++)
        this.remove(a[c]);
    this.cu(this.qa.size)
}
;
gvjs_.delete = function(a) {
    a = this.qa.remove(gvjs_ij(a));
    this.cu(this.qa.size);
    return a
}
;
gvjs_.remove = function(a) {
    return this.delete(a)
}
;
gvjs_.clear = function() {
    this.qa.clear();
    this.cu(0)
}
;
gvjs_.isEmpty = function() {
    return 0 === this.qa.size
}
;
gvjs_.has = function(a) {
    return this.qa.tf(gvjs_ij(a))
}
;
gvjs_.contains = function(a) {
    return this.qa.tf(gvjs_ij(a))
}
;
gvjs_.J_ = gvjs_n(15);
gvjs_.ob = function() {
    return this.qa.ob()
}
;
gvjs_.values = function() {
    return this.qa.values()
}
;
gvjs_.clone = function() {
    return new gvjs_hj(this)
}
;
gvjs_.equals = function(a) {
    return this.Cd() == gvjs_dj(a) && this.kD(a)
}
;
gvjs_.kD = function(a) {
    var b = gvjs_dj(a);
    if (this.Cd() > b)
        return !1;
    !(a instanceof gvjs_hj) && 5 < b && (a = new gvjs_hj(a));
    return gvjs_4aa(this, function(c) {
        var d = a;
        return d.contains && typeof d.contains == gvjs_d ? d.contains(c) : d.XB && typeof d.XB == gvjs_d ? d.XB(c) : gvjs_ne(d) || typeof d === gvjs_l ? gvjs_He(d, c) : gvjs__e(d, c)
    })
}
;
gvjs_.xk = function() {
    return this.qa.xk(!1)
}
;
gvjs_hj.prototype[Symbol.iterator] = function() {
    return this.values()
}
;
gvjs_hj.prototype.cu = function(a) {
    this.size = a
}
;
function gvjs_jj(a) {
    if (gvjs_oe(a)) {
        var b = new Date;
        b.setTime(a.valueOf());
        return b
    }
    var c = gvjs_me(a);
    if (c === gvjs_h || c === gvjs_sb) {
        if (a.clone)
            return a.clone();
        c = c === gvjs_sb ? [] : {};
        for (b in a)
            c[b] = gvjs_jj(a[b]);
        return c
    }
    return a
}
function gvjs_kj(a, b) {
    a = a.split(".");
    b = b || gvjs_p;
    for (var c = 0; c < a.length; c++) {
        var d = a[c];
        if (Array.isArray(b) && !d.match(/[0-9]+/))
            a: {
                for (var e = 0; e < b.length; e++) {
                    var f = b[e];
                    if (f.name && f.name === d) {
                        b = f;
                        break a
                    }
                }
                b = null
            }
        else if (null != b[d])
            b = b[d];
        else
            return null
    }
    return b
}
function gvjs_lj(a) {
    return gvjs_me(a) !== gvjs_h || gvjs_oe(a) ? null : a
}
function gvjs_mj(a, b) {
    for (var c = 1; c < arguments.length; ++c)
        ;
    a = gvjs_lj(a) || {};
    if (2 === arguments.length) {
        c = arguments[1];
        if (!gvjs_lj(c))
            return a;
        for (var d in c)
            if (Array.isArray(c[d]))
                a[d] = gvjs_Le(c[d]);
            else if (gvjs_lj(a[d]))
                a[d] = gvjs_mj(a[d], c[d]);
            else if (gvjs_lj(c[d]))
                a[d] = gvjs_mj({}, c[d]);
            else if (null == a[d] || null != c[d])
                a[d] = c[d]
    } else if (2 < arguments.length)
        for (d = 1,
        c = arguments.length; d < c; d++)
            a = gvjs_mj(a, arguments[d]);
    return a
}
function gvjs_nj(a) {
    var b = [];
    a = gvjs_8d(a);
    for (var c = a.next(); !c.done; c = a.next())
        b.push(c.value);
    return b
}
function gvjs_oj(a, b) {
    var c = new Set;
    b = gvjs_nj(b);
    for (var d = 0; d < b.length; d++) {
        var e = b[d];
        a.has(e) && c.add(e)
    }
    return c
}
;var gvjs_pj = {
    aliceblue: "#f0f8ff",
    antiquewhite: "#faebd7",
    aqua: "#00ffff",
    aquamarine: "#7fffd4",
    azure: "#f0ffff",
    beige: "#f5f5dc",
    bisque: "#ffe4c4",
    black: gvjs_ca,
    blanchedalmond: "#ffebcd",
    blue: "#0000ff",
    blueviolet: "#8a2be2",
    brown: "#a52a2a",
    burlywood: "#deb887",
    cadetblue: "#5f9ea0",
    chartreuse: "#7fff00",
    chocolate: "#d2691e",
    coral: "#ff7f50",
    cornflowerblue: "#6495ed",
    cornsilk: "#fff8dc",
    crimson: "#dc143c",
    cyan: "#00ffff",
    darkblue: "#00008b",
    darkcyan: "#008b8b",
    darkgoldenrod: "#b8860b",
    darkgray: "#a9a9a9",
    darkgreen: "#006400",
    darkgrey: "#a9a9a9",
    darkkhaki: "#bdb76b",
    darkmagenta: "#8b008b",
    darkolivegreen: "#556b2f",
    darkorange: "#ff8c00",
    darkorchid: "#9932cc",
    darkred: "#8b0000",
    darksalmon: "#e9967a",
    darkseagreen: "#8fbc8f",
    darkslateblue: "#483d8b",
    darkslategray: "#2f4f4f",
    darkslategrey: "#2f4f4f",
    darkturquoise: "#00ced1",
    darkviolet: "#9400d3",
    deeppink: "#ff1493",
    deepskyblue: "#00bfff",
    dimgray: "#696969",
    dimgrey: "#696969",
    dodgerblue: "#1e90ff",
    firebrick: "#b22222",
    floralwhite: "#fffaf0",
    forestgreen: "#228b22",
    fuchsia: "#ff00ff",
    gainsboro: "#dcdcdc",
    ghostwhite: "#f8f8ff",
    gold: "#ffd700",
    goldenrod: "#daa520",
    gray: gvjs_da,
    green: "#008000",
    greenyellow: "#adff2f",
    grey: gvjs_da,
    honeydew: "#f0fff0",
    hotpink: "#ff69b4",
    indianred: "#cd5c5c",
    indigo: "#4b0082",
    ivory: "#fffff0",
    khaki: "#f0e68c",
    lavender: "#e6e6fa",
    lavenderblush: "#fff0f5",
    lawngreen: "#7cfc00",
    lemonchiffon: "#fffacd",
    lightblue: "#add8e6",
    lightcoral: "#f08080",
    lightcyan: "#e0ffff",
    lightgoldenrodyellow: "#fafad2",
    lightgray: "#d3d3d3",
    lightgreen: "#90ee90",
    lightgrey: "#d3d3d3",
    lightpink: "#ffb6c1",
    lightsalmon: "#ffa07a",
    lightseagreen: "#20b2aa",
    lightskyblue: "#87cefa",
    lightslategray: "#778899",
    lightslategrey: "#778899",
    lightsteelblue: "#b0c4de",
    lightyellow: "#ffffe0",
    lime: "#00ff00",
    limegreen: "#32cd32",
    linen: "#faf0e6",
    magenta: "#ff00ff",
    maroon: "#800000",
    mediumaquamarine: "#66cdaa",
    mediumblue: "#0000cd",
    mediumorchid: "#ba55d3",
    mediumpurple: "#9370db",
    mediumseagreen: "#3cb371",
    mediumslateblue: "#7b68ee",
    mediumspringgreen: "#00fa9a",
    mediumturquoise: "#48d1cc",
    mediumvioletred: "#c71585",
    midnightblue: "#191970",
    mintcream: "#f5fffa",
    mistyrose: "#ffe4e1",
    moccasin: "#ffe4b5",
    navajowhite: "#ffdead",
    navy: "#000080",
    oldlace: "#fdf5e6",
    olive: "#808000",
    olivedrab: "#6b8e23",
    orange: "#ffa500",
    orangered: "#ff4500",
    orchid: "#da70d6",
    palegoldenrod: "#eee8aa",
    palegreen: "#98fb98",
    paleturquoise: "#afeeee",
    palevioletred: "#db7093",
    papayawhip: "#ffefd5",
    peachpuff: "#ffdab9",
    peru: "#cd853f",
    pink: "#ffc0cb",
    plum: "#dda0dd",
    powderblue: "#b0e0e6",
    purple: "#800080",
    red: "#ff0000",
    rosybrown: "#bc8f8f",
    royalblue: "#4169e1",
    saddlebrown: "#8b4513",
    salmon: "#fa8072",
    sandybrown: "#f4a460",
    seagreen: "#2e8b57",
    seashell: "#fff5ee",
    sienna: "#a0522d",
    silver: "#c0c0c0",
    skyblue: "#87ceeb",
    slateblue: "#6a5acd",
    slategray: "#708090",
    slategrey: "#708090",
    snow: "#fffafa",
    springgreen: "#00ff7f",
    steelblue: "#4682b4",
    tan: "#d2b48c",
    teal: "#008080",
    thistle: "#d8bfd8",
    tomato: "#ff6347",
    turquoise: "#40e0d0",
    violet: "#ee82ee",
    wheat: "#f5deb3",
    white: gvjs_ea,
    whitesmoke: "#f5f5f5",
    yellow: "#ffff00",
    yellowgreen: "#9acd32"
};
function gvjs_qj(a) {
    var b = {};
    a = String(a);
    var c = "#" == a.charAt(0) ? a : "#" + a;
    if (gvjs_rj.test(c))
        return b.hex = gvjs_sj(c),
        b.type = "hex",
        b;
    c = gvjs_tj(a);
    if (c.length)
        return b.hex = gvjs_uj(c),
        b.type = "rgb",
        b;
    if (gvjs_pj && (c = gvjs_pj[a.toLowerCase()]))
        return b.hex = c,
        b.type = "named",
        b;
    throw Error(a + " is not a valid color string");
}
var gvjs_5aa = /#(.)(.)(.)/;
function gvjs_sj(a) {
    if (!gvjs_rj.test(a))
        throw Error("'" + a + "' is not a valid hex color");
    4 == a.length && (a = a.replace(gvjs_5aa, "#$1$1$2$2$3$3"));
    return a.toLowerCase()
}
function gvjs_vj(a) {
    a = gvjs_sj(a);
    a = parseInt(a.substr(1), 16);
    return [a >> 16, a >> 8 & 255, a & 255]
}
function gvjs_wj(a, b, c) {
    a = Number(a);
    b = Number(b);
    c = Number(c);
    if (a != (a & 255) || b != (b & 255) || c != (c & 255))
        throw Error('"(' + a + "," + b + "," + c + '") is not a valid RGB color');
    b = a << 16 | b << 8 | c;
    return 16 > a ? "#" + (16777216 | b).toString(16).substr(1) : "#" + b.toString(16)
}
function gvjs_uj(a) {
    return gvjs_wj(a[0], a[1], a[2])
}
var gvjs_rj = /^#(?:[0-9a-f]{3}){1,2}$/i
  , gvjs_6aa = /^(?:rgb)?\((0|[1-9]\d{0,2}),\s?(0|[1-9]\d{0,2}),\s?(0|[1-9]\d{0,2})\)$/i;
function gvjs_tj(a) {
    var b = a.match(gvjs_6aa);
    if (b) {
        a = Number(b[1]);
        var c = Number(b[2]);
        b = Number(b[3]);
        if (0 <= a && 255 >= a && 0 <= c && 255 >= c && 0 <= b && 255 >= b)
            return [a, c, b]
    }
    return []
}
function gvjs_xj(a, b, c) {
    c = gvjs_0g(c, 0, 1);
    return [Math.round(b[0] + c * (a[0] - b[0])), Math.round(b[1] + c * (a[1] - b[1])), Math.round(b[2] + c * (a[2] - b[2]))]
}
;function gvjs_yj(a, b) {
    if (null != a && "" !== a && a !== gvjs_Qd && a !== gvjs_f) {
        if (gvjs_r(a))
            return a.color || "";
        if (typeof a === gvjs_l) {
            try {
                return gvjs_qj(a).hex
            } catch (c) {
                if (!b)
                    throw Error("Invalid color: " + a);
            }
            return a
        }
    }
    return gvjs_f
}
;var gvjs_zj;
function gvjs_Aj(a, b, c, d) {
    this.Gd = a || [{}];
    this.AJ = d || gvjs_Te(1, this.Gd.length);
    this.lN = b || null;
    this.P_ = null != c ? c : !1
}
gvjs_ = gvjs_Aj.prototype;
gvjs_.view = function(a) {
    a = gvjs_Bj(this, a);
    return new gvjs_Aj(gvjs_Le(this.Gd),a,this.P_,gvjs_Le(this.AJ))
}
;
function gvjs_Bj(a, b) {
    typeof b === gvjs_l && (b = [b]);
    return null != a.lN ? gvjs_Cj(a.lN, b) : b
}
function gvjs_Cj(a, b) {
    a = typeof a === gvjs_l ? [a] : a;
    var c = typeof b === gvjs_l ? [b] : b;
    if (0 === a.length)
        return c;
    if (0 === c.length)
        return a;
    var d = [];
    gvjs_u(a, function(e) {
        var f = gvjs_jf(e);
        gvjs_u(c, function(g) {
            var h = gvjs_jf(g);
            f || h ? f ? h || d.push(g) : d.push(e) : d.push(e + "." + g)
        })
    });
    return d
}
function gvjs_Dj(a, b, c, d) {
    typeof b === gvjs_l && (b = [b]);
    for (var e = 0; e < b.length; ++e) {
        var f = gvjs_Ej(a, b[e], c, d);
        if (null != f)
            return f
    }
    return null
}
function gvjs_Ej(a, b, c, d) {
    a = d ? a[b] : gvjs_kj(b, a);
    return null != a && typeof c === gvjs_d ? c(a) : a
}
gvjs_.ob = function(a, b) {
    var c = [];
    null != b && c.push(b);
    a = gvjs_Bj(this, a);
    for (b = this.Gd.length - 1; 0 <= b; b--)
        for (var d = a.length - 1; 0 <= d; d--) {
            var e = gvjs_Ej(this.Gd[b], a[d], void 0, this.P_);
            null != e && c.unshift(e)
        }
    return c
}
;
function gvjs_7aa(a, b, c) {
    var d = {};
    a = a.ob(b, c);
    gvjs_Ce(a, function(e) {
        typeof e === gvjs_h && gvjs_mj(d, e)
    });
    return d
}
gvjs_.fa = function(a, b, c) {
    a = gvjs_Bj(this, a);
    for (var d = 0; d < this.Gd.length; d++) {
        var e = gvjs_Dj(this.Gd[d], a, c, this.P_);
        if (null != e)
            return e
    }
    e = null != b && c ? c(b) : b;
    return null != e ? e : null
}
;
gvjs_.pb = function(a, b, c) {
    a = gvjs_7aa(this, a, b);
    c && (a = c(a));
    return a || {}
}
;
function gvjs_Fj(a, b, c, d, e, f) {
    function g(h) {
        return b(h, f)
    }
    a = a.fa(d, e, g);
    null == a && (a = g(c),
    null == a && (a = c));
    if (null == a)
        throw Error("Unexpected null value for " + d);
    return a
}
function gvjs_Gj(a, b, c, d) {
    a = a.fa(c, null, function(e) {
        return b(e, d)
    });
    return null == a ? null : a
}
function gvjs_Hj(a, b) {
    a = null != a && typeof a !== gvjs_h ? String(a) : null;
    return b ? Array.isArray(b) ? gvjs_He(b, a) ? a : null : gvjs__e(b, a) ? a : null : a
}
function gvjs_J(a, b, c, d) {
    return gvjs_Fj(a, gvjs_Hj, "", b, c, d)
}
gvjs_.cb = function(a, b) {
    return gvjs_Gj(this, gvjs_Hj, a, b)
}
;
function gvjs_Ij(a, b) {
    if (null == a)
        return null;
    typeof a === gvjs_l && (a = [a]);
    return Array.isArray(a) ? gvjs_De(gvjs_v(a, function(c) {
        return gvjs_Hj(c, b)
    }), function(c) {
        return null != c
    }) : null
}
gvjs_.cD = function(a, b) {
    return gvjs_Gj(this, gvjs_Ij, a, b)
}
;
function gvjs_Jj(a) {
    if (null == a)
        return null;
    if (typeof a === gvjs_zb)
        return a;
    a = String(a);
    return "1" === a || a.toLowerCase() === gvjs_Rd ? !0 : "0" === a || a.toLowerCase() === gvjs_Sb ? !1 : null
}
function gvjs_K(a, b, c) {
    return gvjs_Fj(a, gvjs_Jj, !1, b, c)
}
gvjs_.Dq = function(a) {
    return gvjs_Gj(this, gvjs_Jj, a)
}
;
function gvjs_Kj(a) {
    if (null == a)
        return null;
    if (typeof a === gvjs_g)
        return a;
    a = gvjs_jg(String(a));
    return isNaN(a) ? null : a
}
function gvjs_L(a, b, c) {
    return gvjs_Fj(a, gvjs_Kj, 0, b, c)
}
gvjs_.Aa = function(a) {
    return gvjs_Gj(this, gvjs_Kj, a)
}
;
function gvjs_Lj(a) {
    return null == a ? null : typeof a === gvjs_g || typeof a === gvjs_l || typeof a === gvjs_zb ? a : null
}
gvjs_.kt = function(a) {
    return gvjs_Gj(this, gvjs_Lj, a)
}
;
function gvjs_Mj(a) {
    return null == a ? null : Array.isArray(a) ? gvjs_De(gvjs_v(a, gvjs_Kj), function(b) {
        return null != b
    }) : null
}
gvjs_.$I = function(a) {
    return gvjs_Gj(this, gvjs_Mj, a)
}
;
function gvjs_Nj(a) {
    a = gvjs_Kj(a);
    return null != a && 0 <= a ? a : null
}
function gvjs_Oj(a, b, c) {
    return gvjs_Fj(a, gvjs_Nj, 0, b, c)
}
gvjs_.bD = function(a) {
    return gvjs_Gj(this, gvjs_Nj, a)
}
;
function gvjs_Pj(a) {
    a = gvjs_Kj(a);
    return null != a ? gvjs_0g(a, 0, 1) : null
}
gvjs_.Hra = function(a) {
    return gvjs_Gj(this, gvjs_Pj, a)
}
;
function gvjs_Qj(a, b) {
    if (null == a)
        return null;
    if ("" === a)
        return gvjs_f;
    if (typeof a === gvjs_h)
        return a.color || a.lighter || a.darker ? a : null;
    a = gvjs_Hj(a);
    if (Array.isArray(b) && gvjs_He(b, a))
        return a;
    try {
        return gvjs_yj(a)
    } catch (c) {
        return null
    }
}
gvjs_.mz = function(a, b) {
    return gvjs_Gj(this, gvjs_Qj, a, b)
}
;
function gvjs_Rj(a, b) {
    b = null != b ? b : 1;
    var c = gvjs_Kj(a);
    null == c && (a = gvjs_Hj(a),
    null != a && gvjs_if(a) && (c = a.slice(0, -1),
    c = b * Number(c) / 100));
    null != c && (c = 0 === b ? 0 : b * gvjs_0g(c / b, 0, 1));
    return c
}
gvjs_.Mg = function(a, b) {
    return gvjs_Gj(this, gvjs_Rj, a, b)
}
;
gvjs_zj = {
    string: gvjs_Aj.prototype.cb,
    number: gvjs_Aj.prototype.Aa,
    "boolean": gvjs_Aj.prototype.Dq,
    numberOrString: [gvjs_g, gvjs_l],
    primitive: gvjs_Aj.prototype.kt,
    ratio: gvjs_Aj.prototype.Hra,
    nonNegative: gvjs_Aj.prototype.bD,
    absOrPercentage: gvjs_Aj.prototype.Mg,
    arrayOfNumber: gvjs_Aj.prototype.$I,
    arrayOfString: gvjs_Aj.prototype.cD,
    color: gvjs_Aj.prototype.mz,
    object: gvjs_Aj.prototype.pb
};
function gvjs_Sj() {}
gvjs_Sj.prototype.Ob = function(a) {
    return this.cP(a) || ""
}
;
gvjs_Sj.prototype.format = function(a, b, c) {
    a.format(b, c || this)
}
;
gvjs_Sj.prototype.dv = function() {
    var a = this;
    return {
        format: function(b) {
            return a.Ob(b)
        }
    }
}
;
gvjs_Sj.prototype.QY = function(a, b) {
    return a.format(b, null)
}
;
function gvjs_Tj(a) {
    this.gd = this.pattern = null;
    this.init(a)
}
gvjs_o(gvjs_Tj, gvjs_Sj);
gvjs_ = gvjs_Tj.prototype;
gvjs_.init = function(a) {
    a = new gvjs_Aj([a || {}, {
        formatType: gvjs_Gd,
        valueType: gvjs_Mb
    }]);
    this.pattern = a.fa(gvjs_td);
    this.gd = null;
    this.formatType = a.cb("formatType", Object.values(gvjs_8aa));
    this.Nla = a.cb("valueType", Object.values(gvjs_zi));
    this.Fla = gvjs_K(a, "clearMinutes", !1);
    this.timeZone = null;
    a = a.Aa("timeZone");
    null != a && (this.timeZone = gvjs_Vi(60 * -a))
}
;
function gvjs_9aa(a, b) {
    switch (a) {
    case gvjs_Lb:
        switch (b) {
        case gvjs_Tb:
            return 0;
        case "long":
            return 1;
        case gvjs_dd:
            return 2;
        case gvjs_Gd:
            return 3;
        default:
            return 8
        }
    case gvjs_Mb:
        switch (b) {
        case gvjs_Tb:
            return 8;
        case "long":
            return 9;
        case gvjs_dd:
            return 10;
        case gvjs_Gd:
            return 11;
        default:
            return 8
        }
    case "time":
        switch (b) {
        case gvjs_Tb:
            return 4;
        case "long":
            return 5;
        case gvjs_dd:
            return 6;
        case gvjs_Gd:
            return 7;
        default:
            return 8
        }
    default:
        return 8
    }
}
gvjs_.pm = gvjs_n(16);
gvjs_.cP = function(a) {
    if (gvjs_Uj)
        return gvjs_Uj.call(this, a, this.pattern);
    this.gd || (this.gd = this.dv(this.Nla));
    return this.QY(this.gd, a)
}
;
gvjs_.Jo = function(a) {
    a = gvjs_Hj(a, gvjs_zi);
    return a !== gvjs_Lb && a !== gvjs_Mb ? null : a
}
;
gvjs_.dv = function(a) {
    var b = this.pattern;
    null == b && (b = gvjs_9aa(a, this.formatType));
    var c = new gvjs_Xi(b);
    return {
        format: function(d, e) {
            return c.format(d, e)
        }
    }
}
;
gvjs_.QY = function(a, b) {
    if (null === b)
        return "";
    var c = this.timeZone;
    null == c && (c = gvjs_Vi(b.getTimezoneOffset()));
    b = new Date(b.getTime());
    this.Fla && b.setMinutes(0);
    return a.format(b, c)
}
;
var gvjs_Uj = void 0
  , gvjs_Vj = gvjs_2i
  , gvjs_8aa = {
    gAa: gvjs_Tb,
    EAa: "long",
    JAa: gvjs_dd,
    SHORT: gvjs_Gd
};
var gvjs_Wj = {
    q6: {
        1E3: {
            other: "0K"
        },
        1E4: {
            other: "00K"
        },
        1E5: {
            other: "000K"
        },
        1E6: {
            other: "0M"
        },
        1E7: {
            other: "00M"
        },
        1E8: {
            other: "000M"
        },
        1E9: {
            other: "0B"
        },
        1E10: {
            other: "00B"
        },
        1E11: {
            other: "000B"
        },
        1E12: {
            other: "0T"
        },
        1E13: {
            other: "00T"
        },
        1E14: {
            other: "000T"
        }
    },
    jia: {
        1E3: {
            other: "0 thousand"
        },
        1E4: {
            other: "00 thousand"
        },
        1E5: {
            other: "000 thousand"
        },
        1E6: {
            other: "0 million"
        },
        1E7: {
            other: "00 million"
        },
        1E8: {
            other: "000 million"
        },
        1E9: {
            other: "0 billion"
        },
        1E10: {
            other: "00 billion"
        },
        1E11: {
            other: "000 billion"
        },
        1E12: {
            other: "0 trillion"
        },
        1E13: {
            other: "00 trillion"
        },
        1E14: {
            other: "000 trillion"
        }
    }
}
  , gvjs_Xj = gvjs_Wj;
gvjs_Xj = gvjs_Wj;
var gvjs_Yj = {
    AED: [2, "dh", "\u062f.\u0625."],
    ALL: [0, "Lek", "Lek"],
    AUD: [2, "$", "AU$"],
    BDT: [2, "\u09f3", "Tk"],
    BGN: [2, "lev", "lev"],
    BRL: [2, "R$", "R$"],
    CAD: [2, "$", "C$"],
    CDF: [2, "FrCD", "CDF"],
    CHF: [2, "CHF", "CHF"],
    CLP: [0, "$", "CL$"],
    CNY: [2, "\u00a5", "RMB\u00a5"],
    COP: [32, "$", "COL$"],
    CRC: [0, "\u20a1", "CR\u20a1"],
    CZK: [50, "K\u010d", "K\u010d"],
    DKK: [50, "kr.", "kr."],
    DOP: [2, "RD$", "RD$"],
    EGP: [2, "\u00a3", "LE"],
    ETB: [2, "Birr", "Birr"],
    EUR: [2, "\u20ac", "\u20ac"],
    GBP: [2, "\u00a3", "GB\u00a3"],
    HKD: [2, "$", "HK$"],
    HRK: [2, "kn", "kn"],
    HUF: [34, "Ft", "Ft"],
    IDR: [0, "Rp", "Rp"],
    ILS: [34, "\u20aa", "IL\u20aa"],
    INR: [2, "\u20b9", "Rs"],
    IRR: [0, "Rial", "IRR"],
    ISK: [0, "kr", "kr"],
    JMD: [2, "$", "JA$"],
    JPY: [0, "\u00a5", "JP\u00a5"],
    KRW: [0, "\u20a9", "KR\u20a9"],
    LKR: [2, "Rs", "SLRs"],
    LTL: [2, "Lt", "Lt"],
    MNT: [0, "\u20ae", "MN\u20ae"],
    MVR: [2, "Rf", "MVR"],
    MXN: [2, "$", "Mex$"],
    MYR: [2, "RM", "RM"],
    NOK: [50, "kr", "NOkr"],
    PAB: [2, "B/.", "B/."],
    PEN: [2, "S/.", "S/."],
    PHP: [2, "\u20b1", "PHP"],
    PKR: [0, "Rs", "PKRs."],
    PLN: [50, "z\u0142", "z\u0142"],
    RON: [2, "RON", "RON"],
    RSD: [0, "din", "RSD"],
    RUB: [50, "\u20bd", "RUB"],
    SAR: [2, "Rial", "Rial"],
    SEK: [50, "kr", "kr"],
    SGD: [2, "$", "S$"],
    THB: [2, "\u0e3f", "THB"],
    TRY: [2, "\u20ba", "TRY"],
    TWD: [2, "$", "NT$"],
    TZS: [0, "TSh", "TSh"],
    UAH: [2, "\u0433\u0440\u043d.", "UAH"],
    USD: [2, "$", "US$"],
    UYU: [2, "$", "$U"],
    VND: [48, "\u20ab", "VN\u20ab"],
    YER: [0, "Rial", "Rial"],
    ZAR: [2, "R", "ZAR"]
};
var gvjs_Zj = {
    DECIMAL_SEP: ".",
    GROUP_SEP: ",",
    PERCENT: "%",
    BV: "0",
    nja: "+",
    w6: "-",
    t6: "E",
    y6: "\u2030",
    sV: "\u221e",
    cja: "NaN",
    DECIMAL_PATTERN: "#,##0.###",
    tja: "#E0",
    vV: "#,##0%",
    kia: "\u00a4#,##0.00",
    mia: "USD"
}
  , gvjs__j = gvjs_Zj
  , gvjs_0j = gvjs_Zj;
gvjs_0j = gvjs__j = gvjs_Zj;
function gvjs_1j(a) {
    this.Wra = null;
    this.oma = 0;
    this.Mua = null;
    this.MJ = 40;
    this.Zo = 1;
    this.hu = 0;
    this.Qq = 3;
    this.tR = this.Ht = 0;
    this.h4 = this.jha = !1;
    this.wK = this.hA = "";
    this.sw = gvjs_2j(this).w6;
    this.QD = "";
    this.Jf = 1;
    this.Pz = !1;
    this.Yy = [];
    this.NU = this.i9 = !1;
    this.eH = 0;
    this.kN = null;
    typeof a == gvjs_g ? this.aN(a) : this.Zr(a)
}
var gvjs_3j = !1;
function gvjs_2j(a) {
    return a.Mua || (gvjs_3j ? gvjs_0j : gvjs__j)
}
function gvjs_4j(a) {
    return a.Wra || gvjs_2j(a).mia
}
gvjs_ = gvjs_1j.prototype;
gvjs_.setMinimumFractionDigits = function(a) {
    if (0 < this.hu && 0 < a)
        throw Error(gvjs_ta);
    this.Ht = a;
    return this
}
;
gvjs_.setMaximumFractionDigits = function(a) {
    if (308 < a)
        throw Error("Unsupported maximum fraction digits: " + a);
    this.Qq = a;
    return this
}
;
gvjs_.setSignificantDigits = function(a) {
    if (0 < this.Ht && 0 <= a)
        throw Error(gvjs_ta);
    this.hu = a;
    return this
}
;
gvjs_.getSignificantDigits = function() {
    return this.hu
}
;
gvjs_.setShowTrailingZeros = function(a) {
    this.h4 = a;
    return this
}
;
gvjs_.setBaseFormatting = function(a) {
    this.kN = a;
    return this
}
;
gvjs_.getBaseFormatting = function() {
    return this.kN
}
;
gvjs_.Zr = function(a) {
    this.cA = a.replace(/ /g, "\u00a0");
    var b = [0];
    this.hA = gvjs_5j(this, a, b);
    for (var c = b[0], d = -1, e = 0, f = 0, g = 0, h = -1, k = a.length, l = !0; b[0] < k && l; b[0]++)
        switch (a.charAt(b[0])) {
        case "#":
            0 < f ? g++ : e++;
            0 <= h && 0 > d && h++;
            break;
        case "0":
            if (0 < g)
                throw Error('Unexpected "0" in pattern "' + a + '"');
            f++;
            0 <= h && 0 > d && h++;
            break;
        case ",":
            0 < h && this.Yy.push(h);
            h = 0;
            break;
        case ".":
            if (0 <= d)
                throw Error('Multiple decimal separators in pattern "' + a + '"');
            d = e + f + g;
            break;
        case "E":
            if (this.NU)
                throw Error('Multiple exponential symbols in pattern "' + a + '"');
            this.NU = !0;
            this.tR = 0;
            b[0] + 1 < k && "+" == a.charAt(b[0] + 1) && (b[0]++,
            this.jha = !0);
            for (; b[0] + 1 < k && "0" == a.charAt(b[0] + 1); )
                b[0]++,
                this.tR++;
            if (1 > e + f || 1 > this.tR)
                throw Error('Malformed exponential pattern "' + a + '"');
            l = !1;
            break;
        default:
            b[0]--,
            l = !1
        }
    0 == f && 0 < e && 0 <= d && (f = d,
    0 == f && f++,
    g = e - f,
    e = f - 1,
    f = 1);
    if (0 > d && 0 < g || 0 <= d && (d < e || d > e + f) || 0 == h)
        throw Error('Malformed pattern "' + a + '"');
    g = e + f + g;
    this.Qq = 0 <= d ? g - d : 0;
    0 <= d && (this.Ht = e + f - d,
    0 > this.Ht && (this.Ht = 0));
    this.Zo = (0 <= d ? d : g) - e;
    this.NU && (this.MJ = e + this.Zo,
    0 == this.Qq && 0 == this.Zo && (this.Zo = 1));
    this.Yy.push(Math.max(0, h));
    this.i9 = 0 == d || d == g;
    c = b[0] - c;
    this.wK = gvjs_5j(this, a, b);
    b[0] < a.length && ";" == a.charAt(b[0]) ? (b[0]++,
    1 != this.Jf && (this.Pz = !0),
    this.sw = gvjs_5j(this, a, b),
    b[0] += c,
    this.QD = gvjs_5j(this, a, b)) : (this.sw += this.hA,
    this.QD += this.wK)
}
;
gvjs_.aN = function(a) {
    switch (a) {
    case 1:
        this.Zr(gvjs_2j(this).DECIMAL_PATTERN);
        break;
    case 2:
        this.Zr(gvjs_2j(this).tja);
        break;
    case 3:
        this.Zr(gvjs_2j(this).vV);
        break;
    case 4:
        a = this.Zr;
        var b = gvjs_2j(this).kia;
        var c = ["0"]
          , d = gvjs_Yj[gvjs_4j(this)];
        if (d) {
            d = d[0] & 7;
            if (0 < d) {
                c.push(".");
                for (var e = 0; e < d; e++)
                    c.push("0")
            }
            b = b.replace(/0.00/g, c.join(""))
        }
        a.call(this, b);
        break;
    case 5:
        gvjs_6j(this, 1);
        break;
    case 6:
        gvjs_6j(this, 2);
        break;
    default:
        throw Error("Unsupported pattern type.");
    }
}
;
function gvjs_6j(a, b) {
    a.eH = b;
    a.Zr(gvjs_2j(a).DECIMAL_PATTERN);
    a.setMinimumFractionDigits(0);
    a.setMaximumFractionDigits(2);
    a.setSignificantDigits(2)
}
gvjs_.parse = function(a, b) {
    b = b || [0];
    if (0 != this.eH)
        throw Error("Parsing of compact numbers is unimplemented");
    a = a.replace(/ |\u202f/g, "\u00a0");
    var c = a.indexOf(this.hA, b[0]) == b[0]
      , d = a.indexOf(this.sw, b[0]) == b[0];
    c && d && (this.hA.length > this.sw.length ? d = !1 : this.hA.length < this.sw.length && (c = !1));
    c ? b[0] += this.hA.length : d && (b[0] += this.sw.length);
    if (a.indexOf(gvjs_2j(this).sV, b[0]) == b[0]) {
        b[0] += gvjs_2j(this).sV.length;
        var e = Infinity
    } else {
        e = a;
        var f = !1
          , g = !1
          , h = !1
          , k = -1
          , l = 1
          , m = gvjs_2j(this).DECIMAL_SEP
          , n = gvjs_2j(this).GROUP_SEP
          , p = gvjs_2j(this).t6;
        if (0 != this.eH)
            throw Error("Parsing of compact style numbers is not implemented");
        n = n.replace(/\u202f/g, "\u00a0");
        for (var q = ""; b[0] < e.length; b[0]++) {
            var r = e.charAt(b[0])
              , t = gvjs_7j(this, r);
            if (0 <= t && 9 >= t)
                q += t,
                h = !0;
            else if (r == m.charAt(0)) {
                if (f || g)
                    break;
                q += ".";
                f = !0
            } else if (r == n.charAt(0) && ("\u00a0" != n.charAt(0) || b[0] + 1 < e.length && 0 <= gvjs_7j(this, e.charAt(b[0] + 1)))) {
                if (f || g)
                    break
            } else if (r == p.charAt(0)) {
                if (g)
                    break;
                q += "E";
                g = !0;
                k = b[0]
            } else if ("+" == r || "-" == r) {
                if (h && k != b[0] - 1)
                    break;
                q += r
            } else if (1 == this.Jf && r == gvjs_2j(this).PERCENT.charAt(0)) {
                if (1 != l)
                    break;
                l = 100;
                if (h) {
                    b[0]++;
                    break
                }
            } else if (1 == this.Jf && r == gvjs_2j(this).y6.charAt(0)) {
                if (1 != l)
                    break;
                l = 1E3;
                if (h) {
                    b[0]++;
                    break
                }
            } else
                break
        }
        1 != this.Jf && (l = this.Jf);
        e = parseFloat(q) / l
    }
    if (c) {
        if (a.indexOf(this.wK, b[0]) != b[0])
            return NaN;
        b[0] += this.wK.length
    } else if (d) {
        if (a.indexOf(this.QD, b[0]) != b[0])
            return NaN;
        b[0] += this.QD.length
    }
    return d ? -e : e
}
;
gvjs_.format = function(a) {
    if (isNaN(a))
        return gvjs_2j(this).cja;
    var b = [];
    var c = null === this.kN ? a : this.kN;
    if (0 == this.eH)
        c = gvjs_8j;
    else {
        c = Math.abs(c);
        var d = gvjs_9j(this, 1 >= c ? 0 : gvjs_$j(c)).divisorBase;
        c = gvjs_9j(this, d + gvjs_$j(gvjs_ak(this, gvjs_bk(c, -d)).wba))
    }
    a = gvjs_bk(a, -c.divisorBase);
    (d = 0 > a || 0 == a && 0 > 1 / a) ? c.p1 ? b.push(c.p1) : (b.push(c.prefix),
    b.push(this.sw)) : (b.push(c.prefix),
    b.push(this.hA));
    if (isFinite(a))
        if (a = a * (d ? -1 : 1) * this.Jf,
        this.NU) {
            var e = a;
            if (0 == e)
                gvjs_ck(this, e, this.Zo, b),
                gvjs_dk(this, 0, b);
            else {
                var f = Math.floor(Math.log(e) / Math.log(10) + 2E-15);
                e = gvjs_bk(e, -f);
                var g = this.Zo;
                1 < this.MJ && this.MJ > this.Zo ? (g = f % this.MJ,
                0 > g && (g = this.MJ + g),
                e = gvjs_bk(e, g),
                f -= g,
                g = 1) : 1 > this.Zo ? (f++,
                e = gvjs_bk(e, -1)) : (f -= this.Zo - 1,
                e = gvjs_bk(e, this.Zo - 1));
                gvjs_ck(this, e, g, b);
                gvjs_dk(this, f, b)
            }
        } else
            gvjs_ck(this, a, this.Zo, b);
    else
        b.push(gvjs_2j(this).sV);
    d ? c.q1 ? b.push(c.q1) : (isFinite(a) && b.push(c.suffix),
    b.push(this.QD)) : (isFinite(a) && b.push(c.suffix),
    b.push(this.wK));
    return b.join("")
}
;
function gvjs_ak(a, b) {
    var c = gvjs_bk(b, a.Qq);
    0 < a.hu && (c = gvjs_ek(c, a.hu, a.Qq));
    c = Math.round(c);
    isFinite(c) ? (b = Math.floor(gvjs_bk(c, -a.Qq)),
    a = Math.floor(c - gvjs_bk(b, a.Qq))) : a = 0;
    return {
        wba: b,
        qoa: a
    }
}
function gvjs_ck(a, b, c, d) {
    if (a.Ht > a.Qq)
        throw Error("Min value must be less than max value");
    d || (d = []);
    b = gvjs_ak(a, b);
    var e = b.wba
      , f = b.qoa
      , g = 0 == e ? 0 : gvjs_$j(e) + 1
      , h = 0 < a.Ht || 0 < f || a.h4 && g < a.hu;
    b = a.Ht;
    h && (b = a.h4 && 0 < a.hu ? a.hu - g : a.Ht);
    var k = "";
    for (g = e; 1E20 < g; )
        k = "0" + k,
        g = Math.round(gvjs_bk(g, -1));
    k = g + k;
    var l = gvjs_2j(a).DECIMAL_SEP;
    g = gvjs_2j(a).BV.charCodeAt(0);
    var m = k.length
      , n = 0;
    if (0 < e || 0 < c) {
        for (e = m; e < c; e++)
            d.push(String.fromCharCode(g));
        if (2 <= a.Yy.length)
            for (c = 1; c < a.Yy.length; c++)
                n += a.Yy[c];
        c = m - n;
        if (0 < c) {
            e = a.Yy;
            n = m = 0;
            for (var p, q = gvjs_2j(a).GROUP_SEP, r = k.length, t = 0; t < r; t++)
                if (d.push(String.fromCharCode(g + 1 * Number(k.charAt(t)))),
                1 < r - t)
                    if (p = e[n],
                    t < c) {
                        var u = c - t;
                        (1 === p || 0 < p && 1 === u % p) && d.push(q)
                    } else
                        n < e.length && (t === c ? n += 1 : p === t - c - m + 1 && (d.push(q),
                        m += p,
                        n += 1))
        } else {
            c = k;
            k = a.Yy;
            e = gvjs_2j(a).GROUP_SEP;
            p = c.length;
            q = [];
            for (m = k.length - 1; 0 <= m && 0 < p; m--) {
                n = k[m];
                for (r = 0; r < n && 0 <= p - r - 1; r++)
                    q.push(String.fromCharCode(g + 1 * Number(c.charAt(p - r - 1))));
                p -= n;
                0 < p && q.push(e)
            }
            d.push.apply(d, q.reverse())
        }
    } else
        h || d.push(String.fromCharCode(g));
    (a.i9 || h) && d.push(l);
    f = String(f);
    h = f.split("e+");
    2 == h.length && (f = String(gvjs_ek(parseFloat(h[0]), a.hu, 1)),
    f = f.replace(".", ""),
    f += gvjs_eg("0", parseInt(h[1], 10) - f.length + 1));
    a.Qq + 1 > f.length && (f = "1" + gvjs_eg("0", a.Qq - f.length) + f);
    for (a = f.length; "0" == f.charAt(a - 1) && a > b + 1; )
        a--;
    for (e = 1; e < a; e++)
        d.push(String.fromCharCode(g + 1 * Number(f.charAt(e))))
}
function gvjs_dk(a, b, c) {
    c.push(gvjs_2j(a).t6);
    0 > b ? (b = -b,
    c.push(gvjs_2j(a).w6)) : a.jha && c.push(gvjs_2j(a).nja);
    b = "" + b;
    for (var d = gvjs_2j(a).BV, e = b.length; e < a.tR; e++)
        c.push(d);
    c.push(b)
}
function gvjs_7j(a, b) {
    b = b.charCodeAt(0);
    if (48 <= b && 58 > b)
        return b - 48;
    a = gvjs_2j(a).BV.charCodeAt(0);
    return a <= b && b < a + 10 ? b - a : -1
}
function gvjs_5j(a, b, c) {
    for (var d = "", e = !1, f = b.length; c[0] < f; c[0]++) {
        var g = b.charAt(c[0]);
        if ("'" == g)
            c[0] + 1 < f && "'" == b.charAt(c[0] + 1) ? (c[0]++,
            d += "'") : e = !e;
        else if (e)
            d += g;
        else
            switch (g) {
            case "#":
            case "0":
            case ",":
            case ".":
            case ";":
                return d;
            case "\u00a4":
                if (c[0] + 1 < f && "\u00a4" == b.charAt(c[0] + 1))
                    c[0]++,
                    d += gvjs_4j(a);
                else
                    switch (a.oma) {
                    case 0:
                        g = gvjs_4j(a);
                        d += g in gvjs_Yj ? gvjs_Yj[g][1] : g;
                        break;
                    case 2:
                        g = gvjs_4j(a);
                        var h = gvjs_Yj[g];
                        d += h ? g == h[1] ? g : g + " " + h[1] : g;
                        break;
                    case 1:
                        g = gvjs_4j(a),
                        d += g in gvjs_Yj ? gvjs_Yj[g][2] : g
                    }
                break;
            case "%":
                if (!a.Pz && 1 != a.Jf)
                    throw Error(gvjs_gb);
                if (a.Pz && 100 != a.Jf)
                    throw Error(gvjs_Qa);
                a.Jf = 100;
                a.Pz = !1;
                d += gvjs_2j(a).PERCENT;
                break;
            case "\u2030":
                if (!a.Pz && 1 != a.Jf)
                    throw Error(gvjs_gb);
                if (a.Pz && 1E3 != a.Jf)
                    throw Error(gvjs_Qa);
                a.Jf = 1E3;
                a.Pz = !1;
                d += gvjs_2j(a).y6;
                break;
            default:
                d += g
            }
    }
    return d
}
var gvjs_8j = {
    divisorBase: 0,
    p1: "",
    q1: "",
    prefix: "",
    suffix: ""
};
function gvjs_9j(a, b) {
    a = 1 == a.eH ? gvjs_Xj.q6 : gvjs_Xj.jia;
    null == a && (a = gvjs_Xj.q6);
    if (3 > b)
        return gvjs_8j;
    b = Math.min(14, b);
    var c = a[gvjs_bk(1, b)];
    for (--b; !c && 3 <= b; )
        c = a[gvjs_bk(1, b)],
        b--;
    if (!c)
        return gvjs_8j;
    c = c.other;
    var d = a = ""
      , e = c.indexOf(";");
    0 <= e && (c = c.substring(0, e),
    e = c.substring(e + 1)) && (d = /([^0]*)(0+)(.*)/.exec(e),
    a = d[1],
    d = d[3]);
    return c && "0" != c ? (c = /([^0]*)(0+)(.*)/.exec(c)) ? {
        divisorBase: b + 1 - (c[2].length - 1),
        p1: a,
        q1: d,
        prefix: c[1],
        suffix: c[3]
    } : gvjs_8j : gvjs_8j
}
function gvjs_$j(a) {
    if (!isFinite(a))
        return 0 < a ? a : 0;
    for (var b = 0; 1 <= (a /= 10); )
        b++;
    return b
}
function gvjs_bk(a, b) {
    if (!a || !isFinite(a) || 0 == b)
        return a;
    a = String(a).split("e");
    return parseFloat(a[0] + "e" + (parseInt(a[1] || 0, 10) + b))
}
function gvjs_fk(a, b) {
    return a && isFinite(a) ? gvjs_bk(Math.round(gvjs_bk(a, b)), -b) : a
}
function gvjs_ek(a, b, c) {
    if (!a)
        return a;
    b = b - gvjs_$j(a) - 1;
    return b < -c ? gvjs_fk(a, -c) : gvjs_fk(a, b)
}
gvjs_1j.prototype.isCurrencyCodeBeforeValue = function() {
    var a = this.cA.indexOf("\u00a4")
      , b = this.cA.indexOf("#")
      , c = this.cA.indexOf("0")
      , d = Number.MAX_VALUE;
    0 <= b && b < d && (d = b);
    0 <= c && c < d && (d = c);
    return a < d
}
;
function gvjs_gk(a) {
    this.gd = null;
    var b = new gvjs_Aj([a || {}, {
        decimalSymbol: gvjs_hk,
        groupingSymbol: gvjs_ik,
        fractionDigits: 2,
        significantDigits: null,
        negativeParens: !1,
        prefix: "",
        suffix: "",
        scaleFactor: 1
    }]);
    this.Ey = gvjs_Oj(b, "fractionDigits");
    a && typeof a.fractionDigits === gvjs_g && isNaN(a.fractionDigits) && (this.Ey = NaN);
    this.n4 = b.bD("significantDigits");
    this.Cma = gvjs_J(b, "decimalSymbol");
    this.MZ = gvjs_J(b, "groupingSymbol");
    this.prefix = gvjs_J(b, gvjs_wd);
    this.suffix = gvjs_J(b, gvjs_Kd);
    this.o1 = b.mz("negativeColor");
    this.mda = gvjs_K(b, "negativeParens");
    this.pattern = b.cb(gvjs_td);
    a = (this.pattern || "").toLowerCase();
    a in gvjs_jk && (this.pattern = gvjs_jk[a]);
    this.scaleFactor = gvjs_L(b, "scaleFactor");
    if (0 >= this.scaleFactor)
        throw Error("Scale factor must be a positive number.");
}
gvjs_o(gvjs_gk, gvjs_Sj);
gvjs_ = gvjs_gk.prototype;
gvjs_.format = function(a, b) {
    if (a.W(b) === gvjs_g)
        for (var c = 0; c < a.ca(); c++) {
            var d = a.getValue(c, b);
            if (null != d) {
                var e = this.Ob(d);
                a.Nw(c, b, e);
                0 > d && !gvjs_jf(gvjs_gg(this.o1)) && a.setProperty(c, b, gvjs_Jd, gvjs_Eb + this.o1 + ";")
            }
        }
}
;
gvjs_.Jo = function(a) {
    return a === gvjs_g ? a : null
}
;
gvjs_.dv = function() {
    var a = this;
    return {
        format: function(b) {
            if (null == b)
                return null;
            b = Number(b);
            return a.Ob(b)
        }
    }
}
;
gvjs_.cP = function(a) {
    if (gvjs_kk)
        return a = gvjs_kk.call(this, a / this.scaleFactor, this.pattern),
        this.prefix + a + this.suffix;
    var b = a / this.scaleFactor;
    if (null !== this.pattern) {
        a = gvjs_3j;
        gvjs_3j = !gvjs_lk;
        var c = new gvjs_1j(this.pattern);
        5 !== this.pattern && 6 !== this.pattern || c.setSignificantDigits(3);
        this.gd = c;
        null != this.n4 && (c.setSignificantDigits(this.n4),
        c.setMaximumFractionDigits(this.n4));
        b = c.format(b);
        b = this.prefix + b + this.suffix;
        gvjs_3j = a
    } else {
        if (isNaN(this.Ey))
            return String(a);
        this.mda && (b = Math.abs(b));
        c = b;
        0 === this.Ey && (c = Math.round(c));
        b = [];
        0 > c && (c = -c,
        b.push("-"));
        var d = Math.pow(10, this.Ey)
          , e = Math.round(c * d);
        c = String(Math.floor(e / d));
        d = String(e % d);
        if (3 < c.length && this.MZ)
            for (e = c.length % 3,
            0 < e && (b.push(c.substring(0, e), this.MZ),
            c = c.substring(e)); 3 < c.length; )
                b.push(c.substring(0, 3), this.MZ),
                c = c.substring(3);
        b.push(c);
        0 < this.Ey && (b.push(this.Cma),
        d.length < this.Ey && (d = gvjs_ka + d),
        b.push(d.substring(d.length - this.Ey)));
        b = b.join("");
        b = this.prefix + b + this.suffix;
        this.mda && 0 > a && (b = "(" + b + ")");
        this.o1 && (b += "")
    }
    return b
}
;
gvjs_.parse = function(a) {
    if (this.gd && this.gd.parse) {
        var b = gvjs_3j;
        gvjs_3j = !gvjs_lk;
        a = this.gd.parse(a);
        gvjs_3j = b;
        return a
    }
    throw Error("Cannot parse without parser.");
}
;
var gvjs_kk = void 0
  , gvjs_hk = gvjs__j.DECIMAL_SEP
  , gvjs_ik = gvjs__j.GROUP_SEP
  , gvjs_mk = gvjs__j.DECIMAL_PATTERN
  , gvjs_lk = !1
  , gvjs_jk = {
    decimal: 1,
    scientific: 2,
    percent: 3,
    currency: 4,
    "short": 5,
    "long": 6
};
function gvjs_nk() {}
gvjs_o(gvjs_nk, gvjs_Sj);
gvjs_nk.prototype.Jo = function(a) {
    return a === gvjs_l ? a : null
}
;
gvjs_nk.prototype.cP = function(a) {
    return String(a)
}
;
function gvjs_ok(a, b) {
    this.x = a;
    this.y = b
}
gvjs_t(gvjs_ok, gvjs_z);
gvjs_ = gvjs_ok.prototype;
gvjs_.clone = function() {
    return new gvjs_ok(this.x,this.y)
}
;
gvjs_.scale = gvjs_z.prototype.scale;
gvjs_.invert = function() {
    this.x = -this.x;
    this.y = -this.y;
    return this
}
;
gvjs_.normalize = function() {
    return this.scale(1 / Math.hypot(this.x, this.y))
}
;
gvjs_.add = function(a) {
    this.x += a.x;
    this.y += a.y;
    return this
}
;
gvjs_.aU = gvjs_n(17);
gvjs_.rotate = function(a) {
    var b = Math.cos(a);
    a = Math.sin(a);
    var c = this.y * b + this.x * a;
    this.x = this.x * b - this.y * a;
    this.y = c;
    return this
}
;
gvjs_.equals = function(a) {
    return this === a ? !0 : a instanceof gvjs_ok && !!a && this.x == a.x && this.y == a.y
}
;
/*

 Copyright 2021 Google LLC
 This code is released under the MIT license.
 SPDX-License-Identifier: MIT

 Tested with IE 6.0, IE 7.0, Firefox 2.0 and Opera 9

*/
function gvjs_pk(a) {
    a = 4 > a.length ? gvjs_Ke(a, gvjs_Te(0, 4 - a.length)) : gvjs_Le(a);
    return a.reverse()
}
function gvjs_qk(a) {
    a = gvjs_pk(a);
    var b = new Date(Date.UTC(1970, 0, 1, 0, 0, 0, 0));
    b.setUTCFullYear((a[6] || 0) + 1970);
    b.setUTCMonth(a[5] || 0);
    b.setUTCDate((a[4] || 0) + 1);
    b.setUTCHours(a[3] || 0);
    b.setUTCMinutes(a[2] || 0);
    b.setUTCSeconds(a[1] || 0);
    b.setUTCMilliseconds(a[0] || 0);
    return b
}
var gvjs_rk = "milliseconds seconds minutes hours days months years".split(" ")
  , gvjs_sk = {};
gvjs_u(gvjs_rk, function(a, b) {
    gvjs_sk[a] = b
});
function gvjs_tk(a) {
    var b = a && a.granularity;
    if (null == b || typeof b !== gvjs_g)
        b = 1;
    b = {
        pattern: 1 < b ? gvjs_Ia : 1 === b ? gvjs_Ja : gvjs_Ka
    };
    a && gvjs_2e(b, a);
    this.gd = new gvjs_Tj(b)
}
gvjs_o(gvjs_tk, gvjs_Sj);
gvjs_tk.prototype.Jo = function(a) {
    return a === gvjs_Od ? a : null
}
;
gvjs_tk.prototype.cP = function(a) {
    a = gvjs_qk(a);
    return this.gd.Ob(a)
}
;
function gvjs_uk(a) {
    var b = {};
    if (gvjs_me(a) !== gvjs_h || gvjs_oe(a))
        b.v = null != a ? a : null;
    else {
        b.v = "undefined" === typeof a.v ? null : a.v;
        if (null != a.f)
            if (typeof a.f === gvjs_l)
                b.f = a.f;
            else
                throw Error("Formatted value ('f'), if specified, must be a string.");
        if (null != a.p)
            if (typeof a.p === gvjs_h)
                b.p = a.p;
            else
                throw Error("Properties ('p'), if specified, must be an object.");
    }
    return b
}
function gvjs_$aa(a, b, c) {
    if (typeof b === gvjs_d)
        return b(a, c);
    for (var d = 0; d < b.length; d++) {
        var e = b[d]
          , f = a.jf(e.column)
          , g = a.getValue(c, f)
          , h = a.W(f);
        if (gvjs_Vd in e) {
            if (0 !== gvjs_vk(h, g, e.value))
                return !1
        } else if (null != e.minValue || null != e.maxValue)
            if (null == g || null != e.minValue && 0 > gvjs_vk(h, g, e.minValue) || null != e.maxValue && 0 < gvjs_vk(h, g, e.maxValue))
                return !1;
        e = e.test;
        if (null != e && typeof e === gvjs_d && !e(g, c, f, a))
            return !1
    }
    return !0
}
function gvjs_wk(a, b) {
    if (typeof b !== gvjs_d) {
        if (!Array.isArray(b) || 0 === b.length)
            throw Error("columnFilters must be a non-empty array");
        for (var c = [], d = 0, e = gvjs_8d(b), f = e.next(); !f.done; f = e.next()) {
            f = f.value;
            if (typeof f !== gvjs_h || !(gvjs_Fb in f)) {
                if (!(gvjs_Vd in f || gvjs_ed in f || gvjs_cd in f))
                    throw Error(gvjs_Gb + d + '] must have properties "column" and one of "value", "minValue" or "maxValue"');
                if (gvjs_Vd in f && (gvjs_ed in f || gvjs_cd in f))
                    throw Error(gvjs_Gb + d + '] must specify either "value" or range properties ("minValue" and/or "maxValue"');
            }
            var g = f.column;
            gvjs_xk(a, g);
            var h = a.jf(g);
            if (c[h])
                throw Error(gvjs_wa + g + " is duplicate in columnFilters.");
            gvjs_yk(a, h, f.value);
            c[h] = !0;
            d++
        }
    }
    c = [];
    d = a.ca();
    for (e = 0; e < d; e++)
        gvjs_$aa(a, b, e) && c.push(e);
    return c
}
function gvjs_zk(a, b, c) {
    if (typeof b === gvjs_h && gvjs_Fb in b) {
        if ("desc"in b && typeof b.desc !== gvjs_zb)
            throw Error('Property "desc" in ' + c + " must be boolean.");
        if (null != b.compare && typeof b.compare !== gvjs_d)
            throw Error('Property "compare" in ' + c + " must be a function.");
    } else
        throw Error(c + ' must be an object with a "column" property.');
    gvjs_xk(a, b.column)
}
function gvjs_Ak(a, b, c) {
    function d(l, m) {
        for (var n = 0; n < e.length; n++) {
            var p = e[n]
              , q = p.column
              , r = b(l, q)
              , t = b(m, q)
              , u = p.compare;
            q = null != u ? null === r ? null === t ? 0 : -1 : null === t ? 1 : u(r, t) : gvjs_vk(a.W(q), r, t);
            if (0 !== q)
                return q * (p.desc ? -1 : 1)
        }
        return 0
    }
    var e = [];
    if (typeof c === gvjs_d)
        d = c;
    else if (typeof c === gvjs_g || typeof c === gvjs_l)
        gvjs_xk(a, c),
        e = [{
            column: a.jf(c)
        }];
    else if (gvjs_r(c))
        if (Array.isArray(c)) {
            if (0 === c.length)
                throw Error("sortColumns is an empty array. Must have at least one element.");
            e = [];
            for (var f = [], g = 0, h = 0; h < c.length; h++) {
                g = c[h];
                if (typeof g === gvjs_g || typeof g === gvjs_l)
                    gvjs_xk(a, g),
                    g = a.jf(g),
                    e.push({
                        column: g
                    });
                else if (gvjs_r(g)) {
                    var k = g;
                    gvjs_zk(a, k, "sortColumns[" + h + "]");
                    g = k.column;
                    g = a.jf(g);
                    k.column = g;
                    e.push(k)
                } else
                    throw Error("sortColumns is an array, but not composed of only objects or numbers.");
                if (g in f)
                    throw Error("Column index " + g + " is duplicated in sortColumns.");
                f[g] = !0
            }
        } else
            gvjs_zk(a, c, "sortColumns"),
            e = [c];
    return d
}
function gvjs_vk(a, b, c) {
    if (null == b)
        return null == c ? 0 : -1;
    if (null == c)
        return 1;
    if (a === gvjs_Od) {
        for (a = 0; 3 > a; a++) {
            if (b[a] < c[a])
                return -1;
            if (c[a] < b[a])
                return 1
        }
        b = 4 > b.length ? 0 : b[3];
        c = 4 > c.length ? 0 : c[3];
        return b < c ? -1 : c < b ? 1 : 0
    }
    return b < c ? -1 : c < b ? 1 : 0
}
function gvjs_Bk(a, b) {
    b = gvjs_Ak(a, function(f, g) {
        return a.getValue(f, g)
    }, b);
    for (var c = [], d = a.ca(), e = 0; e < d; e++)
        c.push(e);
    gvjs_Se(c, b);
    return c
}
function gvjs_Ck(a, b) {
    a = a.ca();
    if (0 < a) {
        if (Math.floor(b) !== b || 0 > b || b >= a)
            throw Error("Invalid row index " + b + ". Should be in the range [0-" + (a - 1 + "]."));
    } else
        throw Error("Table has no rows.");
}
function gvjs_xk(a, b) {
    if (typeof b === gvjs_g)
        gvjs_Dk(a, b);
    else {
        if (typeof b !== gvjs_l)
            throw Error("Column reference " + b + " must be a number or string");
        if (-1 === a.jf(b))
            throw Error('Invalid column id "' + b + '"');
    }
}
function gvjs_Dk(a, b) {
    a = a.$();
    if (0 < a) {
        if (Math.floor(b) !== b || 0 > b || b >= a)
            throw Error("Invalid column index " + b + ".  Should be an integer in the range [0-" + (a - 1 + "]."));
    } else
        throw Error("Table has no columns.");
}
function gvjs_yk(a, b, c) {
    a = a.W(b);
    if (!gvjs_Ek(c, a))
        throw Error(gvjs_jb + c + gvjs_aa + a + (" in column index " + b));
}
function gvjs_Ek(a, b) {
    if (null == a)
        return !0;
    var c = typeof a;
    switch (b) {
    case gvjs_g:
        if (c === gvjs_g)
            return !0;
        break;
    case gvjs_l:
        if (c === gvjs_l)
            return !0;
        break;
    case gvjs_zb:
        if (c === gvjs_zb)
            return !0;
        break;
    case gvjs_d:
        if (c === gvjs_d)
            return !0;
        break;
    case gvjs_Lb:
    case gvjs_Mb:
        if (gvjs_oe(a))
            return !0;
        break;
    case gvjs_Od:
        if (Array.isArray(a) && 0 < a.length && 8 > a.length) {
            b = !0;
            for (c = 0; c < a.length; c++) {
                var d = a[c];
                if (typeof d !== gvjs_g || d !== Math.floor(d)) {
                    b = !1;
                    break
                }
            }
            if (b)
                return !0
        }
    }
    return !1
}
function gvjs_Fk(a, b) {
    gvjs_xk(a, b);
    b = a.jf(b);
    var c = a.W(b), d = null, e = null, f, g = a.ca();
    for (f = 0; f < g; f++) {
        var h = a.getValue(f, b);
        if (null != h) {
            e = d = h;
            break
        }
    }
    if (null == d)
        return {
            min: null,
            max: null
        };
    for (f++; f < g; f++)
        h = a.getValue(f, b),
        null != h && (0 > gvjs_vk(c, h, d) ? d = h : 0 > gvjs_vk(c, e, h) && (e = h));
    return {
        min: d,
        max: e
    }
}
function gvjs_Gk(a, b) {
    gvjs_xk(a, b);
    var c = a.jf(b)
      , d = a.ca();
    if (0 === d)
        return [];
    b = [];
    for (var e = 0; e < d; ++e)
        b.push(a.getValue(e, c));
    var f = a.W(c);
    gvjs_Se(b, function(g, h) {
        return gvjs_vk(f, g, h)
    });
    a = b[0];
    c = [];
    c.push(a);
    for (d = 1; d < b.length; d++)
        e = b[d],
        0 !== gvjs_vk(f, e, a) && c.push(e),
        a = e;
    return c
}
function gvjs_Hk(a, b, c) {
    if (null == a)
        return "";
    if (c)
        return c.Ob(a);
    switch (b) {
    case gvjs_Od:
        if (!(a instanceof Array))
            throw Error("Type of value, " + a + ", is not timeofday");
        b = new Date(1970,0,1,a[0],a[1],a[2],a[3] || 0);
        c = gvjs_Ia;
        if (a[2] || a[3])
            c += ":ss";
        a[3] && (c += ".SSS");
        c = new gvjs_Tj({
            pattern: c
        });
        a = c.Ob(b);
        break;
    case gvjs_Lb:
        c = new gvjs_Tj({
            formatType: gvjs_dd,
            valueType: gvjs_Lb
        });
        a = c.Ob(a);
        break;
    case gvjs_Mb:
        c = new gvjs_Tj({
            formatType: gvjs_dd,
            valueType: gvjs_Mb
        });
        a = c.Ob(a);
        break;
    case gvjs_g:
        c = new gvjs_gk({
            pattern: gvjs_Nb
        });
        a = c.Ob(a);
        break;
    default:
        a = null != a ? String(a) : ""
    }
    return a
}
function gvjs_aba(a) {
    switch (a) {
    case gvjs_Od:
        return new gvjs_tk;
    case gvjs_Lb:
        return new gvjs_Tj;
    case gvjs_Mb:
        return new gvjs_Tj({
            formatType: gvjs_dd,
            valueType: gvjs_Mb
        });
    case gvjs_g:
        return new gvjs_gk({
            pattern: gvjs_Nb
        });
    default:
        return new gvjs_nk
    }
}
function gvjs_Ik(a, b, c) {
    var d = a.W(b);
    if (null == c)
        c = gvjs_aba(d);
    else if (null == c.Jo(d))
        return;
    d = c.Jo(d);
    d = c.dv(d);
    for (var e = a.ca(), f = 0; f < e; f++) {
        var g = a.getValue(f, b);
        g = c.QY(d, g);
        a.Nw(f, b, g)
    }
}
function gvjs_Jk(a, b, c, d) {
    for (var e = null, f = a.ca(); (d ? 0 <= b : b < f) && null === e; )
        e = a.getValue(b, c),
        b += d ? -1 : 1;
    return e
}
function gvjs_Kk(a) {
    if (!a)
        throw Error("Data table is not defined.");
    if (!(a instanceof gvjs_Ai)) {
        var b = "the wrong type of data";
        Array.isArray(a) ? b = "an Array" : typeof a === gvjs_l && (b = "a String");
        throw Error("You called the draw() method with " + b + " rather than a DataTable or DataView");
    }
}
;var gvjs_bba = {
    UBa: "0.5",
    VBa: "0.6"
};
function gvjs_M(a, b) {
    gvjs_Ai.call(this);
    this.bf = [];
    this.Wf = [];
    this.Br = null;
    this.cache = [];
    if (typeof this.Cv !== gvjs_d)
        throw Error('You called google.visualization.DataTable() without the "new" keyword');
    this.version = "0.5" === b ? "0.5" : "0.6";
    if (null != a) {
        if (typeof a === gvjs_l)
            a = gvjs_Li(a);
        else
            a: {
                b = a.cols || [];
                for (var c = a.rows || [], d = b.length, e = 0; e < d; e++) {
                    var f = b[e].type;
                    if (f === gvjs_Lb || f === gvjs_Mb) {
                        f = c.length;
                        for (var g = 0; g < f; g++) {
                            var h = c[g].c[e];
                            if (h) {
                                var k = h.v;
                                if (gvjs_oe(k))
                                    break a;
                                typeof k === gvjs_l && (h = gvjs_Ii(h),
                                h = gvjs_Li(h),
                                c[g].c[e] = h)
                            }
                        }
                    }
                }
            }
        this.Br = a.p || null;
        if (null != a.cols)
            for (b = gvjs_8d(a.cols),
            c = b.next(); !c.done; c = b.next())
                this.xd(c.value);
        null != a.rows && (this.Wf = a.rows)
    } else
        this.bf = [],
        this.Wf = [],
        this.Br = null;
    this.cache = []
}
gvjs_o(gvjs_M, gvjs_Ai);
gvjs_ = gvjs_M.prototype;
gvjs_.ca = function() {
    return this.Wf.length
}
;
gvjs_.$ = function() {
    return this.bf.length
}
;
gvjs_.Do = gvjs_n(20);
gvjs_.Ne = function(a) {
    gvjs_Dk(this, a);
    return this.bf[a].id || ""
}
;
gvjs_.Ga = function(a) {
    gvjs_Dk(this, a);
    return String(this.bf[a].label || "")
}
;
gvjs_.Co = function(a) {
    gvjs_Dk(this, a);
    a = this.bf[a].pattern;
    return "undefined" !== typeof a ? a : null
}
;
gvjs_.Jg = function(a) {
    a = this.Bd(a, gvjs_Bd);
    return typeof a === gvjs_l ? a : ""
}
;
gvjs_.W = function(a) {
    gvjs_Dk(this, a);
    a = this.bf[a].type;
    return "undefined" !== typeof a ? a : gvjs_l
}
;
gvjs_.getValue = function(a, b) {
    gvjs_Ck(this, a);
    gvjs_Dk(this, b);
    a = this.si(a, b);
    b = null;
    a && (b = a.v,
    b = "undefined" !== typeof b ? b : null);
    return b
}
;
gvjs_.si = function(a, b) {
    return this.Wf[a].c[b]
}
;
gvjs_.Ha = function(a, b, c) {
    gvjs_Ck(this, a);
    gvjs_Dk(this, b);
    var d = this.si(a, b)
      , e = "";
    if (d)
        if (null != d.f)
            e = String(d.f);
        else {
            this.cache[a] = this.cache[a] || [];
            var f = this.cache[a];
            d = f[b] || {};
            f[b] = d;
            "undefined" !== typeof d.Me ? e = d.Me : (a = this.getValue(a, b),
            null !== a && (e = gvjs_Hk(a, this.W(b), c),
            null == e && (e = void 0)),
            d.Me = e)
        }
    return null == e ? "" : e.toString()
}
;
gvjs_.format = function(a, b) {
    gvjs_Ik(this, a, b)
}
;
gvjs_.getProperty = function(a, b, c) {
    gvjs_Ck(this, a);
    gvjs_Dk(this, b);
    return (a = (a = this.si(a, b)) && a.p) && c in a ? a[c] : null
}
;
gvjs_.getProperties = function(a, b) {
    gvjs_Ck(this, a);
    gvjs_Dk(this, b);
    var c = this.si(a, b);
    c || (c = {
        v: null
    },
    this.Wf[a].c[b] = c);
    c.p || (c.p = {});
    return c.p
}
;
gvjs_.Cv = function() {
    return this.Br
}
;
gvjs_.Sy = function(a) {
    var b = this.Br;
    return b && a in b ? b[a] : null
}
;
gvjs_.Hwa = function(a) {
    this.Br = a || {}
}
;
gvjs_.Iwa = function(a, b) {
    null == this.Br && (this.Br = {});
    this.Br[a] = b
}
;
gvjs_.Wa = function(a, b, c) {
    this.Wb(a, b, c, void 0, void 0)
}
;
gvjs_.Nw = function(a, b, c) {
    this.Wb(a, b, void 0, c, void 0)
}
;
gvjs_.sr = function(a, b, c) {
    this.Wb(a, b, void 0, void 0, c)
}
;
gvjs_.setProperty = function(a, b, c, d) {
    this.getProperties(a, b)[c] = d
}
;
gvjs_.Wb = function(a, b, c, d, e) {
    gvjs_Ck(this, a);
    gvjs_Dk(this, b);
    var f = this.cache[a];
    f && f[b] && (f[b] = {});
    f = this.si(a, b);
    f || (f = {},
    this.Wf[a].c[b] = f);
    "undefined" !== typeof c && (this.W(b) !== gvjs_g || typeof c !== gvjs_l || isNaN(c) ? (gvjs_yk(this, b, c),
    f.v = c) : f.v = Number(c));
    "undefined" !== typeof d && (f.f = d);
    "undefined" !== typeof e && (f.p = gvjs_r(e) ? e : {})
}
;
gvjs_.Gwa = function(a, b) {
    gvjs_Ck(this, a);
    this.Wf[a].p = b
}
;
gvjs_.Gfa = function(a, b, c) {
    this.zv(a)[b] = c
}
;
gvjs_.Ul = function(a, b) {
    gvjs_Ck(this, a);
    return (a = (a = this.Wf[a]) && a.p) && b in a ? a[b] : null
}
;
gvjs_.zv = function(a) {
    gvjs_Ck(this, a);
    a = this.Wf[a];
    a.p || (a.p = {});
    return a.p
}
;
gvjs_.xfa = function(a, b) {
    gvjs_Dk(this, a);
    this.bf[a].label = b
}
;
gvjs_.lT = function(a, b) {
    gvjs_Dk(this, a);
    this.bf[a].p = b
}
;
gvjs_.rA = function(a, b, c) {
    this.Rj(a)[b] = c
}
;
gvjs_.Bd = function(a, b) {
    gvjs_Dk(this, a);
    return (a = (a = this.bf[a]) && a.p) && b in a ? a[b] : null
}
;
gvjs_.Rj = function(a) {
    gvjs_Dk(this, a);
    a = this.bf[a];
    a.p || (a.p = {});
    return a.p
}
;
gvjs_.uba = function(a, b, c, d) {
    a !== this.bf.length && (this.cache = [],
    gvjs_Dk(this, a));
    if (typeof b === gvjs_l) {
        var e = b;
        c = c || "";
        d = d || "";
        b = {
            id: d,
            label: c,
            pattern: "",
            type: e
        }
    }
    if (!gvjs_r(b))
        throw Error("Invalid column specification, " + b + gvjs_ia + a + '".');
    gvjs_8c in b && (c = b.label);
    gvjs_5c in b && (d = b.id);
    c = c || d || a;
    gvjs_Sd in b && (e = b.type);
    null == e && (e = gvjs_l);
    if (!Object.values(gvjs_zi).includes(e))
        throw Error("Invalid type, " + e + gvjs_ia + c + '".');
    b = Object.assign(Object.assign({}, b), {
        type: e
    });
    if (e = b.role)
        c = b.p || {},
        null == c.role && (c.role = e,
        b.p = c);
    this.bf.splice(a, 0, b);
    this.cq = null;
    for (b = 0; b < this.Wf.length; b++)
        this.Wf[b].c.splice(a, 0, {
            v: null
        })
}
;
gvjs_.xd = function(a, b, c) {
    this.uba(this.bf.length, a, b, c);
    return this.bf.length - 1
}
;
gvjs_.G_ = function(a, b) {
    a !== this.Wf.length && (this.cache = [],
    gvjs_Ck(this, a));
    if (Array.isArray(b))
        var c = b;
    else if (typeof b === gvjs_g) {
        if (b !== Math.floor(b) || 0 > b)
            throw Error(gvjs_Ta + b + ". If numOrArray is a number it must be a nonnegative integer.");
        c = gvjs_Te(null, b)
    } else
        throw Error(gvjs_Ta + b + ".Must be a non-negative number or an array of arrays of cells.");
    b = [];
    for (var d = 0; d < c.length; d++) {
        var e = c[d]
          , f = [];
        if (null === e)
            for (e = 0; e < this.bf.length; e++)
                f.push({
                    v: null
                });
        else if (Array.isArray(e)) {
            if (e.length !== this.bf.length)
                throw Error("Row " + d + " given with size different than " + this.bf.length + " (the number of columns in the table).");
            for (var g = 0; g < e.length; g++) {
                var h = f
                  , k = h.push
                  , l = g
                  , m = gvjs_uk(e[g]);
                gvjs_yk(this, l, m.v);
                k.call(h, m)
            }
        } else
            throw Error("Row " + d + " is not null or an array.");
        b.push({
            c: f
        });
        1E4 === b.length && (f = b,
        gvjs_re(gvjs_Ne, this.Wf, a, 0).apply(null, f),
        a += b.length,
        b = [])
    }
    c = b;
    gvjs_re(gvjs_Ne, this.Wf, a, 0).apply(null, c);
    return a + b.length - 1
}
;
gvjs_.Yn = function(a) {
    if (typeof a === gvjs_g || Array.isArray(a))
        return this.G_(this.Wf.length, a);
    throw Error("Argument given to addRows must be either a number or an array");
}
;
gvjs_.Kp = function(a) {
    if (Array.isArray(a))
        return this.Yn([a]);
    if (null == a)
        return this.Yn(1);
    throw Error("If argument is given to addRow, it must be an array, or null");
}
;
gvjs_.Sj = function(a) {
    return gvjs_Fk(this, a)
}
;
gvjs_.bn = function(a) {
    return gvjs_Bk(this, a)
}
;
gvjs_.sort = function(a) {
    this.cache = [];
    a = gvjs_Ak(this, function(b, c) {
        b = b.c[c];
        return null != b && typeof b === gvjs_h && "v"in b ? b.v : null
    }, a);
    gvjs_Se(this.Wf, a)
}
;
gvjs_.fj = function(a) {
    return a
}
;
gvjs_.Ty = function(a) {
    gvjs_Dk(this, a);
    return a
}
;
gvjs_.Uy = function(a) {
    gvjs_Ck(this, a);
    return a
}
;
gvjs_.Gr = function() {
    return this.clone()
}
;
gvjs_.clone = function() {
    return new gvjs_M(this.Bp())
}
;
gvjs_.Bp = function() {
    var a = {
        cols: this.bf,
        rows: this.Wf
    };
    this.Br && (a.p = this.Br);
    return gvjs_Ji(a, gvjs_Ki)
}
;
gvjs_.toJSON = function() {
    for (var a = 0; a < this.bf.length; a++)
        if (this.W(a) === gvjs_d)
            throw Error("Cannot get JSON representation of data table due to function data type at column " + a);
    return gvjs_Hi(this.Bp())
}
;
gvjs_.Py = function(a) {
    return gvjs_Gk(this, a)
}
;
gvjs_.at = function(a) {
    return gvjs_wk(this, a)
}
;
gvjs_.Iea = function(a, b) {
    0 >= b || (this.cache = [],
    gvjs_Ck(this, a),
    a + b > this.Wf.length && (b = this.Wf.length - a),
    this.Wf.splice(a, b))
}
;
gvjs_.qE = function(a) {
    this.Iea(a, 1)
}
;
gvjs_.Hea = function(a, b) {
    if (!(0 >= b)) {
        this.cache = [];
        gvjs_Dk(this, a);
        a + b > this.bf.length && (b = this.bf.length - a);
        this.bf.splice(a, b);
        this.cq = null;
        for (var c = 0; c < this.Wf.length; c++)
            this.Wf[c].c.splice(a, b)
    }
}
;
gvjs_.BS = function(a) {
    this.Hea(a, 1)
}
;
function gvjs_Lk(a) {
    return null == a ? null : a instanceof gvjs_Ai ? a : Array.isArray(a) ? gvjs_Mk(a) : new gvjs_M(a)
}
function gvjs_cba(a, b) {
    if (b) {
        if (!Array.isArray(a))
            throw Error("Column header row must be an array.");
        b = a.map(function(d) {
            if (typeof d === gvjs_l)
                return {
                    label: d
                };
            if (gvjs_r(d))
                return gvjs_x(d);
            throw Error("Unknown type of column header: " + d);
        })
    } else {
        b = [];
        var c = 0;
        Array.isArray(a) ? c = a.length : gvjs_r(a) && gvjs_Ze(a, "c") && Array.isArray(a.c) && (c = a.c.length);
        for (a = 0; a < c; a++)
            b.push({
                type: void 0
            })
    }
    return b
}
function gvjs_Mk(a, b) {
    if (!Array.isArray(a))
        throw Error("Data for arrayToDataTable is not an array.");
    if (0 === a.length)
        b = new gvjs_M;
    else {
        var c = !b;
        if (0 === a.length)
            throw Error("Array of rows must be non-empty");
        b = gvjs_cba(a[0], c);
        var d = [];
        for (c = c ? 1 : 0; c < a.length; c++) {
            var e = void 0
              , f = a[c]
              , g = c;
            if (Array.isArray(f))
                var h = f;
            else if (gvjs_r(f) && gvjs_Ze(f, "c"))
                h = f.c,
                e = f.p;
            else
                throw Error("Invalid row #" + g);
            if (h.length !== b.length)
                throw Error("Row " + g + " has " + h.length + " columns, but must have " + b.length);
            h = gvjs_Le(h);
            e = {
                c: h,
                p: e
            };
            for (f = 0; f < b.length; f++)
                if (g = h[f],
                gvjs_r(g) && (gvjs_Ze(g, "v") || gvjs_Ze(g, "f")) ? g = g.v : h[f] = {
                    v: g
                },
                null == b[f].type || "date?" === b[f].type) {
                    var k = null;
                    if (null != g)
                        if (typeof g === gvjs_l)
                            k = gvjs_l;
                        else if (typeof g === gvjs_g)
                            k = gvjs_g;
                        else if (Array.isArray(g))
                            k = gvjs_Od;
                        else if (typeof g === gvjs_zb)
                            k = gvjs_zb;
                        else if (gvjs_oe(g))
                            g = new Date(g.getTime()),
                            k = 0 !== g.getHours() + g.getMinutes() + g.getSeconds() + g.getMilliseconds() ? gvjs_Mb : gvjs_Lb;
                        else
                            throw Error("Unknown type of value, " + g);
                    g = k;
                    null == b[f].type && g === gvjs_Lb && (g = "date?");
                    null != g && (b[f].type = g)
                }
            d.push(e)
        }
        for (a = 0; a < b.length; a++)
            c = b[a],
            "date?" === c.type && (c.type = gvjs_Lb);
        b = new gvjs_M({
            cols: b,
            rows: d
        })
    }
    return b
}
function gvjs_Nk(a) {
    function b(k) {
        for (var l = Object.keys(k), m = l.length, n = Array(m); m--; )
            n[m] = [l[m], k[l[m]]];
        return n
    }
    for (var c = {}, d = 0, e = gvjs_8d(a), f = e.next(); !f.done; f = e.next()) {
        f = gvjs_8d(b(f.value));
        for (var g = f.next(); !g.done; g = f.next()) {
            g = gvjs_8d(g.value);
            var h = g.next().value;
            g.next();
            c[h] || (c[h] = {
                id: h,
                index: d++
            })
        }
    }
    d = [];
    e = [];
    f = gvjs_8d(b(c));
    for (g = f.next(); !g.done; g = f.next())
        h = gvjs_8d(g.value),
        g = h.next().value,
        h = h.next().value,
        e[h.index] = {
            id: g
        };
    d.unshift(e);
    a = gvjs_8d(a);
    for (f = a.next(); !f.done; f = a.next())
        for (f = f.value,
        e = [],
        d.push(e),
        f = gvjs_8d(b(f)),
        g = f.next(); !g.done; g = f.next())
            h = gvjs_8d(g.value),
            g = h.next().value,
            h = h.next().value,
            e[c[g].index] = h;
    return gvjs_Mk(d)
}
function gvjs_dba(a) {
    a = a.map(function(b) {
        return {
            data: b
        }
    });
    return gvjs_Nk(a)
}
;function gvjs_N(a) {
    gvjs_Ai.call(this);
    this.Ta = a;
    this.columns = [];
    this.Fq = !0;
    this.ir = null;
    this.yW = [];
    this.vW = !0;
    var b = [];
    a = a.$();
    for (var c = 0; c < a; c++)
        b.push(c);
    this.columns = b
}
gvjs_o(gvjs_N, gvjs_Ai);
gvjs_ = gvjs_N.prototype;
gvjs_.mb = function() {
    return this.Ta
}
;
function gvjs_eba(a, b, c) {
    return gvjs_v(c, function(d) {
        if (typeof d === gvjs_l)
            d = a.jf(d);
        else if (gvjs_r(d)) {
            d = gvjs_0e(d);
            var e = d.properties || {};
            delete d.properties;
            d.p = e;
            var f = d.role;
            f && (e.role = f);
            e = d.sourceColumn;
            typeof e === gvjs_l && (e = d.sourceColumn = a.jf(e));
            typeof e === gvjs_g && (gvjs_Dk(b, e),
            d.calc = d.calc || "identity",
            d.type = d.type || b.W(e))
        }
        return d
    })
}
function gvjs_Ok(a) {
    a.vW = !0;
    a.cq = null
}
function gvjs_fba(a) {
    for (var b = [], c = a.Ta.ca(), d = 0; d < c; d++)
        b.push(d);
    a.ir = b;
    gvjs_Ok(a)
}
gvjs_.Hn = function(a) {
    for (var b = this.Ta, c = gvjs_Ye(gvjs_Pk), d = 0; d < a.length; d++) {
        var e = a[d];
        if (typeof e === gvjs_g || typeof e === gvjs_l)
            gvjs_xk(b, e);
        else if (gvjs_r(e)) {
            var f = e.sourceColumn
              , g = e.calc;
            if (typeof g === gvjs_l) {
                if (!c || c && !gvjs_He(c, g))
                    throw Error('Unknown function "' + g + '"');
                null != f && gvjs_xk(b, f)
            } else if (null != g && !e.type)
                throw Error('Calculated column must have a "type" property.');
        } else
            throw Error("Invalid column input, expected either a number, string, or an object.");
    }
    this.columns = gvjs_eba(this, this.Ta, a);
    gvjs_Ok(this)
}
;
gvjs_.Do = gvjs_n(19);
function gvjs_Qk(a, b, c) {
    if (Array.isArray(b)) {
        if (void 0 !== c)
            throw Error("If the first parameter is an array, no second parameter is expected");
        for (c = 0; c < b.length; c++)
            gvjs_Ck(a.Ta, b[c]);
        return gvjs_Le(b)
    }
    if (typeof b === gvjs_g) {
        if (typeof c !== gvjs_g)
            throw Error("If first parameter is a number, second parameter must be specified and be a number.");
        if (b > c)
            throw Error("The first parameter (min) must be smaller than or equal to the second parameter (max).");
        gvjs_Ck(a.Ta, b);
        gvjs_Ck(a.Ta, c);
        for (a = []; b <= c; b++)
            a.push(b);
        return a
    }
    throw Error("First parameter must be a number or an array.");
}
gvjs_.pp = function(a, b) {
    this.ir = gvjs_Qk(this, a, b);
    this.Fq = !1;
    gvjs_Ok(this)
}
;
gvjs_.FZ = function() {
    return gvjs_0e(this.columns)
}
;
gvjs_.T$ = function() {
    if (this.Fq) {
        for (var a = [], b = this.Ta.ca(), c = 0; c < b; c++)
            a.push(c);
        return a
    }
    return gvjs_Le(this.ir)
}
;
gvjs_.ora = function(a) {
    this.Hn(gvjs_De(this.columns, function(b) {
        return !gvjs_He(a, b)
    }));
    gvjs_Ok(this)
}
;
gvjs_.qra = function(a, b) {
    var c = gvjs_Qk(this, a, b);
    this.Fq && (gvjs_fba(this),
    this.Fq = !1);
    this.pp(gvjs_De(this.ir, function(d) {
        return !gvjs_He(c, d)
    }));
    gvjs_Ok(this)
}
;
gvjs_.S$ = function(a) {
    for (var b = 0; b < this.columns.length; b++) {
        var c = this.columns[b];
        if (c === a || gvjs_r(c) && c.sourceColumn === a)
            return b
    }
    return -1
}
;
gvjs_.GZ = function(a) {
    return this.Fq ? 0 > a || a >= this.Ta.ca() ? -1 : a : gvjs_Be(this.ir, a)
}
;
gvjs_.CP = function(a) {
    gvjs_Dk(this, a);
    a = this.columns[a];
    return typeof a === gvjs_g ? a : gvjs_r(a) && typeof a.sourceColumn === gvjs_g ? a.sourceColumn : -1
}
;
gvjs_.Ty = function(a) {
    a = this.CP(a);
    return -1 === a ? a : a = this.Ta.Ty(a)
}
;
gvjs_.fj = function(a) {
    gvjs_Ck(this, a);
    return this.Fq ? a : this.ir[a]
}
;
gvjs_.Uy = function(a) {
    a = this.fj(a);
    return a = this.Ta.Uy(a)
}
;
gvjs_.ca = function() {
    return this.Fq ? this.Ta.ca() : this.ir.length
}
;
gvjs_.$ = function() {
    return this.columns.length
}
;
gvjs_.Ne = function(a) {
    gvjs_Dk(this, a);
    a = this.columns[a];
    return typeof a === gvjs_g ? this.Ta.Ne(a) : a.id || ""
}
;
gvjs_.Ga = function(a) {
    gvjs_Dk(this, a);
    a = this.columns[a];
    return typeof a === gvjs_g ? this.Ta.Ga(a) : a.label || ""
}
;
gvjs_.Co = function(a) {
    gvjs_Dk(this, a);
    a = this.columns[a];
    return typeof a === gvjs_g ? this.Ta.Co(a) : null
}
;
gvjs_.Jg = function(a) {
    a = this.Bd(a, gvjs_Bd);
    return typeof a === gvjs_l ? a : ""
}
;
gvjs_.W = function(a) {
    gvjs_Dk(this, a);
    a = this.columns[a];
    return typeof a === gvjs_g ? this.Ta.W(a) : a.type
}
;
gvjs_.si = function(a, b) {
    gvjs_Dk(this, b);
    var c = this.columns[b]
      , d = null;
    a = this.fj(a);
    if (gvjs_r(c)) {
        if (this.vW) {
            for (c = 0; c < this.columns.length; c++)
                gvjs_r(this.columns[c]) && (this.yW[c] = []);
            this.vW = !1
        }
        c = this.yW[b][a];
        if (void 0 !== c)
            d = c;
        else {
            c = null;
            d = this.columns[b];
            var e = d.calc;
            if (typeof e === gvjs_l) {
                c = gvjs_Pk[e];
                if (typeof d !== gvjs_h)
                    throw Error("Object expected for column " + d);
                c = c(this.Ta, a, d)
            } else
                typeof e === gvjs_d && (c = e.call(null, this.Ta, a));
            c = gvjs_uk(c);
            d = d.type;
            e = c.v;
            if (gvjs_jf(gvjs_gg(d)))
                throw Error('"type" must be specified');
            if (!gvjs_Ek(e, d))
                throw Error(gvjs_jb + e + gvjs_aa + d + ".");
            d = this.yW[b][a] = c
        }
        d.p = gvjs_r(d.p) ? d.p : {}
    } else if (typeof c === gvjs_g)
        d = {
            v: this.Ta.getValue(a, c)
        };
    else
        throw Error("Invalid column definition: " + d + ".");
    return d
}
;
gvjs_.getValue = function(a, b) {
    return this.si(a, b).v
}
;
gvjs_.Ha = function(a, b, c) {
    var d = this.si(a, b);
    if (null == d.f) {
        var e = this.columns[b];
        gvjs_r(e) ? (e = this.W(b),
        d.f = null == d.v ? "" : gvjs_Hk(d.v, e, c)) : typeof e === gvjs_g && (a = this.fj(a),
        d.f = this.Ta.Ha(a, e, c))
    }
    c = d.f;
    return null == c ? "" : c.toString()
}
;
gvjs_.Nw = function() {}
;
gvjs_.format = function(a, b) {
    gvjs_Ik(this, a, b)
}
;
gvjs_.getProperty = function(a, b, c) {
    a = this.getProperties(a, b)[c];
    return void 0 !== a ? a : null
}
;
gvjs_.getProperties = function(a, b) {
    var c = this.si(a, b);
    return c.p ? c.p : (a = this.fj(a),
    b = this.CP(b),
    this.Ta.getProperties(a, b))
}
;
gvjs_.setProperty = function() {}
;
gvjs_.Bd = function(a, b) {
    gvjs_Dk(this, a);
    var c = this.columns[a];
    return typeof c === gvjs_g ? this.Ta.Bd(c, b) : this.Rj(a)[b] || null
}
;
gvjs_.Rj = function(a) {
    gvjs_Dk(this, a);
    a = this.columns[a];
    return typeof a === gvjs_g ? this.Ta.Rj(a) : a.p || {}
}
;
gvjs_.Sy = function(a) {
    return this.Ta.Sy(a)
}
;
gvjs_.Cv = function() {
    return this.Ta.Cv()
}
;
gvjs_.Ul = function(a, b) {
    a = this.fj(a);
    return this.Ta.Ul(a, b)
}
;
gvjs_.zv = function(a) {
    gvjs_Ck(this, a);
    a = this.fj(a);
    return this.Ta.zv(a)
}
;
gvjs_.Sj = function(a) {
    return gvjs_Fk(this, a)
}
;
gvjs_.Py = function(a) {
    return gvjs_Gk(this, a)
}
;
gvjs_.bn = function(a) {
    return gvjs_Bk(this, a)
}
;
gvjs_.at = function(a) {
    return gvjs_wk(this, a)
}
;
gvjs_.Gr = function() {
    var a = this.Ta;
    typeof a.Gr === gvjs_d && (a = a.Gr());
    a = a.Bp();
    var b = this.$(), c = this.ca(), d, e = [], f = [];
    for (d = 0; d < b; d++) {
        var g = this.columns[d];
        if (gvjs_r(g)) {
            var h = gvjs_x(g);
            delete h.calc;
            delete h.sourceColumn
        } else if (typeof g === gvjs_g)
            h = (a.cols || [])[g];
        else
            throw Error(gvjs_Ra);
        e.push(h)
    }
    if (!this.Fq && null == this.ir)
        throw Error("Unexpected state of rowIndices");
    var k = a.rows || [];
    for (h = 0; h < c; h++) {
        var l = k[this.Fq ? h : this.ir[h]]
          , m = [];
        for (d = 0; d < b; d++) {
            g = this.columns[d];
            if (gvjs_r(g))
                g = {
                    v: this.getValue(h, d)
                };
            else if (typeof g === gvjs_g)
                g = l.c[g];
            else
                throw Error(gvjs_Ra);
            m.push(g)
        }
        l.c = m;
        f.push(l)
    }
    a.cols = e;
    a.rows = f;
    return new gvjs_M(a)
}
;
gvjs_.Bp = function() {
    for (var a = {}, b = [], c = 0; c < this.columns.length; c++) {
        var d = this.columns[c];
        gvjs_r(d) && typeof d.calc !== gvjs_l || b.push(d)
    }
    0 == b.length || (a.columns = b);
    this.Fq || (a.rows = gvjs_Le(this.ir));
    return a
}
;
gvjs_.toJSON = function() {
    return gvjs_Ii(this.Bp())
}
;
function gvjs_Rk(a, b) {
    typeof b === gvjs_l && (b = gvjs_Li(b));
    a = new gvjs_N(a);
    var c = b.columns;
    b = b.rows;
    null != c && a.Hn(c);
    null != b && a.pp(b);
    return a
}
var gvjs_Pk = {
    emptyString: function() {
        return ""
    },
    error: function(a, b, c) {
        var d = c.sourceColumn
          , e = c.magnitude;
        if (typeof d !== gvjs_g || typeof e !== gvjs_g)
            return null;
        a = a.getValue(b, d);
        return typeof a !== gvjs_g ? null : c.errorType === gvjs_ud ? a + e / 100 * a : a + e
    },
    mapFromSource: function(a, b, c) {
        var d = c.sourceColumn;
        c = c.mapping;
        return typeof d === gvjs_g && c && (a = a.getValue(b, d),
        typeof a === gvjs_l) ? a in c ? c[a] : null : null
    },
    stringify: function(a, b, c) {
        c = c.sourceColumn;
        return typeof c !== gvjs_g ? "" : a.Ha(b, c)
    },
    fillFromTop: function(a, b, c) {
        c = c.sourceColumn;
        return typeof c !== gvjs_g ? null : gvjs_Jk(a, b, c, !0)
    },
    fillFromBottom: function(a, b, c) {
        c = c.sourceColumn;
        return typeof c !== gvjs_g ? null : gvjs_Jk(a, b, c, !1)
    },
    identity: function(a, b, c) {
        c = c.sourceColumn;
        return typeof c !== gvjs_g ? null : a.getValue(b, c)
    }
};
function gvjs_Sk(a) {
    this.Ta = this.m4 = null;
    this.errors = [];
    this.warnings = [];
    this.Lva = gvjs_Tk(a);
    this.DY = a.status;
    this.warnings = a.warnings || [];
    this.errors = a.errors || [];
    gvjs_Uk(this.warnings);
    gvjs_Uk(this.errors);
    this.DY !== gvjs_Rb && (this.m4 = a.sig,
    this.Ta = new gvjs_M(a.table,this.Lva))
}
function gvjs_Uk(a) {
    for (var b = 0; b < a.length; b++) {
        var c = a[b].detailed_message;
        c && (a[b].detailed_message = c ? c.match(gvjs_gba) && !c.match(gvjs_hba) ? c : c.replace(/&/g, "&amp;").replace(/</g, gvjs_fa).replace(/>/g, "&gt;").replace(/"/g, gvjs_ga) : "")
    }
}
function gvjs_Tk(a) {
    a = a.version || "0.6";
    return gvjs__e(gvjs_bba, a) ? a : "0.6"
}
gvjs_ = gvjs_Sk.prototype;
gvjs_.Xk = function() {
    return this.DY === gvjs_Rb
}
;
gvjs_.j_ = function() {
    return this.DY === gvjs_Wd
}
;
function gvjs_Vk(a) {
    for (var b = 0; b < a.errors.length; b++)
        if ("not_modified" === a.errors[b].reason)
            return !0;
    for (b = 0; b < a.warnings.length; b++)
        if ("not_modified" === a.warnings[b].reason)
            return !0;
    return !1
}
gvjs_.mb = function() {
    return this.Ta
}
;
function gvjs_Wk(a, b) {
    return a.Xk() && a.errors && a.errors[0] && a.errors[0][b] ? a.errors[0][b] : a.j_() && a.warnings && a.warnings[0] && a.warnings[0][b] ? a.warnings[0][b] : null
}
gvjs_.Q$ = function() {
    var a = gvjs_Wk(this, "reason");
    return null != a && "" !== a ? [a] : []
}
;
gvjs_.sP = function() {
    return gvjs_Wk(this, "message") || ""
}
;
gvjs_.nZ = function() {
    return gvjs_Wk(this, "detailed_message") || ""
}
;
function gvjs_Xk(a, b) {
    (0,
    gvjs_D.Vya)(a);
    if (!b)
        throw Error(gvjs_D.v6 + " response is null");
    if (b.Xk() || b.j_()) {
        var c = b.Q$()
          , d = !0;
        b.Xk() && (d = !(gvjs_He(c, "user_not_authenticated") || gvjs_He(c, "invalid_query")));
        c = b.sP();
        var e = b.nZ();
        d = {
            showInTooltip: d
        };
        d.type = b.Xk() ? gvjs_Rb : gvjs_Wd;
        d.removeDuplicates = !0;
        a = {
            container: a,
            message: c,
            Oma: e,
            options: d
        }
    } else
        a = null;
    return null == a ? null : (0,
    gvjs_D.Sc)(a.container, a.message, a.Oma, a.options)
}
var gvjs_gba = /^[^<]*(<a(( )+target=('_blank')?("_blank")?)?( )+(href=('[^']*')?("[^"]*")?)>[^<]*<\/a>[^<]*)*$/
  , gvjs_hba = /javascript((s)?( )?)*:/;
var gvjs_iba = gvjs_D.removeAll;
function gvjs_Yk() {
    this.$m = [];
    this.Np = []
}
function gvjs_Zk(a) {
    0 === a.$m.length && (a.$m = a.Np,
    a.$m.reverse(),
    a.Np = [])
}
gvjs_ = gvjs_Yk.prototype;
gvjs_.enqueue = function(a) {
    this.Np.push(a)
}
;
gvjs_.peek = function() {
    gvjs_Zk(this);
    return gvjs_Ae(this.$m)
}
;
gvjs_.Cd = function() {
    return this.$m.length + this.Np.length
}
;
gvjs_.isEmpty = function() {
    return 0 === this.$m.length && 0 === this.Np.length
}
;
gvjs_.clear = function() {
    this.$m = [];
    this.Np = []
}
;
gvjs_.contains = function(a) {
    return gvjs_He(this.$m, a) || gvjs_He(this.Np, a)
}
;
gvjs_.remove = function(a) {
    var b = this.$m;
    var c = gvjs_haa(b, a);
    0 <= c ? (gvjs_Je(b, c),
    b = !0) : b = !1;
    return b || gvjs_Ie(this.Np, a)
}
;
gvjs_.ob = function() {
    for (var a = [], b = this.$m.length - 1; 0 <= b; --b)
        a.push(this.$m[b]);
    var c = this.Np.length;
    for (b = 0; b < c; ++b)
        a.push(this.Np[b]);
    return a
}
;
function gvjs__k(a, b) {
    this.Psa = 100;
    this.cma = a;
    this.Hva = b;
    this.SR = 0;
    this.pc = null
}
gvjs__k.prototype.get = function() {
    if (0 < this.SR) {
        this.SR--;
        var a = this.pc;
        this.pc = a.next;
        a.next = null
    } else
        a = this.cma();
    return a
}
;
gvjs__k.prototype.put = function(a) {
    this.Hva(a);
    this.SR < this.Psa && (this.SR++,
    a.next = this.pc,
    this.pc = a)
}
;
var gvjs_0k;
function gvjs_jba() {
    var a = gvjs_p.MessageChannel;
    "undefined" === typeof a && "undefined" !== typeof window && window.postMessage && window.addEventListener && !gvjs_Uf("Presto") && (a = function() {
        var e = gvjs_dh(gvjs_Ma);
        e.style.display = gvjs_f;
        document.documentElement.appendChild(e);
        var f = e.contentWindow;
        e = f.document;
        e.open();
        e.close();
        var g = "callImmediate" + Math.random()
          , h = "file:" == f.location.protocol ? "*" : f.location.protocol + "//" + f.location.host;
        e = gvjs_s(function(k) {
            if (("*" == h || k.origin == h) && k.data == g)
                this.port1.onmessage()
        }, this);
        f.addEventListener("message", e, !1);
        this.port1 = {};
        this.port2 = {
            postMessage: function() {
                f.postMessage(g, h)
            }
        }
    }
    );
    if ("undefined" !== typeof a && !gvjs_Uf("Trident") && !gvjs_Uf("MSIE")) {
        var b = new a
          , c = {}
          , d = c;
        b.port1.onmessage = function() {
            if (void 0 !== c.next) {
                c = c.next;
                var e = c.e8;
                c.e8 = null;
                e()
            }
        }
        ;
        return function(e) {
            d.next = {
                e8: e
            };
            d = d.next;
            b.port2.postMessage(0)
        }
    }
    return function(e) {
        gvjs_p.setTimeout(e, 0)
    }
}
;function gvjs_1k(a) {
    gvjs_p.setTimeout(function() {
        throw a;
    }, 0)
}
;function gvjs_2k() {
    this.XU = this.IF = null
}
gvjs_2k.prototype.add = function(a, b) {
    var c = gvjs_3k.get();
    c.set(a, b);
    this.XU ? this.XU.next = c : this.IF = c;
    this.XU = c
}
;
gvjs_2k.prototype.remove = function() {
    var a = null;
    this.IF && (a = this.IF,
    this.IF = this.IF.next,
    this.IF || (this.XU = null),
    a.next = null);
    return a
}
;
var gvjs_3k = new gvjs__k(function() {
    return new gvjs_4k
}
,function(a) {
    return a.reset()
}
);
function gvjs_4k() {
    this.next = this.scope = this.Xs = null
}
gvjs_4k.prototype.set = function(a, b) {
    this.Xs = a;
    this.scope = b;
    this.next = null
}
;
gvjs_4k.prototype.reset = function() {
    this.next = this.scope = this.Xs = null
}
;
function gvjs_5k(a, b) {
    gvjs_6k || gvjs_kba();
    gvjs_7k || (gvjs_6k(),
    gvjs_7k = !0);
    gvjs_8k.add(a, b)
}
var gvjs_6k;
function gvjs_kba() {
    if (gvjs_p.Promise && gvjs_p.Promise.resolve) {
        var a = gvjs_p.Promise.resolve(void 0);
        gvjs_6k = function() {
            a.then(gvjs_9k)
        }
    } else
        gvjs_6k = function() {
            var b = gvjs_9k;
            typeof gvjs_p.setImmediate !== gvjs_d || gvjs_p.Window && gvjs_p.Window.prototype && !gvjs_Uf(gvjs_Ca) && gvjs_p.Window.prototype.setImmediate == gvjs_p.setImmediate ? (gvjs_0k || (gvjs_0k = gvjs_jba()),
            gvjs_0k(b)) : gvjs_p.setImmediate(b)
        }
}
var gvjs_7k = !1
  , gvjs_8k = new gvjs_2k;
function gvjs_9k() {
    for (var a; a = gvjs_8k.remove(); ) {
        try {
            a.Xs.call(a.scope)
        } catch (b) {
            gvjs_1k(b)
        }
        gvjs_3k.put(a)
    }
    gvjs_7k = !1
}
;function gvjs_$k(a) {
    if (!a)
        return !1;
    try {
        return !!a.$goog_Thenable
    } catch (b) {
        return !1
    }
}
;function gvjs_al(a) {
    this.K = 0;
    this.ik = void 0;
    this.NB = this.Pu = this.qd = null;
    this.HP = this.CY = !1;
    if (a != gvjs_ke)
        try {
            var b = this;
            a.call(void 0, function(c) {
                gvjs_bl(b, 2, c)
            }, function(c) {
                gvjs_bl(b, 3, c)
            })
        } catch (c) {
            gvjs_bl(this, 3, c)
        }
}
function gvjs_cl() {
    this.next = this.context = this.UD = this.kK = this.child = null;
    this.ZM = !1
}
gvjs_cl.prototype.reset = function() {
    this.context = this.UD = this.kK = this.child = null;
    this.ZM = !1
}
;
var gvjs_dl = new gvjs__k(function() {
    return new gvjs_cl
}
,function(a) {
    a.reset()
}
);
function gvjs_el(a, b, c) {
    var d = gvjs_dl.get();
    d.kK = a;
    d.UD = b;
    d.context = c;
    return d
}
function gvjs_fl() {
    var a, b, c = new gvjs_al(function(d, e) {
        a = d;
        b = e
    }
    );
    return new gvjs_lba(c,a,b)
}
gvjs_al.prototype.then = function(a, b, c) {
    return gvjs_gl(this, typeof a === gvjs_d ? a : null, typeof b === gvjs_d ? b : null, c)
}
;
gvjs_al.prototype.$goog_Thenable = !0;
function gvjs_mba(a, b) {
    return gvjs_gl(a, null, b, void 0)
}
gvjs_al.prototype.cancel = function(a) {
    if (0 == this.K) {
        var b = new gvjs_hl(a);
        gvjs_5k(function() {
            gvjs_il(this, b)
        }, this)
    }
}
;
function gvjs_il(a, b) {
    if (0 == a.K)
        if (a.qd) {
            var c = a.qd;
            if (c.Pu) {
                for (var d = 0, e = null, f = null, g = c.Pu; g && (g.ZM || (d++,
                g.child == a && (e = g),
                !(e && 1 < d))); g = g.next)
                    e || (f = g);
                e && (0 == c.K && 1 == d ? gvjs_il(c, b) : (f ? (d = f,
                d.next == c.NB && (c.NB = d),
                d.next = d.next.next) : gvjs_jl(c),
                gvjs_kl(c, e, 3, b)))
            }
            a.qd = null
        } else
            gvjs_bl(a, 3, b)
}
function gvjs_ll(a, b) {
    a.Pu || 2 != a.K && 3 != a.K || gvjs_ml(a);
    a.NB ? a.NB.next = b : a.Pu = b;
    a.NB = b
}
function gvjs_gl(a, b, c, d) {
    var e = gvjs_el(null, null, null);
    e.child = new gvjs_al(function(f, g) {
        e.kK = b ? function(h) {
            try {
                var k = b.call(d, h);
                f(k)
            } catch (l) {
                g(l)
            }
        }
        : f;
        e.UD = c ? function(h) {
            try {
                var k = c.call(d, h);
                void 0 === k && h instanceof gvjs_hl ? g(h) : f(k)
            } catch (l) {
                g(l)
            }
        }
        : g
    }
    );
    e.child.qd = a;
    gvjs_ll(a, e);
    return e.child
}
gvjs_al.prototype.Cya = function(a) {
    this.K = 0;
    gvjs_bl(this, 2, a)
}
;
gvjs_al.prototype.Dya = function(a) {
    this.K = 0;
    gvjs_bl(this, 3, a)
}
;
function gvjs_bl(a, b, c) {
    if (0 == a.K) {
        a === c && (b = 3,
        c = new TypeError("Promise cannot resolve to itself"));
        a.K = 1;
        a: {
            var d = c
              , e = a.Cya
              , f = a.Dya;
            if (d instanceof gvjs_al) {
                gvjs_ll(d, gvjs_el(e || gvjs_ke, f || null, a));
                var g = !0
            } else if (gvjs_$k(d))
                d.then(e, f, a),
                g = !0;
            else {
                if (gvjs_r(d))
                    try {
                        var h = d.then;
                        if (typeof h === gvjs_d) {
                            gvjs_nba(d, h, e, f, a);
                            g = !0;
                            break a
                        }
                    } catch (k) {
                        f.call(a, k);
                        g = !0;
                        break a
                    }
                g = !1
            }
        }
        g || (a.ik = c,
        a.K = b,
        a.qd = null,
        gvjs_ml(a),
        3 != b || c instanceof gvjs_hl || gvjs_oba(a, c))
    }
}
function gvjs_nba(a, b, c, d, e) {
    function f(k) {
        h || (h = !0,
        d.call(e, k))
    }
    function g(k) {
        h || (h = !0,
        c.call(e, k))
    }
    var h = !1;
    try {
        b.call(a, g, f)
    } catch (k) {
        f(k)
    }
}
function gvjs_ml(a) {
    a.CY || (a.CY = !0,
    gvjs_5k(a.Xna, a))
}
function gvjs_jl(a) {
    var b = null;
    a.Pu && (b = a.Pu,
    a.Pu = b.next,
    b.next = null);
    a.Pu || (a.NB = null);
    return b
}
gvjs_al.prototype.Xna = function() {
    for (var a; a = gvjs_jl(this); )
        gvjs_kl(this, a, this.K, this.ik);
    this.CY = !1
}
;
function gvjs_kl(a, b, c, d) {
    if (3 == c && b.UD && !b.ZM)
        for (; a && a.HP; a = a.qd)
            a.HP = !1;
    if (b.child)
        b.child.qd = null,
        gvjs_nl(b, c, d);
    else
        try {
            b.ZM ? b.kK.call(b.context) : gvjs_nl(b, c, d)
        } catch (e) {
            gvjs_ol.call(null, e)
        }
    gvjs_dl.put(b)
}
function gvjs_nl(a, b, c) {
    2 == b ? a.kK.call(a.context, c) : a.UD && a.UD.call(a.context, c)
}
function gvjs_oba(a, b) {
    a.HP = !0;
    gvjs_5k(function() {
        a.HP && gvjs_ol.call(null, b)
    })
}
var gvjs_ol = gvjs_1k;
function gvjs_hl(a) {
    gvjs_ve.call(this, a)
}
gvjs_t(gvjs_hl, gvjs_ve);
gvjs_hl.prototype.name = gvjs_Ab;
function gvjs_lba(a, b, c) {
    this.promise = a;
    this.resolve = b;
    this.reject = c
}
;function gvjs_pl(a, b, c) {
    if (typeof a === gvjs_d)
        c && (a = gvjs_s(a, c));
    else if (a && typeof a.handleEvent == gvjs_d)
        a = gvjs_s(a.handleEvent, a);
    else
        throw Error("Invalid listener argument");
    return 2147483647 < Number(b) ? -1 : gvjs_p.setTimeout(a, b || 0)
}
function gvjs_ql(a) {
    gvjs_p.clearTimeout(a)
}
;/*
 Portions of this code are from MochiKit, received by
 The Closure Authors under the MIT license. All other code is Copyright
 2005-2009 The Closure Authors. All Rights Reserved.
*/
function gvjs_rl(a) {
    var b = gvjs_pba;
    this.$e = [];
    this.zda = b;
    this.p9 = a || null;
    this.BI = this.sC = !1;
    this.ik = void 0;
    this.o4 = this.Oka = this.iW = !1;
    this.KU = 0;
    this.qd = null;
    this.pW = 0
}
gvjs_ = gvjs_rl.prototype;
gvjs_.cancel = function(a) {
    if (this.sC)
        this.ik instanceof gvjs_rl && this.ik.cancel();
    else {
        if (this.qd) {
            var b = this.qd;
            delete this.qd;
            a ? b.cancel(a) : (b.pW--,
            0 >= b.pW && b.cancel())
        }
        this.zda ? this.zda.call(this.p9, this) : this.o4 = !0;
        this.sC || (a = new gvjs_sl(this),
        this.Wp(),
        gvjs_tl(this, !1, a))
    }
}
;
gvjs_.H8 = function(a, b) {
    this.iW = !1;
    gvjs_tl(this, a, b)
}
;
function gvjs_tl(a, b, c) {
    a.sC = !0;
    a.ik = c;
    a.BI = !b;
    gvjs_ul(a)
}
gvjs_.Wp = function() {
    if (this.sC) {
        if (!this.o4)
            throw new gvjs_vl(this);
        this.o4 = !1
    }
}
;
gvjs_.yN = gvjs_n(21);
function gvjs_wl(a, b, c, d) {
    a.$e.push([b, c, d]);
    a.sC && gvjs_ul(a)
}
gvjs_.then = function(a, b, c) {
    var d, e, f = new gvjs_al(function(g, h) {
        e = g;
        d = h
    }
    );
    gvjs_wl(this, e, function(g) {
        g instanceof gvjs_sl ? f.cancel() : d(g)
    });
    return f.then(a, b, c)
}
;
gvjs_rl.prototype.$goog_Thenable = !0;
gvjs_rl.prototype.Xk = function(a) {
    return a instanceof Error
}
;
function gvjs_xl(a) {
    return gvjs_Fe(a.$e, function(b) {
        return typeof b[1] === gvjs_d
    })
}
function gvjs_ul(a) {
    if (a.KU && a.sC && gvjs_xl(a)) {
        var b = a.KU
          , c = gvjs_yl[b];
        c && (gvjs_p.clearTimeout(c.ac),
        delete gvjs_yl[b]);
        a.KU = 0
    }
    a.qd && (a.qd.pW--,
    delete a.qd);
    b = a.ik;
    for (var d = c = !1; a.$e.length && !a.iW; ) {
        var e = a.$e.shift()
          , f = e[0]
          , g = e[1];
        e = e[2];
        if (f = a.BI ? g : f)
            try {
                var h = f.call(e || a.p9, b);
                void 0 !== h && (a.BI = a.BI && (h == b || a.Xk(h)),
                a.ik = b = h);
                if (gvjs_$k(b) || typeof gvjs_p.Promise === gvjs_d && b instanceof gvjs_p.Promise)
                    d = !0,
                    a.iW = !0
            } catch (k) {
                b = k,
                a.BI = !0,
                gvjs_xl(a) || (c = !0)
            }
    }
    a.ik = b;
    d && (h = gvjs_s(a.H8, a, !0),
    d = gvjs_s(a.H8, a, !1),
    b instanceof gvjs_rl ? (gvjs_wl(b, h, d),
    b.Oka = !0) : b.then(h, d));
    c && (b = new gvjs_zl(b),
    gvjs_yl[b.ac] = b,
    a.KU = b.ac)
}
function gvjs_vl() {
    gvjs_ve.call(this)
}
gvjs_t(gvjs_vl, gvjs_ve);
gvjs_vl.prototype.message = "Deferred has already fired";
gvjs_vl.prototype.name = "AlreadyCalledError";
function gvjs_sl() {
    gvjs_ve.call(this)
}
gvjs_t(gvjs_sl, gvjs_ve);
gvjs_sl.prototype.message = "Deferred was canceled";
gvjs_sl.prototype.name = "CanceledError";
function gvjs_zl(a) {
    this.ac = gvjs_p.setTimeout(gvjs_s(this.Vxa, this), 0);
    this.xy = a
}
gvjs_zl.prototype.Vxa = function() {
    delete gvjs_yl[this.ac];
    throw this.xy;
}
;
var gvjs_yl = {};
var gvjs_qba = gvjs_9e("https://maps.googleapis.com/maps/api/js?key=%{key}");
function gvjs_Al() {
    this.cache = {};
    this.yC = new google.maps.Geocoder;
    this.cache[gvjs_Hi({
        address: ""
    })] = {
        response: [],
        status: google.maps.GeocoderStatus.ZERO_RESULTS
    };
    this.yx = new Set;
    this.Fw = new Map;
    this.cE = new gvjs_Yk
}
gvjs_Al.prototype.aZ = gvjs_n(22);
gvjs_Al.prototype.FI = gvjs_n(23);
gvjs_le(gvjs_Al);
function gvjs_O(a, b) {
    this.start = a < b ? a : b;
    this.end = a < b ? b : a
}
gvjs_O.prototype.clone = function() {
    return new gvjs_O(this.start,this.end)
}
;
gvjs_O.prototype.getLength = function() {
    return this.end - this.start
}
;
function gvjs_Bl(a, b) {
    return a.start <= b && a.end >= b
}
;function gvjs_Cl() {}
gvjs_Cl.prototype.Pb = function() {}
;
function gvjs_Dl(a) {
    if (gvjs_r(a) && typeof a.$ === gvjs_d && typeof a.ca === gvjs_d)
        return a;
    throw Error("Invalid data table.");
}
gvjs_Cl.prototype.Ej = function(a) {
    return this.Pb(a) ? 2 : 0
}
;
function gvjs_El(a, b, c) {
    return 0 === c.length || gvjs_Fe(c, function(d) {
        return null == d || a.Jg(b) === d
    })
}
function gvjs_Fl(a, b, c) {
    return 0 === c.length || gvjs_Fe(c, function(d) {
        return a.W(b) === d
    })
}
function gvjs_Gl(a, b, c, d) {
    var e;
    if (e = b < a.$())
        e = a.W(b) === c;
    if (c = e)
        d = null == d ? null : d,
        c = null == d || a.Jg(b) === d;
    return c
}
function gvjs_Hl(a, b, c, d) {
    d = null == d ? [] : [d];
    return b < a.$() && gvjs_Fl(a, b, c) && gvjs_El(a, b, d)
}
gvjs_Cl.prototype.indexOf = function(a, b) {
    for (var c = 0; c < a.$(); c++)
        if (a.W(c) == b)
            return c;
    return -1
}
;
function gvjs_Il(a, b, c) {
    for (var d = 0; d < b.length; ++d) {
        var e = b[d];
        if (e >= a.$() || a.W(e) != c[d])
            return !1
    }
    return !0
}
function gvjs_Jl(a, b) {
    return gvjs_Gl(a, b, gvjs_g) ? gvjs_Kl(a, b, function(c) {
        return 0 <= c
    }) : !1
}
function gvjs_Kl(a, b, c) {
    for (var d = Math.min(a.ca(), 20), e = 0; e < d; e++) {
        var f = a.getValue(e, b);
        if (null != f && !c(f))
            return !1
    }
    return !0
}
function gvjs_rba(a) {
    function b(c) {
        return gvjs_Bl(new gvjs_O(-180,180), c) && !gvjs_1g(c)
    }
    return gvjs_Gl(a, 0, gvjs_g) && gvjs_Gl(a, 1, gvjs_g) ? gvjs_Kl(a, 0, function(c) {
        return gvjs_Bl(new gvjs_O(-90,90), c) && !gvjs_1g(c)
    }) && gvjs_Kl(a, 1, b) : !1
}
function gvjs_Ll(a) {
    for (var b = a.Py(0), c = Math.min(a.ca(), 20), d = 0, e = 0; e < c; e++) {
        var f = a.getValue(e, 1);
        f && !gvjs_He(b, f) || d++
    }
    return .6 < d / c
}
;function gvjs_Ml() {}
gvjs_o(gvjs_Ml, gvjs_Cl);
gvjs_Ml.prototype.Pb = function(a) {
    a = gvjs_Dl(a);
    var b = a.$();
    if (2 > b)
        return !1;
    var c = a.W(0);
    if (c != gvjs_Lb && c != gvjs_Mb || a.W(1) != gvjs_g)
        return !1;
    c = 0;
    for (var d = 1; d < b; d++) {
        var e = a.W(d);
        if (e == gvjs_g)
            c = 0;
        else if (e == gvjs_l) {
            if (c++,
            2 < c)
                return !1
        } else
            return !1
    }
    return !0
}
;
gvjs_Ml.prototype.Ej = function(a) {
    if (!this.Pb(a))
        return 0;
    a = gvjs_Dl(a);
    var b = 0 < this.indexOf(a, gvjs_l)
      , c = a.ca()
      , d = a.bn(0);
    if (50 < c)
        a = !0;
    else {
        for (var e = Number.MAX_VALUE, f = Number.MIN_VALUE, g = 1; g < c; g++) {
            var h = Math.abs(a.getValue(d[g - 1], 0) - a.getValue(d[g], 0));
            e = 0 < h && h < e ? h : e;
            f = h > f ? h : f
        }
        a = 0 != e && 50 < f / e ? !0 : !1
    }
    return b && a ? 3 : b || a ? 2 : 1
}
;
function gvjs_Nl(a) {
    a = a || {};
    this.h7 = !!a.wB
}
gvjs_o(gvjs_Nl, gvjs_Cl);
gvjs_Nl.prototype.Pb = function(a) {
    gvjs_Dl(a);
    var b = 0
      , c = a.$();
    if (1 > c)
        return !1;
    if (!gvjs_Gl(a, 0, gvjs_g) && (b++,
    this.h7))
        for (; b < c && gvjs_Gl(a, b, gvjs_l); )
            b++;
    for (var d = null; b < c; ) {
        var e = a.W(b);
        if (e == gvjs_g)
            d = {};
        else if (this.h7 && e == gvjs_l) {
            if (!d)
                return !1
        } else if (e == gvjs_zb) {
            if (!d || d.Nx)
                return !1;
            d.Nx = b
        } else
            return !1;
        b++
    }
    return null !== d
}
;
function gvjs_Ol(a) {
    gvjs_Nl.call(this, a);
    this.W_ = a && a.Qh || !1
}
gvjs_o(gvjs_Ol, gvjs_Nl);
gvjs_Ol.prototype.Pb = function(a) {
    gvjs_Dl(a);
    if (!gvjs_Nl.prototype.Pb.call(this, a))
        return !1;
    var b = a.$();
    if (this.W_)
        for (var c = 1; c < b; c++)
            if (gvjs_Gl(a, c, gvjs_g) && !gvjs_Jl(a, c))
                return !1;
    return !0
}
;
gvjs_Ol.prototype.Ej = function(a) {
    for (var b = a.$(), c = a.ca(), d = 0, e = !1, f = 0; f < b; f++)
        gvjs_Gl(a, f, gvjs_g) && (d++,
        gvjs_Jl(a, f) || (e = !0));
    return this.Pb(a) ? 1 == c || e || gvjs_Gl(a, 0, gvjs_l) ? 1 : 2 < d && this.W_ ? 3 : 1 != d || this.W_ ? 1 : 2 : 0
}
;
function gvjs_Pl() {}
gvjs_o(gvjs_Pl, gvjs_Cl);
gvjs_Pl.prototype.Pb = function(a) {
    a = gvjs_Dl(a);
    var b = a.$();
    return 3 > b || 5 < b || !gvjs_Gl(a, 0, gvjs_l) || !gvjs_Gl(a, 1, gvjs_g) || !gvjs_Gl(a, 2, gvjs_g) || 3 < b && !gvjs_Gl(a, 3, gvjs_l) || 4 < b && !gvjs_Gl(a, 4, gvjs_g) ? !1 : !0
}
;
gvjs_Pl.prototype.Ej = function(a) {
    a = gvjs_Dl(a);
    if (this.Pb(a)) {
        var b = a;
        if (gvjs_Gl(b, 3, gvjs_l)) {
            for (var c = {}, d = 0, e = Math.min(b.ca(), 20), f = 0; f < e; f++) {
                var g = b.getValue(f, 3);
                c[g] || d++;
                c[g] = !0
            }
            b = 10 > d
        } else
            b = !1;
        a = b ? 3 : gvjs_Gl(a, 3, gvjs_l) ? 1 : 2
    } else
        a = 0;
    return a
}
;
function gvjs_Ql() {}
gvjs_o(gvjs_Ql, gvjs_Cl);
gvjs_Ql.prototype.Pb = function(a) {
    gvjs_Dl(a);
    var b = a.$();
    if (5 > b || 6 < b || !(gvjs_Gl(a, 0, gvjs_l) && gvjs_Gl(a, 1, gvjs_g) && gvjs_Gl(a, 2, gvjs_g) && gvjs_Gl(a, 3, gvjs_g) && gvjs_Gl(a, 4, gvjs_g)) || 6 == b && !gvjs_Gl(a, 5, gvjs_l))
        return !1;
    b = Math.min(a.ca(), 20);
    for (var c = !0, d = 0; d < b; d++) {
        var e = a.getValue(d, 1)
          , f = a.getValue(d, 2)
          , g = a.getValue(d, 3)
          , h = a.getValue(d, 4);
        if (null != e && null != f && null != g && null != h && (c = !1,
        e != Math.min(e, f, g, h) || h != Math.max(e, f, g, h)))
            return !1
    }
    return !c
}
;
gvjs_Ql.prototype.Ej = function(a) {
    return this.Pb(a) ? 3 : 0
}
;
function gvjs_Rl(a) {
    gvjs_Nl.call(this, a)
}
gvjs_o(gvjs_Rl, gvjs_Nl);
gvjs_Rl.prototype.Ej = function(a) {
    a = gvjs_Dl(a);
    var b = gvjs_Gl(a, 0, gvjs_g)
      , c = a.$();
    b || c--;
    return this.Pb(a) ? 2 > c ? 1 : 2 : 0
}
;
function gvjs_Sl() {}
gvjs_o(gvjs_Sl, gvjs_Cl);
gvjs_Sl.prototype.Pb = function(a) {
    gvjs_Dl(a);
    var b = a.$();
    if (1 > b || 2 < b)
        b = !1;
    else {
        var c = !0;
        2 == b && (c = c && gvjs_Gl(a, 0, gvjs_l));
        b = c = c && gvjs_Jl(a, b - 1)
    }
    if (!b)
        if (b = a.$(),
        c = a.ca(),
        0 == b || 1 != c)
            b = !1;
        else {
            c = !0;
            for (var d = 0; d < b; d++)
                if (!gvjs_Gl(a, d, gvjs_g)) {
                    c = !1;
                    break
                }
            b = c
        }
    return b
}
;
gvjs_Sl.prototype.Ej = function(a) {
    return this.Pb(a) ? 1 < a.ca() ? 2 : 3 : 0
}
;
function gvjs_Tl() {}
gvjs_o(gvjs_Tl, gvjs_Cl);
gvjs_Tl.prototype.Pb = function(a) {
    var b = a.$();
    if (1 > b || 2 < b)
        return !1;
    var c = gvjs_Gl(a, 0, gvjs_l);
    2 == b && (c = c && gvjs_Gl(a, 1, gvjs_g));
    return c
}
;
gvjs_Tl.prototype.Ej = function(a) {
    return this.Pb(a) ? 1 : 0
}
;
gvjs_Tl.prototype.Ac = function(a, b, c) {
    try {
        a = gvjs_Dl(a);
        b = b || gvjs_ub;
        var d = 0
          , e = -1
          , f = -1
          , g = -1
          , h = -1;
        if (gvjs_Il(a, [d, d + 1], [gvjs_g, gvjs_g])) {
            var k = gvjs_9c;
            g = d;
            h = d + 1;
            d += 2;
            if (b === gvjs_yd)
                throw Error("displayMode must be set to Markers when using lat/long addresses.");
            b === gvjs_ub && (b = gvjs_bd)
        } else if (gvjs_Il(a, [d], [gvjs_l])) {
            switch (b) {
            case gvjs_ub:
                k = gvjs_xd;
                b = gvjs_yd;
                e = d;
                break;
            case gvjs_yd:
                k = gvjs_xd;
                e = d;
                break;
            case gvjs_bd:
            case gvjs_m:
                k = "address";
                f = d;
                break;
            default:
                throw Error("Unknown displayMode: " + b);
            }
            d += 1
        } else
            throw Error("Unknown address type.");
        var l = null;
        gvjs_Il(a, [d], [gvjs_l]) && gvjs_Pd != a.Bd(d, gvjs_Bd) && (l = d++);
        var m = null
          , n = null;
        gvjs_Il(a, [d], [gvjs_g]) && (m = d++,
        gvjs_Il(a, [d], [gvjs_g]) && (n = d++));
        var p = null;
        gvjs_Il(a, [d], [gvjs_l]) && gvjs_Pd == a.Bd(d, gvjs_Bd) && (p = d++);
        k != gvjs_xd && null != m && null == n && (n = m);
        if (a.$() != d)
            throw Error("Table contains more columns than expected (Expecting " + d + " columns)");
        return {
            JV: k,
            ZX: b,
            KK: e,
            fG: f,
            sD: g,
            yD: h,
            FJ: l,
            Yu: m,
            XE: n,
            m5: p
        }
    } catch (q) {
        return c && c.Sc("Incompatible data table: " + q),
        null
    }
}
;
function gvjs_Ul(a) {
    gvjs_Nl.call(this, a)
}
gvjs_o(gvjs_Ul, gvjs_Nl);
gvjs_Ul.prototype.Pb = function(a) {
    gvjs_Dl(a);
    return gvjs_Nl.prototype.Pb.call(this, a) ? !0 : !1
}
;
gvjs_Ul.prototype.Ej = function(a) {
    for (var b = a.$(), c = a.ca(), d = 0, e = 0, f = 0; f < b; f++)
        gvjs_Gl(a, f, gvjs_g) ? d++ : gvjs_Gl(a, f, gvjs_Lb) && e++;
    return this.Pb(a) ? 10 > c ? 1 : 2 > d && 0 == e ? 3 : 2 : 0
}
;
function gvjs_Vl() {}
gvjs_o(gvjs_Vl, gvjs_Cl);
gvjs_Vl.prototype.Pb = function(a) {
    return gvjs_Wl(a) || gvjs_Xl(a)
}
;
gvjs_Vl.prototype.Ej = function(a) {
    var b = gvjs_Wl(a);
    a = gvjs_Xl(a);
    return b || a ? a ? 1 : 3 : 0
}
;
function gvjs_Wl(a) {
    gvjs_Dl(a);
    var b = a.$();
    if (2 > b || 3 < b)
        return !1;
    var c = gvjs_Gl(a, 0, gvjs_g);
    c = c && gvjs_Gl(a, 1, gvjs_g);
    3 == b && (c = c && gvjs_Gl(a, 2, gvjs_l));
    return c && gvjs_rba(a)
}
function gvjs_Xl(a) {
    gvjs_Dl(a);
    var b = a.$();
    return 1 > b || 2 < b || !gvjs_Gl(a, 0, gvjs_l) || 2 == b && !gvjs_Gl(a, 1, gvjs_l) ? !1 : !0
}
;function gvjs_Yl() {}
gvjs_o(gvjs_Yl, gvjs_Cl);
gvjs_Yl.prototype.Pb = function(a) {
    a = gvjs_Dl(a);
    var b = a.$();
    if (3 > b || a.W(0) != gvjs_l)
        return !1;
    var c = a.W(1);
    if (c != gvjs_g && c != gvjs_Lb && c != gvjs_l || c == gvjs_l && !gvjs_sba(a) && !gvjs_tba(a) || c == gvjs_g && !gvjs_Kl(a, 1, function(e) {
        return gvjs_1g(e)
    }))
        return !1;
    for (c = 2; c < b; c++) {
        var d = a.W(c);
        if (d != gvjs_g && d != gvjs_l)
            return !1
    }
    return !0
}
;
gvjs_Yl.prototype.Ej = function(a) {
    try {
        a = gvjs_Dl(a)
    } catch (b) {
        return 0
    }
    return this.Pb(a) ? gvjs_Gl(a, 1, gvjs_g) && !gvjs_uba(a) ? 1 : 3 : 0
}
;
function gvjs_uba(a) {
    return gvjs_Kl(a, 1, function(b) {
        return 1900 < b && 2100 > b
    })
}
function gvjs_sba(a) {
    return gvjs_Kl(a, 1, function(b) {
        return 7 != b.length || isNaN(b.substring(0, 3)) || "W" != b.charAt(4) || isNaN(b.substring(6, 7)) ? !1 : !0
    })
}
function gvjs_tba(a) {
    return gvjs_Kl(a, 1, function(b) {
        return 6 != b.length || isNaN(b.substring(0, 3)) || "Q" != b.charAt(4) || isNaN(b.charAt(5)) ? !1 : !0
    })
}
;function gvjs_Zl() {}
gvjs_o(gvjs_Zl, gvjs_Cl);
gvjs_Zl.prototype.Pb = function(a) {
    gvjs_Dl(a);
    var b = a.$();
    if (2 > b || 3 < b)
        return !1;
    var c = gvjs_Gl(a, 0, gvjs_l) && gvjs_Gl(a, 1, gvjs_l);
    3 == b && (c = c && gvjs_Gl(a, 2, gvjs_l));
    return c && gvjs_Ll(a)
}
;
gvjs_Zl.prototype.Ej = function(a) {
    return this.Pb(a) ? 3 : 0
}
;
function gvjs__l() {}
gvjs_o(gvjs__l, gvjs_Cl);
gvjs__l.prototype.Pb = function(a) {
    gvjs_Dl(a);
    var b = a.$();
    return 1 > b || 2 < b ? !1 : gvjs_Gl(a, b - 1, gvjs_g) && gvjs_Jl(a, b - 1)
}
;
gvjs__l.prototype.Ej = function(a) {
    if (this.Pb(a))
        if (1 == a.ca())
            a = 1;
        else {
            var b;
            if (!(b = !gvjs_Gl(a, 0, gvjs_l) || 25 < a.ca())) {
                for (var c = b = 0; c < a.ca(); c++)
                    b += a.getValue(c, 1);
                b = !(97 < b && 103 > b || .97 < b && 1.03 > b)
            }
            a = b ? 2 : 3
        }
    else
        a = 0;
    return a
}
;
function gvjs_0l() {}
gvjs_o(gvjs_0l, gvjs_Cl);
gvjs_0l.prototype.Pb = function(a) {
    gvjs_Dl(a);
    var b = a.$();
    if (0 == b)
        return !1;
    for (var c = gvjs_Gl(a, 0, gvjs_l) ? 1 : 0, d = b > c; c < b; c++)
        if (!gvjs_Gl(a, c, gvjs_g)) {
            d = !1;
            break
        }
    return d
}
;
function gvjs_1l() {}
gvjs_o(gvjs_1l, gvjs_Cl);
gvjs_1l.prototype.Pb = function(a) {
    gvjs_Dl(a);
    for (var b = !0, c = a.$(), d = 0; d < c; d++)
        if (!gvjs_Gl(a, d, gvjs_g)) {
            b = !1;
            break
        }
    return b
}
;
gvjs_1l.prototype.Ej = function(a) {
    return this.Pb(a) ? 2 > a.$() ? 1 : 2 : 0
}
;
function gvjs_2l() {}
gvjs_o(gvjs_2l, gvjs_Cl);
gvjs_2l.prototype.Pb = function() {
    return !0
}
;
function gvjs_3l(a) {
    this.m = a || new gvjs_Aj([])
}
gvjs_o(gvjs_3l, gvjs_Cl);
gvjs_3l.prototype.Pb = function(a) {
    try {
        this.Ac(a)
    } catch (b) {
        return !1
    }
    return !0
}
;
gvjs_3l.prototype.Ac = function(a) {
    a = gvjs_Dl(a);
    for (var b = [], c = a.$(), d = 0; d < c; ++d) {
        var e = a.Jg(d);
        if ("" === e)
            b.push({
                index: d,
                Nf: {}
            });
        else {
            if (1 > b.length)
                throw Error("At least 1 data column must come before any role columns");
            gvjs_Ae(b).Nf[e] = d
        }
    }
    c = b.length;
    if (3 !== c && 4 !== c)
        throw Error("Invalid data table format: must have 3 or 4 data columns.");
    d = 4 == c;
    this.jb(a, b[0].index, gvjs_l);
    d && this.jb(a, b[1].index, gvjs_l);
    this.jb(a, b[d ? 2 : 1].index, gvjs_4l);
    this.jb(a, b[d ? 3 : 2].index, gvjs_4l);
    return 4 === c ? (a = !gvjs_K(this.m, "timeline.taskMajor", !0),
    {
        qw: b[a ? 1 : 0],
        tt: b[a ? 0 : 1],
        vL: b[2],
        WH: b[3]
    }) : {
        qw: b[0],
        tt: null,
        vL: b[1],
        WH: b[2]
    }
}
;
gvjs_3l.prototype.jb = function(a, b, c) {
    Array.isArray(c) || (c = [c]);
    if (!gvjs_Hl(a, b, c))
        throw Error(gvjs_Sa + b + gvjs_ba + c + "'.");
}
;
var gvjs_4l = [gvjs_Lb, gvjs_g, gvjs_Mb];
function gvjs_5l() {}
gvjs_o(gvjs_5l, gvjs_Cl);
gvjs_5l.prototype.Pb = function(a) {
    gvjs_Dl(a);
    var b = a.$();
    if (2 > b || 4 < b)
        return !1;
    var c = gvjs_Gl(a, 0, gvjs_l) && gvjs_Gl(a, 1, gvjs_l);
    2 < b && (c = c && gvjs_Jl(a, 2)) && 3 < b && (c = c && gvjs_Gl(a, 3, gvjs_g));
    return c && gvjs_Ll(a)
}
;
gvjs_5l.prototype.Ej = function(a) {
    return this.Pb(a) ? 3 : 0
}
;
function gvjs_6l(a) {
    this.yl = Array.isArray(a) ? a : gvjs_Xe(gvjs_vba)
}
gvjs_6l.prototype.BW = function(a) {
    var b = [];
    gvjs_u(this.yl, function(c) {
        var d = gvjs_wba[c]
          , e = d && d.format;
        e && (e = e.Ej(a),
        0 != e && b.push({
            type: c,
            o$: e,
            ve: d.ve
        }))
    });
    gvjs_xba(b);
    return gvjs_v(b, function(c) {
        return c.type
    })
}
;
function gvjs_xba(a) {
    gvjs_Se(a, function(b, c) {
        var d = b.o$ - c.o$;
        0 == d && (d = b.ve - c.ve);
        return -d
    })
}
var gvjs_vba = {
    tza: gvjs_ma,
    Uha: gvjs_na,
    zza: gvjs_qa,
    Kza: gvjs_ra,
    Mza: gvjs_ua,
    Uza: gvjs_xa,
    dia: gvjs_ya,
    hAa: gvjs_Ga,
    iAa: gvjs_Ha,
    Cia: gvjs_La,
    pAa: gvjs_Oa,
    qAa: gvjs_Pa,
    QAa: gvjs_Za,
    Eia: gvjs_Va,
    bBa: gvjs_3a,
    GAa: gvjs_Wa,
    VAa: gvjs_2a,
    sja: gvjs_9a,
    wBa: gvjs_oa,
    zBa: gvjs_ab,
    G6: gvjs_db,
    IBa: gvjs_fb,
    KBa: gvjs_hb,
    Rja: gvjs_mb
}
  , gvjs_wba = {
    AnnotatedTimeLine: {
        format: new gvjs_Ml,
        ve: 3
    },
    AreaChart: {
        format: new gvjs_Ol({
            wB: !0
        }),
        ve: 2
    },
    BarChart: {
        format: new gvjs_Nl({
            wB: !0
        }),
        ve: 2
    },
    BubbleChart: {
        format: new gvjs_Pl,
        ve: 2
    },
    CandlestickChart: {
        format: new gvjs_Ql,
        ve: 2
    },
    ColumnChart: {
        format: new gvjs_Nl({
            wB: !0
        }),
        ve: 2
    },
    ComboChart: {
        format: new gvjs_Rl({
            wB: !0
        }),
        ve: 2
    },
    Gauge: {
        format: new gvjs_Sl,
        ve: 1
    },
    GeoChart: {
        format: new gvjs_Tl,
        ve: 3
    },
    Histogram: {
        format: new gvjs_Ul,
        ve: 3
    },
    LineChart: {
        format: new gvjs_Nl({
            wB: !0
        }),
        ve: 2
    },
    ImageRadarChart: {
        format: new gvjs_0l,
        ve: 1
    },
    ImageSparkLine: {
        format: new gvjs_1l,
        ve: 1
    },
    Map: {
        format: new gvjs_Vl,
        ve: 2
    },
    MotionChart: {
        format: new gvjs_Yl,
        ve: 3
    },
    OrgChart: {
        format: new gvjs_Zl,
        ve: 2
    },
    PieChart: {
        format: new gvjs__l,
        ve: 2
    },
    ScatterChart: {
        format: new gvjs_Nl({
            wB: !0
        }),
        ve: 2
    },
    "AreaChart-stacked": {
        format: new gvjs_Ol({
            Qh: !0
        }),
        ve: 2
    },
    SteppedAreaChart: {
        format: new gvjs_Ol,
        ve: 2
    },
    Table: {
        format: new gvjs_2l,
        ve: 0
    },
    Timeline: {
        format: new gvjs_3l,
        ve: 2
    },
    TreeMap: {
        format: new gvjs_5l,
        ve: 2
    },
    WordTree: {
        format: new gvjs_Tl,
        ve: 2
    }
};
gvjs_q("google.visualization.ChartSelection", gvjs_6l, void 0);
gvjs_6l.prototype.calculateChartTypes = gvjs_6l.prototype.BW;
var google = google || window.google || {};
var gvjs_yba = new Set([gvjs_Zb, gvjs__b, gvjs_0b, gvjs_2b, gvjs_3b, gvjs_4b, gvjs_5b, gvjs_6b, gvjs_7b, gvjs_8b, gvjs_9b, gvjs_$b, gvjs_ac, "google.visualization.Circles", gvjs_bc, gvjs_cc, gvjs_dc, gvjs_ec, gvjs_fc, gvjs_gc, gvjs_ic, gvjs_jc, gvjs_kc, gvjs_lc, gvjs_mc, gvjs_nc, gvjs_oc, gvjs_pc, gvjs_qc, gvjs_rc, gvjs_sc, gvjs_tc, gvjs_uc, gvjs_vc, gvjs_wc, gvjs_xc, gvjs_yc, gvjs_zc, gvjs_Ac, gvjs_Bc, gvjs_Cc, gvjs_Ec, gvjs_Fc, gvjs_Gc, gvjs_Hc, gvjs_Ic, gvjs_Jc, gvjs_Lc, gvjs_Mc, gvjs_Nc, gvjs_Oc, gvjs_Pc, gvjs_Qc, gvjs_Rc, gvjs_Sc, gvjs_Tc, gvjs_Uc, gvjs_Vc, gvjs_Wc, gvjs_Xc, gvjs_Yc, gvjs_Zc, gvjs_1c, gvjs_0c]);
function gvjs_zba(a) {
    a = String(a);
    return [gvjs_1b + a, gvjs_Yb + a, a].some(function(b) {
        return gvjs_yba.has(b)
    }) ? a : ""
}
;var gvjs_7l = {};
function gvjs_8l(a) {
    if (gvjs_y && !gvjs_Eg(9))
        return [0, 0, 0, 0];
    var b = gvjs_7l.hasOwnProperty(a) ? gvjs_7l[a] : null;
    if (b)
        return b;
    65536 < Object.keys(gvjs_7l).length && (gvjs_7l = {});
    var c = [0, 0, 0, 0];
    b = gvjs_9l(a, /\\[0-9A-Fa-f]{6}\s?/g);
    b = gvjs_9l(b, /\\[0-9A-Fa-f]{1,5}\s/g);
    b = gvjs_9l(b, /\\./g);
    b = b.replace(/:not\(([^\)]*)\)/g, "     $1 ");
    b = b.replace(/{[^]*/gm, "");
    b = gvjs_$l(b, c, /(\[[^\]]+\])/g, 2);
    b = gvjs_$l(b, c, /(#[^\#\s\+>~\.\[:]+)/g, 1);
    b = gvjs_$l(b, c, /(\.[^\s\+>~\.\[:]+)/g, 2);
    b = gvjs_$l(b, c, /(::[^\s\+>~\.\[:]+|:first-line|:first-letter|:before|:after)/gi, 3);
    b = gvjs_$l(b, c, /(:[\w-]+\([^\)]*\))/gi, 2);
    b = gvjs_$l(b, c, /(:[^\s\+>~\.\[:]+)/g, 2);
    b = b.replace(/[\*\s\+>~]/g, " ");
    b = b.replace(/[#\.]/g, " ");
    gvjs_$l(b, c, /([^\s\+>~\.\[:]+)/g, 3);
    b = c;
    return gvjs_7l[a] = b
}
function gvjs_$l(a, b, c, d) {
    return a.replace(c, function(e) {
        b[d] += 1;
        return Array(e.length + 1).join(" ")
    })
}
function gvjs_9l(a, b) {
    return a.replace(b, function(c) {
        return Array(c.length + 1).join("A")
    })
}
;var gvjs_Aba = {
    rgb: !0,
    rgba: !0,
    alpha: !0,
    rect: !0,
    image: !0,
    "linear-gradient": !0,
    "radial-gradient": !0,
    "repeating-linear-gradient": !0,
    "repeating-radial-gradient": !0,
    "cubic-bezier": !0,
    matrix: !0,
    perspective: !0,
    rotate: !0,
    rotate3d: !0,
    rotatex: !0,
    rotatey: !0,
    steps: !0,
    rotatez: !0,
    scale: !0,
    scale3d: !0,
    scalex: !0,
    scaley: !0,
    scalez: !0,
    skew: !0,
    skewx: !0,
    skewy: !0,
    translate: !0,
    translate3d: !0,
    translatex: !0,
    translatey: !0,
    translatez: !0
}
  , gvjs_Bba = /[\n\f\r"'()*<>]/g
  , gvjs_Cba = {
    "\n": "%0a",
    "\f": "%0c",
    "\r": "%0d",
    '"': "%22",
    "'": "%27",
    "(": "%28",
    ")": "%29",
    "*": "%2a",
    "<": "%3c",
    ">": "%3e"
};
function gvjs_Dba(a) {
    return gvjs_Cba[a]
}
function gvjs_Eba(a, b, c) {
    b = gvjs_kf(b);
    if ("" == b)
        return null;
    var d = String(b.substr(0, 4)).toLowerCase();
    if (0 == ("url(" < d ? -1 : "url(" == d ? 0 : 1)) {
        if (!b.endsWith(")") || 1 < (b ? b.split("(").length - 1 : 0) || 1 < (b ? b.split(")").length - 1 : 0) || !c)
            a = null;
        else {
            a: for (b = b.substring(4, b.length - 1),
            d = 0; 2 > d; d++) {
                var e = "\"'".charAt(d);
                if (b.charAt(0) == e && b.charAt(b.length - 1) == e) {
                    b = b.substring(1, b.length - 1);
                    break a
                }
            }
            a = c ? (a = c(b, a)) && gvjs_xf(a) != gvjs_ob ? 'url("' + gvjs_xf(a).replace(gvjs_Bba, gvjs_Dba) + '")' : null : null
        }
        return a
    }
    if (0 < b.indexOf("(")) {
        if (/"|'/.test(b))
            return null;
        for (a = /([\-\w]+)\(/g; c = a.exec(b); )
            if (!(c[1].toLowerCase()in gvjs_Aba))
                return null
    }
    return b
}
;function gvjs_am(a, b) {
    a = gvjs_p[a];
    return a && a.prototype ? (b = Object.getOwnPropertyDescriptor(a.prototype, b)) && b.get || null : null
}
function gvjs_bm(a, b) {
    return (a = gvjs_p[a]) && a.prototype && a.prototype[b] || null
}
var gvjs_Fba = gvjs_am(gvjs_Da, gvjs_tb) || gvjs_am("Node", gvjs_tb)
  , gvjs_cm = gvjs_bm(gvjs_Da, gvjs_2c)
  , gvjs_dm = gvjs_bm(gvjs_Da, gvjs_Vb)
  , gvjs_Gba = gvjs_bm(gvjs_Da, gvjs_Fd)
  , gvjs_Hba = gvjs_bm(gvjs_Da, gvjs_Ad)
  , gvjs_Iba = gvjs_bm(gvjs_Da, gvjs_Wb)
  , gvjs_Jba = gvjs_bm(gvjs_Da, "matches") || gvjs_bm(gvjs_Da, gvjs_nd)
  , gvjs_Kba = gvjs_am("Node", gvjs_od)
  , gvjs_Lba = gvjs_am("Node", gvjs_pd)
  , gvjs_Mba = gvjs_am("Node", "parentNode")
  , gvjs_Nba = gvjs_am("HTMLElement", gvjs_Jd) || gvjs_am(gvjs_Da, gvjs_Jd)
  , gvjs_Oba = gvjs_am("HTMLStyleElement", "sheet")
  , gvjs_Pba = gvjs_bm(gvjs_sa, gvjs_Xb)
  , gvjs_Qba = gvjs_bm(gvjs_sa, "setProperty");
function gvjs_em(a, b, c, d) {
    if (a)
        return a.apply(b);
    a = b[c];
    if (!d(a))
        throw Error(gvjs_va);
    return a
}
function gvjs_fm(a, b, c, d) {
    if (a)
        return a.apply(b, d);
    if (gvjs_y && 10 > document.documentMode) {
        if (!b[c].call)
            throw Error("IE Clobbering detected");
    } else if (typeof b[c] != gvjs_d)
        throw Error(gvjs_va);
    return b[c].apply(b, d)
}
function gvjs_gm(a) {
    return gvjs_em(gvjs_Fba, a, gvjs_tb, function(b) {
        return b instanceof NamedNodeMap
    })
}
function gvjs_hm(a, b, c) {
    try {
        gvjs_fm(gvjs_Gba, a, gvjs_Fd, [b, c])
    } catch (d) {
        if (-1 == d.message.indexOf("A security problem occurred"))
            throw d;
    }
}
function gvjs_Rba(a) {
    return gvjs_em(gvjs_Nba, a, gvjs_Jd, function(b) {
        return b instanceof CSSStyleDeclaration
    })
}
function gvjs_Sba(a) {
    return gvjs_em(gvjs_Oba, a, "sheet", function(b) {
        return b instanceof CSSStyleSheet
    })
}
function gvjs_im(a) {
    return gvjs_em(gvjs_Kba, a, gvjs_od, function(b) {
        return typeof b == gvjs_l
    })
}
function gvjs_jm(a) {
    return gvjs_em(gvjs_Lba, a, gvjs_pd, function(b) {
        return typeof b == gvjs_g
    })
}
function gvjs_km(a) {
    return gvjs_em(gvjs_Mba, a, "parentNode", function(b) {
        return !(b && typeof b.name == gvjs_l && b.name && "parentnode" == b.name.toLowerCase())
    })
}
function gvjs_lm(a, b) {
    return gvjs_fm(gvjs_Pba, a, a.getPropertyValue ? gvjs_Xb : gvjs_Vb, [b]) || ""
}
function gvjs_mm(a, b, c) {
    gvjs_fm(gvjs_Qba, a, a.setProperty ? "setProperty" : gvjs_Fd, [b, c])
}
;var gvjs_Tba = gvjs_y && 10 > document.documentMode ? null : /\s*([^\s'",]+[^'",]*(('([^'\r\n\f\\]|\\[^])*')|("([^"\r\n\f\\]|\\[^])*")|[^'",])*)/g
  , gvjs_Uba = {
    "-webkit-border-horizontal-spacing": !0,
    "-webkit-border-vertical-spacing": !0
};
function gvjs_Vba(a, b, c) {
    var d = [];
    gvjs_nm(gvjs_Le(a.cssRules)).forEach(function(e) {
        if (b && !/[a-zA-Z][\w-:\.]*/.test(b))
            throw Error("Invalid container id");
        if (!(b && gvjs_y && 10 == document.documentMode && /\\['"]/.test(e.selectorText))) {
            var f = b ? e.selectorText.replace(gvjs_Tba, "#" + b + " $1") : e.selectorText;
            d.push(gvjs_Nf(f, gvjs_om(e.style, c)))
        }
    });
    return gvjs_Of(d)
}
function gvjs_nm(a) {
    return a.filter(function(b) {
        return b instanceof CSSStyleRule || b.type == CSSRule.STYLE_RULE
    })
}
function gvjs_Wba(a, b, c) {
    a = gvjs_pm("<style>" + a + "</style>");
    return null == a || null == a.sheet ? gvjs_Qf : gvjs_Vba(a.sheet, void 0 != b ? b : null, c)
}
function gvjs_pm(a) {
    if (gvjs_y && !gvjs_Eg(10) || typeof gvjs_p.DOMParser != gvjs_d)
        return null;
    a = gvjs_3f("<html><head></head><body>" + a + "</body></html>", null);
    return (new DOMParser).parseFromString(gvjs_1f(a), "text/html").body.children[0]
}
function gvjs_om(a, b) {
    if (!a)
        return gvjs_Gf;
    var c = document.createElement(gvjs_Ob).style;
    gvjs_qm(a).forEach(function(d) {
        var e = gvjs_tg && d in gvjs_Uba ? d : d.replace(/^-(?:apple|css|epub|khtml|moz|mso?|o|rim|wap|webkit|xv)-(?=[a-z])/i, "");
        gvjs_hf(e, "--") || gvjs_hf(e, "var") || (d = gvjs_lm(a, d),
        d = gvjs_Eba(e, d, b),
        null != d && gvjs_mm(c, e, d))
    });
    return new gvjs_Df(c.cssText || "",gvjs_Ef)
}
function gvjs_Xba(a) {
    var b = Array.from(gvjs_fm(gvjs_Iba, a, gvjs_Wb, [gvjs_7a]))
      , c = gvjs_jaa(b, function(e) {
        return gvjs_Le(gvjs_Sba(e).cssRules)
    });
    c = gvjs_nm(c);
    c.sort(function(e, f) {
        e = gvjs_8l(e.selectorText);
        a: {
            f = gvjs_8l(f.selectorText);
            for (var g = gvjs_Re, h = Math.min(e.length, f.length), k = 0; k < h; k++) {
                var l = g(e[k], f[k]);
                if (0 != l) {
                    e = l;
                    break a
                }
            }
            e = gvjs_Re(e.length, f.length)
        }
        return -e
    });
    a = document.createTreeWalker(a, NodeFilter.SHOW_ELEMENT, null, !1);
    for (var d; d = a.nextNode(); )
        c.forEach(function(e) {
            gvjs_fm(gvjs_Jba, d, d.matches ? "matches" : gvjs_nd, [e.selectorText]) && e.style && gvjs_Yba(d, e.style)
        });
    b.forEach(gvjs_kh)
}
function gvjs_Yba(a, b) {
    var c = gvjs_qm(a.style);
    gvjs_qm(b).forEach(function(d) {
        if (!(0 <= c.indexOf(d))) {
            var e = gvjs_lm(b, d);
            gvjs_mm(a.style, d, e)
        }
    })
}
function gvjs_qm(a) {
    gvjs_ne(a) ? a = gvjs_Le(a) : (a = gvjs_Ye(a),
    gvjs_Ie(a, "cssText"));
    return a
}
;var gvjs_Zba = {
    "* ARIA-CHECKED": !0,
    "* ARIA-COLCOUNT": !0,
    "* ARIA-COLINDEX": !0,
    "* ARIA-CONTROLS": !0,
    "* ARIA-DESCRIBEDBY": !0,
    "* ARIA-DISABLED": !0,
    "* ARIA-EXPANDED": !0,
    "* ARIA-GOOG-EDITABLE": !0,
    "* ARIA-HASPOPUP": !0,
    "* ARIA-HIDDEN": !0,
    "* ARIA-LABEL": !0,
    "* ARIA-LABELLEDBY": !0,
    "* ARIA-MULTILINE": !0,
    "* ARIA-MULTISELECTABLE": !0,
    "* ARIA-ORIENTATION": !0,
    "* ARIA-PLACEHOLDER": !0,
    "* ARIA-READONLY": !0,
    "* ARIA-REQUIRED": !0,
    "* ARIA-ROLEDESCRIPTION": !0,
    "* ARIA-ROWCOUNT": !0,
    "* ARIA-ROWINDEX": !0,
    "* ARIA-SELECTED": !0,
    "* ABBR": !0,
    "* ACCEPT": !0,
    "* ACCESSKEY": !0,
    "* ALIGN": !0,
    "* ALT": !0,
    "* AUTOCOMPLETE": !0,
    "* AXIS": !0,
    "* BGCOLOR": !0,
    "* BORDER": !0,
    "* CELLPADDING": !0,
    "* CELLSPACING": !0,
    "* CHAROFF": !0,
    "* CHAR": !0,
    "* CHECKED": !0,
    "* CLEAR": !0,
    "* COLOR": !0,
    "* COLSPAN": !0,
    "* COLS": !0,
    "* COMPACT": !0,
    "* COORDS": !0,
    "* DATETIME": !0,
    "* DIR": !0,
    "* DISABLED": !0,
    "* ENCTYPE": !0,
    "* FACE": !0,
    "* FRAME": !0,
    "* HEIGHT": !0,
    "* HREFLANG": !0,
    "* HSPACE": !0,
    "* ISMAP": !0,
    "* LABEL": !0,
    "* LANG": !0,
    "* MAX": !0,
    "* MAXLENGTH": !0,
    "* METHOD": !0,
    "* MULTIPLE": !0,
    "* NOHREF": !0,
    "* NOSHADE": !0,
    "* NOWRAP": !0,
    "* OPEN": !0,
    "* READONLY": !0,
    "* REQUIRED": !0,
    "* REL": !0,
    "* REV": !0,
    "* ROLE": !0,
    "* ROWSPAN": !0,
    "* ROWS": !0,
    "* RULES": !0,
    "* SCOPE": !0,
    "* SELECTED": !0,
    "* SHAPE": !0,
    "* SIZE": !0,
    "* SPAN": !0,
    "* START": !0,
    "* SUMMARY": !0,
    "* TABINDEX": !0,
    "* TITLE": !0,
    "* TYPE": !0,
    "* VALIGN": !0,
    "* VALUE": !0,
    "* VSPACE": !0,
    "* WIDTH": !0
}
  , gvjs__ba = {
    "* USEMAP": !0,
    "* ACTION": !0,
    "* CITE": !0,
    "* HREF": !0,
    "* LONGDESC": !0,
    "* SRC": !0,
    "LINK HREF": !0,
    "* FOR": !0,
    "* HEADERS": !0,
    "* NAME": !0,
    "A TARGET": !0,
    "* CLASS": !0,
    "* ID": !0,
    "* STYLE": !0
};
var gvjs_0ba = "undefined" != typeof WeakMap && -1 != WeakMap.toString().indexOf("[native code]")
  , gvjs_1ba = 0;
function gvjs_rm() {
    this.ad = [];
    this.mc = [];
    this.aC = "data-elementweakmap-index-" + gvjs_1ba++
}
gvjs_rm.prototype.set = function(a, b) {
    if (gvjs_fm(gvjs_cm, a, gvjs_2c, [this.aC])) {
        var c = parseInt(gvjs_fm(gvjs_dm, a, gvjs_Vb, [this.aC]) || null, 10);
        this.mc[c] = b
    } else
        c = this.mc.push(b) - 1,
        gvjs_hm(a, this.aC, c.toString()),
        this.ad.push(a);
    return this
}
;
gvjs_rm.prototype.get = function(a) {
    if (gvjs_fm(gvjs_cm, a, gvjs_2c, [this.aC]))
        return a = parseInt(gvjs_fm(gvjs_dm, a, gvjs_Vb, [this.aC]) || null, 10),
        this.mc[a]
}
;
gvjs_rm.prototype.clear = function() {
    this.ad.forEach(function(a) {
        gvjs_fm(gvjs_Hba, a, gvjs_Ad, [this.aC])
    }, this);
    this.ad = [];
    this.mc = []
}
;
var gvjs_sm = !gvjs_y || gvjs_Fg(10)
  , gvjs_2ba = !gvjs_y || null == document.documentMode;
function gvjs_tm() {}
gvjs_tm.prototype.Qd = function(a) {
    if ("TEMPLATE" == gvjs_im(a).toUpperCase())
        return null;
    var b = gvjs_im(a).toUpperCase();
    if (b in this.EL)
        b = null;
    else if (this.gF[b])
        b = document.createElement(b);
    else {
        var c = gvjs_dh(gvjs_6a);
        this.Z3 && gvjs_hm(c, "data-sanitizer-original-tag", b.toLowerCase());
        b = c
    }
    if (!b)
        return null;
    c = b;
    var d = gvjs_gm(a);
    if (null != d)
        for (var e = 0, f; f = d[e]; e++)
            if (f.specified) {
                var g = a;
                var h = f;
                var k = h.name;
                if (gvjs_hf(k, gvjs_Kb))
                    h = null;
                else {
                    var l = gvjs_im(g);
                    h = h.value;
                    var m = {
                        tagName: gvjs_kf(l).toLowerCase(),
                        attributeName: gvjs_kf(k).toLowerCase()
                    }
                      , n = {
                        zX: void 0
                    };
                    m.attributeName == gvjs_Jd && (n.zX = gvjs_Rba(g));
                    g = gvjs_um(l, k);
                    g in this.sG ? (k = this.sG[g],
                    h = k(h, m, n)) : (k = gvjs_um(null, k),
                    k in this.sG ? (k = this.sG[k],
                    h = k(h, m, n)) : h = null)
                }
                null !== h && gvjs_hm(c, f.name, h)
            }
    return b
}
;
var gvjs_3ba = {
    APPLET: !0,
    AUDIO: !0,
    BASE: !0,
    BGSOUND: !0,
    EMBED: !0,
    FORM: !0,
    IFRAME: !0,
    ISINDEX: !0,
    KEYGEN: !0,
    LAYER: !0,
    LINK: !0,
    META: !0,
    OBJECT: !0,
    SCRIPT: !0,
    SVG: !0,
    STYLE: !0,
    TEMPLATE: !0,
    VIDEO: !0
};
var gvjs_4ba = {
    A: !0,
    ABBR: !0,
    ACRONYM: !0,
    ADDRESS: !0,
    AREA: !0,
    ARTICLE: !0,
    ASIDE: !0,
    B: !0,
    BDI: !0,
    BDO: !0,
    BIG: !0,
    BLOCKQUOTE: !0,
    BR: !0,
    BUTTON: !0,
    CAPTION: !0,
    CENTER: !0,
    CITE: !0,
    CODE: !0,
    COL: !0,
    COLGROUP: !0,
    DATA: !0,
    DATALIST: !0,
    DD: !0,
    DEL: !0,
    DETAILS: !0,
    DFN: !0,
    DIALOG: !0,
    DIR: !0,
    DIV: !0,
    DL: !0,
    DT: !0,
    EM: !0,
    FIELDSET: !0,
    FIGCAPTION: !0,
    FIGURE: !0,
    FONT: !0,
    FOOTER: !0,
    FORM: !0,
    H1: !0,
    H2: !0,
    H3: !0,
    H4: !0,
    H5: !0,
    H6: !0,
    HEADER: !0,
    HGROUP: !0,
    HR: !0,
    I: !0,
    IMG: !0,
    INPUT: !0,
    INS: !0,
    KBD: !0,
    LABEL: !0,
    LEGEND: !0,
    LI: !0,
    MAIN: !0,
    MAP: !0,
    MARK: !0,
    MENU: !0,
    METER: !0,
    NAV: !0,
    NOSCRIPT: !0,
    OL: !0,
    OPTGROUP: !0,
    OPTION: !0,
    OUTPUT: !0,
    P: !0,
    PRE: !0,
    PROGRESS: !0,
    Q: !0,
    S: !0,
    SAMP: !0,
    SECTION: !0,
    SELECT: !0,
    SMALL: !0,
    SOURCE: !0,
    SPAN: !0,
    STRIKE: !0,
    STRONG: !0,
    STYLE: !0,
    SUB: !0,
    SUMMARY: !0,
    SUP: !0,
    TABLE: !0,
    TBODY: !0,
    TD: !0,
    TEXTAREA: !0,
    TFOOT: !0,
    TH: !0,
    THEAD: !0,
    TIME: !0,
    TR: !0,
    TT: !0,
    U: !0,
    UL: !0,
    VAR: !0,
    WBR: !0
};
var gvjs_5ba = {
    "ANNOTATION-XML": !0,
    "COLOR-PROFILE": !0,
    "FONT-FACE": !0,
    "FONT-FACE-SRC": !0,
    "FONT-FACE-URI": !0,
    "FONT-FACE-FORMAT": !0,
    "FONT-FACE-NAME": !0,
    "MISSING-GLYPH": !0
};
function gvjs_vm(a) {
    a = a || new gvjs_wm;
    gvjs_6ba(a);
    this.sG = gvjs_x(a.ao);
    this.EL = gvjs_x(a.EL);
    this.gF = gvjs_x(a.gF);
    this.Z3 = a.Z3;
    a.b9.forEach(function(b) {
        if (!gvjs_hf(b, "data-"))
            throw new gvjs_xe('Only "data-" attributes allowed, got: %s.',[b]);
        if (gvjs_hf(b, gvjs_Kb))
            throw new gvjs_xe('Attributes with "%s" prefix are not allowed, got: %s.',[gvjs_Kb, b]);
        this.sG["* " + b.toUpperCase()] = gvjs_xm
    }, this);
    a.V8.forEach(function(b) {
        b = b.toUpperCase();
        if (!gvjs_sf(b, "-") || gvjs_5ba[b])
            throw new gvjs_xe("Only valid custom element tag names allowed, got: %s.",[b]);
        this.gF[b] = !0
    }, this);
    this.RD = a.RD;
    this.yL = a.yL;
    this.fO = null;
    this.D_ = a.D_
}
gvjs_t(gvjs_vm, gvjs_tm);
function gvjs_ym(a) {
    return function(b, c) {
        b = gvjs_kf(b);
        return (c = a(b, c)) && gvjs_xf(c) != gvjs_ob ? gvjs_xf(c) : null
    }
}
function gvjs_wm() {
    this.ao = {};
    gvjs_u([gvjs_Zba, gvjs__ba], function(a) {
        gvjs_Ye(a).forEach(function(b) {
            this.ao[b] = gvjs_xm
        }, this)
    }, this);
    this.bs = {};
    this.b9 = [];
    this.V8 = [];
    this.EL = gvjs_x(gvjs_3ba);
    this.gF = gvjs_x(gvjs_4ba);
    this.Z3 = !1;
    this.hha = gvjs_Bf;
    this.afa = this.AU = this.n1 = this.RD = gvjs_ye;
    this.yL = null;
    this.lea = this.D_ = !1
}
function gvjs_7ba() {
    var a = gvjs_zm();
    gvjs_Me(a.b9, ["data-safe-link"]);
    return a
}
function gvjs_zm() {
    var a = new gvjs_wm;
    a.afa = gvjs_8ba;
    return a
}
function gvjs_Am(a) {
    a.hha = gvjs_Bf;
    return a
}
function gvjs_9ba(a, b) {
    return function(c, d, e, f) {
        c = a(c, d, e, f);
        return null == c ? null : b(c, d, e, f)
    }
}
function gvjs_Bm(a, b, c, d) {
    a[c] && !b[c] && (a[c] = gvjs_9ba(a[c], d))
}
gvjs_wm.prototype.cd = function() {
    return new gvjs_vm(this)
}
;
function gvjs_6ba(a) {
    if (a.lea)
        throw Error("HtmlSanitizer.Builder.build() can only be used once.");
    gvjs_Bm(a.ao, a.bs, "* USEMAP", gvjs_$ba);
    var b = gvjs_ym(a.hha);
    ["* ACTION", "* CITE", "* HREF"].forEach(function(d) {
        gvjs_Bm(this.ao, this.bs, d, b)
    }, a);
    var c = gvjs_ym(a.RD);
    ["* LONGDESC", "* SRC", "LINK HREF"].forEach(function(d) {
        gvjs_Bm(this.ao, this.bs, d, c)
    }, a);
    ["* FOR", "* HEADERS", "* NAME"].forEach(function(d) {
        gvjs_Bm(this.ao, this.bs, d, gvjs_re(gvjs_aca, this.n1))
    }, a);
    gvjs_Bm(a.ao, a.bs, "A TARGET", gvjs_re(gvjs_bca, ["_blank", "_self"]));
    gvjs_Bm(a.ao, a.bs, "* CLASS", gvjs_re(gvjs_cca, a.AU));
    gvjs_Bm(a.ao, a.bs, "* ID", gvjs_re(gvjs_dca, a.AU));
    gvjs_Bm(a.ao, a.bs, "* STYLE", gvjs_re(a.afa, c));
    a.lea = !0
}
function gvjs_um(a, b) {
    a || (a = "*");
    return (a + " " + b).toUpperCase()
}
function gvjs_8ba(a, b, c, d) {
    if (!d.zX)
        return null;
    b = gvjs_Ff(gvjs_om(d.zX, function(e, f) {
        c.lma = f;
        e = a(e, c);
        return null == e ? null : gvjs_zf(e)
    }));
    return "" == b ? null : b
}
function gvjs_xm(a) {
    return gvjs_kf(a)
}
function gvjs_bca(a, b) {
    b = gvjs_kf(b);
    return gvjs_He(a, b.toLowerCase()) ? b : null
}
function gvjs_$ba(a) {
    return (a = gvjs_kf(a)) && "#" == a.charAt(0) ? a : null
}
function gvjs_aca(a, b, c) {
    b = gvjs_kf(b);
    return a(b, c)
}
function gvjs_cca(a, b, c) {
    b = b.split(/(?:\s+)/);
    for (var d = [], e = 0; e < b.length; e++) {
        var f = a(b[e], c);
        f && d.push(f)
    }
    return 0 == d.length ? null : d.join(" ")
}
function gvjs_dca(a, b, c) {
    b = gvjs_kf(b);
    return a(b, c)
}
gvjs_vm.prototype.sanitize = function(a) {
    var b = !(gvjs_7a in this.EL) && gvjs_7a in this.gF;
    this.fO = "*" == this.yL && b ? "sanitizer-" + gvjs_hg() : this.yL;
    if (gvjs_sm) {
        b = a;
        if (gvjs_sm) {
            a = gvjs_dh(gvjs_6a);
            this.fO && "*" == this.yL && (a.id = this.fO);
            this.D_ && (b = gvjs_pm("<div>" + b + gvjs_a),
            gvjs_Xba(b),
            b = b.innerHTML);
            b = gvjs_3f(b, null);
            var c = document.createElement("template");
            if (gvjs_2ba && "content"in c)
                gvjs_cg(c, b),
                c = c.content;
            else {
                var d = document.implementation.createHTMLDocument("x");
                c = d.body;
                gvjs_cg(d.body, b)
            }
            b = document.createTreeWalker(c, NodeFilter.SHOW_ELEMENT | NodeFilter.SHOW_TEXT, null, !1);
            c = gvjs_0ba ? new WeakMap : new gvjs_rm;
            for (var e; e = b.nextNode(); ) {
                c: switch (d = e,
                gvjs_jm(d)) {
                case 3:
                    d = this.createTextNode(d);
                    break c;
                case 1:
                    d = this.Qd(d);
                    break c;
                default:
                    d = null
                }
                if (d) {
                    1 == gvjs_jm(d) && c.set(e, d);
                    e = gvjs_km(e);
                    var f = !1;
                    if (e) {
                        var g = gvjs_jm(e)
                          , h = gvjs_im(e).toLowerCase()
                          , k = gvjs_km(e);
                        11 != g || k ? h == gvjs_yb && k && (g = gvjs_km(k)) && !gvjs_km(g) && (f = !0) : f = !0;
                        g = null;
                        f || !e ? g = a : 1 == gvjs_jm(e) && (g = c.get(e));
                        g.content && (g = g.content);
                        g.appendChild(d)
                    }
                } else
                    gvjs_hh(e)
            }
            c.clear && c.clear()
        } else
            a = gvjs_dh(gvjs_6a);
        0 < gvjs_gm(a).length && (b = gvjs_dh(gvjs_6a),
        b.appendChild(a),
        a = b);
        a = (new XMLSerializer).serializeToString(a);
        a = a.slice(a.indexOf(">") + 1, a.lastIndexOf("</"))
    } else
        a = "";
    return gvjs_3f(a, null)
}
;
gvjs_vm.prototype.createTextNode = function(a) {
    var b = a.data;
    (a = gvjs_km(a)) && gvjs_im(a).toLowerCase() == gvjs_Jd && !(gvjs_7a in this.EL) && gvjs_7a in this.gF && (b = gvjs_Pf(gvjs_Wba(b, this.fO, gvjs_s(function(c, d) {
        return this.RD(c, {
            lma: d
        })
    }, this))));
    return document.createTextNode(b)
}
;
function gvjs_Cm() {
    var a = gvjs_je("google.visualization.ModulePath");
    if (null != a)
        return a;
    a = gvjs_je("google.loader.GoogleApisBase");
    null == a && (a = "//ajax.googleapis.com/ajax");
    var b = gvjs_je(gvjs__c);
    null == b && (b = "current");
    return "" + a + "/static/modules/gviz/" + b
}
function gvjs_Dm() {
    return gvjs_je("google.visualization.Locale") || "en"
}
;var gvjs_Em = gvjs_je("goog.visualization.isSafeMode") || !1
  , gvjs_Fm = function() {
    var a = gvjs_7ba()
      , b = ["icon"];
    a.V8.push("iron-icon");
    b && b.forEach(function(c) {
        c = gvjs_um("iron-icon", c);
        this.ao[c] = gvjs_xm;
        this.bs[c] = !0
    }, a);
    return a
}();
gvjs_Fm.n1 = function(a) {
    return a
}
;
gvjs_Fm.AU = function(a) {
    return a
}
;
gvjs_Fm.RD = function(a, b) {
    return "img" == b.tagName && "src" == b.attributeName && a.startsWith("data:") ? gvjs_yf(a) || gvjs_Cf : gvjs_Bf(a)
}
;
var gvjs_eca = gvjs_Am(gvjs_Fm).cd();
function gvjs_Gm(a) {
    var b = a;
    gvjs_Em && (b = gvjs_zba(a));
    a = gvjs_Oh().Vj();
    b = [gvjs_1b + b, gvjs_Yb + b, "gviz.controls.ui." + b, b];
    for (var c = 0; c < b.length; c++) {
        var d = gvjs_je(b[c], a);
        if (typeof d === gvjs_d)
            return d
    }
    return null
}
var gvjs_Hm = [];
function gvjs_fca(a, b) {
    function c() {
        d()
    }
    function d() {
        f("visualization", a, b)
    }
    b = null == b ? {} : gvjs_x(b);
    var e = gvjs_Dm();
    e && !b.language && (b.language = e);
    b.debug = b.debug || gvjs_je("google.visualization.isDebug");
    b.pseudo = b.pseudo || gvjs_je("google.visualization.isPseudo");
    var f = gvjs_je("google.charts.load") || gvjs_je("google.load");
    if (!f)
        throw Error("No loader available.");
    var g = b.callback || function() {}
    ;
    b.callback = function() {
        g();
        if (0 < gvjs_Hm.length) {
            var h = gvjs_Hm.shift();
            h && h()
        }
    }
    ;
    0 === gvjs_Hm.length ? d() : gvjs_Hm.push(c)
}
;function gvjs_Im(a) {
    gvjs_Ug(this, a, null)
}
gvjs_o(gvjs_Im, gvjs_Sg);
var gvjs_Jm = {};
function gvjs_Km() {
    var a = "undefined" !== typeof window ? window.trustedTypes : void 0;
    return null !== a && void 0 !== a ? a : null
}
var gvjs_Lm;
function gvjs_gca() {
    var a, b;
    void 0 === gvjs_Lm && (gvjs_Lm = null !== (b = null === (a = gvjs_Km()) || void 0 === a ? void 0 : a.createPolicy("google#safe", {
        createHTML: function(c) {
            return c
        },
        createScript: function(c) {
            return c
        },
        createScriptURL: function(c) {
            return c
        }
    })) && void 0 !== b ? b : null);
    return gvjs_Lm
}
;function gvjs_Mm() {}
function gvjs_Nm(a, b) {
    if (b !== gvjs_Jm)
        throw Error("Bad secret");
    this.yea = a
}
gvjs_o(gvjs_Nm, gvjs_Mm);
gvjs_Nm.prototype.toString = function() {
    return this.yea.toString()
}
;
function gvjs_Om(a) {
    var b, c = null === (b = gvjs_gca()) || void 0 === b ? void 0 : b.createScript(a);
    return new gvjs_Nm(null !== c && void 0 !== c ? c : a,gvjs_Jm)
}
;function gvjs_Pm(a) {
    if (a instanceof gvjs_Mm) {
        var b;
        if (null === (b = gvjs_Km()) || void 0 === b || !b.isScript(a))
            if (a instanceof gvjs_Nm)
                a = a.yea;
            else
                throw Error("wrong type");
    } else
        a = gvjs_bf(a);
    return a
}
;function gvjs_hca() {
    var a = new gvjs_Im([null, null, null, null, null, '(function(){/*\n\n Copyright The Closure Library Authors.\n SPDX-License-Identifier: Apache-2.0\n*/\nvar d="function"==typeof Object.create?Object.create:function(a){var b=function(){};b.prototype=a;return new b},e;if("function"==typeof Object.setPrototypeOf)e=Object.setPrototypeOf;else{var f;a:{var k={a:!0},l={};try{l.__proto__=k;f=l.a;break a}catch(a){}f=!1}e=f?function(a,b){a.__proto__=b;if(a.__proto__!==b)throw new TypeError(a+" is not extensible");return a}:null}var m=e;var n={};function p(){var a="undefined"!==typeof window?window.trustedTypes:void 0;return null!==a&&void 0!==a?a:null}var q;function r(){var a,b;void 0===q&&(q=null!==(b=null===(a=p())||void 0===a?void 0:a.createPolicy("google#safe",{createHTML:function(c){return c},createScript:function(c){return c},createScriptURL:function(c){return c}}))&&void 0!==b?b:null);return q};var t=function(a,b){if(b!==n)throw Error("Bad secret");this.g=a},u=function(){};t.prototype=d(u.prototype);t.prototype.constructor=t;if(m)m(t,u);else for(var v in u)if("prototype"!=v)if(Object.defineProperties){var w=Object.getOwnPropertyDescriptor(u,v);w&&Object.defineProperty(t,v,w)}else t[v]=u[v];t.prototype.toString=function(){return this.g.toString()};function x(a){var b;if(null===(b=p())||void 0===b?0:b.isScriptURL(a))return a;if(a instanceof t)return a.g;throw Error("wrong type");};function y(a){var b,c=null===(b=r())||void 0===b?void 0:b.createScriptURL(a);return new t(null!==c&&void 0!==c?c:a,n)};if(!function(){if(self.origin)return"null"===self.origin;if(""!==location.host)return!1;try{return window.parent.escape(""),!1}catch(a){return!0}}())throw Error("sandboxing error");\nwindow.addEventListener("message",function(a){var b=a.ports[0];a=a.data;var c=a.callbackName.split("."),g=window;"window"===c[0]&&c.unshift();for(var h=0;h<c.length-1;h++)g[c[h]]={},g=g[c[h]];g[c[c.length-1]]=function(z){b.postMessage(JSON.stringify(z))};c=document.createElement("script");a=y(a.url);c.src=x(a);document.body.appendChild(c)},!0);}).call(this);\n']);
    return a ? (a = gvjs_Xg(a, 6)) ? gvjs_Om(a) : null : null
}
;var gvjs_Qm = /^(?:([^:/?#.]+):)?(?:\/\/(?:([^\\/?#]*)@)?([^\\/?#]*?)(?::([0-9]+))?(?=[\\/?#]|$))?([^?#]+)?(?:\?([^#]*))?(?:#([\s\S]*))?$/;
function gvjs_Rm(a) {
    return a ? decodeURI(a) : a
}
function gvjs_Sm(a, b) {
    return b.match(gvjs_Qm)[a] || null
}
function gvjs_Tm(a) {
    a = gvjs_Sm(1, a);
    !a && gvjs_p.self && gvjs_p.self.location && (a = gvjs_p.self.location.protocol,
    a = a.substr(0, a.length - 1));
    return a ? a.toLowerCase() : ""
}
function gvjs_ica(a, b) {
    if (a) {
        a = a.split("&");
        for (var c = 0; c < a.length; c++) {
            var d = a[c].indexOf("=")
              , e = null;
            if (0 <= d) {
                var f = a[c].substring(0, d);
                e = a[c].substring(d + 1)
            } else
                f = a[c];
            b(f, e ? decodeURIComponent(e.replace(/\+/g, " ")) : "")
        }
    }
}
function gvjs_Um(a, b, c, d) {
    for (var e = c.length; 0 <= (b = a.indexOf(c, b)) && b < d; ) {
        var f = a.charCodeAt(b - 1);
        if (38 == f || 63 == f)
            if (f = a.charCodeAt(b + e),
            !f || 61 == f || 38 == f || 35 == f)
                return b;
        b += e + 1
    }
    return -1
}
var gvjs_Vm = /#|$/;
function gvjs_Wm(a, b) {
    var c = a.search(gvjs_Vm)
      , d = gvjs_Um(a, 0, b, c);
    if (0 > d)
        return null;
    var e = a.indexOf("&", d);
    if (0 > e || e > c)
        e = c;
    d += b.length + 1;
    return decodeURIComponent(a.substr(d, e - d).replace(/\+/g, " "))
}
;function gvjs_Xm(a, b) {
    this.jv = this.dB = this.gp = "";
    this.Bw = null;
    this.Fy = this.bl = "";
    this.kn = this.nsa = !1;
    if (a instanceof gvjs_Xm) {
        this.kn = void 0 !== b ? b : a.kn;
        gvjs_Ym(this, a.gp);
        var c = a.dB;
        gvjs_Zm(this);
        this.dB = c;
        gvjs__m(this, a.jv);
        gvjs_0m(this, a.Bw);
        this.setPath(a.getPath());
        gvjs_1m(this, a.cg.clone());
        a = a.Fy;
        gvjs_Zm(this);
        this.Fy = a
    } else
        a && (c = String(a).match(gvjs_Qm)) ? (this.kn = !!b,
        gvjs_Ym(this, c[1] || "", !0),
        a = c[2] || "",
        gvjs_Zm(this),
        this.dB = gvjs_2m(a),
        gvjs__m(this, c[3] || "", !0),
        gvjs_0m(this, c[4]),
        this.setPath(c[5] || "", !0),
        gvjs_1m(this, c[6] || "", !0),
        a = c[7] || "",
        gvjs_Zm(this),
        this.Fy = gvjs_2m(a)) : (this.kn = !!b,
        this.cg = new gvjs_3m(null,this.kn))
}
gvjs_ = gvjs_Xm.prototype;
gvjs_.toString = function() {
    var a = []
      , b = this.gp;
    b && a.push(gvjs_4m(b, gvjs_5m, !0), ":");
    var c = this.jv;
    if (c || "file" == b)
        a.push("//"),
        (b = this.dB) && a.push(gvjs_4m(b, gvjs_5m, !0), "@"),
        a.push(encodeURIComponent(String(c)).replace(/%25([0-9a-fA-F]{2})/g, "%$1")),
        c = this.Bw,
        null != c && a.push(":", String(c));
    if (c = this.getPath())
        this.jv && "/" != c.charAt(0) && a.push("/"),
        a.push(gvjs_4m(c, "/" == c.charAt(0) ? gvjs_jca : gvjs_kca, !0));
    (c = this.cg.toString()) && a.push("?", c);
    (c = this.Fy) && a.push("#", gvjs_4m(c, gvjs_lca));
    return a.join("")
}
;
gvjs_.resolve = function(a) {
    var b = this.clone()
      , c = !!a.gp;
    c ? gvjs_Ym(b, a.gp) : c = !!a.dB;
    if (c) {
        var d = a.dB;
        gvjs_Zm(b);
        b.dB = d
    } else
        c = !!a.jv;
    c ? gvjs__m(b, a.jv) : c = null != a.Bw;
    d = a.getPath();
    if (c)
        gvjs_0m(b, a.Bw);
    else if (c = !!a.bl) {
        if ("/" != d.charAt(0))
            if (this.jv && !this.bl)
                d = "/" + d;
            else {
                var e = b.getPath().lastIndexOf("/");
                -1 != e && (d = b.getPath().substr(0, e + 1) + d)
            }
        e = d;
        if (".." == e || "." == e)
            d = "";
        else if (gvjs_sf(e, "./") || gvjs_sf(e, "/.")) {
            d = gvjs_hf(e, "/");
            e = e.split("/");
            for (var f = [], g = 0; g < e.length; ) {
                var h = e[g++];
                "." == h ? d && g == e.length && f.push("") : ".." == h ? ((1 < f.length || 1 == f.length && "" != f[0]) && f.pop(),
                d && g == e.length && f.push("")) : (f.push(h),
                d = !0)
            }
            d = f.join("/")
        } else
            d = e
    }
    c ? b.setPath(d) : c = "" !== a.cg.toString();
    c ? gvjs_1m(b, a.cg.clone()) : c = !!a.Fy;
    c && (a = a.Fy,
    gvjs_Zm(b),
    b.Fy = a);
    return b
}
;
gvjs_.clone = function() {
    return new gvjs_Xm(this)
}
;
function gvjs_Ym(a, b, c) {
    gvjs_Zm(a);
    a.gp = c ? gvjs_2m(b, !0) : b;
    a.gp && (a.gp = a.gp.replace(/:$/, ""))
}
function gvjs__m(a, b, c) {
    gvjs_Zm(a);
    a.jv = c ? gvjs_2m(b, !0) : b
}
function gvjs_0m(a, b) {
    gvjs_Zm(a);
    if (b) {
        b = Number(b);
        if (isNaN(b) || 0 > b)
            throw Error("Bad port number " + b);
        a.Bw = b
    } else
        a.Bw = null
}
gvjs_.getPath = function() {
    return this.bl
}
;
gvjs_.setPath = function(a, b) {
    gvjs_Zm(this);
    this.bl = b ? gvjs_2m(a, !0) : a;
    return this
}
;
function gvjs_1m(a, b, c) {
    gvjs_Zm(a);
    b instanceof gvjs_3m ? (a.cg = b,
    a.cg.O3(a.kn)) : (c || (b = gvjs_4m(b, gvjs_mca)),
    a.cg = new gvjs_3m(b,a.kn));
    return a
}
gvjs_.Jn = function(a, b) {
    return gvjs_1m(this, a, b)
}
;
gvjs_.getQuery = function() {
    return this.cg.toString()
}
;
gvjs_.Ld = function(a, b) {
    gvjs_Zm(this);
    this.cg.set(a, b);
    return this
}
;
gvjs_.removeParameter = function(a) {
    gvjs_Zm(this);
    this.cg.remove(a);
    return this
}
;
function gvjs_Zm(a) {
    if (a.nsa)
        throw Error("Tried to modify a read-only Uri");
}
gvjs_.O3 = function(a) {
    this.kn = a;
    this.cg && this.cg.O3(a)
}
;
function gvjs_2m(a, b) {
    return a ? b ? decodeURI(a.replace(/%25/g, "%2525")) : decodeURIComponent(a) : ""
}
function gvjs_4m(a, b, c) {
    return typeof a === gvjs_l ? (a = encodeURI(a).replace(b, gvjs_nca),
    c && (a = a.replace(/%25([0-9a-fA-F]{2})/g, "%$1")),
    a) : null
}
function gvjs_nca(a) {
    a = a.charCodeAt(0);
    return "%" + (a >> 4 & 15).toString(16) + (a & 15).toString(16)
}
var gvjs_5m = /[#\/\?@]/g
  , gvjs_kca = /[#\?:]/g
  , gvjs_jca = /[#\?]/g
  , gvjs_mca = /[#\?@]/g
  , gvjs_lca = /#/g;
function gvjs_3m(a, b) {
    this.Vc = this.Hf = null;
    this.Il = a || null;
    this.kn = !!b
}
function gvjs_6m(a) {
    a.Hf || (a.Hf = new gvjs_aj,
    a.Vc = 0,
    a.Il && gvjs_ica(a.Il, function(b, c) {
        a.add(decodeURIComponent(b.replace(/\+/g, " ")), c)
    }))
}
function gvjs_oca(a) {
    var b = gvjs_fj(a);
    if ("undefined" == typeof b)
        throw Error("Keys are undefined");
    var c = new gvjs_3m(null,void 0);
    a = gvjs_ej(a);
    for (var d = 0; d < b.length; d++) {
        var e = b[d]
          , f = a[d];
        Array.isArray(f) ? c.setValues(e, f) : c.add(e, f)
    }
    return c
}
gvjs_ = gvjs_3m.prototype;
gvjs_.Cd = function() {
    gvjs_6m(this);
    return this.Vc
}
;
gvjs_.add = function(a, b) {
    gvjs_6m(this);
    this.Il = null;
    a = gvjs_7m(this, a);
    var c = this.Hf.get(a);
    c || this.Hf.set(a, c = []);
    c.push(b);
    this.Vc += 1;
    return this
}
;
gvjs_.remove = function(a) {
    gvjs_6m(this);
    a = gvjs_7m(this, a);
    return this.Hf.tf(a) ? (this.Il = null,
    this.Vc -= this.Hf.get(a).length,
    this.Hf.remove(a)) : !1
}
;
gvjs_.clear = function() {
    this.Hf = this.Il = null;
    this.Vc = 0
}
;
gvjs_.isEmpty = function() {
    gvjs_6m(this);
    return 0 == this.Vc
}
;
gvjs_.tf = function(a) {
    gvjs_6m(this);
    a = gvjs_7m(this, a);
    return this.Hf.tf(a)
}
;
gvjs_.XB = function(a) {
    var b = this.ob();
    return gvjs_He(b, a)
}
;
gvjs_.forEach = function(a, b) {
    gvjs_6m(this);
    this.Hf.forEach(function(c, d) {
        c.forEach(function(e) {
            a.call(b, e, d, this)
        }, this)
    }, this)
}
;
gvjs_.cj = function() {
    gvjs_6m(this);
    for (var a = this.Hf.ob(), b = this.Hf.cj(), c = [], d = 0; d < b.length; d++)
        for (var e = a[d], f = 0; f < e.length; f++)
            c.push(b[d]);
    return c
}
;
gvjs_.ob = function(a) {
    gvjs_6m(this);
    var b = [];
    if (typeof a === gvjs_l)
        this.tf(a) && (b = b.concat(this.Hf.get(gvjs_7m(this, a))));
    else {
        a = this.Hf.ob();
        for (var c = 0; c < a.length; c++)
            b = b.concat(a[c])
    }
    return b
}
;
gvjs_.set = function(a, b) {
    gvjs_6m(this);
    this.Il = null;
    a = gvjs_7m(this, a);
    this.tf(a) && (this.Vc -= this.Hf.get(a).length);
    this.Hf.set(a, [b]);
    this.Vc += 1;
    return this
}
;
gvjs_.get = function(a, b) {
    if (!a)
        return b;
    a = this.ob(a);
    return 0 < a.length ? String(a[0]) : b
}
;
gvjs_.setValues = function(a, b) {
    this.remove(a);
    0 < b.length && (this.Il = null,
    this.Hf.set(gvjs_7m(this, a), gvjs_Le(b)),
    this.Vc += b.length)
}
;
gvjs_.toString = function() {
    if (this.Il)
        return this.Il;
    if (!this.Hf)
        return "";
    for (var a = [], b = this.Hf.cj(), c = 0; c < b.length; c++) {
        var d = b[c]
          , e = encodeURIComponent(String(d));
        d = this.ob(d);
        for (var f = 0; f < d.length; f++) {
            var g = e;
            "" !== d[f] && (g += "=" + encodeURIComponent(String(d[f])));
            a.push(g)
        }
    }
    return this.Il = a.join("&")
}
;
gvjs_.clone = function() {
    var a = new gvjs_3m;
    a.Il = this.Il;
    this.Hf && (a.Hf = this.Hf.clone(),
    a.Vc = this.Vc);
    return a
}
;
function gvjs_7m(a, b) {
    b = String(b);
    a.kn && (b = b.toLowerCase());
    return b
}
gvjs_.O3 = function(a) {
    a && !this.kn && (gvjs_6m(this),
    this.Il = null,
    this.Hf.forEach(function(b, c) {
        var d = c.toLowerCase();
        c != d && (this.remove(c),
        this.setValues(d, b))
    }, this));
    this.kn = a
}
;
gvjs_.extend = function(a) {
    for (var b = 0; b < arguments.length; b++)
        gvjs_gj(arguments[b], function(c, d) {
            this.add(d, c)
        }, this)
}
;
function gvjs_8m(a, b) {
    this.url = a;
    this.timeout = void 0 === b ? 5E3 : b;
    this.EW = this.DW = "callback";
    this.sv = this.YI = null
}
gvjs_8m.prototype.fetch = function(a) {
    var b = this;
    a = void 0 === a ? {} : a;
    this.sv = gvjs_fl();
    var c = new gvjs_Xm(this.url)
      , d = new Map;
    this.EW && d.set(this.EW, this.DW);
    c.cg.extend(gvjs_oca(a), d);
    gvjs_pca(this).then(function() {
        gvjs_qca(b, c.toString())
    }).then(function() {
        return b.sv.promise
    }).then(function() {
        gvjs_9m(b)
    }, function() {
        gvjs_9m(b)
    });
    0 < this.timeout && (this.g5 = setTimeout(function() {
        b.sv.reject("Timeout!")
    }, this.timeout));
    return this.sv.promise
}
;
function gvjs_qca(a, b) {
    var c = new MessageChannel;
    a.YI.contentWindow.postMessage({
        url: b,
        callbackName: a.DW
    }, "*", [c.port2]);
    c.port1.onmessage = function(d) {
        var e = {};
        void 0 !== a.g5 && (clearTimeout(a.g5),
        a.g5 = void 0);
        void 0 === d.data && a.sv.reject("Callback called, but no data received");
        typeof d.data !== gvjs_l && a.sv.reject("Exploitation attempt! Data is not a string!");
        try {
            e = JSON.parse(d.data)
        } catch (f) {
            a.sv.reject("Invalid Data received: " + f.message)
        }
        a.sv.resolve(e)
    }
}
function gvjs_pca(a) {
    var b = gvjs_fl()
      , c = gvjs_dh(gvjs_Ma);
    if (!c.sandbox)
        throw Error("iframe sandboxes not supported");
    c.sandbox.value = "allow-scripts";
    c.style.display = gvjs_f;
    a.YI = c;
    a = gvjs_hca();
    a = gvjs_$f(gvjs_yaa, gvjs_5f(gvjs_yb, {}, gvjs_waa(gvjs_laa(gvjs_Pm(a).toString()))));
    c.srcdoc = gvjs_1f(a);
    a = gvjs_gf("data:text/html;charset=UTF-8;base64," + btoa(gvjs_0f(a)));
    c.src = gvjs_ef(a);
    c.addEventListener("load", function() {
        return b.resolve(c)
    }, !1);
    c.addEventListener(gvjs_Rb, function(d) {
        b.reject(d)
    }, !1);
    document.documentElement.appendChild(c);
    return b.promise
}
function gvjs_9m(a) {
    null !== a.YI && (document.documentElement.removeChild(a.YI),
    a.YI = null)
}
;function gvjs_$m(a) {
    switch (a) {
    case 200:
    case 201:
    case 202:
    case 204:
    case 206:
    case 304:
    case 1223:
        return !0;
    default:
        return !1
    }
}
;function gvjs_an() {}
gvjs_an.prototype.T7 = null;
gvjs_an.prototype.Zc = function() {
    var a;
    (a = this.T7) || (a = {},
    gvjs_bn(this) && (a[0] = !0,
    a[1] = !0),
    a = this.T7 = a);
    return a
}
;
var gvjs_cn;
function gvjs_dn() {}
gvjs_t(gvjs_dn, gvjs_an);
function gvjs_en(a) {
    return (a = gvjs_bn(a)) ? new ActiveXObject(a) : new XMLHttpRequest
}
function gvjs_bn(a) {
    if (!a.iba && "undefined" == typeof XMLHttpRequest && "undefined" != typeof ActiveXObject) {
        for (var b = ["MSXML2.XMLHTTP.6.0", "MSXML2.XMLHTTP.3.0", "MSXML2.XMLHTTP", "Microsoft.XMLHTTP"], c = 0; c < b.length; c++) {
            var d = b[c];
            try {
                return new ActiveXObject(d),
                a.iba = d
            } catch (e) {}
        }
        throw Error("Could not create ActiveXObject. ActiveX might be disabled, or MSXML might not be installed");
    }
    return a.iba
}
gvjs_cn = new gvjs_dn;
function gvjs_fn(a) {
    return gvjs_rca(a).then(function(b) {
        return b.responseText
    })
}
function gvjs_rca(a) {
    var b = {}
      , c = b.gza ? gvjs_en(b.gza) : gvjs_en(gvjs_cn);
    return gvjs_mba(new gvjs_al(function(d, e) {
        var f;
        try {
            c.open("GET", a, !0)
        } catch (k) {
            e(new gvjs_gn("Error opening XHR: " + k.message,a,c))
        }
        c.onreadystatechange = function() {
            if (4 == c.readyState) {
                gvjs_p.clearTimeout(f);
                var k;
                !(k = gvjs_$m(c.status)) && (k = 0 === c.status) && (k = gvjs_Tm(a),
                k = !("http" == k || "https" == k || "" == k));
                k ? d(c) : e(new gvjs_hn(c.status,a,c))
            }
        }
        ;
        c.onerror = function() {
            e(new gvjs_gn("Network error",a,c))
        }
        ;
        if (b.headers)
            for (var g in b.headers) {
                var h = b.headers[g];
                null != h && c.setRequestHeader(g, h)
            }
        b.withCredentials && (c.withCredentials = b.withCredentials);
        b.responseType && (c.responseType = b.responseType);
        b.mimeType && c.overrideMimeType(b.mimeType);
        0 < b.bya && (f = gvjs_p.setTimeout(function() {
            c.onreadystatechange = gvjs_ke;
            c.abort();
            e(new gvjs_in(a,c))
        }, b.bya));
        try {
            c.send(null)
        } catch (k) {
            c.onreadystatechange = gvjs_ke,
            gvjs_p.clearTimeout(f),
            e(new gvjs_gn("Error sending XHR: " + k.message,a,c))
        }
    }
    ), function(d) {
        d instanceof gvjs_hl && c.abort();
        throw d;
    })
}
function gvjs_gn(a, b) {
    gvjs_ve.call(this, a + ", url=" + b);
    this.url = b
}
gvjs_t(gvjs_gn, gvjs_ve);
gvjs_gn.prototype.name = "XhrError";
function gvjs_hn(a, b, c) {
    gvjs_gn.call(this, "Request Failed, status=" + a, b, c);
    this.status = a
}
gvjs_t(gvjs_hn, gvjs_gn);
gvjs_hn.prototype.name = "XhrHttpError";
function gvjs_in(a, b) {
    gvjs_gn.call(this, gvjs_4a, a, b)
}
gvjs_t(gvjs_in, gvjs_gn);
gvjs_in.prototype.name = "XhrTimeoutError";
function gvjs_jn(a) {
    gvjs_H.call(this);
    this.headers = new gvjs_aj;
    this.ZU = a || null;
    this.zu = !1;
    this.YU = this.Zb = null;
    this.Az = this.m0 = "";
    this.lz = this.u_ = this.lQ = this.yY = !1;
    this.wU = 0;
    this.vU = null;
    this.Sea = "";
    this.Q5 = this.kva = this.e6 = !1;
    this.v5 = null
}
gvjs_t(gvjs_jn, gvjs_H);
var gvjs_sca = /^https?$/i
  , gvjs_tca = ["POST", "PUT"]
  , gvjs_kn = [];
function gvjs_uca(a, b, c, d, e) {
    var f = gvjs_vca
      , g = new gvjs_jn;
    gvjs_kn.push(g);
    b && g.o(gvjs_Hb, b);
    g.vD(gvjs_i, g.Bla);
    e && (g.e6 = e);
    g.send(a, c, d, f)
}
gvjs_ = gvjs_jn.prototype;
gvjs_.Bla = function() {
    this.pa();
    gvjs_Ie(gvjs_kn, this)
}
;
gvjs_.setTrustToken = function(a) {
    this.v5 = a
}
;
gvjs_.send = function(a, b, c, d) {
    if (this.Zb)
        throw Error("[goog.net.XhrIo] Object is active with another request=" + this.m0 + "; newUri=" + a);
    b = b ? b.toUpperCase() : "GET";
    this.m0 = a;
    this.Az = "";
    this.yY = !1;
    this.zu = !0;
    this.Zb = this.ZU ? gvjs_en(this.ZU) : gvjs_en(gvjs_cn);
    this.YU = this.ZU ? this.ZU.Zc() : gvjs_cn.Zc();
    this.Zb.onreadystatechange = gvjs_s(this.Kda, this);
    this.kva && "onprogress"in this.Zb && (this.Zb.onprogress = gvjs_s(function(f) {
        this.Jda(f, !0)
    }, this),
    this.Zb.upload && (this.Zb.upload.onprogress = gvjs_s(this.Jda, this)));
    try {
        this.u_ = !0,
        this.Zb.open(b, String(a), !0),
        this.u_ = !1
    } catch (f) {
        this.xy(5, f);
        return
    }
    a = c || "";
    var e = this.headers.clone();
    d && gvjs_gj(d, function(f, g) {
        e.set(g, f)
    });
    d = e.cj().find(function(f) {
        return "content-type" == f.toLowerCase()
    });
    c = gvjs_p.FormData && a instanceof gvjs_p.FormData;
    !gvjs_He(gvjs_tca, b) || d || c || e.set("Content-Type", "application/x-www-form-urlencoded;charset=utf-8");
    e.forEach(function(f, g) {
        this.Zb.setRequestHeader(g, f)
    }, this);
    this.Sea && (this.Zb.responseType = this.Sea);
    gvjs_Yd in this.Zb && this.Zb.withCredentials !== this.e6 && (this.Zb.withCredentials = this.e6);
    if ("setTrustToken"in this.Zb && this.v5)
        try {
            this.Zb.setTrustToken(this.v5)
        } catch (f) {}
    try {
        gvjs_ln(this),
        0 < this.wU && ((this.Q5 = gvjs_wca(this.Zb)) ? (this.Zb.timeout = this.wU,
        this.Zb.ontimeout = gvjs_s(this.zg, this)) : this.vU = gvjs_pl(this.zg, this.wU, this)),
        this.lQ = !0,
        this.Zb.send(a),
        this.lQ = !1
    } catch (f) {
        this.xy(5, f)
    }
}
;
function gvjs_wca(a) {
    return gvjs_y && gvjs_Eg(9) && typeof a.timeout === gvjs_g && void 0 !== a.ontimeout
}
gvjs_.zg = function() {
    "undefined" != typeof gvjs_ie && this.Zb && (this.Az = "Timed out after " + this.wU + "ms, aborting",
    this.dispatchEvent("timeout"),
    this.abort(8))
}
;
gvjs_.xy = function(a, b) {
    this.zu = !1;
    this.Zb && (this.lz = !0,
    this.Zb.abort(),
    this.lz = !1);
    this.Az = b;
    gvjs_mn(this);
    gvjs_nn(this)
}
;
function gvjs_mn(a) {
    a.yY || (a.yY = !0,
    a.dispatchEvent(gvjs_Hb),
    a.dispatchEvent(gvjs_Rb))
}
gvjs_.abort = function() {
    this.Zb && this.zu && (this.zu = !1,
    this.lz = !0,
    this.Zb.abort(),
    this.lz = !1,
    this.dispatchEvent(gvjs_Hb),
    this.dispatchEvent("abort"),
    gvjs_nn(this))
}
;
gvjs_.M = function() {
    this.Zb && (this.zu && (this.zu = !1,
    this.lz = !0,
    this.Zb.abort(),
    this.lz = !1),
    gvjs_nn(this, !0));
    gvjs_jn.G.M.call(this)
}
;
gvjs_.Kda = function() {
    this.xf || (this.u_ || this.lQ || this.lz ? gvjs_on(this) : this.Aua())
}
;
gvjs_.Aua = function() {
    gvjs_on(this)
}
;
function gvjs_on(a) {
    if (a.zu && "undefined" != typeof gvjs_ie && (!a.YU[1] || 4 != gvjs_pn(a) || 2 != a.getStatus()))
        if (a.lQ && 4 == gvjs_pn(a))
            gvjs_pl(a.Kda, 0, a);
        else if (a.dispatchEvent("readystatechange"),
        4 == gvjs_pn(a)) {
            a.zu = !1;
            try {
                if (gvjs_qn(a))
                    a.dispatchEvent(gvjs_Hb),
                    a.dispatchEvent("success");
                else {
                    try {
                        var b = 2 < gvjs_pn(a) ? a.Zb.statusText : ""
                    } catch (c) {
                        b = ""
                    }
                    a.Az = b + " [" + a.getStatus() + "]";
                    gvjs_mn(a)
                }
            } finally {
                gvjs_nn(a)
            }
        }
}
gvjs_.Jda = function(a, b) {
    this.dispatchEvent(gvjs_rn(a, "progress"));
    this.dispatchEvent(gvjs_rn(a, b ? "downloadprogress" : "uploadprogress"))
}
;
function gvjs_rn(a, b) {
    return {
        type: b,
        lengthComputable: a.lengthComputable,
        loaded: a.loaded,
        total: a.total
    }
}
function gvjs_nn(a, b) {
    if (a.Zb) {
        gvjs_ln(a);
        var c = a.Zb
          , d = a.YU[0] ? gvjs_ke : null;
        a.Zb = null;
        a.YU = null;
        b || a.dispatchEvent(gvjs_i);
        try {
            c.onreadystatechange = d
        } catch (e) {}
    }
}
function gvjs_ln(a) {
    a.Zb && a.Q5 && (a.Zb.ontimeout = null);
    a.vU && (gvjs_ql(a.vU),
    a.vU = null)
}
gvjs_.ak = function() {
    return !!this.Zb
}
;
function gvjs_qn(a) {
    var b = a.getStatus(), c;
    if (!(c = gvjs_$m(b))) {
        if (b = 0 === b)
            a = gvjs_Tm(String(a.m0)),
            b = !gvjs_sca.test(a);
        c = b
    }
    return c
}
function gvjs_pn(a) {
    return a.Zb ? a.Zb.readyState : 0
}
gvjs_.getStatus = function() {
    try {
        return 2 < gvjs_pn(this) ? this.Zb.status : -1
    } catch (a) {
        return -1
    }
}
;
gvjs_.getResponseHeader = function(a) {
    if (this.Zb && 4 == gvjs_pn(this))
        return a = this.Zb.getResponseHeader(a),
        null === a ? void 0 : a
}
;
gvjs_.getAllResponseHeaders = function() {
    return this.Zb && 4 == gvjs_pn(this) ? this.Zb.getAllResponseHeaders() || "" : ""
}
;
function gvjs_sn(a) {
    return typeof a.Az === gvjs_l ? a.Az : String(a.Az)
}
;function gvjs_tn() {
    this.position = null;
    gvjs_ve.call(this, void 0)
}
gvjs_t(gvjs_tn, gvjs_ve);
gvjs_tn.prototype.name = "ParseError";
function gvjs_xca(a) {
    function b() {
        if (null != l) {
            var q = l;
            l = null;
            return q
        }
        if (e >= a.length)
            return f;
        q = a.charAt(e++);
        var r = !1;
        "\n" == q ? r = !0 : "\r" == q && (e < a.length && "\n" == a.charAt(e) && e++,
        r = !0);
        return r ? h : q
    }
    function c() {
        var q = e
          , r = m;
        m = !1;
        var t = b();
        if (t == k)
            return g;
        if (t == f || t == h)
            return r ? (l = k,
            "") : g;
        if ('"' == t) {
            q = e;
            r = null;
            for (t = b(); t != f; t = b())
                if ('"' == t)
                    if (r = e - 1,
                    t = b(),
                    '"' == t)
                        r = null;
                    else {
                        if ("," == t || t == f || t == h) {
                            t == h && (l = t);
                            "," == t && (m = !0);
                            break
                        }
                        throw new gvjs_tn(a,e - 1,'Unexpected character "' + t + '" after quote mark');
                    }
            if (null === r)
                throw new gvjs_tn(a,a.length - 1,"Unexpected end of text after open quote");
            return a.substring(q, r).replace(/""/g, '"')
        }
        for (; ; ) {
            if (t == f || t == h) {
                l = t;
                break
            }
            if ("," == t) {
                m = !0;
                break
            }
            if ('"' == t)
                throw new gvjs_tn(a,e - 1,"Unexpected quote mark");
            t = b()
        }
        return (t == f ? a.substring(q) : a.substring(q, e - 1)).replace(/[\r\n]+/g, "")
    }
    function d() {
        if (e >= a.length)
            return f;
        for (var q = [], r = c(); r != g; r = c())
            q.push(r);
        return q
    }
    for (var e = 0, f = gvjs_yca, g = gvjs_zca, h = gvjs_Aca, k = gvjs_Bca, l = null, m = !1, n = [], p = d(); p != f; p = d())
        n.push(p);
    return n
}
var gvjs_Bca = {}
  , gvjs_yca = {}
  , gvjs_zca = {}
  , gvjs_Aca = {};
function gvjs_Cca(a, b, c) {
    this.mma = a;
    this.columns = [];
    this.WP = null != c ? c : !1;
    for (a = 0; a < b.length; a++)
        if (c = b[a],
        !gvjs_un[c])
            throw Error("Unsupported type: " + c);
    this.types = b
}
var gvjs_un = {
    number: function(a) {
        var b = Number(a);
        if (isNaN(b))
            throw Error("Not a number " + a);
        return b
    },
    string: function(a) {
        return a
    },
    "boolean": function(a) {
        return a.toLowerCase() === gvjs_Rd
    },
    date: function(a) {
        return new Date(a)
    },
    datetime: function(a) {
        return new Date(a)
    },
    timeofday: function(a) {
        return a.split(",")
    }
};
var gvjs_Dca = /\/spreadsheet/
  , gvjs_vn = /\/(ccc|tq|pub)$/
  , gvjs_Eca = new RegExp(/^spreadsheets?[0-9]?\.google\.com$/)
  , gvjs_Fca = new RegExp(/^docs\.google\.com*$/)
  , gvjs_wn = new RegExp(/^(trix|spreadsheets|docs|webdrive)(-[a-z]+)?\.(corp|sandbox)\.google\.com/)
  , gvjs_xn = new RegExp(/^(\w*\.){1,2}corp\.google\.com$/)
  , gvjs_Gca = /\/spreadsheets(\/d\/[^/]+)?/
  , gvjs_Hca = /\/(edit|gviz\/tq|)$/
  , gvjs_Ica = new RegExp(/^docs\.google\.com*$/)
  , gvjs_Jca = new RegExp(/^docs(-qa)?\.(corp|sandbox)\.google\.com*$/)
  , gvjs_yn = new RegExp(/^(\w*\.){1,2}corp\.google\.com$/)
  , gvjs_zn = /^\/a\/([\w-]+\.)+\w+/
  , gvjs_An = /^(\/a\/([\w-]+\.)+\w+)?/
  , gvjs_Kca = new RegExp(/^[a-z]+\d+:[a-z]+\d+$/i)
  , gvjs_Lca = new RegExp(/^[a-z]+\d+$/i);
function gvjs_Bn(a) {
    var b = gvjs_Rm(gvjs_Sm(3, a)) || ""
      , c = gvjs_Eca.test(b)
      , d = gvjs_wn.test(b)
      , e = gvjs_xn.test(b);
    b = gvjs_Fca.test(b);
    var f = gvjs_Rm(gvjs_Sm(5, a)) || ""
      , g = new RegExp(gvjs_An.source + gvjs_vn.source);
    f = (a = (new RegExp(gvjs_An.source + gvjs_Dca.source + gvjs_vn.source)).test(f)) || g.test(f);
    return b && a || (d || e || c) && f
}
function gvjs_Cn(a) {
    var b = gvjs_Rm(gvjs_Sm(3, a)) || ""
      , c = gvjs_Jca.test(b)
      , d = gvjs_yn.test(b);
    b = gvjs_Ica.test(b);
    a = gvjs_Rm(gvjs_Sm(5, a)) || "";
    a = (new RegExp(gvjs_An.source + gvjs_Gca.source + gvjs_Hca.source)).test(a);
    return (b || c || d) && a
}
;var gvjs_Dn = {
    WBa: "xhr",
    XBa: "xhrpost",
    kBa: "scriptInjection",
    Hia: gvjs_ad,
    YF: gvjs_ub
}
  , gvjs_vca = new gvjs_aj({
    "X-DataSource-Auth": "a"
});
function gvjs_En(a, b) {
    this.Cga = 30;
    this.cz = this.d_ = this.query = this.xU = this.Hw = null;
    this.Eea = !0;
    this.HK = 0;
    this.Q2 = !1;
    this.xJ = this.IK = null;
    this.Aba = this.ak = !1;
    this.iO = "";
    b = b || {};
    this.Zda = void 0 !== b.csvColumns;
    this.Cxa = null != b.strictJSON ? !!b.strictJSON : !0;
    this.Mla = b.csvColumns;
    this.WP = !!b.csvHasHeader;
    this.cT = b.sendMethod || gvjs_Dn.YF;
    this.fza = !!b.xhrWithCredentials;
    if (!gvjs__e(gvjs_Dn, this.cT))
        throw Error("Send method not supported: " + this.cT);
    this.tca = b.makeRequestParams || {};
    this.yh(a);
    this.requestId = gvjs_Mca++;
    gvjs_Nca.push(this)
}
gvjs_ = gvjs_En.prototype;
gvjs_.yh = function(a) {
    if (gvjs_Cn(a)) {
        var b = a;
        a = new gvjs_Xm(b);
        433 === a.Bw && gvjs_0m(a, null);
        var c = a.getPath();
        c = c.replace(/\/edit/, "/gviz/tq");
        a.setPath(c);
        c = gvjs_Rm(gvjs_Sm(3, b)) || "";
        b = null !== (Number(gvjs_Sm(4, b)) || null);
        b = gvjs_yn.test(c) && b;
        gvjs_Ym(a, b ? "http" : "https");
        a = a.toString()
    } else if (gvjs_Bn(a)) {
        c = a;
        a = new gvjs_Xm(c);
        433 === a.Bw && gvjs_0m(a, null);
        b = a.getPath();
        b = b.replace(/\/ccc$/, "/tq");
        /\/pub$/.test(b) && (b = b.replace(/\/pub$/, "/tq"),
        a.Ld("pub", "1"));
        a.setPath(b);
        b = gvjs_Rm(gvjs_Sm(3, c)) || "";
        c = null != (Number(gvjs_Sm(4, c)) || null);
        var d = gvjs_wn.test(b);
        b = gvjs_xn.test(b) && !d && c;
        gvjs_Ym(a, b ? "http" : "https");
        a = a.toString()
    }
    c = a;
    b = gvjs_Bn(c);
    c = gvjs_Rm(gvjs_Sm(5, c)) || "";
    c = gvjs_zn.test(c);
    (b = b && c) || (c = a,
    b = gvjs_Cn(c),
    c = gvjs_Rm(gvjs_Sm(5, c)) || "",
    c = gvjs_zn.test(c),
    b = b && c);
    this.Aba = b;
    this.iO = a
}
;
function gvjs_Fn(a, b) {
    var c = a.indexOf("#");
    -1 !== c && (a = a.substring(0, c));
    var d = a.indexOf("?")
      , e = [];
    -1 === d ? c = a : (c = a.substring(0, d),
    a = a.substring(d + 1),
    e = a.split("&"));
    a = [];
    for (d = 0; d < e.length; d++) {
        var f = {};
        f.name = e[d].split("=")[0];
        f.W1 = e[d];
        a.push(f)
    }
    for (var g in b)
        if (b.hasOwnProperty(g)) {
            e = b[g];
            f = !1;
            for (d = 0; d < a.length; d++)
                if (a[d].name === g) {
                    a[d].W1 = g + "=" + encodeURIComponent(e);
                    f = !0;
                    break
                }
            f || (d = {},
            d.name = g,
            d.W1 = g + "=" + encodeURIComponent(e),
            a.push(d))
        }
    b = c;
    if (0 < a.length) {
        b += "?";
        g = [];
        for (d = 0; d < a.length; d++)
            g.push(a[d].W1);
        b += g.join("&")
    }
    return b
}
function gvjs_Gn(a) {
    var b = a.reqId
      , c = gvjs_Hn[b];
    if (c)
        gvjs_Hn[b] = null,
        c.VC(a);
    else
        throw Error("Missing query for request id: " + b);
}
function gvjs_In(a, b, c, d) {
    a.VC({
        version: "0.6",
        status: gvjs_Rb,
        errors: [{
            reason: b,
            message: c,
            detailed_message: d
        }]
    })
}
gvjs_.IV = function(a) {
    var b = {};
    this.query && (b.tq = String(this.query));
    var c = "reqId:" + String(this.requestId)
      , d = this.xJ;
    d && (c += ";sig:" + d);
    this.d_ && (c += ";type:" + this.d_);
    b.tqx = c;
    if (this.cz) {
        c = [];
        for (var e in this.cz)
            this.cz.hasOwnProperty(e) && c.push(e + ":" + this.cz[e]);
        b.tqh = c.join(";")
    }
    a = gvjs_Fn(a, b);
    this.HK && (a = new gvjs_Xm(a),
    gvjs_tg && (gvjs_Zm(a),
    a.Ld("zx", gvjs_hg())),
    a = a.toString());
    return a
}
;
gvjs_.nr = function() {
    var a = this
      , b = this.IV(this.iO)
      , c = gvjs_Oh()
      , d = {};
    gvjs_Hn[String(this.requestId)] = this;
    var e = this.cT
      , f = "GET";
    "xhrpost" === e && (e = "xhr",
    f = "POST");
    e === gvjs_ub && (d = gvjs_Oca(b),
    e = d.sendMethod,
    d = d.options);
    if (e === gvjs_ad)
        if (gvjs_je("gadgets.io.makeRequest"))
            gvjs_Pca(this, b, this.tca);
        else
            throw Error("gadgets.io.makeRequest is not defined.");
    else if ("xhr" === e || e === gvjs_ub && gvjs_Qca(c.Vj().location.href, b))
        c = void 0,
        e = b,
        "POST" === f && (b = b.split("?"),
        1 <= b.length && (e = b[0]),
        2 <= b.length && (c = b[1])),
        gvjs_uca(e, function(g) {
            var h = a.requestId;
            g = g.target;
            if (gvjs_qn(g)) {
                try {
                    var k = g.Zb ? g.Zb.responseText : ""
                } catch (t) {
                    k = ""
                }
                k = gvjs_kf(k);
                if (a.Zda) {
                    var l = new gvjs_Cca(k,a.Mla,a.WP);
                    g = gvjs_xca(l.mma);
                    k = new gvjs_M;
                    if (g && 0 < g.length) {
                        for (var m = [], n = l.types, p = 0, q = n.length; p < q; p++)
                            m.push({
                                type: n[p]
                            });
                        if (l.WP)
                            for (n = 0,
                            p = m.length; n < p; n++)
                                m[n].label = g[0][n];
                        n = 0;
                        for (p = m.length; n < p; n++)
                            q = m[n],
                            k.xd(q.type || gvjs_l, q.label);
                        l.columns = m;
                        m = l.columns;
                        n = l = l.WP ? 1 : 0;
                        for (p = g.length; n < p; n++) {
                            k.Kp();
                            q = 0;
                            for (var r = m.length; q < r; q++)
                                k.Wb(n - l, q, gvjs_un[m[q].type || gvjs_l](g[n][q]))
                        }
                    }
                    g = {};
                    g.table = k.toJSON();
                    g.version = gvjs_Tk(g);
                    g.reqId = h;
                    gvjs_Gn(g)
                } else
                    k.match(/^({.*})$/) ? gvjs_Gn(gvjs_Li(k)) : gvjs_te(k)
            } else if (a.Hw)
                gvjs_In(a, gvjs_Kc, gvjs_sn(g));
            else
                throw Error("google.visualization.Query: " + gvjs_sn(g));
        }, f, c, this.fza || !!d.xhrWithCredentials);
    else {
        if (this.Zda)
            throw Error("CSV files on other domains are not supported. Please use sendMethod: 'xhr' or 'auto' and serve your .csv file from the same domain as this page.");
        f = gvjs_zh(c, gvjs_yb)[0];
        d = null === this.xJ;
        if (this.Aba && d) {
            d = c.createElement("IMG");
            gvjs_Rca(this, d, b);
            c.appendChild(f, d);
            return
        }
        gvjs_Jn(this, b)
    }
    this.Q2 && gvjs_Sca(this)
}
;
function gvjs_Rca(a, b, c) {
    b.onerror = function() {
        gvjs_Jn(a, c)
    }
    ;
    b.onload = function() {
        gvjs_Jn(a, c)
    }
    ;
    b.style.display = gvjs_f;
    var d = c + "&requireauth=1&" + (new Date).getTime();
    b.src = d
}
function gvjs_Oca(a) {
    var b = {};
    if (/[?&]alt=gviz(&[^&]*)*$/.test(a))
        a = gvjs_Dn.Hia;
    else {
        var c = (gvjs_Wm(a, "tqrt") || gvjs_Dn.YF).split(":");
        a = c[0];
        "xhr" !== a && "xhrpost" !== a || !gvjs_He(c, gvjs_Yd) || (b.xhrWithCredentials = !0);
        gvjs__e(gvjs_Dn, a) || (a = gvjs_Dn.YF)
    }
    return {
        sendMethod: a,
        options: b
    }
}
function gvjs_Qca(a, b) {
    b = (new gvjs_Xm(a)).resolve(new gvjs_Xm(b)).toString();
    a = a.match(gvjs_Qm);
    b = b.match(gvjs_Qm);
    return a[3] == b[3] && a[1] == b[1] && a[4] == b[4]
}
function gvjs_Pca(a, b, c) {
    var d = gvjs_je("gadgets.io");
    null == c[d.RequestParameters.CONTENT_TYPE] && (c[d.RequestParameters.CONTENT_TYPE] = d.ContentType.TEXT);
    null == c[d.RequestParameters.AUTHORIZATION] && (c[d.RequestParameters.AUTHORIZATION] = d.AuthorizationType.SIGNED);
    null == c.OAUTH_ENABLE_PRIVATE_NETWORK && (c.OAUTH_ENABLE_PRIVATE_NETWORK = !0);
    null == c.OAUTH_ADD_EMAIL && (c.OAUTH_ADD_EMAIL = !0);
    d.makeRequest(b, function() {
        return a.sqa
    }, c);
    gvjs_Kn(a)
}
gvjs_.sqa = function(a) {
    if (null != a && a.data)
        gvjs_te(a.data);
    else {
        var b = "";
        a && a.errors && (b = a.errors.join(" "));
        gvjs_In(this, "make_request_failed", "gadgets.io.makeRequest failed", b)
    }
}
;
function gvjs_Jn(a, b) {
    gvjs_Kn(a);
    a = a.Cxa || gvjs_rg;
    b.match(/^https?:\/\/spreadsheets.google.com/) && (a = !1);
    a ? gvjs_Tca(b) : (b = new gvjs_8m(b,0),
    b.DW = "google.visualization.Query.setResponse",
    b.EW = "",
    b.fetch().then(gvjs_Gn))
}
function gvjs_Tca(a) {
    gvjs_fn(a).then(function(b) {
        try {
            b = b.replace(/^[\s\S]*google\.visualization\.Query\.setResponse\(/g, ""),
            b = b.replace(/\);?[\s]*$/g, ""),
            gvjs_Gn(gvjs_Li(b))
        } catch (c) {
            throw Error("Error handling Query strict JSON response: " + c);
        }
    }, function(b) {
        throw Error("Error handling Query: " + b);
    })
}
function gvjs_Ln(a) {
    a.xU && (clearTimeout(a.xU),
    a.xU = null)
}
function gvjs_Kn(a) {
    gvjs_Ln(a);
    a.xU = setTimeout(function() {
        gvjs_In(a, "timeout", gvjs_4a)
    }, 1E3 * a.Cga)
}
gvjs_.np = function(a) {
    if (typeof a !== gvjs_g || 0 > a)
        throw Error("Refresh interval must be a non-negative number");
    this.HK = a;
    this.Q2 = !0
}
;
function gvjs_Mn(a) {
    a.IK && (clearTimeout(a.IK),
    a.IK = null)
}
function gvjs_Sca(a) {
    gvjs_Mn(a);
    if (0 !== a.HK && a.Eea && a.ak) {
        var b = function() {
            a.nr();
            a.IK = setTimeout(b, 1E3 * a.HK)
        };
        a.IK = setTimeout(b, 1E3 * a.HK);
        a.Q2 = !1
    }
}
gvjs_.send = function(a) {
    this.ak = !0;
    this.Hw = a;
    this.nr()
}
;
gvjs_.makeRequest = function(a, b) {
    this.ak = !0;
    this.Hw = a;
    this.cT = gvjs_ad;
    this.tca = b || {};
    this.nr()
}
;
gvjs_.abort = function() {
    this.ak = !1;
    gvjs_Ln(this);
    gvjs_Mn(this)
}
;
gvjs_.clear = function() {
    this.abort()
}
;
gvjs_.VC = function(a) {
    gvjs_Ln(this);
    a = new gvjs_Sk(a);
    if (!gvjs_Vk(a)) {
        this.xJ = a.Xk() ? null : a.m4;
        var b = this.Hw;
        b && b.call(b, a)
    }
}
;
gvjs_.setTimeout = function(a) {
    if (typeof a !== gvjs_g || isNaN(a) || 0 >= a)
        throw Error("Timeout must be a positive number");
    this.Cga = a
}
;
gvjs_.Fwa = function(a) {
    if (typeof a !== gvjs_zb)
        throw Error("Refreshable must be a boolean");
    return this.Eea = a
}
;
gvjs_.Jn = function(a) {
    if (typeof a !== gvjs_l)
        throw Error("queryString must be a string");
    this.query = a
}
;
gvjs_.Cwa = function(a) {
    this.d_ = a;
    null != a && this.Bfa(gvjs_Sd, a)
}
;
gvjs_.Bfa = function(a, b) {
    a = a.replace(/\\/g, "\\\\");
    b = b.replace(/\\/g, "\\\\");
    a = a.replace(/:/g, "\\c");
    b = b.replace(/:/g, "\\c");
    a = a.replace(/;/g, "\\s");
    b = b.replace(/;/g, "\\s");
    this.cz || (this.cz = {});
    this.cz[a] = b
}
;
var gvjs_Mca = 0
  , gvjs_Hn = {}
  , gvjs_Nca = [];
var gvjs_Nn = {
    Bar: gvjs_wb,
    Line: gvjs_e,
    Scatter: gvjs_Dd,
    AnnotatedTimeLine: gvjs_qb,
    AnnotationChart: gvjs_rb,
    AreaChart: gvjs_Jb,
    BarChart: gvjs_Jb,
    BubbleChart: gvjs_Jb,
    Calendar: "calendar",
    CandlestickChart: gvjs_Jb,
    ClusterChart: "clusterchart",
    ColumnChart: gvjs_Jb,
    ComboChart: gvjs_Jb,
    Gantt: "gantt",
    Gauge: "gauge",
    GeoChart: gvjs_Ub,
    GeoMap: "geomap",
    Histogram: gvjs_Jb,
    ImageAreaChart: gvjs_6c,
    ImageBarChart: gvjs_6c,
    ImageCandlestickChart: gvjs_6c,
    ImageChart: gvjs_6c,
    ImageLineChart: gvjs_6c,
    ImagePieChart: gvjs_6c,
    ImageSparkLine: gvjs_6c,
    LineChart: gvjs_Jb,
    Map: "map",
    MotionChart: gvjs_fd,
    OrgChart: gvjs_sd,
    PieChart: gvjs_Jb,
    RangeSelector: gvjs_Jb,
    Sankey: "sankey",
    ScatterChart: gvjs_Jb,
    SparklineChart: gvjs_Jb,
    SteppedAreaChart: gvjs_Jb,
    Table: gvjs_Ld,
    Timeline: gvjs_Nd,
    TreeMap: "treemap",
    VegaChart: "vegachart",
    WordTree: gvjs_Zd,
    StringFilter: gvjs_Ib,
    DateRangeFilter: gvjs_Ib,
    NumberRangeFilter: gvjs_Ib,
    CategoryFilter: gvjs_Ib,
    ChartRangeFilter: gvjs_Ib,
    NumberRangeSetter: gvjs_Ib,
    ColumnSelector: gvjs_Ib,
    Dashboard: gvjs_Ib
};
function gvjs_On(a, b) {
    var c = a.useFormatFromData;
    (typeof c !== gvjs_zb || c) && gvjs_jf(gvjs_gg(a.format)) && (b = gvjs_De(b, function(d) {
        return !gvjs_jf(gvjs_gg(d))
    }),
    gvjs_Pe(b),
    1 == b.length && (b = gvjs_Uca(b[0]),
    a.format = b))
}
function gvjs_Uca(a) {
    gvjs_jf(gvjs_gg(a)) || (a = a.replace(/\d/g, "0"),
    a = a.replace(/#{10,}/, gvjs_eg("#", 10)));
    return a
}
;function gvjs_Vca(a) {
    var b = gvjs_Wca(a)
      , c = new gvjs_N(a);
    c.Hn([0, 1, {
        type: gvjs_g,
        calc: function(d, e) {
            d = gvjs_Pn(a, e);
            return null != d ? b.slope * d.x + b.intercept : null
        }
    }]);
    return c
}
function gvjs_Wca(a) {
    var b = a.ca();
    for (var c = new gvjs_z, d = 0; d < b; d++) {
        var e = gvjs_Pn(a, d);
        null != e && (c.x += e.x,
        c.y += e.y)
    }
    b = new gvjs_z(c.x / b,c.y / b);
    for (e = d = c = 0; e < a.ca(); e++) {
        var f = gvjs_Pn(a, e);
        null != f && (f = new gvjs_z(f.x - b.x,f.y - b.y),
        c += f.x * f.y,
        d += f.x * f.x)
    }
    a = {};
    a.slope = c / d || 1;
    a.intercept = b.y - a.slope * b.x;
    return a
}
function gvjs_Pn(a, b) {
    var c = a.getValue(b, 0);
    a = a.getValue(b, 1);
    return null == c || null == a ? null : new gvjs_z(c,a)
}
;function gvjs_Xca(a) {
    var b = a.mb();
    if (b) {
        var c = a.getType();
        a = a.Zc();
        a: {
            var d = a.useFormatFromData;
            if (typeof d !== gvjs_zb || d) {
                d = [gvjs_Ud, gvjs_Md, "targetAxes.0", "targetAxes.1", gvjs_Pb];
                for (var e = 0; e < d.length; e++)
                    if (gvjs_je(d[e] + gvjs_ja, a)) {
                        d = !1;
                        break a
                    }
                d = !0
            } else
                d = !1
        }
        if (d)
            if (c == gvjs_ra)
                3 > b.$() || (c = b.Co(1),
                d = a.hAxis || {},
                gvjs_On(d, [c]),
                a.hAxis = d,
                b = b.Co(2),
                c = a.vAxes || {},
                d = c[0] || {},
                gvjs_On(d, [b]),
                c[0] = d,
                a.vAxes = c);
            else if (c != gvjs_La) {
                d = a.vAxes || [{}, {}];
                e = a.hAxis || {};
                for (var f = d[0] || {}, g = d[1] || {}, h = [], k = [], l = b && b.$() || 0, m, n = 0; n < l; n++)
                    if (b.W(n) == gvjs_g) {
                        m = b.Co(n);
                        var p = n;
                        0 == p ? p = null : (p--,
                        p = ((a.series || {})[p] || {}).targetAxisIndex || 0);
                        switch (p) {
                        case 0:
                            h.push(m);
                            break;
                        case 1:
                            k.push(m)
                        }
                    }
                c == gvjs_qa ? gvjs_On(e, h) : (gvjs_On(f, h),
                gvjs_On(g, k));
                0 < l && b.W(0) != gvjs_l && (c = c == gvjs_qa ? f : e,
                m = b.Co(0),
                gvjs_On(c, [m]));
                d[0] = f;
                d[1] = g;
                a.vAxes = d;
                a.hAxis = e
            }
    }
}
function gvjs_Yca(a) {
    if (a.getOption(gvjs_pb)) {
        var b = a.mb();
        a.getType() == gvjs_9a && 2 == b.$() && (b = gvjs_Vca(b),
        a.zh(b),
        a.ba("series.1.lineWidth", 2),
        a.ba("series.1.pointSize", 0),
        a.ba("series.1.visibleInLegend", !1));
        a.ba(gvjs_pb, null)
    }
}
function gvjs_Zca(a) {
    var b = a.mb()
      , c = a.Ni;
    if (Array.isArray(c))
        for (var d = 0; d < c.length; d++)
            b = gvjs_Rk(b, c[d]);
    else
        null != c && (b = gvjs_Rk(b, c));
    a.RE(null);
    a.zh(b)
}
function gvjs__ca(a) {
    var b = a.getType();
    if ((gvjs_Nn[b] || null) == gvjs_Jb && b != gvjs_9a) {
        b = a.mb();
        var c = a.getOption(gvjs_3c);
        if (null != c) {
            var d = [{
                calc: c ? gvjs_Id : "emptyString",
                sourceColumn: 0,
                type: gvjs_l
            }]
              , e = c ? 1 : 0;
            for (c = b.$(); e < c; e++)
                d.push(e);
            b = new gvjs_N(b);
            b.Hn(d);
            a.ba(gvjs_3c, null);
            a.zh(b)
        }
    }
}
;function gvjs_Qn(a) {
    gvjs_F.call(this);
    this.Fu = null;
    this.container = gvjs_Qh(a);
    this.Hg = new gvjs_wi(this,this.container);
    this.Lh = gvjs_fl()
}
gvjs_o(gvjs_Qn, gvjs_F);
gvjs_ = gvjs_Qn.prototype;
gvjs_.getContainer = function() {
    return this.container
}
;
gvjs_.La = gvjs_n(9);
gvjs_.getHeight = function(a, b) {
    return a.bD(gvjs_4c) || gvjs_Gh(this.container).height || b || 200
}
;
gvjs_.draw = function(a, b, c) {
    var d = this;
    gvjs_Zg(this.Hg, function() {
        gvjs_Kk(a);
        if (null == a)
            throw Error("Undefined or null data");
        d.Lh && d.Lh.promise.cancel();
        d.Lh = gvjs_fl();
        d.Fu && (d.Fu.vQ = !0);
        d.Fu = new gvjs_Yg(d.Hg);
        var e = d.Fu.xha.bind(d.Fu);
        d.Rd(e, a, b, c)
    })
}
;
gvjs_.ah = gvjs_n(24);
gvjs_.Jb = function() {
    this.Fu && (this.Fu.vQ = !0,
    this.Fu = null);
    this.Lh && this.Lh.promise && (this.Lh.promise.cancel(),
    this.Lh = null);
    this.He()
}
;
gvjs_.He = function() {}
;
gvjs_.M = function() {
    this.Jb();
    gvjs_F.prototype.M.call(this)
}
;
gvjs_Qn.prototype.clearChart = gvjs_Qn.prototype.Jb;
var gvjs_0ca = gvjs_D.Sc
  , gvjs_Rn = gvjs_D.uX;
function gvjs_Sn(a, b) {
    gvjs_F.call(this);
    b = b || {};
    typeof b === gvjs_l && (b = gvjs_Li(b));
    this.ma = b.container || null;
    this.Yx = b.containerId || null;
    this.HS = null;
    this.sM = a;
    this.Ei = b[a + "Name"] || "";
    this.Kr = null;
    this.pf = "";
    a = b[a + "Type"] || null;
    typeof a === gvjs_d ? (this.rp(""),
    this.Kr = a) : typeof a === gvjs_l && "" !== a ? (this.rp(a),
    this.Kr = null) : null == a && (this.rp(a),
    this.Kr = null);
    a = b.packages;
    this.eS = void 0 !== a ? a : null;
    this.MR = this.visualization = this.zD = null;
    this.Cba = b.isDefaultVisualization || void 0 === b.isDefaultVisualization;
    this.VU = null;
    this.cf = b.dataSourceUrl || null;
    this.vma = b.dataSourceChecksum || null;
    this.Z = null;
    this.zh(b.dataTable);
    this.m = b.options || {};
    this.K = b.state || {};
    this.Dw = b.query || null;
    this.rS = null;
    this.Ew = b.refreshInterval || null;
    this.Ni = b.view || null;
    this.pba = b.initialView || null;
    this.yH = null;
    this.e$ = [gvjs_Zca, gvjs__ca, gvjs_Xca, gvjs_Yca];
    this.Bea = null
}
gvjs_o(gvjs_Sn, gvjs_F);
gvjs_ = gvjs_Sn.prototype;
gvjs_.M = function() {
    this.clear();
    gvjs_F.prototype.M.call(this)
}
;
gvjs_.clear = function() {
    gvjs_Tn(this);
    gvjs_Un(this)
}
;
function gvjs_Tn(a) {
    a.rS && (a.rS.clear(),
    a.rS = null)
}
gvjs_.clone = function() {
    var a = this.Bp();
    a = new this.constructor(a);
    a.yH = this.yH;
    return a
}
;
gvjs_.toJSON = function() {
    var a = gvjs_Vn(this, this.mb());
    a.container = void 0;
    a.typeConstructor_ = void 0;
    return gvjs_Ii(a)
}
;
gvjs_.Bp = function() {
    return gvjs_Vn(this, this.Bea || this.mb())
}
;
function gvjs_Vn(a, b) {
    var c = a.eS
      , d = void 0;
    b && (b = b.Gr(),
    d = b.Bp());
    b = {
        container: a.ma || void 0,
        containerId: a.Yx || void 0,
        dataSourceChecksum: a.vma || void 0,
        dataSourceUrl: a.cf || void 0,
        dataTable: d,
        initialView: a.pba || void 0,
        options: a.Zc() || void 0,
        state: a.getState() || void 0,
        packages: null === c ? void 0 : c,
        refreshInterval: a.Ew || void 0,
        query: a.getQuery() || void 0,
        view: a.Ni || void 0,
        isDefaultVisualization: a.Bba()
    };
    b[a.sM + "Type"] = a.getType() || void 0;
    b[a.sM + "Name"] = a.getName() || void 0;
    a.S6(b);
    return b
}
gvjs_.S6 = function() {}
;
gvjs_.CZ = function() {
    return new this.constructor(this.Bp())
}
;
gvjs_.getName = function() {
    return this.Ei
}
;
gvjs_.rr = function(a) {
    this.Ei = a
}
;
gvjs_.getType = function() {
    return this.pf
}
;
gvjs_.rp = function(a) {
    this.pf = a;
    this.Kr = null
}
;
gvjs_.zZ = function() {
    return this.eS
}
;
gvjs_.oL = function(a) {
    this.eS = a
}
;
gvjs_.HZ = function() {
    return this.visualization
}
;
gvjs_.Jwa = function(a) {
    a != this.visualization && (this.MR = a)
}
;
gvjs_.Bba = function() {
    return this.Cba
}
;
gvjs_.Dfa = function(a) {
    this.Cba = a
}
;
gvjs_.Owa = function(a) {
    var b = arguments
      , c = this;
    gvjs_Wn(this);
    var d = [];
    gvjs_u([gvjs_i, gvjs_k, gvjs_Rb, gvjs_Hd], function(e) {
        var f = gvjs_oi(a, e, function() {
            e == gvjs_i && (c.zD = null,
            c.visualization = a);
            e != gvjs_i && e != gvjs_Hd || typeof a.getState !== gvjs_d || c.setState(a.getState.call(a));
            gvjs_I(c, e, b[0])
        });
        d.push(f)
    });
    this.VU = d
}
;
function gvjs_Un(a) {
    a.visualization && typeof a.visualization.Jb === gvjs_d && a.visualization.Jb();
    gvjs_Wn(a);
    gvjs_E(a.visualization);
    a.visualization = null
}
function gvjs_Wn(a) {
    Array.isArray(a.VU) && (gvjs_u(a.VU, function(b) {
        gvjs_ui(b)
    }),
    a.VU = null)
}
gvjs_.getContainer = function() {
    var a;
    if (!(a = this.ma))
        a: {
            var b = this.HS;
            if (null == b) {
                a = this.Yx;
                if (null == a) {
                    a = b;
                    break a
                }
                b = gvjs_Oh();
                var c = b.j(a);
                if (!b.Qo(c))
                    throw Error("The container #" + a + " is not defined.");
                b = this.HS = c
            }
            a = b
        }
    return a
}
;
gvjs_.jP = function() {
    return this.Yx
}
;
gvjs_.yfa = function(a) {
    this.HS = this.Yx = this.ma = null;
    typeof a === gvjs_l ? this.Yx = a : this.ma = a
}
;
gvjs_.mT = function(a) {
    this.HS = this.ma = null;
    this.Yx = a
}
;
gvjs_.kP = function() {
    return this.cf
}
;
gvjs_.yh = function(a) {
    a != this.cf && (gvjs_Tn(this),
    this.cf = a)
}
;
gvjs_.mb = function() {
    return this.Z
}
;
gvjs_.zh = function(a) {
    this.Z = gvjs_Lk(a)
}
;
gvjs_.EP = function() {
    return this.Ni
}
;
gvjs_.RE = function(a) {
    this.Ni = a
}
;
gvjs_.nva = function(a) {
    Array.isArray(this.Ni) ? this.Ni.push(a) : this.Ni = null === this.Ni ? [a] : [this.Ni, a]
}
;
gvjs_.getQuery = function() {
    return this.Dw
}
;
gvjs_.Jn = function(a) {
    this.Dw = a;
    gvjs_Tn(this)
}
;
gvjs_.nr = function(a, b) {
    b = void 0 === b ? !1 : b;
    gvjs_Tn(this);
    var c = this.rS = new gvjs_En(this.cf || "")
      , d = this.Ew;
    d && b && c.np(d);
    (b = this.getQuery()) && c.Jn(b);
    c.send(a)
}
;
gvjs_.xP = function() {
    return this.Ew
}
;
gvjs_.np = function(a) {
    this.Ew = a;
    gvjs_Tn(this)
}
;
gvjs_.Eoa = function() {
    return this.yH
}
;
gvjs_.xwa = function(a) {
    this.yH = a
}
;
gvjs_.getOption = function(a, b) {
    return gvjs_Xn(this.m, a, b)
}
;
function gvjs_Xn(a, b, c) {
    a = -1 == b.indexOf(".") ? a[b] : gvjs_je(b, a);
    return null != a ? a : void 0 !== c ? c : null
}
gvjs_.Zc = function() {
    return this.m
}
;
gvjs_.ba = function(a, b) {
    if (null == b) {
        if (b = this.m,
        null !== gvjs_Xn(b, a)) {
            var c = a.split(".");
            1 < c.length && (a = c.pop(),
            b = gvjs_Xn(b, c.join(".")));
            delete b[a]
        }
    } else
        gvjs_Yn(this.m, a, b)
}
;
function gvjs_Yn(a, b, c) {
    b = b.split(".");
    for (var d = 0; d < b.length; d++) {
        var e = b[d];
        d == b.length - 1 ? a[e] = c : (gvjs_r(a[e]) && a[e] !== Object.prototype[e] || (a[e] = {}),
        a = a[e])
    }
}
gvjs_.setOptions = function(a) {
    this.m = a || {}
}
;
gvjs_.getState = function() {
    return this.K
}
;
gvjs_.setState = function(a) {
    this.K = a || {}
}
;
gvjs_.A9 = function(a) {
    var b = this.mb();
    if (b)
        this.EO(a, b);
    else if (null != this.cf)
        b = this.lna.bind(this, a),
        a = gvjs_Rn(b, this.UZ.bind(this, a)),
        this.nr(a, !0);
    else
        throw Error("Cannot draw chart: no data specified.");
}
;
gvjs_.lna = function(a, b) {
    if (b.Xk()) {
        var c = b.sP()
          , d = b.nZ();
        a = gvjs_Xk(a, b);
        gvjs_I(this, gvjs_Rb, {
            id: a,
            message: c,
            detailedMessage: d
        })
    } else
        this.EO(a, b.mb())
}
;
gvjs_.EO = function(a, b) {
    var c = this.getType()
      , d = this.Kr || gvjs_Gm(c);
    if (!d)
        throw Error("Invalid " + this.sM + " type: " + (c || String(this.Kr) || "unknown"));
    this.Kr = d;
    this.MR && (gvjs_Un(this),
    this.visualization = this.MR,
    this.MR = null);
    if (c = this.visualization && this.visualization.constructor == d)
        c = (c = this.visualization) && typeof c.getContainer === gvjs_d ? c.getContainer() == a : !1;
    c ? a = this.visualization : (gvjs_Un(this),
    a = new d(a));
    this.zD && this.zD != a && typeof this.zD.Jb === gvjs_d && this.zD.Jb();
    this.zD = a;
    this.Owa(a);
    this.Bea = b;
    d = gvjs_jj(this.Zc());
    b = new gvjs_Sn(this.sM,{
        chartType: this.getType(),
        dataTable: b,
        options: d,
        view: this.Ni
    });
    for (d = 0; d < this.e$.length; d++)
        this.e$[d](b);
    a.draw(b.mb(), b.Zc(), this.getState())
}
;
gvjs_.draw = function(a) {
    a && this.yfa(a);
    a = this.getContainer();
    try {
        if (!this.Kr && (null == this.pf || "" === this.pf))
            throw Error("The " + this.sM + " type is not defined.");
        if (this.Kr)
            var b = this.Kr;
        else {
            var c = this.getType();
            b = gvjs_Gm(c)
        }
        if (b)
            this.A9(a);
        else {
            var d = this.A9.bind(this, a)
              , e = gvjs_Rn(d, this.UZ.bind(this, a))
              , f = this.eS;
            if (null == f) {
                var g = this.getType();
                g = g.replace(gvjs_1b, "");
                g = g.replace(gvjs_Yb, "");
                f = gvjs_Nn[g] || null;
                if (null == f)
                    throw Error("Invalid visualization type: " + g);
            }
            typeof f === gvjs_l && (f = [f]);
            b = {
                packages: f,
                callback: e
            };
            var h = gvjs_je(gvjs__c);
            null === h && (h = "current");
            gvjs_fca(h, b)
        }
    } catch (k) {
        this.UZ(a, k)
    }
}
;
gvjs_.UZ = function(a, b) {
    b = b && "undefined" != typeof b.message ? b.message : gvjs_Rb;
    a = gvjs_0ca(a, b);
    gvjs_I(this, gvjs_Rb, {
        id: a,
        message: b
    })
}
;
gvjs_.setProperty = function(a, b) {
    a = a.split(".");
    if (0 < a.length) {
        var c = a.shift();
        if (c = gvjs_1ca[c])
            0 === a.length ? c.set.apply(this, b) : (c = c.get.apply(this),
            gvjs_Yn(c, a.join("."), b))
    }
}
;
var gvjs_1ca = {
    name: {
        get: gvjs_Sn.prototype.getName,
        set: gvjs_Sn.prototype.rr
    },
    type: {
        get: gvjs_Sn.prototype.getType,
        set: gvjs_Sn.prototype.rp
    },
    container: {
        get: gvjs_Sn.prototype.getContainer,
        set: gvjs_Sn.prototype.yfa
    },
    containerId: {
        get: gvjs_Sn.prototype.jP,
        set: gvjs_Sn.prototype.mT
    },
    options: {
        get: gvjs_Sn.prototype.Zc,
        set: gvjs_Sn.prototype.setOptions
    },
    state: {
        get: gvjs_Sn.prototype.getState,
        set: gvjs_Sn.prototype.setState
    },
    dataSourceUrl: {
        get: gvjs_Sn.prototype.kP,
        set: gvjs_Sn.prototype.yh
    },
    dataTable: {
        get: gvjs_Sn.prototype.mb,
        set: gvjs_Sn.prototype.zh
    },
    refreshInterval: {
        get: gvjs_Sn.prototype.xP,
        set: gvjs_Sn.prototype.np
    },
    query: {
        get: gvjs_Sn.prototype.getQuery,
        set: gvjs_Sn.prototype.Jn
    },
    view: {
        get: gvjs_Sn.prototype.EP,
        set: gvjs_Sn.prototype.RE
    }
};
function gvjs_Zn() {
    this.mh = new gvjs_aj;
    this.$s = new gvjs_aj;
    this.Hu = new gvjs_aj
}
function gvjs__n(a, b, c) {
    gvjs_0n(a, b, c) || (a.mh.set(gvjs_1n(b), b),
    a.mh.set(gvjs_1n(c), c),
    gvjs_2n(b, c, a.$s),
    gvjs_2n(c, b, a.Hu))
}
gvjs_ = gvjs_Zn.prototype;
gvjs_.clear = function() {
    this.mh.clear();
    this.$s.clear();
    this.Hu.clear()
}
;
gvjs_.isEmpty = function() {
    return this.mh.isEmpty()
}
;
gvjs_.DQ = function() {
    try {
        return gvjs_2ca(this),
        !0
    } catch (a) {
        return !1
    }
}
;
gvjs_.Cd = function() {
    return this.mh.Cd()
}
;
gvjs_.ob = function() {
    return this.mh.ob()
}
;
gvjs_.contains = function(a) {
    return this.mh.tf(gvjs_1n(a))
}
;
function gvjs_0n(a, b, c) {
    b = gvjs_1n(b);
    return a.$s.tf(b) && a.$s.get(b).has(gvjs_1n(c))
}
function gvjs_3n(a, b) {
    if (!a.contains(b))
        return null;
    var c = a.Hu.get(gvjs_1n(b));
    if (!c)
        return null;
    b = [];
    c = gvjs_8d(c);
    for (var d = c.next(); !d.done; d = c.next())
        b.push(a.mh.get(d.value));
    return b
}
gvjs_.getChildren = function(a) {
    if (!this.contains(a))
        return null;
    var b = this.$s.get(gvjs_1n(a));
    if (!b)
        return null;
    a = [];
    b = gvjs_8d(b);
    for (var c = b.next(); !c.done; c = b.next())
        a.push(this.mh.get(c.value));
    return a
}
;
function gvjs_4n(a) {
    if (a.mh.isEmpty())
        return [];
    var b = [];
    gvjs_gj(a.$s, function(c, d) {
        this.Hu.tf(d) || b.push(this.mh.get(d))
    }, a);
    if (0 == b.length)
        throw Error("Invalid state: DAG has not root node(s).");
    return b
}
function gvjs_2ca(a) {
    for (var b = gvjs_3ca(a.Hu), c = [], d = gvjs_v(gvjs_4n(a), function(l) {
        return gvjs_1n(l)
    }, a); 0 < d.length; ) {
        for (var e = [], f = 0; f < d.length; f++) {
            var g = d[f];
            c.push(a.mh.get(g));
            var h = a.$s.get(g);
            if (h) {
                h = gvjs_8d(h);
                for (var k = h.next(); !k.done; k = h.next())
                    k = k.value,
                    b.get(k).delete(g),
                    0 === b.get(k).size && (b.remove(k),
                    e.push(k))
            }
        }
        d = e
    }
    if (c.length != a.mh.Cd())
        throw Error("cycle detected");
}
gvjs_.clone = function() {
    return this.isEmpty() ? new gvjs_Zn : gvjs_Zn.prototype.WO.apply(this, gvjs_4n(this))
}
;
gvjs_.WO = function(a) {
    var b = new gvjs_Zn;
    if (0 == arguments.length)
        return b;
    for (var c = 0; c < arguments.length; c++)
        gvjs_5n(this, arguments[c], b);
    return b
}
;
function gvjs_5n(a, b, c) {
    var d = a.getChildren(b);
    if (d) {
        d = gvjs_8d(d);
        for (var e = d.next(); !e.done; e = d.next())
            e = e.value,
            gvjs__n(c, b, e),
            gvjs_5n(a, e, c)
    }
}
function gvjs_1n(a) {
    var b = typeof a;
    return b == gvjs_h && a || b == gvjs_d ? "o" + gvjs_pe(a) : b.substr(0, 1) + a
}
function gvjs_2n(a, b, c) {
    var d = c.get(gvjs_1n(a));
    d || (d = new Set,
    c.set(gvjs_1n(a), d));
    d.add(gvjs_1n(b))
}
function gvjs_6n(a, b, c) {
    var d = c.get(gvjs_1n(a));
    d.delete(gvjs_1n(b));
    0 === d.size && c.remove(gvjs_1n(a))
}
function gvjs_7n(a, b) {
    return !a.$s.tf(gvjs_1n(b)) && !a.Hu.tf(gvjs_1n(b))
}
function gvjs_3ca(a) {
    var b = new gvjs_aj;
    gvjs_gj(a, function(c, d) {
        b.set(d, new Set(c))
    });
    return b
}
;function gvjs_P(a) {
    gvjs_Sn.call(this, "control", a)
}
gvjs_o(gvjs_P, gvjs_Sn);
gvjs_ = gvjs_P.prototype;
gvjs_.Oy = gvjs_Sn.prototype.HZ;
gvjs_.twa = gvjs_Sn.prototype.rp;
gvjs_.Doa = gvjs_Sn.prototype.getType;
gvjs_.swa = gvjs_Sn.prototype.rr;
gvjs_.Coa = gvjs_Sn.prototype.getName;
function gvjs_8n(a, b) {
    return new Set([].concat(gvjs_9d(a)).filter(function(c) {
        return !b.has(c)
    }))
}
function gvjs_9n(a, b) {
    return a.size === b.size && [].concat(gvjs_9d(a)).every(function(c) {
        return b.has(c)
    })
}
function gvjs_$n() {
    this.pj = new Set;
    this.dl = new Set;
    this.nk = new Set
}
gvjs_ = gvjs_$n.prototype;
gvjs_.clear = function() {
    this.pj = new Set;
    this.dl = new Set;
    this.nk = new Set
}
;
gvjs_.clone = function() {
    var a = new gvjs_$n;
    a.pj = new Set(this.pj);
    a.dl = new Set(gvjs_nj(this.dl));
    a.nk = new Set(gvjs_nj(this.nk));
    return a
}
;
gvjs_.equals = function(a) {
    return gvjs_9n(this.pj, a.pj) && gvjs_9n(this.dl, a.dl) && gvjs_9n(this.nk, a.nk)
}
;
function gvjs_ao(a, b) {
    return gvjs_nj(b === gvjs_Cd ? a.pj : a.dl).map(function(c) {
        return Number(c)
    })
}
function gvjs_bo(a) {
    return gvjs_ao(a, gvjs_Cd)
}
function gvjs_co(a) {
    return gvjs_nj(a.nk).map(function(b) {
        b = b.split(",");
        return {
            row: Number(b[0]),
            column: Number(b[1])
        }
    })
}
gvjs_.getSelection = function() {
    var a = gvjs_bo(this)
      , b = gvjs_ao(this, gvjs_Fb)
      , c = gvjs_co(this);
    return [].concat(gvjs_9d(a.map(function(d) {
        var e = {};
        return e.row = d,
        e.column = null,
        e
    })), gvjs_9d(b.map(function(d) {
        var e = {};
        return e.row = null,
        e.column = d,
        e
    })), gvjs_9d(c.map(function(d) {
        var e = {};
        return e.row = d.row,
        e.column = d.column,
        e
    })))
}
;
gvjs_.contains = function(a, b) {
    return a === gvjs_Cd ? gvjs_do(this, b[0]) : a === gvjs_Fb ? gvjs_eo(this, b[0]) : gvjs_fo(this, b[0], b[1])
}
;
function gvjs_do(a, b) {
    return a.pj.has(String(b))
}
function gvjs_eo(a, b) {
    return a.dl.has(String(b))
}
function gvjs_fo(a, b, c) {
    return a.nk.has(String(b + "," + c))
}
gvjs_.add = function(a, b) {
    if (this.contains(a, b))
        return !1;
    a === gvjs_Cd ? this.pj.add(String(b[0])) : a === gvjs_Fb ? this.dl.add(String(b[0])) : this.nk.add(String(b[0] + "," + b[1]));
    return !0
}
;
gvjs_.Kp = function(a) {
    return this.add(gvjs_Cd, [a])
}
;
gvjs_.xd = function(a) {
    return this.add(gvjs_Fb, [a])
}
;
function gvjs_go(a, b, c) {
    a.add("cell", [b, c])
}
gvjs_.qE = function(a) {
    if (!gvjs_do(this, a))
        return !1;
    this.pj.delete(String(a));
    return !0
}
;
gvjs_.BS = function(a) {
    if (!gvjs_eo(this, a))
        return !1;
    this.dl.delete(String(a));
    return !0
}
;
gvjs_.MK = function(a, b) {
    gvjs_fo(this, a, b) && this.nk.delete(String(a + "," + b))
}
;
gvjs_.setSelection = function(a) {
    var b = new Set
      , c = new Set
      , d = new Set;
    a || (a = []);
    for (var e = 0; e < a.length; e++) {
        var f = a[e];
        null != f.row && null != f.column ? d.add("" + f.row + "," + f.column) : null != f.row ? b.add(String(f.row)) : null != f.column && c.add(String(f.column))
    }
    var g = gvjs_8n(b, this.pj)
      , h = gvjs_8n(c, this.dl)
      , k = gvjs_8n(d, this.nk);
    a = gvjs_8n(this.pj, b);
    e = gvjs_8n(this.dl, c);
    f = gvjs_8n(this.nk, d);
    this.pj = b;
    this.dl = c;
    this.nk = d;
    b = new gvjs_$n;
    b.pj = g;
    b.dl = h;
    b.nk = k;
    c = new gvjs_$n;
    c.pj = a;
    c.dl = e;
    c.nk = f;
    return new gvjs_4ca(b,c)
}
;
function gvjs_4ca(a, b) {
    this.uB = a;
    this.An = b
}
;function gvjs_ho(a) {
    gvjs_F.call(this);
    this.ph = new gvjs_Zn;
    this.Se = new gvjs_$n;
    this.v3 = {};
    this.RB = {};
    this.ZI = null;
    this.wD = [];
    this.Sd = new gvjs_wi(this,a);
    this.Tm = null
}
gvjs_t(gvjs_ho, gvjs_F);
gvjs_ = gvjs_ho.prototype;
gvjs_.getSelection = function() {
    return this.Se.getSelection()
}
;
gvjs_.M = function() {
    this.clear();
    gvjs_ho.G.M.call(this)
}
;
gvjs_.clear = function() {
    gvjs_u(this.wD, function(a) {
        gvjs_ui(a)
    });
    this.wD = [];
    this.Tm = null;
    this.ph.clear()
}
;
gvjs_.bind = function(a, b) {
    if (gvjs_io(a) && typeof a.Oy === gvjs_d)
        if (gvjs_io(b)) {
            var c = gvjs_pe(a);
            if (gvjs_pe(b) == c)
                this.Sd.Sc("Cannot bind a control to itself.");
            else {
                c = [];
                this.ph.contains(a) || c.push(a);
                this.ph.contains(b) || c.push(b);
                gvjs__n(this.ph, a, b);
                if (this.ph.DQ())
                    var d = !0;
                else
                    this.Sd.Sc("The requested control and participant cannot be bound together, as this would introduce a dependency cycle"),
                    d = !1;
                if (d)
                    for (a = 0; a < c.length; a++)
                        b = c[a],
                        this.wD.push(gvjs_oi(b, gvjs_Hd, gvjs_s(this.Iqa, this, b))),
                        this.wD.push(gvjs_oi(b, gvjs_i, gvjs_s(this.Gqa, this, b))),
                        this.wD.push(gvjs_oi(b, gvjs_Rb, gvjs_s(this.Fqa, this, b))),
                        b.getChart && this.wD.push(gvjs_oi(b, gvjs_k, gvjs_s(this.Hqa, this, b)));
                else
                    c = this.ph,
                    gvjs_0n(c, a, b) && (gvjs_6n(a, b, c.$s),
                    gvjs_6n(b, a, c.Hu),
                    gvjs_7n(c, a) && c.mh.remove(gvjs_1n(a)),
                    gvjs_7n(c, b) && c.mh.remove(gvjs_1n(b)))
            }
        } else
            this.Sd.Sc(b + " does not fit either the Control or Visualization specification.");
    else
        this.Sd.Sc(a + " does not fit the Control specification.")
}
;
gvjs_.draw = function(a) {
    if (a && !this.ph.isEmpty()) {
        this.ZI = gvjs_Lk(a);
        this.Tm = new gvjs_jo(this);
        a = gvjs_4n(this.ph);
        for (var b = 0; b < a.length; b++)
            a[b].zh(this.ZI);
        this.Tm.start(a)
    }
}
;
function gvjs_io(a) {
    return gvjs_r(a) && typeof a.draw === gvjs_d && typeof a.setDataTable === gvjs_d
}
gvjs_.Iqa = function(a) {
    this.Tm = this.Tm || new gvjs_jo(this);
    gvjs_ko(this.Tm, a)
}
;
gvjs_.Gqa = function(a) {
    var b;
    if (b = gvjs_io(a) && typeof a.Oy === gvjs_d) {
        b = a.Oy();
        if (gvjs_r(b))
            if (typeof b.i7 === gvjs_d)
                a: {
                    b = this.ph;
                    for (var c = b.WO(a), d = c.ob(), e = 0; e < d.length; e++) {
                        var f = d[e];
                        if (f != a && gvjs_3n(c, f).length != gvjs_3n(b, f).length) {
                            b = !1;
                            break a
                        }
                    }
                    b = !0
                }
            else
                b = typeof b.apply === gvjs_d ? !0 : !1;
        else
            b = !1;
        b = !b
    }
    b ? this.Sd.Sc(a + " does not fit the Control specification while handling 'ready' event.") : (this.Tm = this.Tm || new gvjs_jo(this),
    gvjs_ko(this.Tm, a))
}
;
function gvjs_lo(a, b) {
    var c = b.row;
    b = b.column;
    if (null != c || null != b)
        null == c ? a.Se.BS(b) : null == b ? a.Se.qE(c) : a.Se.MK(c, b)
}
gvjs_.Hqa = function(a) {
    var b = gvjs_pe(a)
      , c = a.getChart().getSelection();
    this.v3[b] || (this.v3[b] = new gvjs_$n);
    c = gvjs_De(gvjs_v(c, function(e) {
        for (var f = a.mb(); f !== this.ZI; ) {
            e = {
                row: null == e.row ? null : f.getTableRowIndex(e.row),
                column: null == e.column ? null : f.getTableColumnIndex(e.column)
            };
            0 > e.row && (e.row = null);
            0 > e.column && (e.column = null);
            if (null == e.row && null == e.column)
                return null;
            f = f.mb()
        }
        return e
    }, this), function(e) {
        return null != e
    });
    var d = this.v3[b].setSelection(c);
    c = d.uB.getSelection();
    d = d.An.getSelection();
    gvjs_u(c, function(e) {
        var f = e.row + "," + e.column;
        this.RB[f] || (this.RB[f] = new Set);
        this.RB[f].add(b);
        f = e.row;
        e = e.column;
        if (null != f || null != e)
            null == f ? this.Se.xd(e) : null == e ? this.Se.Kp(f) : gvjs_go(this.Se, f, e)
    }, this);
    gvjs_u(d, function(e) {
        var f = e.row + "," + e.column;
        this.RB[f] ? (this.RB[f].delete(b),
        0 === this.RB[f].size && gvjs_lo(this, e)) : gvjs_lo(this, e)
    }, this)
}
;
gvjs_.Fqa = function(a) {
    this.Tm && this.Tm.handleError(a)
}
;
function gvjs_5ca(a, b) {
    b ? gvjs_I(a, gvjs_i, null) : a.Sd.Sc("One or more participants failed to draw()");
    a.Tm = null
}
function gvjs_6ca(a, b) {
    if (1 == b.length)
        return b[0];
    var c = b[0]
      , d = gvjs_Oe(b, 1)
      , e = new Set(gvjs_mo(a, d[0]));
    for (b = 1; b < d.length && (e = gvjs_oj(e, new Set(gvjs_mo(a, d[b]))),
    0 !== e.size); b++)
        ;
    b = [];
    for (var f = 0; f < c.ca(); f++)
        e.has(gvjs_no(a, c, f)) && b.push(f);
    e = new Set(gvjs_oo(a, d[0]));
    for (f = 1; f < d.length && (e = gvjs_oj(e, new Set(gvjs_oo(a, d[f]))),
    0 !== e.size); f++)
        ;
    d = [];
    for (f = 0; f < c.$(); f++)
        e.has(gvjs_po(a, c, f)) && d.push(f);
    a = new gvjs_N(c);
    a.pp(b);
    a.Hn(d);
    return a
}
function gvjs_mo(a, b) {
    for (var c = [], d = 0; d < b.ca(); d++) {
        var e = gvjs_no(a, b, d);
        null != e && c.push(e)
    }
    return c
}
function gvjs_no(a, b, c) {
    for (; b !== a.ZI; )
        c = b.fj(c),
        b = b.mb();
    return c
}
function gvjs_oo(a, b) {
    for (var c = [], d = 0; d < b.$(); d++) {
        var e = gvjs_po(a, b, d);
        null != e && c.push(e)
    }
    return c
}
function gvjs_po(a, b, c) {
    for (; b !== a.ZI && -1 !== c; )
        c = b.CP(c),
        b = b.mb();
    -1 == c && (c = null);
    return c
}
function gvjs_jo(a) {
    this.Xp = a;
    this.ph = a.ph.clone();
    this.zr = {};
    a = this.ph.ob();
    for (var b = 0; b < a.length; b++)
        this.zr[gvjs_pe(a[b])] = gvjs_i
}
gvjs_jo.prototype.start = function(a) {
    gvjs_jo.prototype.yca.apply(this, a);
    for (var b = 0; b < a.length; b++)
        this.Mj(a[b])
}
;
function gvjs_ko(a, b) {
    if (a.ph.contains(b)) {
        switch (a.zr[gvjs_pe(b)]) {
        case "pending":
            break;
        case gvjs_Rb:
            break;
        case gvjs_Qb:
            a.zr[gvjs_pe(b)] = gvjs_i;
            gvjs_qo(a, b);
            break;
        case gvjs_i:
            a.yca(b);
            gvjs_qo(a, b);
            break;
        default:
            gvjs_pe(b)
        }
        gvjs_ro(a)
    }
}
gvjs_jo.prototype.handleError = function(a) {
    if (this.ph.contains(a)) {
        switch (this.zr[gvjs_pe(a)]) {
        case "pending":
        case gvjs_i:
        case gvjs_Rb:
            break;
        case gvjs_Qb:
            this.zr[gvjs_pe(a)] = gvjs_Rb;
            a = this.ph.WO(a).ob();
            for (var b = 1; b < a.length; b++)
                this.zr[gvjs_pe(a[b])] = gvjs_Rb;
            break;
        default:
            gvjs_pe(a)
        }
        gvjs_ro(this)
    }
}
;
function gvjs_ro(a) {
    var b = 0;
    gvjs_Ve(a.zr, function(c) {
        if (c == gvjs_Rb)
            b++;
        else if (c != gvjs_i)
            return !1;
        return !0
    }, a) && gvjs_5ca(a.Xp, 0 == b)
}
gvjs_jo.prototype.yca = function(a) {
    for (var b = gvjs_Zn.prototype.WO.apply(this.ph, arguments), c = b.ob(), d = 0; d < c.length; d++) {
        var e = b
          , f = c[d];
        if (!e.contains(f) || e.Hu.tf(gvjs_1n(f)))
            this.zr[gvjs_pe(c[d])] = "pending"
    }
}
;
gvjs_jo.prototype.Mj = function(a) {
    this.zr[gvjs_pe(a)] = gvjs_Qb;
    var b = (0,
    gvjs_D.uX)(gvjs_s(function() {
        a.draw()
    }, this), gvjs_s(this.handleError, this, a));
    gvjs_pl(b)
}
;
function gvjs_qo(a, b) {
    var c = a.ph.getChildren(b);
    if (c) {
        if ("undefined" === typeof b.Oy)
            throw Error("Dashboard participant is not a control.");
        b = b.Oy();
        b.zfa && b.zfa(c);
        for (b = 0; b < c.length; b++) {
            var d = c[b];
            a: {
                var e = a;
                var f = gvjs_3n(e.ph, d);
                if (f)
                    for (var g = 0; g < f.length; g++)
                        if (e.zr[gvjs_pe(f[g])] != gvjs_i) {
                            e = !1;
                            break a
                        }
                e = !0
            }
            e && (e = gvjs_7ca(a, d),
            d.zh(e),
            a.Mj(d))
        }
    }
}
function gvjs_7ca(a, b) {
    b = gvjs_v(gvjs_3n(a.ph, b), function(c) {
        c = c.Oy();
        if (typeof c.apply === gvjs_d)
            return c.apply.call(c)
    });
    return gvjs_6ca(a.Xp, b)
}
;function gvjs_so(a) {
    gvjs_F.call(this);
    this.ma = a;
    this.Xp = new gvjs_ho(this.ma);
    gvjs_E(this.N2);
    this.N2 = gvjs_oi(this.Xp, gvjs_i, gvjs_s(this.laa, this, gvjs_i));
    gvjs_E(this.zY);
    this.zY = gvjs_oi(this.Xp, gvjs_Rb, gvjs_s(this.laa, this, gvjs_Rb))
}
gvjs_t(gvjs_so, gvjs_F);
gvjs_ = gvjs_so.prototype;
gvjs_.M = function() {
    this.clear();
    gvjs_E(this.N2);
    gvjs_E(this.zY);
    gvjs_E(this.Xp);
    gvjs_so.G.M.call(this)
}
;
gvjs_.clear = function() {
    gvjs_ui(this.N2);
    gvjs_ui(this.zY);
    this.Xp.clear()
}
;
gvjs_.bind = function(a, b) {
    Array.isArray(a) || (a = [a]);
    Array.isArray(b) || (b = [b]);
    for (var c = 0; c < a.length; c++)
        for (var d = 0; d < b.length; d++)
            this.Xp.bind(a[c], b[d]);
    return this
}
;
gvjs_.draw = function(a) {
    this.Xp.draw(a)
}
;
gvjs_.getContainer = function() {
    return this.ma
}
;
gvjs_.getSelection = function() {
    return this.Xp.getSelection()
}
;
gvjs_.laa = function(a, b) {
    gvjs_I(this, a, b || null)
}
;
function gvjs_to(a, b) {
    this.Fva = a;
    this.iO = b
}
gvjs_to.prototype.send = function(a) {
    this.Hw = a;
    this.nr()
}
;
gvjs_to.prototype.IV = function(a) {
    var b = {}, c, d = this.xJ;
    d && (c = "sig:" + d);
    c && (b.tqx = c,
    a = gvjs_Fn(a, b));
    return a
}
;
gvjs_to.prototype.nr = function() {
    var a = this
      , b = this.IV(this.iO);
    this.Fva.call(this, function(c) {
        a.VC(c)
    }, b)
}
;
gvjs_to.prototype.VC = function(a) {
    a = new gvjs_Sk(a);
    if (!gvjs_Vk(a)) {
        this.xJ = a.Xk() ? null : a.m4;
        var b = this.Hw;
        if (!b)
            throw Error("Response handler undefined.");
        b.call(b, a)
    }
}
;
function gvjs_uo(a, b, c, d) {
    this.query = a;
    this.container = d;
    this.Hg = this.Ta = this.W8 = this.BX = this.OX = null;
    this.options = c || {};
    this.visualization = b;
    d && (this.Hg = this.OX = gvjs_8ca(d));
    if (!(b && "draw"in b) || typeof b.draw !== gvjs_d)
        throw Error("Visualization must have a draw method.");
}
function gvjs_8ca(a) {
    return function(b) {
        (0,
        gvjs_D.removeAll)(a);
        var c = b.Xk();
        c && gvjs_Xk(a, b);
        return !c
    }
}
gvjs_ = gvjs_uo.prototype;
gvjs_.setOptions = function(a) {
    this.options = a || {}
}
;
gvjs_.draw = function() {
    this.visualization && this.visualization.draw(this.Ta, this.options)
}
;
gvjs_.wwa = function(a) {
    var b = this.container;
    this.Hg = a ? a : b ? this.Hg = this.OX : null
}
;
gvjs_.GE = function() {
    var a = this;
    if (!this.Hg)
        throw Error("If no container was supplied, a custom error handler must be supplied instead.");
    this.query.send(function(b) {
        var c = a.BX;
        c && c(b);
        a.VC(b);
        (c = a.W8) && c(b)
    })
}
;
gvjs_.VC = function(a) {
    var b = this.Hg;
    b(a) && this.visualization && (this.Ta = a.mb(),
    this.visualization.draw(this.Ta, this.options))
}
;
gvjs_.oT = function(a) {
    if (null == a)
        this.BX = null;
    else {
        if (typeof a !== gvjs_d)
            throw Error(gvjs_Aa);
        this.BX = a
    }
}
;
gvjs_.nT = function(a) {
    if (null != a) {
        if (typeof a !== gvjs_d)
            throw Error("Custom post response handler must be a function.");
        this.W8 = a
    }
}
;
gvjs_.abort = function() {
    this.query.abort()
}
;
function gvjs_Q(a) {
    gvjs_Sn.call(this, gvjs_Bb, a)
}
gvjs_o(gvjs_Q, gvjs_Sn);
gvjs_ = gvjs_Q.prototype;
gvjs_.zf = gvjs_Sn.prototype.HZ;
gvjs_.jT = gvjs_Sn.prototype.Jwa;
gvjs_.cc = gvjs_Sn.prototype.rp;
gvjs_.Va = gvjs_Sn.prototype.getType;
gvjs_.C3 = gvjs_Sn.prototype.rr;
gvjs_.iZ = gvjs_Sn.prototype.getName;
function gvjs_vo(a) {
    a = a || {};
    typeof a === gvjs_l && (a = gvjs_Li(a));
    return a.dashboardType ? new (gvjs_je(gvjs_hc))(a) : a.controlType ? new gvjs_P(a) : new gvjs_Q(a)
}
;function gvjs_wo(a, b) {
    gvjs_vo(a).draw(b)
}
;function gvjs_xo(a) {
    gvjs_Sn.call(this, "dashboard", a);
    a = a || {};
    typeof a === gvjs_l && (a = gvjs_Li(a));
    this.nN = this.se = null;
    gvjs_yo(this, a.wrappers, a.bindings);
    this.rp(a.dashboardType || "Dashboard")
}
gvjs_o(gvjs_xo, gvjs_Sn);
gvjs_ = gvjs_xo.prototype;
gvjs_.EO = function(a, b) {
    function c(m) {
        return f[m]
    }
    gvjs_E(this.visualization);
    a = gvjs_Qh(a);
    for (var d = new gvjs_so(a), e = this.nN || [], f = this.se, g = e.length, h = 0; h < g; h++) {
        var k = gvjs_v(e[h].controls, c)
          , l = gvjs_v(e[h].participants, c);
        d.bind(k, l)
    }
    this.visualization = d;
    gvjs_Sn.prototype.EO.call(this, a, b)
}
;
gvjs_.S6 = function(a) {
    a.wrappers = this.se ? gvjs_v(this.se, function(b) {
        return b.toJSON()
    }) : void 0;
    a.bindings = this.nN || void 0
}
;
gvjs_.Kwa = function(a) {
    gvjs_yo(this, a, null)
}
;
gvjs_.Xoa = function() {
    return this.se
}
;
gvjs_.qwa = function(a) {
    gvjs_yo(this, null, a)
}
;
gvjs_.yoa = function() {
    return this.nN
}
;
function gvjs_yo(a, b, c) {
    if (null !== b && !Array.isArray(b)) {
        var d = [];
        gvjs_w(b, function(e, f) {
            var g;
            gvjs_zo(e) || (g = gvjs_vo(e));
            g.rr(f);
            d.push(g)
        });
        b = d
    }
    gvjs_Ao(b) && gvjs_Ao(c) || (a.se = gvjs_v(b, a.A1, a),
    a.nN = gvjs_v(c, a.Vta, a))
}
gvjs_.A1 = function(a) {
    gvjs_zo(a) || (a = gvjs_vo(a));
    a.zh(null);
    a.yh(null);
    return a
}
;
gvjs_.Vta = function(a) {
    var b = a.controls
      , c = a.participants;
    if (gvjs_Ao(b) || gvjs_Ao(c))
        throw Error("invalid binding: " + a);
    b = gvjs_v(b, this.k$, this);
    c = gvjs_v(c, this.k$, this);
    return {
        controls: b,
        participants: c
    }
}
;
gvjs_.k$ = function(a) {
    var b = a
      , c = /^{.*}$/;
    if (gvjs_r(a) || typeof a === gvjs_l && c.test(a))
        return gvjs_zo(b) || (b = gvjs_vo(b)),
        this.se.push(b),
        this.se.length - 1;
    a = gvjs_9ca(this);
    a = gvjs_jf(gvjs_gg(b)) ? -1 : gvjs_Be(a, b);
    if (-1 == a)
        throw Error("Invalid wrapper name: " + b);
    return a
}
;
function gvjs_zo(a) {
    return typeof a.toJSON === gvjs_d
}
function gvjs_9ca(a) {
    return (a.se || []).map(function(b) {
        return b.getName()
    })
}
function gvjs_Ao(a) {
    return Array.isArray(a) ? 0 == a.length : !0
}
gvjs_.Foa = gvjs_Sn.prototype.HZ;
gvjs_.zwa = gvjs_Sn.prototype.rr;
gvjs_.Goa = gvjs_Sn.prototype.getName;
if (gvjs_y && gvjs_y)
    try {
        new ActiveXObject("MSXML2.DOMDocument")
    } catch (a) {}
;function gvjs_Bo(a) {
    this.options = a || {}
}
gvjs_Bo.prototype.format = function(a, b) {
    if (a.W(b) === gvjs_g)
        for (var c = this.options.base || 0, d = 0; d < a.ca(); d++) {
            var e = a.getValue(d, b);
            a.setProperty(d, b, gvjs_Db, null != e && e < c ? "google-visualization-formatters-arrow-dr" : null != e && e > c ? "google-visualization-formatters-arrow-ug" : "google-visualization-formatters-arrow-empty")
        }
}
;
gvjs_Bo.prototype.Jo = function(a) {
    return a === gvjs_g ? a : null
}
;
function gvjs_Co(a) {
    this.options = a || {}
}
function gvjs_Do(a, b, c) {
    0 < b && c.push('<span class="google-charts-bar-' + (a || "w") + '" style="width:' + b + 'px;"></span>')
}
gvjs_Co.prototype.format = function(a, b) {
    var c = a.W(b);
    if (null != this.Jo(c)) {
        c = this.options;
        var d = c.min
          , e = c.max
          , f = null;
        if (null == d || null == e)
            f = a.Sj(b),
            null == e && (e = f.max),
            null == d && (d = Math.min(0, f.min));
        d >= e && (f = f || a.Sj(b),
        e = f.max,
        d = f.min);
        d === e && (0 === d ? e = 1 : 0 < d ? d = 0 : e = 0);
        f = e - d;
        var g = c.base || 0;
        g = Math.max(d, Math.min(e, g));
        var h = c.width || 100
          , k = c.showValue;
        null == k && (k = !0);
        for (var l = Math.round((g - d) / f * h), m = h - l, n = 0; n < a.ca(); n++) {
            var p = Number(a.getValue(n, b))
              , q = [];
            p = Math.max(d, Math.min(e, p));
            var r = Math.ceil((p - d) / f * h);
            q.push('<span class="google-visualization-formatters-bars">');
            gvjs_Do("s", 1, q);
            var t = gvjs_Eo(c.colorPositive, "b")
              , u = gvjs_Eo(c.colorNegative, "r")
              , v = c.drawZeroLine ? 1 : 0;
            0 < l ? p < g ? (gvjs_Do("w", r, q),
            gvjs_Do(u, l - r, q),
            0 < v && gvjs_Do("z", v, q),
            gvjs_Do("w", m, q)) : (gvjs_Do("w", l, q),
            0 < v && gvjs_Do("z", v, q),
            gvjs_Do(t, r - l, q),
            gvjs_Do("w", h - r, q)) : (gvjs_Do(t, r, q),
            gvjs_Do("w", h - r, q));
            gvjs_Do("s", 1, q);
            p = a.getProperty(n, b, gvjs_nb);
            null == p && (p = a.Ha(n, b),
            a.setProperty(n, b, gvjs_nb, p));
            k && (q.push("\u00a0"),
            q.push(p));
            q.push("</span>\u00a0");
            a.Nw(n, b, q.join(""))
        }
    }
}
;
gvjs_Co.prototype.Jo = function(a) {
    return a === gvjs_g ? a : null
}
;
function gvjs_Eo(a, b) {
    a = (a || "").toLowerCase();
    return gvjs_$ca[a] || b
}
var gvjs_$ca = {
    red: "r",
    blue: "b",
    green: "g"
};
function gvjs_Fo(a, b, c, d) {
    null != a && a instanceof Date && (a = a.getTime());
    null != b && b instanceof Date && (b = b.getTime());
    null != a && Array.isArray(a) && (a = gvjs_Go(a));
    null != b && Array.isArray(b) && (b = gvjs_Go(b));
    this.from = a;
    this.uk = b;
    this.color = c;
    this.Pp = d
}
gvjs_Fo.prototype.contains = function(a) {
    var b = this.from
      , c = this.uk;
    if (null == a)
        return null == b && null == c;
    a instanceof Date ? a = a.getTime() : Array.isArray(a) && (a = gvjs_Go(a));
    return (null == b || a >= b) && (null == c || a < c)
}
;
gvjs_Fo.prototype.ee = function() {
    return this.color
}
;
gvjs_Fo.prototype.getBackgroundColor = function() {
    return this.Pp
}
;
function gvjs_Ho(a, b, c, d, e) {
    gvjs_Fo.call(this, a, b, c, "");
    this.sS = 0;
    typeof a === gvjs_g && typeof b === gvjs_g && (this.sS = b - a,
    0 >= this.sS && (this.sS = 1));
    this.roa = gvjs_vj(gvjs_qj(d).hex);
    this.hya = gvjs_vj(gvjs_qj(e).hex)
}
gvjs_o(gvjs_Ho, gvjs_Fo);
gvjs_Ho.prototype.getBackgroundColor = function(a) {
    if (typeof a !== gvjs_g)
        return "";
    a = gvjs_xj(this.roa, this.hya, 1 - (a - this.from) / this.sS);
    return gvjs_wj(a[0], a[1], a[2])
}
;
function gvjs_Io() {
    this.tS = []
}
gvjs_Io.prototype.addRange = function(a, b, c, d) {
    this.tS.push(new gvjs_Fo(a,b,c,d))
}
;
gvjs_Io.prototype.dka = function(a, b, c, d, e) {
    this.tS.push(new gvjs_Ho(a,b,c,d,e))
}
;
gvjs_Io.prototype.format = function(a, b) {
    var c = a.W(b);
    if (null != this.Jo(c))
        for (c = 0; c < a.ca(); c++) {
            for (var d = a.getValue(c, b), e = "", f = 0; f < this.tS.length; f++) {
                var g = this.tS[f];
                if ("undefined" !== typeof d && g.contains(d)) {
                    f = g.ee();
                    d = g.getBackgroundColor(d);
                    f && (e += gvjs_Eb + f + ";");
                    d && (e += gvjs_vb + d + ";");
                    break
                }
            }
            a.setProperty(c, b, gvjs_Jd, e)
        }
}
;
gvjs_Io.prototype.Jo = function(a) {
    return a !== gvjs_Lb && a !== gvjs_Mb && a !== gvjs_Od && a !== gvjs_g && a !== gvjs_l ? null : a
}
;
function gvjs_Go(a) {
    return 36E5 * a[0] + 6E4 * a[1] + 1E3 * a[2] + (4 === a.length ? a[3] : 0)
}
;function gvjs_Jo(a) {
    this.pattern = a || ""
}
gvjs_Jo.prototype.format = function(a, b, c, d) {
    var e = b[0];
    null != c && typeof c === gvjs_g && (e = c);
    d = d || null;
    for (c = 0; c < a.ca(); c++) {
        var f = this.pattern.replace(/{(\d+)}/g, function(g) {
            return function(h, k, l, m) {
                return 0 < l && "\\" === m[l - 1] ? h : a.Ha(g, b[Number(k)])
            }
        }(c));
        f = f.replace(/\\(.)/g, "$1");
        d ? a.setProperty(c, e, d, f) : a.Nw(c, e, f)
    }
}
;
gvjs_Jo.prototype.Jo = function(a) {
    return a
}
;
gvjs_q("google.visualization.drawChart", gvjs_wo, void 0);
gvjs_q("google.visualization.createUrl", function(a, b) {
    typeof a === gvjs_l && (a = gvjs_Li(a));
    var c = [], d;
    for (d in a)
        if ("options" == d) {
            var e = a[d], f;
            for (f in e) {
                var g = e[f];
                typeof g !== gvjs_l && (g = gvjs_Ii(g));
                c.push(f + "=" + encodeURIComponent(String(g)))
            }
        } else
            g = a[d],
            typeof g !== gvjs_l && (g = typeof g.toJSON === gvjs_d ? g.toJSON() : gvjs_Ii(g)),
            c.push(d + "=" + encodeURIComponent(String(g)));
    a = gvjs_Cm() + "/chart.html";
    a = a.replace(/^https?:/, "");
    c = (b || a) + "?" + c.join("&");
    c = c.replace(/'/g, "%27");
    return c = c.replace(/"/g, "%22")
}, void 0);
gvjs_q("google.visualization.createSnippet", function(a) {
    var b = gvjs_Cm() + "/chart.js";
    b = b.replace(/^https?:/, "");
    b = '<script type="text/javascript" src="' + b + '">\n';
    a = gvjs_vo(a).toJSON();
    a = a.replace(/</g, gvjs_fa);
    a = a.replace(/>/g, "&gt;");
    return b + a + "\n\x3c/script>"
}, void 0);
gvjs_q("google.visualization.createWrapper", gvjs_vo, void 0);
gvjs_q("google.visualization.ChartWrapper", gvjs_Q, void 0);
gvjs_Q.prototype.clear = gvjs_Q.prototype.clear;
gvjs_Q.prototype.draw = gvjs_Q.prototype.draw;
gvjs_Q.prototype.clone = gvjs_Q.prototype.clone;
gvjs_Q.prototype.toJSON = gvjs_Q.prototype.toJSON;
gvjs_Q.prototype.getSnapshot = gvjs_Q.prototype.CZ;
gvjs_Q.prototype.getDataSourceUrl = gvjs_Q.prototype.kP;
gvjs_Q.prototype.getDataTable = gvjs_Q.prototype.mb;
gvjs_Q.prototype.getChartName = gvjs_Q.prototype.iZ;
gvjs_Q.prototype.getChartType = gvjs_Q.prototype.Va;
gvjs_Q.prototype.getChart = gvjs_Q.prototype.zf;
gvjs_Q.prototype.getContainerId = gvjs_Q.prototype.jP;
gvjs_Q.prototype.getPackages = gvjs_Q.prototype.zZ;
gvjs_Q.prototype.getQuery = gvjs_Q.prototype.getQuery;
gvjs_Q.prototype.getRefreshInterval = gvjs_Q.prototype.xP;
gvjs_Q.prototype.getView = gvjs_Q.prototype.EP;
gvjs_Q.prototype.getOption = gvjs_Q.prototype.getOption;
gvjs_Q.prototype.getOptions = gvjs_Q.prototype.Zc;
gvjs_Q.prototype.getState = gvjs_Q.prototype.getState;
gvjs_Q.prototype.getCustomRequestHandler = gvjs_Q.prototype.Eoa;
gvjs_Q.prototype.isDefaultVisualization = gvjs_Q.prototype.Bba;
gvjs_Q.prototype.pushView = gvjs_Q.prototype.nva;
gvjs_Q.prototype.safeDraw = gvjs_Q.prototype.draw;
gvjs_Q.prototype.sendQuery = gvjs_Q.prototype.nr;
gvjs_Q.prototype.setDataSourceUrl = gvjs_Q.prototype.yh;
gvjs_Q.prototype.setDataTable = gvjs_Q.prototype.zh;
gvjs_Q.prototype.setChart = gvjs_Q.prototype.jT;
gvjs_Q.prototype.setChartName = gvjs_Q.prototype.C3;
gvjs_Q.prototype.setChartType = gvjs_Q.prototype.cc;
gvjs_Q.prototype.setContainerId = gvjs_Q.prototype.mT;
gvjs_Q.prototype.setIsDefaultVisualization = gvjs_Q.prototype.Dfa;
gvjs_Q.prototype.setPackages = gvjs_Q.prototype.oL;
gvjs_Q.prototype.setQuery = gvjs_Q.prototype.Jn;
gvjs_Q.prototype.setRefreshInterval = gvjs_Q.prototype.np;
gvjs_Q.prototype.setView = gvjs_Q.prototype.RE;
gvjs_Q.prototype.setOption = gvjs_Q.prototype.ba;
gvjs_Q.prototype.setOptions = gvjs_Q.prototype.setOptions;
gvjs_Q.prototype.setState = gvjs_Q.prototype.setState;
gvjs_Q.prototype.setCustomRequestHandler = gvjs_Q.prototype.xwa;
gvjs_q("google.visualization.ControlWrapper", gvjs_P, void 0);
gvjs_P.prototype.clear = gvjs_P.prototype.clear;
gvjs_P.prototype.draw = gvjs_P.prototype.draw;
gvjs_P.prototype.toJSON = gvjs_P.prototype.toJSON;
gvjs_P.prototype.getSnapshot = gvjs_P.prototype.CZ;
gvjs_P.prototype.getDataSourceUrl = gvjs_P.prototype.kP;
gvjs_P.prototype.getDataTable = gvjs_P.prototype.mb;
gvjs_P.prototype.getControlName = gvjs_P.prototype.Coa;
gvjs_P.prototype.getControlType = gvjs_P.prototype.Doa;
gvjs_P.prototype.getControl = gvjs_P.prototype.Oy;
gvjs_P.prototype.getContainerId = gvjs_P.prototype.jP;
gvjs_P.prototype.getPackages = gvjs_P.prototype.zZ;
gvjs_P.prototype.getQuery = gvjs_P.prototype.getQuery;
gvjs_P.prototype.getRefreshInterval = gvjs_P.prototype.xP;
gvjs_P.prototype.getView = gvjs_P.prototype.EP;
gvjs_P.prototype.getOption = gvjs_P.prototype.getOption;
gvjs_P.prototype.getOptions = gvjs_P.prototype.Zc;
gvjs_P.prototype.getState = gvjs_P.prototype.getState;
gvjs_P.prototype.sendQuery = gvjs_P.prototype.nr;
gvjs_P.prototype.setDataSourceUrl = gvjs_P.prototype.yh;
gvjs_P.prototype.setDataTable = gvjs_P.prototype.zh;
gvjs_P.prototype.setControlName = gvjs_P.prototype.swa;
gvjs_P.prototype.setControlType = gvjs_P.prototype.twa;
gvjs_P.prototype.setContainerId = gvjs_P.prototype.mT;
gvjs_P.prototype.setPackages = gvjs_P.prototype.oL;
gvjs_P.prototype.setQuery = gvjs_P.prototype.Jn;
gvjs_P.prototype.setRefreshInterval = gvjs_P.prototype.np;
gvjs_P.prototype.setView = gvjs_P.prototype.RE;
gvjs_P.prototype.setOption = gvjs_P.prototype.ba;
gvjs_P.prototype.setOptions = gvjs_P.prototype.setOptions;
gvjs_P.prototype.setState = gvjs_P.prototype.setState;
gvjs_q(gvjs_hc, gvjs_xo, void 0);
gvjs_xo.prototype.clear = gvjs_xo.prototype.clear;
gvjs_xo.prototype.draw = gvjs_xo.prototype.draw;
gvjs_xo.prototype.toJSON = gvjs_xo.prototype.toJSON;
gvjs_xo.prototype.getBindings = gvjs_xo.prototype.yoa;
gvjs_xo.prototype.getDataSourceUrl = gvjs_xo.prototype.kP;
gvjs_xo.prototype.getDataTable = gvjs_xo.prototype.mb;
gvjs_xo.prototype.getDashboard = gvjs_xo.prototype.Foa;
gvjs_xo.prototype.getDashboardName = gvjs_xo.prototype.Goa;
gvjs_xo.prototype.getContainerId = gvjs_xo.prototype.jP;
gvjs_xo.prototype.getPackages = gvjs_xo.prototype.zZ;
gvjs_xo.prototype.getQuery = gvjs_xo.prototype.getQuery;
gvjs_xo.prototype.getRefreshInterval = gvjs_xo.prototype.xP;
gvjs_xo.prototype.getView = gvjs_xo.prototype.EP;
gvjs_xo.prototype.getWrappers = gvjs_xo.prototype.Xoa;
gvjs_xo.prototype.setBindings = gvjs_xo.prototype.qwa;
gvjs_xo.prototype.setDataSourceUrl = gvjs_xo.prototype.yh;
gvjs_xo.prototype.setDataTable = gvjs_xo.prototype.zh;
gvjs_xo.prototype.setDashboardName = gvjs_xo.prototype.zwa;
gvjs_xo.prototype.setContainerId = gvjs_xo.prototype.mT;
gvjs_xo.prototype.setPackages = gvjs_xo.prototype.oL;
gvjs_xo.prototype.setQuery = gvjs_xo.prototype.Jn;
gvjs_xo.prototype.setRefreshInterval = gvjs_xo.prototype.np;
gvjs_xo.prototype.setView = gvjs_xo.prototype.RE;
gvjs_xo.prototype.getSnapshot = gvjs_xo.prototype.CZ;
gvjs_xo.prototype.setWrappers = gvjs_xo.prototype.Kwa;
function gvjs_Ko(a) {
    for (var b = 0, c = 0; c < a.length; c++)
        b += a[c];
    return b
}
function gvjs_Lo(a) {
    return a.length
}
function gvjs_Mo(a) {
    return gvjs_Ko(a) / a.length
}
;function gvjs_No(a, b, c) {
    function d(r, t, u, v) {
        return t(u.getValue(v, r))
    }
    c = void 0 === c ? [] : c;
    for (var e = [], f = [], g = gvjs_8d(b), h = g.next(); !h.done; h = g.next())
        if (h = h.value,
        typeof h === gvjs_g)
            e.push(h);
        else if (typeof h === gvjs_h) {
            var k = a.jf(h.column);
            "modifier"in h && f.push({
                bla: {
                    calc: gvjs_re(d, k, h.modifier),
                    type: h.type,
                    label: h.label,
                    id: h.id
                },
                Jta: e.length
            });
            e.push(k)
        }
    if (0 < f.length) {
        g = new gvjs_N(a);
        h = g.FZ();
        f = gvjs_8d(f);
        for (k = f.next(); !k.done; k = f.next()) {
            k = k.value;
            var l = h.length;
            h[l] = k.bla;
            e[k.Jta] = l
        }
        g.Hn(h);
        a = g
    }
    var m = new gvjs_M;
    f = [];
    for (g = 0; g < e.length; g++) {
        l = b[g];
        var n = e[g];
        h = a.W(n);
        k = typeof l === gvjs_h && null != l.label ? l.label : a.Ga(n);
        l = typeof l === gvjs_h && null != l.id ? l.id : a.Ne(n);
        m.xd(h, k, l);
        f.push(h)
    }
    g = gvjs_8d(c);
    for (h = g.next(); !h.done; h = g.next())
        h = h.value,
        l = a.jf(h.column),
        k = h.label || a.Ga(l),
        l = null != h.id ? h.id : a.Ne(l),
        m.xd(h.type, k, l);
    g = e.map(function(r) {
        return {
            column: r
        }
    });
    var p = a.bn(g)
      , q = [];
    for (g = 0; g < c.length; g++)
        q.push([]);
    for (g = {
        Sr: 0
    }; g.Sr < p.length; g = {
        BM: g.BM,
        Sr: g.Sr,
        gV: g.gV
    },
    g.Sr++) {
        for (h = 0; h < c.length; h++)
            q[h].push(a.getValue(p[g.Sr], a.jf(c[h].column)));
        h = !1;
        if (g.Sr < p.length - 1)
            for (h = !0,
            k = 0; k < e.length; k++)
                if (l = a.getValue(p[g.Sr], e[k]),
                n = a.getValue(p[g.Sr + 1], e[k]),
                0 !== gvjs_vk(f[k], l, n)) {
                    h = !1;
                    break
                }
        if (!h)
            for (g.BM = m.Kp(),
            gvjs_u(e, function(r) {
                return function(t, u) {
                    m.Wa(r.BM, u, a.getValue(p[r.Sr], t))
                }
            }(g)),
            g.gV = b.length,
            gvjs_u(c, function(r) {
                return function(t, u) {
                    t = (0,
                    t.aggregation)(q[u]);
                    m.Wa(r.BM, r.gV + u, t)
                }
            }(g)),
            h = 0; h < c.length; h++)
                q[h] = []
    }
    return m
}
;function gvjs_Oo(a, b, c) {
    var d = b.W(c)
      , e = b.Ne(c)
      , f = b.Ga(c);
    d = a.xd(d, f, e);
    a.lT(d, b.Rj(c))
}
;gvjs_q("google.visualization.data.avg", gvjs_Mo, void 0);
gvjs_q("google.visualization.data.count", gvjs_Lo, void 0);
gvjs_q("google.visualization.data.group", gvjs_No, void 0);
gvjs_q("google.visualization.data.join", function(a, b, c, d, e, f) {
    d = d.map(function(B) {
        return [a.jf(B[0]), b.jf(B[1])]
    });
    e = e.map(a.jf.bind(a));
    f = f.map(b.jf.bind(b));
    for (var g = c === gvjs_$c || c === gvjs_Tb, h = c === gvjs_j || c === gvjs_Tb, k = new gvjs_M, l = d.map(function(B) {
        var D = a.W(B[0])
          , C = b.W(B[1]);
        if (D !== C)
            throw Error("Key types do not match:" + D + gvjs_ha + C);
        gvjs_Oo(k, a, B[0]);
        return D
    }), m = [], n = [], p = gvjs_8d(d), q = p.next(); !q.done; q = p.next()) {
        var r = q.value;
        m.push({
            column: r[0]
        });
        n.push({
            column: r[1]
        })
    }
    m = a.bn(m);
    n = b.bn(n);
    p = gvjs_8d(e);
    for (q = p.next(); !q.done; q = p.next())
        gvjs_Oo(k, a, q.value);
    p = gvjs_8d(f);
    for (q = p.next(); !q.done; q = p.next())
        gvjs_Oo(k, b, q.value);
    p = !1;
    for (var t = r = 0, u = 0; r < m.length || t < n.length; ) {
        var v = 0
          , w = [];
        if (t >= n.length)
            if (g)
                w[0] = m[r],
                v = -1;
            else
                break;
        else if (r >= m.length)
            if (h)
                w[1] = n[t],
                v = 1;
            else
                break;
        else {
            w[0] = m[r];
            w[1] = n[t];
            for (var x = 0; x < d.length && (v = a.getValue(w[0], d[x][0]),
            q = b.getValue(w[1], d[x][1]),
            v = gvjs_vk(l[x], v, q),
            0 === v); x++)
                ;
        }
        if (p && 0 !== v)
            p = !1,
            t++;
        else {
            if (-1 === v && g || 1 === v && h || 0 === v) {
                k.Kp();
                var y = void 0
                  , z = void 0;
                -1 === v && g || 0 === v && c !== gvjs_j ? (y = a,
                z = 0) : (y = b,
                z = 1);
                x = 0;
                var A = gvjs_8d(d);
                for (q = A.next(); !q.done; q = A.next())
                    q = q.value,
                    c === gvjs_Tb ? k.Wa(u, x, y.getValue(w[z], q[z])) : k.Wb(u, x, y.getValue(w[z], q[z]), y.Ha(w[z], q[z]), y.getProperties(w[z], q[z])),
                    x++;
                if (-1 === v && g || 0 === v)
                    for (y = d.length,
                    x = 0,
                    z = gvjs_8d(e),
                    q = z.next(); !q.done; q = z.next())
                        q = q.value,
                        k.Wb(u, x + y, a.getValue(w[0], q), a.Ha(w[0], q), a.getProperties(w[0], q)),
                        x++;
                if (1 === v && h || 0 === v)
                    for (y = e.length + d.length,
                    x = 0,
                    z = gvjs_8d(f),
                    q = z.next(); !q.done; q = z.next())
                        q = q.value,
                        k.Wb(u, x + y, b.getValue(w[1], q), b.Ha(w[1], q), b.getProperties(w[1], q)),
                        x++;
                u++
            }
            1 === v ? t++ : r++;
            0 === v && (p = !0)
        }
    }
    return k
}, void 0);
gvjs_q("google.visualization.data.max", function(a) {
    if (0 === a.length)
        return null;
    for (var b = a[0], c = 1; c < a.length; c++) {
        var d = a[c];
        null != d && d > b && (b = d)
    }
    return b
}, void 0);
gvjs_q("google.visualization.data.min", function(a) {
    if (0 === a.length)
        return null;
    for (var b = a[0], c = 1; c < a.length; c++) {
        var d = a[c];
        null != d && d < b && (b = d)
    }
    return b
}, void 0);
gvjs_q("google.visualization.data.month", function(a) {
    return a.getMonth() + 1
}, void 0);
gvjs_q("google.visualization.data.sum", gvjs_Ko, void 0);
function gvjs_Po(a, b) {
    gvjs_Ai.call(this);
    if (a instanceof gvjs_Ai)
        this.bd = a;
    else if (null == a)
        this.bd = new gvjs_M;
    else {
        this.data = a;
        a: {
            if (b && (a = b ? gvjs_kj(b, this.data) : this.data,
            Array.isArray(a))) {
                b = a[0];
                a = Array.isArray(b) ? gvjs_Mk(a) : typeof b === gvjs_h ? gvjs_Nk(a) : gvjs_dba(a);
                break a
            }
            a = new gvjs_M
        }
        this.bd = a
    }
}
gvjs_o(gvjs_Po, gvjs_Ai);
gvjs_ = gvjs_Po.prototype;
gvjs_.getData = function() {
    return this.data
}
;
gvjs_.Py = function(a) {
    return this.bd.Py(a)
}
;
gvjs_.ca = function() {
    return this.bd.ca()
}
;
gvjs_.$ = function() {
    return this.bd.$()
}
;
gvjs_.Do = gvjs_n(18);
gvjs_.Ne = function(a) {
    return this.bd.Ne(a)
}
;
gvjs_.Ga = function(a) {
    return this.bd.Ga(a)
}
;
gvjs_.Co = function(a) {
    return this.bd.Co(a)
}
;
gvjs_.Jg = function(a) {
    return this.bd.Jg(a)
}
;
gvjs_.W = function(a) {
    return this.bd.W(a)
}
;
gvjs_.getValue = function(a, b) {
    return this.bd.getValue(a, b)
}
;
gvjs_.si = function(a, b) {
    return this.bd.si(a, b)
}
;
gvjs_.Ha = function(a, b) {
    return this.bd.Ha(a, b)
}
;
gvjs_.Nw = function(a, b, c) {
    this.bd.Nw(a, b, c)
}
;
gvjs_.format = function(a, b) {
    this.bd.format(a, b)
}
;
gvjs_.Sj = function(a) {
    return this.bd.Sj(a)
}
;
gvjs_.getProperty = function(a, b, c) {
    return this.bd.getProperty(a, b, c)
}
;
gvjs_.setProperty = function(a, b, c, d) {
    this.bd.setProperty(a, b, c, d)
}
;
gvjs_.getProperties = function(a, b) {
    return this.bd.getProperties(a, b)
}
;
gvjs_.Sy = function(a) {
    return this.bd.Sy(a)
}
;
gvjs_.Cv = function() {
    return this.bd.Cv()
}
;
gvjs_.Ul = function(a, b) {
    return this.bd.Ul(a, b)
}
;
gvjs_.zv = function(a) {
    return this.bd.zv(a)
}
;
gvjs_.Bd = function(a, b) {
    return this.bd.Bd(a, b)
}
;
gvjs_.Rj = function(a) {
    return this.bd.Rj(a)
}
;
gvjs_.bn = function(a) {
    return this.bd.bn(a)
}
;
gvjs_.at = function(a) {
    return this.bd.at(a)
}
;
gvjs_.fj = function(a) {
    return this.bd.fj(a)
}
;
gvjs_.Ty = function(a) {
    return this.bd.Ty(a)
}
;
gvjs_.Uy = function(a) {
    return this.bd.Uy(a)
}
;
gvjs_.Gr = function() {
    return this.bd.Gr()
}
;
gvjs_.Bp = function() {
    return this.bd.Bp()
}
;
gvjs_.toJSON = function() {
    return this.bd.toJSON()
}
;
gvjs_q(gvjs_Kc, gvjs_En, void 0);
gvjs_En.prototype.makeRequest = gvjs_En.prototype.makeRequest;
gvjs_En.prototype.setRefreshInterval = gvjs_En.prototype.np;
gvjs_En.prototype.setQuery = gvjs_En.prototype.Jn;
gvjs_En.prototype.send = gvjs_En.prototype.send;
gvjs_En.prototype.setRefreshable = gvjs_En.prototype.Fwa;
gvjs_En.prototype.setTimeout = gvjs_En.prototype.setTimeout;
gvjs_En.prototype.setHandlerType = gvjs_En.prototype.Cwa;
gvjs_En.prototype.setHandlerParameter = gvjs_En.prototype.Bfa;
gvjs_En.setResponse = gvjs_Gn;
gvjs_En.prototype.abort = gvjs_En.prototype.abort;
gvjs_En.prototype.clear = gvjs_En.prototype.clear;
gvjs_q("google.visualization.CustomQuery", gvjs_to, void 0);
gvjs_to.prototype.send = gvjs_to.prototype.send;
gvjs_q("google.visualization.QueryResponse", gvjs_Sk, void 0);
gvjs_Sk.prototype.getDataTable = gvjs_Sk.prototype.mb;
gvjs_Sk.prototype.isError = gvjs_Sk.prototype.Xk;
gvjs_Sk.prototype.hasWarning = gvjs_Sk.prototype.j_;
gvjs_Sk.prototype.getReasons = gvjs_Sk.prototype.Q$;
gvjs_Sk.prototype.getMessage = gvjs_Sk.prototype.sP;
gvjs_Sk.prototype.getDetailedMessage = gvjs_Sk.prototype.nZ;
gvjs_Sk.addErrorFromQueryResponse = gvjs_Xk;
gvjs_q("google.visualization.Data", gvjs_Po, void 0);
gvjs_Po.prototype.getColumnId = gvjs_Po.prototype.Ne;
gvjs_Po.prototype.getColumnIndex = gvjs_Po.prototype.jf;
gvjs_Po.prototype.getColumnLabel = gvjs_Po.prototype.Ga;
gvjs_Po.prototype.getColumnPattern = gvjs_Po.prototype.Co;
gvjs_Po.prototype.getColumnProperty = gvjs_Po.prototype.Bd;
gvjs_Po.prototype.getColumnProperty = gvjs_Po.prototype.Bd;
gvjs_Po.prototype.getColumnProperties = gvjs_Po.prototype.Rj;
gvjs_Po.prototype.getColumnRange = gvjs_Po.prototype.Sj;
gvjs_Po.prototype.getColumnRole = gvjs_Po.prototype.Jg;
gvjs_Po.prototype.getColumnType = gvjs_Po.prototype.W;
gvjs_Po.prototype.getDistinctValues = gvjs_Po.prototype.Py;
gvjs_Po.prototype.getFilteredRows = gvjs_Po.prototype.at;
gvjs_Po.prototype.getFormattedValue = gvjs_Po.prototype.Ha;
gvjs_Po.prototype.getNumberOfColumns = gvjs_Po.prototype.$;
gvjs_Po.prototype.getNumberOfRows = gvjs_Po.prototype.ca;
gvjs_Po.prototype.getProperties = gvjs_Po.prototype.getProperties;
gvjs_Po.prototype.getProperty = gvjs_Po.prototype.getProperty;
gvjs_Po.prototype.getRowProperty = gvjs_Po.prototype.Ul;
gvjs_Po.prototype.getRowProperties = gvjs_Po.prototype.zv;
gvjs_Po.prototype.getSortedRows = gvjs_Po.prototype.bn;
gvjs_Po.prototype.getUnderlyingTableColumnIndex = gvjs_Po.prototype.Ty;
gvjs_Po.prototype.getTableRowIndex = gvjs_Po.prototype.fj;
gvjs_Po.prototype.getUnderlyingTableRowIndex = gvjs_Po.prototype.Uy;
gvjs_Po.prototype.getTableProperty = gvjs_Po.prototype.Sy;
gvjs_Po.prototype.getTableProperties = gvjs_Po.prototype.Cv;
gvjs_Po.prototype.getValue = gvjs_Po.prototype.getValue;
gvjs_Po.prototype.toDataTable = gvjs_Po.prototype.Gr;
gvjs_Po.prototype.toJSON = gvjs_Po.prototype.toJSON;
gvjs_q("google.visualization.DataTable", gvjs_M, void 0);
gvjs_M.prototype.addColumn = gvjs_M.prototype.xd;
gvjs_M.prototype.addRow = gvjs_M.prototype.Kp;
gvjs_M.prototype.addRows = gvjs_M.prototype.Yn;
gvjs_M.prototype.clone = gvjs_M.prototype.clone;
gvjs_M.prototype.getColumnId = gvjs_M.prototype.Ne;
gvjs_M.prototype.getColumnIndex = gvjs_M.prototype.jf;
gvjs_M.prototype.getColumnLabel = gvjs_M.prototype.Ga;
gvjs_M.prototype.getColumnPattern = gvjs_M.prototype.Co;
gvjs_M.prototype.getColumnProperty = gvjs_M.prototype.Bd;
gvjs_M.prototype.getColumnProperties = gvjs_M.prototype.Rj;
gvjs_M.prototype.getColumnRange = gvjs_M.prototype.Sj;
gvjs_M.prototype.getColumnRole = gvjs_M.prototype.Jg;
gvjs_M.prototype.getColumnType = gvjs_M.prototype.W;
gvjs_M.prototype.getDistinctValues = gvjs_M.prototype.Py;
gvjs_M.prototype.getFilteredRows = gvjs_M.prototype.at;
gvjs_M.prototype.getFormattedValue = gvjs_M.prototype.Ha;
gvjs_M.prototype.getNumberOfColumns = gvjs_M.prototype.$;
gvjs_M.prototype.getNumberOfRows = gvjs_M.prototype.ca;
gvjs_M.prototype.getProperties = gvjs_M.prototype.getProperties;
gvjs_M.prototype.getProperty = gvjs_M.prototype.getProperty;
gvjs_M.prototype.getRowProperty = gvjs_M.prototype.Ul;
gvjs_M.prototype.getRowProperties = gvjs_M.prototype.zv;
gvjs_M.prototype.getSortedRows = gvjs_M.prototype.bn;
gvjs_M.prototype.getTableProperty = gvjs_M.prototype.Sy;
gvjs_M.prototype.getTableProperties = gvjs_M.prototype.Cv;
gvjs_M.prototype.getUnderlyingTableColumnIndex = gvjs_M.prototype.Ty;
gvjs_M.prototype.getUnderlyingTableRowIndex = gvjs_M.prototype.Uy;
gvjs_M.prototype.getValue = gvjs_M.prototype.getValue;
gvjs_M.prototype.insertColumn = gvjs_M.prototype.uba;
gvjs_M.prototype.insertRows = gvjs_M.prototype.G_;
gvjs_M.prototype.removeColumn = gvjs_M.prototype.BS;
gvjs_M.prototype.removeColumns = gvjs_M.prototype.Hea;
gvjs_M.prototype.removeRow = gvjs_M.prototype.qE;
gvjs_M.prototype.removeRows = gvjs_M.prototype.Iea;
gvjs_M.prototype.setCell = gvjs_M.prototype.Wb;
gvjs_M.prototype.setColumnLabel = gvjs_M.prototype.xfa;
gvjs_M.prototype.setColumnProperties = gvjs_M.prototype.lT;
gvjs_M.prototype.setColumnProperty = gvjs_M.prototype.rA;
gvjs_M.prototype.setFormattedValue = gvjs_M.prototype.Nw;
gvjs_M.prototype.setProperties = gvjs_M.prototype.sr;
gvjs_M.prototype.setProperty = gvjs_M.prototype.setProperty;
gvjs_M.prototype.setRowProperties = gvjs_M.prototype.Gwa;
gvjs_M.prototype.setRowProperty = gvjs_M.prototype.Gfa;
gvjs_M.prototype.setTableProperties = gvjs_M.prototype.Hwa;
gvjs_M.prototype.setTableProperty = gvjs_M.prototype.Iwa;
gvjs_M.prototype.setValue = gvjs_M.prototype.Wa;
gvjs_M.prototype.sort = gvjs_M.prototype.sort;
gvjs_M.prototype.toJSON = gvjs_M.prototype.toJSON;
gvjs_q("google.visualization.arrayToDataTable", gvjs_Mk, void 0);
gvjs_q("google.visualization.DataView", gvjs_N, void 0);
gvjs_N.fromJSON = gvjs_Rk;
gvjs_N.prototype.getColumnId = gvjs_N.prototype.Ne;
gvjs_N.prototype.getColumnIndex = gvjs_N.prototype.jf;
gvjs_N.prototype.getColumnLabel = gvjs_N.prototype.Ga;
gvjs_N.prototype.getColumnPattern = gvjs_N.prototype.Co;
gvjs_N.prototype.getColumnProperty = gvjs_N.prototype.Bd;
gvjs_N.prototype.getColumnProperty = gvjs_N.prototype.Bd;
gvjs_N.prototype.getColumnProperties = gvjs_N.prototype.Rj;
gvjs_N.prototype.getColumnRange = gvjs_N.prototype.Sj;
gvjs_N.prototype.getColumnRole = gvjs_N.prototype.Jg;
gvjs_N.prototype.getColumnType = gvjs_N.prototype.W;
gvjs_N.prototype.getDistinctValues = gvjs_N.prototype.Py;
gvjs_N.prototype.getFilteredRows = gvjs_N.prototype.at;
gvjs_N.prototype.getFormattedValue = gvjs_N.prototype.Ha;
gvjs_N.prototype.getNumberOfColumns = gvjs_N.prototype.$;
gvjs_N.prototype.getNumberOfRows = gvjs_N.prototype.ca;
gvjs_N.prototype.getProperties = gvjs_N.prototype.getProperties;
gvjs_N.prototype.getProperty = gvjs_N.prototype.getProperty;
gvjs_N.prototype.getRowProperty = gvjs_N.prototype.Ul;
gvjs_N.prototype.getRowProperties = gvjs_N.prototype.zv;
gvjs_N.prototype.getSortedRows = gvjs_N.prototype.bn;
gvjs_N.prototype.getTableColumnIndex = gvjs_N.prototype.CP;
gvjs_N.prototype.getUnderlyingTableColumnIndex = gvjs_N.prototype.Ty;
gvjs_N.prototype.getTableRowIndex = gvjs_N.prototype.fj;
gvjs_N.prototype.getUnderlyingTableRowIndex = gvjs_N.prototype.Uy;
gvjs_N.prototype.getTableProperty = gvjs_N.prototype.Sy;
gvjs_N.prototype.getTableProperties = gvjs_N.prototype.Cv;
gvjs_N.prototype.getValue = gvjs_N.prototype.getValue;
gvjs_N.prototype.getViewColumnIndex = gvjs_N.prototype.S$;
gvjs_N.prototype.getViewColumns = gvjs_N.prototype.FZ;
gvjs_N.prototype.getViewRowIndex = gvjs_N.prototype.GZ;
gvjs_N.prototype.getViewRows = gvjs_N.prototype.T$;
gvjs_N.prototype.hideColumns = gvjs_N.prototype.ora;
gvjs_N.prototype.hideRows = gvjs_N.prototype.qra;
gvjs_N.prototype.setColumns = gvjs_N.prototype.Hn;
gvjs_N.prototype.setRows = gvjs_N.prototype.pp;
gvjs_N.prototype.toDataTable = gvjs_N.prototype.Gr;
gvjs_N.prototype.toJSON = gvjs_N.prototype.toJSON;
gvjs_q("google.visualization.errors", gvjs_D, void 0);
gvjs_D.addError = gvjs_D.Sc;
gvjs_D.removeAll = gvjs_D.removeAll;
gvjs_D.removeError = gvjs_D.yva;
gvjs_D.getContainer = gvjs_D.getContainer;
gvjs_D.createProtectedCallback = gvjs_D.uX;
gvjs_D.addErrorFromQueryResponse = gvjs_Xk;
gvjs_q("google.visualization.events.addListener", gvjs_oi, void 0);
gvjs_q("google.visualization.events.addOneTimeListener", gvjs_si, void 0);
gvjs_q("google.visualization.events.trigger", gvjs_I, void 0);
gvjs_q("google.visualization.events.removeListener", gvjs_ui, void 0);
gvjs_q("google.visualization.events.removeAllListeners", gvjs_vi, void 0);
gvjs_q("google.visualization.QueryWrapper", gvjs_uo, void 0);
gvjs_uo.prototype.setOptions = gvjs_uo.prototype.setOptions;
gvjs_uo.prototype.draw = gvjs_uo.prototype.draw;
gvjs_uo.prototype.setCustomErrorHandler = gvjs_uo.prototype.wwa;
gvjs_uo.prototype.sendAndDraw = gvjs_uo.prototype.GE;
gvjs_uo.prototype.setCustomPostResponseHandler = gvjs_uo.prototype.nT;
gvjs_uo.prototype.setCustomResponseHandler = gvjs_uo.prototype.oT;
gvjs_uo.prototype.abort = gvjs_uo.prototype.abort;
gvjs_q("google.visualization.datautils.arrayToDataTable", gvjs_Mk, void 0);
gvjs_q("google.visualization.datautils.compareValues", gvjs_vk, void 0);
gvjs_q("google.visualization.dataTableToCsv", function(a) {
    for (var b = "", c = 0; c < a.ca(); c++) {
        for (var d = 0; d < a.$(); d++) {
            0 < d && (b += ",");
            var e = a.Ha(c, d);
            e = e.replace(/"/g, '""');
            var f = -1 !== e.indexOf(",")
              , g = -1 !== e.indexOf("\n")
              , h = -1 !== e.indexOf('"');
            if (f || g || h)
                e = '"' + e + '"';
            b += e
        }
        b += "\n"
    }
    return b
}, void 0);
gvjs_q(gvjs_Dc, gvjs_gk, void 0);
gvjs_gk.prototype.format = gvjs_gk.prototype.format;
gvjs_gk.prototype.formatValue = gvjs_gk.prototype.Ob;
gvjs_q("google.visualization.NumberFormat.useNativeCharactersIfAvailable", function(a) {
    gvjs_lk = a
}, void 0);
gvjs_q("google.visualization.NumberFormat.DECIMAL_SEP", gvjs_hk, void 0);
gvjs_q("google.visualization.NumberFormat.GROUP_SEP", gvjs_ik, void 0);
gvjs_q("google.visualization.NumberFormat.DECIMAL_PATTERN", gvjs_mk, void 0);
gvjs_q("google.visualization.ColorFormat", gvjs_Io, void 0);
gvjs_Io.prototype.format = gvjs_Io.prototype.format;
gvjs_Io.prototype.addRange = gvjs_Io.prototype.addRange;
gvjs_Io.prototype.addGradientRange = gvjs_Io.prototype.dka;
gvjs_q("google.visualization.BarFormat", gvjs_Co, void 0);
gvjs_Co.prototype.format = gvjs_Co.prototype.format;
gvjs_q("google.visualization.ArrowFormat", gvjs_Bo, void 0);
gvjs_Bo.prototype.format = gvjs_Bo.prototype.format;
gvjs_q("google.visualization.PatternFormat", gvjs_Jo, void 0);
gvjs_Jo.prototype.format = gvjs_Jo.prototype.format;
gvjs_q("google.visualization.DateFormat", gvjs_Tj, void 0);
gvjs_Tj.prototype.format = gvjs_Tj.prototype.format;
gvjs_Tj.prototype.formatValue = gvjs_Tj.prototype.Ob;
gvjs_q(gvjs_Dc, gvjs_gk, void 0);
gvjs_gk.prototype.format = gvjs_gk.prototype.format;
gvjs_q("google.visualization.TableColorFormat", gvjs_Io, void 0);
gvjs_q("google.visualization.TableBarFormat", gvjs_Co, void 0);
gvjs_Co.prototype.format = gvjs_Co.prototype.format;
gvjs_q("google.visualization.TableArrowFormat", gvjs_Bo, void 0);
gvjs_Bo.prototype.format = gvjs_Bo.prototype.format;
gvjs_q("google.visualization.TablePatternFormat", gvjs_Jo, void 0);
gvjs_Jo.prototype.format = gvjs_Jo.prototype.format;
gvjs_q("google.visualization.TableDateFormat", gvjs_Tj, void 0);
