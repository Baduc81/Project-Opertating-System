
user/_find:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "user/user.h"
#include "kernel/fs.h"


char* fmtname(char *path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	1800                	addi	s0,sp,48
   a:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--);
   c:	302000ef          	jal	30e <strlen>
  10:	02051793          	slli	a5,a0,0x20
  14:	9381                	srli	a5,a5,0x20
  16:	97a6                	add	a5,a5,s1
  18:	02f00693          	li	a3,47
  1c:	0097e963          	bltu	a5,s1,2e <fmtname+0x2e>
  20:	0007c703          	lbu	a4,0(a5)
  24:	00d70563          	beq	a4,a3,2e <fmtname+0x2e>
  28:	17fd                	addi	a5,a5,-1
  2a:	fe97fbe3          	bgeu	a5,s1,20 <fmtname+0x20>
  p++;
  2e:	00178493          	addi	s1,a5,1

  if(strlen(p) >= DIRSIZ)
  32:	8526                	mv	a0,s1
  34:	2da000ef          	jal	30e <strlen>
  38:	2501                	sext.w	a0,a0
  3a:	47b5                	li	a5,13
  3c:	00a7f863          	bgeu	a5,a0,4c <fmtname+0x4c>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), '\0', DIRSIZ-strlen(p));
  return buf;
}
  40:	8526                	mv	a0,s1
  42:	70a2                	ld	ra,40(sp)
  44:	7402                	ld	s0,32(sp)
  46:	64e2                	ld	s1,24(sp)
  48:	6145                	addi	sp,sp,48
  4a:	8082                	ret
  4c:	e84a                	sd	s2,16(sp)
  4e:	e44e                	sd	s3,8(sp)
  memmove(buf, p, strlen(p));
  50:	8526                	mv	a0,s1
  52:	2bc000ef          	jal	30e <strlen>
  56:	00002997          	auipc	s3,0x2
  5a:	fba98993          	addi	s3,s3,-70 # 2010 <buf.0>
  5e:	0005061b          	sext.w	a2,a0
  62:	85a6                	mv	a1,s1
  64:	854e                	mv	a0,s3
  66:	40a000ef          	jal	470 <memmove>
  memset(buf+strlen(p), '\0', DIRSIZ-strlen(p));
  6a:	8526                	mv	a0,s1
  6c:	2a2000ef          	jal	30e <strlen>
  70:	0005091b          	sext.w	s2,a0
  74:	8526                	mv	a0,s1
  76:	298000ef          	jal	30e <strlen>
  7a:	1902                	slli	s2,s2,0x20
  7c:	02095913          	srli	s2,s2,0x20
  80:	4639                	li	a2,14
  82:	9e09                	subw	a2,a2,a0
  84:	4581                	li	a1,0
  86:	01298533          	add	a0,s3,s2
  8a:	2ae000ef          	jal	338 <memset>
  return buf;
  8e:	84ce                	mv	s1,s3
  90:	6942                	ld	s2,16(sp)
  92:	69a2                	ld	s3,8(sp)
  94:	b775                	j	40 <fmtname+0x40>

0000000000000096 <find>:

