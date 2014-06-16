//
//  MyTextureAtlas.m
//  MyTextureAtlas
//
//  Created by Benny Khoo on 6/15/14.
//  Copyright (c) 2014 Benny Khoo. All rights reserved.
//

#import "MyTextureAtlas.h"

static NSString *const SPRetinaSuffix = @"@2x";

@interface NSString (MyTextureAtlas)
- (NSString *)stringByDeletingPathSuffix:(NSString *)suffix;
@end

@interface _ImageMap : NSObject  {
    __weak MyTextureAtlas *_parent;
    NSString *_path;
    CGSize _size;
    NSArray *_entries;
    
    SKTexture *_texture;
}
@property (readonly) SKTexture *texture;
@property (readonly) UIImage *image;

- (instancetype) initWithDict:(NSDictionary *)dict parent:(MyTextureAtlas *)parent;
- (SKTexture *)textureNamed:(NSString *)name;
@end

@interface _ImageMapEntry : NSObject {
    __weak _ImageMap *_parent;
    
    CGSize _spriteSourceSize;
    BOOL _isFullyOpaque;
    CGRect _textureRect;
    CGPoint _spriteOffset;
    NSString *_name;
    BOOL _textureRotated;
    
    SKTexture *_texture;
}
@property NSString *name;
@property (readonly) SKTexture *texture;

- (instancetype) initWithDict:(NSDictionary *)dict parent:(_ImageMap *)parent;

@end

@interface MyTextureAtlas () {
    NSArray *_images;
    NSString *_folder;
}
@property NSString *folder;
@end

@implementation MyTextureAtlas

- (instancetype)initWithFile:(NSString *)path
{
    self = [super init];
    if (self) {
        NSMutableArray *mutableEntries = [NSMutableArray array];
        NSDictionary *mapping = [NSDictionary dictionaryWithContentsOfFile:path];
        for (NSDictionary *item in [mapping objectForKey:@"images"]) {
            id result = [[_ImageMap alloc] initWithDict:item parent:self];
            [mutableEntries addObject:result];
        }
        _images = mutableEntries;
        _folder = [path stringByDeletingLastPathComponent];
    }
    return self;
}

+ (instancetype) atlasNamed:(NSString *)name
{
    NSString *filepath = [[NSBundle mainBundle] pathForResource:name ofType:@"atlasc"];
    NSString *baseName = [[filepath lastPathComponent] stringByDeletingPathExtension];
    
    NSString *plistFile = [NSString stringWithFormat:@"%@/%@.plist", filepath, baseName];

    return [[self alloc] initWithFile:plistFile];
}

- (SKTexture *)textureNamed:(NSString *)name
{
    SKTexture *result = nil;
    for (_ImageMap *entry in _images) {
        result = [entry textureNamed:name];
        if (result != nil) {
            break;
        }
    }
    return result;
}

@end

@implementation _ImageMap

- (instancetype) initWithDict:(NSDictionary *)dict parent:(MyTextureAtlas *)parent
{
    self = [super init];
    if (self) {
        _parent = parent;
        _path = [dict objectForKey:@"path"];
        _size = CGSizeFromString([dict objectForKey:@"size"]);
        
        NSMutableArray *mutableEntries = [NSMutableArray arrayWithCapacity:10];
        for (NSDictionary *item in [dict objectForKey:@"subimages"]) {
            _ImageMapEntry *entry = [[_ImageMapEntry alloc] initWithDict:item parent:self];
            [mutableEntries addObject:entry];
        }
        _entries = mutableEntries;
    }
    return self;
}

- (SKTexture *)textureNamed:(NSString *)name
{
    SKTexture *result = nil;
    for (_ImageMapEntry *entry in _entries) {
        if ([name isEqualToString:entry.name]) {
            result = entry.texture;
            break;
        }
    }
    return result;
}

