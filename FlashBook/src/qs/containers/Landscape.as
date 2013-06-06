/*
Copyright 2006 Adobe Systems Incorporated

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.


THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/
package qs.containers
{
	import common.FocusController;
	import common.events.BookEvent;
	
	import controls.BaseVBox;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import mx.core.UIComponent;
	import mx.core.UIComponentCachePolicy;
	
	import qs.controls.FlexBook;
	import qs.controls.LayoutAnimator;
	import qs.controls.LayoutTarget;
	//import qs.controls.MoveAnimator;

	[Style(name="paddingLeft", type="Number", inherit="no")]
	[Style(name="paddingTop", type="Number", inherit="no")]
	[Style(name="paddingRight", type="Number", inherit="no")]
	[Style(name="paddingBottom", type="Number", inherit="no")]
	[Style(name="zoomLimit", type="String", inherit="no")]
	[Event(name="pageZoomComplete",type="common.events.BookEvent")]
	[Event(name="transformChanged")]
	[Event(name="pageMove")]

	[DefaultProperty("children")]
	public class Landscape extends UIComponent
	{
		public var zoomContent:DisplayObject;
		// all children are placed inside the pane.  We can then adjust the pane's transform to
		// get the correct pan and zoom.
		private var _contentPane:ContentPane;

		// the mask is applied to the pane to make sure it gets clipped correctly.
		private var _mask:Shape;
		// our trusty layout animator, which allows us to get animated layout without having to write
		// any real animation code.
		private var _animator:LayoutAnimator;
		
		
		//private var _moveAnimator:MoveAnimator;

		// the array of currently selected ancestors
		private var _selection:Array = [];

		//our scale and translation state.
		private var _scaleX:Number = 1;

		public function get layoutScaleX():Number
		{
			return _scaleX;
		}

		private var _scaleY:Number = 1;

		public function get layoutScaleY():Number
		{
			return _scaleY;
		}

		private var _offsetX:Number = 0;

		public function get layoutOffsetX():Number
		{
			return _offsetX;
		}

		private var _offsetY:Number = 0;

		public function get layoutOffsetY():Number
		{
			return _offsetY;
		}

		private var _needImmediateUpdate:Boolean = true;
		
		public var mouseListener:DisplayObject = null;
		
		[Bindable]
		public var autoMoveAfterZoom:Boolean = false;
		
		public function wheel(delta:int):void
		{
			if(isZoomedIn || RunTime.zoomMode=="scalable")
			{
				var m:Matrix = this.contentPane.transform.matrix.clone(); 
				m.ty += delta * scale * 20;
				var newM:Matrix = m.clone();
				m.ty = adjustMatrixTY(newM);
				contentPane.transform.matrix = m;
				this.dispatchEvent(new Event("pageMove"));
				dispatchEvent(new Event("transformChanged"));
			}
		}

		// Constructor
		public function Landscape()
		{
			super();
			
			// setup our pane to hold all of our children.
			_contentPane = new ContentPane();
			_contentPane.landscape=this;
			_contentPane.cachePolicy = UIComponentCachePolicy.ON;

			// and the mask that will guarantee it stays within our bounds.
			_mask = new Shape();
			addChild(_mask);
			addChild(_contentPane);
			_contentPane.mask = _mask;

			// initialize the animated layout engine.
			_animator = new LayoutAnimator();
			_animator.layoutFunction = generateLayout;
			_animator.completeFunction = completeLayout;
			_animator.addEventListener("transformChanged", 
				function(e:*):void
				{
					dispatchEvent(new Event("transformChanged"));
				}
			);
			
			//_moveAnimator = new MoveAnimator(null, callPageMove);
			//_moveAnimator.targetFor(contentPane);
		}

		public function set clipContent(value:Boolean):void
		{
			_mask.visible = (value)? true:false;
			_contentPane.mask = (value)? _mask:null;
		}
		public function get clipContent():Boolean
		{
			return (_contentPane.mask != null);
		}

		override public function set cachePolicy(value:String):void
		{
			_contentPane.cachePolicy = value;
		}
		override public function get cachePolicy():String
		{
			return _contentPane.cachePolicy;
		}

		private var _children:Array = [];
		public function set children(value:Array):void
		{
			var i:int;
			var d:Dictionary = new Dictionary();
			for(i = 0;i<value.length;i++)
			{
				d[value[i]] = true;
				_contentPane.addChild(value[i]);
			}
			for(i = _contentPane.numChildren-1;i>=0;i--)
			{
				if(d[_contentPane.getChildAt(i)] == undefined)
					_contentPane.removeChildAt(i);
			}
			_children = value.concat();
		}
		public function get children():Array
		{
			return _children.concat();
		}

		public function set selection(value:Array):void
		{
			_selection = (value as Array);

			calculateMatrixForDescendants(_selection,true);
			_animator.invalidateLayout();
		}

		public function get selection():Array
		{
			return _selection;
		}
		
		private var _scale:Number = 1;

		public function get scale():Number
		{
			return scaleByDragBox ? dragZoomScale : _scale;
		}

		[Bindable]
		public function set scale(value:Number):void
		{
			_scale = value;
		}
		
		[Bindable]
		public var scaleByDragBox:Boolean = false;
		
		[Bindable]
		public var scaleByDragBoxActive:Boolean;
		
		[Bindable]
		public var dragZoomScale:Number = NaN;
		
		public function zoomToScale(value:Number, focusMode:int=0, forceFitWindow:Boolean = false):void
		{
			trace("zoomToScale:" + value);
			//trace("focurMode:" + focusMode);
			if(scaleByDragBoxActive == true) return;
			focusController.disenableFitFullScreen = false;
			scaleByDragBox = false; 
			scale = value;
			if(focusMode != 0) focusController.focusMode = focusMode;
			calculateMatrixForDescendants(_selection,false,forceFitWindow);
			this.invalidateDisplayList();
		}
		
		public function get contentPane():UIComponent
		{
			return _contentPane;
		}
		
		public var isZoomedIn: Boolean = false;

		private function calculateMatrixForDescendants(selections:Array, switchScaledState: Boolean = true,forceFitWindow:Boolean = false):void
		{
			if(selections == null || selections.length == 0)
			{
				_scaleX = 1;
				_scaleY = 1;
				_offsetX = _offsetY = 0;
				isZoomedIn = false;
			}
			else
			{
				var m:Matrix = _contentPane.transform.matrix;

				if(	switchScaledState == true )
				{
					isZoomedIn = !isZoomedIn;
				}

				_scaleX = _scaleY =  scale;
				
				var ui:DisplayObject = selections[0] as DisplayObject;

				_offsetY = RunTime.mainApp.height / 2 - scale * focusPoint.y  - scale *ui.y;
				//trace("isFitScreenMode()=" + isFitScreenMode());
				if(focusController != null && focusController.disenableFitFullScreen == false && isFitScreenMode() == true)
				{
					_offsetX = focusController.computeOffsetX(zoomContent,ui,scale);
					//trace("_offsetX=" + _offsetX);
				}
				else if(forceFitWindow && canForceFitScreenMode() && focusController.disenableFitFullScreen == false){
					_offsetX = focusController.computeOffsetX(zoomContent,ui,scale);
					//trace("_offsetX3=" + _offsetX);
				}
				else
				{
					_offsetX = RunTime.mainApp.width / 2 - scale * focusPoint.x - scale *ui.x;
					//trace("_offsetX1=" + _offsetX);
				}

				_contentPane.transform.matrix = m;
			}
		}
		
		override protected function measure():void
		{
			var maxW:Number = 0;
			var maxH:Number = 0;
			for(var i:int = 0;i<_contentPane.numChildren;i++)
			{
				var child:UIComponent = UIComponent(_contentPane.getChildAt(i));
				if (isNaN(child.percentHeight))
					maxW = Math.max(maxW, child.x + child.getExplicitOrMeasuredWidth());
				if (isNaN(child.percentHeight))
					maxH = Math.max(maxH,child.y+child.getExplicitOrMeasuredHeight());

			}
			measuredWidth = maxW;
			measuredHeight = maxH;
			measuredMinWidth = 0;
			measuredMinHeight = 0;
			invalidateDisplayList();
		}

		private function generateLayout():void
		{
			var target:LayoutTarget = _animator.targetFor(_contentPane);
			target.scaleX = _scaleX;
			target.scaleY = _scaleY;
			target.x = _offsetX;
			target.y = _offsetY;
			target.reset();
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			_mask.graphics.clear();
			_mask.graphics.beginFill(0);
			_mask.graphics.drawRect(0,0,unscaledWidth,unscaledHeight);

			var childWidth:Number;
			var childHeight:Number;

			for(var i:int = 0;i<_contentPane.numChildren;i++)
			{
				var child:UIComponent = UIComponent(_contentPane.getChildAt(i));
				if(isNaN(child.percentWidth))
					childWidth = child.getExplicitOrMeasuredWidth();
				else
					childWidth = child.percentWidth/100 * unscaledWidth;

				if(isNaN(child.percentHeight))
					childHeight = child.getExplicitOrMeasuredHeight();
				else
					childHeight = child.percentHeight/100 * unscaledHeight;

				child.setActualSize(childWidth, childHeight);
			}
			
			calculateMatrixForDescendants(_selection, false);

			// If someone wanted us to skip animation, we now are guaranteed to know
			// what our viewable area is, so jump to the target values now.
			if(_needImmediateUpdate)
			{
				_needImmediateUpdate = false;
				_animator.updateLayoutWithoutAnimation();
			}
			else
			{
				_animator.invalidateLayout();
			}
		}

		// Rost: called by Animator when animation is finished
		private function completeLayout():void
		{
			switchPanning();

			var event: BookEvent = new BookEvent(BookEvent.PAGE_ZOOM_COMPLETE, true);
			event.isZoomedIn = isZoomedIn;

			dispatchEvent(event);
			
			//_moveAnimator.stopMoveAnimator();
		}

		// Rost: we want Landscape to be able to pan childrens too
		private function switchPanning():void
		{
			if(mouseListener == null) return;
				
			if(isZoomedIn || RunTime.zoomMode=="scalable")
			{
				mouseListener.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
				mouseListener.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove);
				mouseListener.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
				mouseListener.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown);
				mouseListener.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
				mouseListener.addEventListener( MouseEvent.MOUSE_UP, onMouseUp);
			}
			else
			{
				mouseListener.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
				mouseListener.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
				mouseListener.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			}
		}
		
		private var mouseDownPoint:Point;
		private var mouseUpPoint:Point;
		public var focusController:FocusController;
		
		public function receiveFocusPoint(value:Point, target:DisplayObject, focusController:FocusController = null):void
		{
			if(zoomContent == null && scale <= 1) return;
			
			this.focusController = focusController;
			focusPoint = value;
			adjustFocusPoint(target);
			selection = [target];
		}
		
		private function adjustFocusPoint(target:DisplayObject):void
		{
			if(target == null || focusController == null || focusPoint == null) return;
			focusPoint=focusController.adjustFocusPoint(focusPoint, zoomContent, target,scale);
		}
		
		private var _focusPoint:Point;

		public function get focusPoint():Point
		{
			return _focusPoint;
		}

		public function set focusPoint(value:Point):void
		{
			_focusPoint = value;
		}
		
		public function atMoveState():Boolean
		{
			if(isZoomedIn == false) return false;
			
			if(mouseUpPoint == null || mouseDownPoint == null) return false;
			else
			{
				if(Math.abs(mouseDownPoint.x - mouseUpPoint.x) > 10) return true;
				else if(Math.abs(mouseDownPoint.y - mouseUpPoint.y) > 10) return true;
			}
			
			return false;
		}
		
		private var lastMousePoint:Point = null;

		private function onMouseMove(event: MouseEvent):void
		{
			
			if((isZoomedIn || RunTime.zoomMode=="scalable") && RunTime.MouseState != RunTime.MOUSE_STATE_HIGHLIGHT_ON)
			{
				if(event.buttonDown == true && this.autoMoveAfterZoom == false)
				{
					if(RunTime.CurrentMovingObject == null || !(RunTime.CurrentMovingObject is BaseVBox))
					{
						if(lastMousePoint == null)
						{
							lastMousePoint = new Point(event.stageX,event.stageY);
						}
						
						var p:Point = new Point(event.stageX,event.stageY);
						var xOffset:Number = p.x - lastMousePoint.x;
						var yOffset:Number = p.y - lastMousePoint.y;
						
						var m:Matrix = this.contentPane.transform.matrix.clone(); 
						var mNew:Matrix = m.clone();
						mNew.tx += xOffset;
						mNew.ty += yOffset;
						
						if(forbiddenMoveX())
						{
							m.ty = adjustMatrixTY(mNew);
						}
						else
						{
							m.tx = adjustMatrixTX(mNew);
							m.ty = adjustMatrixTY(mNew);
						}
						lastMousePoint = p;
						
						
						//_moveAnimator.move(m,moveAnimatorCallback);
						contentPane.transform.matrix = m;
						this.dispatchEvent(new Event("pageMove"));
						dispatchEvent(new Event("transformChanged"));
						
						return;
					}
				}
				lastMousePoint = new Point(event.stageX,event.stageY);
			}
		}
		
		private function callPageMove():void{
			this.dispatchEvent(new Event("pageMove"));
		}
		
		//private function moveAnimatorCallback():void{
			
			//dispatchEvent(new Event("transformChanged"));
		//}
		
		public function isFitScreenMode():Boolean
		{
			//trace("Math.abs(RunTime.fitScreenScale - scale)=" + Math.abs(RunTime.fitScreenScale - scale));
			return RunTime.fitScreenAfterZoom == true && Math.abs(RunTime.fitScreenScale - scale) < 0.01 && focusController != null;
		}
		/**
		 * 是否可以强制填满屏幕
		 */
		public function canForceFitScreenMode():Boolean
		{
			return focusController != null;
		}
		
		private function forbiddenMoveX():Boolean
		{
			return isFitScreenMode() && autoMoveAfterZoom == true;
		}
		
		public function onStageMouseMove(stageX:Number,stageY:Number):void
		{
			//trace("stageX=" + stageX + ", stageY=" + stageY);
			//return;
			
			if(isZoomedIn)
			{
				if(this.autoMoveAfterZoom == true)
				{
					if(RunTime.CurrentMovingObject == null || !(RunTime.CurrentMovingObject is BaseVBox))
					{
						var x:Number = stageX;
						var y:Number = stageY;
						
						var m:Matrix = this.contentPane.transform.matrix.clone();
						var mNew:Matrix = m.clone();
						mNew.ty = RunTime.mainApp.height / 2 - scale * y;
						mNew.tx = RunTime.mainApp.width / 2 - scale * x ;
						

						
						if(forbiddenMoveX())
						{
							m.ty = adjustMatrixTY(mNew);
						}
						else
						{
							m.tx = adjustMatrixTX(mNew);
							m.ty = adjustMatrixTY(mNew);
						}
						
						
						//_moveAnimator.move(m,moveAnimatorCallback);
						contentPane.transform.matrix = m;
						this.dispatchEvent(new Event("pageMove"));
						dispatchEvent(new Event("transformChanged"));
					}
				}
			}
		}
		
		public function onLandscapeMove(stageX:Number,stageY:Number):void
		{
			if(isZoomedIn)
			{
				//if(this.autoMoveAfterZoom == true)
				{
					if(RunTime.CurrentMovingObject == null || !(RunTime.CurrentMovingObject is BaseVBox))
					{
						var x:Number = stageX;
						var y:Number = stageY;
						
						var m:Matrix = this.contentPane.transform.matrix.clone();
						var mNew:Matrix = m.clone();
						//mNew.ty = RunTime.mainApp.height / 2 - scale * y;
						//mNew.tx = RunTime.mainApp.width / 2 - scale * x;
						
						mNew.ty = RunTime.mainApp.height / 2 - scale * y;
						mNew.tx = RunTime.mainApp.width / 2 - scale * x;
						
						if(forbiddenMoveX())
						{
							m.ty = adjustMatrixTY(mNew);
						}
						else
						{
							m.tx = adjustMatrixTX(mNew);
							m.ty = adjustMatrixTY(mNew);
						}
						
						contentPane.transform.matrix = m;
						this.dispatchEvent(new Event("pageMove"));
						dispatchEvent(new Event("transformChanged"));
					}
				}
			}
		}
		
		const maxContentPadding:int = 30;
		
		private function get maxContentPaddingLeft():Number
		{
			// 同maxContentPaddingRight一致
			if(this.focusController == null || this.focusController.focusMode == 0 || this.focusController.isDoublePage == true)
			{
				return maxContentPadding;
			}
			else
			{
				if(focusController.focusMode == 1)
				{
					return maxContentPadding - (this.zoomContent.width * this.scale * 0.5);
				}
				else
				{
					return maxContentPadding;
				}
			}
		}
		
		private function get maxContentPaddingRight():Number
		{
			if(this.focusController == null || this.focusController.focusMode == 0|| this.focusController.isDoublePage == true)
			{
				return maxContentPadding;
			}
			else
			{
				if(focusController.focusMode == -1)
				{
					return maxContentPadding - (this.zoomContent.width * this.scale * 0.5);
				}
				else
				{
					return maxContentPadding;
				}
			}
		}
		
		private function adjustMatrixTX(m:Matrix):Number
		{
			var mOld:Matrix = contentPane.transform.matrix;
			var p0:Point = this.zoomContent.localToGlobal(new Point());
			var p1:Point = this.zoomContent.localToGlobal(new Point(zoomContent.width,zoomContent.height));
			if(p0.x > maxContentPaddingLeft && p1.x < RunTime.mainApp.width - maxContentPaddingRight)
			{
				return mOld.tx;
			}
			
			if(m.tx > mOld.tx) // 向右移动
			{
				if(p0.x + m.tx - mOld.tx > maxContentPaddingLeft)
					return m.tx + maxContentPaddingLeft - (p0.x + m.tx - mOld.tx) ;
			}
			else if(m.tx < mOld.tx)	// 向左移动
			{
				if(p1.x + m.tx - mOld.tx < RunTime.mainApp.width - maxContentPaddingRight) 
					return m.tx + RunTime.mainApp.width - maxContentPaddingRight - (p1.x + m.tx - mOld.tx);
			}
			
			return m.tx;
		}
		
		private function adjustMatrixTY(m:Matrix):Number
		{
			var mOld:Matrix = contentPane.transform.matrix;
			var p0:Point = this.zoomContent.localToGlobal(new Point());
			var p1:Point = this.zoomContent.localToGlobal(new Point(zoomContent.width,zoomContent.height));
			if(p0.y > maxContentPadding && p1.y < RunTime.mainApp.height - maxContentPadding)
			{
				return mOld.ty;
			}
						
			if(m.ty > mOld.ty) // 向下移动
			{
				if(p0.y + m.ty - mOld.ty > maxContentPadding) 
					return m.ty + maxContentPadding - (p0.y + m.ty - mOld.ty);
			}
			else if(m.ty < mOld.ty)	// 向上移动
			{
				if(p1.y + m.ty - mOld.ty < RunTime.mainApp.height - maxContentPadding)
					return m.ty + RunTime.mainApp.height - maxContentPadding - (p1.y + m.ty - mOld.ty);
			}
			
			return m.ty;
		}
		
		private function onMouseDown(event: MouseEvent):void
		{
			//if(!isZoomedIn)
			//{
				//_moveAnimator.stopMoveAnimator();
			//}
			mouseDownPoint = new Point(event.stageX,event.stageY);
		}
		
		private function onMouseUp(event: MouseEvent):void
		{
			mouseUpPoint = new Point(event.stageX,event.stageY);
		}
	}
}

import mx.core.UIComponent;

import qs.containers.Landscape;

class ContentPane extends UIComponent
{
	public var landscape:Landscape

	override protected function measure():void
	{
		landscape.invalidateDisplayList();
	}
}
