package orc.utils;

import haxe.Http;
import js.Dom;
import js.Lib;
import core.SearchResult;

class Util 
{
	public static function request(url:String, call:String -> Void, onError:Void->Void = null):Void
	{
		var http:Http = new Http(url);
		http.onData = call;
		http.onError = function(e:Dynamic):Void
		{
			if (onError != null)
			{
				onError();
			}
		};
		http.request(false);
		
	}
	
	public static function getUrlParam(key:String):String
	{
		var params:Array <UrlParam> = getUrlParams();
		for (param in params)
		{
			var p:UrlParam = param;
			if (p.key == key)
			{
				return p.value;
			}
		}
		return "";
	}
	
	public static function getUrlParams():Array<UrlParam>
	{
		var url:String = Lib.window.location.href;
		var results:Array <UrlParam> = new Array <UrlParam> ();
		var index:Int = url.indexOf("?");
		if (index > 0)
		{
			var params:String = url.substr(index + 1);
			var lines:Array<String> = params.split("&");
			for (line in lines)
			{
				var terms:Array<String> = line.split("=");
				if (terms.length == 2)
				{
					var val:UrlParam = new UrlParam();
					val.key = terms[0];
					val.value = terms[1];
					results.push(val);
				}
			}
		}
		return results;
	}
	
	public static function getXmlChilds(xml:Xml):Array<Xml>
	{
		var i:Iterator<Xml> = xml.elements();
		var list:Array<Xml> = new Array<Xml>();
		while (i.hasNext() == true)
		{
			var node:Xml = i.next();
			list.push(node);
		}
		return list;
	}
	
	public static function searchPos(txt:String, keyword:String):Array<Int>
	{
		var list:Array<Int> = [];
		var index:Int = -1;
		while(true)
		{
			var from:Int = 0;
			if(index != -1)
			{
				from = index + keyword.length;
				if (from < 0) from = 0;
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

	public static function createSearchResults(txt:String, keyword:String, posList:Array<Int>, page:Int):Array<Dynamic>
	{
		var results:Array<Dynamic> = [];
		var maxChars:Int = 50;
		var coloredWord:String = "<font color='#FF0000'>" + keyword + "</font>";
		for (i in 0 ... posList.length)
		{
			var index:Int = posList[i];
			var r:SearchResult = new SearchResult("",page);
			var offset:Int = index;
			if(txt.length < maxChars)
			{
				r.content = txt;
			}
			else
			{
				var from:Int = Std.int(index - Math.max(0, (maxChars - keyword.length)) / 2);
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
}