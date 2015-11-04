//
//  PRKTableViewUtil.h
//  PRKTableView
//
//  Created by passerbycrk on 15/9/10.
//  Copyright (c) 2015年 prk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PRKTableViewUtil : NSObject

+ (CGSize)contentString:(NSString *)contentString
           sizeWithFont:(UIFont *)font;

+ (CGSize)contentString:(NSString *)contentString
           sizeWithFont:(UIFont *)font
      constrainedToSize:(CGSize)size
          lineBreakMode:(NSLineBreakMode)lineBreakMode
              alignment:(NSTextAlignment)alignment;

@end
