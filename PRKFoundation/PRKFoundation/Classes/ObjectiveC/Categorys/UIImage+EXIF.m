//
//  UIImage+EXIF.m
//  CameraKit
//
//  Created by Kai on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImage+EXIF.h"
#import <ImageIO/ImageIO.h>


@implementation UIImage (EXIF)

- (NSData *)imageDataWithCompressionQuality:(CGFloat)compressionQuality metadata:(NSDictionary *)metadata
{
	// Get the original image data by converting UIImage to JPEG with a specific compression quality.
	NSData *imageData = UIImageJPEGRepresentation(self, compressionQuality);
	
	// If image has no CGImageRef or invalid bitmap format, return nil.
	if (imageData == nil)
	{
		return nil;
	}
	
	// If the ImageIO is not available, just return the image data without any change.
	if (&CGImageSourceCreateWithData == NULL)
	{
		return imageData;
	}
		
	return [[self class] taggedImageDataWithImageData:imageData properties:metadata];
}

+ (NSData *)taggedImageDataWithImageData:(NSData *)imageData properties:(NSDictionary *)properties
{
	NSMutableData *mutableImageData = [[NSMutableData alloc] init];
	
	CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
	
	CGImageDestinationRef imageDestinationRef = CGImageDestinationCreateWithData((CFMutableDataRef)mutableImageData, CGImageSourceGetType(imageSourceRef), 1, NULL);
	CGImageDestinationAddImageFromSource(imageDestinationRef, imageSourceRef, 0, (CFDictionaryRef)properties);
	CGImageDestinationFinalize(imageDestinationRef);
	CFRelease(imageDestinationRef);
	
	CFRelease(imageSourceRef);
	
	return mutableImageData;
}

- (UIImage *)fixOrientation
{
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
//
//void CKImageWriteToSavedPhotosAlbum(UIImage *image, CKImageMetadata *metadata)
//{
//	// 如果支持Assets, 则使用Assets.
//	Class ALAssetsLibraryClass = NSClassFromString(@"ALAssetsLibrary");
//	if (ALAssetsLibraryClass)
//	{
//		ALAssetsLibrary *assetsLibrary = [[[ALAssetsLibrary alloc] init] autorelease];
//		
//		if (&UIImagePickerControllerMediaMetadata != nil && [assetsLibrary respondsToSelector:@selector(writeImageToSavedPhotosAlbum:metadata:completionBlock:)])
//		{
//			// 如果支持存储metadata, 则存储. 4.1及以上支持.
//			[assetsLibrary writeImageToSavedPhotosAlbum:[image CGImage] 
//											   metadata:[metadata EXIFRepresentation] 
//										completionBlock:^(NSURL *assetURL, NSError *error) {
//											
//										}];
//		}
//		else if ([assetsLibrary respondsToSelector:@selector(writeImageToSavedPhotosAlbum:orientation:completionBlock:)])
//		{
//			// 如果不支持存储metadata, 则只存储图片和方向. 4.0及以上支持.
//			[assetsLibrary writeImageToSavedPhotosAlbum:[image CGImage] 
//											orientation:(ALAssetOrientation)[image imageOrientation] 
//										completionBlock:^(NSURL *assetURL, NSError *error) {
//											
//										}];
//		}
//	}
//	else
//	{
//		UIImageWriteToSavedPhotosAlbum(image, NULL, NULL, NULL);
//	}
//}