package ;
import core.BookContext;
import core.HighLight;
import core.Note;
import core.NoteIcon;
import core.SlideshowInfo;
import js.Lib;
import js.Dom;
import core.AudioInfo;
import core.DrawParams;
import core.Page;
import core.PagePair;
import core.HotLink;
import core.VideoInfo;
import core.ButtonInfo;
import core.HtmlHelper;
import core.ZoomStatus;
/**
 * ...
 * @author 
 */

class DoubleFlipBook extends FlipBook
{
	public function new() 
	{
		super();
	}
	
	public override function afterInit():Void
	{
		this.tbPage.style.width = "60px";
	}
	
	public override function checkCanZoom():Bool {
		var p:PagePair = this.getCurrentPair();
		if (p.leftPage != null)
		{
			if (!p.leftPage.canZoom) return false;
		}
		
		if (p.rightPage != null)
		{
			if (!p.rightPage.canZoom) return false;
		}
		return true;
	}

	public override function loadPage(index:Int):Void
	{
		preloadPages(index);
		currentPageNum = index;
		loadCtxHotlinks();
		loadCtxSlideshow();
		loadCtxButtons();
		loadCtxHighLights();
		loadCtxNotes();
		updateVideos();
		var p:PagePair = this.getCurrentPair();
		bookContext.addPage(p.leftPage);			
		bookContext.addPage(p.rightPage);
		if (p.rightPage != null && p.rightPage.locked && RunTime.bLocked) {
			RunTime.flipBook.rightPageLock.style.display = "block";
		}
		if (p.leftPage !=null && p.leftPage.locked && RunTime.bLocked) {
			RunTime.flipBook.leftPageLock.style.display = "block";
		}
				
		bookContext.render();
		//RunTime.divLoading.style.display = "inline";
		if (p.leftPage != null)
		{
			RunTime.logPageView(p.leftPage.num+1);
		}
		
		if (p.rightPage != null)
		{
			RunTime.logPageView(p.rightPage.num+1);
		}
		
		onEnterPage();
	}
	
	private override function getFullText(pages:Array<Page>):String
	{
		var lftPg:Int = -1;
		var rtPg:Int = -1;
		
		var p:PagePair = this.getCurrentPair();
		if (p.leftPage != null)
		{
			lftPg = p.leftPage.num;
		}
		
		if (p.rightPage != null)
		{
			rtPg = p.rightPage.num;
		}
		
		// 考虑到从右向左翻的模式
		if (lftPg > rtPg)
		{
			var tmp:Int = rtPg;
			rtPg = lftPg;
			lftPg = tmp;
		}

		var result:String = "";
		
		for (i in 0 ... pages.length)
		{
			var item:Page = pages[i];
			if (item.num == lftPg)
			{
				result += "<br />";
				result += "<br />";
				result += "==== Page " + Std.string(lftPg+1) + " ====";
				result += "<br />";
				result += "<br />";
				result += item.content;
				result += "<br />";
				result += "<br />";
			}
			else if (item.num == rtPg)
			{
				result += "<br />";
				result += "<br />";
				result += "==== Page " + Std.string(rtPg+1) + " ====";
				result += "<br />";
				result += "<br />";
				result += item.content;
				result += "<br />";
				result += "<br />";
			}
		}
		
		result = StringTools.replace(result, "\n", "<br />");
		return result;
	}
	
	private override function getCurrentPageAudios():Dynamic
	{
		var audios:Array<AudioInfo> = RunTime.book.audios;
		
		var match:Dynamic = { left:null, right:null };
		var lftPg:Int = -1;
		var rtPg:Int = -1;
		
		var p:PagePair = this.getCurrentPair();
		if (p.leftPage != null)
		{
			lftPg = p.leftPage.num;
		}
		
		if (p.rightPage != null)
		{
			rtPg = p.rightPage.num;
		}
		
		for (i in 0 ... audios.length)
		{
			var item:AudioInfo = audios[i];
			if (item.pageNum == lftPg )
			{
				match.left = item;
			}
			else if (item.pageNum == rtPg)
			{
				match.right = item;
			}
		}
		return match;
	}
	
