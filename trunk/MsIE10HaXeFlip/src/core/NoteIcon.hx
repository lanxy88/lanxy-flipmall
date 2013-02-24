package core;
import js.Lib;

/**
 * 标记图标
 * @author kylefly
 */

class NoteIcon 
{
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;	
	
	public var tx:Float;
	public var ty:Float;
	public var twidth:Float;
	public var theight:Float;
	
	public var pageNum:Int;
	public var tpageNum:Int;
	
	public var note:Note;
	public var guid:String;
	public var canvas:Canvas;
	
	public var scale:Float;
	
	public var offsetX:Float;
	
	public var offsetY:Float;
	
	private var checked:Bool;
	// 书页的layout方式。0 为居中，1 为左书页，1 为右书页
	public var pageLayoutType:Int;
	
	public function new() 
	{
		this.note = new Note();
		this.x = 0;
		this.y = 0;
		this.width = 0;
		this.height = 0;
		pageNum = -1;

		guid = "";
		checked = false;
		
		pageLayoutType = 0;
		scale = 1;
		offsetX = 0;
		offsetY = 0;
		
	}
	
	private function getDrawParams():DrawParams
	{
		var dp:DrawParams = RunTime.getDrawParams(pageLayoutType);
		dp.applyTransform(scale, offsetX, offsetY);
		return dp;
	}
	
	private function getLeftDrawParams():DrawParams
	{
		var dp:DrawParams = RunTime.getDrawParams(-1);
		dp.applyTransform(scale, offsetX, offsetY);
		return dp;
	}
	private function getRightDrawParams():DrawParams
	{
		var dp:DrawParams = RunTime.getDrawParams(1);
		dp.applyTransform(scale, offsetX, offsetY);
		return dp;
	}
	
	
	public function clone():NoteIcon {
		DataTransform();
		var hl:NoteIcon = new NoteIcon();
		hl.x = this.x;
		hl.y = this.y;
		hl.width = this.width;
		hl.height = this.height;
		hl.pageNum = this.pageNum;
		hl.guid = this.guid;
		hl.note.text = this.note.text;
		//Lib.alert(hl.pageNum);
		return hl;
	}
	
	public function setCanvas(canvas:Canvas):Void {
		this.canvas = canvas;
		if (note != null) {
			this.note.setCanvas(this.canvas);
		}
	}
	
	public function getContext():CanvasRenderingContext2D {
		return canvas.getContext("2d");
	}
	
	public function getLeft():Float {
		return this.x;
	}
	
	public function getRight():Float {
		return this.x + this.width;
	}
	
	public function getTop():Float {
		return this.y;
	}
	
	public function getBottom():Float {
		return this.y + this.height;
	}
	
	private function toJSONString():String {
		
		var json:String = '{"obj":[{"x":"' + this.x + 
							'","y":"' + this.y + 
							'","width":"' +	this.width +
							'","height":"' + this.height +
							'","page":"' + this.pageNum +
							'","note":"' + this.note.text + '"}]}';
		return json;
	}
	
	public function save():Void {
		if (this.twidth == 0 || this.theight == 0) return;

		//if(guid == ""){
			guid = RunTime.kvPrex + "@$ni$@" + Date.now().getTime();
		//}
		//Lib.alert(guid);
		///return;
		
		DataTransform();
		LocalStorage.setItem(guid, toJSONString());
	}
	
	/**
	 * 转换数据：由屏幕坐标转换为适合图书大小的坐标
	 */
	public function DataTransform():Void {
		var dp:DrawParams = getDrawParams();
	
		//trace("tx=" + this.tx + ",ty=" + this.ty + ",twidth=" + this.twidth + ",theight=" + this.theight);
		//trace("dx=" + dp.dx + ",dy=" + dp.dy + ",sx=" + dp.sx + ",sy=" + dp.sy);
		
		this.pageNum = this.tpageNum;
		
		//单页模式
		if (RunTime.singlePage) {
			//trace("single");
			
		}
		//双页模式
		else {
			//trace("double");
			//标记在右页
			if (RunTime.book.rightToLeft) {
				if (this.tx > RunTime.clientWidth / 2) {
					dp = getLeftDrawParams();
				}
				else {
					
					dp = getRightDrawParams();
				}
			}
			else
			{
				if (this.tx > RunTime.clientWidth / 2) {
					dp = getRightDrawParams();
				}
				else {
					dp = getLeftDrawParams();

				}
			}

		}
		
		this.x = dp.sx + (tx-dp.dx) / dp.scaleX();
		this.y = dp.sy+ (ty -dp.dy ) / dp.scaleY();
		
		//if (this.x > RunTime.clientWidth / 2) x = x -RunTime.clientWidth / 2;
		
		this.width = twidth / dp.scaleX();
		this.height = theight / dp.scaleY();
		
		trace("x=" + this.x + ",y=" + this.y + ",width=" + this.width + ",height=" + this.height);
	}
	