void find(char *path, char *search_exp, int *flag)
{
  96:	d8010113          	addi	sp,sp,-640
  9a:	26113c23          	sd	ra,632(sp)
  9e:	26813823          	sd	s0,624(sp)
  a2:	27213023          	sd	s2,608(sp)
  a6:	25313c23          	sd	s3,600(sp)
  aa:	25413823          	sd	s4,592(sp)
  ae:	0500                	addi	s0,sp,640
  b0:	892a                	mv	s2,a0
  b2:	89ae                	mv	s3,a1
  b4:	8a32                	mv	s4,a2
  struct dirent de;
  struct stat st;


    ///Check some errors of path
  if(strlen(path) + 1 + DIRSIZ + 1 > 512){
  b6:	258000ef          	jal	30e <strlen>
  ba:	2541                	addiw	a0,a0,16
  bc:	20000793          	li	a5,512
  c0:	0ea7ea63          	bltu	a5,a0,1b4 <find+0x11e>
  c4:	26913423          	sd	s1,616(sp)
    fprintf(2, "find: path too long\n");
    return;
  }

    //0: open path with read only mode
  if((fd = open(path, 0)) < 0){
  c8:	4581                	li	a1,0
  ca:	854a                	mv	a0,s2
  cc:	492000ef          	jal	55e <open>
  d0:	84aa                	mv	s1,a0
  d2:	0e054963          	bltz	a0,1c4 <find+0x12e>
    fprintf(2, "find: path %s doesn't not exist\n", path);
    return;
  }

    //fstat function can't retrieve infor of path
  if(fstat(fd, &st) < 0){
  d6:	d8840593          	addi	a1,s0,-632
  da:	49c000ef          	jal	576 <fstat>
  de:	0e054e63          	bltz	a0,1da <find+0x144>
  e2:	25513423          	sd	s5,584(sp)
  e6:	25613023          	sd	s6,576(sp)
  ea:	23713c23          	sd	s7,568(sp)
    fprintf(2, "find: unknown path %s\n", path);
    close(fd);
    return;
  }

  strcpy(buf, path);
  ee:	85ca                	mv	a1,s2
  f0:	db040513          	addi	a0,s0,-592
  f4:	1d2000ef          	jal	2c6 <strcpy>
  p = buf + strlen(buf);
  f8:	db040513          	addi	a0,s0,-592
  fc:	212000ef          	jal	30e <strlen>
 100:	1502                	slli	a0,a0,0x20
 102:	9101                	srli	a0,a0,0x20
 104:	db040793          	addi	a5,s0,-592
 108:	00a78933          	add	s2,a5,a0
  *p++ = '/';
 10c:	00190a93          	addi	s5,s2,1
 110:	02f00793          	li	a5,47
 114:	00f90023          	sb	a5,0(s2)
    if(stat(buf, &st) < 0){
      printf("find: cannot stat %s\n", buf); 
      continue;
    }

    if (st.type == T_FILE){
 118:	4b09                	li	s6,2
      if (strcmp(fmtname(buf), search_exp) == 0) {
        *flag = 1;
        printf("%s\n", buf);
      }
    } else if (st.type == T_DIR){
 11a:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) == sizeof(de)){
 11c:	4641                	li	a2,16
 11e:	da040593          	addi	a1,s0,-608
 122:	8526                	mv	a0,s1
 124:	412000ef          	jal	536 <read>
 128:	47c1                	li	a5,16
 12a:	10f51463          	bne	a0,a5,232 <find+0x19c>
    if(de.inum == 0)
 12e:	da045783          	lhu	a5,-608(s0)
 132:	d7ed                	beqz	a5,11c <find+0x86>
    memmove(p, de.name, DIRSIZ);
 134:	4639                	li	a2,14
 136:	da240593          	addi	a1,s0,-606
 13a:	8556                	mv	a0,s5
 13c:	334000ef          	jal	470 <memmove>
    p[DIRSIZ] = 0;
 140:	000907a3          	sb	zero,15(s2)
    if(stat(buf, &st) < 0){
 144:	d8840593          	addi	a1,s0,-632
 148:	db040513          	addi	a0,s0,-592
 14c:	2a2000ef          	jal	3ee <stat>
 150:	0a054363          	bltz	a0,1f6 <find+0x160>
    if (st.type == T_FILE){
 154:	d9041783          	lh	a5,-624(s0)
 158:	0b678863          	beq	a5,s6,208 <find+0x172>
    } else if (st.type == T_DIR){
 15c:	fd7790e3          	bne	a5,s7,11c <find+0x86>
      // Don't recurse into "." and "..".
      if (strcmp(fmtname(buf), ".") != 0 && strcmp(fmtname(buf), "..") != 0) {
 160:	db040513          	addi	a0,s0,-592
 164:	e9dff0ef          	jal	0 <fmtname>
 168:	00001597          	auipc	a1,0x1
 16c:	a0058593          	addi	a1,a1,-1536 # b68 <malloc+0x17e>
 170:	172000ef          	jal	2e2 <strcmp>
 174:	d545                	beqz	a0,11c <find+0x86>
 176:	db040513          	addi	a0,s0,-592
 17a:	e87ff0ef          	jal	0 <fmtname>
 17e:	00001597          	auipc	a1,0x1
 182:	9f258593          	addi	a1,a1,-1550 # b70 <malloc+0x186>
 186:	15c000ef          	jal	2e2 <strcmp>
 18a:	d949                	beqz	a0,11c <find+0x86>
 18c:	23813823          	sd	s8,560(sp)
        // Get new metadata for directory file
        int fd2 = open(buf, 0);
 190:	4581                	li	a1,0
 192:	db040513          	addi	a0,s0,-592
 196:	3c8000ef          	jal	55e <open>
 19a:	8c2a                	mv	s8,a0
        // Recursive search in found directory
        find(buf, search_exp, flag);
 19c:	8652                	mv	a2,s4
 19e:	85ce                	mv	a1,s3
 1a0:	db040513          	addi	a0,s0,-592
 1a4:	ef3ff0ef          	jal	96 <find>
        close(fd2);
 1a8:	8562                	mv	a0,s8
 1aa:	39c000ef          	jal	546 <close>
 1ae:	23013c03          	ld	s8,560(sp)
 1b2:	b7ad                	j	11c <find+0x86>
    fprintf(2, "find: path too long\n");
 1b4:	00001597          	auipc	a1,0x1
 1b8:	93c58593          	addi	a1,a1,-1732 # af0 <malloc+0x106>
 1bc:	4509                	li	a0,2
 1be:	74e000ef          	jal	90c <fprintf>
    return;
 1c2:	a059                	j	248 <find+0x1b2>
    fprintf(2, "find: path %s doesn't not exist\n", path);
 1c4:	864a                	mv	a2,s2
 1c6:	00001597          	auipc	a1,0x1
 1ca:	94258593          	addi	a1,a1,-1726 # b08 <malloc+0x11e>
 1ce:	4509                	li	a0,2
 1d0:	73c000ef          	jal	90c <fprintf>
    return;
 1d4:	26813483          	ld	s1,616(sp)
 1d8:	a885                	j	248 <find+0x1b2>
    fprintf(2, "find: unknown path %s\n", path);
 1da:	864a                	mv	a2,s2
 1dc:	00001597          	auipc	a1,0x1
 1e0:	95458593          	addi	a1,a1,-1708 # b30 <malloc+0x146>
 1e4:	4509                	li	a0,2
 1e6:	726000ef          	jal	90c <fprintf>
    close(fd);
 1ea:	8526                	mv	a0,s1
 1ec:	35a000ef          	jal	546 <close>
    return;
 1f0:	26813483          	ld	s1,616(sp)
 1f4:	a891                	j	248 <find+0x1b2>
      printf("find: cannot stat %s\n", buf); 
 1f6:	db040593          	addi	a1,s0,-592
 1fa:	00001517          	auipc	a0,0x1
 1fe:	94e50513          	addi	a0,a0,-1714 # b48 <malloc+0x15e>
 202:	734000ef          	jal	936 <printf>
      continue;
 206:	bf19                	j	11c <find+0x86>
      if (strcmp(fmtname(buf), search_exp) == 0) {
 208:	db040513          	addi	a0,s0,-592
 20c:	df5ff0ef          	jal	0 <fmtname>
 210:	85ce                	mv	a1,s3
 212:	0d0000ef          	jal	2e2 <strcmp>
 216:	f00513e3          	bnez	a0,11c <find+0x86>
        *flag = 1;
 21a:	4785                	li	a5,1
 21c:	00fa2023          	sw	a5,0(s4)
        printf("%s\n", buf);
 220:	db040593          	addi	a1,s0,-592
 224:	00001517          	auipc	a0,0x1
 228:	93c50513          	addi	a0,a0,-1732 # b60 <malloc+0x176>
 22c:	70a000ef          	jal	936 <printf>
 230:	b5f5                	j	11c <find+0x86>
      }
    }
  }
  close(fd);
 232:	8526                	mv	a0,s1
 234:	312000ef          	jal	546 <close>
 238:	26813483          	ld	s1,616(sp)
 23c:	24813a83          	ld	s5,584(sp)
 240:	24013b03          	ld	s6,576(sp)
 244:	23813b83          	ld	s7,568(sp)
}
 248:	27813083          	ld	ra,632(sp)
 24c:	27013403          	ld	s0,624(sp)
 250:	26013903          	ld	s2,608(sp)
 254:	25813983          	ld	s3,600(sp)
 258:	25013a03          	ld	s4,592(sp)
 25c:	28010113          	addi	sp,sp,640
 260:	8082                	ret

0000000000000262 <main>:

int main(int argc, char *argv[])
{
 262:	1101                	addi	sp,sp,-32
 264:	ec06                	sd	ra,24(sp)
 266:	e822                	sd	s0,16(sp)
 268:	1000                	addi	s0,sp,32
  int flag = 0;
 26a:	fe042623          	sw	zero,-20(s0)

  if(argc < 3 || argc > 4)
 26e:	3575                	addiw	a0,a0,-3
 270:	4705                	li	a4,1
 272:	02a76163          	bltu	a4,a0,294 <main+0x32>
 276:	87ae                	mv	a5,a1
    printf("Usage: find [path] [expression]\n");
    exit(1);
  } 
  else
  {
    find(argv[1], argv[2], &flag);
 278:	fec40613          	addi	a2,s0,-20
 27c:	698c                	ld	a1,16(a1)
 27e:	6788                	ld	a0,8(a5)
 280:	e17ff0ef          	jal	96 <find>
  }

  if (!flag)
 284:	fec42783          	lw	a5,-20(s0)
 288:	cf99                	beqz	a5,2a6 <main+0x44>
  {
    printf("find: file not found\n");
  }

  return 0;
 28a:	4501                	li	a0,0
 28c:	60e2                	ld	ra,24(sp)
 28e:	6442                	ld	s0,16(sp)
 290:	6105                	addi	sp,sp,32
 292:	8082                	ret
    printf("Usage: find [path] [expression]\n");
 294:	00001517          	auipc	a0,0x1
 298:	8e450513          	addi	a0,a0,-1820 # b78 <malloc+0x18e>
 29c:	69a000ef          	jal	936 <printf>
    exit(1);
 2a0:	4505                	li	a0,1
 2a2:	27c000ef          	jal	51e <exit>
    printf("find: file not found\n");
 2a6:	00001517          	auipc	a0,0x1
 2aa:	8fa50513          	addi	a0,a0,-1798 # ba0 <malloc+0x1b6>
 2ae:	688000ef          	jal	936 <printf>
 2b2:	bfe1                	j	28a <main+0x28>

00000000000002b4 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 2b4:	1141                	addi	sp,sp,-16
 2b6:	e406                	sd	ra,8(sp)
 2b8:	e022                	sd	s0,0(sp)
 2ba:	0800                	addi	s0,sp,16
  extern int main();
  main();
 2bc:	fa7ff0ef          	jal	262 <main>
  exit(0);
 2c0:	4501                	li	a0,0
 2c2:	25c000ef          	jal	51e <exit>

00000000000002c6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2c6:	1141                	addi	sp,sp,-16
 2c8:	e422                	sd	s0,8(sp)
 2ca:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2cc:	87aa                	mv	a5,a0
 2ce:	0585                	addi	a1,a1,1
 2d0:	0785                	addi	a5,a5,1
 2d2:	fff5c703          	lbu	a4,-1(a1)
 2d6:	fee78fa3          	sb	a4,-1(a5)
 2da:	fb75                	bnez	a4,2ce <strcpy+0x8>
    ;
  return os;
}
 2dc:	6422                	ld	s0,8(sp)
 2de:	0141                	addi	sp,sp,16
 2e0:	8082                	ret

