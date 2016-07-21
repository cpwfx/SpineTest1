package harayoki.spine.starling {
    import spine.atlas.AtlasPage;
    import spine.atlas.AtlasRegion;
    import spine.atlas.TextureLoader;
    
    import starling.display.Image;
    
    import starling.textures.Texture;
    
    public class MyStarlingTextureLoader implements TextureLoader {

        private var _singleTexture:Texture;
        private var _textures:Object;

        public function MyStarlingTextureLoader(textures:Object) {

             if(textures is Texture) {
                _singleTexture = textures as Texture;
            } else {

                 _textures  = {};

                 for (var path:* in textures) {
                    var texture:Texture = textures[path] as Texture;
                    if(texture) {
                        _textures[path] = texture;
                    } else {
                        throw new ArgumentError("Object for path \"" + path + "\" must be a Texture: " + textures[path]);
                    }
                }
            }

        }

    public function loadPage (page:AtlasPage, path:String) : void {
        var texture:Texture = _singleTexture || _textures[path];
        if (!texture)
            throw new ArgumentError("Texture not found with name: " + path);
        page.rendererObject = texture;
        page.width = texture.width;
        page.height = texture.height;
    }

    public function loadRegion (region:AtlasRegion) : void {
        var image:Image = new Image(Texture(region.page.rendererObject));
        if (region.rotate) {
            image.setTexCoords(0, region.u, region.v2);
            image.setTexCoords(1, region.u, region.v);
            image.setTexCoords(2, region.u2, region.v2);
            image.setTexCoords(3, region.u2, region.v);
        } else {
            image.setTexCoords(0, region.u, region.v);
            image.setTexCoords(1, region.u2, region.v);
            image.setTexCoords(2, region.u, region.v2);
            image.setTexCoords(3, region.u2, region.v2);
        }
        region.rendererObject = image;
    }

    public function unloadPage (page:AtlasPage) : void {
        Texture(page.rendererObject).dispose();
    }
    }
}
