#start_date = DateTime.parse(params[:from]) rescue nil
#end_date = DateTime.parse(params[:to]) rescue nil
#
#if params[:from].is_duration?
#  start_date = get_start_date params rescue
#    error_400("'#{params[:from]}' is not a valid ISO8601 duration.")
#end
#
#if params[:to].is_duration?
#  end_date = get_end_date params rescue
#    error_400("'#{params[:to]}' is not a valid ISO8601 duration.")
#end
#
#invalid = []
#
#invalid << "'#{params[:from]}' is not a valid ISO8601 date/time." if start_date.nil? && params[:from] != "*"
#invalid << "'#{params[:to]}' is not a valid ISO8601 date/time." if end_date.nil? && params[:to] != "*"
#
#error_400(invalid.join(" ")) unless invalid.blank?
#
#if start_date != nil && end_date != nil
#  error_400("'from' date must be before 'to' date.") if start_date > end_date
#end

class DateWrangler
  def initialize left, right
    @left = left
    @right = right
  end

  def finish
    @finish ||= @right.to_seconds
  end

  def start
    @start ||= @left.to_seconds
  end

  def to
    @to ||= if @right.is_duration?
      from + finish
    else
      @right.to_datetime
    end
  end

  def from
    @from ||= if @left.is_duration?
      to - start
    else
      @left.to_datetime
    end
  end

  def errors
    {
      from: @left,
      to: @right
    }.each_pair do |method, attribute|
      begin
        self.send(method)
      rescue ISO8601::Errors::UnknownPattern
        error = "'#{attribute}' is not a valid ISO8601 duration"
        begin
          @e.push error
        rescue NameError
          @e = [error]
        end
      end
    end

    @e
  end
end

class String
  def is_duration?
    !self.match(/^P/).nil?
  end

  def to_seconds
    ISO8601::Duration.new(self).to_seconds.seconds
  end

  def to_datetime
    DateTime.parse self
  end
end
