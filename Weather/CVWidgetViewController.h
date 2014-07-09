//
//  CVWidgetViewController.h
//  Weather
//
//  Created by Matt Clarke on 06/01/2014.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CVWidgetDelegate.h"
#import <Weather/Weather.h>
#import "CVWDailyForecast.h"

#define is_IOS6 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) && ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)

@interface CVWeatherWidgetViewController : NSObject <CVWidgetDelegate, CityUpdaterDelegate, UIScrollViewDelegate>
{
    UIScrollView *_view;
    float _height;
    City *weatherValues;
    BOOL _allowUpdates;
}

@property (nonatomic, strong) UILabel *location;
@property (nonatomic, strong) UILabel *temperature;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UIImageView *windIcon;
@property (nonatomic, strong) UILabel *windLabel;
@property (nonatomic, strong) UILabel *later;
@property (nonatomic, strong) UIImageView *laterIcon;
@property (nonatomic, strong) UILabel *laterTemp;

@property (nonatomic, strong) UILabel *degrees;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

-(UIView *)view;

@end