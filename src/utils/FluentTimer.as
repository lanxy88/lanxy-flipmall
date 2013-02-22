package utils
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class FluentTimer
	{
		private var _delay:int;
		
		private var _timer:Timer;
		
		private var _ontimer:Function;
		
		public function  FluentTimer(delayMs:int = 1000, callback:Function = null):void
		{
			_delay = delayMs;
			_ontimer = callback;
		}
		
		public function delay(delayMs:int):FluentTimer
		{
			_delay = delayMs;
			return this;
		}
		
		public function onTimer(callback:Function):FluentTimer
		{
			_ontimer = callback;
			return this;
		}
		
		public function run():FluentTimer
		{
			_timer = new Timer(_delay,1);
			_timer.addEventListener(TimerEvent.TIMER, 
				function(event:TimerEvent):void
				{
					if(_ontimer != null) _ontimer();
				});
			_timer.start();
			return this;
		}
	}
}