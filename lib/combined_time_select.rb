require "combined_time_select/version"

module CombinedTimeSelect
  module DateTimeSelectorWithSimpleTimeSelect
    def select_minute
      return super unless @options[:combined].eql? true

      # Although this is a datetime select, we only care about the time.  Assume that the date will
      # be set by some other control, and the date represented here will be overriden

      val_minutes = @datetime.kind_of?(Time) ? @datetime.min + @datetime.hour*60 : @datetime

      @options[:time_separator] = ""

      # Default is 15 minute intervals
      minute_interval = @options.fetch(:minute_interval, 15)

      start_minute = 0
      end_minute   = 1439

      # @options[:start_hour] should be specified in military
      # i.e. 0-23
      if @options[:start_hour]
        start_minute =  @options[:start_hour] * 60
        start_minute += @options.fetch(:start_minute, 0)
      end

      # @options[:end_hour] should be specified in military
      # i.e. 0-23
      if @options[:end_hour]
        end_minute = (@options[:end_hour] * 60) + @options.fetch(:end_minute, 59)
      end

      # @options[:additional_times] should be specified in military
      additional_times =
        Array(@options[:additional_times]).map do |time_string|
          hour_, minute_ = time_string.split(':')
          hour_.to_i * 60 + minute_.to_i
        end

      if @options[:use_hidden] || @options[:discard_minute]
        build_hidden(:minute, val)
      else
        minute_options = []
        start_minute.upto(end_minute) do |minute|
          if minute%minute_interval == 0 || minute.in?(additional_times)
            ampm = minute < 720 ? ' AM' : ' PM'
            hour = minute/60
            minute_padded = zero_pad_num(minute%60)
            hour_padded = zero_pad_num(hour)
            ampm_hour = ampm_hour(hour)

            val = "#{hour_padded}:#{minute_padded}:00"

            option_text = @options[:ampm] ? "#{ampm_hour}:#{minute_padded}#{ampm}" : "#{hour_padded}:#{minute_padded}"
            minute_options << ((val_minutes == minute) ?
              %(<option value="#{val}" selected="selected">#{option_text}</option>\n) :
              %(<option value="#{val}">#{option_text}</option>\n)
            )
          end
        end
        build_select(:minute, minute_options.join(' '))
      end
    end

    def select_hour
      return super unless @options[:combined].eql? true
      # Don't build the hour select
      #build_hidden(:hour, val)
    end

    def select_second
      return super unless @options[:combined].eql? true
      # Don't build the seconds select
      #build_hidden(:second, val)
    end

    def select_year
      return super unless @options[:combined].eql? true
      # Don't build the year select
      #build_hidden(:year, val)
    end

    def select_month
      return super unless @options[:combined].eql? true
      # Don't build the month select
      #build_hidden(:month, val)
    end

    def select_day
      return super unless @options[:combined].eql? true
      # Don't build the day select
      #build_hidden(:day, val)
    end
  end
end

ActionView::Helpers::DateTimeSelector.send(:prepend, CombinedTimeSelect::DateTimeSelectorWithSimpleTimeSelect)

module ActionController
  class Parameters
    def parse_time_select!(attribute)
      self[attribute] = Time.zone.parse("#{self["#{attribute}(1i)"]}-#{self["#{attribute}(2i)"]}-#{self["#{attribute}(3i)"]} #{self["#{attribute}(5i)"]}")
      (1..5).each { |i| self.delete "#{attribute}(#{i}i)" }
      self
    end
  end
end

def ampm_hour(hour)
  return hour == 12 ? 12 : (hour == 0 ? 12 : (hour / 12 == 1 ? hour % 12 : hour))
end

def zero_pad_num(num)
  return num < 10 ? '0' + num.to_s : num.to_s
end
