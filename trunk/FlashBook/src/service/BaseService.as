/**
 * @author xiaotie@geblab.com 
 */

package service
{
	import common.AudioBoxRecord;
	import common.BookMarkRecord;
	import common.ButtonInfo;
	import common.FormInfo;
	import common.HighlightRecord;
	import common.HotLink;
	import common.NoteRecord;
	import common.RSSInfo;
	import common.RSSItem;
	import common.RpcRequest;
	import common.ShareSite;
	import common.SlideshowInfo;
	import common.TreeNodeRecord;
	import common.VideoInfo;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;

	public class BaseService implements IService
	{
		public function init(callback:Function):void{}
		public function loadLocalData():void {};
		public function requestBookMarks():void {}
		public function createBookMark(item:BookMarkRecord):void{}
		public function updateBookMark(item:BookMarkRecord):void{}
		public function deleteBookMark(item:BookMarkRecord):void{}
		public function createNote(item:NoteRecord):void{}
		public function updateNote(item:NoteRecord):void{}
		public function deleteNote(item:NoteRecord):void{}
		public function requestNotes():void{}
		public function createHighlight(item:HighlightRecord):void{}
		public function updateHighlight(item:HighlightRecord):void{}
		public function createAudioBox(item:AudioBoxRecord):void{}
		public function updateAudioBox(item:AudioBoxRecord):void{}
		public function deleteHighlight(item:HighlightRecord):void{}
		public function requestHighlights():void{}
		
		public function requestRss():void
		{
			new RpcRequest(RunTime.instance.rssPath,
				null,parseRss,RunTime.onConfigFileLoadFail);
		}
		
		public function requestHotlinks():void
		{
			new RpcRequest(RunTime.instance.hotlinksPath,
				null, parseHotlinks,RunTime.onConfigFileLoadFail);
		}
		
		public function requestVideos():void
		{
			new RpcRequest(RunTime.instance.videosPath, null, 
				parseVideos, RunTime.onConfigFileLoadFail);
		}
		
		public function requestButtons():void
		{
			new RpcRequest(RunTime.instance.buttonsPath, null, 
				parseButtons, RunTime.onConfigFileLoadFail);
		}
		
		public function requestCustomButtonsIcon():void{
			//trace(RunTime.bookConfig);
			if(RunTime.bookConfig == null) return;
			var btns:Array = ["sound",
				"zoom",
				"autoflip",
				"search",
				"bookmark",
				"notes",
				"highlight",
				"fullscreen",
				"firstpage",
				"prevpage",
				"nextpage",
				"lastpage",
				"help",
				"info",
				"back",
				"forward"];
			RunTime.customButtonSoundEnable = RunTime.iconSound;
			
			RunTime.customButtonZoomEnable = RunTime.iconZoomIn;
			
			RunTime.customButtonAutoFlipEnable = RunTime.iconAutoFlip;
			
			RunTime.customButtonSearchEnable = RunTime.iconSearch;
			
			RunTime.customButtonBookmarkEnable = RunTime.iconBookmark;
			
			RunTime.customButtonNoteEnable = RunTime.iconNote;
			
			RunTime.customButtonHighlightEnable = RunTime.iconMask;
			
			RunTime.customButtonFullscreenEnable = RunTime.ICON_FULL_SCREEN;
			
			
			RunTime.customButtonSoundDisable = RunTime.iconSoundMute;
			
			RunTime.customButtonZoomDisable = RunTime.iconZoomOut;
			
			RunTime.customButtonFullscreenDisable = RunTime.ICON_EXIT_FULL_SCREEN;
			
			RunTime.customButtonFirstPage = RunTime.iconFirstPage;
			RunTime.customButtonPrevPage = RunTime.iconPrevPage;
			RunTime.customButtonNextPage = RunTime.iconNextPage;
			RunTime.customButtonLastPage = RunTime.iconLastPage;
			
			RunTime.customButtonHelp = RunTime.iconHelp;
			RunTime.customButtonInfo = RunTime.iconInfo;
			RunTime.customButtonBackward = RunTime.iconBackward;
			RunTime.customButtonForward = RunTime.iconForward;
			
			for each(var btn:String in btns){
				if(String(RunTime.bookConfig.bottommenu[btn].@icon)){
					var szUrl:String = String(RunTime.bookConfig.bottommenu[btn].@icon);
					var absUrl:String = RunTime.getAbsPath(szUrl);
					loadCustomEnableButton(absUrl,btn);
				}
			
			}
			for each(var btn:String in btns){
				if(String(RunTime.bookConfig.bottommenu[btn].@dicon)){
					var szUrl:String = String(RunTime.bookConfig.bottommenu[btn].@dicon);
					var absUrl:String = RunTime.getAbsPath(szUrl);
					loadCustomDisableButton(absUrl,btn);
					
				}
				
			}
			
			//其他请求
			if(String(RunTime.bookConfig.bottommenu.zoom.@mode)){
				RunTime.zoomMode = String(RunTime.bookConfig.bottommenu.zoom.@mode);
			}
			
		}
		
		private function loadCustomEnableButton(absUrl:String,btn:String):void{
			
			if(btn == "sound"){
				RunTime.customButtonSoundEnable = absUrl;
			}
			else if(btn == "zoom"){
				RunTime.customButtonZoomEnable = absUrl;
			}
			else if(btn == "autoflip"){
				RunTime.customButtonAutoFlipEnable = absUrl;
			}
			else if(btn == "search"){
				RunTime.customButtonSearchEnable = absUrl;
			}
			else if(btn == "bookmark"){
				RunTime.customButtonBookmarkEnable = absUrl;
			}
			else if(btn == "notes"){
				RunTime.customButtonNoteEnable = absUrl;
			}
			else if(btn == "highlight"){
				RunTime.customButtonHighlightEnable = absUrl;
			}
			else if(btn == "fullscreen"){
				RunTime.customButtonFullscreenEnable = absUrl;
			}
			else if(btn == "firstpage"){
				RunTime.customButtonFirstPage = absUrl;
			}
			else if(btn == "prevpage"){
				RunTime.customButtonPrevPage = absUrl;
			}
			else if(btn == "nextpage"){
				RunTime.customButtonNextPage = absUrl;
			}
			else if(btn == "lastpage"){
				RunTime.customButtonLastPage = absUrl;
			}
			else if(btn == "help"){
				RunTime.customButtonHelp = absUrl;
			}
			else if(btn == "info"){
				RunTime.customButtonInfo = absUrl;
			}
			else if(btn == "back"){
				RunTime.customButtonBackward = absUrl;
			}
			else if(btn == "forward"){
				RunTime.customButtonForward = absUrl;
			}
			return;
			
		}
		
		private function loadCustomDisableButton(absUrl:String,btn:String):void{
			
			if(btn == "sound"){
				RunTime.customButtonSoundDisable = absUrl;
			}
			else if(btn == "zoom"){
				RunTime.customButtonZoomDisable = absUrl;
			}
			else if(btn == "fullscreen"){
				RunTime.customButtonFullscreenDisable = absUrl;
			}
			return;
			
			
		}
		
		public function requestForms():void{
			new RpcRequest(RunTime.instance.formsPath, null, 
				parseForms, RunTime.onConfigFileLoadFail);
		}
		
		public function requestSlideshows():void{
			new RpcRequest(RunTime.instance.slideshowPath,null,
				parseSlideshows,RunTime.onConfigFileLoadFail);
		}
		
		public function requestCopyright():void
		{
			new RpcRequest(RunTime.instance.copyrightPath,null, 
				function(obj:Object):void
				{
					RunTime.copyrightConfig = new XML(obj);
					RunTime.cfgFileLoadedCount++;
					RunTime.mainPage.updateProloadInfo();
				},RunTime.onConfigFileLoadFail);
		}
		
		public function requestTexts():void
		{
			new RpcRequest(RunTime.instance.searchPath,null, 
				function(obj:Object):void
				{
					RunTime.bookContent = new XML(obj);
					RunTime.cfgFileLoadedCount++;
					RunTime.mainPage.updateProloadInfo();
				},RunTime.onConfigFileLoadFail);
		}
		
		public function requestSites():void
		{
			new RpcRequest(RunTime.instance.sitePath, null, 
				function(obj:Object):void
				{
					RunTime.sites = parseSites(obj);
					if(XML(obj).@logoWidth) RunTime.siteLogoWidth = int(XML(obj).@logoWidth);
					if(XML(obj).@logoHeight) RunTime.siteLogoHeight = int(XML(obj).@logoHeight);
					RunTime.cfgFileLoadedCount++;
					RunTime.mainPage.updateProloadInfo();
				},RunTime.onConfigFileLoadFail
			);
		}
		
		public function requestLanguages():void
		{
			new RpcRequest(RunTime.instance.languagesPath,null, 
				parseLanguages,RunTime.onConfigFileLoadFail);
		}
		
		public function requestTOC():void
		{
			new RpcRequest(RunTime.instance.contentsPath, null, 
				function(obj:Object):void
				{
					RunTime.tableOfContents = parseContent(obj);
					RunTime.cfgFileLoadedCount++;
					RunTime.mainPage.updateProloadInfo();
				},RunTime.onConfigFileLoadFail
			);
		}
		
		public function requestIssues():void
		{
			new RpcRequest(RunTime.instance.issuesPath, null, 
				function(obj:Object):void
				{
					parseIssues(obj);
					//trace("RunTime.prevSubIssues.length=" + RunTime.prevSubIssues.length);
					RunTime.prevIssues = RunTime.prevSubIssues;// parseIssues(obj);
					RunTime.cfgFileLoadedCount++;
					RunTime.mainPage.updateProloadInfo();
				},RunTime.onConfigFileLoadFail
			);
		}
		
		private function parseRss(xmlData:Object):void
		{
			RunTime.cfgFileLoadedCount++;
			var rss:Array = [];
			var root:XML = new XML(xmlData);
			for each (var rssNode:XML in root.channel) 
			{
				var r:RSSInfo = RSSInfo.parse(rssNode);
				rss.push(r);
			}
			RunTime.rss = rss;
			
			RunTime.mainPage.updateProloadInfo();
		}
		
		private function parseHotlinks(xmlData:Object):void
		{
			RunTime.cfgFileLoadedCount++;
			
			var links:Array = [];
			
			var root:XML = new XML(xmlData);
			
			for each(var linkNode:XML in root.hotlink)
			{
				var l:HotLink = HotLink.parse(linkNode);
				links.push(l);
			}
			
			RunTime.hotlinks = links;
			
			RunTime.mainPage.updateProloadInfo();
		}
		
		private function parseVideos(xmlData:Object):void
		{
			RunTime.cfgFileLoadedCount ++;
			
			var videos:Array = [];
			
			var root:XML = new XML(xmlData);
			
			for each(var videoNode:XML in root.video)
			{
				var l:VideoInfo = VideoInfo.parse(videoNode);
				videos.push(l);
			}
			
			RunTime.videos = videos;
			
			RunTime.mainPage.updateProloadInfo();
		}
		
		private function parseButtons(xmlData: Object):void
		{
			RunTime.cfgFileLoadedCount++;
			
			var list:Array = [];
			
			var root:XML = new XML(xmlData);
			
			for each(var node:XML in root.button)
			{
				var item:ButtonInfo = ButtonInfo.parse(node);
				list.push(item);
			}
			
			RunTime.buttons = list;
			RunTime.mainPage.updateProloadInfo();
		}
		
		private function parseForms(xmlData:Object):void{
			RunTime.cfgFileLoadedCount++;
			var list:Array = [];
			var root:XML = new XML(xmlData);
			for each(var node:XML in root.form)
			{
				var item:FormInfo = FormInfo.parse(node);
				list.push(item);
			}
			
			RunTime.forms = list;
			RunTime.mainPage.updateProloadInfo();
			
		}
		
		private function parseSlideshows(xmlData:Object):void
		{
			RunTime.cfgFileLoadedCount++;
			var list:Array = [];
			var root:XML = new XML(xmlData);
			for each(var node:XML in root.slideshow)
			{
				var item:SlideshowInfo = SlideshowInfo.parse(node);
				list.push(item);
			}
			
			RunTime.slideshows = list;
			RunTime.mainPage.updateProloadInfo();
		}
		
		private function parseLanguages(xmlData: Object):void
		{
			RunTime.cfgFileLoadedCount++;
			RunTime.langConfig = new XML(xmlData);
			
			var key:String = null;
			if(RunTime.localSetting != null && RunTime.localSetting.hasOwnProperty("lang"))
			{
				key = String(RunTime.localSetting.lang);
			}
			
			
			var langId:int = -1;
			var lang:String = "";
			
			var i:int = 0;
			
			for each(var item:XML in RunTime.langConfig.language)
			{
				if(String(item.@content) == key)
				{
					langId = i;
					lang = key;
					break;
				}
				
				if(String(item.@default) == "yes")
				{
					langId = i;
					lang = item.@content;
				}
					
					i++;
					}
			
			langId = Math.max(0,langId);
			RunTime.langSelectedId = langId;
			l.loadRemote(RunTime.instance.getLanguageData(lang));
			
			RunTime.mainPage.updateProloadInfo();
		}
		
		private function parseContent(xmlData: Object, level:int = 0):Array
		{
			var root:XML = new XML(xmlData);
			var contents:Array = [];
			for each(var cnode:XML in root.content)
			{
				var node:TreeNodeRecord = new TreeNodeRecord("",0);
				node.content = String(cnode.@title);
				node.page = int(cnode.@page);
				node.level = level;
				node.childs = parseContent(cnode, level + 1);
				contents.push(node);
			}
			return contents;
		}
		
		private function parseIssues(xmlData: Object, level:int = 0):Array
		{
			var root:XML = new XML(xmlData);
			if(String(root.@thumbnail) || root.localName()=='issues')  
				RunTime.showIssueThumb = String(root.@thumbnail).toLowerCase()=="true" || (root.localName()=='issues' && String(root.@thumbnail)=='');
			var issues:Array = [];
			for each(var inode:XML in root.issue)
			{
				
				var node:TreeNodeRecord = new TreeNodeRecord("",0);
				node.content = String(inode.@title);
				node.url = RunTime.getAbsPath(String(inode.@url));
				//if(RunTime.showIssueThumb) node.thumb = RunTime.getAbsPath(inode.@thumb);
				node.level = level;
				node.childs = parseIssues(inode, level + 1);
				issues.push(node);
				
				trace("root.issue.......level=" + level);
				
				RunTime.prevSubIssues.push(node);
				//if(node.childs != null) RunTime.prevSubIssues.push(node.childs);
			}
			return issues;
		}
		
		private function parseSites(xmlData:Object):Array
		{
			var root:XML = new XML(xmlData);
			var sites:Array = [];
			var ref:String = RunTime.getAbsPath(String(RunTime.bookConfig.@shareUrl));
			
			for each(var node:XML in root.site)
			{
				var s:ShareSite = new ShareSite();
				s.name = node.@name;
				s.logoUrl = RunTime.getAbsPath(node.@logoUrl);
				s.href = node.@href;
				if(ref)
				{
					s.href +=  ref;
				}
				sites.push(s);
			}
			return sites;
		}
	}
}