- (UIImage *) image
{
    NSString *fullpath = [NSString stringWithFormat:@"%@/%@", _parent.folder, _path];
//    NSLog(@"reading %@", fullpath);
    UIImage *result = [UIImage imageWithContentsOfFile:fullpath];
    
    if (result.scale > 1.0) {
        //TODO bad boy! current SKTexture implementation ignores content scaling. So we'll have to scale it first.
        result = [self.class imageWithImage:result scaledToSize:result.size];
    }
//    NSLog(@"image scale %.2f %@", result.scale, NSStringFromCGSize(result.size));
    return result;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (SKTexture *)texture
{
    if (_texture == nil) {
        _texture = [SKTexture textureWithImage:self.image];
    }
    return _texture;
}

- (CGRect) normalizedRect:(CGRect)rect
{
    CGFloat startx = rect.origin.x / _size.width;
    CGFloat starty = 1 - rect.origin.y / _size.height - rect.size.height / _size.height;
    return CGRectMake(startx, starty,
                      rect.size.width / _size.width, rect.size.height / _size.height);
}

@end

@implementation _ImageMapEntry

- (instancetype)initWithDict:(NSDictionary *)dict parent:(_ImageMap *)parent
{
    self = [super init];
    if (self) {
        _parent = parent;
        _spriteSourceSize = CGSizeFromString([dict objectForKey:@"spriteSourceSize"]);
        _isFullyOpaque = [[dict objectForKey:@"isFullyOpaque"] boolValue];
        _textureRect = CGRectFromString([dict objectForKey:@"textureRect"]);
        _spriteOffset = CGPointFromString([dict objectForKey:@"spriteOffset"]);
        _textureRotated = [[dict objectForKey:@"textureRotated"] boolValue];
        
        NSString *rawName = [dict objectForKey:@"name"];
        rawName = [rawName stringByDeletingPathExtension];
        
        if ([rawName hasSuffix:SPRetinaSuffix]) {
            _name = [rawName stringByDeletingPathSuffix:SPRetinaSuffix];
        } else {
            _name = rawName;
        }

    }
    return self;
}

- (SKTexture *) texture
{
    if (_texture == nil) {
        CGRect normalizedRect = [_parent normalizedRect:_textureRect];
        _texture = [SKTexture textureWithRect:normalizedRect inTexture:_parent.texture];
        
        [_texture setValue:[NSNumber numberWithBool:_textureRotated] forKey:@"isRotated"];
        [_texture setValue:[NSNumber numberWithBool:_isFullyOpaque] forKey:@"_disableAlpha"];
        
        CGPoint cropScale;
        CGSize sourceSize;
        if (!_textureRotated) {
            sourceSize = CGSizeMake(_spriteSourceSize.width, _spriteSourceSize.height);
        } else {
            sourceSize = CGSizeMake(_spriteSourceSize.height, _spriteSourceSize.width);
        }
        cropScale = CGPointMake(_textureRect.size.width / sourceSize.width,
                                _textureRect.size.height / sourceSize.height);
        [_texture setValue:[NSValue valueWithCGPoint:cropScale] forKey:@"cropScale"];
        
        CGPoint adjPoint = CGPointMake((_textureRect.size.width - sourceSize.width) / 2 + _spriteOffset.x,
                                       (_textureRect.size.height - sourceSize.height) / 2 + _spriteOffset.y);
        CGPoint cropOffset = CGPointMake(adjPoint.x/_textureRect.size.width, adjPoint.y/_textureRect.size.height);
        [_texture setValue:[NSValue valueWithCGPoint:cropOffset] forKey:@"cropOffset"];
    }
    
    return _texture;
}

@end


@implementation NSString (MyTextureAtlas)

- (NSString *)stringByDeletingPathSuffix:(NSString *)suffix
{
    if ([suffix length])
    {
        NSString *extension = [self pathExtension];
        NSString *path = [self stringByDeletingPathExtension];
        if ([path hasSuffix:suffix])
        {
            path = [path substringToIndex:[path length] - [suffix length]];
            if ([extension length] > 0) {
                path = [path stringByAppendingPathExtension:extension];
            }
            return path;
        }
    }
    return self;
}

@end