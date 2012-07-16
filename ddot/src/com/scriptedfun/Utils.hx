package com.scriptedfun;

/**
 * ...
 * @author Chuck Arellano scriptedfun@gmail.com
 */

class Utils 
{

	public function new() 
	{
		
	}
	
	static public function reflectFieldChain(o:Dynamic, fields:Array<String>):Dynamic
	{
		for (field in fields)
		{
			o = Reflect.field(o, field);
		}
		return o;
	}
	
	static public function sortedArrayFromHash<T>(hash:Hash<T>, sortFunc:T->T->Int):Array<T>
	{
		var result:Array<T> = new Array<T>();
		for (value in hash)
		{
			result.push(value);
		}
		result.sort(sortFunc);
		return result;
	}
	
}