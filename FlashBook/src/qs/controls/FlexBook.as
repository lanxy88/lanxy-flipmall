/*Copyright (c) 2006 Adobe Systems Incorporated

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

/* 
	Copyright (c) 2011 Geblab(geblab.com,xiaotie@geblab.com)
*/

package qs.controls
{
	import com.asfusion.mate.core.mate;
	
	import common.AudioManager;
	import common.BookMarkRecord;
	import common.events.BookEvent;
	
	import controls.BookMark;
	import controls.HotLinkBox;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.collections.XMLListCollection;
	import mx.controls.Alert;
	import mx.core.IFactory;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.core.UIComponentCachePolicy;
	import mx.events.FlexEvent;
	import mx.graphics.codec.JPEGEncoder;
	import mx.graphics.codec.PNGEncoder;

	import qs.controls.flexBookClasses.FlexBookEvent;
	import qs.controls.flexBookClasses.FlexBookPage;
	import qs.utils.Vector2;
	
	import utils.PageNumHelper;

	[Style(name="activeGrabArea", type="String", enumeration="corners,edge,page,none", inherit="no")]
	[Style(name="edgeAndCornerSize", type="Number")]
	[Style(name="showCornerTease", type="Boolean")]
	[Style(name="paddingLeft", type="Number", format="Length", inherit="no")]
	[Style(name="paddingRight", type="Number", format="Length", inherit="no")]
	[Style(name="paddingTop", type="Number", format="Length", inherit="no")]
	[Style(name="paddingBottom", type="Number", format="Length", inherit="no")]
	[Style(name="paddingSpine", type="Number", format="Length", inherit="no")]
	[Style(name="transparencyDepth", type="Number", format="Length", inherit="no")]
	[Style(name="pageShadowStrength", type="Number", format="Length", inherit="no")]
	[Style(name="pageSlope", type="Number", format="Length", inherit="no")]
	[Style(name="curveShadowStrength", type="Number", format="Length", inherit="no")]
	[Style(name="autoTurnDuration", type="Number", format="Length", inherit="no")]
	[Style(name="showPageSlopeAtRest", type="String", format="Boolean", inherit="no")]

	[Style(name="backgroundAlpha", type="Number", inherit="no")]
	[Style(name="backgroundColor", type="uint", format="Color", inherit="no")]
	[Style(name="backgroundImage", type="Object", format="File", inherit="no")]
	[Style(name="backgroundSize", type="String", inherit="no")]
	[Style(name="borderColor", type="uint", format="Color", inherit="no")]
	[Style(name="borderSides", type="String", inherit="no")]
	[Style(name="borderSkin", type="Class", inherit="no")]
	[Style(name="borderStyle", type="String", enumeration="inset,outset,solid,none", inherit="no")]
	[Style(name="borderThickness", type="Number", format="Length", inherit="no")]
	[Style(name="cornerRadius", type="Number", format="Length", inherit="no")]
	[Style(name="dropShadowEnabled", type="Boolean", inherit="no")]
	[Style(name="dropShadowColor", type="uint", format="Color", inherit="yes")]
	[Style(name="shadowDirection", type="String", enumeration="left,center,right", inherit="no")]
	[Style(name="shadowDistance", type="Number", format="Length", inherit="no")]

	[Style(name="hardbackCovers", type="Boolean")]
	[Style(name="hardbackPages", type="Boolean")]

	[Event(name="change")]
	[Event(name="pageChanged")]
	[Event(name="turnStart",type="qs.controls.flexBookClasses.FlexBookEvent")]
	[Event(name="turnEnd",type="qs.controls.flexBookClasses.FlexBookEvent")]

	[DefaultProperty("content")]
	public class FlexBook extends DataDrivenControl implements IBook
	{

//--------------------------------------------------------------------------------------------------------
// constants
//-------------------------------------------------------------------------------------------------------

		// enumeration for what region of the page is active for initiating a turn
		private static const GRAB_REGION_CORNER:Number = 0;
		private static const GRAB_REGION_EDGE:Number = 1;
		private static const GRAB_REGION_PAGE:Number = 2;
		private static const GRAB_REGION_NONE:Number = 3;

		// enumeration for the current turning state of the book
		private static const STATE_NONE:Number = 0;
		private static const STATE_TURNING:Number = 1;
		private static const STATE_COMPLETING:Number = 2;
		private static const STATE_REVERTING:Number = 3;
		private static const STATE_TEASING:Number = 4;
		private static const STATE_AUTO_TURNING:Number = 5;
		private static const STATE_AUTO_COMPLETING:Number = 6;

		// enumeration used to indicate whether we are turning forwards or backwards
		private static const TURN_DIRECTION_FORWARD:Number = 0;
		private static const TURN_DIRECTION_BACKWARDS:Number = 1;

		// constants used to create the animation of the page.
		private static const Y_ACCELERATION:Number = .4;// Rost: was .4;
		private static const X_ACCELERATION:Number = .2;// Rost: was .2
		private static const SOLO_Y_ACCELERATION:Number = .2;
		
		// bitflags to identify a region of the page.
		private static const RIGHT:Number = 	0x0100;
		private static const LEFT:Number =  	0x0200;
		private static const TOP:Number = 		0x0400;
		private static const BOTTOM:Number = 	0x0800;
		private static const TOP_RIGHT:Number = 0x0501;
		private static const TOP_LEFT:Number = 	0x0601;
		private static const BOTTOM_RIGHT:Number = 0x0901;
		private static const BOTTOM_LEFT:Number =  0x0a01;

		private static const DEFAULT_EDGE_WIDTH:Number = 40;

		private static const ITEM_SIZE_PAGE:Number = 0;
		private static const ITEM_SIZE_HALF_PAGE:Number = 1;

//--------------------------------------------------------------------------------------------------------
// private vars
//-------------------------------------------------------------------------------------------------------

		public var bookmarkHeight:Number = 180;
		public var bookmarkWidth:Number = 24;
		public var bookmarkFontSize:Number = 14;
		
		[Bindable]
		public var rightToLeft:Boolean = false;
		
		private var _zoomActive:Boolean = false;
		
		public var zoomActiveCallback:Function;

		[Bindable]
		public function get zoomActive():Boolean
		{
			return _zoomActive;
		}

		public function set zoomActive(value:Boolean):void
		{
			_zoomActive = value;
			if(zoomActiveCallback)
			{
				zoomActiveCallback();
			}
		}
		
		// backing vars for public properties
		private var _userContent:* = [];
		private var _content:IList;
		private var _itemSize:Number = ITEM_SIZE_PAGE;
		private var _cover:*;
		private var _backCover:*;
		private var _currentPageIndex:Number = 0;
		private var _state:Number = 0;
		private var _animatePagesOnTurn:Boolean = false;
		private var _animateCurrentPageIndex:Boolean = false;
		private var _cachePagesAsBitmapPolicy:String = UIComponentCachePolicy.ON;

		// content holders
		private var _frontTurningPage:FlexBookPage;
		private var _backTurningPage:FlexBookPage;

		private var _leftPageStack:Array = [];
		private var _rightPageStack:Array = [];
		private var _currentPage:FlexBookPage;
		
		private var _bookMarks:Array = [];

		
		private var _contentToPageMap:Array = [];

		// content holder bitmaps for the turn
		private var _frontTurningBitmap:BitmapData;
		private var _backTurningBitmap:BitmapData;

		private var _leftPageStackBitmap:Bitmap;
		private var _rightPageStackBitmap:Bitmap;

		// values used during the turn
		private var _currentDragTarget:Point;
		private var _targetPoint:Point;
		private var _pointOfOriginalGrab:Point;
		private var _turnedCorner:Number = 0;
		private var _clickBecameDrag:Boolean;

		// timers used during the turn
		private var _timer:Timer;
		private var _turnStartTime:Number;

		// shapes used for drawing the turned page and creating interaction regions.
		private var _flipLayer:Shape;
		private var _interactionLayer:Sprite;

		// state used to track the difference between the publicly stated current page, and what's on screen during a turn
		private var _turnDirection:Number;
		private var _displayedPageIndex:Number = 0;
		private var _targetPageIndex:Number = 0;

		// dirty flags
		private var _contentChanged:Boolean = true;
		private var _resetCurrentIndex:Boolean = false;
		private var _pageHaveChanged:Boolean = true;

		public function get pageHaveChanged():Boolean
		{
			return _pageHaveChanged;
		}

		public function set pageHaveChanged(value:Boolean):void
		{
			_pageHaveChanged = value;
		}

		private var _interactionLayerDirty:Boolean = true;
		private var _pagesNeedUpdate:Boolean = true;
		private var _bitmapsNeedUpdate:Boolean = true;
		private var _oldWidth:Number;
		private var _oldHeight:Number;
		private var _eventPending:Boolean = true;

		// cached calculated page dimensions
		private var _pageWidth:Number;
		private var _pageHeight:Number;
		private var _hCenter:Number;
		private var _pageLeft:Number;
		private var _pageTop:Number;
		private var _pageRight:Number;
		private var _pageBottom:Number;

		// pages stack for better visualisation
		private var _pageStack: Sprite;
		private var _pageStackArray: Array;
		private var _maxPageStackDepth: Number = 9;
		private var _pageOffsetYInStack: Number = 0.5;
		private var _pageOffsetXInStack: Number = 2;

		private var _pageNumberHeightOffset: int = 50;
		
		// 翻页速度系数。系数越大，翻页速度越快
		public var flipSpeedBoost:Number = 100;
		
		[Bindable]
		public var pageActive:Boolean = true;
		
		public var showPageSlope:Boolean = true;

//--------------------------------------------------------------------------------------------------------
// public properties
//-------------------------------------------------------------------------------------------------------

		// Rost: to implement max page stack depth
		public function get maxPageStackDepth():int
		{
			return _maxPageStackDepth;
		}

		public function set maxPageStackDepth(value:int):void
		{
			_maxPageStackDepth = value;
		}

		public function get pageOffsetXInStack():Number
		{
			return _pageOffsetXInStack;
		}
		
		public function get pageOffsetYInStack():Number
		{
			return _pageOffsetYInStack;
		}
		
		public function get currentPage():FlexBookPage
		{
			return _currentPage;
		}
		
		public function set currentPage(value:FlexBookPage):void
		{
			_currentPage = value;
		}
		
		public function get bookMarks():Array
		{
			return _bookMarks;
		}
		
		[Bindable]
		public function set bookMarks(value:Array):void
		{
			value.sort( function (a:Object,b:Object):int
			{
				if(a.page < b.page) return 1;
				else if(a.page == b.page) return 0;
				else return -1;
			});
			_bookMarks = value;
			this.updateBookMarks();
		}

		[Bindable]
		public function get pageNumberHeightOffset():int
		{
			return _pageNumberHeightOffset;
		}

		public function set pageOffsetXInStack(value:Number):void
		{
			_pageOffsetXInStack = value;
		}
		
		public function set pageOffsetYInStack(value:Number):void
		{
			_pageOffsetYInStack = value;
		}
		
		public function set pageNumberHeightOffset(value:int):void
		{
			_pageNumberHeightOffset = value;
		}

		public function get widthOffset():Number
		{
			return _maxPageStackDepth * _pageOffsetXInStack;;
		}

		public function get heightOffset():Number
		{
			return Math.max(_pageNumberHeightOffset, _maxPageStackDepth * _pageOffsetYInStack) + 10;
		}
		
		public function get displayedPageIndex():Number
		{
			return _displayedPageIndex;
		}

		public function set itemSize(value:String):void
		{
			switch(value)
			{
				case "page":
					_itemSize = ITEM_SIZE_PAGE;
					break;
				default:
				case "halfPage":
					_itemSize = ITEM_SIZE_HALF_PAGE;
					break;
			}
			pageHaveChanged= true;
			dispatchEvent(new Event("contentChange"));
			_contentChanged = true;
			invalidateProperties();
		}
		public function get itemSize():String
		{
			return (_itemSize == ITEM_SIZE_PAGE)? "page":"halfPage";
		}

		[Bindable("contentChange")]
		public function set content(value:*):void
		{
			_userContent = value;
			pageHaveChanged= true;
			dispatchEvent(new Event("contentChange"));
			_contentChanged = true;
			if(_currentPageIndex == 0)
				_resetCurrentIndex = true;

			invalidateProperties();
		}
		
		public function get content():*
		{
			return _userContent;
		}

		public function set cover(value:*):void
		{
			_cover = value;
			pageHaveChanged= true;
			dispatchEvent(new Event("contentChange"));
			_contentChanged = true;
			if(_currentPageIndex == 0)
				_resetCurrentIndex = true;
			invalidateProperties();
		}
		
		public function get cover():*
		{
			return _cover;
		}

		public function set backCover(value:*):void
		{
			_backCover = value;
			pageHaveChanged= true;
			dispatchEvent(new Event("contentChange"));
			_contentChanged = true;
			invalidateProperties();
		}

		public function get backCover():*
		{
			return _backCover;
		}

		public function set cachePagesAsBitmapPolicy(value:String):void
		{
			_cachePagesAsBitmapPolicy = value;
			pageHaveChanged = true;
			invalidateProperties();
		}

		public function get cachePagesAsBitmapPolicy():String
		{
			return _cachePagesAsBitmapPolicy;
		}

		[Bindable] public function set animatePagesOnTurn(v:Boolean):void
		{
			_animatePagesOnTurn = v;
			invalidateDisplayList();
		}

		public function get animatePagesOnTurn():Boolean
		{
			return _animatePagesOnTurn;
		}

		[Bindable("contentChange")]
		public function get pageCount():Number
		{
			if(_contentChanged)
			{
				updateContent();
			}
			var result:Number;
			if(_itemSize == ITEM_SIZE_PAGE)
				result = _content.length;
			else
			{
				result = _content.length/2;
			}
			return result;
		}


		[Bindable("contentChange")]
		public function get minimumPageIndex():Number
		{
			if(_contentChanged)
			{
				updateContent();
			}
			return (_cover == null)? 0:-1;;
		}

		[Bindable("contentChange")]
		public function get maximumPageIndex():Number
		{
			var result:Number;
			if(_contentChanged)
			{
				updateContent();
			}
			if(_itemSize == ITEM_SIZE_PAGE)
				result = _content.length;
			else
			{
				result = Math.ceil(_content.length/2);
			}
			return (_backCover == null)? result:(result+1);
		}

		[Bindable]
		public function set currentPageIndex(value:Number):void
		{
			if(_animateCurrentPageIndex)
			{
				turnToPage(value,true);
			}
			else
			{
				currentPageIndexWithoutAnimation = value;
			}
		}

		public function set animateCurrentPageIndex(value:Boolean):void
		{
			_animateCurrentPageIndex = value;
		}

		public function get animateCurrentPageIndex(): Boolean
		{
			return _animateCurrentPageIndex;
		}
		
		public function checkIsContentArea(e:MouseEvent):Boolean
		{
			var pages:Array = [];
			return false;
		}
		
		[Bindable]
		public var audio:AudioManager;

		public function turnToPage(value:Number,bAnimate:Boolean = true):void
		{
			//Alert.show(value.toString());
			if(value == _currentPageIndex)
			{
				return;
			}
			
			audio.playFlippingSound();
			
			if(bAnimate == false)
			{
				currentPageIndexWithoutAnimation = value;
			}
			else
			{
				finishTurn();
				if(value > _currentPageIndex)
					setupForFlip(_hCenter + _pageWidth,_pageHeight,value);
				else
					setupForFlip(_hCenter - _pageWidth,_pageHeight,value);
				setCurrentPageIndex(value);
				setState(STATE_AUTO_TURNING);
				_turnStartTime = NaN;//getTimer();
				invalidateDisplayList();
				
				//this.currentPage.searchResult();
			}
		}

		[Bindable("change")]
		[Bindable("resetCurrentIndex")]
		public function get currentPageIndex():Number
		{
			return _currentPageIndex;
		}

		private function setCurrentPageIndex(value:Number):void
		{
			if(_currentPageIndex == value)
				return;
			
			_currentPageIndex = value;
			dispatchEvent(new Event("change"));
			dispatchEvent(new Event("pageChanged"));
		}

//--------------------------------------------------------------------------------------------------------
// style management
//-------------------------------------------------------------------------------------------------------


		private function get showPageSlopeAtRestD():Boolean
		{
			var result:* = getStyle("showPageSlopeAtRest");
			result = (result != false && result != "false");
			return result;
		}
		private function get autoTurnDurationD():Number
		{
			var result:Number = getStyle("autoTurnDuration");
			result = (isNaN(result))? 1000:result;
			return result * 100 / flipSpeedBoost;
		}
		private function get curveShadowD():Number
		{
			var result:Number = getStyle("curveShadowStrength");
			return ((isNaN(result))? 1:result)*5;
		}
		private function get pageSlopeD():Number
		{
			var result:Number = getStyle("pageSlope");
			return (isNaN(result))? 1:result;
		}
		private function get shadowStrengthD():Number
		{
			var result:Number = getStyle("pageShadowStrength");
			return (isNaN(result))? 1.4:result;
		}

		private function get transparencyDepthD():Number
		{
			var result:Number = getStyle("transparencyDepth");
			return (isNaN(result)? 0:Math.max(0,result));
		}
		private function get edgeWidthD():Number
		{
			var result:Number = getStyle("edgeAndCornerSize");
			return (isNaN(result))? DEFAULT_EDGE_WIDTH:result;
		}
		private function get hardbackCoversD():Boolean
		{
			var result:* = getStyle("hardbackCovers");
			return (result != false && result != "false");
		}

		private function get hardbackPagesD():Boolean
		{
			var result:* = getStyle("hardbackPages");
			return (result == true || result == "true");
		}
		private function get activeGrabAreaD():Number
		{
			var grStyle:String = getStyle("activeGrabArea");
			switch(grStyle)
			{
				case "none":
					return GRAB_REGION_NONE;
				case "edge":
					return GRAB_REGION_EDGE;
				case "page":
					return GRAB_REGION_PAGE;
				case "corner":
				default:
					return GRAB_REGION_CORNER;
			}
		}

		override public function styleChanged(styleProp:String):void
		{
			if(styleProp == null || styleProp == "activeGrabArea")
			{
				_interactionLayerDirty = true;
			}
			if(styleProp == null || styleProp == "edgeAndCornerSize")
			{
				_interactionLayerDirty = true;
			}
			if(styleProp != null || styleProp == "hardbackCovers" || styleProp == "hardbackPages")
			{
				pageHaveChanged = true;
				invalidateProperties();
			}
			super.styleChanged(styleProp);
		}

//--------------------------------------------------------------------------------------------------------
// initialization
//-------------------------------------------------------------------------------------------------------

		public function FlexBook():void
		{
			_timer = new Timer(10);
			_timer.addEventListener(TimerEvent.TIMER,timerHandler);
		}
		
		override public function set scaleX(num:Number):void
		{
			super.scaleX = num;
		}
		
		override public function set scaleY(num:Number):void
		{
			super.scaleY = num;
		}
		
		override protected function createChildren():void
		{
			
			// draw page-stack
			_pageStack = new Sprite();
			_pageStack.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
			_pageStack.addEventListener(MouseEvent.MOUSE_MOVE,trackMouseHandler);
			_pageStack.addEventListener(MouseEvent.ROLL_OVER,trackMouseHandler);
			_pageStack.addEventListener(MouseEvent.ROLL_OUT,trackMouseHandler);
			addChild(_pageStack);

			_flipLayer= new Shape();
			_interactionLayer = new Sprite();

			_frontTurningPage = new FlexBookPage();
			_backTurningPage = new FlexBookPage();
			_backTurningPage.addEventListener(FlexEvent.UPDATE_COMPLETE,bitmapSourceDrawHandler);
			_frontTurningPage.addEventListener(FlexEvent.UPDATE_COMPLETE,bitmapSourceDrawHandler);

			_frontTurningPage.cachePolicy = _cachePagesAsBitmapPolicy;
			_backTurningPage.cachePolicy = _cachePagesAsBitmapPolicy;

			_frontTurningPage.styleName = this;
			_backTurningPage.styleName = this;
			addChild(_frontTurningPage);
			addChild(_backTurningPage);
			
			_frontTurningPage.visible = false;
			_backTurningPage.visible = false;

			_leftPageStackBitmap = new Bitmap();
			_rightPageStackBitmap = new Bitmap();
			addChild(_leftPageStackBitmap);
			addChild(_rightPageStackBitmap);
			
			_currentPage = new FlexBookPage();
			_currentPage.cacheAsBitmap = true;
			_currentPage.styleName = this;
			
			addChild(_currentPage);
			addChild(_flipLayer);
			addChild(_interactionLayer);
			
			_interactionLayer.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
			_interactionLayer.addEventListener(MouseEvent.MOUSE_MOVE,trackMouseHandler);
			_interactionLayer.addEventListener(MouseEvent.ROLL_OVER,trackMouseHandler);
			_interactionLayer.addEventListener(MouseEvent.ROLL_OUT,trackMouseHandler);

		}

//--------------------------------------------------------------------------------------------------------
// page content and property commit managmeent
//-------------------------------------------------------------------------------------------------------

		private function bitmapSourceDrawHandler(e:Event):void
		{
//			if(_animatePagesOnTurn)
			{
				_pagesNeedUpdate = true;
				invalidateDisplayList();
			}
		}

		private function updateContent():void
		{
			if(_userContent is ArrayCollection)
				_content = _userContent;
			else if(_userContent is Array)
				_content = new ArrayCollection(_userContent);
			else if (_userContent is XMLList)
			{
				_content = new XMLListCollection(_userContent);
			}

			_contentChanged = false;
			pageHaveChanged = true;
			_eventPending = true;
		}

		private function contentFor(index:Number):*
		{
			var oneContent:*;
			if(index < 0)
				oneContent = _cover;
			else if (index >= _content.length)
				oneContent = _backCover;
			else
				oneContent = _content.getItemAt(index);

			return oneContent;
		}

		private function pageContentRendererFor(index:Number):IFlexDisplayObject
		{
			var oneContent:* = contentFor(index);
			return (oneContent == null)? null:allocateRendererFor(oneContent);
		}

		private function isCover(index:Number):Boolean
		{
			return ((_cover != null && index == 1) ||
					(_backCover != null && index == _content.length-2));
		}

		private function setStiff(page:FlexBookPage,pageIndex:Number):void
		{
			if(hardbackPagesD)
			{
				page.leftIsStiff = page.rightIsStiff = true;
			}
			else if(hardbackCoversD)
			{
				page.leftIsStiff = _cover != null && (pageIndex <= 0 || pageIndex >= pageCount);
				page.rightIsStiff = _backCover != null && (pageIndex < 0 || pageIndex >= pageCount-1);
			}
			else
			{
				page.leftIsStiff = page.rightIsStiff = false;
			}
		}

		public function contentToPageIndex(contentIndex:Number):Number
		{
			return  (_itemSize == ITEM_SIZE_PAGE)? contentIndex:Math.floor(contentIndex/2);
		}

		public function pageToContentIndex(pageIndex:Number):Number
		{
			return (_itemSize == ITEM_SIZE_PAGE)? pageIndex:pageIndex*2;
		}
		
		public function renderLeftPage():Bitmap
		{
			return renderPage(true);
		}
		
		public function renderRightPage():Bitmap
		{
			return renderPage(false);
		}
		
		private function renderPage(isLeft:Boolean = false):Bitmap
		{
					
			var obj:FlexBookPage = this.currentPage;
			
			var pageObj:ImagePage = null;
			if(isLeft == true)
			{
				if(obj.leftContent && obj.leftContent is ImagePage)
				{
					pageObj = obj.leftContent as ImagePage;
				}
				else if(obj.leftRenderer && obj.leftRenderer is ImagePage)
				{
					pageObj = obj.leftRenderer as ImagePage;	
				}
			}
			else
			{
				if(obj.rightContent && obj.rightContent is ImagePage)
				{
					pageObj = obj.rightContent as ImagePage;
				}
				else if(obj.rightRenderer && obj.rightRenderer is ImagePage)
				{
					pageObj = obj.rightRenderer as ImagePage;	
				}
			}
			
			
			/*
			//最初处理方式
			var c:DisplayObject = pageObj.imgPage.content;
			var img:BitmapData = new BitmapData(c.width/c.scaleX, c.height/c.scaleY, true, 0x00000000);
			img.draw(c);
			var bmp:Bitmap = new Bitmap(img,"auto",true);
			return bmp;
			*/
			
			pageObj.clearShadow();
			
			var c:DisplayObject = pageObj.imgPage.content;
			var img:BitmapData = new BitmapData(c.width/c.scaleX, c.height/c.scaleY, true, 0x00000000);
			var matrix:Matrix = new Matrix();
			if(isLeft){
				
				matrix.scale(1/c.scaleX,1/c.scaleY);
				img.draw(this,matrix,null,null,new Rectangle(0,0,img.width,img.height),true);
			}
			else{
				matrix.scale(1/c.scaleX,1/c.scaleY);
				matrix.translate(-img.width,0);
				img.draw(this,matrix,null,null,new Rectangle(0,0,img.width,img.height),true);
			}
			
			var bmp:Bitmap = new Bitmap(img,"auto",true);
			pageObj.addShadow();
			
			return bmp;
			
			
		}
		
		public function get currentDisplayObject():DisplayObject
		{
			var leftPage:int = getLeftPageNumber();
			var rightPage:int = getRightPageNumber();
			if(leftPage == -1)
			{
				return leftContentPage.rightRenderer as DisplayObject;
			}
			else if(rightPage == -1)
			{
				return rightContentPage.leftRenderer as DisplayObject;
			}
			else
			{
				return this;
			}
		}
		
		public function renderBookSnapshot():Bitmap
		{
			var obj:DisplayObject = this.currentPage;
			var img:BitmapData = new BitmapData(this.width,this.height, true, 0x00000000);
			img.draw(obj);
			var bmp:Bitmap = new Bitmap(img);
			return bmp;
		}
		
		public function renderSnapshot(maxWidth:Number = 300, maxHeight:Number = 200):Bitmap
		{
			var obj:DisplayObject = this;//this.currentPage;
			var wScale:Number = maxWidth/obj.width;
			var hScale:Number = maxHeight/obj.height;
			
			var scale:Number = Math.min(wScale,hScale);
			
			var imgWidth:Number = obj.width*scale;
			var leftPage:int = this.getLeftPageNumber();
			var rightPage:int = this.getRightPageNumber();
			
			if(leftPage == -1 || rightPage == -1)
			{
				imgWidth = imgWidth/2;
			}
			
			var img:BitmapData = new BitmapData(imgWidth, obj.height*scale, true, 0x00000000);
			
			if(leftPage != -1 && rightPage != -1)
			{
				img.draw(obj, new Matrix(scale,0,0,scale));
			}
			else if(leftPage == -1)
			{
				img.draw(obj, new Matrix(scale,0,0,scale,-scale*obj.width/2,0));
			}
			else
			{
				img.draw(obj, new Matrix(scale,0,0,scale));
			}
			
			var bmp:Bitmap = new Bitmap(img,"auto",true);
			return bmp;
		}

		private function fillPage(page:FlexBookPage,pageIndex:Number):void
		{
			if(zoomActive == true) return;
			
			var contentIndex:Number = pageToContentIndex(pageIndex);
			if(contentIndex < 0)
			{
				var coverContent:* = _cover;
				page.leftRenderer = null;
				page.rightRenderer = pageContentRendererFor(contentIndex);
				page.rightContent = contentFor(contentIndex);
				page.rightIndex = contentIndex;
				
				setStiff(page,pageIndex);
			}
			else if (contentIndex >= _content.length)
			{
				var backCoverContent:* = _backCover;
				page.leftRenderer = pageContentRendererFor(contentIndex);
				page.leftContent = contentFor(contentIndex);
				page.leftIndex = contentIndex;
				page.rightRenderer = null;

				setStiff(page,pageIndex);
				
			}
			else if(_itemSize == ITEM_SIZE_PAGE)
			{
				var content:* = _content.getItemAt(contentIndex);
				page.allRenderer = pageContentRendererFor(contentIndex);
				page.allContent = contentFor(contentIndex);
				page.allIndex = contentIndex;
				setStiff(page,pageIndex);
			}
			else
			{
				var leftContent:* = pageContentRendererFor(contentIndex);
				var rightContent:* = pageContentRendererFor(contentIndex+1);
				page.leftRenderer = leftContent;
				page.rightRenderer = rightContent;

				page.leftIndex = contentIndex;
				page.rightIndex = contentIndex+1;
				page.leftContent = contentFor(contentIndex);
				page.rightContent = contentFor(contentIndex+1);
				setStiff(page,pageIndex);
			}
			
			
		}

		private function fillPageStack(stack:Array,pageIndex:Number,size:Number):void
		{
			return;
//			
//			var dir:Number = 1;
//			if(size < 0)
//			{
//				dir = -1;
//				size = -size;
//			}
//			for(var i:int = 0;i<size;i++)
//			{
//				var idx:Number = pageIndex + i*dir;
//				if(idx < 0 || idx >= _content.length)
//					break;
//				if(contentFor(idx) == null)
//					continue;
//				var page:FlexBookPage = new FlexBookPage();
//				fillPage(page,idx);
//				page.cacheAsBitmap = true;//cachePolicy = cachePagesAsBitmapPolicy;
//				page.styleName = this;
//				addChildAt(page,0);
//				page.visible = false;
//				stack.unshift(page);
//			}
		}

		private function clearPageStack(stack:Array):void
		{
			for(var i:int = 0;i<stack.length;i++)
			{
				removeChild(stack[i]);
			}
			stack.splice(0,stack.length);
		}


		private function dispatchEventForPage(page:FlexBookPage,turning:Boolean):void
		{
			var eventType:String = (turning)? FlexBookEvent.TURN_START:FlexBookEvent.TURN_END;
			//var pageIndex:int = page.paFlexBookEvent.TURN_START:FlexBookEvent.TURN_END;

			updatePageStack(eventType);

			if(page.allRenderer != null)
			{
				dispatchEvent(new FlexBookEvent(eventType,false,false,page.allIndex,page.allContent,page.allRenderer));
			}
			else
			{
				dispatchEvent(new FlexBookEvent(eventType,false,false,page.leftIndex,page.leftContent,page.leftRenderer));
				dispatchEvent(new FlexBookEvent(eventType,false,false,page.rightIndex,page.rightContent,page.rightRenderer));
			}
		}

		override protected function commitProperties():void
		{
			if(_contentChanged)
			{
				updateContent();
			}
			
			if(_resetCurrentIndex)
			{
				_currentPageIndex = _displayedPageIndex = (_cover == null)? 0:-1;
				_resetCurrentIndex = false;
				dispatchEvent(new Event("resetCurrentIndex"));
			}

			if(pageHaveChanged && !zoomActive)
			{
				var transparencyDepth:Number = transparencyDepthD;

				beginRendererAllocation();
				pageHaveChanged = false;
				clearPageStack(_leftPageStack);
				clearPageStack(_rightPageStack);
				_currentPage.clearContent();
				_frontTurningPage.clearContent();
				_frontTurningBitmap = null;

				_backTurningPage.clearContent();
				_backTurningBitmap = null;

				_leftPageStackBitmap.bitmapData = null;
				_rightPageStackBitmap.bitmapData = null;

				if(_state == STATE_NONE)
				{
					_currentPage.visible = true;
					fillPage(_currentPage,_displayedPageIndex);
					fillPageStack(_leftPageStack,_displayedPageIndex-1,-transparencyDepth);
					fillPageStack(_rightPageStack,_displayedPageIndex+1,transparencyDepth);

					if(_eventPending)
					{
						dispatchEventForPage(_currentPage,false);
						_eventPending  = false;
					}
				}
				else
				{
					_currentPage.visible = false;
					if(_turnDirection == TURN_DIRECTION_FORWARD)
					{
						fillPageStack(_leftPageStack,_displayedPageIndex-1,-transparencyDepth);
						fillPageStack(_rightPageStack,_targetPageIndex+1,transparencyDepth);

						fillPage(_frontTurningPage,_displayedPageIndex);
						fillPage(_backTurningPage,_targetPageIndex);
					}
					else
					{
						fillPageStack(_leftPageStack,_targetPageIndex-1,-transparencyDepth);
						fillPageStack(_rightPageStack,_displayedPageIndex+1,transparencyDepth);

						fillPage(_frontTurningPage,_displayedPageIndex);
						fillPage(_backTurningPage,_targetPageIndex);
					}

					if(_eventPending)
						dispatchEventForPage(_backTurningPage,true);
				}


				setChildIndex(_flipLayer,numChildren-1);
				setChildIndex(_interactionLayer,numChildren-1);

				_pagesNeedUpdate = true;
				invalidateDisplayList();
				endRendererAllocation();
			}

		}


//--------------------------------------------------------------------------------------------------------
// layout and drawing
//-------------------------------------------------------------------------------------------------------

		private function updateDetails():void
		{
			_hCenter = unscaledWidth/2;
			_pageWidth = unscaledWidth/2;
			_pageLeft = _hCenter - _pageWidth;
			_pageRight = _hCenter + _pageWidth;
			_pageTop = 0;
			_pageBottom = unscaledHeight;
			_pageHeight = unscaledHeight;
			_oldWidth = unscaledWidth;
			_oldHeight = unscaledHeight;

		}

		private static const PAGE_STACK_FILL_COLOR: uint = 0xbbbbbb;
		private static const PAGE_STACK_LINE_COLOR: uint = 0x666666;
		private var _pageStackDirty: Boolean = true;

		// Rost: draw page stack
		private function updatePageStack(eventType:String = FlexBookEvent.TURN_START):void
		{
			if(zoomActive == true) return;
			var g:Graphics = _pageStack.graphics;

			var curPageIndex: int = _displayedPageIndex;
			if(eventType == FlexBookEvent.TURN_START)
			{
				if (_turnDirection == TURN_DIRECTION_FORWARD)
				{
					if( curPageIndex == pageCount - 1)
					{
						curPageIndex += 1;
					}
				}
				else
				{
					if (curPageIndex == 0)
					{
						curPageIndex = -1;
					}
				}
			}

			g.clear();

			// Draw left side
			var i: int = getLeftPageStackDepth(curPageIndex);
			var c: int = 0;

			var w: int = width / 2;
			var h: int = height;

			g.lineStyle(1, PAGE_STACK_LINE_COLOR, 1, true, LineScaleMode.NONE );
			for(i; i>c; i--)
			{
				g.beginFill( PAGE_STACK_FILL_COLOR, 1 );
				g.drawRect( - i * _pageOffsetXInStack + _pageOffsetXInStack, i * _pageOffsetYInStack - _pageOffsetYInStack, w, h);
				g.endFill();
			}

			i = getRightPageStackDepth(curPageIndex);
			c = 0;
			for(i; i>c; i--)
			{
				g.beginFill( PAGE_STACK_FILL_COLOR, 1 );
				g.drawRect( i * _pageOffsetXInStack + w - _pageOffsetXInStack, i * _pageOffsetYInStack - _pageOffsetYInStack, w, h);
				g.endFill();
			}
			
			updateBookMarks();
			
			_pageStackDirty = false;
			
			this.showGotoPageToolTip();
		}
		
		public function updateBookMarks():void
		{
			if(zoomActive == true) return;
			if(this.width < 10) return;
			
			var leftPages:Array = [];
			var rightPages:Array = [];
			
			if(this.rightToLeft == false)
			{
				for each(var item:BookMarkRecord in bookMarks)
				{
					if(item.pageIndex < this.currentPageIndex)
					{
						leftPages.push(item);
					}
					else if(item.pageIndex > this.currentPageIndex)
					{
						rightPages.push(item);
					}
					else if(item.page % 2 == 0)
					{
						leftPages.push(item);
					}
					else
					{
						rightPages.push(item);
					}
				}
			}
			else
			{
				for each(var item:BookMarkRecord in bookMarks)
				{
					var left:int = utils.PageNumHelper.convertInnerPageToRealPage(this.getLeftPageNumber());
					var right:int = utils.PageNumHelper.convertInnerPageToRealPage(this.getRightPageNumber());
					if(left >= 0 && item.page >= left)
					{
						leftPages.push(item);
					}
					else if(right >= 0 && item.page <= right)
					{
						rightPages.push(item);
					}
				}
			}
			
			var scale:Number = 1;
			if(this.height > 10)
			{
				scale = this.height / 800;
				trace("fb--h:"+this.height+" fb--s:"+scale);
			}
			
			switchLeftBookMarks(leftPages,scale);
			switchRightBookMarks(rightPages,scale);
		}
		
		public function getRealScale():Number
		{
			return this.localToGlobal(new Point(1,0)).x - this.localToGlobal(new Point()).x;
		}
		
		public var bookMarkAdded :Function;
		
		private function addBookMarkToStage(m:BookMark):void
		{
			m.book = this;
			m.fontSize = this.bookmarkFontSize;
			m.adjust();
			if(bookMarkAdded != null)
			{
				bookMarkAdded(m);
			}
		}
		
		private var bookmarkPadding:Number = 20;
		
		private function switchLeftBookMarks(leftPages:Array, scale:Number = 1):void
		{
			for each(var item:BookMarkRecord in leftPages)
			{
				item.remove();
			}
			
			BookMarkRecord.sort(leftPages);
			
			var offset:Number = bookmarkPadding *scale;
			var topOffset:Number = offset;
			var yStart:Number = offset;
			var scaledHeight:Number =  bookmarkHeight*scale + offset;
			
			var list:Array = [];
						
			for each(item in leftPages)
			{
				var m:BookMark = item.bookMark;
				m.rawWidth = bookmarkHeight * scale;
				m.rawHeight = (bookmarkWidth + 10) * scale;
				m.transform.matrix = new Matrix(0,-1,1,0);
				m.rawX = - m.rawHeight - getPageOffset(item.pageIndex);
				m.isLeft = true;
				m.removeEventListener(MouseEvent.CLICK,onBookmarkClick);
				m.addEventListener(MouseEvent.CLICK,onBookmarkClick);
				m.alpha = 1;
				list.push(m);
			}
			
			for(var i:int = 0; i < list.length; i++)
			{
				//BookMark(list[list.length - i - 1]).rawY = yStart + bookmarkHeight*scale;
				BookMark(list[i]).rawY = yStart + bookmarkHeight*scale;;
				
				yStart += scaledHeight;
				if(yStart + scaledHeight > this.height)
				{
					topOffset += offset * 0.2;
					yStart = topOffset;
				}
			}
			
			for(var i:int = 0; i < list.length; i++)
			{
				addBookMarkToStage(list[i]);
			}
		}
		
		private function onBookmarkClick(e:MouseEvent):void
		{
			var m:BookMark = e.currentTarget as BookMark;
			RunTime.mainPage.gotoPage(m.page);
			return;
		}
		
		private function switchRightBookMarks(rightPages:Array, scale:Number = 1):void
		{
			for each(var item:BookMarkRecord in rightPages)
			{
				item.remove();
			}
			
			BookMarkRecord.sort(rightPages);
			rightPages = rightPages.reverse();
			
			var offset:Number = bookmarkPadding *scale;
			var topOffset:Number = offset;
			var yStart:Number = offset;
			var scaledHeight:Number =  bookmarkHeight*scale + offset;
			
			var list:Array = [];
			
			for each(item in rightPages)
			{
				var m:BookMark = item.bookMark;
				m.rawWidth = bookmarkHeight * scale;
				m.rawHeight = (bookmarkWidth + 10) * scale;
				m.transform.matrix = new Matrix(0,1,-1,0);
				m.rawX = width + (bookmarkWidth + 10) * scale + getPageOffset(item.pageIndex);;
				m.rawY = m.offsetY*scale;
				m.isLeft = false;
				m.removeEventListener(MouseEvent.CLICK,onBookmarkClick);
				m.addEventListener(MouseEvent.CLICK,onBookmarkClick);
				m.alpha = 1;
				list.push(m);
			}
			
			for(var i:int = 0; i < list.length; i++)
			{
				BookMark(list[list.length - i - 1]).rawY = yStart;
				yStart += scaledHeight;
				if(yStart + scaledHeight > this.height)
				{
					topOffset += offset * 0.2;
					yStart = topOffset;
				}
			}
			
			for(var i:int = 0; i < list.length; i++)
			{
				addBookMarkToStage(list[i]);
			}
		}
		
		private function updateInteractionLayer():void
		{
			if(zoomActive == true) return;
			
			var g:Graphics = _interactionLayer.graphics;
			g.clear();
			
			var edgeWidth:Number = edgeWidthD;
			switch(activeGrabAreaD)
			{
				case GRAB_REGION_CORNER:
					g.beginFill(0,0);
					g.drawRect(_pageLeft,_pageTop,edgeWidth,edgeWidth);
					g.endFill();

					g.beginFill(0,0);
					g.drawRect(_pageLeft,_pageBottom-edgeWidth,edgeWidth,edgeWidth);
					g.endFill();

					g.beginFill(0,0);
					g.drawRect(_pageRight-edgeWidth,_pageBottom-edgeWidth,edgeWidth,edgeWidth);
					g.endFill();

					g.beginFill(0,0);
					g.drawRect(_pageRight-edgeWidth,_pageTop,edgeWidth,edgeWidth);
					g.endFill();
					break;
				case GRAB_REGION_EDGE:
					g.beginFill(0,0);
					g.drawRect(_pageLeft,_pageTop,edgeWidth,_pageHeight);
					g.endFill();

					g.beginFill(0,0);
					g.drawRect(_pageRight - edgeWidth,_pageTop,edgeWidth,_pageHeight);
					g.endFill();
					break;
				case GRAB_REGION_PAGE:
					g.beginFill(0,0);
					g.drawRect(_pageLeft,_pageTop,2*_pageWidth,_pageHeight);
					g.endFill();
					break;
				case GRAB_REGION_NONE:
					break
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if(zoomActive == true) return;

			var i:int;
			var page:FlexBookPage;

			if(_oldWidth != unscaledWidth || _oldHeight != unscaledHeight)
			{
				updateDetails();
				_interactionLayerDirty = true;
				_pageStackDirty = true;
				_pagesNeedUpdate = true;
			}

			if(_interactionLayerDirty)
			{
				_interactionLayerDirty = false;
				updateInteractionLayer();
			}

			updateInteractionLayer();

			if(_pageStackDirty)
			{
				updatePageStack();
			}

			if(_state != STATE_NONE)
			{
				if(_animatePagesOnTurn)
				{
					_bitmapsNeedUpdate = true;
				}
			}

			if(_frontTurningBitmap == null || _backTurningBitmap == null ||
				_leftPageStackBitmap.bitmapData == null || _rightPageStackBitmap.bitmapData == null)
			{
				_bitmapsNeedUpdate = true;
			}

			if(_pagesNeedUpdate)
			{
				if(_currentPage.hasContent)
				{
					_currentPage.setActualSize(2*_pageWidth,_pageHeight);
					_currentPage.move(_pageLeft,_pageTop);
					if(_currentPage.initialized == false)
						_currentPage.initialized = true;
				}

				for(i = 0;i<_leftPageStack.length;i++)
				{
					page = _leftPageStack[i];
					page.setActualSize(2*_pageWidth,_pageHeight);
					page.move(_pageLeft,_pageTop);
					if(page.initialized == false)
						page.initialized = true;
				}
				for(i = 0;i<_rightPageStack.length;i++)
				{
					page = _rightPageStack[i];
					page.setActualSize(2*_pageWidth,_pageHeight);
					page.move(_hCenter,_pageTop);
					if(page.initialized == false)
						page.initialized = true;
				}


				_pagesNeedUpdate = false;
				_bitmapsNeedUpdate = true;
			}


			if(_bitmapsNeedUpdate)
			{
				_bitmapsNeedUpdate = false;
				if(_frontTurningPage.hasContent)
				{
					_frontTurningPage.setActualSize(2*_pageWidth,_pageHeight);
					if(_frontTurningPage is UIComponent && UIComponent(_frontTurningPage).initialized == false)
						UIComponent(_frontTurningPage).initialized = true;
					_frontTurningBitmap = new BitmapData(_pageWidth,_pageHeight,true,0);
					_frontTurningPage.copyInto(_frontTurningBitmap,_turnDirection == TURN_DIRECTION_FORWARD? "right":"left");
				}
				else
				{
					_frontTurningBitmap = null;
				}
				if(_backTurningPage.hasContent)
				{
					_backTurningPage.setActualSize(2*_pageWidth,_pageHeight);
					if(_backTurningPage is UIComponent && UIComponent(_backTurningPage).initialized == false)
						UIComponent(_backTurningPage).initialized = true;
					_backTurningBitmap = new BitmapData(_pageWidth,_pageHeight,true,0);
					_backTurningPage.copyInto(_backTurningBitmap,_turnDirection == TURN_DIRECTION_FORWARD? "left":"right");
				}
				else
				{
					_backTurningBitmap = null;
				}

				_leftPageStackBitmap.bitmapData = new BitmapData(2*_pageWidth,_pageHeight,true,0);
				for (i=0;i<_leftPageStack.length;i++)
				{
					_leftPageStack[i].copyInto(_leftPageStackBitmap.bitmapData,"left");
				}
				if(_state != STATE_NONE)
				{
					if(_turnDirection == TURN_DIRECTION_FORWARD)
					{
						_frontTurningPage.copyInto(_leftPageStackBitmap.bitmapData,"left");
					}
					else
					{
						_backTurningPage.copyInto(_leftPageStackBitmap.bitmapData,"left");
					}
				}
				_rightPageStackBitmap.bitmapData = new BitmapData(2*_pageWidth,_pageHeight,true,0);
				for (i=0;i<_rightPageStack.length;i++)
				{
					_rightPageStack[i].copyInto(_rightPageStackBitmap.bitmapData,"right");
				}
				if(_state != STATE_NONE)
				{
					if(_turnDirection == TURN_DIRECTION_FORWARD)
					{
						_backTurningPage.copyInto(_rightPageStackBitmap.bitmapData,"right");
					}
					else
					{
						_frontTurningPage.copyInto(_rightPageStackBitmap.bitmapData,"right");
					}
				}
			}

			_leftPageStackBitmap.x = _pageLeft;
			_leftPageStackBitmap.y = _pageTop;
			_rightPageStackBitmap.x = _pageLeft;
			_rightPageStackBitmap.y = _pageTop;

			var g:Graphics = _flipLayer.graphics;
			g.clear();

			if(this.showPageSlope == true)
			{
				drawPageSlopes();
			}

			if (_state != STATE_NONE)
			{
				turnPage(_currentDragTarget,_pointOfOriginalGrab);
			}

		}

//--------------------------------------------------------------------------------------------------------
// lots of other stuff
//-------------------------------------------------------------------------------------------------------



		private function set currentPageIndexWithoutAnimation(value:Number):void
		{
//			value = value - (value % 2);
			if(value == _currentPageIndex)
				return;

			_displayedPageIndex = value;

			setCurrentPageIndex(_displayedPageIndex);

			pageHaveChanged = true;
			setState(STATE_NONE);
			invalidateProperties();
		}

		private function codeIsCorner(code:Number):Boolean
		{
			return ((code & 0x1) != 0);
		}
		
		private function getCornerCode(x:Number,y:Number):Number
		{
			var result:Number = 0;
			var edgeWidth:Number = edgeWidthD;
			if(x < _pageRight && x > _pageRight - edgeWidth)
			{
				if (y < _pageBottom && y > _pageBottom - edgeWidth)
					result = BOTTOM_RIGHT;
				else if (y > _pageTop && y < (_pageTop + edgeWidth))
					result = TOP_RIGHT;
				else
					result = RIGHT;
			}
			else if (x > _pageLeft && x < (_pageLeft + edgeWidth))
			{
				if (y < _pageBottom && y > _pageBottom - edgeWidth)
					result = BOTTOM_LEFT;
				else if (y > _pageTop && y < _pageTop + edgeWidth)
					result = TOP_LEFT;
				else
					result = LEFT;
			}
			return result;
		}

		private var savedCursorID: int;
		
		private function getGotoPageToolTipText(page:int):String
		{
			if(this.rightToLeft == true)
			{
				return l.i.s('GotoPage','Goto Page') + ' ' + utils.PageNumHelper.findPage(page).toString();
			}
			else
			{
				return l.i.s('GotoPage','Goto Page') + ' ' + (2 * page + 3).toString();
			}
		}
		
		private function showGotoPageToolTip():Boolean
		{
			var offsetPageIndex:int = this.getOffsetPage(mouseX,mouseY);

			if(offsetPageIndex > -1)
			{
				this.toolTip = "";
				this.toolTip = getGotoPageToolTipText(offsetPageIndex);
				return true;
			}
			else
			{
				this.toolTip = "";
				return false;
			}
		}
		
		public function isNormal():Boolean
		{
			return _state == STATE_NONE;
		}
		
		private function updateToolTipForNote():void
		{
			if(RunTime.note.length > 0)
			{
				this.toolTip = "";
				this.toolTip = l.i.s('ClickAddNote','Click on page to add your note');
			}			
		}

		private function trackMouseHandler(e:MouseEvent):void
		{
			
			if(this.zoomActive == true) return;
			
			if(this.pageActive == false)
			{
				updateToolTipForNote();
				return;
			}
			
			cursorManager.removeAllCursors();

			if(showGotoPageToolTip() == true)
			{
				buttonMode = true;
				return;
			}
			
			buttonMode = false;
			
			if(_state == STATE_NONE)
			{
				if(mouseX < _hCenter)
				{
					if(canTurnBackward() == false)
						return;
				}
				else
				{
					if(canTurnForward() == false)
						return;
				}

				_turnedCorner = getCornerCode(mouseX,mouseY);

				if(isShowCornerTease() == false)
					return;

				this.updateToolTip();

				if((_turnedCorner % 2) != 0)
				{

					setupForFlip(mouseX,mouseY);
					timerHandler(null);
					setState(STATE_TEASING);
				}
			}

			if (_state == STATE_TEASING)
			{
				var newCorner:Number = getCornerCode(mouseX,mouseY);
				if(newCorner == _turnedCorner)
				{
					_targetPoint = new Point(mouseX, mouseY);
				}
				else
				{
					switch(_turnedCorner)
					{
						case TOP_LEFT:
							_targetPoint = new Point(_pageLeft + 1,_pageTop + 1);
							break;
						case TOP_RIGHT:
							_targetPoint = new Point(_pageRight-1,_pageTop + 1);
							break;
						case BOTTOM_LEFT:
							_targetPoint = new Point(_pageLeft + 1,_pageBottom-1);
							break;
						case BOTTOM_RIGHT:
							_targetPoint = new Point(_pageRight-1,_pageBottom-1);
							break;
					}

					_turnedCorner = newCorner;
					setState(STATE_REVERTING);
				}
				invalidateDisplayList();
				timerHandler(null);
				e.updateAfterEvent();
			}
		}
		
		private function isShowCornerTease():Boolean
		{
			var showCornerTease:* = getStyle("showCornerTease");
			if(showCornerTease == false || showCornerTease == "false")
				return false;
			else return true;
		}
		
		public function clearToolTip():void
		{
			this.toolTip = "";
		}
		
		public function isMouseOnFlipArea():Boolean
		{
			var corner:int = getCornerCode(mouseX,mouseY);
			switch(corner)
			{
				case TOP_LEFT:
				case TOP_RIGHT:
				case BOTTOM_LEFT:
				case BOTTOM_RIGHT:
				case RIGHT:
				case LEFT:
					return true
					break;
			}
			return false;
		}
		
		public function receiveMouseClick(e:MouseEvent):void
		{
			var p:Point = new Point(e.stageX,e.stageY);
			p = this.globalToLocal(p);
			var corner:int = getCornerCode(p.x,p.y);
			if(_state != STATE_NONE || pageActive == false)
			{
				return;
			}
			
			switch(corner)
			{
				case TOP_LEFT:
				case TOP_RIGHT:
				case BOTTOM_LEFT:
				case BOTTOM_RIGHT:
				case RIGHT:
				case LEFT:
					mouseDownHandlerCore(p.x, p.y);
					break;
				default:
			}
		}

		public function updateToolTip():void
		{
			if(pageActive == false)
			{
				updateToolTipForNote();
				return;
			}
			
			var corner:int = getCornerCode(mouseX,mouseY);
			
			if(_state != STATE_NONE || pageActive == false)
			{
				toolTip="";
				return;
			}
			
			switch(corner)
			{
				case TOP_LEFT:
				case TOP_RIGHT:
				case BOTTOM_LEFT:
				case BOTTOM_RIGHT:
				case RIGHT:
				case LEFT:
					toolTip="";
					if(isShowCornerTease() == true)
					{
						if(RunTime.showFlipTip)
							toolTip= l.i.s('ClickToFlip','Click to Flip');
					}
					else
					{
						if(RunTime.showZoomTip)
							toolTip= l.i.s('ClickOrDragToZoom','Click or Drag to Zoom');
					}
					break;
				default:
					toolTip="";
					if(RunTime.showZoomTip)
						toolTip= l.i.s('ClickOrDragToZoom','Click or Drag to Zoom');				
					break;
			}
		}
//--------------------------------------------------------------------------------------------------------
// the flip effect
//-------------------------------------------------------------------------------------------------------

		private function setupForFlip(x:Number,y:Number,targetPageIndex:Number = NaN):void
		{
			var code:Number = getCornerCode(x,y);
			var delta:Vector2;

			switch(code)
			{
				case TOP_LEFT:
					_pointOfOriginalGrab = new Point(_pageLeft,_pageTop);
					break;
				case TOP_RIGHT:
					_pointOfOriginalGrab = new Point(_pageRight,_pageTop);
					break;
				case BOTTOM_LEFT:
					_pointOfOriginalGrab = new Point(_pageLeft,_pageBottom);
					break;
				case BOTTOM_RIGHT:
					_pointOfOriginalGrab = new Point(_pageRight,_pageBottom);
					break;
				default:
					_pointOfOriginalGrab = new Point(x,y);
					break;
			}

			if (!isNaN(targetPageIndex))
			{
				_targetPageIndex = targetPageIndex;
			}
			else
			{
				if (_pointOfOriginalGrab.x < unscaledWidth/2)
				{
					_targetPageIndex = _currentPageIndex - 1;
				}
				else
				{
					_targetPageIndex = _currentPageIndex + 1;
				}
			}
			if (_targetPageIndex < _currentPageIndex)
			{
				if(canTurnBackward() == false)
					return;
				_displayedPageIndex = _currentPageIndex;
				_turnDirection = TURN_DIRECTION_BACKWARDS;
			}
			else
			{
				if(canTurnForward() == false)
					return;
				_turnDirection = TURN_DIRECTION_FORWARD;
				_displayedPageIndex = _currentPageIndex;
			}

			_targetPoint = new Point(x,y);

			if (_pointOfOriginalGrab.x > _hCenter)
			{
				_pointOfOriginalGrab.x = _pageRight;
			}
			else
			{
				_pointOfOriginalGrab.x = _pageLeft;
			}
			if(_pointOfOriginalGrab.y > (_pageTop + _pageBottom)/2)
			{
				if (_pointOfOriginalGrab.x > _hCenter)
				{
					delta = new Vector2(new Point(x,_pointOfOriginalGrab.y),new Point(x+10,_pointOfOriginalGrab.y+1));
				}
				else
				{
					delta = new Vector2(new Point(x,_pointOfOriginalGrab.y),new Point(x-10,_pointOfOriginalGrab.y+1));
				}
				_pointOfOriginalGrab.y = Math.min(_pageBottom,delta.yForX(_pointOfOriginalGrab.x));
			}
			else
			{
				if (_pointOfOriginalGrab.x > _hCenter)
				{
					delta = new Vector2(new Point(x,_pointOfOriginalGrab.y),new Point(x+10,_pointOfOriginalGrab.y-1));
				}
				else
				{
					delta = new Vector2(new Point(x,_pointOfOriginalGrab.y),new Point(x-10,_pointOfOriginalGrab.y-1));
				}
				_pointOfOriginalGrab.y = Math.max(_pageTop,delta.yForX(_pointOfOriginalGrab.x));
			}
			_currentDragTarget = _pointOfOriginalGrab.clone();

			_timer.start();
		}

		private function setState(value:Number):void
		{
			var wasTurning:Boolean = (_state != STATE_NONE);
			var willBeTurning:Boolean = (value != STATE_NONE);
			_state = value;

			if(wasTurning != willBeTurning)
			{
				_eventPending = true;
				pageHaveChanged = true;
				invalidateProperties();
			}
		}
		
		public function getLeftPageNumber():int
		{
			if(currentPageIndex == -1 
				|| leftContentPage == null
				|| leftContentPage.width == 0)
			{
				return -1;
			}
			else
			{
				return currentPageIndex * 2 + 2
			}
		}
		
		public function getRightPageNumber():int
		{
			if(currentPageIndex == pageCount)
			{
				return -1;
			}
			else
			{
				return currentPageIndex * 2 + 3;
			}
		}
		
		private function getLeftPageStackDepth(curPageIndex:int):int
		{
			var realPageCount:int = pageCount;
			if(this.rightToLeft == true)
			{
				if(this.cover == null)
				{
					realPageCount --;
				}
			}
			
			if(realPageCount == 0) return 0;
			
			this.maxPageStackDepth = RunTime.thickness;
			
			var left:Number = curPageIndex + 1;
			if(left / realPageCount < 0.3)
			{
				left = Math.min((left / (0.3 * realPageCount)) * maxPageStackDepth, curPageIndex + 1);
			}
			if(RunTime.showPageCount != RunTime.pageCount && RunTime.showPageCount != 0){
				left = RunTime.showPageCount * (left/realPageCount);
			}
			left = Math.min(maxPageStackDepth, left);

			return left;
		}

		private function getRightPageStackDepth(curPageIndex:int):int
		{
			this.maxPageStackDepth = RunTime.thickness;
			
			if(pageCount == 0) return 0;
			
			var right:Number = pageCount - curPageIndex;
			if(right / pageCount < 0.3)
			{
				right = Math.min((right / (0.3 * pageCount)) * maxPageStackDepth, pageCount - curPageIndex);
			}
			if(RunTime.showPageCount != RunTime.pageCount && RunTime.showPageCount != 0){
				right = RunTime.showPageCount * (right/pageCount);
			}
			right = Math.min(maxPageStackDepth, right);
			
			return right;
		}

		/**
		 * 判断鼠标放在Offset Stack 时，当前所指的页面 
		 * @param x 鼠标的横坐标
		 * @param y 鼠标的纵坐标
		 * @return 鼠标在书的边缘上，则返回相应的页面，否则，返回-1
		 * 
		 */		
		private function getOffsetPage(x:Number,y:Number):int
		{
			var offsetPageIndex:int = -1;

			var curPageIndex: int = _displayedPageIndex;
			var iLeft: int = getLeftPageStackDepth(curPageIndex);
			var iRight: int  = getRightPageStackDepth(curPageIndex);
			var leftOffsetWidth:int = Math.max(1, _pageOffsetXInStack * iLeft);
			var rightOffsetWidth:int = Math.max(1, _pageOffsetXInStack * iRight);
			var leftOffsetHeight:int = Math.max(1, _pageOffsetYInStack * iLeft);
			var rightOffsetHeight:int = Math.max(1, _pageOffsetYInStack * iRight);
			
			if(x > width && x < width + rightOffsetWidth)
			{
				offsetPageIndex = curPageIndex + int(( pageCount - curPageIndex) * (x - width)/rightOffsetWidth);
			}
			else if(x < 0 && x > - leftOffsetWidth)
			{
				offsetPageIndex = curPageIndex + int( curPageIndex * x/leftOffsetWidth);
			}
			else if(x > width/2 && y > height && y < height + rightOffsetHeight)
			{
				offsetPageIndex = curPageIndex + int(( pageCount - curPageIndex) * (y - height)/rightOffsetHeight);
			}
			else if(x < width/2 && y > height && y < height + leftOffsetHeight)
			{
				offsetPageIndex = curPageIndex - int(Math.abs(curPageIndex) * (y - height)/leftOffsetHeight);
			}
			if(offsetPageIndex == curPageIndex)
			{
				offsetPageIndex = -1;
			}
			return offsetPageIndex;
		}
		
		private function getPageOffset(pageIndex:int):Number
		{
			var offsetPageIndex:int = -1;
			
			var curPageIndex: int = _displayedPageIndex;
			var iLeft: int = getLeftPageStackDepth(curPageIndex);
			var iRight: int  = getRightPageStackDepth(curPageIndex);
			var leftOffsetWidth:int = Math.max(1, _pageOffsetXInStack * iLeft);
			var rightOffsetWidth:int = Math.max(1, _pageOffsetXInStack * iRight);
			var offset:Number = 0;
			if(pageIndex == curPageIndex)
			{
				offset = 0;
			}
			else if(pageIndex > curPageIndex)
			{
				if(pageCount > curPageIndex)
				{
					offset = Math.min(rightOffsetWidth - _pageOffsetXInStack, (pageIndex - curPageIndex) * rightOffsetWidth / (pageCount - curPageIndex) + 2);
				}
				else
				{
					offset =  rightOffsetWidth;
				}
			}
			else
			{
				if(curPageIndex > 0)
				{
					offset =  (curPageIndex - pageIndex + 1) * leftOffsetWidth / (curPageIndex + 1) - 2;
				}
				else
				{
					offset =  leftOffsetWidth;
				}
			}
			return offset;
		}
		
		private function mouseDownHandlerCore(xx:Number, yy:Number):void
		{
			var offsetPageIndex:int = this.getOffsetPage(xx,yy);
			
			if(offsetPageIndex > -1)
			{
				this.turnToPage(offsetPageIndex);
				return;
			}
			
			if(mouseX < _hCenter)
			{
				if(canTurnBackward() == false)
					return;
			}
			else
			{
				if(canTurnForward() == false)
					return;
			}
			
			if(_state != STATE_TEASING)
			{
				finishTurn();
				
				if(mouseX < _hCenter)
				{
					this.turnToPage(this.currentPageIndex - 1);
				}
				else
				{
					this.turnToPage(this.currentPageIndex + 1);
				}
				return;
			}
			
			_clickBecameDrag = false;
			
			systemManager.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler,true);
			systemManager.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler,true);
			setState(STATE_TURNING);
			_targetPoint = new Point(mouseX, mouseY);
			invalidateDisplayList();
			timerHandler(null);
		}
		
		private function mouseDownHandler(e:MouseEvent):void
		{
			if(this.pageActive == false)
			{
				updateToolTipForNote();
				return;
			}
			
			mouseDownHandlerCore(mouseX, mouseY);
		}
		
		private function mouseMoveHandler(e:MouseEvent):void
		{
			
			_clickBecameDrag = true;
			_targetPoint = new Point(mouseX, mouseY);
			timerHandler(null);
			
			invalidateDisplayList();
			e.updateAfterEvent();
		}

		private function mouseUpHandler(e:MouseEvent):void
		{
			_targetPoint = new Point(mouseX, mouseY);
			invalidateDisplayList();
			systemManager.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler,true);
			systemManager.removeEventListener(MouseEvent.MOUSE_UP,mouseUpHandler,true);

			_targetPoint = _pointOfOriginalGrab.clone();
			if(_clickBecameDrag == false)
			{
				if(mouseX > _hCenter)
				{
					this.turnToPage(currentPageIndex+1);
				}
				else
				{
					this.turnToPage(currentPageIndex-1);
				}
			}
			else if(mouseX > _hCenter)
			{
				setState(_turnDirection == TURN_DIRECTION_FORWARD? STATE_REVERTING:STATE_COMPLETING);
				_targetPoint.x = _pageRight;
			}
			else
			{
				setState(_turnDirection == TURN_DIRECTION_FORWARD? STATE_COMPLETING:STATE_REVERTING);
				_targetPoint.x = _pageLeft;
			}
		}

		private function finishTurn():void
		{
			_timer.stop();
			if(_state == STATE_COMPLETING || _state == STATE_AUTO_TURNING || _state == STATE_AUTO_COMPLETING )
			{
				setCurrentPageIndex(_targetPageIndex);
			}
			_displayedPageIndex = _currentPageIndex;
			setState(STATE_NONE);
		}

		private function timerHandler(e:TimerEvent):void
		{
			var dx:Number;
			var dy:Number;
			var completeDx:Number;

			if(_currentDragTarget == null)
			{
				return;
			}

			if(_state == STATE_AUTO_TURNING)
			{
				if(isNaN(_turnStartTime))
				{
					_turnStartTime = getTimer();
				}

				dx = (_targetPoint.x - _currentDragTarget.x);
				dy = (_targetPoint.y - _currentDragTarget.y);

				var t:Number = (getTimer() - _turnStartTime)/(autoTurnDurationD );
				t = Math.min(t,1);

				var a:Number = t * Math.PI;

				var accelX: Number = 0.1;//X_ACCELERATION;
				var accelY: Number = 0.1;//Y_ACCELERATION;
				if(_turnDirection == TURN_DIRECTION_FORWARD)
				{
					_currentDragTarget.x = _hCenter + _pageWidth*Math.cos(a);
					_currentDragTarget.y = _pageBottom - _pageHeight/15*Math.sin(a);
					//_currentDragTarget.x = _hCenter + _pageWidth / (a*accelX);
					//_currentDragTarget.y = _pageBottom - _pageHeight/ (a*accelY);
				}
				else
				{
					_currentDragTarget.x = (_hCenter - _pageWidth*Math.cos(a));
					_currentDragTarget.y = _pageBottom - _pageHeight/15*Math.sin(a);
					//_currentDragTarget.x = _hCenter - _pageWidth / (a*accelX);
					//_currentDragTarget.y = _pageBottom - _pageHeight / (a*accelY);
				}
				if(t == 1)
					finishTurn();
			}
			else
			{
				var xSpeedMultiplier:Number = 1 * flipSpeedBoost * 0.02;
				var ySpeedMultiplier:Number = 1 * flipSpeedBoost * 0.02;
				if(_state == STATE_COMPLETING || _state == STATE_REVERTING)
				{
					xSpeedMultiplier = 2.3 * flipSpeedBoost * 0.02;//1.5; Rost: make corner reverting faster
				}
				else if (_state == STATE_AUTO_COMPLETING)
				{
					xSpeedMultiplier = 1.9 * flipSpeedBoost * 0.02;
					ySpeedMultiplier = 1.5 * flipSpeedBoost * 0.02;
				}

				dx = (_targetPoint.x - _currentDragTarget.x);
				dy = (_targetPoint.y - _currentDragTarget.y);

				if( dx > 0 )
				{
					completeDx = Math.max(dx, 2);
				}
				else
				{
					completeDx = Math.min(dx, -2);
				}

				// Rost: seconf condition is added to make reverting faster
				if(Math.abs(dx) <= 1 || ( _state == STATE_REVERTING && Math.abs(dx) <= 30) )
				{
					// if we're very close to the edge of the page, we get rounding
					// errors on things like gradients.  So when our x value gets close,
					// we'll only animate the y value until we're almost done, then just
					// jump to the final values.

					// Rost: seconf condition is added to make reverting faster
					if(Math.abs(dy) <= .1 || ( _state == STATE_REVERTING && Math.abs(dy) <= 30))
					{
						// we're as close as we're gonna get, so jump to the end and finish our turn.
						_currentDragTarget.x += dx;
						_currentDragTarget.y += dy;
						if(_state == STATE_COMPLETING || _state == STATE_REVERTING || _state == STATE_AUTO_COMPLETING)
						{
							finishTurn();
						}
					}
					else
					{
						// just advance the y value.
						_currentDragTarget.y += dy * SOLO_Y_ACCELERATION * ySpeedMultiplier;
					}
				}
				else
				{
					// advance both the x and y values.
					_currentDragTarget.x += completeDx * X_ACCELERATION * xSpeedMultiplier;
					_currentDragTarget.y += dy * Y_ACCELERATION * ySpeedMultiplier;
				}
			}

			invalidateDisplayList();
			if(e)
				e.updateAfterEvent();

		}

		public function get hasLeftContent():Boolean
		{
			return (_leftPageStack.length > 0 ||
				   _currentPage.hasLeftContent ||
				   (_turnDirection == TURN_DIRECTION_BACKWARDS && _backTurningPage.hasLeftContent) ||
				   (_turnDirection == TURN_DIRECTION_FORWARD && _frontTurningPage.hasLeftContent));
		}

		public function get hasRightContent():Boolean
		{
			return (_rightPageStack.length > 0 ||
					_currentPage.hasRightContent ||
					(_turnDirection == TURN_DIRECTION_FORWARD && _backTurningPage.hasRightContent) ||
					(_turnDirection == TURN_DIRECTION_BACKWARDS && _frontTurningPage.hasRightContent));
		}
		
		public function get rightContentPage():FlexBookPage
		{
			return (_state == STATE_NONE)? 							_currentPage		:
				   (_turnDirection == TURN_DIRECTION_FORWARD)? 		_backTurningPage	:
				   													_frontTurningPage	;
		}

		public function get leftContentPage():FlexBookPage
		{
			return (_state == STATE_NONE)? 							_currentPage		:
				   (_turnDirection == TURN_DIRECTION_FORWARD)? 		_frontTurningPage	:
				   													_backTurningPage	;
		}

		private function drawPageSlopes():void
		{
			
			var g:Graphics = _flipLayer.graphics;

			var m:Matrix = new Matrix();

			if(showPageSlopeAtRestD == false)
			{
				if(_state == STATE_NONE)
					return;
			}

			if(hasRightContent)
			{
				m.createGradientBox(_pageWidth,_pageHeight,0,_hCenter,_pageTop);
				g.lineStyle(0,0,0);
				g.moveTo(_hCenter,_pageTop);
				beginRightSideGradient(g,m,rightContentPage.rightIsStiff);
				g.lineTo(_pageRight,_pageTop);
				g.lineTo(_pageRight,_pageBottom);
				g.lineTo(_hCenter,_pageBottom);
				g.lineTo(_hCenter,0);
				g.endFill();
			}

			if(hasLeftContent)
			{
				m.createGradientBox(_pageWidth,_pageHeight,Math.PI,_pageLeft,_pageTop);
				g.lineStyle(0,0,0);
				g.moveTo(_hCenter,_pageTop);

				beginLeftSideGradient(g,m,leftContentPage.leftIsStiff);
				g.lineTo(_pageLeft,_pageTop);
				g.lineTo(_pageLeft, _pageBottom);
				g.lineTo(_hCenter,_pageBottom);
				g.lineTo(_hCenter,_pageTop);
				g.endFill();
			}
		}

		private function turnPage(dragPt:Point, grabPt:Point):void
		{
			if(_turnDirection == TURN_DIRECTION_FORWARD)
			{
				if(_frontTurningPage.rightIsStiff || _backTurningPage.leftIsStiff)
				{
					turnStiffPage(dragPt,grabPt);
					return;
				}
			}
			else
			{
				if(_frontTurningPage.leftIsStiff || _backTurningPage.rightIsStiff)
				{
					turnStiffPage(dragPt,grabPt);
					return;
				}
			}
			turnFoldablePage(dragPt,grabPt);
		}

		private function turnStiffPage(dragPt:Point, grabPt:Point):void
		{
			var topCorner:Point;
			var bottomCorner:Point;
			var hPageEdge:Number;

			var ellipseHAxis:Number = Math.abs(grabPt.x - _hCenter);
			var ellipseVAxis:Number = (_pageWidth/4) * (ellipseHAxis / _pageWidth);
			var slope:Number = - (dragPt.y - grabPt.y)/(dragPt.x - _hCenter);
			var eqY:Number = Math.sqrt((slope*ellipseHAxis*ellipseVAxis)*(slope*ellipseHAxis*ellipseVAxis) /
									( ellipseVAxis*ellipseVAxis + slope*slope*ellipseHAxis*ellipseHAxis));
			var eqX:Number = ellipseHAxis * Math.sqrt(1 - (eqY*eqY)/(ellipseVAxis*ellipseVAxis));

			var targetGrabX:Number = _hCenter + ((dragPt.x > _hCenter)? eqX:-eqX);
			var targetGrabY:Number = grabPt.y - eqY;


			var adjustedDragPt:Point = dragPt.clone();
			if(_turnDirection == TURN_DIRECTION_FORWARD)
			{
				adjustedDragPt.x = Math.min(grabPt.x,adjustedDragPt.x);
				adjustedDragPt.x = Math.max(_hCenter - (grabPt.x-_hCenter),adjustedDragPt.x);
				hPageEdge = _pageRight;
			}
			else
			{
				adjustedDragPt.x = Math.max(grabPt.x,adjustedDragPt.x);
				adjustedDragPt.x = Math.min(_hCenter + (_hCenter-grabPt.x),adjustedDragPt.x);
				hPageEdge = _pageLeft;
			}
			var ellipseYIntersection:Number = ellipseVAxis * Math.sqrt(1 - Math.pow((adjustedDragPt.x-_hCenter)/ellipseHAxis,2));
			topCorner = new Point(hPageEdge,_pageTop);
			bottomCorner = new Point(hPageEdge,_pageBottom);


			var scale:Number = Math.abs((adjustedDragPt.x - _hCenter)/(grabPt.x -_hCenter));

			var m:Matrix = new Matrix();
			var g:Graphics = _flipLayer.graphics;
			g.lineStyle(0,0,0);

			if(adjustedDragPt.x > _hCenter)
			{
				m.identity();
				m.scale(scale,1);
				m.b = -ellipseYIntersection/Math.abs(grabPt.x-_hCenter);
				m.translate(_hCenter,_pageTop);
			}
			else
			{
				m.identity();
				m.scale(scale,1);
				m.b = ellipseYIntersection/Math.abs(_hCenter - grabPt.x);
				m.translate(_hCenter - _pageWidth * scale,_pageTop-ellipseYIntersection);
			}

			var bitmapTopAnchor:Point = m.transformPoint(new Point(0,0));
			var bitmapBottomAnchor:Point = m.transformPoint(new Point(0,_pageHeight));
			var bitmapTopCorner:Point = m.transformPoint(new Point(_pageWidth,0));
			var bitmapBottomCorner:Point = m.transformPoint(new Point(_pageWidth,_pageHeight));

			var pagePoly:Array = [
				bitmapTopAnchor,
				bitmapTopCorner,
				bitmapBottomCorner,
				bitmapBottomAnchor
			];

			if(Math.abs(scale*_pageWidth) > 1)
			{
				// if(this.showPageSlope == true)
				{
					var sm:Matrix = new Matrix();
					if(adjustedDragPt.x > _hCenter)
					{
						if(hasRightContent && Math.abs(scale*_pageWidth) > 5)
						{
							sm.createGradientBox(_pageWidth*(scale*.9),_pageHeight,0,_hCenter,_pageTop);
							beginStiffShadowGradient(g,sm);
							g.moveTo(_hCenter,_pageTop);
							g.lineTo(_pageRight,_pageTop);
							g.lineTo(_pageRight,_pageBottom);
							g.lineTo(_hCenter,_pageBottom);
							g.lineTo(_hCenter,_pageTop);
							g.endFill();
						}
					}
					else
					{
						if(hasLeftContent > 0 && Math.abs(scale*_pageWidth) > 5)
						{
							sm.createGradientBox(_pageWidth*(Math.abs(scale)*.9),_pageHeight,Math.PI,_hCenter - _pageWidth*(Math.abs(scale)*.9),_pageTop);
							beginStiffShadowGradient(g,sm);
							g.moveTo(_pageLeft,_pageTop);
							g.lineTo(_hCenter,_pageTop);
							g.lineTo(_hCenter,_pageBottom);
							g.lineTo(_pageLeft,_pageBottom);
							g.lineTo(_pageLeft,_pageTop);
							g.endFill();
						}
					}
				}


				if(adjustedDragPt.x > _hCenter)
				{
					g.beginBitmapFill(_turnDirection == TURN_DIRECTION_FORWARD? _frontTurningBitmap:_backTurningBitmap,m,false,true);
				}
				else
				{
					g.beginBitmapFill(_turnDirection == TURN_DIRECTION_FORWARD? _backTurningBitmap:_frontTurningBitmap,m,false,true);
				}
				drawPoly(g,pagePoly);
				g.endFill();

				var gm:Matrix = new Matrix();
				if(adjustedDragPt.x > _hCenter)
				{
					if(this.showPageSlope == true)
					{
						gm.createGradientBox(_pageWidth*scale,_pageHeight,0,_hCenter,_pageTop);
						beginRightSideGradient(g,gm,true);
					}
				}
				else
				{
					if(this.showPageSlope == true)
					{
						gm.createGradientBox(_pageWidth*scale,_pageHeight,Math.PI,_hCenter - _pageWidth*scale,_pageTop);
						beginLeftSideGradient(g,gm,true);
					}
				}

				drawPoly(g,pagePoly);
				g.endFill();
			}


		}

		/**
		 * 翻页的核心方法。 
		 * @param dragPt 鼠标拖动点
		 * @param grabPt 拖动方向
		 * 
		 */		
		private function turnFoldablePage(dragPt:Point, grabPt:Point):void
		{

			/* note to the reader: This function, which is the core of the flip effect,
			*  was built iteratively. Which means there's a lot of cleanup to be done, including
			*  probably some performance improvements. So feel free to give it a whack ;)
			*/
			grabPt = grabPt.clone();
			grabPt.x = (grabPt.x > _hCenter)? _pageRight:_pageLeft;

			var maxDistanceFromAnchor:Number;
			var hPageEdge:Number;
			var hOppositePageEdge:Number;

			// figure out which vertical edge we care about
			if (grabPt.x > _hCenter)
			{
				hPageEdge = _pageRight;
				hOppositePageEdge = _pageLeft;
			}
			else
			{
				hPageEdge = _pageLeft;
				hOppositePageEdge = _pageRight;
			}


			// now if the user has dragged past the bounds of the book, clip the drag to the bounds.
			if(dragPt.x > _pageRight)
				dragPt.x = _pageRight;
			else if (dragPt.x < _pageLeft)
				dragPt.x = _pageLeft;

			var topAnchor:Point = new Point(_hCenter,_pageTop);
			var bottomAnchor:Point = new Point(_hCenter,_pageHeight);
			var topCorner:Point = new Point(hPageEdge,_pageTop);
			var topOppositeCorner:Point = new Point(hOppositePageEdge,_pageTop);
			var bottomCorner:Point = new Point(hPageEdge,_pageHeight);
			var bottomOppositeCorner:Point = new Point(hOppositePageEdge,_pageHeight);

			var anchorToDragPt:Vector2;
			var dragDistanceFromAnchor:Number;

			if(dragPt.y <= grabPt.y)
			{
				maxDistanceFromAnchor = new Vector2(bottomAnchor,grabPt).length;
				// the user has dragged up

				// make sure we can't pull so far we'd tear the page.  If that happens, just adjust our drag pt and
				// behave as though we weren't pulling father.
				anchorToDragPt = new Vector2(bottomAnchor,dragPt);
				dragDistanceFromAnchor = anchorToDragPt.length;

				if (dragDistanceFromAnchor > maxDistanceFromAnchor)
				{
					anchorToDragPt.length = maxDistanceFromAnchor;
					dragPt = anchorToDragPt.p1.clone();
				}
			}
			else
			{
				// the user has dragged down

				maxDistanceFromAnchor = new Vector2(topAnchor,grabPt).length;

				// make sure we can't pull so far we'd tear the page.  If that happens, just adjust our drag pt and
				// behave as though we weren't pulling father.
				anchorToDragPt = new Vector2(topAnchor,dragPt);
				dragDistanceFromAnchor = anchorToDragPt.length;

				if (dragDistanceFromAnchor > maxDistanceFromAnchor)
				{
					anchorToDragPt.length = maxDistanceFromAnchor;
					dragPt = anchorToDragPt.p1.clone();
				}

			}

			var dragToStart:Vector2 = new Vector2(dragPt,grabPt);

			//determine the normalize vector for the fold.
			var fold:Vector2 = dragToStart.clone();
			fold.length /= 2;
			var dragToStartCenter:Point = fold.p1.clone();
			fold.perp();
			fold.moveTo(dragToStartCenter);
			fold.normalize();


			var foldTopRight:Point;
			var foldTopLeft:Point;
			var foldBottomRight:Point;
			var foldBottomLeft:Point;
			var virtualPageTopLeft:Point;


			var foldIntersectionWithTop:Number = fold.xForY(_pageTop);

			if(Math.abs(foldIntersectionWithTop - _hCenter)  < Math.abs(hPageEdge - _hCenter))
			{
				var topEdge:Vector2 = new Vector2(new Point(foldIntersectionWithTop,_pageTop), topCorner);
				topEdge.reflect(fold);
				foldTopLeft = virtualPageTopLeft = topEdge.p1;
				foldTopRight = topEdge.p0;
			}
			else
			{
				foldTopLeft = foldTopRight = new Point(hPageEdge,fold.yForX(hPageEdge));
				var foldExtension:Vector2 = new Vector2(foldTopLeft, topCorner);
				foldExtension.reflect(fold);
				virtualPageTopLeft = foldExtension.p1;
			}

			var foldIntersectionWithBottom:Number = fold.xForY(_pageHeight);
			if (Math.abs(foldIntersectionWithBottom - _hCenter) < Math.abs(hPageEdge - _hCenter))
			{
				var bottomEdge:Vector2 = new Vector2(new Point(foldIntersectionWithBottom,_pageHeight),bottomCorner);
				bottomEdge.reflect(fold);
				foldBottomLeft = bottomEdge.p1;
				foldBottomRight = bottomEdge.p0;
			}
			else
			{
				foldBottomLeft = foldBottomRight = new Point(hPageEdge,fold.yForX(hPageEdge));
			}

			var topDoublePagePoly:Array = [];
			var topTurningPagePoly:Array = [];

			if(dragToStart.length2 > .1)
			{

				if(foldTopRight.y > _pageTop)
					topDoublePagePoly.push(topCorner);
				topDoublePagePoly.push(foldTopRight);
				topDoublePagePoly.push(foldBottomRight);
				if(foldBottomRight.y < _pageHeight)
					topDoublePagePoly.push(bottomCorner);

			}
			else
			{
					topDoublePagePoly.push(topCorner);
					topDoublePagePoly.push(bottomCorner);
			}

			topTurningPagePoly = topDoublePagePoly.concat();

			topTurningPagePoly.unshift(topAnchor);
			topTurningPagePoly.push(bottomAnchor);

			topDoublePagePoly.unshift(topOppositeCorner);
			topDoublePagePoly.push(bottomOppositeCorner);

			var revealedPagePoly:Array = [];
			revealedPagePoly.push(foldTopRight);
			if(foldTopRight.y == _pageTop)
				revealedPagePoly.push(topCorner);
			if(foldBottomRight.y == _pageHeight)
				revealedPagePoly.push(bottomCorner);
			revealedPagePoly.push(foldBottomRight);

			var leadingEdge:Vector2;
			var shortPageEdge:Vector2;


			if(_turnDirection == TURN_DIRECTION_FORWARD)
			{
				leadingEdge = new Vector2(foldBottomLeft,foldTopLeft);
			}
			else if(_turnDirection == TURN_DIRECTION_BACKWARDS)
			{
				var tmpP:Point = foldTopLeft;
				foldTopLeft = foldTopRight;
				foldTopRight = tmpP;

				tmpP = foldBottomLeft;
				foldBottomLeft = foldBottomRight;
				foldBottomRight = tmpP;

				leadingEdge = new Vector2(foldBottomRight,foldTopRight);
				shortPageEdge = leadingEdge.clone();
				shortPageEdge.perp();
				shortPageEdge.length = _pageWidth;
				shortPageEdge.moveTo(virtualPageTopLeft);
				virtualPageTopLeft = shortPageEdge.p1;
			}

			var foldPoly:Array = [];
			foldPoly.push(foldTopLeft);
			foldPoly.push(foldTopRight);
			foldPoly.push(foldBottomRight);
			foldPoly.push(foldBottomLeft);

			var turnPercent:Number;

			if(_turnDirection == TURN_DIRECTION_FORWARD)
			{
				turnPercent = 1 - (dragPt.x - _pageLeft) / (2*_pageWidth);
			}
			else
			{
				turnPercent = (dragPt.x-_pageLeft) / (2*_pageWidth);
			}

			var m:Matrix = new Matrix();

			var g:Graphics = _flipLayer.graphics;

			if(_frontTurningBitmap != null)
			{
				// draw the top of the turning page
				m.identity();
				if(_turnDirection == TURN_DIRECTION_FORWARD)
				{
					m.tx = _hCenter;
					m.ty = _pageTop;
				 	g.beginBitmapFill(_frontTurningBitmap,m,false,true);
				}
				else
				{
					m.tx = hPageEdge;
					m.ty = _pageTop;
					g.beginBitmapFill(_frontTurningBitmap,m,false,true);
				}


				drawPoly(g,topTurningPagePoly);
				g.endFill();
			}


			// draw the curvature gradient on the page being revealed by the turn
			if(_turnDirection == TURN_DIRECTION_FORWARD)
			{
				if(this.showPageSlope == true)
				{
					m.createGradientBox(_pageWidth,_pageHeight,0,_hCenter,_pageTop);
					beginRightSideGradient(g,m);
				}
			}
			else
			{
				if(this.showPageSlope == true)
				{
					m.createGradientBox(_pageWidth,_pageHeight,Math.PI,_pageLeft,_pageTop);
					beginLeftSideGradient(g,m);
				}
			}
			
			drawPoly(g,topTurningPagePoly);
			g.endFill();

			var centerToDrag:Vector2;
			var len:Number;

			if(dragToStart.length2 > .1)
			{
				// draw the shadow cast on the top pages by the turned page
				centerToDrag = new Vector2(dragToStartCenter,dragPt);
				m.identity();
				len = centerToDrag.length * 1.2
				if(len > 10)
				{
					m.scale(len/1638.4,50/1638.4);
					m.rotate(fold.angle + Math.PI);
					m.translate(dragToStartCenter.x + centerToDrag.x/2,dragToStartCenter.y + centerToDrag.y/2);
					
					// if(this.showPageSlope == true)
					{
						if(_turnDirection == TURN_DIRECTION_FORWARD)
							beginTopPageGradient(g,m);
						else
							beginTopPageGradient(g,m);
					}

					drawPoly(g,topTurningPagePoly);
					g.endFill();
				}

				// draw the shadow being cast onto the revealed page
				var centerToGrab:Vector2 = new Vector2(dragToStartCenter,grabPt);
				m.identity();
				var boxLen:Number = centerToGrab.length;

				if(boxLen > 1
					&& ((_turnDirection == TURN_DIRECTION_FORWARD && _backTurningPage.hasRightContent) ||
						(_turnDirection == TURN_DIRECTION_BACKWARDS && _backTurningPage.hasLeftContent))
				)
				{
					m.scale(boxLen/1638.4,50/1638.4);
					// if(this.showPageSlope == true)
					{
						if(_turnDirection == TURN_DIRECTION_FORWARD)
						{
							m.rotate(fold.angle);
							m.translate(dragToStartCenter.x + centerToGrab.x/2,dragToStartCenter.y + centerToGrab.y/2);
							beginShadowOnRevealedPage(g,m,turnPercent);
						}
						else
						{
							m.rotate(fold.angle);
							m.translate(dragToStartCenter.x + centerToGrab.x/2,dragToStartCenter.y + centerToGrab.y/2);
							beginShadowOnRevealedPage(g,m,turnPercent);
						}
					}
					drawPoly(g,revealedPagePoly);
					g.endFill();
				}

				if(_backTurningBitmap != null)
				{
					// draw the underside of the turned page
					m.identity();
					m.rotate(Math.atan2(leadingEdge.x,-leadingEdge.y));
					m.tx = virtualPageTopLeft.x;
					m.ty = virtualPageTopLeft.y;

					 g.beginBitmapFill(_backTurningBitmap,m,true,true);

					g.lineStyle(0,0,0);
					drawPoly(g,foldPoly);
					g.endFill();

					// draw the curvature gradient on the underside of the turned page
					centerToDrag = new Vector2(dragToStartCenter,dragPt);
					len = centerToDrag.length;
					if(len > 10)
					{
						m.identity();
						m.scale(len/1638.4,50/1638.4);
						m.rotate(fold.angle + Math.PI);
						m.translate(dragToStartCenter.x + centerToDrag.x/2,dragToStartCenter.y + centerToDrag.y/2);
						// if(this.showPageSlope == true)
						{
							if(_turnDirection == TURN_DIRECTION_FORWARD)
								beginForwardUndersideCurveGradient(g,m,turnPercent);
							else
								beginBackwardsUndersideCurveGradient(g,m,turnPercent);
						}
						drawPoly(g,foldPoly);
						g.endFill();
					}
				}

			}
		}

		private function drawPoly(g:Graphics,poly:Array):void
		{
			g.moveTo(poly[0].x,poly[0].y);
			for(var i:int = 0;i<poly.length;i++)
			{
				g.lineTo(poly[i].x,poly[i].y);
			}
			g.lineTo(poly[0].x,poly[0].y);
		}

