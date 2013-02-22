package common
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import controls.NoteMark;
	import utils.Helper;

	[Bindable]
	public class NoteRecord extends Record
	{
		public static var SerializedProps:Array = [
			"page","content","editable","guid",
			"xPos","yPos","time","detailVisible","detailX","detailY"
		];
		
		public var xPos:Number;
		public var yPos:Number;
		public var time:Date;
		
		public var detailVisible:Boolean = false;
		public var detailX:Number = NaN;
		public var detailY:Number = NaN;
		
		public function NoteRecord(content:String,page:int,x:Number = 0, y:Number = 0,
								   editable:Boolean = false, time:Date = null)
		{
			super(content,page,editable);
			this.xPos = x;
			this.yPos = y;
			this.time = time == null? new Date() : time;
		}
		
		public function toObject():Object
		{
			var r:Object = new Object();
			Helper.copy(this,r,SerializedProps);
			return r;
		}
		
		public function update():void
		{
			RunTime.service.updateNote(this);
		}
		
		public static function createFrom(obj:Object):NoteRecord
		{
			var r:NoteRecord = new NoteRecord("",0);
			Helper.copy(obj,r,SerializedProps);
			return r;
		}
		
		public function remove():void
		{
			if(noteMark == null) return;
			
			var parent:Sprite = noteMark.parent as Sprite;
			
			if(parent != null && parent.contains(noteMark) == true)
			{
				parent.removeChild(noteMark);
			}
		}
		
		private var _noteMark :NoteMark = null;
		
		public function get noteMark():NoteMark
		{
			if(_noteMark == null) _noteMark = this.createNoteMark();
			return _noteMark;
		}
		
		public function set noteMark(value:NoteMark):void
		{
			_noteMark = value;
		}
		
		public function createNoteMark():NoteMark
		{
			var m:NoteMark = new NoteMark();
			m.record = this;
			return m;
		}
		
		public function save():void
		{
			RunTime.service.createNote(this);
		}
		
		public function deleteMe():void
		{
			RunTime.service.deleteNote(this);
		}
	}
}