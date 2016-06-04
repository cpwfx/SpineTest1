package demos {
	import flash.utils.ByteArray;

	import harayoki.spine.starling.MyStarlingTextureLoader;

	import spine.Skeleton;
	import spine.SkeletonData;
	import spine.SkeletonJson;
	import spine.Skin;
	import spine.animation.Animation;
	import spine.atlas.Atlas;
	import spine.attachments.AtlasAttachmentLoader;
	import spine.attachments.AttachmentLoader;
	import spine.starling.SkeletonAnimation;

	import starling.core.Starling;
	import starling.display.Button;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.textures.Texture;
	import starling.utils.AssetManager;

	public class SpneDemo20160604 extends DemoBase {

		private var _animationIndex:int = -1;
		private var _skinIndex:int = -1;
		private var _textField1:TextField;
		private var _textField2:TextField;
		private var _texture:Texture;
		private var _playing:Boolean;
		private var _skeletonAnimation:SkeletonAnimation;
		private var _skeletonData:SkeletonData;
		private var _skeleton:Skeleton;

		private var _assetNames:Array = ["goblins-mesh", "spineboy", "raptor", "girl"];
		private var _scales:Object = {
			"goblins-mesh" : 1.0,
			"spineboy": 1.0,
			"raptor" : 0.5,
			"girl": 0.75
		};
		private var _assetName:String;

		public function SpneDemo20160604(assetManager:AssetManager, starling:Starling = null) {
			super(assetManager, starling);
			_assetName = _lot(_assetNames) + "";
		}

		public override function addAssets(assets:Array):void {
			assets.push("assets/" + _assetName + ".png");
			assets.push("assets/" + _assetName + ".atlas");
			assets.push("assets/" + _assetName + ".json");
		}

		public override function start():void {
			var texture:Texture = _assetManager.getTexture(_assetName);
			var atlasData:ByteArray = _assetManager.getByteArray(_assetName);
			var skeletonJson:Object = _assetManager.getObject(_assetName);

			var attachmentLoader:AttachmentLoader;
			var spineAtlas:Atlas = new Atlas(atlasData, new MyStarlingTextureLoader(texture)); // !
			attachmentLoader = new AtlasAttachmentLoader(spineAtlas);

			var json:SkeletonJson = new SkeletonJson(attachmentLoader);
			json.scale = _scales[_assetName] || 1.0;
			_skeletonData = json.readSkeletonData(skeletonJson);

			_skeletonAnimation = _addGirl(_skeletonData, 420, 490, true);
			_skeleton = _skeletonAnimation.skeleton;
			_playNextAnimation();

			var btnY:int = 505;
			_addButton("play/stop", 20, btnY, function():void{
				_playing = !_playing;
				_updateAnimationPlaying();
			});

			_addButton("change anim", 120, btnY, function():void{
				_playNextAnimation();
			});

			_addButton("pose reset", 220, btnY, function():void{
				_skeletonAnimation.skeleton.setToSetupPose()
			});

			_addButton("change skin", 320, btnY, function():void{
				_applyNextSkin();
			});

			trace(_skeletonAnimation.skeleton.data == _skeletonData); // true
			trace(_skeletonData.animations[0].name); // "animation"
			trace(_skeletonData.skins[0].name); // "default"
			trace(_skeletonData.defaultSkin == _skeletonData.skins[0]); // true

		}

		private function _addButton(text:String,xx:int,yy:int,callback:Function):void {
			if(!_texture) {
				_texture = Texture.fromColor(90, 40, 0xffffffff);
			}
			var btn:Button = new Button(_texture, text);
			btn.x = xx;
			btn.y = yy;
			btn.addEventListener(Event.TRIGGERED, function(ev:Event):void{
				callback();
			});
			addChild(btn);
		}

		private function _playNextAnimation():void {
			_animationIndex++;
			if(_animationIndex >= _skeletonData.animations.length) {
				_animationIndex = 0;
			}
			var anim:Animation = _skeletonData.animations[_animationIndex];
			_skeletonAnimation.state.setAnimationByName(0, anim.name, true);
			_updateInfo();
		}

		private function _applyNextSkin():void {
			_skinIndex++;
			if(_skinIndex >= _skeletonData.skins.length) {
				_skinIndex = 0;
			}
			var skin:Skin = _skeletonData.skins[_skinIndex];
			_skeleton.skin = skin;
			_skeletonAnimation.skeleton.setToSetupPose()
			_updateInfo();
		}

		private function _updateInfo():void {
			if(!_textField1) {
				_textField1 = new TextField(800, 30, "");
				_textField1.x = 20;
				_textField1.y = 550;
				_textField1.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				addChild(_textField1);
			}
			if(!_textField2) {
				_textField2 = new TextField(800, 30, "");
				_textField2.x = 20;
				_textField2.y = 570;
				_textField2.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
				addChild(_textField2);
			}
			var anim:Animation = _skeletonData.animations[_animationIndex];
			_textField1.text =
				(_playing ? "playing" : "stopped") + " animation : " + anim.name + "[ " + _skeletonData.animations.join("/") + " ]";
			_textField2.text =
				"skin : " + _skeleton.skinName + " [ " + _skeletonData.skins.join("/") + " ]";
		}

		private function _addGirl(skeletonData:SkeletonData, xx:int, yy:int, playing:Boolean=true):SkeletonAnimation {
			var girl:SkeletonAnimation = new SkeletonAnimation(skeletonData, true);
			girl.x = xx;
			girl.y = yy;
			addChild(girl);
			return girl;
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
