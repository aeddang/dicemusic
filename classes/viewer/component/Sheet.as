package classes.viewer.component
{
	import com.greensock.TweenLite;
	import com.libs.utils.DisplayUtil;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import classes.Main;
	import classes.model.DetectData;
	import classes.model.InstrumentData;
	
	public class Sheet extends Sprite
	{
		private var diceSets:Vector.< Vector.<DiceSet> > = new Vector.< Vector.<DiceSet> >()
		private var texts:Vector.<TextField> = new Vector.<TextField>()
		private var tab:Sprite
		public function Sheet()
		{
			for(var i:int=0; i<5; ++i){
				var diceSet:MovieClip = MovieClip(DisplayUtil.getChildByName(this,"_diceSet" + i));	
				var sets:Vector.<DiceSet> = new Vector.<DiceSet>()
				for(var x:int=0; x<3; ++x){
					var dice:DiceSet = DiceSet(DisplayUtil.getChildByName(diceSet,"_diceSet" + x));	
					dice.visible = false
					sets.push(dice)
				}
				diceSets.push(sets)
					
				var text:TextField = TextField(DisplayUtil.getChildByName(this,"_text" + i));
				texts.push(text)
				if(i != 0) text.visible = false
			}
			tab = Sprite(DisplayUtil.getChildByName(this,"_tab"));
		}
		
		private var currentText:TextField = null
		private var currentDiceSet:Vector.<DiceSet> = null

		public function setResult(step:int, detects:Vector.<DetectData>){
			setCurrentStep(step)
			var len:int = detects.length
			for(var i:int=0; i<len; ++i){
				var detect:DetectData = detects[i]
				currentDiceSet[i].visible = true
				currentDiceSet[i].setDice(detect.color,detect.idx)
			}
			currentText.visible = true
		}
		
		public function setCurrentStep(step:int){
			if(currentText != null) currentText.alpha = 0.5
				
			var i:int
			if(currentDiceSet != null){
				for(i=0; i<currentDiceSet.length; ++i){
					currentDiceSet[i].alpha = 0.5
				}
			}
			TweenLite.to(tab, 0.3, { x:(step*tab.width) });
			currentDiceSet = diceSets[step]
			currentText = texts[step]
				
			currentText.alpha = 1
			for(i=0; i<currentDiceSet.length; ++i){
				currentDiceSet[i].alpha = 1
			}
		}
		
	}
}


