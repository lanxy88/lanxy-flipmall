package common
{
	/**
	 * 表单字段
	 */
	public class FormFieldInfo
	{
		public var type:String = "";
		public var name:String = "";
		public var label:String = "";
		public var datasource:String = "";
		public var prevalue:String = "";
		public var width:int = 0;
		public var height:int = 0;
		
		public function FormFieldInfo(type:String = "",
									  name:String = "",
									  label:String = "",
									  datasource:String = "",
									  prevalue:String = "")
		{
			this.type = type;
			this.name = name;
			this.label = label;
			this.datasource = datasource;
			this.prevalue = prevalue;
		}
		
		public static function parse(xml:XML):FormFieldInfo
		{
			
			var item:FormFieldInfo = new FormFieldInfo();
			if(String(xml.@type)) item.type = String(xml.@type);
			if(String(xml.@name)) item.name = String(xml.@name);
			if(String(xml.@label)) item.label = String(xml.@label);
			if(String(xml.@datasource)) item.datasource = String(xml.@datasource);
			if(String(xml.@prevalue)) item.prevalue = String(xml.@prevalue);
			if(String(xml.@width)) item.width = int(xml.@width);
			if(String(xml.@height)) item.height = int(xml.@height);
			return item;
		}
	}
}