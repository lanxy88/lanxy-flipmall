package ;

import core.AudioInfo;
import core.Book;
import core.ButtonInfo;
import core.DrawParams;
import core.HotLink;
import core.HighLight;
import core.Bookmark;
import core.Html5Image;
import core.Note;
import core.NoteIcon;
import core.HtmlHelper;
import core.Page;
import core.Slide;
import core.SlideshowInfo;
import core.VideoInfo;
import core.LangCfg;
import haxe.io.Bytes;
import haxe.Timer;
import haxe.web.Request;
import js.Lib;
import js.Dom;

import orc.utils.ImageMetricHelper;
import orc.utils.UrlParam;
import Xml;
import orc.utils.Util;
import StringTools;
import haxe.BaseCode;
import DOMParser;

/**
 * ...
 * @author 
 */

class RunTime 
{
	
	public static var sendService:XMLHttpRequest;
	public static var useGoogleUaAsLogViewer:Bool = true;
	public static var urlIndex:String = "html5forms.html";
	public static var urlZoom:String = "zoom.html";
	
	/** urls **/
	//public static var urlRoot:String = "E:\\MyWorkspace\\haXeWorkspace\\haXeFlip\\bin\\";
	public static var urlRoot:String = "";
	public static var urlBookinfo:String = urlRoot + "data/bookinfo.xml";
	public static var urlPageInfo:String = urlRoot +"data/pages.xml";
	public static var urlHotlinks:String =urlRoot + "data/hotlinks.xml";
	public static var urlContents:String = urlRoot +"data/contents.xml";
	public static var urlSearch:String =urlRoot + "data/search.xml";
	public static var urlVideos:String = urlRoot +"data/videos.xml";
	public static var urlButtons:String = urlRoot + "data/buttons.xml";
	public static var urlAudios:String = urlRoot + "data/sounds.xml";
	public static var urlBookmarks:String = urlRoot + "data/bookmarks.xml";
	public static var urlLang:String = urlRoot + "data/languages/languages.xml";
	
	public static var urlSlideshow:String = urlRoot +"data/slideshow.xml";
	
	public static var urlShareInfo:String = urlRoot +"data/share.xml";
	
	public static var searchHtmlCache:String = "";
	public static var inputHtmlCache:String = "";
	
	public static var isFullscreen:Bool = false;
	public static var resizeTimer:Timer = new Timer(600);
	
	
	/** xmldoc **/
	
	public static var bookInfo:Xml;
	public static var pageInfo:Xml;
	public static var hotlinkInfo:HtmlDom;
	public static var contentInfo:Xml;
	public static var shareInfo:Xml;
	public static var searchInfo:HtmlDom;
	public static var videoInfo:Xml;
	public static var audioInfo:Xml;
	public static var buttonInfo:Xml;
	public static var bookmarkInfo:Xml;
	public static var bgImageData:ImageData;
	
	public static var slideshow:HtmlDom;
	
	
	public static var bgImage:HtmlDom;
	
	public static var defaultScale:Float;
	
	public static var languages:Array<LangCfg> = new Array<LangCfg>();
	
	/** book **/
	public static var book:Book = new Book();
	
	public static var flipBook:FlipBook;
	public static var singlePage:Bool = false;
	
	/** params **/
	public static var clientWidth:Float;	// 窗口宽度
	public static var clientHeight:Float;	// 窗口高度
	
	public static var enablePreload:Bool;	// 是否预加载
	
	public static inline var bookTop:Float = 0;
	public static inline var bookBottom:Float = 0;
	public static inline var bookLeft:Float = 0;
	public static inline var bookRight:Float = 0;
	public static var pcode:String = "";
	
	public static var pageScale:Float;
	public static var imagePageWidth:Float;
	public static var imagePageHeight:Float;
	
	public static var defaultPageNum:Int;
	public static var divLoading:HtmlDom;
	
	public static var bottomBarAlpha:Float = 0.6;
	public static var bottomBarHeight:Float = 40;
	public static var autoflipButtonUnselectedAlpha:Float = 0.5;
	public static var doubleClickIntervalMs:Float = 300; // Click间隔时间低于这个时间算是双击。单位：ms
	public static var doubleZoomIntervalMs:Float = 1000; // 缩放间隔时间。单位：ms
	
	public static var highLights:Array<HighLight> = new Array<HighLight>();
	public static var currentHighLight:HighLight = null;
	
	public static var notes:Array<NoteIcon> = new Array<NoteIcon>();
	public static var currentNote:NoteIcon = null;

	public static var bLocked:Bool = true;
	/**
	 * 本地存储前缀
	 */
	public static var kvPrex:String = "";

	/** util methods **/
	public inline static function alert(msg:Dynamic):Void
	{
		Lib.alert(msg);
		
	}
	
	public static function init():Void
	{
		RunTime.kvPrex = Lib.window.location.pathname.split("?")[0];
		//Lib.alert(RunTime.kvPrex);
		//return;
		
		RunTime.clientWidth = Lib.window.document.body.clientWidth;
		RunTime.clientHeight = Lib.window.document.body.clientHeight;
		RunTime.defaultPageNum = Std.parseInt(Util.getUrlParam("page"));
		var dom:HtmlDom = Lib.document.getElementById("hiddenSearch");
		var html:String = dom.innerHTML;
		dom.innerHTML = "";
		RunTime.searchHtmlCache = html;
		dom = Lib.document.getElementById("hiddenInput");
		html = dom.innerHTML;
		dom.innerHTML = "";
		RunTime.inputHtmlCache = html;
		
		bgImage = Lib.document.getElementById("bgImage");
		
		RunTime.divLoading = Lib.document.getElementById("loading");
		RunTime.divLoading.style.top = (RunTime.clientHeight - divLoading.clientHeight) / 2 + "px";
		RunTime.divLoading.style.left  = (RunTime.clientWidth - divLoading.clientWidth) / 2 + "px";
		RunTime.divLoading.style.display = "inline";
		
		RunTime.resizeTimer.run = RunTime.OnResize;
		
		Lib.window.document.body.onresize = RunTime.msOnResize;
		
		//预计加载BookInfo
		preRequestBookInfo();
		
	}
	
	private static function msOnResize(e):Void {
		
		if (Lib.document.body.clientHeight == Lib.window.screen.height
			&& Lib.document.body.clientWidth == Lib.window.screen.width) {
			//fullscreen	
			trace("fullscreen");
			if(RunTime.resizeTimer != null) RunTime.resizeTimer.stop();
			RunTime.isFullscreen =  true;
			
		}
		else {
			
			trace("exit fullscreen");
			RunTime.isFullscreen = false;
			if(RunTime.resizeTimer != null) RunTime.resizeTimer.stop();
			RunTime.resizeTimer = new Timer(600);
			RunTime.resizeTimer.run = RunTime.OnResize;
		}
		
	}
	
	private static function onFullscreenChange(e:Event):Void {
		var obj:Dynamic = e;
		
		trace(e);
	}
	
	private static function OnResize( ):Void
	{
		if (RunTime.isFullscreen) return;
		
		if (RunTime.clientWidth != Lib.window.document.body.clientWidth 
		|| RunTime.clientHeight != Lib.window.document.body.clientHeight) {
			RunTime.reload();
		}
	}
	
	private static function loadState():Void
	{
		var bbv:Bool = true;
		var params:Array <UrlParam>  = Util.getUrlParams();
		for (i in 0 ... params.length)
		{
			var item:UrlParam = params[i];
			if (item.key == "page")
			{
				var num:Int = Std.parseInt(item.value);
				defaultPageNum = num;
			}
			else if (item.key == "bbv") // bottom bar visible
			{
				if (item.value == "1")
				{
					bbv = true;
				}
				else if(item.value == "0")
				{
					bbv = false;
				}
			}
			else if (item.key == "pcode")
			{
				pcode = item.value;
			}
		}
		
		if (bbv == true)
		{
			RunTime.flipBook.showBottomBar();			
		}
		else
		{
			RunTime.flipBook.hideBottomBar(null,false);
		}
		
		//if (RunTime.book.rightToLeft) RunTime.flipBook.turnToLastPage(null);
	}
	
	private static var key:String = "";
	
