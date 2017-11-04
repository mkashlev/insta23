//
//  AppDelegate.h
//  Insta23
//
//  Created by Dmitry Kashlev on 11/3/17.
//  Copyright © 2017 Dmitry Kashlev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

