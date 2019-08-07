package classes
{
	public class Config
	{
		public static const CAMERA_FILE:String = 'data/cam.dat'
		public static const CODE_FILE_PATH = "data/pattern-dice"
		public static const DICE_NUM:int = 6	
	
			
		public static const INSTRUMENTS:Array = [
			'가야금',
			'거문고',
			'해금',
			'아쟁',
			'대금',
			'피리'
		]
			
		public static const COLORS:Array = [
			40,
			80,
			120,
			160,
			200,
			240
		]
			
		public static const INFO_MSG_INIT:String = "시작 준비중입니다."
		public static const INFO_MSG_NOT_FOUND:String = "주사위를 찾을수 없습니다. 주사위를 다시 놓아주세요."
		public static const INFO_MSG_RETRY:String = "주사위를 다시 놓아주세요."
		public static const INFO_MSG_RETRY_PLAY:String = "주사위를 다시 던저주세요."
		public static const INFO_MSG_NEED_MORE_DICE:String = "주사위는 3개가 필요합니다."	
		public static const INFO_MSG_WRONG_DICE:String = "선택한 주사위를 던저주세요."	
	}
}