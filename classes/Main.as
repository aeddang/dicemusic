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
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
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
		private var diceDetectors:Vector.<MakerDetector> = new Vector.<MakerDetector>
		private var detectors:Vector.<Vector.<MakerDetector>> = new Vector.<Vector.<MakerDetector>>
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
			
			
			
		
			_instence = this;
			
			infoText=TextField(DisplayUtil.getChildByName(this,"_infoText"));	
			//finder.init()
			setupInstrument()
			setupDetector()
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage )	
		}
		
		
		
		private function setupInstrument(){
			var num = Config.INSTRUMENTS.length
			for(var i:int=0; i<num; ++i ){
				var instrument:InstrumentData = new InstrumentData(i,Config.COLORS[i], Config.INSTRUMENTS[i] )
				instruments.push(instrument)
			}	
		}
		
		private function setupDetector(){
			var num = Config.INSTRUMENTS.length
			for(var i:int=0; i<num; ++i ){
				var diceDetector:MakerDetector = new MakerDetector()
				diceDetector.init( Config.CAMERA_FILE, Config.CODE_FILE_PATH+"_"+(i+1)+".patt")
				diceDetectors.push(diceDetector)
				/*	
				var detectorSet:Vector.<MakerDetector> = new Vector.<MakerDetector>
				for(var x:int=1; x<=6; ++x ){
					var detector:MakerDetector = new MakerDetector()
					detector.init( Config.CAMERA_FILE, Config.CODE_FILE_PATH+i+"_"+x+".patt")
					detector.addEventListener(Event.INIT, onReady )	
					detectorSet.push(detector)
				}
				detectors.push(detectorSet)
					*/
			}	
		}
		
		private var stackReady:int = 0
		private function onReady(e:Event):void {
			stackReady++
			if(stackReady == Config.INSTRUMENTS.length) {
				finder.start()
				/*
				var detects:Vector.<DetectData> = new Vector.<DetectData>
				detects.push(new DetectData())
				detects.push(new DetectData())
				detects.push(new DetectData())
				setSelectedDice(detects)
				
				viewerChange(VIEWER_PLAY_DICE)
				var test:PlayDice = currentViewer as PlayDice
				*/
			}
		}
		
		private function onAddedToStage(e:Event = null):void {
				
			var testData:BitmapData = new TestData0()
			var btmData:BitmapData = ColorFilter.monoChromeByHueRange(testData.clone(), 0, 100)
			var detects:Vector.<DetectData> = detectDice(btmData)
			trace( "onAddedToStage "+detects.length)
				
			debug1.graphics.beginBitmapFill(btmData, null, false, true);
			debug1.graphics.drawRect(0, 0, btmData.width, btmData.height);	
			return
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
			
			var btmData:BitmapData = ColorFilter.monoChromeByHueRange(e.data.clone(), 0, 180)
			var detects:Vector.<DetectData> = detectDice(btmData)
			trace( "onSetupComplete "+detects.length)
			var isSuccess = detects.length >=1
			finder.findResult( isSuccess )
			if(isSuccess){
				viewerChange(VIEWER_PLAY_SELECT)
			}else{
				infoMsg(Config.INFO_MSG_RETRY)
			}
				
			if(isDebugMode){
				debug1.graphics.beginBitmapFill(btmData, null, false, true);
				debug1.graphics.drawRect(0, 0, btmData.width, e.data.height);
			}
		}
		
		
		private var step:int =0
		
		private function onFindStart(e:FinderEvent):void {
			trace( "onFindStart" )
		}
		
		
		private function onFindComplete(e:FinderEvent):void {
			var btmData:BitmapData = ColorFilter.monoChrome(e.data.clone())
			var detects:Vector.<DetectData> = detectDice(btmData)
			trace( "onFindComplete "+detects.length )
			finder.pauseDetect()
			var success:int = detects.length
			if(success == 0){
				if(step == 1) infoMsg(Config.INFO_MSG_RETRY)
				else infoMsg(Config.INFO_MSG_RETRY_PLAY)
				finder.findResult(false)
				if(isDebugMode){
					debug1.graphics.beginBitmapFill(btmData, null, false, true);
					debug1.graphics.drawRect(0, 0, btmData.width, btmData.height);
				}
			} else {
				onDiceDetected(e.data, detects )
				if(isDebugMode){
					debug1.graphics.beginBitmapFill(e.data, null, false, true);
					debug1.graphics.drawRect(0, 0, e.data.width, e.data.height);
				}
			}
			
			
		}
		
		private function onDiceDetected( data:BitmapData, dices:Vector.<DetectData> ):void {
			clearPointers()
			var len = dices.length
			var detects:Vector.<DetectData> = new Vector.<DetectData>
			for(var i:int =0; i< len; ++i ){
				var colors:Vector.<DetectData> = detectColorDice(dices[i].idx, data)
				if(colors != null) detects = detects.concat( colors )
			}	
			trace( "find all ColorDice "+detects.length )
			var success:int = detects.length
			if(success == 0){
				if(step == 1) infoMsg(Config.INFO_MSG_RETRY)
				else infoMsg(Config.INFO_MSG_RETRY_PLAY)
				finder.findResult(false)
					
			}else if(success == 3){
				infoMsg()
				if(step == 1){
					setSelectedDice(detects)
					viewerChange(VIEWER_PLAY_SELECTED)
					var playSelected:PlaySelected = currentViewer as PlaySelected
					playSelected.setResult(detects)
					finder.findResult(true)
				}else{
					if(isSelectedDice(detects)){
						if(step == 3){
							var playDice:PlayDice = currentViewer as PlayDice
							playDice.setResult(detects)
							
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
		
		
		private function detectDice(data:BitmapData, findNum:int = 6):Vector.<DetectData>{
			var result:Vector.<DetectData> = new Vector.<DetectData>
			var len =  detectors.length
			
			for(var i:int=0; i<len; ++i ){
				var detector:MakerDetector = diceDetectors[i]
				var resultDice:DetectData = detector.detect(data,0, i,0)
				if(resultDice!= null){
					result.push(resultDice)
					if(result.length == findNum) return result
					if(isDebugMode){
						pointerDice.x = resultDice.tx
						pointerDice.y =resultDice.ty
						pointerDice.visible = true
					}
				}
			}
			return result
		}
		
		
		private function detectColorDice(dice:int, data:BitmapData):Vector.<DetectData>{
			var len:int = detectors.length
			var result:Vector.<DetectData> = new Vector.<DetectData>
			for(var i:int=0; i<len; ++i ){
				var detector:MakerDetector = detectors[i][dice]
				var currentResult:DetectData = detector.detect(data, i, dice, 0.0)
				
				if(currentResult!=null){
					trace( "compare ColorDice "+currentResult.color +" dice : "+ dice)
					var resultLen:int = result.length
					if( resultLen == 0 ) {
						trace( "find new ColorDice "+currentResult.color)
						result.push( currentResult )
					}
					else{
						var isAnother:Boolean = true
						for(var x:int=0; x<resultLen; ++x ){
							var prevResult:DetectData = result[x]	
							var diffX:Number = prevResult.tx - currentResult.tx
							var diffY:Number = prevResult.ty - currentResult.ty
							var distence:Number = Math.sqrt((diffX*diffX) + (diffY*diffY))
							trace( "compare another distence "+distence)
							if(distence > 20){
								
							} else {
								isAnother = false
								if(currentResult.confidence > prevResult.confidence ){
									trace( "find update ColorDice "+currentResult.color)
									result[x] = currentResult
								} else{
									trace( "find wrong ColorDice "+currentResult.color)
									currentResult = null
									break
								}
							}
						}
						if(isAnother){
							trace( "find another ColorDice "+currentResult.color)
							result.push( currentResult)
						}
					}
					if(isDebugMode && currentResult!=null){
						var pointer:Sprite= pointers[currentResult.color]
						pointer.x = currentResult.tx
						pointer.y =currentResult.ty
						pointer.visible = true
					}
				}
			}
			trace( "find ColorDice "+result.length )
			return result
		}
		
		
		private function onCapture(e:FinderEvent):void {
			if(isDebugMode){
				debug0.graphics.beginBitmapFill(e.data, null, false, true);
				debug0.graphics.drawRect(0, 0, e.data.width, e.data.height);
			}
		}
		
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
			pointerDice=Sprite(DisplayUtil.getChildByName(this,"_pointer"));	
			debug0=Sprite(DisplayUtil.getChildByName(this,"_debug0"));	
			debug1=Sprite(DisplayUtil.getChildByName(this,"_debug1"));	
			pointerDice.visible = false
			debug0.scaleX = -1
			debug0.x=320	
			debug1.scaleX = -1
			debug1.x= width	
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