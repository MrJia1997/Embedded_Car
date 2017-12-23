#include "CarMessage.h"

module CarP {
    provides interface Car;

    uses {
        interface HplMsp430Usart as Usart;
        interface HplMsp430UsartInterrupts as Interrupts;
        interface Resource;
        interface HplMsp430GeneralIO as GeneralIO;
    }
}
implementation {
    
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
        call Resource.request()
    }

    error_t handleCommand(uint8_t type, uint16_t value) {
        if (call Usart.isTxEmpty() == SUCCESS) {
            localInit();
            local.type = type;
            local.data1 = value & 0xFF;
            local.data2 = value >> 8;
            sendCount = 0;
            post startSendCommand();
            return SUCCESS;
        }
        else
            return FAIL;
    }

    void configureSerialPort() {
        msp430_uart_union_config_t config1;
        config1 = {
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
        // TODO: set controller status ?
        // U0CTL &= ~SYNC;
    }

    void writeCommand() {
        sendCount = 0;
        while(1) {
            if(call Usart.isTxEmpty() == SUCCESS) {
                switch(sendCount) {
                    case 0: call Usart.tx(local.header1); break;
                    case 1: call Usart.tx(local.header2); break;
                    case 2: call Usart.tx(local.type); break;
                    case 3: call Usart.tx(local.data1); break;
                    case 4: call Usart.tx(local.data2); break;
                    case 5: call Usart.tx(local.footer1); break;
                    case 6: call Usart.tx(local.footer2); break;
                    default: call Usart.tx(local.footer3); 
                }
                sendCount++;
                if (sendCount >= 8) {
                    sendCount = 0;
                    break;
                }
            }
        }
    }

    event void Resource.granted() {
        configureSerialPort();
        writeCommand();
    }

    command error_t Car.Angle(uint16_t value) { return handleCommand(TYPE_SERVO_1, value); }
    command error_t Car.Angle_Senc(uint16_t value) { return handleCommand(TYPE_SERVO_2, value); }
    command error_t Car.Angle_Third(uint16_t value) { return handleCommand(TYPE_SERVO_3, value); }
    command error_t Car.Forward(uint16_t value) { return handleCommand(TYPE_FORWARD, value); }
    command error_t Car.Back(uint16_t value) { return handleCommand(TYPE_BACK, value); }
    command error_t Car.Left(uint16_t value) { return handleCommand(TYPE_LEFT, value); }
    command error_t Car.Right(uint16_t value) { return handleCommand(TYPE_RIGHT, value); }
    command error_t Car.Pause() { return handleCommand(TYPE_PAUSE, 0); }
    
    // command error_t Car.QuiryReader(uint8_t value) {}
    // event void Car.readDone(error_t state, uint16_t data) {}

    // command error_t Car.InitMaxSpeed(uint16_t value) {}
    // command error_t Car.InitMinSpeed(uint16_t value) {}
    // command error_t Car.InitLeftServo(uint16_t value) {}
    // command error_t Car.InitRightServo(uint16_t value) {}
    // command error_t Car.InitMidServo(uint16_t value) {}
}