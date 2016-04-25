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
#import <Parse/Parse.h>


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

//zooms map to last stored user location
-(void) zoomMapToUser {
    MKCoordinateRegion region;
    region.span.latitudeDelta = 0.1;
    region.span.longitudeDelta = 0.;
    region.center = self.loc.coordinate;
    [self.map setRegion:[self.map regionThatFits:region] animated:YES];
    NSLog(@"Lat:%f, Long:%f", self.loc.coordinate.latitude, self.loc.coordinate.longitude);
}

/***
//FUNCTIONS RELATED TO LOADING VC
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //initialize managers
    self.dataManager = [ParseDataManager sharedManager];
    self.locationManager = [[CLLocationManager alloc] init];
    
    //setup location manager
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [self.locationManager startUpdatingLocation];
    NSLog(@"eh");
    
    //check login
    if (![self.dataManager isUserLoggedIn]) {
        UIStoryboard *storyboard = self.storyboard;
        LogInViewController * livc = [storyboard instantiateViewControllerWithIdentifier:@"LogInViewController"];
        UINavigationController *livcNavController = [[UINavigationController alloc] initWithRootViewController:livc];
        [self.navigationController presentViewController:livcNavController animated:YES completion:nil];
    }
    
    //show seek button if user is neutral
    if ([[self.dataManager getStatusOfUser:[PFUser currentUser]] isEqualToString:@"N"]) {
        self.startGameButton.hidden = NO;
    } else {
        self.startGameButton.hidden = YES;
    }
    
    //setup map
    self.map.delegate = self;
    self.map.showsUserLocation = NO;
    [self zoomMapToUser];
    
    Code for deleting a user
     PFQuery *query = [PFQuery queryWithClassName:@"seekingUsers"];
     [query whereKey:@"user" equalTo:[PFUser currentUser]];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error) {
     if (error) {
     NSLog(@"getting object error: %@", error);
     }
     [user deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
     if (succeeded && !error) {
     NSLog(@"Image deleted from Parse");
     } else {
     NSLog(@"deletion error: %@", error);
     }
     }];
     }];]
    
    
}

// FUNCTIONS RELATED TO THE MAP DISPLAY
-(void)loadSeekingUsers {
    [self.dataManager loadSeekingUsersWithCallback:^(NSMutableArray *suArray) {
        for (PFObject *ob in suArray) {
            //add pin for each seeking user
            PFUser *user = [ob objectForKey:@"user"];
            double uLatitude = -73;
            double uLongitude = 40;
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = CLLocationCoordinate2DMake  (uLatitude, uLongitude);
            [self.map addAnnotation:annotation];
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 200, 200);
            [self.map setRegion:[self.map regionThatFits:region] animated:YES];
            [self.map setRegion:[self.map regionThatFits:region] animated:YES];
            NSLog(@"Pin added for %@", [user objectId]);
        }
        
    }];
}

//TODO: Update location of user once in a while
//once location has been updated start displaying map
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.loc = [locations firstObject];
    NSLog(@"Current Lat: %f", self.loc.coordinate.latitude);
    NSLog(@"Current Long: %f", self.loc.coordinate.longitude);
    [self.locationManager stopUpdatingLocation];
    
    [self zoomMapToUser];
}

//zoom in onto user location
-(void) zoomMapToUser {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.1;
    span.longitudeDelta = 0.;
    region.span = span;
    CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([[[PFUser currentUser] objectForKey:@"latitude"] doubleValue], [[[PFUser currentUser] objectForKey:@"longitude"] doubleValue]);
    region.center = coordinates;
    [self.map setRegion:[self.map regionThatFits:region] animated:YES];
    NSLog(@"Lat:%f, Long:%f", coordinates.latitude, coordinates.longitude);
}


//when button tapped, user begins seeking game
- (IBAction)buttonTapped:(UIButton *)sender
{
    //hide button
    self.startGameButton.hidden = YES;
    
    //change status to seeking
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(backgroundQueue, ^{
    [self.dataManager changeStatusToSeeking:[PFUser currentUser]];
    [self.dataManager changeLocationOfUser:[PFUser currentUser]
                              WithLatitude:[NSNumber numberWithDouble:self.loc.coordinate.latitude]
                             WithLongitude:[NSNumber numberWithDouble:self.loc.coordinate.longitude]];
    });
}
- (IBAction)refreshButtonTapped:(id)sender {
    [self.locationManager startUpdatingLocation];
    [self loadSeekingUsers];
}

//function helps fit the map to the screen
-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.map.frame = self.view.bounds;
}
***/

@end
