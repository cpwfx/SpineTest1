package harayoki.spine.starling {
	import flash.geom.Point;
	
	import harayoki.spine.starling.SpineSlotButtonGroup;
	
	import spine.Slot;
	import spine.animation.Listeners;
	import spine.starling.SkeletonAnimation;
	
	import starling.events.TouchPhase;
	
	public class SpineSlotButton {
		
		private static var DEFAULT_GROUP:SpineSlotButtonGroup;
		
		private var _skeletonAnimation:SkeletonAnimation;
		
		private var _onTouchStart:Listeners;
		public function get onTouchStart():Listeners {
			return _onTouchStart;
		}
		
		private var _onTouchEnd:Listeners;
		public function get onTouchEnd():Listeners {
			return _onTouchEnd;
		}
		
		private var _enabled:Boolean = true;
		private var _touching:Boolean = false;
		private var _idolAnimation:ButtonAnimationData;
		private var _touchStartAnimation:ButtonAnimationData;
		private var _touchEndAnimation:ButtonAnimationData;
		private var _group:SpineSlotButtonGroup;
		
		public var hitTestSlot:Slot;
		public var userOption:*;
		
		/**
		 * @param skeletonAnimation ボタンを含むSkeletonAnimation参照
		 * @param hitTestSlotName あたり判定を行うSlot名 SlotはRegionAttachment(Image)かBoundingBoxAttachment(自由な多角形形状)
		 * @param touchEndAnimationName タッチエンド時に再生するアニメーション名
		 */
		public function SpineSlotButton(
			skeletonAnimation:SkeletonAnimation,
			hitTestSlotName:String,
			group:SpineSlotButtonGroup=null,
			touchEndAnimationName:String=null
		) {
			_skeletonAnimation = skeletonAnimation;
			hitTestSlot = _skeletonAnimation.skeleton.findSlot(hitTestSlotName);
			_onTouchStart = new Listeners();
			_onTouchEnd = new Listeners();
			if(group) {
				_group = group;
			} else {
				if(!DEFAULT_GROUP) {
					DEFAULT_GROUP = new SpineSlotButtonGroup();
				}
				_group = DEFAULT_GROUP;
			}
			_group.add(this);
		}
		
		public function dispose():void {
			hitTestSlot = null;
			userOption = null;
			_onTouchEnd = null;
			_idolAnimation = null;
			_touchStartAnimation = null;
			_touchEndAnimation = null;
			_group.remove(this);
			_group = null;
		}
		
		public function toString():String {
			return "[SpineSlotButton:" + (hitTestSlot ? "#"+hitTestSlot.data.index + " " + hitTestSlot.data.name : 'N/A') + "]";
		}
		
		public function get group():SpineSlotButtonGroup {
			return _group;
		}
		
		public function get touching():Boolean{
			return _touching;
		}
		
		public function setIdleAnimation(name:String, slot:int=0, loop:Boolean=false):void {
			if(name) {
				_idolAnimation = new ButtonAnimationData(name, slot, loop);
				_playIdleAnimation();
			} else {
				_idolAnimation = null;
			}
		}
		
		public function setTouchStartAnimation(name:String, slot:int=0):void {
			if(name) {
				_touchStartAnimation = new ButtonAnimationData(name, slot, false);
			} else {
				_touchStartAnimation = null;
			}
		}
		
		public function setTouchEndAnimation(name:String, slot:int=0):void {
			if(name) {
				_touchEndAnimation = new ButtonAnimationData(name, slot, false);
			} else {
				_touchEndAnimation = null;
			}
		}
		
		public function _playIdleAnimation():void {
			if(_idolAnimation) {
				_idolAnimation.applyToSkeleton(_skeletonAnimation);
			}
		}
		
		public function invokeTouchStart():void {
			if(_touchStartAnimation) {
				_touchStartAnimation.applyToSkeleton(_skeletonAnimation);
			}
			_onTouchStart.invoke(this);
		}
		
		public function invokeTouchEnd():void {
			if(_touchEndAnimation) {
				_touchEndAnimation.applyToSkeleton(_skeletonAnimation, _playIdleAnimation);
			}
			_onTouchEnd.invoke(this);
		}
		
		public function hitTest(globalPos:Point, phase:String):Boolean {
			if(!_enabled || !hitTestSlot || !_skeletonAnimation.visible) {
				if(_touching) {
					_touching = false;
					_playIdleAnimation();
				}
				return false;
			}
			if(phase == TouchPhase.MOVED || phase == TouchPhase.STATIONARY) {
				// MOVEDは重そうなのでとりあえず回避(今後設定によって許すかもしれない)
				// STATIONARYはマルチタッチ時でMOVEDしなかった指を示す
				return false;
			}
			if(phase == TouchPhase.HOVER) {
				// TODO HOVERはDesktop用で対応予定
				return false;
			}
			if(phase == TouchPhase.BEGAN && _touching) {
				// マルチタッチ対応
				return false;
			}
			if(phase == TouchPhase.ENDED && !_touching) {
				// マルチタッチ対応
				return false;
			}
			var hit:Boolean = SpineHitTestUtil.hitTestWithAttachmentByGlobalPoint(_skeletonAnimation, hitTestSlot.data.name, globalPos);
			if(hit) {
				trace("hit!", hitTestSlot.data.name, hitTestSlot.data.index);
				if(phase == TouchPhase.BEGAN) {
					_touching = true;
				} else if(phase == TouchPhase.ENDED) {
					_touching = false;
				}
			}
			return hit;
		}
		
		public function getSlotDepth():int {
			return hitTestSlot ? hitTestSlot.data.index : -1;
		}
		
		public function setEnabled(enabled:Boolean):void {
			_enabled = enabled;
		}
	}
	
}

import spine.starling.SkeletonAnimation;

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