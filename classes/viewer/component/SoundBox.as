package classes.viewer.component
{
	import com.libs.utils.DisplayUtil;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import classes.model.DetectData;

	public class SoundBox extends Sprite
	{
		public var results:Vector.< Vector.<DetectData> > = new Vector.< Vector.<DetectData> >
		private var soundSets:Vector.<SoundSet> = new Vector.<SoundSet>
		private var bar:MovieClip 
		public function SoundBox() 
		{
			for(var i:int=0; i<3; ++i){
				var soundSet:SoundSet = SoundSet(DisplayUtil.getChildByName(this,"_soundSet" + i));	
				soundSets.push( soundSet )
			}
			bar = MovieClip(DisplayUtil.getChildByName(this,"_bar"));
		}
		public function play(detects:Vector.<DetectData>, notePaths:Vector.<String>){
			for(var i:int=0; i<detects.length; ++i){
				soundSets[i].setSelect(detects[i].color)
				soundSets[i].loadImage(notePaths[i])
			}
		}
		
		public function setResult(step:int, detects:Vector.<DetectData>){
			results.push(detects)
		}
		
		public function setProgress(progress:Number){
			bar.x = 1100 * progress
		}
		
	}
}