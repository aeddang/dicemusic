package classes.viewer
{
	import flash.display.MovieClip;
	
	import classes.Main;

	public class PlaySelect extends MovieClip
	{
		public function PlaySelect()
		{
			Main.instence.finder.pauseDetect()
		}
		
		public function complete(){
			Main.instence.finder.resumeDetect()
		}
	}
}