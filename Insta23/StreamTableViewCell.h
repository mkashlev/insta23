//
//  StreamTableViewCell.h
//  Insta23
//
//  Created by Dmitry Kashlev on 11/5/17.
//  Copyright © 2017 Dmitry Kashlev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import <AFNetworking/AFNetworking.h>
#import "UIImageView+AFNetworking.h"

@interface StreamTableViewCell : UITableViewCell

@property(strong, nonatomic) UIView *posterInfoBar;
@property(strong, nonatomic) UIImageView *userAvatar;
@property(strong, nonatomic) UILabel *userName;
@property(strong, nonatomic) UIImageView *thumb;
@property(strong, nonatomic) UILabel *info;
@property(strong, nonatomic) UIButton *likeBtn;
@property(strong, nonatomic) UIButton *unlikeBtn;
@property(strong, nonatomic) UILabel *spinner;

@end
