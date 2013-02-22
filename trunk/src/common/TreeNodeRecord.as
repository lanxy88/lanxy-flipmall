package common
{
	import controls.ContentsTable;
	import controls.MinButton;
	
	import flash.display.DisplayObject;

	public class TreeNodeRecord extends Record
	{
		public var level:int = 0;
		public var childs:Array = [];
		public var displayObject:DisplayObject;
		public var table:ContentsTable;
		public var expendButton:MinButton;
		public var url:String = "";
		
		public var thumb:String = "";
		
		public function TreeNodeRecord(content:String, page:int,  level:int = 0, childs:Array = null, url:String = "")
		{
			super(content,page,false);
			this.level = level;
			this.childs = childs;
			this.url = url;
			if(this.childs ==  null) this.childs = [];
		}
		
		public function expendChilds(escade:Boolean = false):void
		{
			if(table == null || displayObject == null) return;
			
			var index:int = table.getChildIndex(displayObject);
			var i:int = 1;
			table.startExpend = true;
			for each(var item:TreeNodeRecord in childs)
			{
				table.handleRecord(item,index + i);
				if(item.expendButton != null) item.expendButton.minimize = true;
				i++;
			}
			
			if(this.expendButton != null) this.expendButton.minimize = false;
			
			if(escade == true)
			{
				for each(var item:TreeNodeRecord in childs)
				{
					item.expendChilds();
				}
			}
		}
		
		public function collapseChilds():void
		{
			if(table == null || displayObject == null) return;
			
			for each(var item:TreeNodeRecord in childs)
			{
				item.collapseChilds();
				
				if(item.displayObject != null && item.displayObject.parent != null)
				{
					item.displayObject.parent.removeChild(item.displayObject);
				}
			}
			table.removeThumbList();
			
			if(this.expendButton != null) this.expendButton.minimize = true;
			
			
			//trace("table.numChildren=" + table.numChildren);
		}
		
		public function getAllNodes():Vector.<TreeNodeRecord>
		{
			var nodes:Vector.<TreeNodeRecord> = new Vector.<TreeNodeRecord>();
			nodes.push(this);
			if(childs != null)
			{
				for each(var item:TreeNodeRecord in childs)
				{
					var subnodes:Vector.<TreeNodeRecord> = item.getAllNodes();
					for each(var n:TreeNodeRecord in subnodes)
					{
						nodes.push(n);
					}
				}
			}
			return nodes;
		}
		
		public function getBaseUrl():String
		{
			if(url == null) return null;
			
			var val:String = RunTime.getAbsPath(this.url);
			var index:int = val.lastIndexOf("/");
			if( index > 0)
			{
				val = val.substr(0, index);
			}
			return val;
		}
		
		public function getPageUrl(pageNum:int):String
		{
			var val:String = this.getBaseUrl();
			if(val == null) val = "";
			var pageStr:String = pageNum.toString();
			while(pageStr.length < 4)
			{
				pageStr = "0" + pageStr;
			}
			val += "/WebSearch/page" + pageStr + ".html";
			return val;
		}
	}
}