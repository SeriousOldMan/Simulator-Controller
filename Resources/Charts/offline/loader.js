(function() {
    /*

 Copyright The Closure Library Authors.
 SPDX-License-Identifier: Apache-2.0
*/
    'use strict';
    function aa(a) {
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
    var l = "function" == typeof Object.defineProperties ? Object.defineProperty : function(a, b, c) {
        if (a == Array.prototype || a == Object.prototype)
            return a;
        a[b] = c.value;
        return a
    }
    ;
    function ba(a) {
        a = ["object" == typeof globalThis && globalThis, a, "object" == typeof window && window, "object" == typeof self && self, "object" == typeof global && global];
        for (var b = 0; b < a.length; ++b) {
            var c = a[b];
            if (c && c.Math == Math)
                return c
        }
        throw Error("Cannot find global object");
    }
    var p = ba(this);
    function q(a, b) {
        if (b)
            a: {
                var c = p;
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
                b != d && null != b && l(c, a, {
                    configurable: !0,
                    writable: !0,
                    value: b
                })
            }
    }
    q("Symbol", function(a) {
        function b(g) {
            if (this instanceof b)
                throw new TypeError("Symbol is not a constructor");
            return new c(d + (g || "") + "_" + e++,g)
        }
        function c(g, f) {
            this.g = g;
            l(this, "description", {
                configurable: !0,
                writable: !0,
                value: f
            })
        }
        if (a)
            return a;
        c.prototype.toString = function() {
            return this.g
        }
        ;
        var d = "jscomp_symbol_" + (1E9 * Math.random() >>> 0) + "_"
          , e = 0;
        return b
    });
    q("Symbol.iterator", function(a) {
        if (a)
            return a;
        a = Symbol("Symbol.iterator");
        for (var b = "Array Int8Array Uint8Array Uint8ClampedArray Int16Array Uint16Array Int32Array Uint32Array Float32Array Float64Array".split(" "), c = 0; c < b.length; c++) {
            var d = p[b[c]];
            "function" === typeof d && "function" != typeof d.prototype[a] && l(d.prototype, a, {
                configurable: !0,
                writable: !0,
                value: function() {
                    return ca(aa(this))
                }
            })
        }
        return a
    });
    q("Symbol.asyncIterator", function(a) {
        return a ? a : Symbol("Symbol.asyncIterator")
    });
    function ca(a) {
        a = {
            next: a
        };
        a[Symbol.iterator] = function() {
            return this
        }
        ;
        return a
    }
    function r(a) {
        var b = "undefined" != typeof Symbol && Symbol.iterator && a[Symbol.iterator];
        return b ? b.call(a) : {
            next: aa(a)
        }
    }
    function t(a, b) {
        return Object.prototype.hasOwnProperty.call(a, b)
    }
    q("WeakMap", function(a) {
        function b(k) {
            this.g = (h += Math.random() + 1).toString();
            if (k) {
                k = r(k);
                for (var m; !(m = k.next()).done; )
                    m = m.value,
                    this.set(m[0], m[1])
            }
        }
        function c() {}
        function d(k) {
            var m = typeof k;
            return "object" === m && null !== k || "function" === m
        }
        function e(k) {
            if (!t(k, f)) {
                var m = new c;
                l(k, f, {
                    value: m
                })
            }
        }
        function g(k) {
            var m = Object[k];
            m && (Object[k] = function(n) {
                if (n instanceof c)
                    return n;
                Object.isExtensible(n) && e(n);
                return m(n)
            }
            )
        }
        if (function() {
            if (!a || !Object.seal)
                return !1;
            try {
                var k = Object.seal({})
                  , m = Object.seal({})
                  , n = new a([[k, 2], [m, 3]]);
                if (2 != n.get(k) || 3 != n.get(m))
                    return !1;
                n.delete(k);
                n.set(m, 4);
                return !n.has(k) && 4 == n.get(m)
            } catch (v) {
                return !1
            }
        }())
            return a;
        var f = "$jscomp_hidden_" + Math.random();
        g("freeze");
        g("preventExtensions");
        g("seal");
        var h = 0;
        b.prototype.set = function(k, m) {
            if (!d(k))
                throw Error("Invalid WeakMap key");
            e(k);
            if (!t(k, f))
                throw Error("WeakMap key fail: " + k);
            k[f][this.g] = m;
            return this
        }
        ;
        b.prototype.get = function(k) {
            return d(k) && t(k, f) ? k[f][this.g] : void 0
        }
        ;
        b.prototype.has = function(k) {
            return d(k) && t(k, f) && t(k[f], this.g)
        }
        ;
        b.prototype.delete = function(k) {
            return d(k) && t(k, f) && t(k[f], this.g) ? delete k[f][this.g] : !1
        }
        ;
        return b
    });
    q("Map", function(a) {
        function b() {
            var h = {};
            return h.s = h.next = h.head = h
        }
        function c(h, k) {
            var m = h.g;
            return ca(function() {
                if (m) {
                    for (; m.head != h.g; )
                        m = m.s;
                    for (; m.next != m.head; )
                        return m = m.next,
                        {
                            done: !1,
                            value: k(m)
                        };
                    m = null
                }
                return {
                    done: !0,
                    value: void 0
                }
            })
        }
        function d(h, k) {
            var m = k && typeof k;
            "object" == m || "function" == m ? g.has(k) ? m = g.get(k) : (m = "" + ++f,
            g.set(k, m)) : m = "p_" + k;
            var n = h.h[m];
            if (n && t(h.h, m))
                for (h = 0; h < n.length; h++) {
                    var v = n[h];
                    if (k !== k && v.key !== v.key || k === v.key)
                        return {
                            id: m,
                            list: n,
                            index: h,
                            m: v
                        }
                }
            return {
                id: m,
                list: n,
                index: -1,
                m: void 0
            }
        }
        function e(h) {
            this.h = {};
            this.g = b();
            this.size = 0;
            if (h) {
                h = r(h);
                for (var k; !(k = h.next()).done; )
                    k = k.value,
                    this.set(k[0], k[1])
            }
        }
        if (function() {
            if (!a || "function" != typeof a || !a.prototype.entries || "function" != typeof Object.seal)
                return !1;
            try {
                var h = Object.seal({
                    x: 4
                })
                  , k = new a(r([[h, "s"]]));
                if ("s" != k.get(h) || 1 != k.size || k.get({
                    x: 4
                }) || k.set({
                    x: 4
                }, "t") != k || 2 != k.size)
                    return !1;
                var m = k.entries()
                  , n = m.next();
                if (n.done || n.value[0] != h || "s" != n.value[1])
                    return !1;
                n = m.next();
                return n.done || 4 != n.value[0].x || "t" != n.value[1] || !m.next().done ? !1 : !0
            } catch (v) {
                return !1
            }
        }())
            return a;
        var g = new WeakMap;
        e.prototype.set = function(h, k) {
            h = 0 === h ? 0 : h;
            var m = d(this, h);
            m.list || (m.list = this.h[m.id] = []);
            m.m ? m.m.value = k : (m.m = {
                next: this.g,
                s: this.g.s,
                head: this.g,
                key: h,
                value: k
            },
            m.list.push(m.m),
            this.g.s.next = m.m,
            this.g.s = m.m,
            this.size++);
            return this
        }
        ;
        e.prototype.delete = function(h) {
            h = d(this, h);
            return h.m && h.list ? (h.list.splice(h.index, 1),
            h.list.length || delete this.h[h.id],
            h.m.s.next = h.m.next,
            h.m.next.s = h.m.s,
            h.m.head = null,
            this.size--,
            !0) : !1
        }
        ;
        e.prototype.clear = function() {
            this.h = {};
            this.g = this.g.s = b();
            this.size = 0
        }
        ;
        e.prototype.has = function(h) {
            return !!d(this, h).m
        }
        ;
        e.prototype.get = function(h) {
            return (h = d(this, h).m) && h.value
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
            for (var m = this.entries(), n; !(n = m.next()).done; )
                n = n.value,
                h.call(k, n[1], n[0], this)
        }
        ;
        e.prototype[Symbol.iterator] = e.prototype.entries;
        var f = 0;
        return e
    });
    function da(a, b, c) {
        a instanceof String && (a = String(a));
        for (var d = a.length, e = 0; e < d; e++) {
            var g = a[e];
            if (b.call(c, g, e, a))
                return {
                    K: e,
                    S: g
                }
        }
        return {
            K: -1,
            S: void 0
        }
    }
    q("Array.prototype.find", function(a) {
        return a ? a : function(b, c) {
            return da(this, b, c).S
        }
    });
    function u(a, b, c) {
        if (null == a)
            throw new TypeError("The 'this' value for String.prototype." + c + " must not be null or undefined");
        if (b instanceof RegExp)
            throw new TypeError("First argument to String.prototype." + c + " must not be a regular expression");
        return a + ""
    }
    q("String.prototype.endsWith", function(a) {
        return a ? a : function(b, c) {
            var d = u(this, b, "endsWith");
            void 0 === c && (c = d.length);
            c = Math.max(0, Math.min(c | 0, d.length));
            for (var e = b.length; 0 < e && 0 < c; )
                if (d[--c] != b[--e])
                    return !1;
            return 0 >= e
        }
    });
    q("String.prototype.startsWith", function(a) {
        return a ? a : function(b, c) {
            var d = u(this, b, "startsWith")
              , e = d.length
              , g = b.length;
            c = Math.max(0, Math.min(c | 0, d.length));
            for (var f = 0; f < g && c < e; )
                if (d[c++] != b[f++])
                    return !1;
            return f >= g
        }
    });
    q("String.prototype.repeat", function(a) {
        return a ? a : function(b) {
            var c = u(this, null, "repeat");
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
    q("String.prototype.trimLeft", function(a) {
        function b() {
            return this.replace(/^[\s\xa0]+/, "")
        }
        return a || b
    });
    q("String.prototype.trimStart", function(a) {
        return a || String.prototype.trimLeft
    });
    var ea;
    if ("function" == typeof Object.setPrototypeOf)
        ea = Object.setPrototypeOf;
    else {
        var fa;
        a: {
            var ha = {
                a: !0
            }
              , ia = {};
            try {
                ia.__proto__ = ha;
                fa = ia.a;
                break a
            } catch (a) {}
            fa = !1
        }
        ea = fa ? function(a, b) {
            a.__proto__ = b;
            if (a.__proto__ !== b)
                throw new TypeError(a + " is not extensible");
            return a
        }
        : null
    }
    var w = ea;
    q("Object.setPrototypeOf", function(a) {
        return a || w
    });
    var ja = "function" == typeof Object.assign ? Object.assign : function(a, b) {
        for (var c = 1; c < arguments.length; c++) {
            var d = arguments[c];
            if (d)
                for (var e in d)
                    t(d, e) && (a[e] = d[e])
        }
        return a
    }
    ;
    q("Object.assign", function(a) {
        return a || ja
    });
    q("Promise", function(a) {
        function b(f) {
            this.g = 0;
            this.i = void 0;
            this.h = [];
            this.u = !1;
            var h = this.j();
            try {
                f(h.resolve, h.reject)
            } catch (k) {
                h.reject(k)
            }
        }
        function c() {
            this.g = null
        }
        function d(f) {
            return f instanceof b ? f : new b(function(h) {
                h(f)
            }
            )
        }
        if (a)
            return a;
        c.prototype.h = function(f) {
            if (null == this.g) {
                this.g = [];
                var h = this;
                this.i(function() {
                    h.l()
                })
            }
            this.g.push(f)
        }
        ;
        var e = p.setTimeout;
        c.prototype.i = function(f) {
            e(f, 0)
        }
        ;
        c.prototype.l = function() {
            for (; this.g && this.g.length; ) {
                var f = this.g;
                this.g = [];
                for (var h = 0; h < f.length; ++h) {
                    var k = f[h];
                    f[h] = null;
                    try {
                        k()
                    } catch (m) {
                        this.j(m)
                    }
                }
            }
            this.g = null
        }
        ;
        c.prototype.j = function(f) {
            this.i(function() {
                throw f;
            })
        }
        ;
        b.prototype.j = function() {
            function f(m) {
                return function(n) {
                    k || (k = !0,
                    m.call(h, n))
                }
            }
            var h = this
              , k = !1;
            return {
                resolve: f(this.D),
                reject: f(this.l)
            }
        }
        ;
        b.prototype.D = function(f) {
            if (f === this)
                this.l(new TypeError("A Promise cannot resolve to itself"));
            else if (f instanceof b)
                this.T(f);
            else {
                a: switch (typeof f) {
                case "object":
                    var h = null != f;
                    break a;
                case "function":
                    h = !0;
                    break a;
                default:
                    h = !1
                }
                h ? this.C(f) : this.o(f)
            }
        }
        ;
        b.prototype.C = function(f) {
            var h = void 0;
            try {
                h = f.then
            } catch (k) {
                this.l(k);
                return
            }
            "function" == typeof h ? this.U(h, f) : this.o(f)
        }
        ;
        b.prototype.l = function(f) {
            this.v(2, f)
        }
        ;
        b.prototype.o = function(f) {
            this.v(1, f)
        }
        ;
        b.prototype.v = function(f, h) {
            if (0 != this.g)
                throw Error("Cannot settle(" + f + ", " + h + "): Promise already settled in state" + this.g);
            this.g = f;
            this.i = h;
            2 === this.g && this.G();
            this.A()
        }
        ;
        b.prototype.G = function() {
            var f = this;
            e(function() {
                if (f.B()) {
                    var h = p.console;
                    "undefined" !== typeof h && h.error(f.i)
                }
            }, 1)
        }
        ;
        b.prototype.B = function() {
            if (this.u)
                return !1;
            var f = p.CustomEvent
              , h = p.Event
              , k = p.dispatchEvent;
            if ("undefined" === typeof k)
                return !0;
            "function" === typeof f ? f = new f("unhandledrejection",{
                cancelable: !0
            }) : "function" === typeof h ? f = new h("unhandledrejection",{
                cancelable: !0
            }) : (f = p.document.createEvent("CustomEvent"),
            f.initCustomEvent("unhandledrejection", !1, !0, f));
            f.promise = this;
            f.reason = this.i;
            return k(f)
        }
        ;
        b.prototype.A = function() {
            if (null != this.h) {
                for (var f = 0; f < this.h.length; ++f)
                    g.h(this.h[f]);
                this.h = null
            }
        }
        ;
        var g = new c;
        b.prototype.T = function(f) {
            var h = this.j();
            f.F(h.resolve, h.reject)
        }
        ;
        b.prototype.U = function(f, h) {
            var k = this.j();
            try {
                f.call(h, k.resolve, k.reject)
            } catch (m) {
                k.reject(m)
            }
        }
        ;
        b.prototype.then = function(f, h) {
            function k(x, H) {
                return "function" == typeof x ? function(ka) {
                    try {
                        m(x(ka))
                    } catch (la) {
                        n(la)
                    }
                }
                : H
            }
            var m, n, v = new b(function(x, H) {
                m = x;
                n = H
            }
            );
            this.F(k(f, m), k(h, n));
            return v
        }
        ;
        b.prototype.catch = function(f) {
            return this.then(void 0, f)
        }
        ;
        b.prototype.F = function(f, h) {
            function k() {
                switch (m.g) {
                case 1:
                    f(m.i);
                    break;
                case 2:
                    h(m.i);
                    break;
                default:
                    throw Error("Unexpected state: " + m.g);
                }
            }
            var m = this;
            null == this.h ? g.h(k) : this.h.push(k);
            this.u = !0
        }
        ;
        b.resolve = d;
        b.reject = function(f) {
            return new b(function(h, k) {
                k(f)
            }
            )
        }
        ;
        b.race = function(f) {
            return new b(function(h, k) {
                for (var m = r(f), n = m.next(); !n.done; n = m.next())
                    d(n.value).F(h, k)
            }
            )
        }
        ;
        b.all = function(f) {
            var h = r(f)
              , k = h.next();
            return k.done ? d([]) : new b(function(m, n) {
                function v(ka) {
                    return function(la) {
                        x[ka] = la;
                        H--;
                        0 == H && m(x)
                    }
                }
                var x = []
                  , H = 0;
                do
                    x.push(void 0),
                    H++,
                    d(k.value).F(v(x.length - 1), n),
                    k = h.next();
                while (!k.done)
            }
            )
        }
        ;
        return b
    });
    q("Array.prototype.copyWithin", function(a) {
        function b(c) {
            c = Number(c);
            return Infinity === c || -Infinity === c ? c : c | 0
        }
        return a ? a : function(c, d, e) {
            var g = this.length;
            c = b(c);
            d = b(d);
            e = void 0 === e ? g : b(e);
            c = 0 > c ? Math.max(g + c, 0) : Math.min(c, g);
            d = 0 > d ? Math.max(g + d, 0) : Math.min(d, g);
            e = 0 > e ? Math.max(g + e, 0) : Math.min(e, g);
            if (c < d)
                for (; d < e; )
                    d in this ? this[c++] = this[d++] : (delete this[c++],
                    d++);
            else
                for (e = Math.min(e, g + d - c),
                c += e - d; e > d; )
                    --e in this ? this[--c] = this[e] : delete this[--c];
            return this
        }
    });
    function ma(a, b) {
        a instanceof String && (a += "");
        var c = 0
          , d = !1
          , e = {
            next: function() {
                if (!d && c < a.length) {
                    var g = c++;
                    return {
                        value: b(g, a[g]),
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
    q("Array.prototype.entries", function(a) {
        return a ? a : function() {
            return ma(this, function(b, c) {
                return [b, c]
            })
        }
    });
    q("Array.prototype.fill", function(a) {
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
    q("Array.prototype.findIndex", function(a) {
        return a ? a : function(b, c) {
            return da(this, b, c).K
        }
    });
    q("Array.prototype.flat", function(a) {
        return a ? a : function(b) {
            b = void 0 === b ? 1 : b;
            for (var c = [], d = 0; d < this.length; d++) {
                var e = this[d];
                Array.isArray(e) && 0 < b ? (e = Array.prototype.flat.call(e, b - 1),
                c.push.apply(c, e)) : c.push(e)
            }
            return c
        }
    });
    q("Array.prototype.flatMap", function(a) {
        return a ? a : function(b, c) {
            for (var d = [], e = 0; e < this.length; e++) {
                var g = b.call(c, this[e], e, this);
                Array.isArray(g) ? d.push.apply(d, g) : d.push(g)
            }
            return d
        }
    });
    q("Array.from", function(a) {
        return a ? a : function(b, c, d) {
            c = null != c ? c : function(h) {
                return h
            }
            ;
            var e = []
              , g = "undefined" != typeof Symbol && Symbol.iterator && b[Symbol.iterator];
            if ("function" == typeof g) {
                b = g.call(b);
                for (var f = 0; !(g = b.next()).done; )
                    e.push(c.call(d, g.value, f++))
            } else
                for (g = b.length,
                f = 0; f < g; f++)
                    e.push(c.call(d, b[f], f));
            return e
        }
    });
    q("Object.is", function(a) {
        return a ? a : function(b, c) {
            return b === c ? 0 !== b || 1 / b === 1 / c : b !== b && c !== c
        }
    });
    q("Array.prototype.includes", function(a) {
        return a ? a : function(b, c) {
            var d = this;
            d instanceof String && (d = String(d));
            var e = d.length;
            c = c || 0;
            for (0 > c && (c = Math.max(c + e, 0)); c < e; c++) {
                var g = d[c];
                if (g === b || Object.is(g, b))
                    return !0
            }
            return !1
        }
    });
    q("Array.prototype.keys", function(a) {
        return a ? a : function() {
            return ma(this, function(b) {
                return b
            })
        }
    });
    q("Array.of", function(a) {
        return a ? a : function(b) {
            return Array.from(arguments)
        }
    });
    q("Array.prototype.values", function(a) {
        return a ? a : function() {
            return ma(this, function(b, c) {
                return c
            })
        }
    });
    q("globalThis", function(a) {
        return a || p
    });
    q("Math.acosh", function(a) {
        return a ? a : function(b) {
            b = Number(b);
            return Math.log(b + Math.sqrt(b * b - 1))
        }
    });
    q("Math.asinh", function(a) {
        return a ? a : function(b) {
            b = Number(b);
            if (0 === b)
                return b;
            var c = Math.log(Math.abs(b) + Math.sqrt(b * b + 1));
            return 0 > b ? -c : c
        }
    });
    q("Math.log1p", function(a) {
        return a ? a : function(b) {
            b = Number(b);
            if (.25 > b && -.25 < b) {
                for (var c = b, d = 1, e = b, g = 0, f = 1; g != e; )
                    c *= b,
                    f *= -1,
                    e = (g = e) + f * c / ++d;
                return e
            }
            return Math.log(1 + b)
        }
    });
    q("Math.atanh", function(a) {
        if (a)
            return a;
        var b = Math.log1p;
        return function(c) {
            c = Number(c);
            return (b(c) - b(-c)) / 2
        }
    });
    q("Math.cbrt", function(a) {
        return a ? a : function(b) {
            if (0 === b)
                return b;
            b = Number(b);
            var c = Math.pow(Math.abs(b), 1 / 3);
            return 0 > b ? -c : c
        }
    });
    q("Math.clz32", function(a) {
        return a ? a : function(b) {
            b = Number(b) >>> 0;
            if (0 === b)
                return 32;
            var c = 0;
            0 === (b & 4294901760) && (b <<= 16,
            c += 16);
            0 === (b & 4278190080) && (b <<= 8,
            c += 8);
            0 === (b & 4026531840) && (b <<= 4,
            c += 4);
            0 === (b & 3221225472) && (b <<= 2,
            c += 2);
            0 === (b & 2147483648) && c++;
            return c
        }
    });
    q("Math.cosh", function(a) {
        if (a)
            return a;
        var b = Math.exp;
        return function(c) {
            c = Number(c);
            return (b(c) + b(-c)) / 2
        }
    });
    q("Math.expm1", function(a) {
        return a ? a : function(b) {
            b = Number(b);
            if (.25 > b && -.25 < b) {
                for (var c = b, d = 1, e = b, g = 0; g != e; )
                    c *= b / ++d,
                    e = (g = e) + c;
                return e
            }
            return Math.exp(b) - 1
        }
    });
    q("Math.fround", function(a) {
        if (a)
            return a;
        if ("function" !== typeof Float32Array)
            return function(c) {
                return c
            }
            ;
        var b = new Float32Array(1);
        return function(c) {
            b[0] = c;
            return b[0]
        }
    });
    q("Math.hypot", function(a) {
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
                    var g = Number(arguments[c]) / e;
                    d += g * g
                }
                return Math.sqrt(d) * e
            }
            for (c = d = 0; c < arguments.length; c++)
                g = Number(arguments[c]),
                d += g * g;
            return Math.sqrt(d)
        }
    });
    q("Math.imul", function(a) {
        return a ? a : function(b, c) {
            b = Number(b);
            c = Number(c);
            var d = b & 65535
              , e = c & 65535;
            return d * e + ((b >>> 16 & 65535) * e + d * (c >>> 16 & 65535) << 16 >>> 0) | 0
        }
    });
    q("Math.log10", function(a) {
        return a ? a : function(b) {
            return Math.log(b) / Math.LN10
        }
    });
    q("Math.log2", function(a) {
        return a ? a : function(b) {
            return Math.log(b) / Math.LN2
        }
    });
    q("Math.sign", function(a) {
        return a ? a : function(b) {
            b = Number(b);
            return 0 === b || isNaN(b) ? b : 0 < b ? 1 : -1
        }
    });
    q("Math.sinh", function(a) {
        if (a)
            return a;
        var b = Math.exp;
        return function(c) {
            c = Number(c);
            return 0 === c ? c : (b(c) - b(-c)) / 2
        }
    });
    q("Math.tanh", function(a) {
        return a ? a : function(b) {
            b = Number(b);
            if (0 === b)
                return b;
            var c = Math.exp(-2 * Math.abs(b));
            c = (1 - c) / (1 + c);
            return 0 > b ? -c : c
        }
    });
    q("Math.trunc", function(a) {
        return a ? a : function(b) {
            b = Number(b);
            if (isNaN(b) || Infinity === b || -Infinity === b || 0 === b)
                return b;
            var c = Math.floor(Math.abs(b));
            return 0 > b ? -c : c
        }
    });
    q("Number.EPSILON", function() {
        return Math.pow(2, -52)
    });
    q("Number.MAX_SAFE_INTEGER", function() {
        return 9007199254740991
    });
    q("Number.MIN_SAFE_INTEGER", function() {
        return -9007199254740991
    });
    q("Number.isFinite", function(a) {
        return a ? a : function(b) {
            return "number" !== typeof b ? !1 : !isNaN(b) && Infinity !== b && -Infinity !== b
        }
    });
    q("Number.isInteger", function(a) {
        return a ? a : function(b) {
            return Number.isFinite(b) ? b === Math.floor(b) : !1
        }
    });
    q("Number.isNaN", function(a) {
        return a ? a : function(b) {
            return "number" === typeof b && isNaN(b)
        }
    });
    q("Number.isSafeInteger", function(a) {
        return a ? a : function(b) {
            return Number.isInteger(b) && Math.abs(b) <= Number.MAX_SAFE_INTEGER
        }
    });
    q("Number.parseFloat", function(a) {
        return a || parseFloat
    });
    q("Number.parseInt", function(a) {
        return a || parseInt
    });
    q("Object.entries", function(a) {
        return a ? a : function(b) {
            var c = [], d;
            for (d in b)
                t(b, d) && c.push([d, b[d]]);
            return c
        }
    });
    q("Object.fromEntries", function(a) {
        return a ? a : function(b) {
            var c = {};
            if (!(Symbol.iterator in b))
                throw new TypeError("" + b + " is not iterable");
            b = b[Symbol.iterator].call(b);
            for (var d = b.next(); !d.done; d = b.next()) {
                d = d.value;
                if (Object(d) !== d)
                    throw new TypeError("iterable for fromEntries should yield objects");
                c[d[0]] = d[1]
            }
            return c
        }
    });
    q("Reflect", function(a) {
        return a ? a : {}
    });
    q("Object.getOwnPropertySymbols", function(a) {
        return a ? a : function() {
            return []
        }
    });
    q("Reflect.ownKeys", function(a) {
        return a ? a : function(b) {
            var c = []
              , d = Object.getOwnPropertyNames(b);
            b = Object.getOwnPropertySymbols(b);
            for (var e = 0; e < d.length; e++)
                ("jscomp_symbol_" == d[e].substring(0, 14) ? b : c).push(d[e]);
            return c.concat(b)
        }
    });
    q("Object.getOwnPropertyDescriptors", function(a) {
        return a ? a : function(b) {
            for (var c = {}, d = Reflect.ownKeys(b), e = 0; e < d.length; e++)
                c[d[e]] = Object.getOwnPropertyDescriptor(b, d[e]);
            return c
        }
    });
    q("Object.values", function(a) {
        return a ? a : function(b) {
            var c = [], d;
            for (d in b)
                t(b, d) && c.push(b[d]);
            return c
        }
    });
    q("Promise.allSettled", function(a) {
        function b(d) {
            return {
                status: "fulfilled",
                value: d
            }
        }
        function c(d) {
            return {
                status: "rejected",
                reason: d
            }
        }
        return a ? a : function(d) {
            var e = this;
            d = Array.from(d, function(g) {
                return e.resolve(g).then(b, c)
            });
            return e.all(d)
        }
    });
    q("Promise.prototype.finally", function(a) {
        return a ? a : function(b) {
            return this.then(function(c) {
                return Promise.resolve(b()).then(function() {
                    return c
                })
            }, function(c) {
                return Promise.resolve(b()).then(function() {
                    throw c;
                })
            })
        }
    });
    var na = "function" == typeof Object.create ? Object.create : function(a) {
        function b() {}
        b.prototype = a;
        return new b
    }
    ;
    function oa(a, b) {
        a.prototype = na(b.prototype);
        a.prototype.constructor = a;
        if (w)
            w(a, b);
        else
            for (var c in b)
                if ("prototype" != c)
                    if (Object.defineProperties) {
                        var d = Object.getOwnPropertyDescriptor(b, c);
                        d && Object.defineProperty(a, c, d)
                    } else
                        a[c] = b[c];
        a.V = b.prototype
    }
    q("AggregateError", function(a) {
        function b(c, d) {
            d = Error(d);
            "stack"in d && (this.stack = d.stack);
            this.errors = c;
            this.message = d.message
        }
        if (a)
            return a;
        oa(b, Error);
        b.prototype.name = "AggregateError";
        return b
    });
    q("Promise.any", function(a) {
        return a ? a : function(b) {
            b = b instanceof Array ? b : Array.from(b);
            return Promise.all(b.map(function(c) {
                return Promise.resolve(c).then(function(d) {
                    throw d;
                }, function(d) {
                    return d
                })
            })).then(function(c) {
                throw new AggregateError(c,"All promises were rejected");
            }, function(c) {
                return c
            })
        }
    });
    q("Reflect.apply", function(a) {
        if (a)
            return a;
        var b = Function.prototype.apply;
        return function(c, d, e) {
            return b.call(c, d, e)
        }
    });
    var pa = function() {
        function a() {
            function c() {}
            new c;
            Reflect.construct(c, [], function() {});
            return new c instanceof c
        }
        if ("undefined" != typeof Reflect && Reflect.construct) {
            if (a())
                return Reflect.construct;
            var b = Reflect.construct;
            return function(c, d, e) {
                c = b(c, d);
                e && Reflect.setPrototypeOf(c, e.prototype);
                return c
            }
        }
        return function(c, d, e) {
            void 0 === e && (e = c);
            e = na(e.prototype || Object.prototype);
            return Function.prototype.apply.call(c, e, d) || e
        }
    }();
    q("Reflect.construct", function() {
        return pa
    });
    q("Reflect.defineProperty", function(a) {
        return a ? a : function(b, c, d) {
            try {
                Object.defineProperty(b, c, d);
                var e = Object.getOwnPropertyDescriptor(b, c);
                return e ? e.configurable === (d.configurable || !1) && e.enumerable === (d.enumerable || !1) && ("value"in e ? e.value === d.value && e.writable === (d.writable || !1) : e.get === d.get && e.set === d.set) : !1
            } catch (g) {
                return !1
            }
        }
    });
    q("Reflect.deleteProperty", function(a) {
        return a ? a : function(b, c) {
            if (!t(b, c))
                return !0;
            try {
                return delete b[c]
            } catch (d) {
                return !1
            }
        }
    });
    q("Reflect.getOwnPropertyDescriptor", function(a) {
        return a || Object.getOwnPropertyDescriptor
    });
    q("Reflect.getPrototypeOf", function(a) {
        return a || Object.getPrototypeOf
    });
    function qa(a, b) {
        for (; a; ) {
            var c = Reflect.getOwnPropertyDescriptor(a, b);
            if (c)
                return c;
            a = Reflect.getPrototypeOf(a)
        }
    }
    q("Reflect.get", function(a) {
        return a ? a : function(b, c, d) {
            if (2 >= arguments.length)
                return b[c];
            var e = qa(b, c);
            if (e)
                return e.get ? e.get.call(d) : e.value
        }
    });
    q("Reflect.has", function(a) {
        return a ? a : function(b, c) {
            return c in b
        }
    });
    q("Reflect.isExtensible", function(a) {
        return a ? a : "function" == typeof Object.isExtensible ? Object.isExtensible : function() {
            return !0
        }
    });
    q("Reflect.preventExtensions", function(a) {
        return a ? a : "function" != typeof Object.preventExtensions ? function() {
            return !1
        }
        : function(b) {
            Object.preventExtensions(b);
            return !Object.isExtensible(b)
        }
    });
    q("Reflect.set", function(a) {
        return a ? a : function(b, c, d, e) {
            var g = qa(b, c);
            return g ? g.set ? (g.set.call(3 < arguments.length ? e : b, d),
            !0) : g.writable && !Object.isFrozen(b) ? (b[c] = d,
            !0) : !1 : Reflect.isExtensible(b) ? (b[c] = d,
            !0) : !1
        }
    });
    q("Reflect.setPrototypeOf", function(a) {
        return a ? a : w ? function(b, c) {
            try {
                return w(b, c),
                !0
            } catch (d) {
                return !1
            }
        }
        : null
    });
    q("Set", function(a) {
        function b(c) {
            this.g = new Map;
            if (c) {
                c = r(c);
                for (var d; !(d = c.next()).done; )
                    this.add(d.value)
            }
            this.size = this.g.size
        }
        if (function() {
            if (!a || "function" != typeof a || !a.prototype.entries || "function" != typeof Object.seal)
                return !1;
            try {
                var c = Object.seal({
                    x: 4
                })
                  , d = new a(r([c]));
                if (!d.has(c) || 1 != d.size || d.add(c) != d || 1 != d.size || d.add({
                    x: 4
                }) != d || 2 != d.size)
                    return !1;
                var e = d.entries()
                  , g = e.next();
                if (g.done || g.value[0] != c || g.value[1] != c)
                    return !1;
                g = e.next();
                return g.done || g.value[0] == c || 4 != g.value[0].x || g.value[1] != g.value[0] ? !1 : e.next().done
            } catch (f) {
                return !1
            }
        }())
            return a;
        b.prototype.add = function(c) {
            c = 0 === c ? 0 : c;
            this.g.set(c, c);
            this.size = this.g.size;
            return this
        }
        ;
        b.prototype.delete = function(c) {
            c = this.g.delete(c);
            this.size = this.g.size;
            return c
        }
        ;
        b.prototype.clear = function() {
            this.g.clear();
            this.size = 0
        }
        ;
        b.prototype.has = function(c) {
            return this.g.has(c)
        }
        ;
        b.prototype.entries = function() {
            return this.g.entries()
        }
        ;
        b.prototype.values = function() {
            return this.g.values()
        }
        ;
        b.prototype.keys = b.prototype.values;
        b.prototype[Symbol.iterator] = b.prototype.values;
        b.prototype.forEach = function(c, d) {
            var e = this;
            this.g.forEach(function(g) {
                return c.call(d, g, g, e)
            })
        }
        ;
        return b
    });
    q("String.prototype.codePointAt", function(a) {
        return a ? a : function(b) {
            var c = u(this, null, "codePointAt")
              , d = c.length;
            b = Number(b) || 0;
            if (0 <= b && b < d) {
                b |= 0;
                var e = c.charCodeAt(b);
                if (55296 > e || 56319 < e || b + 1 === d)
                    return e;
                b = c.charCodeAt(b + 1);
                return 56320 > b || 57343 < b ? e : 1024 * (e - 55296) + b + 9216
            }
        }
    });
    q("String.fromCodePoint", function(a) {
        return a ? a : function(b) {
            for (var c = "", d = 0; d < arguments.length; d++) {
                var e = Number(arguments[d]);
                if (0 > e || 1114111 < e || e !== Math.floor(e))
                    throw new RangeError("invalid_code_point " + e);
                65535 >= e ? c += String.fromCharCode(e) : (e -= 65536,
                c += String.fromCharCode(e >>> 10 & 1023 | 55296),
                c += String.fromCharCode(e & 1023 | 56320))
            }
            return c
        }
    });
    q("String.prototype.includes", function(a) {
        return a ? a : function(b, c) {
            return -1 !== u(this, b, "includes").indexOf(b, c || 0)
        }
    });
    q("String.prototype.matchAll", function(a) {
        return a ? a : function(b) {
            if (b instanceof RegExp && !b.global)
                throw new TypeError("RegExp passed into String.prototype.matchAll() must have global tag.");
            var c = new RegExp(b,b instanceof RegExp ? void 0 : "g")
              , d = this
              , e = !1
              , g = {
                next: function() {
                    if (e)
                        return {
                            value: void 0,
                            done: !0
                        };
                    var f = c.exec(d);
                    if (!f)
                        return e = !0,
                        {
                            value: void 0,
                            done: !0
                        };
                    "" === f[0] && (c.lastIndex += 1);
                    return {
                        value: f,
                        done: !1
                    }
                }
            };
            g[Symbol.iterator] = function() {
                return g
            }
            ;
            return g
        }
    });
    function ra(a, b) {
        a = void 0 !== a ? String(a) : " ";
        return 0 < b && a ? a.repeat(Math.ceil(b / a.length)).substring(0, b) : ""
    }
    q("String.prototype.padEnd", function(a) {
        return a ? a : function(b, c) {
            var d = u(this, null, "padStart");
            return d + ra(c, b - d.length)
        }
    });
    q("String.prototype.padStart", function(a) {
        return a ? a : function(b, c) {
            var d = u(this, null, "padStart");
            return ra(c, b - d.length) + d
        }
    });
    q("String.prototype.replaceAll", function(a) {
        return a ? a : function(b, c) {
            if (b instanceof RegExp && !b.global)
                throw new TypeError("String.prototype.replaceAll called with a non-global RegExp argument.");
            return b instanceof RegExp ? this.replace(b, c) : this.replace(new RegExp(String(b).replace(/([-()\[\]{}+?*.$\^|,:#<!\\])/g, "\\$1").replace(/\x08/g, "\\x08"),"g"), c)
        }
    });
    q("String.prototype.trimRight", function(a) {
        function b() {
            return this.replace(/[\s\xa0]+$/, "")
        }
        return a || b
    });
    q("String.prototype.trimEnd", function(a) {
        return a || String.prototype.trimRight
    });
    function y(a) {
        return a ? a : Array.prototype.copyWithin
    }
    q("Int8Array.prototype.copyWithin", y);
    q("Uint8Array.prototype.copyWithin", y);
    q("Uint8ClampedArray.prototype.copyWithin", y);
    q("Int16Array.prototype.copyWithin", y);
    q("Uint16Array.prototype.copyWithin", y);
    q("Int32Array.prototype.copyWithin", y);
    q("Uint32Array.prototype.copyWithin", y);
    q("Float32Array.prototype.copyWithin", y);
    q("Float64Array.prototype.copyWithin", y);
    function z(a) {
        return a ? a : Array.prototype.fill
    }
    q("Int8Array.prototype.fill", z);
    q("Uint8Array.prototype.fill", z);
    q("Uint8ClampedArray.prototype.fill", z);
    q("Int16Array.prototype.fill", z);
    q("Uint16Array.prototype.fill", z);
    q("Int32Array.prototype.fill", z);
    q("Uint32Array.prototype.fill", z);
    q("Float32Array.prototype.fill", z);
    q("Float64Array.prototype.fill", z);
    q("WeakSet", function(a) {
        function b(c) {
            this.g = new WeakMap;
            if (c) {
                c = r(c);
                for (var d; !(d = c.next()).done; )
                    this.add(d.value)
            }
        }
        if (function() {
            if (!a || !Object.seal)
                return !1;
            try {
                var c = Object.seal({})
                  , d = Object.seal({})
                  , e = new a([c]);
                if (!e.has(c) || e.has(d))
                    return !1;
                e.delete(c);
                e.add(d);
                return !e.has(c) && e.has(d)
            } catch (g) {
                return !1
            }
        }())
            return a;
        b.prototype.add = function(c) {
            this.g.set(c, !0);
            return this
        }
        ;
        b.prototype.has = function(c) {
            return this.g.has(c)
        }
        ;
        b.prototype.delete = function(c) {
            return this.g.delete(c)
        }
        ;
        return b
    });
    var A = this || self;
    function B() {}
    function sa(a) {
        var b = typeof a;
        return "object" == b && null != a || "function" == b
    }
    function ta(a, b, c) {
        return a.call.apply(a.bind, arguments)
    }
    function ua(a, b, c) {
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
    function C(a, b, c) {
        Function.prototype.bind && -1 != Function.prototype.bind.toString().indexOf("native code") ? C = ta : C = ua;
        return C.apply(null, arguments)
    }
    function D(a, b) {
        a = a.split(".");
        var c = A;
        a[0]in c || "undefined" == typeof c.execScript || c.execScript("var " + a[0]);
        for (var d; a.length && (d = a.shift()); )
            a.length || void 0 === b ? c[d] && c[d] !== Object.prototype[d] ? c = c[d] : c = c[d] = {} : c[d] = b
    }
    function E(a, b) {
        function c() {}
        c.prototype = b.prototype;
        a.V = b.prototype;
        a.prototype = new c;
        a.prototype.constructor = a;
        a.W = function(d, e, g) {
            for (var f = Array(arguments.length - 2), h = 2; h < arguments.length; h++)
                f[h - 2] = arguments[h];
            return b.prototype[e].apply(d, f)
        }
    }
    function va(a) {
        return a
    }
    ;function F(a) {
        if (Error.captureStackTrace)
            Error.captureStackTrace(this, F);
        else {
            var b = Error().stack;
            b && (this.stack = b)
        }
        a && (this.message = String(a))
    }
    E(F, Error);
    F.prototype.name = "CustomError";
    function G(a, b) {
        this.g = a === wa && b || "";
        this.h = xa
    }
    G.prototype.L = !0;
    G.prototype.J = function() {
        return this.g
    }
    ;
    function ya(a) {
        return a instanceof G && a.constructor === G && a.h === xa ? a.g : "type_error:Const"
    }
    function I(a) {
        return new G(wa,a)
    }
    var xa = {}
      , wa = {};
    var za = {
        "gstatic.com": {
            loader: I("./charts/%{version}/loader.js"),
            debug: I("./charts/debug/%{version}/js/jsapi_debug_%{package}_module.js"),
            debug_i18n: I("./charts/debug/%{version}/i18n/jsapi_debug_i18n_%{package}_module__%{language}.js"),
            compiled: I("./charts/%{version}/js/jsapi_compiled_%{package}_module.js"),
            compiled_i18n: I("./charts/%{version}/i18n/jsapi_compiled_i18n_%{package}_module__%{language}.js"),
            css: I("./charts/%{version}/css/%{subdir}/%{filename}"),
            css2: I("./charts/%{version}/css/%{subdir1}/%{subdir2}/%{filename}"),
            third_party: I("./charts/%{version}/third_party/%{subdir}/%{filename}"),
            third_party2: I("./charts/%{version}/third_party/%{subdir1}/%{subdir2}/%{filename}"),
            third_party_gen: I("./charts/%{version}/third_party/%{subdir}/%{filename}")
        },
        "gstatic.cn": {
            loader: I("./charts/%{version}/loader.js"),
            debug: I("./charts/debug/%{version}/js/jsapi_debug_%{package}_module.js"),
            debug_i18n: I("./charts/debug/%{version}/i18n/jsapi_debug_i18n_%{package}_module__%{language}.js"),
            compiled: I("./charts/%{version}/js/jsapi_compiled_%{package}_module.js"),
            compiled_i18n: I("./charts/%{version}/i18n/jsapi_compiled_i18n_%{package}_module__%{language}.js"),
            css: I("./charts/%{version}/css/%{subdir}/%{filename}"),
            css2: I("./charts/%{version}/css/%{subdir1}/%{subdir2}/%{filename}"),
            third_party: I("./charts/%{version}/third_party/%{subdir}/%{filename}"),
            third_party2: I("./charts/%{version}/third_party/%{subdir1}/%{subdir2}/%{filename}"),
            third_party_gen: I("./charts/%{version}/third_party/%{subdir}/%{filename}")
        }
    }
      , Aa = ["default"]
      , Ba = {
        "default": [],
        graphics: ["default"],
        ui: ["graphics"],
        ui_base: ["graphics"],
        flashui: ["ui"],
        fw: ["ui"],
        geo: ["ui"],
        annotatedtimeline: ["annotationchart"],
        annotationchart: ["ui", "controls", "corechart", "table"],
        areachart: "browserchart",
        bar: ["fw", "dygraph", "webfontloader"],
        barchart: "browserchart",
        browserchart: ["ui"],
        bubbles: ["fw", "d3"],
        calendar: ["fw"],
        charteditor: "ui corechart imagechart annotatedtimeline gauge geochart motionchart orgchart table".split(" "),
        charteditor_base: "ui_base corechart imagechart annotatedtimeline gauge geochart motionchart orgchart table_base".split(" "),
        circles: ["fw", "d3"],
        clusterchart: ["corechart", "d3"],
        columnchart: "browserchart",
        controls: ["ui"],
        controls_base: ["ui_base"],
        corechart: ["ui"],
        gantt: ["fw", "dygraph"],
        gauge: ["ui"],
        geochart: ["geo"],
        geomap: ["flashui", "geo"],
        geomap_base: ["ui_base"],
        helloworld: ["fw"],
        imagechart: ["ui"],
        imageareachart: "imagechart",
        imagebarchart: "imagechart",
        imagelinechart: "imagechart",
        imagepiechart: "imagechart",
        imagesparkline: "imagechart",
        line: ["fw", "dygraph", "webfontloader"],
        linechart: "browserchart",
        map: ["geo"],
        matrix: ["vegachart"],
        motionchart: ["flashui"],
        orgchart: ["ui"],
        overtimecharts: ["ui", "corechart"],
        piechart: "browserchart",
        sankey: ["fw", "d3", "d3.sankey"],
        scatter: ["fw", "dygraph", "webfontloader"],
        scatterchart: "browserchart",
        sunburst: ["fw", "d3"],
        streamgraph: ["fw", "d3"],
        table: ["ui"],
        table_base: ["ui_base"],
        timeline: ["fw", "ui", "dygraph"],
        treemap: ["ui"],
        vegachart: ["graphics"],
        wordtree: ["ui"]
    }
      , Ca = {
        d3: {
            subdir1: "d3",
            subdir2: "v5",
            filename: "d3.js"
        },
        "d3.sankey": {
            subdir1: "d3_sankey",
            subdir2: "v4",
            filename: "d3.sankey.js"
        },
        webfontloader: {
            subdir: "webfontloader",
            filename: "webfont.js"
        }
    }
      , Da = {
        dygraph: {
            subdir: "dygraphs",
            filename: "dygraph-tickers-combined.js"
        }
    }
      , Ea = {
        "default": [{
            subdir: "core",
            filename: "tooltip.css"
        }],
        annotationchart: [{
            subdir: "annotationchart",
            filename: "annotationchart.css"
        }],
        charteditor: [{
            subdir: "charteditor",
            filename: "charteditor.css"
        }],
        charteditor_base: [{
            subdir: "charteditor_base",
            filename: "charteditor_base.css"
        }],
        controls: [{
            subdir: "controls",
            filename: "controls.css"
        }],
        imagesparkline: [{
            subdir: "imagechart",
            filename: "imagesparkline.css"
        }],
        orgchart: [{
            subdir: "orgchart",
            filename: "orgchart.css"
        }],
        table: [{
            subdir: "table",
            filename: "table.css"
        }, {
            subdir: "util",
            filename: "format.css"
        }],
        table_base: [{
            subdir: "util",
            filename: "format.css"
        }, {
            subdir: "table",
            filename: "table_base.css"
        }],
        ui: [{
            subdir: "util",
            filename: "util.css"
        }],
        ui_base: [{
            subdir: "util",
            filename: "util_base.css"
        }]
    };
    var J = Array.prototype.forEach ? function(a, b) {
        Array.prototype.forEach.call(a, b, void 0)
    }
    : function(a, b) {
        for (var c = a.length, d = "string" === typeof a ? a.split("") : a, e = 0; e < c; e++)
            e in d && b.call(void 0, d[e], e, a)
    }
      , Fa = Array.prototype.filter ? function(a, b) {
        return Array.prototype.filter.call(a, b, void 0)
    }
    : function(a, b) {
        for (var c = a.length, d = [], e = 0, g = "string" === typeof a ? a.split("") : a, f = 0; f < c; f++)
            if (f in g) {
                var h = g[f];
                b.call(void 0, h, f, a) && (d[e++] = h)
            }
        return d
    }
      , K = Array.prototype.map ? function(a, b) {
        return Array.prototype.map.call(a, b, void 0)
    }
    : function(a, b) {
        for (var c = a.length, d = Array(c), e = "string" === typeof a ? a.split("") : a, g = 0; g < c; g++)
            g in e && (d[g] = b.call(void 0, e[g], g, a));
        return d
    }
      , Ga = Array.prototype.some ? function(a, b) {
        return Array.prototype.some.call(a, b, void 0)
    }
    : function(a, b) {
        for (var c = a.length, d = "string" === typeof a ? a.split("") : a, e = 0; e < c; e++)
            if (e in d && b.call(void 0, d[e], e, a))
                return !0;
        return !1
    }
    ;
    function Ha(a, b) {
        a: {
            for (var c = "string" === typeof a ? a.split("") : a, d = a.length - 1; 0 <= d; d--)
                if (d in c && b.call(void 0, c[d], d, a)) {
                    b = d;
                    break a
                }
            b = -1
        }
        return 0 > b ? null : "string" === typeof a ? a.charAt(b) : a[b]
    }
    function Ia(a, b) {
        for (var c = 1; c < arguments.length; c++) {
            var d = arguments[c];
            var e = typeof d;
            e = "object" != e ? e : d ? Array.isArray(d) ? "array" : e : "null";
            if ("array" == e || "object" == e && "number" == typeof d.length) {
                e = a.length || 0;
                var g = d.length || 0;
                a.length = e + g;
                for (var f = 0; f < g; f++)
                    a[e + f] = d[f]
            } else
                a.push(d)
        }
    }
    ;var L;
    function M(a, b) {
        this.g = b === Ja ? a : ""
    }
    M.prototype.L = !0;
    M.prototype.J = function() {
        return this.g.toString()
    }
    ;
    M.prototype.toString = function() {
        return this.g + ""
    }
    ;
    function N(a) {
        return a instanceof M && a.constructor === M ? a.g : "type_error:TrustedResourceUrl"
    }
    function Ka(a, b) {
        var c = ya(a);
        if (!La.test(c))
            throw Error("Invalid TrustedResourceUrl format: " + c);
        a = c.replace(Ma, function(d, e) {
            if (!Object.prototype.hasOwnProperty.call(b, e))
                throw Error('Found marker, "' + e + '", in format string, "' + c + '", but no valid label mapping found in args: ' + JSON.stringify(b));
            d = b[e];
            return d instanceof G ? ya(d) : encodeURIComponent(String(d))
        });
        return Na(a)
    }
    var Ma = /%{(\w+)}/g
      , La = /^((https:)?\/\/[0-9a-z.:[\]-]+\/|\/[^/\\]|[^:/\\%]+\/|[^:/\\%]*[?#]|about:blank#)/i
      , Oa = /^([^?#]*)(\?[^#]*)?(#[\s\S]*)?/
      , Ja = {};
    function Na(a) {
        if (void 0 === L) {
            var b = null;
            var c = A.trustedTypes;
            if (c && c.createPolicy) {
                try {
                    b = c.createPolicy("goog#html", {
                        createHTML: va,
                        createScript: va,
                        createScriptURL: va
                    })
                } catch (d) {
                    A.console && A.console.error(d.message)
                }
                L = b
            } else
                L = b
        }
        a = (b = L) ? b.createScriptURL(a) : a;
        return new M(a,Ja)
    }
    function Pa(a, b, c) {
        if (null == c)
            return b;
        if ("string" === typeof c)
            return c ? a + encodeURIComponent(c) : "";
        for (var d in c)
            if (Object.prototype.hasOwnProperty.call(c, d)) {
                var e = c[d];
                e = Array.isArray(e) ? e : [e];
                for (var g = 0; g < e.length; g++) {
                    var f = e[g];
                    null != f && (b || (b = a),
                    b += (b.length > a.length ? "&" : "") + encodeURIComponent(d) + "=" + encodeURIComponent(String(f)))
                }
            }
        return b
    }
    ;var Qa = String.prototype.trim ? function(a) {
        return a.trim()
    }
    : function(a) {
        return /^[\s\xa0]*([\s\S]*?)[\s\xa0]*$/.exec(a)[1]
    }
    ;
    function Ra(a, b) {
        return a < b ? -1 : a > b ? 1 : 0
    }
    ;var O;
    a: {
        var Sa = A.navigator;
        if (Sa) {
            var Ta = Sa.userAgent;
            if (Ta) {
                O = Ta;
                break a
            }
        }
        O = ""
    }
    function P(a) {
        return -1 != O.indexOf(a)
    }
    ;function Ua(a, b) {
        for (var c in a)
            b.call(void 0, a[c], c, a)
    }
    var Va = "constructor hasOwnProperty isPrototypeOf propertyIsEnumerable toLocaleString toString valueOf".split(" ");
    function Wa(a, b) {
        for (var c, d, e = 1; e < arguments.length; e++) {
            d = arguments[e];
            for (c in d)
                a[c] = d[c];
            for (var g = 0; g < Va.length; g++)
                c = Va[g],
                Object.prototype.hasOwnProperty.call(d, c) && (a[c] = d[c])
        }
    }
    ;function Xa(a) {
        a: {
            var b = (a.ownerDocument && a.ownerDocument.defaultView || A).document;
            if (b.querySelector && (b = b.querySelector("script[nonce]")) && (b = b.nonce || b.getAttribute("nonce")) && Ya.test(b))
                break a;
            b = ""
        }
        b && a.setAttribute("nonce", b)
    }
    var Ya = /^[\w+/_-]+[=]{0,2}$/;
    function Za(a) {
        var b = $a;
        return Object.prototype.hasOwnProperty.call(b, 11) ? b[11] : b[11] = a(11)
    }
    ;var ab = P("Opera"), bb = P("Trident") || P("MSIE"), cb = P("Edge"), db = P("Gecko") && !(-1 != O.toLowerCase().indexOf("webkit") && !P("Edge")) && !(P("Trident") || P("MSIE")) && !P("Edge"), eb = -1 != O.toLowerCase().indexOf("webkit") && !P("Edge"), fb;
    a: {
        var gb = ""
          , hb = function() {
            var a = O;
            if (db)
                return /rv:([^\);]+)(\)|;)/.exec(a);
            if (cb)
                return /Edge\/([\d\.]+)/.exec(a);
            if (bb)
                return /\b(?:MSIE|rv)[: ]([^\);]+)(\)|;)/.exec(a);
            if (eb)
                return /WebKit\/(\S+)/.exec(a);
            if (ab)
                return /(?:Version)[ \/]?(\S+)/.exec(a)
        }();
        hb && (gb = hb ? hb[1] : "");
        if (bb) {
            var ib, jb = A.document;
            ib = jb ? jb.documentMode : void 0;
            if (null != ib && ib > parseFloat(gb)) {
                fb = String(ib);
                break a
            }
        }
        fb = gb
    }
    var kb = fb
      , $a = {};
    function lb() {
        return Za(function() {
            for (var a = 0, b = Qa(String(kb)).split("."), c = Qa("11").split("."), d = Math.max(b.length, c.length), e = 0; 0 == a && e < d; e++) {
                var g = b[e] || ""
                  , f = c[e] || "";
                do {
                    g = /(\d*)(\D*)(.*)/.exec(g) || ["", "", "", ""];
                    f = /(\d*)(\D*)(.*)/.exec(f) || ["", "", "", ""];
                    if (0 == g[0].length && 0 == f[0].length)
                        break;
                    a = Ra(0 == g[1].length ? 0 : parseInt(g[1], 10), 0 == f[1].length ? 0 : parseInt(f[1], 10)) || Ra(0 == g[2].length, 0 == f[2].length) || Ra(g[2], f[2]);
                    g = g[3];
                    f = f[3]
                } while (0 == a)
            }
            return 0 <= a
        })
    }
    ;function mb(a, b) {
        Ua(b, function(c, d) {
            c && "object" == typeof c && c.L && (c = c.J());
            "style" == d ? a.style.cssText = c : "class" == d ? a.className = c : "for" == d ? a.htmlFor = c : nb.hasOwnProperty(d) ? a.setAttribute(nb[d], c) : 0 == d.lastIndexOf("aria-", 0) || 0 == d.lastIndexOf("data-", 0) ? a.setAttribute(d, c) : a[d] = c
        })
    }
    var nb = {
        cellpadding: "cellPadding",
        cellspacing: "cellSpacing",
        colspan: "colSpan",
        frameborder: "frameBorder",
        height: "height",
        maxlength: "maxLength",
        nonce: "nonce",
        role: "role",
        rowspan: "rowSpan",
        type: "type",
        usemap: "useMap",
        valign: "vAlign",
        width: "width"
    };
    function ob(a, b) {
        b = String(b);
        "application/xhtml+xml" === a.contentType && (b = b.toLowerCase());
        return a.createElement(b)
    }
    function pb(a) {
        this.g = a || A.document || document
    }
    ;function qb(a, b) {
        this.i = a;
        this.j = b;
        this.h = 0;
        this.g = null
    }
    qb.prototype.get = function() {
        if (0 < this.h) {
            this.h--;
            var a = this.g;
            this.g = a.next;
            a.next = null
        } else
            a = this.i();
        return a
    }
    ;
    function rb(a, b) {
        a.j(b);
        100 > a.h && (a.h++,
        b.next = a.g,
        a.g = b)
    }
    ;var sb;
    function tb() {
        var a = A.MessageChannel;
        "undefined" === typeof a && "undefined" !== typeof window && window.postMessage && window.addEventListener && !P("Presto") && (a = function() {
            var e = ob(document, "IFRAME");
            e.style.display = "none";
            document.documentElement.appendChild(e);
            var g = e.contentWindow;
            e = g.document;
            e.open();
            e.close();
            var f = "callImmediate" + Math.random()
              , h = "file:" == g.location.protocol ? "*" : g.location.protocol + "//" + g.location.host;
            e = C(function(k) {
                if (("*" == h || k.origin == h) && k.data == f)
                    this.port1.onmessage()
            }, this);
            g.addEventListener("message", e, !1);
            this.port1 = {};
            this.port2 = {
                postMessage: function() {
                    g.postMessage(f, h)
                }
            }
        }
        );
        if ("undefined" !== typeof a && !P("Trident") && !P("MSIE")) {
            var b = new a
              , c = {}
              , d = c;
            b.port1.onmessage = function() {
                if (void 0 !== c.next) {
                    c = c.next;
                    var e = c.I;
                    c.I = null;
                    e()
                }
            }
            ;
            return function(e) {
                d.next = {
                    I: e
                };
                d = d.next;
                b.port2.postMessage(0)
            }
        }
        return function(e) {
            A.setTimeout(e, 0)
        }
    }
    ;function ub(a) {
        A.setTimeout(function() {
            throw a;
        }, 0)
    }
    ;function vb() {
        this.h = this.g = null
    }
    vb.prototype.add = function(a, b) {
        var c = wb.get();
        c.set(a, b);
        this.h ? this.h.next = c : this.g = c;
        this.h = c
    }
    ;
    function xb() {
        var a = yb
          , b = null;
        a.g && (b = a.g,
        a.g = a.g.next,
        a.g || (a.h = null),
        b.next = null);
        return b
    }
    var wb = new qb(function() {
        return new zb
    }
    ,function(a) {
        return a.reset()
    }
    );
    function zb() {
        this.next = this.g = this.h = null
    }
    zb.prototype.set = function(a, b) {
        this.h = a;
        this.g = b;
        this.next = null
    }
    ;
    zb.prototype.reset = function() {
        this.next = this.g = this.h = null
    }
    ;
    function Ab(a, b) {
        Bb || Cb();
        Db || (Bb(),
        Db = !0);
        yb.add(a, b)
    }
    var Bb;
    function Cb() {
        if (A.Promise && A.Promise.resolve) {
            var a = A.Promise.resolve(void 0);
            Bb = function() {
                a.then(Eb)
            }
        } else
            Bb = function() {
                var b = Eb;
                "function" !== typeof A.setImmediate || A.Window && A.Window.prototype && !P("Edge") && A.Window.prototype.setImmediate == A.setImmediate ? (sb || (sb = tb()),
                sb(b)) : A.setImmediate(b)
            }
    }
    var Db = !1
      , yb = new vb;
    function Eb() {
        for (var a; a = xb(); ) {
            try {
                a.h.call(a.g)
            } catch (b) {
                ub(b)
            }
            rb(wb, a)
        }
        Db = !1
    }
    ;function Fb(a) {
        if (!a)
            return !1;
        try {
            return !!a.$goog_Thenable
        } catch (b) {
            return !1
        }
    }
    ;function Q(a) {
        this.g = 0;
        this.u = void 0;
        this.j = this.h = this.i = null;
        this.l = this.o = !1;
        if (a != B)
            try {
                var b = this;
                a.call(void 0, function(c) {
                    R(b, 2, c)
                }, function(c) {
                    R(b, 3, c)
                })
            } catch (c) {
                R(this, 3, c)
            }
    }
    function Gb() {
        this.next = this.i = this.h = this.j = this.g = null;
        this.l = !1
    }
    Gb.prototype.reset = function() {
        this.i = this.h = this.j = this.g = null;
        this.l = !1
    }
    ;
    var Hb = new qb(function() {
        return new Gb
    }
    ,function(a) {
        a.reset()
    }
    );
    function Ib(a, b, c) {
        var d = Hb.get();
        d.j = a;
        d.h = b;
        d.i = c;
        return d
    }
    Q.prototype.then = function(a, b, c) {
        return Jb(this, "function" === typeof a ? a : null, "function" === typeof b ? b : null, c)
    }
    ;
    Q.prototype.$goog_Thenable = !0;
    Q.prototype.cancel = function(a) {
        if (0 == this.g) {
            var b = new S(a);
            Ab(function() {
                Kb(this, b)
            }, this)
        }
    }
    ;
    function Kb(a, b) {
        if (0 == a.g)
            if (a.i) {
                var c = a.i;
                if (c.h) {
                    for (var d = 0, e = null, g = null, f = c.h; f && (f.l || (d++,
                    f.g == a && (e = f),
                    !(e && 1 < d))); f = f.next)
                        e || (g = f);
                    e && (0 == c.g && 1 == d ? Kb(c, b) : (g ? (d = g,
                    d.next == c.j && (c.j = d),
                    d.next = d.next.next) : Lb(c),
                    Mb(c, e, 3, b)))
                }
                a.i = null
            } else
                R(a, 3, b)
    }
    function Nb(a, b) {
        a.h || 2 != a.g && 3 != a.g || Ob(a);
        a.j ? a.j.next = b : a.h = b;
        a.j = b
    }
    function Jb(a, b, c, d) {
        var e = Ib(null, null, null);
        e.g = new Q(function(g, f) {
            e.j = b ? function(h) {
                try {
                    var k = b.call(d, h);
                    g(k)
                } catch (m) {
                    f(m)
                }
            }
            : g;
            e.h = c ? function(h) {
                try {
                    var k = c.call(d, h);
                    void 0 === k && h instanceof S ? f(h) : g(k)
                } catch (m) {
                    f(m)
                }
            }
            : f
        }
        );
        e.g.i = a;
        Nb(a, e);
        return e.g
    }
    Q.prototype.A = function(a) {
        this.g = 0;
        R(this, 2, a)
    }
    ;
    Q.prototype.B = function(a) {
        this.g = 0;
        R(this, 3, a)
    }
    ;
    function R(a, b, c) {
        if (0 == a.g) {
            a === c && (b = 3,
            c = new TypeError("Promise cannot resolve to itself"));
            a.g = 1;
            a: {
                var d = c
                  , e = a.A
                  , g = a.B;
                if (d instanceof Q) {
                    Nb(d, Ib(e || B, g || null, a));
                    var f = !0
                } else if (Fb(d))
                    d.then(e, g, a),
                    f = !0;
                else {
                    if (sa(d))
                        try {
                            var h = d.then;
                            if ("function" === typeof h) {
                                Pb(d, h, e, g, a);
                                f = !0;
                                break a
                            }
                        } catch (k) {
                            g.call(a, k);
                            f = !0;
                            break a
                        }
                    f = !1
                }
            }
            f || (a.u = c,
            a.g = b,
            a.i = null,
            Ob(a),
            3 != b || c instanceof S || Qb(a, c))
        }
    }
    function Pb(a, b, c, d, e) {
        function g(k) {
            h || (h = !0,
            d.call(e, k))
        }
        function f(k) {
            h || (h = !0,
            c.call(e, k))
        }
        var h = !1;
        try {
            b.call(a, f, g)
        } catch (k) {
            g(k)
        }
    }
    function Ob(a) {
        a.o || (a.o = !0,
        Ab(a.v, a))
    }
    function Lb(a) {
        var b = null;
        a.h && (b = a.h,
        a.h = b.next,
        b.next = null);
        a.h || (a.j = null);
        return b
    }
    Q.prototype.v = function() {
        for (var a; a = Lb(this); )
            Mb(this, a, this.g, this.u);
        this.o = !1
    }
    ;
    function Mb(a, b, c, d) {
        if (3 == c && b.h && !b.l)
            for (; a && a.l; a = a.i)
                a.l = !1;
        if (b.g)
            b.g.i = null,
            Rb(b, c, d);
        else
            try {
                b.l ? b.j.call(b.i) : Rb(b, c, d)
            } catch (e) {
                Sb.call(null, e)
            }
        rb(Hb, b)
    }
    function Rb(a, b, c) {
        2 == b ? a.j.call(a.i, c) : a.h && a.h.call(a.i, c)
    }
    function Qb(a, b) {
        a.l = !0;
        Ab(function() {
            a.l && Sb.call(null, b)
        })
    }
    var Sb = ub;
    function S(a) {
        F.call(this, a)
    }
    E(S, F);
    S.prototype.name = "cancel";
    /*
 Portions of this code are from MochiKit, received by
 The Closure Authors under the MIT license. All other code is Copyright
 2005-2009 The Closure Authors. All Rights Reserved.
*/
    function T(a, b) {
        this.l = [];
        this.D = a;
        this.C = b || null;
        this.j = this.i = !1;
        this.h = void 0;
        this.A = this.G = this.u = !1;
        this.o = 0;
        this.g = null;
        this.v = 0
    }
    T.prototype.cancel = function(a) {
        if (this.i)
            this.h instanceof T && this.h.cancel();
        else {
            if (this.g) {
                var b = this.g;
                delete this.g;
                a ? b.cancel(a) : (b.v--,
                0 >= b.v && b.cancel())
            }
            this.D ? this.D.call(this.C, this) : this.A = !0;
            this.i || (a = new U(this),
            V(this),
            W(this, !1, a))
        }
    }
    ;
    T.prototype.B = function(a, b) {
        this.u = !1;
        W(this, a, b)
    }
    ;
    function W(a, b, c) {
        a.i = !0;
        a.h = c;
        a.j = !b;
        Tb(a)
    }
    function V(a) {
        if (a.i) {
            if (!a.A)
                throw new Ub(a);
            a.A = !1
        }
    }
    function Vb(a, b, c, d) {
        a.l.push([b, c, d]);
        a.i && Tb(a)
    }
    T.prototype.then = function(a, b, c) {
        var d, e, g = new Q(function(f, h) {
            e = f;
            d = h
        }
        );
        Vb(this, e, function(f) {
            f instanceof U ? g.cancel() : d(f)
        });
        return g.then(a, b, c)
    }
    ;
    T.prototype.$goog_Thenable = !0;
    function Wb(a) {
        return Ga(a.l, function(b) {
            return "function" === typeof b[1]
        })
    }
    function Tb(a) {
        if (a.o && a.i && Wb(a)) {
            var b = a.o
              , c = Xb[b];
            c && (A.clearTimeout(c.g),
            delete Xb[b]);
            a.o = 0
        }
        a.g && (a.g.v--,
        delete a.g);
        b = a.h;
        for (var d = c = !1; a.l.length && !a.u; ) {
            var e = a.l.shift()
              , g = e[0]
              , f = e[1];
            e = e[2];
            if (g = a.j ? f : g)
                try {
                    var h = g.call(e || a.C, b);
                    void 0 !== h && (a.j = a.j && (h == b || h instanceof Error),
                    a.h = b = h);
                    if (Fb(b) || "function" === typeof A.Promise && b instanceof A.Promise)
                        d = !0,
                        a.u = !0
                } catch (k) {
                    b = k,
                    a.j = !0,
                    Wb(a) || (c = !0)
                }
        }
        a.h = b;
        d && (h = C(a.B, a, !0),
        d = C(a.B, a, !1),
        b instanceof T ? (Vb(b, h, d),
        b.G = !0) : b.then(h, d));
        c && (b = new Yb(b),
        Xb[b.g] = b,
        a.o = b.g)
    }
    function Zb() {
        var a = new T;
        V(a);
        W(a, !0, null);
        return a
    }
    function Ub() {
        F.call(this)
    }
    E(Ub, F);
    Ub.prototype.message = "Deferred has already fired";
    Ub.prototype.name = "AlreadyCalledError";
    function U() {
        F.call(this)
    }
    E(U, F);
    U.prototype.message = "Deferred was canceled";
    U.prototype.name = "CanceledError";
    function Yb(a) {
        this.g = A.setTimeout(C(this.i, this), 0);
        this.h = a
    }
    Yb.prototype.i = function() {
        delete Xb[this.g];
        throw this.h;
    }
    ;
    var Xb = {};
    var $b, ac = [];
    function bc(a, b) {
        function c() {
            var e = a.shift();
            e = cc(e, b);
            a.length && Vb(e, c, c, void 0);
            return e
        }
        if (!a.length)
            return Zb();
        var d = ac.length;
        Ia(ac, a);
        if (d)
            return $b;
        a = ac;
        return $b = c()
    }
    function cc(a, b) {
        var c = b || {};
        b = c.document || document;
        var d = N(a).toString()
          , e = ob((new pb(b)).g, "SCRIPT")
          , g = {
            O: e,
            P: void 0
        }
          , f = new T(dc,g)
          , h = null
          , k = null != c.timeout ? c.timeout : 5E3;
        0 < k && (h = window.setTimeout(function() {
            ec(e, !0);
            var m = new fc(1,"Timeout reached for loading script " + d);
            V(f);
            W(f, !1, m)
        }, k),
        g.P = h);
        e.onload = e.onreadystatechange = function() {
            e.readyState && "loaded" != e.readyState && "complete" != e.readyState || (ec(e, c.X || !1, h),
            V(f),
            W(f, !0, null))
        }
        ;
        e.onerror = function() {
            ec(e, !0, h);
            var m = new fc(0,"Error while loading script " + d);
            V(f);
            W(f, !1, m)
        }
        ;
        g = c.attributes || {};
        Wa(g, {
            type: "text/javascript",
            charset: "UTF-8"
        });
        mb(e, g);
        e.src = N(a);
        Xa(e);
        gc(b).appendChild(e);
        return f
    }
    function gc(a) {
        var b;
        return (b = (a || document).getElementsByTagName("HEAD")) && 0 !== b.length ? b[0] : a.documentElement
    }
    function dc() {
        if (this && this.O) {
            var a = this.O;
            a && "SCRIPT" == a.tagName && ec(a, !0, this.P)
        }
    }
    function ec(a, b, c) {
        null != c && A.clearTimeout(c);
        a.onload = B;
        a.onerror = B;
        a.onreadystatechange = B;
        b && window.setTimeout(function() {
            a && a.parentNode && a.parentNode.removeChild(a)
        }, 0)
    }
    function fc(a, b) {
        var c = "Jsloader error (code #" + a + ")";
        b && (c += ": " + b);
        F.call(this, c);
        this.code = a
    }
    E(fc, F);
    /*

 Copyright 2021 Google LLC
 This code is released under the MIT license.
 SPDX-License-Identifier: MIT
*/
    function hc(a) {
        var b = a.M || {};
        a = Ka(a.format, a.H);
        a = Oa.exec(N(a).toString());
        var c = a[3] || "";
        return Na(a[1] + Pa("?", a[2] || "", b) + Pa("#", c, void 0))
    }
    var ic = cc;
    function jc(a) {
        a = K(a, hc);
        if (0 == a.length)
            return Promise.resolve();
        var b = {
            timeout: 3E4,
            attributes: {
                async: !1,
                defer: !1
            }
        }
          , c = [];
        !bb || lb() ? J(a, function(d) {
            c.push(ic(d, b))
        }) : c.push(bc(a, b));
        return Promise.all(K(c, function(d) {
            return new Promise(function(e) {
                Vb(d, e, null, void 0)
            }
            )
        }))
    }
    ;/*

 Copyright 2021 Google LLC
 This code is released under the MIT license.
 SPDX-License-Identifier: MIT

*/
    function kc() {
        return new Promise(function(a) {
            "undefined" === typeof window || "complete" === document.readyState ? a() : window.addEventListener ? (document.addEventListener("DOMContentLoaded", a, !0),
            window.addEventListener("load", a, !0)) : window.attachEvent ? window.attachEvent("onload", a) : "function" !== typeof window.onload ? window.onload = a : window.onload = function(b) {
                if (window.onload)
                    window.onload(b);
                a()
            }
        }
        )
    }
    var X = {};
    function lc(a) {
        X[a] || (X[a] = {
            loaded: !1
        });
        X[a].loaded = !0
    }
    ;var mc = 0;
    function nc(a, b) {
        b = b || document;
        var c = "load-css-" + mc++
          , d = b.createElement("link");
        d.setAttribute("id", c);
        d.setAttribute("rel", "stylesheet");
        d.setAttribute("type", "text/css");
        return new Promise(function(e, g) {
            void 0 !== d.addEventListener ? (d.addEventListener("load", e, !1),
            d.addEventListener("error", g, !1)) : void 0 !== d.attachEvent && d.attachEvent("onload", function() {
                try {
                    Ha(b.styleSheets, function(f) {
                        return f.id === c
                    }) && (lc(a),
                    e())
                } catch (f) {
                    g()
                }
            });
            try {
                (b.querySelector("head") || b).appendChild(d),
                d.setAttribute("href", a)
            } catch (f) {
                e()
            }
        }
        )
    }
    function oc(a, b) {
        return Promise.all(K(a, function(c) {
            c = hc(c);
            return nc(N(c).toString(), b)
        }))
    }
    ;var Y = "", pc = "", qc = !1, rc = !1, Z;
    function sc(a) {
        function b(d) {
            for (var e = [], g = 0; g < d.length; g++) {
                var f = d[g];
                if (!c[f]) {
                    c[f] = !0;
                    var h = Ba[f] || [];
                    e = e.concat(b("string" === typeof h ? [h] : h));
                    "string" !== typeof h && e.push(f)
                }
            }
            return e
        }
        var c = {};
        return b(a)
    }
    function tc(a) {
        var b = []
          , c = [];
        J(a, function(d) {
            var e = X[d] && X[d].promise;
            void 0 !== e ? b.push(e) : c.push(d)
        });
        return {
            N: b,
            R: c
        }
    }
    function uc(a) {
        a = tc(sc(a));
        var b = a.N
          , c = a.R
          , d = Fa(K(c, function(g) {
            var f = {
                version: Y,
                language: pc,
                "package": g
            };
            Ca[g] ? (g = Ca[g],
            Object.assign(f, g),
            g = Z[g.subdir ? "third_party" : "third_party2"]) : Da[g] ? (Object.assign(f, Da[g]),
            g = Z.third_party_gen) : g = Z[(qc ? "debug" : rc ? "pseudo" : "compiled") + (pc ? "_i18n" : "")];
            return g ? {
                format: g,
                H: f,
                M: void 0
            } : null
        }), function(g) {
            return null != g
        })
          , e = Promise.all(b).then(function() {
            return jc(d)
        }).then(function() {
            J(c, function(g) {
                lc(g)
            })
        });
        J(c, function(g) {
            X[g] = {
                promise: e,
                loaded: !1
            }
        });
        return e
    }
    function vc(a, b) {
        a = sc(a);
        var c = [];
        J(a, function(k) {
            J(Ea[k] || [], function(m) {
                c.push(m)
            })
        });
        if (0 === c.length)
            return Promise.resolve();
        var d = {};
        a = K(c, function(k) {
            var m = (k.subdir || k.subdir1 + "/" + k.subdir2) + "/" + k.filename;
            d[m] = k;
            return m
        });
        a = tc(a);
        var e = a.N
          , g = a.R
          , f = K(g, function(k) {
            k = d[k];
            var m = Z.css
              , n = {
                version: Y,
                subdir: k.subdir,
                filename: k.filename
            };
            k.subdir2 && (m = Z.css2,
            n.subdir1 = k.subdir1,
            n.subdir2 = k.subdir2);
            return {
                format: m,
                H: n,
                M: void 0
            }
        })
          , h = Promise.all(e).then(function() {
            return oc(f, b)
        }).then(function() {
            J(g, function(k) {
                lc(k)
            })
        });
        J(g, function(k) {
            X[k] = {
                promise: h,
                loaded: !1
            }
        });
        return h
    }
    function wc(a, b) {
        D("goog.visualization.isSafeMode", b.safeMode || !1);
        var c = b.debug || !1
          , d = b.pseudo || !1
          , e = b.language || "";
        pc = e;
        a || (a = b.version || "unknown");
        a = a || "";
        "" !== Y && Y !== a && (a = Y);
        a = Y = a || "";
        qc = c;
        rc = d;
        D("google.visualization.ModulePath", Z.format);
        D("google.visualization.Version", a);
        D("google.visualization.Locale", e);
        D("google.visualization.isDebug", c);
        D("google.visualization.isPseudo", d);
        D("google.visualization.mapsApiKey", b.mapsApiKey)
    }
    var xc = null;
    function yc(a, b) {
        function c(e) {
            return e.getRootNode ? e.getRootNode() : null != e.parentNode ? c(e.parentNode) : e
        }
        wc(a, b);
        a = b.packages;
        Array.isArray(a) && 0 != a.length || (a = Aa);
        var d = c(b.element || document);
        return xc = Promise.all([vc(a, d), uc(a), b.ignoreWindowOnLoad ? Promise.resolve() : kc()]).then(function() {
            var e = b.callback;
            if (e) {
                if ("function" !== typeof e)
                    throw Error("Callback must be a function");
                e()
            }
        })
    }
    D("google.charts.loader.VersionSpecific.load", function(a) {
        for (var b = [], c = 0; c < arguments.length; ++c)
            b[c] = arguments[c];
        c = 0;
        "visualization" === b[c] && c++;
        var d = "current";
        "string" === typeof b[c] && (d = b[c],
        c++);
        var e = {};
        sa(b[c]) && (e = b[c]);
        Z || (Z = za[e.domain || "gstatic.com"]);
        return yc(d, e)
    });
    D("google.charts.loader.VersionSpecific.setOnLoadCallback", function(a) {
        if (!xc)
            throw Error("Must call google.charts.load before google.charts.setOnLoadCallback");
        if (!a)
            return xc;
        if ("function" !== typeof a)
            throw Error("Callback must be a function");
        return xc.then(a)
    });
}
).call(this);
