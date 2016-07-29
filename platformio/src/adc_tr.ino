/*
Prototypical arduino/teensy code.
When reading, the first 4 bytes are the timestamp (unsigned long).
Subsequent pairs of bytes are each input channel (uint8).
So the expected size per line is 4 + (2 * n), n being the number of channels.
*/

#include "ADC.h"
#include "IntervalTimer.h"

// only the lines below needs to change
// first line does which analog channels to read,
// second line sets the sampling interval (in microseconds)
const unsigned int channel_array[2] = {A0, A7};
const unsigned long period_0 = 10000;
const unsigned int array_size = sizeof(channel_array) / sizeof(int);

unsigned int value_array[array_size];
unsigned int ii = 0;
volatile bool go_flag = false;
bool go_flag_copy = false;
elapsedMicros current_time;
unsigned long current_time_copy = 0;
IntervalTimer timer_0;

byte time_buf[4];
byte val_buf[2];

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

  time_buf[0] = current_time_copy & 255;
  time_buf[1] = (current_time_copy >> 8) & 255;
  time_buf[2] = (current_time_copy >> 16) & 255;
  time_buf[3] = (current_time_copy >> 24) & 255;

  Serial.write(time_buf, sizeof(time_buf));

  for (ii = 0; ii < array_size; ii++) {
    val_buf[0] = value_array[ii] & 255;
    val_buf[1] = (value_array[ii] >> 8) & 255;
    Serial.write(val_buf, sizeof(val_buf));
  }
}
