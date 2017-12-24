module CarP {
    provides interface Car;

    uses {
        interface Leds;
        interface HplMsp430Usart as Usart;
        // interface HplMsp430UsartInterrupts as Interrupts;
        interface Resource;
        interface HplMsp430GeneralIO as GeneralIO;
    }
}
// #include "CarMessage.h"
implementation {
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

    Control_Msg local;
    uint8_t sendCount;
    // bool busy;

    void localInit() {
        local.header1 = HEADER_1;
        local.header2 = HEADER_2;
        local.footer1 = FOOTER_1;
        local.footer2 = FOOTER_2;
        local.footer3 = FOOTER_3;
    }

    task void startSendCommand() {
        call Resource.request();
    }

    error_t handleCommand(uint8_t type, uint16_t value) {
        if (call Usart.isTxEmpty() == SUCCESS) {
            localInit();
            local.type = type;
            local.data1 = value & 0x00FF;
            local.data2 = value >> 8;
            sendCount = 0;
            post startSendCommand();
            return SUCCESS;
        }
        else
            return FAIL;
    }

    void configureSerialPort() {
        msp430_uart_union_config_t config1 = {
            {
                utxe: 1,
                urxe: 1,
                ubr: UBR_1MHZ_115200,       // Baud rate (use enum msp430_uart_rate_t for predefined rates)
                umctl: UMCTL_1MHZ_115200,   // Modulation (use enum msp430_uart_rate_t for predefined rates)
                ssel: 0x02,                 // Clock source (00=UCLKI; 01=ACLK; 10=SMCLK; 11=SMCLK)
                pena: 0,                    // Parity enable (0=disabled; 1=enabled)
                pev: 0,                     // Parity select (0=odd; 1=even)
                spb: 0,                     // Stop bits (0=one stop bit; 1=two stop bits)
                clen: 1,                    // Character length (0=7-bit data; 1=8-bit data)
                listen: 0,                  // Listen enable (0=disabled; 1=enabled, feed tx back to receiver)
                mm: 0,                      // Multiprocessor mode (0=idle-line protocol; 1=address-bit protocol)
                ckpl: 0,                    // Clock polarity (0=normal; 1=inverted)
                urxse: 0,                   // Receive-edge detection (0=disabled; 1=enabled)
                urxeie: 0,                  // Errorneous-character receive (0=rejected; 1=received and URXIFGx set)
                urxwie: 0,                  // Wake-up interrupt-enable (0=all characters set URXIFGx; 1=only address sets URXIFGx)
                utxe: 1,                    // 1: enable tx module
                urxe: 1                     // 1: enable rx module
            }
        };
        call Usart.setModeUart(&config1);
        call Usart.enableUart();
        atomic U0CTL &= ~SYNC;
    }

    void writeCommand() {
        call Leds.led1Toggle();
        sendCount = 0;
        while(1) {
            if(call Usart.isTxEmpty()) {
                switch(sendCount) {
                    case 0: call Usart.tx(local.header1); call Leds.led2Toggle(); break;
                    case 1: call Usart.tx(local.header2); call Leds.led2Toggle(); break;
                    case 2: call Usart.tx(local.type); call Leds.led2Toggle(); break;
                    case 3: call Usart.tx(local.data1); call Leds.led2Toggle(); break;
                    case 4: call Usart.tx(local.data2); call Leds.led2Toggle(); break;
                    case 5: call Usart.tx(local.footer1); call Leds.led2Toggle(); break;
                    case 6: call Usart.tx(local.footer2); call Leds.led2Toggle(); break;
                    default: call Usart.tx(local.footer3); call Leds.led2Toggle();
                }
                sendCount++;
                if (sendCount >= 8) {
                    sendCount = 0;
                    break;
                }
            }
        }
        call Resource.release();
    }

    event void Resource.granted() {
        configureSerialPort();
        writeCommand();
    }

    command error_t Car.Angle(uint16_t value) { call Leds.led0Toggle(); return handleCommand(TYPE_SERVO_1, value); }
    command error_t Car.Angle_Senc(uint16_t value) { call Leds.led0Toggle(); return handleCommand(TYPE_SERVO_2, value); }
    command error_t Car.Angle_Third(uint16_t value) { call Leds.led0Toggle(); return handleCommand(TYPE_SERVO_3, value); }
    command error_t Car.Forward(uint16_t value) { call Leds.led0Toggle(); return handleCommand(TYPE_FORWARD, value); }
    command error_t Car.Back(uint16_t value) { call Leds.led0Toggle(); return handleCommand(TYPE_BACK, value); }
    command error_t Car.Left(uint16_t value) { call Leds.led0Toggle(); return handleCommand(TYPE_LEFT, value); }
    command error_t Car.Right(uint16_t value) { call Leds.led0Toggle(); return handleCommand(TYPE_RIGHT, value); }
    command error_t Car.Pause() { call Leds.led0Toggle(); return handleCommand(TYPE_PAUSE, 0); }
    
    // command error_t Car.QuiryReader(uint8_t value) {}
    // event void Car.readDone(error_t state, uint16_t data) {}

    // command error_t Car.InitMaxSpeed(uint16_t value) {}
    // command error_t Car.InitMinSpeed(uint16_t value) {}
    // command error_t Car.InitLeftServo(uint16_t value) {}
    // command error_t Car.InitRightServo(uint16_t value) {}
    // command error_t Car.InitMidServo(uint16_t value) {}
}