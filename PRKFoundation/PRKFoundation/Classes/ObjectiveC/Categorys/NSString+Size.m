//
//  NSString+Size.m
//  Passerbycrk
//
//  Created by zhongsheng on 15/3/18.
//  Copyright (c) 2015年 PlayPlus. All rights reserved.
//

#import "NSString+Size.h"

@implementation NSString (Size)

- (CGSize)stringSizeWithFont:(UIFont *)font
{
    CGSize reSize = CGSizeZero;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    reSize = [self sizeWithAttributes:@{ NSFontAttributeName: font }];
#else
    reSize = [self sizeWithFont:font];
#endif
    return CGSizeMake(ceil(reSize.width), ceil(reSize.height));
}

- (CGSize)sizeWithFont:(UIFont *)font
     constrainedToSize:(CGSize)size
         lineBreakMode:(NSLineBreakMode)lineBreakMode
             alignment:(NSTextAlignment)alignment
{
    CGSize reSize = CGSizeZero;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = lineBreakMode;
    paragraph.alignment = alignment;
    
    NSAttributedString *attributeText = [[NSAttributedString alloc] initWithString:self
                                                                        attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraph}];
    CGSize labelsize = [attributeText boundingRectWithSize:size
                                                   options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    reSize = CGSizeMake(ceilf(labelsize.width), ceilf(labelsize.height));
#else
    reSize = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#endif    
    return CGSizeMake(ceil(reSize.width), ceil(reSize.height));
}

@end