	public override function turnToPage(pageNum:Int):Void
	{
		this.preloadPages(pageNum);
		var current:Int = this.getCurrentPageNum();
		//Lib.alert(current);
		if (current < 0 || current >= RunTime.book.pages.length) return;
		if (pageNum < 0 || pageNum >= RunTime.book.pages.length) return;

		var oldPair:PagePair = new PagePair(current);
		var newPair:PagePair = new PagePair(pageNum);
		var oldNum:Int = oldPair.getNumInDoubleMode();
		var newNum:Int = newPair.getNumInDoubleMode();
		
		if (newNum < 0 || oldNum == newNum) {
			
			return;
		}

		bookContext.removeAllPages();
		bookContext.resetLayoutParams();
		
		this.setCurrentPage(pageNum + 1);
		bookContext.addPage(oldPair.leftPage);			
		bookContext.addPage(oldPair.rightPage);
		bookContext.addPage(newPair.leftPage);			
		bookContext.addPage(newPair.rightPage);
		//RunTime.divLoading.style.display = "inline";
		if (newPair.leftPage != null)
		{
			RunTime.logPageView(newPair.leftPage.num+1);
		}
		
		if (newPair.rightPage != null)
		{
			RunTime.logPageView(newPair.rightPage.num+1);
		}
		
		bookContext.pageOffset = 0;
		var pageOffset:Int = 0;
		var offset:Float = 0;
		// 1 则是右翻，-1 则是左翻
		var dstPageOffset:Float = newNum > oldNum ? 1 : -1;
		
		
		var ldp:DrawParams = RunTime.getDrawParams( -1);
		var rdp:DrawParams = RunTime.getDrawParams(1);
		
		var update:Float->Void = function(val:Float):Void
		{
			var downLeft:Page = oldPair.leftPage;
			var downRight:Page = oldPair.rightPage;
			var upLeft:Page = newPair.leftPage;
			var upRight:Page = newPair.rightPage;
			
			if (dstPageOffset > 0)	// 从右向左翻
			{
				//Lib.alert("Q");
				if (RunTime.book.rightToLeft) {
					
					if (downLeft != null)
					{
						if (val <= 0.5)
						{
							downLeft.drawParams = ldp;
						}
						else
						{
							downLeft.drawParams = ldp.sliceRight(2 - val * 2);
						}
					}
					if (downRight != null)
					{
						
						//Lib.alert(downRight.urlPage);
						/*
						if (val <= 0.5)
						{
							downRight.drawParams = rdp.sliceRight(1 - 2 * val);
							trace(downRight.drawParams.toString());

						}
						else
						{
							downRight.drawParams = null;
						}
						*/
						
					}
					
					if (upLeft != null)
					{
						//Lib.alert("Q");
						upLeft.drawParams = ldp.sliceRight(val, -ldp.dw * 2* (1 - val));
						//Lib.alert(upLeft.urlPage);
					}
					if (upRight != null)
					{
						//Lib.alert("QupR");
						
						upRight.drawParams = rdp.sliceLeft(val);
												
						//trace(upRight.drawParams.toString());
					}
					
				}
				else
				{
					if (downLeft != null)
					{
						if (val <= 0.5)
						{
							//Lib.alert("Q2");
							downLeft.drawParams = ldp;
						}
						else
						{
							downLeft.drawParams = ldp.sliceLeft(2 - val * 2);
						}
					}
					
					if (downRight != null)
					{
						//Lib.alert("q");
						/*
						if (val <= 0.5)
						{
							downRight.drawParams = rdp.sliceLeft(1 - 2 * val);
							
						}
						else
						{
							downRight.drawParams = null;
						}
						*/
					}
					
					if (upLeft != null)
					{
						upLeft.drawParams = ldp.sliceLeft(val, ldp.dw * 2 * (1 - val));
					}
					
					if (upRight != null)
					{
						upRight.drawParams = rdp.sliceRight(val);
						//trace(upRight.drawParams.toString());
					}
				}
			}
			else	// 从左向右翻
			{
				val = - val;
				
				
				
				if (RunTime.book.rightToLeft) {
					if (downLeft != null)
					{
						if (val <= 0.5)
						{
							downLeft.drawParams = ldp.sliceLeft(1 - 2 * val);
						}
						else
						{
							downLeft.drawParams = null;
						}
					}
					
					if (downRight != null)
					{
						if (val <= 0.5)
						{
							downRight.drawParams = rdp;
						}
						else
						{
							downRight.drawParams =  rdp.sliceLeft(2 - val * 2);
						}
					}
					
					if (upLeft != null)
					{
						upLeft.drawParams = ldp.sliceRight(val);
					}
					
					if (upRight != null)
					{
						upRight.drawParams = rdp.sliceLeft(val,  rdp.dw * 2 * (1 - val));
					}
				}
				else{
					if (downLeft != null)
					{
						if (val <= 0.5)
						{
							downLeft.drawParams = ldp.sliceRight(1 - 2 * val);
						}
						else
						{
							downLeft.drawParams = null;
						}
					}
					
					if (downRight != null)
					{
						if (val <= 0.5)
						{
							downRight.drawParams = rdp;
						}
						else
						{
							downRight.drawParams =  rdp.sliceRight(2 - val * 2);
						}
					}
					
					if (upLeft != null)
					{
						upLeft.drawParams = ldp.sliceLeft(val);
					}
					
					if (upRight != null)
					{
						upRight.drawParams = rdp.sliceRight(val, - rdp.dw * 2 * (1 - val));
					}
				}
			}
		};
		
		update(0);
		
		if (tweener != null) 
		{
			tweener.stop();
		}
		
		var self:FlipBook = this;
		var ctx:BookContext = bookContext;
		var maxCount:Float = 8;
		tweener.onChange = function(count:Int):Void
		{
			
			var ratio:Float = count /  maxCount;
			offset = dstPageOffset * ratio * ratio  * ratio;
			
			update(offset);
			if (count == maxCount)
			{
				ctx.clear(true);
				ctx.addPage(newPair.leftPage);
				ctx.addPage(newPair.rightPage);
				self.currentPageNum = pageNum;
				self.loadCtxHotlinks();
				self.loadCtxSlideshow();
				self.loadCtxButtons();
				self.loadCtxHighLights();
				self.loadCtxNotes();
				self.updateVideos();
				self.onEnterPage();
				RunTime.flipBook.rightPageLock.style.display = "none";
				RunTime.flipBook.leftPageLock.style.display = "none";
				if (newPair.rightPage != null && newPair.rightPage.locked && RunTime.bLocked) {
					RunTime.flipBook.rightPageLock.style.display = "block";
				}
				if (newPair.leftPage !=null && newPair.leftPage.locked && RunTime.bLocked) {
					RunTime.flipBook.leftPageLock.style.display = "block";
				}
			}
			self.bookContext.render();
		}
		
		this.clearCtxHotlinks();
		this.clearCtxButtons();
		this.clearCtxNote();
		this.clearCtxHighLight();
		this.clearVideos();
		clearSlideshow();
		tweener.start(Std.int(maxCount));
		hideTopBar();
	}
	
