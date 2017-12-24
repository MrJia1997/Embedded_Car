#ifndef MESSAGE_H
#define MESSAGE_H
enum {
    HEADER_1 = 0x01,
    HEADER_2 = 0x02,
    TYPE_SERVO_1 = 0x01,
    TYPE_FORWARD = 0x02,
    TYPE_BACK = 0x03,
    TYPE_LEFT = 0x04,
    TYPE_RIGHT = 0x05,
    TYPE_PAUSE = 0x06,
    TYPE_SERVO_2 = 0x07,
    TYPE_SERVO_3 = 0x08,
    FOOTER_1 = 0xFF,
    FOOTER_2 = 0xFF,
    FOOTER_3 = 0x00
};

typedef struct Control_Msg {
    uint8_t header1;
    uint8_t header2;
    uint8_t type;
    uint8_t data1;
    uint8_t data2;
    uint8_t footer1;
    uint8_t footer2;
    uint8_t footer3;
} Control_Msg;

#endif