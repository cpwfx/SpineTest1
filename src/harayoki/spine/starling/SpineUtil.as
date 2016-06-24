package harayoki.spine.starling {
	import flash.utils.ByteArray;

	import spine.SkeletonData;
	import spine.SkeletonJson;
	import spine.Slot;
	import spine.atlas.Atlas;
	import spine.attachments.AtlasAttachmentLoader;
	import spine.attachments.Attachment;
	import spine.attachments.AttachmentLoader;
	import spine.attachments.RegionAttachment;
	import spine.starling.SkeletonAnimation;
	import spine.starling.SkeletonSprite;
	import spine.starling.StarlingAtlasAttachmentLoader;

	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.AssetManager;

	public class SpineUtil {

		/**
		 * AtalsがStarling形式だろうとSpine形式だろうと
		 * SkeletonJsonを作って返す
		 */
		public static function createSkeletonJson(assetManager:AssetManager, assetName:String):SkeletonJson {
			var attachmentLoader:AttachmentLoader;
			var starlingAtlas:TextureAtlas = assetManager.getTextureAtlas(assetName); // *.png + *.xml
			if(starlingAtlas) {
				attachmentLoader = new StarlingAtlasAttachmentLoader(starlingAtlas);
			} else {
				var texture:Texture = assetManager.getTexture(assetName); // *.png
				var atlasData:ByteArray = assetManager.getByteArray(assetName); // *.atlas
				var spineAtlas:Atlas = new Atlas(atlasData, new MyStarlingTextureLoader(texture));
				attachmentLoader = new AtlasAttachmentLoader(spineAtlas);
			}
			var skeletonJson:SkeletonJson = new SkeletonJson(attachmentLoader);
			return skeletonJson;
		}

		/**
		 * AtalsがStarling形式だろうとSpine形式だろうと
		 * SkeletonDataを作って返す
		 */
		public static function createSkeletonData(
			assetManager:AssetManager, assetName:String, scale:Number=1.0):SkeletonData {
			var skeletonJson:SkeletonJson = createSkeletonJson(assetManager, assetName);
			skeletonJson.scale = scale;
			var json:Object = assetManager.getObject(assetName);
			var data:SkeletonData = skeletonJson.readSkeletonData(json);
			return data;
		}

		/**
		 * AtalsがStarling形式だろうとSpine形式だろうと
		 * SkeletonAnimationを作って返す
		 */
		public static function createSkeletonAnimation(
			assetManager:AssetManager, assetName:String, scale:Number=1.0):SkeletonAnimation {
			var data:SkeletonData = createSkeletonData(assetManager, assetName, scale);
			var skeletonAnimation:SkeletonAnimation = new SkeletonAnimation(data, true);
			return skeletonAnimation;
		}
		
	}

}