	public static function requestLanguages(callbackFunc:Void->Void = null):Void
	{
		Util.request(urlLang, function(data:String):Void
		{
			var xml:Xml = Xml.parse(data);
			
			var i:Iterator<Xml> = xml.elementsNamed("languages");
			if (i.hasNext() == false) return;
			xml = i.next();
			i = xml.elementsNamed("language");
			if (i.hasNext() == false) return;
			var dftLang:LangCfg = null;
			while (i.hasNext() == true)
			{
				var node:Xml = i.next();
				var lang:LangCfg = new LangCfg();
				var cnt:String = node.get("content");
				var dft:String = node.get("default");
				if (dftLang == null) dftLang = lang;
				lang.content = cnt;
				
				if (dft == "yes" || dft == "Yes" || dft == "YES")
				{
					lang.isDefault = true;
					dftLang = lang;
				}
				RunTime.languages.push(lang);
			}
			
			if (dftLang != null)
			{
				var urlLangResource:String = urlRoot + "data/languages/" + dftLang.content + ".xml";
				L.loadRemote(urlLangResource,callbackFunc,callbackFunc);
			}
			else
			{
				callbackFunc();
			}
		},
		callbackFunc
		);
	}
	
	public static function preRequestBookInfo():Void {
		Util.request(urlBookinfo,
			function(data:String):Void
			{
				bookInfo = Xml.parse(data);
				
				getBookInfo();

				if (book.singlepageMode) {
					//Lib.alert(book.singlepageMode);
					RunTime.flipBook = new FlipBook();
					RunTime.singlePage = true;
				}
				else{
					if (RunTime.clientHeight > RunTime.clientWidth)
					{
						// 单页机制
						RunTime.flipBook = new FlipBook();
						RunTime.singlePage = true;
					}
					else
					{
						// 双页机制
						RunTime.flipBook = new DoubleFlipBook();
						RunTime.singlePage = false;
					}
				}
				
				// 单页机制
				//RunTime.flipBook = new FlipBook();

				RunTime.flipBook.zoom = Lib.document.getElementById("zoom");
				
				var bookleftpage:Dynamic = Lib.document.getElementById("leftpage");
				RunTime.flipBook.zoomLeftPage = bookleftpage;
				var bookrightpage:Dynamic = Lib.document.getElementById("rightpage");
				RunTime.flipBook.zoomRightPage = bookrightpage;
				
				var leftPageLock:Dynamic = Lib.document.getElementById("leftPageLock");
				var rightPageLock:Dynamic = Lib.document.getElementById("rightPageLock");
				RunTime.flipBook.leftPageLock = leftPageLock;
				RunTime.flipBook.rightPageLock = rightPageLock;
				
				var leftLockIcon:Dynamic = Lib.document.getElementById("leftLockIcon");
				var rightLockIcon:Dynamic = Lib.document.getElementById("rightLockIcon");
				RunTime.flipBook.leftLockIcon = leftLockIcon;
				RunTime.flipBook.rightLockIcon = rightLockIcon;
				
				
				RunTime.flipBook.root = Lib.document.getElementById("cvsBook");
				RunTime.flipBook.mask = Lib.document.getElementById("mask");
				RunTime.flipBook.tbPageCount = Lib.document.getElementById("tbPageCount");
				RunTime.flipBook.tbPage = Lib.document.getElementById("tbPage");
				RunTime.flipBook.btnContents = Lib.document.getElementById("btnContents");
				RunTime.flipBook.btnThumbs = Lib.document.getElementById("btnThumbs");
				RunTime.flipBook.btnSearch = Lib.document.getElementById("btnSearch");
				
				RunTime.flipBook.btnMask = Lib.document.getElementById("btnMask");
				RunTime.flipBook.btnBookMark = Lib.document.getElementById("btnBookMark");
				RunTime.flipBook.btnNote = Lib.document.getElementById("btnNote");
				
				
				RunTime.flipBook.btnPrevPage = Lib.document.getElementById("btnPrevPage");
				RunTime.flipBook.btnNextPage = Lib.document.getElementById("btnNextPage");
				RunTime.flipBook.btnFirstPage = Lib.document.getElementById("btnFirstPage");
				RunTime.flipBook.btnLastPage = Lib.document.getElementById("btnLastPage");
				RunTime.flipBook.btnAutoFlip = Lib.document.getElementById("btnAutoFlip");
				RunTime.flipBook.btnDownload = Lib.document.getElementById("btnDownload");
				RunTime.flipBook.btnEmail = Lib.document.getElementById("btnEmail");
				RunTime.flipBook.btnSns = Lib.document.getElementById("btnSns");
				RunTime.flipBook.btnShowTxt = Lib.document.getElementById("btnShowTxt");
				RunTime.flipBook.imgLogo = Lib.document.getElementById("imgLogo");
				RunTime.flipBook.topBar = Lib.document.getElementById("topBar");
				RunTime.flipBook.topBarContent = Lib.document.getElementById("topBarContent");
				RunTime.flipBook.topFullTextContent = Lib.document.getElementById("topFullTextContent");
				RunTime.flipBook.bottomBar = Lib.document.getElementById("bottomBar");
				//RunTime.flipBook.bottomBar.style.bottom = "-49px";
				RunTime.flipBook.bottomBarBg = Lib.document.getElementById("bottomBarBg");
				RunTime.flipBook.bottomBarBg.style.opacity = RunTime.bottomBarAlpha;
				
				RunTime.flipBook.topMenuBar = Lib.document.getElementById("topMenuBar");
				RunTime.flipBook.topMenuBarBg = Lib.document.getElementById("topMenuBarBg");
				RunTime.flipBook.topMenuBarBg.style.opacity = RunTime.bottomBarAlpha;
				
				RunTime.flipBook.topBarContent.style.zIndex = 100;
				
				RunTime.flipBook.menuParent = Lib.document.getElementById("menuParent");
				RunTime.flipBook.maskPopup = Lib.document.getElementById("maskPopup");
				RunTime.flipBook.cvsSlideshow = Lib.document.getElementById("cvsSlideshow");
				RunTime.flipBook.cvsVideo = Lib.document.getElementById("cvsVideo");
				RunTime.flipBook.cvsOthers = Lib.document.getElementById("cvsOthers");
				RunTime.flipBook.cvsAudio = Lib.document.getElementById("cvsAudio");
				RunTime.flipBook.cvsLeftPageBgAudio = Lib.document.getElementById("cvsLeftPageBgAudio");
				RunTime.flipBook.cvsRightPageBgAudio = Lib.document.getElementById("cvsRightPageBgAudio");
				RunTime.flipBook.cvsYoutube = Lib.document.getElementById("cvsYoutube");
				RunTime.flipBook.btnZoom = Lib.document.getElementById("btnZoom");
				var left:Int = Std.int((RunTime.clientWidth - 500) / 2);
				RunTime.flipBook.topBar.style.left = Std.string(left) + "px";
				var c:Dynamic  = RunTime.flipBook.root;
				RunTime.flipBook.canvas = c;
				RunTime.flipBook.attachActions();
				c.width = RunTime.clientWidth;
				c.height = RunTime.clientHeight;
				
				//RunTime.flipBook.cvsVideo.style.width = RunTime.clientWidth + "px";
				//RunTime.flipBook.cvsVideo.style.height = RunTime.clientHeight + "px";
				
				if(RunTime.clientWidth < 800){
					Lib.document.getElementById("btnFirstPage").style.marginLeft = "10px";
					Lib.document.getElementById("btnPrevPage").style.marginLeft = "10px";
					Lib.document.getElementById("btnNextPage").style.marginLeft = "10px";
					Lib.document.getElementById("btnLastPage").style.marginLeft = "10px";
				}
				
				var cvsButton:Dynamic = Lib.document.getElementById("cvsButton");
				RunTime.flipBook.cvsButton = cvsButton;
				//TODO:监听点击事件
				//............
				cvsButton.width = RunTime.clientWidth;
				cvsButton.height = RunTime.clientHeight;
				
				var cvsHighLight:Dynamic = Lib.document.getElementById("cvsHighLight");
				RunTime.flipBook.cvsHighLight = cvsHighLight;
				cvsHighLight.width = RunTime.clientWidth;
				cvsHighLight.height = RunTime.clientHeight;
				
				
				var cvsNote:Dynamic = Lib.document.getElementById("cvsNote");
				RunTime.flipBook.cvsNote = cvsNote;
				cvsNote.width = RunTime.clientWidth;
				cvsNote.height = RunTime.clientHeight;
				
				var cvsBookmark:Dynamic = Lib.document.getElementById("cvsBookmark");
				RunTime.flipBook.cvsBookmark = cvsBookmark;
				cvsBookmark.width = RunTime.clientWidth;
				cvsBookmark.height = RunTime.clientHeight;	
				
				
				RunTime.flipBook.zoom.style.width = RunTime.clientWidth +"px";
				RunTime.flipBook.zoom.style.height = RunTime.clientHeight +"px";
				
				RunTime.flipBook.afterInit();
				RunTime.flipBook.bookContext.ctx = RunTime.flipBook.getContext();
				RunTime.flipBook.bookContext.ctxButton = RunTime.flipBook.getButtonContext();
				RunTime.flipBook.bookContext.ctxHighLight = RunTime.flipBook.getHighLightContext();
				RunTime.flipBook.bookContext.ctxNote = RunTime.flipBook.getNoteContext();
				RunTime.flipBook.bookContext.ctxBookmark = RunTime.flipBook.getBookmarkContext();
				RunTime.requestLanguages(RunTime.requestBookInfo);
				//RunTime.requestBookInfo();
		
				
			});
		
	}
	
