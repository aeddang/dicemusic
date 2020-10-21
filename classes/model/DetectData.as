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
		public var confidence:Number = 0
		public var tx:int = -1	
		public var ty:int = -1	
		public var r:int = 0	
		public function DetectData()
		{
		}
		
	}
}