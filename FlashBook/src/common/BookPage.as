package common
{
	import flash.media.Sound;

	[Bindable]
	public class BookPage
	{
		public var pageId: int = -1;
		public var isFrontCover: Boolean = false;
		public var isBackCover: Boolean = false;
		public var shadow:Boolean = true;
		public var thumb: String = "";
		public var source: String = "";

		public var loaded: Boolean = false;

		public var downloadLink: String = "";
		
		public var sound:Sound = null;
		
		public var soundRepeat:Boolean = false;
		
		public var soundControl:Boolean = false;
		
		public var bgSoundUrl:String ="";
		
		public var controlBar:Boolean = false;
		
		public var canZoom:Boolean = true;

		public function toString(): String
		{
			var pageType: String = "Page"
			if (isFrontCover)
			{
				pageType = "Front Cover";
			} else if (isBackCover)
			{
				pageType = "Back Cover";
			}
			return "[" + pageType + ", pageId=" + pageId + " ]";
		}

	}
}