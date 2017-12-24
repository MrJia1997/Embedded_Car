configuration BlinkToRadioAppC {
}
implementation {
    components MainC, PrintfC;
    components BlinkToRadioC as App;
    App.Boot -> MainC;

    components LedsC;
    App.Leds -> LedsC;
    
    components CarC;
    App.Car -> CarC.Car;

    components ActiveMessageC;
    App.RadioControl -> ActiveMessageC;
    
    components new AMReceiverC(AM_BLINKTORADIOMSG);
    App.Receive -> AMReceiverC;

    components SerialActiveMessageC;
    App.Packet -> SerialActiveMessageC;
    App.SerialControl -> SerialActiveMessageC;
    App.AMSend -> SerialActiveMessageC.AMSend[AM_BLINKTORADIOMSG];
}
