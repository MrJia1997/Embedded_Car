#include <Timer.h>
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
    App.Car -> Car;

    components ActiveMessageC;
    App.Packet -> ActiveMessageC;
    App.RadioControl -> ActiveMessageC;
    
    components new AMReceiverC(AM_BLINKTORADIO);
    App.Receive -> AMReceiverC;

    
}
