package classes.model
{
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import classes.Main
	import classes.Config
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	
	public class InstrumentData
	{
		private static const COLOR_EXCUTE_RANGE:int = 10
		
		public var idx:int = -1
		public var color:int = -1
		public var name:String
		
	
		private  var soundPaths:Vector.<Vector.< Vector.<String> >> = new Vector.<Vector.< Vector.<String> >>()
		private  var notePaths:Vector.<Vector.< Vector.<String> >> = new Vector.<Vector.< Vector.<String> >>()
		private  var defaultNotePaths:Vector.< Vector.<String> > = new Vector.< Vector.<String> >()
		public function InstrumentData(_idx:int, _color:int,_name:String)
		{
			name = _name
			idx = _idx
			color = _color
			setupExistFilePath()
		}
		public function getSoundPath(group:int, dice:int,r:int):String{
			return soundPaths[group][dice][r]
		}
		
		public function getNotePath(group:int, dice:int,r:int):String{
			return notePaths[group][dice][r]
		}
		
		public function getDefaultPath(group:int, dice:int):String{
			return defaultNotePaths[group][dice]
		}
		
		public function getRandomPath(group:int, dice:int):int{
			
			var sounds:Vector.<String> = soundPaths[group][dice]
			var notes:Vector.<String> = notePaths[group][dice]
			var pathNum:int = Math.min(sounds.length, notes.length)
			if(notes.length == 0) pathNum = sounds.length
			var currentPath:int = Math.floor( Math.random() * pathNum )
			if(currentPath >= pathNum) currentPath = pathNum-1
			return currentPath	
		}
		
		private function setupExistFilePath(){
			for (var x:uint = 0; x < 5; x++)  
			{
				var defaultNotes:Vector.<String> = new Vector.<String>()
				var sounds:Vector.< Vector.<String> > = new Vector.< Vector.<String> >()
				var notes:Vector.< Vector.<String> > = new Vector.< Vector.<String> >()
				for (var i:uint = 0; i < 6; i++)  
				{
					setExistFilePath(sounds,notes,defaultNotes,x, i)
					
				}
				soundPaths.push(sounds)
				notePaths.push(notes)
				defaultNotePaths.push(defaultNotes)
			}
			
		}
		
		private function setExistFilePath(soundSets:Vector.< Vector.<String> >,noteSets:Vector.< Vector.<String> >, defaultNotes:Vector.<String>,group:int,dice:int){
			
		
			var sounds:Vector.<String> = new Vector.<String>()
			var notes:Vector.<String> = new Vector.<String>()
			
			var soundDir:String = "music/group"+(group+1)+"/dice"+(Config.INSTRUMENT_IDS[idx])+"/"
			var soundDirectory:File = File.applicationDirectory.resolvePath(soundDir)
			var mps:Array = soundDirectory.getDirectoryListing(); 
			var key:String = "0"+(dice+1)
			
			//trace(soundDir + "*********************")
			for (var i:int = 0; i < mps.length; i++)  
			{ 
				var mp:String = mps[i].name
				if(mp == "00.jpg") defaultNotes.push(soundDir + mp)
				if( mp.indexOf(key) != -1) {
				
					if(mp.indexOf(".mp3") != -1) {
						sounds.push(soundDir + mp)
					}
					if(mp.indexOf(".jpg") != -1) {
						 notes.push(soundDir + mp)
					}
				}
			} 	
			//trace("*********************")
			soundSets.push(sounds.sort(0))
			noteSets.push(notes.sort(0))
		}
	}
}
		