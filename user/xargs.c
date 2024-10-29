#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/param.h"

#define BUFFER_SIZE 512

int main(int argc, char *argv[]) {
    char buffer[BUFFER_SIZE];
    char *cmd_argv[MAXARG];  // Mảng đối số cho lệnh
    int n; //, pid;
    // int i, j;

    if (argc < 2){
        fprintf(2, "Not have enough input");
        exit(1);
    }
    for (int i = 0; i < argc - 1; i++){
        cmd_argv[i] = argv[i + 1];
    }

    cmd_argv[argc - 1] = 0;
    
    
    while ((n = read(0, buffer, sizeof(buffer))) > 0){
        int i = 0;
        while (i < n){
            char line[BUFFER_SIZE];
            int j = 0;
            while (i < n && buffer[i] != '\n'){
                line[j++] = buffer[i++];
            }

            if (buffer[i] == '\n'){
                i++;
            }

            line[j] = '\0';
            cmd_argv[argc - 1] = line;
            cmd_argv[argc] = 0;
            
            int pid = fork();
            if (pid == 0) {
                exec(cmd_argv[0], cmd_argv);
                fprintf(2, "exec %s failed\n", cmd_argv[0]);
                exit(1);
            } else if (pid < 0) {
                fprintf(2, "fork failed\n");
                exit(1);
            } else {
                // Tiến trình cha đợi tiến trình con hoàn thành
                wait(0);
            }
        }  
    }
    exit(0);
}