00000000000002e2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2e2:	1141                	addi	sp,sp,-16
 2e4:	e422                	sd	s0,8(sp)
 2e6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2e8:	00054783          	lbu	a5,0(a0)
 2ec:	cb91                	beqz	a5,300 <strcmp+0x1e>
 2ee:	0005c703          	lbu	a4,0(a1)
 2f2:	00f71763          	bne	a4,a5,300 <strcmp+0x1e>
    p++, q++;
 2f6:	0505                	addi	a0,a0,1
 2f8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2fa:	00054783          	lbu	a5,0(a0)
 2fe:	fbe5                	bnez	a5,2ee <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 300:	0005c503          	lbu	a0,0(a1)
}
 304:	40a7853b          	subw	a0,a5,a0
 308:	6422                	ld	s0,8(sp)
 30a:	0141                	addi	sp,sp,16
 30c:	8082                	ret

000000000000030e <strlen>:

uint
strlen(const char *s)
{
 30e:	1141                	addi	sp,sp,-16
 310:	e422                	sd	s0,8(sp)
 312:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 314:	00054783          	lbu	a5,0(a0)
 318:	cf91                	beqz	a5,334 <strlen+0x26>
 31a:	0505                	addi	a0,a0,1
 31c:	87aa                	mv	a5,a0
 31e:	86be                	mv	a3,a5
 320:	0785                	addi	a5,a5,1
 322:	fff7c703          	lbu	a4,-1(a5)
 326:	ff65                	bnez	a4,31e <strlen+0x10>
 328:	40a6853b          	subw	a0,a3,a0
 32c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 32e:	6422                	ld	s0,8(sp)
 330:	0141                	addi	sp,sp,16
 332:	8082                	ret
  for(n = 0; s[n]; n++)
 334:	4501                	li	a0,0
 336:	bfe5                	j	32e <strlen+0x20>

0000000000000338 <memset>:

void*
memset(void *dst, int c, uint n)
{
 338:	1141                	addi	sp,sp,-16
 33a:	e422                	sd	s0,8(sp)
 33c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 33e:	ca19                	beqz	a2,354 <memset+0x1c>
 340:	87aa                	mv	a5,a0
 342:	1602                	slli	a2,a2,0x20
 344:	9201                	srli	a2,a2,0x20
 346:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 34a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 34e:	0785                	addi	a5,a5,1
 350:	fee79de3          	bne	a5,a4,34a <memset+0x12>
  }
  return dst;
}
 354:	6422                	ld	s0,8(sp)
 356:	0141                	addi	sp,sp,16
 358:	8082                	ret

000000000000035a <strchr>:

char*
strchr(const char *s, char c)
{
 35a:	1141                	addi	sp,sp,-16
 35c:	e422                	sd	s0,8(sp)
 35e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 360:	00054783          	lbu	a5,0(a0)
 364:	cb99                	beqz	a5,37a <strchr+0x20>
    if(*s == c)
 366:	00f58763          	beq	a1,a5,374 <strchr+0x1a>
  for(; *s; s++)
 36a:	0505                	addi	a0,a0,1
 36c:	00054783          	lbu	a5,0(a0)
 370:	fbfd                	bnez	a5,366 <strchr+0xc>
      return (char*)s;
  return 0;
 372:	4501                	li	a0,0
}
 374:	6422                	ld	s0,8(sp)
 376:	0141                	addi	sp,sp,16
 378:	8082                	ret
  return 0;
 37a:	4501                	li	a0,0
 37c:	bfe5                	j	374 <strchr+0x1a>

000000000000037e <gets>:

