package common
{
	import controls.AdDisplay;
	
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	import mx.controls.Image;

	/**
	 * 幻灯显示项目
	 */
	public class SlideshowItem
	{
		public var url:String = "";
		public var switchSeconds:int = 5;
		public var href:String = "";
		public function SlideshowItem(url:String="",href:String = "")
		{
			this.url = url;
		}
		
		public static function parse(xml:XML):SlideshowItem{
			var item:SlideshowItem = new SlideshowItem();
			if(String(xml.@url)) item.url = String(xml.@url);
			if(String(xml.@href)) item.href = String(xml.@href);
			return item;
		}
		

		public function createImageControl(width:int, height:int):Image
		{
			var img:AdDisplay = new AdDisplay();
			img.url = RunTime.getAbsPath(url);
			//var img:Image = new Image();
			//img.source = RunTime.getAbsPath(url);
			
			img.width = width;
			img.height = height;
			//img.maxHeight = height;
			//img.maxWidth = width;
			img.scaleContent = true;
			img.maintainAspectRatio = false;
			
			if(href)
			{
				img.buttonMode = true;
				img.useHandCursor = true;				
			}
			img.addEventListener("imageLoaded",
				function(e:*){
					var scale:Number = height / img.contentHeight;
					img.width = int(scale * img.contentWidth);
					img.x = (width-img.width)/2;
					//trace("img.height=" + img.height + "img.widht=" + img.width);
			});
			
			img.addEventListener(MouseEvent.CLICK, 
				function(e:MouseEvent):void
				{
					//e.stopPropagation();
					//e.stopImmediatePropagation();
					RunTime.clickHref(href,"_blank");
				});
			
			return img;
		}
	}
}