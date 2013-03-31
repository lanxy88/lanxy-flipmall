package ;
import Canvas;
import core.AudioInfo;
import core.BookContext;
import core.DrawParams;
import core.HotLink;
import core.Page;
import core.PagePair;
import core.Tweener;
import core.ZoomStatus;
import haxe.Timer;
import core.VideoInfo;
import core.ButtonInfo;
import core.SlideshowInfo;
import core.Slide;
import core.HighLight;
import core.Note;
import core.NoteIcon;
import core.Bookmark;
import js.Dom;
import js.Lib;
import orc.utils.ImageMetricHelper;
import core.HtmlHelper;
import orc.utils.Util;
using HtmlDomHelper;

/**
 * ...
 * @author 
 */
class FlipBook
{
	public var canvas:Canvas;
	public var cvsButton:Canvas;
	public var cvsHighLight:Canvas;
	public var cvsNote:Canvas;
	public var cvsBookmark:Canvas;
	
	public var zoomLeftPage:Image;
	public var zoomRightPage:Image;
	public var zoom:HtmlDom;
	public var root:HtmlDom;
	public var mask:HtmlDom;
	public var cvsVideo:HtmlDom;
	public var cvsOthers:HtmlDom;
	public var cvsAudio:HtmlDom;
	public var cvsLeftPageBgAudio:HtmlDom;
	public var cvsRightPageBgAudio:HtmlDom;
	
	public var cvsSlideshow:HtmlDom;
	
	public var leftPageLock:HtmlDom;
	public var rightPageLock:HtmlDom;
	
	public var cvsYoutube:HtmlDom;
	public var maskPopup:HtmlDom;
	public var btnPrevPage:HtmlDom;
	public var btnNextPage:HtmlDom;
	public var btnFirstPage:HtmlDom;
	public var btnLastPage:HtmlDom;
	public var btnAutoFlip:HtmlDom;
	public var btnZoom:HtmlDom;
	public var tbPageCount:HtmlDom;
	public var btnContents:HtmlDom;
	public var btnThumbs:HtmlDom;
	public var btnShowTxt:HtmlDom;
	public var btnSearch:HtmlDom;
	
	public var btnMask:HtmlDom;
	public var btnBookMark:HtmlDom;
	public var btnNote:HtmlDom;
	
	public var btnDownload:HtmlDom;
	public var btnEmail:HtmlDom;
	public var btnSns:HtmlDom;
	
	public var imgLogo:HtmlDom;
	public var tbPage:HtmlDom;
	public var topBar:HtmlDom;
	public var bottomBar:HtmlDom;
	public var bottomBarBg:HtmlDom;
	public var topMenuBar:HtmlDom;
	public var topMenuBarBg:HtmlDom;
	
	public var topBarContent:HtmlDom;
	public var topFullTextContent:HtmlDom;
	public var menuParent:HtmlDom;
	public var bookContext:BookContext;
	public var tweener:Tweener;
	public var zoomStatus:ZoomStatus;
	
	public var leftPageNum:Int = -1;
	public var rightPageNum:Int = -1;
	/**
	 * 是否开始缩放手势
	 */
	public var startZoomGesture:Bool = false;
	public var startFingerDistance:Float = 0;
	public var startMoveGesture:Bool = false;
	public var gestureScale:Float = 1;
	public var totalGeustureScale:Float = 0;
	public var realScale:Float = 1;
	/**
	 * 页面偏移
	 */
	public var page_offsetX:Float = 0;
	public var page_offsetY:Float = 0;
	public var last_moveX:Float = 0;
	public var last_moveY:Float = 0;
	
	public var totalDistance:Float = 0;
	public var totalLast:Float = 0;
	
	public var init_moveX:Float = 0;
	public var init_moveY:Float = 0;
	
	public var currentMoveX:Float = 0;
	public var currentMoveY:Float = 0;
	public var gestureMoveX:Float = 0;
	public var gestureMoveY:Float = 0;
	
	public var gestureLastX:Float = -1;
	public var gestureLastY:Float = -1;
	
	/**
	 * 是否开始手指标记高亮
	 */
	public var bStartHighLight:Bool = false;
	public var currentHighLight:HighLight = null;
	public var bStartHighLightGesture:Bool = false;
	
	
	/**
	 * 是否开始手指标记笔记
	 */
	public var bStartNote:Bool = false;
	public var currentNote:NoteIcon = null;
	public var bStartNoteGesture:Bool = false;
	
	/**
	 * 是否允许缩放
	 */
	public var bCanGestureZoom:Bool = true;
	
	public var bShowBottomBar:Bool = true;
	
	/**
	 * 滑动中
	 */
	public var bFlipping:Bool = false;
	
	public function new() 
	{
		bookContext = new BookContext();
		tweener = new Tweener();
		currentPageNum = 0;
		zoomStatus = ZoomStatus.normal;
	}
	
	public function getContext():CanvasRenderingContext2D
	{
		return canvas.getContext("2d");
	}
	
	public function getButtonContext():CanvasRenderingContext2D {
		return cvsButton.getContext("2d");
	}
	
	public function getHighLightContext():CanvasRenderingContext2D {
		return cvsHighLight.getContext("2d");
	}
	
	public function getNoteContext():CanvasRenderingContext2D {
		return cvsNote.getContext("2d");
	}
	
	public function getBookmarkContext():CanvasRenderingContext2D {
		return cvsBookmark.getContext("2d");
	}
	
	public function attachActions():Void
	{
		if (root == null) return;
		mask.ondblclick = this.onDblClick;
		mask.onclick = this.onMouseDown;
		//mask.onmousedown = this.onMouseDown;
		//mask.onmousemove = this.onMouseMove;
		//mask.onmouseup = this.onMouseUp;
		
		mask.ontouchstart = this.onTouchStart;
		mask.ontouchmove = this.onTouchMove;
		mask.ontouchend = this.onTouchEnd;
		mask.ontouchcancel = this.onTouchEnd;
		mask.gestureend = this.onGestureEnd;
		mask.gesturestart = this.onGestureStart;
		mask.gesturechange = this.onGestureChange;
		mask.onscroll = this.forbidden;
		mask.onmousewheel = this.forbidden;		
	
		cvsVideo.onclick = this.onMouseDown;
		cvsVideo.ontouchstart = this.onTouchStart;
		cvsVideo.ontouchmove = this.onTouchMove;
		cvsVideo.ontouchend = this.onTouchEnd;
		cvsVideo.ontouchcancel = this.onTouchEnd;
		cvsVideo.gestureend = this.onGestureEnd;
		cvsVideo.gesturestart = this.onGestureStart;
		cvsVideo.gesturechange = this.onGestureChange;
		
		maskPopup.onscroll = this.forbidden;
		maskPopup.onmousewheel = this.forbidden;
		
		

		//Lib.alert(Lib.window.navigator.userAgent);
		if (Lib.window.navigator.userAgent.indexOf("iPad") != -1) {
			
			topBarContent.ontouchstart = this.onTopBarTouchStart;
			topBarContent.ontouchmove = this.onTopBarTouchMove;
			topBarContent.ontouchend = this.onTopBarTouchEnd;
			topBarContent.ontouchcancel = this.onTopBarTouchEnd;
		
			topFullTextContent.ontouchstart = this.onTopBarTouchStart;
			topFullTextContent.ontouchmove = this.onTopBarTouchMove;
			topFullTextContent.ontouchend = this.onTopBarTouchEnd;
			topFullTextContent.ontouchcancel = this.onTopBarTouchEnd;
		}
		
		
		
		//btnNextPage.onclick = this.turnToNextPage;
		//btnPrevPage.onclick = this.turnToPrevPage;
		//btnFirstPage.onclick = this.turnToFirstPage;
		//btnLastPage.onclick = this.turnToLastPage;
		
		
		btnNextPage.ontouchstart = this.turnToNextPage;
		btnPrevPage.ontouchstart = this.turnToPrevPage;
		btnFirstPage.ontouchstart = this.turnToFirstPage;
		btnLastPage.ontouchstart = this.turnToLastPage;
		btnContents.onclick = this.onContentsClick;
		btnEmail.onclick = this.onEmailClick;
		btnSns.onclick = this.onSnsClick;
		
		btnThumbs.onclick = this.onThumbsClick;
		btnSearch.ontouchstart = this.onSearchClick;
		btnAutoFlip.ontouchstart = this.onAutoFlipClick;
		btnShowTxt.ontouchstart = this.onShowTxtClick;
		tbPage.onfocus = this.onTbPageFocus;
		btnZoom.ontouchstart = this.onZoomClick;
		
		btnMask.ontouchstart = this.onButtonMaskClick;
		btnBookMark.ontouchstart = this.onButtonBookmark;
		btnNote.ontouchstart = this.onButtonNoteClick;
		
		
		//btnAutoFlip.onclick = this.onAutoFlipClick;
		
	}
	
