//
//  Constants.m
//  SDOSKZBootstrapExample
//
//  Created by Rafael Fernandez Alvarez on 29/05/2018.
//  Copyright © 2018 SDOS. All rights reserved.
//

#import "Constants.h"

#define STRINGIZE(x) #x
#define PREPROCESS_MACRO_VALUE(x) [NSString stringWithFormat:@"%s" , STRINGIZE(x)]

@implementation Constants

+ (NSString *) getCurrentEnvironment {
    return PREPROCESS_MACRO_VALUE(KZBDefaultEnv);
}

@end
