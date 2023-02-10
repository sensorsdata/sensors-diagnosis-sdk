//
//  SensorsDiagnosticObject.m
//  SensorsDiagnosis
//
//  Created by 陈玉国 on 2022/12/26.
//

#import "SensorsDiagnosticObject.h"

@implementation SensorsDiagnosticObject

- (instancetype)init {
    if (self = [super init]) {
        _timestamp = [[NSDate date] timeIntervalSince1970];
        _level = SensorsDiagnosticInfoLevelInfo;
    }
    return self;
}

@end
