//
//  UIViewController+MessageUI.m
//  Utility
//
//  Created by iwill on 2013-05-10.
//
//

#if ! __has_feature(objc_arc)
// set -fobjc-arc flag: - Target > Build Phases > Compile Sources > implementation.m + -fobjc-arc
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

#import "UIViewController+MessageUI.h"

#define MessageUIAnimationDelay 0.5

@implementation UIViewController (MessageUI)

- (void)presentViewControllerAnimated:(UIViewController *)viewController {
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else {
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (void)dismissViewControllerAnimated {
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)sendMailToRecipients:(NSArray *)recipients subject:(NSString *)subject body:(NSString *)body {
    [MFMailComposeViewController sendMailToRecipients:recipients
                                              subject:subject
                                                 body:body
                                   fromViewController:self];
}

- (void)sendMailToRecipients:(NSArray *)recipients subject:(NSString *)subject body:(NSString *)body setting:(SendMailSetting)setting {
    [MFMailComposeViewController sendMailToRecipients:recipients
                                              subject:subject
                                                 body:body
                                   fromViewController:self
                                              setting:setting];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self performSelector:@selector(dismissViewControllerAnimated) withObject:nil afterDelay:MessageUIAnimationDelay];
}

- (void)sendMessageToRecipients:(NSArray *)recipients message:(NSString *)message {
    [MFMessageComposeViewController sendMessageToRecipients:recipients
                                                    message:message
                                         fromViewController:self];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self performSelector:@selector(dismissViewControllerAnimated) withObject:nil afterDelay:MessageUIAnimationDelay];
}

@end

#pragma mark -

@implementation MFMailComposeViewController (SendMail)

+ (void)sendMailToRecipients:(NSArray *)recipients subject:(NSString *)subject body:(NSString *)body {
    [self sendMailToRecipients:recipients subject:subject body:body fromViewController:nil];
}

+ (void)sendMailToRecipients:(NSArray *)recipients subject:(NSString *)subject body:(NSString *)body fromViewController:(UIViewController *)viewController {
    [self sendMailToRecipients:recipients subject:subject body:body fromViewController:viewController setting:nil];
}

+ (void)sendMailToRecipients:(NSArray *)recipients subject:(NSString *)subject body:(NSString *)body fromViewController:(UIViewController *)viewController setting:(SendMailSetting)setting {
    subject = subject ? subject : @"";
    body = body ? body : @"";
    
    if (viewController && [MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        mailComposeViewController.mailComposeDelegate = viewController;
        [mailComposeViewController setToRecipients:recipients];
        [mailComposeViewController setSubject:subject];
        [mailComposeViewController setMessageBody:body isHTML:YES];
        if (setting) {
            setting(mailComposeViewController);
        }
        [viewController performSelector:@selector(presentViewControllerAnimated:)
                             withObject:mailComposeViewController
                             afterDelay:MessageUIAnimationDelay];
    }
    else {
        NSString *mailURLString = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@",
                                   [recipients componentsJoinedByString:@","],
                                   subject,
                                   body];
        mailURLString = [mailURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *mailURL = [NSURL URLWithString:mailURLString];
        [[UIApplication sharedApplication] openURL:mailURL];
    }
}

@end

#pragma mark -

@implementation MFMessageComposeViewController (SendMessage)

+ (void)sendMessageToRecipients:(NSArray *)recipients message:(NSString *)message fromViewController:(UIViewController *)viewController {
    if (viewController && [MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
        messageComposeViewController.messageComposeDelegate = viewController;
        messageComposeViewController.body = message;
        messageComposeViewController.recipients = recipients;
        [viewController performSelector:@selector(presentViewControllerAnimated:)
                             withObject:messageComposeViewController
                             afterDelay:MessageUIAnimationDelay];
    }
}

@end

