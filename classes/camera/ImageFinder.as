package classes.camera
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.utils.Timer;
	import com.libs.utils.ColorFilter
	import classes.model.DetectData;

	public class ImageFinder extends EventDispatcher
	{
		private var camera:Camera;
		private var video:Video;
		private var capture:Bitmap;
		private var canvasWidth:int;
		private var canvasHeight:int;
		private var fps:int;
		private var timer:Timer
		
		public function ImageFinder()
		{
		}
		
		public function init(_canvasWidth:int = 240, _canvasHeight:int = 160, _fps:int = 12):void{
			canvasWidth = _canvasWidth;
			canvasHeight = _canvasHeight;
			fps = _fps;
			capture = new Bitmap(new BitmapData(canvasWidth, canvasHeight, true, 0), PixelSnapping.AUTO, true);
		}
		
		public function start(period:Number = 50){
			if(camera != null) return
			
			camera = Camera.getCamera();
			if (!camera) {
				throw new Error('No camera!!!!');
			}
			camera.setMode(canvasWidth, canvasHeight, fps);
			video = new Video(canvasWidth, canvasHeight);
			video.attachCamera(camera);
			status = INIT
			prevData = null
			initData = null
			
			removeTimer()
			timer = new Timer(period)
			timer.addEventListener(TimerEvent.TIMER, onFind)
			timer.start()
			reset()
		}
		
		public function end(){
			if(video != null){
				video.attachCamera(null)
			}
			camera = null;
			video = null;
			removeTimer()
		}
		
		private function removeTimer(){
			if(timer == null) return
			timer.removeEventListener(TimerEvent.TIMER, onFind)
			timer.stop()
			timer = null
		}
		
		private function onFind(e:Event):void {
			capture.bitmapData.draw(video);
			compare(capture.bitmapData)
			//dispatchEvent(new FinderEvent(FinderEvent.CAPTURE, capture.bitmapData))	
			
		}
		
		
		private static const MIN_SIMILARITY:int = 5
		private static const MIN_FIX_STACK:int = 10
		private static const MIN_CHANGE_STACK:int = 1
		private static const MIN_RETRY_STACK:int = 10 * 5
		private static const MIN_RESET_STACK:int = 10 * 10
		private static const COMPARE_SIMILARITY_PIXEL:int = 2
		
		private var prevData:BitmapData;
		private var initData:BitmapData;
		private var status:String = INIT;
		private var sameComparedStack:int = 0
		private var isSame:Boolean = false;
		private var isDetect:Boolean = true
		private var currentFindStack:Boolean = true;
		private static const INIT:String = "init";
		private static const SETUP:String = "setup";
		private static const FIND:String = "find";
		
		
		private function resetStack(){
			sameComparedStack = 0;
		}
		
		public function pauseDetect(){
			resetStack();
			isDetect = false;
		}
		
		public function resumeDetect(){
			resetStack();
			isDetect = true;
		}
		
		public function findResult(isSuccess:Boolean){
			resetStack();
			isDetect = true;
			if(isSuccess){
				if(status == SETUP) status = FIND
			}
			if(status == SETUP){
				dispatchEvent(new FinderEvent(FinderEvent.SETUP_START))
			}
			else{
				dispatchEvent(new FinderEvent(FinderEvent.FIND_START))
			}
		}
		
		
		public function reset(){
			prevData = null;
			initData = null;
			status = INIT;
			sameComparedStack = 0;
			isSame = false;
			isDetect = true
			currentFindStack = true;
			dispatchEvent(new FinderEvent(FinderEvent.INIT_START))
		}
		
		
		private function compare(data:BitmapData){
			dispatchEvent(new FinderEvent(FinderEvent.CAPTURE,data))
			if(prevData == null){
				prevData =  getCompareData(data)
				return
			}
			if(!isDetect) return
			var compareData = getCompareData(data)
			var current = isSameData(compareData)
			prevData = compareData	
			sameComparedStack = (current == isSame) ? (sameComparedStack+1) : 0
			isSame = current
			var minStack = current ? MIN_FIX_STACK : MIN_CHANGE_STACK
			
			if(sameComparedStack >= minStack){ 
				if(current == currentFindStack){
					resetStack();
					//trace( "stack event " + current)	
					if(current){//화면정지 화면이 움직일때까지 기다림
						currentFindStack = false
						//dispatchEvent(new FinderEvent(FinderEvent.CAPTURE,data.clone()))
						switch(status){
							case INIT:
								status = SETUP
								initData = data.clone()
								dispatchEvent(new FinderEvent(FinderEvent.INIT_COMPLETED, data.clone()))
								dispatchEvent(new FinderEvent(FinderEvent.SETUP_START))
								break;
							case SETUP:
								dispatchEvent(new FinderEvent(FinderEvent.SETUP_COMPLETED, data.clone()))
								break;
							case FIND:
								dispatchEvent(new FinderEvent(FinderEvent.FIND_COMPLETED, data.clone()))
								break;
						}
							
					}else{//화면움직임 감지 화면이 멈출때까지 기다림
						currentFindStack = true
					}
				}else{ 
					//화면상태변화없음
					//trace( "stack unchanged " + current + " " + sameComparedStack)	
					if(sameComparedStack == MIN_RETRY_STACK) dispatchEvent(new FinderEvent(FinderEvent.RETRY))
					if(sameComparedStack >= MIN_RESET_STACK) reset()
				}
			}
			
		}
		
		private function isSameData(data:BitmapData):Boolean{
			var diff = prevData.compare(data)
			if(diff == 0) return true
			var diffBmpData:BitmapData = diff as BitmapData;
			//dispatchEvent(new FinderEvent(FinderEvent.CAPTURE,getResize(diffBmpData, 320,240)))
			var w:int = diffBmpData.width
			var h:int = diffBmpData.height
			var len = w * h
			for(var i:int=0;i<len;++i){
				var tx:int=i%w
				var ty:int=Math.floor(i/w)
				var color =	diffBmpData.getPixel(tx,ty).toString(16).slice(4)
				diff = int(color).toString(10)
				if(diff >= MIN_SIMILARITY) return false	
			}
			return true
		}
		
		private function getCompareData(data:BitmapData):BitmapData
		{	
			return ColorFilter.grayScale(getResize(data))
		}
		
		public  function getResize(data:BitmapData, thumbWidth:Number=COMPARE_SIMILARITY_PIXEL, thumbHeight:Number=COMPARE_SIMILARITY_PIXEL):BitmapData {
			var m:Matrix = new Matrix();
			m.scale(thumbWidth / data.width, thumbHeight / data.height);
			var resize:BitmapData = new BitmapData(thumbWidth, thumbHeight, false);
			resize.draw(data, m);
			return resize
		}
		
		
	}
}