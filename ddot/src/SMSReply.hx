package ;

import com.scriptedfun.ddot.Config;
import com.scriptedfun.ddot.Constants;
import com.scriptedfun.ddot.onebusaway.objects.Arrival;
import com.scriptedfun.ddot.onebusaway.OneBusAway;
import haxe.Template;
import php.Lib;
import php.Web;

/**
 * ...
 * @author Chuck Arellano scriptedfun@gmail.com
 */

class SMSReply 
{

	static function main() 
	{
		var configRest:Config = new Config(Constants.FILE_REST);
		var configSms:Config = new Config(Constants.FILE_SMS);
		
		var oneBusAway:OneBusAway = new OneBusAway(configRest.config.path, configRest.config.extension);
		
		var invalidCode:Template = new Template(configSms.config.invalidCode);
		var noArrival:Template = new Template(configSms.config.noArrival);
		var firstArrival:Template = new Template(configSms.config.firstArrival);
		var upcomingArrival:Template = new Template(configSms.config.upcomingArrival);
		var xmlResponse:Template = new Template(configSms.config.xmlResponse);
		
		var texts:Array<String> = new Array<String>();
		for (code in cast(Web.getParams().get("Body"), String).split(configSms.config.delimiter))
		{
			code = code.toUpperCase();
			if (code.length == 0) continue;
			
			var arrivals:Array<Arrival> = oneBusAway.getArrivalsAndDeparturesForStopCode(code);
			if (arrivals == null)
			{
				texts.push(invalidCode.execute({code : code}));
				continue;
			}
			
			if (arrivals.length == 0)
			{
				texts.push(noArrival.execute({code : code}));
				continue;
			}
			
			var first:Arrival = arrivals[0];
			texts.push(firstArrival.execute({stop : first.stop}));
			
			for (arrival in arrivals)
			{
				texts.push(upcomingArrival.execute({arrival : arrival}));
			}
		}
		
		if (texts.length == 0)
		{
			texts.push(configSms.config.noText);
		}
		
		var message:String = texts.join(configSms.config.textDelimiter);
		var parts:Array<String> = new Array<String>();
		var maxLength:Int = Std.parseInt(configSms.config.maxLength);
		
		if (message.length > maxLength)
		{
			var truncLength:Int = Std.parseInt(configSms.config.truncLength);
			while (message.length > truncLength)
			{
				parts.push(message.substr(0, truncLength));
				message = message.substr(truncLength);
			}
		}
		parts.push(message);
		
		var total:Int = parts.length;
		if (total > 1)
		{
			var truncLabel:Template = new Template(configSms.config.truncLabel);
			var newParts:Array<String> = new Array<String>();
			var page:Int = 0;
			for (part in parts)
			{
				page++;
				newParts.push(truncLabel.execute({page : page, total : total, message : part}));
			}
			parts = newParts;
		}
		
		var escaped:Array<String> = new Array<String>();
		for (part in parts)
		{
			escaped.push(StringTools.htmlEscape(part));
		}
		
		Web.setHeader("Content-type", "text/xml");
		Lib.print(xmlResponse.execute({parts : escaped}));
	}
	
}