#include "stm32f4xx.h"

void initGpio() {
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOF, ENABLE);

    GPIO_InitTypeDef gpioInit = {
        .GPIO_Pin = GPIO_Pin_9,
        .GPIO_Speed = GPIO_Speed_50MHz,
        .GPIO_Mode = GPIO_Mode_OUT,
    };

    GPIO_Init(GPIOF, &gpioInit);
}

int main(void)
{
    GPIO_ResetBits(GPIOF, GPIO_Pin_9);
    while (1) {


    }
}
