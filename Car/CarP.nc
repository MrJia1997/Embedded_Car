module CarP {
    provides interface Car;

    uses {
        interface Leds;
        interface Timer<TMilli> as TimerInit;
        interface HplMsp430Usart as Usart;
        // interface HplMsp430UsartInterrupts as Interrupts;
        interface Resource;
        interface HplMsp430GeneralIO as GeneralIO;
    }
}
implementation {
    enum {
        HEADER_1 = 0x01,
        HEADER_2 = 0x02,
        TYPE_SERVO_1 = 0x01,
        TYPE_FORWARD = 0x04,
        TYPE_BACK = 0x05,
        TYPE_LEFT = 0x03,
        TYPE_RIGHT = 0x02,
        TYPE_PAUSE = 0x06,
        TYPE_SERVO_2 = 0x07,
        TYPE_SERVO_3 = 0x08,
        FOOTER_1 = 0x0FF,
        FOOTER_2 = 0x0FF,
        FOOTER_3 = 0x00,
        SERVO_DEFAULT = 3000,
        SERVO_DELTA = 300,
        SERVO_MIN = 700,
        SERVO_MAX = 4300
    };

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

    uint8_t buffer[8];
    uint16_t servoPos[16];
    uint8_t sendCount;
    uint8_t initCount;
    bool busy = FALSE;

    void localInit() {
        buffer[0] = HEADER_1;
        buffer[1] = HEADER_2;
        buffer[5] = FOOTER_1;
        buffer[6] = FOOTER_2;
        buffer[7] = FOOTER_3;
    }

    void startSendCommand() {
        call Resource.request();
    }

    error_t handleCommand(uint8_t type, uint16_t value) {
        if (!busy) {
            busy = TRUE;
            localInit();
            buffer[2] = type;
            buffer[3] = (value >> 8) & 0x00FF;
            buffer[4] = value & 0x00FF;
            
            servoPos[type] = value;
            startSendCommand();
            return SUCCESS;
        }
        else
            return FAIL;
    }

    error_t handleServoChange(uint8_t type, uint16_t flag) {
        while(busy);
        if (flag == 0) {
            if (servoPos[type] - SERVO_DELTA >= SERVO_MIN)
                handleCommand(type, servoPos[type] - SERVO_DELTA);
            else
                handleCommand(type, SERVO_MIN);
        }
        else {
            if (servoPos[type] + SERVO_DELTA <= SERVO_MAX)
                handleCommand(type, servoPos[type] + SERVO_DELTA);
            else
                handleCommand(type, SERVO_MAX);
        }          
    }


    event void TimerInit.fired() {
        switch(initCount) {
            case 0: handleCommand(TYPE_SERVO_1, SERVO_DEFAULT); initCount++; break;
            case 1: handleCommand(TYPE_SERVO_2, SERVO_DEFAULT); initCount++; break;
            case 2: handleCommand(TYPE_SERVO_3, SERVO_DEFAULT); initCount++; break;
            default: call TimerInit.stop();
        }
    }
    error_t handleInit() {
        handleCommand(TYPE_SERVO_1, SERVO_DEFAULT);
        handleCommand(TYPE_SERVO_2, SERVO_DEFAULT);
        handleCommand(TYPE_SERVO_3, SERVO_DEFAULT);
        return SUCCESS;
    }

    void configureSerialPort() {
        call Usart.setModeUart(&config1);
        call Usart.enableUart();
        atomic U0CTL &= ~SYNC;
    }

    void writeCommand() {
        while(!call Usart.isTxEmpty());
        call Usart.tx(buffer[0]);
        while(!call Usart.isTxEmpty());
        call Usart.tx(buffer[1]);
        while(!call Usart.isTxEmpty());
        call Usart.tx(buffer[2]);
        while(!call Usart.isTxEmpty());
        call Usart.tx(buffer[3]);
        while(!call Usart.isTxEmpty());
        call Usart.tx(buffer[4]);
        while(!call Usart.isTxEmpty());
        call Usart.tx(buffer[5]);
        while(!call Usart.isTxEmpty());
        call Usart.tx(buffer[6]);
        while(!call Usart.isTxEmpty());
        call Usart.tx(buffer[7]);
        while(!call Usart.isTxEmpty());
        // for(sendCount = 0; sendCount < 8; sendCount++) {
        //     while(!call Usart.isTxEmpty());
        //     call Usart.tx(buffer[sendCount]);
        // }

        call Resource.release();
        busy = FALSE;
    }

    event void Resource.granted() {
        configureSerialPort();
        writeCommand();
    }

    command error_t Car.Angle(uint16_t value) { return handleServoChange(TYPE_SERVO_1, value); }
    command error_t Car.Angle_Senc(uint16_t value) { return handleServoChange(TYPE_SERVO_2, value); }
    command error_t Car.Angle_Third(uint16_t value) { return handleServoChange(TYPE_SERVO_3, value); }
    command error_t Car.Forward(uint16_t value) { return handleCommand(TYPE_FORWARD, value); }
    command error_t Car.Back(uint16_t value) { return handleCommand(TYPE_BACK, value); }
    command error_t Car.Left(uint16_t value) { return handleCommand(TYPE_LEFT, value); }
    command error_t Car.Right(uint16_t value) { return handleCommand(TYPE_RIGHT, value); }
    command error_t Car.Pause() { return handleCommand(TYPE_PAUSE, 0); }
    command error_t Car.Angle_Init() { 
        initCount = 0;
        call TimerInit.startPeriodic(50); 
    }
    // command error_t Car.QuiryReader(uint8_t value) {}
    // event void Car.readDone(error_t state, uint16_t data) {}

    // command error_t Car.InitMaxSpeed(uint16_t value) {}
    // command error_t Car.InitMinSpeed(uint16_t value) {}
    // command error_t Car.InitLeftServo(uint16_t value) {}
    // command error_t Car.InitRightServo(uint16_t value) {}
    // command error_t Car.InitMidServo(uint16_t value) {}
}