// $Id: BlinkToRadioC.nc,v 1.6 2010-06-29 22:07:40 scipio Exp $

/*
 * Copyright (c) 2000-2006 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the University of California nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

/**
 * Implementation of the BlinkToRadio application.  A counter is
 * incremented and a radio message is sent whenever a timer fires.
 * Whenever a radio message is received, the three least significant
 * bits of the counter in the message payload are displayed on the
 * LEDs.  Program two motes with this application.  As long as they
 * are both within range of each other, the LEDs on both will keep
 * changing.  If the LEDs on one (or both) of the nodes stops changing
 * and hold steady, then that node is no longer receiving any messages
 * from the other node.
 *
 * @author Prabal Dutta
 * @date   Feb 1, 2006
 */
#include <Timer.h>
#include <Msp430Adc12.h>
#include "BlinkToRadio.h"

#define SPIN_ANGLE 2500
#define MOVE_SPEED 500

module BlinkToRadioC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
  uses interface Packet;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;
  uses interface Read<uint16_t> as Read1;
  uses interface Read<uint16_t> as Read2;
  uses interface Button;
}
implementation {
  message_t pkt;
  bool busy = FALSE;

  //操作信息
  bool buttons[6] = {FALSE,FALSE,FALSE,FALSE,FALSE,FALSE};
  // A:舵机1 B:舵机2 C:舵机3 D:左转 E:右转 F:停止 
  uint16_t joystick_x;
  uint16_t joystick_y;
  //当前已经获取了多少个输入
  int gotInputCount = 0;

  uint8_t currentInstruct = 0x06;
  uint8_t previousInstruct = 0x06;

  void setLeds(uint8_t val) {
    if (val & 0x01)
      call Leds.led0On();
    else 
      call Leds.led0Off();
    if (val & 0x02)
      call Leds.led1On();
    else
      call Leds.led1Off();
    if (val & 0x04)
      call Leds.led2On();
    else
      call Leds.led2Off();
  }

  void ledShowInstruct() {
    setLeds(currentInstruct);
  }

  void getInputs() {
    call Read1.read();
    call Read2.read();
    call Button.pinvalueA();
    call Button.pinvalueB();
    call Button.pinvalueC();
    call Button.pinvalueD();
    call Button.pinvalueE();
    call Button.pinvalueF();
  }

  void sendOneInstruct() {
    getInputs();
  }

  void sendInstruct() {
    BlinkToRadioMsg* sndPayload;
    int i=0;
    bool flag = FALSE;

    sndPayload = (BlinkToRadioMsg*)(call Packet.getPayload(&pkt, sizeof(BlinkToRadioMsg)));

    //检验按钮
    for (i=0;i<6;i++) {
      if (buttons[i] == TRUE) {
        switch (i){
          case 0: { //舵机1
            sndPayload->type = 0x01;
            sndPayload->data = SPIN_ANGLE;
            break;
          }
          case 1: { //舵机2
            sndPayload->type = 0x07;
            sndPayload->data = SPIN_ANGLE;
            break;
          }
          case 2: { //舵机3
            sndPayload->type = 0x08;
            sndPayload->data = SPIN_ANGLE;
            break;
          }
          case 3: { //左转
            sndPayload->type = 0x04;
            sndPayload->data = MOVE_SPEED;
            break;
          }
          case 4: { //右转
            sndPayload->type = 0x05;
            sndPayload->data = MOVE_SPEED;
            break;
          }
          case 5: { //停止
            sndPayload->type = 0x06;
            sndPayload->data = 0;
            break;
          }
          default:
            break;
        }
        flag = TRUE;
        break; 
      }
    }

    //检验摇杆
    if (flag == FALSE) {
      if ( joystick_y > 505 ){ //前进
        currentInstruct = 0x02;
        sndPayload->type = 0x02;
        sndPayload->data = MOVE_SPEED;
      }
      else if ( joystick_y < 495 ){  //后退
        currentInstruct = 0x03;
        sndPayload->type = 0x03;
        sndPayload->data = MOVE_SPEED;
      }      
      else if (joystick_x < 495 ){  //左转
        currentInstruct = 0x04;
        sndPayload->type = 0x04;
        sndPayload->data = MOVE_SPEED;
      }
      else if (joystick_x > 505){  //右转
        currentInstruct = 0x05;
        sndPayload->type = 0x05;
        sndPayload->data = MOVE_SPEED;
      }
      else {  //停止
        currentInstruct = 0x06;  
        sndPayload->type = 0x06;
        sndPayload->data = 0;
      }
    }

    //发送
    if (!busy) {
      if (sndPayload == NULL) {
        return;
      }

      ledShowInstruct();
      if (call AMSend.send(AM_SEND_ID, &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) {
        busy = TRUE;
      }
    }
  }

  event void Boot.booted() {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void Timer0.fired() {
    sendOneInstruct();
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      previousInstruct = currentInstruct;
      busy = FALSE;
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    BlinkToRadioMsg * rcvPayload;
    if (len == sizeof(BlinkToRadioMsg)) {
      rcvPayload = (BlinkToRadioMsg*)payload;
    }
    return msg;
  }

  event void Read1.readDone(error_t result, uint16_t val) {
    if (result == SUCCESS) {
      joystick_x = val;
      
      gotInputCount++;
      if (gotInputCount >= 8) {
        gotInputCount = 0;
        sendInstruct();
      }
    }
  }

  event void Read2.readDone(error_t result, uint16_t val) {
    if (result == SUCCESS) {
      joystick_y = val;

      gotInputCount++;
      if (gotInputCount >= 8) {
        gotInputCount = 0;
        sendInstruct();
      }
    }
  }

  event void Button.pinvalueADone(error_t error, bool val){
    if (error == SUCCESS){
      buttons[0] = val;
      gotInputCount++;
      if (gotInputCount >= 8) {
        gotInputCount = 0;
        sendInstruct();
      }
    }
  }
  
  event void Button.pinvalueBDone(error_t error, bool val){
    if (error == SUCCESS){
      buttons[1] = val;
      gotInputCount++;
      if (gotInputCount >= 8) {
        gotInputCount = 0;
        sendInstruct();
      }
    }
  }

  event void Button.pinvalueCDone(error_t error, bool val){
    if (error == SUCCESS){
      buttons[2] = val;
      gotInputCount++;
      if (gotInputCount >= 8) {
        gotInputCount = 0;
        sendInstruct();
      }
    }
  }

  event void Button.pinvalueDDone(error_t error, bool val){
    if (error == SUCCESS){
      buttons[3] = val;
      gotInputCount++;
      if (gotInputCount >= 8) {
        gotInputCount = 0;
        sendInstruct();
      }
    } 
  }

  event void Button.pinvalueEDone(error_t error, bool val){
    if (error == SUCCESS){
      buttons[4] = val;
      gotInputCount++;
      if (gotInputCount >= 8) {
        gotInputCount = 0;
        sendInstruct();
      }
    } 
  }

  event void Button.pinvalueFDone(error_t error, bool val){
    if (error == SUCCESS){
      buttons[5] = val;
      gotInputCount++;
      if (gotInputCount >= 8) {
        gotInputCount = 0;
        sendInstruct();
      }
    } 
  }

  event void Button.startDone(error_t error) {
    if (error != SUCCESS) {
      call Button.start();
    }
  }

  event void Button.stopDone(error_t error) {
    //todo 
  }
}
