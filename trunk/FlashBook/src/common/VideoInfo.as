package common
{
	import controls.VideoBox;
	
	import mx.effects.Fade;

	[Bindable]
	public class VideoInfo
	{
		public var page:int = 0;
		public var x:int = 0;
		public var y:int = 0;
		public var width:int = 100;
		public var height:int = 20;
		public var url:String = '';
		public var autoPlay:Boolean = false;
		public var showControl:Boolean = false;
		public var autoRepeat:Boolean = false;
		public var youtubeId:String = "";
		public var stopWhenFlip:Boolean = false;
		
		public var videoBox:VideoBox = null;
		
		public static function parse(xml:XML):VideoInfo
		{
			var video:VideoInfo = new VideoInfo();
			if(String(xml.@page)) video.page = int(xml.@page);
			if(xml.@x) video.x = int(xml.@x);
			if(xml.@y) video.y = int(xml.@y);
			if(xml.@width) video.width = int(xml.@width);
			if(xml.@height) video.height = int(xml.@height);
			if(xml.@autoPlay) video.autoPlay = String(xml.@autoPlay) == "true";
			if(xml.@showControl) video.showControl = String(xml.@showControl) == "true";
			if(xml.@stopWhenFlip) video.stopWhenFlip = String(xml.@stopWhenFlip) == "true";
			if(xml.@autoRepeat) video.autoRepeat = String(xml.@autoRepeat) == "true";
			if(String(xml.@url)) video.url = String(xml.@url);
			if(String(xml.@youtubeId)) video.youtubeId = String(xml.@youtubeId);
			
			return video;
		}
	}
}