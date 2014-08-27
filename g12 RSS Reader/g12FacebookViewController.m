//
//  g12FacebookViewController.m
//  g12 RSS Reader
//
//  Created by Anton on 8/27/14.
//  Copyright (c) 2014 g12-Squad. All rights reserved.
//

#import "g12FacebookViewController.h"
#import "g12MasterViewController.h"

@interface g12FacebookViewController ()

@property (weak, nonatomic) IBOutlet FBLoginView *loginView;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation g12FacebookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // In your viewDidLoad method:
    self.loginView.readPermissions = @[@"public_profile"];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.alpha = 0;
    self.profilePictureView.backgroundColor = [UIColor clearColor];
    self.profilePictureView.alpha = 0;
}

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    self.profilePictureView.profileID = user.objectID;
    self.profilePictureView.alpha = 1;
    self.nameLabel.text = user.name;
    self.nameLabel.alpha = 1;
}

// Logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    self.profilePictureView.alpha = 0;
    self.profilePictureView.profileID = nil;
    self.nameLabel.alpha = 0;
    self.nameLabel.text = @"";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"Master View"]) {
        [[segue destinationViewController] setManagedObjectContext:_managedObjectContext];
    }
} //Do stuff for segue

@end
