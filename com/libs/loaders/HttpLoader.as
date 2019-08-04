/*
credit by aeddang-KJC(Jeong-Cheol Kim) 2010/03/04
*/
package com.libs.loaders
{
	import com.adobe.serialization.json.JSON;
	import com.libs.utils.CommonUtil;
	
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.net.URLVariables;
	
	public class HttpLoader
	{
		private var loader:Object
		
		private var comFn:Function;
		private var errFn:Function;
		private var proFn:Function;
		private var comErrFn:Function;
		private var returnType:String
		private var type:String
		private var _boundary:String
		private var idx:int
		public function HttpLoader (urlPass:String,_comFn:Function,_errFn:Function=null,_proFn:Function=null,_comErrFn:Function=null,varObj:Object=null,_type:String="utf",_returnType:String="xml",_idx:int=-1,sendType:String="post"):void
		{
			comFn = _comFn;
			errFn = _errFn;
			proFn = _proFn;
			comErrFn = _comErrFn;
			_boundary = null;
			type=_type
			returnType=_returnType
			idx=_idx
			var variables:URLVariables
			var paramStr:String=""
			var req:URLRequest	
			if(varObj==null){
				req = new URLRequest(urlPass);
				req.method = URLRequestMethod.GET
				trace("XmlLoader: "+urlPass)
			}else
			{
				
				variables=new URLVariables()
				for (var key:String in varObj)
				{
					variables[key] = varObj[key];
					
					if(paramStr==""){
						paramStr=paramStr+"?"+key+"="+variables[key]
					}else{
						paramStr=paramStr+"&"+key+"="+variables[key]
					}
					
				}
				trace("XmlLoader: "+urlPass+paramStr)
				if(sendType=="post"){
					req = new URLRequest(urlPass);
					req.method = URLRequestMethod.POST
					req.data = variables;
				}else{
					req = new URLRequest(urlPass+paramStr);
					req.method = URLRequestMethod.GET
				}
			}
			
			
			
			if(type=="utf"){
				loader=new URLLoader 
			}else{
				loader=new URLStream
			}
			
			loader.addEventListener (Event.COMPLETE,returnXml);
			loader.addEventListener (IOErrorEvent.IO_ERROR,errXml);
			
			if(type=="utf"){
				URLLoader (loader).load (req)
			}else{
				URLStream(loader).load (req)
			}
			if (proFn != null)
			{				
				loader.addEventListener (ProgressEvent.PROGRESS,proFn);
			}
			
		}
		
		public function removeXmlLoader ():void
		{
			if (loader == null)
			{
				return;
			}
			loader.removeEventListener (Event.COMPLETE,returnXml);
			loader.removeEventListener (IOErrorEvent.IO_ERROR,errXml);
			if (proFn != null)
			{
				loader.removeEventListener (ProgressEvent.PROGRESS,proFn);
			}
			try
			{
				if(type=="utf"){
					URLLoader (loader).close ();
				}else{
					URLStream(loader).close ();
				}
			}
			catch (e:Error)
			{
				trace("XmlLoader : clear err")
			}
			
			
			comFn = null;
			errFn = null;
			proFn = null;
		}
		private function errXml (e:Event):void
		{
			
			trace ("XmlLoader : xmlload err");
			
			if (errFn != null)
			{
				if(idx==-1){
					errFn ();
				}else{
					errFn (idx)
				}
				
			}
			removeXmlLoader ();
		}
		private function returnXml (e:Event):void
		{
			
			var str : String
			if(type=="utf"){
				
				str=URLLoader (loader).data
			}else{
				
				str  = URLStream(loader).readMultiByte(loader.bytesAvailable, "euc-kr");
			}
			
			
			if(returnType=="xml"){
				var xml:XML;
				try
				{
					xml = new XML(str);
				}
				catch (e:Error)
				{
					if (comErrFn != null)
					{
						
						if(idx==-1){
							comErrFn  ();
						}else{
							comErrFn  (idx);
						}
					}
					trace ("XmlLoader : xmldata err");
					
				}
				if (comFn != null)
				{
					xml.ignoreWhitespace=true
					if(idx==-1){
						comFn (xml);
					}else{
						comFn (xml,idx);
					}
				}
			}else if(returnType=="json"){
				var json:Object;
				try
				{
					var s:int=str.indexOf("(")
					var f:int=str.indexOf(")")
					if(s==-1){
						s=0
					}else{
						s=s+1
					}
					if(f==-1){
						f=str.length
					}
					str=str.substring(s,f)
					
					json = com.adobe.serialization.json.JSON.decode(str);
				}
				catch (e:Error)
				{
					if (comErrFn != null)
					{
						
						if(idx==-1){
							comErrFn  ();
						}else{
							comErrFn  (idx);
						}
					}
					trace ("XmlLoader : jsondata err");
					
				}
				if (comFn != null)
				{
					
					if(idx==-1){
						comFn (json);
					}else{
						comFn (json,idx);
					}
				}
				
				
			}else
			{
				if (comFn != null)
				{
					if(idx==-1){
						comFn (str);
					}else{
						comFn (str,idx);
					}
				}
				
			}
			removeXmlLoader ();
		}
	}
}