	private function getCurrentPair():PagePair
	{
		var current:Int = 0;
		if (currentPageNum != null) current = currentPageNum;
		return new PagePair(current);
	}
	
	private  function pageZoomOut():Void
	{
		
		zoomStatus = ZoomStatus.normal;

		page_offsetX = 0;
		page_offsetY = 0;
		
		//this.bottomBar.style.display = "inline";
		//this.showBottomBar(null);
		//Lib.alert(RunTime.getBottomBarVisible());
		if (bShowBottomBar) this.showBottomBar(null);
	}
	
	private function pageZoomIn(page:PagePair,point0:Dynamic, point1:Dynamic):Void
	{
		//Lib.alert("ZoomIn");
		zoomStatus = ZoomStatus.zoomed;
		
		if (page == null) return;
		
		if (page.leftPage != null ) {
			//this.hideBottomBar(null,false,true);
			
			if(!page.leftPage.locked){
				this.zoomLeftPage.src = page.leftPage.getBigPageUrl();		
			}
			else {
				//this.zoomLeftPage.src = page.leftPage.getBlankPage();
			}
			
			this.zoomLeftPage.style.display = "inline";
			//this.hideBottomBar();
			
			//this.zoomLeftPage.style.cssText  ="-webkit-transition: 0.5s ease-out; " ;
			
		}
		
		if (page.rightPage != null) {
			//this.hideBottomBar(null,false,true);
			if(!page.rightPage.locked){
				this.zoomRightPage.src = page.rightPage.getBigPageUrl();
			}
			else {
				//this.zoomRightPage.src = page.rightPage.getBlankPage();
			}
			this.zoomRightPage.style.display = "inline";
			//this.hideBottomBar();
			
			//this.zoomRightPage.style.cssText  ="-webkit-transition: 0.5s ease-out; " ;
		}
		//this.bottomBar.style.display = "none";
		//this.hideBottomBar(null);
	}
	
