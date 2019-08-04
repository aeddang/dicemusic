package classes.model
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	
	public class DetectData
	{
		private static const COLOR_EXCUTE_RANGE:int = 10
		
		public var mat:FLARTransMatResult = null
		public var idx:int = 0
		public var color:int = 3
		public var tx:int = -1	
		public var ty:int = -1	
		public function DetectData()
		{
		}
		
		public function detectColor(data:BitmapData):Rectangle{
			var rect:Rectangle = new Rectangle()
				
			var sx:int = tx - COLOR_EXCUTE_RANGE  
			var ex:int = tx + COLOR_EXCUTE_RANGE
			var sy:int = ty - COLOR_EXCUTE_RANGE  
			var ey:int = ty + COLOR_EXCUTE_RANGE
			sx = (sx<0) ? 0 : sx
			sy = (sy<0) ? 0 : sy
			ex = (ex>data.width) ? data.width : ex
			ey = (ey>data.height) ? data.height : ey
			var w:int = ex-sx
			var h:int = ey-sy
			var size:int = w * h
			rect.x = sx
			rect.y = sy
			rect.width = w
			rect.height = h
			for(var i:int=0; i< size; ++i){
				var cx:int = sx + (i%w)
				var cy:int = sy + Math.floor(i/w)
				var pixel:String = data.getPixel(cx,cy).toString(16) 
				var r:String = pixel.slice(0,2)	
				var g:String = pixel.slice(2,4)	
				var b:String = pixel.slice(4)	
				var hsv = RGBtoHSV( uint(r), uint(g), uint(b) )
				//trace("h : " +hsv.h+" s: "+hsv.s +" v: "+hsv.v)
				//diff = int(color).toString(10)
			}	
			return rect
		}
		
		private function RGBtoHSV( r:uint, g:uint, b:uint ):Object
		{
			var max:uint = Math.max( r, g, b );
			var min:uint = Math.min( r, g, b );
			
			var hue:Number = 0;
			var saturation:Number = 0;
			var value:Number = 0;
			
			//get Hue
			if( max == min )
				hue = 0;
			else if( max == r )
				hue = ( 60 * ( g - b ) / ( max - min ) + 360 ) % 360;
			else if( max == g )
				hue = ( 60 * ( b - r ) / ( max - min ) + 120 );
			else if( max == b )
				hue = ( 60 * ( r - g ) / ( max - min ) + 240 );
			
			//get Value
			value = max;
			
			//get Saturation
			if(max == 0){
				saturation = 0;
			}else{
				saturation = ( max - min ) / max;
			}
			
			var hsv:Object = {};
			hsv.h = Math.round(hue);
			hsv.s = Math.round(saturation * 100);
			hsv.v = Math.round(value / 255 * 100);
			return hsv;
		}
	}
}