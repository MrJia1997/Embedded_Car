
interface Button {
    command void start();
    event void startDone(error_t error);
    command void stop();
    event void stopDone(error_t error);

    command void pinvalueA();
    event void pinvalueADone(error_t error,bool val);
    command void pinvalueB();
    event void pinvalueBDone(error_t error,bool val);
    command void pinvalueC();
    event void pinvalueCDone(error_t error,bool val);
    command void pinvalueD();
    event void pinvalueDDone(error_t error,bool val);
    command void pinvalueE();
    event void pinvalueEDone(error_t error,bool val);
    command void pinvalueF();
    event void pinvalueFDone(error_t error,bool val);
}