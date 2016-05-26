package demos {
	import flash.utils.ByteArray;

	import harayoki.spine.starling.MyStarlingTextureLoader;

	import spine.SkeletonData;
	import spine.SkeletonJson;
	import spine.atlas.Atlas;
	import spine.attachments.AtlasAttachmentLoader;
	import spine.attachments.AttachmentLoader;
	import spine.starling.SkeletonAnimation;

	import starling.core.Starling;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import starling.utils.AssetManager;
	
	public class GirlDemo extends DemoBase {

		private var _skeleton:SkeletonAnimation;

		public function GirlDemo(assetManager:AssetManager, starling:Starling = null) {
			super(assetManager, starling);
		}

		public override function addAssets(assets:Array):void {
			assets.push("assets/a.png");
			assets.push("assets/spine.atlas");
			assets.push("assets/spine.json");
		}

		public override function start():void {
			var texture:Texture = _assetManager.getTexture("a");
			var atlasData:ByteArray = _assetManager.getByteArray("spine");
			var skeletonJson:Object = _assetManager.getObject("spine");
			// trace(texture, atlasData, skeletonJson);

			var attachmentLoader:AttachmentLoader;
			var spineAtlas:Atlas = new Atlas(atlasData, new MyStarlingTextureLoader(texture)); // !
			attachmentLoader = new AtlasAttachmentLoader(spineAtlas);

			var json:SkeletonJson = new SkeletonJson(attachmentLoader);
			json.scale = 0.5;
			var skeletonData:SkeletonData = json.readSkeletonData(skeletonJson);

			_skeleton = new SkeletonAnimation(skeletonData, true);
			_skeleton.x = 150;
			_skeleton.y = 360;
			_skeleton.scaleX = -1;
			_skeleton.state.setAnimationByName(0, "animation", true);
			addChild(_skeleton);
			Starling.juggler.add(_skeleton);

			_skeleton = new SkeletonAnimation(skeletonData, true);
			_skeleton.x = 280;
			_skeleton.y = 360;
			_skeleton.timeScale = 3;
			_skeleton.state.setAnimationByName(0, "animation", true);
			addChild(_skeleton);
			Starling.juggler.add(_skeleton);

			_skeleton = new SkeletonAnimation(skeletonData, true);
			_skeleton.x = 410;
			_skeleton.y = 360;
			_skeleton.scaleX = 0.75;
			_skeleton.scaleY = 0.75;
			addChild(_skeleton);
			_skeleton.state.setAnimationByName(0, "animation", true);
			_skeleton.timeScale = 4;
			Starling.juggler.add(_skeleton);

			addEventListener(TouchEvent.TOUCH, onClick);

			scaleX = scaleY = 1.5;

		}


		private function onClick (event:TouchEvent) : void {
			var touch:Touch = event.getTouch(this);
			if (touch && touch.phase == TouchPhase.BEGAN) {
			}
		}

	}
}
