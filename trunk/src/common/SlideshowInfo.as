package common
{
	import controls.SlideshowBox;

	/**
	 * 幻灯信息
	 */
	public class SlideshowInfo
	{
		public var page:int = 0;
		public var x:int = 0;
		public var y:int = 0;
		public var width:int = 100;
		public var height:int = 20;
		public var time:int = 5;
		public var color:String = "";
		public var slideshows:Array = [];
		public var slideshowBox:SlideshowBox = null;
		public var transition:String = "fade";
		
		public var ctrlBarAlpha:Number = 0.3;
		
		public function SlideshowInfo(page:int = 0,
									  x:int = 0,
									  y:int = 0,
									  width:int = 100,
									  height:int = 20,
									  time:int = 5,
									  color:String = "")
		{
			this.page = page;
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			this.time = time;
			this.color = color;
			this.transition = "fade";
		}
		
		public static function parse(xml:XML):SlideshowInfo{
			var item:SlideshowInfo = new SlideshowInfo();
			if(String(xml.@page)) item.page = int(xml.@page);
			if(xml.@x) item.x = int(xml.@x);
			if(xml.@y) item.y = int(xml.@y);
			if(xml.@width) item.width = int(xml.@width);
			if(xml.@height) item.height = int(xml.@height);
			if(xml.@time) item.time = int(xml.@time);
			if(xml.@bgColor) item.color = String(xml.@bgColor);
			if(xml.@transition) item.transition = String(xml.@transition);
			if(xml.@ctrlBarAlpha) item.ctrlBarAlpha = parseFloat(xml.@ctrlBarAlpha);
			for each(var node:XML in xml.pic){
				var slideItem:SlideshowItem = SlideshowItem.parse(node);
				item.slideshows.push(slideItem);
			}
			return item;
		}
	}
}