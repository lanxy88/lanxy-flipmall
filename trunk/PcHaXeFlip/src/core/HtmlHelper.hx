package core;
import js.Lib;
import orc.utils.ImageMetricHelper;
import orc.utils.Util;

class HtmlHelper 
{
	public static function toContentsHtml(xml:Xml):String
	{
		var roots:Array<Xml> = Util.getXmlChilds(xml);
		if (roots.length != 1) return "";
		var root:Xml = roots[0];
		var childs:Array<Xml> = Util.getXmlChilds(root);
		
		var s:String = "";
		if (childs.length > 0)
		{
			for (i in 0 ... childs.length)
			{
				s += toContentsNodeHtml(childs[i]);
			}
		}
		return s;
	}
	
	private static function toContentsNodeHtml(xml:Xml):String
	{
		var childs:Array<Xml> = Util.getXmlChilds(xml);
		var s:String = "";
		s += "<ul>";
		s += "<li>";
		s += toContentsNodeHtmlCore(xml);
		s += "</li>";
		if (childs.length > 0)
		{
			s += "<ul>";
			for (i in 0 ... childs.length)
			{
				s += toContentsNodeHtml(childs[i]);
			}
			s += "</ul>";
		}
		s += "</ul>";
		return s;
	}
	
	private static function toContentsNodeHtmlCore(xml:Xml):String
	{
		var title:String = xml.get("title");
		var page:String = xml.get("page");
		var pageVal:Int = 0;
		if (page != null && page != "")
		{
			pageVal = Std.parseInt(page);
			page = Std.string(pageVal-1);
		}
		return "<span onclick=\"gotoPage(" + page + ");\">" + title + "</span>";
	}
	
	public static function toSnsHtml(xml:Xml):String {
		var roots:Array<Xml> = Util.getXmlChilds(xml);
		if (roots.length != 1) return "";
		var root:Xml = roots[0];
		var childs:Array<Xml> = Util.getXmlChilds(root);
		
		var s:String = "";
		s += "<div id='snsbox' style='float:left;width: 100%;height: 250px;'>";
		if (childs.length > 0)
		{
			for (i in 0 ... childs.length)
			{
				s += toSnsNodeHtml(childs[i]);
			}
		}
		
		s += "</div>";
		
		return s;
	}
	
	private static function toSnsNodeHtml(xml:Xml):String {
		
		var s:String = "<p style='float:left;width:150px;height:20px;'>";
		s += "<a href='" + xml.get("href" ) + "'><img style='vertical-align:middle;' src='" +
				xml.get("logoUrl") + "'>" + "</a>";
			 
		s +=  "<span onclick=\"RunTime.navigateUrl('" + xml.get("href")  + "')\" style='vertical-align:middle;'>" + xml.get("name") + "</span>";
		s += "</p>";
		return s;
	}
	
	public static function toEmailHtml():String {
		var s:String = "";
		s += "<form  id='sendEmail' action='" + RunTime.book.gateway + "' method='post'>";
		s += "<table border='none' class='email'>";
		s += "<tr><td>" + L.s("To", "To") + ":</td><td><input  id='tomail' type='text' name='tomail' /></td></tr>";
		s += "<tr><td>" + L.s("YourName", "Your Name") + ":</td><td><input id='yname' type='text' name='yourName'/></td></tr>";
		s += "<tr><td>" + L.s("YourEmail", "Your Email") +":</td><td><input id='youremail' type='text' name='frommail'/></td></tr>";
		s += "<tr><td>" + L.s("Message", "Message") + ":</td><td><textarea rows='7' cols='30' id='sharemsg' name='message'></textarea></td></tr>";
		s += "<tr><td></td><td align='right'><input style='width:100px' type='button' onclick='RunTime.onSendEmail();' value='" + L.s("Send","Send") + "'/></td></tr>";
		s += "</table>";
		s += "<input style='display:none' type='hide' id='subject' name='subject' value='" + 
				L.s("YourFriend", "YourFirend") + 
				L.s("ShareEmailTitle","ShareEmailTitle")  + "'/>";
		s += "</form>";

		return s;
	}
	
	public static function toThumbsHtml(pages:Array<Page>):String
	{
		var s:String = "";
		for (i in 0 ... pages.length)
		{
			var page:Page = pages[i];
			s += toThumbsNodeHtml(page);
		}
		return s;
	}
	
