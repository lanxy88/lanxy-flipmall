package common
{
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import mx.controls.SWFLoader;
	import utils.AVM2Loader;


	/**
	 * 本类不正确/。
	 */
	public class PowerSwfLoader extends SWFLoader
	{
		public function PowerSwfLoader()
		{
			super();
			this.addEventListener(Event.COMPLETE, 
				function(... args):void
				{
				});
		}
		
		private var _urlLoader:AVM2Loader;
		public override function set source(val:Object):void
		{
			if(val is String)
			{
				var url:String = String(val);
				if(url.lastIndexOf(".swf") == url.length -4)
				{
					loadSwf(url);
					return;
				}
			}
			super.source = val;
		}
		
		private function loadSwf(url:String):void
		{
			if(_urlLoader != null)
			{
				_urlLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,_binaryLoaded);
				_urlLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,_transferEvent);
				_urlLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,_transferEvent);
				_urlLoader.contentLoaderInfo.removeEventListener(Event.OPEN,_transferEvent);
				_urlLoader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS,_transferEvent);
				_urlLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,_transferEvent);
			}
			_urlLoader=new AVM2Loader ;
			_urlLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,_binaryLoaded,false,0,true);
			_urlLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,_transferEvent,false,0,true);
			_urlLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,_transferEvent,false,0,true);
			_urlLoader.contentLoaderInfo.addEventListener(Event.OPEN,_transferEvent,false,0,true);
			_urlLoader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS,_transferEvent,false,0,true);
			_urlLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,_transferEvent,false,0,true);
			_urlLoader.load(new URLRequest(url));
		}
		
		private function _binaryLoaded(e:Event):void {
//			super.source = _urlLoader;
//			_urlLoader.removeEventListener(Event.COMPLETE,_binaryLoaded);
//			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR,_transferEvent);
//			_urlLoader.removeEventListener(ProgressEvent.PROGRESS,_transferEvent);
//			_urlLoader.removeEventListener(Event.OPEN,_transferEvent);
//			_urlLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS,_transferEvent);
//			_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,_transferEvent);
//			_urlLoader=null;
		}
		private function _transferEvent(e:Event):void {
			dispatchEvent(e);
		}
	}
}