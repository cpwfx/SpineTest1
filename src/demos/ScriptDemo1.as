package demos {
	import harayoki.spine.starling.SpineUtil;

	import spine.Skeleton;
	import spine.SkeletonData;
	import spine.Skin;
	import spine.animation.Animation;
	import spine.animation.AnimationState;
	import spine.starling.SkeletonAnimation;

	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.textures.Texture;
	import starling.utils.AssetManager;

	public class ScriptDemo1 extends DemoBase {

		private var _animationIndex:int = -1;
		private var _skinIndex:int = -1;
		private var _uiSprite:Sprite;
		private var _lastBtnX:int = 10;
		private var _textField1:TextField;
		private var _textField2:TextField;
		private var _texture:Texture;
		private var _playing:Boolean;
		private var _skeletonAnimation:SkeletonAnimation;
		private var _skeletonData:SkeletonData;
		private var _skeleton:Skeleton;
		private var _animationState:AnimationState;

		private var _assetNames:Array = ["mecha", "goblins-mesh", "spineboy", "girl"]; //"raptor",
		private var _infos:Object = {
			"goblins-mesh" : {scale:1.0, pos:{x:420, y:480}},
			"spineboy" : {scale:0.5, pos:{x:420, y:480}},
			"raptor"  : {scale:0.4, pos:{x:420, y:480}},
			"girl": {scale:0.75, pos:{x:420, y:480}},
			"mecha" : {scale:0.5, pos:{x:128, y:128}},
			"default" : {scale:0.5, pos:{x:420, y:480}}
		};
		private var _assetName:String;

		public function ScriptDemo1(assetManager:AssetManager, starling:Starling = null) {
			super(assetManager, starling);
			_assetName = _lot(_assetNames) + "";
		}

		public override function addAssets(assets:Array):void {
			assets.push("assets/" + _assetName + ".png");
			assets.push("assets/" + _assetName + ".atlas");
			assets.push("assets/" + _assetName + ".json");
		}

		public override function start():void {

			_uiSprite = new Sprite();

			var info:Object = _infos[_assetName] || _infos["default"];

			_skeletonData = SpineUtil.createSkeletonData(_assetManager, _assetName, info.scale);

			var pos:Object = info.pos || {x:0, y:0};
			_skeletonAnimation = _addSkeletonAnimation(_skeletonData, pos.x, pos.y);

			_skeleton = _skeletonAnimation.skeleton;
			_animationState = _skeletonAnimation.state;
			_playNextAnimation();

			addChild(_uiSprite);

			var btnY:int = 505;
			_addButton("play/stop", btnY, function():void{
				_playing = !_playing;
				_updateAnimationPlaying();
			});

			_addButton("change anim", btnY, function():void{
				_playNextAnimation();
			});

			_addButton("setTo\nSetupPose", btnY, function():void{
				_skeletonAnimation.skeleton.setToSetupPose()
			});

			_addButton("change skin", btnY, function():void{
				_applyNextSkin();
			});

			_addButton("flipX", btnY, function():void{
				_skeleton.flipX = !_skeleton.flipX;
			});

			_addButton("color", btnY, function():void{
				_skeletonAnimation.skeleton.r = 0.1 + Math.random() * 1.9;
				_skeletonAnimation.skeleton.g = 0.1 + Math.random() * 1.9;
				_skeletonAnimation.skeleton.b = 0.1 + Math.random() * 1.9;
			});

			_addButton("alpha\n(Starling)", btnY, function():void{
				_skeletonAnimation.alpha = _skeletonAnimation.alpha == 1.0 ? 0.5 : 1.0;

			});

			_addButton("skewX\n(Starling)", btnY, function():void{
				_skeletonAnimation.skewX = _skeletonAnimation.skewX == 0.0 ? -0.25: 0.0;
			});

			_addButton("scaleX\n(Starling)", btnY, function():void{
				_skeletonAnimation.scaleX = _skeletonAnimation.scaleX == 1.0 ? 1.25 : 1.0;
			});

			trace(_skeletonAnimation.skeleton.data == _skeletonData); // true
			trace(_skeletonData.animations[0].name); // "animation"
			trace(_skeletonData.skins[0].name); // "default"
			trace(_skeletonData.defaultSkin == _skeletonData.skins[0]); // true
			trace(_skeletonData.findAnimation(_skeletonData.animations[0].name) == _skeletonData.animations[0]); //true

			addEventListener(TouchEvent.TOUCH, function(ev:TouchEvent):void{
				if(ev.getTouch(_skeletonAnimation, TouchPhase.ENDED)) {
					_uiSprite.visible = !_uiSprite.visible;
				}
			});

		}

		private function _addButton(text:String,yy:int,callback:Function):void {
			if(!_texture) {
				_texture = Texture.fromColor(75, 40, 0xffffffff);
			}
			var btn:Button = new Button(_texture, text);
			btn.x = _lastBtnX;
			btn.y = yy;
			btn.addEventListener(Event.TRIGGERED, function(ev:Event):void{
				callback();
			});
			_uiSprite.addChild(btn);
			_lastBtnX += 80;
		}

		private function _playNextAnimation():void {
			_animationIndex++;
			if(_animationIndex >= _skeletonData.animations.length) {
				_animationIndex = 0;
			}
			var anim:Animation = _skeletonData.animations[_animationIndex];
			_animationState.setAnimationByName(0, anim.name, true);

			// _skeletonAnimation.skeleton.setToSetupPose(); // これを呼ばないとちょっとおかしいままになる
			_updateInfo();
		}

		private function _applyNextSkin():void {
			_skinIndex++;
			if(_skinIndex >= _skeletonData.skins.length) {
				_skinIndex = 0;
			}
			var skin:Skin = _skeletonData.skins[_skinIndex];
			_skeleton.skin = skin;
			// _skeletonAnimation.skeleton.setToSetupPose(); // これを呼ばないと変わらない
			_updateInfo();
		}

		private function _updateInfo():void {
			if(!_textField1) {
				_textField1 = new TextField(800, 30, "");
				_textField1.x = 20;
				_textField1.y = 550;
				_textField1.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				_uiSprite.addChild(_textField1);
			}
			if(!_textField2) {
				_textField2 = new TextField(800, 30, "");
				_textField2.x = 20;
				_textField2.y = 570;
				_textField2.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				_uiSprite.addChild(_textField2);
			}

			var quad:Quad
			var anim:Animation = _skeletonData.animations[_animationIndex];
			_textField1.text =
				(_playing ? "playing" : "stopped") + " animation : " + anim.name + "[ " + _skeletonData.animations.join("/") + " ]";
			_textField2.text =
				"skin : " + _skeleton.skinName + " [ " + _skeletonData.skins.join("/") + " ]";
		}

		private function _addSkeletonAnimation(skeletonData:SkeletonData, xx:int, yy:int):SkeletonAnimation {
			var skeletonAnimation:SkeletonAnimation = new SkeletonAnimation(skeletonData, true);
			skeletonAnimation.x = xx;
			skeletonAnimation.y = yy;
			addChild(skeletonAnimation);
			return skeletonAnimation;
		}

		private function _updateAnimationPlaying():void {

			if(_playing) {
				Starling.juggler.add(_skeletonAnimation);
			} else {
				Starling.juggler.remove(_skeletonAnimation);
			}
			_updateInfo();
		}

	}
}