	private function forbidden(e:Event):Void
	{
		e.preventDefault();
		e.stopPropagation();
	}
	
	public function afterInit():Void
	{
		
	}
	
	public var currentPageNum:Int;
	
	public function loadPage(index:Int):Void
	{
		RunTime.flipBook.rightPageLock.style.display = "none";
		preloadPages(index);
		currentPageNum = index;
		loadCtxHotlinks();
		loadCtxSlideshow();
		loadCurrentBookmark();
		var page:Page = RunTime.getPage(currentPageNum);
		bookContext.addPage(page);
		if (page != null && page.locked && RunTime.bLocked) {
			RunTime.flipBook.leftPageLock.style.display = "block";
		}
		bookContext.render();
		//RunTime.divLoading.style.display = "inline";
		var p:Int = currentPageNum;
		if (p == null) p = 0;
		RunTime.logPageView(p + 1);
		onEnterPage();
	}
	private function onButtonLinkClick(x:Float, y:Float):Bool {
		var hotlink:HotLink = this.bookContext.getHotLinkAt(x, y);
		if (hotlink != null)
		{
			hotlink.click();
			return true;
		}
		
		var button:ButtonInfo = this.bookContext.getButtonAt(x, y);
		if (button != null)
		{
			button.click();
			return true;
		}
		
		return false;
	}
	
	private function onHighLightClick(x:Float, y:Float):Bool {
		var highlight:HighLight = this.bookContext.getHighLightAt(x, y);
		if (highlight != null && bStartHighLight) {
			RunTime.currentHighLight = highlight;
			//Lib.alert("onHighlight");
			highlight.click();
			return true;
		}
		else {
			RunTime.currentHighLight = null;
		}
		return false;
	}
	
	private function onNoteClick(x:Float, y:Float):Bool {
		var note:NoteIcon = this.bookContext.getNoteAt(x, y);
		if (note != null && bStartNote) {
			RunTime.currentNote = note;
			//Lib.alert("onHighlight");
			note.click();
			return true;
		}
		else {
			RunTime.currentNote = null;
		}
		return false;
	}
	
	
	
	
	public function onMouseUp(e:Event):Void {
		

			
	}
	public function onMouseDown(e:Event):Void
	{
		//Lib.alert("onMouseDown");
		
		e.stopPropagation();
		
		//onButtonLinkClick(e.pageX, e.pageY);
		
		//Lib.alert("onMouseDown");
		
		/*
		if (this.bottomBarBg.style.opacity != RunTime.bottomBarAlpha)
		{
			//if(zoomStatus != ZoomStatus.zoomed){
				this.showBottomBar(e);
			//}
		}
		else
		{
			this.hideBottomBar(e);
		}
		*/
		
		if (bStartHighLight || bStartNote) return;
		
		if(Math.abs(Lib.window.innerWidth - RunTime.clientWidth) < 10){
		
			if (this.topMenuBarBg.style.opacity != RunTime.bottomBarAlpha)
			{
				this.showBottomBar(e);
			}
			else
			{
				this.hideBottomBar(e);
			}
		}
		
	}
	
	public function turnPage(pageOffset:Int):Void
	{
		if (bFlipping) return ;
		
		if (pageOffset == 0) return;
		
		if (RunTime.book.rightToLeft) {
			pageOffset =  0 - pageOffset;
		}
		if (RunTime.book == null || RunTime.book.pages == null) {
			
			return;
		}
		var dstPageNum:Int = this.currentPageNum + pageOffset;
		var dstPage:Page = RunTime.getPage(dstPageNum);
		if (dstPage == null) {
			
			return;
		}
		//kylefly 2012.9.5 add  -----------begin-------------
		resetZoom();
		//-----------------------end-------------------------
		
		this.setCurrentPage(dstPageNum + 1);
		var self:FlipBook = this;
		bookContext.removeAllPages();
		bookContext.resetLayoutParams();
		
		bookContext.addPage(RunTime.getPage(currentPageNum, 0));
		bookContext.addPage(RunTime.getPage(currentPageNum, 1));
		bookContext.addPage(RunTime.getPage(currentPageNum, -1));
	
		
		bookContext.pageOffset = 0;
		if (tweener != null) 
		{
			tweener.stop();
		}
		var maxCount:Float = 8;
		
	
		tweener.onChange = function(count:Int):Void
		{
			var ratio:Float = count /  maxCount;
			if (RunTime.book.rightToLeft) {
				self.bookContext.pageOffset = pageOffset * ratio * ratio;
			}
			else {
				self.bookContext.pageOffset = -pageOffset  * ratio * ratio;
			}
			
			if (count == maxCount) {
				//bFlipping = false;
				self.bookContext.pageOffset = -pageOffset;
			}
			
			if (count == maxCount) {
				//bFlipping = false;
				self.currentPageNum = dstPageNum;
				self.loadCtxHotlinks();
				self.loadCtxSlideshow();
				self.loadCtxButtons();
				self.loadCtxHighLights();
				self.loadCtxNotes();
				self.loadCurrentBookmark();
				self.updateVideos();
				
				RunTime.flipBook.rightPageLock.style.display = "none";
				RunTime.flipBook.leftPageLock.style.display = "none";
		
				if (dstPage != null && dstPage.locked && RunTime.bLocked) {
					RunTime.flipBook.leftPageLock.style.display = "block";
				}
				
				RunTime.logPageView(dstPageNum + 1);
				RunTime.clearPopupContents();
				self.onEnterPage();
			}
			
			self.bookContext.render();
		}
	
		
		this.clearCtxHotlinks();
		this.clearCtxButtons();
		clearVideos();
		clearSlideshow();
		tweener.start(Std.int(maxCount));
	}
	
	public function turnToPage(pageNum:Int):Void
	{
		//Lib.alert("turnToPage");
		clearZoom() ;
		preloadPages(pageNum);
		var page:Page = RunTime.getPage(pageNum);
		if (page == null) return;
		this.setCurrentPage(pageNum + 1);
		this.currentPageNum = pageNum;
		
		hideTopBar();
		
		RunTime.flipBook.rightPageLock.style.display = "none";
		RunTime.flipBook.leftPageLock.style.display = "none";
		
		if (page != null && page.locked && RunTime.bLocked) {
			RunTime.flipBook.leftPageLock.style.display = "block";
		}
				
		clearSlideshow();
		
		loadCtxHotlinks();
		loadCtxSlideshow();
		loadCtxButtons();
		loadCtxHighLights();
		loadCtxNotes();
		loadCurrentBookmark();
		clearVideos();
		
		bookContext.removeAllPages();
		bookContext.resetLayoutParams();
		bookContext.addPage(page);
		bookContext.pageOffset = 0;
		bookContext.render();
		//RunTime.divLoading.style.display = "inline";
		updateVideos();
		RunTime.logPageView(pageNum + 1);
	}
	
	public function turnToNextPage(e:Dynamic):Void
	{
		
		clearZoom() ;
		this.stopFlip();
		this.turnPage(1);
	}
	
	public function clearZoom() {
		
		if (this.zoomLeftPage.src !="") {
			this.zoomLeftPage.src = "";
			this.zoomLeftPage.style.display = "none";
		}
		if (this.zoomRightPage.src != "") {
			this.zoomRightPage.src = "";
			this.zoomRightPage.style.display = "none";
		}
		
		
		RunTime.clearPopupContents();
		
		resetNoteButton();
		resetHighlightButton();
		
		//topBarContent.innerHTML = "";
		//setVisible(topBarContent, false);
	}
	
