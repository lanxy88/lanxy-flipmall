package common
{
	import flash.events.Event;

	public class RecordEvent extends Event
	{
		public var record:Record = null;
		
		public var oldContent:String = "";
		
		public function RecordEvent(type:String, record:Record)
		{
			super(type);
			this.record = record;
		}
	}
}