	private static function toThumbsNodeHtml(page:Page):String
	{
		// <img class="thumb" src="page.urlThumb" width="128" height="128" onclick="gotoPage(m);" />
		return "<img class=\"thumb\" src=\""+ page.urlThumb +"\" onclick=\"gotoPage(" + page.num + "); \" />";
	}
	
	public static function toBookmarksHtml(bookmarks:Array<Bookmark>, singleMode:Bool,lbEnable:Bool, rbEnable:Bool):String {
		var s:String = "";
		s += "<div id=\"op\">";
		s += "<textarea id=\"bookmarknote\"></textarea>";
		if(singleMode){
			s += "<button onclick=\"addBookmark(0)\">Add Bookmark</button>";
		}
		else {
			if (lbEnable) {
				s += "<button onclick=\"addBookmark(-1)\">Add Left Bookmark</button>";
			}
			else{
				s += "<button disabled=\"disabled\">Add Left Bookmark</button>";
			}
			if(rbEnable){
				s += "<button onclick=\"addBookmark(1)\">Add Right Bookmark</button>";
			}
			else {
				s += "<button disabled=\"disabled\">Add Right Bookmark</button>";
			}
		}
		s += "<button>Remove All</button>";
		s += "</div>";
		s += "<ul style=\"margin:20px 0px 0px 0px;padding-left:5px;padding-right:5px;\">";
		
		if(bookmarks != null){
			for ( i in 0 ... bookmarks.length) {
				var bookmark:Bookmark = bookmarks[i];
				s += toBookmarkNodeHtml(bookmark);
			}
		}
		s += "</ul>";
		return s;
	}
	
	private static function toBookmarkNodeHtml(bookmark:Bookmark):String {
		var s:String = "";
		s += "<li class=\"bookmarkrow\" >";
		s += "<p class=\"p1\" onclick=\"gotoPage(" + Std.string(bookmark.pageNum-1) + ")\" > P" + bookmark.pageNum + "</p>";
		s += "<p class=\"p2\" onclick=\"gotoPage(" + Std.string(bookmark.pageNum-1) + ")\">" + bookmark.text + "</p>";
		s += "<button onclick=\"removeBookmark(" + Std.string(bookmark.pageNum - 1) 
											+")\" style=\"float:right;margin:0px -2px;\">" 
											+ L.s("RemoveBookmark","Remove") +"</button>";
		s += "</li>";
		return s;
	}
	
	public static function toSearchHtml():String
	{
		return StringTools.replace(RunTime.searchHtmlCache, "$Search", L.s("Search"));
	}
	
	public static function toSearchResultHtml(results:Array<Dynamic>):String
	{
		var s:String = "";
		s += "<table>";
		for (i in 0 ... results.length)
		{
			var item:SearchResult = results[i];
			s += "<tr onclick=\"gotoPage(" + Std.string(item.page - 1) + ")\">";
			s += "<td width=\"40px\" class=\"colPage\">";
			s += "P" + Std.string(item.page);
			s += "</td>";
			s += "<td class=\"colContent\">";
			s += item.content;
			s += "</td>";
			s += "</tr>";
		}
		s += "</table>";
		return s;
	}
	
	public static function toVideoHtml(video:VideoInfo):String
	{
		return video.toHtml();
	}
	
	public static function toRectVideoHtml(video:VideoInfo, xx:Float, yy:Float, ww:Float, hh:Float):String
	{
		var loop:String = video.autoRepeat ? "loop" : "";
		
		
		var s:String = "";
		s += "<div id=\"" + video.id + "\" style=\"position:absolute;z-index:101;left:" 
		+ Std.string(Math.round(xx)) + "px;top:"
		+ Std.string(Math.round(yy)) + "px;width:" + Std.string(Math.round(ww)) 
		+ "px;height:"+ Std.string(Math.round(hh)) + "px;\">";
		s += "<video class=\"video-js\" src=\"" + video.url 
		+ "\" width=\"" + Std.string(Math.round(ww)) 
		+ "\" height=\"" + Std.string(Math.round(hh))
		+"\" controls autoplay preload onloadeddata='RunTime.logVideoView(\"" + video.url + "\", \""+ video.youtubeId +"\")' " + loop + " >";
		s += "</video>";
		s += "</div>";

		
		return s;
	}
	
