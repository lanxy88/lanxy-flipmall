package 
{
	import com.google.analytics.AnalyticsTracker;
	import com.google.analytics.GATracker;
	
	import common.BookPage;
	import common.HistoryManager;
	import common.ThicknessInfo;
	import common.TreeNodeRecord;
	import common.events.MomentoEvent;
	
	import controls.ExitConfirm;
	import controls.NoteMark;
	import controls.NoteMarkDetail;
	import controls.SModeBook;
	import controls.VideoBox;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.EventDispatcher;
	import flash.events.FullScreenEvent;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.text.StaticText;
	import flash.utils.getTimer;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.managers.CursorManager;
	import mx.managers.PopUpManager;
	import mx.utils.Base64Encoder;
	import mx.utils.URLUtil;
	
	import org.alivepdf.pdf.PDF;
	
	import qs.controls.FlexBook;
	
	import service.BaseService;
	import service.IService;
	import service.LocalService;
	import service.RemoteService;
	
	import utils.Helper;

	public class RunTime extends EventDispatcher
	{
		private static var useGoogleUaAsLogViewer:Boolean = true;
		
		private var app: Application;
		
		[Bindable]
		public static var audioVolume:Number = 0.8;
		[Bindable]
		public static var audioBoxPostion:Point;
		
		public static var autoMoveAfterZoom:Boolean;
		
		[Bindable]
		public static var fitScreenAfterZoom:Boolean;
		[Bindable]
		public static var configFitScreenAfterZoom:Boolean;
		
		[Bindable]
		public static var fitScreenScale:Number;
		
		public static var singlePageMode:Boolean = false;
		
		public static var initBookPageWidth:Number;
		
		public static var normalPageWidth:Number = 0;
		public static var normalPageHeight:Number = 0;
		
		[Bindable]
		public static var useLocalDefaultScale:Boolean;
		
		[Bindable]
		public static var rightToLeft:Boolean;
		
		[Bindable]
		public static var highlightRecords:Array = [];
		
		[Bindable]
		public static var bookmarkRecords:Array = [];
		
		[Bindable]
		public static var audioboxRecords:Array = [];
		
		[Bindable]
		public static var noteRecords:Array = [];
		
		public static var bookId:String = "";
		
		public static var infoUrl:String = "";
		
		public static var helpUrl:String = "";
		
		public static var pageWidth:Number;
		public static var pageHeight:Number;
		
		[Bindable]
		public static var autoHideOnFullScreen:Boolean = true;
		
		[Bindable]
		public static var bottomMenuFixTop:Boolean = false;
		
		[Bindable]
		public static var hideLeftMenu:Boolean = false;
		[Bindable]
		public static var hideBottomMenu:Boolean = false;
		
		[Bindable]
		public static var showBottomThumb:Boolean = false;
		
		[Bindable]
		public static var windowColor:Number = 0x222222;
		
		[Bindable]
		public static var bottomThumbBgColor:Number = 0x000000;
		[Bindable]
		public static var bottomThumbAlpha:Number = 0.5;
	
		[Bindable]
		public static var hideLefMenuAfterZoom:Boolean = false;
		
		[Bindable]
		public static var hideBottomMenuAfterZoom:Boolean = false;
		
		[Bindable]
		public static var showTabBackground:Boolean = true;
		
		[Bindable]
		public static var iconSameSize:Boolean = false;
		
		[Bindable]
		public static var iconSize:int = 27;
		
		[Bindable]
		public static var showPageCount:Number = 0;
		
		[Bindable]
		public static var thickness:Number = 9;
		
		//[Bindable]
		public static var thicknessInfo:ThicknessInfo = null;
		
		/**
		 * 导入的pdf品质
		 */
		public static var exportPdfQuality:int = 80;
		
		public static var bookContent:XML;
		
		/**
		 * 需要保护的页面
		 */
		public static var protectedPages:Array = [];
		/**
		 * 页面是否已经解锁
		 */
		public static var unlockPage:Boolean = false;
		
		/**
		 * 是否手工触发缩放 
		 */		
		public static var firstZoomed:Boolean = false;
		
		[Bindable]
		public static var flipArrow:Boolean = false;
		
		[Bindable]
		public static var bookPages:Array = [];
		
		public static function get pageCount():int
		{
			return bookPages.length;
		}
		
		public static function get bookLayoutPageCount():int
		{
			return mainPage.bookLayoutPageCount;
		}
		
		[Embed (source="assets/btnNote.png")]
		[Bindable]
		public static var CURSOR_NOTE:Class;
		
		[Embed (source="assets/btnHighlightNote.png")]
		[Bindable]
		public static var ICON_HIGHLIGHT_NOTE:Class;
		
		[Embed (source="assets/btnHighlightBrush.png")]
		[Bindable]
		public static var CURSOR_HIGHLIGHT:Class;
		
		[Embed (source="assets/blackStyle/btnExitFullScreen.png")]
		[Bindable]
		public static var ICON_EXIT_FULL_SCREEN:Class;
		
		[Embed (source="assets/blackStyle/btnFullScreen.png")]
		[Bindable]
		public static var ICON_FULL_SCREEN:Class;
		
		[Embed(source='assets/blackStyle/btnZoom.png')]
		[Bindable]
		public static var iconZoomIn: Class;
		
		[Embed(source='assets/blackStyle/btnZoomOut.png')]
		[Bindable]
		public static var iconZoomOut: Class;
		
		[Embed(source='assets/blackStyle/btnAutoFlip.png')]
		[Bindable]
		public static var iconAutoFlip:Class;
		
		[Embed(source='assets/blackStyle/btnSearch.png')]
		[Bindable]
		public static var iconSearch:Class;
		
		[Embed(source='assets/blackStyle/btnBookMark.png')]
		[Bindable]
		public static var iconBookmark:Class;
		
		[Embed(source='assets/blackStyle/btnNote.png')]
		[Bindable]
		public static var iconNote:Class;
		
		[Embed(source='assets/blackStyle/btnMask.png')]
		[Bindable]
		public static var iconMask:Class;
		
		[Embed(source='assets/blackStyle/btnSound.png')]
		[Bindable]
		public static var iconSound: Class;
		
		[Embed(source='assets/blackStyle/btnSoundMute.png')]
		[Bindable]
		public static var iconSoundMute: Class;
		
		[Embed(source='assets/blackStyle/btnContents.png')]
		[Bindable]
		public static var iconBtnContents:Class;
		
		
		[Embed(source='assets/blackStyle/btnThumbs.png')]
		[Bindable]
		public static var iconBtnThumbs:Class;
		
		[Embed(source='assets/blackStyle/btnEmail.png')]
		[Bindable]
		public static var iconBtnEmail:Class;
		
		[Embed(source='assets/blackStyle/btnShare.png')]
		[Bindable]
		public static var iconBtnShare:Class;
		
		[Embed(source='assets/blackStyle/btnPrint.png')]
		[Bindable]
		public static var iconBtnPrint:Class;
		
		[Embed(source='assets/blackStyle/btnSavePdf.png')]
		[Bindable]
		public static var iconBtnSavePdf:Class;
		
		
		[Embed(source='assets/blackStyle/btnDownload.png')]
		[Bindable]
		public static var iconBtnDownload:Class;
		
		[Embed(source='assets/blackStyle/btnPrevIssues.png')]
		[Bindable]
		public static var iconBtnPrevIssues:Class;
		
		[Embed(source='assets/blackStyle/btnSetting.png')]
		[Bindable]
		public static var iconBtnSetting:Class;
		
		[Embed(source='assets/blackStyle/btnCloseBox16.png')]
		[Bindable]
		public static var iconBtnCloseBox16:Class;
		
		[Embed(source='assets/blackStyle/btnAbout.png')]
		[Bindable]
		public static var iconBtnAbout:Class;
		

		[Embed(source='assets/blackStyle/btnQuest.png')]
		[Bindable]
		public static var iconBtnQuest:Class;
		
		[Embed(source='assets/blackStyle/btnInfo.png')]
		[Bindable]
		public static var iconBtnInfo:Class;
		
		[Embed(source='assets/blackStyle/btnBackward.png')]
		[Bindable]
		public static var iconBtnBackward:Class;
		
		[Embed(source='assets/blackStyle/btnForward.png')]
		[Bindable]
		public static var iconBtnForward:Class;
		
		[Embed(source='assets/blackStyle/btnFirstPage.png')]
		[Bindable]
		public static var iconBtnFirstPage:Class;
		
		[Embed(source='assets/blackStyle/btnPrevPage.png')]
		[Bindable]
		public static var iconBtnPrevPage:Class;
		
		[Embed(source='assets/blackStyle/btnGotoPage.png')]
		[Bindable]
		public static var iconBtnGotoPage:Class;
		
		
		[Embed(source='assets/blackStyle/btnNextPage.png')]
		[Bindable]
		public static var iconBtnNextPage:Class;
		
		[Embed(source='assets/blackStyle/btnLastPage.png')]
		[Bindable]
		public static var iconBtnLastPage:Class;
		
		[Embed(source='assets/blackStyle/btnAutoFlip.png')]
		[Bindable]
		public static var iconBtnAutoFlip:Class;
		
		[Embed(source='assets/blackStyle/btnSearch.png')]
		[Bindable]
		public static var iconBtnSearch:Class;
		
		[Embed(source='assets/blackStyle/btnBookMark.png')]
		[Bindable]
		public static var iconBtnBookMark:Class;
		
		
		[Embed(source='assets/blackStyle/btnNote.png')]
		[Bindable]
		public static var iconBtnNote:Class;
		
		[Embed(source='assets/blackStyle/btnMask.png')]
		[Bindable]
		public static var iconBtnMask:Class;
		
		[Embed(source='assets/blackStyle/btnFirstPage.png')]
		[Bindable]
		public static var iconFirstPage:Class;
		
		[Embed(source='assets/blackStyle/btnPrevPage.png')]
		[Bindable]
		public static var iconPrevPage:Class;
		
		[Embed(source='assets/blackStyle/btnGotoPage.png')]
		[Bindable]
		public static var iconGotoPage:Class;
		
		[Embed(source='assets/blackStyle/btnNextPage.png')]
		[Bindable]
		public static var iconNextPage:Class;
		
		[Embed(source='assets/blackStyle/btnLastPage.png')]
		[Bindable]
		public static var iconLastPage:Class;
		
		[Embed(source='assets/blackStyle/btnQuest.png')]
		[Bindable]
		public static var iconHelp:Class;
		
		[Embed(source='assets/blackStyle/btnBackward.png')]
		[Bindable]
		public static var iconBackward:Class;
		
		[Embed(source='assets/blackStyle/btnForward.png')]
		[Bindable]
		public static var iconForward:Class;
		
		[Embed(source='assets/blackStyle/btnInfo.png')]
		[Bindable]
		public static var iconInfo:Class;

		
		[Bindable]
		public static var note:String = "";
		
		private static var _instance: RunTime;
		
		[Bindable]
		public static var mainPage:IMainApp;
		
		[Bindable]
		public static var history:common.HistoryManager = new common.HistoryManager();
		
		[Bindable]
		public static var zoomedIn: Boolean = false;
		
		[Bindable]
		public static var zoomMode:String = "normal";
		
		[Bindable]
		public static var zoomedOut:Boolean = false;
		
		[Bindable]
		public static var mainApp:Application;
		
		[Bindable]
		public static var book:FlexBook;
		
		[Bindable]
		public static var sModeBook:SModeBook;
		
		[Bindable]
		public static var prevIssues:Array = [];
		
		[Bindable]
		public static var prevSubIssues:Array = [];
		
		public static var cfgFileCount:int = 16;
		public static var cfgFileLoadedCount:int = 0;
		
		[Bindable]
		public static var forms:Array = [];
		
		[Bindable]
		public static var slideshows:Array = [];
		
		[Bindable]
		public static var rss:Array = [];
		
		[Bindable]
		public static var hotlinks:Array = [];

		[Bindable]
		public static var buttons:Array = [];
		
		[Bindable]
		public static var videos:Array = [];
		
		[Bindable]
		public static var tableOfContents:Array = [];
		
		[Bindable]
		public static var copyrightConfig:XML;
		
		[Bindable]
		public static var langConfig:XML;
		
		[Bindable]
		public static var langSelectedId:int = 0;
		
		public static var localSetting:Object = null;
		
		public static var analyticsUA:String;
		
		[Bindable]
		public static var sites:Array = [];
		
		[Bindable]
		public static var siteLogoWidth:int = 100;
		
		[Bindable]
		public static var siteLogoHeight:int = 40;
		
		[Bindable]
		public static var bookConfig: XML;
		
		public static var service :BaseService;
		
		public static var searchString:String="";
		
		/**
		 * 限制最大缩放到100%
		 */
		public static var limitTo100:Boolean = false;
		
		/**
		 * 是否显示缩放框
		 */
		public static var showZoomBox:Boolean = true;
		
		/**
		 * 滚轮缩放
		 */
		public static var mouseWheelZoom:Boolean = false;
		
		
		public static var currentLeftPage:int = 0;
		public static var currentRightPage:int = 1;

		
		public static var xLeftWhenFitWindow:Number = 0;
		
		public static var xRightWhenFitWindow:Number = 0;
		
		public static var yWhenFitWindow:Number = 0;
		
		public static var bottomMenuIconLoadedCount = 0;
		
		
		[Bindable]
		public static var customButtonSoundEnable:Object = null;
		[Bindable]
		public static var customButtonSoundDisable:Object = null;
		
		[Bindable]
		public static var customButtonZoomEnable:Object = null;
		[Bindable]
		public static var customButtonZoomDisable:Object = null;
		
		[Bindable]
		public static var customButtonAutoFlipEnable:Object = null;
		[Bindable]
		public static var customButtonAutoFlipDisable:Object = null;
		
		[Bindable]
		public static var customButtonSearchEnable:Object = null;
		[Bindable]
		public static var customButtonSearchDisable:Object = null;
		
		[Bindable]
		public static var customButtonBookmarkEnable:Object = null;
		[Bindable]
		public static var customButtonBookmarkDisable:Object = null;
		
		[Bindable]
		public static var customButtonNoteEnable:Object = null;
		[Bindable]
		public static var customButtonNoteDisable:Object = null;
		
		[Bindable]
		public static var customButtonHighlightEnable:Object = null;
		[Bindable]
		public static var customButtonHighlightDisable:Object = null;
		
		[Bindable]
		public static var customButtonFullscreenEnable:Object = null;
		[Bindable]
		public static var customButtonFullscreenDisable:Object = null;
		
		[Bindable]
		public static var customButtonFirstPage:Object = null;
		[Bindable]
		public static var customButtonPrevPage:Object = null;
		[Bindable]
		public static var customButtonNextPage:Object = null;
		[Bindable]
		public static var customButtonLastPage:Object = null;
		
		[Bindable]
		public static var customButtonHelp:Object = null;
		[Bindable]
		public static var customButtonInfo:Object = null;
		[Bindable]
		public static var customButtonBackward:Object = null;
		[Bindable]
		public static var customButtonForward:Object = null;
		
		[Bindable]
		public static var tooltipBgColor:String = "";
		[Bindable]
		public static var tooltipFgColor:String = "";
		[Bindable]
		public static var showZoomTip:Boolean = true;
		[Bindable]
		public static var showFlipTip:Boolean = true;
		
		[Bindable]
		public static var bookSize:Number = 1;
		
		[Bindable]
		public static var bookBgImageLayout:String = "center";
		[Bindable]
		public static var bookBgImage:String = "";
		[Bindable]
		public static var topAdPosition:String ="left";
		[Bindable]
		public static var rightAdPosition:String="top";
		[Bindable]
		public static var showIssueThumb:Boolean = false;
		
		
		[Bindable]
		public static var isLocal:Boolean = false;
		
		public static function onConfigFileLoadFail(...args):void
		{
			RunTime.cfgFileLoadedCount++;
			RunTime.mainPage.updateProloadInfo();
		}
		
		public static function getAllIssues():Vector.<TreeNodeRecord>
		{
			var nodes:Vector.<TreeNodeRecord> = new Vector.<TreeNodeRecord>();
			for each(var item:TreeNodeRecord in prevIssues)
			{
				nodes = nodes.concat(item.getAllNodes());
			}
			return nodes;
		}
		
		[Bindable]
		public static var hardCover:Boolean = false;
		
		public static function get isSinglePageMode():Boolean
		{
			return mainApp is smain;
		}
		
		[Bindable]
		public static var clickToZoom:String = "none";
		
		public static function isSingleClickToZoom():Boolean
		{
			return clickToZoom == "singleclick";
		}
		
		public static function isDoubleClickToZoom():Boolean
		{
			return clickToZoom == "doubleclick";
		}
		
		[Bindable]
		public static var zoomAfterLoaded:Boolean = false;
		
		public static function clickHref(dest:String,target:String="_blank"):void
		{
			if(!dest) return;
			
			if(dest.indexOf("page:") == 0)
			{
				RunTime.mainPage.gotoPage(int(dest.substr("page:".length)));
			}
			else
			{
//				Alert.show(dest+"\n"+target);
				if(!RunTime.isLocal){
					flash.net.navigateToURL(new URLRequest(RunTime.getAbsPath(dest)),target);
//					Alert.show("!local");
				}
				else{
					flash.net.navigateToURL(new URLRequest(dest),target);
				}
			}
		}
		
		public static var linkInnerSwf:Boolean = false;
		
		public static function showHelp():void
		{
			if(!RunTime.helpUrl) return;
			RunTime.clickHref(RunTime.helpUrl);
		}
		
		public static function showMVHelp():Boolean{
//			if(!RunTime.helpUrl) return false;
			return true;
		}
	
		
		public static function removeHighlightOn():void
		{
			if(RunTime.MouseState == RunTime.MOUSE_STATE_HIGHLIGHT_ON)
			{
				RunTime.setNormal();
			}
		}
		
		public static function saveCurrentObjectState():void
		{
			if( RunTime.CurrentMovingObject != null)
			{
				if(RunTime.CurrentMovingObject is NoteMark || RunTime.CurrentMovingObject is NoteMarkDetail)
				{
					if(RunTime.service is LocalService)
					{
						RunTime.service.updateNote(Object(RunTime.CurrentMovingObject).record);
					}
				}
			}
		}
		
		[Bindable]
		public static var fullScreen:Boolean = false;
		
		[Bindable]
		public static var editor:Object = null;
		
		public static function showInfo(obj:*):void
		{
			if(obj == null) Alert.show("null");
			else if(obj is Sprite)
			{
				Alert.show("x:"+obj.x+";y:"+obj.y+";width:"+obj.width+";height:"+obj.height+";");
			}
			else
			{
				Alert.show(obj);
			}
		}
		
		public static const MOUSE_STATE_NORMAL:int = 0;
		public static const MOUSE_STATE_NOTE_MOVING:int = 1;
		public static const MOUSE_STATE_NOTE_DELETING:int = 2;
		public static const MOUSE_STATE_NOTE_DETAIL_MOVING:int = 3;
		public static const MOUSE_STATE_PENDING:int = 4;
		public static const MOUSE_STATE_HIGHLIGHT_ON:int = 5;
		public static const MOUSE_STATE_HIGHLIGHT_DETAIL_MOVING:int = 6;
		public static const MENU_RESIZE_DURATION :Number = 200;
		
		[Bindable]
		public static var MouseState:int = MOUSE_STATE_NORMAL;
		
		private static var _CurrentMovingObject:Sprite = null;

		public static function get CurrentMovingObject():Sprite
		{
			return _CurrentMovingObject;
		}

		public static function set CurrentMovingObject(value:Sprite):void
		{
			RunTime.saveCurrentObjectState();
			_CurrentMovingObject = value;
		}
		
		public static function setNormal():void
		{
			RunTime.CurrentMovingObject = null;
			CursorManager.removeAllCursors();
			RunTime.MouseState = RunTime.MOUSE_STATE_NORMAL;
		}
		
		public static function setHighlightOnState():void
		{
			RunTime.CurrentMovingObject = null;
			CursorManager.setCursor(RunTime.CURSOR_HIGHLIGHT,2,0,-30);
			RunTime.MouseState = RunTime.MOUSE_STATE_HIGHLIGHT_ON;	
		}

		public function RunTime(target:IEventDispatcher=null)
		{
			super(target);
		}

		public function initApp(app: Application): void
		{
			Security.allowDomain("*");
			this.app = app;
			
			var path:String = app.systemManager.loaderInfo.url;
			
			RunTime.history.addEventListener(HistoryManager.EVENT_MOMENTO_UNDO,
				function(e:MomentoEvent):void
				{
					RunTime.mainPage.gotoPageIndex(e.momento as int);
				});
			
			RunTime.history.addEventListener(HistoryManager.EVENT_MOMENTO_REDO,
				function(e:MomentoEvent):void
				{
					RunTime.mainPage.gotoPageIndex(e.momento as int);
				});
			
			var index:int = path.indexOf("?");
			if(index > 0)
			{
				path = path.substr(0,index);
			}
			var i:int = path.indexOf(".swf");
			if(i > 0)
			{
				path = path.substr(0,i) + "9483728472839487628394058" + path.substr(i + 4);
			}
			basePath = path.replace( /\w+9483728472839487628394058/gi, '' );
//			basePath = "http://www.geblab.com/demo/Trim_Catalog/";
//			basePath = "http://www.flipmall.net/demo/disney/";
//			basePath = "http://www.geblab.com/demo/flip/button/";
//			basePath = "http://www.docteurduparebrise.com/catalogues/roues/";
//			basePath = "http://192.168.1.199/flipbook/jpVideo01/";
//			basePath = "http://epagecreator.net/demo/pro/";
//			basePath = "http://localhost/flipbook/";
//			basePath = "http://www.genomebc.ca/flip/Winter2012_Online/";
//			basePath = "http://localhost/fliptest/swf-vector/";
//			basePath = "http://localhost/fliptest/AdNotShow/";
//			basePath = "http://www.geblab.com/demo/flip/adnotshow1/";
			
			var serviceUrl:String = null;
			//serviceUrl = ExternalInterface.call("getFlashBookServiceUrl");
			if(serviceUrl)
			{
				RunTime.service = new RemoteService(serviceUrl);
			}
			else
			{
				RunTime.service = new LocalService();
			}
		}

		public function get urlRandomizer(): String
		{
			return "?rand=" + String(Math.round((Math.random() * 1000 + getTimer())));
		}

		public function get serverUrl(): String
		{
			return URLUtil.getServerName( app.systemManager.loaderInfo.url );
		}
		
		public function get configPath(): String
		{
			return basePath + "data/bookinfo.xml" + RunTime.instance.urlRandomizer;
		}
		
		public function get soundsPath():String
		{
			return basePath + "data/sounds.xml" + RunTime.instance.urlRandomizer;
		}
		
		public function get contentsPath():String
		{
			return basePath + "data/contents.xml" + RunTime.instance.urlRandomizer;
		}
		
		public function get issuesPath():String
		{
			return basePath + "data/issues.xml" + RunTime.instance.urlRandomizer;
		}
		
		public function get searchPath():String
		{
			return basePath + "data/search.xml" + RunTime.instance.urlRandomizer;
		}
		
		public function get sitePath():String
		{
			return basePath + "data/share.xml" + RunTime.instance.urlRandomizer;;
		}
		
		public function get copyrightPath():String
		{
			return basePath + "data/copyright.xml" + RunTime.instance.urlRandomizer;;
		}
		
		public function get languagesPath():String
		{
			return basePath + "data/languages/languages.xml" + RunTime.instance.urlRandomizer;
		}
		
		public function getLanguageData(lang:String):String
		{
			return basePath + "data/languages/" + lang + ".xml" + RunTime.instance.urlRandomizer;
		}
		
		public function get pagesPath():String
		{
			return basePath + "data/pages.xml" + RunTime.instance.urlRandomizer;;
		}
		
		public function get bookmarksPath():String
		{
			return basePath + "data/bookmarks.xml" + RunTime.instance.urlRandomizer;;
		}
		
		public function get hotlinksPath():String
		{
			return basePath + "data/hotlinks.xml" + RunTime.instance.urlRandomizer;;
		}
		
		public function get videosPath():String
		{
			return basePath + "data/videos.xml" + RunTime.instance.urlRandomizer;
 		}
		
		public function get buttonsPath():String
		{
			return basePath + "data/buttons.xml" + RunTime.instance.urlRandomizer;
		}
		
		public function get rssPath():String{
			return basePath + "data/rss.xml" + RunTime.instance.urlRandomizer;
		}
		
		public function get formsPath():String{
			return basePath + "data/forms.xml" + RunTime.instance.urlRandomizer;
		}
		
		public function get slideshowPath():String
		{
			return basePath + "data/slideshow.xml" + RunTime.instance.urlRandomizer;
		}

		public static function get instance(): RunTime
		{
			if( _instance == null )
			{
				_instance = new RunTime();
			}
			return _instance;
		}
		
		private static var _basePath:String = "";
		
		public static function get basePath():String
		{
			return _basePath;
		}
		
		public static function set basePath(path:String):void
		{
			_basePath = path;
		}
		
		public static function getAbsPath(path:String):String
		{
			if(!path) return null;
			
			if(	path.indexOf("http:") == 0
				|| path.indexOf("https:") == 0
				|| path.indexOf("mailto:") == 0
				|| path.indexOf("file:") == 0
			)
			{
				return path;
			}
			else if(path.indexOf("/") == 0)
			{
				return basePath + path.substring(1);
			}
			else
			{
				return basePath + path;
			}
		}
		
		public static var tracker:AnalyticsTracker;
		
		public static function useAnalyticsUA(ua:String):void
		{
			if(basePath.indexOf("http") == 0)
			{
				try
				{
					tracker = new GATracker(RunTime.mainApp, ua, "as3", false);
				} 
				catch(error:Error) 
				{
					
				}
				
			}
		}
		
		public static function log(action:String, msg:String):void
		{
			if(!msg) return;
			if(useGoogleUaAsLogViewer == false) return;
			
			if(tracker)
			{
				tracker.trackPageview(RunTime.bookId + "/" + action + "/" + msg);
			}
		}
		
		public static function logPageView(pageNum:int):void
		{
			if(pageNum > 0)
			{
				log("page", pageNum.toString());
			}
		}
		
		public static function logClickLink(url:String, url2:String = null):void
		{
			if((!url) && (!url2)) return;
			log("link",(url ? url : url2));
		}
		
		public static function logVideoView(url:String, url2:String = null):void
		{
			if((!url) && (!url2)) return;
			url = removePrefix(url);
			log("video",(url ? url : url2));
		}
		
		public static function logAudioView(url:String):void
		{
			if(!url) return;
			url = removePrefix(url);
			log("audio" , url);
		}
		
		public static function logSearch(keyword:String):void
		{
			if(!keyword) return;
			log("search" , keyword);
		}
		
		private static function removePrefix(url:String):String
		{
			if(url == null || url == "") return url;
			else if(url.indexOf("http") == 0) return url;
			else
			{
				var i:int = url.lastIndexOf("/");
				return url.substring(i+1);
			}
		}
		
		public static var key:String = "";
		
		public static var license:int = LicenseType.TRIAL;
		
		public static function encrypt(src:String):String
		{
			return encryptKey(src,RunTime.key);
		}
		
		public static function encryptKey(src:String, key:String):String
		{
			var n:int = 0;
			var rtn:String = "";
			for(var i:int = 0; i < src.length - 1; i++)
			{
				var c:int = src.charCodeAt(i) + key.charCodeAt(n);
				var s:String = String.fromCharCode(c);
				rtn += s;
				n ++;
				if(n >= key.length - 1) n = 0;
			}
			
			if(src.length > 0)
			{
				rtn = rtn + src.substr(src.length - 1);
			}
			var base64:Base64Encoder = new Base64Encoder();
			base64.encode(rtn);
			return base64.toString();
		}
		
		public static function getLicenseType(lic:String):int{
			
			/*
			trace("standard: " + RunTime.encrypt("standard"));
			trace("annual: " + RunTime.encrypt("annual"));
			trace("professional: " + RunTime.encrypt("professional"));
			trace("enterprise: " + RunTime.encrypt("enterprise"));
			trace("global: " + RunTime.encrypt("global"));
			*/
			
			if(lic == RunTime.encrypt("standard"))
				return LicenseType.STANDARD;
			
			if(lic == RunTime.encrypt("annual"))
				return LicenseType.ANNUAL;
			if(lic == RunTime.encrypt("professional"))
				return LicenseType.PROFESSIONAL;
			if(lic == RunTime.encrypt("enterprise"))
				return LicenseType.ENTERPRISE;
			if(lic == RunTime.encrypt("global"))
				return LicenseType.GLOBAL;
			return LicenseType.TRIAL;
		}
		
		private static var fullScreenVideoBoxParent:DisplayObjectContainer;
		public static var fullScreenVideoBox:VideoBox;
		private static var fullScreenVideoBoxPosition:Rectangle;
		
		public static function enterFullScreenMode(videoBox:VideoBox):void
		{
			fullScreenVideoBoxParent = videoBox.parent;
			fullScreenVideoBoxParent.removeChild(videoBox);
			fullScreenVideoBox = videoBox;
			fullScreenVideoBoxPosition = new Rectangle(videoBox.x,videoBox.y,videoBox.width,videoBox.height);
			var parent:DisplayObject = RunTime.mainApp;
			PopUpManager.addPopUp(videoBox, parent,true);
			videoBox.x = 0;
			videoBox.y = 0;
			videoBox.width = RunTime.mainApp.width;
			videoBox.height = RunTime.mainApp.height;

			/*
			if(RunTime.fullScreen == false)
			{
				mainPage.switchFullScreenMode();
			}
			*/
		}
		
		public static function exitVideoBoxFullScreenMode():void
		{
			if(fullScreenVideoBox != null)
			{
				PopUpManager.removePopUp(fullScreenVideoBox);
				fullScreenVideoBoxParent.addChild(fullScreenVideoBox);
				fullScreenVideoBox.x = fullScreenVideoBoxPosition.x;
				fullScreenVideoBox.y = fullScreenVideoBoxPosition.y;
				fullScreenVideoBox.width = fullScreenVideoBoxPosition.width;
				fullScreenVideoBox.height = fullScreenVideoBoxPosition.height;
				fullScreenVideoBoxParent = null;
				fullScreenVideoBox = null;
			}
		}
		
		public static function computePopupPosition(e:MouseEvent, width:Number, height:Number):Point
		{
			var w:Number = RunTime.mainApp.width;
			var h:Number = RunTime.mainApp.height;
			var p:Point = RunTime.mainApp.globalToLocal(new Point(e.stageX,e.stageY));
			var x:Number = p.x;
			var y:Number = p.y;
			
			if(isNaN(width) || isNaN(height)) return new Point(x,y);;
			
			if(p.x > 0.5 * w)
			{
				if(p.x + width > w - 10)
				{
					x = p.x - width - 10;
					if(x < 10) x = 10;
				}
			}
			
			if(p.y > 0.5 * h)
			{
				if(p.y + height > h - 10)
				{
					y = h - height - 10;
					if(y < 10) y = 10;
				}
			}
			
			return new Point(x,y);
		}
		
		public static function close(needConfirm:Boolean=false):void
		{
			//ExternalInterface.call("function closeMe(){return window.close();}");
			if(needConfirm){
				var confirm:ExitConfirm = new ExitConfirm();
				confirm.showDialog();
			}
			else{
				ExternalInterface.call("closeMe");
			}
		}
		
		public static function updateBookPages(soundConfig:XML):void
		{
			if(soundConfig == null || RunTime.bookPages == null) return;
			
			for each(var item:XML in soundConfig.pages.sound)
			{
				var pageNumber:int = int(item.@pageNumber);
				var url:String = String(item.@url);
				for each(var page:BookPage in RunTime.bookPages)
				{
					if(page.pageId == pageNumber)
					{
						page.bgSoundUrl = RunTime.getAbsPath(url);
						page.sound = new Sound(new URLRequest(RunTime.getAbsPath(url)));
						page.soundRepeat = String(item.@repeat) == 'true';
						page.soundControl = String(item.@controlBar) == 'true';
						break;
					}
				}
			}
		}
		
		public static function getFlashVersion():Array
		{
			var version:String = Capabilities.version;
			var idx:int = version.search(/\d/);
			if (idx!=-1)
			{
				version = version.substr(idx);
				return version.split(',');
			}
			else
			{
				return null;
			}
		}
		
		public static function showLeftMenu(hide:Boolean):void{
			var menus:Array = RunTime.mainPage.controlBars;
			Helper.setVisibleWithFade(DisplayObject(menus[0]),hide);
			DisplayObject(menus[0]).visible = hide;
			if(RunTime.hideLeftMenu) 
				DisplayObject(menus[0]).visible = false;
			
		}
		public static function showBottomMenu(hide:Boolean):void{
			
			var menus:Array = RunTime.mainPage.controlBars;
			Helper.setVisibleWithFade(DisplayObject(menus[1]),hide);
			DisplayObject(menus[1]).visible = hide;
			if(RunTime.hideBottomMenu) 
				DisplayObject(menus[1]).visible = false;
		}
		
		
		public static function switchFullScreenMode():void
		{
			var stage:Stage = RunTime.mainApp.stage;
			stage.removeEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenStateChanged);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenStateChanged);
			
			var setVisibleWithFade:Function = function(visible:Boolean):void
			{
				var menus:Array = RunTime.mainPage.controlBars;
				for each(var item:DisplayObject in menus)
				{
					Helper.setVisibleWithFade(item,visible);
				}
			}
			
			if(stage.displayState == StageDisplayState.NORMAL)
			{
				//stage.displayState = canFullScreenInteractive ? "fullScreenInteractive" : StageDisplayState.FULL_SCREEN ;	
				stage.displayState = StageDisplayState.FULL_SCREEN ;	
				if(RunTime.autoHideOnFullScreen) {
					trace("RunTime.autoHideOnFullScreen=" + RunTime.autoHideOnFullScreen);
					setVisibleWithFade(false);
				}
				if(RunTime.hideLeftMenu) 
					Helper.setVisibleWithFade(RunTime.mainPage.controlBars[1],false);
				if(RunTime.hideBottomMenu)  
					Helper.setVisibleWithFade(RunTime.mainPage.controlBars[0],false);
				RunTime.fullScreen = true;
				
			}
			else
			{
				stage.displayState = StageDisplayState.NORMAL;
				setVisibleWithFade(true);
				
				if(RunTime.hideLeftMenu) Helper.setVisibleWithFade(RunTime.mainPage.controlBars[1],false);
				if(RunTime.hideBottomMenu)  Helper.setVisibleWithFade(RunTime.mainPage.controlBars[0],false);;
				
				RunTime.fullScreen = false;
			}
		}
		
		private static function get canFullScreenInteractive():Boolean
		{
			var versions:Array = RunTime.getFlashVersion();
			if(versions.length > 2)
			{
				var v1:int = int(versions[0]);
				var v2:int = int(versions[1]);
				return (v1 > 11) || ((v1 == 11) && (v2 >= 3));
			}
			return false;
		}
		
		private static function onFullScreenStateChanged(event:FullScreenEvent):void
		{
			var stage:Stage = RunTime.mainApp.stage;
			if(stage.displayState == StageDisplayState.NORMAL)
			{
				RunTime.fullScreen = false;
				RunTime.exitVideoBoxFullScreenMode();
				var menus:Array = RunTime.mainPage.controlBars;
				for each(var item:DisplayObject in menus)
				{
			  		
					item.alpha = 1;
					item.visible = true;
				}
			}
		}
	}
}