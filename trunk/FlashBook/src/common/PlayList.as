package common
{
	import flash.media.Sound;

	public dynamic class PlayList extends Array
	{
		private var _index:int = 0;
		
		public function next():String
		{
			if(length > _index)
			{
				var list:Array = this;
				var item:String = list[_index] as String;
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