//
//  KZBootstrapEnviromentsManager.m
//  SDOSKZBootstrap
//
//  Created by Antonio Jesús Pallares on 2/11/16.
//  Copyright 2016 SDOS. All rights reserved.
//	File created using Singleton XCode Template by Mugunth Kumar (http://blog.mugunthkumar.com)
//  More information about this template on the post http://mk.sg/89	
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above

#import "KZBootstrapEnviromentsManager.h"
#import "SDOSEnvironmentExample-Swift.h"
@import SDOSEnvironment;


#define ENVIRONMENT_DEBUG @"Debug"
#define ENVIRONMENT_PREPRODUCTION @"Preproduction"
#define ENVIRONMENT_PRODUCTION @"Production"
#define KZBOOTSTRAP_ENVIRONMENTS_PLIST_FILE_NAME @"KZBEnvironments"
#define KZBOOTSTRAP_ENVIRONMENTS_KEY @"KZBEnvironments"

@implementation KZBootstrapEnviromentsManager

#pragma mark - Class methods

+(NSArray<NSString *> *)environments {
    return @[ENVIRONMENT_DEBUG, ENVIRONMENT_PREPRODUCTION, ENVIRONMENT_PRODUCTION];
}

+ (void)changeEnvironmentTo:(NSString *)env {
    if ([[self environments] containsObject:env]) {
        
        [SDOSEnvironment changeEnvironmentKey:env];
    } else {
        NSLog(@"The environment %@ is not valid", env);
    }
}

+ (NSDictionary *)dictionaryOfValuesSpecificToCurrentEnvironment {
    
    /*
    NSString *path = [[NSBundle mainBundle] pathForResource:KZBOOTSTRAP_ENVIRONMENTS_PLIST_FILE_NAME ofType:@"plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    [dict removeObjectForKey:KZBOOTSTRAP_ENVIRONMENTS_KEY];
     */
    
    return @{@"wsBaseUrl" : [ConstantsSwift getWSBaseUrl],
             @"octopushMode" : [ConstantsSwift getOctopushMode],
             @"googleAnalyticsKey" : [ConstantsSwift getGoogleAnalyticsKey],
             @"showSelectedEnvironmentsOnLoad" : [ConstantsSwift getShowSelectedEnvironmentsOnLoad],
             @"EnvironmentDescription" : [ConstantsSwift getEnvironmentDescription]};
}

#pragma mark -
#pragma mark Singleton Methods

+ (KZBootstrapEnviromentsManager*)sharedInstance {

	static KZBootstrapEnviromentsManager *_sharedInstance;
	if(!_sharedInstance) {
		static dispatch_once_t oncePredicate;
		dispatch_once(&oncePredicate, ^{
			_sharedInstance = [[super allocWithZone:nil] init];
			});
		}

		return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {	

	return [self sharedInstance];
}


- (id)copyWithZone:(NSZone *)zone {
	return self;	
}

#if (!__has_feature(objc_arc))

- (id)retain {	

	return self;	
}

- (unsigned)retainCount {
	return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
	//do nothing
}

- (id)autorelease {

	return self;	
}
#endif

#pragma mark -
#pragma mark Custom Methods

// Add your custom methods here

@end
