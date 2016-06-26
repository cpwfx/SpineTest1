package demos {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import harayoki.spine.starling.MySkeletonAnimation;
	import harayoki.spine.starling.SpineHitTestUtil;
	import harayoki.spine.starling.SpineUtil;

	import spine.Skeleton;
	import spine.SkeletonData;
	import spine.Slot;
	import spine.animation.AnimationState;
	import spine.attachments.Attachment;
	import spine.attachments.BoundingBoxAttachment;
	import spine.attachments.FfdAttachment;
	import spine.attachments.MeshAttachment;
	import spine.attachments.RegionAttachment;
	import spine.attachments.WeightedMeshAttachment;

	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.filters.BlurFilter;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.AssetManager;

	public class FilterDemo1 extends DemoBase {

		private static var sPoint:Point = new Point();

		private var _skeletonAnimation:MySkeletonAnimation;
		private var _skeletonData:SkeletonData;
		private var _skeleton:Skeleton;
		private var _animationState:AnimationState;

		private var _assetNames:Array = ["manmaru"];
		private var _infos:Object = {
			"default" : {scale:1.0, pos:{x:420, y:260}}
		};
		private var _assetName:String;
		private var _textField1:TextField;
		private var _tid:uint;
		private var _hits:Array = [];

		public function FilterDemo1(assetManager:AssetManager, starling:Starling = null) {
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

			_skeletonAnimation = new MySkeletonAnimation(_skeletonData, new flash.geom.Rectangle(-160, -160, 320, 320));
			sp.addChild(_skeletonAnimation);
			sp.touchGroup = true;
			sp.touchable = true;

			_skeleton = _skeletonAnimation.skeleton;
			_animationState = _skeletonAnimation.state;
			trace("animations:", _skeletonData.animations);
			trace("slots:", _skeleton.slots);

			var tween:Tween = new Tween(null, 0.0);
			Starling.juggler.add(_skeletonAnimation);

			_animationState.timeScale = 1.0;
			_animationState.addAnimation(0, _skeletonData.findAnimation("guruguru"), true, 0);

			_skeletonAnimation.touchable = true;

			_skeletonAnimation.filter = new BlurFilter(4,1);

			_showInfo("Touch character!");

			bg.addEventListener(TouchEvent.TOUCH, function(ev:TouchEvent):void{
				var bgTouch:Touch = ev.getTouch(bg, TouchPhase.ENDED);
				var skeletonTouch:Touch = ev.getTouch(sp, TouchPhase.ENDED);
				trace(bgTouch, skeletonTouch);
				if(skeletonTouch) {
					_animationState.addAnimation(1, _skeletonData.findAnimation("bowan"), false, 0);
					_showInfo("Touched ");
				} else if(bgTouch) {
					//背景のタッチは移動
					_showInfo("Touched : outside");
					bgTouch.getLocation(self, sPoint);
					tween.reset(sp, 1.0, Transitions.EASE_OUT);
					tween.moveTo(sPoint.x, sPoint.y);
					Starling.juggler.add(tween);
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
