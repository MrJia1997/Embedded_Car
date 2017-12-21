module ButtonC {
    provides interface Button;
    uses {
        interface HplMsp430GeneralIO as HplMspGeneralIO;
    }
}
implementation{
    command void Button.start() {
        error_t error = SUCCESS;

        call HplMspGeneralIO.clr();
        call HplMspGeneralIO.makeInput();
        signal Button.startDone();
    }

    command void Button.stop() {
        error_t error = SUCCESS;

        signal Button.stopDone();
    }

    command void Button.pinvalueA() {
        error_t error = SUCCESS;
        call HplMspGeneralIO.get();

        signal Button.pinvalueADone();
    }

    command void Button.pinvalueB() {
        error_t error = SUCCESS;
        call HplMspGeneralIO.get();

        signal Button.pinvalueBDone();
    }

    command void Button.pinvalueC() {
        error_t error = SUCCESS;
        call HplMspGeneralIO.get();

        signal Button.pinvalueCDone();
    }

    command void Button.pinvalueD() {
        error_t error = SUCCESS;
        call HplMspGeneralIO.get();

        signal Button.pinvalueDDone();
    }

    command void Button.pinvalueE() {
        error_t error = SUCCESS;
        call HplMspGeneralIO.get();

        signal Button.pinvalueEDone();
    }

    command void Button.pinvalueF() {
        error_t error = SUCCESS;
        call HplMspGeneralIO.get();

        signal Button.pinvalueFDone();
    }

}
