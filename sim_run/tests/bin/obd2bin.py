#!/usr/bin/env python
# coding=UTF-8（等号换为”:“也可以）

import argparse
#obj_file = '${CUTERISCV}/sim_run/work/${FILE}_elf.txt'
#bin_file = '${CUTERISCV}/sim_run/work/cutecore.v_toplevel_icache_inst_icache_rom.bin'

import sys

import re

def is_hexadecimal(s):
    try:
        int(s, 16)
        return True
    except ValueError:
        return False

def process_files(input_file_path, output_file_path):
    try:
        with open(input_file_path, 'r') as input_file:
            with open(output_file_path, 'w') as output_file:
                bin_num = 0
                bin_total = 65536 # todo
                for line in input_file:
                    incre_flag = 1
                    while incre_flag:
                        line = line.strip()
                        if ":" in line:
                            line_s = line.split(":")
                            if (is_hexadecimal(line_s[0])):
                                index = int(line_s[0],16)/4
                                if(index == bin_num):
                                    content = line.split(":")[1].strip()
                                    first_part = content.split(" ")[0].strip()
                                    binary_content = int(first_part, 16)
                                    binary = '{:032b}'.format(binary_content)
                                    print(binary)
                                    output_file.write(binary + b'\n')
                                    incre_flag = 0
                                    bin_num = bin_num+1
                                else:
                                    binary = '{:032b}'.format(0)
                                    print(binary)
                                    output_file.write(binary + b'\n')
                                    incre_flag = 1
                                    bin_num = bin_num+1
                            else:
                                incre_flag = 0
                        else:
                            incre_flag = 0
                if(bin_num < bin_total):
                    while(bin_num < bin_total):
                        binary = '{:032b}'.format(0)
                        print(binary)
                        output_file.write(binary + b'\n')
                        bin_num = bin_num+1

    except IOError:
        print("输入文件 {input_file_path} 不存在，请检查文件路径是否正确。")
    #except Exception as e:
    #    print("处理文件过程中出现错误: {e}")


if __name__ == "__main__":
    if len(sys.argv)!= 3:
        print("请传入正确的参数，格式为：python 脚本名 input.txt output.txt")
        sys.exit(1)
    input_file_path = sys.argv[1]
    output_file_path = sys.argv[2]
    process_files(input_file_path, output_file_path)