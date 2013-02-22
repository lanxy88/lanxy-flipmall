package controls.SkinClasses
{
	import mx.core.UIComponent;

	public class HightlightTrack extends UIComponent
	{
		override public function get height():Number{
			return 10;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			this.graphics.clear();
			this.graphics.beginFill(0xFF0000,1);
			this.graphics.lineStyle(10,0xFF0000,1,false,"normal","none","bevel");
			this.graphics.moveTo(0,4);
			this.graphics.lineTo(unscaledWidth,4);
		}
	}
}