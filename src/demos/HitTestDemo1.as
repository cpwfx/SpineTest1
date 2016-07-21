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
	import spine.attachments.Attachment;
	import spine.attachments.BoundingBoxAttachment;
	import spine.attachments.MeshAttachment;
	import spine.attachments.PathAttachment;
	import spine.attachments.RegionAttachment;
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
			"default" : {scale:1.0, pos:{x:420, y:260}}
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

			_skeletonAnimation = new SkeletonAnimation(_skeletonData);
			sp.addChild(_skeletonAnimation);
			sp.touchGroup = true;
			sp.touchable = false;

			_skeleton = _skeletonAnimation.skeleton;
			_animationState = _skeletonAnimation.state;
			trace("animations:", _skeletonData.animations);
			for each(var slot:Slot in _skeleton.slots) {
				var attachment:Attachment = slot.attachment;
				if(attachment) {
					var type:String = "Unknown Attachment";
					if(attachment is MeshAttachment) {
						type = "MeshAttachment";
					}
					else if(attachment is RegionAttachment) {
						type = "RegionAttachment";
					}
					else if(attachment is BoundingBoxAttachment) {
						type = "BoundingBoxAttachment";
					}
					else if(attachment is PathAttachment) {
						type = "PathAttachment";
					}
					trace("slot:"+slot, "("+type+"):"+attachment);
				}
			}

			var tween:Tween = new Tween(null, 0.0);
			Starling.juggler.add(_skeletonAnimation);

			_animationState.timeScale = 1.0;
			_animationState.addAnimation(0, _skeletonData.findAnimation("guruguru"), true, 0);
			_animationState.getCurrent(0).timeScale = 0.25;

			_skeletonAnimation.touchable = false;

			_showInfo("Touch character!");

			bg.addEventListener(TouchEvent.TOUCH, function(ev:TouchEvent):void{

				var touch:Touch = ev.getTouch(self, TouchPhase.ENDED);

				if(touch) {

					_hits.length = 0;

					var gx:Number = touch.globalX;
					var gy:Number = touch.globalY;

					if(_hitTest(gx, gy, ["hitAreaEyes"])) {
						_hits.push("Eyes(Bounding:square)");
					} else if(_hitTest(gx, gy, ["tie"])) {
						_hits.push("Tie(Region)");
						_animationState.addAnimation(2, _skeletonData.findAnimation("tie"), false, 0);
					} else if(_hitTest(gx, gy, ["ribon"])) {
						_hits.push("Ribon(Mesh)");
						_animationState.addAnimation(2, _skeletonData.findAnimation("tie"), false, 0);
					} else if(_hitTest(gx, gy, ["armR", "armL"])) {
						_hits.push("Arm(Region)");
					}

					if(_hitTest(gx, gy, ["hitAreaBody"])) {
						_hits.push("Body(Bounding:hexagon)");
						_animationState.addAnimation(1, _skeletonData.findAnimation("bowan"), false, 0);
					}

					if(_hits.length>0) {
						_showInfo("Touched : " + _hits.join(" and ") + "");
					} else {
						_showInfo("Touched : outside");
						//背景のタッチは移動
						touch.getLocation(self, sPoint);
						tween.reset(sp, 1.0, Transitions.EASE_OUT);
						tween.moveTo(sPoint.x, sPoint.y);
						Starling.juggler.add(tween);
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
