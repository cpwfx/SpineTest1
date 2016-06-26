package harayoki.spine.starling {
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	import spine.SkeletonData;
	import spine.animation.AnimationStateData;
	import spine.starling.SkeletonAnimation;

	import starling.display.DisplayObject;
	import starling.utils.VertexData;

	public class MySkeletonAnimation extends SkeletonAnimation {

		private static var _tempPoint:Point = new Point();
		private static var _tempMatrix:Matrix = new Matrix();
		private static var _tempMatrix3D:Matrix3D = new Matrix3D();
		private static var _tempPoint3D:Vector3D = new Vector3D();

		private var _fixedBounds:Rectangle;
		private var _tempVertexData:VertexData;

		public function MySkeletonAnimation(skeletonData:SkeletonData, fixedBounds:Rectangle, renderMeshes:Boolean = true, stateData:AnimationStateData = null) {
			_tempVertexData = new VertexData(4);
			this.fixedBounds = fixedBounds;
			super(skeletonData, renderMeshes, stateData);
		}

		public function set fixedBounds(value:Rectangle) : void {
			if(_fixedBounds != value) {
				_fixedBounds = value;
				_tempVertexData.setPosition(0, _fixedBounds.x, _fixedBounds.y);
				_tempVertexData.setPosition(1, _fixedBounds.right, _fixedBounds.y);
				_tempVertexData.setPosition(2, _fixedBounds.x, _fixedBounds.bottom);
				_tempVertexData.setPosition(3, _fixedBounds.right, _fixedBounds.bottom);
			}
		}

		public function get fixedBounds() : Rectangle {
			return _fixedBounds;
		}

		override public function getBounds (targetSpace:DisplayObject, resultRect:Rectangle = null) : Rectangle {

			var scaleX:Number = this.scaleX;
			var scaleY:Number = this.scaleY;

			if(!resultRect) {
				resultRect = new flash.geom.Rectangle();
			}

			if (!resultRect)
				resultRect = new Rectangle();
			if (targetSpace == this)
				resultRect.copyFrom(_fixedBounds);
			else if (targetSpace == parent && rotation==0.0) {
				_tempPoint.setTo(_fixedBounds.right, _fixedBounds.bottom);
				resultRect.setTo(x - pivotX * scaleX,      y - pivotY * scaleY,
					_fixedBounds.x * scaleX, _fixedBounds.y * scaleY);
				if (scaleX < 0) { resultRect.width  *= -1; resultRect.x -= resultRect.width;  }
				if (scaleY < 0) { resultRect.height *= -1; resultRect.y -= resultRect.height; }
			}
			else if (is3D && stage) {
				stage.getCameraPosition(targetSpace, _tempPoint3D);
				getTransformationMatrix3D(targetSpace, _tempMatrix3D);
				_tempVertexData.getBoundsProjected(_tempMatrix3D, _tempPoint3D, 0, 4, resultRect);
			}
			else {
				getTransformationMatrix(targetSpace, _tempMatrix);
				_tempVertexData.getBounds(_tempMatrix, 0, 4, resultRect);
			}

			return resultRect;
		}
	}
}
