require "swing_servo_pi/version"
require 'wiringpi'

module SwingServoPi
  class Servo
    attr_reader :gpio, :yaw_pin, :pitch_pin

    INITIAL_POSITION = 0
    RANGE = (-10..10)
    OFFSET = 15

    def initialize(yaw_pin, pitch_pin)
      @yaw_pin = yaw_pin
      @pitch_pin = pitch_pin
      @gpio = WiringPi::GPIO.new

      pwm_init(yaw_pin)
      pwm_init(pitch_pin)
    end

    def yawing(position)
      swing(yaw_pin, position)
    end

    def pitching(position)
      swing(pitch_pin, position)
    end

    def reset
      [yaw_pin, pitch_pin].each { |pin| swing(pin, INITIAL_POSITION) }
    end

    private

    def adjust_position(position)
      if RANGE.include?(position)
        position + OFFSET
      else
        raise RangeError.new('Position is out of range. Please be between -10 and 10')
      end
    end

    def pwm_init(pin)
      gpio.pin_mode(pin, WiringPi::PWM_OUTPUT)
      gpio.soft_pwm_create(pin, adjust_position(INITIAL_POSITION), 100)
    end

    def swing(pin, position)
      gpio.soft_pwm_write(pin, adjust_position(position))
      sleep 1
      gpio.soft_pwm_write(pin, 0)
    end
  end
end
