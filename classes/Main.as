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
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE; 
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.showDefaultContextMenu = false;
			
			TweenPlugin.activate([TintPlugin]);
			TweenPlugin.activate([AutoAlphaPlugin]);
			TweenPlugin.activate([GlowFilterPlugin]);
			setDebugMode()
			
			
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
			viewerChange(VIEWER_INTRO)
			infoMsg(Config.INFO_MSG_INIT)
		}
		
		private function onInitComplete(e:FinderEvent):void {
			trace( "onInitComplete" )
			infoMsg()
			if(isDebugMode){
				debug1.graphics.beginBitmapFill(e.data, null, false, true);
				debug1.graphics.drawRect(0, 0, e.data.width, e.data.height);
			}
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
			var findRect:DetectData = detectRect(e.data.clone())
			trace( "onSetupComplete " + findRect)
			if(findRect == null){
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
			
			var findRect:DetectData = detectRect(e.data.clone())
			trace( "onFindComplete "+findRect )
			finder.pauseDetect()
			if(findRect == null){
				if(step == 1) infoMsg(Config.INFO_MSG_RETRY)
				else infoMsg(Config.INFO_MSG_RETRY_PLAY)
				finder.findResult(false)
				
			} else {
				startTimer(e.data)
			}
			
			
		}
		private var detectResults:Vector.<DetectData>
		private var findData:BitmapData = null
		private var timer:Timer
		private function startTimer(btmData:BitmapData){
			removeTimer()
			clearPointers()
			detectResults = new Vector.<DetectData>
			findData = btmData
			timer = new Timer(200,Config.INSTRUMENTS.length)
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
			var color:int = timer.currentCount - 1
			infoMsg(Config.INFO_MSG_FIND_DICE + color)
			var range = Config.COLORS[color]
			var btmData:BitmapData = ColorFilter.monoChromeByHueRange(findData.clone(), range.min, range.max)
			var colorDice:DetectData = detectDice(btmData, color)
			if(colorDice != null) detectResults.push(colorDice)
		}
		
		private function onCompletedDetect(e:TimerEvent){
			trace( "find all ColorDice "+detectResults.length )
			var success:int = detectResults.length
			if(success == 1){
				detectResults.push(detectResults[0])
				detectResults.push(detectResults[0])	
				success = 3
			}else if(success == 2){
				detectResults.push(detectResults[0])
				success = 3
			}
				
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
		
		private function detectRect(data:BitmapData):DetectData{
		
			var btmData:BitmapData = ColorFilter.monoChromeByHueRange(data.clone(), 0, 60, 60)
			var detector:MakerDetector = diceDetectors[0]
			var detect:DetectData = detector.detect(btmData,0, 0, 0)
			if(detect == null) {
				btmData.dispose()
				btmData = ColorFilter.monoChromeByHueRange(data.clone(), 160, 220, 60)
				detect = detector.detect( btmData ,0, 0, 0)
			}
			if(isDebugMode){
				debug1.graphics.beginBitmapFill(btmData, null, false, true);
				debug1.graphics.drawRect(0, 0, btmData.width, btmData.height);
			}
			return detect
		}
		
		private function detectDice(data:BitmapData, color:int = 0):DetectData{
			if(isDebugMode){
				debug1.graphics.beginBitmapFill(data, null, false, true);
				debug1.graphics.drawRect(0, 0, data.width, data.height);
			}
			var len =  diceDetectors.length
			for(var i:int=0; i<len; ++i ){
				var detector:MakerDetector = diceDetectors[i]
				var resultDice:DetectData = detector.detect(data, color, i )
				if(resultDice!= null){
					if(isDebugMode){
						var pointer:Sprite = pointers[color]
						pointer.x = resultDice.tx
						pointer.y = resultDice.ty
						pointer.visible = true
					}
					return resultDice
				}
			}
			return null
		}
		
		
		private function onCapture(e:FinderEvent):void {
			if(isDebugMode){
				debug0.graphics.beginBitmapFill(e.data, null, false, true);
				debug0.graphics.drawRect(0, 0, e.data.width, e.data.height);
			}
		}
		
		private var debugBtn:SimpleButton
		public var debugInfo:TextField
		private var debug0:Sprite	
		private var debug1:Sprite	
		private var pointerDice:Sprite	
		private var pointers:Vector.<Sprite> = new Vector.<Sprite>
		private function setDebugMode(){
			for(var i:int=0; i<Config.INSTRUMENTS.length; ++i){
				var pointer:Sprite=Sprite(DisplayUtil.getChildByName(this,"_pointer"+i));	
				pointer.visible = false
				pointers.push(pointer)
			}
			debugBtn=SimpleButton(DisplayUtil.getChildByName(this,"_debugBtn"));	
			debugInfo=TextField(DisplayUtil.getChildByName(this,"_debugInfo"));	
			pointerDice=Sprite(DisplayUtil.getChildByName(this,"_pointer"));	
			debug0=Sprite(DisplayUtil.getChildByName(this,"_debug0"));	
			debug1=Sprite(DisplayUtil.getChildByName(this,"_debug1"));	
			pointerDice.visible = false
			debug0.scaleX = -1
			debug0.x=320	
			debug1.scaleX = -1
			debug1.x= width	
			debug0.visible = isDebugMode
			debug1.visible = isDebugMode 
			debugInfo.visible = isDebugMode 
			debugBtn.addEventListener(MouseEvent.CLICK, onDebugModeChange)
		}
		
		private function onDebugModeChange(e:MouseEvent){
			isDebugMode = !isDebugMode
			clearPointers()
			debug0.visible = isDebugMode
			debug1.visible = isDebugMode 
			debugInfo.visible = isDebugMode 
		}
		
		private function clearPointers(){
			pointerDice.visible = false
			for(var i:int=0; i<pointers.length; ++i){
				var pointer:Sprite=pointers[i]
				pointer.visible = false
			}
		}
	}
}