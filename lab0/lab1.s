    .option nopic
    .attribute arch, "rv64i2p1_m2p0_d2p2"
    .attribute unaligned_access, 0
    .attribute stack_align, 16
    .text

    .globl my_add
    .globl main
my_add:
    add a0, a0, a1
    ret
main:
    # --- 函数序言：保存main的返回地址 ---
    addi sp, sp, -192           # (0xC0 + 28 + 16 = 192 + 28 + 16 = 224) 提前分配好所有空间
    sd ra, 184(sp)              # 将ra保存在栈顶附近
    mv s2, sp                   # s2指向栈顶

    # 一、基本的算术运算指令 int a = 1 + 2 * 3
    li a0, 1
    li a1, 2
    li a2, 3
    mul a1, a1, a2

    sd  ra, 176(s2)
    call my_add
    ld  ra, 176(s2)                         # a0 = my_add(a0, a1)，局部变量a存在a0中

    sw a0, 0(sp)                          # 保存局部变量a到栈中

    # 二、if-else 语句 int flag; if(a > 6) flag = 1; else flag = 0;
    li a1, 6
    bgt a0, a1, then_label
    li a2, 0
    j endif_label
    then_label:
    li a2, 1                            #flag存在a2中
endif_label:
    sw a2, 4(sp)                        # 保存局部变量flag到栈中
    
    # 三、循环语句 while循环计算1-10的和
    li a0, 1
    li a1, 10
    li a2, 0
    bge a0, a1, endwhile_label
while_label:
    add a2, a2, a0
    addi a0, a0, 1
    ble a0, a1, while_label             # 局部变量sum存在a2中  
endwhile_label:
    sw a2, 8(sp)                        # 保存局部变量sum到栈中

    # 四、for循环，五、循环中的break与continue语句
    # int prod; prod = 1; for(int i = 1; i <= 5; i++) { if(i == 3) continue; if(i == 4) break; prod *= i; }
    li a0, 1                            # prod存在a0中
    li a1, 1                            # i存在a1中
    li a2, 5                            # a2 = 5
    li a3, 3
    li a4, 4 
for_label:
    bgt a1, a2, endfor_label            # a1 <= a2 时进入循环
    beq a1, a3, continue_label          # 跳过i=3的循环
    beq a1, a4, endfor_label            # 跳出循环
    mul a0, a0, a1                      # 计算prod *= i
continue_label:
    addi a1, a1, 1
    j for_label
endfor_label:                           # prod = a0
    sw a0, 12(sp)                       # 保存局部变量prod到栈中

    # 六、自定义函数的调用
    # int s2 = my_add(sum, prod)
    lw a0, 8(sp)                        # a0 = sum
    lw a1, 12(sp)                       # a1 = prod

    sd ra, 176(s2)
    call my_add                         # a0 = my_add(a0, a1)，局部变量s2存在a0中
    ld ra, 176(s2)

    sw a0, 16(sp)                       # sum + prod在16(sp)

    # 七、数组声明、赋值与访问
    # int arr[5] = {10, 20, arr[0] + arr[1] - 5, 0, 1};
    mv a3, sp                           # a3 = sp
    addi sp, sp, 20                     # 前面用到了 sp + 16, 所以从sp + 20 开始分配空间 

    li t0, 10
    sw t0, 0(sp)                        # arr[0] = 10
    li t0, 20
    sw t0, 4(sp)                        # arr[1] = 20
    lw a0, 0(sp)                        # a0 = arr[0]
    lw a1, 4(sp)                        # a1 = arr[1]

    sd ra, 176(s2)
    call my_add                         # a0 = my_add(a0, a1)
    ld ra, 176(s2)
    
    addi a0, a0, -5                      # a0 = a0 - 5
    sw a0, 8(sp)                        # arr[2] = arr[0] + arr[1] - 5  
    li t0, 0
    sw t0, 12(sp)                       # arr[3] = 0   
    li t0, 1
    sw t0, 16(sp)                       # arr[4] = 1

    # int arr_sum; arr_sum = 0; for(int i = 0; i < 5; i++) { arr_sum += arr[i]; }
    li t0, 0                            # arr_sum存在t0中
    li t1, 0                            # i存在t1中
    li t2, 5                            # t2 = 5
    mv t3, sp                           # t3 = sp
for_label2:
    bge t1, t2, endfor_label2           # i < 5 时进入循环
    lw t4, 0(t3)                        # t4 = arr[i]
    add t0, t0, t4                      # arr_sum += arr[i]
    addi t1, t1, 1                      # i++
    addi t3, t3, 4                      # 指向下一个元素
    j for_label2                        # 进入下一次循环
endfor_label2:
    sw t0, 20(sp)                       # arr_sum存在sp+20中  

    # result = a + flag + sum + prod + s2 + arr_sum
    lw a0, 20(sp)                   # a0 = arr_sum

    lw a1, 0(a3)                    # a1 = a
    add a0, a0, a1                  # a0 = a0 + a1
    lw a1, 4(a3)                    # a1 = flag
    add a0, a0, a1                  # a0 = a0 + flag
    lw a1, 8(a3)                    # a1 = sum
    add a0, a0, a1                  # a0 = a0 + sum
    lw a1, 12(a3)                   # a1 = prod
    add a0, a0, a1                  # a0 = a0 + prod
    lw a1, 16(a3)                   # a1 = s2
    add a0, a0, a1                  # a0 = a0 + s2

    sd ra, 176(s2)
    call putint
    ld ra, 176(s2)

    ld ra, 184(s2)

    # 函数尾声: 清理堆栈并返回
    mv sp, s2        # 修正: 恢复堆栈指针
    ret                           # 修正: 从 main 函数返回




