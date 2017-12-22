configuration CarC {
    provides interface Car;
}
implementation {
    components CarP;
    Car = CarP;

    components new HplMsp430Usart0C() as HplUsart;
    components new Msp430Uart0C() as Uart;
    components new HplMsp430GeneralIOC() as HplGeneralIO;

    CarP.Usart -> HplUsart;
    CarP.Interrupts -> HplUsart;
    CarP.Resource -> Uart;
    CarP.GeneralIO -> HplGeneralIO.Port20;
}