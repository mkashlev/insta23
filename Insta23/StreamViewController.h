//
//  StreamViewController.h
//  Insta23
//
//  Created by Dmitry Kashlev on 11/5/17.
//  Copyright © 2017 Dmitry Kashlev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Api.h"
#import "LoginViewController.h"
#import "StreamTableViewCell.h"
#import <AFNetworking/AFNetworking.h>
#import "UIImageView+AFNetworking.h"



@interface StreamViewController : UITableViewController<UITableViewDelegate,UITableViewDataSource>

@end
