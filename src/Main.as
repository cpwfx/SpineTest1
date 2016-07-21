package {
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    
    import starling.core.Starling;
    
    [SWF(width = "800", height = "600", frameRate = "60", backgroundColor = "#dddddd")]
    public class Main extends Sprite {
        private var _starling:Starling

        public function Main () {

            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.quality = StageQuality.MEDIUM; // mobileではlowに
            addEventListener(Event.ADDED_TO_STAGE, _init);
        }

        private function _init(ev:Event=null):void {

            _starling = new Starling(StarlingMain, stage);
            _starling.enableErrorChecking = true;
            _starling.showStats = true;
            _starling.start();
        }
    }

}
