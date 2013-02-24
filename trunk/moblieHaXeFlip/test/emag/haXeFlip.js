$estr = function() { return js.Boot.__string_rec(this,''); }
StringTools = function() { }
StringTools.__name__ = ["StringTools"];
StringTools.urlEncode = function(s) {
	return encodeURIComponent(s);
}
StringTools.urlDecode = function(s) {
	return decodeURIComponent(s.split("+").join(" "));
}
StringTools.htmlEscape = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
}
StringTools.htmlUnescape = function(s) {
	return s.split("&gt;").join(">").split("&lt;").join("<").split("&amp;").join("&");
}
StringTools.startsWith = function(s,start) {
	return s.length >= start.length && s.substr(0,start.length) == start;
}
StringTools.endsWith = function(s,end) {
	var elen = end.length;
	var slen = s.length;
	return slen >= elen && s.substr(slen - elen,elen) == end;
}
StringTools.isSpace = function(s,pos) {
	var c = s.charCodeAt(pos);
	return c >= 9 && c <= 13 || c == 32;
}
StringTools.ltrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,r)) {
		r++;
	}
	if(r > 0) return s.substr(r,l - r);
	else return s;
}
StringTools.rtrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,l - r - 1)) {
		r++;
	}
	if(r > 0) {
		return s.substr(0,l - r);
	}
	else {
		return s;
	}
}
StringTools.trim = function(s) {
	return StringTools.ltrim(StringTools.rtrim(s));
}
StringTools.rpad = function(s,c,l) {
	var sl = s.length;
	var cl = c.length;
	while(sl < l) {
		if(l - sl < cl) {
			s += c.substr(0,l - sl);
			sl = l;
		}
		else {
			s += c;
			sl += cl;
		}
	}
	return s;
}
StringTools.lpad = function(s,c,l) {
	var ns = "";
	var sl = s.length;
	if(sl >= l) return s;
	var cl = c.length;
	while(sl < l) {
		if(l - sl < cl) {
			ns += c.substr(0,l - sl);
			sl = l;
		}
		else {
			ns += c;
			sl += cl;
		}
	}
	return ns + s;
}
StringTools.replace = function(s,sub,by) {
	return s.split(sub).join(by);
}
StringTools.hex = function(n,digits) {
	var s = "";
	var hexChars = "0123456789ABCDEF";
	do {
		s = hexChars.charAt(n & 15) + s;
		n >>>= 4;
	} while(n > 0);
	if(digits != null) while(s.length < digits) s = "0" + s;
	return s;
}
StringTools.fastCodeAt = function(s,index) {
	return s.cca(index);
}
StringTools.isEOF = function(c) {
	return c != c;
}
StringTools.prototype.__class__ = StringTools;
EReg = function(r,opt) { if( r === $_ ) return; {
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
}}
EReg.__name__ = ["EReg"];
EReg.prototype.r = null;
EReg.prototype.match = function(s) {
	this.r.m = this.r.exec(s);
	this.r.s = s;
	this.r.l = RegExp.leftContext;
	this.r.r = RegExp.rightContext;
	return this.r.m != null;
}
EReg.prototype.matched = function(n) {
	return this.r.m != null && n >= 0 && n < this.r.m.length?this.r.m[n]:(function($this) {
		var $r;
		throw "EReg::matched";
		return $r;
	}(this));
}
EReg.prototype.matchedLeft = function() {
	if(this.r.m == null) throw "No string matched";
	if(this.r.l == null) return this.r.s.substr(0,this.r.m.index);
	return this.r.l;
}
EReg.prototype.matchedRight = function() {
	if(this.r.m == null) throw "No string matched";
	if(this.r.r == null) {
		var sz = this.r.m.index + this.r.m[0].length;
		return this.r.s.substr(sz,this.r.s.length - sz);
	}
	return this.r.r;
}
EReg.prototype.matchedPos = function() {
	if(this.r.m == null) throw "No string matched";
	return { pos : this.r.m.index, len : this.r.m[0].length};
}
EReg.prototype.split = function(s) {
	var d = "#__delim__#";
	return s.replace(this.r,d).split(d);
}
EReg.prototype.replace = function(s,by) {
	return s.replace(this.r,by);
}
EReg.prototype.customReplace = function(s,f) {
	var buf = new StringBuf();
	while(true) {
		if(!this.match(s)) break;
		buf.b[buf.b.length] = this.matchedLeft();
		buf.b[buf.b.length] = f(this);
		s = this.matchedRight();
	}
	buf.b[buf.b.length] = s;
	return buf.b.join("");
}
EReg.prototype.__class__ = EReg;
Xml = function(p) { if( p === $_ ) return; {
	null;
}}
Xml.__name__ = ["Xml"];
Xml.Element = null;
Xml.PCData = null;
Xml.CData = null;
Xml.Comment = null;
Xml.DocType = null;
Xml.Prolog = null;
Xml.Document = null;
Xml.parse = function(str) {
	var rules = [Xml.enode,Xml.epcdata,Xml.eend,Xml.ecdata,Xml.edoctype,Xml.ecomment,Xml.eprolog];
	var nrules = rules.length;
	var current = Xml.createDocument();
	var stack = new List();
	while(str.length > 0) {
		var i = 0;
		try {
			while(i < nrules) {
				var r = rules[i];
				if(r.match(str)) {
					switch(i) {
					case 0:{
						var x = Xml.createElement(r.matched(1));
						current.addChild(x);
						str = r.matchedRight();
						while(Xml.eattribute.match(str)) {
							x.set(Xml.eattribute.matched(1),Xml.eattribute.matched(3));
							str = Xml.eattribute.matchedRight();
						}
						if(!Xml.eclose.match(str)) {
							i = nrules;
							throw "__break__";
						}
						if(Xml.eclose.matched(1) == ">") {
							stack.push(current);
							current = x;
						}
						str = Xml.eclose.matchedRight();
					}break;
					case 1:{
						var x = Xml.createPCData(r.matched(0));
						current.addChild(x);
						str = r.matchedRight();
					}break;
					case 2:{
						if(current._children != null && current._children.length == 0) {
							var e = Xml.createPCData("");
							current.addChild(e);
						}
						else null;
						if(r.matched(1) != current._nodeName || stack.isEmpty()) {
							i = nrules;
							throw "__break__";
						}
						else null;
						current = stack.pop();
						str = r.matchedRight();
					}break;
					case 3:{
						str = r.matchedRight();
						if(!Xml.ecdata_end.match(str)) throw "End of CDATA section not found";
						var x = Xml.createCData(Xml.ecdata_end.matchedLeft());
						current.addChild(x);
						str = Xml.ecdata_end.matchedRight();
					}break;
					case 4:{
						var pos = 0;
						var count = 0;
						var old = str;
						try {
							while(true) {
								if(!Xml.edoctype_elt.match(str)) throw "End of DOCTYPE section not found";
								var p = Xml.edoctype_elt.matchedPos();
								pos += p.pos + p.len;
								str = Xml.edoctype_elt.matchedRight();
								switch(Xml.edoctype_elt.matched(0)) {
								case "[":{
									count++;
								}break;
								case "]":{
									count--;
									if(count < 0) throw "Invalid ] found in DOCTYPE declaration";
								}break;
								default:{
									if(count == 0) throw "__break__";
								}break;
								}
							}
						} catch( e ) { if( e != "__break__" ) throw e; }
						var x = Xml.createDocType(old.substr(10,pos - 11));
						current.addChild(x);
					}break;
					case 5:{
						if(!Xml.ecomment_end.match(str)) throw "Unclosed Comment";
						var p = Xml.ecomment_end.matchedPos();
						var x = Xml.createComment(str.substr(4,p.pos + p.len - 7));
						current.addChild(x);
						str = Xml.ecomment_end.matchedRight();
					}break;
					case 6:{
						var prolog = r.matched(0);
						var x = Xml.createProlog(prolog.substr(2,prolog.length - 4));
						current.addChild(x);
						str = r.matchedRight();
					}break;
					}
					throw "__break__";
				}
				i += 1;
			}
		} catch( e ) { if( e != "__break__" ) throw e; }
		if(i == nrules) {
			if(str.length > 10) throw "Xml parse error : Unexpected " + str.substr(0,10) + "...";
			else throw "Xml parse error : Unexpected " + str;
		}
	}
	if(!stack.isEmpty()) throw "Xml parse error : Unclosed " + stack.last().getNodeName();
	return current;
}
Xml.createElement = function(name) {
	var r = new Xml();
	r.nodeType = Xml.Element;
	r._children = new Array();
	r._attributes = new Hash();
	r.setNodeName(name);
	return r;
}
Xml.createPCData = function(data) {
	var r = new Xml();
	r.nodeType = Xml.PCData;
	r.setNodeValue(data);
	return r;
}
Xml.createCData = function(data) {
	var r = new Xml();
	r.nodeType = Xml.CData;
	r.setNodeValue(data);
	return r;
}
Xml.createComment = function(data) {
	var r = new Xml();
	r.nodeType = Xml.Comment;
	r.setNodeValue(data);
	return r;
}
Xml.createDocType = function(data) {
	var r = new Xml();
	r.nodeType = Xml.DocType;
	r.setNodeValue(data);
	return r;
}
Xml.createProlog = function(data) {
	var r = new Xml();
	r.nodeType = Xml.Prolog;
	r.setNodeValue(data);
	return r;
}
Xml.createDocument = function() {
	var r = new Xml();
	r.nodeType = Xml.Document;
	r._children = new Array();
	return r;
}
Xml.prototype.nodeType = null;
Xml.prototype.nodeName = null;
Xml.prototype.nodeValue = null;
Xml.prototype.parent = null;
Xml.prototype._nodeName = null;
Xml.prototype._nodeValue = null;
Xml.prototype._attributes = null;
Xml.prototype._children = null;
Xml.prototype._parent = null;
Xml.prototype.getNodeName = function() {
	if(this.nodeType != Xml.Element) throw "bad nodeType";
	return this._nodeName;
}
Xml.prototype.setNodeName = function(n) {
	if(this.nodeType != Xml.Element) throw "bad nodeType";
	return this._nodeName = n;
}
Xml.prototype.getNodeValue = function() {
	if(this.nodeType == Xml.Element || this.nodeType == Xml.Document) throw "bad nodeType";
	return this._nodeValue;
}
Xml.prototype.setNodeValue = function(v) {
	if(this.nodeType == Xml.Element || this.nodeType == Xml.Document) throw "bad nodeType";
	return this._nodeValue = v;
}
Xml.prototype.getParent = function() {
	return this._parent;
}
Xml.prototype.get = function(att) {
	if(this.nodeType != Xml.Element) throw "bad nodeType";
	return this._attributes.get(att);
}
Xml.prototype.set = function(att,value) {
	if(this.nodeType != Xml.Element) throw "bad nodeType";
	this._attributes.set(att,value);
}
Xml.prototype.remove = function(att) {
	if(this.nodeType != Xml.Element) throw "bad nodeType";
	this._attributes.remove(att);
}
Xml.prototype.exists = function(att) {
	if(this.nodeType != Xml.Element) throw "bad nodeType";
	return this._attributes.exists(att);
}
Xml.prototype.attributes = function() {
	if(this.nodeType != Xml.Element) throw "bad nodeType";
	return this._attributes.keys();
}
Xml.prototype.iterator = function() {
	if(this._children == null) throw "bad nodetype";
	return { cur : 0, x : this._children, hasNext : function() {
		return this.cur < this.x.length;
	}, next : function() {
		return this.x[this.cur++];
	}};
}
Xml.prototype.elements = function() {
	if(this._children == null) throw "bad nodetype";
	return { cur : 0, x : this._children, hasNext : function() {
		var k = this.cur;
		var l = this.x.length;
		while(k < l) {
			if(this.x[k].nodeType == Xml.Element) break;
			k += 1;
		}
		this.cur = k;
		return k < l;
	}, next : function() {
		var k = this.cur;
		var l = this.x.length;
		while(k < l) {
			var n = this.x[k];
			k += 1;
			if(n.nodeType == Xml.Element) {
				this.cur = k;
				return n;
			}
		}
		return null;
	}};
}
Xml.prototype.elementsNamed = function(name) {
	if(this._children == null) throw "bad nodetype";
	return { cur : 0, x : this._children, hasNext : function() {
		var k = this.cur;
		var l = this.x.length;
		while(k < l) {
			var n = this.x[k];
			if(n.nodeType == Xml.Element && n._nodeName == name) break;
			k++;
		}
		this.cur = k;
		return k < l;
	}, next : function() {
		var k = this.cur;
		var l = this.x.length;
		while(k < l) {
			var n = this.x[k];
			k++;
			if(n.nodeType == Xml.Element && n._nodeName == name) {
				this.cur = k;
				return n;
			}
		}
		return null;
	}};
}
Xml.prototype.firstChild = function() {
	if(this._children == null) throw "bad nodetype";
	return this._children[0];
}
Xml.prototype.firstElement = function() {
	if(this._children == null) throw "bad nodetype";
	var cur = 0;
	var l = this._children.length;
	while(cur < l) {
		var n = this._children[cur];
		if(n.nodeType == Xml.Element) return n;
		cur++;
	}
	return null;
}
Xml.prototype.addChild = function(x) {
	if(this._children == null) throw "bad nodetype";
	if(x._parent != null) x._parent._children.remove(x);
	x._parent = this;
	this._children.push(x);
}
Xml.prototype.removeChild = function(x) {
	if(this._children == null) throw "bad nodetype";
	var b = this._children.remove(x);
	if(b) x._parent = null;
	return b;
}
Xml.prototype.insertChild = function(x,pos) {
	if(this._children == null) throw "bad nodetype";
	if(x._parent != null) x._parent._children.remove(x);
	x._parent = this;
	this._children.insert(pos,x);
}
Xml.prototype.toString = function() {
	if(this.nodeType == Xml.PCData) return this._nodeValue;
	if(this.nodeType == Xml.CData) return "<![CDATA[" + this._nodeValue + "]]>";
	if(this.nodeType == Xml.Comment) return "<!--" + this._nodeValue + "-->";
	if(this.nodeType == Xml.DocType) return "<!DOCTYPE " + this._nodeValue + ">";
	if(this.nodeType == Xml.Prolog) return "<?" + this._nodeValue + "?>";
	var s = new StringBuf();
	if(this.nodeType == Xml.Element) {
		s.b[s.b.length] = "<";
		s.b[s.b.length] = this._nodeName;
		{ var $it0 = this._attributes.keys();
		while( $it0.hasNext() ) { var k = $it0.next();
		{
			s.b[s.b.length] = " ";
			s.b[s.b.length] = k;
			s.b[s.b.length] = "=\"";
			s.b[s.b.length] = this._attributes.get(k);
			s.b[s.b.length] = "\"";
		}
		}}
		if(this._children.length == 0) {
			s.b[s.b.length] = "/>";
			return s.b.join("");
		}
		s.b[s.b.length] = ">";
	}
	{ var $it1 = this.iterator();
	while( $it1.hasNext() ) { var x = $it1.next();
	s.b[s.b.length] = x.toString();
	}}
	if(this.nodeType == Xml.Element) {
		s.b[s.b.length] = "</";
		s.b[s.b.length] = this._nodeName;
		s.b[s.b.length] = ">";
	}
	return s.b.join("");
}
Xml.prototype.__class__ = Xml;
if(typeof haxe=='undefined') haxe = {}
haxe.Log = function() { }
haxe.Log.__name__ = ["haxe","Log"];
haxe.Log.trace = function(v,infos) {
	js.Boot.__trace(v,infos);
}
haxe.Log.clear = function() {
	js.Boot.__clear_trace();
}
haxe.Log.prototype.__class__ = haxe.Log;
if(typeof orc=='undefined') orc = {}
if(!orc.utils) orc.utils = {}
orc.utils.ImageMetricHelper = function(imgWidth,imgHeight) { if( imgWidth === $_ ) return; {
	this.width = imgWidth;
	this.height = imgHeight;
	this.diagonalLineTheta = Math.atan2(this.width,this.height);
	this.diagonalLineLength = Math.sqrt(this.width * this.width + this.height * this.height);
}}
orc.utils.ImageMetricHelper.__name__ = ["orc","utils","ImageMetricHelper"];
orc.utils.ImageMetricHelper.prototype.diagonalLineTheta = null;
orc.utils.ImageMetricHelper.prototype.diagonalLineLength = null;
orc.utils.ImageMetricHelper.prototype.width = null;
orc.utils.ImageMetricHelper.prototype.height = null;
orc.utils.ImageMetricHelper.prototype.getMaxFitScale = function(width,height,rotation) {
	if(rotation == null) rotation = 0;
	var scaleX;
	var scaleY;
	if(rotation == 0 || rotation == 180) {
		scaleX = width / this.width;
		scaleY = height / this.height;
	}
	else {
		var r = Math.PI * rotation / 180;
		var t0 = this.diagonalLineTheta + r;
		var w0 = Math.abs(this.diagonalLineLength * Math.sin(t0));
		var h0 = Math.abs(this.diagonalLineLength * Math.cos(t0));
		var t1 = -this.diagonalLineTheta + r;
		var w1 = Math.abs(this.diagonalLineLength * Math.sin(t1));
		var h1 = Math.abs(this.diagonalLineLength * Math.cos(t1));
		var w = Math.max(w0,w1);
		var h = Math.max(h0,h1);
		scaleX = width / w;
		scaleY = height / h;
	}
	return Math.min(scaleX,scaleY);
}
orc.utils.ImageMetricHelper.prototype.__class__ = orc.utils.ImageMetricHelper;
orc.utils.Util = function() { }
orc.utils.Util.__name__ = ["orc","utils","Util"];
orc.utils.Util.request = function(url,call) {
	var http = new haxe.Http(url);
	http.onData = call;
	http.onError = $closure(js.Lib,"alert");
	http.request(false);
}
orc.utils.Util.prototype.__class__ = orc.utils.Util;
StringBuf = function(p) { if( p === $_ ) return; {
	this.b = new Array();
}}
StringBuf.__name__ = ["StringBuf"];
StringBuf.prototype.add = function(x) {
	this.b[this.b.length] = x;
}
StringBuf.prototype.addSub = function(s,pos,len) {
	this.b[this.b.length] = s.substr(pos,len);
}
StringBuf.prototype.addChar = function(c) {
	this.b[this.b.length] = String.fromCharCode(c);
}
StringBuf.prototype.toString = function() {
	return this.b.join("");
}
StringBuf.prototype.b = null;
StringBuf.prototype.__class__ = StringBuf;
if(typeof core=='undefined') core = {}
core.Tweener = function(p) { if( p === $_ ) return; {
	this.count = 0;
	this.maxCount = 0;
}}
core.Tweener.__name__ = ["core","Tweener"];
core.Tweener.prototype.count = null;
core.Tweener.prototype.maxCount = null;
core.Tweener.prototype.onChange = null;
core.Tweener.prototype.start = function(max) {
	if(max == null) max = 1;
	this.maxCount = max;
	this.count = 0;
	this.run();
}
core.Tweener.prototype.stop = function() {
	this.maxCount = this.count;
}
core.Tweener.prototype.run = function() {
	if(this.count >= this.maxCount) return;
	haxe.Timer.delay($closure(this,"onChangeInvoke"),20);
}
core.Tweener.prototype.onChangeInvoke = function() {
	this.count++;
	if(this.onChange == null) return;
	if(this.count > this.maxCount) return;
	this.onChange(this.count);
	this.run();
}
core.Tweener.prototype.__class__ = core.Tweener;
core.Page = function(p) { if( p === $_ ) return; {
	this.visible = true;
	this.pageOffset = 0;
}}
core.Page.__name__ = ["core","Page"];
core.Page.prototype.urlPage = null;
core.Page.prototype.urlThumb = null;
core.Page.prototype.id = null;
core.Page.prototype.num = null;
core.Page.prototype.turnRightCallback = null;
core.Page.prototype.turnLeftCallback = null;
core.Page.prototype.drawParams = null;
core.Page.prototype.pageOffset = null;
core.Page.prototype.ctx = null;
core.Page.prototype._imagePage = null;
core.Page.prototype._imageData = null;
core.Page.prototype.imagePage = null;
core.Page.prototype.loaded = null;
core.Page.prototype.visible = null;
core.Page.prototype.bookContext = null;
core.Page.prototype.onLoadImage = function() {
	this.loaded = true;
	this.draw();
}
core.Page.prototype.getImagePage = function() {
	if(this._imagePage != null) return this._imagePage;
	var img = new Image();
	img.src = this.urlPage;
	img.onload = $closure(this,"onLoadImage");
	this._imagePage = img;
	return this._imagePage;
}
core.Page.prototype.clearCallback = function() {
	this.turnLeftCallback = null;
	this.turnRightCallback = null;
}
core.Page.prototype.onMouseClick = function(e) {
	if(e.localX > this.getImagePage().width * 0.5) {
		if(this.turnRightCallback != null) {
			this.turnRightCallback();
		}
	}
	else {
		if(this.turnLeftCallback != null) {
			this.turnLeftCallback();
		}
	}
}
core.Page.prototype.loadToContext2D = function(ctx) {
	this.ctx = ctx;
	if(this._imagePage == null) {
		this.getImagePage();
	}
	if(this.loaded == true) {
		this.draw();
	}
}
core.Page.prototype.draw = function() {
	if(this.ctx == null) return;
	if(this.drawParams == null) return;
	if(this.visible == false) return;
	var offset = this.pageOffset;
	if(this.bookContext != null) {
		offset += this.bookContext.pageOffset;
	}
	if(offset > -1.001 && offset < -1) offset = -1;
	if(offset > 1 && offset < 1.001) offset = 1;
	if(offset <= -1 || offset >= 1) return;
	this.drawImageCore(offset);
}
core.Page.prototype.drawDataCore = function(offset) {
	var dp = this.drawParams;
	if(offset == 0) {
		this.ctx.putImageData(this._imageData,dp.dx,dp.dy);
	}
	else if(offset > 0) {
		this.ctx.putImageData(this._imageData,dp.dx + dp.dw * offset,dp.dy,0,0,dp.dw * (1 - offset),dp.dh);
	}
	else {
		offset = -offset;
		this.ctx.putImageData(this._imageData,dp.dx,dp.dy,offset * dp.sw,0,dp.dw * (1 - offset),dp.dh);
	}
}
core.Page.prototype.drawImageCore = function(offset) {
	var dp = this.drawParams;
	if(offset == 0) {
		this.ctx.drawImage(this._imagePage,dp.sx,dp.sy,dp.sw,dp.sh,dp.dx,dp.dy,dp.dw,dp.dh);
		if(this._imageData == null) null;
	}
	else if(offset > 0) {
		this.ctx.drawImage(this._imagePage,dp.sx,dp.sy,dp.sw * (1 - offset),dp.sh,dp.dx + dp.dw * offset,dp.dy,dp.dw * (1 - offset),dp.dh);
	}
	else {
		offset = -offset;
		this.ctx.drawImage(this._imagePage,dp.sx + offset * dp.sw,dp.sy,dp.sw * (1 - offset),dp.sh,dp.dx,dp.dy,dp.dw * (1 - offset),dp.dh);
	}
}
core.Page.prototype.__class__ = core.Page;
FlipBook = function(p) { if( p === $_ ) return; {
	this.bookContext = new core.BookContext();
	this.tweener = new core.Tweener();
}}
FlipBook.__name__ = ["FlipBook"];
FlipBook.prototype.canvas = null;
FlipBook.prototype.root = null;
FlipBook.prototype.bookContext = null;
FlipBook.prototype.tweener = null;
FlipBook.prototype.getContext = function() {
	return this.canvas.getContext("2d");
}
FlipBook.prototype.attachActions = function() {
	if(this.root == null) return;
	this.root.onmousedown = $closure(this,"onMouseDown");
}
FlipBook.prototype.currentPageNum = null;
FlipBook.prototype.initBackground = function() {
	var ctx = this.getContext();
	var dp = RunTime.getDrawParams();
	js.Lib.alert(dp.toString());
	ctx.fillStyle = "#FFFFFF";
	ctx.fillRect(dp.dxi(),dp.dyi(),dp.dwi(),dp.dhi());
	var img = ctx.getImageData(dp.dxi(),dp.dyi(),dp.dwi(),dp.dhi());
	return img;
}
FlipBook.prototype.loadPage = function(index) {
	this.currentPageNum = index;
	this.bookContext.addPage(RunTime.getPage(this.currentPageNum));
	this.bookContext.render();
}
FlipBook.prototype.onMouseDown = function(e) {
	var dp = RunTime.getDrawParams();
	if(e.clientX < dp.dx || e.clientX > dp.dx + dp.dw) {
		return;
	}
	this.turnPage(e.clientX < 0.5 * (dp.dx + dp.dw)?-1:1);
}
FlipBook.prototype.turnPage = function(pageOffset) {
	if(pageOffset == 0) return;
	if(RunTime.book == null || RunTime.book.pages == null) return;
	var dstPageNum = this.currentPageNum + pageOffset;
	var dstPage = RunTime.getPage(dstPageNum);
	if(dstPage == null) return;
	var self = this;
	this.bookContext.removeAllPages();
	this.bookContext.addPage(RunTime.getPage(this.currentPageNum,0));
	this.bookContext.addPage(RunTime.getPage(this.currentPageNum,1));
	this.bookContext.addPage(RunTime.getPage(this.currentPageNum,-1));
	this.bookContext.pageOffset = 0;
	if(this.tweener != null) {
		this.tweener.stop();
	}
	var maxCount = 8;
	this.tweener.onChange = function(count) {
		var ratio = count / maxCount;
		self.bookContext.pageOffset = -pageOffset * ratio * ratio * ratio;
		if(count == maxCount) {
			self.bookContext.pageOffset = -pageOffset;
		}
		self.bookContext.render();
		if(count == maxCount) {
			self.currentPageNum = dstPageNum;
		}
	}
	this.tweener.start(Std["int"](maxCount));
}
FlipBook.prototype.__class__ = FlipBook;
IntIter = function(min,max) { if( min === $_ ) return; {
	this.min = min;
	this.max = max;
}}
IntIter.__name__ = ["IntIter"];
IntIter.prototype.min = null;
IntIter.prototype.max = null;
IntIter.prototype.hasNext = function() {
	return this.min < this.max;
}
IntIter.prototype.next = function() {
	return this.min++;
}
IntIter.prototype.__class__ = IntIter;
haxe.Timer = function(time_ms) { if( time_ms === $_ ) return; {
	this.id = haxe.Timer.arr.length;
	haxe.Timer.arr[this.id] = this;
	this.timerId = window.setInterval("haxe.Timer.arr[" + this.id + "].run();",time_ms);
}}
haxe.Timer.__name__ = ["haxe","Timer"];
haxe.Timer.delay = function(f,time_ms) {
	var t = new haxe.Timer(time_ms);
	t.run = function() {
		t.stop();
		f();
	}
	return t;
}
haxe.Timer.measure = function(f,pos) {
	var t0 = haxe.Timer.stamp();
	var r = f();
	haxe.Log.trace(haxe.Timer.stamp() - t0 + "s",pos);
	return r;
}
haxe.Timer.stamp = function() {
	return Date.now().getTime() / 1000;
}
haxe.Timer.prototype.id = null;
haxe.Timer.prototype.timerId = null;
haxe.Timer.prototype.stop = function() {
	if(this.id == null) return;
	window.clearInterval(this.timerId);
	haxe.Timer.arr[this.id] = null;
	if(this.id > 100 && this.id == haxe.Timer.arr.length - 1) {
		var p = this.id - 1;
		while(p >= 0 && haxe.Timer.arr[p] == null) p--;
		haxe.Timer.arr = haxe.Timer.arr.slice(0,p + 1);
	}
	this.id = null;
}
haxe.Timer.prototype.run = function() {
	null;
}
haxe.Timer.prototype.__class__ = haxe.Timer;
Std = function() { }
Std.__name__ = ["Std"];
Std["is"] = function(v,t) {
	return js.Boot.__instanceof(v,t);
}
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
}
Std["int"] = function(x) {
	if(x < 0) return Math.ceil(x);
	return Math.floor(x);
}
Std.parseInt = function(x) {
	var v = parseInt(x,10);
	if(v == 0 && x.charCodeAt(1) == 120) v = parseInt(x);
	if(isNaN(v)) return null;
	return v;
}
Std.parseFloat = function(x) {
	return parseFloat(x);
}
Std.random = function(x) {
	return Math.floor(Math.random() * x);
}
Std.prototype.__class__ = Std;
List = function(p) { if( p === $_ ) return; {
	this.length = 0;
}}
List.__name__ = ["List"];
List.prototype.h = null;
List.prototype.q = null;
List.prototype.length = null;
List.prototype.add = function(item) {
	var x = [item];
	if(this.h == null) this.h = x;
	else this.q[1] = x;
	this.q = x;
	this.length++;
}
List.prototype.push = function(item) {
	var x = [item,this.h];
	this.h = x;
	if(this.q == null) this.q = x;
	this.length++;
}
List.prototype.first = function() {
	return this.h == null?null:this.h[0];
}
List.prototype.last = function() {
	return this.q == null?null:this.q[0];
}
List.prototype.pop = function() {
	if(this.h == null) return null;
	var x = this.h[0];
	this.h = this.h[1];
	if(this.h == null) this.q = null;
	this.length--;
	return x;
}
List.prototype.isEmpty = function() {
	return this.h == null;
}
List.prototype.clear = function() {
	this.h = null;
	this.q = null;
	this.length = 0;
}
List.prototype.remove = function(v) {
	var prev = null;
	var l = this.h;
	while(l != null) {
		if(l[0] == v) {
			if(prev == null) this.h = l[1];
			else prev[1] = l[1];
			if(this.q == l) this.q = prev;
			this.length--;
			return true;
		}
		prev = l;
		l = l[1];
	}
	return false;
}
List.prototype.iterator = function() {
	return { h : this.h, hasNext : function() {
		return this.h != null;
	}, next : function() {
		if(this.h == null) return null;
		var x = this.h[0];
		this.h = this.h[1];
		return x;
	}};
}
List.prototype.toString = function() {
	var s = new StringBuf();
	var first = true;
	var l = this.h;
	s.b[s.b.length] = "{";
	while(l != null) {
		if(first) first = false;
		else s.b[s.b.length] = ", ";
		s.b[s.b.length] = Std.string(l[0]);
		l = l[1];
	}
	s.b[s.b.length] = "}";
	return s.b.join("");
}
List.prototype.join = function(sep) {
	var s = new StringBuf();
	var first = true;
	var l = this.h;
	while(l != null) {
		if(first) first = false;
		else s.b[s.b.length] = sep;
		s.b[s.b.length] = l[0];
		l = l[1];
	}
	return s.b.join("");
}
List.prototype.filter = function(f) {
	var l2 = new List();
	var l = this.h;
	while(l != null) {
		var v = l[0];
		l = l[1];
		if(f(v)) l2.add(v);
	}
	return l2;
}
List.prototype.map = function(f) {
	var b = new List();
	var l = this.h;
	while(l != null) {
		var v = l[0];
		l = l[1];
		b.add(f(v));
	}
	return b;
}
List.prototype.__class__ = List;
haxe.Http = function(url) { if( url === $_ ) return; {
	this.url = url;
	this.headers = new Hash();
	this.params = new Hash();
	this.async = true;
}}
haxe.Http.__name__ = ["haxe","Http"];
haxe.Http.requestUrl = function(url) {
	var h = new haxe.Http(url);
	h.async = false;
	var r = null;
	h.onData = function(d) {
		r = d;
	}
	h.onError = function(e) {
		throw e;
	}
	h.request(false);
	return r;
}
haxe.Http.prototype.url = null;
haxe.Http.prototype.async = null;
haxe.Http.prototype.postData = null;
haxe.Http.prototype.headers = null;
haxe.Http.prototype.params = null;
haxe.Http.prototype.setHeader = function(header,value) {
	this.headers.set(header,value);
}
haxe.Http.prototype.setParameter = function(param,value) {
	this.params.set(param,value);
}
haxe.Http.prototype.setPostData = function(data) {
	this.postData = data;
}
haxe.Http.prototype.request = function(post) {
	var me = this;
	var r = new js.XMLHttpRequest();
	var onreadystatechange = function() {
		if(r.readyState != 4) return;
		var s = (function($this) {
			var $r;
			try {
				$r = r.status;
			}
			catch( $e0 ) {
				{
					var e = $e0;
					$r = null;
				}
			}
			return $r;
		}(this));
		if(s == undefined) s = null;
		if(s != null) me.onStatus(s);
		if(s != null && s >= 200 && s < 400) me.onData(r.responseText);
		else switch(s) {
		case null: case undefined:{
			me.onError("Failed to connect or resolve host");
		}break;
		case 12029:{
			me.onError("Failed to connect to host");
		}break;
		case 12007:{
			me.onError("Unknown host");
		}break;
		default:{
			me.onError("Http Error #" + r.status);
		}break;
		}
	}
	if(this.async) r.onreadystatechange = onreadystatechange;
	var uri = this.postData;
	if(uri != null) post = true;
	else { var $it1 = this.params.keys();
	while( $it1.hasNext() ) { var p = $it1.next();
	{
		if(uri == null) uri = "";
		else uri += "&";
		uri += StringTools.urlDecode(p) + "=" + StringTools.urlEncode(this.params.get(p));
	}
	}}
	try {
		if(post) r.open("POST",this.url,this.async);
		else if(uri != null) {
			var question = this.url.split("?").length <= 1;
			r.open("GET",this.url + (question?"?":"&") + uri,this.async);
			uri = null;
		}
		else r.open("GET",this.url,this.async);
	}
	catch( $e2 ) {
		{
			var e = $e2;
			{
				this.onError(e.toString());
				return;
			}
		}
	}
	if(this.headers.get("Content-Type") == null && post && this.postData == null) r.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
	{ var $it3 = this.headers.keys();
	while( $it3.hasNext() ) { var h = $it3.next();
	r.setRequestHeader(h,this.headers.get(h));
	}}
	r.send(uri);
	if(!this.async) onreadystatechange();
}
haxe.Http.prototype.onData = function(data) {
	null;
}
haxe.Http.prototype.onError = function(msg) {
	null;
}
haxe.Http.prototype.onStatus = function(status) {
	null;
}
haxe.Http.prototype.__class__ = haxe.Http;
if(typeof js=='undefined') js = {}
js.Lib = function() { }
js.Lib.__name__ = ["js","Lib"];
js.Lib.isIE = null;
js.Lib.isOpera = null;
js.Lib.document = null;
js.Lib.window = null;
js.Lib.alert = function(v) {
	alert(js.Boot.__string_rec(v,""));
}
js.Lib.eval = function(code) {
	return eval(code);
}
js.Lib.setErrorHandler = function(f) {
	js.Lib.onerror = f;
}
js.Lib.prototype.__class__ = js.Lib;
js.Boot = function() { }
js.Boot.__name__ = ["js","Boot"];
js.Boot.__unhtml = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
}
js.Boot.__trace = function(v,i) {
	var msg = i != null?i.fileName + ":" + i.lineNumber + ": ":"";
	msg += js.Boot.__unhtml(js.Boot.__string_rec(v,"")) + "<br/>";
	var d = document.getElementById("haxe:trace");
	if(d == null) alert("No haxe:trace element defined\n" + msg);
	else d.innerHTML += msg;
}
js.Boot.__clear_trace = function() {
	var d = document.getElementById("haxe:trace");
	if(d != null) d.innerHTML = "";
	else null;
}
js.Boot.__closure = function(o,f) {
	var m = o[f];
	if(m == null) return null;
	var f1 = function() {
		return m.apply(o,arguments);
	}
	f1.scope = o;
	f1.method = m;
	return f1;
}
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ != null || o.__ename__ != null)) t = "object";
	switch(t) {
	case "object":{
		if(o instanceof Array) {
			if(o.__enum__ != null) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				{
					var _g1 = 2, _g = o.length;
					while(_g1 < _g) {
						var i = _g1++;
						if(i != 2) str += "," + js.Boot.__string_rec(o[i],s);
						else str += js.Boot.__string_rec(o[i],s);
					}
				}
				return str + ")";
			}
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			{
				var _g = 0;
				while(_g < l) {
					var i1 = _g++;
					str += (i1 > 0?",":"") + js.Boot.__string_rec(o[i1],s);
				}
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		}
		catch( $e0 ) {
			{
				var e = $e0;
				{
					return "???";
				}
			}
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) { ;
		if(hasp && !o.hasOwnProperty(k)) continue;
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__") continue;
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	}break;
	case "function":{
		return "<function>";
	}break;
	case "string":{
		return o;
	}break;
	default:{
		return String(o);
	}break;
	}
}
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0, _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
}
js.Boot.__instanceof = function(o,cl) {
	try {
		if(o instanceof cl) {
			if(cl == Array) return o.__enum__ == null;
			return true;
		}
		if(js.Boot.__interfLoop(o.__class__,cl)) return true;
	}
	catch( $e0 ) {
		{
			var e = $e0;
			{
				if(cl == null) return false;
			}
		}
	}
	switch(cl) {
	case Int:{
		return Math.ceil(o%2147483648.0) === o;
	}break;
	case Float:{
		return typeof(o) == "number";
	}break;
	case Bool:{
		return o === true || o === false;
	}break;
	case String:{
		return typeof(o) == "string";
	}break;
	case Dynamic:{
		return true;
	}break;
	default:{
		if(o == null) return false;
		return o.__enum__ == cl || cl == Class && o.__name__ != null || cl == Enum && o.__ename__ != null;
	}break;
	}
}
js.Boot.__init = function() {
	js.Lib.isIE = typeof document!='undefined' && document.all != null && typeof window!='undefined' && window.opera == null;
	js.Lib.isOpera = typeof window!='undefined' && window.opera != null;
	Array.prototype.copy = Array.prototype.slice;
	Array.prototype.insert = function(i,x) {
		this.splice(i,0,x);
	}
	Array.prototype.remove = Array.prototype.indexOf?function(obj) {
		var idx = this.indexOf(obj);
		if(idx == -1) return false;
		this.splice(idx,1);
		return true;
	}:function(obj) {
		var i = 0;
		var l = this.length;
		while(i < l) {
			if(this[i] == obj) {
				this.splice(i,1);
				return true;
			}
			i++;
		}
		return false;
	}
	Array.prototype.iterator = function() {
		return { cur : 0, arr : this, hasNext : function() {
			return this.cur < this.arr.length;
		}, next : function() {
			return this.arr[this.cur++];
		}};
	}
	if(String.prototype.cca == null) String.prototype.cca = String.prototype.charCodeAt;
	String.prototype.charCodeAt = function(i) {
		var x = this.cca(i);
		if(x != x) return null;
		return x;
	}
	var oldsub = String.prototype.substr;
	String.prototype.substr = function(pos,len) {
		if(pos != null && pos != 0 && len != null && len < 0) return "";
		if(len == null) len = this.length;
		if(pos < 0) {
			pos = this.length + pos;
			if(pos < 0) pos = 0;
		}
		else if(len < 0) {
			len = this.length + len - pos;
		}
		return oldsub.apply(this,[pos,len]);
	}
	$closure = js.Boot.__closure;
}
js.Boot.prototype.__class__ = js.Boot;
core.BookContext = function(p) { if( p === $_ ) return; {
	this.pages = new Array();
	this.pageOffset = 0;
}}
core.BookContext.__name__ = ["core","BookContext"];
core.BookContext.prototype.ctx = null;
core.BookContext.prototype.pages = null;
core.BookContext.prototype.pageOffset = null;
core.BookContext.prototype.getPageCount = function() {
	return this.pages.length;
}
core.BookContext.prototype.removeAllPages = function() {
	if(this.pages != null) {
		{
			var _g1 = 0, _g = this.pages.length;
			while(_g1 < _g) {
				var i = _g1++;
				var item = this.pages[i];
				item.visible = false;
			}
		}
	}
	this.pages = new Array();
}
core.BookContext.prototype.clear = function(removePages) {
	if(removePages == null) removePages = false;
	if(this.pages != null) {
		{
			var _g1 = 0, _g = this.pages.length;
			while(_g1 < _g) {
				var i = _g1++;
				var item = this.pages[i];
				item.visible = false;
			}
		}
	}
	if(removePages == true) {
		this.pages = new Array();
	}
	if(this.ctx != null) {
		this.ctx.clearRect(0,0,this.ctx.canvas.width,this.ctx.canvas.height);
	}
}
core.BookContext.prototype.addPage = function(page) {
	if(page == null) return;
	if(this.pages == null) this.pages = new Array();
	page.bookContext = this;
	this.pages.push(page);
}
core.BookContext.prototype.render = function() {
	this.clear();
	if(this.pages != null && this.ctx != null) {
		{
			var _g1 = 0, _g = this.pages.length;
			while(_g1 < _g) {
				var i = _g1++;
				var item = this.pages[i];
				item.visible = true;
				item.loadToContext2D(this.ctx);
			}
		}
	}
}
core.BookContext.prototype.__class__ = core.BookContext;
core.Book = function(p) { if( p === $_ ) return; {
	this.pages = new Array();
}}
core.Book.__name__ = ["core","Book"];
core.Book.prototype.pages = null;
core.Book.prototype.pageWidth = null;
core.Book.prototype.pageHeight = null;
core.Book.prototype.__class__ = core.Book;
RunTime = function() { }
RunTime.__name__ = ["RunTime"];
RunTime.bookInfo = null;
RunTime.pageInfo = null;
RunTime.bgImageData = null;
RunTime.flipBook = null;
RunTime.clientWidth = null;
RunTime.clientHeight = null;
RunTime.pageScale = null;
RunTime.imagePageWidth = null;
RunTime.imagePageHeight = null;
RunTime.alert = function(msg) {
	js.Lib.alert(msg);
}
RunTime.init = function() {
	RunTime.clientWidth = js.Lib.window.document.body.clientWidth;
	RunTime.clientHeight = js.Lib.window.document.body.clientHeight;
}
RunTime.requestBookInfo = function() {
	orc.utils.Util.request(RunTime.urlBookinfo,function(data) {
		RunTime.bookInfo = Xml.parse(data);
		RunTime.loadBookInfo();
		RunTime.requestPages();
	});
}
RunTime.requestPages = function() {
	orc.utils.Util.request(RunTime.urlPageInfo,function(data) {
		RunTime.pageInfo = Xml.parse(data);
		RunTime.loadPageInfo();
	});
}
RunTime.loadBookInfo = function() {
	if(RunTime.bookInfo == null) return;
	var i = RunTime.bookInfo.elementsNamed("bookinfo");
	if(i.hasNext() == false) return;
	var node = i.next();
	var pageWidth = Std.parseFloat(node.get("pageWidth"));
	var pageHeight = Std.parseFloat(node.get("pageHeight"));
	RunTime.book.pageWidth = pageWidth;
	RunTime.book.pageHeight = pageHeight;
	var m = new orc.utils.ImageMetricHelper(pageWidth,pageHeight);
	var w = RunTime.clientWidth - 32 - 32;
	var h = RunTime.clientHeight - 48;
	var scale = m.getMaxFitScale(w,h);
	RunTime.imagePageWidth = pageWidth * scale;
	RunTime.imagePageHeight = pageHeight * scale;
	RunTime.pageScale = scale;
	RunTime.bgImageData = RunTime.flipBook.initBackground();
}
RunTime.loadPageInfo = function() {
	if(RunTime.pageInfo == null) return;
	var i = RunTime.pageInfo.firstChild().elementsNamed("page");
	var num = 1;
	while(i.hasNext() == true) {
		var node = i.next();
		var id = node.get("id");
		var source = node.get("source");
		var thumb = node.get("thumb");
		var page = new core.Page();
		page.id = id;
		page.num = num;
		page.urlPage = source;
		page.urlThumb = thumb;
		RunTime.book.pages.push(page);
		num++;
	}
	RunTime.flipBook.loadPage(0);
}
RunTime.getPage = function(currentPageNum,pageOffset) {
	if(pageOffset == null) pageOffset = 0;
	if(RunTime.book == null || RunTime.book.pages == null) return null;
	var num = currentPageNum + pageOffset;
	if(num < 0 || num > RunTime.book.pages.length - 1) return null;
	var page = RunTime.book.pages[num];
	page.pageOffset = pageOffset;
	page.drawParams = RunTime.getDrawParams();
	return page;
}
RunTime.getDrawParams = function() {
	var dp = new core.DrawParams();
	var im = new orc.utils.ImageMetricHelper(RunTime.book.pageWidth,RunTime.book.pageHeight);
	var cw = RunTime.clientWidth - 32 - 32;
	var ch = RunTime.clientHeight - 48;
	var scale = im.getMaxFitScale(cw,ch);
	var dw = scale * RunTime.book.pageWidth;
	var dh = scale * RunTime.book.pageHeight;
	var dx = 32 + 0.5 * (cw - dw);
	var dy = 0.5 * (ch - dh);
	var sx = 0;
	var sy = 0;
	var sw = RunTime.book.pageWidth;
	var sh = RunTime.book.pageHeight;
	dp.sx = sx;
	dp.sy = sy;
	dp.sw = sw;
	dp.sh = sh;
	dp.dx = dx;
	dp.dy = dy;
	dp.dw = dw;
	dp.dh = dh;
	return dp;
}
RunTime.prototype.__class__ = RunTime;
core.DrawParams = function(p) { if( p === $_ ) return; {
	null;
}}
core.DrawParams.__name__ = ["core","DrawParams"];
core.DrawParams.prototype.sx = null;
core.DrawParams.prototype.sy = null;
core.DrawParams.prototype.sw = null;
core.DrawParams.prototype.sh = null;
core.DrawParams.prototype.dx = null;
core.DrawParams.prototype.dy = null;
core.DrawParams.prototype.dw = null;
core.DrawParams.prototype.dh = null;
core.DrawParams.prototype.dxi = function() {
	return Math.round(this.dx);
}
core.DrawParams.prototype.dyi = function() {
	return Math.round(this.dy);
}
core.DrawParams.prototype.dwi = function() {
	return Math.round(this.dw);
}
core.DrawParams.prototype.dhi = function() {
	return Math.round(this.dh);
}
core.DrawParams.prototype.toString = function() {
	return Std.string(this.sx) + "," + Std.string(this.sy) + "," + Std.string(this.sw) + "," + Std.string(this.sh) + "," + Std.string(this.dx) + "," + Std.string(this.dy) + "," + Std.string(this.dw) + "," + Std.string(this.dh);
}
core.DrawParams.prototype.__class__ = core.DrawParams;
Hash = function(p) { if( p === $_ ) return; {
	this.h = {}
	if(this.h.__proto__ != null) {
		this.h.__proto__ = null;
		delete(this.h.__proto__);
	}
	else null;
}}
Hash.__name__ = ["Hash"];
Hash.prototype.h = null;
Hash.prototype.set = function(key,value) {
	this.h["$" + key] = value;
}
Hash.prototype.get = function(key) {
	return this.h["$" + key];
}
Hash.prototype.exists = function(key) {
	try {
		key = "$" + key;
		return this.hasOwnProperty.call(this.h,key);
	}
	catch( $e0 ) {
		{
			var e = $e0;
			{
				
				for(var i in this.h)
					if( i == key ) return true;
			;
				return false;
			}
		}
	}
}
Hash.prototype.remove = function(key) {
	if(!this.exists(key)) return false;
	delete(this.h["$" + key]);
	return true;
}
Hash.prototype.keys = function() {
	var a = new Array();
	
			for(var i in this.h)
				a.push(i.substr(1));
		;
	return a.iterator();
}
Hash.prototype.iterator = function() {
	return { ref : this.h, it : this.keys(), hasNext : function() {
		return this.it.hasNext();
	}, next : function() {
		var i = this.it.next();
		return this.ref["$" + i];
	}};
}
Hash.prototype.toString = function() {
	var s = new StringBuf();
	s.b[s.b.length] = "{";
	var it = this.keys();
	{ var $it0 = it;
	while( $it0.hasNext() ) { var i = $it0.next();
	{
		s.b[s.b.length] = i;
		s.b[s.b.length] = " => ";
		s.b[s.b.length] = Std.string(this.get(i));
		if(it.hasNext()) s.b[s.b.length] = ", ";
	}
	}}
	s.b[s.b.length] = "}";
	return s.b.join("");
}
Hash.prototype.__class__ = Hash;
Main = function() { }
Main.__name__ = ["Main"];
Main.main = function() {
	Main.init();
}
Main.testCss = function() {
	var t = new core.Tweener();
	var max = 20;
	var cvs = js.Lib.document.getElementById("img");
	t.onChange = function(count) {
		var l = Std.string(count * 30);
		cvs.style.left = l;
	}
	t.start(max);
}
Main.init = function() {
	RunTime.init();
	RunTime.flipBook = new FlipBook();
	RunTime.flipBook.root = js.Lib.document.getElementById("cvsBook");
	var c = RunTime.flipBook.root;
	RunTime.flipBook.canvas = c;
	RunTime.flipBook.attachActions();
	c.width = RunTime.clientWidth;
	c.height = RunTime.clientHeight;
	RunTime.flipBook.bookContext.ctx = RunTime.flipBook.getContext();
	RunTime.requestBookInfo();
}
Main.prototype.__class__ = Main;
$_ = {}
js.Boot.__res = {}
js.Boot.__init();
{
	Xml.Element = "element";
	Xml.PCData = "pcdata";
	Xml.CData = "cdata";
	Xml.Comment = "comment";
	Xml.DocType = "doctype";
	Xml.Prolog = "prolog";
	Xml.Document = "document";
}
{
	var d = Date;
	d.now = function() {
		return new Date();
	}
	d.fromTime = function(t) {
		var d1 = new Date();
		d1["setTime"](t);
		return d1;
	}
	d.fromString = function(s) {
		switch(s.length) {
		case 8:{
			var k = s.split(":");
			var d1 = new Date();
			d1["setTime"](0);
			d1["setUTCHours"](k[0]);
			d1["setUTCMinutes"](k[1]);
			d1["setUTCSeconds"](k[2]);
			return d1;
		}break;
		case 10:{
			var k = s.split("-");
			return new Date(k[0],k[1] - 1,k[2],0,0,0);
		}break;
		case 19:{
			var k = s.split(" ");
			var y = k[0].split("-");
			var t = k[1].split(":");
			return new Date(y[0],y[1] - 1,y[2],t[0],t[1],t[2]);
		}break;
		default:{
			throw "Invalid date format : " + s;
		}break;
		}
	}
	d.prototype["toString"] = function() {
		var date = this;
		var m = date.getMonth() + 1;
		var d1 = date.getDate();
		var h = date.getHours();
		var mi = date.getMinutes();
		var s = date.getSeconds();
		return date.getFullYear() + "-" + (m < 10?"0" + m:"" + m) + "-" + (d1 < 10?"0" + d1:"" + d1) + " " + (h < 10?"0" + h:"" + h) + ":" + (mi < 10?"0" + mi:"" + mi) + ":" + (s < 10?"0" + s:"" + s);
	}
	d.prototype.__class__ = d;
	d.__name__ = ["Date"];
}
{
	String.prototype.__class__ = String;
	String.__name__ = ["String"];
	Array.prototype.__class__ = Array;
	Array.__name__ = ["Array"];
	Int = { __name__ : ["Int"]};
	Dynamic = { __name__ : ["Dynamic"]};
	Float = Number;
	Float.__name__ = ["Float"];
	Bool = { __ename__ : ["Bool"]};
	Class = { __name__ : ["Class"]};
	Enum = { };
	Void = { __ename__ : ["Void"]};
}
{
	Math.__name__ = ["Math"];
	Math.NaN = Number["NaN"];
	Math.NEGATIVE_INFINITY = Number["NEGATIVE_INFINITY"];
	Math.POSITIVE_INFINITY = Number["POSITIVE_INFINITY"];
	Math.isFinite = function(i) {
		return isFinite(i);
	}
	Math.isNaN = function(i) {
		return isNaN(i);
	}
}
{
	js.Lib.document = document;
	js.Lib.window = window;
	onerror = function(msg,url,line) {
		var f = js.Lib.onerror;
		if( f == null )
			return false;
		return f(msg,[url+":"+line]);
	}
}
{
	js["XMLHttpRequest"] = window.XMLHttpRequest?XMLHttpRequest:window.ActiveXObject?function() {
		try {
			return new ActiveXObject("Msxml2.XMLHTTP");
		}
		catch( $e0 ) {
			{
				var e = $e0;
				{
					try {
						return new ActiveXObject("Microsoft.XMLHTTP");
					}
					catch( $e1 ) {
						{
							var e1 = $e1;
							{
								throw "Unable to create XMLHttpRequest object.";
							}
						}
					}
				}
			}
		}
	}:(function($this) {
		var $r;
		throw "Unable to create XMLHttpRequest object.";
		return $r;
	}(this));
}
Xml.enode = new EReg("^<([a-zA-Z0-9:_-]+)","");
Xml.ecdata = new EReg("^<!\\[CDATA\\[","i");
Xml.edoctype = new EReg("^<!DOCTYPE ","i");
Xml.eend = new EReg("^</([a-zA-Z0-9:_-]+)>","");
Xml.epcdata = new EReg("^[^<]+","");
Xml.ecomment = new EReg("^<!--","");
Xml.eprolog = new EReg("^<\\?[^\\?]+\\?>","");
Xml.eattribute = new EReg("^\\s*([a-zA-Z0-9:_-]+)\\s*=\\s*([\"'])([^\\2]*?)\\2","");
Xml.eclose = new EReg("^[ \r\n\t]*(>|(/>))","");
Xml.ecdata_end = new EReg("\\]\\]>","");
Xml.edoctype_elt = new EReg("[\\[|\\]>]","");
Xml.ecomment_end = new EReg("-->","");
haxe.Timer.arr = new Array();
js.Lib.onerror = null;
RunTime.urlBookinfo = "./data/bookinfo.xml";
RunTime.urlPageInfo = "./data/pages.xml";
RunTime.book = new core.Book();
RunTime.bookTop = 0;
RunTime.bookBottom = 48;
RunTime.bookLeft = 32;
RunTime.bookRight = 32;
Main.main()