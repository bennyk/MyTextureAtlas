//
//  MyScene.m
//  MyTextureAtlas
//
//  Created by Benny Khoo on 6/15/14.
//  Copyright (c) 2014 Benny Khoo. All rights reserved.
//

#import "MyScene.h"
#import "MyTextureAtlas.h"

// assets based on
// https://github.com/AndreasLoew/TexturePacker-SpriteKit

#define SPRITES_SPR_BACKGROUND       @"Background"
#define SPRITES_SPR_CAPGUY_TURN_0001 @"capguy/turn/0001"
#define SPRITES_SPR_CAPGUY_TURN_0002 @"capguy/turn/0002"
#define SPRITES_SPR_CAPGUY_TURN_0003 @"capguy/turn/0003"
#define SPRITES_SPR_CAPGUY_TURN_0004 @"capguy/turn/0004"
#define SPRITES_SPR_CAPGUY_TURN_0005 @"capguy/turn/0005"
#define SPRITES_SPR_CAPGUY_TURN_0006 @"capguy/turn/0006"
#define SPRITES_SPR_CAPGUY_TURN_0007 @"capguy/turn/0007"
#define SPRITES_SPR_CAPGUY_TURN_0008 @"capguy/turn/0008"
#define SPRITES_SPR_CAPGUY_TURN_0009 @"capguy/turn/0009"
#define SPRITES_SPR_CAPGUY_TURN_0010 @"capguy/turn/0010"
#define SPRITES_SPR_CAPGUY_TURN_0011 @"capguy/turn/0011"
#define SPRITES_SPR_CAPGUY_TURN_0012 @"capguy/turn/0012"
#define SPRITES_SPR_CAPGUY_WALK_0001 @"capguy/walk/0001"
#define SPRITES_SPR_CAPGUY_WALK_0002 @"capguy/walk/0002"
#define SPRITES_SPR_CAPGUY_WALK_0003 @"capguy/walk/0003"
#define SPRITES_SPR_CAPGUY_WALK_0004 @"capguy/walk/0004"
#define SPRITES_SPR_CAPGUY_WALK_0005 @"capguy/walk/0005"
#define SPRITES_SPR_CAPGUY_WALK_0006 @"capguy/walk/0006"
#define SPRITES_SPR_CAPGUY_WALK_0007 @"capguy/walk/0007"
#define SPRITES_SPR_CAPGUY_WALK_0008 @"capguy/walk/0008"
#define SPRITES_SPR_CAPGUY_WALK_0009 @"capguy/walk/0009"
#define SPRITES_SPR_CAPGUY_WALK_0010 @"capguy/walk/0010"
#define SPRITES_SPR_CAPGUY_WALK_0011 @"capguy/walk/0011"
#define SPRITES_SPR_CAPGUY_WALK_0012 @"capguy/walk/0012"
#define SPRITES_SPR_CAPGUY_WALK_0013 @"capguy/walk/0013"
#define SPRITES_SPR_CAPGUY_WALK_0014 @"capguy/walk/0014"
#define SPRITES_SPR_CAPGUY_WALK_0015 @"capguy/walk/0015"
#define SPRITES_SPR_CAPGUY_WALK_0016 @"capguy/walk/0016"

@interface MyScene ()
@property SKAction *sequence;
@property MyTextureAtlas *atlas;
@end

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        [self initScene];
    }
    return self;
}

- (void) dumpTexProps:(SKTexture *)tex
{
    NSLog(@"crop offset: %@", NSStringFromCGPoint([[tex valueForKey:@"cropOffset"] CGPointValue]));
    NSLog(@"crop scale: %@", NSStringFromCGPoint([[tex valueForKey:@"cropScale"] CGPointValue]));
    NSLog(@"text rect: %@", NSStringFromCGRect([[tex valueForKey:@"textRect"] CGRectValue]));
    NSLog(@"text coords: %@", NSStringFromCGRect([[tex valueForKey:@"textCoords"] CGRectValue]));
    NSLog(@"text size: %@", NSStringFromCGSize(tex.size));
}

