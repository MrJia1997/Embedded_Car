configuration ButtonC {
  provides interface Button;
}
implementation {
  components ButtonP;
  Button = ButtonP.Button;
  components HplMsp430GeneralIOC;
  ButtonP.PortA -> HplMsp430GeneralIOC.Port60;
  ButtonP.PortB -> HplMsp430GeneralIOC.Port21;
  ButtonP.PortC -> HplMsp430GeneralIOC.Port61;
  ButtonP.PortD -> HplMsp430GeneralIOC.Port23;
  ButtonP.PortE -> HplMsp430GeneralIOC.Port62;
  ButtonP.PortF -> HplMsp430GeneralIOC.Port26;
}