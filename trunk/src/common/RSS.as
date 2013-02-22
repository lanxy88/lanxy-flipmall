package common
{

	public class RSS
	{
		private var rssItems:Array = [];
		private var _rssInfo:RSSInfo;
		
		private var callback:Function = null;
		
		public function RSS(callback:Function = null)
		{
			this.callback = callback;
		}
		
		public function set rssInfo(rssinfo:RSSInfo):void{
			this._rssInfo = rssinfo;
		}
		
		public function get rssInfo():RSSInfo{
			return this._rssInfo;
		}
		
		public function readRss():void{
			if(rssInfo == null) return;
			new RpcRequest(rssInfo.url,null,parseItem,null);
		}
		
		private function parseItem(xmlData:Object):void
		{
			var items:Array = [];
			var root:XML = new XML(xmlData);
			//组合html字符串
			var szHtml:String = "";
			
			for each (var itemNode:XML in root.channel.item) 
			{
				
					var r:RSSItem = RSSItem.parse(itemNode);
					items.push(r);
					szHtml +=  "<p style=''>";
					szHtml +=  r.title;
					szHtml += "</p>";
					szHtml += r.description;
				
			}
			rssItems = items;
			
			
			
			
			//回调
			if(callback != null) callback(szHtml);
		}

		
	}
}