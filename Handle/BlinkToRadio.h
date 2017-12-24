// $Id: BlinkToRadio.h,v 1.4 2006-12-12 18:22:52 vlahan Exp $

#ifndef BLINKTORADIO_H
#define BLINKTORADIO_H

enum {
  AM_BLINKTORADIOMSG = 6,
  AM_STEPMSG = 7,
  TIMER_PERIOD_MILLI = 250,
  AM_SEND_ID = 1234
};

typedef nx_struct BlinkToRadioMsg {
  nx_uint8_t type;
  nx_uint16_t data;
} BlinkToRadioMsg;

typedef nx_struct StepMsg {
  nx_uint8_t buttonA;
  nx_uint8_t buttonB;
  nx_uint8_t buttonC;
  nx_uint8_t buttonD;
  nx_uint8_t buttonE;
  nx_uint8_t buttonF;
} StepMsg;

#endif
