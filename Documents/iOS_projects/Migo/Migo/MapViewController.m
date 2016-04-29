//
//  MapViewController.m
//  Migo
//
//  Created by Victoria Xiao on 2016-04-22.
//  Copyright © 2016 My Majesty Productions. All rights reserved.
//

#import "MapViewController.h"
#import "ParseDataManager.h"
#import "LogInViewController.h"
#import "BlackjackViewController.h"


@interface MapViewController()
@property(nonatomic) ParseDataManager *dataManager;
@property (weak, nonatomic) IBOutlet UIButton *startGameButton;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *loc;
@property (strong, nonatomic) IBOutlet MKMapView *map;
@property(nonatomic) NSMutableArray *seekingUsers;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //initialize map
    self.map.delegate = self;
    self.map.showsUserLocation = NO;
    
    //initialize dataManager
    self.dataManager = [ParseDataManager sharedManager];
    
    //initialize location manager
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [self.locationManager startUpdatingLocation];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    //if user is not logged in, segue to loginVC
    if (![self.dataManager isUserLoggedIn]) {
        UIStoryboard *storyboard = self.storyboard;
        LogInViewController * livc = [storyboard instantiateViewControllerWithIdentifier:@"LogInViewController"];
        UINavigationController *livcNavController = [[UINavigationController alloc] initWithRootViewController:livc];
        [self.navigationController presentViewController:livcNavController animated:YES completion:nil];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    NSLog(@"view appeared");
    
    //show seek button if user is neutral
    NSString *status = [self.dataManager getStatusOfUser:[PFUser currentUser]];
    if ([status isEqualToString:@"N"]) {
        self.startGameButton.hidden = NO;
    } else if ([status isEqualToString:@"S"]){
        self.startGameButton.hidden = YES;
        [self.dataManager userRequestedInGameCheck:[PFUser currentUser]
                                            Sender:self];
    } else {
        [self.dataManager segueToGameForUser:[PFUser currentUser]
                                      Sender:self];
    }

    [self loadSeekingUsers];
}


//function called when a new location is found
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.loc = [locations firstObject];
    NSLog(@"Current Lat: %f", self.loc.coordinate.latitude);
    NSLog(@"Current Long: %f", self.loc.coordinate.longitude);
    [self.locationManager stopUpdatingLocation];
    [self.dataManager changeLocationOfUser:[PFUser currentUser]
                              WithLatitude:[NSNumber numberWithDouble:self.loc.coordinate.latitude]
                             WithLongitude:[NSNumber numberWithDouble:self.loc.coordinate.longitude]];
    [self zoomMapToUser];
    
}

//updates location and user pins
- (IBAction)refreshButtonTapped:(id)sender {
    [self.locationManager startUpdatingLocation];
}

//functionality with the "seek game" button is tapped
- (IBAction)buttonTapped:(UIButton *)sender
{
    //hide button
    self.startGameButton.hidden = YES;
    
    //change status to seeking
    [self.dataManager changeStatusToSeeking:[PFUser currentUser]];
}
- (IBAction)stopSeekingTapped:(id)sender {
    [[PFUser currentUser] setObject:@"N" forKey:@"status"];
    self.startGameButton.hidden = NO;
}

//zooms map to last stored user location
-(void) zoomMapToUser {
    MKCoordinateRegion region;
    region.span.latitudeDelta = 0.1;
    region.span.longitudeDelta = 0.1;
    region.center = self.loc.coordinate;
    [self.map setRegion:[self.map regionThatFits:region] animated:YES];
    NSLog(@" zooming in on Lat:%f, Long:%f", self.loc.coordinate.latitude, self.loc.coordinate.longitude);
}

//load pins for seeking users
-(void)loadSeekingUsers {
    [self.dataManager loadSeekingUsersWithCallback:^(NSMutableArray *suArray) {
        for (PFObject *ob in suArray) {
            PFUser *user = [self.dataManager getUserFromSeekingUser:ob];
            if (![user.objectId isEqualToString:[PFUser currentUser].objectId]) {
                [self.dataManager drawPinForUser:user
                                      sender:self];
            }
        }
    }];
}

-(void)drawPins:(CLLocationCoordinate2D)co
       WithUser:(NSString *) userId
       withName:(NSString *) name {
    //draws a pin for user at given coordinates - called by ParseDataManager
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = co;
    annotation.title = name;
    annotation.subtitle = userId;
    NSLog(@"Pin at lat:%f long:%f", annotation.coordinate.latitude, annotation.coordinate.longitude);
    [self.map addAnnotation:annotation];
}


- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation {
    //creates a button that segues to a blackjack game
    MKPinAnnotationView *newAn = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pLoc"];
    newAn.canShowCallout = YES;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [button setTintColor:[UIColor clearColor]];
    [button setBackgroundImage:[UIImage imageNamed:@"chatIcon"] forState:UIControlStateNormal];
    newAn.rightCalloutAccessoryView = button;
    return newAn;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    //when button is tapped, create new viewcontroller and present it
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query getObjectInBackgroundWithId:view.annotation.subtitle
                                 block:^(PFObject *user, NSError *error) {
                                        //present new BlackjavkViewController for game
                                     [self segueToGameBoardWithHost:[PFUser currentUser] WithGuest:user];

                                 }];
}

-(void)segueToGameBoardWithHost:(PFUser *)host
                      WithGuest:(PFUser *)guest{
    UIStoryboard *storyboard = self.storyboard;
    BlackjackViewController * bjvc = [storyboard instantiateViewControllerWithIdentifier:@"BlackjackViewController"];
    UINavigationController *livcNavController = [[UINavigationController alloc] initWithRootViewController:bjvc];
    bjvc.host = host;
    bjvc.guest = guest;
    [self.navigationController presentViewController:livcNavController animated:YES completion:nil];
}

-(void)segueToGameBoardWithGame:(PFObject *) gOb {
    NSLog(@"segue to game board with game");
    UIStoryboard *storyboard = self.storyboard;
    BlackjackViewController * bjvc = [storyboard instantiateViewControllerWithIdentifier:@"BlackjackViewController"];
    UINavigationController *livcNavController = [[UINavigationController alloc] initWithRootViewController:bjvc];
    bjvc.game = gOb;
    bjvc.host = [gOb objectForKey:@"host"];
    bjvc.guest = [gOb objectForKey:@"guest"];
    NSLog(@"game %@, host %@, guest %@", bjvc.game, bjvc.host, bjvc.guest);
    [self.navigationController presentViewController:livcNavController animated:YES completion:nil];
}


@end
