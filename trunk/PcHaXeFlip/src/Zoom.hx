import core.DrawParams;
import core.Html5Image;
import core.HotLink;
import core.VideoInfo;
import core.ButtonInfo;
import js.Dom;
import js.Lib;
import orc.utils.ImageMetricHelper;
import orc.utils.UrlParam;
import orc.utils.Util;
import core.HtmlHelper;

/**
 * ...
 * @author xiaotie
 */

class Zoom 
{
	private static var imgSrc:String = "";
	private static var pageNum:String = "";
	private static var bookId:String = "";
	private static var analyticsUA:String = "";
	private static var bookTitle:String = "";
	private static var bbv:String = ""; // bottom bar visible
	private static var pcode:String = "";
	private static var pageWidth:Float;
	private static var pageHeight:Float;
	private static var xScale:Float;
	private static var yScale:Float;
	
	private static var cvsZoom:Canvas;
	private static var cvsZoomDom:HtmlDom;
	private static var mask:HtmlDom;
	private static var maskPopup:HtmlDom;
	private static var img:Html5Image;
	private static var hotlinks:Array<HotLink> = [];
	private static var videos:Array<VideoInfo> = [];
	private static var buttons:Array<ButtonInfo> = [];
	private static var clientWidth:Float;
	private static var clientHeight:Float;
	private static var xOffset:Float = 0;
	private static var yOffset:Float = 0;
	
	private static function getContext():CanvasRenderingContext2D
	{
		return cvsZoom.getContext("2d");
	}
	
	public static function Load():Void
	{
		
		cvsZoomDom = Lib.document.getElementById("cvsZoom");
		mask = Lib.document.getElementById("mask");
		maskPopup = Lib.document.getElementById("maskPopup");
		maskPopup.onclick = forbidden;
		maskPopup.ondblclick = onDblClick;
		maskPopup.ontouchstart = forbidden;
		maskPopup.ontouchmove = forbidden;
		maskPopup.ontouchend = forbidden;
		maskPopup.ontouchcancel = forbidden;
		maskPopup.gestureend = forbidden;
		maskPopup.gesturestart = forbidden;
		maskPopup.gesturechange = forbidden;
		maskPopup.onscroll = forbidden;
		maskPopup.onmousewheel = forbidden;
		
		mask.ondblclick = onDblClick;

		var dy:Dynamic = cvsZoomDom;
		cvsZoom = dy;
		mask.ontouchstart = onZoom;
		clientWidth = Lib.window.document.body.clientWidth;
		clientHeight = Lib.window.document.body.clientHeight;
		RunTime.clientWidth = clientWidth;
		RunTime.clientHeight = clientHeight;
		
		var params:Array <UrlParam>  = Util.getUrlParams();
		for (i in 0 ... params.length)
		{
			var item:UrlParam = params[i];
			if (item.key == "img")
			{
				imgSrc = item.value;
			}
			else if(item.key == "bookId")
			{
				bookId = item.value;
			}
			else if(item.key == "page")
			{
				pageNum = item.value;
			}
			else if(item.key == "pw")
			{
				pageWidth = Std.parseFloat(item.value);
			}
			else if(item.key == "ph")
			{
				pageHeight = Std.parseFloat(item.value);
			}
			else if (item.key == "bookTitle")
			{
				bookTitle = item.value;
				bookTitle = StringTools.urlDecode(bookTitle);
			}
			else if (item.key == "bbv")
			{
				bbv = item.value;
			}
			else if (item.key == "ua")
			{
				analyticsUA = item.value;
			}
			else if (item.key == "pcode")
			{
				pcode = item.value;
			}
		}
		
		Lib.document.title = bookTitle + " - Page " + Std.string(Std.parseInt(pageNum)+1);
		img = new Html5Image(imgSrc, onLoadImage);
		RunTime.useAnalyticsUA(analyticsUA, bookId);
		RunTime.logPageView(Std.parseInt(pageNum)+1);
	}
	
	private static function forbidden(e:Event):Void
	{
		e.stopPropagation();
		//e.preventDefault();
	}
	
	private static function onLoadImage():Void
	{
		var w:Int = img.image.width;
		var h:Int = img.image.height;
		cvsZoom.width = Std.int(Math.max(pageWidth,Math.max(w, clientWidth)));
		cvsZoom.height = Std.int(Math.max(pageHeight, Math.max(h, clientHeight)));
		mask.style.width = Std.string(cvsZoom.width) + "px";
		mask.style.height = Std.string(cvsZoom.height) + "px";
		//maskPopup.style.width = Std.string(cvsZoom.width) + "px";
		//maskPopup.style.height = Std.string(cvsZoom.height) + "px";
		xOffset = 0.5 *( cvsZoom.width - Math.max(img.image.width,pageWidth));
		yOffset = 0.5 * ( cvsZoom.height - Math.max(img.image.height,pageHeight));
		xScale = w / pageWidth;
		yScale = h / pageHeight;
		draw();
		RunTime.requestHotlinks(loadHotlinks);
		RunTime.requestButtons(loadButtons);
		RunTime.requestVideos(loadVideos);
	}
	
	private static function draw():Void
	{
		var ctx:CanvasRenderingContext2D = getContext();
		var dp:DrawParams = getDrawParams();
		ctx.drawImage(img.image, dp.sx, dp.sy, dp.sw, dp.sh, dp.dx, dp.dy, dp.dw, dp.dh);
	}
	
	private static function getDrawParams():DrawParams
	{
		var dp:DrawParams = new DrawParams();
		dp.sx = 0;
		dp.sy = 0;
		dp.sw = img.image.width;
		dp.sh = img.image.height;
		dp.dx = xOffset;
		dp.dy = yOffset;
		dp.dw = Math.max(pageWidth, dp.sw);
		dp.dh = Math.max(pageHeight, dp.sh);
		return dp;
	}
	
