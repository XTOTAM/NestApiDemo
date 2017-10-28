//
//  NASettigsViewController.m
//  iNestApi
//
//  Created by XTOTAM on 10/27/17.
//  Copyright © 2017 MoveTech. All rights reserved.
//

#import "NASettigsViewController.h"
#import "NAThermostatModel.h"
#import "NAAuthManager.h"
#import "MBProgressHUD.h"
#import "NADefine.h"

@interface NASettigsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *logOut;
@property (weak, nonatomic) IBOutlet UISwitch *canCool;
@property (weak, nonatomic) IBOutlet UISwitch *canHeat;
@property (weak, nonatomic) IBOutlet UISwitch *hvacState;
@property (weak, nonatomic) IBOutlet UISwitch *hasFan;
@property (weak, nonatomic) IBOutlet UISwitch *leafe;


@end

@implementation NASettigsViewController {
    NAThermostatModel *thermostateModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    thermostateModel = [NAThermostatModel sharedManager];
    [self setupSettingScreen];
}

-(void)setupSettingScreen {
    self.logOut.layer.cornerRadius = 15.0f;
    self.canCool.on = thermostateModel.canCool;
    self.canHeat.on = thermostateModel.canHeat;
    self.hvacState.on = thermostateModel.hvacState;
    self.hasFan.on = thermostateModel.hasFan;
    self.leafe.on = thermostateModel.hasLeafe;

    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void)walueWasChanged:(NSInteger)tag {
    NSDictionary *dict;
    switch (tag) {
        case TAG_CAN_COOL:
            dict = @{@"can_cool": @((int)self.canCool.on)};
            break;
        case TAG_CAN_HEAT:
            dict = @{@"can_heat": @((int)self.canHeat.on)};
            break;
        case TAG_HAS_FAN:
            dict = @{@"has_fan": @((int)self.hasFan.on)};
            break;
        case TAG_HAS_LEAF:
            dict = @{@"has_leaf": @((int)self.leafe.on)};
            break;
        default:
            break;
    }
    [[NAAuthManager sharedManager] changeThermostatValue:dict withComplit:^(id valueWasChange) {
        if (nil != valueWasChange) {
            [NAThermostatModel updateModelForResponce:valueWasChange];
        }
        [self setupSettingScreen];
    }];
}

- (IBAction)switcherChange:(UISwitch *)sender {
    [self walueWasChanged:sender.tag];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)logOut:(id)sender {
    [[NAAuthManager sharedManager] logOutwithComplit:^(BOOL valueWasChange) {
        if (YES == valueWasChange) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
}

@end
