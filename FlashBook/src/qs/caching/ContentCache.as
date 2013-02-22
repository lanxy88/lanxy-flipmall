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
package qs.caching
{
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.SecurityDomain;
import flash.utils.Dictionary;

import mx.controls.Image;

import qs.utils.DLinkedList;
import qs.utils.DLinkedListNode;

public class ContentCache
{
	static private var caches:Dictionary;
	static private var defaultCache:ContentCache;

	private var _caches:Dictionary;
	private var _mruList:DLinkedList;
	private var _maximumSize:Number = 200;

	static public function getCache(name:String = null):ContentCache
	{
		if (name == "" || name == null)
		{
			if(defaultCache == null)
				defaultCache = new ContentCache();
				return defaultCache;
		}
		if(caches == null)
			caches = new Dictionary();
		if(name in caches)
			return caches[name];
		var cache:ContentCache = new ContentCache();
		caches[name] = cache;
		return cache;
	}	
	
	public function get maximumSize():Number
	{
		return _maximumSize;
	}
	
	public function set maximumSize(value:Number):void
	{
		_maximumSize = value;
		checkLimit();
	}
	
	public function ContentCache():void
	{
		_caches = new Dictionary();
		_mruList = new DLinkedList();
	}
	
	public function clear():void
	{
		_caches = new Dictionary();
		_mruList = new DLinkedList();
	}
	
	public function hasContent(value:*):Boolean
	{
		var request:URLRequest;
		var url:String;
		var cachedNode:ContentCacheNode;
		
		if(value is String)
		{
			url = value;
		}
		else if (value is URLRequest)
		{
			request = value;
			url = request.url;
		}

		
		
		cachedNode = _caches[url];
		return (cachedNode != null && cachedNode.value.length > 0);
	}
	
	public function preloadContent(value:*):void
	{
		getContent(value);
	}

	public function getContent(value:*):DisplayObject
	{
		var request:URLRequest;
		var url:String;
		var cachedItems:Array;
		var cachedNode:ContentCacheNode;
		var cachedItem:DisplayObject;

		if(value is String)
		{
			url = value;
			request = new URLRequest(url);
		}
		else if (value is URLRequest)
		{
			request = value;
			url = request.url;
		}
		
		//xace("*** Checking Cache for " + url);		
		var result:DisplayObject;
		var loader:Loader;
		var bitmap:Bitmap;
		
		cachedNode = _caches[url];
		if(cachedNode == null)
		{
			_caches[url] = cachedNode = new ContentCacheNode(url);
			_mruList.unshift(cachedNode);
		}
		else
		{
			_mruList.remove(cachedNode);
			_mruList.unshift(cachedNode);
		}
		
		cachedItems = cachedNode.value;
		
		for(var i:int = 0;i<cachedItems.length;i++)
		{
			cachedItem = cachedItems[i];

			if (cachedItem.parent == null)
			{
				result = cachedItem;		
				break;
			}
			else
			{
				if(bitmap == null && cachedItem is Bitmap)
				{
					bitmap = Bitmap(cachedItem);
				}
				if(loader == null && cachedItem is Loader)
				{
					loader = Loader(cachedItem);
				}
			}
		}
		
		if(result == null)
		{
			if (bitmap != null)
			{
				result = new Bitmap(bitmap.bitmapData,bitmap.pixelSnapping,bitmap.smoothing);
				cachedItems.push(result);
			}
			else if (loader != null && loader.contentLoaderInfo.childAllowsParent && loader.content is Bitmap)
			{
				bitmap = Bitmap(loader.content);
				result = new Bitmap(bitmap.bitmapData,bitmap.pixelSnapping,bitmap.smoothing);
				cachedItems.push(bitmap);
			}
			
			if (result == null)
			{
				var context:LoaderContext = new LoaderContext();
				context.applicationDomain = new ApplicationDomain();    //这个是关键
				context.checkPolicyFile = true;
				context.securityDomain = SecurityDomain.currentDomain;
				
				//xace("\t not in cache or inaccessible: creating new Loader");
				loader = new Loader();
				loader.load(request);
				cachedItems.push(loader);
				result = loader;
			}
		}
		checkLimit();
		
		return result;		
	}

	private function checkLimit():void
	{
		if(_maximumSize <= 0 || _mruList.length <= _maximumSize)
			return;
		//xace("dropping " + (_mruList.length - _maximumSize) + " items");
		for(var i:int = _mruList.length;i>_maximumSize;i--)
		{
			var node:ContentCacheNode = ContentCacheNode(_mruList.pop());
			delete _caches[node.url];
		}
	}
}
}

import qs.utils.DLinkedListNode;
	

class ContentCacheNode extends DLinkedListNode
{
	public var url:String;
	public function ContentCacheNode(url:String):void
	{
		super([]);
		this.url = url;
	}	
}
