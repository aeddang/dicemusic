package classes.model
{
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import classes.Main
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	
	public class InstrumentData
	{
		private static const COLOR_EXCUTE_RANGE:int = 10
		
		public var idx:int = -1
		public var color:int = -1
		public var name:String
		
		private var currentGroup:int  = 0
		private var currentDice:int  = 0
		private var currentPath:int  = 0
		private  var soundPaths:Vector.<Vector.< Vector.<String> >> = new Vector.<Vector.< Vector.<String> >>()
		private  var notePaths:Vector.<Vector.< Vector.<String> >> = new Vector.<Vector.< Vector.<String> >>()
		
		public function InstrumentData(_idx:int, _color:int,_name:String)
		{
			name = _name
			idx = _idx
			color = _color
			setupExistFilePath()
		}
		public function get soundPath():String{
			return soundPaths[currentGroup][currentDice][currentPath]
		}
		
		public function get notePath():String{
			return notePaths[currentGroup][currentDice][currentPath]
		}
		
		public function setRandomPath(group:int, dice:int){
			currentGroup = group
			var sounds:Vector.<String> = soundPaths[group][dice]
			var notes:Vector.<String> = notePaths[group][dice]
			currentDice = dice
			var pathNum:int = Math.min(sounds.length, notes.length)
			if(notes.length == 0) pathNum = sounds.length
			currentPath = Math.floor( Math.random() * pathNum )
			if(currentPath >= pathNum) currentPath = pathNum-1
		}
		
		private function setupExistFilePath(){
			for (var x:uint = 0; x < 5; x++)  
			{
				var sounds:Vector.< Vector.<String> > = new Vector.< Vector.<String> >()
				var notes:Vector.< Vector.<String> > = new Vector.< Vector.<String> >()
				for (var i:uint = 0; i < 6; i++)  
				{
					setExistFilePath(sounds,notes,x, i)
					
				}
				soundPaths.push(sounds)
				notePaths.push(notes)
			}
			
		}
		
		private function setExistFilePath(soundSets:Vector.< Vector.<String> >,noteSets:Vector.< Vector.<String> >, group:int,dice:int){
			var sounds:Vector.<String> = new Vector.<String>()
			var notes:Vector.<String> = new Vector.<String>()
			
			var soundDir:String = "music/group"+(group+1)+"/dice"+(idx+1)+"/"
			var soundDirectory:File = File.applicationDirectory.resolvePath(soundDir)
			
			var key:String = "0"+(dice+1)
			var mps:Array = soundDirectory.getDirectoryListing(); 
			
			for (var i:int = 0; i < mps.length; i++)  
			{ 
				var mp:String = mps[i].name
				if( mp.indexOf(key) != -1) {
					if(mp.indexOf(".mp3") != -1) sounds.push(soundDir + mp)
					if(mp.indexOf(".jpg") != -1) notes.push(soundDir + mp)
				}
			} 	
		
			soundSets.push(sounds.sort(0))
			noteSets.push(notes.sort(0))
		}
	}
}
		