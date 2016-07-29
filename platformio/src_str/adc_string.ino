/*
Prototypical arduino/teensy code.
This one sends things as chars, which allows it to be a bit more flexible,
at the cost of efficiency. For example, sending the timestamp + two analog
channels takes 8 bytes in the more efficient code, but ~15 bytes in this code.
Additionally, you would need to parse the string on the other side.
The plus is that the output is human-readable.
*/

#include "ADC.h"
#include "IntervalTimer.h"

// only the lines below needs to change
// first line does which analog channels to read,
// second line sets the sampling interval (in microseconds)
const unsigned int channel_array[2] = {A0, A7};
const unsigned long period_0 = 100000;
const unsigned int array_size = sizeof(channel_array) / sizeof(int);

unsigned int value_array[array_size];
unsigned int ii = 0;
volatile bool go_flag = false;
bool go_flag_copy = false;
elapsedMicros current_time;
unsigned long current_time_copy = 0;
IntervalTimer timer_0;

ADC *adc = new ADC();

void setup() {
  for(ii = 0; ii < array_size; ii++) {
    pinMode(channel_array[ii], INPUT);
  }

  Serial.begin(9600);
  delay(1000);

  adc->setReference(ADC_REF_3V3, ADC_0);
  adc->setAveraging(8);
  adc->setResolution(12);
  adc->setConversionSpeed(ADC_HIGH_SPEED);
  adc->setSamplingSpeed(ADC_HIGH_SPEED);
  timer_0.priority(10);
  timer_0.begin(timerCallback, period_0);
  delay(500);
}

FASTRUN void timerCallback(void) {
  go_flag = true;
}

void loop() {

  while(!go_flag_copy) {
    noInterrupts();
    go_flag_copy = go_flag;
    interrupts();
  }
  go_flag_copy = false;
  go_flag = false;

  current_time_copy = current_time;
  for (ii = 0; ii < array_size; ii++) {
    value_array[ii] = adc->analogRead(channel_array[ii]);
  }

  Serial.print(current_time_copy);
  Serial.print(" ");

  for (ii = 0; ii < array_size; ii++) {
    Serial.print(value_array[ii]);
    Serial.print(" ");
  }
  Serial.print("\n");
}
