//
//  CVWidgetViewController.m
//  Weather
//
//  Created by Matt Clarke on 06/01/2014.
//  Copyright (c) 2014 Matchstic. All rights reserved.
//

#import "CVWidgetViewController.h"
#import <CoreLocation/CLLocationManager.h>

static NSDictionary *settings;
static BOOL failedWeather;

@interface City (iOS7)
@property (assign,nonatomic) unsigned conditionCode;
@property (assign,nonatomic) BOOL isRequestedByFrameworkClient;

+(id)descriptionForWeatherUpdateDetail:(unsigned)arg1 ;
@end

@interface HourlyForecast (iOS7)
- (id)time;
@property(copy) NSString * detail;
@end

@interface WeatherUpdateController (private)

@end

@interface WeatherPreferences (iOS7)
- (id)loadSavedCityAtIndex:(int)arg1;
@end

@interface WeatherLocationManager (iOS7)
- (BOOL)localWeatherAuthorized;
@end

@implementation CVWeatherWidgetViewController

-(void)reloadSettings {
    settings = nil;
    settings = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.matchstic.Convergance.weather.plist"];
}

-(UIView *)view {
	if (_view == nil) {
        _allowUpdates = NO;
        
        [self reloadSettings];
        
		_view = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width*0.9, [self viewHeight])];
        _view.contentSize = CGSizeMake(_view.frame.size.width, _view.frame.size.height);
        _view.contentOffset = CGPointMake(0, 0);
        _view.alwaysBounceVertical = YES;
        _view.showsVerticalScrollIndicator = NO;
        _view.scrollEnabled = YES;
        
        if (settings[@"pullRefresh"] ? [settings[@"pullRefresh"] boolValue] : YES) {
            self.refreshControl = [[UIRefreshControl alloc] init];
            [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
            [_view addSubview:self.refreshControl];
        } else {
            _view.scrollEnabled = NO;
            _view.alwaysBounceVertical = NO;
        }
        
        [City initialize];
		weatherValues = [[City alloc] init];
        [weatherValues setAutoUpdate:YES];
        weatherValues.isRequestedByFrameworkClient = YES;
        [weatherValues associateWithDelegate:self];
        
        // Load changes to weather.app
        @try {
            [[WeatherPreferences sharedPreferences] synchronizeStateToDisk];
            [[WeatherLocationManager sharedWeatherLocationManager] forceLocationUpdate];
        } @catch (NSException *e) {
            NSLog(@"*** [Convergance :: Weather] Avoided crash: %@", e);
        }
        
        if ([CLLocationManager locationServicesEnabled]) {
            @try {
            [[WeatherIdentifierUpdater sharedWeatherIdentifierUpdater] updateWeatherForCity:[[WeatherPreferences sharedPreferences] localWeatherCity]];
                [weatherValues populateWithDataFromCity:[[WeatherPreferences sharedPreferences] localWeatherCity]];
            } @catch (NSException *e) {
                NSLog(@"No internet connection?");
                
                UILabel *noData = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, _view.frame.size.width, 50)];
                noData.backgroundColor = [UIColor clearColor];
                noData.textAlignment = NSTextAlignmentCenter;
                noData.text = @"No weather data";
                noData.textColor = [UIColor darkGrayColor];
                noData.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
                noData.clipsToBounds = NO;
                noData.opaque = NO;
                
                [_view addSubview:noData];
                
                return _view;
            }
        } else {
            // Get first city in Weather.app
            NSLog(@"**** Getting first from Weather.app");
            @try {
            [[WeatherIdentifierUpdater sharedWeatherIdentifierUpdater] updateWeatherForCity:[[WeatherPreferences sharedPreferences] loadSavedCityAtIndex:0]];
                [weatherValues populateWithDataFromCity:[[WeatherPreferences sharedPreferences] loadSavedCityAtIndex:0]];
            } @catch (NSException *e) {
                NSLog(@"No internet connection?");
                
                UILabel *noData = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, _view.frame.size.width, 50)];
                noData.backgroundColor = [UIColor clearColor];
                noData.textAlignment = NSTextAlignmentCenter;
                noData.text = @"No weather data";
                noData.textColor = [UIColor darkGrayColor];
                noData.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
                noData.clipsToBounds = NO;
                noData.opaque = NO;
                
                [_view addSubview:noData];
                
                return _view;
            }
        }
        
        @try {
            [weatherValues update];
        } @catch (NSException *e) {
            NSLog(@"*** [Convergance :: Weather] Avoided crash: %@", e);
        }
    
        // Icon
        NSString *iconPath;
        if (is_IOS6)
            iconPath = [NSString stringWithFormat:@"/var/mobile/Library/Convergance/LockWidgets.bundle/com.matchstic.Weather/Icons/%d.png", weatherValues.bigIcon];
        else
            iconPath = [NSString stringWithFormat:@"/var/mobile/Library/Convergance/LockWidgets.bundle/com.matchstic.Weather/Icons/%d.png", weatherValues.conditionCode];
        self.icon = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:iconPath]];
        self.icon.frame = CGRectMake(0, 0, 120, 90);
        self.icon.backgroundColor = [UIColor clearColor];
        self.icon.center = CGPointMake(_view.frame.size.width*0.5, 45);
        
        [_view addSubview:self.icon];
        
        self.location = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width*0.9, 50)];
        self.location.text = weatherValues.name;
        self.location.backgroundColor = [UIColor clearColor];
        self.location.textColor = [UIColor darkGrayColor];
        self.location.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        self.location.clipsToBounds = NO;
        self.location.opaque = NO;
        self.location.textAlignment = NSTextAlignmentCenter;
        if (settings[@"showDegrees"] ? [settings[@"showDegrees"] boolValue] : NO)
            self.location.center = CGPointMake(_view.frame.size.width*0.5, 105);
        else
            self.location.center = CGPointMake(_view.frame.size.width*0.5, 97);
        
        [_view addSubview:self.location];
        
        self.temperature = [[UILabel alloc] initWithFrame:self.location.frame];
        
        int temp;
        if ([[WeatherPreferences sharedPreferences] isCelsius])
            temp = [weatherValues.temperature intValue];
        else
            temp = (([weatherValues.temperature intValue]*9)/5) + 32;
        
        self.temperature.text = [NSString stringWithFormat:@"%d", temp];
        self.temperature.backgroundColor = [UIColor clearColor];
        self.temperature.textAlignment = NSTextAlignmentCenter;
        self.temperature.textColor = [UIColor darkGrayColor];
        self.temperature.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:45];
        self.temperature.clipsToBounds = NO;
        self.temperature.opaque = NO;

        self.temperature.center = CGPointMake(_view.frame.size.width*0.21, 45);
        
        [_view addSubview:self.temperature];
        
        if (settings[@"showDegrees"] ? [settings[@"showDegrees"] boolValue] : NO) {
            self.degrees = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
            
            if ([[WeatherPreferences sharedPreferences] isCelsius])
                self.degrees.text = @"Celsius";
            else
                self.degrees.text = @"Fahrenheit";
            
            self.degrees.backgroundColor = [UIColor clearColor];
            self.degrees.textAlignment = NSTextAlignmentCenter;
            self.degrees.textColor = [UIColor darkGrayColor];
            self.degrees.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
            self.degrees.clipsToBounds = NO;
            self.degrees.opaque = NO;
            
            self.degrees.center = CGPointMake(_view.frame.size.width*0.5, 85);

            [_view addSubview:self.degrees];
        }
        
        // Grab first hourly forecast
        HourlyForecast *lat;
        @try {
            lat = [[weatherValues hourlyForecasts] objectAtIndex:1];
        }
        @catch (NSException *exception) {
            lat = nil;
        }
        
        if (!lat) {
            // We don't actually have weather info!
            failedWeather = YES;
            
            for (UIView *view in _view.subviews) [view removeFromSuperview];
            
            UILabel *noData = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, _view.frame.size.width, 50)];
            noData.backgroundColor = [UIColor clearColor];
            noData.textAlignment = NSTextAlignmentCenter;
            noData.text = @"No weather data";
            noData.textColor = [UIColor darkGrayColor];
            noData.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
            noData.clipsToBounds = NO;
            noData.opaque = NO;
            
            [_view addSubview:noData];
            
            UILabel *plz = [[UILabel alloc] initWithFrame:CGRectMake(40, 90, _view.frame.size.width-80, 50)];
            plz.backgroundColor = [UIColor clearColor];
            plz.textAlignment = NSTextAlignmentCenter;
            plz.text = @"Please open Apple's weather app to download new data";
            plz.textColor = [UIColor darkGrayColor];
            plz.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
            plz.clipsToBounds = NO;
            plz.numberOfLines = 0;
            plz.opaque = NO;
            
            return _view;
        }
        
        self.later = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width*0.9, 14)];
        if (is_IOS6)
            self.later.text = lat.time24Hour;
        else
            self.later.text = lat.time;
        self.later.backgroundColor = [UIColor clearColor];
        self.later.textAlignment = NSTextAlignmentCenter;
        self.later.textColor = [UIColor darkGrayColor];
        self.later.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
        self.later.clipsToBounds = NO;
        self.later.opaque = NO;
        self.later.center = CGPointMake(_view.frame.size.width*0.785, 32.5);
        
        [_view addSubview:self.later];
        
        NSString *iconPat = [NSString stringWithFormat:@"/var/mobile/Library/Convergance/LockWidgets.bundle/com.matchstic.Weather/Icons/%d.png", lat.conditionCode];
        UIImage *img = [UIImage imageWithContentsOfFile:iconPat];
        CGSize newSize = CGSizeMake(40, 30);
        
        if (img) {
            UIGraphicsBeginImageContextWithOptions(newSize, // context size
                                               NO,      // opaque?
                                               0);      // image scale. 0 means "device screen scale"
            CGContextRef context = UIGraphicsGetCurrentContext();
        
            CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
            [img drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        
            self.laterIcon = [[UIImageView alloc] initWithImage:newimg];
            self.laterIcon.frame = CGRectMake(0, 0, 40, 30);
            self.laterIcon.backgroundColor = [UIColor clearColor];
            self.laterIcon.center = CGPointMake((_view.frame.size.width*0.785)-12, 55);
        
            [_view addSubview:self.laterIcon];
        }
        
        self.laterTemp = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width*0.9, 14)];
        NSString *det;
        if (is_IOS6)
            det = lat.temperature;
        else
            det = lat.detail;
        int lattemp;
        if ([[WeatherPreferences sharedPreferences] isCelsius])
            lattemp = [det intValue];
        else
            lattemp = (([det intValue]*9)/5) + 32;
        self.laterTemp.text = [NSString stringWithFormat:@"%d", lattemp];
        self.laterTemp.backgroundColor = [UIColor clearColor];
        self.laterTemp.textAlignment = NSTextAlignmentCenter;
        self.laterTemp.textColor = [UIColor darkGrayColor];
        self.laterTemp.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
        self.laterTemp.clipsToBounds = NO;
        self.laterTemp.opaque = NO;
        self.laterTemp.center = CGPointMake((_view.frame.size.width*0.785)+12, 55);
        
        [_view addSubview:self.laterTemp];
        
        // Daily forecasts
        int i = 0;
        BOOL missFirstOut = YES;
        for (DayForecast* forecast in weatherValues.dayForecasts) {
            // discount first one!
            if (i == 5)
                break;
            if (missFirstOut) {
                missFirstOut = NO;
            } else {
                int hightemp;
                if ([[WeatherPreferences sharedPreferences] isCelsius])
                    hightemp = [forecast.high intValue];
                else
                    hightemp = (([forecast.high intValue]*9)/5) + 32;
                
                int lowtemp;
                if ([[WeatherPreferences sharedPreferences] isCelsius])
                    lowtemp = [forecast.low intValue];
                else
                    lowtemp = (([forecast.low intValue]*9)/5) + 32;

                CVWDailyForecast *small = [[CVWDailyForecast alloc] initWithDay:forecast.dayOfWeek icon:forecast.icon high:[NSString stringWithFormat:@"%d", hightemp] andLow:[NSString stringWithFormat:@"%d", lowtemp]];
                small.frame = CGRectMake(10 + (50*i) + (5*i), 120, 50, 70);
                small.clipsToBounds = NO;
                [_view addSubview:small];
                i++;
            }
        }
	}

    _allowUpdates = YES;
    
	return _view;
}

