package common
{
	/**
	 * 厚度定义
	 */
	public class ThicknessInfo
	{
		public var tks:Array = [];
		
		public function ThicknessInfo()
		{
		}
		
		public function parse(xml:XMLList):void
		{
			for each(var node:XML in xml.tk){
				
				var item:ThicknessItem = ThicknessItem.parse(node);
				tks.push(item);
			}
		}
		
		public function getThickness(pageCount:int):int{
			
			for each(var tk:ThicknessItem in tks){
				if(tk.begin == 0) tk.begin = 1;
				if(tk.end == 0) tk.end = pageCount;
				if(pageCount >= tk.begin && pageCount <= tk.end ) return tk.value;
			}
			return 9;
		}
	}
}