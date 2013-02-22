package
{
	import common.RpcRequest;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import mx.controls.SWFLoader;
	import mx.events.FlexEvent;
	import mx.preloaders.DownloadProgressBar;
	
	public class SwfPreloader extends DownloadProgressBar
	{
		//显示进度的文字
		private var progressText:TextField;
		private var slices:int = 12;
		private var radius:int = 11;
		
		[Bindable]
		private var value:int = 0;
		
		//logo页面
		private var _timer:Timer;
		
		private var timerDelay:int = 100;
		private var sliceColor:uint = 0xFFFFFF;
		private var cycleContainer:Sprite = null;
		
		private var bg:Sprite;
		
		public function SwfPreloader()
		{
			super();
			bg = new Sprite();
			this.addChild(bg);

			var fm:TextFormat = new TextFormat();
			fm.align = "center";
			fm.color = 0xFFFFFF;
			progressText = new TextField();
			progressText.width = 100;
			progressText.x = -50 + 3;
			progressText.y = 50 - 10;
			progressText.defaultTextFormat = fm;
			this.addChild(progressText);
			
			draw();
			
			_timer = new Timer(timerDelay);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			_timer.start();
			
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
			{
				stage.addEventListener(Event.RESIZE, onResize);
			});
			
			new RpcRequest("data/bookinfo.xml", null, onReceiveBookinfo);
		}
		
		private function onReceiveBookinfo(xmlData: Object):void
		{
			var root:XML = new XML(xmlData);
			if(String(root.@loadingLogo))
			{
				if(this.loaderInfo == null) return;
				
				var logoPath:String = String(root.@loadingLogo);
				var path:String = this.loaderInfo.url;
				var index:int = path.indexOf("?");
				if(index > 0)
				{
					path = path.substr(0,index);
				}
				var i:int = path.indexOf(".swf");
				if(i > 0)
				{
					path = path.substr(0,i) + "9483728472839487628394058" + path.substr(i + 4);
				}
				Setting.basePath = path.replace( /\w+9483728472839487628394058/gi, '' );
				logoPath = Setting.getAbsPath(logoPath);
				var self:SwfPreloader = this;
				var loader:Loader = new Loader();
				loader.load(new URLRequest(logoPath));
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,
					function(e:Event):void
					{
						var bmp:Bitmap = loader.content as Bitmap;
						bmp.x = - bmp.width * 0.5;
						bmp.y = - bmp.height - 50;
						var clone:BitmapData =bmp.bitmapData.clone();
						Setting.logo = new Bitmap(clone,"auto",true); 
						self.addChild(bmp);
					});
			}
		}
		
		private function onResize(e:Event):void
		{
			x = (stageWidth/2);
			y = (stageHeight/2);
			bg.graphics.clear();
			bg.graphics.beginFill(0x454545);
			//bg.graphics.beginFill(0xFF0000);
			bg.graphics.drawRect(-x,-y,stageWidth, stageHeight);
		}
		
		private function draw():void
		{
			var ui:Sprite = new Sprite();
			var i:int = slices;
			var degrees:int = 360 / slices;
			while (i--)
			{
				var slice:Shape = getSlice();
				slice.alpha = Math.max(0.2, 1 - (0.1 * i));
				var radianAngle:Number = (degrees * i) * Math.PI / 180;
				slice.rotation = -degrees * i;
				slice.x = Math.sin(radianAngle) * radius;
				slice.y = Math.cos(radianAngle) * radius;
				ui.addChild(slice);
			}
			this.addChild(ui);
			cycleContainer = ui;
		}
		
		private function getSlice():Shape
		{
			var slice:Shape = new Shape();
			slice.graphics.beginFill(sliceColor);
			slice.graphics.drawRoundRect(-1, 0, 4, 14, 4, 4);
			slice.graphics.endFill();
			return slice;
		}
		
		override public function set preloader(value:Sprite):void
		{
			value.addEventListener(ProgressEvent.PROGRESS, onProg);
			value.addEventListener(FlexEvent.INIT_COMPLETE, onInitComplete);
			onResize(null);
		}
		
		private function onProg(e:ProgressEvent):void
		{
			var prog:Number = e.bytesLoaded/e.bytesTotal*100;
			progressText.text = String(int(prog)) + "%";
		}
		
		private function onInitComplete(e:FlexEvent):void
		{
			_timer.stop();
			if(stage != null)
			{
				stage.addEventListener(Event.RESIZE, onResize);
			}
			this.dispatchEvent(new Event(Event.COMPLETE));
			Setting.swfLoaded = true;
		}
		
		private function onTimer(event:TimerEvent):void
		{
			if(cycleContainer != null)
				cycleContainer.rotation = (cycleContainer.rotation + (360 / slices)) % 360;
		}
	}
}