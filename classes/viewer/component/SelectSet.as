package classes.viewer.component
{
	import com.libs.utils.DisplayUtil;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;

	public class SelectSet extends Sprite
	{
		var dice:DiceSet
		var instrument:MovieClip
		
		public function SelectSet()
		{
			dice = DiceSet(DisplayUtil.getChildByName(this,"_diceSet"));	
			instrument = MovieClip(DisplayUtil.getChildByName(this,"_instrument"));	
			instrument.stop()
		}
		
		public function setSelect(color:int, idx:int){
			
			dice.setDice(color,idx)
			instrument.gotoAndStop(color+1)
		}
	}
}