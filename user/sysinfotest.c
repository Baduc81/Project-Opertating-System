#include "kernel/sysinfo.h"
#include "kernel/types.h"
#include "user/user.h"

void sysinfotest() {
    struct sysinfo info1, info2;    // Khai báo hai biến lưu thông tin sysinfo
    char *mem;                      // Biến dùng để cấp phát bộ nhớ

    // Gọi sysinfo lần đầu để lấy thông tin ban đầu.
    // Nếu gọi sysinfo thất bại (trả về giá trị nhỏ hơn 0), in thông báo lỗi và thoát chương trình với mã lỗi 1.
    if (sysinfo(&info1) < 0) {
        printf("sysinfotest: sysinfo failed (initial)\n");
        exit(1);
    }

    // Kiểm tra giá trị ban đầu.
    if (info1.freemem <= 0 || info1.nproc <= 0) {
        printf("sysinfotest: invalid initial freemem or nproc\n");
        exit(1);
    }

    // *** Kiểm tra bộ nhớ ***
    // Cấp phát một lượng lớn bộ nhớ.
    /*
    Hàm sbrk thay đổi dung lượng bộ nhớ của tiến trình.
    Nếu sbrk trả về (char *)-1, tức là cấp phát bộ nhớ thất bại, in thông báo lỗi và thoát chương trình.
    */
    mem = sbrk(4096);  // Cấp phát 1 trang (4 KB).
    if (mem == (char *)-1) {
        printf("sysinfotest: sbrk failed\n");
        exit(1);
    }

    // Gọi sysinfo lần thứ hai.
    if (sysinfo(&info2) < 0) {
        printf("sysinfotest: sysinfo failed (after allocation)\n");
        exit(1);
    }

    // Kiểm tra bộ nhớ sau khi cấp phát.
    // Kiểm tra xem bộ nhớ trống (freemem) có giảm đi sau khi cấp phát bộ nhớ hay không. 
    // Nếu không, in thông báo lỗi và thoát chương trình.
    if (info2.freemem >= info1.freemem) {
        printf("sysinfotest: freemem did not decrease after allocation\n");
        exit(1);
    }

    // Thu hồi bộ nhớ.
    sbrk(-4096);

    // Gọi sysinfo lần thứ ba để kiểm tra bộ nhớ được thu hồi.
    if (sysinfo(&info2) < 0) {
        printf("sysinfotest: sysinfo failed (after free)\n");
        exit(1);
    }

    // Kiểm tra xem bộ nhớ trống (freemem) có được phục hồi về giá trị ban đầu sau khi thu hồi bộ nhớ không.
    if (info2.freemem != info1.freemem) {
        printf("sysinfotest: freemem did not restore after free\n");
        exit(1);
    }

    // *** Kiểm tra tiến trình ***
    // Tạo tiến trình con.
    int pid = fork();
    if (pid < 0) {
        printf("sysinfotest: fork failed\n");
        exit(1);
    }

    if (pid == 0) {
        // Tiến trình con chỉ tồn tại trong thời gian ngắn.
        exit(0);
    }

    // Gọi sysinfo lần thứ tư khi có thêm tiến trình.
    if (sysinfo(&info2) < 0) {
        printf("sysinfotest: sysinfo failed (after fork)\n");
        exit(1);
    }

    // Gọi sysinfo lần thứ tư sau khi tạo tiến trình con để kiểm tra xem số lượng tiến trình (nproc) có thay đổi không.
    if (info2.nproc != info1.nproc + 1) {
        printf("sysinfotest: nproc did not increase after fork\n");
        exit(1);
    }

    // Chờ tiến trình con kết thúc.
    wait(0);

    // Gọi sysinfo lần cuối cùng để kiểm tra số tiến trình trở về ban đầu.
    if (sysinfo(&info2) < 0) {
        printf("sysinfotest: sysinfo failed (after wait)\n");
        exit(1);
    }

    if (info2.nproc != info1.nproc) {
        printf("sysinfotest: nproc did not restore after child exit\n");
        exit(1);
    }

    // Nếu mọi kiểm tra đều thành công.
    printf("sysinfotest: OK\n");
    // exit(0);
}

int main(int argc, char *argv[]) {
    sysinfotest();

    struct sysinfo info;

    if (sysinfo(&info) < 0) {
        printf("sysinfo failed\n");
        exit(1);
    }

    printf("Free memory: %lu bytes\n", info.freemem);
    printf("Number of processes: %lu\n", info.nproc);
    printf("Load average (x100): %lu\n", info.loadavg);
    exit(0);
}