	public static function toRectYoutubeVideoHtml(video:VideoInfo, xx:Float, yy:Float, ww:Float, hh:Float):String
	{
		var s:String = "";
		s += "<div id=\"" + video.id + "\" style=\"position:absolute;z-index:101;left:" 
		+ Std.string(Math.round(xx)) + "px;top:"
		+ Std.string(Math.round(yy)) + "px;width:1px;height:1px;\">";
		s += "<iframe frameborder=\"0\" type=\"text/html\""  
		+ "\" width=\"" + Std.string(Math.round(ww)) 
		+ "\" height=\"" + Std.string(Math.round(hh))
		+"\""  + " src=\"http://www.youtube.com/embed/" + video.youtubeId + "?controls=1&amp;antoplay=1&amp;enablejsapi=1\">";
		s += "</iframe>";
		s += "</div>";
		return s;
	}
	
	public static function toSlideshow(slideshow:SlideshowInfo):String {
		return slideshow.toHtml();
	}

	public static function toSlideShowHtml(slideshow:SlideshowInfo, xx:Float, yy:Float, ww:Float, hh:Float,scale:Float):String
	{
		var s:String = "";
		if(slideshow.transition == "move"){
			s += "<div class=\"" + "slides" + "\" style=\"position:absolute;z-index:108;left:" 
			+ Std.string(Math.round(xx)) + "px;top:"
			+ Std.string(Math.round(yy)) + "px;width:" + Std.string(Math.round(ww)) 
			+ "px;height:" + Std.string(Math.round(hh)) + "px;\">";
			s += "<div  style=\"width: 100%;overflow: hidden;\">";
			s += "<div class=\"inner\" id=\"p_" + slideshow.id +  "\" style=\"width:"
				+ slideshow.slides.length * 100 + "%;\">";
			for( i in 0 ... slideshow.slides.length){
				s += "<article style=\"width:" + 1 / slideshow.slides.length * 100 +"%;\">";
				s += "<img src=\"" + slideshow.slides[i].url + "\" onclick=\"RunTime.navigateUrl('" + slideshow.slides[i].href + "');\">";
				s += "</article>";
			}
			s += "</div>";
			s += "</div>";
			s += "</div>";
		}
		else if(slideshow.transition == "fade"){
			s += "<div class=\"" + "slides" + "\" style=\"position:absolute;z-index:108;left:" 
			+ Std.string(Math.round(xx)) + "px;top:"
			+ Std.string(Math.round(yy)) + "px;width:" + Std.string(Math.round(ww)) 
			+ "px;height:" + Std.string(Math.round(hh)) + "px;\">";
			//s += "<div  style=\"width: 100%; \">";
			s += "<div class=\"inner\" id=\"p_" + slideshow.id +  "\" >";
			for ( i in 0 ... slideshow.slides.length) {
				var sid:String = slideshow.id + "_" +  (slideshow.slides.length - i) ;
				
				s += "<article style=\"text-align:left;width:100%;overflow: hidden;background:" 
					+ slideshow.bgColor 
					+ ";position:absolute;\""
					+ " id=\"a_" + sid
					+ "\">";
				
				
				s += "<img id=\"" + sid 
					+ "\" src=\"" + slideshow.slides[slideshow.slides.length - i - 1].url  + "\""
					+ " onclick=\"RunTime.navigateUrl('" 
					+ slideshow.slides[slideshow.slides.length - i - 1].href + "');\" "
					+ " style=\"" + "\""  
					+ " onload=\"RunTime.resizeSlide(this," + Std.int(ww) + "," +Std.int(hh) +  ",'" + sid + "'," +  scale + ");\""
					+">";
				
				s += "</article>";
			}
	
			s += "</div>";
			s += "</div>";
			//s += "</div>";
			
			//Lib.alert(s);
		}
		
		return s;
	}
	
