/*
credit by aeddang-KJC(Jeong-Cheol Kim) 2010/03/04
*/
package com.libs.utils
{
	
	
	
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
		
	public class MySharedObject 
		
	{
			
		    private var mySo:SharedObject;
			private var id:String
			
			public function MySharedObject (_id:String):void
			{
				id=_id
				mySo = SharedObject.getLocal(id);
			}
			public function getData (seq:String):Object
			{
				var value:Object
				if(mySo.data[seq]!=undefined){
					value=mySo.data[seq]
					if(value is String == true){
						return value	
					}
					if(value.date!=-1 && value.date !=undefined && value.date !=null){
						var data:Date=new Date()
						trace("value.date : "+data.time+"   "+value.date)
						if(data.time>value.date){
						     return null;
						}else{
							return value.value;
						}
					}else{
						return value.value;
					}	
					
				}else{
					return null;
				}
				
			}
			public function getBoolean (seq:String,df:Boolean=false):Boolean
			{
				var value:Boolean
				if(mySo.data[seq]!=undefined){
					var v=getData (seq)
					
					if(v==true)
					{
						value=true;
					}else
					{
						if(v=="Y")
						{
							value=true;
						}
						else if(v=="N")
						{
							value=false;
						}else
						{
							value=df;
						}	
					}
				}else{
					value=df;
				}
				trace("VALUE : "+value)
				return value
			}
			public function setData (seq:String,value,t:Number=-1):void
			{
				var saveValue:Object=new Object()
				saveValue.value=value
				
				if(t!=-1){
					var data:Date=new Date()
					t=data.time+(t*24*60*100*1000);
					saveValue.date=t
				}else{
					saveValue.date=-1;
				}
				
				
				mySo.data[seq]=saveValue;
				var flushStatus:String = null;
				try {
					flushStatus = mySo.flush(500);
				} catch (error:Error) {
					trace("SharedInfo : Could not write SharedObject to disk");
				}
				if (flushStatus != null) {
					switch (flushStatus) {
						case SharedObjectFlushStatus.PENDING:
							trace("SharedInfo : Requesting permission to save object...");
							break;
						case SharedObjectFlushStatus.FLUSHED:
							trace("SharedInfo : Value flushed to disk.");
							break;
					}
				}	
			}
			
			
	}
	
	
	
}