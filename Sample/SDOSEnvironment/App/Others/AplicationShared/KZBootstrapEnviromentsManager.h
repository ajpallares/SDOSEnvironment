//
//  KZBootstrapEnviromentsManager.h
//  SDOSKZBootstrap
//
//  Created by Antonio Jesús Pallares on 2/11/16.
//  Copyright 2016 SDOS. All rights reserved.
//	File created using Singleton XCode Template by Mugunth Kumar (http://blog.mugunthkumar.com)
//  More information about this template on the post http://mk.sg/89
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above

#import <Foundation/Foundation.h>

@interface KZBootstrapEnviromentsManager : NSObject

/**
 *  Returns an NSArray with the supported environments.
 *
 *  @return an NSArray containing all the supported environments.
 */
+ (NSArray <NSString *> *)environments;

/**
 *  Changes the KZBootstrap environment.
 *
 *  @param env the new environment. It must be an element of the array returned by the +environments method.
 */
+ (void)changeEnvironmentTo:(NSString *)env;

/**
 *  Returns an NSDictionary containing the keys and values in KZBEnvironments.plist for the current environment.
 *
 *  @return an NSDictionary instance with the keys and values in KZBEnvironments.plist for the current environment.
 */
+ (NSDictionary *)dictionaryOfValuesSpecificToCurrentEnvironment;

/**
 *  returns the environment defined in the .xconfig file for KZBDefaultEnv
 *
 *  @return an NSString containing the environment defined in the .xconfig file for KZBDefaultEnv
 */
+ (NSString *)executionEnvironment;

/**
 *  Changes the KZBootstrap environment to the environment returned by the +executionEnvironment method
 */
+ (void)changeToExecutionEnvironment;

@end
