package classes.flar
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import org.libspark.flartoolkit.core.FLARCode;
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.core.raster.rgb.FLARRgbRaster_BitmapData;
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	import org.libspark.flartoolkit.detector.FLARSingleMarkerDetector;
	import org.libspark.flartoolkit.support.pv3d.FLARBaseNode;
	import org.libspark.flartoolkit.support.pv3d.FLARCamera3D;
	import org.papervision3d.render.LazyRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	
	
	public class MakerDetector extends EventDispatcher
	{
		private var loader:URLLoader;
		private var cameraFile:String;
		private var codeFile:String;
		private var codeWidth:int;
		private var canvasWidth:int;
		private var canvasHeight:int;
		private var param:FLARParam;
		private var code:FLARCode;
		private var raster:FLARRgbRaster_BitmapData;
		private var detector:FLARSingleMarkerDetector;
		private var capture:Bitmap;
		
		public function MakerDetector()
		{
		}
		
		public function init(_cameraFile:String, _codeFile:String, _codeWidth:int = 80, _canvasWidth:int = 320, _canvasHeight:int = 240):void {
			cameraFile = _cameraFile;
			codeFile = _codeFile;
			codeWidth = _codeWidth;
			canvasWidth = _canvasWidth;
			canvasHeight = _canvasHeight;
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, onLoadParam);
			loader.addEventListener(IOErrorEvent.IO_ERROR, dispatchEvent);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, dispatchEvent);
			loader.load(new URLRequest(_cameraFile));
		}
		
		private function onLoadParam(e:Event):void {
			loader.removeEventListener(Event.COMPLETE, onLoadParam);
			param = new FLARParam();
			param.loadARParam(loader.data);
			param.changeScreenSize(canvasWidth, canvasHeight);
			
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onLoadCode);
			loader.load(new URLRequest(codeFile));
		}
		
		private function onLoadCode(e:Event):void {
			code = new FLARCode(16, 16);
			code.loadARPatt(loader.data);
			
			loader.removeEventListener(Event.COMPLETE, onLoadCode);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, dispatchEvent);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, dispatchEvent);
			loader = null;
			
			capture = new Bitmap(new BitmapData(canvasWidth, canvasHeight, false, 0), PixelSnapping.AUTO, true);
			raster = new FLARRgbRaster_BitmapData(capture.bitmapData);
			detector = new FLARSingleMarkerDetector(param, code, codeWidth);
			detector.setContinueMode(true);
			dispatchEvent(new Event(Event.INIT));
		}
		
		private var resultMat:FLARTransMatResult = new FLARTransMatResult();
		public function detect(bitmapData:BitmapData):FLARTransMatResult{
			capture.bitmapData.draw(bitmapData)
			var detected:Boolean = false;
			try {
				
				detected = detector.detectMarkerLite(raster, 80) && detector.getConfidence() > 0.5;
			} catch (e:Error) {
				return null
			}
			if(detected){
				detector.getTransformMatrix(resultMat)
				trace( "resultMat.x : " +resultMat.m03)
				trace( "resultMat.y : " +resultMat.m13)
				return resultMat
			}else{
				return null
			}
			
		
		}
	}
}









