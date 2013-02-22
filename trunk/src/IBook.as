package
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;

	public interface IBook
	{
		function clearToolTip():void;
		
		function updateToolTip():void;
		
		function renderSnapshot(maxWidth:Number = 300, maxHeight:Number = 200):Bitmap;
		
		function get currentDisplayObject():DisplayObject;
	}
}