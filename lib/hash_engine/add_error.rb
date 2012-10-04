module HashEngine
  module AddError

    def add_error(error_array, long, short)
      if error_array.first == :long
        error_array.push long
      else
        error_array.push short 
      end
    end

  end
end
