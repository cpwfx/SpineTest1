package demos {
	import harayoki.spine.starling.SpineUtil;

	import spine.Skeleton;
	import spine.SkeletonData;
	import spine.Skin;
	import spine.animation.Animation;
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

	public class GoghDemo1 extends DemoBase {

		private var _uiSprite:Sprite;
		private var _lastBtnX:int = 10;
		private var _textField1:TextField;
		private var _texture:Texture;
		private var _playing:Boolean;
		private var _skeletonAnimation:SkeletonAnimation;
		private var _skeletonData:SkeletonData;
		private var _skeleton:Skeleton;
		private var _animationState:AnimationState;

		private var _assetNames:Array = ["gogh"];
		private var _infos:Object = {
			"default" : {scale:0.75, pos:{x:420, y:340}}
		};
		private var _assetName:String;

		public function GoghDemo1(assetManager:AssetManager, starling:Starling = null) {
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

			var animYurayura:Animation = _skeletonData.findAnimation("yurayura");
			var animGungun:Animation = _skeletonData.findAnimation("gungun");
			var animUnun:Animation = _skeletonData.findAnimation("unun");
			var animMusu:Animation = _skeletonData.findAnimation("musu");

			_playAnimation(animYurayura, 0, true, 1.5);

			addChild(_uiSprite);

			_playing = true;
			_updateAnimationPlaying();

			var btnY:int = 520;

			_addButton("うんうん@1(合成)", btnY, function():void{
				_playAnimation(animUnun, 1);
			});

			_addButton("むすっ@2(合成)", btnY, function():void{
				_playAnimation(animMusu, 2);
			});

			_addButton("てくてく@0", btnY, function():void{
				_playAnimation(animYurayura, 0, true, 1.5);
			}, 0xffcccccc);

			_addButton("ぐんぐん@0(上書き)", btnY, function():void{
				_playAnimation(animGungun, 0, true);
			}, 0xffcccccc);
			
			_addButton("play/stop", btnY, function():void{
				_playing = !_playing;
				_updateAnimationPlaying();
			}, 0xffffcccc);

			_addButton("setTo\nSetupPose", btnY, function():void{
				_skeletonAnimation.skeleton.setToSetupPose()
			}, 0xffffcccc);


			//_addButton("color", btnY, function():void{
			//	_skeletonAnimation.skeleton.r = 0.1 + Math.random() * 1.9;
			//	_skeletonAnimation.skeleton.g = 0.1 + Math.random() * 1.9;
			//	_skeletonAnimation.skeleton.b = 0.1 + Math.random() * 1.9;
			//});

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

		private function _addButton(text:String,yy:int,callback:Function, color:Number=0xffffffff):void {
			if(!_texture) {
				_texture = Texture.fromColor(75, 40, 0xffffffff);
			}
			var btn:Button = new Button(_texture, text);
			btn.x = _lastBtnX;
			btn.y = yy;
			btn.color = color;
			btn.addEventListener(Event.TRIGGERED, function(ev:Event):void{
				callback();
			});
			_uiSprite.addChild(btn);
			_lastBtnX += 80;
		}

		private function _playAnimation(anim:Animation, trackIndex:int=0, loop:Boolean=false, speed:Number=NaN):void {
			_animationState.setAnimationByName(trackIndex, anim.name, loop);
			if(!isNaN(speed)) {
				_animationState.getCurrent(trackIndex).timeScale  = speed;
			}
			// _skeletonAnimation.skeleton.setToSetupPose(); // これを呼ばないとちょっとおかしいままになる
			_updateInfo();
		}

		private function _updateInfo():void {
			if(!_textField1) {
				_textField1 = new TextField(800, 30, "");
				_textField1.x = 20;
				_textField1.y = 570;
				_textField1.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				_uiSprite.addChild(_textField1);
			}

			_textField1.text =
				(_playing ? "playing" : "stopped") + " animations : [ " + _skeletonData.animations.join("/") + " ]";
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
