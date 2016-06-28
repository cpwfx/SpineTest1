package harayoki.spine.starling {
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	import spine.SkeletonData;
	import spine.Slot;
	import spine.animation.AnimationStateData;
	import spine.attachments.Attachment;
	import spine.attachments.MeshAttachment;
	import spine.attachments.RegionAttachment;
	import spine.attachments.WeightedMeshAttachment;
	import spine.starling.SkeletonAnimation;

	import starling.display.DisplayObject;
	import starling.utils.VertexData;

	public class MySkeletonAnimation extends SkeletonAnimation {

		private static var _tempPoint:Point = new Point();
		private static var _tempMatrix:Matrix = new Matrix();
		private static var _tempMatrix3D:Matrix3D = new Matrix3D();
		private static var _tempPoint3D:Vector3D = new Vector3D();
		private static var _tempVertices:Vector.<Number> = new Vector.<Number>(8);

		private var _fixedBounds:Rectangle;
		private var _fixedVertexData:VertexData;

		public function MySkeletonAnimation(skeletonData:SkeletonData, renderMeshes:Boolean = true, stateData:AnimationStateData = null) {
			_fixedVertexData = new VertexData(4);
			super(skeletonData, renderMeshes, stateData);
		}

		public override function dispose():void {
			_fixedVertexData = null;
			_fixedBounds = null;
			super.dispose();
		}

		public function setBoundsDirectly(value:Rectangle) : void {
			if(_fixedBounds != value) {
				_fixedBounds = value;
			}
			_updateVertexData();
		}

		private function _updateVertexData(): void {
			if(_fixedBounds) {
				_fixedVertexData.setPosition(0, _fixedBounds.x, _fixedBounds.y);
				_fixedVertexData.setPosition(1, _fixedBounds.right, _fixedBounds.y);
				_fixedVertexData.setPosition(2, _fixedBounds.x, _fixedBounds.bottom);
				_fixedVertexData.setPosition(3, _fixedBounds.right, _fixedBounds.bottom);
			} else {
				_fixedVertexData.setPosition(0, 0, 0);
				_fixedVertexData.setPosition(1, 0, 0);
				_fixedVertexData.setPosition(2, 0, 0);
				_fixedVertexData.setPosition(3, 0, 0);
			}
		}

		public function updateBounds(marginX:Number=0, marginY:Number=0) : void {
			var minX:Number = Number.MAX_VALUE, minY:Number = Number.MAX_VALUE;
			var maxX:Number = -Number.MAX_VALUE, maxY:Number = -Number.MAX_VALUE;
			var slots:Vector.<Slot> = skeleton.slots;
			var worldVertices:Vector.<Number> = _tempVertices;
			for (var i:int = 0, n:int = slots.length; i < n; ++i) {
				var slot:Slot = slots[i];
				var attachment:Attachment = slot.attachment;
				if (!attachment) continue;
				var verticesLength:int;
				if (attachment is RegionAttachment) {
					var region:RegionAttachment = RegionAttachment(slot.attachment);
					verticesLength = 8;
					region.computeWorldVertices(0, 0, slot.bone, worldVertices);
				} else if (attachment is MeshAttachment) {
					var mesh:MeshAttachment = MeshAttachment(attachment);
					verticesLength = mesh.vertices.length;
					if (worldVertices.length < verticesLength) worldVertices.length = verticesLength;
					mesh.computeWorldVertices(0, 0, slot, worldVertices);
				} else if (attachment is WeightedMeshAttachment) {
					var weightedMesh:WeightedMeshAttachment = WeightedMeshAttachment(attachment);
					verticesLength = weightedMesh.uvs.length;
					if (worldVertices.length < verticesLength) worldVertices.length = verticesLength;
					weightedMesh.computeWorldVertices(0, 0, slot, worldVertices);
				} else
					continue;
				for (var ii:int = 0; ii < verticesLength; ii += 2) {
					var x:Number = worldVertices[ii], y:Number = worldVertices[ii + 1];
					minX = minX < x ? minX : x;
					minY = minY < y ? minY : y;
					maxX = maxX > x ? maxX : x;
					maxY = maxY > y ? maxY : y;
				}
			}

			var temp:Number;
			if (maxX < minX) {
				temp = maxX;
				maxX = minX;
				minX = temp;
			}
			if (maxY < minY) {
				temp = maxY;
				maxY = minY;
				minY = temp;
			}

			if(!_fixedBounds) {
				_fixedBounds = new Rectangle();
			}

			_fixedBounds.setTo(minX, minY, maxX - minX, maxY - minY);

			if(marginX > 0 || marginY > 0) {
				_fixedBounds.inflate(marginX, marginY);
			}

			_updateVertexData();

		}

		public override function getBounds (targetSpace:DisplayObject, resultRect:Rectangle = null) : Rectangle {

			if(!_fixedBounds) {
				return super.getBounds(targetSpace, resultRect);
			}

			if (!resultRect) {
				resultRect = new Rectangle();
			}

			if (targetSpace == this) {
				resultRect.copyFrom(_fixedBounds);
			} else if (targetSpace == parent && rotation == 0.0) {
				var scaleX:Number = this.scaleX;
				var scaleY:Number = this.scaleY;
				_tempPoint.setTo(_fixedBounds.right, _fixedBounds.bottom);
				resultRect.setTo(x - pivotX * scaleX, y - pivotY * scaleY, _fixedBounds.x * scaleX, _fixedBounds.y * scaleY);
				if (scaleX < 0) {
					resultRect.width  *= -1;
					resultRect.x -= resultRect.width;
				}
				if (scaleY < 0) {
					resultRect.height *= -1;
					resultRect.y -= resultRect.height;
				}
			} else if (is3D && stage) {
				// not tested yet
				stage.getCameraPosition(targetSpace, _tempPoint3D);
				getTransformationMatrix3D(targetSpace, _tempMatrix3D);
				_fixedVertexData.getBoundsProjected(_tempMatrix3D, _tempPoint3D, 0, 4, resultRect);
			} else {
				getTransformationMatrix(targetSpace, _tempMatrix);
				_fixedVertexData.getBounds(_tempMatrix, 0, 4, resultRect);
			}

			return resultRect;
		}
	}
}
