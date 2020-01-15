#import "FlutterSegmentPlugin.h"
#import <Analytics/SEGAnalytics.h>
#import <Segment_Mixpanel/SEGMixpanelIntegrationFactory.h>

@implementation FlutterSegmentPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    @try {
        NSString *path = [[NSBundle mainBundle] pathForResource: @"Info" ofType: @"plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
        NSString *writeKey = [dict objectForKey: @"com.claimsforce.segment.WRITE_KEY"];
        SEGAnalyticsConfiguration *configuration = [SEGAnalyticsConfiguration configurationWithWriteKey:writeKey];
        configuration.trackApplicationLifecycleEvents = YES;

        [configuration use:[SEGMixpanelIntegrationFactory instance]];
        [SEGAnalytics setupWithConfiguration:configuration];
        
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
           UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeSound |
           UIUserNotificationTypeBadge;
           UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types
           categories:nil];
           [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
           [[UIApplication sharedApplication] registerForRemoteNotifications];
         } else {
           UIRemoteNotificationType types = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound |
           UIRemoteNotificationTypeBadge;
           [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
         }
        
        FlutterMethodChannel* channel = [FlutterMethodChannel
                                         methodChannelWithName:@"flutter_segment"
                                         binaryMessenger:[registrar messenger]];
        FlutterSegmentPlugin* instance = [[FlutterSegmentPlugin alloc] init];
        [registrar addApplicationDelegate:instance];
        [registrar addMethodCallDelegate:instance channel:channel];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", [exception reason]);
    }
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"identify" isEqualToString:call.method]) {
        [self identify:call result:result];
    } else if ([@"track" isEqualToString:call.method]) {
        [self track:call result:result];
    } else if ([@"screen" isEqualToString:call.method]) {
        [self screen:call result:result];
    } else if ([@"group" isEqualToString:call.method]) {
        [self group:call result:result];
    } else if ([@"alias" isEqualToString:call.method]) {
        [self alias:call result:result];
    } else if ([@"getAnonymousId" isEqualToString:call.method]) {
        [self anonymousId:result];
    } else if ([@"reset" isEqualToString:call.method]) {
        [self reset:result];
    } else if ([@"disable" isEqualToString:call.method]) {
        [self disable:result];
    } else if ([@"enable" isEqualToString:call.method]) {
        [self enable:result];
    } else if ([@"debug" isEqualToString:call.method]) {
        [self debug:call result:result];
    } else if ([@"putDeviceToken" isEqualToString:call.method]) {
        [self putDeviceToken:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)identify:(FlutterMethodCall*)call result:(FlutterResult)result {
    @try {
        NSString *userId = call.arguments[@"userId"];
        NSDictionary *traits = call.arguments[@"traits"];
        NSDictionary *options = call.arguments[@"options"];
        [[SEGAnalytics sharedAnalytics] identify: userId
                                          traits: traits
                                         options: options];
        result([NSNumber numberWithBool:YES]);
    }
    @catch (NSException *exception) {
        result([FlutterError errorWithCode:@"FlutterSegmentException" message:[exception reason] details: nil]);
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[SEGAnalytics sharedAnalytics] registeredForRemoteNotificationsWithDeviceToken:deviceToken];
}

// A notification has been received while the app is running in the foreground
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  [[SEGAnalytics sharedAnalytics] receivedRemoteNotification:userInfo];
}

// iOS 8+ only
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
  // register to receive notifications
  [application registerForRemoteNotifications];
}

- (void)track:(FlutterMethodCall*)call result:(FlutterResult)result {
    @try {
        NSString *eventName = call.arguments[@"eventName"];
        NSDictionary *properties = call.arguments[@"properties"];
        NSDictionary *options = call.arguments[@"options"];
        [[SEGAnalytics sharedAnalytics] track: eventName
                                          properties: properties
                                         options: options];
        result([NSNumber numberWithBool:YES]);
    }
    @catch (NSException *exception) {
        result([FlutterError errorWithCode:@"FlutterSegmentException" message:[exception reason] details: nil]);
    }
}

