package controls
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	import mx.containers.Canvas;
	import mx.containers.TitleWindow;
	import mx.controls.Button;
	import mx.effects.Zoom;
	import mx.managers.PopUpManager;
	import mx.managers.PopUpManagerChildList;
	
	public class BasePopupCanvas extends Canvas
	{
		public static function zoom(control:BasePopupCanvas):void
		{
//			var effect:Zoom = new Zoom();
//			effect.zoomHeightFrom = 0;
//			effect.zoomHeightTo = 1;
//			effect.zoomWidthFrom = 0;
//			effect.zoomWidthTo = 1;
//			effect.play([control]);
		}
		
		public var isPopup:Boolean = true;
		
		public function showDialog(x:Number = NaN, y:Number = NaN, modal:Boolean = true):void
		{

			trace("showDialog");
			var parent:DisplayObject = RunTime.mainApp;
			
			/*
			var tw:TitleWindow = new TitleWindow();
			tw.title = "My Title";
			tw.width = 500;
			tw.height =500;
			tw.x = x;
			tw.y = y;
			var btn:Button = new Button();
			btn.label ="AAAAAAAAAAA";
			tw.addChild(btn);
			
			var cnt:ComboContent = new ComboContent();
			cnt.type = 'message';
			cnt.height = 400;
			cnt.width = 400;
			cnt.message = "HELLO";
			//tw.addChild(cnt);
			PopUpManager.addPopUp(cnt, parent, false);
			
			return;
			*/
			
			
			this.visible = true;
			PopUpManager.addPopUp(this, parent,modal);
	
			if(isNaN(x) || isNaN(y))
			{
				PopUpManager.centerPopUp(this);
			}
			else
			{
				this.x = x;
				this.y = y;
			}
			
			
			zoom(this);
		}
		
		public function show(x:Number = NaN, y:Number = NaN, parent:DisplayObjectContainer = null):void
		{
			if(parent == null) return;
			isPopup = false;

			if(isNaN(x) || isNaN(y))
			{
				//x = (RunTime.mainApp.width - this.width)/2;
				//y = (RunTime.mainApp.height - this.height)/2;
				
				x = 40;
				y = 40;
				
				if(RunTime.audioBoxPostion != null){
					x = RunTime.audioBoxPostion.x;
					y = RunTime.audioBoxPostion.y;
				}
				
			}
			
			this.x = x;
			this.y = y;
			
			parent.addChild(this);
			zoom(this);
		}
		
		public function close():void
		{
			if(isPopup == true)
			{
				PopUpManager.removePopUp(this);
			}
			else
			{
				if(this.parent != null)
				{
					this.parent.removeChild(this);
				}
			}
		}
	}
}