	public override function zoomAt(point0:Dynamic, point1:Dynamic):Void
	{
		//super.zoomAt(point0,point1);
		//return;
		var num:Int = 0;
		if (currentPageNum != null) num = currentPageNum;
		//var page:Page = RunTime.getPage(num);
		var pair:PagePair = this.getCurrentPair();
		if (point0 == null || point1 == null) {
			pageZoomOut();
			
		}
		else {
			
			pageZoomIn(pair, point0, point1);
		}
		/*
		//普通状态
		if (zoomStatus == ZoomStatus.normal) {
			pageZoomIn(pair, point0, point1);
			
		}
		//放大状态
		else if(zoomStatus == ZoomStatus.zoomed) {
			pageZoomOut();
		}
		*/
	}
	
	public override function loadCtxSlideshow():Void
	{
		var slides:Array<SlideshowInfo> = new Array<SlideshowInfo>();
		if (RunTime.book != null && RunTime.book.slideshows != null)
		{
			var pair:PagePair = this.getCurrentPair();
			
			for (i in 0 ... RunTime.book.slideshows.length)
			{
				var item:SlideshowInfo  = RunTime.book.slideshows[i];
				
				var match:Int = pair.match(item.pageNum);
				if(match != 0)
				{
					item.pageLayoutType = match;
					slides.push(item);
				}
			}
		}
		this.bookContext.slideshow = slides;
		updateSlideshow();
	}
	
	
	public override function loadCtxHotlinks():Void
	{
		var links:Array<HotLink> = new Array<HotLink>();
		if (RunTime.book != null && RunTime.book.hotlinks != null)
		{
			var pair:PagePair = this.getCurrentPair();
			
			for (i in 0 ... RunTime.book.hotlinks.length)
			{
				var item:HotLink  = RunTime.book.hotlinks[i];
				var match:Int = pair.match(item.pageNum);
				if(match != 0)
				{
					
					item.pageLayoutType = match;
					links.push(item);
				}
			}
		}
		this.bookContext.hotlinks = links;
	}
	
	public override function loadCtxVideos():Void
	{
		var videos:Array<VideoInfo> = new Array<VideoInfo>();
		if (RunTime.book != null && RunTime.book.videos != null)
		{
			var pair:PagePair = this.getCurrentPair();
			
			for (i in 0 ... RunTime.book.videos.length)
			{
				var item:VideoInfo  = RunTime.book.videos[i];
				var match:Int = pair.match(item.pageNum);
				if(match != 0)
				{
					item.pageLayoutType = match;
					videos.push(item);
				}
			}
		}
		this.bookContext.videos = videos;
	}
	
	public override function setCurrentPage(val:Int):Void
	{
		var count:Int = RunTime.book.pages.length;
		/*
		if (RunTime.book.rightToLeft) {
			val = Std.int(Math.abs(val -count)) +1;
		}
		*/
		//Lib.alert(val);
		
		//RunTime.flipBook.rightPageLock.style.display = "none";
		//RunTime.flipBook.leftPageLock.style.display = "none";
		
		var t:Dynamic = tbPage;
		if (val == 1 )		// 首页
		{
			t.value = Std.string(val);		
			this.leftPageNum = -1;
			this.rightPageNum = val;
			//if (RunTime.getPage(val-1).locked && RunTime.unlocked) {
			//	RunTime.flipBook.rightPageLock.style.display = "block";
			//}
		}
		else if(val % 2 == 0 && val == count)	// 末页
		{
			t.value = Std.string(val);
			this.leftPageNum = val;
			this.rightPageNum = -1;
			
			//if (RunTime.getPage(val-1).locked && RunTime.unlocked) {
			//	RunTime.flipBook.leftPageLock.style.display = "block";
			//}
		}
		else
		{
			var v0:Int = val - val%2;
			var v1:Int = v0 + 1;
			this.leftPageNum = v0;
			this.rightPageNum = v1;
			t.value = Std.string(v0) + "-" + Std.string(v1);
			
			//if (RunTime.getPage(v1-1).locked && RunTime.unlocked) {
			//	RunTime.flipBook.rightPageLock.style.display = "block";
			//}
			//if (RunTime.getPage(v0-1).locked && RunTime.unlocked) {
			//	RunTime.flipBook.leftPageLock.style.display = "block";
			//}
		}
	}
	
