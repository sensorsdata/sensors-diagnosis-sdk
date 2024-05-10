//
//  SensorsDatabaseDiagnostor.h
//  SensorsDiagnosis
//
//  Created by 陈玉国 on 2022/12/9.
//

#import "SensorsDiagnostor.h"
#import "SensorsDiagnosticResolver.h"
#import <sqlite3.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kSensorsDiagnosticDatabaseNameUsers;
extern NSString *const kDatabaseColumnDistinctId;
extern NSString *const kDatabaseColumnUserIdList;
extern NSString *const kSensorsDiagnosticDatabaseNameInfos;
extern NSString *const kDatabaseColumnUserId;
extern NSString *const kDatabaseColumnContent;
extern NSString *const kDatabaseColumnBusinessLine;
extern NSString *const kDatabaseColumnFeature;
extern NSString *const kDatabaseColumnCategory;
extern NSString *const kDatabaseColumnCharacteristics;
extern NSString *const kDatabaseColumnLevel;
extern NSString *const kDatabaseColumnTimestamp;

typedef enum : NSUInteger {
    SensorsDatabaseColumnDataTypeInteger,
    SensorsDatabaseColumnDataTypeText,
    SensorsDatabaseColumnDataTypeBlob,
    SensorsDatabaseColumnDataTypeReal
} SensorsDatabaseColumnDataType;

@interface SensorsDatabaseDiagnostor : SensorsDiagnostor <SensorsDiagnosticResolver>

@property (nonatomic, assign) BOOL isCreatedTable;

-(instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithPath:(NSURL *)path NS_DESIGNATED_INITIALIZER;

- (BOOL)createTable;

- (BOOL)createColumn:(NSString *)column type:(SensorsDatabaseColumnDataType)type inTable:(NSString *)table;

- (BOOL)createTextColumn:(NSString *)columnName withDefaultValue:(NSString *)defaultValue inTable:(NSString *)table;

- (sqlite3_stmt *)cachedStatementWithQuery:(NSString *)query;

- (BOOL)createTableWithQuery:(NSString *)query;
- (BOOL)open;

/// database error if exists
- (NSString *)errorMessage;

- (BOOL)executeQuery:(NSString *)query;

@end

NS_ASSUME_NONNULL_END