	/**
	 * 请求BookInfo信息
	 */
	public static function requestBookInfo():Void
	{
		Util.request(urlBookinfo,
			function(data:String):Void
			{
				bookInfo = Xml.parse(data);
				
				loadBookInfo();
				
				key = calcKey(Std.int(book.pageWidth), Std.int(book.pageHeight));
				
				var defaultKey:String = "Pwd-Empty";
				if (RunTime.pcode.length > 0)
				{
					defaultKey = decode64(RunTime.pcode);
				}
				var encode:String =  RunTime.encryptKey(defaultKey, key);
				
				if (encode == book.password)
				{
					if (encode == book.password &&  RunTime.pcode.length > 0) {
						
						RunTime.bLocked = false;
					}
					afterRequestBookInfo();
				}
				else if (RunTime.book.lockPages != null) {
					if (book.lockPages.length > 0) {
						if (encode == book.password &&  RunTime.pcode.length > 0) {
						
						RunTime.bLocked = false;
					}
					afterRequestBookInfo();
					}
				}
				else
				{
					InputPwd();
					//RunTime.showPopupMaskLayer();
					//RunTime.flipBook.cvsOthers.innerHTML = HtmlHelper.toInputPwdHtml();
				}
				//double flipbook ad
				if (!singlePage) {
					flipBook.requestMainAd();
				}
			});
	}
	
	public static function InputPwd():Void {
		RunTime.showPopupMaskLayer();
		RunTime.flipBook.cvsOthers.innerHTML = HtmlHelper.toInputPwdHtml();
	}
	
	public static function InputUnlock():Void {
		RunTime.showPopupMaskLayer();
		RunTime.flipBook.cvsOthers.innerHTML = HtmlHelper.toInputUnlockPwdHtml();
	}
	
	public static function tryPwd(pwd:String):Void
	{
		var encode:String =  RunTime.encryptKey(pwd, key);
		if (encode == book.password)
		{
			RunTime.pcode = StringTools.urlEncode(encode64(pwd, false));
			afterRequestBookInfo();
		}
		else
		{
			Lib.window.alert(L.s("PasswordError"));
		}
	}
	
	public static function tryUnlock(pwd:String):Void
	{
		var encode:String =  RunTime.encryptKey(pwd, key);
		if (encode == book.password)
		{
			RunTime.pcode = StringTools.urlEncode(encode64(pwd, false));
			//afterRequestBookInfo();
			Lib.document.getElementById("inputBox").style.display = "none";
			RunTime.clearPopupContents();
			RunTime.bLocked = false;
			RunTime.flipBook.leftPageLock.style.display = "none";
			RunTime.flipBook.rightPageLock.style.display = "none";
			RunTime.flipBook.bookContext.render();
		}
		else
		{
			Lib.window.alert(L.s("PasswordError"));
		}
	}
	
	private static function afterRequestBookInfo():Void
	{
		RunTime.flipBook.cvsOthers.innerHTML = "";
		clearPopupContents();
		requestPages();
		useAnalyticsUA(book.analyticsUA, book.bookId);
	}
	
	public static function requestPages():Void
	{
		
		Util.request(urlPageInfo,
			function(data:Dynamic):Void
			{
				pageInfo = Xml.parse(data);
				
				loadPageInfo();
				requestHotlinks();
				requestSlideshow();
				requestContents();
				requestShare();
				requestVideos();
				reauestAudios();
				requestButtons();
				readLocalHighLights();
				readLocalNotes();
				requestBookmark();
				readLocalBookmarks();
			});
	}

	public static function requestSlideshow(onSuccess:Void->Void = null):Void
	{
		Util.request(urlSlideshow,
			function(data:Dynamic):Void
			{
				var dom:DOMParser = new DOMParser();
				var ctx:Xml2Html = new Xml2Html();
				slideshow = dom.parseFromString(ctx.prepareXmlAsHtml(data),"text/xml");
				loadSlideshow(ctx);
				if (RunTime.flipBook != null)
				{
					RunTime.flipBook.loadCtxSlideshow();
					RunTime.flipBook.bookContext.render();
				}
				if (onSuccess != null) onSuccess();
			});
	}
	
	public static function requestHotlinks(onSuccess:Void->Void = null):Void
	{
		Util.request(urlHotlinks,
			function(data:Dynamic):Void
			{
				var dom:DOMParser = new DOMParser();
				var ctx:Xml2Html = new Xml2Html();
				hotlinkInfo = dom.parseFromString(ctx.prepareXmlAsHtml(data),"text/xml");
				loadHotlinks(ctx);
				if (RunTime.flipBook != null)
				{
					RunTime.flipBook.loadCtxHotlinks();
					RunTime.flipBook.bookContext.render();
				}
				if (onSuccess != null) onSuccess();
			});
	}
	
	public static function requestVideos(onSuccess:Void->Void = null):Void
	{
		Util.request(urlVideos,
			function(data:Dynamic):Void
			{
				videoInfo = Xml.parse(data);
				loadVideos();
				if (RunTime.flipBook != null)
				{
					RunTime.flipBook.updateVideos();
					RunTime.flipBook.bookContext.render();
				}
				if (onSuccess != null) onSuccess();
			});
	}
	
	public static function reauestAudios(onSuccess:Void->Void = null):Void
	{
		Util.request(urlAudios,
			function(data:Dynamic):Void
			{
				audioInfo = Xml.parse(data);
				loadAudios();
				if (RunTime.flipBook != null)
				{
					RunTime.flipBook.updateAudios();
				}
				if (onSuccess != null) onSuccess();
			});
	}
	
	public static function requestButtons(onSuccess:Void->Void = null):Void
	{
		
		Util.request(urlButtons,
			function(data:Dynamic):Void
			{
				buttonInfo = Xml.parse(data);
				loadButtons();
				if (RunTime.flipBook != null)
				{
					RunTime.flipBook.loadCtxButtons();
					RunTime.flipBook.bookContext.render();
				}
				if (onSuccess != null) onSuccess();
			});
	}
	
	public static function requestContents():Void
	{
		Util.request(urlContents,
			function(data:Dynamic):Void
			{
				contentInfo = Xml.parse(data);
			});
	}
	
	public static function requestShare():Void {
		Util.request(urlShareInfo,
		function(data:Dynamic):Void {
			shareInfo = Xml.parse(data);
		});
	}
	
	public static function requestSearch(invoke:Array<Page>->Void ):Void
	{
		Util.request(urlSearch,
			function(data:Dynamic):Void
			{
				var dom:DOMParser = new DOMParser();
				var ctx:Xml2Html = new Xml2Html();
				searchInfo = dom.parseFromString(ctx.prepareXmlAsHtml(data), "text/xml");
				loadPageContents(ctx);
				if (invoke != null)
				{
					invoke(book.pages);
				}
			});
	}
	
	//bookmarkInfo
	public static function requestBookmark():Void
	{
		Util.request(urlBookmarks,
			function(data:Dynamic):Void
			{
				bookmarkInfo = Xml.parse(data);
				var it:Iterator<Xml> = bookmarkInfo.firstElement().elementsNamed("bookmark");		
				do {
					var node:Xml = it.next();
					if (node == null) break;
					//Lib.alert(node);
					var bk:Bookmark = new Bookmark();
					bk.pageNum = untyped node.get("page");
					bk.text = node.get("content");
					bk.onlyread = true;
					book.bookmarks.push(bk);				
					
				}while (it.hasNext());
				
				//Lib.alert(book.bookmarks.length);
				
			});
	}
	
	public static function invokePageContentsAction(invoke:Array<Page>->Void ):Void
	{
		if (searchInfo == null)
		{
			requestSearch(invoke);
		}
		else
		{
			invoke(book.pages);
		}
	}
	
