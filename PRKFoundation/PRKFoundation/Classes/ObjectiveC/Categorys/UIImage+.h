//
//  UIImage+.h
//  iM9
//
//  Created by iwill on 2011-06-20.
//  Copyright 2011 M9. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (M9Category)

+ (UIImage*)imageWithPureColorBackgroundImage:(CGColorRef)color withSize:(CGSize)size;

- (UIImage *)resizableImage;

- (UIImage *)imageByResizing:(CGSize)size;
- (UIImage *)imageByZooming:(CGFloat)zoom;
+ (UIImage *)imageWithImage:(UIImage *)image size:(CGSize)size;
+ (UIImage *)imageWithImage:(UIImage *)image zoom:(CGFloat)zoom;

- (UIImage *)imageByRotateRadians:(CGFloat)radians;
- (UIImage *)imageByRotateRadians:(CGFloat)radians size:(CGSize)size;
- (UIImage *)imageByRotateDegrees:(CGFloat)degrees;
- (UIImage *)imageByRotateDegrees:(CGFloat)degrees size:(CGSize)size;
+ (UIImage *)imageWithImage:(UIImage *)image rotateRadians:(CGFloat)radians;
+ (UIImage *)imageWithImage:(UIImage *)image rotateRadians:(CGFloat)radians size:(CGSize)size;
+ (UIImage *)imageWithImage:(UIImage *)image rotateDegrees:(CGFloat)degrees;
+ (UIImage *)imageWithImage:(UIImage *)image rotateDegrees:(CGFloat)degrees size:(CGSize)size;

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/*!
 *  生成并返回一个根据指定尺寸裁剪的UIImage对象
 *
 *  @param bounds 要裁剪图片的大小
 *
 *  @return 裁剪后的UIImage对象
 */
- (UIImage *)croppedImage:(CGRect)bounds;
- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;


#if !APP_EXTENSION
+ (UIImage *)screenshot;
#endif

@end

#pragma mark - UIImage+Base64

@interface UIImage (Base64)

+ (instancetype)imageWithBase64String:(NSString *)base64String;

@end

#pragma mark - UIImageView+M9Category

@interface UIImageView (M9Category)

+ (instancetype)imageViewWithImageNamed:(NSString *)imageName;

@end
