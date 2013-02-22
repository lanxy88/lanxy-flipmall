package common
{
	public class SearchResult extends Record
	{
		public var node:TreeNodeRecord;
		
		public function SearchResult(content:String, page:int, editable:Boolean = false)
		{
			super(content,page,editable);
		}
	}
}