- (void)screen:(FlutterMethodCall*)call result:(FlutterResult)result {
    @try {
        NSString *screenName = call.arguments[@"screenName"];
        NSDictionary *properties = call.arguments[@"properties"];
        NSDictionary *options = call.arguments[@"options"];
        [[SEGAnalytics sharedAnalytics] screen: screenName
                                    properties: properties
                                       options: options];
        result([NSNumber numberWithBool:YES]);
    }
    @catch (NSException *exception) {
        result([FlutterError errorWithCode:@"FlutterSegmentException" message:[exception reason] details: nil]);
    }
}

- (void)group:(FlutterMethodCall*)call result:(FlutterResult)result {
    @try {
        NSString *groupId = call.arguments[@"groupId"];
        NSDictionary *traits = call.arguments[@"traits"];
        NSDictionary *options = call.arguments[@"options"];
        [[SEGAnalytics sharedAnalytics] group: groupId
                                       traits: traits
                                      options: options];
        result([NSNumber numberWithBool:YES]);
    }
    @catch (NSException *exception) {
        result([FlutterError errorWithCode:@"FlutterSegmentException" message:[exception reason] details: nil]);
    }
}

- (void)alias:(FlutterMethodCall*)call result:(FlutterResult)result {
    @try {
        NSString *alias = call.arguments[@"alias"];
        NSDictionary *options = call.arguments[@"options"];
        [[SEGAnalytics sharedAnalytics] alias: alias
                                      options: options];
        result([NSNumber numberWithBool:YES]);
    }
    @catch (NSException *exception) {
        result([FlutterError errorWithCode:@"FlutterSegmentException" message:[exception reason] details: nil]);
    }
}

- (void)anonymousId:(FlutterResult)result {
    @try {
        NSString *anonymousId = [[SEGAnalytics sharedAnalytics] getAnonymousId];
        result(anonymousId);
    }
    @catch (NSException *exception) {
        result([FlutterError errorWithCode:@"FlutterSegmentException" message:[exception reason] details: nil]);
    }
}

- (void)reset:(FlutterResult)result {
    @try {
        [[SEGAnalytics sharedAnalytics] reset];
        [[SEGAnalytics sharedAnalytics] flush];
        result([NSNumber numberWithBool:YES]);
    }
    @catch (NSException *exception) {
        result([FlutterError errorWithCode:@"FlutterSegmentException" message:[exception reason] details: nil]);
    }
}

- (void)disable:(FlutterResult)result {
    @try {
        [[SEGAnalytics sharedAnalytics] disable];
        result([NSNumber numberWithBool:YES]);
    }
    @catch (NSException *exception) {
        result([FlutterError errorWithCode:@"FlutterSegmentException" message:[exception reason] details: nil]);
    }
}

- (void)enable:(FlutterResult)result {
    @try {
        [[SEGAnalytics sharedAnalytics] enable];
        result([NSNumber numberWithBool:YES]);
    }
    @catch (NSException *exception) {
        result([FlutterError errorWithCode:@"FlutterSegmentException" message:[exception reason] details: nil]);
    }
}

- (void)debug:(FlutterMethodCall*)call result:(FlutterResult)result {
    @try {
        BOOL enabled = call.arguments[@"debug"];
        [SEGAnalytics debug: enabled];
        result([NSNumber numberWithBool:YES]);
    }
    @catch (NSException *exception) {
        result([FlutterError errorWithCode:@"FlutterSegmentException" message:[exception reason] details: nil]);
    }
}


- (void)putDeviceToken:(FlutterMethodCall*)call result:(FlutterResult)result {
    @try {
        NSString *token = call.arguments[@"token"];
        NSData* data = [token dataUsingEncoding:NSUTF8StringEncoding];
        [[SEGAnalytics sharedAnalytics] registeredForRemoteNotificationsWithDeviceToken: data];
        result([NSNumber numberWithBool:YES]);
    }
    @catch (NSException *exception) {
        result([FlutterError errorWithCode:@"FlutterSegmentException" message:[exception reason] details: nil]);
    }
}

@end
