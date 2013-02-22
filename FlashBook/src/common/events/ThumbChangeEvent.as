package common.events
{
	import flash.events.Event;
	
	public class ThumbChangeEvent extends Event
	{
		public static const THUMB_CHANGE: String = "thumbChange";
		
		public var currentThumb:int = 0;
		
		
		
		public function ThumbChangeEvent(type:String, currentThumb:int)
		{
			
			super(type, false, false);
			this.currentThumb = currentThumb;
		}
	}
}