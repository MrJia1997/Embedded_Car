#include "RadioMessage.h"

configuration BlinkToRadioAppC {
}
implementation {
    components MainC;
    components BlinkToRadioC as App;
    App.Boot -> MainC;

    components LedsC;
    App.Leds -> LedsC;
    
    components CarC;
    App.Car -> CarC;

    components ActiveMessageC;
    App.RadioControl -> ActiveMessageC;
    
    components new AMReceiverC(AM_BLINKTORADIO);
    App.Receive -> AMReceiverC;

    components SerialActiveMessageC;
    App.Packet -> SerialActiveMessageC;
    App.AMSend -> SerialActiveMessageC.AMSend[AM_BLINKTORADIO];
}