char*
gets(char *buf, int max)
{
 37e:	711d                	addi	sp,sp,-96
 380:	ec86                	sd	ra,88(sp)
 382:	e8a2                	sd	s0,80(sp)
 384:	e4a6                	sd	s1,72(sp)
 386:	e0ca                	sd	s2,64(sp)
 388:	fc4e                	sd	s3,56(sp)
 38a:	f852                	sd	s4,48(sp)
 38c:	f456                	sd	s5,40(sp)
 38e:	f05a                	sd	s6,32(sp)
 390:	ec5e                	sd	s7,24(sp)
 392:	1080                	addi	s0,sp,96
 394:	8baa                	mv	s7,a0
 396:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 398:	892a                	mv	s2,a0
 39a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 39c:	4aa9                	li	s5,10
 39e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3a0:	89a6                	mv	s3,s1
 3a2:	2485                	addiw	s1,s1,1
 3a4:	0344d663          	bge	s1,s4,3d0 <gets+0x52>
    cc = read(0, &c, 1);
 3a8:	4605                	li	a2,1
 3aa:	faf40593          	addi	a1,s0,-81
 3ae:	4501                	li	a0,0
 3b0:	186000ef          	jal	536 <read>
    if(cc < 1)
 3b4:	00a05e63          	blez	a0,3d0 <gets+0x52>
    buf[i++] = c;
 3b8:	faf44783          	lbu	a5,-81(s0)
 3bc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3c0:	01578763          	beq	a5,s5,3ce <gets+0x50>
 3c4:	0905                	addi	s2,s2,1
 3c6:	fd679de3          	bne	a5,s6,3a0 <gets+0x22>
    buf[i++] = c;
 3ca:	89a6                	mv	s3,s1
 3cc:	a011                	j	3d0 <gets+0x52>
 3ce:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3d0:	99de                	add	s3,s3,s7
 3d2:	00098023          	sb	zero,0(s3)
  return buf;
}
 3d6:	855e                	mv	a0,s7
 3d8:	60e6                	ld	ra,88(sp)
 3da:	6446                	ld	s0,80(sp)
 3dc:	64a6                	ld	s1,72(sp)
 3de:	6906                	ld	s2,64(sp)
 3e0:	79e2                	ld	s3,56(sp)
 3e2:	7a42                	ld	s4,48(sp)
 3e4:	7aa2                	ld	s5,40(sp)
 3e6:	7b02                	ld	s6,32(sp)
 3e8:	6be2                	ld	s7,24(sp)
 3ea:	6125                	addi	sp,sp,96
 3ec:	8082                	ret

00000000000003ee <stat>:

int
stat(const char *n, struct stat *st)
{
 3ee:	1101                	addi	sp,sp,-32
 3f0:	ec06                	sd	ra,24(sp)
 3f2:	e822                	sd	s0,16(sp)
 3f4:	e04a                	sd	s2,0(sp)
 3f6:	1000                	addi	s0,sp,32
 3f8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3fa:	4581                	li	a1,0
 3fc:	162000ef          	jal	55e <open>
  if(fd < 0)
 400:	02054263          	bltz	a0,424 <stat+0x36>
 404:	e426                	sd	s1,8(sp)
 406:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 408:	85ca                	mv	a1,s2
 40a:	16c000ef          	jal	576 <fstat>
 40e:	892a                	mv	s2,a0
  close(fd);
 410:	8526                	mv	a0,s1
 412:	134000ef          	jal	546 <close>
  return r;
 416:	64a2                	ld	s1,8(sp)
}
 418:	854a                	mv	a0,s2
 41a:	60e2                	ld	ra,24(sp)
 41c:	6442                	ld	s0,16(sp)
 41e:	6902                	ld	s2,0(sp)
 420:	6105                	addi	sp,sp,32
 422:	8082                	ret
    return -1;
 424:	597d                	li	s2,-1
 426:	bfcd                	j	418 <stat+0x2a>

0000000000000428 <atoi>:

int
atoi(const char *s)
{
 428:	1141                	addi	sp,sp,-16
 42a:	e422                	sd	s0,8(sp)
 42c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 42e:	00054683          	lbu	a3,0(a0)
 432:	fd06879b          	addiw	a5,a3,-48
 436:	0ff7f793          	zext.b	a5,a5
 43a:	4625                	li	a2,9
 43c:	02f66863          	bltu	a2,a5,46c <atoi+0x44>
 440:	872a                	mv	a4,a0
  n = 0;
 442:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 444:	0705                	addi	a4,a4,1
 446:	0025179b          	slliw	a5,a0,0x2
 44a:	9fa9                	addw	a5,a5,a0
 44c:	0017979b          	slliw	a5,a5,0x1
 450:	9fb5                	addw	a5,a5,a3
 452:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 456:	00074683          	lbu	a3,0(a4)
 45a:	fd06879b          	addiw	a5,a3,-48
 45e:	0ff7f793          	zext.b	a5,a5
 462:	fef671e3          	bgeu	a2,a5,444 <atoi+0x1c>
  return n;
}
 466:	6422                	ld	s0,8(sp)
 468:	0141                	addi	sp,sp,16
 46a:	8082                	ret
  n = 0;
 46c:	4501                	li	a0,0
 46e:	bfe5                	j	466 <atoi+0x3e>

0000000000000470 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 470:	1141                	addi	sp,sp,-16
 472:	e422                	sd	s0,8(sp)
 474:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 476:	02b57463          	bgeu	a0,a1,49e <memmove+0x2e>
    while(n-- > 0)
 47a:	00c05f63          	blez	a2,498 <memmove+0x28>
 47e:	1602                	slli	a2,a2,0x20
 480:	9201                	srli	a2,a2,0x20
 482:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 486:	872a                	mv	a4,a0
      *dst++ = *src++;
 488:	0585                	addi	a1,a1,1
 48a:	0705                	addi	a4,a4,1
 48c:	fff5c683          	lbu	a3,-1(a1)
 490:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 494:	fef71ae3          	bne	a4,a5,488 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 498:	6422                	ld	s0,8(sp)
 49a:	0141                	addi	sp,sp,16
 49c:	8082                	ret
    dst += n;
 49e:	00c50733          	add	a4,a0,a2
    src += n;
 4a2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4a4:	fec05ae3          	blez	a2,498 <memmove+0x28>
 4a8:	fff6079b          	addiw	a5,a2,-1
 4ac:	1782                	slli	a5,a5,0x20
 4ae:	9381                	srli	a5,a5,0x20
 4b0:	fff7c793          	not	a5,a5
 4b4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4b6:	15fd                	addi	a1,a1,-1
 4b8:	177d                	addi	a4,a4,-1
 4ba:	0005c683          	lbu	a3,0(a1)
 4be:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4c2:	fee79ae3          	bne	a5,a4,4b6 <memmove+0x46>
 4c6:	bfc9                	j	498 <memmove+0x28>

00000000000004c8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4c8:	1141                	addi	sp,sp,-16
 4ca:	e422                	sd	s0,8(sp)
 4cc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4ce:	ca05                	beqz	a2,4fe <memcmp+0x36>
 4d0:	fff6069b          	addiw	a3,a2,-1
 4d4:	1682                	slli	a3,a3,0x20
 4d6:	9281                	srli	a3,a3,0x20
 4d8:	0685                	addi	a3,a3,1
 4da:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4dc:	00054783          	lbu	a5,0(a0)
 4e0:	0005c703          	lbu	a4,0(a1)
 4e4:	00e79863          	bne	a5,a4,4f4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4e8:	0505                	addi	a0,a0,1
    p2++;
 4ea:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4ec:	fed518e3          	bne	a0,a3,4dc <memcmp+0x14>
  }
  return 0;
 4f0:	4501                	li	a0,0
 4f2:	a019                	j	4f8 <memcmp+0x30>
      return *p1 - *p2;
 4f4:	40e7853b          	subw	a0,a5,a4
}
 4f8:	6422                	ld	s0,8(sp)
 4fa:	0141                	addi	sp,sp,16
 4fc:	8082                	ret
  return 0;
 4fe:	4501                	li	a0,0
 500:	bfe5                	j	4f8 <memcmp+0x30>

