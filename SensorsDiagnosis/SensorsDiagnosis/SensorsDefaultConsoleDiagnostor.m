//
//  SensorsDefaultConsoleDiagnostor.m
//  SensorsDiagnosis
//
//  Created by 陈玉国 on 2022/12/21.
//

#import "SensorsDefaultConsoleDiagnostor.h"
#import "SensorsDiagnosticConstants.h"

@implementation SensorsDefaultConsoleDiagnostor

- (instancetype)init {
    if (self = [super init]) {
        self.serialQueue = dispatch_queue_create("cn.sensorsdata.SensorsDefaultConsoleDiagnostorQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(BOOL)shouldResolveDiagnosticObject:(SensorsDiagnosticObject *)object {
    if (![object isKindOfClass:[SensorsDiagnosticConsoleLog class]]) {
        return NO;
    }
    SensorsDiagnosticConsoleLog *consoleObject = (SensorsDiagnosticConsoleLog *)object;
    return [consoleObject.category isEqualToString:kSensorsConsoleLogDefaultCategory];
}
@end
