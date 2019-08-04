/*
credit by aeddang-KJC(Jeong-Cheol Kim) 2010/03/04
*/
package com.libs.loaders
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	import flash.system.*;

	public class FontLoader
	{

		private var classNameA:Vector.<String>;
		private var font_ldr:Loader;
		private var comFn:Function;
		private var errFn:Function;
		private var proFn:Function;
		private var _fontNameA:Vector.<String>

		public function FontLoader (urlPass:String,_classNameA:Vector.<String>,_comFn:Function,_errFn:Function=null,_proFn:Function=null):void
		{
			comFn = _comFn;
			errFn = _errFn;
			proFn = _proFn;
			classNameA = _classNameA;
			_fontNameA=new Vector.<String>
			font_ldr = new Loader  ;
			var urlReq:URLRequest = new URLRequest(urlPass);
			var context:LoaderContext = new LoaderContext  ;
			context.checkPolicyFile = true;
			context.applicationDomain = ApplicationDomain.currentDomain
			
			font_ldr.load (urlReq,context);
			font_ldr.contentLoaderInfo.addEventListener (Event.COMPLETE,fontLoadCompleate);
			font_ldr.contentLoaderInfo.addEventListener (IOErrorEvent.IO_ERROR,fontLoadErr);

			if (proFn != null)
			{
				font_ldr.addEventListener (ProgressEvent.PROGRESS,proFn);
			}
		}
		public function removeFontLoader ():void
		{
			if (font_ldr == null)
			{
				return;
			}
			font_ldr.removeEventListener (Event.COMPLETE,fontLoadCompleate);
			font_ldr.removeEventListener (IOErrorEvent.IO_ERROR,fontLoadErr);
			if (proFn != null)
			{
				font_ldr.removeEventListener (ProgressEvent.PROGRESS,proFn);
			}
			try
			{
				font_ldr.close ();
			}
			catch (e:Error)
			{
				
			}
			
			
			comFn = null;
			errFn = null;
			proFn = null;
		}
		public function get  fontNameA():Vector.<String>
		{
			return _fontNameA
		}
		private function fontLoadErr (e:Event):void
		{
			trace ("FontLoader : fontload err");
			if (errFn != null)
			{
				errFn ();
			}
			else
			{
				comFn ();
			}
			removeFontLoader ();
		}
		private function fontLoadCompleate (e:Event):void
		{
            var sharedFont:Class 
			var fontA:Array
			
			for(var i:int=0;i<classNameA.length;++i){
				sharedFont= e.currentTarget.applicationDomain.getDefinition(classNameA[i]) as Class;
				Font.registerFont (sharedFont);
				fontA=Font.enumerateFonts (false);
				trace(fontA[i].fontName)
				_fontNameA[i]=fontA[i].fontName
			}
			trace(fontA[0].fontName)
			comFn ();
			removeFontLoader ();
		}
		
	}
}