0000000000000502 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 502:	1141                	addi	sp,sp,-16
 504:	e406                	sd	ra,8(sp)
 506:	e022                	sd	s0,0(sp)
 508:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 50a:	f67ff0ef          	jal	470 <memmove>
}
 50e:	60a2                	ld	ra,8(sp)
 510:	6402                	ld	s0,0(sp)
 512:	0141                	addi	sp,sp,16
 514:	8082                	ret

0000000000000516 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 516:	4885                	li	a7,1
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <exit>:
.global exit
exit:
 li a7, SYS_exit
 51e:	4889                	li	a7,2
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <wait>:
.global wait
wait:
 li a7, SYS_wait
 526:	488d                	li	a7,3
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 52e:	4891                	li	a7,4
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <read>:
.global read
read:
 li a7, SYS_read
 536:	4895                	li	a7,5
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <write>:
.global write
write:
 li a7, SYS_write
 53e:	48c1                	li	a7,16
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <close>:
.global close
close:
 li a7, SYS_close
 546:	48d5                	li	a7,21
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <kill>:
.global kill
kill:
 li a7, SYS_kill
 54e:	4899                	li	a7,6
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <exec>:
.global exec
exec:
 li a7, SYS_exec
 556:	489d                	li	a7,7
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <open>:
.global open
open:
 li a7, SYS_open
 55e:	48bd                	li	a7,15
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 566:	48c5                	li	a7,17
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 56e:	48c9                	li	a7,18
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 576:	48a1                	li	a7,8
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <link>:
.global link
link:
 li a7, SYS_link
 57e:	48cd                	li	a7,19
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 586:	48d1                	li	a7,20
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 58e:	48a5                	li	a7,9
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <dup>:
.global dup
dup:
 li a7, SYS_dup
 596:	48a9                	li	a7,10
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 59e:	48ad                	li	a7,11
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5a6:	48b1                	li	a7,12
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5ae:	48b5                	li	a7,13
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5b6:	48b9                	li	a7,14
 ecall
 5b8:	00000073          	ecall
 ret
 5bc:	8082                	ret

00000000000005be <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5be:	1101                	addi	sp,sp,-32
 5c0:	ec06                	sd	ra,24(sp)
 5c2:	e822                	sd	s0,16(sp)
 5c4:	1000                	addi	s0,sp,32
 5c6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5ca:	4605                	li	a2,1
 5cc:	fef40593          	addi	a1,s0,-17
 5d0:	f6fff0ef          	jal	53e <write>
}
 5d4:	60e2                	ld	ra,24(sp)
 5d6:	6442                	ld	s0,16(sp)
 5d8:	6105                	addi	sp,sp,32
 5da:	8082                	ret

00000000000005dc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5dc:	7139                	addi	sp,sp,-64
 5de:	fc06                	sd	ra,56(sp)
 5e0:	f822                	sd	s0,48(sp)
 5e2:	f426                	sd	s1,40(sp)
 5e4:	0080                	addi	s0,sp,64
 5e6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5e8:	c299                	beqz	a3,5ee <printint+0x12>
 5ea:	0805c963          	bltz	a1,67c <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5ee:	2581                	sext.w	a1,a1
  neg = 0;
 5f0:	4881                	li	a7,0
 5f2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5f6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5f8:	2601                	sext.w	a2,a2
 5fa:	00000517          	auipc	a0,0x0
 5fe:	5c650513          	addi	a0,a0,1478 # bc0 <digits>
 602:	883a                	mv	a6,a4
 604:	2705                	addiw	a4,a4,1
 606:	02c5f7bb          	remuw	a5,a1,a2
 60a:	1782                	slli	a5,a5,0x20
 60c:	9381                	srli	a5,a5,0x20
 60e:	97aa                	add	a5,a5,a0
 610:	0007c783          	lbu	a5,0(a5)
 614:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 618:	0005879b          	sext.w	a5,a1
 61c:	02c5d5bb          	divuw	a1,a1,a2
 620:	0685                	addi	a3,a3,1
 622:	fec7f0e3          	bgeu	a5,a2,602 <printint+0x26>
  if(neg)
 626:	00088c63          	beqz	a7,63e <printint+0x62>
    buf[i++] = '-';
 62a:	fd070793          	addi	a5,a4,-48
 62e:	00878733          	add	a4,a5,s0
 632:	02d00793          	li	a5,45
 636:	fef70823          	sb	a5,-16(a4)
 63a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 63e:	02e05a63          	blez	a4,672 <printint+0x96>
 642:	f04a                	sd	s2,32(sp)
 644:	ec4e                	sd	s3,24(sp)
 646:	fc040793          	addi	a5,s0,-64
 64a:	00e78933          	add	s2,a5,a4
 64e:	fff78993          	addi	s3,a5,-1
 652:	99ba                	add	s3,s3,a4
 654:	377d                	addiw	a4,a4,-1
 656:	1702                	slli	a4,a4,0x20
 658:	9301                	srli	a4,a4,0x20
 65a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 65e:	fff94583          	lbu	a1,-1(s2)
 662:	8526                	mv	a0,s1
 664:	f5bff0ef          	jal	5be <putc>
  while(--i >= 0)
 668:	197d                	addi	s2,s2,-1
 66a:	ff391ae3          	bne	s2,s3,65e <printint+0x82>
 66e:	7902                	ld	s2,32(sp)
 670:	69e2                	ld	s3,24(sp)
}
 672:	70e2                	ld	ra,56(sp)
 674:	7442                	ld	s0,48(sp)
 676:	74a2                	ld	s1,40(sp)
 678:	6121                	addi	sp,sp,64
 67a:	8082                	ret
    x = -xx;
 67c:	40b005bb          	negw	a1,a1
    neg = 1;
 680:	4885                	li	a7,1
    x = -xx;
 682:	bf85                	j	5f2 <printint+0x16>

