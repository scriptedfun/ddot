package com.scriptedfun.ddot;

import haxe.Json;
import sys.io.File;

/**
 * ...
 * @author Chuck Arellano scriptedfun@gmail.com
 */

class Config 
{
	
	public var config(default, null):Dynamic;
	
	public function new(filename:String) 
	{
		config = Json.parse(File.getContent(Std.format("config/$filename.json")));
	}
	
}