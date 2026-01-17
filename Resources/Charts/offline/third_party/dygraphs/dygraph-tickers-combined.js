/*! @license Copyright 2011 Dan Vanderkam (danvdk@gmail.com) MIT-licensed (http://opensource.org/licenses/MIT) */
(function() {
    this.Dygraph = this.Dygraph || {};
    this.Dygraph.prototype = this.Dygraph.prototype || {};
    (function() {
        Dygraph.LOG_SCALE = 10;
        Dygraph.LN_TEN = Math.log(Dygraph.LOG_SCALE);
        Dygraph.log10 = function(c) {
            return Math.log(c) / Dygraph.LN_TEN
        }
        ;
        Dygraph.DOTTED_LINE = [2, 2];
        Dygraph.DASHED_LINE = [7, 3];
        Dygraph.DOT_DASH_LINE = [7, 2, 2, 2];
        Dygraph.getContext = function(c) {
            return (c.getContext("2d"))
        }
        ;
        Dygraph.addEvent = function b(e, d, c) {
            if (e.addEventListener) {
                e.addEventListener(d, c, false)
            } else {
                e[d + c] = function() {
                    c(window.event)
                }
                ;
                e.attachEvent("on" + d, e[d + c])
            }
        }
        ;
        Dygraph.prototype.addAndTrackEvent = function(e, d, c) {
            Dygraph.addEvent(e, d, c);
            this.registeredEvents_.push({
                elem: e,
                type: d,
                fn: c
            })
        }
        ;
        Dygraph.removeEvent = function(f, d, c) {
            if (f.removeEventListener) {
                f.removeEventListener(d, c, false)
            } else {
                try {
                    f.detachEvent("on" + d, f[d + c])
                } catch (g) {}
                f[d + c] = null
            }
        }
        ;
        Dygraph.prototype.removeTrackedEvents_ = function() {
            if (this.registeredEvents_) {
                for (var c = 0; c < this.registeredEvents_.length; c++) {
                    var d = this.registeredEvents_[c];
                    Dygraph.removeEvent(d.elem, d.type, d.fn)
                }
            }
            this.registeredEvents_ = []
        }
        ;
        Dygraph.cancelEvent = function(c) {
            c = c ? c : window.event;
            if (c.stopPropagation) {
                c.stopPropagation()
            }
            if (c.preventDefault) {
                c.preventDefault()
            }
            c.cancelBubble = true;
            c.cancel = true;
            c.returnValue = false;
            return false
        }
        ;
        Dygraph.hsvToRGB = function(k, j, m) {
            var e;
            var g;
            var n;
            if (j === 0) {
                e = m;
                g = m;
                n = m
            } else {
                var h = Math.floor(k * 6);
                var l = (k * 6) - h;
                var d = m * (1 - j);
                var c = m * (1 - (j * l));
                var o = m * (1 - (j * (1 - l)));
                switch (h) {
                case 1:
                    e = c;
                    g = m;
                    n = d;
                    break;
                case 2:
                    e = d;
                    g = m;
                    n = o;
                    break;
                case 3:
                    e = d;
                    g = c;
                    n = m;
                    break;
                case 4:
                    e = o;
                    g = d;
                    n = m;
                    break;
                case 5:
                    e = m;
                    g = d;
                    n = c;
                    break;
                case 6:
                case 0:
                    e = m;
                    g = o;
                    n = d;
                    break
                }
            }
            e = Math.floor(255 * e + 0.5);
            g = Math.floor(255 * g + 0.5);
            n = Math.floor(255 * n + 0.5);
            return "rgb(" + e + "," + g + "," + n + ")"
        }
        ;
        Dygraph.findPos = function(g) {
            var i = 0
              , e = 0;
            if (g.offsetParent) {
                var c = g;
                while (1) {
                    var f = "0"
                      , h = "0";
                    if (window.getComputedStyle) {
                        var d = window.getComputedStyle(c, null);
                        f = d.borderLeft || "0";
                        h = d.borderTop || "0"
                    }
                    i += parseInt(f, 10);
                    e += parseInt(h, 10);
                    i += c.offsetLeft;
                    e += c.offsetTop;
                    if (!c.offsetParent) {
                        break
                    }
                    c = c.offsetParent
                }
            } else {
                if (g.x) {
                    i += g.x
                }
                if (g.y) {
                    e += g.y
                }
            }
            while (g && g != document.body) {
                i -= isNaN(g.scrollLeft) ? 0 : g.scrollLeft;
                e -= isNaN(g.scrollTop) ? 0 : g.scrollTop;
                g = g.parentNode
            }
            return {
                x: i,
                y: e
            }
        }
        ;
        Dygraph.pageX = function(d) {
            if (d.pageX) {
                return (!d.pageX || d.pageX < 0) ? 0 : d.pageX
            } else {
                var f = document.documentElement;
                var c = document.body;
                return d.clientX + (f.scrollLeft || c.scrollLeft) - (f.clientLeft || 0)
            }
        }
        ;
        Dygraph.pageY = function(d) {
            if (d.pageY) {
                return (!d.pageY || d.pageY < 0) ? 0 : d.pageY
            } else {
                var f = document.documentElement;
                var c = document.body;
                return d.clientY + (f.scrollTop || c.scrollTop) - (f.clientTop || 0)
            }
        }
        ;
        Dygraph.dragGetX_ = function(d, c) {
            return Dygraph.pageX(d) - c.px
        }
        ;
        Dygraph.dragGetY_ = function(d, c) {
            return Dygraph.pageY(d) - c.py
        }
        ;
        Dygraph.isOK = function(c) {
            return !!c && !isNaN(c)
        }
        ;
        Dygraph.isValidPoint = function(d, c) {
            if (!d) {
                return false
            }
            if (d.yval === null) {
                return false
            }
            if (d.x === null || d.x === undefined) {
                return false
            }
            if (d.y === null || d.y === undefined) {
                return false
            }
            if (isNaN(d.x) || (!c && isNaN(d.y))) {
                return false
            }
            return true
        }
        ;
        Dygraph.floatFormat = function(c, d) {
            var e = Math.min(Math.max(1, d || 2), 21);
            return (Math.abs(c) < 0.001 && c !== 0) ? c.toExponential(e - 1) : c.toPrecision(e)
        }
        ;
        Dygraph.zeropad = function(c) {
            if (c < 10) {
                return "0" + c
            } else {
                return "" + c
            }
        }
        ;
        Dygraph.DateAccessorsLocal = {
            getFullYear: function(c) {
                return c.getFullYear()
            },
            getMonth: function(c) {
                return c.getMonth()
            },
            getDate: function(c) {
                return c.getDate()
            },
            getHours: function(c) {
                return c.getHours()
            },
            getMinutes: function(c) {
                return c.getMinutes()
            },
            getSeconds: function(c) {
                return c.getSeconds()
            },
            getMilliseconds: function(c) {
                return c.getMilliseconds()
            },
            getDay: function(c) {
                return c.getDay()
            },
            makeDate: function(j, c, i, g, h, f, e) {
                return new Date(j,c,i,g,h,f,e)
            }
        };
        Dygraph.DateAccessorsUTC = {
            getFullYear: function(c) {
                return c.getUTCFullYear()
            },
            getMonth: function(c) {
                return c.getUTCMonth()
            },
            getDate: function(c) {
                return c.getUTCDate()
            },
            getHours: function(c) {
                return c.getUTCHours()
            },
            getMinutes: function(c) {
                return c.getUTCMinutes()
            },
            getSeconds: function(c) {
                return c.getUTCSeconds()
            },
            getMilliseconds: function(c) {
                return c.getUTCMilliseconds()
            },
            getDay: function(c) {
                return c.getUTCDay()
            },
            makeDate: function(j, c, i, g, h, f, e) {
                return new Date(Date.UTC(j, c, i, g, h, f, e))
            }
        };
        Dygraph.hmsString_ = function(e, f, d) {
            var g = Dygraph.zeropad;
            var c = g(e) + ":" + g(f);
            if (d) {
                c += ":" + g(d)
            }
            return c
        }
        ;
        Dygraph.dateString_ = function(e, s) {
            var j = Dygraph.zeropad;
            var k = s ? Dygraph.DateAccessorsUTC : Dygraph.DateAccessorsLocal;
            var f = new Date(e);
            var r = k.getFullYear(f);
            var g = k.getMonth(f);
            var o = k.getDate(f);
            var h = k.getHours(f);
            var i = k.getMinutes(f);
            var t = k.getSeconds(f);
            var p = "" + r;
            var n = j(g + 1);
            var q = j(o);
            var c = h * 3600 + i * 60 + t;
            var l = p + "/" + n + "/" + q;
            if (c) {
                l += " " + Dygraph.hmsString_(h, i, t)
            }
            return l
        }
        ;
        Dygraph.round_ = function(e, d) {
            var c = Math.pow(10, d);
            return Math.round(e * c) / c
        }
        ;
        Dygraph.binarySearch = function(c, f, k, g, d) {
            if (g === null || g === undefined || d === null || d === undefined) {
                g = 0;
                d = f.length - 1
            }
            if (g > d) {
                return -1
            }
            if (k === null || k === undefined) {
                k = 0
            }
            var j = function(l) {
                return l >= 0 && l < f.length
            };
            var i = parseInt((g + d) / 2, 10);
            var e = f[i];
            var h;
            if (e == c) {
                return i
            } else {
                if (e > c) {
                    if (k > 0) {
                        h = i - 1;
                        if (j(h) && f[h] < c) {
                            return i
                        }
                    }
                    return Dygraph.binarySearch(c, f, k, g, i - 1)
                } else {
                    if (e < c) {
                        if (k < 0) {
                            h = i + 1;
                            if (j(h) && f[h] > c) {
                                return i
                            }
                        }
                        return Dygraph.binarySearch(c, f, k, i + 1, d)
                    }
                }
            }
            return -1
        }
        ;
        Dygraph.dateParser = function(c) {
            var e;
            var f;
            if (c.search("-") == -1 || c.search("T") != -1 || c.search("Z") != -1) {
                f = Dygraph.dateStrToMillis(c);
                if (f && !isNaN(f)) {
                    return f
                }
            }
            if (c.search("-") != -1) {
                e = c.replace("-", "/", "g");
                while (e.search("-") != -1) {
                    e = e.replace("-", "/")
                }
                f = Dygraph.dateStrToMillis(e)
            } else {
                if (c.length == 8) {
                    e = c.substr(0, 4) + "/" + c.substr(4, 2) + "/" + c.substr(6, 2);
                    f = Dygraph.dateStrToMillis(e)
                } else {
                    f = Dygraph.dateStrToMillis(c)
                }
            }
            if (!f || isNaN(f)) {
                console.error("Couldn't parse " + c + " as a date")
            }
            return f
        }
        ;
        Dygraph.dateStrToMillis = function(c) {
            return new Date(c).getTime()
        }
        ;
        Dygraph.update = function(d, e) {
            if (typeof (e) != "undefined" && e !== null) {
                for (var c in e) {
                    if (e.hasOwnProperty(c)) {
                        d[c] = e[c]
                    }
                }
            }
            return d
        }
        ;
        Dygraph.updateDeep = function(d, f) {
            function e(g) {
                return (typeof Node === "object" ? g instanceof Node : typeof g === "object" && typeof g.nodeType === "number" && typeof g.nodeName === "string")
            }
            if (typeof (f) != "undefined" && f !== null) {
                for (var c in f) {
                    if (f.hasOwnProperty(c)) {
                        if (f[c] === null) {
                            d[c] = null
                        } else {
                            if (Dygraph.isArrayLike(f[c])) {
                                d[c] = f[c].slice()
                            } else {
                                if (e(f[c])) {
                                    d[c] = f[c]
                                } else {
                                    if (typeof (f[c]) == "object") {
                                        if (typeof (d[c]) != "object" || d[c] === null) {
                                            d[c] = {}
                                        }
                                        Dygraph.updateDeep(d[c], f[c])
                                    } else {
                                        d[c] = f[c]
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return d
        }
        ;
        Dygraph.isArrayLike = function(d) {
            var c = typeof (d);
            if ((c != "object" && !(c == "function" && typeof (d.item) == "function")) || d === null || typeof (d.length) != "number" || d.nodeType === 3) {
                return false
            }
            return true
        }
        ;
        Dygraph.isDateLike = function(c) {
            if (typeof (c) != "object" || c === null || typeof (c.getTime) != "function") {
                return false
            }
            return true
        }
        ;
        Dygraph.clone = function(e) {
            var d = [];
            for (var c = 0; c < e.length; c++) {
                if (Dygraph.isArrayLike(e[c])) {
                    d.push(Dygraph.clone(e[c]))
                } else {
                    d.push(e[c])
                }
            }
            return d
        }
        ;
        Dygraph.createCanvas = function() {
            var c = document.createElement("canvas");
            var d = (/MSIE/.test(navigator.userAgent) && !window.opera);
            if (d && (typeof (G_vmlCanvasManager) != "undefined")) {
                c = G_vmlCanvasManager.initElement((c))
            }
            return c
        }
        ;
        Dygraph.getContextPixelRatio = function(d) {
            try {
                var c = window.devicePixelRatio;
                var f = d.webkitBackingStorePixelRatio || d.mozBackingStorePixelRatio || d.msBackingStorePixelRatio || d.oBackingStorePixelRatio || d.backingStorePixelRatio || 1;
                if (c !== undefined) {
                    return c / f
                } else {
                    return 1
                }
            } catch (g) {
                return 1
            }
        }
        ;
        Dygraph.isAndroid = function() {
            return (/Android/).test(navigator.userAgent)
        }
        ;
        Dygraph.Iterator = function(f, e, d, c) {
            e = e || 0;
            d = d || f.length;
            this.hasNext = true;
            this.peek = null;
            this.start_ = e;
            this.array_ = f;
            this.predicate_ = c;
            this.end_ = Math.min(f.length, e + d);
            this.nextIdx_ = e - 1;
            this.next()
        }
        ;
        Dygraph.Iterator.prototype.next = function() {
            if (!this.hasNext) {
                return null
            }
            var e = this.peek;
            var d = this.nextIdx_ + 1;
            var c = false;
            while (d < this.end_) {
                if (!this.predicate_ || this.predicate_(this.array_, d)) {
                    this.peek = this.array_[d];
                    c = true;
                    break
                }
                d++
            }
            this.nextIdx_ = d;
            if (!c) {
                this.hasNext = false;
                this.peek = null
            }
            return e
        }
        ;
        Dygraph.createIterator = function(f, e, d, c) {
            return new Dygraph.Iterator(f,e,d,c)
        }
        ;
        Dygraph.requestAnimFrame = (function() {
            return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(c) {
                window.setTimeout(c, 1000 / 60)
            }
        }
        )();
        Dygraph.repeatAndCleanup = function(j, i, h, c) {
            var k = 0;
            var f;
            var d = new Date().getTime();
            j(k);
            if (i == 1) {
                c();
                return
            }
            var g = i - 1;
            (function e() {
                if (k >= i) {
                    return
                }
                Dygraph.requestAnimFrame.call(window, function() {
                    var n = new Date().getTime();
                    var l = n - d;
                    f = k;
                    k = Math.floor(l / h);
                    var m = k - f;
                    var o = (k + m) > g;
                    if (o || (k >= g)) {
                        j(g);
                        c()
                    } else {
                        if (m !== 0) {
                            j(k)
                        }
                        e()
                    }
                })
            }
            )()
        }
        ;
        var a = {
            annotationClickHandler: true,
            annotationDblClickHandler: true,
            annotationMouseOutHandler: true,
            annotationMouseOverHandler: true,
            axisLabelColor: true,
            axisLineColor: true,
            axisLineWidth: true,
            clickCallback: true,
            drawCallback: true,
            drawHighlightPointCallback: true,
            drawPoints: true,
            drawPointCallback: true,
            drawXGrid: true,
            drawYGrid: true,
            fillAlpha: true,
            gridLineColor: true,
            gridLineWidth: true,
            hideOverlayOnMouseOut: true,
            highlightCallback: true,
            highlightCircleSize: true,
            interactionModel: true,
            isZoomedIgnoreProgrammaticZoom: true,
            labelsDiv: true,
            labelsDivStyles: true,
            labelsDivWidth: true,
            labelsKMB: true,
            labelsKMG2: true,
            labelsSeparateLines: true,
            labelsShowZeroValues: true,
            legend: true,
            panEdgeFraction: true,
            pixelsPerYLabel: true,
            pointClickCallback: true,
            pointSize: true,
            rangeSelectorPlotFillColor: true,
            rangeSelectorPlotStrokeColor: true,
            showLabelsOnHighlight: true,
            showRoller: true,
            strokeWidth: true,
            underlayCallback: true,
            unhighlightCallback: true,
            zoomCallback: true
        };
        Dygraph.isPixelChangingOptionList = function(k, f) {
            var e = {};
            if (k) {
                for (var h = 1; h < k.length; h++) {
                    e[k[h]] = true
                }
            }
            var d = function(i) {
                for (var l in i) {
                    if (i.hasOwnProperty(l) && !a[l]) {
                        return true
                    }
                }
                return false
            };
            for (var j in f) {
                if (!f.hasOwnProperty(j)) {
                    continue
                }
                if (j == "highlightSeriesOpts" || (e[j] && !f.series)) {
                    if (d(f[j])) {
                        return true
                    }
                } else {
                    if (j == "series" || j == "axes") {
                        var c = f[j];
                        for (var g in c) {
                            if (c.hasOwnProperty(g) && d(c[g])) {
                                return true
                            }
                        }
                    } else {
                        if (!a[j]) {
                            return true
                        }
                    }
                }
            }
            return false
        }
        ;
        Dygraph.Circles = {
            DEFAULT: function(j, i, d, h, f, e, c) {
                d.beginPath();
                d.fillStyle = e;
                d.arc(h, f, c, 0, 2 * Math.PI, false);
                d.fill()
            }
        };
        Dygraph.IFrameTarp = function() {
            this.tarps = []
        }
        ;
        Dygraph.IFrameTarp.prototype.cover = function() {
            var g = document.getElementsByTagName("iframe");
            for (var f = 0; f < g.length; f++) {
                var e = g[f];
                var h = Dygraph.findPos(e)
                  , k = h.x
                  , j = h.y
                  , d = e.offsetWidth
                  , l = e.offsetHeight;
                var c = document.createElement("div");
                c.style.position = "absolute";
                c.style.left = k + "px";
                c.style.top = j + "px";
                c.style.width = d + "px";
                c.style.height = l + "px";
                c.style.zIndex = 999;
                document.body.appendChild(c);
                this.tarps.push(c)
            }
        }
        ;
        Dygraph.IFrameTarp.prototype.uncover = function() {
            for (var c = 0; c < this.tarps.length; c++) {
                this.tarps[c].parentNode.removeChild(this.tarps[c])
            }
            this.tarps = []
        }
        ;
        Dygraph.detectLineDelimiter = function(e) {
            for (var c = 0; c < e.length; c++) {
                var d = e.charAt(c);
                if (d === "\r") {
                    if (((c + 1) < e.length) && (e.charAt(c + 1) === "\n")) {
                        return "\r\n"
                    }
                    return d
                }
                if (d === "\n") {
                    if (((c + 1) < e.length) && (e.charAt(c + 1) === "\r")) {
                        return "\n\r"
                    }
                    return d
                }
            }
            return null
        }
        ;
        Dygraph.isNodeContainedBy = function(d, c) {
            if (c === null || d === null) {
                return false
            }
            var e = (d);
            while (e && e !== c) {
                e = e.parentNode
            }
            return (e === c)
        }
        ;
        Dygraph.pow = function(c, d) {
            if (d < 0) {
                return 1 / Math.pow(c, -d)
            }
            return Math.pow(c, d)
        }
        ;
        Dygraph.toRGB_ = function(c) {
            var f = document.createElement("div");
            f.style.backgroundColor = c;
            f.style.visibility = "hidden";
            document.body.appendChild(f);
            var e;
            if (window.getComputedStyle) {
                e = window.getComputedStyle(f, null).backgroundColor
            } else {
                e = f.currentStyle.backgroundColor
            }
            document.body.removeChild(f);
            var d = /^rgb\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3})\)$/.exec(e);
            return {
                r: parseInt(d[1], 10),
                g: parseInt(d[2], 10),
                b: parseInt(d[3], 10)
            }
        }
        ;
        Dygraph.isCanvasSupported = function(f) {
            var d;
            try {
                d = f || document.createElement("canvas");
                d.getContext("2d")
            } catch (g) {
                var h = navigator.appVersion.match(/MSIE (\d\.\d)/);
                var c = (navigator.userAgent.toLowerCase().indexOf("opera") != -1);
                if ((!h) || (h[1] < 6) || (c)) {
                    return false
                }
                return true
            }
            return true
        }
        ;
        Dygraph.parseFloat_ = function(c, e, d) {
            var g = parseFloat(c);
            if (!isNaN(g)) {
                return g
            }
            if (/^ *$/.test(c)) {
                return null
            }
            if (/^ *nan *$/i.test(c)) {
                return NaN
            }
            var f = "Unable to parse '" + c + "' as a number";
            if (d !== undefined && e !== undefined) {
                f += " on line " + (1 + (e || 0)) + " ('" + d + "') of CSV."
            }
            console.error(f);
            return null
        }
    }
    )();
    (function() {
        Dygraph.TickList = undefined;
        Dygraph.Ticker = undefined;
        Dygraph.numericLinearTicks = function(d, c, i, g, f, h) {
            var e = function(a) {
                if (a === "logscale") {
                    return false
                }
                return g(a)
            };
            return Dygraph.numericTicks(d, c, i, e, f, h)
        }
        ;
        Dygraph.numericTicks = function(F, E, u, p, d, q) {
            var z = (p("pixelsPerLabel"));
            var G = [];
            var C, A, t, y;
            if (q) {
                for (C = 0; C < q.length; C++) {
                    G.push({
                        v: q[C]
                    })
                }
            } else {
                if (p("logscale")) {
                    y = Math.floor(u / z);
                    var l = Dygraph.binarySearch(F, Dygraph.PREFERRED_LOG_TICK_VALUES, 1);
                    var H = Dygraph.binarySearch(E, Dygraph.PREFERRED_LOG_TICK_VALUES, -1);
                    if (l == -1) {
                        l = 0
                    }
                    if (H == -1) {
                        H = Dygraph.PREFERRED_LOG_TICK_VALUES.length - 1
                    }
                    var s = null;
                    if (H - l >= y / 4) {
                        for (var r = H; r >= l; r--) {
                            var m = Dygraph.PREFERRED_LOG_TICK_VALUES[r];
                            var k = Math.log(m / F) / Math.log(E / F) * u;
                            var D = {
                                v: m
                            };
                            if (s === null) {
                                s = {
                                    tickValue: m,
                                    pixel_coord: k
                                }
                            } else {
                                if (Math.abs(k - s.pixel_coord) >= z) {
                                    s = {
                                        tickValue: m,
                                        pixel_coord: k
                                    }
                                } else {
                                    D.label = ""
                                }
                            }
                            G.push(D)
                        }
                        G.reverse()
                    }
                }
                if (G.length === 0) {
                    var g = p("labelsKMG2");
                    var n, h;
                    if (g) {
                        n = [1, 2, 4, 8, 16, 32, 64, 128, 256];
                        h = 16
                    } else {
                        n = [1, 2, 5, 10, 20, 50, 100];
                        h = 10
                    }
                    var w = Math.ceil(u / z);
                    var o = Math.abs(E - F) / w;
                    var v = Math.floor(Math.log(o) / Math.log(h));
                    var f = Math.pow(h, v);
                    var I, x, c, e;
                    for (A = 0; A < n.length; A++) {
                        I = f * n[A];
                        x = Math.floor(F / I) * I;
                        c = Math.ceil(E / I) * I;
                        y = Math.abs(c - x) / I;
                        e = u / y;
                        if (e > z) {
                            break
                        }
                    }
                    if (x > c) {
                        I *= -1
                    }
                    for (C = 0; C <= y; C++) {
                        t = x + C * I;
                        G.push({
                            v: t
                        })
                    }
                }
            }
            var B = (p("axisLabelFormatter"));
            for (C = 0; C < G.length; C++) {
                if (G[C].label !== undefined) {
                    continue
                }
                G[C].label = B(G[C].v, 0, p, d)
            }
            return G
        }
        ;
        Dygraph.dateTicker = function(e, c, i, g, f, h) {
            var d = Dygraph.pickDateTickGranularity(e, c, i, g);
            if (d >= 0) {
                return Dygraph.getDateAxis(e, c, d, g, f)
            } else {
                return []
            }
        }
        ;
        Dygraph.SECONDLY = 0;
        Dygraph.TWO_SECONDLY = 1;
        Dygraph.FIVE_SECONDLY = 2;
        Dygraph.TEN_SECONDLY = 3;
        Dygraph.THIRTY_SECONDLY = 4;
        Dygraph.MINUTELY = 5;
        Dygraph.TWO_MINUTELY = 6;
        Dygraph.FIVE_MINUTELY = 7;
        Dygraph.TEN_MINUTELY = 8;
        Dygraph.THIRTY_MINUTELY = 9;
        Dygraph.HOURLY = 10;
        Dygraph.TWO_HOURLY = 11;
        Dygraph.SIX_HOURLY = 12;
        Dygraph.DAILY = 13;
        Dygraph.TWO_DAILY = 14;
        Dygraph.WEEKLY = 15;
        Dygraph.MONTHLY = 16;
        Dygraph.QUARTERLY = 17;
        Dygraph.BIANNUAL = 18;
        Dygraph.ANNUAL = 19;
        Dygraph.DECADAL = 20;
        Dygraph.CENTENNIAL = 21;
        Dygraph.NUM_GRANULARITIES = 22;
        Dygraph.DATEFIELD_Y = 0;
        Dygraph.DATEFIELD_M = 1;
        Dygraph.DATEFIELD_D = 2;
        Dygraph.DATEFIELD_HH = 3;
        Dygraph.DATEFIELD_MM = 4;
        Dygraph.DATEFIELD_SS = 5;
        Dygraph.DATEFIELD_MS = 6;
        Dygraph.NUM_DATEFIELDS = 7;
        Dygraph.TICK_PLACEMENT = [];
        Dygraph.TICK_PLACEMENT[Dygraph.SECONDLY] = {
            datefield: Dygraph.DATEFIELD_SS,
            step: 1,
            spacing: 1000 * 1
        };
        Dygraph.TICK_PLACEMENT[Dygraph.TWO_SECONDLY] = {
            datefield: Dygraph.DATEFIELD_SS,
            step: 2,
            spacing: 1000 * 2
        };
        Dygraph.TICK_PLACEMENT[Dygraph.FIVE_SECONDLY] = {
            datefield: Dygraph.DATEFIELD_SS,
            step: 5,
            spacing: 1000 * 5
        };
        Dygraph.TICK_PLACEMENT[Dygraph.TEN_SECONDLY] = {
            datefield: Dygraph.DATEFIELD_SS,
            step: 10,
            spacing: 1000 * 10
        };
        Dygraph.TICK_PLACEMENT[Dygraph.THIRTY_SECONDLY] = {
            datefield: Dygraph.DATEFIELD_SS,
            step: 30,
            spacing: 1000 * 30
        };
        Dygraph.TICK_PLACEMENT[Dygraph.MINUTELY] = {
            datefield: Dygraph.DATEFIELD_MM,
            step: 1,
            spacing: 1000 * 60
        };
        Dygraph.TICK_PLACEMENT[Dygraph.TWO_MINUTELY] = {
            datefield: Dygraph.DATEFIELD_MM,
            step: 2,
            spacing: 1000 * 60 * 2
        };
        Dygraph.TICK_PLACEMENT[Dygraph.FIVE_MINUTELY] = {
            datefield: Dygraph.DATEFIELD_MM,
            step: 5,
            spacing: 1000 * 60 * 5
        };
        Dygraph.TICK_PLACEMENT[Dygraph.TEN_MINUTELY] = {
            datefield: Dygraph.DATEFIELD_MM,
            step: 10,
            spacing: 1000 * 60 * 10
        };
        Dygraph.TICK_PLACEMENT[Dygraph.THIRTY_MINUTELY] = {
            datefield: Dygraph.DATEFIELD_MM,
            step: 30,
            spacing: 1000 * 60 * 30
        };
        Dygraph.TICK_PLACEMENT[Dygraph.HOURLY] = {
            datefield: Dygraph.DATEFIELD_HH,
            step: 1,
            spacing: 1000 * 3600
        };
        Dygraph.TICK_PLACEMENT[Dygraph.TWO_HOURLY] = {
            datefield: Dygraph.DATEFIELD_HH,
            step: 2,
            spacing: 1000 * 3600 * 2
        };
        Dygraph.TICK_PLACEMENT[Dygraph.SIX_HOURLY] = {
            datefield: Dygraph.DATEFIELD_HH,
            step: 6,
            spacing: 1000 * 3600 * 6
        };
        Dygraph.TICK_PLACEMENT[Dygraph.DAILY] = {
            datefield: Dygraph.DATEFIELD_D,
            step: 1,
            spacing: 1000 * 86400
        };
        Dygraph.TICK_PLACEMENT[Dygraph.TWO_DAILY] = {
            datefield: Dygraph.DATEFIELD_D,
            step: 2,
            spacing: 1000 * 86400 * 2
        };
        Dygraph.TICK_PLACEMENT[Dygraph.WEEKLY] = {
            datefield: Dygraph.DATEFIELD_D,
            step: 7,
            spacing: 1000 * 604800
        };
        Dygraph.TICK_PLACEMENT[Dygraph.MONTHLY] = {
            datefield: Dygraph.DATEFIELD_M,
            step: 1,
            spacing: 1000 * 7200 * 365.2524
        };
        Dygraph.TICK_PLACEMENT[Dygraph.QUARTERLY] = {
            datefield: Dygraph.DATEFIELD_M,
            step: 3,
            spacing: 1000 * 21600 * 365.2524
        };
        Dygraph.TICK_PLACEMENT[Dygraph.BIANNUAL] = {
            datefield: Dygraph.DATEFIELD_M,
            step: 6,
            spacing: 1000 * 43200 * 365.2524
        };
        Dygraph.TICK_PLACEMENT[Dygraph.ANNUAL] = {
            datefield: Dygraph.DATEFIELD_Y,
            step: 1,
            spacing: 1000 * 86400 * 365.2524
        };
        Dygraph.TICK_PLACEMENT[Dygraph.DECADAL] = {
            datefield: Dygraph.DATEFIELD_Y,
            step: 10,
            spacing: 1000 * 864000 * 365.2524
        };
        Dygraph.TICK_PLACEMENT[Dygraph.CENTENNIAL] = {
            datefield: Dygraph.DATEFIELD_Y,
            step: 100,
            spacing: 1000 * 8640000 * 365.2524
        };
        Dygraph.PREFERRED_LOG_TICK_VALUES = (function() {
            var c = [];
            for (var b = -39; b <= 39; b++) {
                var a = Math.pow(10, b);
                for (var d = 1; d <= 9; d++) {
                    var e = a * d;
                    c.push(e)
                }
            }
            return c
        }
        )();
        Dygraph.pickDateTickGranularity = function(d, c, j, h) {
            var g = (h("pixelsPerLabel"));
            for (var f = 0; f < Dygraph.NUM_GRANULARITIES; f++) {
                var e = Dygraph.numDateTicks(d, c, f);
                if (j / e >= g) {
                    return f
                }
            }
            return -1
        }
        ;
        Dygraph.numDateTicks = function(b, a, c) {
            var d = Dygraph.TICK_PLACEMENT[c].spacing;
            return Math.round(1 * (a - b) / d)
        }
        ;
        Dygraph.getDateAxis = function(j, h, a, i, l) {
            var k = (i("axisLabelFormatter"));
            var b = i("labelsUTC");
            var n = b ? Dygraph.DateAccessorsUTC : Dygraph.DateAccessorsLocal;
            var r = Dygraph.TICK_PLACEMENT[a].datefield;
            var f = Dygraph.TICK_PLACEMENT[a].step;
            var e = Dygraph.TICK_PLACEMENT[a].spacing;
            var c = new Date(j);
            var o = [];
            o[Dygraph.DATEFIELD_Y] = n.getFullYear(c);
            o[Dygraph.DATEFIELD_M] = n.getMonth(c);
            o[Dygraph.DATEFIELD_D] = n.getDate(c);
            o[Dygraph.DATEFIELD_HH] = n.getHours(c);
            o[Dygraph.DATEFIELD_MM] = n.getMinutes(c);
            o[Dygraph.DATEFIELD_SS] = n.getSeconds(c);
            o[Dygraph.DATEFIELD_MS] = n.getMilliseconds(c);
            var d = o[r] % f;
            if (a == Dygraph.WEEKLY) {
                d = n.getDay(c)
            }
            o[r] -= d;
            for (var m = r + 1; m < Dygraph.NUM_DATEFIELDS; m++) {
                o[m] = (m === Dygraph.DATEFIELD_D) ? 1 : 0
            }
            var p = [];
            var q = n.makeDate.apply(null, o);
            var g = q.getTime();
            if (a <= Dygraph.HOURLY) {
                if (g < j) {
                    g += e;
                    q = new Date(g)
                }
                while (g <= h) {
                    p.push({
                        v: g,
                        label: k(q, a, i, l)
                    });
                    g += e;
                    q = new Date(g)
                }
            } else {
                if (g < j) {
                    o[r] += f;
                    q = n.makeDate.apply(null, o);
                    g = q.getTime()
                }
                while (g <= h) {
                    if (a >= Dygraph.DAILY || n.getHours(q) % f === 0) {
                        p.push({
                            v: g,
                            label: k(q, a, i, l)
                        })
                    }
                    o[r] += f;
                    q = n.makeDate.apply(null, o);
                    g = q.getTime()
                }
            }
            return p
        }
        ;
        if (Dygraph && Dygraph.DEFAULT_ATTRS && Dygraph.DEFAULT_ATTRS.axes && Dygraph.DEFAULT_ATTRS.axes["x"] && Dygraph.DEFAULT_ATTRS.axes["y"] && Dygraph.DEFAULT_ATTRS.axes["y2"]) {
            Dygraph.DEFAULT_ATTRS.axes["x"]["ticker"] = Dygraph.dateTicker;
            Dygraph.DEFAULT_ATTRS.axes["y"]["ticker"] = Dygraph.numericTicks;
            Dygraph.DEFAULT_ATTRS.axes["y2"]["ticker"] = Dygraph.numericTicks
        }
    }
    )();
}());