	public function turnToPrevPage(e:Dynamic):Void
	{

		clearZoom() ;
		this.stopFlip();
		this.turnPage(-1);
	}
	
	public function turnToFirstPage(e:Dynamic):Void
	{
		clearZoom() ;
		this.stopFlip();
		
		
		if (RunTime.book.rightToLeft) {
			turnToPage(RunTime.book.pages.length - 1);
		}
		else {
			turnToPage(0);
		}
	}
	
	public function turnToLastPage(e:Dynamic):Void
	{
		clearZoom() ;
		this.stopFlip();
		//turnToPage(RunTime.book.pages.length - 1);
		
		if (RunTime.book.rightToLeft) {
			turnToPage(0);
		}
		else {
			
			turnToPage(RunTime.book.pages.length - 1);
		}
	}
	
	public function TansRightToLeft():Void
	{
		
		turnToPage(RunTime.book.pages.length-1);
	}
	
	public function onEnterPage():Void
	{
		updateFullText();
		updateAudios();
	}
	
	public function setPageCount(val:Int):Void
	{
		tbPageCount.innerHTML = "/&nbsp;" + Std.string(val);
	}
	
	public function setCurrentPage(val:Int):Void
	{
		var t:Dynamic = tbPage;
		t.value = Std.string(val);
	}
	
	public var touchActive:Bool;
	public var touchStartX:Float;
	public var touchStartY:Float;
	public var lastTouchX:Float;
	public var lastTouchY:Float;
	public var lastTouchTime:Date;
	public var lastAnimationTime:Date;
	
	public var startZoomInTime:Date;
	
	public function onDblClick(e:Event):Void {
		e.stopPropagation();
		
		//Lib.alert("onDblClick");
	}
	
	public function onMouseMove(e:Event):Void {

			
			
		e.stopPropagation();
		if (zoomStatus == ZoomStatus.zoomed) {
			//trace("moving");
			
		}
	}
	
	public function onTouchStart(e:Event):Void
	{

		var obj:Dynamic = e;
		//obj.preventDefault();
		var touch:Dynamic = obj.touches[0];
		//选中高亮
		if (onHighLightClick(touch.pageX, touch.pageY)) return;
		
		if (onNoteClick(touch.pageX, touch.pageY)) return;

		//标记模式
		if (bStartHighLight) {
			currentHighLight = new HighLight();
			currentHighLight.tx = touch.pageX;
			currentHighLight.ty = touch.pageY;
			if(RunTime.singlePage){
				currentHighLight.tpageNum = getCurrentPageNum();
			}
			else {
				
				if (RunTime.book.rightToLeft) {
					if (currentHighLight.tx > RunTime.clientWidth / 2) {
						currentHighLight.tpageNum = this.leftPageNum-1;
						
					}
					else {
						currentHighLight.tpageNum = this.rightPageNum-1;
					}
				}
				else{
				
					if (currentHighLight.tx > RunTime.clientWidth / 2) {
						currentHighLight.tpageNum = this.rightPageNum-1;
					}
					else {
						currentHighLight.tpageNum = this.leftPageNum-1;
					}
				}
			}
			return;
		}
		
		//笔记模式
		if (bStartNote) {
			//Lib.alert("Note");
			currentNote = new NoteIcon();
			currentNote.tx = touch.pageX;
			currentNote.ty = touch.pageY;
			
			gestureLastX = touch.pageX;
			gestureLastY = touch.pageY;
			
			if(RunTime.singlePage){
				currentNote.tpageNum = getCurrentPageNum();
			}
			else {
				
				if (RunTime.book.rightToLeft) {
					if (currentNote.tx > RunTime.clientWidth / 2) {
						currentNote.tpageNum = this.leftPageNum-1;
						
					}
					else {
						currentNote.tpageNum = this.rightPageNum-1;
					}
				}
				else{
				
					if (currentNote.tx > RunTime.clientWidth / 2) {
						currentNote.tpageNum = this.rightPageNum-1;
					}
					else {
						currentNote.tpageNum = this.leftPageNum-1;
					}
				}
			}
			return;
		}
		
		//Lib.alert("onTouchStart");
		var date:Date = Date.now();
		//e.stopPropagation();
		//var obj:Dynamic = e;
		//obj.preventDefault();
		//var touch:Dynamic = obj.touches[0];
		
		
		if (obj.touches.length == 2) {
			startZoomGesture = true;
		}
		
		
		if (lastTouchTime != null && obj.touches.length == 1)
		{
			var lastTime:Float = lastTouchTime.getTime();
			var newTime:Float = date.getTime();
			if (newTime - lastTime < RunTime.doubleClickIntervalMs) // 双击屏幕
			{
				
				zoomAt(0, 0);
				
				lastTouchTime = null;
				if (zoomStatus == ZoomStatus.zoomed) {
					//zoomAt(null, null);
				}
				else{
					//zoomAt(touch, touch);
				}
				return;
			}
			
		}
		lastTouchTime = date;
		
		this.stopFlip();
		
		
		touchActive = true;
		
		//放大模式下，单个手指滑动，恢复系统默认行为
		if (zoomStatus == ZoomStatus.zoomed) {
			touchActive = false;
		}
		/*
		Lib.alert("clientX=" + touch.clientX + " , clientY=" + touch.clientY);
		Lib.alert("PageX=" + touch.pageX + " , PageY=" + touch.pageY);
		*/
		
		onButtonLinkClick(touch.pageX, touch.pageY);
		
		touchStartX = touch.clientX;
		touchStartY = touch.clientY;
		lastTouchX = touchStartX;
		lastTouchY = touchStartY;
	}
	
	public function fillImg(urlPage:String):Void {
		this.zoomLeftPage.src = urlPage;
	}
	
	public function zoomAt(point0:Dynamic, point1:Dynamic):Void
	{
		
		//Lib.alert("zoomAt");
		var num:Int = 0;
		if (currentPageNum != null) num = currentPageNum;
		var page:Page = RunTime.getPage(num);
		if (point0 == null || point1 == null) {
			//Lib.alert("zoomout");
			zoomOut();
		}
		else {
			
			zoomIn(page, point0, point1);
		}
		
		/*
		//普通状态
		if (zoomStatus == ZoomStatus.normal) {
			zoomIn(page,point0,point1);
		}
		//放大状态
		else if(zoomStatus == ZoomStatus.zoomed) {
			zoomOut();
		}
		*/

	}
	
	public function zoomOut():Void
	{
		//this.bottomBar.style.display = "inline";
		//this.showBottomBar(null);
		
		if (bShowBottomBar) this.showBottomBar(null);
		
	}
	
	public function zoomIn(page:Page,point0:Dynamic, point1:Dynamic):Void
	{
		//zoomStatus = ZoomStatus.zoomed;
		
		if (page == null ) return;
		//this.hideBottomBar(null,true,true);
		if(!page.locked){
			this.zoomLeftPage.src = page.getBigPageUrl();	
		}
		else {
		//	this.zoomLeftPage.src = page.getBlankPage();	
		}
		this.zoomLeftPage.style.display = "inline";
		
		//this.zoomLeftPage.style.cssText  = "-webkit-transition: 0.5s ease-out; " ;
		
		//this.hideBottomBar(null);
		//this.bottomBar.style.display = "none";

	}
	
	/**
	 * 计算两指之间的距离
	 * @param	touch1
	 * @param	touch2
	 */
	function getDistance(touch1, touch2){
            var x1 = touch1.clientX;
            var x2 = touch2.clientX;
            var y1 = touch1.clientY;
            var y2 = touch2.clientY;
 
            return Math.sqrt(((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1)));
    }
	
	public function resizeContainer(w:Float, h:Float, l:Float, t:Float) {

	}
	
	public function getFullUrl():String
	{
		return RunTime.urlIndex + "?page=" + Std.string(currentPageNum) + "&bbv=" + getCurrentBBV() + "&pcode=" + RunTime.pcode;
	}
	
