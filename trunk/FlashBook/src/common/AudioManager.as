package common
{
	import common.events.BookEvent;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	
	public class AudioManager
	{
		private var _bgSoundEnables:Boolean = true;
		
		private var _timer:Timer;
		
		public var flippingSound:Sound = null;
		
		public var clickSound:Sound = null;
		
		public var bgSounds:Array = [];
		
		private var _bgChannel:SoundChannel;
		
		private var _bgSound:Sound;
		
		private var _bgSoundPos:Number = NaN;
		
		private var _bgSoundPlaying:Boolean = false;
		
		
		
		[Bindable]
		public var flippingSoundEnabled:Boolean = true;
		
		[Bindable]
		public var clickSoundEnabled:Boolean = true;
		
		public function AudioManager():void
		{
			_timer = new Timer(1000,100000000);
			_timer.addEventListener(TimerEvent.TIMER,
				function(... args):void
				{
					playBgSound();
				}
			);
			_timer.start();
		}

		public function get bgSoundsEnabled():Boolean
		{
			return _bgSoundEnables;
		}
		
		private function playBgSound():void
		{
			if(_bgSoundEnables == false) return;
			if(bgSounds.length == 0) return;
			
			if(_bgSound != null && isNaN(_bgSoundPos) == false)
			{
				_bgChannel = _bgSound.play(_bgSoundPos);
				_bgSoundPlaying = true;
				_bgSoundPos = NaN;
				if(_bgChannel.hasEventListener(Event.SOUND_COMPLETE) == false)
				{
					_bgChannel.addEventListener(Event.SOUND_COMPLETE, onBgSoundComplete);
				}
				_timer.stop();
				return;
			}
			else
			{
				var index:int = 0;
				if(_bgSound != null)
				{
					index = bgSounds.indexOf(bgSounds) + 1;
				}
				
				for(var i:int = index ; i < index + bgSounds.length; i++)
				{
					var item:Sound = bgSounds[i%bgSounds.length];
					if(item.bytesLoaded == item.bytesTotal && item.bytesTotal > 0)
					{
						_bgSound = item;
						_bgChannel = item.play();
						_bgSoundPlaying = true;
						if(_bgChannel.hasEventListener(Event.SOUND_COMPLETE) == false)
						{
							_bgChannel.addEventListener(Event.SOUND_COMPLETE, onBgSoundComplete);
						}
						_timer.stop();
						break;
					}
				}
			}
		}
		
		private function onBgSoundComplete(e:Event):void
		{
			playBgSound();
		}
		
		[Bindable]
		public function set bgSoundsEnabled(value:Boolean):void
		{
			_bgSoundEnables = value;
			
			if(_bgSoundEnables) SoundMixer.soundTransform = new SoundTransform(1);
			else SoundMixer.soundTransform = new SoundTransform(0);
			
			if(value == false)
			{
				pauseBgSound();
			}
			else
			{
				playBgSound();
			}
		}
		
		private function pauseBgSound():void
		{
			if(_bgChannel != null)
			{
				_bgChannel.stop();
				_bgSoundPlaying = false;
				_bgSoundPos = _bgChannel.position;
			}
		}
		
		private function playSound(sound:Sound):void
		{
			if(sound == null) return;
			try
			{
				sound.play();
			} 
			catch(error:Error) 
			{
				
			}
			
		}
		
		public function playFlippingSound():void
		{
			if(flippingSoundEnabled == true)
			{
				this.playSound(this.flippingSound);
			}
		}
		
		public function playClickSound():void{
			//if(clickSoundEnabled){
				this.playSound(this.clickSound);
			//}
		}
		
		private var _tempSounds:SoundContainer;
		
		private var _tempSoundChannel:SoundChannel;
		
		private var _currentSoundWrap:SoundWrap;
		
		public function playTempSound(sounds:SoundContainer):void
		{
			if(sounds == null && _tempSounds == null) return;
			
			if(this.bgSoundsEnabled == false) return;
			
			_tempSounds = sounds;
			
			var soundWrap:SoundWrap = sounds.nextSoundWrap();
			if(soundWrap == null) return;
			_currentSoundWrap = soundWrap;
			var sound:Sound = soundWrap.sound;
			
			if(sound != null)
			{
				_tempSoundChannel = sound.play();
				if(_tempSoundChannel.hasEventListener(Event.SOUND_COMPLETE) == false)
				{
					_tempSoundChannel.addEventListener(Event.SOUND_COMPLETE, onTempSoundComplete);
				}
			}			
		}
		
		private function onTempSoundComplete(e:Event):void
		{
			//刚播放完毕的这首音乐设置了重复播放，一直播放这首，不播放下一首
			if(_currentSoundWrap != null && _currentSoundWrap.repeat){
				//trace("sound repeat......");
				var sound:Sound = _currentSoundWrap.sound;
				if(sound != null)
				{
					_tempSoundChannel = sound.play();
					_tempSoundChannel.removeEventListener(Event.SOUND_COMPLETE, onTempSoundComplete);
					_tempSoundChannel.addEventListener(Event.SOUND_COMPLETE, onTempSoundComplete);

				}
				return;
			}
			
			if(_tempSounds != null)
			{
				var soundWrap:SoundWrap = _tempSounds.nextSoundWrap();
				_currentSoundWrap = soundWrap;
				if(soundWrap == null) return;
				var sound:Sound = soundWrap.sound;
				if(sound != null)
				{
					_tempSoundChannel = sound.play();
					_tempSoundChannel.removeEventListener(Event.SOUND_COMPLETE, onTempSoundComplete);
					_tempSoundChannel.addEventListener(Event.SOUND_COMPLETE, onTempSoundComplete);
				}
			}
		}
		
		public function stopTempSound():void
		{
			if(_tempSoundChannel != null)
			{
				_tempSoundChannel.stop();
				_tempSounds = null;
				_tempSoundChannel = null;
			}
		}
	}
}