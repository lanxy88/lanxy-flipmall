package core;
import haxe.Timer;

/**
 * ...
 * @author 
 */

class Tweener 
{
	private var count:Int;
	
	private var maxCount:Int;
	
	public var onChange:Int->Void;
	
	public function new() 
	{
		count = 0;
		maxCount = 0;
	}
	
	public function start(max:Int = 1):Void
	{
		maxCount = max;
		count = 0;
		run();
	}
	
	public function stop():Void
	{
		maxCount = count;
	}
	
	private function run():Void
	{
		if (count >= maxCount) return;
		Timer.delay(onChangeInvoke, 33);
	}
	
	private function onChangeInvoke():Void
	{
		count ++;
		
		if (onChange == null) return;
		if (count > maxCount) return;
		
		onChange(count);		
		run();
	}
}