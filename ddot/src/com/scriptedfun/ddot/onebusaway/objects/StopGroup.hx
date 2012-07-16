package com.scriptedfun.ddot.onebusaway.objects;

import com.scriptedfun.Utils;

/**
 * ...
 * @author Chuck Arellano scriptedfun@gmail.com
 */

class StopGroup 
{
	
	public var name(default, null):String;
	public var stops(default, null):Hash<Stop>;
	public var stopsArray(default, null):Array<Stop>;
	
	static public function sortFunc(x:StopGroup, y:StopGroup):Int
	{
		return x.name < y.name ? -1 : x.name > y.name ? 1 : 0;
	}
	
	public function new(newName:String, newStops:Hash<Stop>) 
	{
		name = newName;
		stops = newStops;
		stopsArray = Utils.sortedArrayFromHash(stops, Stop.sortFunc);
	}
	
}