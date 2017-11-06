//
//  LoginViewController.m
//  Insta23
//
//  Created by Dmitry Kashlev on 11/5/17.
//  Copyright © 2017 Dmitry Kashlev. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogout:) name:NC_LOGOUT_SIGNAL object:nil];
    }
    return self;
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NC_LOGOUT_SIGNAL object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self setTitle:@"Instagram Login"];
    
    NSInteger offsetX = 10;
    NSInteger offsetY = 100;
    NSInteger defaultWidth = self.view.bounds.size.width-(offsetX*2);
    
    self.loginStatus = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, offsetY, defaultWidth, 50)];
    if ([[Api client] isLoggedIn]) {
        [self.loginStatus setText:@"Logged in!"];
    } else {
        [self.loginStatus setText:@"Not Logged in!"];
    }
    [self.view addSubview:self.loginStatus];
    offsetY += (self.loginStatus.frame.size.height+20);
    
    if ([[Api client] isLoggedIn]) {
        UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        logoutButton.frame = CGRectMake(offsetX, offsetY, defaultWidth, 50);
        [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
        [logoutButton addTarget:self action:@selector(handleLogout:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:logoutButton];
        offsetY += (logoutButton.frame.size.height + 20);
    }
    else {
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        loginButton.frame = CGRectMake(offsetX, offsetY, defaultWidth, 50);
        [loginButton setTitle:@"Login" forState:UIControlStateNormal];
        [loginButton addTarget:self action:@selector(displayLoginView:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:loginButton];
        offsetY += (loginButton.frame.size.height + 20);
    }
    
    
    
}

//DELEGATE HANDLERS
//Presents Instagram's Login screen in a web view
- (IBAction)displayLoginView:(id)sender {
    loginScreen = [[UIWebView alloc] initWithFrame:self.view.frame];
    [loginScreen loadRequest:[[Api client] createAuthRequest]];
    [loginScreen setDelegate:self];
    [self.view addSubview:loginScreen];
}

//handles logic for logout button (not used)
- (IBAction)handleLogout:(id)sender {
    [[Api client] logout];
    [self.loginStatus setText:@"Not Logged in..."];
}

//handles callback from instagram API on login.
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *val = [[Api client] checkRequestForCallbackURL:request];
    StreamViewController *streamVC = [[StreamViewController alloc] init];
    if ([val isEqualToString:AUTH_AUTHENTICATED]) {
        [self.loginStatus setText:@"Logged In!"];
        [self.navigationController pushViewController:streamVC animated:NO];
        [loginScreen removeFromSuperview];
    } else if ([val isEqualToString:AUTH_AUTHORIZED]) {
        [loginScreen removeFromSuperview];
        [self.navigationController pushViewController:streamVC animated:NO];
    }
    return [val isEqualToString:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
