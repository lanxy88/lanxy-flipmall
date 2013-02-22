package common
{
	import utils.Guid;

	[Bindable]
	public class Record
	{
		public var guid:String = "";
		
		public var page:int;
		
		public var content:String = "";
		
		public var editable:Boolean = false;
		
		public function Record(content:String, page:int, editable:Boolean = false)
		{
			this.content = content;
			this.page = page;
			this.editable = editable;
			this.guid = Guid.newGuid();
		}
		
		public static function sort(list:Array):Array
		{
			
			list.sort(function(a:Record,b:Record):int
			{
				if(a.page < b.page) return -1;
				else if(a.page == b.page) return 0;
				else return 1;
			});
			
			return list;
		}
	}
}