	private static function loadPageContents(ctx:Xml2Html):Void
	{
		if (searchInfo == null) return;
		
		var dom:HtmlDom = searchInfo;
		var pages:HtmlCollection<HtmlDom> = dom.getElementsByTagName("page");
		for (i in 0 ... pages.length)
		{
			var node:HtmlDom = pages[i];
			var pageNumVal:String = node.getAttribute("pageNumber");
			var htmlText:String = null;
			var htmlTextDoms:HtmlCollection<HtmlDom> = node.getElementsByTagName("cdata");
			if (htmlTextDoms != null && htmlTextDoms.length > 0)
			{
				htmlText = StringTools.trim(htmlTextDoms[0].childNodes[0].nodeValue);
				htmlText = ctx.getCData(htmlText);
			}
			
			for (k in 0 ... book.pages.length)
			{
				var page:Page = book.pages[k];
				if (page.id == pageNumVal)
				{
					page.content = htmlText;
				}
			}
		}
	}
	
	public static function reload():Void
	{
		Lib.window.location.href = RunTime.flipBook.getFullUrl();
	}
	
	public static function navigateUrl(url:String):Void {
		
		if (url == null || url == "null" || url == "") return ;
		Lib.window.location.href = url;
	}
	
	private static function getBookInfo():Void {
		if (bookInfo == null) return;
		
		var i:Iterator<Xml> = bookInfo.elementsNamed("bookinfo");
		if (i.hasNext() == false) return;
		
		// 获取pageWidth节点
		var node:Xml = i.next();
		
		book.singlepageMode =  node.get("singlepageMode") == "true" ? true : false;
		book.rightToLeft =  node.get("rightToLeft") == "true" ? true : false;
		
		book.autoFlipSecond = Std.parseInt( node.get("autoFlipSeconds"));
		
		book.gateway = node.get("gateway");
		
		book.shareHref = node.get("shareUrl");
	}
	
	private static function loadBookInfo():Void
	{
		if (bookInfo == null) return;
		
		var i:Iterator<Xml> = bookInfo.elementsNamed("bookinfo");
		if (i.hasNext() == false) return;
		
		// 获取pageWidth节点
		var node:Xml = i.next();
		
		var idVal:String = node.get("id");
		if (idVal == null) idVal = "";
		book.bookId = idVal;
		book.bookTitle = node.get("title");
		book.bgColor = node.get("bgColor");
		book.bgImageUrl = node.get("bgImage");
		book.analyticsUA = node.get("analyticsUA");
		book.password = node.get("password");
		book.bookDownloadUrl = node.get("pdfUrl");
		
		var locked:String = node.get("protectedPages");
		if (locked != null && locked != "") {
			book.lockPages =  locked.split(",");
		}
		//book.lockPages
		
		//book.singlepageMode =  node.get("singlepageMode") == "true" ? true : false;
		//book.rightToLeft  =  node.get("rightToLeft") == "true" ? true : false;
		if (book.bgColor == "" || book.bgColor == null)
		{
			book.bgColor = "gray";
		}
		//book.bgColor = "blue";

		if (book.bgColor != "" && book.bgColor != null)
		{
			Lib.document.body.style.backgroundColor = book.bgColor;
			
			//RunTime.flipBook.zoomCSS =  "margin:0; padding:0; overflow:auto; height:100%;background-color:" + book.bgColor+";";
		}
		
		if (book.bgImageUrl != "" && book.bgImageUrl != null)
		{
			
			
			Lib.document.body.style.backgroundImage = "url(" + book.bgImageUrl + ")";
			Lib.document.body.style.backgroundRepeat = "no-repeat";
			Lib.document.body.style.backgroundPosition = "center";
			Lib.document.body.style.backgroundSize = "cover";
			Lib.document.body.style.backgroundClip = "border-box";
			
		}
		
		Lib.window.document.title = book.bookTitle;
		
		// 获取页宽和页高
		var pageWidth:Float = Std.parseFloat(node.get("pageWidth"));
		var pageHeight:Float = Std.parseFloat(node.get("pageHeight"));
		book.pageWidth = pageWidth;
		book.pageHeight = pageHeight;
		
		
		var m:ImageMetricHelper = new ImageMetricHelper(pageWidth, pageHeight);
		var w:Float = RunTime.clientWidth - RunTime.bookLeft - RunTime.bookRight;
		var h:Float = RunTime.clientHeight - RunTime.bookTop - RunTime.bookBottom;
		var scale:Float = m.getMaxFitScale(w, h);
		RunTime.defaultScale = scale;
		imagePageWidth = pageWidth*scale;
		imagePageHeight = pageHeight * scale;
		pageScale = scale;
		
		var li:Iterator<Xml> = node.elementsNamed("bookLogo");
		if (li.hasNext() == true)
		{
			var lnode:Xml = li.next();
			book.logoUrl = lnode.get("url");
			book.logoHref = lnode.get("href");
		}
		
		if (book.logoUrl != null && book.logoUrl != "" )
		{
			//android 小屏幕手机不显示logo
			var hideLogo:Bool = false;
			if (RunTime.clientWidth < 600) hideLogo = true;
			if (Lib.window.navigator.userAgent.indexOf("iPhone") != -1)  hideLogo = true;
			//iPhone下不显示logo
			if (!hideLogo) {
				flipBook.imgLogo.style.display = "inline";
				var obj:Dynamic = flipBook.imgLogo;
				obj.src = book.logoUrl;
				flipBook.imgLogo.onclick = RunTime.onLogoClick;
			}
		}
		
		flipBook.btnDownload.onclick = RunTime.onDownloadClick;
		
		var bottomMenuIter:Iterator<Xml> = node.elementsNamed("bottommenu");
		if (bottomMenuIter.hasNext() == true)
		{
			var bottomMenuNode:Xml = bottomMenuIter.next();
			book.menuAutoFlipVisible = getMenuVisible(bottomMenuNode, "autoflip");
			book.menuSearchVisible = getMenuVisible(bottomMenuNode, "search");
			book.menuTxtVisible = getMenuVisible(bottomMenuNode, "txt");
			book.menuZoomVisible = getMenuVisible(bottomMenuNode, "zoom");
			book.menuBookmarkVisible =  getMenuVisible(bottomMenuNode, "bookmark");
			book.menuNoteVisible = getMenuVisible(bottomMenuNode, "notes");
			book.menuHighlightVisible = getMenuVisible(bottomMenuNode, "highlight");
		}
		
		var leftMenuIter:Iterator<Xml> = node.elementsNamed("leftmenu");
		if (leftMenuIter.hasNext() == true)
		{
			var leftMenuNode:Xml = leftMenuIter.next();
			book.menuTocVisible = getMenuVisible(leftMenuNode, "toc");
			book.menuThumbsVisible = getMenuVisible(leftMenuNode, "thumbs");
			book.menuDownloadVisible = getMenuEntirePDF(leftMenuNode, "pdf");
			book.menuEmailVisible = getMenuVisible(leftMenuNode, "email");
			book.menuSnsVisible = getMenuVisible(leftMenuNode, "sns");
		}
		
		setMenuVisible(RunTime.flipBook.btnContents, book.menuTocVisible);
		setMenuVisible(RunTime.flipBook.btnThumbs, book.menuThumbsVisible);
		setMenuVisible(RunTime.flipBook.btnSearch, book.menuSearchVisible);
		setMenuVisible(RunTime.flipBook.btnAutoFlip, book.menuAutoFlipVisible);
		setMenuVisible(RunTime.flipBook.btnShowTxt, book.menuTxtVisible);
		setMenuVisible(RunTime.flipBook.btnZoom, false/* book.menuZoomVisible*/);
		
		setMenuVisible(RunTime.flipBook.btnDownload, book.menuDownloadVisible);
		setMenuVisible(RunTime.flipBook.btnEmail, book.menuEmailVisible);
		setMenuVisible(RunTime.flipBook.btnSns, book.menuSnsVisible);
		
		
		var menuCount:Int = 0;
		if (book.menuTocVisible) menuCount += 1;
		if (book.menuThumbsVisible) menuCount += 1;
		if (book.menuSearchVisible) menuCount += 1;
		if (book.menuAutoFlipVisible) menuCount += 1;
		if (book.menuTxtVisible) menuCount += 1;
		
		var hideIcon:Bool = false;
		if (RunTime.clientWidth < 480) hideIcon = true;
		//Lib.alert(RunTime.clientWidth);
		if (Lib.window.navigator.userAgent.indexOf("iPhone") != -1 && RunTime.clientWidth < 480)  hideIcon = true;
			
		if (hideIcon) {
			if (menuCount < 5) {
				setMenuVisible(RunTime.flipBook.btnMask, book.menuHighlightVisible);
				
			}
			if (book.menuHighlightVisible) menuCount += 1;
			if (menuCount < 5) {
				setMenuVisible(RunTime.flipBook.btnNote, book.menuNoteVisible);
				menuCount += 1;
			}
			if (book.menuNoteVisible) menuCount += 1;
			if (menuCount < 5) {
				setMenuVisible(RunTime.flipBook.btnBookMark, book.menuBookmarkVisible);
				menuCount += 1;
			}
		}
		else {
			setMenuVisible(RunTime.flipBook.btnMask, book.menuHighlightVisible);
			setMenuVisible(RunTime.flipBook.btnNote, book.menuNoteVisible);
			setMenuVisible(RunTime.flipBook.btnBookMark, book.menuBookmarkVisible);
		}
		
		
		
		loadState();
	}
	
