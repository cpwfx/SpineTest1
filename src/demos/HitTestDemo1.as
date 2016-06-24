package demos {
	import flash.geom.Point;

	import harayoki.spine.starling.SpineHitTestUtil;
	import harayoki.spine.starling.SpineUtil;

	import spine.Skeleton;
	import spine.SkeletonData;
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

			_skeleton = _skeletonAnimation.skeleton;
			_animationState = _skeletonAnimation.state;
			trace("animations:", _skeletonData.animations);
			trace("slots:",_skeletonData.slots);

			var tween:Tween = new Tween(sp, 0.5);
			Starling.juggler.add(_skeletonAnimation);

			_animationState.addAnimation(0, _skeletonData.findAnimation("guruguru"), true, 0);
			_animationState.timeScale = 0.5;

			_skeletonAnimation.touchable = false;

			var bb:BoundingBoxAttachment = _skeleton.findSlot("hitArea1").attachment as BoundingBoxAttachment;
			for (var i:int=0;i<bb.vertices.length;i+=2) {
				var quad:Quad = new Quad(4, 4, 0xffff0000);
				quad.pivotX = 2;
				quad.pivotY = 2;
				quad.x = bb.vertices[i];
				quad.y = bb.vertices[i+1];
				quad.rotation = Math.PI / 8;
				sp.addChild(quad);
			}

			bg.addEventListener(TouchEvent.TOUCH, function(ev:TouchEvent):void{
				var touch:Touch = ev.getTouch(self, TouchPhase.ENDED);
				if(touch) {
					var hit:Boolean =  _hitTest(touch.globalX, touch.globalY, ["hitArea1"]); // "armR", "armL"
					if(hit) {
						_animationState.addAnimation(1, _skeletonData.findAnimation("bowan"), false, 0);
					}else {
						touch.getLocation(self, sPoint);
						tween.reset(sp, 0.5, Transitions.EASE_OUT);
						tween.moveTo(sPoint.x, sPoint.y);
						Starling.juggler.add(tween);
					}
				}
			});

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
