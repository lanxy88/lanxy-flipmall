package core;
import js.Lib;
import js.Dom;
/**
 * ...
 * @author 
 */

class VideoInfo 
{
	public var pageNum:Int;
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;
	public var autoPlay:Bool;
	public var showControl:Bool;
	public var autoRepeat:Bool;
	public var url:String;
	public var youtubeId:String;
	public var id:String;
	
	// 书页的layout方式。0 为居中，1 为左书页，1 为右书页
	public var pageLayoutType:Int;
	
	public function new() 
	{
		pageLayoutType = 0;
		youtubeId = "";
		url = "";
		id = "";
	}
	
	public function getDrawParams():DrawParams
	{
		var dp:DrawParams = RunTime.getDrawParams(pageLayoutType);
		var ctx:BookContext = RunTime.flipBook.bookContext;
		dp.applyTransform(ctx.scale, ctx.offsetX, ctx.offsetY);
		return dp;
	}
	
	public function toHtml():String
	{
		var dp:DrawParams = this.getDrawParams();
		var xx:Float = dp.dx + (this.x - dp.sx) * dp.scaleX();
		var yy:Float = dp.dy + (this.y - dp.sy) * dp.scaleY();
		var ww:Float = this.width * dp.scaleX();
		var hh:Float = this.height * dp.scaleY();
		if (this.youtubeId != null && this.youtubeId != "")
		{
			return HtmlHelper.toRectYoutubeVideoHtml(this, xx, yy, ww, hh);			
		}
		else
		{
			return HtmlHelper.toRectVideoHtml(this, xx, yy, ww, hh);			
		}
	}
	
	public function updateLayout(dom:HtmlDom):Void
	{
		if (dom == null) return;
		var dp:DrawParams = this.getDrawParams();
		var xx:Float = dp.dx + (this.x - dp.sx) * dp.scaleX();
		var yy:Float = dp.dy + (this.y - dp.sy) * dp.scaleY();
		var ww:Float = this.width * dp.scaleX();
		var hh:Float = this.height * dp.scaleY();
		dom.style.left = Std.string(Math.round(xx)) + "px";
		dom.style.top = Std.string(Math.round(yy)) + "px";
		var videoDom:Dynamic = dom.firstChild;
		videoDom.width = Std.string(Math.round(ww));
		videoDom.height = Std.string(Math.round(hh));
	}
	
}