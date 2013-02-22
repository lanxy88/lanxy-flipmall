package common
{
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import qs.caching.ContentCache;

	public class Prefetch
	{
		public var pages:Array = [];
		
		private var _loader:URLLoader;
		
		private var _dic:Object = new Object;
		
		private var _urls:Array = [];
		
		private var _index:int = -1;
		
		public function Prefetch():void
		{
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, prefetchNext);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, prefetchNext);
//			_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, prefetchNext );
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, prefetchNext );
		}
		
		private var _loading:Boolean = false;
		private var _currentUrl:String = "";
		
		private function prefetchNext(e:Event = null):void
		{
			if(_loading == true && e == null) return;
			
			if(_currentUrl && e != null && _loading == true)
			{
				ContentCache.getCache().getContent(_currentUrl);
			}
			
			_loading = false;
			_currentUrl = null;
			
			for(var i:int = 0; i < this._urls.length; i++)
			{
				var url:String = this._urls[i] as String;
				
				if(_dic.hasOwnProperty(url) && _dic[url] == false)
				{
					_dic[url] = true;
					_loader.load(new URLRequest(url));
					_loading = true;
					_currentUrl = url;
					return;
				}
			}
		}
		
		public function prefetchForward(page:int, count:int = 10):void
		{
			if(page == -1) return;
			var nums:Array = [];
			for(var i:int = 0; i < count ; i++)
			{
				nums.push(page + i + 1);
			}
			prefetchPages(nums, false, true);
		}
		
		public function prefetchBackward(page:int, count:int = 10):void
		{
			if(page < 1) return;
			var nums:Array = [];
			for(var i:int = 0; i < count ; i++)
			{
				nums.push(page - i - 1);
			}
			prefetchPages(nums, false, false);
		}
		
		public function prefetchPages(nums:*, withThumb:Boolean = false, prior:Boolean = false):void
		{
			var list:Array = [];
			if(!nums)
			{
				list = pages;
			}
			else if(nums is Array)
			{
				for each(var i:int in nums)
				{
					if(i <= 0) return;
					
					for each(var page:BookPage in this.pages)
					{
						if(page.pageId == i)
						{
							list.push(page);
						}
					}
				}
			}
			else if(nums is int)
			{
				var count:int = Math.min(int(nums), pages.length);
				list = pages.slice(0,count);
			}
			
			var sources:Array = [];
			var thumbs:Array = [];
			for each(var page:BookPage in list)
			{
				sources.push(page.source);
				if(withThumb == true)
				{
					if(page.thumb)
					{
						thumbs.push(page.thumb);
					}
				}
			}
			
			prefetchUrls(sources,prior);
			if(withThumb == true)
			{
				prefetchUrls(thumbs,prior);
			}
		}
		
		public function prefetchUrls(urls:Array, prior:Boolean = false):void
		{
			var list:Array = [];
			
			for each(var item:String in urls)
			{
				if(_dic.hasOwnProperty(item))
				{
					if(_dic[item] == true)
					{
						continue;
					}
				}
				else
				{
					list.push(item);
					_dic[item] = false;
				}
			}
			
			if(prior == false) _urls = _urls.concat(list);
			else _urls = list.concat(_urls);
			
			this.prefetchNext();
		}
	}
}