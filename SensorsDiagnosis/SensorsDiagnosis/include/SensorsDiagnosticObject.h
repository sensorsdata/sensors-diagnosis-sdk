//
//  SensorsDiagnosticObject.h
//  SensorsDiagnosis
//
//  Created by 陈玉国 on 2022/12/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SensorsDiagnosticInfoLevel) {
    SensorsDiagnosticInfoLevelError,
    SensorsDiagnosticInfoLevelWarn,
    SensorsDiagnosticInfoLevelInfo,
    SensorsDiagnosticInfoLevelDebug,
    SensorsDiagnosticInfoLevelVerbose
};

@interface SensorsDiagnosticObject : NSObject

@property (nonatomic, copy) NSDictionary *content;
@property (nonatomic, assign) SensorsDiagnosticInfoLevel level;
@property (nonatomic, assign) NSTimeInterval timestamp;

@end

NS_ASSUME_NONNULL_END
