package common
{
	import controls.BookMark;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import utils.Helper;
	import utils.PageNumHelper;

	public class BookMarkRecord extends Record
	{
		public static var SerializedProps:Array = [
			"page","content","editable","guid",
			"bgColor","y"
		];
		
		public var bgColor:uint;
		
		public var y:Number = 20;
		
		public function get bgColorStr():String
		{
			return Helper.toColorStr(bgColor);
		}
		
		public function get pageIndex():int
		{
			if(RunTime.rightToLeft == false)
			{
				return int(page / 2) - 1;
			}
			else
			{
				return utils.PageNumHelper.getPageIndex(page);
			}
		}
		
		private var _bookMark :BookMark = null;

		public function get bookMark():BookMark
		{
			if(_bookMark == null) _bookMark = this.createBookMark();
			return _bookMark;
		}

		public function set bookMark(value:BookMark):void
		{
			_bookMark = value;
		}

		public function BookMarkRecord(content:String,page:int,bgColor:uint,y:Number,editable:Boolean = false)
		{
			super(content,page,editable);
			this.bgColor = bgColor;
			this.y = y;
		}
		
		public function toObject():Object
		{
			var r:Object = new Object();
			Helper.copy(this,r,SerializedProps);
			return r;
		}
		
		public function update():void
		{
			RunTime.service.updateBookMark(this);
			bookMark.content = this.content;
			bookMark.bgColor = this.bgColor;
			bookMark.update();
		}
		
		public static function createFrom(obj:Object):BookMarkRecord
		{
			var r:BookMarkRecord = new BookMarkRecord("",0,0,0);
			Helper.copy(obj,r,SerializedProps);
			return r;
		}
		
		public function remove():void
		{
			if(bookMark == null) return;
			var parent:Sprite = bookMark.parent as Sprite;
			if(parent != null && parent.contains(bookMark) == true)
			{
				parent.removeChild(bookMark);
			}
		}
		
		public function createBookMark():BookMark
		{
			var m:BookMark = new BookMark();
			m.bgColor = bgColor;
			m.content = content;
			m.page = page;
			m.pageIndex = pageIndex;
			m.markObj = this;
			m.offsetY = y;
			return m;
		}
		
		public function save():void
		{
			RunTime.service.createBookMark(this);
		}
		
		public function deleteMe():void
		{
			RunTime.service.deleteBookMark(this);
		}
		
		public static function sort(array:Array):void
		{
			
			if(RunTime.rightToLeft == false)
			{
				array.sort(function(a:BookMarkRecord, b:BookMarkRecord):int
				{
					if(a.page < b.page) return -1;
					else if(a.page == b.page) return 0;
					else return 1;
				});
			}
			else
			{
				array.sort(function(a:BookMarkRecord, b:BookMarkRecord):int
				{
					if(a.page > b.page) return -1;
					else if(a.page == b.page) return 0;
					else return 1;
				});
			}
			
			
		}
	}
}