//
//  BlackjackDataManager.m
//  Migo
//
//  Created by Victoria Xiao on 2016-04-28.
//  Copyright © 2016 My Majesty Productions. All rights reserved.
//

#import "ParseDataManager.h"
#import "BlackjackDataManager.h"


@interface BlackjackDataManager()

@property(strong, nonatomic) ParseDataManager *dataManager;
@property(strong, nonatomic) PFObject * game;
@end

@implementation BlackjackDataManager : NSObject

-(id) initWithSender:(id<BlackjackDataManagerDelegate>)vc {
    if (self = [super init]) {
        self.dataManager = [ParseDataManager sharedManager];
        self.delegate = vc;
    }
    return self;
}

//create new instance of game
- (void) gameWithHost:(PFUser *)host
            WithGuest:(PFUser *)guest {
    self.game = [PFObject objectWithClassName:@"Game"];
    
    //initialize players
    [self.game setObject:host forKey:@"host"];
    [self.game setObject:@"NO" forKey:@"hostStanding"];
    [self.game setObject:guest forKey:@"guest"];
    [self.game setObject:@"NO" forKey:@"guestStanding"];
    
    [self.game setObject:guest forKey:@"guest"];
    
    //initialize deck
    NSMutableArray *deck = [self newDeck];
    [self.game setObject:deck forKey:@"deck"];
    [self.game setObject:@4 forKey:@"top"];
    
    //initialize player hands
    NSMutableArray *hostHand = [[NSMutableArray alloc] init];
    [hostHand addObject:[deck objectAtIndex:0]];
    [hostHand addObject:[deck objectAtIndex:1]];
    int hostScore = [self cardValue:[deck objectAtIndex:0]] + [self cardValue:[deck objectAtIndex:1]];
    [self.delegate displayCard:[deck objectAtIndex:0] ForTag:1];
    [self.delegate displayCard:[deck objectAtIndex:1] ForTag:2];
    
    NSMutableArray *guestHand = [[NSMutableArray alloc] init];
    [guestHand addObject:[deck objectAtIndex:2]];
    [guestHand addObject:[deck objectAtIndex:3]];
    [self.delegate displayCard:@"back" ForTag:7];
    [self.delegate displayCard:@"back" ForTag:8];
    int guestScore = [self cardValue:[deck objectAtIndex:2]] + [self cardValue:[deck objectAtIndex:3]];
    
    //initialize player hands
    [self.game setObject:hostHand forKey:@"hostHand"];
    [self.game setObject:guestHand forKey:@"guestHand"];
    [self.game setObject:[NSNumber numberWithInt:hostScore] forKey:@"hostScore"];
    [self.game setObject:[NSNumber numberWithInt:guestScore] forKey:@"guestScore"];
    
    //initialize turn and winner
    [self.game setObject:@"H" forKey:@"curTurn"];
    [self.game setObject:@"N" forKey:@"winner"];
    
    //once saved, segue to appriopriate VC for game
    [self.game saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            //store changes in dataManager
            [self.dataManager addUser:[PFUser currentUser]
                               ToGame:self.game];
             
             //add guest to RequestingUsers table
             [self.dataManager addRequestingUser:guest
                                         ForGame:self.game];
            [self.delegate gameDidLoad:self.game];
        } else {
            // There was a problem, check error.description
        }
    }];
}

- (void)getGameWithGuest:(PFUser *) guest{
    PFQuery *query = [PFQuery queryWithClassName:@"Game"];
    NSLog(@"guest: %@", guest);
    [query whereKey:@"guest" equalTo:guest];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable game, NSError * _Nullable error) {
        if (!error) {
            self.game = game;
            NSArray *arr = [self.game objectForKey:@"guestHand"];
            int i = 1;
            for (NSString *card in arr) {
                [self.delegate displayCard:card
                                    ForTag:i++];
            }
            NSArray *arrB = [self.game objectForKey:@"hostHand"];
            i = 7;
            for (NSString *card in arrB) {
                [self.delegate displayCard:@"back"
                                    ForTag:i++];
            }
            [self.delegate gameDidLoad:self.game];
        }
    }];
}

- (void)getGameWithHost:(PFUser *) host
              WithGuest:(PFUser *) guest{
    PFQuery *query = [PFQuery queryWithClassName:@"Game"];
    NSLog(@"host: %@", host);
    [query whereKey:@"host" equalTo:host];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable game, NSError * _Nullable error) {
        if (!error) {
            self.game = game;
            NSArray *arr = [self.game objectForKey:@"hostHand"];
            int i = 1;
            for (NSString *card in arr) {
                [self.delegate displayCard:card
                                    ForTag:i++];
            }
            NSArray *arrB = [self.game objectForKey:@"guestHand"];
            i = 7;
            for (NSString *card in arrB) {
                [self.delegate displayCard:@"back"
                                    ForTag:i++];
            }
            [self.delegate gameDidLoad:self.game];
        } else {
            [self gameWithHost:host
                     WithGuest:guest];
        }
    }];
}

