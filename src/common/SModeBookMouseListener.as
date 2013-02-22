package common
{
	import controls.BaseVBox;
	import controls.HighlightMark;
	import controls.NoteMark;
	import controls.SModeBook;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.engine.BreakOpportunity;
	
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.managers.CursorManager;
	
	import qs.controls.FlexBook;
	
	import utils.Helper;
	
	public class SModeBookMouseListener
	{
		private var book:SModeBook;
		
		private var mouseDownPoint:Point;
		private var mouseUpPoint:Point;
		private var mousePoint:Point;
		
		public function SModeBookMouseListener(book:SModeBook)
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
			if(RunTime.mouseWheelZoom){
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

		private function onMouseDown(event:MouseEvent):void
		{
			mouseDownPoint = new Point(event.stageX,event.stageY);
			var root:Point = book.localToGlobal(new Point());
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
					var record:HighlightRecord = new HighlightRecord("",
						book.currentPage,
						(mouseDownPoint.x - root.x)/book.width,
						(mouseDownPoint.y - root.y - HighlightRecord.MIN_SIZE)/book.height);
					record.finished = false;
					record.addParent(book);
					record.highlightMark.drawing = true;
					RunTime.CurrentMovingObject = record.highlightMark;
					break;
				case RunTime.MOUSE_STATE_PENDING:
					setNormal();
					break;
				default:
					
					break;
			}
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
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
						
			var p:Point = new Point(event.stageX,event.stageY);
			var root:Point = book.localToGlobal(new Point());
			
			switch(RunTime.MouseState)
			{
				case RunTime.MOUSE_STATE_NOTE_MOVING:
					if(mousePoint != null && mouseDownPoint != null 
						&& RunTime.CurrentMovingObject != null
						&& RunTime.CurrentMovingObject is NoteMark
					)
					{
						var m:NoteMark = RunTime.CurrentMovingObject as NoteMark;
						if(m.parent == null) return;
						
						var xx:Number = m.x + p.x - mousePoint.x;
						var yy:Number = m.y + p.y - mousePoint.y;
						var pWidth:Number = (m.parent as DisplayObject).width;
						var pHeight:Number = (m.parent as DisplayObject).height;
						
						if(xx >= 0 && yy >= 0 && xx  < pWidth && yy < pHeight)
						{
							m.moveTo(xx,yy);
							
							var r:NoteRecord = m.record;
							r.xPos = m.x / pWidth;
							r.yPos = m.y / pHeight;
						}
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