module ButtonP {
    provides interface Button;
    uses {
        interface HplMsp430GeneralIO as PortA;
        interface HplMsp430GeneralIO as PortB;
        interface HplMsp430GeneralIO as PortC;
        interface HplMsp430GeneralIO as PortD;
        interface HplMsp430GeneralIO as PortE;
        interface HplMsp430GeneralIO as PortF;
    }
}
implementation{
    command void Button.start() {
        error_t error = SUCCESS;

        call PortA.clr();
        call PortA.makeInput();
        call PortB.clr();
        call PortB.makeInput();
        call PortC.clr();
        call PortC.makeInput();
        call PortD.clr();
        call PortD.makeInput();
        call PortE.clr();
        call PortE.makeInput();
        call PortF.clr();
        call PortF.makeInput();
        
        signal Button.startDone(error);
    }

    command void Button.stop() {
        error_t error = SUCCESS;

        signal Button.stopDone(error);
    }

    command void Button.pinvalueA() {
        error_t error = SUCCESS;
        bool val = call PortA.get();

        signal Button.pinvalueADone(error,val);
    }

    command void Button.pinvalueB() {
        error_t error = SUCCESS;
        bool val = call PortB.get();

        signal Button.pinvalueBDone(error,val);
    }

    command void Button.pinvalueC() {
        error_t error = SUCCESS;
        bool val = call PortC.get();

        signal Button.pinvalueCDone(error,val);
    }

    command void Button.pinvalueD() {
        error_t error = SUCCESS;
        bool val = call PortD.get();

        signal Button.pinvalueDDone(error,val);
    }

    command void Button.pinvalueE() {
        error_t error = SUCCESS;
        bool val = call PortE.get();

        signal Button.pinvalueEDone(error,val);
    }

    command void Button.pinvalueF() {
        error_t error = SUCCESS;
        bool val = call PortF.get();

        signal Button.pinvalueFDone(error,val);
    }

}
