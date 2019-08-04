package classes.viewer
{
	import com.libs.utils.DisplayUtil;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	
	import classes.Main;
	import classes.model.DetectData;
	import classes.model.InstrumentData;
	import classes.viewer.component.SelectSet;

	public class PlaySelected extends MovieClip
	{
		private var count:TextField
		private var text0:TextField
		private var text1:TextField
		private var title:Sprite
		private var selects:Vector.<SelectSet> = new Vector.<SelectSet>
		private var timer:Timer
		public function PlaySelected()
		{
			title = Sprite(DisplayUtil.getChildByName(this,"_title"));
			text0 = TextField(DisplayUtil.getChildByName(title,"_text0"));
			text1 = TextField(DisplayUtil.getChildByName(title,"_text1"));
			count = TextField(DisplayUtil.getChildByName(this,"_count"));
			text0.autoSize = TextFieldAutoSize.LEFT
			for(var i:int=0; i<3; ++i){
				var select:SelectSet = SelectSet(DisplayUtil.getChildByName(this,"_select" + i));	
				selects.push(select)
			}
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedToStage )
		}
		
		private function onRemovedToStage(e:Event = null):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedToStage )
			removeTimer()
		}
		
		
		public function setResult(detects:Vector.<DetectData>){
			var instruments:Vector.<InstrumentData> = Main.instence.instruments
			var len:int = detects.length
			var str:String = ""
			for(var i:int=0; i<len; ++i){
				var detect:DetectData = detects[i]
				selects[i].setSelect(detect.color, detect.idx)
				var name:String = instruments[detect.color].name
				str += (i == len-1) ? name : (name +", ")
			}
			text0.text = str
			text1.x = text0.width + 2
			title.x = Math.floor( (width - title.width)/2 )
			startTimer()
		}
		
		private function startTimer(){
			Main.instence.finder.pauseDetect()
			removeTimer()
			timer = new Timer(1000,6)
			timer.addEventListener(TimerEvent.TIMER, onCount)
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete)
			timer.start()
		}
		private function removeTimer(){
			if(timer == null) return
			timer.removeEventListener(TimerEvent.TIMER, onCount)
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete)
			timer.stop()
			timer = null
		}
		
		private function onCount(e:TimerEvent):void {
			var c:int = 5 - timer.currentCount
			if(c < 0) c = 0
			count.text = c.toString()	
		}
		
		private function onComplete(e:TimerEvent):void {
			Main.instence.finder.resumeDetect()
			Main.instence.viewerChange(Main.VIEWER_PLAY_DICE)
		}
	}
}