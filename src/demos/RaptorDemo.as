package demos {
    import spine.SkeletonData;
    import spine.SkeletonJson;
    import spine.atlas.Atlas;
    import spine.attachments.AtlasAttachmentLoader;
    import spine.attachments.AttachmentLoader;
    import spine.starling.SkeletonAnimation;
    import spine.starling.StarlingTextureLoader;

    import starling.core.Starling;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.textures.Texture;
    import starling.utils.AssetManager;

    public class RaptorDemo extends DemoBase {

        private var _skeleton:SkeletonAnimation;
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
            var texture:Texture = _assetManager.getTexture("raptor"); // TODO Bitmapを取り出さないとerrorに!
            var atlasData:Object = _assetManager.getByteArray("raptor");
            var skeletonJson:Object = _assetManager.getObject("raptor");
            trace(texture, atlasData, skeletonJson);

            var attachmentLoader:AttachmentLoader;
            var spineAtlas:Atlas = new Atlas(atlasData, new StarlingTextureLoader(texture));
            attachmentLoader = new AtlasAttachmentLoader(spineAtlas);

            var json:SkeletonJson = new SkeletonJson(attachmentLoader);
            json.scale = 0.5;
            var skeletonData:SkeletonData = json.readSkeletonData(skeletonJson);

            _skeleton = new SkeletonAnimation(skeletonData, true);
            _skeleton.x = 400;
            _skeleton.y = 560;
            _skeleton.state.setAnimationByName(0, "walk", true);

            addChild(_skeleton);
            Starling.juggler.add(_skeleton);

            addEventListener(TouchEvent.TOUCH, onClick);
        }

        private function onClick (event:TouchEvent) : void {
            var touch:Touch = event.getTouch(this);
            if (touch && touch.phase == TouchPhase.BEGAN) {
                if (_gunGrabbed) {
                    _skeleton.skeleton.setToSetupPose();
                } else {
                    _skeleton.state.setAnimationByName(1, "gungrab", false);
                }
                _gunGrabbed = !_gunGrabbed;
            }
        }

    }
}
