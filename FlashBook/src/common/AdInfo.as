package common
{
	import controls.AdDisplay;
	
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	
	import mx.controls.Image;
	
	import qs.caching.ContentCache;
	
	import utils.ContentHelper;

	public class AdInfo
	{
		public var url:String;
		
		public var href:String;
		
		public var target:String = "_blank";
		
		public var width:int = 200;
		
		public var height:int = 200;
		
		public var switchSeconds:int = 5;
		
		public function createImageControl():Image
		{
			var img:AdDisplay = new AdDisplay();
			img.url = RunTime.getAbsPath(url);
			
			img.width = width;
			img.height = height;
			img.maxHeight = height;
			img.maxWidth = width;
			img.scaleContent = true;
			img.maintainAspectRatio = false;
			
			if(href)
			{
				img.buttonMode = true;
				img.useHandCursor = true;				
			}
			
			img.addEventListener(MouseEvent.CLICK, 
				function(... args):void
				{
					RunTime.clickHref(href,target);
				});
			
			return img;
		}
	}
}