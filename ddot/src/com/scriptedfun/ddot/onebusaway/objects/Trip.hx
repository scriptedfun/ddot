package com.scriptedfun.ddot.onebusaway.objects;

/**
 * ...
 * @author Chuck Arellano scriptedfun@gmail.com
 */

class Trip 
{
	
	public var id(default, null):String;
	public var tripHeadsign(default, null):String;
	public var route(default, null):Route;
	
	static public function sortFunc(x:Trip, y:Trip):Int
	{
		return x.tripHeadsign < y.tripHeadsign ? -1 : x.tripHeadsign > y.tripHeadsign ? 1 : 0;
	}
	
	public function new(newId:String, newTripHeadsign:String, newRoute:Route) 
	{
		id = newId;
		tripHeadsign = newTripHeadsign;
		route = newRoute;
	}
	
}