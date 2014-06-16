//
//  MyTextureAtlas.h
//  MyTextureAtlas
//
//  Created by Benny Khoo on 6/15/14.
//  Copyright (c) 2014 Benny Khoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface MyTextureAtlas : NSObject

- (instancetype)initWithFile:(NSString *)path;
+ (instancetype) atlasNamed:(NSString *)name;
- (SKTexture *)textureNamed:(NSString *)name;

@end
