//
//  LoginViewController.h
//  Insta23
//
//  Created by Dmitry Kashlev on 11/5/17.
//  Copyright © 2017 Dmitry Kashlev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Api.h"
#import "StreamViewController.h"
#import "Constants.h"

@interface LoginViewController : UIViewController<UIWebViewDelegate>
{
    UIWebView *loginScreen;
}
@property (strong, nonatomic) UILabel *loginStatus;
@end
