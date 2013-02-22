package icons
{
	import mx.controls.sliderClasses.SliderThumb;
	
	public class VideoSliderThumb extends SliderThumb
	{
		public function VideoSliderThumb()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			this.graphics.beginFill(0xeeeeee,1);
			this.graphics.drawCircle(7,7,9);
			this.graphics.endFill();
		}

	}
}