//--------------------------------------------------------------------------------------------------------
// gradient/shadow helper functions
//-------------------------------------------------------------------------------------------------------

		private function beginTopPageGradient(g:Graphics,m:Matrix):void
		{
			g.beginGradientFill(GradientType.LINEAR,
				[0,0],
				[.9*shadowStrengthD,0.00],
				[0,131.61],
				m,SpreadMethod.PAD);
		}
		
		private function beginForwardUndersideCurveGradient(g:Graphics,m:Matrix,p:Number):void
		{
			var base:Number = curveShadowD;
			var v:Number = base + (pageSlopeD-base)*p;
			g.beginGradientFill(GradientType.LINEAR,
				[0xFFFFFF,0],
				[0.19*v,0],
				[0,65.80],
				m,SpreadMethod.PAD);
		}
		
		private function beginBackwardsUndersideCurveGradient(g:Graphics,m:Matrix,p:Number):void
		{
			var base:Number = curveShadowD;
			var v:Number = base + (pageSlopeD-base)*p;
			g.beginGradientFill(GradientType.LINEAR,
				[0,0xFFFFFF],
				[0.27*v,0],
				[0,86],
				m);
		}
		
		private function beginLeftSideGradient(g:Graphics,m:Matrix,isStiff:Boolean = false):void
		{
			g.beginGradientFill(GradientType.LINEAR,
				[0xFFFFFF,0],
				[(isStiff? 0.08:0.19)*pageSlopeD,0],
				[0,65.80],
				m,SpreadMethod.PAD);
		}
		
		private function beginRightSideGradient(g:Graphics,m:Matrix,isStiff:Boolean = false):void
		{
			g.beginGradientFill(GradientType.LINEAR,
				[0,0xFFFFFF],
				[((isStiff)? 0.08:0.27)*pageSlopeD,0],
				[0,86],
				m);
		}
		
		private function beginStiffShadowGradient(g:Graphics,m:Matrix):void
		{
			g.beginGradientFill(GradientType.LINEAR,
				[0,0],
				[2.4*shadowStrengthD,0],
				[0,255],
				m);
		}
		
		private function beginShadowOnRevealedPage(g:Graphics,m:Matrix,p:Number):void
		{
			g.beginGradientFill(GradientType.LINEAR,
				[0,0],
				[1.8*(1-p)*shadowStrengthD,0],
				[0,200],
				m);
		}

		public function canTurnBackward():Boolean
		{
			return (_state == STATE_NONE)? (_currentPageIndex > minimumPageIndex):
				(_state == STATE_TEASING)? (_targetPageIndex >= minimumPageIndex):
				(_targetPageIndex > minimumPageIndex);
		}
		
		public function canTurnForward():Boolean
		{
			return (_state == STATE_NONE)? (_currentPageIndex+1 < maximumPageIndex):
				(_state == STATE_TEASING)? (_targetPageIndex < maximumPageIndex):
				_targetPageIndex+1 < maximumPageIndex;
		}
	}
}
