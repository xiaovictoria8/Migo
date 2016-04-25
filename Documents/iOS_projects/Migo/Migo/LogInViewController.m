//
//  LogInViewController.m
//  Migo
//
//  Created by Victoria Xiao on 2016-04-21.
//  Copyright © 2016 My Majesty Productions. All rights reserved.
//

#import "LogInViewController.h"
#import "ParseDataManager.h"
#import "MapViewController.h"

@interface LogInViewController()

@property(nonatomic) ParseDataManager *dataManager;


@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //setup dataManager
    self.dataManager = [ParseDataManager sharedManager];
    
    //setup login button
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    [loginButton setDelegate:self];
    loginButton.center = self.view.center;
    [self.view addSubview:loginButton];
    
}

- (void)  loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:	(FBSDKLoginManagerLoginResult *)result
                error:	(NSError *)error {
    [self.dataManager fbLoginWithToken:result.token withViewController:self];
}

- (void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    [self.dataManager fbLogout];
}



@end
