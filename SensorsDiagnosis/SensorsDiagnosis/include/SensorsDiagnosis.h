//
//  SensorsDiagnosis.h
//  SensorsDiagnosis
//
//  Created by 陈玉国 on 2022/12/9.
//

#import <Foundation/Foundation.h>
#import "SensorsDiagnostor.h"
#import "SensorsDiagnosticObject.h"
#import "SensorsDatabaseDiagnostor.h"
#import "SensorsDiagnosticInfo.h"
#import "SensorsDiagnosticCondition.h"

#define SENSORS_DIADNOSIS_LOG_MACRO(lvl, fnct, frmt, ...) \
[[SensorsDiagnosis sharedInstance] log : lvl                    \
      file : __FILE__                                           \
  function : fnct                                               \
      line : __LINE__                                           \
    format : (frmt), ## __VA_ARGS__]


#define SensorsLogError(frmt, ...)   SENSORS_DIADNOSIS_LOG_MACRO(SensorsDiagnosticInfoLevelError, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define SensorsLogWarn(frmt, ...)   SENSORS_DIADNOSIS_LOG_MACRO(SensorsDiagnosticInfoLevelWarn, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define SensorsLogInfo(frmt, ...)   SENSORS_DIADNOSIS_LOG_MACRO(SensorsDiagnosticInfoLevelInfo, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define SensorsLogDebug(frmt, ...)   SENSORS_DIADNOSIS_LOG_MACRO(SensorsDiagnosticInfoLevelDebug, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define SensorsLogVerbose(frmt, ...)   SENSORS_DIADNOSIS_LOG_MACRO(SensorsDiagnosticInfoLevelVerbose, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

NS_ASSUME_NONNULL_BEGIN

@interface SensorsDiagnosis : NSObject

+ (instancetype)sharedInstance;
- (void)addDiagnostor:(SensorsDiagnostor *)diagnostor;
- (void)removeDiagnostor:(SensorsDiagnostor *)diagnostor;
- (void)removeDiagnostorWithIdentifier:(NSString *)identifier;
- (void)addDiagnosticObject:(SensorsDiagnosticObject *)object;
- (void)flushWithCondition:(SensorsDiagnosticCondition *)condition;
- (SensorsDiagnostor * _Nullable)diagnostorWithIdentifier:(nullable NSString *)identifier;

// enable sensors diagnosis, default value is YES
@property (nonatomic, assign) BOOL enable;

- (void)log:(SensorsDiagnosticInfoLevel)level file:(const char*)file function:(const char*)function line:(NSUInteger)line format:(NSString *)format, ... NS_FORMAT_FUNCTION(5, 6);

@end

NS_ASSUME_NONNULL_END
