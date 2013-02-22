package common
{
	import controls.HighlightMark;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import mx.core.UIComponent;
	import mx.rpc.remoting.RemoteObject;
	
	import qs.controls.FlexBook;
	import qs.controls.flexBookClasses.FlexBookPage;
	
	import utils.Helper;

	[Bindable]
	public class HighlightRecord extends Record
	{
		public static var SerializedProps:Array = [
			"page","content","editable","guid",
			"xPos","yPos","time","detailVisible","detailX","detailY","destXPos","destYPos",
			"highlightColor"
		];
		
		public static var MIN_SIZE:Number = 0;
		
		public static const emptyColor:uint = 1;
		public static var defaultColor:uint = 0x0000AA;
		
		public var xPos:Number;
		public var yPos:Number;
		public var destXPos:Number;
		public var destYPos:Number;
		public var time:Date;
		public var changed:Boolean;
		
		public var highlightColor:uint;
		
		public function get bgColorStr():String
		{
			return Helper.toColorStr(highlightColor);
		}
		
		public var detailVisible:Boolean = false;
		public var detailX:Number = NaN;
		public var detailY:Number = NaN;
		public var finished:Boolean = true;
		
		public function HighlightRecord(content:String,page:int,x:Number = 0, y:Number = 0,
								   editable:Boolean = false, time:Date = null)
		{
			super(content,page,editable);
			highlightColor = defaultColor;
			this.xPos = x;
			this.yPos = y;
			destXPos = x;
			destYPos = y;
			this.time = time == null? new Date() : time;
		}
		
		public function toObject():Object
		{
			var r:Object = new Object();
			Helper.copy(this,r,SerializedProps);
			return r;
		}
		
		public static function createFrom(obj:Object):HighlightRecord
		{
			var r:HighlightRecord = new HighlightRecord("",0);
			Helper.copy(obj,r,SerializedProps);
			return r;
		}
		
		public function remove():void
		{
			if(highlightMark == null) return;
			var parent:Sprite = highlightMark.parent as Sprite;
			
			if(parent != null && parent.contains(highlightMark) == true)
			{
				parent.removeChild(highlightMark);
			}
		}
		
		public function addParent(parent:Sprite):void
		{
			//trace("drawHighlight");
			if(parent == null) return;
			
			var m:HighlightMark = highlightMark;
			parent.addChild(m);	
			
			m.layout();
			m.checkDetailPos();
			
			//var fb:FlexBook = FlexBook(parent);
			//fb.currentPage.addChild(m);
		}
		
		private var _highlightMark :HighlightMark = null;
		
		public function get highlightMark():HighlightMark
		{
			if(_highlightMark == null) _highlightMark = this.createHighlightMark();
			return _highlightMark;
		}
		
		public function set highlightMark(value:HighlightMark):void
		{
			_highlightMark = value;
		}
		
		public function createHighlightMark():HighlightMark
		{
			var m:HighlightMark = new HighlightMark();
			m.record = this;
			return m;
		}
		
		public function update():void
		{
			RunTime.service.updateHighlight(this);
		}
		
		public function save():void
		{
			RunTime.service.createHighlight(this);
		}
		
		public function deleteMe():void
		{
			RunTime.service.deleteHighlight(this);
		}
	}
}