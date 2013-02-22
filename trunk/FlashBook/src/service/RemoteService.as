/**
 * @author xiaotie@geblab.com 
 */

package service
{
	import common.BookMarkRecord;
	import common.HighlightRecord;
	import common.NoteRecord;
	import common.RpcRequest;
	
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	
	import mx.utils.StringUtil;
	
	import utils.Base64;
	import utils.Helper;
	
	public class RemoteService extends BaseService implements IService
	{
		public var userId:String = "10";
		private var eUserId:String = "";
		//public var userId:String = "yjLwSUbBrbeWTGQ9s_TwisJ22uIZQMWrlUBRKdSZ_SRBqUTdb07kchyRjCWSyOHn_zlJ4pG1hQp6Hmk3mjVnOw2";
		
		private var url:String;
		
		private function get title():String
		{
			return "2";
			// return RunTime.bookId;
		}
		
		private function onFail(e:*):void
		{
			
		}
		
		private function emptyCallback(obj:Object):void
		{
		}
		
		private function getStr(obj:Object):String
		{
			var xml:XML = new XML(obj);
			return StringUtil.trim(xml.toString());
		}
		
		private function encode(val:String):String
		{
			return val;
		}
		
		private function decode(val:String):String
		{
			return val;
		}
		
		private function encodeWithDate(val:String, data:Date):String
		{
			return data.toString() + "__DATE__" + val;
		}
		
		private function decodeWithDate(val:String):Object
		{
			var date:Date = new Date();
			var content:String = "";
			var index:int = val.indexOf("__DATE__");
			if(index > 0)
			{
				content = val.substr(index + 8);
				date = new Date(Date.parse(val.substr(0,index)));
			}
			
			var obj:Object = { date:date, content:content };
			return obj;
		}
		
		public override function loadLocalData():void
		{
		}
		
		public override function init(callback:Function):void
		{
			userId = ExternalInterface.call("getFlashBookUserId");
			eUserId = userId;
			if(callback != null) callback();
		}
		
		public function RemoteService(url:String)
		{
			this.url = url;
		}
		
		public override function requestBookMarks():void
		{
			new RpcRequest(url + "getbookmarks", 
				{
					userid: eUserId,
					booktitle: title,
					page:-1
				}, 
				function(obj:Object):void
				{
					var xml:XML = new XML(obj);
					var bookmarks:Array = [];
					for each(var node:XML in xml..bookmark)
					{
						var item:BookMarkRecord = new BookMarkRecord("",0,0,0,true);
						item.guid = node.id;
						item.page = node.page;
						item.y = node.y;
						item.bgColor = Helper.parseColor(node.color);
						item.content = decode(node.content);
						bookmarks.push(item);
					}
					RunTime.bookmarkRecords = bookmarks;
					RunTime.cfgFileLoadedCount++;
					RunTime.mainPage.updateProloadInfo();
				},
				function(e:*):void
				{
					RunTime.cfgFileLoadedCount++;
					RunTime.mainPage.updateProloadInfo();
				}
			);
		}
		
		public override function createBookMark(item:BookMarkRecord):void
		{
			new RpcRequest(url + "createbookmark", 
				{
					userid: eUserId,
					booktitle: title,
					y:item.y.toString(),
					color:item.bgColorStr,
					page:item.page.toString(),
					content:encode(item.content)
				}, 
				function(obj:Object):void
				{
					item.guid = getStr(obj);
				},
				onFail);
		}
		
		public override function updateBookMark(item:BookMarkRecord):void
		{
			new RpcRequest(url + "updatebookmark", 
				{
					userid: eUserId,
					id:item.guid,
					y:item.y.toString(),
					color:item.bgColorStr,
					page:item.page.toString(),
					content:encode(item.content)
				}, 
				emptyCallback,
				onFail);
		}
		
		public override function deleteBookMark(item:BookMarkRecord):void
		{
			new RpcRequest(url + "deletebookmark", 
				{
					userid: eUserId,
					id:item.guid
				}, 
				emptyCallback,
				onFail);
		}

		public override function requestNotes():void
		{
			new RpcRequest(url + "getnotes", 
				{
					userid: eUserId,
					booktitle: title,
					page:-1
				}, 
				function(obj:Object):void
				{
					var xml:XML = new XML(obj);
					var notes:Array = [];
					for each(var node:XML in xml..note)
					{
						var item:NoteRecord = new NoteRecord("",0,0,0,true,new Date());
						item.guid = node.id;
						item.page = node.page;
						item.xPos = node.x/10000.0;
						item.yPos = node.y/10000.0;
						var obj:Object = decodeWithDate(node.content);
						item.content = obj.content;
						item.time = obj.date;
						notes.push(item);
					}
					RunTime.noteRecords = notes;
					RunTime.cfgFileLoadedCount++;
					RunTime.mainPage.updateProloadInfo();
				},
				function(e:*):void
				{
					RunTime.cfgFileLoadedCount++;
					RunTime.mainPage.updateProloadInfo();
				}
			);
		}
		
		public override function createNote(item:NoteRecord):void
		{
			new RpcRequest(url + "createnote", 
				{
					userid: eUserId,
					booktitle: title,
					x:int(item.xPos * 10000).toString(),
					y:int(item.yPos * 10000).toString(),
					page:item.page.toString(),
					content:encodeWithDate(item.content, item.time)
				}, 
				function(obj:Object):void
				{
					item.guid = getStr(obj);
				},
				onFail);
		}
		
		public override function updateNote(item:NoteRecord):void
		{
			new RpcRequest(url + "updatenote", 
				{
					userid: eUserId,
					id:item.guid,
					x:int(item.xPos * 10000).toString(),
					y:int(item.yPos * 10000).toString(),
					page:item.page.toString(),
					content:encodeWithDate(item.content, item.time)
				}, 
				emptyCallback,
				onFail);
		}
		
		public override function deleteNote(item:NoteRecord):void
		{
			new RpcRequest(url + "deletenote", 
				{
					userid: eUserId,
					id:item.guid
				}, 
				emptyCallback,
				onFail);
		}
		
		public override function requestHighlights():void
		{
			new RpcRequest(url + "gethighlights", 
				{
					userid: eUserId,
					booktitle: title,
					page:-1
				}, 
				function(obj:Object):void
				{
					var xml:XML = new XML(obj);
					var highlights:Array = [];
					for each(var node:XML in xml..highlight)
					{
						var item:HighlightRecord = new HighlightRecord("",0,0,0,true,new Date());
						item.guid = node.id;
						item.page = node.page;
						item.xPos = node.x/10000.0;
						item.yPos = node.y/10000.0;
						item.destXPos = node.width/10000.0 + item.xPos;
						item.destYPos = node.height/10000.0 + item.yPos;
						item.highlightColor = Helper.parseColor(node.color);
						var obj:Object = decodeWithDate(node.content);
						item.content = obj.content;
						item.time = obj.date;
						highlights.push(item);
					}
					RunTime.highlightRecords = highlights;
					RunTime.cfgFileLoadedCount++;
					RunTime.mainPage.updateProloadInfo();
				},
				function(e:*):void
				{
					RunTime.cfgFileLoadedCount++;
					RunTime.mainPage.updateProloadInfo();
				}
			);
		}
		
		public override function createHighlight(item:HighlightRecord):void
		{
			item.guid = "__unsaved__" + item.guid; 
				
			new RpcRequest(url + "createhighlight", 
				{
					userid: eUserId,
					booktitle: title,
					x:int(item.xPos * 10000).toString(),
					y:int(item.yPos * 10000).toString(),
					width:int(item.destXPos*10000 - item.xPos*10000).toString(),
					height:int(item.destYPos*10000 - item.yPos*10000).toString(),
					color:item.bgColorStr,
					page:item.page.toString(),
					content:encodeWithDate(item.content, item.time)
				}, 
				function(obj:Object):void
				{
					item.guid = getStr(obj);
					if(item.changed == true)
					{
						item.changed = false;
						updateHighlight(item);
					}
				},
				onFail);
		}
		
		public override function updateHighlight(item:HighlightRecord):void
		{
			if(item.guid.indexOf("__unsaved__") == 0)
			{
				item.changed = true;
			}
			else
			{
				new RpcRequest(url + "updatehighlight", 
					{
						userid: eUserId,
						id:item.guid,
						x:int(item.xPos * 10000).toString(),
						y:int(item.yPos * 10000).toString(),
						width:int(item.destXPos*10000 - item.xPos*10000).toString(),
						height:int(item.destYPos*10000 - item.yPos*10000).toString(),
						color:item.bgColorStr,
						page:item.page.toString(),
						content:encodeWithDate(item.content, item.time)
					}, 
					emptyCallback,
					onFail);
			}
		}
		
		public override function deleteHighlight(item:HighlightRecord):void
		{
			new RpcRequest(url + "deletehighlight", 
				{
					userid: eUserId,
					id:item.guid
				}, 
				emptyCallback,
				onFail);
		}		
	}
}