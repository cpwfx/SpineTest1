package demos {
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import harayoki.spine.starling.SpineHitTestUtil;
	import harayoki.spine.starling.SpineUtil;
	
	import spine.Skeleton;
	import spine.SkeletonData;
	import spine.Slot;
	import spine.animation.AnimationState;
	import spine.attachments.BoundingBoxAttachment;
	import spine.starling.SkeletonAnimation;
	
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.AssetManager;
	
	public class UI1Demo1 extends DemoBase {

		private static var sPoint:Point = new Point();

		private var _skeletonAnimation:SkeletonAnimation;
		private var _skeletonData:SkeletonData;
		private var _skeleton:Skeleton;
		private var _animationState:AnimationState;
		//private var _animations:Vector.<Slot>;
		private var _hitAreaSlots:Vector.<Slot>;

		private var _assetNames:Array = ["_temp_/ui1"];
		private var _infos:Object = {
			"default" : {scale:0.5, pos:{x:480, y:280}}
		};
		private var _assetName:String;
		private var _assetFolder:String;
		private var _textField1:TextField;
		private var _tid:uint;
		private var _hits:Array = [];

		public function UI1Demo1(assetManager:AssetManager, starling:Starling = null) {
			super(assetManager, starling);
			_assetName = _lot(_assetNames) + "";
			var arr:Array = _assetName.split("/");
			_assetName = arr.pop();
			_assetFolder = arr.join("/");
			_assetFolder = _assetFolder ? _assetFolder + "/" : "";
		}

		public override function addAssets(assets:Array):void {
			assets.push("assets/" + _assetFolder + _assetName + ".png");
			assets.push("assets/" + _assetFolder + _assetName + ".atlas");
			assets.push("assets/" + _assetFolder + _assetName + ".json");
		}

		public override function start():void {

			var self:DemoBase = this;
			var info:Object = _infos[_assetName] || _infos["default"];
			var pos:Object = info.pos || {x:0, y:0};

			var bg:Quad = new Quad(800, 600, 0x000000);
			bg.touchable = true;
			bg.alpha = 0;
			addChild(bg);
			
			stage.color = 0xbbbbbb;

			var sp:Sprite = new Sprite();
			sp.x = pos.x;
			sp.y = pos.y;
			//sp.rotationX = 0.3;
			//sp.rotationY = 0.3;
			stage.fieldOfView = Math.PI*0.6;
			addChild(sp);

			_skeletonData = SpineUtil.createSkeletonData(_assetManager, _assetName, info.scale);

			_skeletonAnimation = new SkeletonAnimation(_skeletonData);
			sp.addChild(_skeletonAnimation);
			sp.touchGroup = true;
			sp.touchable = false;

			_skeleton = _skeletonAnimation.skeleton;
			_animationState = _skeletonAnimation.state;
			//trace("animations:", _skeletonData.animations);
			//[trace] animations:
			// btn_big_3,home_lp,btn_mini_set_5,btn_big_2,btn_mini_set_4,list_in,contents_lp,home_out,contents_out,
			// btn_mini_set_2,list_out,btn_mini_set_3,btn_mini_set_1,contents_in,home_in,list_lp,btn_big_1
			//trace("slots:", _skeleton.slots);
			//[trace] slots:
			// bg,haguruma_shadow,haguruma_shadow-copy2,haguruma_shadow-copy,haguruma,haguruma-copy2,haguruma-copy,
			// line-copy2,line,line-copy,btn_mini_set_1,btn_mini_set_2,btn_mini_set_3,btn_mini_set_4,btn_mini_set_5,
			// haguruma_shadow2,haguruma_shadow2-copy2,haguruma_shadow2-copy,haguruma2,haguruma2-copy2,haguruma2-copy,
			// haguruma_shadow3,haguruma_shadow3-copy2,haguruma_shadow3-copy,haguruma3,haguruma3-copy2,haguruma3-copy,
			// btn_big,btn_big-copy2,btn_big-copy,Area_btn_big,Area_btn_mini_set_1,Area_btn_mini_set_2,
			// Area_btn_mini_set_3,Area_btn_mini_set_4,Area_btn_mini_set_5,Area_btn_big-copy,Area_btn_big-copy2
			
			_hitAreaSlots = new <Slot>[];
			for each(var slot:Slot in _skeleton.slots) {
				var atc:BoundingBoxAttachment = slot.attachment as BoundingBoxAttachment;
				if(atc) {
					_hitAreaSlots.push(slot);
				}
			}
			trace("hitAreaSlots:", _hitAreaSlots);
			//[trace] hitAreaSlots:
			// Area_btn_big,Area_btn_mini_set_1,Area_btn_mini_set_2,Area_btn_mini_set_3,Area_btn_mini_set_4,
			// Area_btn_mini_set_5,Area_btn_big-copy,Area_btn_big-copy2
			
			_animationState.timeScale = 1.0;
			_animationState.addAnimationByName(0, "home_in", false, 0);
			_animationState.addAnimationByName(0, "home_lp", true, 0);
			Starling.juggler.add(_skeletonAnimation);

			_skeletonAnimation.touchable = false;

			_showInfo("UI test");

			var btn:SpineSlotButton;
			btn = new SpineSlotButton(_skeletonAnimation, 'Area_btn_big');
			btn.setTouchedAnimation('btn_big_1', 1);
			btn.onTouch.add(function(btn:SpineSlotButton):void{
				trace(btn);
			});
			
			btn = new SpineSlotButton(_skeletonAnimation, 'Area_btn_big-copy');
			btn.setTouchedAnimation('btn_big_2', 1);
			btn.onTouch.add(function(btn:SpineSlotButton):void{
				trace(btn);
			});
			
			btn = new SpineSlotButton(_skeletonAnimation, 'Area_btn_big-copy2');
			btn.setTouchedAnimation('btn_big_3', 1);
			btn.onTouch.add(function(btn:SpineSlotButton):void{
				trace(btn);
			});
			
			var touchCount:int = 0;
			var p:Point = new Point();
			bg.addEventListener(TouchEvent.TOUCH, function(ev:TouchEvent):void{
				var touch:Touch;
				touch = ev.getTouch(bg, TouchPhase.ENDED);
				
				if(touch) {
					
					p.setTo(touch.globalX, touch.globalY);
					
					for each(var slot:Slot in _hitAreaSlots) {
						if(SpineHitTestUtil.hitTestWithAttachmentByGlobalPoint(_skeletonAnimation, slot.data.name, p)) {
							_showInfo("Touched " + slot.data.name);
						}
					}
				}
				
			});

		}

		private function _showInfo(info:String):void {

			if(!_textField1) {
				_textField1 = new TextField(800, 30, "");
				_textField1.x = 20;
				_textField1.y = 550;
				_textField1.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				addChild(_textField1);
			}

			_textField1.text = info;
			_textField1.visible = true;
			clearTimeout(_tid);
			_tid = setTimeout(function():void{
				_textField1.visible = false;
			},4000);
		}

	}
}

