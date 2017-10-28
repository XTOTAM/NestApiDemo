//
//  NAThermostatViewController.m
//  iNestApi
//
//  Created by XTOTAM on 10/25/17.
//  Copyright © 2017 MoveTech. All rights reserved.
//

#import "NAThermostatViewController.h"
#import "NAAuthManager.h"
#import "MBProgressHUD.h"
#import "NAThermostatModel.h"
#import "NAAPIClient.h"
#import "NASettigsViewController.h"

@interface NAThermostatViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLong;
@property (weak, nonatomic) IBOutlet UILabel *heat;
@property (weak, nonatomic) IBOutlet UILabel *curentTemperature;
@property (weak, nonatomic) IBOutlet UILabel *target;
@property (weak, nonatomic) IBOutlet UISlider *targetSlider;
@property (weak, nonatomic) IBOutlet UILabel *humidityTarget;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation NAThermostatViewController {
    NAThermostatModel * _thermostatModel;
    NSTimer *_pullingTimer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _pullingTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(getTermostateData) userInfo:nil repeats:YES];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.targetSlider addTarget:self action:@selector(onSliderValChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
}

-(void)viewWillAppear:(BOOL)animated{
    [self getTermostateData];
}

-(void)getTermostateData{
    [[NAAuthManager sharedManager] getThermostatDataWithComplition:^(BOOL isSucsses) {
        if (isSucsses) {
            _thermostatModel = [NAThermostatModel sharedManager];
            [self setupControlsScreen];
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}

- (IBAction)targetChange:(UISlider *)sender {
    switch (sender.tag) {
        case 6:
            self.curentTemperature.text = [NSString stringWithFormat:@"%.0f",sender.value];
            break;
        case 7:
            self.target.text = [NSString stringWithFormat:@"%.0f",sender.value];
            break;
        default:
            break;
    }
    self.containerView.layer.borderColor = [self updateContainerFrameForValue:sender.value].CGColor;
}


- (void)onSliderValChanged:(UISlider*)slider forEvent:(UIEvent*)event {
    UITouch *touchEvent = [[event allTouches] anyObject];
    switch (touchEvent.phase) {
        case UITouchPhaseEnded:
            [self walueWasChanged:slider.tag];
            break;
        default:
            break;
    }
}

-(void)walueWasChanged:(NSInteger)tag {
    NSDictionary *dict;
    switch (tag) {
       case 7:
            dict = @{@"target_temperature_f": @((int)self.targetSlider.value)};
            break;
        default:
            break;
    }
    [[NAAuthManager sharedManager] changeThermostatValue:dict withComplit:^(id valueWasChange) {
        if (nil != valueWasChange) {
            [NAThermostatModel updateModelForResponce:valueWasChange];
        }
        [self setupControlsScreen];
    }];
}

- (IBAction)setingAction:(id)sender {
    [self getTermostateData];
    NASettigsViewController  *seting = [self.storyboard instantiateViewControllerWithIdentifier:@"setingID"];
    [self.navigationController pushViewController:seting animated:YES];
}


-(void)setupControlsScreen {
    self.containerView.layer.cornerRadius = 15.0f;
    self.containerView.layer.borderWidth = 1.0f;
    self.containerView.layer.borderColor = [self updateContainerFrameForValue:_thermostatModel.targetTemperatureF].CGColor;
    
    [self.targetSlider setMaximumValue:90];
    [self.targetSlider setMinimumValue:50];
    [self.targetSlider setValue:_thermostatModel.targetTemperatureF];
    
    self.nameLong.text = _thermostatModel.nameLong;
    self.heat.text = _thermostatModel.hvacMode;
    self.curentTemperature.text = [NSString stringWithFormat:@"%ld",(long)_thermostatModel.ambientTemperatureF];
    self.target.text = [NSString stringWithFormat:@"%ld",(long)_thermostatModel.targetTemperatureF];
    self.humidityTarget.text = [NSString stringWithFormat:@"%ld",(long)_thermostatModel.humidity];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(UIColor *)updateContainerFrameForValue:(CGFloat)value {
    CGFloat red;
    CGFloat blue;
    
    if (value == 70) {
        return [UIColor lightGrayColor];
    }
    if (value > 70) {
        red = 1.0f;
        blue = 255.0f * (value / 50.0f) / 255.0f;
    } else {
        blue = 1.0f;
        red = 255.0f * ((100 - value) / 50.0f) / 255.0f;
    }
    
    return [UIColor colorWithRed:red green:0.0f blue:blue alpha:0.85f];
}

@end
