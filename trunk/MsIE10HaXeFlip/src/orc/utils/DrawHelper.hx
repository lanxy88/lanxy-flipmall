package orc.utils;

/**
 * ...
 * @author 
 */

class DrawHelper 
{
	public static function createFillStyle(cssStyleColor:String, alpha:Float):String
	{
		cssStyleColor = StringTools.replace(cssStyleColor, "0x", "");
		cssStyleColor = StringTools.replace(cssStyleColor, "0X", "");
		cssStyleColor = StringTools.replace(cssStyleColor, "#", "");
		if (cssStyleColor.length == 6)
		{
			var r:String = Std.string(Std.parseInt("0x" + cssStyleColor.substr(0, 2)));
			var g:String = Std.string(Std.parseInt("0x" + cssStyleColor.substr(2, 2)));
			var b:String = Std.string(Std.parseInt("0x" + cssStyleColor.substr(4, 2)));
			return "rgba(" + r + "," + g + "," + b + "," + Std.string(alpha) + ")";
		}
		return "";
	}
}