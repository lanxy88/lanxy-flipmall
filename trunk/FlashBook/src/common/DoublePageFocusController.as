package common
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	public class DoublePageFocusController extends FocusController
	{
		public override function computeOffsetX(content:DisplayObject, container:DisplayObject, scale:Number):Number
		{
			//trace("computeOffsetX DoublePage");
			if(focusMode == -1)
			{
				return -(content.x + container.x) * scale;
			}
			else
			{
				return -(content.x + content.width * 0.5 + container.x) * scale;
			}
		}
		
		public override function adjustFocusPoint(focusPoint:Point, zoomContent:DisplayObject, container:DisplayObject, scale:Number):Point
		{

			if(this.isDoublePage == true || this.focusMode == 0)
			{
				super.adjustFocusPoint(focusPoint,zoomContent,container,scale);
			}
			else if(this.focusMode == -1)
			{
				adjustLeftHalfFocusPoint(focusPoint,zoomContent,container,scale);
			}
			else if(this.focusMode == 1)
			{
				adjustRightHalfFocusPoint(focusPoint,zoomContent,container,scale);
			}
			
			return focusPoint;
		}
		
		private function adjustLeftHalfFocusPoint(focusPoint:Point, zoomContent:DisplayObject, container:DisplayObject, scale:Number):Point
		{
			var value:Point = focusPoint;
			var s:Number = scale;
			var target:DisplayObject = container;
			var minH:Number = RunTime.mainApp.height / (2*s);
			var minW:Number = RunTime.mainApp.width / (2 * s);
			
			var p0:Point = new Point(zoomContent.x,zoomContent.y);
			var p1:Point = new Point(zoomContent.x + zoomContent.width * 0.5,zoomContent.y + zoomContent.height);
			
			p0.x += minW;
			p0.x += 20 / scale;
			p0.y += minH;
			p1.x -= minW;
			p1.x -= 20 / scale;
			p1.y -= minH;
			
			if(value.x < p0.x) value.x = p0.x;
			else if(value.x > p1.x) value.x = p1.x;
			if(value.y < p0.y) value.y = p0.y;
			else if(value.y > p1.y) value.y = p1.y;
			
			// 当页面放大后，不能占满宽度时，进行处理
			if(p1.x < p0.x)
			{
				value.x = 0.5*(p0.x + p1.x);
			}
			
			// 当页面放大后，不能占满高度时，进行处理
			if(p1.y < p0.y)
			{
				value.y = 0.5*(p0.y + p1.y);
			}
			return value;
		}
		
		private function adjustRightHalfFocusPoint(focusPoint:Point, zoomContent:DisplayObject, container:DisplayObject, scale:Number):Point
		{
			var value:Point = focusPoint;
			var s:Number = scale;
			var target:DisplayObject = container;
			var minH:Number = RunTime.mainApp.height / (2*s);
			var minW:Number = RunTime.mainApp.width / (2 * s);
			
			var p0:Point = new Point(zoomContent.x + zoomContent.width * 0.5,zoomContent.y);
			var p1:Point = new Point(zoomContent.x + zoomContent.width,zoomContent.y + zoomContent.height);
			
			p0.x += minW;
			p0.x += 20 / scale;
			p0.y += minH;
			p1.x -= minW;
			p1.x -= 20 / scale;
			p1.y -= minH;
			
			if(value.x < p0.x) value.x = p0.x;
			else if(value.x > p1.x) value.x = p1.x;
			if(value.y < p0.y) value.y = p0.y;
			else if(value.y > p1.y) value.y = p1.y;
			
			// 当页面放大后，不能占满宽度时，进行处理
			if(p1.x < p0.x)
			{
				value.x = 0.5*(p0.x + p1.x);
			}
			
			// 当页面放大后，不能占满高度时，进行处理
			if(p1.y < p0.y)
			{
				value.y = 0.5*(p0.y + p1.y);
			}
			return value;
		}
	}
}