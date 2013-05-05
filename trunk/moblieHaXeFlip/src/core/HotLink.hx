package core;

import js.Dom;
import js.Lib;
import orc.utils.DrawHelper;
/**
 * ...
 * @author xiaotie
 */

class HotLink 
{
	public var pageNum:Int;
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;
	public var opacity:Float;
	public var color:String;
	public var destination:String;
	public var htmlText:String;
	public var type:String;
	public var popupWidth:Int;
	public var popupHeight:Int;
	public var youtubeId:String;
	
	public var scale:Float;
	
	public var offsetX:Float;
	
	public var offsetY:Float;
	
	public var target:String = "_blank";
	
	// 书页的layout方式。0 为居中，1 为左书页，1 为右书页
	public var pageLayoutType:Int;
	
	public function new() 
	{
		opacity = 0.8;
		pageLayoutType = 0;
		color = "#333333";
		scale = 1;
		offsetX = 0;
		offsetY = 0;
	}
	
	private function getDrawParams():DrawParams
	{
		var dp:DrawParams = RunTime.getDrawParams(pageLayoutType);
		dp.applyTransform(scale, offsetX, offsetY);
		return dp;
	}
	
	public function loadToRect(ctx:CanvasRenderingContext2D, x:Float,y:Float,w:Float,h:Float):Void
	{
		if (w > 0 && h > 0)
		{
			ctx.fillStyle = DrawHelper.createFillStyle(color, opacity);
			ctx.fillRect(Std.int(x), Std.int(y), Std.int(w), Std.int(h));
		}
	}
	
	public function loadToContext2D(ctx:CanvasRenderingContext2D):Void
	{
		var dp:DrawParams = getDrawParams();
		
		var xx:Float = dp.dx + (x - dp.sx) * dp.scaleX();
		var yy:Float = dp.dy + (y - dp.sy) * dp.scaleY();
		var ww:Float = width * dp.scaleX();
		var hh:Float = height * dp.scaleY();
		loadToRect(ctx, xx, yy, ww, hh);
	}
	
	public function hitTest(mouseX:Float, mouseY:Float):Bool
	{
		var dp:DrawParams = getDrawParams();
		
		var xx:Float = dp.dx + (x - dp.sx) * dp.scaleX();
		var yy:Float = dp.dy + (y - dp.sy) * dp.scaleY();
		var ww:Float = width * dp.scaleX();
		var hh:Float = height * dp.scaleY();
		
		var result:Bool = mouseX >= xx && mouseY >= yy && mouseX <= xx + ww && mouseY <= yy + hh;
		return result;
	}
	
