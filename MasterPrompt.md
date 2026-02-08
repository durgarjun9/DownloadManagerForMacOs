# The Master Prompt
--- 

** Task ** :Architect and develop a high-performance, native macOS Download Manager named "DownloadManagerForMac."
This application need to download files super fast.

---

## Core Requirements

### Dual-Engine Support

> * HTTP/S Engine: Implement a multi-threaded downloader using URLSession and Range headers to split files into 8+ parallel segments.
> * Torrent Engine: Integrate libtorrent-rasterbar (C++) to handle .torrent and magnet links via a Swift-to-C++ wrapper.

### Performance Optimizations

> * Implement Dynamic Segmentation for HTTP downloads to re-assign slow chunks.
> * Enable Sequential Downloading and Rarest-First logic for torrents.
> * Use Zero-Copy I/O or direct disk pre-allocation to maximize SSD write speeds and minimize CPU overhead.

### The UI (SwiftUI)

> * Create a modern, translucent macOS sidebar interface.
> * Provide a "Main Dashboard" showing active transfers, download speeds, and estimated completion times.
> * Include a "Global Speed Limiter" and "Priority Toggle" for specific files.
> * Provide a "Download Queue" showing the list of files to be downloaded.
> * Provide a "Settings" view for configuring the download manager.
> * Provide a "History" view for viewing completed downloads.
> * Provide a "Search" view for searching for files to download.
> * Provide a "Details" view for viewing the details of a specific download.


### Deliverables

> * A Swift "DownloadManager" class that acts as a bridge between the two engines.
> * A SwiftUI view for the download queue.
> * The configuration settings for libtorrent to ensure it is tuned for high-speed fiber connections (high peer limits and optimized cache).