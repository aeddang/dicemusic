/*
credit by aeddang-KJC(Jeong-Cheol Kim) 2010/03/04
*/

package com.libs.utils
{
   // import flash.system.ApplicationDomain;
    import flash.utils.ByteArray;
	public class CommonUtil
	{
		
		/*
		public static function getClass (className:String,returnClass:Class):Object
		{
			if ( ApplicationDomain.currentDomain.hasDefinition(className) == true ) {
				var findClass : Class = ApplicationDomain.currentDomain.getDefinition(className) as Class;
				return new findClass() as returnClass;
			}
			
			return null;
		}
		*/
		
		public static function overrideObject (defaultObj:Object,updateObj:Object):Object
		{
			if (updateObj == null)
			{
				return defaultObj;
			}
			for (var key:String in updateObj)
			{
				
				
					try{
						defaultObj[key] = updateObj[key];
					}catch(e:Error){
						
					}
					
			
				
			}
			return defaultObj;
		}
		
		public static function updateObject (defaultObj:Object,updateObj:Object):Object
		{
			if (updateObj == null)
			{
				return defaultObj;
			}
			for (var key:String in defaultObj)
			{
				//trace(key+"="+defaultObj[key])
				if (updateObj[key] == undefined)
				{
					updateObj[key] = defaultObj[key];
				}
			}
			return updateObj;
		}

		public static function getRandomInt (n:int):int
		{
			if (n <= 0)
			{
				return 0;
			}
			var r:Number = Math.random();
			var k:int = Math.floor(r * n );
			if(k==n){
			   k=n-1
			}
			return k;
		}
		public static function getNumberData (str:String,df:String="0"):Number
		{
			 if(str=="undefiend" || str=="null" || str==""){
				str=df
			 }
			 return Number(str) 
		}
		public static function getIntData (str:String,df:String="0"):int
		{
			 if(str=="undefiend" || str=="null" || str==""){
				str=df
			 }
			 return int(str) 
		}
		public static function getStrData (str:String,df:String=""):String
		{
			 if(str=="undefiend" || str=="null" || str==""){
				str=df
			 }
			 return str
		}
		public static function getPctByRatio (ritio:Number,len:int=2, addString = "" ):String
		{
			 return String((ritio*100).toFixed(len)+addString)
		}
		public static function getStringSlice (str:String,len:int,slc:int=-1,addStr:String="..."):String
		{
			if (str.length > len)
			{
				if (slc == -1)
				{
					slc = len - 2;
				}
				str = str.slice(0,slc) + addStr;
				return str;
			}
			else
			{
				return str;
			}
		}
		public static function getStringSliceR (str:String,len:int):String
		{
			var mN:int = str.length;
			if (mN <= len)
			{
				return str;
			}
			var sN:int = mN - len;
			str = str.slice(sN,mN);
			return str;
		}
		public static function getStringDivision (str:String,key:String):Vector.<String>
		{
			var num:int = str.length;
			var s:String;
			var txtA:Vector.<String> = new Vector.<String>;
			var t:String = "";
			var an:int = 0;
			var p:int = 0;
			for (var i:int = 0; i < num; ++i)
			{
				s = str.slice(i,i + 1);
				switch (s)
				{
					case key :
						txtA[an] = str.slice(p,i);
						an++;
						p = i + 1;
						break;
					default :
						break;
				}
			}
			txtA.push (str.slice(p));
			return txtA;
		}
        public static function getPriceStr (price:Number):String
		{
            if(price==0){
				return "0"
			}
			var str:String=String(price)
			var pointStr:String=""
			var strA:Vector.<String>=CommonUtil.getStringDivision (str,".")
			str=strA[0]
			if(strA.length>1){
				pointStr="."+strA[1]
			}
			
			var num:int=str.length;
			var s:String="";
			if (num>3)
			{
				var min:int=num-3;
				for (var i:int=min; i>-3; i-=3)
				{
					if (i>0)
					{
						s= ","+str.slice(i,i+3)+s;
					} else
					{
						s= str.slice(0,i+3)+s;
					}
				}
			} else
			{
				s=str;
			}
			return s+pointStr;
		}
		
		public static function getDateByCode (yymmdd:int,key:String="-"):String
		{
			var ymdStr:String=String(yymmdd)
			if(ymdStr.length!=8){
				return ""
			}
			
			var str:String=ymdStr.slice(0,4)+key+ymdStr.slice(4,6)+key+ymdStr.slice(6,8)
			return str
		}
		public static function textToInt (str:String):int
		{
			var num:int = str.length - 1;
			var n:String;
			var dfStr:String = str;
			for (var i:int = 0; i < num; ++i)
			{
				n = dfStr.slice(i,i + 1);
				switch (n)
				{
					case "0" :
						break;
					default :
						return int(str);
				}
				str = dfStr.slice(i + 1);
			}
			return int(str);
		}
		public static function getTimeStr (t:Number,div:String=":"):String
		{
			var m:Number=t%3600
			var tim:String=""
			if(Math.floor(t/3600)>0){
				tim=intToText(Math.floor(t/3600),2)+div
			}	
			tim=tim+intToText(Math.floor(m/60),2)+div+CommonUtil.intToText((m%60),2)
			return tim;
		}
		public static function intToText (n:int,len:int):String
		{
			var str:String = String(n);
			var num:int = str.length;
			if (num >= len)
			{

			}
			else
			{
				for (var i:int = num; i < len; ++i)
				{
					str = "0" + str;
				}
			}

			return str;
		}
		public static function uintToInt (s:String):int
		{
			var n:int;
			var n0:int = codeToInt(s.slice(0,1));
			var n1:int = codeToInt(s.slice(1,2));
			n = n0 * 16 + n1;
			return n;
		}

		private static function codeToInt (s:String):int
		{
			var n:int;
			var k;
			switch (s)
			{
				case "a" :
					n = 10;
					break;
				case "b" :
					n = 11;
					break;
				case "c" :
					n = 12;
					break;
				case "d" :
					n = 13;
					break;
				case "e" :
					n = 14;
					break;
				case "f" :
					n = 15;
					break;
				case "A" :
					n = 10;
					break;
				case "B" :
					n = 11;
					break;
				case "C" :
					n = 12;
					break;
				case "D" :
					n = 13;
					break;
				case "E" :
					n = 14;
					break;
				case "F" :
					n = 15;
					break;
				default :
					k = s;
					n = k - 0;
					break;
			}
			return n;
		}

		/** getDays
		 * @parammon(int)
		 * @paramyear(int)
		 * @paramday(int)
		 * @return(int)
		*/
		public static function getDays (year:int,mon:int,day:int):int
		{

			var someday:Date = new Date(year,mon - 1,day);
			return someday.getDay();
		}
		/** getDaysInMonth
		 * @parammon(int)
		 * @paramyear(int)
		 * @return(int)
		*/
		public static function getDaysInMonth (year:int,mon:int):int
		{
			var daysInMonth = new Array(31,28,31,30,31,30,31,31,30,31,30,31);
			if (isLeapYear(year) == true)
			{
				daysInMonth[1] = 29;
			}
			return daysInMonth[mon - 1];
		}
		/** isLeapYear
		 * @paramyear(int)
		 * @return(Boolean)
		*/
		private static function isLeapYear (year:int):Boolean
		{
			if (year % 4 == 0 && year % 100 != 0 || year % 400 == 0)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
        public static function calcBytesString( str: String, encode:String = "utf-8" ): uint
		{
			var bytes: ByteArray = new ByteArray();
			bytes.writeMultiByte( str, encode )
			return bytes.length;
		}
		public static function escapeStr(str:String):String {
			var num:int=str.length
			var returnStr:String=""
			var s:String=""
	        for (var i:int = 0; i < num; ++i)
			{
				s=str.charAt(i)
				/*
				if(s=="&"){
					s="%26"
				}
				*/
				if(s=="<"){
					s="&lt"
				}
				if(s==">"){
					s="&gt"
				}
				returnStr=returnStr+s
			}
			return returnStr
		}
		public static function getUrlParam (urlStr:String):Object
		{
			var urlObject=new Object
			var uA:Array=urlStr.split("?")
			var paramStr:String
			if(uA.length<2){
				urlObject.url=urlStr
				return urlObject
			}else{
				urlObject.url=uA[0]
				paramStr=uA[1]
			}
				
			var param:Object=new Object
			var pA:Array=paramStr.split("&")
			var sA:Array
			for(var i:int=0;i<pA.length;++i){
				sA=String(pA[i]).split("=")
				if(sA.length==2){
					param[sA[0]]=sA[1]
				}
			}	
			urlObject.param=param
			return urlObject;
		}
		public static function trim(str:String):String {
			if (str == null) { return ''; }
			return str.replace(/^\s+|\s+$/g, '');
		}
		public static function isWhiteStr(str:String):Boolean {
			var len:int=str.length
			for(var i:int=0;i<len;++i ){
				if(str.charAt(i)!=" "){
				   return false
				}
			}
			return true
		}
        public static function getDirectory(str:String):String{
			var str:String;
			if(str.lastIndexOf("\\")!=-1){
				str = str.substring(0,str.lastIndexOf("\\")) + "\\";
			}else{
				str = str.substring(0,str.lastIndexOf("/")) + "/";
			}
			return str;
		}

		/**
		 * 전달된 파일경로에서 파일명 제거후 디렉토리 만 리턴
		 * @param str	파일경로
		 * @return		파일명이 제거된 순수한 폴더 경로
		 */
		public static function getDirectoryParent(str:String):String{
			var str:String;
			if(str.lastIndexOf("\\")!=-1){
				str = str.substring(0,str.lastIndexOf("\\"));
				str = str.substring(0,str.lastIndexOf("\\")) + "\\";
			}else{
				str = str.substring(0,str.lastIndexOf("/"));
				str = str.substring(0,str.lastIndexOf("/")) + "/";
			}
			return str;
		}
		
		public static function hasKOR(str:String):Boolean{
			
			var len:int=str.length
			var s:int;
			for(var i:int=0;i<len;++i ){
				s=str.charCodeAt(i)
				if(s>=44032 && s<=55199){
					return true
				}
			}
			return false
		}
	}//class
}//package