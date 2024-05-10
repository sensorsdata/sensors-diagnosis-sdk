//
//  SensorsDiagnosis.m
//  SensorsDiagnosis
//
//  Created by 陈玉国 on 2022/12/9.
//

#import "SensorsDiagnosis.h"
#import "SensorsDefaultConsoleDiagnostor.h"
#import "SensorsDiagnosticConsoleLog.h"
#import "SensorsDiagnosticConstants.h"


@interface SensorsDiagnosis ()

@property (nonatomic, strong) NSMutableArray<SensorsDiagnostor *> *diagnostors;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) dispatch_semaphore_t resolveSemaphore;
@property (nonatomic, strong) dispatch_semaphore_t flushSemaphore;
@property (nonatomic, assign) NSUInteger maxConcurrentCount;
@property (nonatomic, strong) dispatch_group_t resolveGroup;
@property (nonatomic, strong) dispatch_group_t flushGroup;

@end

@implementation SensorsDiagnosis

+ (instancetype)sharedInstance {
    static SensorsDiagnosis *sharedDiagnosis = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDiagnosis = [[SensorsDiagnosis alloc] init];
        [sharedDiagnosis addDiagnostor:[[SensorsDefaultConsoleDiagnostor alloc] init]];
    });
    return sharedDiagnosis;
}

- (instancetype)init {
    if (self = [super init]) {
        _queue = dispatch_queue_create("cn.sensorsdata.SensorsDiagnosisQueue", DISPATCH_QUEUE_SERIAL);
        _maxConcurrentCount = 10;
        _resolveSemaphore = dispatch_semaphore_create(_maxConcurrentCount);
        _flushSemaphore = dispatch_semaphore_create(_maxConcurrentCount);
        _resolveGroup = dispatch_group_create();
        _flushGroup = dispatch_group_create();
        _enable = YES;
    }
    return self;
}

-(void)addDiagnostor:(SensorsDiagnostor *)diagnostor {
    if (!diagnostor) {
        return;
    }
    dispatch_async(self.queue, ^{
        [self.diagnostors addObject:diagnostor];
    });
}

-(void)removeDiagnostor:(SensorsDiagnostor *)diagnostor {
    if (!diagnostor) {
        return;
    }
    dispatch_async(self.queue, ^{
        [self.diagnostors removeObject:diagnostor];
    });
}

-(void)removeDiagnostorWithIdentifier:(NSString *)identifier {
    if (!identifier) {
        return;
    }
    dispatch_async(self.queue, ^{
        [self.diagnostors enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(SensorsDiagnostor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.identifier isEqualToString:identifier]) {
                [self.diagnostors removeObject:obj];
                *stop = YES;
            }
        }];
    });
}

-(void)addDiagnosticObject:(SensorsDiagnosticObject *)object {
    if (!self.enable) {
        return;
    }
    [self queueResolveDiagnosticObject:object];
}

-(void)flushWithCondition:(SensorsDiagnosticCondition *)condition {
    if (!self.enable) {
        return;
    }
    [self queueFlushObjectWithCondition:condition];
}

- (void)queueFlushObjectWithCondition:(SensorsDiagnosticCondition *)condition {
    dispatch_block_t flushBlock = ^{
        dispatch_semaphore_wait(self.flushSemaphore, DISPATCH_TIME_FOREVER);
        @autoreleasepool {
            [self flushObjectWithCondition:condition];
        }
    };
    dispatch_async(self.queue, flushBlock);
}

- (void)flushObjectWithCondition:(SensorsDiagnosticCondition *)condition {
    for (SensorsDiagnostor *diagnostor in self.diagnostors) {
        dispatch_group_async(self.flushGroup, diagnostor.serialQueue, ^{
            @autoreleasepool {
                [diagnostor flushWithCondition:condition];
            }
        });
        dispatch_group_wait(self.flushGroup, DISPATCH_TIME_FOREVER);
    }
    dispatch_semaphore_signal(self.flushSemaphore);
}

-(SensorsDiagnostor *)diagnostorWithIdentifier:(NSString *)identifier {
    if (!identifier) {
        return nil;
    }
    for (SensorsDiagnostor *diagnostor in self.diagnostors) {
        if ([diagnostor.identifier isEqualToString:identifier]) {
            return diagnostor;
        }
    }
    return nil;
}

- (void)queueResolveDiagnosticObject:(SensorsDiagnosticObject *)object {
    dispatch_block_t resolveBlock = ^{
        dispatch_semaphore_wait(self.resolveSemaphore, DISPATCH_TIME_FOREVER);
        @autoreleasepool {
            [self resolveDiagnosticObject:object];
        }
    };
    dispatch_async(self.queue, resolveBlock);
}

- (void)resolveDiagnosticObject:(SensorsDiagnosticObject *)object {
    for (SensorsDiagnostor *diagnostor in self.diagnostors) {
        dispatch_group_async(self.resolveGroup, diagnostor.serialQueue, ^{
            @autoreleasepool {
                [diagnostor resolveDiagnosticObject:object];
            }
        });
        dispatch_group_wait(self.resolveGroup, DISPATCH_TIME_FOREVER);
    }
    dispatch_semaphore_signal(self.resolveSemaphore);
}

-(NSMutableArray<SensorsDiagnostor *> *)diagnostors {
    if (!_diagnostors) {
        _diagnostors = [NSMutableArray array];
    }
    return _diagnostors;
}

- (void)log:(SensorsDiagnosticInfoLevel)level file:(const char *)file function:(const char *)function line:(NSUInteger)line format:(NSString *)format, ... {
#if TARGET_OS_IOS
#ifndef DEBUG
    //in iOS10, initWithFormat: arguments: crashed when format string contain special char "%" but no escaped, like "%2434343%rfrfrfrf%".
    if ([[[UIDevice currentDevice] systemVersion] integerValue] == 10) {
        return;
    }
#endif
#endif
    if (!format) {
        return;
    }

    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    SensorsDiagnosticConsoleLog *logObject = [[SensorsDiagnosticConsoleLog alloc] init];
    logObject.category = kSensorsConsoleLogDefaultCategory;
    logObject.level = level;
    logObject.content = @{kSensorsConsoleLogFieldFile: [NSString stringWithUTF8String:file], kSensorsConsoleLogFieldFunction: [NSString stringWithUTF8String:function], kSensorsConsoleLogFieldLine: [NSString stringWithFormat:@"%lu", line], kSensorsConsoleLogFieldMessage: message};
    [[SensorsDiagnosis sharedInstance] addDiagnosticObject:logObject];
}

+ (NSString *)version {
    return kSensorsDiagnosisSDKVersion;
}

@end
