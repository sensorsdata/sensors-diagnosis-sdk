//
//  SensorsDiagnosticConsoleLogFormatter.m
//  SensorsDiagnosis
//
//  Created by 陈玉国 on 2022/12/16.
//

#import "SensorsDiagnosticConsoleLogFormatter.h"
#import "SensorsDiagnosticConsoleLog.h"
#import "SensorsDiagnosticConstants.h"

@interface SensorsDiagnosticConsoleLogFormatter ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation SensorsDiagnosticConsoleLogFormatter

- (instancetype)init {
    if (self = [super init]) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSSSSSZ";
    }
    return self;
}

- (nonnull NSString *)formattedDiagnosticObject:(nonnull SensorsDiagnosticObject *)object {
    NSString *formattedString = @"";
    if (![object isKindOfClass:[SensorsDiagnosticConsoleLog class]]) {
        return formattedString;
    }
    NSDictionary *content = object.content;
    if (!content) {
        return formattedString;
    }

    NSString *date = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:object.timestamp]];
    NSString *file = content[kSensorsConsoleLogFieldFile];
    NSString *function = content[kSensorsConsoleLogFieldFunction];
    NSString *line = content[kSensorsConsoleLogFieldLine];
    NSString *message = content[kSensorsConsoleLogFieldMessage];
    NSString *prefixEmoji = @"";
    NSString *levelString = @"";
    switch (object.level) {
        case SensorsDiagnosticInfoLevelError:
            prefixEmoji = @"❌";
            levelString = @"Error";
            break;
        case SensorsDiagnosticInfoLevelWarn:
            prefixEmoji = @"⚠️";
            levelString = @"Warn";
            break;
        case SensorsDiagnosticInfoLevelInfo:
            prefixEmoji = @"ℹ️";
            levelString = @"Info";
            break;
        case SensorsDiagnosticInfoLevelDebug:
            prefixEmoji = @"🛠";
            levelString = @"Debug";
            break;
        case SensorsDiagnosticInfoLevelVerbose:
            prefixEmoji = @"📝";
            levelString = @"Verbose";
            break;
        default:
            break;
    }
    return [NSString stringWithFormat:@"%@ %@ %@ %@ %@ line:%@ %@\n", date, prefixEmoji, levelString, file, function, line, message];
}

@end
