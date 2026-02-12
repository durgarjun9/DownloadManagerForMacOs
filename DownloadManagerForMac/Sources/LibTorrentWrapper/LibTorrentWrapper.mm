#import "LibTorrentWrapper.h"
#include <libtorrent/session.hpp>
#include <libtorrent/add_torrent_params.hpp>
#include <libtorrent/torrent_handle.hpp>
#include <libtorrent/magnet_uri.hpp>
#include <libtorrent/alert_types.hpp>
#include <libtorrent/settings_pack.hpp>
#include <vector>
#include <map>

@implementation TorrentManager {
    lt::session *session;
    std::map<NSString *, lt::torrent_handle> handles;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        lt::settings_pack pack;
        // Optimized for high speed
        pack.set_int(lt::settings_pack::active_downloads, 10);
        pack.set_int(lt::settings_pack::active_seeds, 5);
        pack.set_int(lt::settings_pack::cache_size, 512 * 64); // 32MB cache
        
        session = new lt::session(pack);
    }
    return self;
}

- (void)addTorrentWithMagnet:(NSString *)magnet withSavePath:(NSString *)path {
    lt::add_torrent_params p = lt::parse_magnet_uri([magnet UTF8String]);
    p.save_path = [path UTF8String];
    
    lt::torrent_handle h = session->add_torrent(p);
    handles[magnet] = h;
}

- (float)getDownloadProgressForMagnet:(NSString *)magnet {
    if (handles.count(magnet)) {
        lt::torrent_status s = handles[magnet].status();
        return s.progress;
    }
    return 0.0;
}

- (double)getDownloadSpeedForMagnet:(NSString *)magnet {
    if (handles.count(magnet)) {
        lt::torrent_status s = handles[magnet].status();
        return (double)s.download_rate;
    }
    return 0.0;
}

- (NSString *)getNameForMagnet:(NSString *)magnet {
    if (handles.count(magnet)) {
        lt::torrent_status s = handles[magnet].status();
        if (!s.name.empty()) {
            return [NSString stringWithUTF8String:s.name.c_str()];
        }
    }
    return @"";
}

- (long long)getTotalSizeForMagnet:(NSString *)magnet {
    if (handles.count(magnet)) {
        lt::torrent_status s = handles[magnet].status();
        return (long long)s.total_wanted;
    }
    return 0;
}

- (void)stopAll {
    delete session;
}

@end
