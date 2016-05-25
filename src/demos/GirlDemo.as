package demos {
	import harayoki.spine.starling.MyStarlingTextureLoader;

	import spine.SkeletonData;
	import spine.SkeletonJson;
	import spine.atlas.Atlas;
	import spine.attachments.AtlasAttachmentLoader;
	import spine.attachments.AttachmentLoader;
	import spine.starling.SkeletonAnimation;

	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import starling.utils.AssetManager;

	public class GirlDemo extends DemoBase {

		public function GirlDemo(assetManager:AssetManager, starling:Starling = null) {
			super(assetManager, starling);
		}

		public override function addAssets(assets:Array):void {
			assets.push("assets/girl.png");
			assets.push("assets/girl.atlas");
			assets.push("assets/girl.json");
		}

		public override function start():void {
			var texture:Texture = _assetManager.getTexture("girl");
			var atlasData:Object = _assetManager.getByteArray("girl");
			var skeletonJson:Object = _assetManager.getObject("girl");

			var attachmentLoader:AttachmentLoader;
			var spineAtlas:Atlas = new Atlas(atlasData, new MyStarlingTextureLoader(texture)); // !
			attachmentLoader = new AtlasAttachmentLoader(spineAtlas);

			var json:SkeletonJson = new SkeletonJson(attachmentLoader);
			json.scale = 0.75;
			var skeletonData:SkeletonData = json.readSkeletonData(skeletonJson);

			_addGirl(skeletonData, 280, 470, false);
			_addGirl(skeletonData, 410, 470, true);
			_addGirl(skeletonData, 540, 470, false);

		}

		private function _addGirl(skeletonData:SkeletonData, xx:int, yy:int, playing:Boolean=true):void {
			var girl:SkeletonAnimation = new SkeletonAnimation(skeletonData, true);
			girl.x = xx;
			girl.y = yy;
			addChild(girl);

			var animName:String = "animation";

			if(playing) {
				girl.state.setAnimationByName(0, animName, true);
				Starling.juggler.add(girl);
			} else {
				girl.skeleton.setToSetupPose()
			}

			//girl.addEventListener(Event.ENTER_FRAME, function(ev:Event):void{
			//});

			girl.addEventListener(TouchEvent.TOUCH, function(ev:TouchEvent):void{
				if (! ev.getTouch(girl, TouchPhase.ENDED)) {
					return;
				}
				playing = !playing;
				if(playing) {
					girl.state.setAnimationByName(0, animName, true);
					Starling.juggler.add(girl);
				} else {
					Starling.juggler.remove(girl);
				}
			});

		}

	}
}
