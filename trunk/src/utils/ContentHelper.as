package utils
{
	import common.AudioManager;
	import common.PlayList;
	import common.SoundContainer;
	import common.VideoInfo;
	
	import controls.BgAudioBox;
	import controls.ComboContent;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	
	import mx.containers.TitleWindow;
	import mx.managers.PopUpManager;
	
	public class ContentHelper
	{
		// 如果未指定w和h，则放大到全屏，否则，则拉伸为w*h
		public static function showImage(url:String, w:Number = NaN, h:Number = NaN):void
		{
			var callback:Function = function(width:Number, height:Number):void
			{
				var cnt:ComboContent = new ComboContent();
				cnt.type = 'image';
				cnt.width = width;
				cnt.height = height;
				cnt.height = Math.min(cnt.height,RunTime.mainApp.height-100);
				cnt.width = Math.min(cnt.width,RunTime.mainApp.width-100);
				
				cnt.url = url;
				cnt.showDialog();
			};
			
			if(isNaN(w) || isNaN(h))
			{
				var margin:int = 40;
				var maxFitScale:Number = 1;
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, 
					function(e:Event):void
					{
						var bmp:Bitmap = loader.content as Bitmap;
						if(bmp == null) return;
						
						var metric:ImageMetricHelper = new ImageMetricHelper(bmp);
						var scale:Number = metric.getMaxFitScale((RunTime.mainApp.width - margin) * maxFitScale, (RunTime.mainApp.height - margin) * maxFitScale);
						scale = Math.min(scale,1); 
						callback(bmp.width * scale,bmp.height * scale);
					});
				loader.load(new URLRequest(url));
			}
			else
			{
				callback(w,h);
			}
		}
		
		public static function isVideoUrl(url:String):Boolean
		{
			var _url:String = url.toLowerCase();
			return _url && (_url.indexOf(".flv") > 0 || _url.indexOf(".mp4") > 0);
		}
		
		public static function getVideoSize(url:String, callback:Function):void
		{
			if(isVideoUrl(url))
			{
				var n:NetConnection = new NetConnection();
				n.connect(null);
				var ns:NetStream = new NetStream(n);
				ns.client = {};
				ns.client.onMetaData = function (item:Object):void {
					var width:Number = item.width;
					var height:Number = item.height
						
					height = Math.min(height,RunTime.mainApp.height-100);
					width = Math.min(width,RunTime.mainApp.width-100);
					
					ns.close();
					if(callback != null)
					{
						callback(width, height);
					}
				};
				
				ns.play(url);
			}
			else
			{
				if(callback != null)
				{
					callback(800, 640);
				}
			}
		}
		
		public static function showVideo(url:String, youtubeId:String, popupWidth:Number, popupHeight:Number):void
		{
			var autosize:Boolean = isNaN(popupWidth);
			
			var callback:Function = function(w:Number, h:Number):void
			{
				var video:VideoInfo = new VideoInfo();
				video.autoPlay = true;
				video.autoRepeat = false;
				
				h = Math.min(h,RunTime.mainApp.height-100);
				w = Math.min(w,RunTime.mainApp.width-100);
				
				video.height = h;
				video.width = w;
				video.showControl = true;
				video.url = url;
				video.youtubeId = youtubeId;
				
				var cnt:ComboContent = new ComboContent();
				cnt.type = 'video';
				cnt.height = h;
				cnt.width = w;
				
				cnt.height = Math.min(cnt.height,RunTime.mainApp.height-100);
				cnt.width = Math.min(cnt.width,RunTime.mainApp.width-100);
				
				cnt.videoInfo = video;
				cnt.showDialog();
				cnt.autosize = autosize;
			};
			var w:Number = 600;
			var h:Number = 400;
			
			if(!isNaN(popupWidth)) { w = popupWidth };
			if(!isNaN(popupHeight)) h = popupHeight;
			callback(w,h);
		}
		/**
		 * 显示背景音乐控制条
		 */
		public static function showBgAudioBox(audioManager:AudioManager,playlist:SoundContainer=null):void{
			var cnt:BgAudioBox = new BgAudioBox();
			cnt.type = 'audio--hover';
			cnt.height = 60;
			cnt.width = 500;
			cnt.audioManager = audioManager;
			cnt.playlist = playlist;
			showBgAudioAt(cnt,RunTime.mainPage.getBgAudioLayer());

		}
		
		public static function showBgAudioAt(cnt:BgAudioBox, parent:DisplayObjectContainer):void
		{
			clearBgAudioBox(parent);
			cnt.show(NaN,NaN,parent);
		}
		
		public static function clearBgAudioBox(parent:DisplayObjectContainer){
			if(parent.numChildren > 0)
			{
				var old:BgAudioBox = parent.getChildAt(0) as BgAudioBox;
				old.close();
			}
		}
		
		
		public static function showAudio(url:String):ComboContent
		{
			var cnt:ComboContent = new ComboContent();
			cnt.type = 'audio';
			cnt.height = 60;
			cnt.width = 500;
			cnt.url = url;
			showAudioAt(cnt,RunTime.mainPage.getAudioLayer());
			return cnt;
		}
		
		public static function showAudioAt(cnt:ComboContent, parent:DisplayObjectContainer):void
		{
			var x:Number = NaN;
			var y:Number = NaN;
			if(parent.numChildren > 0)
			{
				var old:ComboContent = parent.getChildAt(0) as ComboContent;
				x = old.x;
				y = old.y;
				old.close();
			}
			cnt.show(x,y,parent);
		}
		
		
		public static function showMessage(msg:String, item:Object):ComboContent
		{
			trace("width=" + RunTime.mainApp.width);
			var cnt:ComboContent = new ComboContent();
			cnt.type = 'message';
			cnt.height = item.popupHeight;
			cnt.width = item.popupWidth;
			if(isNaN(cnt.height)) cnt.height = 400;
			if(isNaN(cnt.width)) cnt.width = 400;
			
			cnt.height = Math.min(cnt.height,RunTime.mainApp.height-100);
			cnt.width = Math.min(cnt.width,RunTime.mainApp.width-100);
			
			cnt.message = msg;
			cnt.showDialog();
			return cnt;
		}
		
		public static function showMessageHover(msg:String, x:Number, y:Number, item:Object):ComboContent
		{
			
			/*
			var tw:TitleWindow = new TitleWindow();
			tw.title = "My Title";
			PopUpManager.addPopUp(tw, RunTime.mainPage.getAudioLayer(), false);
			
			return null;
			
			*/
			
			var cnt:ComboContent = new ComboContent();
			cnt.type = 'message-hover';
			cnt.height = item.popupHeight;
			cnt.width = item.popupWidth;
			if(isNaN(cnt.height)) cnt.height = 400;
			if(isNaN(cnt.width)) cnt.width = 400;
			
			cnt.height = Math.min(cnt.height,RunTime.mainApp.height-100);
			cnt.width = Math.min(cnt.width,RunTime.mainApp.width-100);
			cnt.message = msg;
			cnt.showDialog(x,y,false);

			return cnt;
		}
		
		public static function showImageHover(url:String, x:Number, y:Number, item:Object, w:Number = NaN, h:Number = NaN):ComboContent
		{
			var cnt:ComboContent = new ComboContent();
			
			var callback:Function = function(width:Number, height:Number):void
			{
				cnt.type = 'image-hover';
				cnt.width = width;
				cnt.height = height;
				if(isNaN(cnt.height)) cnt.height = 400;
				if(isNaN(cnt.width)) cnt.width = 400;
				
				cnt.height = Math.min(cnt.height,RunTime.mainApp.height-100);
				cnt.width = Math.min(cnt.width,RunTime.mainApp.width-100);
				
				cnt.url = url;
				cnt.showDialog(x,y,false);
			};
			
			if(isNaN(w) || isNaN(h))
			{
				var margin:int = 40;
				var maxFitScale:Number = 1;
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, 
					function(e:Event):void
					{
						var bmp:Bitmap = loader.content as Bitmap;
						if(bmp == null) return;
						
						var metric:ImageMetricHelper = new ImageMetricHelper(bmp);
						var scale:Number = metric.getMaxFitScale((RunTime.mainApp.width - margin) * maxFitScale, (RunTime.mainApp.height - margin) * maxFitScale);
						scale = Math.min(scale,1); 
						callback(bmp.width * scale,bmp.height * scale);
					});
				loader.load(new URLRequest(url));
			}
			else
			{
				callback(w,h);
			}
			
			return cnt;
		}
	}
}