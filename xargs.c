#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/param.h"

#define BUFFER_SIZE 512

int main(int argc, char *argv[]) {
    char buffer[BUFFER_SIZE];
    char *cmd_argv[MAXARG];  // Mảng đối số cho lệnh
    int n, pid;
    int i, j;

    if (argc < 2){
        fprintf(2, "Not have enough input");
        exit(1);
    }
    for (int i = 0; i < n - 1; i++){
        cmd_argv[i] = argv[i + 1];
    }

    cmd_argv[n - 1] = 0;
    
    exit(0);
}
