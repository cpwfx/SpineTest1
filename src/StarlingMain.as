package {
    import demos.DemoBase;
    import demos.FilterDemo1;
    import demos.GoghDemo1;
    import demos.HitTestDemo1;

    import starling.core.Starling;
    import starling.display.Quad;
    import starling.display.Sprite;
    import starling.utils.AssetManager;

    public class StarlingMain extends Sprite {

        private var _assetManager:AssetManager;
        private var _demo:DemoBase;

        public function StarlingMain() {

            _assetManager = new AssetManager();
            _assetManager.verbose = true;

            var assets:Array = [];
            _demo = new FilterDemo1(_assetManager, Starling.current);
            _demo.addAssets(assets);
            addChild(_demo);

            _assetManager.enqueue(assets);
            _assetManager.loadQueue(function (ratio:Number):void {
                if (ratio == 1.0) {
                    _startDemo();
                }
            });

       }

        private function _startDemo():void {
            _demo.start();
        }
    }
}