-(float)viewHeight {
	return 200.0;
}

#pragma mark Weather delegate
-(void)cityDidFinishWeatherUpdate:(City*)city {
    // update our stuff
    if (_allowUpdates) {
        weatherValues = nil;
        weatherValues = city;
        
        // Force location update if needed
        @try {
            [[WeatherLocationManager sharedWeatherLocationManager] forceLocationUpdate];
        
            NSLog(@"*** [Convergance :: Weather] Saving new data to disk");
            [[WeatherPreferences sharedPreferences] synchronizeStateToDisk];
        } @catch (NSException *e) {
            NSLog(@"*** [Convergance :: Weather] Avoided crash: %@", e);
        }
        
        NSString *iconPath;
        if (is_IOS6)
            iconPath = [NSString stringWithFormat:@"/var/mobile/Library/Convergance/LockWidgets.bundle/com.matchstic.Weather/Icons/%d.png", city.bigIcon];
        else
            iconPath = [NSString stringWithFormat:@"/var/mobile/Library/Convergance/LockWidgets.bundle/com.matchstic.Weather/Icons/%d.png", city.conditionCode];
        
        self.icon.image = [UIImage imageWithContentsOfFile:iconPath];
        self.location.text = city.name;
        int temp;
        if ([[WeatherPreferences sharedPreferences] isCelsius])
            temp = [city.temperature intValue];
        else
            temp = (([city.temperature intValue]*9)/5) + 32;
        self.temperature.text = [NSString stringWithFormat:@"%d", temp];
        
        HourlyForecast *lat;
        @try {
            lat = [[city hourlyForecasts] objectAtIndex:1];
        }
        @catch (NSException *exception) {
            lat = nil;
        }
        if (is_IOS6)
            self.later.text = lat.time24Hour;
        else
            self.later.text = lat.time;
        
        NSString *iconPat = [NSString stringWithFormat:@"/var/mobile/Library/Convergance/LockWidgets.bundle/com.matchstic.Weather/Icons/%d.png", lat.conditionCode];
        UIImage *img = [UIImage imageWithContentsOfFile:iconPat];
        CGSize newSize = CGSizeMake(80, 60);
        
        if (img) {
            UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
            CGContextRef context = UIGraphicsGetCurrentContext();
        
            CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
            [img drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            self.laterIcon.image = newimg;
        }
        
        NSString *det;
        if (is_IOS6)
            det = lat.temperature;
        else
            det = lat.detail;
        int lattemp;
        if ([[WeatherPreferences sharedPreferences] isCelsius])
            lattemp = [det intValue];
        else
            lattemp = (([det intValue]*9)/5) + 32;
        self.laterTemp.text = [NSString stringWithFormat:@"%d", lattemp];
        
        for (UIView *view in _view.subviews) {
            if ([view class] == [CVWDailyForecast class])
                [view removeFromSuperview];
        }
        
        // Daily forecasts
        int i = 0;
        BOOL missFirstOut = YES;
        for (DayForecast* forecast in weatherValues.dayForecasts) {
            // discount first one!
            if (i == 5)
                break;
            if (missFirstOut) {
                missFirstOut = NO;
            } else {
                int hightemp;
                if ([[WeatherPreferences sharedPreferences] isCelsius])
                    hightemp = [forecast.high intValue];
                else
                    hightemp = (([forecast.high intValue]*9)/5) + 32;
                
                int lowtemp;
                if ([[WeatherPreferences sharedPreferences] isCelsius])
                    lowtemp = [forecast.low intValue];
                else
                    lowtemp = (([forecast.low intValue]*9)/5) + 32;
                
                CVWDailyForecast *small = [[CVWDailyForecast alloc] initWithDay:forecast.dayOfWeek icon:forecast.icon high:[NSString stringWithFormat:@"%d", hightemp] andLow:[NSString stringWithFormat:@"%d", lowtemp]];
                small.frame = CGRectMake(10 + (50*i) + (5*i), 120, 50, 70);
                [_view addSubview:small];
                i++;
            }
        }
    }
    
    // We should now drop down and cancel the refresher
    if (settings[@"pullRefresh"] ? [settings[@"pullRefresh"] boolValue] : YES)
        [self.refreshControl endRefreshing];
}

-(void)cityDidStartWeatherUpdate:(id)city {
    // Force location update
}

-(void)midnightPassed {
    [weatherValues update];
}


-(void)refresh:(UIRefreshControl *)refreshControl {
    // Load changes to weather.app
    @try {
        [[WeatherPreferences sharedPreferences] synchronizeStateToDisk];
        [[WeatherLocationManager sharedWeatherLocationManager] forceLocationUpdate];
    } @catch (NSException *e) {
        NSLog(@"*** [Convergance :: Weather] Avoided crash: %@", e);
    }
    
    if ([CLLocationManager locationServicesEnabled]) {
        @try {
            [[WeatherIdentifierUpdater sharedWeatherIdentifierUpdater] updateWeatherForCity:[[WeatherPreferences sharedPreferences] localWeatherCity]];
            [weatherValues populateWithDataFromCity:[[WeatherPreferences sharedPreferences] localWeatherCity]];
        } @catch (NSException *e) {
            NSLog(@"No internet connection?");
        }
    } else {
        // Get first city in Weather.app
        NSLog(@"**** Getting first from Weather.app");
        @try {
            [[WeatherIdentifierUpdater sharedWeatherIdentifierUpdater] updateWeatherForCity:[[WeatherPreferences sharedPreferences] loadSavedCityAtIndex:0]];
            [weatherValues populateWithDataFromCity:[[WeatherPreferences sharedPreferences] loadSavedCityAtIndex:0]];
        } @catch (NSException *e) {
            NSLog(@"No internet connection?");
        }
    }
    
    @try {
        [weatherValues update];
    } @catch (NSException *e) {
        NSLog(@"*** [Convergance :: Weather] Avoided crash: %@", e);
    }
    
}

-(void)dealloc {
    [weatherValues disassociateWithDelegate:self];
    weatherValues = nil;
    
    [self.location removeFromSuperview];
    self.location = nil;
    
    [self.temperature removeFromSuperview];
    self.temperature = nil;
    
    [self.icon removeFromSuperview];
    self.icon = nil;
    
    [self.later removeFromSuperview];
    self.later = nil;
    
    [self.laterIcon removeFromSuperview];
    self.laterIcon = nil;
    
    [self.laterTemp removeFromSuperview];
    self.laterTemp = nil;
    
    for (UIView *view in _view.subviews)
        [view removeFromSuperview];
    
    [_view removeFromSuperview];
    _view = nil;
}

@end