import flash.geom.Point;

import harayoki.spine.starling.SpineHitTestUtil;

import spine.Slot;
import spine.animation.Listeners;
import spine.starling.SkeletonAnimation;

import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

class SpineSlotButtonGroup {
	
	private static var P:Point = new Point();
	private static const TOUCHES:Vector.<Touch> = new <Touch>[];
	
	public var _enabled:Boolean = true;
	public var allowMultiHit:Boolean = true;
	private var _touchEventSource:DisplayObject;
	
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
		
		TOUCHES.length = 0;
		ev.getTouches(_touchEventSource, TouchPhase.ENDED, TOUCHES);
		
		if(TOUCHES.length == 0) {
			return;
		}
		
		if(!allowMultiHit) {
			//同時に複数のボタンに反応させない時は複数のタッチを捨てる
			TOUCHES.length = 1;
			//同時に複数のボタンに反応させない時は現在のアニメの重なり順でソートさせて上から判定する
			_buttons.sort(_btnSortFunc);
		}
		
		for each(var touch:Touch in TOUCHES) {
			P.setTo(touch.globalX, touch.globalY);
			for each(var btn:SpineSlotButton in _buttons) {
				var hit:Boolean = btn.hitTest(P);
				if(hit) {
					btn.invokeTouched();
					if(!allowMultiHit) {
						return;
					}
				}
			}
		}
	}
	
	private function _btnSortFunc(a:SpineSlotButton, b:SpineSlotButton):int {
		return b.getDepth() - a.getDepth();
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

class SpineSlotButton {
	
	private static var DEFAULT_GROUP:SpineSlotButtonGroup;
	
	private var _skeletonAnimation:SkeletonAnimation;
	
	private var _onTouch:Listeners;
	public function get onTouch():Listeners {
		return _onTouch;
	}
	
	private var _enabled:Boolean = true;
	private var _touchedAnimation:ButtonAnimationData;
	private var _loopAnimation:ButtonAnimationData;
	
	public var hitTestSlot:Slot;
	public var userOption:*;
	
	public function SpineSlotButton(skeletonAnimation:SkeletonAnimation, hitTestSlotName:String) {
		_skeletonAnimation = skeletonAnimation;
		hitTestSlot = _skeletonAnimation.skeleton.findSlot(hitTestSlotName);
		_onTouch = new Listeners();
		if(!DEFAULT_GROUP) {
			DEFAULT_GROUP = new SpineSlotButtonGroup();
		}
		DEFAULT_GROUP.add(this);
	}
	
	public function dispose():void {
		hitTestSlot = null;
		userOption = null;
		_onTouch = null;
		DEFAULT_GROUP.remove(this);
	}
	
	public function toString():String {
		return "[SpineSlotButton:" + (hitTestSlot ? "#"+hitTestSlot.data.index + " " + hitTestSlot.data.name : 'N/A') + "]";
	}
	
	public function setTouchedAnimation(name:String, slot:int=0):void {
		_touchedAnimation = new ButtonAnimationData(name, slot, false);
	}
	
	public function setNormalLoopAnimation(name:String, slot:int=0):void {
		if(_loopAnimation) {
			// 止める？
		}
		_loopAnimation = new ButtonAnimationData(name, slot, true);
		_playLoopAnimation();
	}
	
	public function _playLoopAnimation():void {
		if(_loopAnimation) {
			_loopAnimation.applyToSkeleton(_skeletonAnimation);
		}
	}
	
	public function invokeTouched():void {
		if(_touchedAnimation) {
			_touchedAnimation.applyToSkeleton(_skeletonAnimation, _playLoopAnimation);
		}
		_onTouch.invoke(this);
	}
	
	public function hitTest(globalPos:Point):Boolean {
		if(!_enabled || !hitTestSlot || !_skeletonAnimation.visible || _skeletonAnimation.alpha <=0) return false;
		var hit:Boolean = SpineHitTestUtil.hitTestWithAttachmentByGlobalPoint(_skeletonAnimation, hitTestSlot.data.name, globalPos);
		if(hit) {
			trace("hit!", hitTestSlot.data.name, hitTestSlot.data.index);
		}
		return hit;
	}
	
	public function getDepth():int {
		return hitTestSlot ? hitTestSlot.data.index : -1;
	}
	
	public function setEnabled(enabled:Boolean):void {
		_enabled = enabled;
	}
}

class ButtonAnimationData {
	public var loop:Boolean;
	public var name:String;
	public var slot:int;
	
	public function ButtonAnimationData(name:String, slot:int, loop:Boolean) {
		this.name = name;
		this.slot = slot;
		this.loop = loop;
	}
	
	public function applyToSkeleton(skeletonAnimation:SkeletonAnimation, callback:Function=null):void {
		if(!skeletonAnimation) return;
		skeletonAnimation.state.setAnimationByName(slot, name, loop);
		if(callback != null) {
			skeletonAnimation.state.getCurrent(slot).onEnd = function(slot:int):void{
				callback && callback();
			};
		} else {
			skeletonAnimation.state.getCurrent(slot).onEnd = null;
		}
		
	}
}