	public static function toPopupImageHtml(item:Dynamic, success:String->Void):Void
	{
		
		
		/*
		<div style="position:absolute;left:80px;top:120px;width:200px;height:200px;background-color:#ffffff;">
		<div style="margin:0 auto;">
		<img src="" style="width:200px;height:200px;" />
		<img width="24" height="24" src="content/images/close.png" onclick="hideTopBar();" style="position:absolute;right:-12px;top:-12px;" />				
		</div>
		</div>
		*/
		
		var w:Int = Std.int(RunTime.clientWidth * 0.9);
		var h:Int = Std.int(RunTime.clientHeight * 0.9);
		
		if (item.popupWidth != null && item.popupHeight != null)
		{
			w =  item.popupWidth;
			h =  item.popupHeight;
		}
		else
		{
			var img:Html5Image = null;
			var onload:Void->Void = 
			function():Void
			{
				item.popupWidth = img.image.width;
				item.popupHeight = img.image.height;
				toPopupImageHtml(item,success);
			};
			
			img = new Html5Image(item.destination,onload);
			return;
		}
		
		var helper:ImageMetricHelper = new ImageMetricHelper(w, h);
		var scale:Float = helper.getMaxFitScale(RunTime.clientWidth * 0.9, RunTime.clientHeight * 0.9);
		h = Std.int(h * scale);
		w = Std.int(w * scale);
		
		var left:Int = Std.int((RunTime.clientWidth - w) / 2);
		var top:Int = Std.int((RunTime.clientHeight - h) / 2);
		
		var s:String = "";
		if (item.popupWidth != null && item.popupHeight != null)
		{
			s = "";
			s += "<div id=\"popupImage\" style=\"position:absolute; z-index:200;left:"
			+ Std.string(left) + "px; top:" 
			+ Std.string(top) + "px; width:"
			+ Std.string(w) + "px; height:"
			+ Std.string(h) + "px; background-color:#ffffff; -moz-transform: scale(0.2);-moz-transition: width 0s ease-out;-webkit-transform: scale(0.2); -webkit-transition: 0s ease-out; \" >";
			s += "<img src=\"" + item.destination +"\" style=\"width:" + Std.string(w) + "px;height:" + Std.string(h) + "px;\" />";
			s += "<img width=\"24\" height=\"24\" src=\"content/images/close.png\" onclick=\"clearPopupContents();\" style=\"position:absolute;right:-12px;top:-12px;\" />";
			s += "</div>";
		}
		else
		{
			s = "";
			s += "<div style=\"position:absolute;z-index:200; left:"
			+ Std.string(left) + "px; top:" 
			+ Std.string(top) + "px; width:"
			+ Std.string(w) + "px; height:"
			+ Std.string(h) + "px; \">";
			s += "<div style=\"margin:0 auto; \">";
			s += "<img src=\"" + item.destination +"\" style=\"max-width:" + Std.string(w) + "px;max-height:" + Std.string(h) + "px;\" />";
			s += "<img width=\"24\" height=\"24\" src=\"content/images/close.png\" onclick=\"clearPopupContents();\" style=\"position:absolute;right:-12px;top:-12px;\" />";
			s += "</div>";
			s += "</div>";
		}
		if (success != null)
		{
			success(s);
		}
	}
	
	public static function toPopupVideoHtml(item:Dynamic):String
	{
		var w:Int = 600;
		var h:Int = 480;
		
		if (item.popupWidth != null && item.popupHeight != null)
		{
			w =  item.popupWidth;
			h =  item.popupHeight;
		}
		
		var left:Int = Std.int((RunTime.clientWidth - w) / 2);
		var top:Int = Std.int((RunTime.clientHeight - h) / 2);
		
		var s:String = "";
		s += "<div id=\"popupVideo\"style=\"position:absolute; z-index:201;left:"
		+ Std.string(left) + "px; top:" 
		+ Std.string(top) + "px; width:"
		+ Std.string(w) + "px; height:"
		+ Std.string(h) + "px; background-color:#ffffff;-moz-transform: scale(0.2);-moz-transition: width 0s ease-out; -webkit-transform: scale(0.2); -webkit-transition: 0s ease-out; \">";
		
		if (item.youtubeId == null || item.youtubeId == "")
		{
			s += "<video class=\"video-js\" src=\"" + item.destination 
			+ "\" width=\"" + Std.string(Math.round(w)) 
			+ "\" height=\"" + Std.string(Math.round(h))
			+"\" controls autoplay preload onloadstart='this.play()' >";
			s += "</video>";
		}
		else
		{
			s += "<div style=\"position:absolute;padding-left:0px;padding-top:0px;\">";
			s += "<iframe frameborder=\"0\" type=\"text/html\""  
			+ "\" width=\"" + Std.string(Math.round(w)) 
			+ "\" height=\"" + Std.string(Math.round(h))
			+"\""  + " src=\"http://www.youtube.com/embed/" + item.youtubeId + "?controls=1&amp;antoplay=1&amp;enablejsapi=1\">";
			s += "</iframe>";
			s += "</div>";
		}
		s += "<img width=\"24\" height=\"24\" src=\"content/images/close.png\" onclick=\"clearPopupContents();\" style=\"position:absolute;right:-12px;top:-12px;\" />";
		s += "</div>";
		return s;
	}
	
