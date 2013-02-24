package core;

/**
 * ...
 * @author 
 */

class PagePair 
{
	public var leftPage:Page;
	public var rightPage:Page;

	public var currentPageNum:Int;
	
	public function new(i:Int) 
	{
		if (i < 0 || i >= RunTime.book.pages.length) return;

		this.currentPageNum = i;
		
		if (i == 0)	// 首页
		{
			rightPage = RunTime.book.pages[i];
			rightPage.isDoublePageMode = true;
			rightPage.pageOffset = 0;
			rightPage.drawParams = RunTime.getDrawParams(1);
			RunTime.flipBook.zoomRightPage.width = Std.int(rightPage.drawParams.dw);
			RunTime.flipBook.zoomRightPage.height = Std.int(rightPage.drawParams.dh);
			RunTime.flipBook.zoomRightPage.style.left = Std.string(rightPage.drawParams.dx) + "px";
			RunTime.flipBook.zoomRightPage.style.top = Std.string(rightPage.drawParams.dy) + "px";
			
			RunTime.flipBook.rightPageLock.style.width = Std.int(rightPage.drawParams.dw) + "px";
			RunTime.flipBook.rightPageLock.style.height = Std.int(rightPage.drawParams.dh) + "px";
			RunTime.flipBook.rightPageLock.style.left = Std.string(rightPage.drawParams.dx) + "px";
			RunTime.flipBook.rightPageLock.style.top = Std.string(rightPage.drawParams.dy) + "px";
		}
		else if (i == RunTime.book.pages.length - 1 && i%2 == 1) // 只有末页
		{
			leftPage = RunTime.book.pages[i];
			leftPage.isDoublePageMode = true;
			leftPage.pageOffset = 0;
			leftPage.drawParams =  RunTime.getDrawParams( -1);
			RunTime.flipBook.zoomLeftPage.width = Std.int(leftPage.drawParams.dw);
			RunTime.flipBook.zoomLeftPage.height = Std.int(leftPage.drawParams.dh);
			RunTime.flipBook.zoomLeftPage.style.left = Std.string(leftPage.drawParams.dx) + "px";
			RunTime.flipBook.zoomLeftPage.style.top = Std.string(leftPage.drawParams.dy) + "px";
			
			RunTime.flipBook.leftPageLock.style.width = Std.int(leftPage.drawParams.dw) + "px";
			RunTime.flipBook.leftPageLock.style.height = Std.int(leftPage.drawParams.dh) + "px";
			RunTime.flipBook.leftPageLock.style.left = Std.string(leftPage.drawParams.dx) + "px";
			RunTime.flipBook.leftPageLock.style.top = Std.string(leftPage.drawParams.dy) + "px";
		}
		else
		{
			var right:Int = i + 1 - (i + 1) % 2;
			var left:Int = right - 1;
			leftPage = RunTime.book.pages[left];
			rightPage = RunTime.book.pages[right];
			leftPage.isDoublePageMode = true;
			rightPage.isDoublePageMode = true;
			leftPage.pageOffset = 0;
			rightPage.pageOffset = 0;
			leftPage.drawParams = RunTime.getDrawParams(-1);
			rightPage.drawParams =  RunTime.getDrawParams(1);
			
			RunTime.flipBook.zoomRightPage.width = Std.int(rightPage.drawParams.dw);
			RunTime.flipBook.zoomRightPage.height = Std.int(rightPage.drawParams.dh);
			RunTime.flipBook.zoomRightPage.style.left = Std.string(rightPage.drawParams.dx) + "px";
			RunTime.flipBook.zoomRightPage.style.top = Std.string(rightPage.drawParams.dy) + "px";
			RunTime.flipBook.zoomLeftPage.width = Std.int(leftPage.drawParams.dw);
			RunTime.flipBook.zoomLeftPage.height = Std.int(leftPage.drawParams.dh);
			RunTime.flipBook.zoomLeftPage.style.left = Std.string(leftPage.drawParams.dx) + "px";
			RunTime.flipBook.zoomLeftPage.style.top = Std.string(leftPage.drawParams.dy) + "px";
			
			RunTime.flipBook.rightPageLock.style.width = Std.int(rightPage.drawParams.dw) + "px";
			RunTime.flipBook.rightPageLock.style.height = Std.int(rightPage.drawParams.dh) + "px";
			RunTime.flipBook.rightPageLock.style.left = Std.string(rightPage.drawParams.dx) + "px";
			RunTime.flipBook.rightPageLock.style.top = Std.string(rightPage.drawParams.dy) + "px";
			
			RunTime.flipBook.leftPageLock.style.width = Std.int(leftPage.drawParams.dw) + "px";
			RunTime.flipBook.leftPageLock.style.height = Std.int(leftPage.drawParams.dh) + "px";
			RunTime.flipBook.leftPageLock.style.left = Std.string(leftPage.drawParams.dx) + "px";
			RunTime.flipBook.leftPageLock.style.top = Std.string(leftPage.drawParams.dy) + "px";
		}
	}
	
	public function match(pageNum:Int):Int
	{
		if (leftPage != null)
		{
			if (leftPage.num == pageNum) return -1;
		}
		
		if (rightPage != null)
		{
			if (rightPage.num == pageNum) return 1;
		}
		
		return 0;
	}
	
	public function getNumInDoubleMode():Int
	{
		if (leftPage != null) return leftPage.numInDoubleMode;
		else if (rightPage != null) return rightPage.numInDoubleMode;
		else return -1;
	}
}