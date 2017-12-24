COMPONENT=BlinkToRadioAppC
BUILD_EXTRA_DEPS += Handle.class
CLEAN_EXTRA = *.class Message.java
Handle.class: $(wildcard *.java) Message.java
	javac -target 1.4 -source 1.4 *.java
Message.java:
	mig java -target=null -java-classname=Message BlinkToRadio.h StepMsg -o $(@)
include $(MAKERULES)

