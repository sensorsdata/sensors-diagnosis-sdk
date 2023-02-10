//
//  SensorsDiagnostor.h
//  SensorsDiagnosis
//
//  Created by 陈玉国 on 2022/12/26.
//

#import <Foundation/Foundation.h>
#import "SensorsDiagnosticResolver.h"

NS_ASSUME_NONNULL_BEGIN

@interface SensorsDiagnostor : NSObject <SensorsDiagnosticResolver>

@property (nonatomic, assign) BOOL enable;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, strong) dispatch_queue_t serialQueue;

@end

NS_ASSUME_NONNULL_END
