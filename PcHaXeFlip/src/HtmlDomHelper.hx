package ;

import js.Lib;
import js.Dom;

class HtmlDomHelper 
{
	public static function setTopBarDefaultSize(dom:HtmlDom):Void
	{
		dom.style.width = "500px";
		dom.style.left = Std.string(Std.int((RunTime.clientWidth - 500) / 2)) + "px";
	}
	
	public static function setTopBarMaxSize(dom:HtmlDom):Void
	{
		dom.style.width = Std.string(Std.int(RunTime.clientWidth)) + "px";
		dom.style.left = "0px";
	}
	
	public static function setTopFullTextContentMaxSize(dom:HtmlDom):Void
	{
		dom.style.width = Std.string(Std.int(RunTime.clientWidth)-20) + "px";
		dom.style.top = "35px";
		dom.style.height = Std.string(Std.int(RunTime.clientHeight) - 80) + "px";
		dom.style.left = "0px";
	}
}