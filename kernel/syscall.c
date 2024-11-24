#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "syscall.h"
#include "defs.h"

// Fetch the uint64 at addr from the current process.
int
fetchaddr(uint64 addr, uint64 *ip)
{
  struct proc *p = myproc();
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    return -1;
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    return -1;
  return 0;
}

// Fetch the nul-terminated string at addr from the current process.
// Returns length of string, not including nul, or -1 for error.
int
fetchstr(uint64 addr, char *buf, int max)
{
  struct proc *p = myproc();
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    return -1;
  return strlen(buf);
}

static uint64
argraw(int n)
{
  struct proc *p = myproc();
  switch (n) {
  case 0:
    return p->trapframe->a0;
  case 1:
    return p->trapframe->a1;
  case 2:
    return p->trapframe->a2;
  case 3:
    return p->trapframe->a3;
  case 4:
    return p->trapframe->a4;
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
  *ip = argraw(n);
}

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
  *ip = argraw(n);
}

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
}

// Prototypes for the functions that handle system calls.
extern uint64 sys_fork(void);
extern uint64 sys_exit(void);
extern uint64 sys_wait(void);
extern uint64 sys_pipe(void);
extern uint64 sys_read(void);
extern uint64 sys_kill(void);
extern uint64 sys_exec(void);
extern uint64 sys_fstat(void);
extern uint64 sys_chdir(void);
extern uint64 sys_dup(void);
extern uint64 sys_getpid(void);
extern uint64 sys_sbrk(void);
extern uint64 sys_sleep(void);
extern uint64 sys_uptime(void);
extern uint64 sys_open(void);
extern uint64 sys_write(void);
extern uint64 sys_mknod(void);
extern uint64 sys_unlink(void);
extern uint64 sys_link(void);
extern uint64 sys_mkdir(void);
extern uint64 sys_close(void);
extern uint64 sys_trace(void);
extern uint64 sys_sysinfo(void); // Khai báo hàm xử lý.

// An array mapping syscall numbers from syscall.h
// to the function that handles the system call.
static uint64 (*syscalls[])(void) = {
[SYS_fork]    sys_fork,
[SYS_exit]    sys_exit,
[SYS_wait]    sys_wait,
[SYS_pipe]    sys_pipe,
[SYS_read]    sys_read,
[SYS_kill]    sys_kill,
[SYS_exec]    sys_exec,
[SYS_fstat]   sys_fstat,
[SYS_chdir]   sys_chdir,
[SYS_dup]     sys_dup,
[SYS_getpid]  sys_getpid,
[SYS_sbrk]    sys_sbrk,
[SYS_sleep]   sys_sleep,
[SYS_uptime]  sys_uptime,
[SYS_open]    sys_open,
[SYS_write]   sys_write,
[SYS_mknod]   sys_mknod,
[SYS_unlink]  sys_unlink,
[SYS_link]    sys_link,
[SYS_mkdir]   sys_mkdir,
[SYS_close]   sys_close,
[SYS_trace]   sys_trace,
[SYS_sysinfo] sys_sysinfo,
};

char* syscall_name(int syscall_num) {
    switch(syscall_num) {
    case SYS_fork: return "fork";
    case SYS_exit: return "exit";
    case SYS_wait: return "wait";
    case SYS_pipe: return "pipe";
    case SYS_read: return "read";
    case SYS_kill: return "kill";
    case SYS_exec: return "exec";
    case SYS_fstat: return "fstat";
    case SYS_chdir: return "chdir";
    case SYS_dup: return "dup";
    case SYS_getpid: return "getpid";
    case SYS_sbrk: return "sbrk";
    case SYS_sleep: return "sleep";
    case SYS_uptime: return "uptime";
    case SYS_open: return "open";
    case SYS_write: return "write";
    case SYS_mknod: return "mknod";
    case SYS_unlink: return "unlink";
    case SYS_link: return "link";
    case SYS_mkdir: return "mkdir";
    case SYS_close: return "close";
    case SYS_trace: return "trace";
    // case SYS_sysinfo: return "sysinfo";
    default: return "unknown";
    }
}

int syscall_arg_count(int syscall_num) {
    switch(syscall_num) {
    case SYS_fork: return 0;
    case SYS_exit: return 1;
    case SYS_wait: return 1;
    case SYS_pipe: return 1;
    case SYS_read: return 3;
    case SYS_kill: return 2;
    case SYS_exec: return 2;
    case SYS_fstat: return 2;
    case SYS_chdir: return 1;
    case SYS_dup: return 1;
    case SYS_getpid: return 0;
    case SYS_sbrk: return 1;
    case SYS_sleep: return 1;
    case SYS_uptime: return 0;
    case SYS_open: return 2;
    case SYS_write: return 3;
    case SYS_mknod: return 3;
    case SYS_unlink: return 1;
    case SYS_link: return 2;
    case SYS_mkdir: return 1;
    case SYS_close: return 1;
    case SYS_trace: return 1;
    default: return 0;
    }
}

void
syscall(void)
{
  int num;
  struct proc *p = myproc();

  num = p->trapframe->a7;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    uint64 args[6];
    args[0] = p->trapframe->a0;
    args[1] = p->trapframe->a1;
    args[2] = p->trapframe->a2;
    args[3] = p->trapframe->a3;
    args[4] = p->trapframe->a4;
    args[5] = p->trapframe->a5;
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();

    //trace
    if((p->traced & (1 << num))) {
      printf("%d: syscall %s(", p->pid, syscall_name(num));
            
      // In các tham số dựa trên số lượng cần thiết
      int num_args = syscall_arg_count(num);  // Lấy số lượng tham số
      for (int i = 0; i < num_args; i++) {
        if (i > 0) printf(", ");
          printf("%ld", args[i]);
        }
        printf(") -> %ld\n", p->trapframe->a0);  // In giá trị trả về
    }

  } else {
    printf("%d %s: unknown sys call %d\n",
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
  }
}



