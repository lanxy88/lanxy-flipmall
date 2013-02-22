package controls
{
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	
	import mx.core.UIComponent;

	public class PolygonIcon extends UIComponent
	{
		private var _points:Array;
		

		
		public function get points():Array
		{
			return _points;
		}
		
		public function set points(value:Array):void
		{
			if(_points == value) return;
			
			_points = value;
			this.invalidateDisplayList();
		}
		
		private var _color:uint = 0xFFFFFF;
		
		public function get color():uint
		{
			return _color;
		}
		
		public function set color(value:uint):void
		{
			if(_color == value) return;
			
			_color = value;
			this.invalidateDisplayList();
		}
		
		private var _fillAlpha:Number = 1;
		
		public function get fillAlpha():Number
		{
			return _fillAlpha;
		}
		
		public function set fillAlpha(value:Number):void
		{
			_fillAlpha = value;
			this.invalidateDisplayList();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			
			var g:Graphics = this.graphics;
			g.clear();
			
			if(points == null || points.length == 0) return;
			
			g.lineStyle(10,0xffffff,1,false,"normal",CapsStyle.SQUARE,JointStyle.MITER);
			
			g.moveTo(points[0].x, points[0].y);
			for(var i:int = 1; i < points.length; i++)
			{
				g.lineTo(points[i].x,points[i].y);
			}
			/*
			g.moveTo(points[0].x,points[0].y);
			
			g.beginFill(color, this.fillAlpha);
			
			for(var i:int = 1; i < points.length; i++)
			{
				g.lineTo(points[i].x,points[i].y);
			}
			
			g.lineTo(points[0].x,points[0].y);
			
			g.endFill();
			*/
		}

	}
}