-(void) initScene
{
//    NSLog(@"scale factor: %.1f ", [[UIScreen mainScreen] scale]);

    MyTextureAtlas *atlas = [MyTextureAtlas atlasNamed:@"sprites"];
    self.atlas = atlas;
//    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"sprites"];
    
    NSArray *walking = @[
                         [atlas textureNamed:@"capguy/walk/0001"],
                         [atlas textureNamed:@"capguy/walk/0002"],
                         [atlas textureNamed:@"capguy/walk/0003"],
                         [atlas textureNamed:@"capguy/walk/0004"],
                         [atlas textureNamed:@"capguy/walk/0005"],
                         [atlas textureNamed:@"capguy/walk/0006"],
                         [atlas textureNamed:@"capguy/walk/0007"],
                         [atlas textureNamed:@"capguy/walk/0008"],
                         [atlas textureNamed:@"capguy/walk/0009"],
                         [atlas textureNamed:@"capguy/walk/0010"],
                         [atlas textureNamed:@"capguy/walk/0011"],
                         [atlas textureNamed:@"capguy/walk/0012"],
                         [atlas textureNamed:@"capguy/walk/0013"],
                         [atlas textureNamed:@"capguy/walk/0014"],
                         [atlas textureNamed:@"capguy/walk/0015"],
                         [atlas textureNamed:@"capguy/walk/0016"]
                         ];
    
    NSArray *turning = @[
                         [atlas textureNamed:@"capguy/turn/0001"],
                         [atlas textureNamed:@"capguy/turn/0002"],
                         [atlas textureNamed:@"capguy/turn/0003"],
                         [atlas textureNamed:@"capguy/turn/0004"],
                         [atlas textureNamed:@"capguy/turn/0005"],
                         [atlas textureNamed:@"capguy/turn/0006"],
                         [atlas textureNamed:@"capguy/turn/0007"],
                         [atlas textureNamed:@"capguy/turn/0008"],
                         [atlas textureNamed:@"capguy/turn/0009"],
                         [atlas textureNamed:@"capguy/turn/0010"],
                         [atlas textureNamed:@"capguy/turn/0011"],
                         [atlas textureNamed:@"capguy/turn/0012"]
                         ];
    
    // load background image, and set anchor point to the bottom left corner (default: center of sprite)
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:SPRITES_SPR_BACKGROUND]];
    background.anchorPoint = CGPointMake(0, 0);
    // add the background image to the SKScene; by default it is added to position 0,0 (bottom left corner) of the scene
    [self addChild: background];
    
    // in the first animation CapGuy walks from left to right, in the second one he turns from right to left
    SKAction *walk = [SKAction animateWithTextures:walking timePerFrame:0.033];
    SKAction *turn = [SKAction animateWithTextures:turning timePerFrame:0.033];
    
    // as the iPad display has such an enormous width, we have to repeat the animation
    // note: as 'repeat' actions may not be nested, we cannot use [SKAction repeatAction:count:] here,
    //       this would conflict with the [SKAction repeatActionForever:], see below
    SKAction *walkAnim = [SKAction sequence:@[walk, walk, walk, walk, walk, walk]];
    
    // we define two actions to move the sprite from left to right, and back;
    SKAction *moveRight  = [SKAction moveToX:900 duration:walkAnim.duration];
    SKAction *moveLeft   = [SKAction moveToX:100 duration:walkAnim.duration];
    
    // as we have only an animation with the CapGuy walking from left to right, we use a 'scale' action
    // to get a mirrored animation.
    SKAction *mirrorDirection  = [SKAction scaleXTo:-1 y:1 duration:0.0];
    SKAction *resetDirection   = [SKAction scaleXTo:1  y:1 duration:0.0];
    
    // Action within a group are executed in parallel:
    SKAction *walkAndMoveRight = [SKAction group:@[resetDirection,  walkAnim, moveRight]];
    SKAction *walkAndMoveLeft  = [SKAction group:@[mirrorDirection, walkAnim, moveLeft]];
    
    // now we combine the walk+turn actions into a sequence, and repeat it forever
    self.sequence = [SKAction repeatActionForever:[SKAction sequence:@[walkAndMoveRight, turn, walkAndMoveLeft, turn]]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // each time the user touches the screen, we create a new sprite, set its position, ...
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:[self.atlas textureNamed:@"capguy/walk/0001"]];
    sprite.position = CGPointMake(100, rand() % 100 + 200);
    
    // ... attach the action with the walk animation, and add it to our scene
    [sprite runAction:self.sequence];
    [self addChild:sprite];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
