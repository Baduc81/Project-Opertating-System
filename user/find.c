#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"


char* fmtname(char *path)
{
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--);
  p++;

  if(strlen(p) >= DIRSIZ)
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), '\0', DIRSIZ-strlen(p));
  return buf;
}

void find(char *path, char *search_exp, int *flag)
{
  char buf[512];
  char *p;
  int fd;
  struct dirent de;
  struct stat st;


    ///Check some errors of path
  if(strlen(path) + 1 + DIRSIZ + 1 > 512){
    fprintf(2, "find: path too long\n");
    return;
  }

    //0: open path with read only mode
  if((fd = open(path, 0)) < 0){
    fprintf(2, "find: path %s doesn't not exist\n", path);
    return;
  }

    //fstat function can't retrieve infor of path
  if(fstat(fd, &st) < 0){
    fprintf(2, "find: unknown path %s\n", path);
    close(fd);
    return;
  }

  strcpy(buf, path);
  p = buf + strlen(buf);
  *p++ = '/';

  while(read(fd, &de, sizeof(de)) == sizeof(de)){
    if(de.inum == 0)
      continue;

    memmove(p, de.name, DIRSIZ);
    p[DIRSIZ] = 0;

    if(stat(buf, &st) < 0){
      printf("find: cannot stat %s\n", buf); 
      continue;
    }

    if (st.type == T_FILE){
      if (strcmp(fmtname(buf), search_exp) == 0) {
        *flag = 1;
        printf("%s\n", buf);
      }
    } else if (st.type == T_DIR){
      // Don't recurse into "." and "..".
      if (strcmp(fmtname(buf), ".") != 0 && strcmp(fmtname(buf), "..") != 0) {
        // Get new metadata for directory file
        int fd2 = open(buf, 0);
        // Recursive search in found directory
        find(buf, search_exp, flag);
        close(fd2);
      }
    }
  }
  close(fd);
}

int main(int argc, char *argv[])
{
  int flag = 0;

  if(argc < 3 || argc > 4)
  {
    printf("Usage: find [path] [expression]\n");
    exit(1);
  } 
  else
  {
    find(argv[1], argv[2], &flag);
  }

  if (!flag)
  {
    printf("find: file not found\n");
  }

  return 0;
}