	public function onTouchEnd(e:Event):Void
	{
		//trace("onTouchEnd");
		//标记模式
		if (bStartHighLight && gestureLastX != -1 && gestureLastY !=-1) {
			//Lib.alert("aa");
			var obj:Dynamic = e;
			e.preventDefault();
			if (gestureLastX < currentHighLight.tx )
			{
				currentHighLight.tx = gestureLastX;
				currentHighLight.twidth = Math.abs(currentHighLight.twidth);
			}
			
			if (gestureLastY < currentHighLight.ty )
			{
				currentHighLight.ty = gestureLastY;
				currentHighLight.theight = Math.abs(currentHighLight.theight);
			}
			
			currentHighLight.save();
			
			RunTime.book.highlights.push(currentHighLight.clone());
			
			//this.bookContext.highlights.push(currentHighLight.clone());
			this.loadCtxHighLights();
			this.bookContext.render();
			
			gestureLastX = -1;
			gestureLastY = -1;
			currentHighLight.tx = 0;
			currentHighLight.ty = 0;
			currentHighLight.twidth = 0;
			currentHighLight.theight = 0;
			currentHighLight.tpageNum = getCurrentPageNum();
			
			onButtonMaskClick(null);
			
			return;
		}
		
		
		if (bStartNote && gestureLastX != -1 && gestureLastY !=-1) {
			
			var obj:Dynamic = e;
			e.preventDefault();
			//if (gestureLastX < currentNote.tx )
			//{
				//currentNote.tx = gestureLastX;
				currentNote.twidth = 32;
			//}
			
			//if (gestureLastY < currentNote.ty )
			//{
				//currentNote.ty = gestureLastY;
				currentNote.theight = 32;
			//}
			
			currentNote.save();
			var saveObj:NoteIcon = currentNote.clone();
			RunTime.book.notes.push(saveObj);
			
			//this.bookContext.highlights.push(currentHighLight.clone());
			this.loadCtxNotes();
			this.bookContext.render();
			
			gestureLastX = -1;
			gestureLastY = -1;
			currentNote.tx = 0;
			currentNote.ty = 0;
			currentNote.twidth = 0;
			currentNote.theight = 0;
			currentNote.tpageNum = getCurrentPageNum();
			
			onButtonNoteClick(null);
			
			RunTime.currentNote = saveObj;
			RunTime.currentNote.click();
			
			return;
		}
		
		
		totalDistance += totalLast;
		
		if (startZoomGesture) {
			if(Math.abs(Lib.window.innerWidth - RunTime.clientWidth) >= 10){
				hideBottomBar();
			}
			else {
				if (bShowBottomBar) this.showBottomBar(null);
			}
		}
		
		if (totalDistance <= 0) {
			//Lib.alert("normal");
		}
		bFlipping = false;
		e.stopPropagation();
		touchActive = false;
		startZoomGesture = false;
		startFingerDistance = 0;
		
		return;
	
	}
	
	public function checkCanZoom():Bool {
		var num:Int = 0;
		if (currentPageNum != null) num = currentPageNum;
		var page:Page = RunTime.getPage(num);
		return page.canZoom;
	}

	public function onTouchMove(e:Event):Void
	{
		

		//Lib.alert("onTouchMove");
		if (RunTime.isPopupModal()) return;
		
		
		//标记模式
		if (bStartHighLight) {
			e.preventDefault();
			var obj:Dynamic = e;
			var touch:Dynamic = obj.touches[0];
			gestureLastX = touch.pageX;
			gestureLastY = touch.pageY;
			
			if (Math.abs(gestureLastX - currentHighLight.tx) <= 10 
				||
				Math.abs(gestureLastY -  currentHighLight.ty) <= 10) {
				return;
			}
			currentHighLight.twidth = gestureLastX - currentHighLight.tx;
			currentHighLight.theight = gestureLastY - currentHighLight.ty;
			getHighLightContext().clearRect(0, 0,  Lib.window.document.body.clientWidth,  Lib.window.document.body.clientHeight);
			this.bookContext.render();
			currentHighLight.draw(getHighLightContext());
			
			
			return;
		}
		
		//笔记模式
		if (bStartNote) {
			e.preventDefault();
			var obj:Dynamic = e;
			var touch:Dynamic = obj.touches[0];
			gestureLastX = touch.pageX;
			gestureLastY = touch.pageY;
			
			/*
			if (Math.abs(gestureLastX - currentNote.tx) <= 10 
				||
				Math.abs(gestureLastY -  currentNote.ty) <= 10) {
				return;
			}
			*/
			currentNote.twidth = 32;
			currentNote.theight = 32;
			getNoteContext().clearRect(0, 0,  Lib.window.document.body.clientWidth,  Lib.window.document.body.clientHeight);
			this.bookContext.render();
			currentNote.draw(getNoteContext());
			
			
			return;
		}
		
		
		
		//RunTime.clearPopupContents();
		
		//Lib.alert(Lib.window.innerWidth + " ----------- " + RunTime.clientWidth);
		//Lib.alert(Lib.window.innerWidth);
		//e.stopPropagation();
		//if (touchActive == false) return;
		var obj:Dynamic = e;
		var touch:Dynamic = obj.touches[0];
		var touch2:Dynamic = obj.touches[1];
				
		//obj.preventDefault();

		var date:Date = Date.now();
	
		var offsetX:Float = touch.clientX - touchStartX;
		var offsetY:Float = touch.clientY - touchStartY;
		
		

		
		//禁止放大，阻止默认行为
		if (!checkCanZoom() && obj.touches.length == 2) {
			obj.preventDefault();
		}
		
		//缩放手势
		if (obj.touches.length == 2 && checkCanZoom()) {
			
			zoomAt(touch, touch2);
			return;
		}
	
		if (obj.touches.length == 1 && Math.abs(Lib.window.innerWidth - RunTime.clientWidth) < 10)
		{
			//Lib.alert(Math.abs(Lib.window.innerWidth - RunTime.clientWidth));
		
			
			this.zoomLeftPage.src = "";
			this.zoomLeftPage.style.display = "none";
			this.zoomRightPage.src = "";
			this.zoomRightPage.style.display = "none";

			
			
			if (offsetX > 0)
			{
				//this.turnPage( -1);
				turnToPrevPage(null);
				touchActive = false;
				bFlipping = true;
			}
			else if (offsetX < 0)
			{
				//this.turnPage( 1);
				turnToNextPage(null);
				touchActive = false;
				bFlipping = true;
			}
			zoomAt(null, null);
			obj.preventDefault();
		}
		
		/*
		else if(zoomStatus == ZoomStatus.zoomed)
		{
			last_moveX = offsetX;
			last_moveY = offsetY;
			
			startMoveGesture = true;
			move(touch.clientX - lastTouchX, touch.clientY - lastTouchY);
			
			//obj.preventDefault();
		}
		*/
		
		
		lastTouchX = touch.clientX;
		lastTouchY = touch.clientY;
	}
	
	private function move(offsetX:Float, offsetY:Float):Void
	{
		bookContext.offsetX += offsetX;
		bookContext.offsetY += offsetY;
		updateVideoLayout();
		bookContext.render();
	}
	
	public function onGestureStart(e:Event):Void
	{
		//Lib.alert("gesture");
		e.stopPropagation();
	}
	
	public function onGestureChange(e:Event):Void
	{
		
		//Lib.alert(e.scale);
		e.stopPropagation();
	}
	
	public function onGestureEnd(e:Event):Void
	{
		//Lib.alert("onGestureEnd");
		e.stopPropagation();
		
		
		
	}
	
	public var touchTopBarActive:Bool;
	public var touchTopBarY:Float;
	
	public function onTopBarTouchStart(e:Event):Void
	{
		//e.preventDefault();
		//Lib.alert("ontopbar");
		touchTopBarActive = true;
		var obj:Dynamic = e;
		var touch:Dynamic = obj.touches.item(0);
		touchTopBarY = touch.pageY;
	}
	
	public function onTopBarTouchEnd(e:Event):Void
	{
		//e.preventDefault();
		touchTopBarActive = false;
	}
	