	public static function toPopupPageAudiosHtml(audio:AudioInfo, isLeft:Bool = true):String
	{
		var w:Int = 200;
		var h:Int = 40;
		
		var left:Int = 20;
		var top:Int = 20;
		
		var s:String = "";
		
		if (audio == null) return s;
		
		if (isLeft == true)
		{
			s += "<div style=\"position:absolute; z-index:102;left:"
			+ Std.string(left) + "px; top:" 
			+ Std.string(top) + "px; width:"
			+ Std.string(w) + "px; height:"
			+ Std.string(h) + "px; \">";
			s += "<audio class=\"video-js\" src=\"" + audio.url
			+ "\" width=\"" + Std.string(Math.round(w)) 
			+ "\" height=\"" + Std.string(Math.round(h))
			+"\" controls autoplay >";
			s += "</audio>";
			s += "<img width=\"24\" height=\"24\" src=\"content/images/close.png\" onclick=\"clearLeftBgAudio();\" style=\"position:absolute;right:-12px;top:-12px;\" />";
			s += "</div>";
		}
		else
		{
			s += "<div style=\"position:absolute; z-index:102;left:"
			+ Std.string(Std.int(RunTime.clientWidth/2 + left)) + "px; top:" 
			+ Std.string(top) + "px; width:"
			+ Std.string(w) + "px; height:"
			+ Std.string(h) + "px; \">";
			s += "<audio class=\"video-js\" src=\"" + audio.url
			+ "\" width=\"" + Std.string(Math.round(w)) 
			+ "\" height=\"" + Std.string(Math.round(h))
			+"\" controls autoplay >";
			s += "</audio>";
			s += "<img width=\"24\" height=\"24\" src=\"content/images/close.png\" onclick=\"clearRightBgAudio();\" style=\"position:absolute;right:-12px;top:-12px;\" />";
			s += "</div>";
		}
		
		return s;
	}
	
	public static function toPopupAudioHtml(item:Dynamic):String
	{
		var w:Int = 200;
		var h:Int = 40;
		
		var left:Int = 20;
		var top:Int = 20;
		
		var s:String = "";
		s += "<div style=\"position:absolute; z-index:203;left:"
		+ Std.string(left) + "px; top:" 
		+ Std.string(top) + "px; width:"
		+ Std.string(w) + "px; height:"
		+ Std.string(h) + "px; \">";
		s += "<audio class=\"video-js\" src=\"" + item.destination 
		+ "\" width=\"" + Std.string(Math.round(w)) 
		+ "\" height=\"" + Std.string(Math.round(h))
		+"\" controls autoplay >";
		s += "</audio>";
		s += "<img width=\"24\" height=\"24\" src=\"content/images/close.png\" onclick=\"clearAudio();\" style=\"position:absolute;right:-12px;top:-12px;\" />";
		s += "</div>";
		return s;
	}
	
	public static function toPopupHtml(item:Dynamic):String
	{
		
		var w:Int = 600;
		var h:Int = 480;
		
		if (item.popupWidth != null && item.popupHeight != null)
		{
			w =  item.popupWidth;
			h =  item.popupHeight;
		}
		
		var left:Int = Std.int((RunTime.clientWidth - w) / 2);
		var top:Int = Std.int((RunTime.clientHeight - h) / 2);
		
		var s:String = "";
		s += "<div id=\"popupMessage\" style=\"position:absolute; z-index:204; left:"
		+ Std.string(left) + "px; top:" 
		+ Std.string(top) + "px; width:"
		+ Std.string(w) + "px; height:"
		+ Std.string(h) + "px; background-color:#ffffff; text-align:left;-moz-transform: scale(0.2);-moz-transition:width  0s ease-out; -webkit-transform: scale(0.2); -webkit-transition: 0s ease-out; \">";
		s += item.htmlText;
		s += "<img width=\"24\" height=\"24\" src=\"content/images/close.png\" onclick=\"clearPopupContents();\" style=\"position:absolute;right:-12px;top:-12px;\" />";
		s += "</div>";
		return s;
	}
	
