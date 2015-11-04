//
//  UIImage+EXIF.h
//  CameraKit
//
//  Created by Kai on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CLLocation;

/**
 *  @ingroup CameraKit
 */
@interface UIImage (EXIF)

/**
 * 	将 UIImage 转换成NSData.
 * 	
 * 	@param compressionQuality 压缩比例. 范围从0到1, 图片质量从低到高.
 * 	@param metadata 图片的EXIF信息.
 * 	@returns 转换之后带EXIF信息的 NSData.
 *  @attention EXIF信息中图片的方向会被改写为 UIImage 的方向, 以防止错误的方向信息.
 */
- (NSData *)imageDataWithCompressionQuality:(CGFloat)compressionQuality metadata:(NSDictionary *)metadata;

/**
 * 	将图片的 NSData 中附加EXIF信息.
 * 	
 * 	@param imageData 已经转换成 NSData 的图片.
 * 	@param properties 图片的EXIF, GPS等信息. 字典里的键遵循 ImageIO 中的定义.
 * 	@returns 附加EXIF信息的 NSData.
 */
+ (NSData *)taggedImageDataWithImageData:(NSData *)imageData properties:(NSDictionary *)properties;

- (UIImage *)fixOrientation;

@end

/**
 *  @ingroup CameraKit
 *  
 * 	将图片存入系统的用户相册中. 此方法适用于用户在程序内拍照后, 存入相册的操作.
 * 	
 * 	@param image 要存入相册的 UIImage.
 * 	@param metadata 图片的EXIF等信息.
 */
//extern void CKImageWriteToSavedPhotosAlbum(UIImage *image, CKImageMetadata *metadata);
