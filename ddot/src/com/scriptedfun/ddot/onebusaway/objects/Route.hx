package com.scriptedfun.ddot.onebusaway.objects;

/**
 * ...
 * @author Chuck Arellano scriptedfun@gmail.com
 */

class Route 
{
	
	public var id(default, null):String;
	public var longName(default, null):String;
	public var shortName(default, null):Int;
	
	static public function sortFunc(x:Route, y:Route):Int
	{
		return x.shortName - y.shortName;
	}
	
	public function new(newId:String, newLongName:String, newShortName:Int) 
	{
		id = newId;
		longName = newLongName;
		shortName = newShortName;
	}
	
}