	public function onTopBarTouchMove(e:Event):Void
	{
		e.preventDefault();
		
		var obj:Dynamic = e;
		var touch:Dynamic = obj.touches.item(0);
		var offset:Float = touchTopBarY - touch.pageY;
		//Lib.alert("scrollTop=" + this.topBarContent.scrollTop);
		this.topBarContent.scrollTop += Std.int(Math.round(offset));
		this.topFullTextContent.scrollTop += Std.int(Math.round(offset));
	}
	
	public function clearCtxHotlinks():Void
	{
		this.bookContext.hotlinks = null;
	}
	
	public function clearCtxButtons():Void
	{
		this.bookContext.buttons = null;
	}
	
	public function clearCtxHighLight():Void {
		this.bookContext.highlights = null;
		//this.bookContext.notes = null;
	}
	
	public function clearCtxNote():Void {
		this.bookContext.notes = null;
		
	}
	
	public function loadCtxSlideshow():Void
	{

		var slides:Array<SlideshowInfo> = new Array<SlideshowInfo>();
		if (RunTime.book != null && RunTime.book.slideshows != null)
		{
			var current:Int = 0;
			if (currentPageNum != null) current = currentPageNum;
			for (i in 0 ... RunTime.book.slideshows.length)
			{
				var item:SlideshowInfo  = RunTime.book.slideshows[i];
				if (item.pageNum == current)
				{
					slides.push(item);
				}
			}
		}
		this.bookContext.slideshow = slides;
		updateSlideshow();
	}
	
	
	public function loadCtxHotlinks():Void
	{
		var links:Array<HotLink> = new Array<HotLink>();
		if (RunTime.book != null && RunTime.book.hotlinks != null)
		{
			var current:Int = 0;
			if (currentPageNum != null) current = currentPageNum;
			for (i in 0 ... RunTime.book.hotlinks.length)
			{
				var item:HotLink  = RunTime.book.hotlinks[i];
				if (item.pageNum == current)
				{
					links.push(item);
				}
			}
		}
		this.bookContext.hotlinks = links;
		
		
	}
	
	public function loadCtxVideos():Void
	{
		var videos:Array<VideoInfo> = new Array<VideoInfo>();
		if (RunTime.book != null && RunTime.book.videos != null)
		{
			var current:Int = 0;
			if (currentPageNum != null) current = currentPageNum;
			for (i in 0 ... RunTime.book.videos.length)
			{
				var item:VideoInfo  = RunTime.book.videos[i];
				if (item.pageNum == current)
				{
					videos.push(item);
				}
			}
		}
		this.bookContext.videos = videos;
	}
	
	public function hideTopBar():Void
	{
		setVisible(topBar, false);
		currentTopBarButton = null;
	}
	
	public function setVisible(dom:HtmlDom, val:Bool):Void
	{
		if (val == true)
		{
			dom.style.display = "inline";
		}
		else
		{
			dom.style.display = "none";
		}
	}
	
	public function setTopTitle(val:String):Void
	{
		var dom:HtmlDom = Lib.document.getElementById("topTitle");
		dom.innerHTML = L.s(val);
	}
	
	public function resetAndShowTopBar(type:String = ""):Void
	{
		
		resetNoteButton();
		resetHighlightButton();
		
		var dom:HtmlDom = this.topBar;
		dom.style.height = "0px";
		var step:Int = 30;
		var height:Int = 300;
		setVisible(topBarContent, false);
		setVisible(topFullTextContent, false);
		if (type == "text")
		{
			dom.setTopBarMaxSize();
			topFullTextContent.setTopFullTextContentMaxSize();
			height = Std.int(RunTime.clientHeight-45);
			step = Std.int(step / 10);
		}
		else
		{
			dom.setTopBarDefaultSize();
		}
		
		var t:Tweener = new Tweener();
		var self:FlipBook = this;
		self.setVisible(self.topBarContent, false);
		t.start(10);
		t.onChange = function(count:Int):Void
		{
			if (count < 10)
			{
				dom.style.height =  Std.string(count * step) + "px";				
			}
			else
			{
				dom.style.height =  Std.string(height) + "px";				
				
				if (type == "text")
				{
					self.setVisible(self.topFullTextContent, true);					
				}
				else
				{
					self.setVisible(self.topBarContent, true);					
				}
				if (type == "search")
				{
					self.focusSearchInput();
				}
			}
		}
		setVisible(topBar, true);
		topBarContent.innerHTML = "";		
	}
	
	public function focusSearchInput():Void
	{
		//注: ipad 上不支持focus
		
		var t:Tweener = new Tweener();
		var self:FlipBook = this;
		t.start(10);
		t.onChange = function(count:Int):Void
		{
			if (count == 10)
			{
				var input:HtmlDom = self.getSearchInputDom();
				input.focus();
			}
		}
	}
	
	public var currentTopBarButton:HtmlDom;
	
	public function onEmailClick(e:Event):Void {
		
		this.stopFlip();
		if (currentTopBarButton == btnEmail)
		{
			hideTopBar();
			return;
		}
		
		resetAndShowTopBar("email");
		currentTopBarButton = btnEmail;
		setTopTitle("ShareThisFlipBook");
		if (RunTime.contentInfo != null)
		{
			var html:String = HtmlHelper.toEmailHtml();
			topBarContent.innerHTML = html;
			
		}
		
		HideBarOnPhone();
	}
	
	public function onSnsClick(e:Event):Void {
		this.stopFlip();
		if (currentTopBarButton == btnSns)
		{
			hideTopBar();
			return;
		}
		resetAndShowTopBar("sns");
		currentTopBarButton = btnSns;
		setTopTitle("ShareOnSocialNetwork");
		if (RunTime.contentInfo != null)
		{
			var html:String = HtmlHelper.toSnsHtml(RunTime.shareInfo);
			topBarContent.innerHTML = html;
			
		}
		HideBarOnPhone();
	}
	
	public function onContentsClick(e:Event):Void
	{
		this.stopFlip();
		if (currentTopBarButton == btnContents)
		{
			hideTopBar();
			return;
		}
		
		resetAndShowTopBar("toc");
		currentTopBarButton = btnContents;
		setTopTitle("TableOfContents");
		if (RunTime.contentInfo != null)
		{
			var html:String = HtmlHelper.toContentsHtml(RunTime.contentInfo);
			topBarContent.innerHTML = html;
			
		}
		HideBarOnPhone();
		
	}
	
	private function HideBarOnPhone() {
		var hide:Bool = false;
		if (RunTime.clientWidth < 600) hide = true;
		if (Lib.window.navigator.userAgent.indexOf("iPhone") != -1)  hide = true;
		
		
		if (hide)
		{
			this.hideBottomBar();
		}
	}
	
	public function onThumbsClick(e:Event):Void
	{
		//Lib.alert("onThumbsClick");
		//return;
		
		this.stopFlip();
		if (currentTopBarButton == btnThumbs)
		{
			hideTopBar();
			return;
		}

		resetAndShowTopBar("thumbs");
		setTopTitle("ThumbnailView");
		currentTopBarButton = btnThumbs;
		var html:String = HtmlHelper.toThumbsHtml(RunTime.book.pages);
		topBarContent.innerHTML = html;
		HideBarOnPhone();
	}
	
	public function onSearchClick(e:Event):Void
	{
		this.stopFlip();
		if (currentTopBarButton == btnSearch)
		{
			hideTopBar();
			return;
		}

		resetAndShowTopBar("search");
		setTopTitle("Search");
		currentTopBarButton = btnSearch;
		var html:String = HtmlHelper.toSearchHtml();
		topBarContent.innerHTML = html;
		HideBarOnPhone();
	}
	
	public function onTbPageFocus(e:Event):Void
	{
		this.stopFlip();
		var obj:Dynamic = this.tbPage;
		obj.value = "";
	}
	
	public var searchWord:String;
	public function search():Void
	{
		var input:Dynamic = this.getSearchInputDom();
		var word:String = input.value;
		word = StringTools.trim(word);
		if (word == "") return;
		searchWord = word.toLowerCase();
		RunTime.requestSearch(searchCore);
		RunTime.logSearch(searchWord);
	}
	
