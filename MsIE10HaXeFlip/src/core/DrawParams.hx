package core;

/**
 * ...
 * @author 
 */

class DrawParams 
{
	public var sx:Float;
	public var sy:Float;
	public var sw:Float;
	public var sh:Float;
	public var dx:Float;
	public var dy:Float;
	public var dw:Float;
	public var dh:Float;
	
	public inline function dxi():Int
	{
		return Math.round(dx);
	}

	public inline function dyi():Int
	{
		return Math.round(dy);
	}

	public inline function dwi():Int
	{
		return Math.round(dw);
	}
	
	public inline function dhi():Int
	{
		return Math.round(dh);
	}
	
	public inline function scaleX():Float
	{
		return dw / sw;
	}
	
	public inline function scaleY():Float
	{
		return dh / sh;
	}
	
	public function new() 
	{
		
	}
	
	public function clone():DrawParams
	{
		var dw:DrawParams = new DrawParams();
		dw.sx = this.sx;
		dw.sy = this.sy;
		dw.sw = this.sw;
		dw.sh = this.sh;
		dw.dx = this.dx;
		dw.dy = this.dy;
		dw.dw = this.dw;
		dw.dh = this.dh;
		return dw;
	}
	
	/**
	 * 对 DrawParams 进行变换。其中，scale 是缩放系数
	 * @param	scale
	 * @param	offsetX
	 * @param	offsetY
	 */
	public function applyTransform(scale:Float, offsetX:Float, offsetY:Float):Void
	{
		dx = dx * scale + offsetX;
		dy = dy * scale + offsetY;
		dw = dw * scale;
		dh = dh * scale;
	}
	
	public function toString():String
	{
		return Std.string(sx)
			+ "," + Std.string(sy)
			+ "," + Std.string(sw)
			+ "," + Std.string(sh)
			+ "," + Std.string(dx)
			+ "," + Std.string(dy)
			+ "," + Std.string(dw)
			+ "," + Std.string(dh);
	}
	
	public function sliceLeft(ratio:Float, xOffset:Float = 0):DrawParams
	{
		if (ratio < 0 ) ratio = 0;
		else if (ratio > 1) ratio = 1;
		var dp:DrawParams = new DrawParams();
		dp.sx = this.sx;
		dp.sy = this.sy;
		dp.dx = this.dx + xOffset;
		dp.dy = this.dy;
		dp.sw = this.sw * ratio;
		dp.sh = this.sh;
		dp.dw = this.dw * ratio;
		dp.dh = this.dh;
		return dp;
	}
	
	public function sliceRight(ratio:Float, xOffset:Float = 0):DrawParams
	{
		if (ratio < 0 ) ratio = 0;
		else if (ratio > 1) ratio = 1;
		var dp:DrawParams = new DrawParams();
		dp.sx = this.sx + this.sw * (1 - ratio);
		dp.sy = this.sy;
		dp.dx = this.dx + this.dw * (1 - ratio) + xOffset;
		dp.dy = this.dy;
		dp.sw = this.sw * ratio;
		dp.sh = this.sh;
		dp.dw = this.dw * ratio;
		dp.dh = this.dh;
		return dp;
	}
	
}