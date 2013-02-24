package core;

/**
 * ...
 * @author 
 */

class Html5Image
{
	public var image:Image;
	public var onload:Void->Void;
	public var url:String;
	
	public function new(url:String, onLoad:Void->Void):Void
	{
		this.url = url;
		this.onload = onLoad;
		image = new Image();
		image.onload = this.onload;
		image.src = url;
	}
}