	public function inputPwd():Void
	{
		var dom:HtmlDom = this.cvsOthers;
		var inputDom:Dynamic = dom.getElementsByTagName("input")[0];
		var word:String = inputDom.value;
		word = StringTools.trim(word);
		RunTime.tryPwd(word);
	}
	
	public function unlockPage():Void {
		var dom:HtmlDom = this.cvsOthers;
		var inputDom:Dynamic = dom.getElementsByTagName("input")[0];
		var word:String = inputDom.value;
		word = StringTools.trim(word);
		RunTime.tryUnlock(word);
	}
	
	public function getSearchInputDom():HtmlDom
	{
		var dom:HtmlDom = this.topBarContent;
		var inputDom:Dynamic = dom.getElementsByTagName("input")[0];
		return inputDom;
	}
	
	public function searchCore(pages:Array<Page>):Void
	{
		if (searchWord == "") return;
		var list:Array<Dynamic> = searchInPages(pages);
		var dom:HtmlDom = this.topBarContent;
		var resultsDom:HtmlDom = dom.getElementsByTagName("div")[1];
		
		if (list == null || list.length == 0)
		{
			resultsDom.innerHTML = "0 " + L.s("SearchResults", "Search Results") + ".";
		}
		else
		{
			resultsDom.innerHTML = HtmlHelper.toSearchResultHtml(list);
		}
	}
	
	public function searchInPages(pages:Array<Page>):Array<Dynamic>
	{
		var results:Array<Dynamic> = [];
		for (i in 0 ... pages.length)
		{
			var item:Page = pages[i];
			if (item.content == null || item.content == "") continue;
			
			if (item.contentLowerCase == null)
			{
				item.contentLowerCase = item.content.toLowerCase();
			}
			var posList:Array<Int> = Util.searchPos(item.contentLowerCase, searchWord);
			results = results.concat(Util.createSearchResults(item.content,searchWord,posList,Std.parseInt(item.id)));
		}
		
		return results;
	}
	
	public var isAutoFliping:Bool;
	public var flipTweener:Tweener;
	
	public function getCurrentPageNum():Int
	{
		var num:Int = 0;
		if (this.currentPageNum != null)
		{
			num = this.currentPageNum;
		}
		return num;
	}
	
	public function removeBookmark(pageNum:Int):Void {
		//Lib.alert(pageNum);
		var i:Int = 0;
		var tmp:Array<Bookmark> = new Array<Bookmark>();
		var currentBookmark:Bookmark = null;
		for (i in 0 ... RunTime.book.bookmarks.length) {
			trace( RunTime.book.bookmarks[i].pageNum);
			if ((pageNum+1) != RunTime.book.bookmarks[i].pageNum) {
				tmp.push(RunTime.book.bookmarks[i]);
				
			}
			else {
				currentBookmark = RunTime.book.bookmarks[i];
				//Lib.alert("got it");
			}
		}
		if (currentBookmark != null) {
			currentBookmark.remove();
		}
		RunTime.book.bookmarks = tmp;
		
		var bookmarks:Array<Bookmark> = RunTime.book.bookmarks;
		var lv:Bool = !checkIfExistBookmark(this.leftPageNum) && this.leftPageNum != -1;
		var rv:Bool = !checkIfExistBookmark(this.rightPageNum) && this.rightPageNum != -1;
		var html:String = HtmlHelper.toBookmarksHtml(bookmarks, RunTime.singlePage, lv, rv);
		if (RunTime.book.rightToLeft) {
			html = HtmlHelper.toBookmarksHtml(bookmarks, RunTime.singlePage, rv, lv);
		}
		topBarContent.innerHTML = html;
		
	}
	
	/**
	 * 设置书签
	 * @param	layout
	 */
	public function addBookmark(layout:Int = 0, text:String):Void {
		
		//Lib.alert("getCurrentPageNum():" + getCurrentPageNum());
		//return;
		
		//Lib.alert("right:" + this.rightPageNum + ", left:" + this.leftPageNum);
		var bookmark:Bookmark = new Bookmark();
		
		//return;
		
		if (layout == -1) {
			if (RunTime.book.rightToLeft) {
				bookmark.pageNum = this.rightPageNum;
			}
			else {
				bookmark.pageNum = this.leftPageNum;
			}
		}
		else if (layout == 1) {
			if (RunTime.book.rightToLeft) {
				bookmark.pageNum = this.leftPageNum;
			}
			else {
				bookmark.pageNum = this.rightPageNum;
			}
		}
		else if (layout == 0) {

			bookmark.pageNum = getCurrentPageNum()+1;
			
		}
		
		//Lib.alert("getCurrentPageNum():" + bookmark.pageNum);
		
		bookmark.text = text;
		Lib.alert(bookmark.pageNum);
		bookmark.save();
		RunTime.book.bookmarks.push(bookmark.clone());
		
		var bookmarks:Array<Bookmark> = RunTime.book.bookmarks;
		var lv:Bool = !checkIfExistBookmark(this.leftPageNum) && this.leftPageNum != -1;
		var rv:Bool = !checkIfExistBookmark(this.rightPageNum) && this.rightPageNum != -1;
		

		var html:String = HtmlHelper.toBookmarksHtml(bookmarks, RunTime.singlePage, lv, rv);
		if (RunTime.book.rightToLeft) {
			html = HtmlHelper.toBookmarksHtml(bookmarks, RunTime.singlePage, rv, lv);
		}
		topBarContent.innerHTML = html;
		
	}
	
	private function checkIfExistBookmark(pageNum:Int):Bool {
		var i:Int = 0;
		for (i in 0 ... RunTime.book.bookmarks.length) {
			if (pageNum == RunTime.book.bookmarks[i].pageNum) {
				return true;
			}
		}
		return false;
	}
	
	public function stopFlip(resetFlipFlag:Bool = true):Void
	{
		if (flipTweener != null)
		{
			flipTweener.onChange = null;
			flipTweener.stop();
			flipTweener = null;
		}
		
		if (resetFlipFlag == true)
		{
			isAutoFliping = false;
			this.btnAutoFlip.style.opacity = 1;
		}
		

		
	}
	
	public function preloadPages(num:Int):Void
	{
		if (RunTime.enablePreload == false) return;
		RunTime.book.preloadPages(num);
	}
	
	public function canTurnRight():Bool
	{
		var num:Int = this.getCurrentPageNum();
		return num < RunTime.book.pages.length - 1;
	}
	
	public function onAutoFlipClick(e:Event):Void
	{
		if (this.zoomLeftPage.src !="") {
			this.zoomLeftPage.src = "";
			this.zoomLeftPage.style.display = "none";
		}
		if (this.zoomRightPage.src != "") {
			this.zoomRightPage.src = "";
			this.zoomRightPage.style.display = "none";
		}
		
		
		stopFlip(false);
		this.hideTopBar();
		
		if (isAutoFliping == true)
		{
			isAutoFliping = false;
			this.btnAutoFlip.style.opacity = 1;
		}
		else
		{
			isAutoFliping = true;
			this.btnAutoFlip.style.opacity = RunTime.autoflipButtonUnselectedAlpha;
			flipTweener = new Tweener();
			var self:FlipBook = this;
			var countOfClip:Int = 50 * RunTime.book.autoFlipSecond;
			flipTweener.onChange = function(count:Int):Void
			{
				//trace(count);
				if (count % countOfClip != 0) return;
				if (self.isAutoFliping == false) return;
				
				if (self.canTurnRight() == true)
				{
					//Lib.alert("autoflip");
					if(RunTime.book.rightToLeft){
						self.turnPage(-1);
					}
					else {
						self.turnPage(1);
					}
				}
				else
				{
					self.stopFlip();
				}
			}
			flipTweener.start(1000000);
		}
	}
	
	public function onZoomClick(e:Event):Void
	{
		//Lib.alert("abc");
		zoomAt(null, null);
	}
	
	public function onShowTxtClick(e:Event):Void
	{
		this.stopFlip();
		if (currentTopBarButton == btnShowTxt)
		{
			hideTopBar();
			return;
		}
		HideBarOnPhone();
		RunTime.invokePageContentsAction(showTxtCore);
	}
	
