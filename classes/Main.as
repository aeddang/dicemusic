package classes
{
	import com.greensock.TweenLite;
	import com.greensock.plugins.AutoAlphaPlugin;
	import com.greensock.plugins.GlowFilterPlugin;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.libs.utils.ColorFilter;
	import com.libs.utils.DisplayUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	import classes.camera.FinderEvent;
	import classes.camera.ImageFinder;
	import classes.flar.MakerDetector;
	import classes.model.DetectData;
	import classes.model.InstrumentData;
	import classes.player.SoundPlayer;
	import classes.viewer.Intro;
	import classes.viewer.PlayDice;
	import classes.viewer.PlaySelect;
	import classes.viewer.PlaySelected;
	import classes.viewer.component.SelectSet;
	
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;

	
	public class Main extends Sprite
	{
		private static var _instence:Main;
		public static function get instence():Main
		{
			return _instence;
		}
		public var soundPlayer:SoundPlayer = new SoundPlayer()
		public var finder:ImageFinder = new ImageFinder()
		public var instruments:Vector.<InstrumentData> = new Vector.<InstrumentData>
		public var bgInstrument:InstrumentData 
		private var diceDetectors:Vector.<MakerDetector> = new Vector.<MakerDetector>
		private var isDebugMode:Boolean = true
		private var infoText:TextField
		public function Main() 
		{
			//stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE; 
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.showDefaultContextMenu = false;
			
			TweenPlugin.activate([TintPlugin]);
			TweenPlugin.activate([AutoAlphaPlugin]);
			TweenPlugin.activate([GlowFilterPlugin]);
			setDebugMode()
			
			var _ = new Config()
			_instence = this;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage )	
		}
		
		
		
		private function setupInstrument(){
			var num = Config.INSTRUMENTS.length
			for(var i:int=0; i<num; ++i ){
				var instrument:InstrumentData = new InstrumentData(i,Config.COLORS[i], Config.INSTRUMENTS[i] )
				instruments.push(instrument)
			}	
			bgInstrument = new InstrumentData(num ,Config.COLORS[0], Config.INSTRUMENTS[0] )
		}
		
		private function setupDetector(){
			var num = Config.INSTRUMENTS.length
			for(var i:int=0; i<num; ++i ){
				var diceDetector:MakerDetector = new MakerDetector()
				diceDetector.init( Config.CAMERA_FILE, Config.CODE_FILE_PATH+"_"+(i+1)+".patt", Config.CANVAS_SIZE.x, Config.CANVAS_SIZE.y)
				diceDetectors.push(diceDetector)
				diceDetector.addEventListener(Event.INIT, onReady )	
			}	
		}
		
		private var stackReady:int = 0
		private function onReady(e:Event):void {
			stackReady++
			if(stackReady == Config.DICE_NUM) {
				/*
				var testData:BitmapData = new TestData1()
				var btmData:BitmapData = ColorFilter.monoChromeByHueRange(testData.clone(), 20, 40)
				debug1.graphics.beginBitmapFill(btmData, null, false, true);
				debug1.graphics.drawRect(0, 0, btmData.width, btmData.height);	
				*/
				finder.start()
				
			}
		}
		
		private function onAddedToStage(e:Event = null):void {
			infoText=TextField(DisplayUtil.getChildByName(this,"_infoText"));	
			finder.init(Config.CANVAS_SIZE.x, Config.CANVAS_SIZE.y)
			setupInstrument()
			setupDetector()
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage )
			finder.addEventListener(FinderEvent.CAPTURE, onCapture)
			finder.addEventListener(FinderEvent.INIT_START, onInitStart)
			finder.addEventListener(FinderEvent.INIT_COMPLETED, onInitComplete)
			finder.addEventListener(FinderEvent.SETUP_START, onSetupStart)
			finder.addEventListener(FinderEvent.SETUP_COMPLETED, onSetupComplete)
			finder.addEventListener(FinderEvent.FIND_START, onFindStart)
			finder.addEventListener(FinderEvent.FIND_COMPLETED, onFindComplete)
			finder.addEventListener(FinderEvent.RETRY, onRetry)
		}
		
		private function onRetry(e:FinderEvent):void {
			trace( "onRetry" )
			infoMsg(Config.INFO_MSG_NOT_FOUND)
		}
		private function onInitStart(e:FinderEvent):void {
			trace( "onInitStart" )
			removeTimer()
			finder.start()
			step = 0
			selectedDice = []
			viewerChange(VIEWER_INTRO)
			infoMsg(Config.INFO_MSG_INIT)
		}
		
		private function onInitComplete(e:FinderEvent):void {
			trace( "onInitComplete" )
			infoMsg()
		}
		
		private function onSetupStart(e:FinderEvent):void {
			trace( "onSetupStart" )
		}
		
		private function onSetupComplete(e:FinderEvent):void {
			if(step > 1) {
				onFindComplete(e)
				return
			}
			/*
			var resize = finder.getResize(e.data.clone(), 30,30)
			var btmData:BitmapData = ColorFilter.monoChromeByHueRange(resize)
			finder.findResult( false )
			*/
			var findRect:Vector.<DetectData> = detectRect(e.data.clone())
			trace( "onSetupComplete " + findRect.length)
			if(findRect.length < 1){
				infoMsg(Config.INFO_MSG_RETRY)
				finder.findResult( false )
			}else{
				finder.findResult( true )
				viewerChange(VIEWER_PLAY_SELECT)
			}
		}
		
		
		private var step:int =0
		private function onFindStart(e:FinderEvent):void {
			trace( "onFindStart" )
		}
		
		private function onFindComplete(e:FinderEvent):void {
			var resize:BitmapData = finder.getResize(e.data, Config.CANVAS_SIZE.x/2, Config.CANVAS_SIZE.y/2 )
			var findRects:Vector.<DetectData> = detectRect(resize,4)
			resize.dispose()
			trace( "onFindComplete "+findRects.length )
			finder.pauseDetect()
			if(findRects.length == 0){
				if(step == 1) infoMsg(Config.INFO_MSG_RETRY)
				else infoMsg(Config.INFO_MSG_RETRY_PLAY)
				
			} else if(findRects.length == 3){
				if(isSelectedDice(findRects)){
					startTimer(e.data, findRects)
					return
				}else{
					infoMsg(Config.INFO_MSG_WRONG_DICE)
				}
				
			}else{
				infoMsg(Config.INFO_MSG_NEED_MORE_DICE)
			}
			finder.findResult(false)
			
		}
		private var findColors:Vector.<DetectData>
		private var detectResults:Vector.<DetectData>
		private var findData:BitmapData = null
		private var timer:Timer
		private function startTimer(btmData:BitmapData, detects:Vector.<DetectData>){
			removeTimer()
			detectResults = new Vector.<DetectData>
			findData = btmData
			findColors = detects
			timer = new Timer(100,findColors.length)
			timer.addEventListener(TimerEvent.TIMER, onNextDetect)
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onCompletedDetect)
			timer.start()
		}
		private function removeTimer(){
			if(timer == null) return
			timer.removeEventListener(TimerEvent.TIMER, onNextDetect)
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onCompletedDetect)
			timer.stop()
			if(findData != null ) findData.dispose()
			findData = null
			timer = null
			detectResults = null
		}
		private function onNextDetect( e:TimerEvent ):void {
			var idx:int = timer.currentCount - 1
			var color:int = findColors[idx].color
			infoMsg(Config.INFO_MSG_FIND_DICE + color)
			var range = Config.COLORS[color]
			var btmData:BitmapData = ColorFilter.monoChromeByHueRange(findData.clone(), range.min, range.max, range.saturation)
			var colorDice:DetectData = detectDice(btmData, color)
			if(colorDice != null) detectResults.push(colorDice)
		}
		
		private function onCompletedDetect(e:TimerEvent){
			trace( "find all ColorDice "+detectResults.length )
			var success:int = detectResults.length
			if(success == 0){
				if(step == 1) infoMsg(Config.INFO_MSG_RETRY)
				else infoMsg(Config.INFO_MSG_RETRY_PLAY)
				finder.findResult(false)
				
			}else if(success == 3){
				infoMsg()
				if(step == 1){
					setSelectedDice(detectResults)
					viewerChange(VIEWER_PLAY_SELECTED)
					var playSelected:PlaySelected = currentViewer as PlaySelected
					playSelected.setResult(detectResults)
					finder.findResult(true)
				}else{
					if(isSelectedDice(detectResults)){
						if(step == 3){
							var playDice:PlayDice = currentViewer as PlayDice
							playDice.setResult(detectResults)
							
						}
						finder.findResult(true)
					}else{
						infoMsg(Config.INFO_MSG_WRONG_DICE)
						finder.findResult(false)
					}
				}
			}else{
				infoMsg(Config.INFO_MSG_NEED_MORE_DICE)
				finder.findResult(false )
			}
		}
		
		
		private var selectedDice:Array = []
		private function setSelectedDice(detects:Vector.<DetectData>){
			var len = detects.length
			selectedDice = []
			for(var i:int =0; i< len; ++i ){
				selectedDice.push(detects[i].color)
			}	
		}
		private function isSelectedDice(detects:Vector.<DetectData>):Boolean{
			if(selectedDice.length ==0) return true
			var len = detects.length
			for(var i:int =0; i< len; ++i ){
				if( selectedDice.indexOf(detects[i].color) == -1) return false
			}	
			return true
		}
		
		
		public static const VIEWER_INTRO:String = "IntroMc"
		public static const VIEWER_PLAY_SELECT:String = "PlaySelectMc"
		public static const VIEWER_PLAY_SELECTED:String = "PlaySelectedMc"
		public static const VIEWER_PLAY_DICE:String = "PlayDiceMc"
			
		private var currentViewer:MovieClip = null
		private var currentClass:String = ""
		public function viewerChange(viewerClass:String){
			if(currentClass == viewerClass) return
			currentClass = viewerClass
			if(currentViewer != null) DisplayUtil.remove(currentViewer)
			currentViewer = MovieClip(DisplayUtil.getSymbolByName(viewerClass));
			infoMsg()
			switch(viewerClass){
				case VIEWER_INTRO:
					this.infoText.textColor = 0xffffff
				case VIEWER_PLAY_SELECT :
					this.infoText.textColor = 0xffffff
					step = 1
					var playSelect:PlaySelect = currentViewer as PlaySelect
					break;
				case VIEWER_PLAY_SELECTED :
					this.infoText.textColor = 0xffffff
					step = 2
					var playSelected:PlaySelected = currentViewer as PlaySelected
					break;
				case VIEWER_PLAY_DICE :
					this.infoText.textColor = 0x000000
					step = 3
					var playDice:PlayDice = currentViewer as PlayDice
					break;
			}
			this.addChildAt(currentViewer,0)
		
		}
		
		public function infoMsg(msg:String = ""){
			this.infoText.text = msg
		}
		
		private function detectRect(data:BitmapData, findNum:int = 1):Vector.<DetectData>{
		
			var results:Vector.<DetectData> = new Vector.<DetectData>() 
				
			var len =  Config.COLORS.length
			var detector:MakerDetector = diceDetectors[0]
			for(var i:int=0; i<len; ++i ){
				var range = Config.COLORS[i]
				var btmData:BitmapData = ColorFilter.monoChromeByHueRange(data.clone(),range.min, range.max, range.saturation)
				if(isDebugMode){
					debugViews[i].graphics.beginBitmapFill(btmData, null, false, true);
					debugViews[i].graphics.drawRect(0, 0, btmData.width, btmData.height);
				}
				var resultDice:DetectData = detector.detect(btmData,i, 0, 0 )
				btmData.dispose()
				if(resultDice!= null){
					results.push(resultDice)
					if(results.length >= findNum) return results
				}
				
			}	
			return results
		}
		
		private function detectDice(data:BitmapData, color:int = 0):DetectData{
			if(isDebugMode){
				debugViews[color].graphics.beginBitmapFill(data, null, false, true);
				debugViews[color].graphics.drawRect(0, 0, data.width, data.height);
			}
			var findDice:DetectData = null
			var len =  diceDetectors.length
			for(var i:int=0; i<len; ++i ){
				var detector:MakerDetector = diceDetectors[i]
				var resultDice:DetectData = detector.detect(data, color, i, 0.5 )
				if(resultDice!= null){
					if(resultDice.confidence >= 0.87) return resultDice
					else if(findDice == null) findDice = resultDice
					else if(resultDice.confidence > findDice.confidence) findDice = resultDice
				}
			}
			return findDice
		}
		
		
		private function onCapture(e:FinderEvent):void {
			if(isDebugMode){
				debugView.graphics.beginBitmapFill(e.data, null, false, true);
				debugView.graphics.drawRect(0, 0, e.data.width, e.data.height);
			}
		}
		
		private var debugBtn:SimpleButton
		public var debugInfo:TextField
		private var debugView:Sprite
		private var debugViews:Vector.<Sprite> = new Vector.<Sprite>
		
		private function setDebugMode(){
			var w:int = 240
			debugView = new Sprite()
			debugView.scaleX = -1
			debugView.x = w
			addChildAt(debugView,0)
			for(var i:int=0; i<Config.INSTRUMENTS.length; ++i){
				var view:Sprite = new Sprite()
				debugViews.push(view)
				view.scaleX = -1
				view.x= (w*2) +( i*w)
				view.visible = isDebugMode
				addChildAt(view,0)
			}
			debugBtn=SimpleButton(DisplayUtil.getChildByName(this,"_debugBtn"));	
			debugInfo=TextField(DisplayUtil.getChildByName(this,"_debugInfo"));	
			
			debugInfo.visible = isDebugMode 
			debugBtn.addEventListener(MouseEvent.CLICK, onDebugModeChange)
		}
		
		private function onDebugModeChange(e:MouseEvent){
			isDebugMode = !isDebugMode
			debugView.visible = isDebugMode
			debugInfo.visible = isDebugMode 
			for(var i:int=0; i<debugViews.length; ++i){
				debugViews[i].visible = isDebugMode 
			}
		}
		
		
	}
}