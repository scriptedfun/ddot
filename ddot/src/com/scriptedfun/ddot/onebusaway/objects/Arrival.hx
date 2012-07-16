package com.scriptedfun.ddot.onebusaway.objects;

/**
 * ...
 * @author Chuck Arellano scriptedfun@gmail.com
 */

class Arrival 
{
	
	public var numberOfStopsAway(default, null):Int;
	public var route(default, null):Route;
	public var arrivalDelta(default, null):Int;
	public var arrivalDeltaMinutes(default, null):Int;
	public var trip(default, null):Trip;
	public var predicted(default, null):Bool;
	public var stop(default, null):Stop;
	public var lon(default, null):Float;
	public var lat(default, null):Float;
	public var orientation(default, null):Float;
	public var closestStop(default, null):Stop;
	public var scheduleDeviation(default, null):Float;
	
	static public function sortFunc(x:Arrival, y:Arrival):Int
	{
		return x.arrivalDelta - y.arrivalDelta;
	}
	
	public function new
	(
		newNumberOfStopsAway:Int,
		newRoute:Route,
		newArrivalDelta:Int,
		newTrip:Trip,
		newPredicted:Bool,
		newStop:Stop,
		newLon:Float,
		newLat:Float,
		newOrientation:Float,
		newClosestStop:Stop,
		newScheduleDeviation:Float
	) 
	{
		numberOfStopsAway = newNumberOfStopsAway;
		route = newRoute;
		arrivalDelta = newArrivalDelta;
		trip = newTrip;
		predicted = newPredicted;
		stop = newStop;
		lon = newLon;
		lat = newLat;
		orientation = newOrientation;
		closestStop = newClosestStop;
		scheduleDeviation = newScheduleDeviation;
		
		arrivalDeltaMinutes = Math.ceil(arrivalDelta / 60000);
	}
	
}