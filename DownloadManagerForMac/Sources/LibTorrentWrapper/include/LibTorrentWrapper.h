#ifndef LIBTORRENT_WRAPPER_H
#define LIBTORRENT_WRAPPER_H

#import <Foundation/Foundation.h>

@interface TorrentManager : NSObject

- (instancetype)init;
- (void)addTorrentWithMagnet:(NSString *)magnet withSavePath:(NSString *)path NS_SWIFT_NAME(addTorrent(withMagnet:withSavePath:));
- (float)getDownloadProgressForMagnet:(NSString *)magnet NS_SWIFT_NAME(downloadProgress(forMagnet:));
- (double)getDownloadSpeedForMagnet:(NSString *)magnet NS_SWIFT_NAME(downloadSpeed(forMagnet:));
- (NSString *)getNameForMagnet:(NSString *)magnet NS_SWIFT_NAME(name(forMagnet:));
- (long long)getTotalSizeForMagnet:(NSString *)magnet NS_SWIFT_NAME(totalSize(forMagnet:));
- (void)stopAll;

@end

#endif
