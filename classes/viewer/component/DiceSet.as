package classes.viewer.component
{
	import com.libs.utils.DisplayUtil;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;

	public class DiceSet extends Sprite
	{
		var dices:Vector.<MovieClip> = new Vector.<MovieClip>
		var currentDice:MovieClip = null
		public function DiceSet()
		{
			for(var i:int=0; i<6; ++i){
				var dice:MovieClip = MovieClip(DisplayUtil.getChildByName(this,"_dice" + i));	
				dice.visible = false
				dice.stop()
				dices.push(dice)
			}
		}
		
		public function setDice(color:int, idx:int){
			if(currentDice != null) currentDice.visible = false
			currentDice = dices[color]
			currentDice.gotoAndStop(idx+1)
			currentDice.visible = true
		}
		
	
	}
}