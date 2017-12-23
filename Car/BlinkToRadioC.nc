#include <Timer.h>
#include "RadioMessage.h"

module BlinkToRadioC {
    uses interface Boot;
    uses interface Leds;
    uses interface Car;
    uses interface Packet;
    uses interface Receive;
    uses interface SplitControl as RadioControl;
}

implementation {
    message_t pkt;
    
    event void Boot.booted() {
        call RadioControl.start();
    }

    event void RadioControl.startDone(error_t err) {
        if (err != SUCCESS) 
            call RadioControl.start();
    }

    event void RadioControl.stopDone(error_t err) {}

    void setLeds(uint8_t val) {
        if (val & 0x01)
            call Leds.led0On();
        else 
            call Leds.led0Off();
        if (val & 0x02)
            call Leds.led1On();
        else
            call Leds.led1Off();
        if (val & 0x04)
            call Leds.led2On();
        else
            call Leds.led2Off();
    }

    void clearLeds() {
        call Leds.led0Off();
        call Leds.led1Off();
        call Leds.led2Off();
    }

    event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
        BlinkToRadioMsg* rcvPayload;
        uint8_t type;
        uint16_t value;

        rcvPayload = (BlinkToRadioMsg*)msg;
        if (len != sizeof(BlinkToRadioMsg)) {
            return NULL;
        }
        type = rcvPayload->type;
        value = rcvPayload->data;
        setLeds(type);

        switch(type){
            case 1: call Car.Angle(value); break;
            case 2: call Car.Forward(value); break;
            case 3: call Car.Back(value); break;
            case 4: call Car.Left(value); break;
            case 5: call Car.Right(value); break;
            case 6: call Car.Pause(); break;
            case 7: call Car.Angle_Senc(value); break;
            case 8: call Car.Angle_Third(value); break;
            default: clearLeds();
        }
        
        return msg;
    }
}