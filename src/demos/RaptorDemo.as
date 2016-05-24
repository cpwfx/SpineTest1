package demos {
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

    public class RaptorDemo extends DemoBase {

        private var _skeleton1:SkeletonAnimation;
        private var _skeleton2:SkeletonAnimation;
        private var _gunGrabbed:Boolean;

        public function RaptorDemo(assetManager:AssetManager, starling:Starling = null) {
            super(assetManager, starling);
        }

        public override function addAssets(assets:Array):void {
            assets.push("assets/raptor.png");
            assets.push("assets/raptor.atlas");
            assets.push("assets/raptor.json");
        }

        public override function start():void {
            var texture:Texture = _assetManager.getTexture("raptor");
            var atlasData:Object = _assetManager.getByteArray("raptor");
            var skeletonJson:Object = _assetManager.getObject("raptor");
            trace(texture, atlasData, skeletonJson);

            var attachmentLoader:AttachmentLoader;
            var spineAtlas:Atlas = new Atlas(atlasData, new MyStarlingTextureLoader(texture)); // !
            attachmentLoader = new AtlasAttachmentLoader(spineAtlas);

            var json:SkeletonJson = new SkeletonJson(attachmentLoader);
            json.scale = 0.5;
            var skeletonData:SkeletonData = json.readSkeletonData(skeletonJson);

            _skeleton1 = new SkeletonAnimation(skeletonData, true);
            _skeleton1.x = 180;
            _skeleton1.y = 520;
            _skeleton1.scaleX = _skeleton1.scaleY = 0.5;
            _skeleton1.state.setAnimationByName(0, "walk", true);
            addChild(_skeleton1);
            Starling.juggler.add(_skeleton1);

            _skeleton2 = new SkeletonAnimation(skeletonData, true);
            _skeleton2.x = 560;
            _skeleton2.y = 540;
            _skeleton2.scaleX = _skeleton2.scaleY = 1.0;
            _skeleton2.scaleX *= -1;
            _skeleton2.state.setAnimationByName(0, "walk", true);
            addChild(_skeleton2);
            Starling.juggler.add(_skeleton2);

            addEventListener(TouchEvent.TOUCH, onClick);
        }

        private function onClick (event:TouchEvent) : void {
            var touch:Touch = event.getTouch(this);
            if (touch && touch.phase == TouchPhase.BEGAN) {
                if (_gunGrabbed) {
                    _skeleton2.skeleton.setToSetupPose();
                } else {
                    _skeleton2.state.setAnimationByName(1, "gungrab", false);
                }
                _gunGrabbed = !_gunGrabbed;
            }
        }

    }
}
