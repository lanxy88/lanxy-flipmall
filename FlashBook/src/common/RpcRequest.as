package common
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.*;
	import flash.system.LoaderContext;

	public class RpcRequest
	{
		public function RpcRequest(url:String, postData:Object = null, callback:Function = null, fail:Function = null, isPost:Boolean = true)
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE,
				function(event:Event): void
				{
					if(callback != null)
					{
						callback(event.target.data);
					}
				}
			);
			
			loader.addEventListener(IOErrorEvent.IO_ERROR, 
				function(event:Event): void
				{
					if(fail != null)
					{
						fail(event.target);
					}
				}
			);
			
			var pds:URLVariables = new URLVariables();
			if(postData != null)
			{
				for(var name:String in postData)
				{
					pds[name] = postData[name];
				}
			}
			
			var req:URLRequest = new URLRequest(RunTime.getAbsPath(url));
			
			req.method = isPost? URLRequestMethod.POST :URLRequestMethod.GET; 
			req.data = pds;
			loader.load(req);
		}
	}
}