#ifndef RADIOMESSAGE_H
#define RADIOMESSAGE_H

enum {
    AM_BLINKTORADIOMSG = 6,
    AM_SERIAL_MSG = 10,
    AM_SEND_ID = 1234
};

typedef nx_struct BlinkToRadioMsg {
    nx_uint8_t type;
    nx_uint16_t data;
} BlinkToRadioMsg;

#endif