0000000000000684 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 684:	711d                	addi	sp,sp,-96
 686:	ec86                	sd	ra,88(sp)
 688:	e8a2                	sd	s0,80(sp)
 68a:	e0ca                	sd	s2,64(sp)
 68c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 68e:	0005c903          	lbu	s2,0(a1)
 692:	26090863          	beqz	s2,902 <vprintf+0x27e>
 696:	e4a6                	sd	s1,72(sp)
 698:	fc4e                	sd	s3,56(sp)
 69a:	f852                	sd	s4,48(sp)
 69c:	f456                	sd	s5,40(sp)
 69e:	f05a                	sd	s6,32(sp)
 6a0:	ec5e                	sd	s7,24(sp)
 6a2:	e862                	sd	s8,16(sp)
 6a4:	e466                	sd	s9,8(sp)
 6a6:	8b2a                	mv	s6,a0
 6a8:	8a2e                	mv	s4,a1
 6aa:	8bb2                	mv	s7,a2
  state = 0;
 6ac:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 6ae:	4481                	li	s1,0
 6b0:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 6b2:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 6b6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6ba:	06c00c93          	li	s9,108
 6be:	a005                	j	6de <vprintf+0x5a>
        putc(fd, c0);
 6c0:	85ca                	mv	a1,s2
 6c2:	855a                	mv	a0,s6
 6c4:	efbff0ef          	jal	5be <putc>
 6c8:	a019                	j	6ce <vprintf+0x4a>
    } else if(state == '%'){
 6ca:	03598263          	beq	s3,s5,6ee <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 6ce:	2485                	addiw	s1,s1,1
 6d0:	8726                	mv	a4,s1
 6d2:	009a07b3          	add	a5,s4,s1
 6d6:	0007c903          	lbu	s2,0(a5)
 6da:	20090c63          	beqz	s2,8f2 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 6de:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6e2:	fe0994e3          	bnez	s3,6ca <vprintf+0x46>
      if(c0 == '%'){
 6e6:	fd579de3          	bne	a5,s5,6c0 <vprintf+0x3c>
        state = '%';
 6ea:	89be                	mv	s3,a5
 6ec:	b7cd                	j	6ce <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 6ee:	00ea06b3          	add	a3,s4,a4
 6f2:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 6f6:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 6f8:	c681                	beqz	a3,700 <vprintf+0x7c>
 6fa:	9752                	add	a4,a4,s4
 6fc:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 700:	03878f63          	beq	a5,s8,73e <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 704:	05978963          	beq	a5,s9,756 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 708:	07500713          	li	a4,117
 70c:	0ee78363          	beq	a5,a4,7f2 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 710:	07800713          	li	a4,120
 714:	12e78563          	beq	a5,a4,83e <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 718:	07000713          	li	a4,112
 71c:	14e78a63          	beq	a5,a4,870 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 720:	07300713          	li	a4,115
 724:	18e78a63          	beq	a5,a4,8b8 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 728:	02500713          	li	a4,37
 72c:	04e79563          	bne	a5,a4,776 <vprintf+0xf2>
        putc(fd, '%');
 730:	02500593          	li	a1,37
 734:	855a                	mv	a0,s6
 736:	e89ff0ef          	jal	5be <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 73a:	4981                	li	s3,0
 73c:	bf49                	j	6ce <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 73e:	008b8913          	addi	s2,s7,8
 742:	4685                	li	a3,1
 744:	4629                	li	a2,10
 746:	000ba583          	lw	a1,0(s7)
 74a:	855a                	mv	a0,s6
 74c:	e91ff0ef          	jal	5dc <printint>
 750:	8bca                	mv	s7,s2
      state = 0;
 752:	4981                	li	s3,0
 754:	bfad                	j	6ce <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 756:	06400793          	li	a5,100
 75a:	02f68963          	beq	a3,a5,78c <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 75e:	06c00793          	li	a5,108
 762:	04f68263          	beq	a3,a5,7a6 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 766:	07500793          	li	a5,117
 76a:	0af68063          	beq	a3,a5,80a <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 76e:	07800793          	li	a5,120
 772:	0ef68263          	beq	a3,a5,856 <vprintf+0x1d2>
        putc(fd, '%');
 776:	02500593          	li	a1,37
 77a:	855a                	mv	a0,s6
 77c:	e43ff0ef          	jal	5be <putc>
        putc(fd, c0);
 780:	85ca                	mv	a1,s2
 782:	855a                	mv	a0,s6
 784:	e3bff0ef          	jal	5be <putc>
      state = 0;
 788:	4981                	li	s3,0
 78a:	b791                	j	6ce <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 78c:	008b8913          	addi	s2,s7,8
 790:	4685                	li	a3,1
 792:	4629                	li	a2,10
 794:	000ba583          	lw	a1,0(s7)
 798:	855a                	mv	a0,s6
 79a:	e43ff0ef          	jal	5dc <printint>
        i += 1;
 79e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 7a0:	8bca                	mv	s7,s2
      state = 0;
 7a2:	4981                	li	s3,0
        i += 1;
 7a4:	b72d                	j	6ce <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7a6:	06400793          	li	a5,100
 7aa:	02f60763          	beq	a2,a5,7d8 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7ae:	07500793          	li	a5,117
 7b2:	06f60963          	beq	a2,a5,824 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7b6:	07800793          	li	a5,120
 7ba:	faf61ee3          	bne	a2,a5,776 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7be:	008b8913          	addi	s2,s7,8
 7c2:	4681                	li	a3,0
 7c4:	4641                	li	a2,16
 7c6:	000ba583          	lw	a1,0(s7)
 7ca:	855a                	mv	a0,s6
 7cc:	e11ff0ef          	jal	5dc <printint>
        i += 2;
 7d0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7d2:	8bca                	mv	s7,s2
      state = 0;
 7d4:	4981                	li	s3,0
        i += 2;
 7d6:	bde5                	j	6ce <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7d8:	008b8913          	addi	s2,s7,8
 7dc:	4685                	li	a3,1
 7de:	4629                	li	a2,10
 7e0:	000ba583          	lw	a1,0(s7)
 7e4:	855a                	mv	a0,s6
 7e6:	df7ff0ef          	jal	5dc <printint>
        i += 2;
 7ea:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7ec:	8bca                	mv	s7,s2
      state = 0;
 7ee:	4981                	li	s3,0
        i += 2;
 7f0:	bdf9                	j	6ce <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 7f2:	008b8913          	addi	s2,s7,8
 7f6:	4681                	li	a3,0
 7f8:	4629                	li	a2,10
 7fa:	000ba583          	lw	a1,0(s7)
 7fe:	855a                	mv	a0,s6
 800:	dddff0ef          	jal	5dc <printint>
 804:	8bca                	mv	s7,s2
      state = 0;
 806:	4981                	li	s3,0
 808:	b5d9                	j	6ce <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 80a:	008b8913          	addi	s2,s7,8
 80e:	4681                	li	a3,0
 810:	4629                	li	a2,10
 812:	000ba583          	lw	a1,0(s7)
 816:	855a                	mv	a0,s6
 818:	dc5ff0ef          	jal	5dc <printint>
        i += 1;
 81c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 81e:	8bca                	mv	s7,s2
      state = 0;
 820:	4981                	li	s3,0
        i += 1;
 822:	b575                	j	6ce <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 824:	008b8913          	addi	s2,s7,8
 828:	4681                	li	a3,0
 82a:	4629                	li	a2,10
 82c:	000ba583          	lw	a1,0(s7)
 830:	855a                	mv	a0,s6
 832:	dabff0ef          	jal	5dc <printint>
        i += 2;
 836:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 838:	8bca                	mv	s7,s2
      state = 0;
 83a:	4981                	li	s3,0
        i += 2;
 83c:	bd49                	j	6ce <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 83e:	008b8913          	addi	s2,s7,8
 842:	4681                	li	a3,0
 844:	4641                	li	a2,16
 846:	000ba583          	lw	a1,0(s7)
 84a:	855a                	mv	a0,s6
 84c:	d91ff0ef          	jal	5dc <printint>
 850:	8bca                	mv	s7,s2
      state = 0;
 852:	4981                	li	s3,0
 854:	bdad                	j	6ce <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 856:	008b8913          	addi	s2,s7,8
 85a:	4681                	li	a3,0
 85c:	4641                	li	a2,16
 85e:	000ba583          	lw	a1,0(s7)
 862:	855a                	mv	a0,s6
 864:	d79ff0ef          	jal	5dc <printint>
        i += 1;
 868:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 86a:	8bca                	mv	s7,s2
      state = 0;
 86c:	4981                	li	s3,0
        i += 1;
 86e:	b585                	j	6ce <vprintf+0x4a>
 870:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 872:	008b8d13          	addi	s10,s7,8
 876:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 87a:	03000593          	li	a1,48
 87e:	855a                	mv	a0,s6
 880:	d3fff0ef          	jal	5be <putc>
  putc(fd, 'x');
 884:	07800593          	li	a1,120
 888:	855a                	mv	a0,s6
 88a:	d35ff0ef          	jal	5be <putc>
 88e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 890:	00000b97          	auipc	s7,0x0
 894:	330b8b93          	addi	s7,s7,816 # bc0 <digits>
 898:	03c9d793          	srli	a5,s3,0x3c
 89c:	97de                	add	a5,a5,s7
 89e:	0007c583          	lbu	a1,0(a5)
 8a2:	855a                	mv	a0,s6
 8a4:	d1bff0ef          	jal	5be <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8a8:	0992                	slli	s3,s3,0x4
 8aa:	397d                	addiw	s2,s2,-1
 8ac:	fe0916e3          	bnez	s2,898 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 8b0:	8bea                	mv	s7,s10
      state = 0;
 8b2:	4981                	li	s3,0
 8b4:	6d02                	ld	s10,0(sp)
 8b6:	bd21                	j	6ce <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 8b8:	008b8993          	addi	s3,s7,8
 8bc:	000bb903          	ld	s2,0(s7)
 8c0:	00090f63          	beqz	s2,8de <vprintf+0x25a>
        for(; *s; s++)
 8c4:	00094583          	lbu	a1,0(s2)
 8c8:	c195                	beqz	a1,8ec <vprintf+0x268>
          putc(fd, *s);
 8ca:	855a                	mv	a0,s6
 8cc:	cf3ff0ef          	jal	5be <putc>
        for(; *s; s++)
 8d0:	0905                	addi	s2,s2,1
 8d2:	00094583          	lbu	a1,0(s2)
 8d6:	f9f5                	bnez	a1,8ca <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 8d8:	8bce                	mv	s7,s3
      state = 0;
 8da:	4981                	li	s3,0
 8dc:	bbcd                	j	6ce <vprintf+0x4a>
          s = "(null)";
 8de:	00000917          	auipc	s2,0x0
 8e2:	2da90913          	addi	s2,s2,730 # bb8 <malloc+0x1ce>
        for(; *s; s++)
 8e6:	02800593          	li	a1,40
 8ea:	b7c5                	j	8ca <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 8ec:	8bce                	mv	s7,s3
      state = 0;
 8ee:	4981                	li	s3,0
 8f0:	bbf9                	j	6ce <vprintf+0x4a>
 8f2:	64a6                	ld	s1,72(sp)
 8f4:	79e2                	ld	s3,56(sp)
 8f6:	7a42                	ld	s4,48(sp)
 8f8:	7aa2                	ld	s5,40(sp)
 8fa:	7b02                	ld	s6,32(sp)
 8fc:	6be2                	ld	s7,24(sp)
 8fe:	6c42                	ld	s8,16(sp)
 900:	6ca2                	ld	s9,8(sp)
    }
  }
}
 902:	60e6                	ld	ra,88(sp)
 904:	6446                	ld	s0,80(sp)
 906:	6906                	ld	s2,64(sp)
 908:	6125                	addi	sp,sp,96
 90a:	8082                	ret

