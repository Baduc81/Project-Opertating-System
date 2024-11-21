/*
Tất cả các file cần sử dụng struct sysinfo đều đã 
#include "kernel/types.h" để định nghĩa uint64.
nên ở đây không cần định nghĩa thư viện
*/
#include "types.h"  // Đảm bảo bao gồm file này để định nghĩa uint64

struct sysinfo {
    uint64 freemem;  // Bộ nhớ trống, tính bằng byte.
    uint64 nproc;    // Số lượng tiến trình hoạt động.
};
