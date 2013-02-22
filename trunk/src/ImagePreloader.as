package
{
	import flash.display.Bitmap;
	
	public class ImagePreloader extends LogoPreloader
	{
		[@Embed(source="content/images/fm_rect_logo.jpg")]
		private var img:Class;
		
		protected override function createLogo():Bitmap
		{
			return new img() as Bitmap;
		}
		
		protected override function receiveParameters(params:Object):void
		{
		}
	}
}