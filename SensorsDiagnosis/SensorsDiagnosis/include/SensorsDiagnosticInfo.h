//
//  SensorsDiagnosticInfo.h
//  SensorsDiagnosis
//
//  Created by 陈玉国 on 2022/12/9.
//

#import <SensorsDiagnosis/SensorsDiagnosis.h>

NS_ASSUME_NONNULL_BEGIN

@interface SensorsDiagnosticInfo : SensorsDiagnosticObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *businessLine;
@property (nonatomic, copy) NSString *feature;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *characteristics;

@end

NS_ASSUME_NONNULL_END
