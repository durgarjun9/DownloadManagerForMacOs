#ifndef LIBTORRENT_WRAPPER_H
#define LIBTORRENT_WRAPPER_H

#import <Foundation/Foundation.h>

@interface TorrentManager : NSObject

- (instancetype)init;
- (void)addTorrentWithMagnet:(NSString *)magnet withSavePath:(NSString *)path;
- (float)getDownloadProgressForMagnet:(NSString *)magnet;
- (void)stopAll;

@end

#endif
