package com.scriptedfun.ddot.onebusaway;

import com.scriptedfun.ddot.Config;
import com.scriptedfun.ddot.Constants;
import com.scriptedfun.ddot.onebusaway.objects.Arrival;
import com.scriptedfun.ddot.onebusaway.objects.Route;
import com.scriptedfun.ddot.onebusaway.objects.Stop;
import com.scriptedfun.ddot.onebusaway.objects.StopGroup;
import com.scriptedfun.ddot.onebusaway.objects.Trip;
import com.scriptedfun.Utils;
import haxe.Http;
import haxe.Json;

/**
 * ...
 * @author Chuck Arellano scriptedfun@gmail.com
 */

class OneBusAway 
{
	
	private var _apiPath:String;
	private var _apiExtension:String;
	private var _busCodes:Hash<String>;
	
	public function new(apiPath:String, apiExtension:String) 
	{
		_apiPath = apiPath;
		_apiExtension = apiExtension;
	}
	
	public function callMethod(method:String):Dynamic
	{
		return Json.parse(Http.requestUrl(Std.format("$_apiPath$method$_apiExtension")));
	}
	
	public function getAgenciesWithCoverage():Array<String>
	{
		var agencies:Array<String> = new Array<String>();
		for (agency in cast(Utils.reflectFieldChain(callMethod("agencies-with-coverage"), ["data", "references", "agencies"]), Array<Dynamic>))
		{
			agencies.push(agency.id);
		}
		return agencies;
	}
	
	public function getArrivalsAndDeparturesForStop(id:String):Array<Arrival>
	{
		var response:Dynamic = callMethod(Std.format("arrivals-and-departures-for-stop/$id"));
		var routes:Hash<Route> = _dynamicToRoutes(Utils.reflectFieldChain(response, ["data", "references", "routes"]));
		var stops:Hash<Stop> = _dynamicToStops(Utils.reflectFieldChain(response, ["data", "references", "stops"]), routes);
		var trips:Hash<Trip> = _dynamicToTrips(Utils.reflectFieldChain(response, ["data", "references", "trips"]), routes);
		var currentTime:Int = Reflect.field(response, "currentTime");
		
		var arrivals:Array<Arrival> = new Array<Arrival>();
		for (arrival in cast(Utils.reflectFieldChain(response, ["data", "entry", "arrivalsAndDepartures"]), Array<Dynamic>))
		{
			var predicted:Bool = cast(Std.parseInt(arrival.predicted), Bool);
			var arrivalTime:Int = Std.parseInt(predicted ? arrival.predictedArrivalTime : arrival.scheduledArrivalTime);
			arrivals.push(new Arrival(Std.parseInt(arrival.numberOfStopsAway), routes.get(arrival.routeId), arrivalTime - currentTime, trips.get(arrival.tripId), predicted, stops.get(arrival.stopId), Std.parseFloat(arrival.tripStatus.position.lon), Std.parseFloat(arrival.tripStatus.position.lat), Std.parseFloat(arrival.tripStatus.orientation), stops.get(arrival.tripStatus.closestStop), Std.parseInt(arrival.tripStatus.scheduleDeviation)));
		}
		
		arrivals.sort(Arrival.sortFunc);
		return arrivals;
	}
	
	public function getArrivalsAndDeparturesForStopCode(code:String):Array<Arrival>
	{
		var id:String = _getKeyForBusCode(code);
		if (id == null) return null;
		return getArrivalsAndDeparturesForStop(id);
	}
	
	public function getRoutesForAgency(id:String):Hash<Route>
	{
		return _dynamicToRoutes(Utils.reflectFieldChain(callMethod(Std.format("routes-for-agency/$id")), ["data", "list"]));
	}
	
	public function getStopsForRoute(id:String):Array<StopGroup>
	{
		var response:Dynamic = callMethod(Std.format("stops-for-route/$id"));
		var stops:Hash<Stop> = _dynamicToStops(Utils.reflectFieldChain(response, ["data", "references", "stops"]), _dynamicToRoutes(Utils.reflectFieldChain(response, ["data", "references", "routes"])));
		
		var stopGroups:Array<StopGroup> = new Array<StopGroup>();
		for (stopGrouping in cast(Utils.reflectFieldChain(response, ["data", "entry", "stopGroupings"]), Array<Dynamic>))
		{
			for (stopGroup in cast(Reflect.field(stopGrouping, "stopGroups"), Array<Dynamic>))
			{
				var stopsInGroup:Hash<Stop> = new Hash<Stop>();
				for (stopId in cast(Reflect.field(stopGroup, "stopIds"), Array<Dynamic>))
				{
					stopsInGroup.set(stopId, stops.get(stopId));
				}
				stopGroups.push(new StopGroup(Utils.reflectFieldChain(stopGroup, ["name", "name"]), stopsInGroup));
			}
		}
		
		stopGroups.sort(StopGroup.sortFunc);
		return stopGroups;
	}
	
	public function getTripsForRoute(id:String):Hash<Trip>
	{
		var response:Dynamic = callMethod(Std.format("trips-for-route/$id"));
		return _dynamicToTrips(Utils.reflectFieldChain(response, ["data", "references", "trips"]), _dynamicToRoutes(Utils.reflectFieldChain(response, ["data", "references", "routes"])));
	}
	
	private function _dynamicToRoutes(o:Dynamic):Hash<Route>
	{
		var routes:Hash<Route> = new Hash<Route>();
		for (route in cast(o, Array<Dynamic>))
		{
			routes.set(route.id, new Route(route.id, route.longName, Std.parseInt(route.shortName)));
		}
		return routes;
	}
	
	private function _dynamicToStops(o:Dynamic, routes:Hash<Route>):Hash<Stop>
	{
		var stops:Hash<Stop> = new Hash<Stop>();
		for (stop in cast(o, Array<Dynamic>))
		{
			var routesForStop:Hash<Route> = new Hash<Route>();
			for (routeId in cast(Reflect.field(stop, "routeIds"), Array<Dynamic>))
			{
				routesForStop.set(routeId, routes.get(routeId));
			}
			stops.set(stop.id, new Stop(stop.code, stop.id, Std.parseFloat(stop.lat), Std.parseFloat(stop.lon), stop.name, routesForStop));
		}
		return stops;
	}
	
	private function _dynamicToTrips(o:Dynamic, routes:Hash<Route>):Hash<Trip>
	{
		var trips:Hash<Trip> = new Hash<Trip>();
		for (trip in cast(o, Array<Dynamic>))
		{
			trips.set(trip.id, new Trip(trip.id, trip.tripHeadsign, routes.get(trip.routeId)));
		}
		return trips;
	}
	
	private function _getKeyForBusCode(code:String):String
	{
		if (_busCodes == null)
		{
			var busCodesDynamic:Dynamic = new Config(Constants.FILE_STOPCODES).config;
			_busCodes = new Hash<String>();
			for (busCode in Reflect.fields(busCodesDynamic))
			{
				_busCodes.set(busCode, Reflect.field(busCodesDynamic, busCode));
			}
		}
		
		return _busCodes.get(code);
	}
	
}