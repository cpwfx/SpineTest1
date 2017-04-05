package harayoki.spine.starling {
	import flash.geom.Point;
	
	import starling.core.Starling;
	
	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class SpineSlotButtonGroup {
		
		private static var P:Point = new Point();
		private static const TOUCHES_BEGAN:Vector.<Touch> = new <Touch>[];
		private static const TOUCHES_END:Vector.<Touch> = new <Touch>[];
		
		/**
		 * 1つのタッチを複数の重なったボタンに反応させてよいか
		 * (マルチタッチの抑制ではない)
		 */
		public var allowMultiHitPerTouch:Boolean = true;
		
		private var _touchEventSource:DisplayObject;
		private var _enabled:Boolean = true;
		private var _buttons:Vector.<SpineSlotButton>;
		private var _handlerReady:Boolean = false;
		
		public function SpineSlotButtonGroup(touchEventSource:DisplayObject=null) {
			this._touchEventSource = touchEventSource;
			_buttons = new <SpineSlotButton>[];
		}
		public function dipose():void {
			enabled = false;
			removeAll();
		}
		private function _initTouchHandler():void {
			if(_handlerReady) {
				return;
			}
			if(!_touchEventSource) {
				_touchEventSource = Starling.current.stage;
			}
			_applyEnabled();
		}
		
		private function _handleTouch(ev:TouchEvent):void {
			
			TOUCHES_BEGAN.length = 0;
			TOUCHES_END.length = 0;
			ev.getTouches(_touchEventSource, TouchPhase.BEGAN, TOUCHES_BEGAN);
			ev.getTouches(_touchEventSource, TouchPhase.ENDED, TOUCHES_END);
			
			if(TOUCHES_BEGAN.length == 0 && TOUCHES_END.length == 0) {
				return;
			}
			
			if(!allowMultiHitPerTouch) {
				//同時に複数の重なったボタンに反応させない時は現在のアニメの重なり順でソートさせて上から判定する
				_buttons.sort(_btnSortFunc);
			}
			
			for1 : for each(var touch:Touch in TOUCHES_BEGAN) {
				P.setTo(touch.globalX, touch.globalY);
				for2 : for each(var btn:SpineSlotButton in _buttons) {
					var hit:Boolean = btn.hitTest(P, touch.phase);
					if(hit) {
						btn.invokeTouchStart();
						if(!allowMultiHitPerTouch) {
							// 一度ヒットしたら背面のオブジェクトは無視する
							break for2;
						}
					}
				}
			}
			
			for1 : for each(var touch2:Touch in TOUCHES_END) {
				P.setTo(touch2.globalX, touch2.globalY);
				for2 : for each(var btn2:SpineSlotButton in _buttons) {
					var hit2:Boolean = btn2.hitTest(P, touch2.phase);
					if(hit2) {
						btn2.invokeTouchEnd();
						if(!allowMultiHitPerTouch) {
							// 一度ヒットしたら背面のオブジェクトは無視する
							break for2;
						}
					}
				}
			}
		}
		
		// 表示深度でソート(手前が優先)
		private function _btnSortFunc(a:SpineSlotButton, b:SpineSlotButton):int {
			return b.getSlotDepth() - a.getSlotDepth();
		}
		
		public function set enabled(value:Boolean):void {
			if(_enabled == value) return;
			_enabled = value;
			_applyEnabled();
		}
		
		private function _applyEnabled():void {
			if(!_touchEventSource) {
				return;
			}
			if(_enabled) {
				_touchEventSource.addEventListener(TouchEvent.TOUCH, _handleTouch);
			} else {
				_touchEventSource.removeEventListener(TouchEvent.TOUCH, _handleTouch);
			}
		}
		
		public function get enabled():Boolean {
			return _enabled;
		}
		
		
		public function add(button:SpineSlotButton):void {
			remove(button);
			_buttons.push(button);
			_initTouchHandler(); // stageが存在する必要があるのでこのタイミングで行う
		}
		
		public function remove(button:SpineSlotButton):void {
			var i:int = _buttons.length;
			while(i--) {
				if(_buttons[i] == button) {
					_buttons.splice(i, 1);
					break;
				}
			}
		}
		public function removeAll():void {
			_buttons.length = 0;
		}
	}

}
