package com.libs.system
{
	import com.libs.utils.CommonUtil
	import flash.display.DisplayObject;
	import flash.system.Capabilities;
	/**
	 * ...
	 * @author oneweb@vi-nyl.com
	 */
	public class SWFPath
	{
		/**
		 * swf 파일이 위치한 경로를 리턴
		 * @param referObj : DisplayObject	참조할 swf의 displayObject
		 * @return	swf파일이 위치한 경로
		 */
		public static function getSwfPath(referObj : DisplayObject) : String{
			var curURL:String = referObj.loaderInfo.url;
			//trace("SWFPath url : "+curURL)
			if(isBrowser()){
				curURL = CommonUtil.getDirectory(curURL);
			}else{
				curURL = "";	
			}
			return curURL;	
		}
		
		/**
		 * swf 파일이 위치한 한단계 부모 경로를 리턴
		 * @param referObj	참조할 swf의 displayObject
		 * @return	swf파일이 위치한 경로
		 */
		public static function getSwfParentPath(referObj : DisplayObject) : String{
			var curURL:String = referObj.loaderInfo.url;
			
			
			if(isBrowser()){
				curURL = CommonUtil.getDirectoryParent(curURL);
			}else{
				curURL = "../";	
			}
			
			
			return curURL;	
		}
		
		/**
		 * 현재 실행되고 있는 flash 환경이 웹환경인지 로컬환경인지를 리턴
		 * @return	true일경우 브라우저(웹) 환경, false 일경우 로컬(스탠드 얼론 플레이어)
		 */
		public static function isBrowser():Boolean {
			var playerType:String = Capabilities.playerType;
			if(playerType == "ActiveX" || playerType == "PlugIn"){
				//웹브라우저에서 실행중
				return true;
			}else{
				//로컬 플레이어에서 실행중
				return false;
			}
		}
		
	}

}