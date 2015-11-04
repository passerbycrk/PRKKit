//
//  NSData+.h
//  Utility
//
//  Created by iwill on 2014-06-19.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSData (NSString)

+ (instancetype)dataWithString:(NSString *)string encoding:(NSStringEncoding)encoding;
+ (instancetype)dataWithString:(NSString *)string encoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)lossy;

@end

#pragma mark - NSData+Base64

@interface NSData (Base64)

+ (instancetype)dataWithBase64String:(NSString *)base64String;

@end

#pragma mark - NSData+UIImage

@interface NSData (UIImage)

+ (instancetype)dataWithPNGImage:(UIImage *)image;
+ (instancetype)dataWithJPGImage:(UIImage *)image quality:(CGFloat)quality;

@end
