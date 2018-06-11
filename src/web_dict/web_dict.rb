require "mechanize"
require "uri"
require "timeout"
require "logger"

module WebDict
  POSSIBLE_RESPONSES = ["400", "404", "410", "413", "414"]

  class WebDict
    def browse(keyword)
      query = URI::escape(keyword.strip())
      page = @mechanize.get("#{uri}#{query}")
      return extract_abstract(page)
    rescue Timeout::Error => e
      log_warn(e)
      return nil
    rescue Mechanize::ResponseCodeError => e
      log_warn(e) unless POSSIBLE_RESPONSES.include?(e.response_code)
      return nil
    rescue Mechanize::Error => e
      log_error(e)
      return nil
    end

    def initialize
      @mechanize = Mechanize.new()
      @mechanize.open_timeout = 2
      @mechanize.read_timeout = 2
      @mechanize.idle_timeout = 2
      @mechanize.follow_meta_refresh = true
      @logger = Logger.new(STDERR)
    end

    private

    def log_warn(error, message = nil)
      if message.nil?
        @logger.warn("#{error.to_s} in #{self.class}")
      else
        @logger.warn("#{error.to_s}: #{message} in #{self.class}")
      end
    end

    def log_error(error, message = nil)
      if message.nil?
        @logger.error("#{error.to_s} in #{self.class}")
      else
        @logger.error("#{error.to_s}: #{message} in #{self.class}")
      end
      @logger.error(error)
    end

    def extract_abstract(page)
      elem = page.search(first_elem_selector).first
      return nil if elem.nil?
      result = ""
      index = 0
      while result.length < min_num_characters &&
          !elem.nil? && read_further?(elem, index)
        unless skip_elem?(elem, index)
          elem = change_elem(elem, index)
          result << elem_to_str(elem, index)
        end
        index += 1
        elem = elem.next
      end
      result = result.strip()
      return nil if result == ""
      return result
    end

    SKIPPED_TAGS = [
      "h1", "h2", "h3", "h4", "h5", 
      "hr", "div", "img"
    ]

    EXPECTED_TAGS = [
      "p", "ul", "dl", "ol", "text",
    ] + SKIPPED_TAGS

    def uri
      raise NotImplementedError
    end

    def min_num_characters
      return 50
    end

    def first_elem_selector
      return 'p'
    end

    def skip_elem?(elem, index)
      return SKIPPED_TAGS.include?(elem.name)
    end

    def read_further?(elem, index)
      return EXPECTED_TAGS.include?(elem.name)
    end

    def change_elem(elem, index)
      return elem
    end

    def elem_to_str(elem, index)
      @li_count = 0
      result = show_elem(elem)
      result = remove_blank_lines(result).strip()
      result += "\n" unless result == ""
      return result
    end

    def show_elem(elem, parent_elem = nil)
      case elem.name
      when "ul", "ol"
        show_list(elem)
      when "li"
        show_list_item(elem, parent_elem)
      else
        return elem.text
      end
    end

    def show_list(elem)
      @li_count = 0
      result = elem.children
        .map { |e| next show_elem(e, elem).strip() }
        .select { |s| s != "" }
        .join("\n")
      return "\n" + result + "\n"
    end

    def show_list_item(elem, parent_elem)
      mark = "• "
      if !parent_elem.nil? && parent_elem.name == "ol"
        @li_count += 1
        mark = "#{@li_count}. "
      end
      children_result = elem.children
        .map { |e| next show_elem(e, elem) }
        .join()
      return add_list_mark(children_result.strip(), mark)
    end

    def remove_blank_lines(str)
      return str.gsub(/[[:space:]]*\R/, "\n")
    end

    INDENT_STR = "  "

    def add_list_mark(str, mark)
      s = str.split("\n").map.with_index do |l, i|
        next mark + l if i == 0
        next INDENT_STR + l
      end
      return s.join("\n")
    end
  end
end
