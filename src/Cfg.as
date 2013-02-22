package
{
	public class Cfg
	{
		public static var pageCoverData:Object;
		public static var pageBackCoverData:Object;
		
		public static function isPdfAttrTrue(cfg:XML, attr:String):Boolean
		{
			if(cfg == null) return false;
			
			for each(var item:XML in cfg..pdf)
			{
				var x =(item.attribute(attr));
				if(x != null && String(x) == 'true')
				{
					return true;
				}
			}
			return false;
		}
	}
}