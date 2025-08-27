#include <stdint.h>
#include <stdio.h>

#define GPIO_BASE_ADDR  0x10019000
 
#define REG_GPIO_DR    *(volatile uint32_t*)(0x00 + GPIO_BASE_ADDR)
#define REG_GPIO_DDR   *(volatile uint32_t*)(0x04 + GPIO_BASE_ADDR)
#define REG_GPIO_CTL   *(volatile uint32_t*)(0x08 + GPIO_BASE_ADDR)

//#define REG_GPIO_LOCK  *(volatile uint32_t*)(0x0c + GPIO_BASE_ADDR)
#define REG_KEY        *(volatile uint32_t*)(0x10 + GPIO_BASE_ADDR)
#define REG_PWD        *(volatile uint32_t*)(0x14 + GPIO_BASE_ADDR)
//#define REG_BUG        *(volatile uint32_t*)(0x18 + GPIO_BASE_ADDR)


static inline void pmp_level_allow() {
    uintptr_t allones = ~(uintptr_t)0;
    uintptr_t paddr = (allones >> 2);
    asm volatile("csrw pmpaddr0, %0" :: "r"(paddr));
    uint32_t cfg = 0x0F;
    asm volatile("csrw pmpcfg0, %0" :: "r"(cfg));
}

__attribute__((aligned(4))) void user_mode_main(){

  uint32_t gpio_state;
  uint8_t  gpio_buf[4];

  printf("**********BUG DETECT****************\n");
  printf("Current level: MPP = 0, U mode");
  printf("\n");
  REG_PWD = 0x04;
  for(uint8_t i=0; i < 256; i++){
    REG_KEY = i;
    REG_GPIO_DR = 0x00;
    gpio_buf[0] = REG_GPIO_DR;
    REG_GPIO_DR = 0x0f;
    gpio_buf[1] = REG_GPIO_DR;
    REG_GPIO_DR = 0xf0;
    gpio_buf[2] = REG_GPIO_DR;
    REG_GPIO_DR = 0xff;
    gpio_buf[3] = REG_GPIO_DR;
    gpio_state = (gpio_buf[3]<<24) | (gpio_buf[2]<<16) | (gpio_buf[1]<<8) | gpio_buf[0];
    printf("input value = 0xfff00f00, output value = 0x%08x\t", gpio_state);
    printf("REG_PWD = 0x04, REG_KEY = 0x%02x\n", i);
    if(gpio_state == 0xfff00f00){
      printf("BUG detected, REG_KEY can be modified on U mode\n");
      break;
    }
  }
  
  exit(0);
}

void M2U_swich(){
 
  uint32_t mstatus;
  uint32_t mepc = (uint32_t)user_mode_main;
  asm volatile("csrr %0, mstatus" : "=r"(mstatus));
  mstatus &= ~(3UL << 11);
  asm volatile("csrw mstatus, %0" :: "r"(mstatus));
  asm volatile("csrw mepc, %0" :: "r"(mepc));
  //printf("\nSwitch mode from M mode to U mode\n");
  //printf("MEPC = %08x, user mode main function address\n\n", mepc);
  asm volatile("mret");
  
  return;
}


void main(){
  uint32_t gpio_state;
  uint8_t  gpio_buf[4];
  REG_GPIO_DDR = 0xff;

  printf("#######GPIO_LOCK BUG TEST#########\n");  
  uint32_t mstatus;
  asm volatile("csrr %0, mstatus" : "=r"(mstatus));

  printf("**********TEST 1****************\n");
  printf("Current level: MPP = %d, M mode\n", (mstatus>>11 & 0x3));
  REG_PWD = 0x03;
  for(uint8_t i=0; i < 256; i++){
    REG_KEY = i;
    REG_GPIO_DR = 0x00;
    gpio_buf[0] = REG_GPIO_DR;
    REG_GPIO_DR = 0x0f;
    gpio_buf[1] = REG_GPIO_DR;
    REG_GPIO_DR = 0xf0;
    gpio_buf[2] = REG_GPIO_DR;
    REG_GPIO_DR = 0xff;
    gpio_buf[3] = REG_GPIO_DR;
    gpio_state = (gpio_buf[3]<<24) | (gpio_buf[2]<<16) | (gpio_buf[1]<<8) | gpio_buf[0];
    printf("input value = 0xfff00f00, output value = 0x%08x\t", gpio_state);
    printf("REG_PWD = 0x03, REG_KEY = 0x%02x\n", i);
    if(gpio_state == 0xfff00f00){
      break;
    }
  }
  
  printf("**********TEST 2****************\n");
  printf("Current level: MPP = %d, M mode\n", (mstatus>>11 & 0x3));
  REG_PWD = 0x05;
  for(uint8_t i=0; i < 256; i++){
    REG_KEY = i;
    REG_GPIO_DR = 0x00;
    gpio_buf[0] = REG_GPIO_DR;
    REG_GPIO_DR = 0x0f;
    gpio_buf[1] = REG_GPIO_DR;
    REG_GPIO_DR = 0xf0;
    gpio_buf[2] = REG_GPIO_DR;
    REG_GPIO_DR = 0xff;
    gpio_buf[3] = REG_GPIO_DR;
    gpio_state = (gpio_buf[3]<<24) | (gpio_buf[2]<<16) | (gpio_buf[1]<<8) | gpio_buf[0];
    printf("input value = 0xfff00f00, output value = 0x%08x\t", gpio_state);
    printf("REG_PWD = 0x05, REG_KEY = 0x%02x\n", i);
    if(gpio_state == 0xfff00f00){
      break;
    }
  }

  pmp_level_allow();
  M2U_swich();
  
  return;
}