	private static function setMenuVisible(menu:HtmlDom, visible:Bool):Void
	{
		if (visible == true)
		{
			menu.style.display = "inline";
		}
		else
		{
			RunTime.flipBook.menuParent.removeChild(menu);
		}
	}
	
	private static function getMenuVisible(parent:Xml, nodeName:String):Bool
	{
		var li:Iterator<Xml> = parent.elementsNamed(nodeName);
		if (li.hasNext() == true)
		{
			var lnode:Xml = li.next();
			if (lnode.get("visible") == "false") return false;
		}
		return true;
	}
	
	private static function getMenuEntirePDF(parent:Xml, nodeName:String):Bool
	{
		
		var li:Iterator<Xml> = parent.elementsNamed(nodeName);
		if (li.hasNext() == true)
		{
			var lnode:Xml = li.next();
			
			if (lnode.get("entirePDF") == "true") {
				
				return true;
			}
		}
		return false;
	}
	
	private static function onLogoClick(e:Event):Void
	{
		if (RunTime.book == null || RunTime.book.logoHref == null || RunTime.book.logoHref == "")
		{
			return;
		}
		
		Lib.window.location.href = RunTime.book.logoHref;
	}
	
	public static function onDownloadClick(e:Event):Void {
		
		if (RunTime.book == null || RunTime.book.bookDownloadUrl == null || RunTime.book.bookDownloadUrl == "")
		{
			return;
		}
		Lib.window.location.href = RunTime.book.bookDownloadUrl;
	}
	
	public static function onSendEmail():Void {
		sendEmailByService();		
		//sendEmailByForm();
	}
	
	public static function sendEmailResult():Void {
		
		if (sendService.responseText.length < 2) {
			Lib.alert(L.s("EmailSendSuccessful"));
			var tomail:Dynamic = Lib.window.document.getElementById("tomail");
			tomail.value = "";
			var frommail:Dynamic = Lib.window.document.getElementById("youremail");
			frommail.value = "";
			var n:Dynamic = Lib.window.document.getElementById("yname");
			n.value = "";
			var m:Dynamic = Lib.window.document.getElementById("sharemsg");
			m.value = "";
			
		}
		else {
			Lib.alert(L.s("EmailSendFailed"));
		}
		//sendService.responseText
	}
	
	public static function sendEmailByService():Void {
		
		var baseUrl:String = Lib.window.location.href.split("?")[0];
		baseUrl = baseUrl.substring(0, baseUrl.lastIndexOf("/"));
		//Lib.alert( baseUrl);
		//Lib.alert( RunTime.book.pages[0].urlThumb);
	
		var tomail:Dynamic = Lib.window.document.getElementById("tomail");
		var frommail:Dynamic = Lib.window.document.getElementById("youremail");
		var n:Dynamic = Lib.window.document.getElementById("yname");
		var subject:String = L.s("YourFriend", "YourFirend") + n.value +	
			L.s("ShareEmailTitle", "ShareEmailTitle");
		Lib.window.document.getElementById("subject").setAttribute("value", subject);
		var m:Dynamic = Lib.window.document.getElementById("sharemsg");
		var msg:String = m.value;
		msg += "<br /> <br /> " + n.value + L.s("ShareEmailContent")
					+ "<a href='" + RunTime.book.shareHref + "' target='_black'>"+ RunTime.book.shareHref +"<a/>"
					+ "<br /> <br />" +"<a href='" + RunTime.book.shareHref + "' target='_black'>" +
					"<img src='" + baseUrl +"/" + RunTime.book.pages[0].urlThumb + "' >" +"<a/>";
		sendService = new XMLHttpRequest();
			
		var query:String = "tomail=" + tomail.value + "&frommail=" + frommail.value + 
						   "&subject=" + subject + "&message=" + msg;
		sendService.open("get", RunTime.book.gateway+"?"+query, true);
		sendService.onreadystatechange = RunTime.sendEmailResult ;
		sendService.send();
		
	}
	/**
	 * 普通的Form 提交
	 */
	public static function sendEmailByForm():Void {
		var n:Dynamic = Lib.window.document.getElementById("yname");
		var subject:String = L.s("YourFriend", "YourFirend") +  
			n.value +	
			L.s("ShareEmailTitle", "ShareEmailTitle");
		Lib.window.document.getElementById("subject").setAttribute("value", subject);
		var m:Dynamic = Lib.window.document.getElementById("sharemsg");
		var msg:String = m.value;
		msg += "<br /> <br /> " + n.value + L.s("ShareEmailContent")
					+ "<a href='" + RunTime.book.shareHref + "' target='_black'>"+ RunTime.book.shareHref +"<a/>"
					+ "<br /> <br />" +"<a href='" + RunTime.book.shareHref + "' target='_black'>" +
					"<img src='" + RunTime.book.pages[0].urlThumb + "' >" +"<a/>";
		var b:Dynamic = Lib.window.document.getElementById("sendEmail");
		b.submit();
	}
	
	private static function loadPageInfo():Void
	{
		
		if (pageInfo == null) return;
		var root:Xml = pageInfo.firstElement();
		var val:String = root.get("preload");
		
		if (val.toLowerCase() == "true")
		{
			enablePreload = true;
		}
		
		var i:Iterator<Xml> = root.elementsNamed("page");
		var num:Int = 0;
		var numDouble:Float = 0.1;
		while (i.hasNext() == true)
		{
			var node:Xml = i.next();
			var id:String = node.get("id");
			var source:String = node.get("source");
			var medium:String = node.get("medium");
			var thumb:String = node.get("thumb");
			var canZoom:Bool = !(node.get("canZoom") == "false");
			
			var page:Page = new Page();
			RunTime.book.pages.push(page);
			
			if (medium == null || medium == "")
			{
				
				medium = "content/medium/page" + Std.string(num + 1) + ".jpg";

			}
			
			page.id = id;
			page.num = num;
			page.numInDoubleMode = Std.int(Math.round(numDouble));
			page.urlPage = medium;
			page.urlBigPage = source;
			page.urlThumb = thumb;
			page.urlFullPage = source;
			page.canZoom = canZoom;
			page.locked = checkLocked(num+1);
			//trace("page.id=" + num + ", locked=" + page.locked);
			numDouble += 0.5;
			num++;
		}
		
		RunTime.flipBook.setPageCount(RunTime.book.pages.length);
	
		RunTime.flipBook.setCurrentPage(RunTime.defaultPageNum + 1);
		RunTime.flipBook.loadPage(RunTime.defaultPageNum);
	
	}
	
	private static function checkLocked(num:Int):Bool {
		if (RunTime.book.lockPages == null || RunTime.book.lockPages.length == 0) return false;
		for (i in 0 ... RunTime.book.lockPages.length) {
			if (Std.parseInt(RunTime.book.lockPages[i]) == num) return true;
		}
		return false;
	}
	
