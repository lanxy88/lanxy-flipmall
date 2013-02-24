package core;
import js.Lib;

/**
 * ...
 * @author 
 */
class Page 
{
	public var urlBigPage:String;//放大以后的图片url
	public var urlPage:String;
	public var urlThumb:String;
	public var urlFullPage:String;
	public var id:String;
	public var num:Int;
	public var numInDoubleMode:Int;	// 在双页模式下的 num
	public var turnRightCallback:Void->Void;
	public var turnLeftCallback:Void->Void;
	public var drawParams:DrawParams;
	public var pageOffset:Float;
	
	public var scale:Float;
	
	public var offsetX:Float;
	
	public var offsetY:Float;
	
	public var isDoublePageMode:Bool;

	private var ctx:CanvasRenderingContext2D;
	private var _imagePage:Image;
	private var _imageData:ImageData;
	
	//public var imagePage(getImagePage, null) : Image;
	
	public var loaded:Bool;
	public var visible:Bool;
	
	public var bookContext:BookContext;
	
	public var content:String;
	
	public var contentLowerCase:String;
	
	public var bigMode:Bool;
	public var aniScale:Float = 1;
	
	public var canZoom:Bool = true;
	
	/**
	 * 是否保护
	 */
	public var locked:Bool = false;

	public function new()
	{
		visible = true;
		pageOffset = 0;
		scale = 1;
		offsetX = 0;
		offsetY = 0;
		bigMode = false;
		locked = false;
	}
	
	private function onLoadImage():Void
	{
		//Lib.alert(num);
		//首页加载完毕，移除预加载动画
		//if (num == 0){
			RunTime.divLoading.style.display = "none";
		//}
		loaded = true;
		draw();
		if (RunTime.flipBook.currentPageNum == null || RunTime.flipBook.currentPageNum == this.num)
		{
			//RunTime.flipBook.fillImg(urlPage);
			RunTime.flipBook.loadCtxHotlinks();
			RunTime.flipBook.bookContext.render();
		}
	}
	
	public function getImagePage():Image
	{
		
		if (_imagePage != null ) return _imagePage;
		
		var img:Image = new Image();
		img.src = urlPage;
		img.onload = onLoadImage;
		RunTime.divLoading.style.display = "inline";
		_imagePage = img;
		return _imagePage;
	}
	
	public function setBigImageMode() {
		bigMode = true;
		//this.getBigImagePage();
	}
	
	public function getBigPageUrl():String {
		var url:String = urlPage;
		var seg:Array<String> = url.split("/");
		return "content/pages/" + seg[seg.length-1];
		//return this.urlBigPage;
	}
	
	public function getBlankPage():String {
		return "content/images/bgLock.png";
	}
	
	public function getPageUrl():String {
		return this.urlPage;
	}
	
	public function loadBigImagePage() {
		var img:Image = new Image();
		img.src = getBigPageUrl();
		//Lib.alert(img.src);
		//img.onload = onLoadImage;
	}
	/**
	 * 页面缩放
	 * @param	scale
	 */
	public function zoom(scale:Float) {
		aniScale += scale;
		//draw();
	}

	
	public function clearCallback():Void
	{
		this.turnLeftCallback = null;
		this.turnRightCallback = null;
	}
	
	private function onMouseClick(e):Void
	{
		if (e.localX > _imagePage.width * 0.5)
		{
			if (turnRightCallback != null)
			{
				turnRightCallback();
			}
		}
		else
		{
			if (turnLeftCallback != null)
			{
				turnLeftCallback();
			}
		}
	}
	
	public function loadToContext2D(ctx:CanvasRenderingContext2D):Void
	{
		this.ctx = ctx;
		if (this._imagePage == null)
		{
			
			this.getImagePage();
			//draw();
			//return;
		}

		if (this.loaded == true)
		{
			RunTime.divLoading.style.display = "none";
			draw();
		}
	}
	
	private function draw():Void
	{
		
		if (this.ctx == null) return;
		if (this.drawParams == null) return;
		if (visible == false) return;
		
		var offset:Float = pageOffset;
		if (this.bookContext != null)
		{
			offset += this.bookContext.pageOffset;
		}
		
		
		if (offset > -1.001 && offset < -1) offset = -1;
		if (offset > 1 && offset < 1.001) offset = 1;
		
		if (offset <= -1 || offset >=1) return;
		
		
		drawImageCore(offset);
	}
	
	private function drawImageCore(offset:Float):Void
	{
	
		var dp:DrawParams = this.drawParams.clone();
		if (dp == null || dp.dw < 2) return;
		dp.applyTransform(this.scale, this.offsetX, this.offsetY);
		//trace("offset=" + offset);
		if (offset == 0)
		{
			clipImage(ctx,this._imagePage, dp.sx, dp.sy, dp.sw, dp.sh, dp.dx, dp.dy, dp.dw, dp.dh);
			if (_imageData == null)
			{
				//_imageData = ctx.getImageData(dp.dx, dp.dy, dp.dw, dp.dh);
			}
		}
		else if (offset > 0)
		{

			clipImage(ctx,this._imagePage, 
				dp.sx, dp.sy, dp.sw * (1-offset), dp.sh, 
				dp.dx + dp.dw * offset, dp.dy, dp.dw * (1 - offset), dp.dh);
				

		}
		else
		{

			offset = -offset;
			clipImage(ctx,this._imagePage, 
				dp.sx + offset * dp.sw, dp.sy, dp.sw*(1-offset), dp.sh,
				dp.dx, dp.dy, dp.dw*(1-offset), dp.dh);
			
		}
		
		
	}
	
	private function clipImage(ctx:CanvasRenderingContext2D, img:Image, sx:Float, sy:Float, sw:Float, sh:Float, dx:Float, dy:Float, dw:Float, dh:Float):Void
	{
		
		if (img.src == null || img.src == "") {
			Lib.alert("no data");
			return;
		}
		var pw:Float = RunTime.book.pageWidth;
		var ph:Float = RunTime.book.pageHeight;
		var rw:Float = img.width;
		var rh:Float = img.height;
		var scaleX:Float = rw / pw;
		var scaleY:Float = rh / ph;
		
		
		
		//RunTime.flipBook.resizeContainer(dw, dh,dx,dy);
		//trace("1.sx=" + sx + ", sy=" + sy + ", sw =" + sw + ",sh=" + sh);
		
		sx = sx * scaleX;
		sy = sy * scaleY;
		sw = sw * scaleX;
		sh = sh * scaleY;
		
		//trace("2.sx=" + sx + ", sy=" + sy + ", sw =" + sw + ",sh=" + sh);
		
		if (sx < 0) sx = 0;
		if (sy < 0) sy = 0;
		
		if (sx + sw > img.width)
		{
			sw = img.width - sx;
		}
		if (sy + sh > img.height)
		{
			sh = img.height - sy;
		}
		
		
		if (sx >= img.width || sy >= img.height) return;
		
		
		if (sw < 1 || sh < 1) return;
		
		
		
		
		ctx.save();

		ctx.drawImage(img, sx, sy, sw, sh, dx, dy, dw, dh);
		
		if(RunTime.bLocked && locked){
			ctx.fillStyle = "rgb(255,255,255)";
			//trace("dx=" + dx);
			ctx.fillRect(Std.int(dx), Std.int(dy), Std.int(dw), Std.int(dh));
		}
		
		ctx.restore();

	}
}