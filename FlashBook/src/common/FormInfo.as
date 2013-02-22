package common
{
	import controls.FormBox;
	/**
	 * 表单信息
	 */
	public class FormInfo
	{
		public var page:int = 0;
		public var x:int = 0;
		public var y:int = 0;
		
		public var width:int = 100;
		public var height:int = 100;
		
		public var labelWidth:int = 150;
		
		public var url:String = "";
		public var formFieldInfos:Array = [];
		public var formBox:FormBox = null;
		
		public var backgroundColor:String="";
		public function FormInfo(page:int = 0,
								 x:int = 0,
								 y:int = 0,
								 width:int = 100,
								 height:int = 100,
								 url:String="")
		{
			this.page = page;
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			this.url = url;
		}
		
		public static function parse(xml:XML):FormInfo
		{
			
			var item:FormInfo = new FormInfo();
			if(String(xml.@page)) item.page = int(xml.@page);
			if(xml.@x) item.x = int(xml.@x);
			if(xml.@y) item.y = int(xml.@y);
			if(xml.@width) item.width = int(xml.@width);
			if(xml.@height) item.height = int(xml.@height);
			if(xml.@url) item.url = String(xml.@url);
			if(xml.@background) item.backgroundColor = String(xml.@background)
			if(xml.@labelWidth) item.labelWidth = int(xml.@labelWidth);
			for each(var node:XML in xml.field){
				var field:FormFieldInfo = FormFieldInfo.parse(node);
				item.formFieldInfos.push(field);
			}
			return item;
		}
	}
}