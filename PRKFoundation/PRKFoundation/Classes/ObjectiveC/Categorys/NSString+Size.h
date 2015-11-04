//
//  NSString+Size.h
//  Passerbycrk
//
//  Created by zhongsheng on 15/3/18.
//  Copyright (c) 2015年 PlayPlus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (Size)

- (CGSize)stringSizeWithFont:(UIFont *)font;

- (CGSize)sizeWithFont:(UIFont *)font
     constrainedToSize:(CGSize)size
         lineBreakMode:(NSLineBreakMode)lineBreakMode
             alignment:(NSTextAlignment)alignment;

@end
