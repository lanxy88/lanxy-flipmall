package core;

/**
 * ...
 * @author ...
 */

class SearchResult 
{
	public var content:String;
	public var page:Int;
	
	public function new(content:String, page:Int) 
	{
		this.content = content;
		this.page = page;
	}
	
}