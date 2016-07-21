package harayoki.spine.starling {
	import flash.geom.Point;
	
	import spine.Slot;
	import spine.attachments.Attachment;
	import spine.attachments.BoundingBoxAttachment;
	import spine.attachments.MeshAttachment;
	import spine.attachments.PathAttachment;
	import spine.attachments.RegionAttachment;
	import spine.starling.SkeletonSprite;
	
	public class SpineHitTestUtil {
		
		private static var sVertices:Vector.<Number> = new <Number>[];
		private static var sPoint:Point = new Point();

		/**
		 * グローバル空間座標でSlot内の各種アタッチメントと当たり判定
		 */
		public static function hitTestWithAttachmentByGlobalPoint(sprite:SkeletonSprite, slotName:String, globalPoint:Point):Boolean {
			sprite.globalToLocal(globalPoint, sPoint);
			return hitTestWithAttachmentByLocalPoint(sprite, slotName, sPoint);
		}

		/**
		 * SkeletonSprite内の座標空間でSlot内の各種アタッチメントと当たり判定
		 * 対応したアタッチメント
		 * - RegionAttachment(画像) 推奨
		 * - BoundingBoxAttachment(多角形) 推奨
		 * - MeshAttachment(メッシュ) 大雑把な処理
		 * 対応していないアタッチメント
		 * - PathAttachment(パス) TODO できる事あるか確認
		 */
		public static function hitTestWithAttachmentByLocalPoint(sprite:SkeletonSprite, slotName:String, localPoint:Point):Boolean {

			var verticesLength:int;
			var worldVertices:Vector.<Number> = sVertices;
			var slot:Slot = sprite.skeleton.findSlot(slotName);
			if(!slot) return false;
			var attachment:Attachment = slot.attachment;

			if (attachment is RegionAttachment) {
				var region:RegionAttachment = RegionAttachment(slot.attachment);
				verticesLength = 8;
				if (worldVertices.length < verticesLength) worldVertices.length = verticesLength;
				region.computeWorldVertices(0, 0, slot.bone, worldVertices);

				return crossingNumberAlgorithmHitTest(localPoint.x, localPoint.y, worldVertices, verticesLength);
			}

			if(attachment is BoundingBoxAttachment) {
				var bounding:BoundingBoxAttachment = BoundingBoxAttachment(slot.attachment);
				verticesLength = bounding.vertices.length;
				if (worldVertices.length < verticesLength) worldVertices.length = verticesLength;
				bounding.computeWorldVertices(slot, worldVertices);

				return crossingNumberAlgorithmHitTest(localPoint.x, localPoint.y, worldVertices, verticesLength);
			}

			if (attachment is MeshAttachment) {
				var mesh:MeshAttachment = MeshAttachment(attachment);
				verticesLength = mesh.vertices.length;
				if (worldVertices.length < verticesLength) worldVertices.length = verticesLength;
				mesh.computeWorldVertices(slot, worldVertices);

				return minMaxHitTest(localPoint.x, localPoint.y, worldVertices, verticesLength);
			}

			if (attachment is PathAttachment) {
				// TODO
			}

			return false;

		};

		/**
		 * 各頂点に囲まれた領域に指定の点が含まれるか全体を含む矩形で大雑把にチェックする
		 */
		public static function minMaxHitTest(x:Number, y:Number, vertices:Vector.<Number>, verticesLen:int= -1):Boolean{
			var minX:Number = Number.MAX_VALUE, minY:Number = Number.MAX_VALUE;
			var maxX:Number = -Number.MAX_VALUE, maxY:Number = -Number.MAX_VALUE;
			verticesLen = verticesLen == -1 ? vertices.length : verticesLen;
			for (var ii:int = 0; ii < verticesLen; ii += 2) {
				var xx:Number = vertices[ii], yy:Number = vertices[ii + 1];
				minX = minX < xx ? minX : xx;
				minY = minY < yy ? minY : yy;
				maxX = maxX > xx ? maxX : xx;
				maxY = maxY > yy ? maxY : yy;
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

			if (x >= minX && x < maxX && y >= minY && y < maxY) {
				return true;
			}

			return false;

		}

		/**
		 * 各頂点に囲まれた内部に指定の点が含まれるかCrossing Number Algorithmでチェックする
		 * Crossing Number Algorithm
		 * (http://www.nttpc.co.jp/technology/number_algorithm.html)
		 */
		public static function crossingNumberAlgorithmHitTest(x:Number, y:Number, vertices:Vector.<Number>, verticesLen:int= -1):Boolean{
			verticesLen = verticesLen == -1 ? vertices.length : verticesLen;
			var cn:int = 0;
			var vt:Number;
			var x1:Number;
			var y1:Number;
			var x2:Number;
			var y2:Number;
			for(var i:int = 0; i < verticesLen; i+=2){
				x1 = vertices[i];
				y1 = vertices[i+1];
				x2 = vertices[i+2 >= verticesLen ? 0 : i+2];
				y2 = vertices[i+3 >= verticesLen ? 1 : i+3];
				if( ((y1 <= y) && (y2 > y))
					|| ((y1 > y) && (y2 <= y)) ){
					vt = (y - y1) / (y2 - y1);
					if(x < (x1 + (vt * (x2 - x1)))){
						cn++;
					}
				}
			}
			return (cn % 2) == 1;
		}

	}
}

