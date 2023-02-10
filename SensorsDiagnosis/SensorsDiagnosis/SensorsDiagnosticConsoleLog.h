//
//  SensorsDiagnosticConsoleLog.h
//  SensorsDiagnosis
//
//  Created by 陈玉国 on 2022/12/14.
//

#import <SensorsDiagnosis/SensorsDiagnosis.h>

NS_ASSUME_NONNULL_BEGIN

@interface SensorsDiagnosticConsoleLog : SensorsDiagnosticObject

//use category to differentiate console logs
@property (nonatomic, copy) NSString *category;

@end

NS_ASSUME_NONNULL_END
