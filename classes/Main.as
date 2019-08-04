package classes
{
	import com.greensock.TweenLite;
	import com.greensock.plugins.AutoAlphaPlugin;
	import com.greensock.plugins.GlowFilterPlugin;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.libs.utils.DisplayUtil;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
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
		private var detectors:Vector.<MakerDetector> = new Vector.<MakerDetector>
		private var isDebugMode:Boolean = false
		private var infoText:TextField
		public function Main() 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE
			stage.align = StageAlign.TOP_LEFT;
			stage.showDefaultContextMenu = false;
			
			TweenPlugin.activate([TintPlugin]);
			TweenPlugin.activate([AutoAlphaPlugin]);
			TweenPlugin.activate([GlowFilterPlugin]);
			
			_instence = this;
			if(isDebugMode) setDebugMode()
			infoText=TextField(DisplayUtil.getChildByName(this,"_infoText"));	
			finder.init()
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
			var num = Config.CAMERA_FILES.length
			for(var i:int=0; i<num; ++i ){
				var detector:MakerDetector = new MakerDetector()
				detector.init( Config.CAMERA_FILES[i], Config.CODE_FILES[i])
				detector.addEventListener(Event.INIT, onReady )	
				detectors.push(detector)
			}	
		}
		
		private var stackReady:int = 0
		private function onReady(e:Event):void {
			stackReady++
			if(stackReady == Config.CAMERA_FILES.length) {
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
				debug3.graphics.beginBitmapFill(e.data, null, false, true);
				debug3.graphics.drawRect(0, 0, e.data.width, e.data.height);
			}
		}
		
		private function onSetupStart(e:FinderEvent):void {
			trace( "onSetupStart" )
		}
		
		private function onSetupComplete(e:FinderEvent):void {
			if(step != 0) {
				onFindComplete(e)
				return
			}
			var detects:Vector.<DetectData> = detect(e.data)
			trace( "onSetupComplete "+detects.length)
			var isSuccess = detects.length >=1
			finder.findResult( isSuccess )
			if(isSuccess){
				viewerChange(VIEWER_PLAY_SELECT)
			}else{
				infoMsg(Config.INFO_MSG_RETRY)
			}
				
			if(isDebugMode){
				debug1.graphics.beginBitmapFill(e.data, null, false, true);
				debug1.graphics.drawRect(0, 0, e.data.width, e.data.height);
			}
		}
		
		
		private var step:int =0
		
		private function onFindStart(e:FinderEvent):void {
			trace( "onFindStart" )
		}
		
		private function onFindComplete(e:FinderEvent):void {
			var detects:Vector.<DetectData> = detect(e.data)
			trace( "onFindComplete "+detects.length )
			var isSuccess:Boolean = false
			var success:int = detects.length
			if(success == 0){
				if(step == 1) infoMsg(Config.INFO_MSG_RETRY)
				else infoMsg(Config.INFO_MSG_RETRY_PLAY)
			}else if(success == 3){
				infoMsg()
				if(step == 1){
					isSuccess = true	
					setSelectedDice(detects)
					viewerChange(VIEWER_PLAY_SELECTED)
					var playSelected:PlaySelected = currentViewer as PlaySelected
					playSelected.setResult(detects)
					trace( "playSelected "+detects.length )
				}else{
					if(isSelectedDice(detects)){
						isSuccess = true
						if(step == 3){
							var playDice:PlayDice = currentViewer as PlayDice
							playDice.setResult(detects)
							trace( "playDice "+detects.length )
						}
					}else{
						infoMsg(Config.INFO_MSG_WRONG_DICE)
					}
				}
			}else{
				infoMsg(Config.INFO_MSG_NEED_MORE_DICE)
			}
			finder.findResult(isSuccess )
			if(isDebugMode){
				debug1.graphics.beginBitmapFill(e.data, null, false, true);
				debug1.graphics.drawRect(0, 0, e.data.width, e.data.height);
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
		
		
		private function detect(data:BitmapData):Vector.<DetectData>{
			var result:Vector.<DetectData> = new Vector.<DetectData>
			var len =  detectors.length
			for(var i:int=0; i<len; ++i ){
				var detector:MakerDetector = detectors[i]
				var mat:FLARTransMatResult = detector.detect(data)
				if(mat!= null){
					var detectData:DetectData = new DetectData()
					detectData.mat = mat
					detectData.idx = i
					detectData.tx = (data.width/2) - mat.m03
					detectData.ty = (data.height/2) + mat.m13
					
					result.push(detectData)
					var rect:Rectangle = detectData.detectColor(data)
					if(isDebugMode){
						pointer.x = rect.x
						pointer.y = rect.y
						pointer.width = rect.width
						pointer.height = rect.height
					}
				}
			}
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
		private var debug2:Sprite	
		private var debug3:Sprite	
		private var pointer:Sprite
		private function setDebugMode(){
			debug0=Sprite(DisplayUtil.getChildByName(this,"_debug0"));	
			debug1=Sprite(DisplayUtil.getChildByName(this,"_debug1"));	
			debug2=Sprite(DisplayUtil.getChildByName(this,"_debug2"));	
			debug3=Sprite(DisplayUtil.getChildByName(this,"_debug3"));	
			pointer=Sprite(DisplayUtil.getChildByName(this,"_pointer"));	
			debug0.scaleX = -1
			debug0.x=320	
			debug1.scaleX = -1
			debug1.x=640	
			debug2.scaleX = -1
			debug2.x=320	
			debug3.scaleX = -1
			debug3.x=640		
			pointer.alpha=1
		}
	}
}