configuration CarC {
    provides interface Car;
}
implementation {
    components CarP;
    Car = CarP.Car;

    components LedsC;
    CarP.Leds -> LedsC;

    components new TimerMilliC() as TimerInit;
    CarP.TimerInit -> TimerInit;

    components HplMsp430Usart0C as HplUsart;
    components new Msp430Uart0C() as Uart;
    components HplMsp430GeneralIOC as HplGeneralIO;

    CarP.Usart -> HplUsart;
    // CarP.Interrupts -> HplUsart;
    CarP.Resource -> Uart;
    CarP.GeneralIO -> HplGeneralIO.Port20;
}