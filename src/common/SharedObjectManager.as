package common
{
	import flash.net.SharedObject;

	public class SharedObjectManager
	{
		public static var instance:SharedObjectManager = new SharedObjectManager();
		
		public var id:String = "";
		
		private function get bookCfgKey():String
		{
			return id + "_cfg";
		}
		
		private function get noteRecordsKey():String
		{
			return id + "_notes";
		}
		
		private function get highlightRecordsKey():String
		{
			return id + "_highlights";
		}
		
		private function get audioboxRecrodsKey():String
		{
			return id + "_audioboxs";
		}
		
		private function get bookmarkRecordsKey():String
		{
			return id + "_bookmarks";
		}
		
		private function get localSettingKey():String
		{
			return "localSetting";
		}
		
		private function get highlightColorKey():String
		{
			return "highlightColor";
		}
		
		private var notes:Array = null;
		
		private var highlights:Array = null;
		
		private var audioboxs:Array = null;
		
		private var bookmarks:Array = null;
		
		private var audioVolume:Number = NaN;
		
		public var highlightColor:uint = HighlightRecord.emptyColor;
		
		public function saveAudioVolume():void
		{
			var setting:Object = getLocalSetting();
			setting.audioVolume = RunTime.audioVolume;
			saveLocalSetting(setting);
		}
		
		public function saveAudioBoxPostion():void{
			var setting:Object = getLocalSetting();
			if(RunTime.audioBoxPostion != null){
				setting.audioBoxPostionX = RunTime.audioBoxPostion.x;
				setting.audioBoxPostionY = RunTime.audioBoxPostion.y;
			}
			saveLocalSetting(setting);
		}
		
		public function saveDefaultZoomScale(scale:Number):void
		{
			var so:SharedObject = SharedObject.getLocal(bookCfgKey);
			so.data.defaultZoomScale = scale;
			so.flush();
		}
		
		private function checkHighlightColor():void
		{
			if(highlightColor == HighlightRecord.emptyColor)
			{
				var so:SharedObject = SharedObject.getLocal(highlightColorKey);
				if(so.data.hasOwnProperty("highlightColor"))
				{
					highlightColor = so.data.highlightColor;
				}
			}
		}
		
		private function checkNotes():void
		{
			if(notes == null)
			{
				var so:SharedObject = SharedObject.getLocal(noteRecordsKey);
				notes = so.data.notes as Array;
				if(notes == null) notes = [];
			}
		}
		
		private function checkHighlights():void
		{
			if(highlights == null)
			{
				var so:SharedObject = SharedObject.getLocal(highlightRecordsKey);
				highlights = so.data.highlights as Array;
				if(highlights == null) highlights = [];
			}
		}
		/**
		 * 获取audio播放器的位置
		 */
		private function checkAudioboxs():void{
			if(audioboxs == null){
				var so:SharedObject = SharedObject.getLocal(audioboxRecrodsKey);
				audioboxs = so.data.audioboxs as Array;
				if(audioboxs == null) audioboxs =[];
			}
		}
		
		private function checkBookmarks():void
		{
			if(bookmarks == null)
			{
				var so:SharedObject = SharedObject.getLocal(bookmarkRecordsKey);
				bookmarks = so.data.bookmarks as Array;
				if(bookmarks == null) bookmarks = [];
			}
		}
		
		public function getLocalDefaultScale():Number
		{
			var so:SharedObject = SharedObject.getLocal(bookCfgKey);
			if(so.data.hasOwnProperty("defaultZoomScale"))
			{
				return Number(so.data.defaultZoomScale);
			}
			return NaN;
		}
		
		public function getHighlightColor():uint
		{
			checkHighlightColor();
			return this.highlightColor;
		}
		
		public function getNoteRecords():Array
		{
			var list:Array = [];
			checkNotes();
			for each(var item:Object in notes)
			{
				list.push(NoteRecord.createFrom(item));
			}
			return list;
		}
		
		public function getHighlights():Array
		{
			var list:Array = [];
			checkHighlights();
			for each(var item:Object in highlights)
			{
				list.push(HighlightRecord.createFrom(item));
			}
			return list;
		}
		
		public function getAudioboxs():Array{
			var list:Array = [];
			checkAudioboxs();
			for each(var item:Object in audioboxs)
			{
				list.push(AudioBoxRecord.createFrom(item));
			}
			return list;
		}
		
		public function getLocalSetting():Object
		{
			var so:SharedObject = SharedObject.getLocal(localSettingKey, "/");
			if(so.data.localSetting)
			{
				return so.data.localSetting;	
			}
			else
			{
				return {};
			}
		}
		
		public function saveLocalSetting(obj:Object):void
		{
			var so:SharedObject = SharedObject.getLocal(localSettingKey, "/");
			so.data.localSetting = obj;
			so.flush();
		}
		
		public function getBookmarks():Array
		{
			var list:Array = [];
			checkBookmarks();
			for each(var item:Object in bookmarks)
			{
				list.push(BookMarkRecord.createFrom(item));
			}
			return list;
		}
		
		private function saveNoteRecords():void
		{
			var so:SharedObject = SharedObject.getLocal(noteRecordsKey);
			so.data.notes = notes;
			so.flush();
		}
		
		private function saveHighlights():void
		{
			var so:SharedObject = SharedObject.getLocal(highlightRecordsKey);
			so.data.highlights = highlights;
			so.flush();
		}
		
		private function saveAudioboxs():void{
			var so:SharedObject = SharedObject.getLocal(audioboxRecrodsKey);
			so.data.audioboxs = audioboxs;
			so.flush();
		}
		
		public function saveHighlightColor():void
		{
			var so:SharedObject = SharedObject.getLocal(highlightColorKey);
			so.data.highlightColor = highlightColor;
			so.flush();
		}
		
		
		
		private function saveBookMarks():void
		{
			var so:SharedObject = SharedObject.getLocal(bookmarkRecordsKey);
			so.data.bookmarks = bookmarks;
			so.flush();
		}
		
		public function saveNoteRecord(r:NoteRecord):void
		{
			if(r == null) return;
			checkNotes();
			var newNotes:Array = [];
			for each(var item :Object in this.notes)
			{
				if(item.guid != r.guid) 
				{
					newNotes.push(item);
				}
			}
			newNotes.push(r.toObject());
			notes = newNotes;
			saveNoteRecords();
		}
		
		public function saveHighlightRecord(r:HighlightRecord):void
		{
			if(r == null) return;
			checkHighlights();
			var newHighlights:Array = [];
			for each(var item :Object in this.highlights)
			{
				if(item.guid != r.guid) 
				{
					newHighlights.push(item);
				}
			}
			
			newHighlights.push(r.toObject());
			highlights = newHighlights;
			saveHighlights();
		}
		
		public function saveAudioboxRecord(r:AudioBoxRecord):void{
			if(r == null) return;
			checkAudioboxs();
			var newAudioboxs:Array = [];
			for each(var item :Object in this.audioboxs)
			{
				if(item.guid != r.guid) 
				{
					newAudioboxs.push(item);
				}
			}
			newAudioboxs.push(r.toObject());
			audioboxs = newAudioboxs;
			saveAudioboxs();
		}
		
		public function saveBookMarkRecord(r:BookMarkRecord):void
		{
			if(r == null) return;
			checkBookmarks();
			var newBookmarks:Array = [];
			for each(var item :Object in this.bookmarks)
			{
				if(item.guid != r.guid) 
				{
					newBookmarks.push(item);
				}
			}
			
			newBookmarks.push(r.toObject());
			bookmarks = newBookmarks;
			saveBookMarks();
		}
		
		public function deleteNoteRecord(r:NoteRecord):void
		{
			if(r == null) return;
			checkNotes();
			var newNotes:Array = [];
			for each(var item :Object in this.notes)
			{
				if(item.guid != r.guid) 
				{
					newNotes.push(item);
				}
			}
			notes = newNotes;
			saveNoteRecords();
		}
		
		public function deleteHighlightRecord(r:HighlightRecord):void
		{
			if(r == null) return;
			checkHighlights();
			var newHighlights:Array = [];
			for each(var item :Object in this.highlights)
			{
				if(item.guid != r.guid) 
				{
					newHighlights.push(item);
				}
			}
			
			highlights = newHighlights;
			saveHighlights();
		}
		
		public function deleteBookMarkRecord(r:BookMarkRecord):void
		{
			if(r == null) return;
			checkBookmarks();
			var newBookmarks:Array = [];
			for each(var item :Object in this.bookmarks)
			{
				if(item.guid != r.guid) 
				{
					newBookmarks.push(item);
				}
			}
			bookmarks = newBookmarks;
			saveBookMarks();
		}
		
		public function clearNoteRecords():void
		{
			notes = [];
			saveNoteRecords();
		}
		
		public function clearHighlightRecords():void
		{
			highlights = [];
			saveHighlights();
		}
		
		public function clearBookMarks():void
		{
			bookmarks = [];
			saveBookMarks();
		}
	}
}