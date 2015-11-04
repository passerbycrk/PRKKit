//
//  UIImage+.m
//  iM9
//
//  Created by iwill on 2011-06-20.
//  Copyright 2011 M9. All rights reserved.
//

#if ! __has_feature(objc_arc)
// set -fobjc-arc flag: - Target > Build Phases > Compile Sources > implementation.m + -fobjc-arc
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

#import <QuartzCore/QuartzCore.h>

#import "UIImage+.h"
#import "NSData+.h"

static inline CGFloat DegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}

static inline CGFloat RadiansToDegrees(CGFloat radians) {
    return radians * 180 / M_PI;
}

@implementation UIImage (M9Category)

#pragma mark resizable image

+ (UIImage*)imageWithPureColorBackgroundImage:(CGColorRef)color withSize:(CGSize)size
{
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, size.width, size.height));
    
    
    // Build a context that's the same dimensions as the new size
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                8,
                                                newRect.size.width * 4,
                                                rgbColorSpace,					// CGImageGetColorSpace(imageRef)
                                                (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(rgbColorSpace);
    
    // Default white background color.
    CGRect rect = CGRectMake(0, 0, newRect.size.width, newRect.size.height);
    CGContextSetFillColorWithColor(bitmap, color);
    CGContextFillRect(bitmap, rect);
    
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}

// Returns a copy of this image that is cropped to the given bounds.
// The bounds will be adjusted using CGRectIntegral.
// This method ignores the image's imageOrientation setting.
- (UIImage *)croppedImage:(CGRect)bounds {
    bounds = CGRectMake(bounds.origin.x * self.scale, bounds.origin.y * self.scale, bounds.size.width * self.scale, bounds.size.height * self.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

// Returns a rescaled copy of the image, taking into account its orientation
// The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality {
    BOOL drawTransposed;
    
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
            
        default:
            drawTransposed = NO;
    }
    
    return [self resizedImage:newSize
                    transform:[self transformForOrientation:newSize]
               drawTransposed:drawTransposed
         interpolationQuality:quality];
}

// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
// If the new size is not integral, it will be rounded up
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                8,
                                                newRect.size.width * 4,
                                                rgbColorSpace,					// CGImageGetColorSpace(imageRef)
                                                (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    CGColorSpaceRelease(rgbColorSpace);
    
    // Default white background color.
    CGRect rect = CGRectMake(0, 0, newRect.size.width, newRect.size.height);
    CGContextSetRGBFillColor(bitmap, 1, 1, 1, 1);
    CGContextFillRect(bitmap, rect);
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}

// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
            
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        default:
            break;
    }
    
    return transform;
}

- (UIImage *)resizableImage {
    CGFloat x = MAX(self.size.width / 2, 0), y = MAX(self.size.height / 2, 0);
    
    if (![self respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        return [self stretchableImageWithLeftCapWidth:x topCapHeight:y];
    }
    
    return [self resizableImageWithCapInsets:UIEdgeInsetsMake(y, x, y, x)];
}

#pragma mark resize and zoom image

- (UIImage *)imageByResizing:(CGSize)size {
    return [UIImage imageWithImage:self size:size];
}

- (UIImage *)imageByZooming:(CGFloat)zoom {
    return [UIImage imageWithImage:self zoom:zoom];
}

+ (UIImage *)imageWithImage:(UIImage *)image size:(CGSize)size {
    if (!image) {
        return nil;
    }
    if (CGSizeEqualToSize(size, image.size)) {
        return [image copy];
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithImage:(UIImage *)image zoom:(CGFloat)zoom {
    return [self imageWithImage:image size:CGSizeMake(image.size.width * zoom, image.size.height * zoom)];
}

#pragma mark rotate image

- (UIImage *)imageByRotateRadians:(CGFloat)radians {
    return [self imageByRotateDegrees:RadiansToDegrees(radians)];
}

- (UIImage *)imageByRotateRadians:(CGFloat)radians size:(CGSize)size {
    return [self imageByRotateDegrees:RadiansToDegrees(radians) size:size];
}

- (UIImage *)imageByRotateDegrees:(CGFloat)degrees {
    return [self imageByRotateDegrees:degrees size:CGSizeZero];
}

- (UIImage *)imageByRotateDegrees:(CGFloat)degrees size:(CGSize)size {
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        UIView *rotatedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height)];
        CGAffineTransform transform = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
        rotatedView.transform = transform;
        size = rotatedView.frame.size;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 先上移一个图像高度，图像对y轴反转=>恢复成原图。
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1, -1);
    // 再设定坐标系原点到图片中心，进行旋转操作。
    CGContextTranslateCTM(context, size.width / 2, size.height / 2);
    CGContextRotateCTM(context, -DegreesToRadians(degrees)); // 这里也需要反向一次。
    CGContextDrawImage(context,
                       CGRectMake(- size.width / 2,
                                  - size.height / 2,
                                  size.width,
                                  size.height),
                       self.CGImage);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithImage:(UIImage *)image rotateRadians:(CGFloat)radians {
    return [image imageByRotateRadians:radians];
}

+ (UIImage *)imageWithImage:(UIImage *)image rotateRadians:(CGFloat)radians size:(CGSize)size {
    return [image imageByRotateRadians:radians size:size];
}

+ (UIImage *)imageWithImage:(UIImage *)image rotateDegrees:(CGFloat)degrees {
    return [image imageByRotateDegrees:degrees];
}

+ (UIImage *)imageWithImage:(UIImage *)image rotateDegrees:(CGFloat)degrees size:(CGSize)size {
    return [image imageByRotateDegrees:degrees size:size];
}

#pragma mark image with color

+ (UIImage *)imageWithColor:(UIColor *)color {
    return [[self imageWithColor:color size:CGSizeMake(1, 1)] resizableImage];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    color = color ? color : [UIColor clearColor];
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark screenshot image

#if !APP_EXTENSION
+ (UIImage *)screenshot {
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [UIScreen mainScreen].bounds.size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if (![window respondsToSelector:@selector(screen)] || window.screen == [UIScreen mainScreen]) {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, window.center.x, window.center.y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  - window.bounds.size.width * [window.layer anchorPoint].x,
                                  - window.bounds.size.height * [window.layer anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [window.layer renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}
#endif

@end

#pragma mark - UIImage+Base64

@implementation UIImage (Base64)

+ (instancetype)imageWithBase64String:(NSString *)base64String {
    return [self imageWithData:[NSData dataWithBase64String:base64String]];
}

@end

#pragma mark - UIImageView+M9Category

@implementation UIImageView (M9Category)

+ (instancetype)imageViewWithImageNamed:(NSString *)imageName {
    return [[self alloc] initWithImage:[UIImage imageNamed:imageName]];
}

@end
