//
//  BlackjackDataManager.h
//  Migo
//
//  Created by Victoria Xiao on 2016-04-28.
//  Copyright © 2016 My Majesty Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapViewController.h"

@protocol BlackjackDataManagerDelegate <NSObject>

- (void)gameDidLoad:(PFObject *)gOb;
- (void)endTurn;
- (void)displayWinner:(NSString *) str;
-(void) displayCard:(NSString *) card
             ForTag:(int) tag;
@end

@interface BlackjackDataManager : NSObject
@property (strong, nonatomic) id<BlackjackDataManagerDelegate> delegate;

-(id) initWithSender:(id<BlackjackDataManagerDelegate>)vc;
- (void) gameWithHost:(PFUser *)host
            WithGuest:(PFUser *)guest;
- (void)getGameWithGuest:(PFUser *) guest;
- (void)getGameWithHost:(PFUser *) host
              WithGuest:(PFUser *) guest;
- (NSString *)currentTurn;
-(void)dealCardToUser:(NSString *) str;
-(void)standUser:(NSString *) str;
-(void)endTurn:(NSString *) str;
-(void)standingCheck:(NSString *) str;
-(void)didExceed21:(NSString *) str;
-(void)gameOver;
-(void) displayCardBacks:(NSString *) str;
@end
