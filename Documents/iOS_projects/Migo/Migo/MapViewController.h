//
//  MapViewController.h
//  Migo
//
//  Created by Victoria Xiao on 2016-04-22.
//  Copyright © 2016 My Majesty Productions. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>


@interface MapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>


-(void)drawPins:(CLLocationCoordinate2D)co
       WithUser:(PFObject *) user
       withName:(NSString *) name;

@end
