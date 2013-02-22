package common
{
	import controls.HighlightMark;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import mx.rpc.remoting.RemoteObject;
	
	import utils.Helper;

	[Bindable]
	public class AudioBoxRecord extends Record
	{
		public static var SerializedProps:Array = [
			"page","content","editable","guid",
			"xPos","yPos"
		];
		
		public static var MIN_SIZE:Number = 0;

		public var xPos:Number;
		public var yPos:Number;

		public var changed:Boolean;

		public var finished:Boolean = true;
		
		public function AudioBoxRecord(content:String,page:int,x:Number = 0, y:Number = 0,
								   editable:Boolean = false)
		{
			super(content,page,editable);
			this.xPos = x;
			this.yPos = y;

		}
		
		public function toObject():Object
		{
			var r:Object = new Object();
			Helper.copy(this,r,SerializedProps);
			return r;
		}
		
		public static function createFrom(obj:Object):AudioBoxRecord
		{
			var r:AudioBoxRecord = new AudioBoxRecord("",0);
			Helper.copy(obj,r,SerializedProps);
			return r;
		}

		
		public function update():void
		{
			RunTime.service.updateAudioBox(this);
		}
		
		public function save():void
		{
			RunTime.service.createAudioBox(this);
		}

	}
}