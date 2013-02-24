package orc.utils;

class ImageMetricHelper
{
		/**
		 * 对角线的弧度值 
		 */		
		public var diagonalLineTheta:Float;
		
		/**
		 * 对角线的长度值 
		 */		
		public var diagonalLineLength:Float;
		
		public var width:Float;
		
		public var height:Float;
		
		public function new(imgWidth:Float,imgHeight:Float)
		{
			width = imgWidth;
			height = imgHeight;
			diagonalLineTheta = Math.atan2(width, height);
			diagonalLineLength = Math.sqrt(width *width + height * height);
		}
				
		/**
		 * 获得针对指定长宽的最大缩放尺度 
		 * @param width 宽
		 * @param height 长
		 * @param rotation 图像的旋转角度
		 * @return 最大缩放尺度
		 * 
		 */		
		public function getMaxFitScale(width:Float, height:Float, rotation:Float = 0):Float
		{
			var scaleX:Float;
			var scaleY:Float;
			
			if(rotation == 0 || rotation == 180)
			{
				scaleX = width / this.width;
				scaleY = height / this.height;
			}
			else
			{
				var r:Float = Math.PI * rotation / 180;
				var t0:Float = diagonalLineTheta + r;
				var w0:Float = Math.abs(diagonalLineLength * Math.sin(t0));
				var h0:Float = Math.abs(diagonalLineLength * Math.cos(t0));
				var t1:Float = -diagonalLineTheta + r;
				var w1:Float = Math.abs(diagonalLineLength * Math.sin(t1));
				var h1:Float = Math.abs(diagonalLineLength * Math.cos(t1));
				var w:Float = Math.max(w0,w1);
				var h:Float = Math.max(h0,h1);
				scaleX = width / w;
				scaleY = height / h;
			}
			return Math.min(scaleX,scaleY);
		}
}