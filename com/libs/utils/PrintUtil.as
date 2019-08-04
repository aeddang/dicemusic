/*
credit by aeddang-KJC(Jeong-Cheol Kim) 2010/11/12
*/

package com.libs.utils
{
	import flash.display.*;
	import flash.geom.Rectangle;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;
	
	public class PrintUtil
	{
		
		private var printJob:PrintJob;
		private var printOption:PrintJobOptions
		private var errFn:Function
		private var scMode:Boolean
		
		public function PrintUtil (printAsBitmap:Boolean=true,_scMode:Boolean=false,_errFn:Function=null):void
		{
			
			printOption=new PrintJobOptions
			printOption.printAsBitmap=printAsBitmap
			errFn=_errFn
			scMode=_scMode
		}
		
		
		public function printPage (mcA:Vector.<DisplayObject>,printAreaA:Vector.<Rectangle>=null):void {
			
			printJob=new PrintJob
			printJob.start();
			
			var num:int=mcA.length
			
			var i:int
			var frameA:Vector.<Sprite>=new Vector.<Sprite>
			if(printAreaA==null){
				printAreaA=new Vector.<Rectangle>
				for(i=0;i<num;++i){
					printAreaA[i]=null
				}
			}
			for(i=0;i<num;++i){
				frameA[i]=new Sprite
				frameA[i].addChild(DisplayUtil.makeBitmap(mcA[i]))
			}
			
			try {
				for(i=0;i<num;++i){
					if(scMode==true){
						DisplayUtil.equalRatioReSize(frameA[i],printJob.pageWidth,printJob.pageHeight)
					}else{
						frameA[i].height = printJob.pageHeight;
						frameA[i].width = printJob.pageWidth;
					}
					printJob.addPage(frameA[i], printAreaA[i], printOption);
				}
			}
			catch(e:Error) {
				trace ("PrintUtil : Had problem adding the page to print job: " + e);
				printErr()
			}
			try {
				printJob.send();
			}
			catch (e:Error) {
				trace (" PrintUtil : Had problem printing: " + e);   
				printErr()
			}
		}
		
		private function printErr():void{
			if(errFn!=null){
				errFn()
			}
		}
	}
	
}
