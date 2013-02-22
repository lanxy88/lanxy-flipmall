package common
{
	import utils.Helper;
	
	public class SearchTask
	{
		public var finished:Boolean;
		
		public var resultsExtracted:Boolean;
		
		public var url:String;
		
		public var node:TreeNodeRecord;
		
		public var results:Array = [];
		
		private var data:XML;
		
		public var keyword:String;
		
		public var matchCase:Boolean;
		
		public function start()
		{	
			new RpcRequest(url,null,
				function(txt:String):void
				{
					try
					{
						data = new XML(txt);
						results = Helper.search(data,keyword,matchCase)
						for each(var item:SearchResult in results)
						{
							item.node = node;
						}
					}
					catch(e:*)
					{
					}
					
					exit();
				},
				exit);
		}
		
		public var onExitCallback:Function;
		
		private function exit(... args):void
		{
			finished = true;
			
			if(onExitCallback != null)
			{
				onExitCallback();
			}
		}
	}
}