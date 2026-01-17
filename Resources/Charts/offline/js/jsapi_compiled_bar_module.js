gvjs_PR.prototype.ko = gvjs_V(85, function(a, b) {
    return b - a
});
gvjs_QR.prototype.ko = gvjs_V(84, function(a, b) {
    return this.bL.ko(a, b)
});
gvjs_TR.prototype.ko = gvjs_V(83, function(a, b) {
    return this.qe.mo(a, b)
});
gvjs_YR.prototype.ko = gvjs_V(82, function(a, b) {
    return this.BH.mo(a, b)
});
gvjs_PR.prototype.mo = gvjs_V(81, function(a, b) {
    return this.ko(this.scale(a), this.scale(b))
});
gvjs_QR.prototype.mo = gvjs_V(80, function(a, b) {
    return this.Dy.ko(a, b)
});
gvjs_TR.prototype.mo = gvjs_V(79, function(a, b) {
    return this.qe.ko(a, b)
});
gvjs_YR.prototype.mo = gvjs_V(78, function(a, b) {
    return this.nU.mo(a, b)
});
function gvjs_uY(a) {
    this.m = a.options;
    this.aY = a.Sm;
    this.oh = a.rK;
    this.AO = a.axes.domain;
    this.R4 = a.axes.target;
    this.eaa = null != a.daa ? a.daa : 1;
    this.dpa = null != a.cpa ? a.cpa : gvjs_0;
    this.ew = this.layout()
}
gvjs_uY.prototype.Ry = function() {
    var a = [];
    gvjs_w(this.ew, function(b) {
        gvjs_Me(a, b.C.list)
    });
    gvjs_Qe(a, function(b, c) {
        return b.stack === c.stack ? -gvjs_Re(b.bar, c.bar) : gvjs_Re(b.stack, c.stack)
    });
    return a
}
;
gvjs_uY.prototype.rI = function() {
    var a = [];
    gvjs_w(this.ew, function(b) {
        gvjs_u(b.groups, function(c, d) {
            null != c && gvjs_u(c.Mn, function(e, f) {
                gvjs_Me(a, gvjs_v(e.Mb.fk, function(g, h) {
                    var k = g.shape.data();
                    return g.shape.clone().data({
                        value: k,
                        id: gvjs_KL(gvjs_KL(gvjs_KL(gvjs_KL(gvjs_wR(g.definition.sourceColumn, g.definition.ZE), gvjs_JQ, g.definition.Yi), gvjs_Cp, d), gvjs_2w, f), gvjs_KQ, h + 1)
                    })
                }));
                gvjs_Me(a, gvjs_v(e.Mb.Oz, function(g, h) {
                    var k = g.shape.data();
                    return g.shape.clone().data({
                        value: k,
                        id: gvjs_KL(gvjs_KL(gvjs_KL(gvjs_KL(gvjs_wR(g.definition.sourceColumn, g.definition.ZE), gvjs_JQ, g.definition.Yi), gvjs_Cp, d), gvjs_2w, f), gvjs_KQ, -h - 1)
                    })
                }))
            }, this)
        }, this)
    }, this);
    return a
}
;
function gvjs_Wka(a, b) {
    if (1 >= a)
        return [b];
    var c = 0 * (b.end - b.start)
      , d = c / (a - 1);
    c = (b.end - b.start - c) / a;
    var e = [];
    b = b.start;
    for (var f = 0; f < a; f++)
        e.push(new gvjs_O(b,b + c)),
        b += c + d;
    return e
}
function gvjs_Xka(a, b, c, d) {
    var e = {
        range: b,
        definition: c,
        Mn: []
    }
      , f = gvjs_Wka(c.Mn.length, b);
    gvjs_u(c.Mn, function(g, h) {
        var k = {
            definition: g,
            range: f[h],
            height: {
                fk: 0,
                Oz: 0
            },
            Mb: {
                fk: [],
                Oz: []
            }
        };
        e.Mn.push(k);
        gvjs_u(g.Mb, function(l, m) {
            l.sourceColumn in d.index ? d.list[d.index[l.sourceColumn]].Mb.push(l) : (d.index[l.sourceColumn] = d.list.length,
            d.list.push({
                color: null,
                column: l.sourceColumn,
                stack: h,
                bar: m,
                Mb: [l]
            }),
            d.C4 = Math.max(d.C4, h + 1),
            d.fW = Math.max(d.fW, m + 1));
            m = this.R4[l.GL];
            var n = m.scale
              , p = n.scale(n.BC());
            n = k.range.start;
            var q = k.height.fk + p
              , r = k.range.end - k.range.start
              , t = l.value;
            if (isNaN(t) || null == t)
                m = null;
            else {
                t -= p;
                var u = t + k.height.fk;
                0 <= t ? k.height.fk += t : (q = -k.height.Oz + p,
                u = -k.height.Oz + t + p,
                k.height.Oz -= t);
                l.Tt = r / 2 + k.range.start;
                l.pEa = u;
                gvjs_KL(gvjs_wR(l.sourceColumn, l.ZE), gvjs_JQ, l.Yi);
                p = new gvjs_B(q,n + r,q + t,n);
                p.top > p.bottom && (u = p.top,
                p.top = p.bottom,
                p.bottom = u);
                null === m.range ? m.range = new gvjs_O(p.top,p.bottom) : (gvjs_5Q(m.range, p.top),
                gvjs_5Q(m.range, p.bottom));
                m = (new gvjs_4Q(n,q,r,t)).setData(l)
            }
            m && (0 <= gvjs_L(gvjs_xq(m), gvjs_4c) ? k.Mb.fk : k.Mb.Oz).push({
                definition: l,
                shape: m
            })
        }, this)
    }, a);
    return e
}
function gvjs_Yka(a, b) {
    var c = {};
    if (gvjs_Ge(a, function(q) {
        return 0 === q.groups.length
    }))
        return {};
    gvjs_u(a, function(q, r) {
        gvjs_u(q.groups, function(t) {
            c[t.Yi] = r
        })
    });
    var d = {}, e = {}, f;
    for (f in b) {
        var g = b[f]
          , h = g.scale;
        g = gvjs_v(g.columns, function(q) {
            return a[c[q]]
        });
        var k = {
            FCa: h.isDiscrete(),
            type: g[0].type,
            scale: h,
            Nf: {},
            groups: []
        };
        e[f] = k;
        k.type in d || (d[k.type] = f);
        if (h.isDiscrete())
            for (var l = 0; ; l++) {
                var m = {
                    Mn: []
                }
                  , n = gvjs_v(g, function(q) {
                    return q.groups[l]
                });
                if (!gvjs_Fe(n, function(q) {
                    return null != q
                }))
                    break;
                gvjs_u(n, function(q) {
                    q.Gg && null == m.Gg && (m.Gg = q.Gg);
                    gvjs_Me(m.Mn, q.Mn)
                });
                k.groups.push(m)
            }
        else {
            var p = [];
            gvjs_u(g, function(q) {
                gvjs_u(q.groups, function(r) {
                    var t = gvjs_Iy(p, r, function(u, v) {
                        return h.mo(u.Gg, v.Gg)
                    });
                    0 > t ? gvjs_fq(p, {
                        Gg: r.Gg,
                        Nf: gvjs_x(r.Nf),
                        Mn: gvjs_Le(r.Mn)
                    }, -(t + 1)) : gvjs_Me(p[t].Mn, r.Mn)
                })
            });
            k.groups = p
        }
    }
    return e
}
function gvjs_Zka(a, b, c, d) {
    var e = a.AO[c]
      , f = e.scale;
    f.isDiscrete() || gvjs_Qe(b.groups, function(r, t) {
        r = r.ia ? r.Gg : f.scale(r.Gg);
        t = t.ia ? t.Gg : f.scale(t.Gg);
        return gvjs_Re(r, t)
    });
    var g = Infinity
      , h = null;
    gvjs_u(b.groups, function(r) {
        f.isDiscrete() && (r.Gg = f.add(r.Gg),
        r.ia = !0);
        r = r.ia ? r.Gg : f.scale(r.Gg);
        if (null != r) {
            if (null !== h) {
                var t = r - h;
                0 < t && t < g && (g = t)
            }
            h = r
        }
    });
    isFinite(g) || (g = 1);
    var k = {
        list: [],
        index: {},
        C4: 0,
        fW: 0
    };
    c = gvjs_v(b.groups, function(r) {
        var t = r.ia ? r.Gg : f.scale(r.Gg);
        if (null != t) {
            var u = g
              , v = t;
            t += u;
            switch (this.dpa) {
            case gvjs_0:
                v -= u / 2,
                t -= u / 2
            }
            u = (t - v) / 2;
            v += (1 - this.eaa) * u;
            t -= (1 - this.eaa) * u;
            v = new gvjs_O(v,t);
            null === e.range ? e.range = v.clone() : (u = e.range,
            u.start = Math.min(u.start, v.start),
            u.end = Math.max(u.end, v.end));
            return gvjs_Xka(this, v, r, k)
        }
    }, a);
    for (var l = 0, m = k.C4; l < m; l++)
        for (var n = 0, p = k.fW; n < p; n++)
            a.oh.Au(String(l), String(n));
    var q = a.oh.cd();
    gvjs_u(k.list, function(r, t) {
        var u = gvjs_qj(gvjs_J(this.m, gvjs_Qw + (t + d) + ".color", q.Cq(r.stack, r.bar))).hex;
        r.color = u;
        gvjs_u(r.Mb, function(v) {
            v.color = u
        })
    }, a);
    return {
        definition: b,
        C: k,
        groups: c
    }
}
gvjs_uY.prototype.layout = function() {
    var a = gvjs_Yka(this.aY, this.AO)
      , b = 0;
    return gvjs_Ny(a, function(c, d) {
        c = gvjs_Zka(this, c, d, b);
        b += c.C.list.length;
        return c
    }, this)
}
;
function gvjs_vY(a, b, c, d) {
    gvjs_DS.call(this, a, b, c, d)
}
gvjs_o(gvjs_vY, gvjs_DS);
gvjs_vY.prototype.vi = function() {
    return gvjs_J(this.options, gvjs_lt, gvjs_U, gvjs_CS) === gvjs_S ? gvjs_U : gvjs_S
}
;
gvjs_vY.prototype.Kma = function(a, b, c, d) {
    function e(n, p) {
        return f ? p : n
    }
    var f = gvjs_K(this.options, "stacked", !1)
      , g = this.Ta
      , h = a[String(c.Yi)]
      , k = g.getValue(d, c.Yi);
    this.vi();
    var l = e([0], c.C);
    a = e(c.C, [0]);
    var m = [];
    gvjs_u(a, function(n) {
        var p = []
          , q = {};
        gvjs_u(l, function(r) {
            r = (f ? r : n).Bs;
            var t = g.getValue(d, r)
              , u = b[r]
              , v = u.scale
              , w = u.name;
            w in q || (p.push({
                Mb: []
            }),
            q[w] = p.length - 1);
            w = p[q[w]].Mb;
            v.isDiscrete() && null != t && (0 === v.getMapping().length && v.add("", !0),
            v.add(t, !0));
            w.push({
                Yi: c.Yi,
                sourceColumn: r,
                ZE: d,
                BO: h.name,
                GL: u.name,
                Gg: k,
                wEa: t,
                color: null,
                value: u.scale.scale(t),
                ia: !0
            })
        });
        gvjs_u(p, function(r) {
            m.push(r)
        })
    });
    return {
        Yi: c.Yi,
        Gg: k,
        Nf: c.Nf,
        Mn: m
    }
}
;
gvjs_vY.prototype.Jma = function(a, b, c) {
    return {
        type: this.Ta.W(c.Yi),
        Nf: c.Nf,
        groups: gvjs_v(gvjs_Ky(this.Ta.ca()), gvjs_s(this.Kma, this, a, b, c))
    }
}
;
gvjs_vY.prototype.hZ = function(a, b, c) {
    gvjs_w(a, function(m) {
        m.expand = !1
    });
    gvjs_w(b, function(m) {
        m.expand = !0
    });
    var d = this.vi() === gvjs_U, e = d && gvjs_Fe(gvjs_Ye(b), function(m) {
        return b[m].sk === gvjs_vx
    }), f = d && gvjs_Fe(gvjs_Ye(b), function(m) {
        return b[m].sk === gvjs_vt
    }), g = {}, h;
    for (h in b)
        gvjs_u(b[h].columns, function(m) {
            g[m] = {
                name: h,
                scale: b[h].scale
            }
        });
    var k = {};
    for (h in a)
        gvjs_u(a[h].columns, function(m) {
            k[m] = {
                name: h,
                scale: a[h].scale
            }
        });
    var l = gvjs_v(this.jO.Sm, gvjs_s(this.Jma, this, k, g));
    return new gvjs_uY({
        options: this.options,
        Sm: l,
        axes: {
            domain: a,
            target: b
        },
        rK: c,
        daa: gvjs_ny(this.options, "groupSize"),
        PDa: !d || e,
        QDa: !d || f
    })
}
;
function gvjs_wY(a, b) {
    gvjs_GS.call(this, a, b)
}
gvjs_t(gvjs_wY, gvjs_GS);
gvjs_ = gvjs_wY.prototype;
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
    this.Lp(a).style(gvjs_pp, b)
}
;
gvjs_.tT = function(a) {
    var b = a.data().value.color;
    this.Lp(a).style(gvjs_pp, gvjs_HS(b, this.dQ, this.HB))
}
;
gvjs_.pT = function(a) {
    var b = a.data().value.color;
    this.dr(a).style(gvjs_pp, gvjs_IS(b, this.nfa, this.HB))
}
;
gvjs_.zT = function(a) {
    var b = a.data().value.color;
    this.dr(a).style(gvjs_pp, b)
}
;
function gvjs_xY(a) {
    gvjs_UL.call(this, a)
}
gvjs_o(gvjs_xY, gvjs_UL);
gvjs_ = gvjs_xY.prototype;
gvjs_.xq = function() {
    return null
}
;
gvjs_.og = function() {
    return gvjs_FS
}
;
gvjs_.po = function(a, b, c, d) {
    a = new gvjs_AR(this,a,b,c,d);
    a.$t([gvjs_Wo, gvjs_Pu, gvjs_Cw, gvjs_YQ, gvjs_RQ, gvjs_Ds, gvjs_Cs, gvjs_Pd]);
    return a
}
;
gvjs_.Mm = function(a, b) {
    return new gvjs_wY(a,b)
}
;
gvjs_.Al = function(a, b, c, d) {
    return new gvjs_vY(a,b,c,d)
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
gvjs_q(gvjs_Zb, gvjs_xY, void 0);
gvjs_xY.convertOptions = function(a) {
    if (a) {
        var b = new gvjs_Aj([a]);
        a = gvjs__S(a);
        b = b.cb(gvjs_9v);
        null != b && (a.bars = b === gvjs_U ? gvjs_S : gvjs_U);
        b = a
    } else
        b = {};
    return b
}
;
gvjs_xY.prototype.draw = gvjs_xY.prototype.draw;
gvjs_xY.prototype.clearChart = gvjs_xY.prototype.Jb;
gvjs_xY.prototype.getSelection = gvjs_xY.prototype.getSelection;
gvjs_xY.prototype.setSelection = gvjs_xY.prototype.setSelection;
