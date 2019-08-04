/*
credit by aeddang-KJC(Jeong-Cheol Kim) 2010/03/04
*/

package com.libs.utils
{
	import flash.system.*;
	

	public class SystemUtil
	{
		
		public static  function inputKor ():void
		{
			if (Capabilities.hasIME)
			{
				if (IME.enabled)
				{
					
					trace ("SystemUtil : IME is installed and enabled.");
				}
				else
				{
					trace ("SystemUtil : IME is installed but not enabled. Please enable your IME and try again.");
				}
				//
			}
			else
			{
				trace ("SystemUtil : IME is not installed. Please install an IME and try again.");
			}
			if (Capabilities.hasIME)
			{
				try
				{
					IME.enabled = true;
					IME.conversionMode = IMEConversionMode.KOREAN;
				}
				catch (error:Error)
				{
					
				}
			}

		}
	}//class
}//package