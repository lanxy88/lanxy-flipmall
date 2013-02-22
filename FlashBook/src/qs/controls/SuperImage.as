/*
Copyright 2006 Adobe Systems Incorporated

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.


THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/
package qs.controls
{
	import common.ButtonInfo;
	import common.FormInfo;
	import common.HotLink;
	import common.RSSInfo;
	import common.SlideshowInfo;
	import common.VideoInfo;
	
	import controls.BgSprite;
	import controls.ButtonBox;
	import controls.FormBox;
	import controls.HotLinkBox;
	import controls.LockPageBox;
	import controls.RSSBox;
	import controls.SlideshowBox;
	import controls.SwfContent;
	import controls.VideoBox;
	
	import flash.display.AVM1Movie;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.text.TextSnapshot;
	
	import mx.controls.Alert;
	import mx.core.IDataRenderer;
	import mx.core.UIComponent;
	import mx.states.AddChild;
	
	import org.flexunit.internals.matchers.Each;
	
	import qs.caching.ContentCache;
	
	
	[Style(name="backgroundAlpha", type="Number", inherit="no")]
	[Style(name="backgroundColor", type="uint", format="Color", inherit="no")]
	[Style(name="cornerRadius", type="Number", format="Length", inherit="no")]
	[Style(name="dropShadowEnabled", type="Boolean", inherit="no")]
	[Style(name="dropShadowColor", type="uint", format="Color", inherit="yes")]
	[Style(name="shadowDirection", type="String", enumeration="left,center,right", inherit="no")]
	[Style(name="shadowDistance", type="Number", format="Length", inherit="no")]
	[Style(name="dropShadowColor", type="uint", format="Color", inherit="yes")]
	[Style(name="shadowDirection", type="String", enumeration="left,center,right", inherit="no")]
	[Style(name="shadowDistance", type="Number", format="Length", inherit="no")]
	
	[Event(name="complete", type="flash.events.Event")]
	
	public class SuperImage extends UIComponent implements IDataRenderer
	{
		private var _source:*;
		private var _sourceChanged:Boolean = false;
		private var _cacheName:String = "";
		private var _loadedFromCache:Boolean = false;
		

		[Bindable]
		public var smoothImage:Boolean = false;
		
		[Bindable]
		public var content:DisplayObject;
		


		private var _hotlinks:Array;

		[Bindable]
		public function get hotlinks():Array
		{
			return _hotlinks;
		}

		public function set hotlinks(value:Array):void
		{
			_hotlinks = value;'' +
			loadWidgets();
		}
		
		private var _buttons:Array;

		[Bindable]
		public function get buttons():Array
		{
			return _buttons;
		}

		public function set buttons(value:Array):void
		{
			_buttons = value;
			loadWidgets();
		}
		
		private var _forms:Array;
		[Bindable]
		public function get forms():Array{
			return _forms;
		}
		public function set forms(value:Array):void{
			_forms = value;
			loadWidgets();
		}
		
		private var _slideshows:Array;
		[Bindable]
		public function get slideshows():Array{
			return _slideshows;
		}
		public function set slideshows(value:Array):void{
			_slideshows = value;
			loadWidgets();
		}
		
		private var _rss:Array;
		[Bindable]
		public function get RSS():Array{
			return _rss;
		}
		public function set RSS(value:Array):void{
			_rss = value;
			loadWidgets();
		}
		
		private var _videos:Array;

		[Bindable]
		public function get videos():Array
		{
			return _videos;
		}

		public function set videos(value:Array):void
		{
			_videos = value;
			loadWidgets();
		}
		
		/** What to display. Options are:  Bitmap, BitmapData, url, URLRequest, or a Class or ClassName that when instantiated matches one of the other
		 * 	options.
		 */
		[Bindable] public function set source(value:*):void
		{
			if(value == _source)
				return;
			if(content is Loader)
			{
				Loader(content).contentLoaderInfo.removeEventListener(Event.COMPLETE,onLoadComplete);
				Loader(content).contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onLoadError);
			}
			
			_source = value;
			_sourceChanged = true;
			this.commitProperties();
		}
		
		public function get source():*
		{
			return _source;
		}
		
		[Bindable] public function set data(value:Object):void
		{
			source = value;
		}
		
		public function get data():Object
		{
			return source;
		}
		
		
		/*--------------------------------------------------------------------------------------------------------------------
		*  private methods
		*-------------------------------------------------------------------------------------------------------------------*/
		override protected function commitProperties():void
		{
			if(_sourceChanged)
			{
				_sourceChanged= false;
				if(content != null)
				{
					removeChild(content);
				}
				
				_loadedFromCache = false;
				content = null;
				
				var newSource:* = _source;
				
				if(newSource is Class)
				{
					newSource = new newSource();
				}
				
				var loading:Boolean = false;
				
				if(newSource is Bitmap)
				{
					content = newSource;
				}
				else if (newSource is BitmapData)
				{
					content = new Bitmap(newSource);
				}
				else if (newSource is String || newSource is URLRequest)
				{
					// it's an url that needs to be loaded.
					var cachedContent:DisplayObject;
					
					if(_cacheName == null)
					{
						cachedContent = new Loader();
						Loader(cachedContent).load((newSource is URLRequest)? newSource:new URLRequest(newSource));
					}
					else
					{
						cachedContent = ContentCache.getCache(_cacheName).getContent(newSource);
					}
					
					_loadedFromCache = true;
					// now the cache can give us back different types of display objects. If they gave us back a Loader,
					// and the loader is actively loading, we need to listen to it to know when its completed.
					if (cachedContent is Loader)
					{
						var l:Loader = Loader(cachedContent);
						
						if(l.contentLoaderInfo.bytesLoaded > 0 && l.contentLoaderInfo.bytesLoaded > l.contentLoaderInfo.bytesTotal)
						{
							// 可能出现 	bytesTotal 为0 而  bytesLoaded 不为0的情况
							loading = true;
							onLoadCompleteCore(l.contentLoaderInfo);
						}
						else if(l.contentLoaderInfo.bytesTotal == 0 || (l.contentLoaderInfo.bytesLoaded < l.contentLoaderInfo.bytesTotal))
						{
							l.contentLoaderInfo.removeEventListener(Event.COMPLETE,onLoadComplete);
							l.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
							l.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onLoadError);
							l.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadComplete);
							l.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
							l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onLoadError);
							loading = true;
						}
						else
						{
							loading = true;
							onLoadCompleteCore(l.contentLoaderInfo);
						}
					}
					else
					{
						dispatchEvent(new Event(Event.COMPLETE));
					}
					
					if(content == null) content = cachedContent;
					
					if(loading == false)
					{
						if(smoothImage)
						{
							content = getSmoothedContent(cachedContent as DisplayObject);
						}
						else
						{
							content = cachedContent;
						}
					}
				}
				
				if(loading == false)
				{
					loadContent(content);
				}
				
				invalidateSize();
				invalidateDisplayList();
			}
		}
		
		private var movieLoader:Loader;
		
		public static function getSmoothedContent(source: DisplayObject): DisplayObject
		{

			if(source == null) return null;
			else if(source is Sprite || source is AVM1Movie) return source;
			
			var bData: BitmapData;
			var result: DisplayObject;
			if( source != null && source.width > 0 && source.height > 0 )
			{
				bData = new BitmapData(source.width, source.height, false, 0xff00ff00 );
				bData.draw(source, null, null, null, null, true);
				
				var spr: Sprite = new Sprite();
				spr.graphics.beginBitmapFill(bData, null, false, true );
				spr.graphics.drawRect(0, 0, source.width, source.height);
				spr.graphics.endFill();
				result = spr as DisplayObject;
			}
			else
			{
				result = source;
			}
			
			return result;
		}
		
		private function onLoadError(e:Event):void
		{
		}
		
		private function loadContent(obj:DisplayObject):void
		{
			if(obj == null) return;
			
			
			if(obj is MovieClip || obj is Sprite)
			{
				var bg:Sprite = new BgSprite();
				bg.width = obj.width;
				bg.height = obj.height;
				var ui:SwfContent = new SwfContent();
				ui.width = obj.width;
				ui.height = obj.height;
				ui.addChild(bg);
				ui.addChild(obj);
				obj = ui;
			}
			

			var cvs:ComboLinkPage = new ComboLinkPage();
			cvs.content = obj;
			addChild(cvs);
			cvs.width = this.width/this.scaleX;
			cvs.height = this.height/this.scaleY;
			cvs.cnt = content;
			
			this.content = cvs;
			
			loadWidgets();
			
			this.invalidateDisplayList();
		}
		
		private function loadWidgets()
		{
			if(content == null) return;
			var cvs:ComboLinkPage = this.content as ComboLinkPage;
			if(cvs == null) return;
			
			for each(var slideshow:SlideshowInfo in this.slideshows){
				if(slideshow.slideshowBox == null){
					slideshow.slideshowBox = new SlideshowBox();
					slideshow.slideshowBox.slideshowInfo = slideshow;
				}
				cvs.addChild(slideshow.slideshowBox);
			}
			
			
			for each(var rssInfo:RSSInfo in this.RSS){
				if(rssInfo.rssBox == null){
					rssInfo.rssBox = new RSSBox();
					rssInfo.rssBox.rssInfo = rssInfo;
				}
				//cvs.addChild(rssInfo.rssBox);
			}
			
			for each(var form:FormInfo in this.forms)
			{
				if(form.formBox == null)
				{
					form.formBox = new FormBox();
					form.formBox.formInfo = form;
				}
				cvs.addChild(form.formBox);
				
			}
			
			for each(var button:ButtonInfo in this.buttons)
			{
				if(button.buttonBox == null)
				{
					button.buttonBox = new ButtonBox();
					button.buttonBox.buttonInfo = button;
				}
				
				if(button.layer == ButtonInfo.LAYER_ONPAGE){
					
					
					cvs.addChild(button.buttonBox);
				}
				else{
					RunTime.mainPage.addFunButton(button.layer,button.buttonBox);
				}
			}
			
			for each(var link:HotLink in this.hotlinks)
			{
				if(link.hotlinkBox == null)
				{
					link.hotlinkBox = new HotLinkBox();
					link.hotlinkBox.hotlink = link;
				}
				cvs.addChild(link.hotlinkBox);
			}
			
			for each(var video:VideoInfo in this.videos)
			{
				if(video.videoBox == null)
				{
					video.videoBox = new VideoBox();
					video.videoBox.videoInfo = video;
				}
				cvs.addChild(video.videoBox);
			}
			
			
			

			this.invalidateProperties();
		}
		
		private function onLoadComplete(e:Event):void
		{
			onLoadCompleteCore(LoaderInfo(e.target));
		}
		
		private function onLoadCompleteCore(target:LoaderInfo):void
		{
			if(smoothImage && target != null && target.width > 0 && target.height > 0 )
			{
				var loadedCnt:DisplayObject = target.content;
				content = getSmoothedContent(loadedCnt as DisplayObject);
				//content = loadedCnt as DisplayObject;
				

			}
			
			loadContent(content);
			
//			invalidateSize();
//			invalidateDisplayList();
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onProgress(event:ProgressEvent) : void
		{
			dispatchEvent(event);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if(content == null) return;

			content.width = unscaledWidth;
			content.height = unscaledHeight;
		}
	}
}

