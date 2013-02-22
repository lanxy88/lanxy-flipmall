/**
 * @author xiaotie@geblab.com 
 */

package service
{
	import common.AudioBoxRecord;
	import common.BookMarkRecord;
	import common.HighlightRecord;
	import common.NoteRecord;
	import common.RpcRequest;
	import common.SharedObjectManager;
	
	import utils.Helper;

	public class LocalService extends BaseService implements IService
	{
		public function LocalService()
		{
		}

		public override function init(callback:Function):void
		{			
			if(callback != null) callback();
		}
		
		public override function loadLocalData():void
		{
			RunTime.noteRecords = SharedObjectManager.instance.getNoteRecords();
			RunTime.bookmarkRecords = RunTime.bookmarkRecords.concat(SharedObjectManager.instance.getBookmarks());
			RunTime.highlightRecords = SharedObjectManager.instance.getHighlights();
		}
		
		public override function createBookMark(item:BookMarkRecord):void
		{
			SharedObjectManager.instance.saveBookMarkRecord(item);
		}
		
		public override function updateBookMark(item:BookMarkRecord):void
		{
			SharedObjectManager.instance.saveBookMarkRecord(item);
		}
		
		public override function deleteBookMark(item:BookMarkRecord):void
		{
			SharedObjectManager.instance.deleteBookMarkRecord(item);
		}
		
		public override function createNote(item:NoteRecord):void
		{
			SharedObjectManager.instance.saveNoteRecord(item);
		}
		
		public override function updateNote(item:NoteRecord):void
		{
			SharedObjectManager.instance.saveNoteRecord(item);
		}
		
		public override function deleteNote(item:NoteRecord):void
		{
			SharedObjectManager.instance.deleteNoteRecord(item);
		}
		
		public override function requestNotes():void
		{
			RunTime.cfgFileLoadedCount++;
			RunTime.mainPage.updateProloadInfo();
		}
		
		public override function createHighlight(item:HighlightRecord):void
		{
			SharedObjectManager.instance.saveHighlightRecord(item);
		}
		
		public override function updateHighlight(item:HighlightRecord):void
		{
			SharedObjectManager.instance.saveHighlightRecord(item);
		}
		
		public override function createAudioBox(item:AudioBoxRecord):void{
			SharedObjectManager.instance.saveAudioboxRecord(item);
			
		}
		public override function updateAudioBox(item:AudioBoxRecord):void{
			SharedObjectManager.instance.saveAudioboxRecord(item);
		}
		
		public override function deleteHighlight(item:HighlightRecord):void
		{
			SharedObjectManager.instance.deleteHighlightRecord(item);
		}
		
		public override function requestHighlights():void
		{
			RunTime.cfgFileLoadedCount++;
			RunTime.mainPage.updateProloadInfo();
		}
		
		public override function requestBookMarks():void
		{
			new RpcRequest(RunTime.instance.bookmarksPath, null,
				parseBookMarks, RunTime.onConfigFileLoadFail);
		}
		
		private function parseBookMarks(xmlData: Object):void
		{
			RunTime.cfgFileLoadedCount++;
			
			var root:XML = new XML(xmlData);
			
			var list:Array = [];
			
			for each(var markNode:XML in root.bookmark)
			{
				var m:BookMarkRecord = new BookMarkRecord("",0,0,20,false);
				m.page = int(markNode.@page);
				m.content = String(markNode.@content);
				m.y = int(markNode.@y);
				m.bgColor = Helper.parseColor(markNode.@color);
				list.push(m);
			}
			
			RunTime.bookmarkRecords = RunTime.bookmarkRecords.concat(list);
			RunTime.mainPage.updateProloadInfo();
		}
	}
}