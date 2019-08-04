package classes.camera
{
	import flash.display.BitmapData;
	import flash.events.Event;

	public class FinderEvent extends Event
	{
		public static const CAPTURE:String = "capture";
		public static const INIT_START:String = "initStart";
		public static const INIT_COMPLETED:String = "initCompleted";
		public static const SETUP_START:String = "setupStart";
		public static const SETUP_COMPLETED:String = "setupCompleted";
		public static const FIND_START:String = "findStart";
		public static const FIND_COMPLETED:String = "findCompleted";
		public static const RETRY:String = "retry";
		private var _data:BitmapData;
		
		public function FinderEvent( type:String, __data:BitmapData=null, bubble:Boolean = false, cancelable:Boolean = false )
		{
			super( type, bubble, cancelable );
			_data = __data;
		}
		
		override public function clone():Event
		{
			return new FinderEvent( type, _data, bubbles, cancelable );
		}
		
		public function get data():BitmapData
		{
			return _data;
		}
	}
}