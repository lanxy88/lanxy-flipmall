package
{
	import common.ButtonInfo;
	import common.HighlightRecord;
	import common.NoteRecord;
	
	import controls.ButtonBox;
	
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;

	public interface IMainApp
	{
		function updateNotes():void;
		
		function shiftLeft():void;
		
		function gotoPage(page:int):void;
		function gotoPageIndex(pageIndex:int):void;
		
		function zoomInBook(focus:Point = null, limit:Number = 0): void;
		
		function zoomBook(offset:Number):void;
		
		function switchFullScreenMode():void;
		
		function addHighlight(record:HighlightRecord):void;
			
		function deleteHighlight(record:HighlightRecord):void;
			
		function deleteNote(record:NoteRecord):void;
		
		function updateBookMarks():void;
		
		function getAudioLayer():DisplayObjectContainer;
		
		function getBgAudioLayer():DisplayObjectContainer;
		
		function get bookLayoutPageCount():int;
		
		function get controlBars():Array;
		
		function updateProloadInfo():void;
		
		function addFunButton(layer:int,button:ButtonBox):void;
		
		function callButtonFunction(fun:String):void;
	}
}