//
//  ParseDataManager.m
//  Migo
//
//  Created by Victoria Xiao on 2016-04-22.
//  Copyright © 2016 My Majesty Productions. All rights reserved.
//

#import "ParseDataManager.h"
#import "MapViewController.h"
#import <Foundation/Foundation.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <MapKit/MapKit.h>

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
    return [PFUser currentUser] != nil;
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
                                                        [self setUpNewUser:user];
                                                        [[vc presentingViewController] dismissViewControllerAnimated:YES completion:nil];
                                                    } else {
                                                       // NSLog(@"User logged in through Facebook!");
                                                        [[vc presentingViewController] dismissViewControllerAnimated:YES completion:nil];
                                                    }
                                                }];
}

-(void)setUpNewUser:(PFUser *) user {
    [user setObject:@0 forKey:@"wins"];
    [user setObject:@0 forKey:@"losses"];
    [user setObject:@0 forKey:@"ties"];
    [user setObject:@"N" forKey:@"status"];
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"name"}];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSDictionary *data = (NSDictionary *)result;
            NSLog(@"fb request is called");
            NSLog(@"name:%@", data[@"name"]);
            [user setObject:data[@"name"] forKey:@"fbName"];
        } else {
            NSLog(@"%@", error);
        }
        [user save];
    }];
}

-(void) fbLogout {
    [PFUser logOutInBackground];
    [[FBSDKLoginManager new] logOut];
}

/** METHODS THAT HAVE TO DEAL WITH USERS **/

-(void)changeStatusToSeeking:(PFUser *) user {
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(backgroundQueue, ^{
        //change user's status
        [user setObject:@"S" forKey:@"status"];
        [user save];
        
        //add user to "seekingUsers" database
        PFObject *sUser = [PFObject objectWithClassName:@"SeekingUsers"];
        [sUser setObject:[PFUser currentUser] forKey:@"user"];
        [sUser save];
        //NSLog(@"%@ logged as seeking game", [user objectId]);
    });
}

-(void)changeLocationOfUser:(PFUser *)user
               WithLatitude:(NSNumber *)latitude
              WithLongitude:(NSNumber *)longitude {
    //store current location
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(backgroundQueue, ^{
        [user setObject:latitude forKey:@"latitude"];
        [user setObject:longitude forKey:@"longitude"];
        [user save];
    });
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


//draws a pin for all seeking users on the sender VC
-(void)drawPinForUser:(PFUser *)user
                                 sender:(MapViewController *)vc {
    __block CLLocationCoordinate2D co;
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query getObjectInBackgroundWithId:user.objectId block:^(PFObject *userOb, NSError *error) {
        NSLog(@"getCoordinate called with user %@", [user objectId]);
        NSLog(@"latitude: %@", [userOb objectForKey:@"latitude"]);
        NSLog(@"longitude: %@", [userOb objectForKey:@"longitude"]);
        co = CLLocationCoordinate2DMake  ([[userOb objectForKey:@"latitude"] doubleValue], [[userOb objectForKey:@"longitude"] doubleValue]);
        [vc drawPins:co
            WithUser:userOb
            withName:[userOb objectForKey:@"fbName"]];
    }];
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
