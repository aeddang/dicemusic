﻿package com.libs.utils
{
	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	public class ColorFilter
	{
		public static function grayScale(data:BitmapData):BitmapData
		{
			var rLum : Number = 0.2225;
			var gLum : Number = 0.7169;
			var bLum : Number = 0.0606; 	
			var matrix:Array = [ rLum, gLum, bLum, 0, 0,
				rLum, gLum, bLum, 0, 0,
				rLum, gLum, bLum, 0, 0,
				0,    0,    0,    1, 0 ];
			
			var filter:ColorMatrixFilter = new ColorMatrixFilter( matrix );
			data.applyFilter( data, new Rectangle( 0,0,data.width,data.height ), new Point(0,0), filter );
			return data
		}
		
		public static function monoChrome(data:BitmapData, level:uint = 0xFF999999):BitmapData {
			var rect:Rectangle = new Rectangle(0,0,data.width,data.height);
			var dest:Point = new Point();
			data.threshold(data, rect, dest, ">", level, 0xFFFFFFFF, 0xFFFFFFFF);
			data.threshold(data, rect, dest, "<=", level, 0xFF000000, 0xFFFFFFFF);
			return data
		}
		
		public static function monoChromeByColorRange(data:BitmapData, rangeMin:uint = 0x000000, rangeMax:uint = 0xFFFFFF):BitmapData{
			var w:int = data.width
			var h:int = data.height
			var len:int = w * h
			data.lock();   
			for(var i:int=0;i<len;++i){
				var tx:int=i%w
				var ty:int=Math.floor(i/w)
				var color:uint =	data.getPixel(tx,ty)
				if(color > rangeMin && rangeMin < rangeMax){
					data.setPixel(tx, ty, 0xFF000000)
				}else {
					data.setPixel(tx, ty, 0xFFFFFFFF)
				}
			}
			data.unlock()
			return data
		}
		
		public static function monoChromeByHueRange(data:BitmapData, rangeMin:uint = 0, rangeMax:uint = 255, minSaturation:int = 40):BitmapData{
			var w:int = data.width
			var stack:int = 0
			var num:int = 0
			var len:int = w * data.height
			data.lock();   
			var dr:uint = 256 *256 
			var dg:uint = 256 
			var db:uint = 256 
			for(var i:int=0;i<len;++i){
				var tx:int=i%w
				var ty:int=Math.floor(i/w)
				var color:uint = data.getPixel(tx,ty)
				var r:uint = (color/dr) % db//uintToInt ( color.slice(0,2) )
				var g:uint = (color/dg) % db//uintToInt ( color.slice(2,4) )
				var b:uint = color % db//uintToInt ( color.slice(4,6) )
				var hvs:Object = getHSVfromRGB( r, g, b )
				var h:int = hvs.h
				var s:int = hvs.s
					
				//trace("color: " + color +" r:" + r + " g:"+g +" b:"+b)
				if(h >= rangeMin && h <= rangeMax && s > minSaturation){
					stack += h
					num++
					data.setPixel(tx, ty, 0x000000)
				}else {
					data.setPixel(tx, ty, 0xffffff)
				}
			}
			
			data.unlock()
			return data
		}
		
		private static function getHSVfromRGB( r:uint, g:uint, b:uint ):Object
		{
			var max:uint = Math.max( r, g, b );
			var min:uint = Math.min( r, g, b );
			
			var hsv:Object = {h:0, s:0, v:0};
			if(max == 0) return hsv
			
			var hue:Number = 0;
			var saturation:Number = 0;
			var value:Number = 0;
			
			//get Value
			value = max;
			//get Saturation
			saturation = 255*( max - min ) / value;
			if(saturation == 0) return hsv
				
			//get Hue
			if( max == min ) hue = 0;
			else if( max == r ) hue = 0 + 43*Math.abs(g - b)/(max - min)
			else if( max == g ) hue = 85 + 43*Math.abs(b - r)/(max - min);
			else if( max == b ) hue = 171 + 43*Math.abs(r - g)/(max - min);
			hsv.h = Math.round(hue);
			hsv.s = Math.round(saturation)
			hsv.v = Math.round(value);
			return hsv;
		}
		
		
		public static function uintToInt (s:String):int
		{
			
			var n:int;
			var n0:int = codeToInt(s.slice(0,1));
			var n1:int = codeToInt(s.slice(1,2));
			n = n0 * 16 + n1;
			return n;
		}
		
		private static function codeToInt (s:String):int
		{
			var n:int;
			var k;
			switch (s.toLowerCase())
			{
				case "a" : n = 10; break;
				case "b" : n = 11; break;
				case "c" : n = 12; break;
				case "d" : n = 13; break;
				case "e" : n = 14; break;
				case "f" : n = 15;break;
				default : n = int(s); break;
			}
			return n;
		}
		
		
	}
}