package common
{
	import flash.media.Sound;

	public dynamic class SoundContainer extends Array
	{
		private var _index:int = 0;
		
		public function next():Sound
		{
			if(length > _index)
			{
				var list:Array = this;
				var item:Sound = list[_index] as Sound;
				_index ++;
				return item;
			}
			else
			{
				return null;
			}
		}
		
		/**
		 * 下一个音乐包装
		 */
		public function nextSoundWrap():SoundWrap
		{
			if(length > _index)
			{
				var list:Array = this;
				var item:SoundWrap = list[_index] as SoundWrap;
				_index ++;
				return item;
			}
			else
			{
				return null;
			}
		}
	}
}