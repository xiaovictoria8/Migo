//
//  ParseDataManager.h
//  Migo
//
//  Created by Victoria Xiao on 2016-04-22.
//  Copyright © 2016 My Majesty Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/Parse.h>
#import "MapViewController.h"

@interface ParseDataManager : NSObject

+ (ParseDataManager *)sharedManager;

/** METHODS THAT HAVE TO DO WITH LOGGING INTO FB **/
-(BOOL) isUserLoggedIn;
-(void)fbLoginWithToken: (FBSDKAccessToken *) token
     withViewController: (UIViewController *) vc;
-(void) fbLogout;

/** METHODS THAT HAVE TO DEAL WITH USERS **/
-(void)changeStatusToSeeking:(PFUser *) user;
-(NSString *)getStatusOfUser:(PFUser *) user;
-(void)changeLocationOfUser:(PFUser *) user
               WithLatitude:(NSNumber *) latitude
              WithLongitude:(NSNumber *)longitude;

/** METHODS THAT DEAL WITH SEEKINGUSERS CLASS **/
-(void)loadSeekingUsersWithCallback:(void (^)(NSMutableArray *))callback;
-(PFUser *)getUserFromSeekingUser:(PFObject *) su;
-(void)drawPinForUser:(PFUser *)user
               sender:(MapViewController *)vc;


@end
