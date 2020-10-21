package classes.viewer
{
	import com.greensock.TweenLite;
	import com.libs.utils.DisplayUtil;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import classes.Main;
	import classes.model.DetectData;
	import classes.model.InstrumentData;
	import classes.player.SoundPlayer;
	import classes.player.PlayerEvent
	import classes.viewer.component.DiceSet;
	import classes.viewer.component.Sheet;
	import classes.viewer.component.SoundBox;
	import classes.viewer.component.SoundSet;
	import classes.Config
	public class PlayDice extends MovieClip
	{
		
		private var sheet:Sheet
		private var soundBox:SoundBox
		private var motion:MovieClip
		private var diceSets:Sprite
		private var dices:Vector.<DiceSet> = new Vector.<DiceSet>
		private var texts:Vector.<TextField> = new Vector.<TextField>
		public function PlayDice()
		{
			diceSets = Sprite(DisplayUtil.getChildByName(this,"_diceSets"));
			motion = MovieClip(DisplayUtil.getChildByName(this,"_motion"));
			sheet = Sheet(DisplayUtil.getChildByName(this,"_sheet"));
			soundBox = SoundBox(DisplayUtil.getChildByName(this,"_soundBox"));
			for(var i:int=0; i<3; ++i){
				var dice:DiceSet = DiceSet(DisplayUtil.getChildByName(diceSets,"_diceSet" + i));	
				var text:TextField = TextField(DisplayUtil.getChildByName(diceSets,"_text" + i));	
				dices.push(dice)
				texts.push(text)
			}
		
			diceSets.visible = false
			motion.visible = false
			//soundBox.visible = false
			diceSets.alpha = 0
			motion.alpha = 0
			//soundBox.alpha = 0
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedToStage )
		}
		
		private function onRemovedToStage(e:Event = null):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedToStage )
			Main.instence.soundPlayer.removeEventListener(PlayerEvent.CURRENT_COMPLETED, subStepNext)
			Main.instence.soundPlayer.removeEventListener(PlayerEvent.COMPLETED, nextSound)
			Main.instence.soundPlayer.removeEventListener(PlayerEvent.PROGRESS, onProress)
			Main.instence.soundPlayer.stop()
			removeTimer()
			TweenLite.killTweensOf(diceSets)
			TweenLite.killTweensOf(motion)
			TweenLite.killTweensOf(soundBox)
		}
		
		
		private var timer:Timer
		private var step:int = 0
		private var subStep:int = 0	
		private var currentPlayPaths:Vector.<String>
		private var currentInstruments:Vector.<InstrumentData>
		private static const COMPLETE_STEP:int = 5
		private var	defaultDetects:Vector.<DetectData> = null
			
		
		public function start(detects:Vector.<DetectData>){
			defaultDetects = detects
			next()
		}
			
		public function setResult(detects:Vector.<DetectData>){
			var instruments:Vector.<InstrumentData> = Main.instence.instruments
			soundBox.setResult(step, detects)
			sheet.setResult(step,detects)
			currentInstruments = new Vector.<InstrumentData>()
			var playPaths:Vector.<String> = new Vector.<String>()	
			var notePaths:Vector.<String> = new Vector.<String>()
			var len:int = detects.length
			for(var i:int=0; i<len; ++i){
				var detect:DetectData = detects[i]
				
				dices[i].setDice(detect.color, detect.idx)
				var name:String = instruments[detect.color].name
				texts[i].text = name
				var instrument:InstrumentData = instruments[detect.color ]
				detect.r = instrument.getRandomPath(step, detect.idx)
				currentInstruments.push(instrument)
				playPaths.push(instrument.getSoundPath(step, detect.idx, detect.r))
				notePaths.push(instrument.getNotePath(step, detect.idx, detect.r))
			}	
			step ++
			subStep =0
			soundBox.play( detects, notePaths , false)
			currentPlayPaths = playPaths
			motion.stop()
			TweenLite.to(motion, 0.3, {autoAlpha:0});
			Main.instence.finder.pauseDetect()
			Main.instence.soundPlayer.addEventListener(PlayerEvent.CURRENT_COMPLETED, subStepNext)
			subStepNext()
			//startTimer()
		}
		
		private function subStepNext(e:PlayerEvent = null){
			if(subStep >= currentPlayPaths.length ){
				Main.instence.soundPlayer.removeEventListener(PlayerEvent.CURRENT_COMPLETED, subStepNext)
				next();
				return
			}
			soundBox.setCurrentSubStep(subStep)
			sheet.setCurrentSubStep(subStep)
			Main.instence.infoMsg(currentInstruments[subStep].name +" "+ Config.INFO_MSG_SOLO)
			var path:String = currentPlayPaths[subStep]
			Main.instence.soundPlayer.currentPlay(path)
			subStep++
		}
		
		private function next(e:TimerEvent = null){
			if(step == COMPLETE_STEP){
				complete()
				return
			}
			sheet.setNextStep( step )
			Main.instence.finder.resumeDetect()
		
			var instruments:Vector.<InstrumentData> = Main.instence.instruments
			var len:int = defaultDetects.length
			var notePaths:Vector.<String> = new Vector.<String>()
			for(var i:int=0; i<len; ++i){
				var detect:DetectData = defaultDetects[i]
				var instrument:InstrumentData = instruments[detect.color ]
				notePaths.push(instrument.getDefaultPath(step, detect.idx))
			}	
			soundBox.reset(defaultDetects, notePaths)
			motion.play()
			TweenLite.to(motion, 0.3, {autoAlpha:1});
			trace("next " + step)
			Main.instence.infoMsg(Config.INFO_MSG_RETRY)
		}
		
		private function complete(){
			step = 0
			Main.instence.finder.pauseDetect()
			Main.instence.finder.end()
				
			TweenLite.to(diceSets, 0.3, {autoAlpha:0});
			TweenLite.to(soundBox, 0.3, {autoAlpha:1});
			Main.instence.infoMsg()
			Main.instence.soundPlayer.addEventListener(PlayerEvent.COMPLETED, nextSound)
			Main.instence.soundPlayer.addEventListener(PlayerEvent.PROGRESS, onProress)
			nextSound()
				
		}
		private function  onProress(e:PlayerEvent){
			soundBox.setProgress(e.data)
		}
		
		private function nextSound(e:Event = null){
			if(step >= COMPLETE_STEP){
				Main.instence.finder.reset()
				Main.instence.infoMsg(Config.INFO_MSG_RETRY)
				return
			}
			sheet.setCurrentStep(step)
			
			var instruments:Vector.<InstrumentData> = Main.instence.instruments
			var detects:Vector.<DetectData> = soundBox.results[step]	
			var len = detects.length 
			var playPaths:Vector.<String> = new Vector.<String>()
			var notePaths:Vector.<String> = new Vector.<String>()
			for(var i:int=0; i<len ; ++i){
				var detect:DetectData = detects[i]
				var instrument:InstrumentData = instruments[detect.color ]
				playPaths.push(instrument.getSoundPath(step, detect.idx, detect.r))
				notePaths.push(instrument.getNotePath(step, detect.idx, detect.r))
			}	
			
			var choice = Math.floor( Math.random() * Config.DICE_NUM)
			if(choice == Config.DICE_NUM) choice = Config.DICE_NUM-1
			var r:int = Main.instence.bgInstrument.getRandomPath(step, choice)
			playPaths.push( Main.instence.bgInstrument.getSoundPath(step, choice, r) )
		
			Main.instence.soundPlayer.play(	playPaths )
			soundBox.play( detects, notePaths )
			step ++
			Main.instence.infoMsg(Config.INFO_MSG_CONCERT)
		}
		
		
		private function startTimer(){
			removeTimer()
			timer = new Timer(4000,1)
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, next)
			timer.start()
		}
		private function removeTimer(){
			if(timer == null) return
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, next)
			timer.stop()
			timer = null
		}
		
	}
}