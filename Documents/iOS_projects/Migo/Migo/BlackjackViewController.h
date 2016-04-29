//
//  BlackjackViewController.h
//  Migo
//
//  Created by Victoria Xiao on 2016-04-28.
//  Copyright © 2016 My Majesty Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "BlackjackDataManager.h"

@interface BlackjackViewController : UIViewController <BlackjackDataManagerDelegate>
@property(strong, nonatomic) PFUser *host;
@property(strong, nonatomic) PFUser *guest;
@property (strong, nonatomic) PFObject *game;

-(void)gameDidLoad:(PFObject *) gOb;
- (void)endTurn;
- (void)displayWinner:(NSString *) str;
-(void) displayCard:(NSString *) card
             ForTag:(int) tag;


@end
