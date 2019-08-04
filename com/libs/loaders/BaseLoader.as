/*
credit by aeddang-KJC(Jeong-Cheol Kim) 2010/03/04
*/
package com.libs.loaders
{
	import flash.display.*;
	import flash.net.*;
	import flash.system.*;
	import flash.events.*;
	import com.libs.utils.CommonUtil

	public class BaseLoader
	{
		private var loader:Loader
		private var comFn:Function;
		private var errFn:Function;
		private var proFn:Function;
		private var securityFn:Function;
		private var idx:int
		public function BaseLoader (mc:DisplayObjectContainer,urlPass:String,updateInfo:Object=null,_comFn:Function=null,_errFn:Function=null,_proFn=null,_securityFn=null):void
		{
			//trace("BaseLoader : load "+urlPass)
			comFn = _comFn;
			errFn = _errFn;
			proFn = _proFn;
			securityFn=_securityFn;
			var defaultInfo = new Object  ;
			defaultInfo.addAc = true;
			defaultInfo.applicationDomain=true
			defaultInfo.tx = 0;
			defaultInfo.ty = 0;
			defaultInfo.index = 0;
			defaultInfo.idx = -1
			defaultInfo = CommonUtil.updateObject(defaultInfo,updateInfo);
			
			idx=defaultInfo.idx
			loader = new Loader  ;
			var urlRequest:URLRequest = new URLRequest(urlPass);
			var context:LoaderContext = new LoaderContext  ;
			context.checkPolicyFile = true;
			if(defaultInfo.applicationDomain==true){
			    context.applicationDomain = ApplicationDomain.currentDomain
			}else{
				context.applicationDomain = null
			}
            loader.load (urlRequest,context);
			if (defaultInfo.addAc == true &&mc!=null)
			{
				mc.addChildAt (loader,defaultInfo.index);
				loader.x = defaultInfo.tx;
				loader.y = defaultInfo.ty;
			}
			loader.contentLoaderInfo.addEventListener (Event.COMPLETE,loadComplete);
			loader.contentLoaderInfo.addEventListener (IOErrorEvent.IO_ERROR,loadErr);
			loader.contentLoaderInfo.addEventListener (SecurityErrorEvent.SECURITY_ERROR,securityError)
			
			
			if (proFn != null)
			{
				loader.contentLoaderInfo.addEventListener (ProgressEvent.PROGRESS,proFn);
			}
		}
		public function clearLoader ():void
		{
			if (loader == null)
			{
				return;
			}
			try
			{
				loader.unloadAndStop();
			}
			catch (e:Error)
			{
				trace("BaseLoader : clear err")
			}
			loader =null
		}
		public function removeLoader ():void
		{
			if (loader == null)
			{
				return;
			}
			loader.removeEventListener (Event.COMPLETE,loadComplete);
			loader.removeEventListener (IOErrorEvent.IO_ERROR,loadErr);
			if (proFn != null)
			{
				loader.removeEventListener (ProgressEvent.PROGRESS,proFn);
			}
			
			try
			{
				loader.close ();
			}
			catch (e:Error)
			{
				
			}
			comFn = null;
			errFn = null;
			proFn = null;
		}
		private function securityError(e:SecurityErrorEvent):void
		{
			if (securityFn != null)
			{
				if(idx==-1){
					securityFn ();
				}else{
					securityFn (null,idx)
				}
			}
		}
		private function loadErr (e:IOErrorEvent):void
		{
			if (errFn != null)
			{
				if(idx==-1){
				    errFn ();
				}else{
					errFn (null,idx)
				}
			}
			removeLoader ()
			trace ("BaseLoader : load err");

		}
		private function loadComplete (e:Event):void
		{
			if(comFn!=null){
			   if(idx==-1){
				   comFn (e);
			   }else{
				   comFn (e,idx);
			   }
				
			}
			removeLoader ()
		}
	}//class
}//package