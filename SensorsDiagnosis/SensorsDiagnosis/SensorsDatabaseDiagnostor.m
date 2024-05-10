//
//  SensorsDatabaseDiagnostor.m
//  SensorsDiagnosis
//
//  Created by 陈玉国 on 2022/12/9.
//

#import "SensorsDatabaseDiagnostor.h"
#import "SensorsDiagnosticInfo.h"

//default table users
NSString *const kSensorsDiagnosticDatabaseNameUsers = @"SensorsDiagnosticUsers";
NSString *const kDatabaseColumnDistinctId = @"distinct_id";
NSString *const kDatabaseColumnUserIdList = @"user_id_list";

//default table infos
NSString *const kSensorsDiagnosticDatabaseNameInfos = @"SensorsDiagnosticInfos";
NSString *const kDatabaseColumnUserId = @"user_id";
NSString *const kDatabaseColumnContent = @"content";
NSString *const kDatabaseColumnBusinessLine = @"business_line";
NSString *const kDatabaseColumnFeature = @"feature";
NSString *const kDatabaseColumnCategory = @"category";
NSString *const kDatabaseColumnCharacteristics = @"characteristics";
NSString *const kDatabaseColumnLevel = @"level";
NSString *const kDatabaseColumnTimestamp = @"timestamp";

@interface SensorsDatabaseDiagnostor ()

@property (nonatomic, copy) NSURL *path;
@property (nonatomic, assign) BOOL isOpened;

@end

@implementation SensorsDatabaseDiagnostor {
    sqlite3 *_database;
    CFMutableDictionaryRef _statementCache;
}

- (instancetype)initWithPath:(NSURL *)path {
    if (self = [super init]) {
        _path = path;
        [self createStatementCache];
        [self createTable];
    }
    return self;
}

//SensorsDiagnositcResolver
- (BOOL)shouldResolveDiagnosticObject:(SensorsDiagnosticObject *)object {
    return [object isKindOfClass:[SensorsDiagnosticInfo class]];
}

-(void)resolveDiagnosticObject:(SensorsDiagnosticObject *)object {
}

- (BOOL)open {
    if (self.isOpened) {
        return YES;
    }
    if (_database) {
        [self close];
    }
    if (!self.path.absoluteString) {
        return NO;
    }
    if (sqlite3_open_v2(self.path.absoluteString.UTF8String, &_database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL) != SQLITE_OK) {
        _database = NULL;
        return NO;
    }
    self.isOpened = YES;
    return YES;
}

- (void)close {
    if (_statementCache) {
        CFRelease(_statementCache);
    }
    _statementCache = NULL;
    if (_database) {
        sqlite3_close(_database);
    }
    _database = NULL;
    _isCreatedTable = NO;
    _isOpened = NO;
}

- (BOOL)createTable {
    return YES;
}

- (BOOL)createTableWithQuery:(NSString *)query {
    return sqlite3_exec(_database, query.UTF8String, NULL, NULL, NULL) == SQLITE_OK;
}

- (sqlite3_stmt *)cachedStatementWithQuery:(NSString *)query {
    if (![query isKindOfClass:[NSString class]] || query.length == 0) {
        return NULL;
    }
    sqlite3_stmt *statement = (sqlite3_stmt *)CFDictionaryGetValue(_statementCache, (__bridge const void *)(query));
    if (statement) {
        sqlite3_reset(statement);
        return statement;
    }
    int result = sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL);
    if (result != SQLITE_OK) {
        sqlite3_finalize(statement);
        return NULL;
    }
    CFDictionarySetValue(_statementCache, (__bridge const void *)(query), statement);
    return statement;
}

- (void)createStatementCache {
    CFDictionaryKeyCallBacks keyCallbacks = kCFCopyStringDictionaryKeyCallBacks;
    CFDictionaryValueCallBacks valueCallbacks = { 0 };
    _statementCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &keyCallbacks, &valueCallbacks);
}

- (BOOL)createColumn:(NSString *)column type:(SensorsDatabaseColumnDataType)type inTable:(NSString *)table {
    if (![column isKindOfClass:[NSString class]] || column.length == 0) {
        return NO;
    }
    if ([self columnExists:column inTable:table]) {
        return YES;
    }
    NSString *datatype = [self datatypeWithType:type];
    NSString *createColumnQuery = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@;", table, column, datatype];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, createColumnQuery.UTF8String, -1, &statement, NULL) != SQLITE_OK) {
        sqlite3_finalize(statement);
        return NO;
    }
    if (sqlite3_step(statement) != SQLITE_DONE) {
        sqlite3_finalize(statement);
        return NO;
    }
    sqlite3_finalize(statement);
    return YES;
}

- (BOOL)createTextColumn:(NSString *)columnName withDefaultValue:(NSString *)defaultValue inTable:(NSString *)table {
    if (![columnName isKindOfClass:[NSString class]] || columnName.length == 0) {
        return NO;
    }
    if (![defaultValue isKindOfClass:[NSString class]] || defaultValue.length == 0) {
        return NO;
    }
    if ([self columnExists:columnName inTable:table]) {
        return YES;
    }
    NSString *createColumnQuery = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT NOT NULL DEFAULT '%@';", table, columnName, defaultValue];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, createColumnQuery.UTF8String, -1, &statement, NULL) != SQLITE_OK) {
        sqlite3_finalize(statement);
        return NO;
    }
    if (sqlite3_step(statement) != SQLITE_DONE) {
        sqlite3_finalize(statement);
        return NO;
    }
    sqlite3_finalize(statement);
    return YES;
}

- (NSString *)datatypeWithType:(SensorsDatabaseColumnDataType)type {
    NSString *datatype = @"INTEGER";
    switch (type) {
        case SensorsDatabaseColumnDataTypeInteger:
            datatype = @"INTEGER";
            break;
        case SensorsDatabaseColumnDataTypeReal:
            datatype = @"REAL";
            break;
        case SensorsDatabaseColumnDataTypeText:
            datatype = @"TEXT";
            break;
        case SensorsDatabaseColumnDataTypeBlob:
            datatype = @"BLOB";
            break;
        default:
            break;
    }
    return datatype;
}

- (BOOL)columnExists:(NSString *)columnName inTable:(NSString *)tableName {
    if (!columnName) {
        return NO;
    }
    return [[self columnsInTable:tableName] containsObject:columnName];
}

- (NSArray<NSString *> *)columnsInTable:(NSString *)table {
    NSMutableArray<NSString *> *columns = [NSMutableArray array];
    NSString *query = [NSString stringWithFormat: @"PRAGMA table_info('%@');", table];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, NULL) != SQLITE_OK) {
        sqlite3_finalize(statement);
        return [columns copy];
    }

    while (sqlite3_step(statement) == SQLITE_ROW) {
        char *name = (char *)sqlite3_column_text(statement, 1);
        if (!name) {
            continue;
        }
        NSString *columnName = [NSString stringWithUTF8String:name];
        if (columnName) {
            [columns addObject:columnName];
        }
    }
    sqlite3_finalize(statement);
    return [columns copy];
}

- (NSString *)errorMessage {
    const char *error = sqlite3_errmsg(_database);
    return error ? [NSString stringWithUTF8String:error] : nil;
}

- (BOOL)executeQuery:(NSString *)query {
    if (![self createTable]) {
        return NO;
    }
    return sqlite3_exec(_database, query.UTF8String, NULL, NULL, NULL) == SQLITE_OK;
}

@end
