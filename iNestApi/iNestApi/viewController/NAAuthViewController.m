//
//  NAAuthViewController.m
//  iNestApi
//
//  Created by XTOTAM on 10/24/17.
//  Copyright © 2017 MoveTech. All rights reserved.
//

#import "NAAuthViewController.h"
#import "NAThermostatViewController.h"
#import "NADefine.h"
#import "MBProgressHUD.h"
#import "NAAuthManager.h"

@interface NAAuthViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField * enterCodeField;
@property (weak, nonatomic) IBOutlet UILabel     * linckText;
@property (weak, nonatomic) IBOutlet UIButton    * acept;

@end

@implementation NAAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkValidSession];
    self.linckText.userInteractionEnabled = YES;
    self.enterCodeField.delegate = self;
}


#pragma mark -
#pragma mark - handel linck text

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
     UITouch *touch = [touches anyObject];
    if (touch.view == self.linckText) {
        UIApplication *application = [UIApplication sharedApplication];
        NSURL *url = [NSURL URLWithString:[[NAAuthManager sharedManager] authorizationURL]];
        [application openURL:url options:@{} completionHandler:nil];
    }
}

#pragma mark -
#pragma mark - code validation

-(BOOL)isEmptyField {
    if ([self.enterCodeField.text isEqualToString:@""]) {
        [MBProgressHUD showModeText:@"field can not be empty"];
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark - action

- (IBAction)aceptAction:(id)sender {
    if ([self isEmptyField]) {
        [self.acept setEnabled:NO];
        [[NAAuthManager sharedManager] exchangeCodeForToken:self.enterCodeField.text withComplition:^(BOOL isSucsses) {
            if (YES == isSucsses) {
                NAThermostatViewController *thermostat = [self.storyboard instantiateViewControllerWithIdentifier:@"thermostatID"];
                [self.navigationController pushViewController:thermostat animated:YES];
            } else {
                [self.acept setEnabled:YES];
            }
        }];
    }
}

-(void)checkValidSession {
    if (YES == [[NAAuthManager sharedManager] isValidSession]) {
        NAThermostatViewController *thermostat = [self.storyboard instantiateViewControllerWithIdentifier:@"thermostatID"];
        [self.navigationController pushViewController:thermostat animated:YES];
    }
}

#pragma mark -
#pragma mark - textField delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_enterCodeField resignFirstResponder];
    return YES;
}

@end

