//
//  ParseDataManager.m
//  Migo
//
//  Created by Victoria Xiao on 2016-04-22.
//  Copyright © 2016 My Majesty Productions. All rights reserved.
//

#import "ParseDataManager.h"
#import <Foundation/Foundation.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

#import <Parse/Parse.h>

@interface ParseDataManager()

@end
@implementation ParseDataManager

+ (ParseDataManager *)sharedManager {
    static ParseDataManager *obj;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        obj = [[ParseDataManager alloc] init];
    });
    return obj;
}

/** METHODS THAT HAVE TO DO WITH LOGGING INTO FB **/

- (BOOL)isUserLoggedIn {
    return [[PFUser currentUser] isAuthenticated];
}

-(void) fbLoginWithToken: (FBSDKAccessToken *) token
    withViewController:(UIViewController *)vc {
    [PFFacebookUtils logInInBackgroundWithAccessToken:token
                                                block:^(PFUser *user, NSError *error) {
                                                    if (!user) {
                                                        //NSLog(@"Uh oh. The user cancelled the Facebook login.");
                                                    } else if (user.isNew) {
                                                        //NSLog(@"User signed up and logged in through Facebook!");
                                                        
                                                        //setup new user
                                                        [user setObject:@0 forKey:@"wins"];
                                                        [user setObject:@0 forKey:@"losses"];
                                                        [user setObject:@0 forKey:@"ties"];
                                                        [user setObject:@"N" forKey:@"status"];
                                                        [user save];
                                                        [[vc presentingViewController] dismissViewControllerAnimated:YES completion:nil];
                                                    } else {
                                                       // NSLog(@"User logged in through Facebook!");
                                                        [[vc presentingViewController] dismissViewControllerAnimated:YES completion:nil];
                                                    }
                                                }];
}

-(void) fbLogout {
    [PFUser logOutInBackground];
    [[FBSDKLoginManager new] logOut];
}

/** METHODS THAT HAVE TO DEAL WITH USERS **/

-(void)changeStatusToSeeking:(PFUser *) user {
    //change user's status
    [user setObject:@"S" forKey:@"status"];
    [user save];
    
    //add user to "seekingUsers" database
    PFObject *sUser = [PFObject objectWithClassName:@"SeekingUsers"];
    [sUser setObject:[PFUser currentUser] forKey:@"user"];
    [sUser save];
    //NSLog(@"%@ logged as seeking game", [user objectId]);
}

-(void)changeLocationOfUser:(PFUser *)user
               WithLatitude:(NSNumber *)latitude
              WithLongitude:(NSNumber *)longitude {
    //store current location
    [user setObject:latitude forKey:@"latitude"];
    [user setObject:longitude forKey:@"longitude"];
    //NSLog(@"%@ latitude:%@, longitude:%@", [user objectId], latitude, longitude);
    [user save];
}

-(NSString *)getStatusOfUser:(PFUser *) user {
    return [user objectForKey:@"status"];
}

/** METHODS THAT DEAL WITH SEEKINGUSERS CLASS **/
-(void)loadSeekingUsersWithCallback:(void (^)(NSMutableArray *))callback {
    [[PFQuery queryWithClassName:@"SeekingUsers"] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            callback([objects mutableCopy]);
        }

    }];
}

-(PFUser *)getUserFromSeekingUser:(PFObject *) su{
    return [su objectForKey:@"user"];
}

-(NSNumber *)getLatitudeOfUser:(PFUser *)user {
    return [user objectForKey:@"latitude"];
}

-(NSNumber *)getLongitudeOfUser:(PFUser *)user {
    return [user objectForKey:@"longitude"];
}



/**
-(void)loadSeekingUsersWithCallback:(void (^)(NSMutableArray *))callback {
    [[PFQuery queryWithClassName:@"SeekingUsers"] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            NSLog(@"SeekingUsers array found");
            NSMutableArray *userArray = [[NSMutableArray alloc] init];
            for (PFObject *ob in objects) {
                NSLog(@"%@ added to userArray", [ob objectId]);
                [userArray addObject:[ob objectForKey:@"user"]];
            }
            
            for (PFObject *ob in userArray) {
                NSLog(@"%@ found in userArray", [ob objectId]);
            }
            
            callback([userArray mutableCopy]); 
        }
    }];
} **/
     
@end