000000000000090c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 90c:	715d                	addi	sp,sp,-80
 90e:	ec06                	sd	ra,24(sp)
 910:	e822                	sd	s0,16(sp)
 912:	1000                	addi	s0,sp,32
 914:	e010                	sd	a2,0(s0)
 916:	e414                	sd	a3,8(s0)
 918:	e818                	sd	a4,16(s0)
 91a:	ec1c                	sd	a5,24(s0)
 91c:	03043023          	sd	a6,32(s0)
 920:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 924:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 928:	8622                	mv	a2,s0
 92a:	d5bff0ef          	jal	684 <vprintf>
}
 92e:	60e2                	ld	ra,24(sp)
 930:	6442                	ld	s0,16(sp)
 932:	6161                	addi	sp,sp,80
 934:	8082                	ret

0000000000000936 <printf>:

void
printf(const char *fmt, ...)
{
 936:	711d                	addi	sp,sp,-96
 938:	ec06                	sd	ra,24(sp)
 93a:	e822                	sd	s0,16(sp)
 93c:	1000                	addi	s0,sp,32
 93e:	e40c                	sd	a1,8(s0)
 940:	e810                	sd	a2,16(s0)
 942:	ec14                	sd	a3,24(s0)
 944:	f018                	sd	a4,32(s0)
 946:	f41c                	sd	a5,40(s0)
 948:	03043823          	sd	a6,48(s0)
 94c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 950:	00840613          	addi	a2,s0,8
 954:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 958:	85aa                	mv	a1,a0
 95a:	4505                	li	a0,1
 95c:	d29ff0ef          	jal	684 <vprintf>
}
 960:	60e2                	ld	ra,24(sp)
 962:	6442                	ld	s0,16(sp)
 964:	6125                	addi	sp,sp,96
 966:	8082                	ret

