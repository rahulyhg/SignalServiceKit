//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import "OWSOutgoingNullMessage.h"
#import "OWSSignalServiceProtos.pb.h"
#import "Cryptography.h"
#import "OWSVerificationStateSyncMessage.h"
#import "NSDate+millisecondTimeStamp.h"
#import "TSContactThread.h"

NS_ASSUME_NONNULL_BEGIN

@interface OWSOutgoingNullMessage ()

@property (nonatomic, readonly) OWSVerificationStateSyncMessage *verificationStateSyncMessage;

@end

@implementation OWSOutgoingNullMessage

- (instancetype)initWithContactThread:(TSContactThread *)contactThread
         verificationStateSyncMessage:(OWSVerificationStateSyncMessage *)verificationStateSyncMessage
{
    self = [super initWithTimestamp:[NSDate ows_millisecondTimeStamp]
                           inThread:contactThread];
    if (!self) {
        return self;
    }
    
    _verificationStateSyncMessage = verificationStateSyncMessage;
    
    return self;
}

#pragma mark - override TSOutgoingMessage

- (NSData *)buildPlainTextData
{
    OWSSignalServiceProtosContentBuilder *contentBuilder = [OWSSignalServiceProtosContentBuilder new];
    OWSSignalServiceProtosNullMessageBuilder *nullMessageBuilder = [OWSSignalServiceProtosNullMessageBuilder new];

    NSUInteger contentLength = self.verificationStateSyncMessage.buildPlainTextData.length;
    contentLength -= self.verificationStateSyncMessage.paddingBytesLength;
    
    OWSAssert(contentLength > 0)
    
    nullMessageBuilder.padding = [Cryptography generateRandomBytes:contentLength];
    
    contentBuilder.nullMessage = [nullMessageBuilder build];
    
    return [contentBuilder build].data;
}

- (BOOL)shouldSyncTranscript
{
    return NO;
}

- (void)saveWithTransaction:(YapDatabaseReadWriteTransaction *)transaction
{
    // No-op as we don't want to actually display this as an outgoing message in our thread.
    return;
}

@end

NS_ASSUME_NONNULL_END