	public override function turnPage(pageOffset:Int):Void
	{
		
		var current:Int = 0;
		if (currentPageNum != null) current = currentPageNum;
		
		if (RunTime.book.rightToLeft) {
			pageOffset =  0 - pageOffset;
		}
		
		current = current + pageOffset * 2;
		
		//Lib.alert(current);
		
		if (current < 0) current = 0;
		if (current >= RunTime.book.pages.length)
		{
			current = RunTime.book.pages.length -1;
		}
		this.turnToPage(current);
	}
	
	public override function showPopupAudio(item:Dynamic):Void
	{
		item.url = item.destination;
		var pageNum:Int = item.pageNum;
		var audio:AudioInfo = new AudioInfo();
		audio.pageNum = pageNum;
		audio.url = item.destination;
		if (pageNum % 2 == 1)
		{
			this.cvsLeftPageBgAudio.innerHTML = "";
			this.cvsLeftPageBgAudio.innerHTML = HtmlHelper.toPopupPageAudiosHtml(audio, true);
			var item:Dynamic = Lib.document.getElementById("cvsLeftPageBgAudio").getElementsByTagName("audio")[0];
			item.play();
		}
		else
		{
			this.cvsRightPageBgAudio.innerHTML = "";
			this.cvsRightPageBgAudio.innerHTML = HtmlHelper.toPopupPageAudiosHtml(audio, false);
			var item:Dynamic = Lib.document.getElementById("cvsRightPageBgAudio").getElementsByTagName("audio")[0];
			item.play();
		}
	}
	
	public override function canTurnRight():Bool
	{
		var num:Int = this.getCurrentPageNum();
		var count:Int = RunTime.book.pages.length;
		//trace(num);
		
		if (num % 2 == 1) num ++;
		
		//Lib.alert(num < count - 1);
		return num < count - 1;
	}
	
	public override function loadCtxButtons():Void
	{
		var buttons:Array<ButtonInfo> = new Array<ButtonInfo>();
		if (RunTime.book != null && RunTime.book.buttons != null)
		{
			var pair:PagePair = this.getCurrentPair();
			
			for (i in 0 ... RunTime.book.buttons.length)
			{
				var item:ButtonInfo  = RunTime.book.buttons[i];
				var match:Int = pair.match(item.pageNum);
				if(match != 0 && item.layer == "onpage")
				{
					item.pageLayoutType = match;
					buttons.push(item);
				}
				else if (item.layer == "foreground" ) {
							
					if ((item.pageNum+1)%2 != 0) {
							item.pageLayoutType = 1;
							
					}
					else {
						item.pageLayoutType = -1;
					}

					buttons.push(item);
				}
				
				else if (item.layer == "background") {
					if(pair.leftPage == null && (item.pageNum+1)%2 == 0){
						item.pageLayoutType = -1;
						//item.pageLayoutType = match;
						buttons.push(item);
					}
					if(pair.rightPage == null && (item.pageNum+1)%2 != 0){
						item.pageLayoutType = 1;
						//item.pageLayoutType = match;
						buttons.push(item);
					}
				}
				
			}
		}
		this.bookContext.buttons = buttons;
	}
	
	public override function loadCtxHighLights():Void {
		var pair:PagePair = this.getCurrentPair();
		
		var highlights:Array<HighLight> = new Array<HighLight>();
		if (RunTime.book != null && RunTime.book.highlights != null) {
			
			for (i in 0 ... RunTime.book.highlights.length)
			{
				var item:HighLight  = RunTime.book.highlights[i];
				//trace("pagNumber=" + item.pageNum);
				var match:Int = pair.match(item.pageNum);
				if(match != 0)
				{
					item.pageLayoutType = match;
					
					highlights.push(item);
				}

			}
		}
		this.bookContext.highlights = highlights;

	}
	
	public override function loadCtxNotes():Void {
		var pair:PagePair = this.getCurrentPair();
		
		
		var notes:Array<NoteIcon> = new Array<NoteIcon>();
		if (RunTime.book != null && RunTime.book.notes != null) {
			
			for (i in 0 ... RunTime.book.notes.length)
			{
				var item:NoteIcon  = RunTime.book.notes[i];
				var match:Int = pair.match(item.pageNum);
				if(match != 0)
				{
					item.pageLayoutType = match;
					
					notes.push(item);
				}
			}
		}
		this.bookContext.notes = notes;
	}
	
}