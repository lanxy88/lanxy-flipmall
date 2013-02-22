package utils
{
	import controls.ButtonBox;
	import controls.HighlightMark;
	import controls.HotLinkBox;
	import controls.VideoBox;
	
	import flash.display.DisplayObject;
	
	import mx.controls.Label;
	import mx.controls.TextArea;
	import mx.core.UIComponent;
	import mx.core.UITextField;

	public class MouseStateHelper
	{
		public static function isToolTipActive(obj:Object):Boolean
		{
			if(obj is HotLinkBox 
				|| obj is TextArea 
				|| obj is Label 
				|| obj is UITextField
				|| obj is ButtonBox
				|| obj is VideoBox
			)
			{
				if(obj is ButtonBox)
				{
					var bbox:ButtonBox = obj as ButtonBox;
					return bbox.isTooltipActive;
				}
				else
				{
					return false;
				}
			}
			else
			{
				var display:DisplayObject = obj as DisplayObject;
				if(display != null)
				{
					if(display.parent != null && display.parent != display)
					{
						return isToolTipActive(display.parent);
					}
				}
				return true;	
			}
		}
		
		public static function isZoomActive(obj:Object):Boolean
		{
			if(obj is HighlightMark || obj is ComboLinkPage)
			{
				return true;
			}
			else if(obj is ButtonBox)
			{
				var bbox:ButtonBox = obj as ButtonBox;
				return bbox.isTooltipActive;
			}
			else if(obj is UITextField)
			{
				return false;
			}
			else
			{
				return !(obj is UIComponent);
			}
		}
	}
}