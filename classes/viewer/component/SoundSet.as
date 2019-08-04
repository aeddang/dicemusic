package classes.viewer.component
{
	import com.greensock.TweenLite;
	import com.libs.utils.DisplayUtil;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.UncaughtErrorEvent;
	import flash.net.URLRequest;
	
	import classes.Main;
	import classes.model.InstrumentData;
	import classes.player.PlayerEvent;

	public class SoundSet extends Sprite
	{
		private var instrument:MovieClip
		private var note:MovieClip
		private var imageLoader:Loader
		public function SoundSet()
		{
			instrument = MovieClip(DisplayUtil.getChildByName(this,"_instrument"));	
			note = MovieClip(DisplayUtil.getChildByName(this,"_note"));	
			instrument.stop()
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedToStage )
		}
		
		private function onRemovedToStage(e:Event = null):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedToStage )
			if(imageLoader != null){
				try{
					imageLoader.close()
				} catch (e:Error){
					trace("imageLoader not open!!")
				}
				imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaded); 
				imageLoader.uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onError);
				imageLoader = null
			}
		}
		
		public function setSelect(color:int){
			instrument.gotoAndStop(color+1)
		}
		
		public function loadImage(imageURL:String) {
			trace("imageURL " + imageURL)
			imageLoader = new Loader();
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded); 
			imageLoader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onError);
			imageLoader.load(new URLRequest(imageURL));
		
		}
		
		private function onLoaded(e:Event) {
			note.addChild(e.target.loader.content); 
		}
		
		private function onError(e:UncaughtErrorEvent) {
			trace("error image not found!!")
		}
	}
}