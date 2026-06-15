###############################################################################
# STM32F4xx 标准外设库开发模板 - Makefile
# arm-none-eabi-gcc 工具链
#
# 用法:  make / make clean / make flash / make size / make gdb
###############################################################################

# ========= 改这里: 目标芯片 =========
TARGET_MCU   = STM32F40_41xxx
STARTUP_FILE = startup_stm32f40_41xxx.s
LDSCRIPT     = linker/STM32F417IGHx_FLASH.ld

# 其他芯片示例 (取消注释，注释掉上面三行):
# F401:  STM32F401xx     startup_stm32f401xx.s       linker/STM32F401VCTx_FLASH.ld
# F411:  STM32F411xE     startup_stm32f411xe.s       linker/STM32F411RETx_FLASH.ld
# F427:  STM32F427_437xx startup_stm32f427_437xx.s   linker/STM32F437IIHx_FLASH.ld
# F429:  STM32F429_439xx startup_stm32f429_439xx.s   linker/STM32F439NIHx_FLASH.ld
# F446:  STM32F446xx     startup_stm32f446xx.s       linker/STM32F446ZETx_FLASH.ld
# F469:  STM32F469_479xx startup_stm32f469_479xx.s   linker/STM32F479NIHx_FLASH.ld

# ========= 工具链 =========
PREFIX = arm-none-eabi-
CC     = $(PREFIX)gcc
AS     = $(PREFIX)gcc -x assembler-with-cpp
CP     = $(PREFIX)objcopy
SZ     = $(PREFIX)size

TARGET = firmware

# ========= 源文件 =========

# 用户代码
C_SOURCES = User/main.c User/stm32f4xx_it.c

# CMSIS 系统初始化
C_SOURCES += cmsis/device/system_stm32f4xx.c

# 标准外设库 —— 通用 (所有型号都有)
C_SOURCES += \
lib/stm32f4xx_adc.c    lib/stm32f4xx_crc.c     lib/stm32f4xx_dbgmcu.c \
lib/stm32f4xx_dma.c    lib/stm32f4xx_exti.c    lib/stm32f4xx_flash.c \
lib/stm32f4xx_gpio.c   lib/stm32f4xx_i2c.c     lib/stm32f4xx_iwdg.c \
lib/stm32f4xx_pwr.c    lib/stm32f4xx_rcc.c     lib/stm32f4xx_rtc.c \
lib/stm32f4xx_sdio.c   lib/stm32f4xx_spi.c     lib/stm32f4xx_syscfg.c \
lib/stm32f4xx_tim.c    lib/stm32f4xx_usart.c   lib/stm32f4xx_wwdg.c \
lib/misc.c

# 条件驱动 —— 按型号自动包含
ifneq ($(filter $(TARGET_MCU),STM32F40_41xxx STM32F427_437xx STM32F429_439xx STM32F446xx STM32F469_479xx STM32F413_423xx),)
C_SOURCES += lib/stm32f4xx_cryp.c lib/stm32f4xx_cryp_aes.c lib/stm32f4xx_cryp_des.c lib/stm32f4xx_cryp_tdes.c
C_SOURCES += lib/stm32f4xx_hash.c lib/stm32f4xx_hash_md5.c lib/stm32f4xx_hash_sha1.c
C_SOURCES += lib/stm32f4xx_rng.c lib/stm32f4xx_can.c lib/stm32f4xx_dac.c lib/stm32f4xx_dcmi.c
endif
ifneq ($(filter $(TARGET_MCU),STM32F40_41xxx),)
C_SOURCES += lib/stm32f4xx_fsmc.c
endif
ifneq ($(filter $(TARGET_MCU),STM32F427_437xx STM32F429_439xx STM32F446xx STM32F469_479xx),)
C_SOURCES += lib/stm32f4xx_fmc.c lib/stm32f4xx_dma2d.c lib/stm32f4xx_sai.c
endif
ifneq ($(filter $(TARGET_MCU),STM32F429_439xx STM32F469_479xx),)
C_SOURCES += lib/stm32f4xx_ltdc.c
endif
ifneq ($(filter $(TARGET_MCU),STM32F446xx STM32F469_479xx),)
C_SOURCES += lib/stm32f4xx_qspi.c
endif
ifneq ($(filter $(TARGET_MCU),STM32F410xx STM32F446xx),)
C_SOURCES += lib/stm32f4xx_fmpi2c.c
endif
ifneq ($(filter $(TARGET_MCU),STM32F446xx),)
C_SOURCES += lib/stm32f4xx_spdifrx.c lib/stm32f4xx_cec.c
endif
ifneq ($(filter $(TARGET_MCU),STM32F469_479xx),)
C_SOURCES += lib/stm32f4xx_dsi.c
endif
ifneq ($(filter $(TARGET_MCU),STM32F410xx),)
C_SOURCES += lib/stm32f4xx_lptim.c
endif
ifneq ($(filter $(TARGET_MCU),STM32F411xE),)
C_SOURCES += lib/stm32f4xx_flash_ramfunc.c
endif
ifneq ($(filter $(TARGET_MCU),STM32F412xG STM32F413_423xx),)
C_SOURCES += lib/stm32f4xx_fsmc.c lib/stm32f4xx_dfsdm.c
endif

