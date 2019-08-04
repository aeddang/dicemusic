/*
credit by aeddang-KJC(Jeong-Cheol Kim) 2010/03/04
*/
package com.libs.utils
{
	import flash.external.*;
	import flash.net.*;
	
	public class ExternalUtil
	{
		public static function alert (msg:String):void
		{
			trace ("ExternalUtil : alert="+msg);
			navigateToURL(new URLRequest("javascript:alert(\" "+msg+"  \")"),"_self");
		}
		public static function windowOpen(pageUrl:String, title:String="") : void
		{
			
			trace ("ExternalUtil : url="+pageUrl+"  title="+title);
			if(pageUrl==""||pageUrl=="undefined"){
				return
			}
		    ExternalInterface.call("window.open('"+pageUrl+"', '"+title+"')");
		}
		public static function windowResize(wid:int,hei:int) : void
		{
			ExternalInterface.call("javascript:self.resizeTo("+wid+","+hei+");");
		}
		public static function windowFullSize() : void
		{
			var id:String="document.getElementById("+ExternalInterface.objectID+")"
		    ExternalInterface.call("javascript:self.resizeTo("+id+".clientWidth,"+id+".clientHeight);");
		}
		public static function gotoTop():void
		{
			ExternalInterface.call("window.scrollTo('0')");
		}	
		
		public static function windowClose(alt:Boolean=true) : void
		{
			if(alt==true)
			{
				ExternalInterface.call("window.close()");
			}
			else
			{
				ExternalInterface.call("window.open('about:blank','_self').close()");
			}
		}
		public static function gotoLink (pageUrl:String,target:String="_self"):void
		{
			trace ("ExternalUtil : url="+pageUrl+"  tar="+target);
			if(pageUrl==""||pageUrl=="undefined"){
				return
			}
			if(target==""||target=="undefined"){
				target="_self"
			}
			navigateToURL(new URLRequest(pageUrl),target);
		}
		
		public static function gotoPage(pageUrl:String,target:String="_self"):void
		{
			trace ("ExternalUtil : url="+pageUrl+"  tar="+target);
			if(pageUrl==""||pageUrl=="undefined"){
				return
			}
			if(target==""||target=="undefined"){
				target="_self"
			}
			ExternalInterface.call("FF_gotoPage",pageUrl,target);
		}
		
		public static function gotoScript (js:String,args:Array=null):void
		{
			if(args==null){
				args=new Array
			}
			var num:int=args.length;
			trace ("ExternalUtil : js="+js+"  varNum="+num);
			switch (num)
			{
				case 1 :
					ExternalInterface.call (js,args[0]);
					break;
				case 2 :
					ExternalInterface.call (js,args[0],args[1]);
					break;
				case 3 :
					ExternalInterface.call (js,args[0],args[1],args[2]);
					break;
				case 4 :
					ExternalInterface.call (js,args[0],args[1],args[2],args[3]);
					break;
				default :
					ExternalInterface.call (js,args[0],args[1],args[2],args[3],args[4]);
					break;
			}
		}
		
		public static function changeFlashSize(wid:String,hei:String):void
		{
			trace ("ExternalUtil : wid="+wid+"  hei="+hei);
			var id:String=ExternalInterface.objectID;
			ExternalInterface.call("FF_changeFlashSize", id, wid, hei);
		}
		
		
		public static function setCookie(key:String, value:String):void
		{
			trace ("ExternalUtil : key="+key+"  value="+value);
			ExternalInterface.call("FF_setCookie", "f_"+key, value);
		}
		

		
		
	}//class
}//package