package core;
import js.Lib;

/**
 * ...
 * @author 
 */

class BookContext 
{
	public var ctx:CanvasRenderingContext2D;
	//按钮层
	public var ctxButton:CanvasRenderingContext2D;
	//高亮层
	public var ctxHighLight:CanvasRenderingContext2D;
	
	//笔记层
	public var ctxNote:CanvasRenderingContext2D;
	
	//书签
	public var ctxBookmark:CanvasRenderingContext2D;
	
	
	private var pages:Array<Page>;
	
	public var pageOffset:Float;
	
	public var hotlinks:Array<HotLink>;
	
	public var slideshow:Array<SlideshowInfo>;
	
	public var videos:Array<VideoInfo>;
	
	public var buttons:Array<ButtonInfo>;
	
	public var bookmarks:Array<Bookmark>;
	
	public var highlights:Array<HighLight>;
	public var notes:Array<NoteIcon>;
	
	
	public var scale:Float;
	
	public var offsetX:Float;
	
	public var offsetY:Float;
	
	public function new() 
	{
		pages = new Array<Page>();
		pageOffset = 0;
		scale = 1;
		offsetX = 0;
		offsetY = 0;
	}
	
	public function getPageCount():Int
	{
		return pages.length;
	}
	
	public function resetLayoutParams():Void
	{
		offsetX = 0;
		offsetY = 0;
		scale = 1;
	}
	
	public function removeAllPages():Void
	{
		if (pages != null)
		{
			for (i in 0 ... pages.length)
			{
				var item:Page = pages[i];
				item.visible = false;
			}
		}
		
		pages = new Array<Page>();
	}
	
	public function clear(removePages:Bool = false):Void
	{
		if (pages != null)
		{
			for (i in 0 ... pages.length)
			{
				var item:Page = pages[i];
				item.visible = false;
			}
		}
		
		if (removePages == true)
		{
			pages = new Array<Page>();
		}
		
		if (ctx != null)
		{
			ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
		}
		
		if (ctxButton != null)
		{
			ctxButton.clearRect(0, 0, ctxButton.canvas.width, ctxButton.canvas.height);
		}
		
		if (ctxHighLight != null)
		{
			ctxHighLight.clearRect(0, 0, ctxHighLight.canvas.width, ctxHighLight.canvas.height);
		}
		
		if (ctxNote != null)
		{
			ctxNote.clearRect(0, 0, ctxNote.canvas.width, ctxNote.canvas.height);
			
		}
		if (ctxBookmark != null) {
			ctxBookmark.clearRect(0, 0, ctxBookmark.canvas.width, ctxBookmark.canvas.height);
		}
	}
	
	public function addPage(page:Page):Void
	{
		if (page == null) return;
		if (pages == null) pages = new Array<Page>();
		page.bookContext = this;
		pages.push(page);
	}

	public function render():Void
	{
		this.clear();
		
		if (pages != null && ctx != null)
		{
			for (i in 0 ... pages.length)
			{
				//trace("this.offsetX=" + this.offsetX);
				var item:Page = pages[i];
				item.scale = this.scale;
				item.offsetX = this.offsetX;
				item.offsetY = this.offsetY;
				item.visible = true;
				item.loadToContext2D(ctx);
			}
		}
		
		if (hotlinks != null && ctx != null)
		{
			for (i in 0 ... hotlinks.length)
			{
				var item:HotLink = hotlinks[i];
				item.scale = this.scale;
				item.offsetX = this.offsetX;
				item.offsetY = this.offsetY;
				item.loadToContext2D(ctxButton);
			}
		}
		
		if (buttons != null && ctxButton != null)
		{
			for (i in 0 ... buttons.length)
			{
				
				var item:ButtonInfo = buttons[i];
				item.scale = this.scale;
				item.offsetX = this.offsetX;
				item.offsetY = this.offsetY;
				item.loadToContext2D(ctxButton);
			}
		}
		
		if (highlights != null && ctxHighLight != null)
		{
			for (i in 0 ... highlights.length)
			{
				//Lib.alert(i);
				var item:HighLight = highlights[i];
				item.scale = this.scale;
				item.offsetX = this.offsetX;
				item.offsetY = this.offsetY;
				item.loadToContext2D(ctxHighLight);
			}
		}
		
		if (notes != null && ctxNote != null)
		{
			for (i in 0 ... notes.length)
			{
				var item:NoteIcon = notes[i];
				item.scale = this.scale;
				item.offsetX = this.offsetX;
				item.offsetY = this.offsetY;
				item.loadToContext2D(ctxNote);
			}
		}
		
		if (this.bookmarks != null && bookmarks.length > 0) {
			//Lib.alert(bookmarks);
			for (i in 0 ... bookmarks.length) {
				var item:Bookmark = bookmarks[i];
				item.loadToContext2D(ctxBookmark);
			}
		}
		
	}
	
	public function getHotLinkAt(x:Float, y:Float):HotLink
	{
		if (this.hotlinks == null) return null;
		for (i in 0 ... this.hotlinks.length)
		{
			var item:HotLink = this.hotlinks[i];
			if (item.hitTest(x, y) == true)
			{
				return item;
			}
		}
		return null;
	}
	
	public function getButtonAt(x:Float, y:Float):ButtonInfo
	{
		if (this.buttons == null) return null;
		for (i in 0 ... this.buttons.length)
		{
			var item:ButtonInfo = this.buttons[i];
			if (item.hitTest(x, y) == true)
			{
				return item;
			}
		}
		return null;
	}
	
	public function getHighLightAt(x:Float, y:Float):HighLight {
		if (this.highlights == null) return null;
		for (i in 0 ... this.highlights.length)
		{
			var item:HighLight = this.highlights[i];
			if (item.hitTest(x, y) == true)
			{
				return item;
			}
		}
		return null;
	}
	
	public function getNoteAt(x:Float, y:Float):NoteIcon {
		if (this.notes == null) return null;
		for (i in 0 ... this.notes.length)
		{
			var item:NoteIcon = this.notes[i];
			if (item.hitTest(x, y) == true)
			{
				return item;
			}
		}
		return null;
	}
}