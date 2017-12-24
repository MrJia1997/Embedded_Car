#include "RadioMessage.h"
#include <printf.h>

module BlinkToRadioC {
    uses interface Boot;
    uses interface Leds;
    uses interface Car;
    uses interface Packet;
    uses interface AMSend;
    uses interface Receive;
    uses interface SplitControl as RadioControl;
    uses interface SplitControl as SerialControl;
}

implementation {
    message_t pkt;
    BlinkToRadioMsg local;
    bool busy;
    
    event void Boot.booted() {
        call RadioControl.start();
        call SerialControl.start();
        printf("Boot", "Boot complete");
    }

    event void RadioControl.startDone(error_t err) {
        if (err != SUCCESS) 
            call RadioControl.start();
    }

    event void SerialControl.startDone(error_t err) {
        if (err != SUCCESS) 
            call SerialControl.start();
    }

    event void RadioControl.stopDone(error_t err) {}
    event void SerialControl.stopDone(error_t err) {}

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
        BlinkToRadioMsg* sndPayload;

        if (len != sizeof(BlinkToRadioMsg)) {
            return NULL;
        }
        
        rcvPayload = (BlinkToRadioMsg*)payload;
        sndPayload = (BlinkToRadioMsg*)(call Packet.getPayload(&pkt, sizeof(BlinkToRadioMsg)));
        if (sndPayload == NULL) {
            call Leds.led0On();
            return NULL;
        }
        
        local.type = rcvPayload->type;
        local.data = rcvPayload->data;
        // setLeds(local.type);
        // call Leds.led0Toggle();
        switch(local.type){
            case 1: call Car.Angle(local.data); break;
            case 2: call Car.Forward(local.data); break;
            case 3: call Car.Back(local.data); break;
            case 4: call Car.Left(local.data); break;
            case 5: call Car.Right(local.data); break;
            case 6: call Car.Pause(); break;
            case 7: call Car.Angle_Senc(local.data); break;
            case 8: call Car.Angle_Third(local.data); break;
            default: clearLeds();
        }
        
        memcpy(sndPayload, rcvPayload ,sizeof(BlinkToRadioMsg));

        if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) {
            busy = TRUE;
            // call Leds.led1Toggle();
        }
        // printf("Radio", "Type: %u and Value: %u\n", local.type, local.data); 

        return msg;
    }

    event void AMSend.sendDone(message_t* msg, error_t err) {
        if (&pkt == msg) {
            busy = FALSE;
        }
    }
}