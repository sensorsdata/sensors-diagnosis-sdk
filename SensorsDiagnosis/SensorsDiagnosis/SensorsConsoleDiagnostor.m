//
//  SensorsConsoleDiagnostor.m
//  SensorsDiagnosis
//
//  Created by 陈玉国 on 2022/12/9.
//

#import "SensorsConsoleDiagnostor.h"
#import "SensorsDiagnosticConsoleLogFormatter.h"
#import <sys/uio.h>

@interface SensorsConsoleDiagnostor ()

@property (nonatomic, strong) SensorsDiagnosticConsoleLogFormatter *formatter;

@end

@implementation SensorsConsoleDiagnostor

- (instancetype)init {
    if (self = [super init]) {
        _maxStackSize = 1024 * 4;
        _formatter = [[SensorsDiagnosticConsoleLogFormatter alloc] init];
    }
    return self;
}

- (BOOL)shouldResolveDiagnosticObject:(SensorsDiagnosticObject *)object {
    if (![object isKindOfClass:[SensorsDiagnosticConsoleLog class]]) {
        return NO;
    }
    return YES;
}

- (void)resolveDiagnosticObject:(SensorsDiagnosticObject *)object {
    if (![self shouldResolveDiagnosticObject:object]) {
        return;
    }

    NSString *formattedMessage = [self.formatter formattedDiagnosticObject:object];
    [self outputMessage:formattedMessage];
}

- (void)outputMessage:(NSString *)message {
    NSUInteger messageLength = [message lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    BOOL useStack = messageLength < _maxStackSize;
    char messageStack[useStack ? (messageLength + 1) : 1];
    char *msg = useStack ? messageStack : (char *)calloc(messageLength + 1, sizeof(char));

    if (msg == NULL) {
        return;
    }

    BOOL canBeConvertedToEncoding = [message getCString:msg maxLength:(messageLength + 1) encoding:NSUTF8StringEncoding];

    if (!canBeConvertedToEncoding) {
        // free memory if not use stack
        if (!useStack) {
            free(msg);
        }
        return;
    }

    struct iovec dataBuffer[1];
    dataBuffer[0].iov_base = msg;
    dataBuffer[0].iov_len = messageLength;
    writev(STDERR_FILENO, dataBuffer, 1);

    // free memory if not use stack
    if (!useStack) {
        free(msg);
    }
}

@end
