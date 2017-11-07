//
//  StreamTableViewCell.m
//  Insta23
//
//  Created by Dmitry Kashlev on 11/5/17.
//  Copyright © 2017 Dmitry Kashlev. All rights reserved.
//

#import "StreamTableViewCell.h"

@implementation StreamTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    NSLog(@"INIT CELL");
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        NSInteger offsetY = 0;
        NSInteger buttonWidth = 80;
        NSInteger infoHeight = 50;
        
        //Poster info view
        self.posterInfoBar = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, self.frame.size.width, infoHeight)];
        [self.posterInfoBar setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.posterInfoBar];
        offsetY += infoHeight;
        //user avatar
        self.userAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, 40, 40)];
        [self.userAvatar setBackgroundColor:[UIColor whiteColor]];
        self.userAvatar.layer.cornerRadius = 20;
        self.userAvatar.layer.masksToBounds = YES;
        [self.posterInfoBar addSubview:_userAvatar];
        //username
        self.userName = [[UILabel alloc] initWithFrame:CGRectMake(70, 5, self.frame.size.width-70, 40)];
        [self.posterInfoBar addSubview:self.userName];
        
        //Post Image
        self.thumb = [[UIImageView alloc] initWithFrame:CGRectMake(0, offsetY, self.frame.size.width, self.frame.size.width)];
        self.thumb.image = [UIImage imageNamed:@"placeholder"];
        [self.contentView addSubview:self.thumb];
        offsetY += self.contentView.frame.size.width;
        
        //Like button
        self.likeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, offsetY, buttonWidth, infoHeight)];
        [self.likeBtn setTitle:@"Like" forState:UIControlStateNormal];
        [self.likeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.likeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        
        //UnLike button
        self.unlikeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, offsetY, buttonWidth, infoHeight)];
        [self.unlikeBtn setTitle:@"Unlike" forState:UIControlStateNormal];
        [self.unlikeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.unlikeBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        
        //spinner
        self.spinner = [[UILabel alloc] init];
        [self.spinner setText:@"..."];
        self.spinner.frame = CGRectMake(self.frame.size.width-60, offsetY+5, 40, 40);
        
        //info such as status of like
        self.info = [[UILabel alloc] initWithFrame:CGRectMake(20, offsetY, self.frame.size.width-buttonWidth, infoHeight)];
        [self.info setText:@"placeholder..."];
        [self.contentView addSubview:self.info];
        offsetY += infoHeight;
    }
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
