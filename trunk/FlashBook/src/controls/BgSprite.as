package controls
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;

	public class BgSprite extends Sprite
	{
		protected var _width:Number = 0;
		protected var _height:Number = 0;
		
		override public function set width(w:Number):void
		{
			_width = w;
			draw(null);
		}
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function set height(h:Number):void
		{
			_height = h;
			draw(null);
		}
		
		override public function get height():Number
		{
			return _height;
		}
		
		public function BgSprite()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, draw);
		}
		
		private function draw(e:Event):void
		{
			var g:Graphics = this.graphics;
			g.clear();
			g.beginFill(0x333333);
			g.drawRect(0,0,width*this.scaleX,height*this.scaleY);
			g.endFill();
		}
	}
}