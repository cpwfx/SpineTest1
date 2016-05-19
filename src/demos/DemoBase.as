package demos {

    import starling.core.Starling;
    import starling.display.Sprite;
    import starling.utils.AssetManager;

    public class DemoBase extends Sprite{

        internal var _starling:Starling;
        internal var _assetManager:AssetManager;
        internal var _assets:Array;

        public function DemoBase(assetManager:AssetManager, starling:Starling=null) {
            _assets = [];
            _starling = starling ? starling : Starling.current;
            _assetManager = assetManager;
        }

        public function addAssets(assets:Array):void {
            return;
        }

        //public function getBottomButtons(out:Vector.<DisplayObject>):Vector.<DisplayObject> {
        //    return out;
        //}

        public function start():void{

        }
    }
}