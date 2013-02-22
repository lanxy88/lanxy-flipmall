package utils
{
	import qs.controls.FlexBook;

	public class PageNumHelper
	{
		public static function buildPageNumTipString(pageCount:int, book:FlexBook, currentPageIndex:int):String
		{
			var count:int = pageCount;
			var info:String = "";
			var left:int = book.getLeftPageNumber();
			var right:int = book.getRightPageNumber();
			
			if(book.rightToLeft == true)
			{
				var c:int = pageCount%2 == 0 ? count + 1 : count + 2;
				left = c - left;
				var tmp:int = c - right;
				right = left;
				left = tmp;
				if(left >= count + 2)
				{
					info =  "1";
				}
				else if(right == count + 2)
				{
					info =  count.toString();
				}
				else
				{
					info =  left.toString() + " - " + right.toString();
				}
			}
			else
			{
				if(left == -1)
				{
					info =  "1";
				}
				else if(right == -1)
				{
					info =  (currentPageIndex * 2 + 2).toString();
				}
				else
				{
					info =  left.toString() + " - " + right.toString();
				}
			}
			if(info != "" && count > 0)
			{
				info = info + " / " + count.toString();
			}
			
			return info;
		}
		
		public static function getPageIndex(page:int):int
		{
			if(RunTime.bookPages == null) return 0;
			
			var pageCount:int = RunTime.bookPages.length;
			if(RunTime.rightToLeft == false)
			{
				return getPageIndexCore(pageCount, page);
			}
			else
			{
				return getPageIndexCoreByRightToLeft(pageCount, page);
			}
		}
		
		public static function getPageIndexCore(pageCount:int, page:int):int
		{
			if(page>pageCount)
			{
				page = pageCount;
			}
			
			var index:int = 0;
			
			index = page == 1 ? -1 : (page / 2) - 1;
			if(index > pageCount)
			{
				index = pageCount;
			}
			
			return index;
		}
		
		public static function getPageIndexCoreByRightToLeft(pageCount:int, page:int):int
		{
			if(page > pageCount)
			{
				page = pageCount;
			}
			else if(page < 1)
			{
				page = 1;
			}
			
			if(pageCount % 2 == 0)
			{
				if(page == pageCount) return -1;
				else
				{
					return (pageCount - 3 - page)/2 + 1;
				}
			}
			else
			{
				return (pageCount - 2 - page)/2 + 1;
			}
		}
		
		public static function convertInnerPageToRealPage(pageNum:int):int
		{
			if(RunTime.rightToLeft == false || RunTime.bookPages == null) return pageNum;
			else
			{
				var pageCount:int = RunTime.bookPages.length;
				if(pageCount % 2 == 0)
				{
					return pageCount + 1 - pageNum;
				}
				else
				{
					return pageCount + 2 - pageNum;
				}
			}
		}
		
		public static var pageMap:Array = [];
		
		public static function buildPageMap():void
		{
			var count:int = RunTime.pageCount;
			for(var i:int = 1; i <= count; i ++)
			{
				pageMap[i] = getPageIndex(i);
			}
		}
		
		public static function findPage(pageLayoutIndex:int, max:Boolean = true):int
		{
			var count:int = RunTime.pageCount;
			var pages:Array = [];
			for(var i:int = 1; i <= count; i ++)
			{
				if(pageMap[i] == pageLayoutIndex)
				{
					pages.push(i);
				}
			}
			
			if(pages.length == 1)
			{
				return pages[0];
			}
			else if(pages.length == 2)
			{
				if(max == true)
				{
					return Math.max(pages[0],pages[1]);
				}
				else
				{
					return Math.min(pages[0],pages[1]);
				}
			}
			else
			{
				return -1;
			}
		}
	}
}