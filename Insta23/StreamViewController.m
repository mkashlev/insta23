//
//  StreamViewController.m
//  Insta23
//
//  Created by Dmitry Kashlev on 11/5/17.
//  Copyright © 2017 Dmitry Kashlev. All rights reserved.
//

#import "StreamViewController.h"


@interface StreamViewController ()
{
    NSArray *stream;
    NSDictionary *likes;
}
@end

@implementation StreamViewController

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadStream:) name:NC_STREAM_LOADED_SIGNAL object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLike:) name:NC_LIKES_LOADED_SIGNAL object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogout:) name:NC_LOGOUT_SIGNAL object:nil];
    }
    return self;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NC_STREAM_LOADED_SIGNAL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NC_LIKES_LOADED_SIGNAL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NC_LOGOUT_SIGNAL object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // General TableView setup
    [self.tableView registerClass:[StreamTableViewCell class] forCellReuseIdentifier:kCELL_ID];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self setTitle:@"Your Stream"];
    
    //Delegate and datasource setup
    stream = [[Api client] getStream];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Navbar setup
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"LOG OUT"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(handleLogout:)];
    self.navigationItem.rightBarButtonItem = logoutButton;
}


/*
 * TableView setup methods
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[Api client] getStream] count];
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
}



/**
 * Methods for populating Cells with data
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StreamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCELL_ID forIndexPath:indexPath];
    [self setUpCell:cell atIndexPath:indexPath];
    return cell;
}
- (void)setUpCell:(StreamTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    // get image info (size, url, etc...)
    NSString *mediaId = [[stream objectAtIndex:indexPath.row] objectForKey:@"id"];
    NSDictionary *images = [[stream objectAtIndex:indexPath.row] objectForKey:@"images"];
    NSDictionary *imgInfo = [images objectForKey:@"standard_resolution"];
    NSString *ImageURL = [imgInfo objectForKey:@"url"];
    CGFloat imgWidth = [[imgInfo objectForKey:@"width"] floatValue];
    CGFloat imgHeight = [[imgInfo objectForKey:@"height"] floatValue];
    NSDictionary *userData = [[stream objectAtIndex:indexPath.row] objectForKey:@"user"];
    NSString *userAvatarUrlStr = [userData objectForKey:@"profile_picture"];
    NSString *userNameStr = [userData objectForKey:@"username"];
    
    CGFloat screenwidth = self.tableView.frame.size.width;
    CGRect cellframe = cell.frame;
    cellframe.size.width = screenwidth;
    [cell setFrame:cellframe];
    
    // set poster info data
    CGRect userframe = cell.posterInfoBar.frame;
    userframe.size.width = screenwidth;
    userframe.size.height = 50;
    [cell.posterInfoBar setFrame:userframe];
    [cell.userAvatar setImageWithURL:[NSURL URLWithString:userAvatarUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    [cell.userName setText:userNameStr];
    
    // set image data
    [cell.thumb setImageWithURL:[NSURL URLWithString:ImageURL] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    CGRect imgframe = cell.thumb.frame;
    
    CGFloat height = imgHeight*screenwidth/imgWidth;
    //imgframe.origin.y = 0;
    imgframe.size.width = screenwidth;
    imgframe.size.height = height;
    [cell.thumb setFrame:imgframe];
    
    //set button
    CGRect btnframe = cell.likeBtn.frame;
    btnframe.origin.y = height+userframe.size.height;
    btnframe.origin.x = screenwidth-100;
//    btnframe.size.width = 80;
//    btnframe.size.height = 50;
    [cell.likeBtn setFrame:btnframe];
    [cell.unlikeBtn setFrame:btnframe];
    [cell.likeBtn addTarget:self action:@selector(doLike:) forControlEvents:UIControlEventTouchUpInside];
    [cell.unlikeBtn addTarget:self action:@selector(doUnlike:) forControlEvents:UIControlEventTouchUpInside];
    
    // set info label
    CGRect infoframe = cell.info.frame;
    infoframe.origin.y = height+userframe.size.height;
    infoframe.size.width = screenwidth-100;
    [cell.info setFrame:infoframe];
    NSArray *likesForMedia = [likes objectForKey:mediaId];
    BOOL youDidLike = NO;
    for (NSDictionary *like in likesForMedia) {
        if (like && [[like objectForKey:@"id"] isEqualToString:[[[Api client] getUser] objectForKey:@"id"]]) {
            youDidLike = YES;
            break;
        }
    }
    if (youDidLike) {
        [cell.info setText:@"Liked by You"];
        [cell.likeBtn removeFromSuperview];
        [cell.contentView addSubview:cell.unlikeBtn];
    } else {
        [cell.info setText:@"No Likes"];
        [cell.unlikeBtn removeFromSuperview];
        [cell.contentView addSubview:cell.likeBtn];
    }
    
}
- (IBAction)reloadStream:(id)sender {
    stream = [[Api client] getStream];
    likes = [[Api client] getLikes];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
- (IBAction)reloadLike:(NSNotification *)notification {
    likes = [[Api client] getLikes];
    NSString *mediaId = [notification.userInfo objectForKey:@"media_id"];
    //instead of updating every cell, only update one cell
    BOOL found = NO;
    int ind = 0;
    for (NSDictionary *itm in stream) {
        if ([[itm objectForKey:@"id"] isEqualToString:mediaId]) {
            found = YES;
            break;
        }
        ind += 1;
    }
    NSLog(@"UPDATING LIKES");
    if (found) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            NSIndexPath *ip = [NSIndexPath indexPathForRow:ind inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            //[self.tableView reloadData];
        });
    }
}





//HEIGHT calculation methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static StreamTableViewCell *cell = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:kCELL_ID];
        [cell setUserInteractionEnabled:YES];
    });
    
    [self setUpCell:cell atIndexPath:indexPath];
    
    return [self calculateHeightForConfiguredSizingCell:cell];
}
- (CGFloat)calculateHeightForConfiguredSizingCell:(StreamTableViewCell *)sizingCell {
    //[sizingCell layoutIfNeeded];
    CGFloat ht = sizingCell.posterInfoBar.frame.size.height + sizingCell.thumb.frame.size.height + sizingCell.info.frame.size.height;
    return ht;
}


// Like/Unlike/Logout action handlers
- (IBAction)doLike:(id)sender {
    NSLog(@"clicked like");
    CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonOriginInTableView];
    NSString *imgid = [[stream objectAtIndex:indexPath.row] objectForKey:@"id"];
    [[Api client] performLikeOn:imgid];
}
- (IBAction)doUnlike:(id)sender {
    NSLog(@"clicked unlike");
    CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonOriginInTableView];
    NSString *imgid = [[stream objectAtIndex:indexPath.row] objectForKey:@"id"];
    [[Api client] performUnlikeOn:imgid];
}
- (IBAction)handleLogout:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[Api client] logout];
        [self.navigationController popViewControllerAnimated:NO];
    });
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