	private static function loadHotlinks():Void
	{
		var list:Array<HotLink> = RunTime.book.hotlinks;
		for (i in 0 ... list.length)
		{
			var item:HotLink = list[i];
			if (Std.string(item.pageNum) == pageNum)
			{
				hotlinks.push(item);
			}
		}
		renderHotlinks();
	}
	
	private static function loadVideos():Void
	{
		var list:Array<VideoInfo> = RunTime.book.videos;
		for (i in 0 ... list.length)
		{
			var item:VideoInfo = list[i];
			if (Std.string(item.pageNum) == pageNum)
			{
				videos.push(item);
			}
		}
		renderVideos();
	}
	
	private static function loadButtons():Void
	{
		var list:Array<ButtonInfo> = RunTime.book.buttons;
		for (i in 0 ... list.length)
		{
			var item:ButtonInfo = list[i];
			if (Std.string(item.pageNum) == pageNum)
			{
				buttons.push(item);
			}
		}
		renderButtons();
	}
	
	private static function renderHotlinks():Void
	{
		var list:Array<HotLink> = hotlinks;
		var ctx:CanvasRenderingContext2D = getContext();
		for (i in 0 ... list.length)
		{
			var item:HotLink = list[i];
			renderHotlink(ctx,item);
		}
	}
	
	private static function renderHotlink(ctx:CanvasRenderingContext2D, link:HotLink):Void
	{
		link.loadToRect(ctx, xOffset + link.x * xScale, yOffset + link.y * yScale, link.width * xScale, link.height * yScale);
	}
	
	private static function renderVideos():Void
	{
		var dom:HtmlDom = Lib.document.getElementById("cvsVideo");
		for (i in 0 ... videos.length)
		{
			var item:VideoInfo = videos[i];
			item.x = item.x * xScale;
			if (item.youtubeId == null || item.youtubeId == "")
			{
				dom.innerHTML += HtmlHelper.toRectVideoHtml(item, xOffset + item.x * xScale, yOffset + item.y * yScale, item.width * xScale, item.height * yScale);	
			}
			else
			{
				dom.innerHTML += HtmlHelper.toRectYoutubeVideoHtml(item, xOffset + item.x * xScale, yOffset + item.y * yScale, item.width * xScale, item.height * yScale);	
			}
		}
	}
	
	private static function renderButtons():Void
	{
		var list:Array<ButtonInfo> = buttons;
		var ctx:CanvasRenderingContext2D = getContext();
		for (i in 0 ... list.length)
		{
			var item:ButtonInfo = list[i];
			item.loadToContext2DRect(ctx,xOffset + item.x * xScale, yOffset + item.y * yScale, item.width * xScale, item.height * yScale);
		}
	}
	
	private static function onDblClick(e:Event):Void {
		zoomOut();
	}
	
	private static var lastTouchTime:Date;
	
	private static function onZoom(e:Event):Void
	{
		var date:Date = Date.now();
		
		if (lastTouchTime != null)
		{
			var lastTime:Float = lastTouchTime.getTime();
			var newTime:Float = date.getTime();
			if (newTime - lastTime < RunTime.doubleClickIntervalMs) // 双击屏幕
			{
				lastTouchTime = null;
				zoomOut();
				return;
			}
		}
		
		lastTouchTime = date;
		
		var obj:Dynamic = e;
		var touch:Dynamic = obj.touches[0];
		if (obj.touches.length > 1)
		{
			zoomOut();
		}
		else
		{
			onClick(e);
		}
	}
	
	public static function zoomOut(num:Int = -1):Void
	{
		
		if (num == -1 || num == null)
		{
			num = Std.parseInt(pageNum);
		}
		
		Lib.window.location.href = RunTime.urlIndex + "?page=" + Std.string(num) + "&bbv=" + bbv + "&pcode=" + pcode;	
	}
	
	private static var popupXOffset:Float = 0;
	private static var popupYOffset:Float = 0;
	
	private static function onClick(e:Event):Void
	{
		var match:HotLink = null;
		var list:Array<HotLink> = hotlinks;
		var obj:Dynamic = e;
		var touch:Dynamic = obj.touches[0];
		var xx:Float = touch.screenX;
		var yy:Float = touch.screenY;
		popupXOffset = xx - touch.clientX;
		popupYOffset = yy - touch.clientY;
		
		for (i in 0 ... list.length)
		{
			var link:HotLink = list[i];
			if (xx >= xOffset + link.x * xScale && xx <= xOffset + link.x * xScale + link.width * xScale 
				&& yy >= yOffset + link.y * yScale && yy <= yOffset + link.y * yScale + link.height * yScale)
			{
				match = link;
				break;
			}
		}
		invokeClickHotlink(match);
		
		var matchButton:ButtonInfo = null;
		for (i in 0 ... buttons.length)
		{
			var button:ButtonInfo = buttons[i];
			if (xx >= xOffset + button.x * xScale && xx <= xOffset + button.x * xScale + button.width * xScale 
				&& yy >= yOffset + button.y * yScale && yy <= yOffset + button.y * yScale + button.height * yScale)
			{
				matchButton = button;
				break;
			}
		}
		invokeClickButton(matchButton);
	}
	
	private static function invokeClickHotlink(link:HotLink):Void
	{
		if (link == null) return;
		link.click(popupXOffset,popupYOffset);
	}
	
	private static function invokeClickButton(item:ButtonInfo):Void
	{
		if (item == null) return;
		item.click(popupXOffset,popupYOffset);
	}
}