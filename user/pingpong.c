#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
  int p[2];
  char buf[100];

  // Tạo pipe
  pipe(p);

  // Tạo tiến trình con
  int pid = fork();
  if (pid == 0) {
    // Tiến trình con: gửi tin nhắn cho tiến trình cha
    write(p[1], "ping", 4);  // Ghi "ping" vào pipe
    printf("Thread id %d: received ping\n", getpid());
  } 
  else {
    // Tiến trình cha: đợi tiến trình con, sau đó đọc tin nhắn
    wait(0);  // Đợi tiến trình con kết thúc
    read(p[0], buf, 4);  // Đọc "ping" từ pipe
    printf("Thread id %d: received pong\n", getpid());
  }

  return 0;
}
