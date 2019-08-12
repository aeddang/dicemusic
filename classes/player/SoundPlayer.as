// ActionScript file
package classes.player {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.Camera;
	import flash.media.ID3Info;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.Video;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	
	import classes.camera.FinderEvent;
	
	public class SoundPlayer extends EventDispatcher {
		private var snds:Vector.<Sound>  
		private var mainSnd:Sound
		private var mainChannel:SoundChannel
		private var channels:Vector.<SoundChannel>
		private var timer:Timer
		private var currentPlayTime:Number = 0
	
		public function SoundPlayer() {
			
			
		}
		
		public function play(playList:Vector.<String>){
			stop()
			currentPlayTime = 0
			snds = new Vector.<Sound>();   
			channels = new Vector.<SoundChannel>(playList.length)
			for(var i:int=0; i< playList.length; ++i){
				trace("play sound " + playList[i])
				var snd:Sound =  new Sound()    
				snds.push(snd)                  
				snd.addEventListener(IOErrorEvent.IO_ERROR, onError);
				snd.addEventListener(Event.COMPLETE, onLoaded);
				snd.load(new URLRequest(playList[i]))
			}
			
			timer = new Timer(30)
			timer.addEventListener(TimerEvent.TIMER, onProgress)
			timer.start()
		}
		
		public function stop(){
			
		    removeTimer()
			stopChannels()
			stopSnds()
		}
		private function stopSnds(){
			if(snds != null){
				for(var i:int=0; i< snds.length; ++i){
					var snd:Sound = snds[i]
					snd.removeEventListener(IOErrorEvent.IO_ERROR, onError);
					snd.removeEventListener(Event.COMPLETE, onLoaded);
					try{
						snd.close()
					} catch (e:Error){
						//trace("sound not open!!")
					}
				}
				mainSnd = null
				snds = null
			}
		}
		
		private function stopChannels(){
			if(channels != null){
				for(var i:int=0; i< channels.length; ++i){
					channels[i].stop()
				}
				mainChannel.removeEventListener(Event.SOUND_COMPLETE, onCompleted)
				channels = null
				mainChannel = null
			}
		}
		private function onLoaded(event:Event):void {
			var snd:Sound = event.currentTarget as Sound
			var channel:SoundChannel = snd.play(0)
			var idx:int = snds.indexOf(snd)
			channels[idx] = channel
			if(currentPlayTime < snd.length){
				if(mainChannel != null) mainChannel.removeEventListener(Event.SOUND_COMPLETE, onCompleted)
				currentPlayTime = snd.length
				if(isNaN(currentPlayTime)) currentPlayTime = 200
				mainChannel = channel
				mainSnd = snd
				mainChannel.addEventListener(Event.SOUND_COMPLETE, onCompleted)
				trace("currentPlayTime ->" + currentPlayTime )
			}	
			
		}
		
		private function onProgress(event:TimerEvent):void {
		
			if(mainChannel == null) return
			var pct:Number = mainChannel.position / currentPlayTime
			
			dispatchEvent(new PlayerEvent(PlayerEvent.PROGRESS, pct))
		}
		private function onCompleted(event:Event):void {
			stop()
			trace("onCompleted")
			dispatchEvent(new PlayerEvent(PlayerEvent.COMPLETED))	
		}
		
		private function onError(event:Event):void {
			trace("error sound not found!!")
		}
		
		
		private function removeTimer(){
			if(timer == null) return
			timer.removeEventListener(TimerEvent.TIMER, onProgress)
			timer.stop()
			timer = null
		}
	}
}