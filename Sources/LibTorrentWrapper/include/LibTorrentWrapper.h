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
- (void)pauseTorrentForMagnet:(NSString *)magnet NS_SWIFT_NAME(pauseTorrent(forMagnet:));
- (void)resumeTorrentForMagnet:(NSString *)magnet NS_SWIFT_NAME(resumeTorrent(forMagnet:));
- (void)removeTorrentForMagnet:(NSString *)magnet NS_SWIFT_NAME(removeTorrent(forMagnet:));
- (void)setDownloadLimit:(int)bytesPerSecond NS_SWIFT_NAME(setDownloadLimit(_:));
- (void)setUploadLimit:(int)bytesPerSecond NS_SWIFT_NAME(setUploadLimit(_:));
- (void)stopAll;

@end

#endif
