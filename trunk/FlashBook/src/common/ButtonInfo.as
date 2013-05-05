package common
{
	import controls.ButtonBox;
	
	import mx.messaging.channels.StreamingAMFChannel;

	[Bindable]
	public class ButtonInfo
	{
		public static var LAYER_BACKGROUND:int = 0;
		public static var LAYER_ONPAGE:int = 1;
		public static var LAYER_FOREGROUND:int = 2;
		
		public static var ROLLOVER_NONE:int = 0;
		public static var ROLLOVER_ZOOM:int = 1;
		public static var ROLLOVER_LIGHT:int = 2;
		
		public var page:int = 0;
		public var x:int = 0;
		public var y:int = 0;
		public var image:String = "";
		public var width:int = 100;
		public var height:int = 20;
		public var popupWidth:Number = NaN;
		public var popupHeight:Number = NaN;
		public var destination:String = "";
		public var text:String = "";
		public var fontSize:Number= 12 ;
		public var fontColor:Number = 0xffffff;
		public var type:String = "url";
		public var message:String = "";
		public var youtubeId:String = "";
		public var buttonBox:ButtonBox = null;
		public var rolloverText:String = null;
		public var target:String ="_self";
		
		public var clickSound:Boolean = false;
		
		public var iframeUrl:String = "";
		
		public var layer:int = ButtonInfo.LAYER_ONPAGE;
		public var rollover:int = ButtonInfo.ROLLOVER_NONE;
		public var fun:String = "";
		
		public var pageWidth:int = RunTime.pageWidth;
		
		public function ButtonInfo(
			page:int = 0,
			image:String = "",
			x:int = 0,
			y:int = 0,
			width:int = 100,
			height:int = 20
		)
		{
			this.page = page;
			this.image = image;
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}
		
		public static function parse(xml:XML):ButtonInfo
		{
			
			var item:ButtonInfo = new ButtonInfo();
			if(String(xml.@page)) item.page = int(xml.@page);
			if(xml.@x) item.x = int(xml.@x);
			if(xml.@y) item.y = int(xml.@y);
			if(xml.@image) item.image = String(xml.@image);
			if(xml.@width) item.width = int(xml.@width);
			if(xml.@height) item.height = int(xml.@height);
			if(String(xml.@popupWidth)) item.popupWidth = Number(xml.@popupWidth);
			if(String(xml.@popupHeight)) item.popupHeight = Number(xml.@popupHeight);
			if(String(xml.@destination)) item.destination = String(xml.@destination);
			if(String(xml.@text)) {
				item.text = String(xml.@text);
				//trace(item.text);
			}
			if(String(xml.@fontColor)) item.fontColor = Number(xml.@fontColor);
			if(String(xml.@fontSize)) item.fontSize = Number(xml.@fontSize);
			
			if(String(xml.@clickSound)) item.clickSound = String(xml.@clickSound)=="true";
			
			if(String(xml.@youtubeId)) item.youtubeId = String(xml.@youtubeId);
			if(String(xml.@rolloverText)) item.rolloverText = String(xml.@rolloverText);
			if(String(xml.@target)) item.target = String(xml.@target);
			if(String(xml.@pageWidth)) item.pageWidth = Number(xml.@pageWidth);
			if(String(xml.@rollover)){
				var szRollover:String = String(xml.@rollover);
				if(szRollover == "light") {
					item.rollover = ButtonInfo.ROLLOVER_LIGHT;
				}
				else if(szRollover == "zoom"){
					item.rollover = ButtonInfo.ROLLOVER_ZOOM;
				}
			}
			
			if(String(xml.@fun)) item.fun = String(xml.@fun);
			if(String(xml.@layer)) {
				var szLayer:String = String(xml.@layer);
				if(szLayer == "background"){
					item.layer = ButtonInfo.LAYER_BACKGROUND;
					var realPage:int = item.page;
					var mod:int = realPage % 2;
					if(!RunTime.singlePageMode){
						if(RunTime.rightToLeft){
							if(mod == 0){
								item.x = item.x+item.pageWidth;
							}
						}
						else{
							if(mod != 0){
								item.x = item.x + item.pageWidth;
							}
						}
					}
					item.page = 1;
				}
				else if( szLayer == "foreground"){
					item.layer = ButtonInfo.LAYER_FOREGROUND;
					var realPage:int = item.page;
					var mod:int = realPage % 2;
					if(!RunTime.singlePageMode){
						if(RunTime.rightToLeft){
							if(mod == 0){
								item.x = item.x+item.pageWidth;
							}
						}
						else{
							if(mod != 0){
								item.x = item.x + item.pageWidth;
							}
						}
					}
					item.page = 1;
				}
			}
			
			
			if(String(xml.@type))
			{
				item.type = String(xml.@type);
			}
			
			if(xml.elements("iframe")[0]){
				var iframe:XML = xml.elements("iframe")[0];
				item.iframeUrl = iframe.@src;
			}
			
			var text:String = xml.text();
			if(text)
			{
				item.message = text;
			}
			return item;
		}
	}
}