	private static function loadSlideshow(ctx:Xml2Html):Void
	{
		if (slideshow == null) return;
		var dom:HtmlDom = slideshow;
		var slides:HtmlCollection<HtmlDom> = dom.getElementsByTagName("slideshow");
		for (i in 0 ... slides.length)
		{
			var node:HtmlDom = slides[i];
			var pageNumVal:String = node.getAttribute("page");
			var xVal:String =  node.getAttribute("x");
			var yVal:String =  node.getAttribute("y");
			var widthVal:String =  node.getAttribute("width");
			var heightVal:String =  node.getAttribute("height");
			var timeVal:String =  node.getAttribute("time");
			var transitionVal:String =  node.getAttribute("transition");
			var idVal:String = node.getAttribute("sid");
			var bgColorVal:String  =  node.getAttribute("bgColor");
			var slideshowInfo:SlideshowInfo = new SlideshowInfo();
			
			var pics:HtmlCollection<HtmlDom> = node.getElementsByTagName("pic");
			for (j in 0 ... pics.length)
			{
				var pnode:HtmlDom = pics[j];
				var slide:Slide = new Slide();
				
				slide.url = pnode.getAttribute("url");
				slide.href = pnode.getAttribute("href");
				slideshowInfo.slides.push(slide);
			}
			
			slideshowInfo.pageNum = Std.parseInt(pageNumVal)-1;
			slideshowInfo.x = Std.parseFloat(xVal);
			slideshowInfo.y = Std.parseFloat(yVal);
			slideshowInfo.width = Std.parseFloat(widthVal);
			slideshowInfo.height = Std.parseFloat(heightVal);
			slideshowInfo.interval = timeVal;
			slideshowInfo.transition = transitionVal;
			slideshowInfo.id = idVal;
			slideshowInfo.bgColor = bgColorVal;
			
			book.slideshows.push(slideshowInfo);
		}
		
		//Lib.alert(book.slideshows);
	}
	
	private static function loadHotlinks(ctx:Xml2Html):Void
	{
		if (hotlinkInfo == null) return;
		var dom:HtmlDom = hotlinkInfo;
		var links:HtmlCollection<HtmlDom> = dom.getElementsByTagName("hotlink");
		for (i in 0 ... links.length)
		{
			var node:HtmlDom = links[i];
			var pageNumVal:String = node.getAttribute("page");
			var xVal:String =  node.getAttribute("x");
			var yVal:String =  node.getAttribute("y");
			var widthVal:String =  node.getAttribute("width");
			var heightVal:String =  node.getAttribute("height");
			var colorVal:String =  node.getAttribute("color");
			var opacityVal:String =  node.getAttribute("opacity");
			var destinationVal:String = node.getAttribute("destination");
			var typeVal:String =  node.getAttribute("type");
			var popupWidthVal:String =  node.getAttribute("popupWidth");
			var popupHeightVal:String =  node.getAttribute("popupHeight");
			var youtubeIdVal:String =  node.getAttribute("youtubeId");
			var htmlText:String = null;
			var htmlTextDoms:HtmlCollection<HtmlDom> = node.getElementsByTagName("cdata");
			if (htmlTextDoms != null && htmlTextDoms.length > 0)
			{
				htmlText = StringTools.trim(htmlTextDoms[0].childNodes[0].nodeValue);
				htmlText = ctx.getCData(htmlText);
			}
			var link:HotLink = new HotLink();
			link.pageNum = Std.parseInt(pageNumVal) - 1;
			link.x = Std.parseFloat(xVal);
			link.y = Std.parseFloat(yVal);
			link.width = Std.parseFloat(widthVal);
			link.height = Std.parseFloat(heightVal);
			link.htmlText = htmlText;
			if (popupWidthVal != null) link.popupWidth = Std.parseInt(popupWidthVal);
			if (popupHeightVal != null) link.popupHeight = Std.parseInt(popupHeightVal);
			link.youtubeId = youtubeIdVal;
			link.type = typeVal == null ? "" : typeVal;
			
			if (colorVal != null)
			{
				colorVal = StringTools.replace(colorVal, "0x", "#");
				colorVal = StringTools.replace(colorVal, "0X", "#");
				link.color =  colorVal;
			}
			if (opacityVal != null) link.opacity = Std.parseFloat(opacityVal);
			if (destinationVal != null) link.destination = destinationVal;
			book.hotlinks.push(link);
		}
	}
	
	public static function loadVideos():Void
	{
		if (videoInfo == null) return;
		var index:Int = 0;
		var i:Iterator<Xml> = videoInfo.firstElement().elementsNamed("video");
		while (i.hasNext() == true)
		{
			var node:Xml = i.next();
			var pageNumVal:String = node.get("page");
			var xVal:String =  node.get("x");
			var yVal:String =  node.get("y");
			var widthVal:String =  node.get("width");
			var heightVal:String =  node.get("height");
			var autoPlayVal:String =  node.get("autoPlay");
			var showControlVal:String =  node.get("showControl");
			var autoRepeatVal:String =  node.get("autoRepeat");
			var urlVal:String =  node.get("url");
			var youtubeIdVal:String =  node.get("youtubeId");
			
			var video:VideoInfo = new VideoInfo();
			video.pageNum = Std.parseInt(pageNumVal) - 1;
			video.x = Std.parseFloat(xVal);
			video.y = Std.parseFloat(yVal);
			video.width = Std.parseFloat(widthVal);
			video.height = Std.parseFloat(heightVal);
			video.autoPlay = autoPlayVal == "true";
			video.showControl = showControlVal == "true";
			video.autoRepeat = autoRepeatVal == "true";
			video.url = urlVal;
			video.youtubeId = youtubeIdVal;
			video.id = "video_embed_" + Std.string(index);
			book.videos.push(video);
			index++;
		}		
	}
	
	public static function loadAudios():Void
	{
		if (audioInfo == null) return;
		var index:Int = 0;
		var i:Iterator<Xml> = audioInfo.firstElement().elementsNamed("pages");
		if (i.hasNext() == true)
		{
			var index:Int = 0;
			i = i.next().elementsNamed("sound");
			while (i.hasNext() == true)
			{
				var node:Xml = i.next();
				var pageNumVal:String = node.get("pageNumber");
				var urlVal:String =  node.get("url");
				var audio:AudioInfo = new AudioInfo();
				audio.url = urlVal;
				audio.pageNum = Std.parseInt(pageNumVal) - 1;
				audio.id = "audio_embed_" + Std.string(index);
				index++;
				book.audios.push(audio);
			}	
		}
	}
	
	public static function extractCData(txt:String):String
	{
		if (txt == null) return null;
		
		var first:Int = txt.indexOf("<![CDATA[");
		var last:Int = txt.lastIndexOf("]]>");
		if (first < 0 || last < 0 || last < first ) return null;
		return txt.substr(first + "<![CDATA[".length, last - first - "<![CDATA[".length);
	}
	
	public static function loadButtons():Void
	{
		if (buttonInfo == null) return;
		var i:Iterator<Xml> = buttonInfo.firstElement().elementsNamed("button");
		while (i.hasNext() == true)
		{
			var node:Xml = i.next();
			var pageNumVal:String = node.get("page");
			var xVal:String =  node.get("x");
			var yVal:String =  node.get("y");
			var widthVal:String =  node.get("width");
			var heightVal:String =  node.get("height");
			var imageVal:String =  node.get("image");
			var typeVal:String =  node.get("type");
			var popupWidthVal:String =  node.get("popupWidth");
			var popupHeightVal:String =  node.get("popupHeight");
			var youtubeIdVal:String =  node.get("youtubeId");
			var destinationVal:String = node.get("destination");
			var layer:String = node.get("layer");
			var textVal:String = "";
			var fontColorVal:String = "";
			var fontSizeVal:String = "";
			
			if ( node.get("text") != null) textVal = node.get("text");
			if ( node.get("fontColor") != null) fontColorVal = node.get("fontColor");
			if	( node.get("fontSize") != null) fontSizeVal = node.get("fontSize");
			
			var htmlText:String = extractCData(node.toString());
			var item:ButtonInfo = new ButtonInfo();
			item.pageNum = Std.parseInt(pageNumVal) - 1;
			item.x = Std.parseFloat(xVal);
			item.y = Std.parseFloat(yVal);
			item.width = Std.parseFloat(widthVal);
			item.height = Std.parseFloat(heightVal);
			item.layer = layer == null ? "onpage" : layer ;
			item.htmlText = htmlText;
			if (popupWidthVal != null) item.popupWidth = Std.parseInt(popupWidthVal);
			if (popupHeightVal != null) item.popupHeight = Std.parseInt(popupHeightVal);
			item.youtubeId = youtubeIdVal;
			item.destination = destinationVal;
			item.type = typeVal == null ? "" : typeVal;
			item.image = imageVal;
			item.text = textVal;
			
			if(fontColorVal != "")	item.fontColor = fontColorVal;
			if(fontSizeVal != "")	item.fontSize = fontSizeVal;
			book.buttons.push(item);
		}	
	}
	
