# STM32F4xx 标准外设库开发模板

基于 STM32F4xx Standard Peripheral Library V1.9.0，GCC (arm-none-eabi-gcc) 工具链，Makefile 构建。

## 目录结构

```
├── Makefile              构建脚本
├── User/                 你的代码
│   ├── main.c            主程序入口
│   ├── stm32f4xx_it.c    中断服务函数
│   ├── stm32f4xx_it.h
│   ├── stm32f4xx_conf.h  外设裁剪 (注释掉不用的驱动加速编译)
│   └── system_stm32f4xx.c  PLL时钟配置
├── cmsis/
│   ├── include/           CMSIS 核心头文件 (core_cm4.h 等)
│   ├── device/            stm32f4xx.h + 启动文件 + system_stm32f4xx.c
│   └── libarm_cortexM4lf_math.a  DSP 预编译库
├── lib/                   标准外设库 (38 头文件 + 43 源文件)
└── linker/                GCC 链接脚本 (10 个芯片型号)
```

## 支持的芯片

| 芯片 | TARGET_MCU | 启动文件 | 链接脚本 | 主频 |
|------|-----------|---------|---------|------|
| STM32F407/405 | STM32F40_41xxx | startup_stm32f40_41xxx.s | STM32F417IGHx_FLASH.ld | 168MHz |
| STM32F401 | STM32F401xx | startup_stm32f401xx.s | STM32F401VCTx_FLASH.ld | 84MHz |
| STM32F411 | STM32F411xE | startup_stm32f411xe.s | STM32F411RETx_FLASH.ld | 100MHz |
| STM32F427/437 | STM32F427_437xx | startup_stm32f427_437xx.s | STM32F437IIHx_FLASH.ld | 180MHz |
| STM32F429/439 | STM32F429_439xx | startup_stm32f429_439xx.s | STM32F439NIHx_FLASH.ld | 180MHz |
| STM32F446 | STM32F446xx | startup_stm32f446xx.s | STM32F446ZETx_FLASH.ld | 180MHz |
| STM32F469/479 | STM32F469_479xx | startup_stm32f469_479xx.s | STM32F479NIHx_FLASH.ld | 180MHz |

其他子型号 (F410/F412/F413) 需从原始库复制对应启动文件到 `cmsis/device/`，链接脚本到 `linker/`。

## 使用方法

### 1. 安装工具链

```bash
# macOS
brew install arm-none-eabi-gcc stlink stm32flash

# Ubuntu/Debian
sudo apt install gcc-arm-none-eabi stlink-tools stm32flash

# Arch Linux
sudo pacman -S arm-none-eabi-gcc arm-none-eabi-newlib stlink stm32flash
```

### 2. 选择芯片

编辑 `Makefile` 顶部三行：

```makefile
TARGET_MCU   = STM32F40_41xxx
STARTUP_FILE = startup_stm32f40_41xxx.s
LDSCRIPT     = linker/STM32F417IGHx_FLASH.ld
```

如果链接脚本的 Flash/RAM 大小与你的芯片不匹配，修改 `.ld` 文件中 MEMORY 段。

### 3. 编写代码

编辑 `User/main.c`，所有标准外设库 API 可直接使用：

```c
#include "stm32f4xx.h"

int main(void)
{
    GPIO_InitTypeDef GPIO_InitStruct;

    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOF, ENABLE);

    GPIO_InitStruct.GPIO_Pin   = GPIO_Pin_9 | GPIO_Pin_10;
    GPIO_InitStruct.GPIO_Mode  = GPIO_Mode_OUT;
    GPIO_InitStruct.GPIO_OType = GPIO_OType_PP;
    GPIO_InitStruct.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStruct.GPIO_PuPd  = GPIO_PuPd_NOPULL;
    GPIO_Init(GPIOF, &GPIO_InitStruct);

    while (1)
    {
        GPIO_ToggleBits(GPIOF, GPIO_Pin_9 | GPIO_Pin_10);
        for (volatile int i = 0; i < 2000000; i++) {}
    }
}
```

添加中断处理函数到 `User/stm32f4xx_it.c`。

### 4. 编译

```bash
make            # 编译
make clean      # 清理
make size       # 查看固件大小
```

### 5. 烧录

**ST-Link (SWD，推荐)：**
```bash
make flash
```

**串口 ISP：**
```bash
# BOOT0接3.3V，BOOT1接GND，USB-TTL连USART1 (PA9-TX, PA10-RX)
make ISP_PORT=/dev/tty.usbserial-xxx isp
```

### 6. 调试

```bash
make gdb        # 需要 OpenOCD + ST-Link
```

## 使用 CMSIS-DSP 库

编辑 `Makefile`，取消注释这两行：

```makefile
LDFLAGS += cmsis/libarm_cortexM4lf_math.a
C_INCLUDES += -Icmsis/include
```

然后在代码中 `#include "arm_math.h"` 即可。

## printf 串口输出

需要自己实现 `_write` 或 `fputc` 把字符发到串口，示例：

```c
#include <stdio.h>

// GCC 环境
int _write(int file, char *ptr, int len)
{
    for (int i = 0; i < len; i++)
    {
        USART_SendData(USART1, ptr[i]);
        while (USART_GetFlagStatus(USART1, USART_FLAG_TXE) == RESET);
    }
    return len;
}
```

Makefile 中取消 `-u _printf_float` 的注释可支持浮点打印。

## 添加新的外设驱动

1. 在 `User/` 创建 `xxx_driver.c/h`
2. 在 `Makefile` 的 `C_SOURCES` 中添加路径
3. 在 `stm32f4xx_conf.h` 中 include 对应外设头文件

## 已验证硬件

- 正点原子 探索者 STM32F407IGT6 (LED: PF9/PF10)
