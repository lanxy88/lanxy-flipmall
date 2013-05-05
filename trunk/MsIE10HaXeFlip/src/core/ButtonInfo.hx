package core;
import haxe.Timer;
import js.Lib;
import orc.utils.DrawHelper;

/**
 * ...
 * @author 
 */

class ButtonInfo 
{
	public var pageNum:Int;
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;
	public var destination:String;
	public var htmlText:String;
	public var type:String;
	public var image:String;
	public var popupWidth:Int;
	public var popupHeight:Int;
	public var youtubeId:String;
	private var _imagePage:Image;
	public var loaded:Bool;
	private var ctx:CanvasRenderingContext2D;
	public var scale:Float;
	public var offsetX:Float;
	public var offsetY:Float;
	// 书页的layout方式。0 为居中，-1 为左书页，1 为右书页 , 2 为左右两页
	public var pageLayoutType:Int;
	
	public var layer:String = "onpage";
	public var text:String = "";
	public var fontColor:String = "#ffffff";
	public var fontSize:String = "12";
	
	public var target:String = "_blank";
	
	public function new() 
	{
		pageLayoutType = 0;
		scale = 1;
		offsetX = 0;
		offsetY = 0;
	}
	
	private function getDrawParams():DrawParams
	{
		var dp:DrawParams = RunTime.getDrawParams(pageLayoutType);
		if (pageLayoutType == 2) dp = RunTime.getGolobaDrawParams();
		//trace("scale=" + scale + ", offsetX=" + offsetX + ",offsetY=" + offsetY + ",type=" + pageLayoutType);
		dp.applyTransform(scale, offsetX, offsetY);
		return dp;
	}
	
	public function getImagePage(onloadFunc):Image
	{
		if (_imagePage != null) return _imagePage;
		
		var img:Image = new Image();
		img.src = image;
		img.onload = onloadFunc;
		_imagePage = img;
		return _imagePage;
	}
	
	public function loadToContext2D(ctx:CanvasRenderingContext2D):Void
	{
		this.ctx = ctx;
		if (this._imagePage == null)
		{
			var self:ButtonInfo = this;
			this.getImagePage(
				function():Void
				{
					self.loaded = true;
					self.loadToContext2D(self.ctx);
				}
			);
		}
			
		if (this.loaded == true)
		{
			var dp:DrawParams = getDrawParams();
			
			var xx:Float = dp.dx + (x - dp.sx) * dp.scaleX();
			var yy:Float = dp.dy + (y - dp.sy) * dp.scaleY();
			var ww:Float = width * dp.scaleX();
			var hh:Float = height * dp.scaleY();
			
			//trace(dp.scaleX()+ "," + dp.scaleY() + "," + dp.dx + "," + dp.dy);
			
			loadToRect(ctx,xx, yy, ww, hh);
		}
	}
	
	public function loadToContext2DRect(ctx:CanvasRenderingContext2D,x:Float,y:Float,w:Float,h:Float):Void
	{
		this.ctx = ctx;
		if (this._imagePage == null)
		{
			var self:ButtonInfo = this;
			this.getImagePage(
				function():Void
				{
					self.loaded = true;
					self.loadToContext2DRect(self.ctx,self.x,self.y,self.width,self.height);
				}
			);
		}
			
		if (this.loaded == true)
		{
			loadToRect(ctx, x, y, width, height);
		}
	}
	
	public function loadToRect(ctx:CanvasRenderingContext2D, x:Float,y:Float,w:Float,h:Float):Void
	{
		if (w > 0 && h > 0)
		{
			if(this.text == ""){
				ctx.drawImage(_imagePage, 0, 0, _imagePage.width, _imagePage.height, x, y, w, h);
			}
			else {
				ctx.save();
				ctx.fillStyle = this.fontColor;
				ctx.font = this.fontSize +"px " + "san-serif" ;
				ctx.fillText(this.text , x, y+30);
				//ctx.fillRect(Std.int(x),Std.int(y), Std.int(w), Std.int(h));
				ctx.restore();
			}
		}
	}
	
