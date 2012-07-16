package com.scriptedfun.ddot.onebusaway.objects;

/**
 * ...
 * @author Chuck Arellano scriptedfun@gmail.com
 */

class Stop 
{
	
	public var code(default, null):String;
	public var id(default, null):String;
	public var lat(default, null):Float;
	public var lon(default, null):Float;
	public var name(default, null):String;
	public var routes(default, null):Hash<Route>;
	
	static public function sortFunc(x:Stop, y:Stop):Int
	{
		return x.name < y.name ? -1 : x.name > y.name ? 1 : 0;
	}
	
	public function new(newCode:String, newId:String, newLat:Float, newLon:Float, newName:String, newRoutes:Hash<Route>) 
	{
		code = newCode;
		id = newId;
		lat = newLat;
		lon = newLon;
		name = newName;
		routes = newRoutes;
	}
	
}