package ;

import core.Tweener;
import js.Lib;
import js.Dom;
/**
 * ...
 * @author 
 */

class Main 
{
	static function main() 
	{
		//RunTime.alert(Lib.document.referrer);
		if (Lib.document.getElementById("cvsBook") == null)
		{
			Zoom.Load();
			
		}
		else
		{
			RunTime.init();
			
		}
	}
	
	static function testCss():Void
	{
		var t:Tweener = new Tweener();
		var max:Int = 20;
		var cvs:HtmlDom = Lib.document.getElementById("img");
		t.onChange = function(count:Int):Void
		{
			var l:String = Std.string(count * 30);
			cvs.style.left = l;
		}
		t.start(max);
	}
}