# 启动文件
ASM_SOURCES = cmsis/device/$(STARTUP_FILE)

# ========= 包含路径 =========
C_INCLUDES = \
-IUser \
-Icmsis/include \
-Icmsis/device \
-Ilib

# ========= 编译参数 =========
CFLAGS  = -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard
CFLAGS += -Wall -fdata-sections -ffunction-sections -fno-common -Os -g -std=c99
CFLAGS += $(C_INCLUDES) -D$(TARGET_MCU) -DUSE_STDPERIPH_DRIVER

ASFLAGS = -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard -g

LDFLAGS  = -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard
LDFLAGS += -specs=nosys.specs -specs=nano.specs -T$(LDSCRIPT)
LDFLAGS += -Wl,--gc-sections -Wl,-Map=$(BUILD)/$(TARGET).map,--cref
LDFLAGS += -lm -lc -lnosys
# LDFLAGS += -u _printf_float                    # 浮点 printf
# LDFLAGS += cmsis/libarm_cortexM4lf_math.a      # CMSIS-DSP

# ========= 构建 =========
BUILD = build

OBJECTS  = $(addprefix $(BUILD)/,$(notdir $(C_SOURCES:.c=.o)))
OBJECTS += $(addprefix $(BUILD)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

all: $(BUILD)/$(TARGET).elf $(BUILD)/$(TARGET).hex $(BUILD)/$(TARGET).bin size

$(BUILD)/%.o: %.c | $(BUILD)
	@$(CC) -c $(CFLAGS) -MMD -MP $< -o $@

$(BUILD)/%.o: %.s | $(BUILD)
	@$(AS) -c $(ASFLAGS) $< -o $@

$(BUILD)/$(TARGET).elf: $(OBJECTS)
	@$(CC) $(OBJECTS) $(LDFLAGS) -o $@

$(BUILD)/%.hex: $(BUILD)/%.elf ; @$(CP) -O ihex $< $@
$(BUILD)/%.bin: $(BUILD)/%.elf ; @$(CP) -O binary -S $< $@
$(BUILD)       : ; @mkdir -p $@

size: $(BUILD)/$(TARGET).elf ; @$(SZ) $<

# ========= 烧录 =========

# ST-Link
flash: $(BUILD)/$(TARGET).bin ; st-flash write $< 0x08000000

# 串口 ISP (BOOT0=1, BOOT1=0, 连接 USART1: PA9-TX PA10-RX)
ISP_PORT ?= /dev/tty.usbserial-xxx
ISP_BAUD ?= 115200

isp: $(BUILD)/$(TARGET).bin
	stm32flash -w $< -v -g 0x08000000 -b $(ISP_BAUD) $(ISP_PORT)

flash-ocd: $(BUILD)/$(TARGET).elf
	openocd -f interface/stlink-v2.cfg -f target/stm32f4x.cfg -c "program $< verify reset exit"

gdb: $(BUILD)/$(TARGET).elf ; $(GDB) -tui $< -ex "target remote :3333"

clean: ; rm -rf $(BUILD)

-include $(wildcard $(BUILD)/*.d)

.PHONY: all clean flash isp flash-ocd gdb size
