//
//  BlackjackViewController.m
//  Migo
//
//  Created by Victoria Xiao on 2016-04-28.
//  Copyright © 2016 My Majesty Productions. All rights reserved.
//

#import "BlackjackViewController.h"

@interface BlackjackViewController ()
@property (strong, nonatomic) NSString *gameId;
@property (strong, nonatomic) NSString *userType;
@property (strong, nonatomic) BlackjackDataManager *manager;
@property (strong, nonatomic) IBOutlet UILabel *statusText;

@end

@implementation BlackjackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gameId = @"none";
    if ([[self.host objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        self.userType = @"H";
    } else {
        self.userType = @"G";
    }
    
    self.manager = [[BlackjackDataManager alloc] initWithSender:self];
    //initialize blackjack game if you are host and if it doesn't already exist
    if ([self.userType isEqualToString:@"H"]) {
        [self.manager getGameWithHost:self.host
                            WithGuest:self.guest];
    } else {
        [self.manager getGameWithGuest:self.guest];
    }
}
- (IBAction)refreshPressed:(id)sender {
    NSLog(@"Your turn, refresh pressed");
    [self.manager displayCardBacks:self.userType];
    [self.manager standingCheck:self.userType];
}

-(void)gameDidLoad:(PFObject *) gOb{
    NSLog(@"Game begins!");
    self.game = gOb;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)hitPressed:(id)sender {
    NSLog(@"Your turn, hit pressed");
    NSString *turn = [self.manager currentTurn];
    if ([turn isEqualToString:self.userType]) {
        [self.manager dealCardToUser:self.userType];
        [self endTurn];
    }
}
         
- (IBAction)standPressed:(id)sender {
    NSLog(@"Your turn, stand pressed");
    if ([[self.manager currentTurn] isEqualToString:self.userType]) {
        [self.manager standUser:self.userType];
        [self endTurn];
    }
}

-(void) displayCard:(NSString *) card
             ForTag:(int) tag {
    UIImageView *imageView=(UIImageView *)[self.view viewWithTag:tag];
    [imageView setImage:[UIImage imageNamed:[card stringByAppendingString:@".png"]]];
}

-(void) endTurn {
    //check if anyone won
    [self.manager didExceed21:self.userType];
    
    //change curTurn
    [self.manager endTurn:self.userType];
}

- (void)displayWinner:(NSString *) str{
    //setting up UIAlertControllerStuff
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"displayWinnter"
                                                                        message:str
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action ) {
                                                        [alert dismissViewControllerAnimated: YES completion: nil];
                                                        [self.manager gameOver];
                                                        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
                                                    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];

    self.statusText.text = str;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
