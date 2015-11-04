//
//  UIViewController+MessageUI.h
//  Utility
//
//  Created by iwill on 2013-05-10.
//
//

#import <UIKit/UIKit.h>

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>

// typedef void (^SendMailCallback)(MFMailComposeViewController *controller, MFMailComposeResult result, NSError *error);
typedef void (^SendMailSetting)(MFMailComposeViewController *controller);

@interface UIViewController (MessageUI) <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

- (void)sendMailToRecipients:(NSArray *)recipients subject:(NSString *)subject body:(NSString *)body;
- (void)sendMailToRecipients:(NSArray *)recipients subject:(NSString *)subject body:(NSString *)body setting:(SendMailSetting)setting;
- (void)sendMessageToRecipients:(NSArray *)recipients message:(NSString *)message;

@end

@interface MFMailComposeViewController (SendMail)

+ (void)sendMailToRecipients:(NSArray *)recipients subject:(NSString *)subject body:(NSString *)body;
+ (void)sendMailToRecipients:(NSArray *)recipients subject:(NSString *)subject body:(NSString *)body fromViewController:(UIViewController *)viewController;
+ (void)sendMailToRecipients:(NSArray *)recipients subject:(NSString *)subject body:(NSString *)body fromViewController:(UIViewController *)viewController setting:(SendMailSetting)setting;

@end

@interface MFMessageComposeViewController (SendMessage)

+ (void)sendMessageToRecipients:(NSArray *)recipients message:(NSString *)message fromViewController:(UIViewController *)viewController;

@end

