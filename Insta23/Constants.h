//
//  Constants.h
//  Insta23
//
//  Created by Dmitry Kashlev on 11/5/17.
//  Copyright © 2017 Dmitry Kashlev. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

//Instagram-soecific constants
#define BASE_URL @"https://api.instagram.com"
#define CLIENT_ID @"0637825256de4d9e9c969ec594b032c8"
#define REDIRECT_URI @"https://www.23andme.com"
#define INSTAGRAM_SCOPE @"public_content+likes"

//UI Constants
#define kCELL_ID @"StreamItem"

//NotificationCenter constants
#define NC_LOGOUT_SIGNAL @"logout"
#define NC_STREAM_LOADED_SIGNAL @"stream_loaded_from_api"
#define NC_LIKES_LOADED_SIGNAL @"likes_loaded_from_api"
#define NC_USER_INFO_LOADED_SIGNAL @"user_info_loaded_from_api"

//Auth constants
#define AUTH_AUTHENTICATED @"authenticated"
#define AUTH_AUTHORIZED @"authorized"

#endif /* Constants_h */
