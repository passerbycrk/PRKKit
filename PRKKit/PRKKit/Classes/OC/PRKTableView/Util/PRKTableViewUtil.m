//
//  PRKTableViewUtil.m
//  PRKTableView
//
//  Created by passerbycrk on 15/9/10.
//  Copyright (c) 2015年 prk. All rights reserved.
//

#import "PRKTableViewUtil.h"

@implementation PRKTableViewUtil

+ (CGSize)contentString:(NSString *)contentString
           sizeWithFont:(UIFont *)font {
    CGSize reSize = CGSizeZero;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    reSize = [contentString sizeWithAttributes:@{ NSFontAttributeName: font }];
#else
    reSize = [contentString sizeWithFont:font];
#endif
    return CGSizeMake(ceil(reSize.width), ceil(reSize.height));
}

+ (CGSize)contentString:(NSString *)contentString
           sizeWithFont:(UIFont *)font
      constrainedToSize:(CGSize)size
          lineBreakMode:(NSLineBreakMode)lineBreakMode
              alignment:(NSTextAlignment)alignment {
    CGSize reSize = CGSizeZero;
    if (contentString.length > 0) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = lineBreakMode;
        paragraph.alignment = alignment;
        
        NSAttributedString *attributeText = [[NSAttributedString alloc] initWithString:contentString
                                                                            attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraph}];
        CGSize labelsize = [attributeText boundingRectWithSize:size
                                                       options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        reSize = CGSizeMake(ceilf(labelsize.width), ceilf(labelsize.height));
#else
        reSize = [contentString sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#endif
    }
    return CGSizeMake(ceil(reSize.width), ceil(reSize.height));
}

@end
