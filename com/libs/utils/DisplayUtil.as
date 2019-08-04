/*
credit by aeddang-KJC(Jeong-Cheol Kim) 2010/03/04
*/

package com.libs.utils
{
	import flash.accessibility.Accessibility;
	import flash.accessibility.AccessibilityProperties;
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.media.Video;
	import flash.net.*;
	import flash.system.*;

	public class DisplayUtil
	{
		public static function getChildByName (pmc:DisplayObjectContainer ,instanceName : String):DisplayObject
		{
			var mc:DisplayObject
			try {
				mc=DisplayObject(pmc.getChildByName(instanceName))
			}
			catch( e : Error ) {
				
				mc=null
			}
			if(mc==null){
				trace("DisplayUtil : "+pmc+"--"+instanceName+" is null")
			}
			return mc
		}
		public static function getSymbolByName( className : String ) : DisplayObject {
			if ( ApplicationDomain.currentDomain.hasDefinition(className) == true ) {
				var symbolClass : Class = ApplicationDomain.currentDomain.getDefinition(className) as Class;
				return new symbolClass() as DisplayObject;
			}
			//trace("DisplayUtil : "+className+" is null")
			return null;
		}
		public static function setChildIndexByValue (pmc:DisplayObjectContainer,value:String="z",isNumeric:Boolean=true)
		{
			var num:int = pmc.numChildren
			if (num <= 0)
			{
				return
			}
			var cmc:DisplayObject;
			var idx:int
			var mcA:Vector.<DisplayObject>=new Vector.<DisplayObject>
			for (var i:int = 0; i < num; ++i)
			{
				cmc = pmc.getChildAt(i);
				mcA[i]=cmc
			}
			
			var idxA:Vector.<DisplayObject>=mcA.sort(compare)
			for (i = 0; i < num; ++i)
			{
				pmc.setChildIndex(idxA[i],i)
			}	
			function compare(a:DisplayObject,b:DisplayObject):Number
			{
			   var v:Number=a[value]-b[value]
			   //var v:Number=a.z-b.z
			   if(v==0){
				   return 0
			   }
			   switch(isNumeric){
			     case true:
					return -v
				 case false:
					return v
				 default:
					return 0
			     
			   }
			}
		}
		public static function removeAllChild (pmc:DisplayObjectContainer,tmcA:Vector.<DisplayObject>=null,index:int=0):Boolean
		{
			var num:int = pmc.numChildren - index;
			if (num < 0)
			{
				num = 0;
			}
			if (num == 0)
			{
				return false;
			}
			var cmc:DisplayObject;
			var idx:int
			
			for (var i:int = num; i > 0; --i)
			{
				cmc = pmc.getChildAt(i - 1);
				if(tmcA!=null){
					idx=tmcA.indexOf(cmc)
			    }else{
					idx=-1
				}
				if (idx == -1)
				{
					pmc.removeChild (cmc);
				}
			}
			return true;
		}
		public static function remove (mc:DisplayObject):void
		{
			
			var pmc:DisplayObjectContainer;
			try
			{
				pmc = DisplayObjectContainer(mc.parent);
			}
			catch (e:Error)
			{
				return;
			}
			if(pmc==null){
				return
			}
			pmc.removeChild (mc);
		}
		public static function mouseEnabled (mc:DisplayObjectContainer):void
		{
			mc.mouseChildren  =false
			mc.mouseEnabled =false
			/*
			var num:int = mc.numChildren
			var cmc:DisplayObject;
			for (var i:int = num; i > 0; --i)
			{
				cmc = mc.getChildAt(i - 1);
				if (cmc is InteractiveObject==true)
				{
				    if (cmc is DisplayObjectContainer==true)
				    {
						DisplayUtil.mouseEnabled(DisplayObjectContainer(cmc))
					}else{
						InteractiveObject(cmc).mouseEnabled =false
					}
				}
				
			}
			*/
		}
		public static function getFrameDuration(mc:MovieClip,target:int,fps:Number=0):Number
		{
			var spd:Number=0
			if(fps==0 && mc.stage==null){
				trace("DisplayUtil : "+mc+" stage is null")
			    return spd
			}
			if(fps==0){
				fps=mc.stage.frameRate
			}
			var diff:int=Math.abs(mc.currentFrame-target)
			spd=diff/fps
			return spd
			
		}
        public static function rollOn (mc:InteractiveObject,over:Function=null,out:Function=null,click:Function=null,down:Function=null,up:Function=null,btMode:Boolean=false):void
		{
			if ((mc is Sprite)==true)
			{
				Sprite(mc).buttonMode = btMode;
			}
			if (over != null)
			{
				mc.addEventListener (MouseEvent.ROLL_OVER,over);
			}
			if (out != null)
			{
				mc.addEventListener (MouseEvent.ROLL_OUT,out);
			}
			if (click != null)
			{
				mc.addEventListener (MouseEvent.CLICK,click);
			}
			if (down != null)
			{
				mc.addEventListener (MouseEvent.MOUSE_DOWN,down);
			}
			if (up != null)
			{
				mc.addEventListener (MouseEvent.MOUSE_UP,up);
			}
			
		}
		public static function rollOff (mc:InteractiveObject,over:Function=null,out:Function=null,click:Function=null,down:Function=null,up:Function=null):void
		{
			
			if (over != null)
			{
				mc.removeEventListener (MouseEvent.ROLL_OVER,over);
			}
			if (out != null)
			{
				mc.removeEventListener (MouseEvent.ROLL_OUT,out);
			}
			if (click != null)
			{
				mc.removeEventListener (MouseEvent.CLICK,click);
			}
			if (down != null)
			{
				mc.removeEventListener (MouseEvent.MOUSE_DOWN,down);
			}
			if (up != null)
			{
				mc.removeEventListener (MouseEvent.MOUSE_UP,up);
			}
		}
		public static function dragOn (mc:InteractiveObject,down:Function=null,up:Function=null):void
		{
			
			
			if (down != null)
			{
				mc.addEventListener (MouseEvent.MOUSE_DOWN,down);
			}
			if (up != null)
			{
				mc.addEventListener (MouseEvent.ROLL_OUT,up);
				mc.addEventListener (MouseEvent.MOUSE_UP,up);
			}
			if(mc.stage!=null){
				
				mc.stage.addEventListener(Event.MOUSE_LEAVE,up);
			}
			
		}
		public static function dragOff (mc:InteractiveObject,down:Function=null,up:Function=null):void
		{
			
			
			if (down != null)
			{
				mc.removeEventListener (MouseEvent.MOUSE_DOWN,down);
			}
			if (up != null)
			{
				mc.removeEventListener (MouseEvent.ROLL_OUT,up);
				mc.removeEventListener (MouseEvent.MOUSE_UP,up);
			}
			if(mc.stage!=null){
				mc.stage.removeEventListener(Event.MOUSE_LEAVE,up);
			}
			
		}
		public static function makeBitmap( mc:DisplayObject , smooth:Boolean = true ,wid:int=-1,hei:int=-1):Bitmap
		{
			var bitmap:Bitmap;
			if(wid==-1){
				wid=mc.width
			}
			if(hei==-1){
				hei=mc.height
			}
			var bitmapData:BitmapData = new BitmapData( wid, hei );
			try
			{
				//trace("DisplayUtil : change draw err")
				bitmapData.draw( mc );
				//trace("DisplayUtil : change new err")
				bitmap = new Bitmap( bitmapData );
				//trace("DisplayUtil : change smooth err")
				bitmap.smoothing = smooth;
			
				return bitmap;	
			}
			catch (e:Error)
			{
				trace("DisplayUtil : change Bitmap err")
			}
			return null
			
					
		}
		public static function copyBtm (btm:Bitmap):Bitmap
		{
			var btmImg:Bitmap = new Bitmap(btm.bitmapData.clone());
			btmImg.alpha = 0;
			btmImg.width=btm.width
			btmImg.height=btm.height
			btmImg.x=btm.x
			btmImg.y=btm.y
			return btmImg
		}
		
			
		public static function bitmapMask (maskMc:DisplayObject,imgMc:DisplayObject,cache:Boolean):void
		{
			maskMc.cacheAsBitmap = cache;
			imgMc.cacheAsBitmap = cache;
			imgMc.mask = maskMc;
			
		}
        public static function drawLine(mc:DisplayObject,C:uint,pointA:Vector.<Point>,gep:int=1,al:Number=1,fill:uint=0,fillAl:Number=0):void
		{
			var _mc:Shape;
			if ((mc is Shape)==true)
			{
				_mc=Shape(mc) ;
			}
			else if ((mc is Sprite)==true)
			{
				_mc = new Shape  ;
				Sprite(mc).addChildAt (_mc,0);
			}
			else
			{
				trace ("DisplayUtil : .graphics null");
				return;
			}
			_mc.graphics.clear ();
		    _mc.graphics.lineStyle (gep, C , al, true, LineScaleMode.VERTICAL,CapsStyle.SQUARE, JointStyle.MITER, 10)
			if(fillAl!=0){
				_mc.graphics.beginFill (fill,fillAl);
			}
			_mc.graphics.moveTo(pointA[0].x,pointA[0].y)
			for(var i:int=1;i<pointA.length;++i){
				_mc.graphics.lineTo(pointA[i].x,pointA[i].y)
			}
			if(fillAl!=0){
				_mc.graphics.lineTo(pointA[0].x,pointA[0].y)
				_mc.graphics.endFill()
			}
		}
		
		public static function drawRect (mc:DisplayObject,C:uint,wid:Number,hei:Number,alp:Number=1,gep:int=0,lc:uint=0,alpL:Number=0):void
		{
			var _mc:Shape;
			if ((mc is Shape)==true)
			{
				_mc=Shape(mc) ;
			}
			else if ((mc is Sprite)==true)
			{
				_mc = new Shape  ;
				Sprite(mc).addChild (_mc);
			}
			else
			{
				trace ("DisplayUtil : .graphics null");
				return;
			}
			_mc.graphics.clear ();
			var sp:int=0
			
			if(alpL!=0){
			   _mc.graphics.lineStyle (gep, lc , alpL, true, LineScaleMode.VERTICAL,CapsStyle.SQUARE, JointStyle.MITER, 10);
			   sp=Math.floor(gep/2)
			   wid=wid-gep
			   hei=hei-gep
			}
			if(alp!=0){
			   _mc.graphics.beginFill (C,alp);
			}
			_mc.graphics.drawRect (sp,sp,wid,hei);

		}
		
			
		public static function drawRectGradient (mc:DisplayObject,C:uint,wid:int,hei:int,gep:int,rotate:Number=0):void
		{
			var _mc:Shape;
			if ((mc is Shape)==true)
			{
				_mc=Shape(mc)
				;
			}
			else if ((mc is Sprite)==true)
			{
				_mc = new Shape  ;
				Sprite(mc).addChild (_mc);
			}
			else
			{
				trace ("DisplayUtil : .graphics null");
				return;
			}


			_mc.graphics.clear ();
			var fillType:String = GradientType.LINEAR;
			var colors:Array = [C,C,C,C];
			var alphas:Array = [0,1,1,0];
			var ratios:Array = [0,gep,255 - gep,255];
			var matr:Matrix = new Matrix  ;
			matr.createGradientBox (wid,25,rotate,0,0);
			_mc.graphics.beginGradientFill (fillType,colors,alphas,ratios,matr);
			_mc.graphics.drawRect (0,0,wid,hei);

		}

		public static function saturationFilter (mc:DisplayObject,n:Number,k:Number):void
		{
			if (n==0&&k==0)
			{
				mc.filters=null;
				return;
			}
			
			var matrix:Array = new Array  ;
			matrix = matrix.concat([k,n,n,0,0]);// red
			matrix = matrix.concat([n,k,n,0,0]);// green
			matrix = matrix.concat([n,n,k,0,0]);// blue
			matrix = matrix.concat([0,0,0,1,0]);// alpha
			var filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			mc.filters = [filter];
		}
		public static function glowFilter (mc:DisplayObject,color:uint=0xFF0000,al:Number=1.0,blurX:Number=6.0,blurY:Number=6.0,strength:Number=2,quality:int=1,inner:Boolean=false,knockout:Boolean=false):void
		{
			var filter:GlowFilter = new GlowFilter(color,al,blurX,blurY,strength,quality,inner,knockout);
			mc.filters = [filter];
		}
		public static function dropShadowFilter (mc:DisplayObject,distance:Number=4.0,angle:Number=45,color:uint=0,al:Number=1.0,blurX:Number=4.0,blurY:Number=4.0,strength:Number=1.0,quality:int=1,inner:Boolean=false,knockout:Boolean=false,hideObject:Boolean=false):void
		{
			var filter:DropShadowFilter = new DropShadowFilter(distance,angle,color,al,blurX,blurY,strength,quality,inner,knockout,hideObject);
			mc.filters = [filter];
		}
		public static function removeFilter (mc:DisplayObject):void
		{
			mc.filters = null;
		}
		public static function colorFilter (mc:DisplayObject,s:String):void
		{
           
			var i0:int = CommonUtil.uintToInt(s.slice(2,4));
			var i1:int = CommonUtil.uintToInt(s.slice(4,6));
			var i2:int = CommonUtil.uintToInt(s.slice(6,8));
			var n0:Number = i0 / 255;
			var n1:Number = i1 / 255;
			var n2:Number = i2 / 255;
			mc.transform.colorTransform = new ColorTransform(0,0,0,1,i0,i1,i2,0);
		}

		
		public static function equalRatioReSize (mc:DisplayObject,tw:int,th:int,smallResize:Boolean=false,dfWid:Number=0,dfHei:Number=0):void
		{

			var w:Number = mc.width;
			var h:Number = mc.height;
			if(dfWid==0){
			   w=mc.width
			   dfWid=w
			}else{
			   w=dfWid
			}
			if(dfHei==0){
				h=mc.height
				dfHei=h
			}else{
				h=dfHei
			}
			var sc:Number;
			if (w > tw || h > th)
			{
				if (w > tw)
				{
					sc = tw / w;
					w = tw;
					h = h * sc;
				}
				if (h > th)
				{
					sc = th / h;
					h = th;
					w = w * sc;
				}
			}else{
				if(smallResize==true){
					if (w < tw)
					{
						sc = tw / w;
						w = tw;
						h = h * sc;
					}
					if (h > th)
					{
						sc = th / h;
						h = th;
						w = w * sc;
					}
				}
			}
			mc.height = h;
			mc.width = w;
			mc.x = Math.round((tw - w) / 2);
			mc.y = Math.round((th - h) / 2);
			if (mc is Bitmap == true)
			{
				if(mc.height==dfHei && mc.width==dfWid){
				    Bitmap(mc).smoothing = false;
				}else{
					Bitmap(mc).smoothing = true;
				}
			}
			
		}
		
		public static function getEqualRatioRect (mc:Rectangle,tw:int,th:int,smallResize:Boolean=false,dfWid:Number=0,dfHei:Number=0):Rectangle
		{
			
			var w:Number = mc.width
			var h:Number = mc.height;
			if(dfWid==0){
				w=mc.width
				dfWid=w
			}else{
				w=dfWid
			}
			if(dfHei==0){
				h=mc.height
				dfHei=h
			}else{
				h=dfHei
			}
			var sc:Number;
			if (w > tw || h > th)
			{
				if (w > tw)
				{
					sc = tw / w;
					w = tw;
					h = h * sc;
				}
				if (h > th)
				{
					sc = th / h;
					h = th;
					w = w * sc;
				}
			}else{
				if(smallResize==true){
					if (w < tw)
					{
						sc = tw / w;
						w = tw;
						h = h * sc;
					}
					if (h > th)
					{
						sc = th / h;
						h = th;
						w = w * sc;
					}
				}
			}
			mc.height = h;
			mc.width = w;
			mc.x = Math.round((tw - w) / 2);
			mc.y = Math.round((th - h) / 2);
			return mc
			
		}
		
		public static function makeAccessible (mc:InteractiveObject,accessible:Boolean,name:String=null,tabIndex:int=-1,description:String=null)
		{
			if (mc.accessibilityProperties == null)
			{
				mc.accessibilityProperties = new AccessibilityProperties  ;
			}

			if (accessible)
			{
				mc.tabEnabled = true;
				if (mc is DisplayObjectContainer)
				{
					DisplayObjectContainer(mc).tabChildren = false;
				}
				if (name != null)
				{
					mc.accessibilityProperties.name = name;
				}
				if (! isNaN(tabIndex))
				{
					mc.tabIndex = tabIndex;
				}
				if (description != null)
				{
					mc.accessibilityProperties.description = description;
				}
				else
				{
				}
				mc.accessibilityProperties.forceSimple = true;
				mc.accessibilityProperties.silent = true;
			}
			if (Capabilities.hasAccessibility)
			{
				Accessibility.updateProperties ();
			}
		}
	}//class
}//package