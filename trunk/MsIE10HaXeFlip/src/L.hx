package ;

import orc.utils.Util;

class L
{
	private static var instance:Hash<String> = new Hash<String>();
	
	public static function s(key:String, dftVal:String = null):String
	{
		if (instance.exists(key) == false)
		{
			return dftVal != null ? dftVal : key;
		}
		else
		{
			return instance.get(key);
		}
	}
	
	public static function loadRemote(url:String, onSuccess:Void->Void = null, onError:Void->Void = null):Void
	{
		Util.request(url, function(data:String):Void
		{
			var xml:Xml = Xml.parse(data);
			loadXml(xml);
			if (onSuccess != null)
			{
				onSuccess();
			}
		},onError);
	}
	
	public static function loadXml(xml:Xml):Void
	{
		if (xml == null) return;
		var i:Iterator<Xml> = xml.elementsNamed("lang");
		if (i.hasNext() == false) return;
		xml = i.next();
		i = xml.elementsNamed("item");
		while (i.hasNext() == true)
		{
			var node:Xml = i.next();
			var key:String = node.get("key");
			var val:String = node.get("value");
			instance.set(key, val);
		}
	}
}