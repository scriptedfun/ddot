package ;

import com.scriptedfun.ddot.Config;
import com.scriptedfun.ddot.Constants;
import com.scriptedfun.ddot.onebusaway.objects.Arrival;
import com.scriptedfun.ddot.onebusaway.objects.Route;
import com.scriptedfun.ddot.onebusaway.OneBusAway;
import com.scriptedfun.Utils;
import haxe.Template;
import php.Lib;
import php.Web;
import sys.io.File;

/**
 * ...
 * @author Chuck Arellano scriptedfun@gmail.com
 */

class Main 
{
	
	static function main() 
	{
		SMSReply;
		
		var configRest:Config = new Config(Constants.FILE_REST);
		var oneBusAway:OneBusAway = new OneBusAway(configRest.config.path, configRest.config.extension);
		
		var routeId:String = Web.getParams().get("route");
		if (routeId == null)
		{
			var agency:String = new Config(Constants.FILE_AGENCY).config.agency;
			var routesTemplate:Template = new Template(File.getContent("templates/routes.txt"));
			Lib.print(routesTemplate.execute({routes : Utils.sortedArrayFromHash(oneBusAway.getRoutesForAgency(agency), Route.sortFunc)}));
			return;
		}
		
		var stopId:String = Web.getParams().get("stop");
		if (stopId == null)
		{
			var stopsTemplate:Template = new Template(File.getContent("templates/stops.txt"));
			Lib.print(stopsTemplate.execute({routeId : routeId, stopGroups : oneBusAway.getStopsForRoute(routeId)}));
			return;
		}
		
		var arrivals:Array<Arrival> = oneBusAway.getArrivalsAndDeparturesForStop(stopId);
		var arrivalsTemplate:Template = new Template(File.getContent("templates/arrivals.txt"));
		
		var count:Int = arrivals.length;
		var first:Arrival = count == 0 ? null : arrivals[0];
		
		Lib.print(arrivalsTemplate.execute({routeId : routeId, stopId : stopId, count : count, first : first, upcoming : arrivals}));
	}
	
}