-(void)dealCardToUser:(NSString *) str{
    //retrieve deck from game
    NSMutableArray *deck = [self.game objectForKey:@"deck"];
    NSNumber *top = [self.game objectForKey:@"top"];
    
    NSMutableArray *hand;
    int score;
    //add top card to appriopriate user
    if ([str isEqualToString:@"H"] && [[self.game objectForKey:@"hostStanding"] isEqualToString:@"NO"]) {
        hand = [self.game objectForKey:@"hostHand"];
        score = [[self.game objectForKey:@"hostScore"] intValue];
    } else if ([str isEqualToString:@"G"] && [[self.game objectForKey:@"guest Standing"] isEqualToString:@"NO"]){
        hand = [self.game objectForKey:@"guestHand"];
        score = [[self.game objectForKey:@"guestScore"] intValue];
    } else {
        return;
    }
                                              
    NSLog(@"Drew card %@", [deck objectAtIndex:[top intValue]]);
    [hand addObject:[deck objectAtIndex:[top intValue]]];
    score = score + [self cardValue:[deck objectAtIndex:[top intValue]]];
    
    //display card
    [self.delegate displayCard:[deck objectAtIndex:[top intValue]] ForTag:(int)[hand count]];
    
    //save new hand and top
    if ([str isEqualToString:@"H"]) {
        [self.game setObject:hand forKey:@"hostHand"];
        [self.game setObject:[NSNumber numberWithInt:score] forKey:@"hostScore"];
    } else {
        [self.game setObject:hand forKey:@"guestHand"];
        [self.game setObject:[NSNumber numberWithInt:score] forKey:@"guestScore"];
    }
    [self.game setObject:[NSNumber numberWithInt:[top intValue] + 1] forKey:@"top"];
    [self.game saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
        } else {
            // There was a problem, check error.description
        }
    }];
}

-(void)standUser:(NSString *) str {
    if ([str isEqualToString:@"H"]) {
        [self.game setObject:@"YES" forKey:@"hostStanding"];
    } else {
        [self.game setObject:@"YES" forKey:@"guestStanding"];
    }
    [self.game saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            //success!
        } else {
            // There was a problem, check error.description
        }
    }];
}

- (NSString *)currentTurn {
    NSLog(@"current game %@", self.game);
    NSLog(@"currentTurn %@", [self.game objectForKey:@"curTurn"]);
    return [self.game objectForKey:@"curTurn"];
    
}

-(void)endTurn:(NSString *) str {
    if ([str isEqualToString:@"H"]) {
        [self.game setObject:@"G" forKey:@"curTurn"];
    } else {
        [self.game setObject:@"H" forKey:@"curTurn"];
    }
    [self.game saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            //success!
        } else {
            // There was a problem, check error.description
        }
    }];
}

-(void)didExceed21:(NSString *) str {
    int value;
    if ([str isEqualToString:@"H"]) {
        value = [[self.game objectForKey:@"hostScore"] intValue];
        if (value > 21) {
            [self.delegate displayWinner:@"Guest wins"];
        }
    } else {
        value = [[self.game objectForKey:@"guestScore"] intValue];
        if (value > 21) {
            [self.delegate displayWinner:@"Host wins"];
        }
    }
}

-(void)standingCheck:(NSString *) str {
    if ([[self.game objectForKey:@"hostStanding"] isEqualToString:@"YES"] && [[self.game objectForKey:@"guestStanding"] isEqualToString:@"YES"]) {
        [self decideVictor];
    } else if (([[self.game objectForKey:@"hostStanding"] isEqualToString:@"YES"] && [str isEqualToString:@"H"]) || ([str isEqualToString:@"G"] && [[self.game objectForKey:@"guestStanding"] isEqualToString:@"YES"])) {
        [self.delegate endTurn];
    } else {
        
    }
}

-(void) displayCardBacks:(NSString *) str {
    if ([str isEqualToString:@"H"]) {
        NSArray *arrB = [self.game objectForKey:@"guestHand"];
        int i = 7;
        for (NSString *card in arrB) {
            [self.delegate displayCard:@"back"
                                ForTag:i++];
        }
    } else {
        NSArray *arrB = [self.game objectForKey:@"hostHand"];
        int i = 7;
        for (NSString *card in arrB) {
            [self.delegate displayCard:@"back"
                                ForTag:i++];
        }
    }
}

/*** PRIVATE FUNCTIONS ***/
-(void) decideVictor {
    int hostScore = [[self.game objectForKey:@"hostScore"] intValue];
    int guestScore = [[self.game objectForKey:@"guestScore"] intValue];
    
    if (hostScore > guestScore) {
        [self.delegate displayWinner:@"Host wins"];
    } else if (hostScore < guestScore) {
        [self.delegate displayWinner:@"Guest wins"];
    } else {
        [self.delegate displayWinner:@"Tie"];
    }
}

//initialize a deck in sorted order
-(NSMutableArray *) newDeck {
    NSMutableArray *deck = [[NSMutableArray alloc] init];
    for (int i = 1; i < 14; i++) {
        [deck addObject:[NSString stringWithFormat:@"s%d", i]];
        [deck addObject:[NSString stringWithFormat:@"c%d", i]];
        [deck addObject:[NSString stringWithFormat:@"d%d", i]];
        [deck addObject:[NSString stringWithFormat:@"h%d", i]];
    }
    
    for (int i = 0; i < 53; i++) {
        int card1 = (int) arc4random_uniform(51);
        int card2 = (int) arc4random_uniform(51);
        NSString *tempCard = deck[card1];
        deck[card1] = deck[card2];
        deck[card2] = tempCard;
    }
    
    return deck;
}

-(int)cardValue:(NSString *)card {
    NSString *num = [card substringFromIndex:1];
    if ([num isEqualToString:@"11"] || [num isEqualToString:@"12"] || [num isEqualToString:@"13"]) {
        return 10;
    } else {
        return [num intValue];
    }
}

-(void)gameOver {
    //change player's statuses
    PFUser *hostUser = [PFUser currentUser];
    [hostUser setObject:@"N" forKey:@"status"];
    [hostUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            //success!
        } else {
            // There was a problem, check error.description
        }
    }];
}


@end
