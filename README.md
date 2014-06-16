MyTextureAtlas
==============

This project parses Apple's internal atlasc package to produce a texture atlas with per image texture mapping. Interface is
similar to Apple's [SKTextureAtlas](https://developer.apple.com/library/ios/documentation/SpriteKit/Reference/SKTextureAtlas/Reference/Reference.html).

Additionaly you can init *MyTextureAtlas* using the *initWithFile* passing the argument to the packaged *plist* file.
Be forewarned that atlasc format is internal and may subject to change in between iOS releases. Use the defacto SDK's
implementation whenever possible unless you came up with some weird requirements like in my case.

The Xcode's project contains an animation example based on the art assets produced by TexturePacker as in the following link: -

http://www.codeandweb.com/blog/2013/09/23/spritekit-animations-and-textureatlasses

Finally support Texturepacker for superior texture packing software.

