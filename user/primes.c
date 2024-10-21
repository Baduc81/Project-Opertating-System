#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

// Hàm xử lý sàng lọc nguyên tố sử dụng pipe
//void primes(int fd) __attribute__((noreturn)); // Khai báo để tránh lỗi đệ quy vô hạn

void primes(int fd) {
    int num;

    if (read(fd, &num, 4) != 4) {
        close(fd);
        return;
    }

    printf("prime %d\n", num);

    int p[2];
    pipe(p);
    int tmp;

    while (1) {
        int n = read(fd, &tmp, 4);
        if (n <= 0) {
            break; // Không còn số để đọc từ pipe
        }
        if (tmp % num != 0) {
            write(p[1], &tmp, 4); // Ghi số vào pipe nếu không chia hết cho `num`
        }
    }

    close(fd);  // Đóng pipe hiện tại
    close(p[1]); // Đóng đầu ghi của pipe mới

    if (fork() == 0) {
        // Process con: tiếp tục xử lý với các số nguyên còn lại
        close(p[1]); // Đầu ghi của process con đã được đóng
        primes(p[0]); // Gọi đệ quy để xử lý tiếp
        // Không cần close(p[0]) ở đây vì exec_pipe không bao giờ trở về
    } else {
        // Process cha: đợi process con hoàn thành
        close(p[0]); // Đóng đầu đọc của pipe
        wait(0); // Đợi process con kết thúc
    }

    // Chương trình cha chỉ thoát sau khi tất cả tiến trình con đã hoàn thành
    exit(0);
}

int main(int argc, char *argv[]) {
    int p[2];
    pipe(p); // Tạo pipe

    // Ghi các số từ 2 đến 280 vào pipe
    for (int i = 2; i <= 100; i++) { 
        write(p[1], &i, 4); // Ghi số nguyên trực tiếp vào pipe
    }
    close(p[1]); // Đóng đầu ghi sau khi hoàn thành ghi các số

    primes(p[0]); // Gọi hàm exec_pipe để bắt đầu sàng lọc
    close(p[0]); // Đóng đầu đọc của pipe sau khi hoàn thành

    // Chương trình chính chỉ thoát sau khi tất cả đầu ra đã được in và tất cả các quy trình số nguyên tố khác đã thoát.
    exit(0); // Kết thúc chương trình chính
}