	public static function toBookmarkPopupHtml(item:Dynamic=null):String {
		var w:Int = 600;
		var h:Int = 480;
		var left:Int = Std.int((RunTime.clientWidth - w) / 2);
		var top:Int = Std.int((RunTime.clientHeight - h) / 2);
		var s:String = "";
		s += "<div style=\"position:absolute; z-index:104; left:"
		+ Std.string(left) + "px; top:" 
		+ Std.string(top) + "px; width:"
		+ Std.string(w) + "px; height:"
		+ Std.string(h) + "px; background-color:#ffffff; text-align:left; \">";
		
		s += "<img width=\"24\" height=\"24\" src=\"content/images/close.png\" onclick=\"clearPopupContents();\" style=\"position:absolute;right:-12px;top:-12px;\" />";
		s += "</div>";
		return s;
	}
	public static function toNotePopupHtml(item:Dynamic, szSaveFunName, szDeleteFunName):String
	{
		var w:Int = 300;
		var h:Int = 200;
		
		if (item.popupWidth != null && item.popupHeight != null)
		{
			w =  item.popupWidth;
			h =  item.popupHeight;
		}
		
		var left:Int = Std.int((RunTime.clientWidth - w) / 2);
		var top:Int = Std.int((RunTime.clientHeight - h) / 2);
		
		var s:String = "";
		s += "<div style=\"position:absolute; z-index:800; left:"
		+ Std.string(left) + "px; top:" 
		+ Std.string(top) + "px; width:"
		+ Std.string(w) + "px; height:"
		+ Std.string(h) + "px;  \">"
		+ "<div style=\"margin:0 0; position:absolute; background-color:black;" 
		+ "-webkit-border-radius:10px; border:1px solid #ccc; opacity:0.6;width:300px; height:200px;\">"
		+ "</div>"
		+ "<div style=\"position:absolute;top:10px; left:10px; width:280px;" 
		+ "background-color:#ffffff; border:1px solid #ccc;margin:0 0;\">" 
		+ "<div style=\"width:280px; height:150px; background:#ffffff\">"
		+ "<textarea id=\"textNote\" style=\"width:275px; height:145px; border:0px\">" 
		+ item.note.text
		+ "</textarea>"
		+ "</div>"
		+ "<img width=\"24\" height=\"24\" src=\"content/images/close.png\" onclick=\"clearPopupContents();\" style=\"position:absolute;right:-20px;top:-20px;\" />"
		+ "</div>"
		+ "<div style=\"position:absolute;top:182px; left:10px;width:280px; margin:0 0; \">"
		+ "<img onclick=\""+ szSaveFunName+"()\" src=\"content/images/save.png\" style=\"position:absolute;"
		+ "left:5px; top:-16px\"/>"
		+ "<img onclick=\""+szDeleteFunName+"()\" src=\"content/images/garbage.png\" style=\"position:absolute;"
		+ "left:75px; top:-16px\"/>"
		+ "</div>"
		+ "</div>";

		return s;
	}
	
	public static function toInputPwdHtml():String
	{
		var left:Float = (RunTime.clientWidth - 300) / 2;
		var top:Float = (RunTime.clientHeight - 180) / 2;
		var pos:String = "position:absolute;z-index:200; left:"+Std.string(Math.round(left))+"px; top:"+Std.string(Math.round(top))+"px;";
		
		var s:String = "";
		s += "<div id=\"inputBox\" style=\" "+ pos +" width:300px; height:120px;background-color:#CCCCCC; \">";
		s += "<p>"+L.s("NeedPassword")+"</p>";
		s += "<input id=\"tbKeyword\" type=\"password\" style=\"width:120px; height:20px; \"  onkeypress=\"return onInputKeyPress(event)\" />";
		s += "<input type=\"button\" style=\"height:20px; \" value=\""+ L.s("Submit") +"\" onclick=\"inputPwd(); \" />";
		s += "</div>";
		return s;
	}
	
	public static function toInputUnlockPwdHtml():String
	{
		var left:Float = (RunTime.clientWidth - 300) / 2;
		var top:Float = (RunTime.clientHeight - 180) / 2;
		var pos:String = "position:absolute;z-index:200;left:"+Std.string(Math.round(left))+"px; top:"+Std.string(Math.round(top))+"px;";
		
		var s:String = "";
		s += "<div id=\"inputBox\" style=\" "+ pos +" width:300px; height:120px;background-color:#CCCCCC; \">";
		s += "<img width=\"24\" height=\"24\" src=\"content/images/close.png\" onclick=\"clearPopupContents();\" style=\"position:absolute;right:-10px;top:-10px;\" />";
		s += "<p>"+L.s("NeedPassword")+"</p>";
		s += "<input id=\"tbKeyword\" type=\"password\" style=\"width:120px; height:20px; \"  onkeypress=\"return onUnlockKeyPress(event)\" />";
		s += "<input type=\"button\" style=\"height:20px; \" value=\""+ L.s("Submit") +"\" onclick=\"unlockPage(); \" />";
		s += "</div>";
		return s;
	}
}