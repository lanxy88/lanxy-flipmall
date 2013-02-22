package common
{
	import flash.media.Sound;

	/**
	 * 
	 * Sound包装类
	 * 
	 */
	public dynamic class SoundWrap extends Array
	{
		public var repeat:Boolean;
		public var showControlBar:Boolean;
		public var sound:Sound;
		public var url:String;
		
		public function SoundWrap(sound:Sound, repeat:Boolean = false,showCotrolBar:Boolean= false,url:String=null)
		{
			this.sound = sound;
			this.repeat = repeat;
			this.showControlBar = showCotrolBar;
			this.url = url;
		}
	}
}