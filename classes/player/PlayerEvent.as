package classes.player
{
	import flash.display.BitmapData;
	import flash.events.Event;
	
	public class PlayerEvent extends Event
	{
		public static const PROGRESS:String = "progress";
		public static const COMPLETED:String = "completed";
		private var _data:Number;
		
		public function PlayerEvent( type:String, __data:Number=0, bubble:Boolean = false, cancelable:Boolean = false )
		{
			super( type, bubble, cancelable );
			_data = __data;
		}
		
		override public function clone():Event
		{
			return new PlayerEvent( type, _data, bubbles, cancelable );
		}
		
		public function get data():Number
		{
			return _data;
		}
	}
}