	public function hitTest(mouseX:Float, mouseY:Float):Bool
	{
		if (type == "none") return false;
		
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
		//Lib.alert(destination);	
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
				
				RunTime.showPopupMaskLayer();
				RunTime.setOffset(Lib.document.getElementById("cvsOthers"), popupXOffset, popupYOffset);
				//var cvsOthers:HtmlDom = Lib.document.getElementById("cvsOthers");
				HtmlHelper.toPopupImageHtml(this, function(txt:String):Void
				{
					Lib.document.getElementById("cvsOthers").innerHTML = txt;	
					
					var timer:Timer = new Timer(100);
					timer.run = function() { 
						trace("zoomComplete");
						timer.stop();
						Lib.document.getElementById("popupImage").style.cssText += " transform: scale(1);transition:all 500ms; -ms-transform: scale(1);-ms-transition: all 500ms;" ;
					};
					
					//Lib.alert(Lib.document.getElementById("popupImage").style.cssText);
				});
				RunTime.logClickLink(destination);
			case "video":
				RunTime.showPopupMaskLayer();
				RunTime.setOffset(Lib.document.getElementById("cvsOthers"), popupXOffset, popupYOffset);
				Lib.document.getElementById("cvsOthers").innerHTML = HtmlHelper.toPopupVideoHtml(this);
				//Lib.document.getElementById("popupVideo").style.cssText += " transform: scale(1);transition: width 0.5s ease-out; -ms-transform: scale(1);-ms-transition:width  0.5s ease-out; -webkit-transform: scale(1);-webkit-transition: 0.5s ease-out; " ;
				
				var timer:Timer = new Timer(100);
				timer.run = function() { 
					trace("zoomComplete");
					timer.stop();
					Lib.document.getElementById("popupVideo").style.cssText += " transform: scale(1);transition:all 500ms; -ms-transform: scale(1);-ms-transition: all 500ms;" ;
				};
					
				RunTime.playVideo();
				RunTime.logVideoView(destination, youtubeId);
			case "audio":
				RunTime.flipBook.showPopupAudio(this);
				RunTime.logAudioView(destination);
				RunTime.playAudio();
			case "message":
				RunTime.showPopupMaskLayer();
				RunTime.setOffset(Lib.document.getElementById("cvsOthers"), popupXOffset, popupYOffset);
				Lib.document.getElementById("cvsOthers").innerHTML = HtmlHelper.toPopupHtml(this);
				//Lib.document.getElementById("popupMessage").style.cssText += " transform: scale(1);transition: width 0.5s ease-out; -ms-transform: scale(1);-ms-transition:width  0.5s ease-out; -webkit-transform: scale(1);-webkit-transition: 0.5s ease-out; " ;
				var timer:Timer = new Timer(100);
				timer.run = function() { 
					trace("zoomComplete");
					timer.stop();
					Lib.document.getElementById("popupMessage").style.cssText += " transform: scale(1);transition:all 500ms; -ms-transform: scale(1);-ms-transition: all 500ms;" ;
				};
			case "message-hover":
				RunTime.showPopupMaskLayer();
				RunTime.setOffset(Lib.document.getElementById("cvsOthers"), popupXOffset, popupYOffset);
				Lib.document.getElementById("cvsOthers").innerHTML = HtmlHelper.toPopupHtml(this);
				//Lib.document.getElementById("popupMessage").style.cssText += "transform: scale(1);transition: width 0.5s ease-out; -ms-transform: scale(1); -ms-transition:width 2s ease-out; -webkit-transform: scale(1); -webkit-transition: 0.5s ease-out; " ;
				var timer:Timer = new Timer(100);
				timer.run = function() { 
					trace("zoomComplete");
					timer.stop();
					Lib.document.getElementById("popupMessage").style.cssText += " transform: scale(1);transition:all 500ms; -ms-transform: scale(1);-ms-transition: all 500ms;" ;
				};
		}
	}
}