	public static function getInputAndJumpToPage():Void
	{
		RunTime.flipBook.stopFlip();
		var t:Dynamic = RunTime.flipBook.tbPage;
		var val:String = t.value;
		val = StringTools.trim(val);
		var num = RunTime.flipBook.currentPageNum;
		if (val != "")
		{
			num = Std.parseInt(val) - 1;
		}
		
		if (num < 0) num = 0;
		else if (num > RunTime.book.pages.length - 1)
		{
			num = RunTime.book.pages.length - 1;
		}
		RunTime.flipBook.tbPage.setAttribute("value", Std.string(num + 1));
		RunTime.flipBook.turnToPage(num); 
		RunTime.flipBook.tbPage.blur();
	}
	
	public static function getPage(currentPageNum:Int, pageOffset:Int = 0, useNewDrawParams:Bool = true):Page
	{

		if (book == null || book.pages == null) return null;
		var num:Int = currentPageNum + pageOffset;
		if (num < 0|| num>book.pages.length-1) return null;
		var page:Page = book.pages[num];
		page.pageOffset = pageOffset;
		if (useNewDrawParams == true)
		{
			page.drawParams = getDrawParams();
		}
		
		
		if(RunTime.singlePage){
		
			RunTime.flipBook.zoomLeftPage.width = Std.int(page.drawParams.dw);
			RunTime.flipBook.zoomLeftPage.height = Std.int(page.drawParams.dh);
			RunTime.flipBook.zoomLeftPage.style.left = Std.string(page.drawParams.dx) + "px";
			RunTime.flipBook.zoomLeftPage.style.top = Std.string(page.drawParams.dy) + "px";
			
			

			
			RunTime.flipBook.leftPageLock.style.width = Std.int(page.drawParams.dw) + "px";
			RunTime.flipBook.leftPageLock.style.height = Std.int(page.drawParams.dh)+ "px";
			RunTime.flipBook.leftPageLock.style.left = Std.string(page.drawParams.dx) + "px";
			RunTime.flipBook.leftPageLock.style.top = Std.string(page.drawParams.dy) + "px";
			
			RunTime.flipBook.leftLockIcon.style.left = Std.int((page.drawParams.dw - 128) / 2) + "px";
			RunTime.flipBook.leftLockIcon.style.top = Std.int((page.drawParams.dh - 128) / 2) + "px";
			
		}
		return page;
		
		
	}
	
	
	
