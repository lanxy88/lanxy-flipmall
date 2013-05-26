package common
{
	import common.events.BookEvent;
	
	import controls.BaseVBox;
	import controls.BgAudioBox;
	import controls.ComboContent;
	import controls.HighlightMark;
	import controls.HighlightMarkDetail;
	import controls.NoteMark;
	import controls.NoteMarkDetail;
	import controls.ZoomBox;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.engine.BreakOpportunity;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.core.UIComponent;
	import mx.core.UITextField;
	import mx.managers.CursorManager;
	
	import qs.controls.FlexBook;
	
	import utils.Helper;
	import utils.MouseStateHelper;
	import utils.PageNumHelper;

	public class StageMouseListener
	{
		private var mainPage:main;
		private var mouseDownPoint:Point;
		private var mouseUpPoint:Point;
		private var mousePoint:Point;
		private var stage:DisplayObject;
		
		private var mask:Canvas;
		private var showMask:Boolean = false;
		
		public function StageMouseListener(mainPage:main)
		{
			this.stage = mainPage;
			this.mask = new Canvas();
			this.mainPage = mainPage;
			mask.setStyle("backgroundColor",0xAAAAAA);
			mask.setStyle("backgroundAlpha",0.5);
			mask.visible = false;
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			mouseDownPoint = new Point(event.stageX,event.stageY);
			
			if(RunTime.editor != null)
			{
				RunTime.editor.receiveClick(event.stageX,event.stageY);
			}
			
			if(RunTime.note.length > 0)
			{
				if(event.target is UITextField) return;
				var book:FlexBook = mainPage.book;
				var mid:Point = new Point(book.width/2,0);
				var p:Point = new Point(event.stageX, event.stageY);
				p = book.globalToLocal(p);
				var pageId:int = p.x >= mid.x ? book.getRightPageNumber() : book.getLeftPageNumber();
				
				if(pageId == -1) return;

				pageId = utils.PageNumHelper.convertInnerPageToRealPage(pageId);
				var rootX:Number = p.x >= mid.x ? mid.x : (new Point(0,0)).x;
			
				if(p.y > (new Point(0,0)).y
						&& p.y < (new Point(0,book.height-1)).y - 20
				)
				{
					if(pageId > -1)
					{
						
						var note:NoteRecord = new NoteRecord(
							RunTime.note, pageId, 
							(p.x - rootX) / (book.width * 0.5),
							(p.y - mid.y) / book.height
							,true);

						note.save();
						RunTime.noteRecords = RunTime.noteRecords.concat(note);
						mainPage.updateNotes();
					}
				}
				CursorManager.removeAllCursors();
				RunTime.note = "";
				return;
			}
			
			switch(RunTime.MouseState)
			{
				case RunTime.MOUSE_STATE_NOTE_DETAIL_MOVING:
					if( RunTime.CurrentMovingObject != null
						&& RunTime.CurrentMovingObject is NoteMarkDetail
					)
					{
						Helper.bringTop((RunTime.CurrentMovingObject as NoteMarkDetail).parent);
					}
					break;
				case RunTime.MOUSE_STATE_HIGHLIGHT_DETAIL_MOVING:
					if(RunTime.CurrentMovingObject != null
						&& RunTime.CurrentMovingObject is HighlightMarkDetail
					)
					{
						Helper.bringTop((RunTime.CurrentMovingObject as HighlightMarkDetail).parent);
					}
					break;
				case RunTime.MOUSE_STATE_NORMAL:
					if( !MouseStateHelper.isZoomActive(event.target) 
						|| isStagePointInBookArea(mouseDownPoint) == false
						|| this.flexBook.isMouseOnFlipArea() == true
						|| this.flexBook.isNormal() == false
						|| RunTime.note.length > 0
						|| RunTime.zoomedIn == true
					)
					{
						
						mask.visible = false;
						showMask = false;
						
					}
					else if(isStagePointInBookArea(mouseDownPoint) == true)
					{
						mask.x = mouseDownPoint.x;
						mask.y = mouseDownPoint.y - 1;
						mask.height = 1;
						mask.width = 1;
						mask.data = new Point(mouseDownPoint.x,mouseDownPoint.y);
						flexBook.setStyle("showCornerTease",false);
						if(mask.parent == null)
						{
							RunTime.mainApp.addChild(mask);
						}
						showMask = true;
						mask.visible = true;
					}
					else
					{
						mask.visible = false;
						showMask = false;
					}
					break;
			}
		}
		
		private function isStagePointInBookArea(p:Point):Boolean
		{
			var book:FlexBook = mainPage.book;
			if(book.stage == null) return false;
			var stageX:Number = book.stage.x;
			var stageY:Number = book.stage.y;
			var root:Point = book.localToGlobal(new Point());
			if(p.x < root.x || p.y < root.y || p.x > root.x + book.width || p.y > root.y + book.height)
			{
				return false;
			}
			else if(book.getLeftPageNumber() == -1 && p.x < root.x + book.width/2)
			{
				return false;
			}
			else if(book.getRightPageNumber() == -1 && p.x > root.x + book.width/2)
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			//trace("stage mouseup");
			if(RunTime.CurrentMovingObject != null 
				&& ( RunTime.CurrentMovingObject is BaseVBox || RunTime.CurrentMovingObject is ComboContent
					|| RunTime.CurrentMovingObject is BgAudioBox)
			)
			{
				RunTime.CurrentMovingObject = null;
				return;
			}
			
			if(RunTime.MouseState == RunTime.MOUSE_STATE_NOTE_DETAIL_MOVING)
			{
				setNormal();
			}
			else if(RunTime.MouseState == RunTime.MOUSE_STATE_HIGHLIGHT_DETAIL_MOVING)
			{
				setHighlightOnState();
			}
			else if(RunTime.MouseState == RunTime.MOUSE_STATE_NORMAL)
			{
				releaseMask(new Point(event.stageX,event.stageY));
			}
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
						
			//trace("RunTime.MouseState=" + RunTime.MouseState);
			var p:Point = new Point(event.stageX,event.stageY);
			switch(RunTime.MouseState)
			{
				//移动note图标
				case RunTime.MOUSE_STATE_NOTE_MOVING:{
					if(mousePoint != null
						&& RunTime.CurrentMovingObject != null
						&& RunTime.CurrentMovingObject is NoteMark
					)
					{
						//放大情况下，不可移动
						if(mainPage.zoomBox.visible) return;
						
						var n:NoteMark = RunTime.CurrentMovingObject as NoteMark;
						if(n.parent == null) return;
						
						var xx:Number = n.x + p.x - mousePoint.x;
						var yy:Number = n.y + p.y - mousePoint.y;
						
						n.x = xx;
						n.y = yy;
						
						var mid:Point = mainPage.book.localToGlobal(new Point(mainPage.book.width/2,0));
						var rootX:Number = p.x >= mid.x ? mid.x : mainPage.book.localToGlobal(new Point(0,0)).x;
						
						var d:Point = mainPage.book.localToGlobal(new Point(xx,yy));
						
						var r:NoteRecord = n.record;
						r.xPos = (d.x - rootX) / (mainPage.book.width * 0.5);
						r.yPos = (d.y - mid.y) / mainPage.book.height;
					}

					break;
				}
				case RunTime.MOUSE_STATE_NOTE_DETAIL_MOVING:
					if(mousePoint != null && mouseDownPoint != null 
						&& RunTime.CurrentMovingObject != null
						&& RunTime.CurrentMovingObject is NoteMarkDetail
					)
					{
						
						var m:NoteMarkDetail = RunTime.CurrentMovingObject as NoteMarkDetail;
						if(m.parent == null) return;
						
						var xx:Number = m.x + p.x - mousePoint.x;
						var yy:Number = m.y + p.y - mousePoint.y;
						
						m.moveTo(xx,yy);
					}
					
					
					
					break;
				case RunTime.MOUSE_STATE_HIGHLIGHT_DETAIL_MOVING:
					if(mousePoint != null && mouseDownPoint != null 
						&& RunTime.CurrentMovingObject != null
						&& RunTime.CurrentMovingObject is HighlightMarkDetail
					)
					{
						var hm:HighlightMarkDetail = RunTime.CurrentMovingObject as HighlightMarkDetail;
						if(hm.parent == null) return;
						
						var xx:Number = hm.x + p.x - mousePoint.x;
						var yy:Number = hm.y + p.y - mousePoint.y;
						
						hm.moveTo(xx,yy);
					}
					break;
				case RunTime.MOUSE_STATE_NORMAL:
					if(mousePoint != null && mouseDownPoint != null 
						&& RunTime.CurrentMovingObject != null
						&& ( RunTime.CurrentMovingObject is BaseVBox 
							|| RunTime.CurrentMovingObject is ComboContent
							|| RunTime.CurrentMovingObject is BgAudioBox)
					)
					{
						
						var b:DisplayObject = RunTime.CurrentMovingObject as DisplayObject;
						if(b.parent == null) return;
						
						var xx:Number = b.x + p.x - mousePoint.x;
						var yy:Number = b.y + p.y - mousePoint.y;
						b.x = xx;
						b.y = yy;
					}
					else
					{
						if(RunTime.fullScreen == true)
						{
							var menuLeft:DisplayObject = mainPage.menuLeft;
							var menuBottom:DisplayObject = mainPage.menuBottom;
							if(menuLeft != null && menuBottom != null)
							{
								if(isMouseOver(menuLeft,p.x,p.y) == true)
								{
									Helper.setVisibleWithFade(menuLeft,true);
								}
								else
								{
									Helper.setVisibleWithFade(menuLeft,false);
								}
								
								if(isMouseOver(menuBottom,p.x,p.y) == true)
								{
									Helper.setVisibleWithFade(menuBottom,true);
								}
								else
								{
									Helper.setVisibleWithFade(menuBottom,false);
								}
							}
						}
						drawMask(p);
						
						if(mainPage.landscape.autoMoveAfterZoom == true)
						{
							var cp:MouseEvent = new MouseEvent("");
							var current:DisplayObject = event.target as DisplayObject;
							var isLandscapeActive:Boolean = true;
							while(current != null)
							{
								if(current is ZoomBox)
								{
									isLandscapeActive = false;
									current = null;
								}
								else
								{
									current = current.parent;
								}
							}
							
							if(isLandscapeActive == true)
							{
								mainPage.landscape.onStageMouseMove(event.stageX,event.stageY);
								//trace("onStageMouseMove x=" + event.stageX + " , y=" + event.stageY);
							}
						}
					}
					break;
			}
			mousePoint = p; 
		}
		
		private function isMouseOver(obj:DisplayObject, x:Number, y:Number):Boolean
		{
			var root:Point = obj.localToGlobal(new Point());
			if(x < root.x || y < root.y || x > root.x + obj.width || y > root.y + obj.height)
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		
		private function onMouseOut(event:MouseEvent):void
		{
			
		}
		
		private function setNormal():void
		{
			mouseUpPoint = null;
			mouseDownPoint = null;
			RunTime.setNormal();
		}
		
		private function setHighlightOnState():void
		{
			mouseUpPoint = null;
			mouseDownPoint = null;
			RunTime.setHighlightOnState();
		}
		
		private function get flexBook():FlexBook
		{
			return mainPage.book;
		}
		
		private function fitPoint(p:Point):Point
		{
			var book:FlexBook = this.flexBook;
			var pp:Point = p.clone();
			// 点需要在book的内部
			var root:Point = flexBook.localToGlobal(new Point());
			if(pp.x < root.x) pp.x = root.x;
			if(pp.y < root.y) pp.y = root.y;
			if(pp.x > root.x + book.width) pp.x = root.x + book.width;
			if(pp.y > root.y + book.height) pp.y = root.y + book.height;
			
			if(book.getLeftPageNumber() == -1)
			{
				if(pp.x < root.x + book.width / 2)
				{
					pp.x = root.x + book.width / 2;
				}
			}
			else if(book.getRightPageNumber() == -1)
			{
				if(pp.x > root.x + book.width / 2)
				{
					pp.x = root.x + book.width / 2;
				}
			}
			return pp;
		}
		
		private function drawMask(p:Point):void
		{

			if(showMask == false)
			{
				mask.visible = false;
				return;
			}
			
			var p0:Point = mask.data as Point;
			var p1:Point = fitPoint(p);
			
			mask.x = Math.min(p0.x,p1.x);
			mask.y = Math.min(p0.y,p1.y);
			mask.width = Math.max(1, Math.abs(p0.x - p1.x));
			mask.height = Math.max(1, Math.abs(p0.y - p1.y));
			
			if(showMask == true)
			{
				mask.visible = true;
				if(mask.parent == null)
				{
					RunTime.mainApp.addChild(mask);
				}
			}
		}
		
		private function releaseMask(p:Point = null):void
		{
						
			flexBook.setStyle("showCornerTease",true);
			showMask = false;
			if(mask.visible == true)
			{

				var from:Point = mask.data as Point;
				var to:Point = this.fitPoint(p);
				var w:Number = Math.abs(from.x - to.x);
				var h:Number = Math.abs(from.y - to.y);
				mask.visible = false;
							
				flexBook.zoomActive = true;
				
				if(w > 10 && h > 10)
				{
					var wScale:Number = mainPage.book.width / w;
					var hScale:Number = mainPage.book.height / h;
					var scale:Number = Math.min(wScale,hScale);
					scale = Math.min(5,scale);
					mainPage.zoomInBook(new Point((from.x + to.x)/2,(from.y + to.y)/2), scale);

				}
				else
				{
					if(RunTime.isSingleClickToZoom() == true )
					{
						if(RunTime.zoomMode=="scalable")
							mainPage.zoomInBook2(new Point((from.x + to.x)/2,(from.y + to.y)/2));
						else
							mainPage.zoomInBook(new Point((from.x + to.x)/2,(from.y + to.y)/2));
					}
				}
			}
		}
	}
}