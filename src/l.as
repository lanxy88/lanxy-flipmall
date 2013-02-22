package
{
	import common.RpcRequest;

	public dynamic class l extends Object
	{
		[Bindable]
		public static var i:l = new l();
		
		public function s(key:String, defaultString:String = null):String
		{
			if(this.hasOwnProperty(key)==false) 
			{
				return defaultString ? defaultString : key;	
			}
			else
			{
				return this[key];
			}
		}
		
		public static function loadRemote(url:String, callback:Function = null):void
		{
			new RpcRequest(url, null,
				function(obj:Object):void
				{
					loadXml(new XML(obj));
					if(callback != null) callback();
				}
			);
		}
		
		public static function loadXml(xml:XML):void
		{
			if(xml == null) return;
			
			var lang:l = new l();
			
			for each(var node: XML in xml.item)
			{
				lang[node.@key]=String(node.@value);
			}
			
			i = lang;
		}
	}
}