	private function showTxtCore(pages:Array<Page>):Void
	{
		var result:String = getFullText(pages);
		resetAndShowTopBar("text");
		setTopTitle("FullText");
		currentTopBarButton = btnShowTxt;
		topFullTextContent.innerHTML = result;
		this.topFullTextContent.scrollTop = 0;
	}
	
	private function updateFullText():Void
	{
		RunTime.invokePageContentsAction(updateFullTextCore);
	}
	
	private function updateFullTextCore(pages:Array<Page>):Void
	{
		var result:String = getFullText(pages);
		topFullTextContent.innerHTML = result;
		this.topFullTextContent.scrollTop = 0;
	}
	
	private function getFullText(pages:Array<Page>):String
	{
		var result:String = "";
		var pg:Int = this.getCurrentPageNum();
		for (i in 0 ... pages.length)
		{
			var item:Page = pages[i];
			if (item.num == pg)
			{
				result += "<br />";
				result += "<br />";
				result += "==== Page " + Std.string(pg+1) + " ====";
				result += "<br />";
				result += "<br />";
				result += item.content;
				result += "<br />";
				result += "<br />";
				break;
			}
		}
		
		result = StringTools.replace(result, "\n", "<br />");
		return result;
	}
	
	private function getCurrentPageAudios():Dynamic
	{
		var audios:Array<AudioInfo> = RunTime.book.audios;
		var match:Dynamic = { left:null, right:null };
		var pg:Int = this.getCurrentPageNum();
		for (i in 0 ... audios.length)
		{
			var item:AudioInfo = audios[i];
			if (item.pageNum == pg)
			{
				match.left = item;
			}
		}
		return match;
	}
	
	public function hideBottomBar(e:Event = null, animate:Bool = true, atOnce:Bool=false):Void
	{
		
		if (e != null)
		{
			var t:HtmlDom = e.target;
			if ( t == btnAutoFlip
				|| t == btnContents
				|| t == btnFirstPage
				|| t == btnLastPage
				|| t == btnNextPage
				|| t == btnPrevPage
				|| t == btnSearch
				|| t == btnThumbs
				|| t == tbPage
				|| t == imgLogo
			)
			{
				return;
			}
		}
		
		/*
		if (animate == false)
		{
			this.bottomBarBg.style.opacity = 0;
			this.bottomBar.style.display = "none";
			this.topMenuBarBg.style.opacity = 0;
			this.topMenuBar.style.display = "none";
			RunTime.saveBottomBarVisible(false);
		}
		
		var self:FlipBook = this;
		var alpha:Float = RunTime.bottomBarAlpha;
		var max:Int = 60;
		var t:Tweener = new Tweener();
		t.onChange = function(count:Int):Void
		{
			var alpha:Float = alpha - count * alpha / max;
			self.bottomBarBg.style.opacity = alpha;
			self.topMenuBarBg.style.opacity = alpha;
			//self.bottomBarBg.style.top = 
			//self.topMenuBarBg.style.top = 
			if (alpha < 0 ) alpha = 0;
			if (alpha < 0.05)
			{
				self.bottomBar.style.display = "none";
				self.topMenuBar.style.display = "none";
			}
		}
		t.start(max);
		*/

		if(atOnce){
			//Lib.alert("atonce");
			this.topMenuBarBg.style.cssText  = "opacity:0 ; " ;
			//this.bottomBarBg.style.cssText  = "opacity:0 ;-webkit-transform: translate(0 px, -40px)  ; -webkit-transition: 0.5s ease-out; " ;
			
			//this.bottomBarBg.style.cssText  = "opacity:0 ;-webkit-transform: translate(0 px, -149px)  ; -webkit-transition: 0.5s ease-out; " ;
			
			//this.bottomBar.style.cssText  = "opacity: 0 ; height:0px  ;" ;
			this.bottomBar.style.cssText  = "opacity: 0 ;" ;
			//lastAnimationTime = null;
		}
		else {
			
			//this.topMenuBarBg.style.cssText  = "opacity:0 ; -webkit-transition: 0.3s ease-out; " ;
			
			this.topMenuBarBg.style.cssText  = "opacity:0 ; -webkit-transition: 0.3s ease-out; " ;
			
			
			//this.bottomBar.style.cssText  = "opacity: 0 ; height:0px  ; -webkit-transition: 0.3s ease-out; " ;
			this.bottomBar.style.cssText  = "opacity: 0 ; -webkit-transition: 0.3s ease-out; " ;
			bCanGestureZoom = false;
			
		}
		
		if (e != null) {
			bShowBottomBar = false;
			
		}
		
		RunTime.saveBottomBarVisible(false);
	}
	
	private function getCurrentBBV():String
	{
		if (bottomBar.style.display == "inline-block") return "1";
		else return "0";
	}
	
	public function showBottomBar(e:Event = null):Void
	{
		//Lib.alert("showBottomBar");
		
		//this.topMenuBarBg.style.cssText  = "opacity:" +  RunTime.bottomBarAlpha +
		//	"; -webkit-transform: translate( 0px,40px)  ; -webkit-transition: 0.3s ease-out; " ;
		
		this.topMenuBarBg.style.cssText  = "opacity:" +  RunTime.bottomBarAlpha +
			";  -webkit-transition: 0.3s ease-out; " ;
		
		
		/*
		this.bottomBarBg.style.cssText  = "opacity:" +  RunTime.bottomBarAlpha +
			";-webkit-transform: translate(0px,-40px)  ; -webkit-transition: 0.5s ease-out; " ;
		*/
		
		//this.bottomBar.style.cssText  = "opacity:" +  1 +
		//	";height:49px  ; -webkit-transition: 0.3s ease-out; " ;
			
		this.bottomBar.style.cssText  = "opacity:" +  1 +
			"; -webkit-transition: 0.3s ease-out; " ;
			
		bottomBar.style.display = "inline-block";
		bottomBarBg.style.opacity = RunTime.bottomBarAlpha;
		//bottomBarBg.style.top = RunTime.clientHeight + "px";
		
		topMenuBar.style.display = "inline-block";
		//topMenuBarBg.style.opacity = RunTime.bottomBarAlpha;
			
		bCanGestureZoom = false;
		
		//lastAnimationTime = Date.now();
		RunTime.saveBottomBarVisible(true);
		
		bShowBottomBar = true;
	}
	
	public function clearSlideshow():Void {
		this.cvsSlideshow.innerHTML = "";
		
		var slides:Array<SlideshowInfo> = bookContext.slideshow;
		if (slides != null) {
			for (i in 0 ... slides.length)
			{
				var item:SlideshowInfo = slides[i];
				item.stopTweener();
			}
		}
	}
	
	public function updateSlideshow():Void {

		var slides:Array<SlideshowInfo> = bookContext.slideshow;
		if (slides != null) {
			for (i in 0 ... slides.length)
			{
				var item:SlideshowInfo = slides[i];
				renderSlideshow(item);
				item.startTweener();
			}
		}
	}
	
	public function renderSlideshow(item:SlideshowInfo):Void
	{
		this.cvsSlideshow.innerHTML += HtmlHelper.toSlideshow(item);
		
		
	}
	
	public function clearVideos():Void
	{
		this.cvsVideo.innerHTML = "";
	}
	
	public function updateVideos():Void
	{
		this.loadCtxVideos();
		var videos:Array<VideoInfo> = bookContext.videos;
		if (videos != null)
		{
			for (i in 0 ... videos.length)
			{
				var item:VideoInfo = videos[i];
				renderVideo(item);
			}
		}
		
		this.attachVideoTouchEvents();
	}
	
	public function renderVideo(item:VideoInfo):Void
	{
		//this.cvsVideo.style.cssText = HtmlHelper.toVideoHtml(item).split("|")[1];
		this.cvsVideo.innerHTML += HtmlHelper.toVideoHtml(item);
		
	}
	
	public function updateAudios():Void
	{
		var audios:Dynamic = getCurrentPageAudios();
		if (audios.left != null || audios.right != null )
		{
			cvsLeftPageBgAudio.innerHTML = HtmlHelper.toPopupPageAudiosHtml(audios.left, true);
			cvsRightPageBgAudio.innerHTML = HtmlHelper.toPopupPageAudiosHtml(audios.right, false);
		}
		else
		{
			RunTime.clearBgAudio();
		}
	}
	
