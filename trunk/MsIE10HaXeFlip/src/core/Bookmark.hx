package core;
import js.Lib;

/**
 * 书签
 * @author kylefly
 */

class Bookmark 
{
	public var pageNum:Int;
	public var text:String;
	public var guid:String;
	public var onlyread:Bool = false;
	private var bookmarkImg:Image;
	private var bookImgLoaded:Bool;
		
	public function new() 
	{
		bookmarkImg = untyped Lib.document.createElement("img");		
		bookmarkImg.onload = function():Void {
			//Lib.alert("loaded");
			bookImgLoaded = true;
		};
		bookmarkImg.src = RunTime.urlRoot + "content/images/bookmark.png";
	}
	
	private function toJSONString():String {
		var json:String = '{"obj":[{"pageNum":"' + this.pageNum + 
							'","text":"' + this.text + '"}]}';
		return json;
	}
	public function save():Void {
		guid = RunTime.kvPrex + "@$bm$@" + Date.now().getTime();
		//Lib.alert(toJSONString());
		LocalStorage.setItem(guid, toJSONString());
	}
	
	public function fillData(guid:String,json:String):Void {
		var objJSON:Dynamic = JSON.parse(json);
		this.pageNum = Std.parseInt(objJSON.obj[0].pageNum);
		this.text = objJSON.obj[0].text;
		this.guid = guid;
	}
	
	public function remove():Void {
		LocalStorage.removeItem(this.guid);
	}
	
	public function clone():Bookmark {
		var bookmark = new Bookmark();
		bookmark.guid = this.guid;
		bookmark.pageNum = this.pageNum;
		bookmark.text = this.text;
		return bookmark;
	}
	
		
	public function loadToContext2D(ctx:CanvasRenderingContext2D) {
		if (ctx != null && bookImgLoaded) {
			ctx.save();
			ctx.drawImage(bookmarkImg,Std.int(RunTime.clientWidth)-40 , 52);
			//ctx.fillRect(Std.int(RunTime.imagePageWidth), 50, 32, 32);
			ctx.restore();
		}
	}
	
}