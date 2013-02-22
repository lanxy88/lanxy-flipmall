package common
{
	import controls.HotLinkBox;
	import utils.Helper;

	public class HotLink
	{
		public var page:int = 0;
		public var title:String = "";
		public var x:int = 0;
		public var y:int = 0;
		public var width:int = 100;
		public var height:int = 20;
		public var color:uint = 0xFF0000;
		public var destination:String = "";
		public var fontSize:int = 12;
		public var fontColor:uint = 0x00FF00;
		public var paddingLeft:int = 3;
		public var paddingRight:int = 3;
		public var pageText:String = "";
		public var rolloverText:String = "";
		public var rolloverColor:uint = 0xFF0000;
		public var opacity:Number = 1;
		public var rolloverOpacity:Number = 1;
		public var isRichText:Boolean = false;
		public var type:String = "url";
		public var message:String = "";
		public var youtubeId:String = "";
		public var popupWidth:Number = NaN;
		public var popupHeight:Number = NaN;
		public var target:String ="_self";
		
		public var clickSound:Boolean = false;
		
		public function get isMessageHover():Boolean
		{
			return type == "message-hover";
			
		}
		
		public function HotLink(
			page:int = 0,
			title:String = "",
			x:int = 0,
			y:int = 0,
			width:int = 100,
			height:int = 20,
			color:uint = 0xFF0000,
			linkToPage:int = -1,
			fontSize:int = 12,
			fontColor:uint = 0x00FF00
		)
		{
			this.page = page;
			this.title = title;
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			this.color = color;
			if(linkToPage > 0)
			{
				this.destination = "page:" + linkToPage.toString();
			}
			this.fontSize = fontSize;
			this.fontColor = fontColor;
			this.rolloverColor = this.color;
		}
		
		public var hotlinkBox:HotLinkBox = null;
		
		public static function parse(xml:XML):HotLink
		{
			var hotlink:HotLink = new HotLink();
			if(String(xml.@page)) hotlink.page = int(xml.@page);
			if(xml.@x) hotlink.x = int(xml.@x);
			if(xml.@y) hotlink.y = int(xml.@y);
			if(xml.@title) hotlink.title = String(xml.@title);
			if(xml.@width) hotlink.width = int(xml.@width);
			if(xml.@height) hotlink.height = int(xml.@height);
			if(String(xml.@popupWidth)) hotlink.popupWidth = Number(xml.@popupWidth);
			if(String(xml.@popupHeight)) hotlink.popupHeight = Number(xml.@popupHeight);
			if(xml.@color) hotlink.color = Helper.parseColor(xml.@color);
			if(String(xml.@destination)) hotlink.destination = String(xml.@destination);
			if(String(xml.@fontSize)) hotlink.fontSize = int(xml.@fontSize);
			if(String(xml.@fontColor)) hotlink.fontColor = Helper.parseColor(xml.@fontColor);
			if(xml.@pageText) hotlink.pageText = String(xml.@pageText);
			if(String(xml.@opacity)) hotlink.opacity = Number(xml.@opacity);
			if(String(xml.@rolloverOpacity)) hotlink.rolloverOpacity = Number(xml.@rolloverOpacity);
			if(xml.@rolloverText) hotlink.rolloverText = String(xml.@rolloverText);
			if(String(xml.@youtubeId)) hotlink.youtubeId = String(xml.@youtubeId);
			if(String(xml.@target)) hotlink.target = String(xml.@target);
			if(String(xml.@rolloverColor))
			{
				hotlink.rolloverColor = Helper.parseColor(xml.@rolloverColor);
			}
			else
			{
				hotlink.rolloverColor = hotlink.color;
			}
			if(String(xml.@clickSound)) hotlink.clickSound = String(xml.@clickSound)=="true";
			if(String(xml.@type))
			{
				hotlink.type = String(xml.@type);
			}
			
			var text:String = xml.text();
			if(text)
			{
				if(hotlink.type != "message" && hotlink.type != "message-hover")
				{
					hotlink.title = text;
					hotlink.isRichText = true;
				}
				else
				{
					hotlink.message = text;
				}
			}
			return hotlink;
		}
	}
}