	public function loadCtxButtons():Void
	{
		var buttons:Array<ButtonInfo> = new Array<ButtonInfo>();
		if (RunTime.book != null && RunTime.book.buttons != null)
		{
			var current:Int = 0;
			if (currentPageNum != null) current = currentPageNum;
			for (i in 0 ... RunTime.book.buttons.length)
			{
				var item:ButtonInfo  = RunTime.book.buttons[i];
				if (item.pageNum == current)
				{
					buttons.push(item);
				}
				else if (item.layer == "foreground") {
					
					buttons.push(item);
				}
			}
		}
		this.bookContext.buttons = buttons;
	}
	
	public function loadCurrentBookmark() {
		Lib.alert( RunTime.book.bookmarks.length);
		var bms:Array<Bookmark> = new Array<Bookmark>();
		if (RunTime.book != null && RunTime.book.bookmarks != null) {
			for (i in 0 ... RunTime.book.bookmarks.length) {
				var bm:Bookmark = RunTime.book.bookmarks[i];
				Lib.alert(bm.text);
				if (bm.pageNum == currentPageNum) {
					bms.push(bm);
				}
			}
		}
		this.bookContext.bookmarks = bms;
	}
	
	public function loadCtxHighLights():Void {
		
		var highlights:Array<HighLight> = new Array<HighLight>();
		if (RunTime.book != null && RunTime.book.highlights != null) {
			var current:Int = 0;
			if (currentPageNum != null) current = currentPageNum;
			for (i in 0 ... RunTime.book.highlights.length)
			{
				var item:HighLight  = RunTime.book.highlights[i];
				if (item.pageNum == current)
				{
					highlights.push(item);
				}
			}
		}
		this.bookContext.highlights = highlights;
		
		/*
		var notes:Array<Note> = new Array<Note>();
		if (RunTime.book != null && RunTime.book.notes != null) {
			var current:Int = 0;
			if (currentPageNum != null) current = currentPageNum;
			for (i in 0 ... RunTime.book.notes.length)
			{
				var item:Note  = RunTime.book.notes[i];
				if (item.pageNum == current)
				{
					notes.push(item);
				}
			}
		}
		this.bookContext.notes = notes;
		*/
	}
	
	
	public function loadCtxNotes():Void {
		
		var notes:Array<NoteIcon> = new Array<NoteIcon>();
		if (RunTime.book != null && RunTime.book.notes != null) {
			var current:Int = 0;
			if (currentPageNum != null) current = currentPageNum;
			for (i in 0 ... RunTime.book.notes.length)
			{
				var item:NoteIcon  = RunTime.book.notes[i];
				if (item.pageNum == current)
				{
					notes.push(item);
				}
			}
		}
		this.bookContext.notes = notes;
		/*
		var notes:Array<Note> = new Array<Note>();
		if (RunTime.book != null && RunTime.book.notes != null) {
			var current:Int = 0;
			if (currentPageNum != null) current = currentPageNum;
			for (i in 0 ... RunTime.book.notes.length)
			{
				var item:Note  = RunTime.book.notes[i];
				if (item.pageNum == current)
				{
					notes.push(item);
				}
			}
		}
		this.bookContext.notes = notes;
		*/
	}
	
	public function showPopupAudio(item:Dynamic):Void
	{
		item.url = item.destination;
		var pageNum:Int = item.pageNum;
		var audio:AudioInfo = new AudioInfo();
		audio.pageNum = pageNum;
		audio.url = item.destination;
		this.cvsLeftPageBgAudio.innerHTML = "";
		this.cvsLeftPageBgAudio.innerHTML = HtmlHelper.toPopupPageAudiosHtml(audio, true);
		var item:Dynamic = Lib.document.getElementById("cvsLeftPageBgAudio").getElementsByTagName("audio")[0];
		item.play();
	}
	
	public function attachVideoTouchEvents():Void
	{
		var list:Array<HtmlDom> = findVideoHtmlDoms();
		for (i in 0 ... list.length)
		{
			var item:HtmlDom = list[i];
			//hackHtmlDom(item);
			//hackHtmlDom(item.firstChild);
		}
	}
	
	private function hackHtmlDom(item:HtmlDom):Void
	{
		
		item.onclick = this.forbidden;
		item.ontouchstart = this.forbidden;
		item.ontouchmove = this.forbidden;
		item.ontouchend = this.forbidden;
		item.ontouchcancel = this.forbidden;
		item.gestureend = this.forbidden;
		item.gesturestart = this.forbidden;
		item.gesturechange = this.forbidden;
		item.onscroll = this.forbidden;
		item.onmousewheel = this.forbidden;
		item.ondblclick = this.forbidden;
	}
	
	public function findVideoHtmlDoms():Array<HtmlDom>
	{
		var list:Array<HtmlDom> = new Array<HtmlDom>();
		if (this.cvsVideo != null)
		{
			var c:HtmlCollection<HtmlDom> = this.cvsVideo.childNodes;
			for (i in 0 ... c.length)
			{
				list.push(c[i]);
			}
		}
		return list;
	}
	
	public function updateVideoLayout():Void
	{
		var list:Array<HtmlDom> = findVideoHtmlDoms();
		var videos:Array<VideoInfo> = new Array<VideoInfo>();
		for (i in 0 ... list.length)
		{
			var dom:HtmlDom = list[i];
			for (j in 0 ... RunTime.book.videos.length)
			{
				var video:VideoInfo = RunTime.book.videos[j];
				if (video.id == dom.id)
				{
					video.updateLayout(dom);
				}
			}
		}
	}
	
	public function resetZoom() {
		startZoomGesture = false;
		startFingerDistance = 0;
		startMoveGesture = false;
		page_offsetX = 0;
		page_offsetY = 0;
		last_moveX = 0;
		last_moveY = 0;
	
		init_moveX = 0;
		init_moveY = 0;
	}
	
	public function onButtonMaskClick(e:Event):Void
	{
		resetNoteButton();
		
		bStartHighLight = !bStartHighLight;
		if (bStartHighLight) {
			this.btnMask.style.backgroundColor = "#ff00ff";
		}
		else {
			this.btnMask.style.backgroundColor = "";
		}
		
		HideBarOnPhone();
	}
	
	public function onButtonNoteClick(e:Event):Void
	{
		resetHighlightButton();
		
		bStartNote = !bStartNote;
		if (bStartNote) {
			this.btnNote.style.backgroundColor = "#ff00ff";
		}
		else {
			this.btnNote.style.backgroundColor = "";
		}
		
		HideBarOnPhone();
	}
	
	public function resetNoteButton():Void {
		bStartNote = false;
		this.btnNote.style.backgroundColor = "";
		
	}
	
	public function resetHighlightButton():Void {
		bStartHighLight = false;
		this.btnMask.style.backgroundColor = "";
	}
	
	//bStartNote
	
	public function onButtonBookmark(e:Event):Void {
		this.stopFlip();
		if (currentTopBarButton == btnBookMark)
		{
			hideTopBar();
			return;
		}

		resetAndShowTopBar("bookmarks");
		setTopTitle("BookmarkView");
		currentTopBarButton = btnBookMark;
		
		var bookmarks:Array<Bookmark> = RunTime.book.bookmarks;
		var lv:Bool = !checkIfExistBookmark(this.leftPageNum) && this.leftPageNum != -1;
		var rv:Bool = !checkIfExistBookmark(this.rightPageNum) && this.rightPageNum != -1;
		bookmarks.sort(f_sort);
		var html:String = HtmlHelper.toBookmarksHtml(bookmarks, RunTime.singlePage, lv, rv);
		if (RunTime.book.rightToLeft) {
			html = HtmlHelper.toBookmarksHtml(bookmarks, RunTime.singlePage, rv, lv);
		}
		topBarContent.innerHTML = html;
		
		HideBarOnPhone();
	}
	
	private function f_sort(x:Bookmark, y:Bookmark ):Int {
		if (x.pageNum > y.pageNum) return 1;
		if (x.pageNum == y.pageNum) return 0;
		return -1;
	}
}