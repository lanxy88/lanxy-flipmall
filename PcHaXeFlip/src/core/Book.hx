package core;

class Book 
{
	public var pages:Array<Page>;
	
	public var lockPages:Array<String>;
	
	public var hotlinks:Array<HotLink>;
	
	public var slideshows:Array<SlideshowInfo>;
	
	public var videos:Array<VideoInfo>;
	
	public var audios:Array<AudioInfo>;
	
	public var buttons:Array<ButtonInfo>;
	
	public var highlights:Array<HighLight>;
	
	public var notes:Array<NoteIcon>;
	
	public var bookmarks:Array<Bookmark>;
	
	public var pageWidth:Float;
	
	public var pageHeight:Float;
	
	public var logoUrl:String;
	
	public var logoHref:String;
	
	public var shareHref:String;
	
	public var bookId:String;
	
	public var bookTitle:String;
	
	public var bgColor:String;
	
	public var bgImageUrl:String;
	
	public var analyticsUA:String;
	public var password:String;
	
	public var singlepageMode:Bool;
	public var rightToLeft:Bool;
	
	public var menuTocVisible:Bool;
	public var menuThumbsVisible:Bool;
	public var menuSearchVisible:Bool;
	public var menuAutoFlipVisible:Bool;
	public var menuTxtVisible:Bool;
	public var menuZoomVisible:Bool;
	
	public var menuBookmarkVisible:Bool;
	public var menuNoteVisible:Bool;
	public var menuHighlightVisible:Bool;
	
	public var menuDownloadVisible:Bool;
	public var menuEmailVisible:Bool;
	public var menuSnsVisible:Bool;
	
	public var bookDownloadUrl:String;
	
	public var autoFlipSecond:Int;
	
	public var gateway:String;

	public function new() 
	{
		pages = new Array<Page>();
		hotlinks = new Array<HotLink>();
		videos = new Array<VideoInfo>();
		audios = new Array<AudioInfo>();
		buttons = new Array<ButtonInfo>();
		highlights = new Array<HighLight>();
		notes = new Array<NoteIcon>();
		bookmarks = new Array<Bookmark>();
		slideshows = new Array<SlideshowInfo>();
		
		bookId = "";
		bookTitle = "";
		analyticsUA = "";
		singlepageMode = false;
		rightToLeft = false;
		menuTocVisible = true;
		menuThumbsVisible = true;
		menuSearchVisible = true;
		menuAutoFlipVisible = true;
		menuZoomVisible = true;
		
		menuBookmarkVisible = true;
		menuNoteVisible = true;
		menuHighlightVisible = true;
	}
	
	public function preloadPages(num:Int):Void
	{
		if (num == null) num = 0;
		
		if (num < 0 || num >pages.length -1) return;
		var p:Array<Int> = [];
		p.push(num);
		p.push(num + 1);
		p.push(num - 1);
		p.push(num + 2);
		p.push(num - 2);
		p.push(num + 3);
		p.push(num - 3);
		p.push(num + 4);
		p.push(num + 5);
		
		for (i in 0 ... p.length)
		{
			var index:Int = p[i];
			if (index >= 0 && index < pages.length)
			{
				var page:Page = this.pages[index];
				page.getImagePage();
				page.loadBigImagePage();
			}
		}
	}
	
}