package utils
{
	import com.google.analytics.debug.Label;
	
	import common.BookPage;
	import common.SearchResult;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.containers.Canvas;
	import mx.containers.Panel;
	import mx.containers.VBox;
	import mx.controls.Image;
	import mx.controls.SWFLoader;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.effects.Fade;
	import mx.effects.Resize;
	import mx.printing.FlexPrintJob;
	import mx.printing.FlexPrintJobScaleType;
	
	import org.alivepdf.images.ImageFormat;
	import org.alivepdf.layout.Orientation;
	import org.alivepdf.layout.Size;
	import org.alivepdf.pages.Page;
	import org.alivepdf.pdf.PDF;
	import org.alivepdf.saving.Method;
	
	public class Helper
	{
		public static function bringTop(obj:DisplayObject):void
		{
			if(obj == null || obj.parent == null || obj.parent.numChildren < 2) return;
			
			obj.parent.setChildIndex(obj,obj.parent.numChildren - 1);
		}
		
		public static function ensureTop(top:DisplayObject, bottom:DisplayObject):void
		{
			if(top == null || bottom == null || top.parent == null || bottom.parent == null || top.parent != bottom.parent) return;
			var c:DisplayObjectContainer = top.parent;
			if(top.parent.contains(bottom) && c.getChildIndex(top) < c.getChildIndex(bottom))
			{
				try
				{
					c.removeChild(bottom);
					c.addChildAt(bottom,c.getChildIndex(top));
				}
				catch(e:*)
				{
				}
			}
		}
		
		public static function bringBottom(obj:DisplayObject):void
		{
			if(obj == null || obj.parent == null || obj.parent.numChildren < 2) return;
			
			obj.parent.setChildIndex(obj,0);
		}
		
		public static function copy(src:Object,dst:Object,props:Array):void
		{
			if(src == null || dst == null || props == null || props.length == 0) return;
			for each(var key:String in props)
			{
				dst[key] = src[key];
			}
		}
		
		public static function setVisibleWithFade(obj:DisplayObject, visible:Boolean):void
		{
			if(!RunTime.autoHideOnFullScreen){
				visible = true;
			}
			if(obj == null || obj.visible == visible) return;
			obj.visible = visible;
			if(obj.visible == true)
			{
				var fadeIn:Fade = new Fade(obj);
				fadeIn.duration = 200;
				fadeIn.alphaFrom = 0;
				fadeIn.alphaTo = 1;
				fadeIn.play();
			}
			else
			{
				var fadeOut:Fade = new Fade(obj);
				fadeOut.duration = 200;
				fadeOut.alphaFrom = 1;
				fadeOut.alphaTo = 0;
				fadeOut.play();
			}
		}
		
		public static function load(url:String, success:Function):URLLoader
		{
			var req:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, 
				function(event:Event):void
				{
					if(success != null)
						success(event.target);
				}
			);
			loader.load(req);
			return loader;
		}
		
		
		public static function loadList(list:Array, success:Function):void
		{
			var results:Array = [];
			var index:int = 0;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, 
				function(event:Event):void
				{
					results.push(event.target);
					if(success != null)
					{
						if(index == list.length)
						{
							success(event.target);
						}
					}
				}
			);
			
			for each(var url:String in list)
			{
				index ++;
				loader.load(new URLRequest(url));
			}
		}
		
		public static function parseColor(value:*):uint
		{
			var string:String = value.toString();
			
			if ( string.charAt(0) == '#' )
				string = string.split('#').join('0x');
			else if(string.indexOf("0x") != 0)
				string = "0x" + string;
			
			return parseInt(string);
		}
		
		public static function toColorStr(value:uint):String
		{
			var val:String = value.toString(16);
			if(val.length == 8) val = val.substr(2);
			return val;
		}
		
		public static function search(xml:XML, 
									  keyword:String, 
									  matchCase:Boolean = false, 
									  minPage:int = 1,
									  maxPage:int = 10000,
									  max:int = 100):Array
		{
			if(!keyword || xml == null) return [];
			
			var searchKey:String = keyword;
			
			if(matchCase == false) searchKey = keyword.toLocaleLowerCase();
			var rex0 :RegExp =/\s+/g; //空格
			var rex1 : RegExp = /[\r|\n]+/g; //换行
			var results:Array = [];
			for each(var item:XML in xml.page)
			{
				if(results.length >= max) break;
				
				var page:int = int(item.@pageNumber);
				if(page < minPage || page > maxPage) continue;// break;
				
				var txt:String = XML(item.text).text();
				txt = txt.replace(rex0," ");
				txt = txt.replace(rex1," ");
				var searchText:String = txt;
				if(matchCase == false) searchText = txt.toLocaleLowerCase();
				var list:Array = searchPos(searchText,searchKey);
				results = results.concat(creastSearchResults(txt,keyword,list,page));
			}
			return results.slice(0,max);
		}
		
		private static function creastSearchResults(txt:String, keyword:String, posList:Array, page:int):Array
		{
			var results:Array = [];
			const maxChars:int = 50;
			var coloredWord:String = "<font color='#FF0000'>" + keyword + "</font>";
			for each(var index:int in posList)
			{
				var r:SearchResult = new SearchResult("",page);
				var offset:int = index;
				if(txt.length < maxChars)
				{
					r.content = txt;
				}
				else
				{
					var from:int = index - Math.max(0,(maxChars - keyword.length))/2;
					if(from < 0) from = 0;
					r.content = txt.substr(from,maxChars);
					offset = index - from;
					
					if(from + maxChars < txt.length)
					{
						r.content += " ...";
					}
					
					if(from > 0)
					{
						r.content = "... " + r.content;
						offset += 4;
					}
				}
				
				r.content = r.content.substr(0,offset) + "<font color='#FF0000'>" + r.content.substr(offset,keyword.length) + "</font>" + r.content.substr(offset + keyword.length);
				
				results.push(r);
			}
			return results;
		}
		
		private static function searchPos(txt:String, keyword:String):Array
		{
			var list:Array = [];
			var index:int = -1;
			while(true)
			{
				var from:int = 0;
				if(index != -1)
				{
					from = Math.max(0,index + keyword.length);
				}
				
				index = txt.indexOf(keyword, from);
				if(index > -1 && index + keyword.length <= txt.length)
				{
					list.push(index);
				}
				else
				{
					break;
				}
			}
			return list;
		}
		
		public static function printPages(pages:Array, 
										  continueFunc:Function = null,
										  successCallback:Function = null,
										  cancelCallback:Function = null):void
		{
			if(pages == null || pages.length == 0) return;
			
			var successCount:int = 0;
			var failCount:int = 0;
			
			var loaders:Array = [];
			
			var okLoaders:Array = [];
			
			var printImages:Function = function():void
			{
				if(loaders.length == 0) return;
				
				if(continueFunc != null && continueFunc() == false) return;
				
				var printList:Array = [];
				for each(var item:Loader in loaders)
				{
					for each(var okItem:Object in okLoaders)
					{
						if(item.contentLoaderInfo == LoaderInfo(okItem.v))
						{
							printList.push(okItem);
							break;
						}
					}
				}
				
				if(printList.length == 0) return;
				
				var sprite:Sprite = new Sprite();				
				var job:PrintJob = new PrintJob();
				
				if(job.start() == true)
				{
					/**
					 * 加入stage否则无法再新版chrome下打印
					 * */
					Application.application.stage.addChild(sprite);
					
					var pageWidth:Number = job.pageWidth;
					var pageHeight:Number = job.pageHeight;
					
					for each(var info:Object in printList)
					{
						var width:Number = LoaderInfo(info.v).content.width;
						var height:Number = LoaderInfo(info.v).content.height;
						var wScale:Number = pageWidth / width;
						var hScale:Number = pageHeight / height;
						var scale:Number = Math.min(wScale,hScale);
						LoaderInfo(info.v).content.scaleX = scale;
						LoaderInfo(info.v).content.scaleY = scale;
						
						if(RunTime.unlockPage){
							sprite.addChild(LoaderInfo(info.v).content);
						}
						else{
							//试图导出受保护的页
							if(RunTime.protectedPages.indexOf(String(info.k)) != -1){
								var errMsg:Label = new Label();
								errMsg.text ="This page is protected.";
								errMsg.width = 300;
								errMsg.height = 50;
								
								//pdf.addText("This page is protected.",100,100);
								sprite.addChild(errMsg);
							}
							else{
								sprite.addChild(LoaderInfo(info.v).content);
							}
						}
						
						/****/
						//
						
						//
						job.addPage(sprite, new Rectangle((width*scale - pageWidth)/2, (height*scale - pageHeight)/2,pageWidth,pageHeight));
						sprite.removeChildAt(0);
						//sprite.removeChild(LoaderInfo(info.v).content);
						
					}
					job.send();
					if(successCallback != null) successCallback();
					Application.application.stage.removeChild(sprite);
				}
				else
				{
					if(cancelCallback != null) cancelCallback();
				}
			};
			
			var success:Function = function(img:LoaderInfo,tag:Object):void
			{
				if(continueFunc != null && continueFunc() == false) return;
				
				successCount ++;
				okLoaders.push({k:tag,v:img});
				
				if(successCount + failCount == pages.length) printImages();
			};
			
			var fail:Function = function(img:LoaderInfo):void
			{
				if(continueFunc != null && continueFunc() == false) return;
				
				failCount ++;
				
				if(successCount + failCount == pages.length) printImages();
			};
			
			for each(var item:BookPage in pages)
			{
				loaders.push(loadImage(item.source,success,fail,item.pageId));
			}
		}
		
		public static function loadImage(url:String,callback:Function, errorCallback:Function, tag:Object = null):Loader
		{
			var loader:Loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,
				function(event:Event):void
				{
					if(callback != null) 
						callback(loader.contentLoaderInfo,tag);
				}
			);
			
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, 
				function(event:*):void
				{
					if(errorCallback != null) errorCallback(loader.contentLoaderInfo);
				}
			);
			
			loader.load(new URLRequest(url));
			
			return loader;
		}
		
		public static function savePdf(obj:DisplayObject, pageStr:String, prefix:String = ""):void
		{
			if(!prefix) prefix = "";
			var autoSize:Size = new Size([obj.height,obj.width],"Tabloid",[11, 17],[279, 432]);
			var pdf:PDF = new PDF(Orientation.LANDSCAPE, "Mm", autoSize);
			pdf.setLeftMargin(0);
			pdf.setRightMargin(0);
			pdf.setTopMargin(0);
			pdf.setBottomMargin(0);
			pdf.setDisplayMode();
			pdf.addPage();
			pdf.addImage(obj,null,0,0,0,0,0,1,true,ImageFormat.JPG,RunTime.exportPdfQuality);
			var bytes:ByteArray = pdf.save( Method.LOCAL );
			var f:FileReference = new FileReference();
			f.save(bytes, prefix + "_" + pageStr + ".pdf");
		}
		
		public static function savePages(pages:Array,callback:Function = null):void
		{
			if(pages == null || pages.length == 0) return;
			
			var successCount:int = 0;
			var failCount:int = 0;
			
			var imgs:Array = [];
			
			var printImages:Function = function():void
			{
				if(imgs.length == 0) return;
				
				
				imgs.sort(function(a:Object,b:Object):int
				{
					var aa:int = int(a.k);
					var bb:int = int(b.k);
					return aa < bb ? -1 : aa > bb ? 1 : 0;
				});
				
				var autoSize:Size = new Size([RunTime.pageHeight,RunTime.pageWidth],"Tabloid",[11, 17],[279, 432]);
				var pdf:PDF = new PDF(Orientation.LANDSCAPE, "Mm", autoSize);
				
				pdf.setLeftMargin(0);
				pdf.setRightMargin(0);
				pdf.setTopMargin(0);
				pdf.setBottomMargin(0);
				pdf.setDisplayMode();
				
				for each(var item:Object in imgs)
				{
					pdf.addPage();
					//已解锁
					if(RunTime.unlockPage){
						pdf.addImage(LoaderInfo(item.v).content);
					}
					else{
						//试图导出受保护的页
						if(RunTime.protectedPages.indexOf(String(item.k)) != -1){
							//var errMsg:Label = new Label();
							//errMsg.text ="this page protected.";
							//errMsg.width = 300;
							//errMsg.height = 50;
							
							pdf.addText("This page is protected.",100,100);
						}
						else{
							pdf.addImage(LoaderInfo(item.v).content);
						}
					}
					
					//trace("pdf.....");
				}
				
				//RunTime.pdfPages =  pdf;
				
				if(callback != null) callback(pdf);
				/*
				var bytes:ByteArray = pdf.save( Method.LOCAL );
				var f:FileReference = new FileReference();
				//trace("save....");
				f.save(bytes, "output.pdf");
				*/
			};
			
			var success:Function = function(img:LoaderInfo,tag:Object):void
			{
				successCount ++;
				imgs.push({k:tag,v:img});
				
				if(successCount + failCount == pages.length) printImages();
			};
			
			var fail:Function = function(img:LoaderInfo):void
			{
				failCount ++;
				
				if(successCount + failCount == pages.length) printImages();
			};
			
			
			for each(var item:BookPage in pages)
			{
				loadImage(item.source,success,fail,item.pageId);
			}
		}
		
		public static function download(url:String):void
		{
//			var fi:FileReference = new FileReference();
//			fi.download(new URLRequest(url));
			flash.net.navigateToURL(new URLRequest(url));
		}
		
		public static function createLanguageDataSource(xml:XML, lang:l):Array
		{
			var array :Array = [];
			for each(var item:XML in xml.language)
			{
				array.push(lang.s(String(item.@content)));
			}
			return array;
		}
		
		public static function drawReflection(
			dst:Sprite, 
			src:Sprite,
			reflectHeightPercent:Number = 0.6) : void
		{
			if(src.visible == false) return;
			
			var h:Number = rect.height * reflectHeightPercent;
			var mat:Matrix = new Matrix();
			var rect:Rectangle = new Rectangle(0,0,src.width,src.height);
			mat.createGradientBox(rect.width, h, Math.PI / 2, 0, 0);
			var s:Sprite = new Sprite();
			s.graphics.beginGradientFill(GradientType.LINEAR, [3355443, 3355443], [0.6, 0.01], [0, 255], mat);
			s.graphics.drawRect(0, 0, rect.width, h);
			s.cacheAsBitmap = true;
			var bmpData:BitmapData = new BitmapData(rect.width, h, true, 0);
			bmpData.draw(src, new Matrix(src.scaleX, 0, 0, -src.scaleY, 0, rect.height));
			var bmp:Bitmap = new Bitmap(bmpData);
			bmp.y = 0.5;
			bmp.cacheAsBitmap = true;
			bmp.mask = s;
			var tmp:UIComponent = new UIComponent();
			tmp.addChild(bmp);
			tmp.addChild(s);
			dst.addChild(tmp);
		}
		
		public static function drawShadow(	g:Graphics,
										  	rect:Rectangle, 
											colors:Array,
											alphas:Array,
											ratios:Array
											) : void
		{
			g.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios);
			g.drawRect(0, 0, rect.width, rect.height);
			g.endFill();
		}
		
		public static function buildUrlHref(url:String):String
		{
			return "<font color='#0066ee'><u><a href='" + url + "' target='_black'>"+url+"</a></u></font>" 
		}
		
		public static function buildEmailHref(email:String):String
		{
			return "<font color='#0066ee'><u><a href='mailto:" + email + "' target='_self'>"+email+"</a></u></font>"
		}
		
		public static function buildBoldText(txt:String):String
		{
			if(!txt) return "";
			else return "<b>" + txt + "</b>";
		}
		
		public static function buildAboutUsHtmlText(lang:l, bookConfig:XML):String
		{
			if(bookConfig == null) return "";
			
			var txt:String = "";
			var space:String = "<br /><br />";
			
			if(String(bookConfig.@title))
			{
				txt += lang.s('BookTitle','Book Title') + ': ' 
					+ Helper.buildBoldText(bookConfig.@title);
				txt += space;
			}
			
			if(String(bookConfig.@author))
			{
				txt += lang.s('BookAuthor','Book Author') + ': '
					+ Helper.buildBoldText(bookConfig.@author)
				txt += space;
			}
			
			if(String(bookConfig.@companyName))
			{
				txt += lang.s('CompanyName','Company Name') + ': ' 
					+ Helper.buildBoldText(bookConfig.@companyName)
				txt += space;
			}
			
			if(String(bookConfig.@companyUrl))
			{
				txt += lang.s('CompanyUrl','Company Url') + ': ' 
					+ Helper.buildBoldText(Helper.buildUrlHref(bookConfig.@companyUrl))
				txt += space;
			}
			
			if(String(bookConfig.@companyAddress))
			{
				txt += lang.s('CompanyAddress','Address') + ': ' 
					+ Helper.buildBoldText(bookConfig.@companyAddress)
				txt += space;
			}
			
			if(String(bookConfig.@email))
			{
				txt += lang.s('CompanyEmail','Email') + ': '
					+ Helper.buildBoldText(Helper.buildEmailHref(bookConfig.@email)) 
				txt += space;
			}
			
			if(String(bookConfig.@tel))
			{
				txt += lang.s('CompanyTel','Tel') + ': '
					+ Helper.buildBoldText(bookConfig.@tel)
				txt += space;
			}
			
			return txt;
		}
	}
}