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
	import spine.animation.AnimationStateData;
	import spine.attachments.BoundingBoxAttachment;
	import spine.starling.SkeletonAnimation;
	
	import starling.core.Starling;
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
			///
			assets.push("assets/font/font.xml");
			assets.push("assets/font/font.png");
		}

		public override function start():void {
			
			var info:Object = _infos[_assetName] || _infos["default"];
			var pos:Object = info.pos || {x:0, y:0};
			
			stage.color = 0xbbbbbb;

			_skeletonData = SpineUtil.createSkeletonData(_assetManager, _assetName, info.scale);

			var stateData:AnimationStateData = new AnimationStateData(_skeletonData);
			// stateData.defaultMix = 1.0;
			_skeletonAnimation = new SkeletonAnimation(_skeletonData, stateData);
			addChild(_skeletonAnimation);
			_skeletonAnimation.x = pos.x;
			_skeletonAnimation.y = pos.y;
			_skeletonAnimation.touchable = false; // false推奨 処理が重そうなので

			_skeleton = _skeletonAnimation.skeleton;
			_animationState = _skeletonAnimation.state;
			_animationState.onStart.add(function(track:int):void{
				trace("state.onStart", arguments);
			});
			_animationState.onEnd.add(function(track:int):void{
				trace("state.onEnd", arguments);
			});
			_animationState.onComplete.add(function(track:int, count:int):void{
				trace("state.onComplete", arguments);
			});
			_animationState.onEvent.add(function(track:int, data:*):void{
				trace("state.onEvent", arguments);
			});
			
			//trace("animations:", _skeletonData.animations);
			//[trace] animations:
			// btn_big_3,home_lp,btn_mini_set_5,btn_big_2,btn_mini_set_4,list_in,contents_lp,home_out,contents_out,
			// btn_mini_set_2,list_out,btn_mini_set_3,btn_mini_set_1,contents_in,home_in,list_lp,btn_big_1
			//trace("slots:", _skeleton.slots);
			// Area_btn_big,Area_btn_mini_set_1,Area_btn_mini_set_2,Area_btn_mini_set_3,Area_btn_mini_set_4,
			// Area_btn_mini_set_5,Area_btn_big-copy,Area_btn_big-copy2
			
			_hitAreaSlots = new <Slot>[];
			for each(var slot:Slot in _skeleton.slots) {
				var atc:BoundingBoxAttachment = slot.attachment as BoundingBoxAttachment;
				if(atc) {
					_hitAreaSlots.push(slot);
				}
			}
			trace("hitAreaSlots:", _hitAreaSlots);
			//[trace] hitAreaSlots:
			
			var ui:UiControl = new UiControl(_skeletonAnimation);
			Starling.juggler.add(_skeletonAnimation);
			var p:Point = new Point();
			
			stage.addEventListener(TouchEvent.TOUCH, function(ev:TouchEvent):void{
				var touch:Touch;
				touch = ev.getTouch(stage, TouchPhase.ENDED);
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
				// _textField1.format = new TextFormat("font", 32);
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

import harayoki.spine.starling.SpineSlotButton;
import harayoki.spine.starling.SpineSlotButtonGroup;

import spine.animation.AnimationState;
import spine.animation.TrackEntry;
import spine.starling.SkeletonAnimation;

import starling.core.Starling;

class UiControl {
	private var _state:UiState
	private var _prevState:UiState
	private var _skeletonAnimation:SkeletonAnimation;
	private var _btnGroup:SpineSlotButtonGroup;
	public var _mainTrackIndex:int = 0;
	public var _btnTrackIndex:int = 1;
	
	public function UiControl(skeletonAnimation:SkeletonAnimation) {
		_skeletonAnimation = skeletonAnimation;
		
		_btnGroup = new SpineSlotButtonGroup();
		
		// ,Area_btn_mini_set_2,Area_btn_mini_set_3,Area_btn_mini_set_4,
		// Area_btn_mini_set_5
		
		var btn:SpineSlotButton;
		
		btn = new SpineSlotButton(_skeletonAnimation, 'Area_btn_big', _btnGroup);
		btn.setTouchStartAnimation('btn_big_1', _btnTrackIndex);
		btn.onTouchEnd.add(function(btn:SpineSlotButton):void{
			if(isState(UiState.HOME)) {
				changeState(UiState.CONTENTS);
			} else {
				changeState(UiState.HOME);
			}
		});
		
		btn = new SpineSlotButton(_skeletonAnimation, 'Area_btn_big-copy', _btnGroup);
		btn.setTouchStartAnimation('btn_big_2', _btnTrackIndex);
		btn.onTouchEnd.add(function(btn:SpineSlotButton):void{
			changeState(UiState.LIST);
		});
		
		btn = new SpineSlotButton(_skeletonAnimation, 'Area_btn_big-copy2', _btnGroup);
		btn.setTouchStartAnimation('btn_big_3', _btnTrackIndex);
		btn.onTouchEnd.add(function(btn:SpineSlotButton):void{
		});
		
		btn = new SpineSlotButton(_skeletonAnimation, 'Area_btn_mini_set_1', _btnGroup);
		btn.setTouchStartAnimation('btn_mini_set_1', _btnTrackIndex);
		btn.onTouchEnd.add(function(btn:SpineSlotButton):void{
		});
		btn = new SpineSlotButton(_skeletonAnimation, 'Area_btn_mini_set_2', _btnGroup);
		btn.setTouchStartAnimation('btn_mini_set_2', _btnTrackIndex);
		btn.onTouchEnd.add(function(btn:SpineSlotButton):void{
		});
		btn = new SpineSlotButton(_skeletonAnimation, 'Area_btn_mini_set_3', _btnGroup);
		btn.setTouchStartAnimation('btn_mini_set_3', _btnTrackIndex);
		btn.onTouchEnd.add(function(btn:SpineSlotButton):void{
		});
		btn = new SpineSlotButton(_skeletonAnimation, 'Area_btn_mini_set_4', _btnGroup);
		btn.setTouchStartAnimation('btn_mini_set_4', _btnTrackIndex);
		btn.onTouchEnd.add(function(btn:SpineSlotButton):void{
		});
		btn = new SpineSlotButton(_skeletonAnimation, 'Area_btn_mini_set_5', _btnGroup);
		btn.setTouchStartAnimation('btn_mini_set_5', _btnTrackIndex);
		btn.onTouchEnd.add(function(btn:SpineSlotButton):void{
		});
		
		changeState(UiState.HOME);
		
		
	}
	
	public function isState(state:UiState):Boolean {
		return _state == state;
	}
	
	public function changeState(state:UiState):void {
		var animState:AnimationState = _skeletonAnimation.state;
		animState.timeScale = 1.75;
		if (_state == state) {
			return;
		}
		_prevState = _state;
		_state = state;
		if (_prevState) {
			_btnGroup.enabled = false;
			_changeState();
		} else {
			_playNextStateAnimation();
		}
	}
	
	private function _changeState():void {
		trace("_changeState", _prevState , _state);
		var animState:AnimationState = _skeletonAnimation.state;
		var track0:TrackEntry = animState.setAnimationByName(_mainTrackIndex, _prevState.outAnimaton, false);
		track0.onStart = function(slot:int):void {
			trace('track0.onStart', arguments);
		};
		track0.onComplete = function(slot:int, count:int):void {
			trace('track0.onComplete', arguments);
			// onEndコールバック内ですぐ次のアニメ再生処理をするとおかしくなるのでonCompleteで見ている
			track0.onStart = track0.onComplete = track0.onEnd = null;
			_playNextStateAnimation();
		};
		track0.onEnd = function(slot):void {
			trace('track0.onEnd', arguments);
		}
	}
	
	private function _playNextStateAnimation():void {
		trace("_playNextStateAnimation", _state);
		if(_state) {
			_btnGroup.enabled = false;
			var animState:AnimationState = _skeletonAnimation.state;
			var track1:TrackEntry, track2:TrackEntry;
			track1 = animState.setAnimationByName(_mainTrackIndex, _state.inAnimaton, false);
			track1.onStart = function(slot:int):void {
				trace('track1.onStart', arguments);
			};
			track1.onComplete = function(slot:int):void {
				trace('track1.onComplete', arguments);
			};
			track1.onEnd = function(slot:int):void {
				trace('track1.onEnd', arguments);
				track1.onStart = track1.onComplete = track1.onEnd = null;
				// 念のため1フレーム待つ
				Starling.juggler.delayCall(_setUpNextAnimation, 0);
				_skeletonAnimation.skeleton.setSlotsToSetupPose(); // １フレあとで呼ぶと見えてはいけないパーツがちらっと見える
			};
			track2 = animState.addAnimationByName(_mainTrackIndex, _state.loopAnimaton, true, 0);
			track2.onStart = function(slot:int):void {
				trace('track2.onStart', arguments);
			};
			track2.onComplete = function(slot:int, count:int):void {
				trace('track2.onComplete', arguments);
			};
			track2.onEnd = function(slot:int):void {
				trace('track2.onEnd', arguments);
			};
		} else {
			_btnGroup.enabled = true;
		}
	}
	
	private function _setUpNextAnimation():void {
		// setSlotsToSetupPoseを行わないとあたり判定がとれなかった
		_btnGroup.enabled = true;
	}
	
}

/* アニメーションコールバックメモ
 AnimationState onEndはイベントリスナー型、コールバックへの引数にスロット番号が渡される
全部のアニメーションのイベントが来るので、トラック別に処理を分けないといけない
 TrackEntry onEnd はfunction型、同様にコールバックへの引数にスロット番号が渡される
 
対象スロットだけコールバックが来るので、こちらの方が便利
 setAnimationByName、addAnimationByNameの戻り値はTrackEntry
 AnimationState.getCurrent(trakNum)でもTrackEntryがとれる
 
 どちらのイベントでもイベントハンドラ内で次のアニメーション処理を行うとおかしくなるので、１フレーム待ってから処理をした方が良い

ループアニメーションの終了コールバックはAnimationState.onEndに１度目の再生が終了した際につくが
 
 
 
 */


class UiState {
	
	public static const HOME:UiState = new UiState("home");
	public static const CONTENTS:UiState = new UiState("contents");
	public static const LIST:UiState = new UiState("list");
	
	public var id:String;
	public function UiState(id:String) {
		this.id = id;
	}
	
	public function toString():String {
		return "[State:" + id + "]";
	}
	
	public function get inAnimaton():String {
		return id + "_in";
	}
	
	public function get loopAnimaton():String {
		return id + "_lp";
	}
	
	public function get outAnimaton():String {
		return id + "_out";
	}
}
