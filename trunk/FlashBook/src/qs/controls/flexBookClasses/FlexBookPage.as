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
package qs.controls.flexBookClasses
{
	import controls.LockPageBox;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.TextSnapshot;
	
	import mx.controls.Alert;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import org.hamcrest.object.nullValue;

	public class FlexBookPage extends UIComponent
	{
		private var _leftRenderer:IFlexDisplayObject;
		private var _rightRenderer:IFlexDisplayObject;
		private var _allRenderer:IFlexDisplayObject;
		
		public var leftLockBox:LockPageBox = null;
		public var rightLockBox:LockPageBox = null;

		private var _side:String;
		private var _isStiff:Boolean = false;
		
		public var leftIsStiff:Boolean = false;
		public var rightIsStiff:Boolean = false;
		public var leftIndex:Number;
		public var rightIndex:Number;
		public var allIndex:Number;
		public var leftContent:*;
		public var rightContent:*;
		public var allContent:*;

		public var leftPage:Number;
		public var rightPage:Number;
		
		private var leftSnapText:TextSnapshot = null;
		private var rightSnapText:TextSnapshot = null;
		
		
		
		public function set isStiff(value:Boolean):void
		{
			_isStiff = value;
		}
		public function get isStiff():Boolean
		{
			return _isStiff;
		}

		public function set side(value:String):void
		{
			_side= value;
			invalidateProperties();
		}

		public function get side():String
		{
			return _side;
		}
		
		public function set leftRenderer(value:IFlexDisplayObject):void
		{
			if(value == _leftRenderer)
				return;

			if(_leftRenderer != null)
			{
				if(this.contains(DisplayObject(_leftRenderer)))
				{
					_leftRenderer.removeEventListener(FlexEvent.UPDATE_COMPLETE,updateCompleteHandler);
					removeChild(DisplayObject(_leftRenderer));
					leftLockBox = null;
					
				}
			}
			_leftRenderer = value;
			
			if(_leftRenderer != null)
			{
				_leftRenderer.addEventListener(FlexEvent.UPDATE_COMPLETE,updateCompleteHandler);
				addChild(DisplayObject(_leftRenderer));
			}
			invalidateDisplayList();
		}

		
		public function unlockLeftPage():void{
			if(_leftRenderer != null )
			{
				ImagePage(_leftRenderer).lpb.visible =false;
			}
		}
		
		public function unlockRightPage():void{
			if(_rightRenderer != null)
			{
				ImagePage(_rightRenderer).lpb.visible =false;
			}
		}
		

		
		public function unlockBookPage():void
		{
			unlockLeftPage();
			unlockRightPage();
		}
		public function get leftRenderer():IFlexDisplayObject
		{
			return _leftRenderer;
		}
		
		public function set rightRenderer(value:IFlexDisplayObject):void
		{
			
			if(value == _rightRenderer)
				return;

			if(_rightRenderer != null)
			{
				if(this.contains(DisplayObject(_rightRenderer)))
				{
					_rightRenderer.removeEventListener(FlexEvent.UPDATE_COMPLETE,updateCompleteHandler);
					removeChild(DisplayObject(_rightRenderer));
					rightLockBox = null;
				}
			}
			
			_rightRenderer = value;
			
			if(_rightRenderer != null)
			{
				_rightRenderer.addEventListener(FlexEvent.UPDATE_COMPLETE,updateCompleteHandler);
				addChild(DisplayObject(_rightRenderer));

				//trace("render......");
			}

			invalidateDisplayList();
		}
		
		public function get rightRenderer():IFlexDisplayObject
		{
			return _rightRenderer;
		}

		public function set allRenderer(value:IFlexDisplayObject):void
		{
			if(value == _allRenderer)
				return;

			if(_allRenderer != null)
			{
				_allRenderer.removeEventListener(FlexEvent.UPDATE_COMPLETE,updateCompleteHandler);
				removeChild(DisplayObject(_allRenderer));
			}
			_allRenderer = value;
			if(_allRenderer != null)
			{
				_allRenderer.addEventListener(FlexEvent.UPDATE_COMPLETE,updateCompleteHandler);
				addChild(DisplayObject(_allRenderer));
			}
			invalidateDisplayList();
		}
		
		public function get allRenderer():IFlexDisplayObject
		{
			return _allRenderer;
		}
		
		public function clearContent():void
		{
			leftRenderer = null;
			rightRenderer=  null;
			allRenderer = null;
			
		}

		public function get hasContent():Boolean
		{
			return (_leftRenderer != null || _rightRenderer != null || _allRenderer != null);
		}
		
		public function get hasLeftContent():Boolean
		{
			return (_leftRenderer != null || _allRenderer != null);
		}
		
		public function get hasRightContent():Boolean
		{
			return (_rightRenderer != null || _allRenderer != null);
		}
		private function onBookPageClick(e:MouseEvent):void{
			e.preventDefault();
			e.stopPropagation();

		}
		private function onLinkClick(e:TextEvent):void
		{
			e.stopPropagation();
			RunTime.linkInnerSwf = true;

			var t:Array = e.text.split("_");
			if(t.length > 1){
				var val:String = t[0].toString();
				if(val.indexOf("frame") == 0){
					var dest:int= Number(val.substr(5)) +1;
					//trace("goto " + dest);
					RunTime.mainPage.gotoPage(dest);
				}
				
			}
			else{
				flash.net.navigateToURL( new URLRequest(String(e.text)), "_blank");
			}
			
		}
		public function linkPage():void
		{
			
			
			
			var render:UIComponent = null;
			RunTime.linkInnerSwf = false;
			if(_rightRenderer != null ){
				render = UIComponent(_rightRenderer);
				if(ImagePage(render).imgPage !=null && 
					ImagePage(render).imgPage.content != null){
					if (ImagePage(render).imgPage.content is ComboLinkPage 
						&& ComboLinkPage(ImagePage(render).imgPage.content).cnt is MovieClip){
						var _content:MovieClip =  MovieClip(ComboLinkPage(ImagePage(render).imgPage.content).cnt );
						
						
						if(_content is MovieClip){
							_content.removeEventListener(MouseEvent.MOUSE_DOWN,onBookPageClick);
							_content.addEventListener(MouseEvent.MOUSE_DOWN,onBookPageClick);
							_content.addEventListener(TextEvent.LINK,onLinkClick);
							
							
						}
					}
				}
				
			}
			if(_leftRenderer != null){
				render = UIComponent(_leftRenderer);
				if(ImagePage(render).imgPage !=null && 
					ImagePage(render).imgPage.content != null){
					if (ImagePage(render).imgPage.content is ComboLinkPage 
						&& 
						ComboLinkPage(ImagePage(render).imgPage.content).cnt is MovieClip){
						var _content:MovieClip =  MovieClip(ComboLinkPage(ImagePage(render).imgPage.content).cnt );
						
						
						if(_content is MovieClip){
							_content.removeEventListener(MouseEvent.MOUSE_DOWN,onBookPageClick);
							_content.addEventListener(MouseEvent.MOUSE_DOWN,onBookPageClick);
							_content.addEventListener(TextEvent.LINK,onLinkClick);
						}
					}
				}
				
			}

		}
		
		public function searchResult():void
		{

			var render:UIComponent = null;

			if(_rightRenderer != null  && rightSnapText == null){
				render = UIComponent(_rightRenderer);
				if(ImagePage(render).imgPage !=null && ImagePage(render).imgPage.content != null && RunTime.searchString !=""){
					if (ImagePage(render).imgPage.content is ComboLinkPage 
						&& ComboLinkPage(ImagePage(render).imgPage.content).cnt is MovieClip){
						var _content:MovieClip =  MovieClip(ComboLinkPage(ImagePage(render).imgPage.content).cnt );
						
						if(_content is MovieClip){
							var snapText:TextSnapshot = MovieClip(_content).textSnapshot;
							var textPos:int = snapText.findText(0,RunTime.searchString,false);
							snapText.setSelected(0,snapText.charCount-1,false);
							//trace(snapText.getText(0,snapText.charCount-1));
							if(textPos != -1){
								do{
									snapText.setSelectColor(0xffff00);
									snapText.setSelected(textPos, textPos+RunTime.searchString.length,true);
									textPos = snapText.findText(textPos + RunTime.searchString.length,RunTime.searchString,false);
								}while(textPos != -1)
							}
							rightSnapText = snapText;

						}
					}
				}

			}
			if(_leftRenderer != null && leftSnapText == null){
				render = UIComponent(_leftRenderer);
				if(ImagePage(render).imgPage !=null && ImagePage(render).imgPage.content != null && RunTime.searchString !=""){
					if (ImagePage(render).imgPage.content is ComboLinkPage 
						&& 
						ComboLinkPage(ImagePage(render).imgPage.content).cnt is MovieClip){
						var _content:MovieClip =  MovieClip(ComboLinkPage(ImagePage(render).imgPage.content).cnt );
						
						
						if(_content is MovieClip){
							var snapText:TextSnapshot = MovieClip(_content).textSnapshot;
							var textPos:int = snapText.findText(0,RunTime.searchString,false);
							snapText.setSelected(0,snapText.charCount-1,false);
							//trace(snapText.getText(0,snapText.charCount-1));
							
							if(textPos != -1){
								do{
									snapText.setSelectColor(0xffff00);
									snapText.setSelected(textPos, textPos+RunTime.searchString.length,true);
									textPos = snapText.findText(textPos + RunTime.searchString.length,RunTime.searchString,false);
								}while(textPos != -1)
							}
							
							leftSnapText = snapText;
							//leftSnapText.getTextRunInfo(0,leftSnapText.charCount-1);
						}
					}
				}

			}

		}

		public function reSearch():void
		{
			//RunTime.searchString = "";
			leftSnapText = null;
			rightSnapText = null;
		}

		private function updateCompleteHandler(e:FlexEvent):void
		{
			dispatchEvent(new FlexEvent(e.type,e.bubbles,e.cancelable));
			linkPage();
			searchResult();
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			
			if(_allRenderer != null)
			{
				_allRenderer.move(0,0);
				_allRenderer.setActualSize(unscaledWidth, unscaledHeight);
				if(_allRenderer is UIComponent && UIComponent(_allRenderer).initialized == false)
					UIComponent(_allRenderer).initialized = true;

			}
			
			if(_leftRenderer != null)
			{
				_leftRenderer.move(0,0);
				//if(leftLockBox != null) leftLockBox.move(0,0);
				_leftRenderer.setActualSize(unscaledWidth/2,unscaledHeight);
				if(_leftRenderer is UIComponent && UIComponent(_leftRenderer).initialized == false)
					UIComponent(_leftRenderer).initialized = true;

			}
			
			if(_rightRenderer != null)
			{
				_rightRenderer.setActualSize(unscaledWidth/2,unscaledHeight);
				_rightRenderer.move(unscaledWidth/2,0);
				//if(rightLockBox != null) rightLockBox.move(unscaledWidth/2,0);
				if(_rightRenderer is UIComponent && UIComponent(_rightRenderer).initialized == false)
					UIComponent(_rightRenderer).initialized = true;
				
			}

			
			searchResult();
			
		}

		public function copyInto(bitmap:BitmapData,side:String):void
		{
		
			cacheAsBitmap = false;
			
			validateNow();
			if(_allRenderer is UIComponent)
				UIComponent(_allRenderer).validateNow();
			if(_leftRenderer is UIComponent)
				UIComponent(_leftRenderer).validateNow();
			if(_rightRenderer is UIComponent)
				UIComponent(_rightRenderer).validateNow();

			var m:Matrix = new Matrix();
			var rc:Rectangle;
			if(side == "left")
			{
				if(bitmap.width < unscaledWidth)
				{
//					m.translate(unscaledWidth/2,0);
					var x:int = 0;
				}
				bitmap.draw(this,m,null,null,new Rectangle(0,0,unscaledWidth/2,unscaledHeight));

			}
			else if (side == "right")
			{
				// FIXME Bad drawing
				if(bitmap.width < unscaledWidth)
				{
					m.translate(-unscaledWidth/2,0);
					rc = new Rectangle(0,0,unscaledWidth/2,unscaledHeight)
				}
				else
				{
					rc = new Rectangle(unscaledWidth/2,0,unscaledWidth/2,unscaledHeight)
				}
				bitmap.draw(this,m,null,null,rc);
			}
			else
			{
				bitmap.draw(this);
			}

			cacheAsBitmap = true;

		}
	}
}