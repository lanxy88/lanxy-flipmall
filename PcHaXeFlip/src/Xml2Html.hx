package ;

/**
 * ...
 * @author 
 */

class Xml2Html 
{
	private var map:Array<CData>;

	public function new() 
	{
	}
	
	public function getCData(key:String):String
	{
		if (map == null) return null;
		
		for (i in 0 ... map.length)
		{
			var item:CData = map[i];
			if (item.key == key)
			{
				return item.val;
			}
		}
		
		return null;
	}
	
		//如果xml中的CData部分无法被解析出来，因此需要将转换它为正常的节点。
	public function prepareXmlAsHtml(txt:String):String
	{
		map = new Array<CData>();
		txt = StringTools.replace(txt, "<![CDATA[", "]]>");
		var lines:Array<String> = txt.split("]]>");
		if (lines.length == 0) return txt;
		var buff:StringBuf = new StringBuf();
		var k:Int = 0;
		for (i in 0 ... lines.length)
		{
			var val:String = lines[i];
			if (i % 2 == 0) // 正常内容
			{
				buff.add(val);
			}
			else
			{
				var key:String = Std.string(k);
				buff.add("<cdata>" + key + "</cdata>");
				var cdata:CData = new CData();
				cdata.key = key;
				cdata.val = val;
				map.push(cdata);
				k++;
			}
		}
		
		return buff.toString();
	}
}