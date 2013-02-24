package core;

/**
 * 笔记
 * @author kylefly
 */

class Note 
{
	public var x:Float;
	public var y:Float;
	public var text:String;
	public var guid:String;
	public var pageNum:Int;
	public var image:Image;
	

	public var context:CanvasRenderingContext2D;
	public var canvas:Canvas;

	public var scale:Float;
	
	public var offsetX:Float;
	
	public var offsetY:Float;
	
	public function new() 
	{
		image = new Image();
		image.src = "content/images/iconNote.png";
		this.text = "";
		this.x = 0;
		this.y = 0;
		this.guid = "";
	}
	
	public  function setImage(image:Image):Void {
		this.image = image;
	}
	
	public function setCanvas(canvas:Canvas):Void {
		this.canvas = canvas;
	}
	
	public function getContext():CanvasRenderingContext2D {
		return canvas.getContext("2d");
	}
	
	public function draw():Void {
		if (canvas == null || this.image == null) return;
		var context:CanvasRenderingContext2D = getContext();
		context.drawImage(image, x, y);
	}
	
	public function loadToContext2D(context:CanvasRenderingContext2D):Void {
		if(image != null)	context.drawImage(image, x, y);
	}
	
	/**
	 * 点击测试
	 * @param	x
	 * @param	y
	 * @return
	 */	
	public function hitTest(x:Float, y:Float):Bool {
		if (image == null) return false;
		if (x < this.x || y < this.y || x > (this.x+this.image.width) || y > (this.y+this.image.height) )
			return false;
		return true;
	}
	
}