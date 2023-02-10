//
//  SensorsDiagnositcResolver.h
//  SensorsDiagnosis
//
//  Created by 陈玉国 on 2022/12/26.
//
#import <Foundation/Foundation.h>

@class SensorsDiagnosticObject;
@class SensorsDiagnosticCondition;

@protocol SensorsDiagnosticResolver <NSObject>

- (BOOL)shouldResolveDiagnosticObject:(SensorsDiagnosticObject *)object;
- (void)flushWithCondition:(SensorsDiagnosticCondition *)condition;
- (void)resolveDiagnosticObject:(SensorsDiagnosticObject *)object;

@end

@protocol SensorsDiagnosticFormatter <NSObject>

- (NSString *)formattedDiagnosticObject:(SensorsDiagnosticObject *)object;

@end