0000000000000968 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 968:	1141                	addi	sp,sp,-16
 96a:	e422                	sd	s0,8(sp)
 96c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 96e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 972:	00001797          	auipc	a5,0x1
 976:	68e7b783          	ld	a5,1678(a5) # 2000 <freep>
 97a:	a02d                	j	9a4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 97c:	4618                	lw	a4,8(a2)
 97e:	9f2d                	addw	a4,a4,a1
 980:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 984:	6398                	ld	a4,0(a5)
 986:	6310                	ld	a2,0(a4)
 988:	a83d                	j	9c6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 98a:	ff852703          	lw	a4,-8(a0)
 98e:	9f31                	addw	a4,a4,a2
 990:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 992:	ff053683          	ld	a3,-16(a0)
 996:	a091                	j	9da <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 998:	6398                	ld	a4,0(a5)
 99a:	00e7e463          	bltu	a5,a4,9a2 <free+0x3a>
 99e:	00e6ea63          	bltu	a3,a4,9b2 <free+0x4a>
{
 9a2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9a4:	fed7fae3          	bgeu	a5,a3,998 <free+0x30>
 9a8:	6398                	ld	a4,0(a5)
 9aa:	00e6e463          	bltu	a3,a4,9b2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9ae:	fee7eae3          	bltu	a5,a4,9a2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 9b2:	ff852583          	lw	a1,-8(a0)
 9b6:	6390                	ld	a2,0(a5)
 9b8:	02059813          	slli	a6,a1,0x20
 9bc:	01c85713          	srli	a4,a6,0x1c
 9c0:	9736                	add	a4,a4,a3
 9c2:	fae60de3          	beq	a2,a4,97c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 9c6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9ca:	4790                	lw	a2,8(a5)
 9cc:	02061593          	slli	a1,a2,0x20
 9d0:	01c5d713          	srli	a4,a1,0x1c
 9d4:	973e                	add	a4,a4,a5
 9d6:	fae68ae3          	beq	a3,a4,98a <free+0x22>
    p->s.ptr = bp->s.ptr;
 9da:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9dc:	00001717          	auipc	a4,0x1
 9e0:	62f73223          	sd	a5,1572(a4) # 2000 <freep>
}
 9e4:	6422                	ld	s0,8(sp)
 9e6:	0141                	addi	sp,sp,16
 9e8:	8082                	ret

00000000000009ea <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9ea:	7139                	addi	sp,sp,-64
 9ec:	fc06                	sd	ra,56(sp)
 9ee:	f822                	sd	s0,48(sp)
 9f0:	f426                	sd	s1,40(sp)
 9f2:	ec4e                	sd	s3,24(sp)
 9f4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9f6:	02051493          	slli	s1,a0,0x20
 9fa:	9081                	srli	s1,s1,0x20
 9fc:	04bd                	addi	s1,s1,15
 9fe:	8091                	srli	s1,s1,0x4
 a00:	0014899b          	addiw	s3,s1,1
 a04:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a06:	00001517          	auipc	a0,0x1
 a0a:	5fa53503          	ld	a0,1530(a0) # 2000 <freep>
 a0e:	c915                	beqz	a0,a42 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a10:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a12:	4798                	lw	a4,8(a5)
 a14:	08977a63          	bgeu	a4,s1,aa8 <malloc+0xbe>
 a18:	f04a                	sd	s2,32(sp)
 a1a:	e852                	sd	s4,16(sp)
 a1c:	e456                	sd	s5,8(sp)
 a1e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a20:	8a4e                	mv	s4,s3
 a22:	0009871b          	sext.w	a4,s3
 a26:	6685                	lui	a3,0x1
 a28:	00d77363          	bgeu	a4,a3,a2e <malloc+0x44>
 a2c:	6a05                	lui	s4,0x1
 a2e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a32:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a36:	00001917          	auipc	s2,0x1
 a3a:	5ca90913          	addi	s2,s2,1482 # 2000 <freep>
  if(p == (char*)-1)
 a3e:	5afd                	li	s5,-1
 a40:	a081                	j	a80 <malloc+0x96>
 a42:	f04a                	sd	s2,32(sp)
 a44:	e852                	sd	s4,16(sp)
 a46:	e456                	sd	s5,8(sp)
 a48:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a4a:	00001797          	auipc	a5,0x1
 a4e:	5d678793          	addi	a5,a5,1494 # 2020 <base>
 a52:	00001717          	auipc	a4,0x1
 a56:	5af73723          	sd	a5,1454(a4) # 2000 <freep>
 a5a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a5c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a60:	b7c1                	j	a20 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 a62:	6398                	ld	a4,0(a5)
 a64:	e118                	sd	a4,0(a0)
 a66:	a8a9                	j	ac0 <malloc+0xd6>
  hp->s.size = nu;
 a68:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a6c:	0541                	addi	a0,a0,16
 a6e:	efbff0ef          	jal	968 <free>
  return freep;
 a72:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a76:	c12d                	beqz	a0,ad8 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a78:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a7a:	4798                	lw	a4,8(a5)
 a7c:	02977263          	bgeu	a4,s1,aa0 <malloc+0xb6>
    if(p == freep)
 a80:	00093703          	ld	a4,0(s2)
 a84:	853e                	mv	a0,a5
 a86:	fef719e3          	bne	a4,a5,a78 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a8a:	8552                	mv	a0,s4
 a8c:	b1bff0ef          	jal	5a6 <sbrk>
  if(p == (char*)-1)
 a90:	fd551ce3          	bne	a0,s5,a68 <malloc+0x7e>
        return 0;
 a94:	4501                	li	a0,0
 a96:	7902                	ld	s2,32(sp)
 a98:	6a42                	ld	s4,16(sp)
 a9a:	6aa2                	ld	s5,8(sp)
 a9c:	6b02                	ld	s6,0(sp)
 a9e:	a03d                	j	acc <malloc+0xe2>
 aa0:	7902                	ld	s2,32(sp)
 aa2:	6a42                	ld	s4,16(sp)
 aa4:	6aa2                	ld	s5,8(sp)
 aa6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 aa8:	fae48de3          	beq	s1,a4,a62 <malloc+0x78>
        p->s.size -= nunits;
 aac:	4137073b          	subw	a4,a4,s3
 ab0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ab2:	02071693          	slli	a3,a4,0x20
 ab6:	01c6d713          	srli	a4,a3,0x1c
 aba:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 abc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 ac0:	00001717          	auipc	a4,0x1
 ac4:	54a73023          	sd	a0,1344(a4) # 2000 <freep>
      return (void*)(p + 1);
 ac8:	01078513          	addi	a0,a5,16
  }
}
 acc:	70e2                	ld	ra,56(sp)
 ace:	7442                	ld	s0,48(sp)
 ad0:	74a2                	ld	s1,40(sp)
 ad2:	69e2                	ld	s3,24(sp)
 ad4:	6121                	addi	sp,sp,64
 ad6:	8082                	ret
 ad8:	7902                	ld	s2,32(sp)
 ada:	6a42                	ld	s4,16(sp)
 adc:	6aa2                	ld	s5,8(sp)
 ade:	6b02                	ld	s6,0(sp)
 ae0:	b7f5                	j	acc <malloc+0xe2>
