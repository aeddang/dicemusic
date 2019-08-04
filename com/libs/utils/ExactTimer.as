/*
credit by aeddang-KJC(Jeong-Cheol Kim) 2010/03/04
*/
package com.libs.utils
{

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	

	public class ExactTimer extends Sprite
	{

		private var startTime:Number;
		private var _count:int;
		private var _delay:Number;
		private var _repeatCount:int;
		private var _isRun:Boolean
		public function ExactTimer (__delay:Number,__repeatCount:int=0):void
		{
			_delay = __delay;
			_repeatCount = __repeatCount;
			_isRun=false;
			reset ();
		}
		public function reset ():void
		{
			_count = 0;
			var now:Date = new Date  ;
			startTime = now.valueOf();
		}

		public function start ():void
		{
			_isRun=true;
			this.addEventListener (Event.ENTER_FRAME,onTimer);
		}
		public function stop ():void
		{
			_isRun=true;
			this.removeEventListener (Event.ENTER_FRAME,onTimer);
		}
		private function onTimer (e:Event):void
		{
			var now:Date = new Date  ;
			var cTime:Number = now.valueOf();
			var gep:Number = cTime - startTime;
			var cCount:int = Math.floor(gep / _delay);
			if (cCount > _count)
			{
				_count++;
				this.dispatchEvent (new TimerEvent(TimerEvent.TIMER));
			}
			if (_repeatCount != 0 && _count == _repeatCount)
			{
				stop ();
			}
		}
		public function get isRun ():Boolean
		{
			return _isRun;
		}

		public function get delay ():Number
		{
			return _delay;
		}
		public function set delay (__delay):void
		{
			_delay = __delay;
		}
		public function get currentCount ():int
		{
			return _count;
		}
		public function set currentCount (__count):void
		{
			_count = __count;
		}

		public function set repeatCount (__repeatCount):void
		{
			_repeatCount = __repeatCount;
		}

	}

}