	public function fillData(guid:String,json:String):Void {
		var objJSON:Dynamic = JSON.parse(json);
		this.x = Std.parseFloat(objJSON.obj[0].x);
		this.y = Std.parseFloat(objJSON.obj[0].y);
		this.width = Std.parseFloat(objJSON.obj[0].width);
		this.height = Std.parseFloat(objJSON.obj[0].height);
		this.note.text = objJSON.obj[0].note;
		this.pageNum = Std.parseInt(objJSON.obj[0].page);
		this.guid = guid;
	}
	
	public function setChecked(bChecked:Bool):Void {
		this.checked = bChecked;
		if(this.checked){
			//this.draw("rgba(0,0,255,0.4)");
		}
		else {
			//this.draw("rgba(0,255,0,0.4)");
		}
	}
	
	public function updateText(text:String):Void {
		//Lib.alert(text);
		//return;
		this.note.text = text;
		LocalStorage.setItem(this.guid, toJSONString());
	}
	
	public function remove():Void {
		LocalStorage.removeItem(this.guid);
	}
	
	public function loadToContext2D(context:CanvasRenderingContext2D):Void {
		//Lib.alert("loadToContext2D");
		var radius:Int = 5;
		context.save();
		context.fillStyle = "rgba(255,0,0,0.4)";
		
		var dp:DrawParams = getDrawParams();
		
		var xx:Float = dp.dx + (x - dp.sx) * dp.scaleX();
		var yy:Float = dp.dy + (y - dp.sy) * dp.scaleY();
		var ww:Float = width * dp.scaleX();
		var hh:Float = height * dp.scaleY();

		//context.fillRect(Std.int(xx), Std.int(yy), Std.int(ww), Std.int(hh));
		
		context.drawImage(note.image,Std.int(xx),Std.int(yy),Std.int(ww),Std.int(hh));
		
		context.restore();
		if (note != null) {
			note.x = this.x;
			note.y = this.y - note.image.height;
			note.draw();
		}
	}
	
	public function draw(context:CanvasRenderingContext2D):Void {
		var radius:Int = 5;
		context.save();
		context.fillStyle = "rgba(255,0,0,0.4)";

		//context.fillRect(Std.int(xx), Std.int(yy), Std.int(ww), Std.int(hh));
		context.fillRect(Std.int(this.tx), Std.int(this.ty), Std.int(this.twidth), Std.int(this.theight));
		
		context.restore();
		if (note != null) {
			note.x = this.tx;
			note.y = this.ty - note.image.height;
			note.draw();
		}
	}
	
	
	/**
	 * 点击测试
	 * @param	x
	 * @param	y
	 * @return
	 */	
	public function hitTest(mouseX:Float, mouseY:Float):Bool {

		var dp:DrawParams = getDrawParams();

		
		var xx:Float = dp.dx + (x - dp.sx) * dp.scaleX();
		var yy:Float = dp.dy + (y - dp.sy) * dp.scaleY();
		var ww:Float = width * dp.scaleX();
		var hh:Float = height * dp.scaleY();
		
		var result:Bool = mouseX >= xx && mouseY >= yy && mouseX <= xx + ww && mouseY <= yy + hh;
		return result;
	}
	
	public function click(popupXOffset:Float = 0,popupYOffset:Float = 0):Void
	{
		RunTime.showPopupMaskLayer();
		RunTime.setOffset(Lib.document.getElementById("cvsOthers"), popupXOffset, popupYOffset);
		Lib.document.getElementById("cvsOthers").innerHTML = HtmlHelper.toNotePopupHtml(this, "saveNote", "deleteNote");
		Lib.document.getElementById("textNote").focus();
	}
}