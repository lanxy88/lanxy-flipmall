package common
{
	import controls.BaseVBox;
	import controls.HighlightMark;
	import controls.NoteMark;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.system.System;
	
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.core.UIComponent;
	import mx.managers.CursorManager;
	
	import qs.controls.FlexBook;
	
	import utils.Helper;
	
	public class BookMouseListener
	{
		private var book:FlexBook;

		private var mouseDownPoint:Point;
		private var mouseUpPoint:Point;
		private var mousePoint:Point;
		
		private var lastClickTime:Number = 0;
		
		public function BookMouseListener(book:FlexBook)
		{
			this.book = book;
			book.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			book.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			book.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			book.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			book.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			book.addEventListener(MouseEvent.DOUBLE_CLICK, onMouseDoubleClick);
			book.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}
		
		private function onMouseWheel(event:MouseEvent):void
		{
			if(RunTime.mouseWheelZoom && RunTime.zoomedIn){
				//阻止滚轮默认行为
				event.preventDefault();
				event.stopPropagation();
				//trace(event.delta);
				
				if(event.delta > 0){
					//向下滚动，放大
				}
				else{
					//向上滚动，缩小
				}
				RunTime.mainPage.zoomBook(event.delta);
			}
			
		}
		
		private function onMouseDoubleClick(event:MouseEvent):void
		{
			var localP:Point = book.globalToLocal(new Point(event.stageX, event.stageY));
			switch(RunTime.MouseState)
			{
				case RunTime.MOUSE_STATE_NORMAL:
					if( RunTime.note.length == 0
						&& RunTime.zoomedIn == false
						&& isStagePointInBookArea(localP) == true
					)
					{
						var p:Point = new Point(event.stageX, event.stageY);
						if(RunTime.isDoubleClickToZoom() == true)
						{
							RunTime.mainPage.zoomInBook(p);
						}
					}
			}
		}
		
		private function isStagePointInBookArea(p:Point):Boolean
		{
			if(book.getLeftPageNumber() == -1 && p.x < book.width/2)
			{
				return false;
			}
			else if(book.getRightPageNumber() == -1 && p.x > book.width/2)
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			mouseDownPoint = new Point(event.stageX,event.stageY);
			
			mouseDownPoint = book.globalToLocal(mouseDownPoint);
			
			var root:Point = book.localToGlobal(new Point());
			
			root = new Point();
			
			var local:Point = new Point(mouseDownPoint.x - root.x,mouseDownPoint.y - root.y);
			switch(RunTime.MouseState)
			{
				case RunTime.MOUSE_STATE_NOTE_DELETING:
					var btn:Button = event.target as mx.controls.Button;
					if(btn==null)
					{
						RunTime.MouseState = RunTime.MOUSE_STATE_PENDING;
					}
					break;
				case RunTime.MOUSE_STATE_NOTE_MOVING:
					if( RunTime.CurrentMovingObject != null
						&& RunTime.CurrentMovingObject is NoteMark
					)
					{
						Helper.bringTop(RunTime.CurrentMovingObject as NoteMark);
					}
					break;
				case RunTime.MOUSE_STATE_HIGHLIGHT_ON:
					if( (book.getLeftPageNumber()==-1 && local.x > book.width/2)
						|| (book.getRightPageNumber()==-1 && local.x < book.width/2)
						|| (book.getLeftPageNumber()>-1 && book.getRightPageNumber() > -1))
					{
						var record:HighlightRecord = new HighlightRecord("",
							book.getLeftPageNumber(),
							(mouseDownPoint.x - root.x)/book.width,
							(mouseDownPoint.y - root.y - HighlightRecord.MIN_SIZE)/book.height);
						record.finished = false;
						record.addParent(book);
						record.highlightMark.drawing = true;
						RunTime.CurrentMovingObject = record.highlightMark;
						break;
					}
				case RunTime.MOUSE_STATE_PENDING:
					setNormal();
					break;
				default:
					book.receiveMouseClick(event);
					break;
			}
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			//trace("Book mouseup");
			if(RunTime.MouseState == RunTime.MOUSE_STATE_HIGHLIGHT_ON)
			{
				if(RunTime.CurrentMovingObject is HighlightMark)
				{
					HighlightMark(RunTime.CurrentMovingObject).drawing = false;
					RunTime.service.updateHighlight(HighlightMark(RunTime.CurrentMovingObject).record);
				}
				
				RunTime.CurrentMovingObject = null;
			}
			else if(RunTime.MouseState != RunTime.MOUSE_STATE_NOTE_DELETING
				&& RunTime.MouseState != RunTime.MOUSE_STATE_NOTE_DETAIL_MOVING
				&& RunTime.MouseState != RunTime.MOUSE_STATE_HIGHLIGHT_DETAIL_MOVING
			)
			{
				setNormal();
			}
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			//trace("event.stageX=" + event.stageX + ",event.stageY=" +event.stageY );
			var p:Point = new Point(event.stageX,event.stageY);
			var root:Point = book.localToGlobal(new Point());
			p = book.globalToLocal(p);
			root = new Point();
			
			switch(RunTime.MouseState)
			{
				case RunTime.MOUSE_STATE_NOTE_MOVING:
					
					if(mousePoint != null 
						&& RunTime.CurrentMovingObject != null
						&& RunTime.CurrentMovingObject is NoteMark
					)
					{

					}
					break;
				case RunTime.MOUSE_STATE_HIGHLIGHT_ON:
					if(mousePoint != null && mouseDownPoint != null 
						&& RunTime.CurrentMovingObject != null
						&& RunTime.CurrentMovingObject is HighlightMark
					)
					{
						if(HighlightMark(RunTime.CurrentMovingObject).drawing == true)
						{
							HighlightMark(RunTime.CurrentMovingObject).extendTo(p.x - root.x,p.y - root.y);
						}
					}
					break;
			}

			mousePoint = p; 
		}
	
		
		private function onMouseOver(event:MouseEvent):void
		{
			if(RunTime.MouseState == RunTime.MOUSE_STATE_HIGHLIGHT_ON)
			{
				CursorManager.setCursor(RunTime.CURSOR_HIGHLIGHT,2,0,-30);
			}
		}
		
		private function onMouseOut(event:MouseEvent):void
		{
			if(RunTime.CurrentMovingObject != null && RunTime.CurrentMovingObject is BaseVBox)
			{
				return;
			}
			
			if(RunTime.note)
			{
				return;
			}
			
			var p:Point = new Point(event.stageX,event.stageY);
			var tl:Point = book.localToGlobal(new Point());
			if(p.x < tl.x + 2 || p.y < tl.y + 2 || p.x > tl.x + book.width - 2 || p.y > tl.y + book.height - 2)
			{
				CursorManager.removeAllCursors();
				
				if(RunTime.CurrentMovingObject!= null && RunTime.CurrentMovingObject is HighlightMark)
				{
					HighlightMark(RunTime.CurrentMovingObject).drawing = false;
				}
				
				mouseDownPoint = null;
				mouseUpPoint = null;
				
				if(RunTime.MouseState != RunTime.MOUSE_STATE_NOTE_DELETING
				&& RunTime.MouseState != RunTime.MOUSE_STATE_NOTE_DETAIL_MOVING
				&& RunTime.MouseState != RunTime.MOUSE_STATE_HIGHLIGHT_ON)
					setNormal();
			}
			else
			{
				// 在book的范围内释放鼠标，则什么也不做
			}
		}
		
		private function setNormal():void
		{
			mouseUpPoint = null;
			mouseDownPoint = null;
			RunTime.setNormal();
		}
	}
}