package
{
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.events.FlexEvent;
	import mx.preloaders.DownloadProgressBar;
	
	public class NullPreloader extends DownloadProgressBar
	{
		private var timer:Timer;
		public var timerDelay:int = 100;
		private var slices:int = 12;
		private var radius:int = 11;
		public var sliceColor:uint = 0xFFFFFF;
		
		private var cycleContainer:Sprite = null;
		
		public function NullPreloader():void
		{
			super();
		}
		
		public override function set preloader(preloader:Sprite):void
		{
			preloader.addEventListener(ProgressEvent.PROGRESS, onSWFDownloadProgress);
			preloader.addEventListener(Event.COMPLETE, onSWFDownloadComplete);
			preloader.addEventListener(FlexEvent.INIT_PROGRESS, onFlexInitProgress);
			preloader.addEventListener(FlexEvent.INIT_COMPLETE, onFlexInitComplete);
		}	
		
		private function onSWFDownloadProgress(event:ProgressEvent):void
		{
			var t:Number = event.bytesTotal;
			var l:Number = event.bytesLoaded;
			var p:Number = Math.round((l/t) * 19);
			var pForAmount:int = Math.floor(p * 5);
		}
		
		private function onSWFDownloadComplete(event:Event):void
		{
		}
		
		private function onFlexInitProgress(event:FlexEvent):void
		{
		}
		
		private function onFlexInitComplete(event:FlexEvent):void
		{
			dispatchEvent( new Event(Event.COMPLETE));
		}
	}

}