	public function click(popupXOffset:Float = 0,popupYOffset:Float = 0):Void
	{
		switch(type)
		{
			case "":
				if (destination != null)
				{
					if (destination.indexOf("page:") == 0)
					{
						var val:String = destination.substr(5);
						var num:Int = Std.parseInt(val);
						if (RunTime.flipBook != null)
						{
							RunTime.flipBook.turnToPage(num - 1);
						}
						else
						{
							Zoom.zoomOut(num - 1);
						}
					}
					else if (destination.indexOf("mailto:") == 0)
					{
						RunTime.logClickLink(destination);
						Lib.window.location.href = destination;
					}
					else if (destination.indexOf("fun:") == 0) {
						var fun:String = destination.substr(4);
						if (fun == "content") {
							RunTime.flipBook.onContentsClick(null);
						}
						else if (fun == "thumb") {
							RunTime.flipBook.onThumbsClick(null);
						}
						else if (fun == "showtxt") {
							RunTime.flipBook.onShowTxtClick(null);
						}
						else if (fun == "highlight") {
							RunTime.flipBook.onButtonMaskClick(null);
						}
						else if (fun == "bookmark") {
							RunTime.flipBook.onButtonBookmark(null);
						}
						else if (fun == "notes") {
							RunTime.flipBook.onButtonNoteClick(null);
						}
						else if (fun == "autoflip") {
							RunTime.flipBook.onAutoFlipClick(null);
						}
						else if (fun == "download") {
							RunTime.onDownloadClick(null);
						}
						else if (fun == "fliptofront") {
							RunTime.flipBook.turnToFirstPage(null);
						}
						else if (fun == "flipleft") {
							RunTime.flipBook.turnToPrevPage(null);
						}
						else if (fun == "flipright") {
							
							RunTime.flipBook.turnToNextPage(null);
						}
						else if (fun == "fliptoback") {
							RunTime.flipBook.turnToLastPage(null);
						}
						
					}
					else
					{
						RunTime.logClickLink(destination);
						if ("_self" == target) {
							Lib.window.location.href = destination;
						}else {
							Lib.window.open(destination,target);
						}
						//RunTime.logClickLink(destination);
						//Lib.window.location.href = destination;
					}
				}
			case "image":
				/*
				RunTime.showPopupMaskLayer();
				RunTime.setOffset(Lib.document.getElementById("cvsOthers"), popupXOffset, popupYOffset);
				HtmlHelper.toPopupImageHtml(this, function(txt:String):Void
				{
					Lib.document.getElementById("cvsOthers").innerHTML = txt;					
				});
				RunTime.logClickLink(destination);
				*/
				RunTime.showPopupMaskLayer();
				RunTime.setOffset(Lib.document.getElementById("cvsOthers"), popupXOffset, popupYOffset);
				//var cvsOthers:HtmlDom = Lib.document.getElementById("cvsOthers");
				HtmlHelper.toPopupImageHtml(this, function(txt:String):Void
				{
					Lib.document.getElementById("cvsOthers").innerHTML = txt;	
					Lib.document.getElementById("popupImage").style.cssText += " -webkit-transform: scale(1); -webkit-transition: 0.5s ease-out; " ;
				});
				RunTime.logClickLink(destination);
			case "video":
				/*
				RunTime.showPopupMaskLayer();
				RunTime.setOffset(Lib.document.getElementById("cvsOthers"), popupXOffset, popupYOffset);
				Lib.document.getElementById("cvsOthers").innerHTML = HtmlHelper.toPopupVideoHtml(this);
				RunTime.playVideo();
				RunTime.logVideoView(destination, youtubeId);
				*/
				RunTime.showPopupMaskLayer();
				RunTime.setOffset(Lib.document.getElementById("cvsOthers"), popupXOffset, popupYOffset);
				Lib.document.getElementById("cvsOthers").innerHTML = HtmlHelper.toPopupVideoHtml(this);
				Lib.document.getElementById("popupVideo").style.cssText += " -webkit-transform: scale(1); -webkit-transition: 0.5s ease-out; " ;
				
				RunTime.playVideo();
				RunTime.logVideoView(destination, youtubeId);
			case "audio":
				RunTime.flipBook.showPopupAudio(this);
				RunTime.logAudioView(destination);
				RunTime.playAudio();
			case "message":
				/*
				RunTime.showPopupMaskLayer();
				RunTime.setOffset(Lib.document.getElementById("cvsOthers"), popupXOffset, popupYOffset);
				Lib.document.getElementById("cvsOthers").innerHTML = HtmlHelper.toPopupHtml(this);
				*/
				RunTime.showPopupMaskLayer();
				RunTime.setOffset(Lib.document.getElementById("cvsOthers"), popupXOffset, popupYOffset);
				Lib.document.getElementById("cvsOthers").innerHTML = HtmlHelper.toPopupHtml(this);
				Lib.document.getElementById("popupMessage").style.cssText += " -webkit-transform: scale(1); -webkit-transition: 0.5s ease-out; " ;
			case "message-hover":
				RunTime.showPopupMaskLayer();
				RunTime.setOffset(Lib.document.getElementById("cvsOthers"), popupXOffset, popupYOffset);
				Lib.document.getElementById("cvsOthers").innerHTML = HtmlHelper.toPopupHtml(this);
				Lib.document.getElementById("popupMessage").style.cssText += " -webkit-transform: scale(1); -webkit-transition: 0.5s ease-out; " ;
		}
	}
}