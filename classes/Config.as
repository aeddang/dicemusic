package classes
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class Config
	{
		public static const CAMERA_FILE:String = 'data/cam.dat'
		public static const CODE_FILE_PATH = "data/pattern-dice"
		public static const CONFIG_FILE_PATH = "data/config.json"
		public static const DICE_NUM:int = 6	
			
		public static const CANVAS_SIZE:Point = new Point(160,120)	
	
			
		public static const INSTRUMENTS:Array = [
			'가야금',
			'거문고',
			'해금',
			'아쟁',
			'대금',
			'피리'
		]
			
		public static var COLORS:Array = [
			{min:0,max:10,saturation:20},
			{min:15,max:25,saturation:20},
			{min:25,max:60,saturation:20},
			{min:160,max:180,saturation:20},
			{min:180,max:200,saturation:20},
			{min:200,max:220,saturation:20}
		]
			
		public static const INFO_MSG_INIT:String = "시작 준비중입니다."
		public static const INFO_MSG_NOT_FOUND:String = "주사위를 찾을수 없습니다. 주사위를 다시 놓아주세요."
		public static const INFO_MSG_RETRY:String = "주사위를 다시 놓아주세요."
		public static const INFO_MSG_RETRY_PLAY:String = "주사위를 다시 던저주세요."
		public static const INFO_MSG_NEED_MORE_DICE:String = "주사위는 3개가 필요합니다."	
		public static const INFO_MSG_WRONG_DICE:String = "선택한 주사위를 던저주세요."	
		public static const INFO_MSG_FIND_DICE:String = "주사위를 검색중..."	
			
		public function Config() {
			var loader:URLLoader = new URLLoader();
			var req:URLRequest = new URLRequest(CONFIG_FILE_PATH);
		
			loader.load(req);
			loader.addEventListener(Event.COMPLETE, onParseData);
			
		}
		
		
		private function onParseData(e:Event)
		{
			var loader:URLLoader = URLLoader(e.target);
			try{
				
				var data:Object = JSON.parse(loader.data);
				var colors:Array = data["colors"]	
	
				for(var i:int; i< colors.length; ++i){
					var color:Object = colors[i]
					COLORS[i] = color
					trace(COLORS[i].min + " - " + COLORS[i].max);	
				}
			} catch (e:Error){
				trace(e);	
			}
		}
		
		
		
	}
}