package demos {
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import harayoki.spine.starling.SpineHitTestUtil;
	import harayoki.spine.starling.SpineSlotButton;
	import harayoki.spine.starling.SpineUtil;
	
	import spine.Skeleton;
	import spine.SkeletonData;
	import spine.Slot;
	import spine.animation.AnimationState;
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

		private var _assetNames:Array = ["ui1"];
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

			var info:Object = _infos[_assetName] || _infos["default"];
			var pos:Object = info.pos || {x:0, y:0};

			
			stage.color = 0xbbbbbb;

			_skeletonData = SpineUtil.createSkeletonData(_assetManager, _assetName, info.scale);

			_skeletonAnimation = new SkeletonAnimation(_skeletonData);
			addChild(_skeletonAnimation);
			_skeletonAnimation.x = pos.x;
			_skeletonAnimation.y = pos.y;
			_skeletonAnimation.touchable = false; // false推奨 処理が重そうなので

			_skeleton = _skeletonAnimation.skeleton;
			_animationState = _skeletonAnimation.state;
			//trace("animations:", _skeletonData.animations);
			//[trace] animations:
			// btn_big_3,home_lp,btn_mini_set_5,btn_big_2,btn_mini_set_4,list_in,contents_lp,home_out,contents_out,
			// btn_mini_set_2,list_out,btn_mini_set_3,btn_mini_set_1,contents_in,home_in,list_lp,btn_big_1
			//trace("slots:", _skeleton.slots);
			
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

			_showInfo("UI test");

			var btn:SpineSlotButton;
			btn = new SpineSlotButton(_skeletonAnimation, 'Area_btn_big');
			btn.setTouchStartAnimation('btn_big_1', 1);
			btn.onTouchEnd.add(function(btn:SpineSlotButton):void{
				trace(btn);
			});
			
			btn = new SpineSlotButton(_skeletonAnimation, 'Area_btn_big-copy');
			btn.setTouchStartAnimation('btn_big_2', 1);
			btn.onTouchEnd.add(function(btn:SpineSlotButton):void{
				trace(btn);
			});
			
			btn = new SpineSlotButton(_skeletonAnimation, 'Area_btn_big-copy2');
			btn.setTouchStartAnimation('btn_big_3', 1);
			btn.onTouchEnd.add(function(btn:SpineSlotButton):void{
				trace(btn);
			});
			
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
