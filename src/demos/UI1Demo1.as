package demos {
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import harayoki.spine.starling.SkeletonAnimationFilterApplicable;
	import harayoki.spine.starling.SpineHitTestUtil;
	import harayoki.spine.starling.SpineUtil;
	import harayoki.starling2.filters.PosterizationFilter;
	import harayoki.starling2.filters.ScanLineFilter;
	import harayoki.starling2.filters.SlashShadedFilter;
	
	import spine.Skeleton;
	import spine.SkeletonData;
	import spine.animation.AnimationState;
	import spine.starling.SkeletonAnimation;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.display.Sprite3D;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.filters.DropShadowFilter;
	import starling.filters.FilterChain;
	import starling.filters.FragmentFilter;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.AssetManager;
	
	public class UI1Demo1 extends DemoBase {

		private static var sPoint:Point = new Point();

		private var _skeletonAnimation:SkeletonAnimation;
		private var _skeletonData:SkeletonData;
		private var _skeleton:Skeleton;
		private var _animationState:AnimationState;

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

			var bg:Quad = new Quad(800, 600, 0xbbbbbb);
			bg.touchable = true;
			addChild(bg);

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
			trace("animations:", _skeletonData.animations);
			trace("slots:", _skeleton.slots);
			
			_animationState.timeScale = 1.0;
			//_animationState.addAnimationByName(0, "guruguru", true, 0);

			_skeletonAnimation.touchable = true;

			_showInfo("UI test");

			var touchCount:int = 0;
			var p:Point = new Point();
			bg.addEventListener(TouchEvent.TOUCH, function(ev:TouchEvent):void{
				var touch:Touch;
				touch = ev.getTouch(bg, TouchPhase.ENDED);
				
				if(touch) {
					
					p.setTo(touch.globalX, touch.globalY);
					if(SpineHitTestUtil.hitTestWithAttachmentByGlobalPoint(_skeletonAnimation, "xxxxxx", p)) {
					} else {
						_showInfo("Touched ");
						touchCount++;
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