	/**
	 * 获取绘制参数
	 * @param	layout 页面的布局模式。0 为单页居中布局；1 为双页右页；-1 为双页左页
	 * @return
	 */
	public static function getDrawParams(layout:Int= 0):DrawParams
	{
		var dp:DrawParams = new DrawParams();
		var im:ImageMetricHelper = new ImageMetricHelper(RunTime.book.pageWidth, RunTime.book.pageHeight);
		var cw:Float = RunTime.clientWidth -RunTime.bookLeft - RunTime.bookRight;
		if (layout != 0)
		{
			cw = 0.5 * cw;
		}
		var ch:Float = RunTime.clientHeight -RunTime.bookTop -RunTime.bookBottom;
		var scale:Float = im.getMaxFitScale(cw, ch);
		var dw:Float = scale * RunTime.book.pageWidth;
		var dh:Float = scale * RunTime.book.pageHeight;
		var dx:Float = RunTime.bookLeft + 0.5 * (cw - dw);
		if (layout != 0)
		{
			if (RunTime.book.rightToLeft) {
				dx = layout > 0 ? RunTime.bookLeft + (cw - dw) : RunTime.bookLeft + cw;
			}
			else {
				dx = layout < 0 ? RunTime.bookLeft + (cw - dw) : RunTime.bookLeft + cw;
			}
		}
		var dy:Float = RunTime.bookTop + 0.5 * (ch -dh );
		var sx:Float = 0;
		var sy:Float = 0;
		var sw:Float = RunTime.book.pageWidth;
		var sh:Float = RunTime.book.pageHeight;
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
	
	
	public static function getGolobaDrawParams():DrawParams
	{
		var dp:DrawParams = new DrawParams();
		var im:ImageMetricHelper = new ImageMetricHelper(RunTime.book.pageWidth*2, RunTime.book.pageHeight);
		var cw:Float = RunTime.clientWidth -RunTime.bookLeft - RunTime.bookRight;

		var ch:Float = RunTime.clientHeight -RunTime.bookTop -RunTime.bookBottom;
		var scale:Float = im.getMaxFitScale(cw, ch);
		var dw:Float = scale * RunTime.book.pageWidth*2;
		var dh:Float = scale * RunTime.book.pageHeight;
		var dx:Float = RunTime.bookLeft + 0.5 * (cw - dw)*2;
		
		var dy:Float = RunTime.bookTop + 0.5 * (ch -dh )*2;
		var sx:Float = 0;
		var sy:Float = 0;
		var sw:Float = RunTime.book.pageWidth*2;
		var sh:Float = RunTime.book.pageHeight;
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
	
	
	/********** 下面是本地存储相关方法。由于ios5+引入了private browser模式，因此，不再调用这些方法 **********/
	
	public static function saveLocal(key:String, val:String):Void
	{
		//var local:Dynamic = Lib.window;
		//local.localStorage.setItem(key,val);
	}
	
	public static function getLocal(key:String):String
	{
		return "";
		//var local:Dynamic = Lib.window;
		//return local.localStorage.getItem(key);
	}
	
	public static function setUpdateFlag(bookId:String = null):Void
	{
		var prefix:String = bookId == null ? book.bookId : bookId;
		saveLocal(prefix + "-" +"uploadFlag", "1");
	}
	
	public static function getAndResetUpdateFlag():Bool
	{
		var val:String = getLocal(book.bookId + "-" +"uploadFlag");
		saveLocal(book.bookId + "-" +"uploadFlag", "");
		return val == "1";
	}
	
	public static function saveCurrentPageNum():Void
	{
		savePageNum(Std.string(RunTime.flipBook.getCurrentPageNum()));
	}
	
	public static function savePageNum(val:String, bookId:String = null):Void
	{
		var prefix:String = bookId == null ? book.bookId : bookId;
		saveLocal(prefix + "-" + "page", val);
	}
	
	public static function getAndResetSavedPageNum():Int
	{
		var val:String = getLocal(book.bookId + "-" + "page");
		savePageNum("");
		if (val == null || val == "") return 0;
		else
		{
			return Std.parseInt(val);
		}
	}
	
	public static function saveBottomBarVisible(val:Bool):Void
	{
		
		if (val == true)
		{
			saveLocal(book.bookId + "-" + "bottomBarVisible", "true");
		}
		else
		{
			saveLocal(book.bookId + "-" +"bottomBarVisible", "false");
		}
	}
	
	public static function getBottomBarVisible():Bool
	{
		return getLocal(book.bookId + "-" +"bottomBarVisible") == "true";
	}
	
	public static function encrypt(src:String):String
	{
		return encryptKey(src,RunTime.key);
	}
		
	public static function encryptKey(src:String, key:String):String
	{
		var n:Int = 0;
		var rtn:String = "";
		for(i in 0 ... (src.length - 1))
		{
			var c:Int = src.charCodeAt(i) + key.charCodeAt(n);
			var s:String = String.fromCharCode(c);
			rtn += s;
			n ++;
			if(n >= key.length - 1) n = 0;
		}
		
		if(src.length > 0)
		{
			rtn = rtn + src.substr(src.length - 1);
		}
		return encode64(rtn);
	}
	
	private static function encode64(txt:String, padding:Bool = true):String
	{
		var bytes:Bytes = Bytes.alloc(txt.length);
		for( i in 0...txt.length ) {
			var c : Int = StringTools.fastCodeAt(txt, i);
			bytes.set(i, c);
		}
		
		var c = new BaseCode(Bytes.ofString("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"));
		var base64:String = c.encodeBytes(bytes).toString();
		
		if (padding == true)
		{
			var remainder:Int = base64.length % 4;
			
			if (remainder > 1) {
				base64 += "=";
			}

			if (remainder == 2) {
				base64 += "=";
			}
		}
		
		return base64;
	}
	
	private static function decode64(txt:String):String
	{
		var paddingSize:Int = -1;
		
		if (txt.charAt(txt.length - 2) == "=") {
			paddingSize = 2;
		}
		
		else if (txt.charAt(txt.length - 1) == "=") {
			paddingSize = 1;
		}
		
		if (paddingSize != -1) {
			txt = txt.substr(0, txt.length - paddingSize);
		}
		
		var c = new BaseCode(Bytes.ofString("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"));
		return c.decodeString(txt);
	}
	
	public static function calcKey(w:Int, h:Int):String
	{
		var val:String = Std.string(w * h);
		val = val.substr(val.length - 3) + val.substr(0,2);
		var n:String = "";
		for(i in 0 ...val.length)
		{
			var c:Int = Std.int(val.charCodeAt(i) / 2);
			n = n + StringTools.hex(c);
		}
		return n.toUpperCase();
	}
	
	public static function clearPopupContents():Void
	{
		Lib.document.getElementById("maskPopup").style.display = "none";
		Lib.document.getElementById("cvsOthers").innerHTML = "";
		
		RunTime.flipBook.resetNoteButton();
		RunTime.flipBook.resetHighlightButton();
	}
	
	public static function isPopupModal():Bool {
		return Lib.document.getElementById("maskPopup").style.display == "none"?false: true;
	}
	
	public static function clearAudio():Void
	{
		Lib.document.getElementById("cvsAudio").innerHTML = "";
	}
	
	public static function clearBgAudio():Void
	{
		clearLeftBgAudio();
		clearRightBgAudio();
	}
	
	public static function clearLeftBgAudio():Void
	{
		Lib.document.getElementById("cvsLeftPageBgAudio").innerHTML = "";
	}
	
	public static function clearRightBgAudio():Void
	{
		Lib.document.getElementById("cvsRightPageBgAudio").innerHTML = "";
	}
	
	public static function showPopupMaskLayer():Void
	{
		Lib.document.getElementById("maskPopup").style.display = "inline";
	}
	
	public static function playAudio():Void
	{
		var item:Dynamic = Lib.document.getElementById("cvsAudio").getElementsByTagName("audio")[0];
		item.play();
	}
	
	public static function playVideo():Void
	{
		var item:Dynamic = Lib.document.getElementById("cvsOthers").getElementsByTagName("video")[0];
		item.play();	
	}
	
	public static function setOffset(dom:HtmlDom, left:Float, top:Float):Void
	{
		var l:Int = Math.round(left);
		var t:Int = Math.round(top);
		dom.style.left = Std.string(l) + "px";
		dom.style.top = Std.string(t) + "px";
	}
	
	public static var tracker:Dynamic;
	
	private static var trackerId:String;
		
	public static function useAnalyticsUA(ua:String, id:String):Void
	{
		if (isNullOrEmpty(ua)) return;
		
		trackerId = id;
		var gat = untyped __js__("_gat");
		tracker = gat._getTracker(ua);
		tracker._initData();
	}
		
	public static function log(action:String, msg:String):Void
	{
		if (isNullOrEmpty(msg)) return;
		
		if (useGoogleUaAsLogViewer == false)
		{
			RunTime.alert(action+":"+msg );
			return;
		};
		
		if(tracker)
		{
			tracker._trackPageview(trackerId + "/" + action + "/" + msg);
		}
	}
		
	public static function logPageView(pageNum:Int):Void
	{
		if(pageNum > 0)
		{
			log("page", Std.string(pageNum));
		}
	}
		
	public static function logClickLink(url:String, url2:String = null):Void
	{
		if(isNullOrEmpty(url) && isNullOrEmpty(url2)) return;
		log("link",(isNullOrEmpty(url) == false ? url : url2));
	}
		
	public static function logVideoView(url:String, url2:String = null):Void
	{
		if(isNullOrEmpty(url) && isNullOrEmpty(url2)) return;
		url = removePrefix(url);
		log("video",(isNullOrEmpty(url) == false ? url : url2));
	}
	
	private static function isNullOrEmpty(txt:String):Bool
	{
		return txt == null || txt == "" || txt == "undefined";
	}
	
	public static function logAudioView(url:String):Void
	{
		if(url == null || url == "") return;
		url = removePrefix(url);
		log("audio" , url);
	}
	
	public static function logSearch(keyword:String):Void
	{
		if(keyword == null || keyword == "") return;
		log("search" , keyword);
	}
	
	private static function removePrefix(url:String):String
	{
		if(url == null || url == "") return url;
		else if(url.indexOf("http") == 0) return url;
		else
		{
			var i:Int = url.lastIndexOf("/");
			return url.substr(i+1);
		}
	}
	
	public static function readLocalBookmarks():Array<Bookmark> {
		
		var bookmarks:Array<Bookmark> = new Array<Bookmark>();
		var i:Int = 0;
		for (i in 0 ... LocalStorage.length) {
			var szKey = LocalStorage.key(i);
			if(szKey.indexOf(kvPrex) == 0){
				if (szKey.indexOf("@$bm$@") != -1) {
					var bookmark:Bookmark = new Bookmark();
					bookmark.fillData(szKey, LocalStorage.getItem(szKey));
					bookmarks.push(bookmark);
					book.bookmarks.push(bookmark);
					//trace("bookmark.text:" + bookmark.text + "  pagenum: " + bookmark.pageNum);
				}
			}
		}
		return bookmarks;
	}
	
	public static function readLocalHighLights():Array<HighLight> {

		var highlights:Array<HighLight> = new Array<HighLight>();
		var i:Int = 0;
		for (i in  0 ... LocalStorage.length) {
			var szKey = LocalStorage.key(i);
			if (szKey.indexOf(kvPrex) == 0 ) {
				
				if (szKey.indexOf("@$ht$@") != -1) {
					//Lib.alert(szKey);
					
					var highlight:HighLight = new HighLight();
					highlight.fillData(szKey, LocalStorage.getItem(szKey));
					highlights.push(highlight);
					book.highlights.push(highlight);
				}
			}
			
			//Lib.alert(highlight.pageNum);
		}
		
		RunTime.highLights = highlights;
		
		if (RunTime.flipBook != null)
		{
			RunTime.flipBook.loadCtxHighLights();
			RunTime.flipBook.bookContext.render();
		}
				
		return highlights;
	}
	
	public static function updateHighLightNote(text:String):Void {
		if (RunTime.currentHighLight != null) {
			RunTime.currentHighLight.updateText(text);
			RunTime.flipBook.resetHighlightButton();
		}
	}
	
	public static function deleteHighLight():Void {
		if (RunTime.currentHighLight != null) {
			RunTime.currentHighLight.remove();
			RunTime.book.highlights.remove(RunTime.currentHighLight);
			RunTime.currentHighLight = null;
			RunTime.flipBook.loadCtxHighLights();
			RunTime.flipBook.bookContext.render();
			RunTime.flipBook.resetHighlightButton();
		}
	}
	
	
	public static function readLocalNotes():Array<NoteIcon> {

		var notes:Array<NoteIcon> = new Array<NoteIcon>();
		var i:Int = 0;
		for (i in  0 ... LocalStorage.length) {
			var szKey = LocalStorage.key(i);
			if(szKey.indexOf(kvPrex) == 0 ){
				if(szKey.indexOf("@$ni$@") != -1){
					var note:NoteIcon = new NoteIcon();
					note.fillData(szKey, LocalStorage.getItem(szKey));
					//Lib.alert(note.pageNum);
					notes.push(note);
					book.notes.push(note);
				}
			}
			
			//Lib.alert(highlight.pageNum);
		}
		
		RunTime.notes = notes;
		
		if (RunTime.flipBook != null)
		{
			RunTime.flipBook.loadCtxNotes();
			RunTime.flipBook.bookContext.render();
		}
				
		return notes;
	}
	
	public static function updateNote(text:String):Void {
		if (RunTime.currentNote != null) {
			RunTime.currentNote.updateText(text);
			RunTime.flipBook.resetNoteButton();
		}
	}
	
	public static function deleteNote():Void {
		if (RunTime.currentNote != null) {
			RunTime.currentNote.remove();
			RunTime.book.notes.remove(RunTime.currentNote);
			RunTime.currentNote = null;
			RunTime.flipBook.loadCtxNotes();
			RunTime.flipBook.bookContext.render();
			RunTime.flipBook.resetNoteButton();
			
		}
		
	}
	
	public static function resizeSlide(p1,p2,p3,p4,p5):Void {
		//Lib.alert(p2);
		var scale:Float = p3 / p1.height;
		var leftVal:Float = (p2 - p1.width * scale) / 2;
		//Lib.alert((p2 - p1.width * scale) / 2);
		
		Lib.document.getElementById(p4).style.width = Std.int(p1.width  * scale) + "px";
		Lib.document.getElementById(p4).style.marginLeft = leftVal+ "px";


	}

}