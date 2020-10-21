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
	
	import classes.model.DetectData;
	
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
		
		public function init(_cameraFile:String, _codeFile:String, _canvasWidth:int = 320, _canvasHeight:int = 240, _codeWidth:int = 80):void {
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
			var scale:Number = 394/500 * 100
			code = new FLARCode(16, 16, scale, scale);
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
		public function detect(bitmapData:BitmapData, color:int, dice:int, minConfidence:Number = 0.80):DetectData{
			capture.bitmapData.draw(bitmapData)
			var detected:Boolean = false;
			var confidence:Number = 0
			try {
				var find:Boolean = false
				if(minConfidence == 0) {
					find = detector.detectSquareLite(raster, codeWidth)
					confidence = 0
					//if(find) trace( "find rect color : "+ color)
				}
				else {
					
					find = detector.detectMarkerLite(raster, codeWidth)
					confidence = detector.getConfidence()
				}
				
				if( confidence >= 0.5 && find == true ){
					///trace( "color : "+ color +" ************* dice : "+ dice)
					//trace( "confidence : " +find+" "+confidence)
				}
				detected = find && confidence >= minConfidence;
				
			} catch (e:Error) {
				trace( "error : " +e.message)
				return null
			}
			if(detected){
				if(confidence!=0) detector.getTransformMatrix(resultMat)
				var result:DetectData = new DetectData()
				result.confidence = confidence
				result.color = color
				result.idx = dice
				result.mat = resultMat
				result..tx = (bitmapData.width/2) - resultMat.m03
				result.ty = (bitmapData.height/2) + resultMat.m13	
				return result
			}else{
				return null
			}
			
		
		}
	}
}









