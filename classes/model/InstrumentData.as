package classes.model
{
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	
	public class InstrumentData
	{
		private static const COLOR_EXCUTE_RANGE:int = 10
		
		public var idx:int = -1
		public var color:int = -1
		public var name:String
		
		private var currentDice:int  = 0
		private var currentPath:int  = 0
		private  var soundPaths:Vector.< Vector.<String> > = new Vector.< Vector.<String> >()
		private  var notePaths:Vector.< Vector.<String> > = new Vector.< Vector.<String> >()
		
		public function InstrumentData(_idx:int, _color:int,_name:String)
		{
			name = _name
			idx = _idx
			color = _color
			setupExistFilePath()
		}
		public function get soundPath():String{
			return soundPaths[currentDice][currentPath]
		}
		
		public function get notePath():String{
			return notePaths[currentDice][currentPath]
		}
		
		public function setRandomPath(dice:int){
			
			var sounds:Vector.<String> = soundPaths[dice]
			var notes:Vector.<String> = notePaths[dice]
			currentDice = dice
			var pathNum:int = Math.min(sounds.length, notes.length)
			currentPath = Math.floor( Math.random() * pathNum )
			if(currentPath >= pathNum) currentPath = pathNum-1
		}
		
		private function setupExistFilePath(){
			for (var i:uint = 0; i < 6; i++)  
			{
				setExistFilePath(i)
			}
		}
		
		private function setExistFilePath(dice:int){
			var sounds:Vector.<String> = new Vector.<String>()
			var notes:Vector.<String> = new Vector.<String>()
			soundPaths.push(sounds)
			notePaths.push(notes)
			var dir:String = "sound/"+idx +"/"+dice+"/"
			var directory:File = File.applicationDirectory.resolvePath(dir)
			var contents:Array = directory.getDirectoryListing();  
			for (var i:uint = 0; i < contents.length; i++)  
			{ 
				var name:String = contents[i].name
				trace(dir + name)
				if( name.indexOf(".mp3") != -1) sounds.push(dir + name)
				else if( name.indexOf(".png") != -1) notes.push(dir + name) 
			} 	
			
		}
		
		
		
		
	}
}
		