require 'getoptlong'

# ShinyOpts is designed to be really concise for the common cases of script options.
# @opts = ShinyOpts.new do |o|
#   o.flag 'enable-stuff', 'e'
#   o.num  'retry-count', 'r'
# end
#
# @opts.enable_stuff #=> true
# @opts.retry_count #=> 5
class ShinyOpts
  def initialize(&blk)
    @accepted_opts, @gol_args, @val_map = {}, [], {}

    # yield to configure options, plus --help, which is always valid
    yield(self)
    @gol_args << ['--help', '-h', GetoptLong::NO_ARGUMENT]

    GetoptLong.new(*@gol_args).each {|opt, arg| @val_map[opt]=arg } #store results out of GetOptLong

    do_help if @val_map["--help"]
  end

  def flag(name, letter)
    @accepted_opts[name] = {:type => :flag, :letter => letter}
    @gol_args << ["--#{name}", "-#{letter}", GetoptLong::NO_ARGUMENT]
  end

  def string(name, letter)
    @accepted_opts[name] = {:type => :string, :letter => letter}
    @gol_args << ["--#{name}", "-#{letter}", GetoptLong::REQUIRED_ARGUMENT]
  end

  # for all unknown methods, we look to see if this was an option, and if so
  # return the value in the proper type for that option
  def method_missing(mname, *args, &blk)
    mname = mname.to_s.gsub(/_/, '-') # all options use dashes by convention
    raise "No arg called #{mname}" if !@accepted_opts.include?(mname)
    val = @val_map["--#{mname}"]

    case @accepted_opts[mname][:type]
      when :flag then !!val
      when :string then val
    end
  end

  private
  def do_help
    @accepted_opts.each do |name, opt|
      puts "-#{opt[:letter]}/--#{name}"
    end
    puts "-h/--help (this help message)"
    exit
  end

end
