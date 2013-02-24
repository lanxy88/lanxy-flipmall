package core;
import js.Lib;
import js.Dom;
/**
 * ...
 * @author kylefly
 */

class SlideshowInfo 
{
	public var pageNum:Int;
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;
	public var interval:String;
	public var transition:String;
	
	public var slides:Array<Slide>;
	
	public var tweener:Tweener ;
	
	public var id:String;
	
	public var idx:Int;
	
	private var countOfClip:Int;
	
	public var bgColor:String ="";
	// 书页的layout方式。0 为居中，1 为左书页，1 为右书页
	public var pageLayoutType:Int;
	
	public function new() 
	{
		slides = new Array<Slide>();
		tweener = new Tweener();
		idx = 1;
		transition = "fade";
		countOfClip = 0;
	}
	
	public function startTweener():Void {
		countOfClip = 50 * Std.parseInt(interval);
		tweener.onChange = onSlideChange;
		tweener.start(1000000);
		
		
	}
	
	public function stopTweener():Void {
		tweener.stop();
	}
	private function onSlideChange(count:Int):Void {
		
		if (count % countOfClip != 0) return;
		
		if(this.transition == "move"){
			var p:HtmlDom = Lib.document.getElementById("p_" + id);
			
			
			if (p != null) {
				var pidx:Int = -idx * 100;
				p.style.marginLeft = Std.string(pidx) + "%";
				
			}
			idx ++;
			if (idx >= slides.length) idx = 0;
		}
		else  {
			
			var a:HtmlDom = Lib.document.getElementById("a_" +  this.id + "_" + Std.string(idx));
			
			idx ++;
			if (idx == this.slides.length+1) {
				
				for (i in 0 ... this.slides.length) {
					var t:Int = i +1;
					var p:HtmlDom = Lib.document.getElementById("a_" +  this.id + "_" + Std.string(t));
					if (p != null) {
						p.style.cssText = "text-align:left;width:100%;overflow: hidden;opacity:1;position:absolute;background:" + bgColor;
					}
				}
				
				
			}
			
			if (a != null && idx < this.slides.length+1) {
				a.style.cssText = "text-align:left;opacity: 0 ; -webkit-transition: 0.5s ease-out;width:100%;overflow: hidden;";
			}
			
			if (idx > slides.length) idx = 1;
		}
		
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
		return HtmlHelper.toSlideShowHtml(this, xx, yy, ww, hh, dp.scaleX());			

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