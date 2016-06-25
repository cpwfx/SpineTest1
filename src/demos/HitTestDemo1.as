package demos {
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import harayoki.spine.starling.SpineHitTestUtil;
	import harayoki.spine.starling.SpineUtil;

	import spine.Skeleton;
	import spine.SkeletonData;
	import spine.animation.Animation;
	import spine.animation.AnimationState;
	import spine.attachments.BoundingBoxAttachment;
	import spine.starling.SkeletonAnimation;

	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.AssetManager;

	public class HitTestDemo1 extends DemoBase {

		private static var sPoint:Point = new Point();

		private var _skeletonAnimation:SkeletonAnimation;
		private var _skeletonData:SkeletonData;
		private var _skeleton:Skeleton;
		private var _animationState:AnimationState;

		private var _assetNames:Array = ["manmaru"];
		private var _infos:Object = {
			"default" : {scale:1.0, pos:{x:420, y:250}}
		};
		private var _assetName:String;
		private var _textField1:TextField;
		private var _tid:uint;
		private var _hits:Array = [];

		public function HitTestDemo1(assetManager:AssetManager, starling:Starling = null) {
			super(assetManager, starling);
			_assetName = _lot(_assetNames) + "";
		}

		public override function addAssets(assets:Array):void {
			assets.push("assets/" + _assetName + ".png");
			assets.push("assets/" + _assetName + ".atlas");
			assets.push("assets/" + _assetName + ".json");
		}

		public override function start():void {

			var self:DemoBase = this;
			var info:Object = _infos[_assetName] || _infos["default"];
			var pos:Object = info.pos || {x:0, y:0};

			var bg:Quad = new Quad(800, 600, 0xeeeeee);
			bg.setVertexColor(0, 0xffffff);
			bg.touchable = true;
			addChild(bg);

			var sp:Sprite = new Sprite();
			sp.x = pos.x;
			sp.y = pos.y;
			addChild(sp);

			_skeletonData = SpineUtil.createSkeletonData(_assetManager, _assetName, info.scale);

			_skeletonAnimation = new SkeletonAnimation(_skeletonData, true);
			sp.addChild(_skeletonAnimation);
			sp.touchGroup = true;
			sp.touchable = false;

			_skeleton = _skeletonAnimation.skeleton;
			_animationState = _skeletonAnimation.state;
			trace("animations:", _skeletonData.animations);
			trace("slots:",_skeletonData.slots);

			var tween:Tween = new Tween(null, 0.0);
			Starling.juggler.add(_skeletonAnimation);

			_animationState.addAnimation(0, _skeletonData.findAnimation("guruguru"), true, 0);
			_animationState.timeScale = 0.5;

			_skeletonAnimation.touchable = false;

			_showInfo("Touch character!");

			bg.addEventListener(TouchEvent.TOUCH, function(ev:TouchEvent):void{

				var touch:Touch = ev.getTouch(self, TouchPhase.ENDED);

				if(touch) {

					_hits.length = 0;

					var gx:Number = touch.globalX;
					var gy:Number = touch.globalY;

					if(_hitTest(gx, gy, ["hitAreaEyes"])) {
						_hits.push("eyes");
					} else if(_hitTest(gx, gy, ["tie"])) {
						_hits.push("tie");
						_animationState.addAnimation(2, _skeletonData.findAnimation("tie"), false, 0);
					} else if(_hitTest(gx, gy, ["ribon"])) {
						_hits.push("ribon");
						_animationState.addAnimation(2, _skeletonData.findAnimation("tie"), false, 0);
					} else if(_hitTest(gx, gy, ["armR", "armL"])) {
						_hits.push("arms");
					}

					if(_hitTest(gx, gy, ["hitAreaBody"])) {
						_hits.push("body");
						_animationState.addAnimation(1, _skeletonData.findAnimation("bowan"), false, 0);
					}

					//背景のタッチは移動
					if(_hits.length==0) {
						touch.getLocation(self, sPoint);
						tween.reset(sp, 1.0, Transitions.EASE_OUT);
						tween.moveTo(sPoint.x, sPoint.y);
						Starling.juggler.add(tween);
					} else {
						_showInfo("Touched : " + _hits.join(" and ") + " !");
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
			clearTimeout(_tid);
			_tid = setTimeout(function():void{
				_textField1.text = "";
			},4000);
		}

		private function _hitTest(globalX:Number, globalY:Number, slotNames:Array):Boolean {
			sPoint.setTo(globalX, globalY);
			for each(var slotName:String in slotNames) {
				if(SpineHitTestUtil.hitTestWithAttachmentByGlobalPoint(_skeletonAnimation, slotName, sPoint)) {
					return true;
				}
			}
			return false;
		}

	}
}
