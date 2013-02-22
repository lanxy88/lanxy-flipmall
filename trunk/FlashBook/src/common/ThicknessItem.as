package common
{
	/**
	 * 厚度定义条目
	 */
	public class ThicknessItem
	{
		public var begin:int = 0;
		public var end:int = 0;
		public var value:int = 0;
		
		public function ThicknessItem()
		{
		}
		
		public static function parse(xml:XML):ThicknessItem{
			var item:ThicknessItem = new ThicknessItem();
			if(String(xml.@begin)) item.begin = parseInt(xml.@begin);
			if(String(xml.@end)) item.end = parseInt(xml.@end);
			if(String(xml.@value)) item.value = parseInt(xml.@value);
			return item;
		}
	}
}