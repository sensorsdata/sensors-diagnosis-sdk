//
//  SensorsConsoleDiagnostor.h
//  SensorsDiagnosis
//
//  Created by 陈玉国 on 2022/12/9.
//

#import "SensorsDiagnosticConsoleLog.h"

NS_ASSUME_NONNULL_BEGIN

@interface SensorsConsoleDiagnostor : SensorsDiagnostor <SensorsDiagnosticResolver>

@property (nonatomic, assign) NSUInteger maxStackSize;

@end

NS_ASSUME_NONNULL_END
